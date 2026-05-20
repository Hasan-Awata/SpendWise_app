using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.OcrScanning;
using SpendWise.Domain.ProcessingResults;
using System;
using System.IO;
using System.Linq;
using System.Threading;
using Tesseract;

namespace SpendWise.Infrastructure.ExternalServices;

public class TesseractOcrEngine : IOcrEngine, IDisposable
{
    private readonly TesseractEngine _engine;
    // Ensures only one thread uses the native engine at a time
    private readonly SemaphoreSlim _semaphore = new SemaphoreSlim(1, 1);

    public TesseractOcrEngine(IConfiguration configuration)
    {
        string tessDataPath = configuration["OcrSettings:TessDataPath"] ?? "./tessdata";
        string language = configuration["OcrSettings:Language"] ?? "eng+ara";

        tessDataPath = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, tessDataPath));

        if (!Directory.Exists(tessDataPath))
        {
            throw new DirectoryNotFoundException($"Tessdata directory not found at: '{tessDataPath}'.");
        }

        // Instantiate the heavy native engine exactly once
        _engine = new TesseractEngine(tessDataPath, language, EngineMode.Default);

        _engine.SetVariable("tessedit_char_whitelist", "");   // no whitelist — allow all chars
        _engine.SetVariable("classify_bln_numeric_mode", "0");
        _engine.SetVariable("textord_heavy_nr", "1");          // better number row detection
    }

    public OcrResult ExtractText(byte[] imageBytes)
    {
        // Block other incoming API requests from using the engine until this one finishes
        _semaphore.Wait();
        try
        {
            using var img = Pix.LoadFromMemory(imageBytes);
            using var page = _engine.Process(img, PageSegMode.Auto);

            var rawText = page.GetText();

            var lines = rawText
                .Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                .Select(line => line.Trim())
                .Where(line => !string.IsNullOrWhiteSpace(line))
                .ToList();

            return new OcrResult
            {
                RawText = rawText,
                //Products = lines,
                IsSuccess = true
            };
        }
        catch (Exception ex)
        {
            return new OcrResult
            {
                IsSuccess = false,
                ErrorMessage = $"OCR Processing Failed: {ex.Message}"
            };
        }
        finally
        {
            // Always release the lock so the next request can process
            _semaphore.Release();
        }
    }

    public void Dispose()
    {
        _engine?.Dispose();
        _semaphore?.Dispose();
    }
}