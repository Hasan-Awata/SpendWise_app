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
    }
}
