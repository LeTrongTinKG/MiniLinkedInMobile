class AiServiceError extends Error {
  constructor(code, message, status = 502) {
    super(message);
    this.name = "AiServiceError";
    this.code = code;
    this.status = status;
  }
}

module.exports = { AiServiceError };
