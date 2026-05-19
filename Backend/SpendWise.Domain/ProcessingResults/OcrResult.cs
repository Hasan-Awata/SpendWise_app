using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.ProcessingResults
{
    public class OcrResult
    {
        public string RawText { get; set; } = string.Empty;
        public List<string> Lines {  get; set; } = new List<string>();
        public bool IsSuccess { get; set; }
        public string? ErrorMessage { get; set; }
    }
}
