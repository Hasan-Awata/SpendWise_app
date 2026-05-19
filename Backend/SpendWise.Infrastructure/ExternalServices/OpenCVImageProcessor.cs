using OpenCvSharp;
using SpendWise.Application.Interfaces.OcrScanning;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Infrastructure.ExternalServices
{
    public class OpenCVImageProcessor: IImageProcessor
    {
        public byte[] PolishReceipt(byte[] imageBytes)
        {
            using var src = Mat.FromImageData(imageBytes, ImreadModes.Color);

            if (src.Empty())
                throw new ArgumentException("The uploaded file is not a valid image.");

            using var gray = new Mat();
            using var upscaled = new Mat();
            using var denoised = new Mat();
            using var sharpened = new Mat();

            // 1. Grayscale
            Cv2.CvtColor(src, gray, ColorConversionCodes.BGR2GRAY);

            // 2. Upscale 2x — Tesseract reads larger characters far more accurately
            Cv2.Resize(gray, upscaled, new Size(gray.Width * 2, gray.Height * 2),
                interpolation: InterpolationFlags.Cubic);

            // 3. Light denoise — preserves edges better than GaussianBlur for clean images
            Cv2.FastNlMeansDenoising(upscaled, denoised, h: 3, templateWindowSize: 7, searchWindowSize: 21);

            // 4. Sharpen to make character edges crisp
            var kernel = Mat.FromArray(new float[,]
            {
                {  0, -1,  0 },
                { -1,  5, -1 },
                {  0, -1,  0 }
            });

            Cv2.Filter2D(denoised, sharpened, -1, kernel);

            // 5. Simple Otsu threshold — much better than AdaptiveThreshold for clean/evenly lit receipts
            using var binary = new Mat();
            Cv2.Threshold(sharpened, binary, 0, 255, ThresholdTypes.Binary | ThresholdTypes.Otsu);

            return binary.ToBytes(".png");
        }
    }
}
