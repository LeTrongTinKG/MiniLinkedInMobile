import io
import os
import pytest
from fastapi.testclient import TestClient

from extractor import (
    PATTERNS,
    SKILLS,
    analyze_pdf,
    extract_pdf_text,
    find_education,
    find_experience_months,
    find_skills,
)
from main import app

client = TestClient(app)

FIXTURES_DIR = os.path.join(os.path.dirname(__file__), "..", "server", "test", "fixtures")
SAMPLE_PDF_PATH = os.path.join(FIXTURES_DIR, "cv-sample.pdf")


# ============================================================================
# 1. UNIT TESTS: EXTRACTOR LOGIC
# ============================================================================

class TestExtractorUnit:
    """Kiểm tra logic trích xuất kỹ năng, kinh nghiệm, học vấn từ văn bản."""

    def test_skills_dictionary_and_patterns_loaded(self):
        """Từ điển kỹ năng phải có ít nhất 60 skill và pattern biên dịch đầy đủ."""
        assert len(SKILLS) >= 60
        assert len(PATTERNS) == len(SKILLS)
        for p in PATTERNS:
            assert "name" in p
            assert len(p["regexes"]) >= 1

    def test_word_boundary_isolation(self):
        """Khớp nguyên từ: tránh nhận nhầm 'go' trong 'good', 'java' trong 'javascript'."""
        text_with_false_positives = (
            "I have good communication skills and strong javascript knowledge. "
            "I am proactive, reactive and enjoy reading books."
        )
        found = find_skills(text_with_false_positives)
        assert "go" not in found, "Nhận nhầm 'go' trong 'good'"
        assert "java" not in found, "Nhận nhầm 'java' trong 'javascript'"
        assert "javascript" in found, "Javascript phải được nhận diện"

    def test_alias_normalization(self):
        """Các bí danh công nghệ phải chuẩn hoá về tên gốc."""
        text = "Experienced with Github, Gitlab, Postgres, Springboot, and Node.js."
        found = find_skills(text)
        assert "git" in found
        assert "postgresql" in found
        assert "spring boot" in found
        assert "nodejs" in found

    @pytest.mark.parametrize(
        "text,expected_months",
        [
            ("Có 2 năm kinh nghiệm làm lập trình viên Flutter", 24),
            ("1.5 năm kinh nghiệm backend", 18),
            ("1,5 years experience in software engineering", 18),
            ("6 tháng kinh nghiệm thực tập", 6),
            ("3 months experience with React", 3),
            ("Sinh viên mới tốt nghiệp chưa có số năm cụ thể", 0),
        ],
    )
    def test_experience_months_extraction(self, text, expected_months):
        """Trích xuất đúng số tháng kinh nghiệm từ cả tiếng Việt và tiếng Anh."""
        assert find_experience_months(text) == expected_months

    @pytest.mark.parametrize(
        "text,expected_keyword",
        [
            ("Cử nhân Đại học Bách Khoa Hà Nội", "Đại học"),
            ("Graduated from National University of Technology", "University"),
            ("Học Viện Công Nghệ Bưu Chính Viễn Thông", "Học Viện"),
            ("Community College of San Francisco", "College"),
        ],
    )
    def test_education_extraction(self, text, expected_keyword):
        """Nhận diện trường đại học / học viện / college."""
        edu = find_education(text)
        assert edu is not None
        assert expected_keyword.lower() in edu.lower()

    def test_education_not_found(self):
        """Không có thông tin học vấn thì trả None."""
        assert find_education("Lập trình viên tự học, không ghi trường lớp.") is None

    def test_analyze_real_pdf_fixture(self):
        """Đọc và trích xuất file PDF cv-sample.pdf thật của hệ thống."""
        assert os.path.exists(SAMPLE_PDF_PATH), f"Không tìm thấy file {SAMPLE_PDF_PATH}"
        with open(SAMPLE_PDF_PATH, "rb") as f:
            pdf_bytes = f.read()

        result = analyze_pdf(pdf_bytes)
        assert isinstance(result["skills"], list)
        assert len(result["skills"]) >= 5

        # Các skill cốt lõi trong cv-sample.pdf
        expected_core = ["flutter", "dart", "git", "firebase", "rest api", "nodejs", "postgresql"]
        for skill in expected_core:
            assert skill in result["skills"], f"Thiếu skill dự kiến: {skill}"

        # Skill không có trong CV không được xuất hiện
        assert "python" not in result["skills"]
        assert "java" not in result["skills"]


# ============================================================================
# 2. INTEGRATION TESTS: FASTAPI ENDPOINTS
# ============================================================================

