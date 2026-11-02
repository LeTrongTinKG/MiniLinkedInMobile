import io
import re
from typing import List, Optional

import pdfplumber

# Từ điển kỹ năng: tên chuẩn + bí danh (khớp server/src/services/ai/skillsDictionary.js)
SKILLS: list[list[str]] = [
    ["flutter"], ["dart"], ["git", "github", "gitlab"], ["firebase"],
    ["rest api", "restful", "restful api", "rest"], ["react", "reactjs", "react.js"],
    ["javascript", "es6"], ["html", "html5"], ["css", "css3"], ["typescript"],
    ["tailwind", "tailwindcss"], ["nodejs", "node.js", "node js", "node"],
    ["postgresql", "postgres"], ["docker"], ["python"],
    ["machine learning", "ml"], ["tensorflow"], ["pandas"], ["java"],
    ["spring boot", "springboot", "spring"], ["sql"], ["microservices", "microservice"],
    ["redux"], ["graphql"], ["bloc"], ["kubernetes", "k8s"], ["redis"], ["linux"],
    ["ci/cd", "cicd", "ci cd"], ["terraform"], ["aws", "amazon web services"],
    ["state management", "provider", "riverpod"], ["spark", "apache spark"], ["kafka"],
    ["airflow"], ["selenium"], ["appium"], ["postman"], ["swift"], ["ios"], ["xcode"],
    ["combine"], ["swiftui"], ["kotlin"], ["android"], ["android studio"],
    ["jetpack compose"], ["coroutines"], ["excel"], ["tableau"], ["bigquery"],
    ["react native"], ["reanimated"], ["go", "golang"], ["grpc"], ["monitoring"],
    ["pytorch"], ["mlops"], ["huggingface", "hugging face"], ["vue", "vuejs", "vue.js"],
    ["pinia"], ["fastapi"], ["expo"], ["php"], ["mysql"], ["laravel"], ["nuxt"],
    ["mongodb", "mongo"], ["query optimization"], ["hilt"], ["core data"], ["jest"],
    ["backup"], ["replication"], ["performance tuning"],
]


def _build_patterns() -> list[dict]:
    """Khớp nguyên từ, không dính chữ/số hai bên (tránh 'go' trong 'good', 'java' trong 'javascript')."""
    result = []
    for names in SKILLS:
        regexes = [re.compile(rf"(?<![a-z0-9]){re.escape(term)}(?![a-z0-9])") for term in names]
        result.append({"name": names[0], "regexes": regexes})
    return result


PATTERNS = _build_patterns()


def extract_pdf_text(file_bytes: bytes) -> str:
    """Đọc chữ trong PDF bằng pdfplumber. Ném lỗi nếu file không hợp lệ."""
    with pdfplumber.open(io.BytesIO(file_bytes)) as pdf:
        pages = []
        for page in pdf.pages:
            text = page.extract_text()
            if text:
                pages.append(text)
        return "\n".join(pages)


def find_skills(text: str) -> List[str]:
    """Dò kỹ năng trong chữ CV bằng từ điển và regex."""
    lines = text.split("\n")
    found = []
    for pattern in PATTERNS:
        for line in lines:
            if any(r.search(line.lower()) for r in pattern["regexes"]):
                found.append(pattern["name"])
                break
    return found


def find_experience_months(text: str) -> int:
    years = re.search(r"(\d+(?:[.,]\d+)?)\s*(?:năm|years?)\s+(?:kinh nghiệm|experience)", text, re.IGNORECASE)
    if years:
        return round(float(years.group(1).replace(",", ".")) * 12)
    months = re.search(r"(\d+)\s*(?:tháng|months?)\s+(?:kinh nghiệm|experience)", text, re.IGNORECASE)
    return int(months.group(1)) if months else 0


def find_education(text: str) -> Optional[str]:
    for line in text.split("\n"):
        if re.search(r"đại học|university|học viện|college", line, re.IGNORECASE):
            return line.strip()[:120]
    return None


def analyze_pdf(file_bytes: bytes) -> dict:
    """Trích xuất kỹ năng, học vấn, kinh nghiệm từ file PDF."""
    text = extract_pdf_text(file_bytes)
    return {
        "skills": find_skills(text),
        "education": find_education(text),
        "experience_months": find_experience_months(text),
    }
