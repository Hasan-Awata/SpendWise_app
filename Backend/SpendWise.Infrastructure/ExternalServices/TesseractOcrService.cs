using SpendWise.Application.Interfaces.OcrScanning;
using SpendWise.Domain.ProcessingResults;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public class TesseractOcrService
    {
        private readonly IImageProcessor _imageProcessor;
        private readonly IOcrEngine _ocrEngine;

        public TesseractOcrService(IImageProcessor imageProcessor, IOcrEngine engine)
        {
            _imageProcessor = imageProcessor;
            _ocrEngine = engine;
        }

        public OcrResult ProcessReceipt(byte[] rawImageFile)
        {
            if (rawImageFile == null || rawImageFile.Length == 0)
            {
                return new OcrResult { IsSuccess = false, ErrorMessage = "No image data provided." };
            }

            // 1. Run OpenCV Cleanup
            byte[] cleanImage = _imageProcessor.PolishReceipt(rawImageFile);

            // 2. Run Tesseract Extraction
            OcrResult ocrResult = _ocrEngine.ExtractText(cleanImage);

            // 3. Return Core Domain Object
            return ocrResult;
        }
    }
}
