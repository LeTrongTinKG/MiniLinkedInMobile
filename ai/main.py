from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(
    title="Mini LinkedIn AI Service",
    description="AI Service phân tích CV và chấm điểm độ phù hợp Job",
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
    return {"message": "Mini LinkedIn AI Service is running"}

@app.get("/health")
def health_check():
    return {"status": "ok", "service": "ai"}

@app.post("/analyze-cv", response_model=AnalyzeCvResponse)
async def analyze_cv(file: UploadFile = File(...)):
    """
    Trích xuất kỹ năng, học vấn, kinh nghiệm từ file PDF CV
    (Mock implementation phục vụ giai đoạn đầu)
    """
    # TODO (AI Track): Đọc nội dung PDF bằng pdfplumber và trích xuất thực tế
    return AnalyzeCvResponse(
        skills=["flutter", "dart", "git", "rest api"],
        education="CNTT Đại học",
        experience_months=6
    )

@app.post("/match", response_model=MatchResponse)
def match_cv_job(request: MatchRequest):
    """
    Chấm điểm độ phù hợp giữa kỹ năng trong CV và yêu cầu Job
    """
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

