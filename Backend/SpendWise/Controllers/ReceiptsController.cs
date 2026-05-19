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
    public IActionResult ProcessReceipt(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("Please upload a valid receipt image.");

        using var memoryStream = new MemoryStream();
        file.CopyTo(memoryStream);
        byte[] imageBytes = memoryStream.ToArray();

        var result = _ocrService.ProcessReceipt(imageBytes);

        if (!result.IsSuccess)
            return StatusCode(500, result.ErrorMessage);

        return Ok(new { text = result.RawText, lines = result.Lines });
    }
}