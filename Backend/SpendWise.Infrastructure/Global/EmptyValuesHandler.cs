using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Infrastructure.Global
{
    public class EmptyValuesHandler
    {
        public static decimal GetDecimalOrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? 0m : reader.GetDecimal(ordinal);
        }
        public static int GetInt32OrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? 0 : reader.GetInt32(ordinal);
        }
        public static string GetStringOrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? "" : reader.GetString(ordinal);
        }
        public static DateTime GetDateTimeOrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? default : reader.GetDateTime(ordinal);
        }
        public static bool GetBooleanOrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return !reader.IsDBNull(ordinal) && reader.GetBoolean(ordinal);
        }

        // Maps to SQL 'bigint'
        public static long GetInt64OrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? 0L : reader.GetInt64(ordinal);
        }

        // Maps to SQL 'smallint'
        public static short GetInt16OrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? (short)0 : reader.GetInt16(ordinal);
        }

        // Maps to SQL 'tinyint'
        public static byte GetByteOrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? (byte)0 : reader.GetByte(ordinal);
        }

        // Maps to SQL 'float'
        public static double GetDoubleOrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? 0d : reader.GetDouble(ordinal);
        }

        // Maps to SQL 'real'
        public static float GetFloatOrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? 0f : reader.GetFloat(ordinal);
        }

        // Maps to SQL 'uniqueidentifier'
        public static Guid GetGuidOrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? Guid.Empty : reader.GetGuid(ordinal);
        }

        // Maps to SQL 'varbinary', 'binary', or 'image'
        public static byte[] GetBytesOrDefault(SqlDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? Array.Empty<byte>() : (byte[])reader.GetValue(ordinal);
        }
    }
}