class TestApiEndpoints:
    """Kiểm tra các REST endpoint của Python AI Service."""

    def test_root_endpoint(self):
        res = client.get("/")
        assert res.status_code == 200
        assert "Atom AI Service is running" in res.json().get("message", "")

    def test_health_check(self):
        res = client.get("/health")
        assert res.status_code == 200
        assert res.json() == {"status": "ok", "service": "ai"}

    def test_analyze_cv_success_with_pdf(self):
        """POST /analyze-cv với PDF thật thành công và trả đúng schema."""
        with open(SAMPLE_PDF_PATH, "rb") as f:
            res = client.post(
                "/analyze-cv",
                files={"file": ("cv-candidate.pdf", f, "application/pdf")},
            )

        assert res.status_code == 200
        data = res.json()
        assert "skills" in data
        assert "education" in data
        assert "experience_months" in data
        assert isinstance(data["skills"], list)
        assert "flutter" in data["skills"]
        assert "dart" in data["skills"]

    def test_analyze_cv_reject_non_pdf_extension(self):
        """Từ chối file không có đuôi .pdf."""
        res = client.post(
            "/analyze-cv",
            files={"file": ("resume.docx", b"some content", "application/vnd.openxmlformats")},
        )
        assert res.status_code == 400
        assert "Chỉ chấp nhận file PDF" in res.json()["detail"]

    def test_analyze_cv_reject_corrupted_header(self):
        """Từ chối file có đuôi .pdf nhưng magic bytes không phải %PDF."""
        res = client.post(
            "/analyze-cv",
            files={"file": ("fake.pdf", b"NOT_A_PDF_HEADER_12345", "application/pdf")},
        )
        assert res.status_code == 400
        assert "không phải định dạng PDF hợp lệ" in res.json()["detail"]

    def test_analyze_cv_reject_empty_file(self):
        """Từ chối file rỗng 0 bytes."""
        res = client.post(
            "/analyze-cv",
            files={"file": ("empty.pdf", b"", "application/pdf")},
        )
        assert res.status_code == 400

    def test_analyze_cv_graceful_on_malformed_pdf_body(self):
        """Nếu file có magic bytes %PDF nhưng nội dung bên trong hỏng, trả skills rỗng không crash."""
        malformed_pdf = b"%PDF-1.4\nCorrupted content without valid xref table..."
        res = client.post(
            "/analyze-cv",
            files={"file": ("broken.pdf", malformed_pdf, "application/pdf")},
        )
        assert res.status_code == 200
        data = res.json()
        assert data["skills"] == []
        assert data["education"] is None
        assert data["experience_months"] == 0

    def test_match_perfect_score(self):
        """Khớp 100% khi ứng viên có đủ mọi required skills."""
        payload = {
            "cv_skills": ["Flutter", "Dart", "Git", "REST API"],
            "job": {
                "title": "Flutter Developer",
                "required_skills": ["flutter", "dart", "git"],
                "nice_to_have": ["docker"],
                "description": "Junior position",
            },
        }
        res = client.post("/match", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert data["score"] == 100
        assert set(data["matched_skills"]) == {"flutter", "dart", "git"}
        assert data["missing_skills"] == []
        assert "rất tốt" in data["suggestion"]

    def test_match_partial_score_and_missing_skills(self):
        """Khớp một phần và gợi ý đúng các skill còn thiếu."""
        payload = {
            "cv_skills": ["Flutter"],
            "job": {
                "title": "Flutter Developer",
                "required_skills": ["flutter", "bloc", "firebase", "ci/cd"],
                "nice_to_have": [],
                "description": "",
            },
        }
        res = client.post("/match", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert data["score"] == 25  # 1/4 = 25%
        assert data["matched_skills"] == ["flutter"]
        assert set(data["missing_skills"]) == {"bloc", "firebase", "ci/cd"}
        assert "bổ sung hoặc học thêm" in data["suggestion"]
        assert "bloc" in data["suggestion"]

    def test_match_zero_required_skills(self):
        """Khi job không có required skills, mặc định trả 100."""
        payload = {
            "cv_skills": ["python"],
            "job": {
                "title": "General Intern",
                "required_skills": [],
                "nice_to_have": [],
                "description": "",
            },
        }
        res = client.post("/match", json=payload)
        assert res.status_code == 200
        assert res.json()["score"] == 100

    def test_match_case_insensitivity_and_trimming(self):
        """So khớp không phân biệt hoa thường và tự xoá khoảng trắng thừa."""
        payload = {
            "cv_skills": ["  FLUTTER  ", "DART\t"],
            "job": {
                "title": "Mobile Dev",
                "required_skills": ["flutter", "dart"],
                "nice_to_have": [],
                "description": "",
            },
        }
        res = client.post("/match", json=payload)
        assert res.status_code == 200
        assert res.json()["score"] == 100
        assert set(res.json()["matched_skills"]) == {"flutter", "dart"}

