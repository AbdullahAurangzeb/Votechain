const fs = require('fs/promises');
const { env } = require('../config/env');
const AppError = require('../utils/AppError');

/**
 * Forwards CNIC images to the VoteChain FastAPI OCR microservice.
 */
class AiOcrService {
  /**
   * Sends an uploaded image to the AI service and returns OCR output.
   * @param {Express.Multer.File} file
   * @returns {Promise<{ rawText: string[], parsed: object }>}
   */
  async extractFromImage(file) {
    if (!file?.path) {
      throw new AppError('CNIC image is required', 400);
    }

    const formData = new FormData();
    const buffer = await fs.readFile(file.path);
    const blob = new Blob([buffer], { type: file.mimetype });
    formData.append('image', blob, file.originalname || 'cnic.jpg');

    let response;

    try {
      response = await fetch(`${env.aiService.baseUrl}/ocr/extract`, {
        method: 'POST',
        body: formData,
      });
    } catch (error) {
      throw new AppError('Unable to reach OCR service', 503);
    }

    const body = await response.json().catch(() => null);

    if (!response.ok) {
      const message =
        body?.message || body?.detail || 'OCR service request failed';
      throw new AppError(message, response.status);
    }

    if (!body?.success) {
      throw new AppError(body?.message || 'OCR extraction failed', 502);
    }

    return {
      rawText: Array.isArray(body.rawText) ? body.rawText : [],
      parsed: body.parsed || {},
    };
  }
}

module.exports = new AiOcrService();
