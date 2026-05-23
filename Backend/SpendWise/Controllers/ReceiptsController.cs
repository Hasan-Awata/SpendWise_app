using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.Interfaces.OcrScanning;
using SpendWise.Application.Services;

namespace SpendWise.Controllers;

[ApiController]
[Route("api/ocr")]
public class ReceiptsController : ControllerBase
{
    private readonly IOcrService _ocrService;

    public ReceiptsController(IOcrService ocrOrchestrator)
    {
        _ocrService = ocrOrchestrator;
    }

    [HttpPost]
    public async Task<IActionResult> ScanReceipt(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("Please upload a valid receipt image.");

        // Detect mime type from the actual file, not the extension
        var mimeType = file.ContentType switch
        {
            "image/webp" => "image/webp",
            "image/png" => "image/png",
            "image/jpeg" => "image/jpeg",
            _ => "image/jpeg"
        };

        using var ms = new MemoryStream();
        await file.CopyToAsync(ms);

        var result = await _ocrService.ProcessReceipt(ms.ToArray(), mimeType);

        if (!result.IsSuccess)
            return StatusCode(500, result.ErrorMessage);

        return Ok(result);
    }
}