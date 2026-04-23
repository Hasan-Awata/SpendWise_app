import pyodbc # Requires installation of pyodbc package (pip install pyodbc)
import os

def dump_database_procedures(output_file):
    # Using the local connection string from your appsettings.Development.json
    conn_str = (
        "Driver={ODBC Driver 17 for SQL Server};"
        "Server=.;"
        "Database=SpendWiseDB;"
        "Trusted_Connection=yes;"
    )

    # This SQL query looks inside the database's brain to get your procedure code
    query = """
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
        cursor.execute(query)

        successful_procs = 0

        with open(output_file, 'w', encoding='utf-8') as outfile:
            outfile.write("=========================================\n")
            outfile.write(" SPENDWISE DATABASE STORED PROCEDURES\n")
            outfile.write("=========================================\n\n")

            for row in cursor:
                schema_name = row.SchemaName
                proc_name = row.ProcedureName
                script = row.Script

                # Write the header for each procedure
                outfile.write(f"-- =========================================\n")
                outfile.write(f"-- Schema: [{schema_name}] | Procedure: [{proc_name}]\n")
                outfile.write(f"-- =========================================\n")
                
                # Write the actual SQL code
                outfile.write(script)
                outfile.write("\nGO\n\n")
                
                print(f"[SUCCESS] Dumped: [{schema_name}].[{proc_name}]")
                successful_procs += 1

        print("\n" + "="*50)
        print("DATABASE DUMP COMPLETE!")
        print(f"Total procedures successfully dumped: {successful_procs}")
        print(f"Output saved to: {output_file}")
        print("="*50)

    except pyodbc.Error as e:
        print(f"\n[DATABASE ERROR] Could not connect or query the database:\n{e}")
    except Exception as e:
        print(f"\n[ERROR] An unexpected error occurred:\n{e}")

if __name__ == "__main__":
    # Name of the output text file
    output_filename = "database_procedures_dump.sql"
    dump_database_procedures(output_filename)