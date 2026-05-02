import pyodbc # Requires installation of pyodbc package (pip install pyodbc)
import os

def dump_database_schema_and_procedures(output_file):
    # Using the local connection string from your appsettings.Development.json
    conn_str = (
        "Driver={ODBC Driver 17 for SQL Server};"
        "Server=.;"
        "Database=SpendWiseDB;"
        "Trusted_Connection=yes;"
    )

    # SQL query to get Table Schema (Columns, Types, Lengths, Nullability)
    table_query = """
    SELECT 
        s.name AS SchemaName, 
        t.name AS TableName, 
        c.name AS ColumnName, 
        ty.name AS DataType, 
        c.max_length AS MaxLength, 
        c.is_nullable AS IsNullable
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.columns c ON t.object_id = c.object_id
    INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
    WHERE t.is_ms_shipped = 0 -- Exclude system tables
    ORDER BY s.name, t.name, c.column_id;
    """

    # SQL query to get Stored Procedures
    proc_query = """
    SELECT s.name AS SchemaName, o.name AS ProcedureName, m.definition AS Script
    FROM sys.sql_modules m
    INNER JOIN sys.objects o ON m.object_id = o.object_id
    INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
    WHERE o.type = 'P' -- 'P' stands for SQL Stored Procedure
    ORDER BY s.name, o.name;
    """

    print("Connecting to SQL Server (SpendWiseDB)...")
    
    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()

        with open(output_file, 'w', encoding='utf-8') as outfile:
            outfile.write("=========================================\n")
            outfile.write(" SPENDWISE DATABASE FULL DUMP\n")
            outfile.write("=========================================\n\n")

            # ---------------------------------------------------------
            # 1. DUMP TABLE SCHEMAS
            # ---------------------------------------------------------
            print("Fetching table schemas...")
            cursor.execute(table_query)
            
            tables = {}
            for row in cursor:
                schema_name, table_name, col_name, data_type, max_len, is_nullable = row
                table_key = f"[{schema_name}].[{table_name}]"

                if table_key not in tables:
                    tables[table_key] = []

                # Format data types with character lengths (e.g., varchar(50))
                if data_type in ('varchar', 'nvarchar', 'char', 'nchar', 'varbinary'):
                    if max_len == -1:
                        length_str = "MAX"
                    else:
                        # nvarchar/nchar store 2 bytes per char, so we divide by 2
                        length_str = str(max_len // 2) if 'n' in data_type else str(max_len)
                    
                    type_str = f"{data_type}({length_str})"
                else:
                    type_str = data_type

                null_str = "NULL" if is_nullable else "NOT NULL"
                tables[table_key].append(f"    [{col_name}] {type_str} {null_str}")

            outfile.write("-- =========================================\n")
            outfile.write("-- TABLES \n")
            outfile.write("-- =========================================\n\n")

            for table_key, columns in tables.items():
                outfile.write(f"CREATE TABLE {table_key} (\n")
                outfile.write(",\n".join(columns))
                outfile.write("\n);\nGO\n\n")
                print(f"[SUCCESS] Dumped Schema: {table_key}")

            # ---------------------------------------------------------
            # 2. DUMP STORED PROCEDURES
            # ---------------------------------------------------------
            print("\nFetching stored procedures...")
            cursor.execute(proc_query)
            successful_procs = 0

            outfile.write("-- =========================================\n")
            outfile.write("-- STORED PROCEDURES \n")
            outfile.write("-- =========================================\n\n")

            for row in cursor:
                schema_name = row.SchemaName
                proc_name = row.ProcedureName
                script = row.Script

                # Write the header for each procedure
                outfile.write(f"-- Schema: [{schema_name}] | Procedure: [{proc_name}]\n")
                
                # Write the actual SQL code
                outfile.write(script)
                outfile.write("\nGO\n\n")
                
                print(f"[SUCCESS] Dumped Proc: [{schema_name}].[{proc_name}]")
                successful_procs += 1

        print("\n" + "="*50)
        print("DATABASE DUMP COMPLETE!")
        print(f"Total tables dumped: {len(tables)}")
        print(f"Total procedures dumped: {successful_procs}")
        print(f"Output saved to: {output_file}")
        print("="*50)

    except pyodbc.Error as e:
        print(f"\n[DATABASE ERROR] Could not connect or query the database:\n{e}")
    except Exception as e:
        print(f"\n[ERROR] An unexpected error occurred:\n{e}")

if __name__ == "__main__":
    # Updated output filename to reflect full schema + procedures
    output_filename = "spendwise_full_database_dump.sql"
    dump_database_schema_and_procedures(output_filename)