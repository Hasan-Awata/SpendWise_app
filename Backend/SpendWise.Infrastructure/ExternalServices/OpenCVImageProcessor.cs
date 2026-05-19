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
            // Decode the raw byte array into an OpenCV Mat object
            using var src = Mat.FromImageData(imageBytes, ImreadModes.Color);
            using var gray = new Mat();
            using var blurred = new Mat();
            using var binarized = new Mat();

            if (src.Empty())
                throw new ArgumentException("The uploaded file is not a valid image.");

            // 1. Convert to Grayscale
            Cv2.CvtColor(src, gray, ColorConversionCodes.BGR2GRAY);

            // 2. Apply Gaussian Blur to reduce high-frequency noise
            Cv2.GaussianBlur(gray, blurred, new Size(3, 3), 0);

            // 3. Apply Adaptive Thresholding for crisp black/white separation (ideal for text)
            Cv2.AdaptiveThreshold(
                blurred,
                binarized,
                255,
                AdaptiveThresholdTypes.MeanC,
                ThresholdTypes.Binary,
                11,
                2);

            // Add this inside OpenCvImageProcessor if Arabic text recognition is faint:
            //using var structuringElement = Cv2.GetStructuringElement(StructuringElementShape.Rect, new Size(2, 2));
            //Cv2.Dilate(binarized, binarized, structuringElement);

            // Encode the processed image back into a byte array
            return binarized.ToBytes(".png");
        }
    }
}
