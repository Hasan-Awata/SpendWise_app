// SpendWise.Infrastructure/ExternalServices/TesseractOcrService.cs
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces;
using SpendWise.Application.Interfaces.OcrScanning;
using SpendWise.Domain.Entities;
using SpendWise.Domain.ProcessingResults;
using Tesseract;

namespace SpendWise.Infrastructure.ExternalServices;

public class TesseractOcrEngine : IOcrEngine
{
    private readonly string _tessDataPath;
    private readonly string _language;

    public TesseractOcrEngine(IConfiguration configuration)
    {
        _tessDataPath = configuration["OcrSettings:TessDataPath"] ?? "./tessdata";
        _language = configuration["OcrSettings:Language"] ?? "eng+ara";

        // Clean up and resolve the path to a pure native absolute path
        // e.g., converts "C:\YourApp\bin\Debug\net8.0\./tessdata" to "C:\YourApp\bin\Debug\net8.0\tessdata"
        _tessDataPath = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, _tessDataPath));

        // Safety verification: If this fails, it throws a safe C# exception instead of a native crash
        if (!Directory.Exists(_tessDataPath))
        {
            throw new DirectoryNotFoundException(
                $"Tessdata directory not found at resolved absolute path: '{_tessDataPath}'. " +
                "Ensure the folder exists and contains your .traineddata files.");
        }

    }

    public OcrResult ExtractText(byte[] imageBytes)
    {
        try
        {
            // Initialize engine with multi-language capabilities
            using var engine = new TesseractEngine(_tessDataPath, _language, EngineMode.Default);

            //// Optional: Ensure digits are parsed correctly alongside Arabic script
            //engine.SetVariable("textord_blocksrestr", "1");

            using var img = Pix.LoadFromMemory(imageBytes);
            using var page = engine.Process(img, PageSegMode.SingleBlock);

            var rawText = page.GetText();

            // Clean up lines while preserving RTL characters
            var lines = rawText
                .Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                .Select(line => line.Trim())
                .Where(line => !string.IsNullOrWhiteSpace(line))
                .ToList();

            return new OcrResult
            {
                RawText = rawText,
                Lines = lines,
                IsSuccess = true
            };
        }
        catch (Exception ex)
        {
            return new OcrResult
            {
                IsSuccess = false,
                ErrorMessage = $"OCR Processing Failed (Multi-language): {ex.Message}"
            };
        }
    }
}

