using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.OcrScanning
{
    public interface IImageProcessor
    {
        byte[] PolishReceipt(byte[] image);
    }
}
