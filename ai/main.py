import logging

from fastapi import FastAPI, UploadFile, File, HTTPException
from pydantic import BaseModel
from typing import List, Optional

from extractor import analyze_pdf

logger = logging.getLogger("ai-service")

app = FastAPI(
    title="Atom AI Service",
    description="AI Service phân tích CV và chấm điểm độ phù hợp Job - Atom",
    version="1.0.0"
)

class JobData(BaseModel):
    title: str
    required_skills: List[str]
    nice_to_have: Optional[List[str]] = []
    description: Optional[str] = ""

class MatchRequest(BaseModel):
    cv_skills: List[str]
    job: JobData

class AnalyzeCvResponse(BaseModel):
    skills: List[str]
    education: Optional[str] = None
    experience_months: Optional[int] = 0

class MatchResponse(BaseModel):
    score: int
    matched_skills: List[str]
    missing_skills: List[str]
    suggestion: Optional[str] = None

@app.get("/")
def read_root():
    return {"message": "Atom AI Service is running"}

@app.get("/health")
def health_check():
    return {"status": "ok", "service": "ai"}

@app.post("/analyze-cv", response_model=AnalyzeCvResponse)
async def analyze_cv(file: UploadFile = File(...)):
    if not file.filename or not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Chỉ chấp nhận file PDF")

    content = await file.read()
    if len(content) < 5:
        raise HTTPException(status_code=400, detail="File rỗng hoặc quá nhỏ")
    # Kiểm tra magic bytes PDF (%PDF)
    if content[:4] != b"%PDF":
        raise HTTPException(status_code=400, detail="File không phải định dạng PDF hợp lệ")

    try:
        result = analyze_pdf(content)
    except Exception as exc:
        logger.warning("Không đọc được PDF: %s", exc)
        return AnalyzeCvResponse(skills=[], education=None, experience_months=0)

    return AnalyzeCvResponse(
        skills=result["skills"],
        education=result["education"],
        experience_months=result["experience_months"],
    )

@app.post("/match", response_model=MatchResponse)
def match_cv_job(request: MatchRequest):

    cv_skills_lower = [s.strip().lower() for s in request.cv_skills]
    req_skills_lower = [s.strip().lower() for s in request.job.required_skills]

    matched = [s for s in req_skills_lower if s in cv_skills_lower]
    missing = [s for s in req_skills_lower if s not in cv_skills_lower]

    total_req = len(req_skills_lower)
    score = int((len(matched) / total_req * 100)) if total_req > 0 else 100

    suggestion = None
    if missing:
        suggestion = f"Bạn nên bổ sung hoặc học thêm về: {', '.join(missing)}"
    else:
        suggestion = "Hồ sơ của bạn đáp ứng rất tốt các yêu cầu bắt buộc của công việc này!"

    return MatchResponse(
        score=score,
        matched_skills=matched,
        missing_skills=missing,
        suggestion=suggestion
    )
