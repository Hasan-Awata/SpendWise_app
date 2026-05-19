using SpendWise.Domain.ProcessingResults;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.OcrScanning
{
    public interface IOcrService
    {
        public OcrResult ProcessReceipt(byte[] rawImageFile);
    }
}
