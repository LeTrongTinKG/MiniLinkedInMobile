# AI Service Client

Lớp trung gian duy nhất giữa backend và AI service (Python FastAPI).  
Phần còn lại của backend chỉ import từ `aiClient.js`, không import trực tiếp adapter.

## Cách dùng

```js
const { analyzeCv, match } = require("./services/ai/aiClient");

const cvResult = await analyzeCv(fileBuffer, "cv.pdf");
// → { skills: string[], education: string|null, experienceMonths: number }

const matchResult = await match(cvResult.skills, job);
// job: { title, requiredSkills, niceToHave, description }
// → { score: number, matchedSkills: string[], missingSkills: string[], suggestion: string }
```

## Biến môi trường

| Biến | Giá trị | Mặc định |
|---|---|---|
| `AI_MODE` | `mock` hoặc `real` | `mock` |
| `AI_SERVICE_URL` | URL của AI service | `http://localhost:8000` |
| `AI_FALLBACK_TO_MOCK` | `true` hoặc `false` | `false` |

## Đổi sang AI thật

Trong `.env`:
```
AI_MODE=real
AI_SERVICE_URL=http://localhost:8000
AI_FALLBACK_TO_MOCK=true
```

Không cần sửa bất kỳ route, controller hay service nào khác.

## Test nhanh bằng curl

```bash
# Health check AI service
curl http://localhost:8000/health

# Analyze CV (upload file PDF)
curl -X POST http://localhost:8000/analyze-cv \
  -F "file=@/path/to/cv.pdf"

# Match CV với Job
curl -X POST http://localhost:8000/match \
  -H "Content-Type: application/json" \
  -d '{
    "cv_skills": ["flutter", "dart"],
    "job": {
      "title": "Mobile Developer",
      "required_skills": ["flutter", "rest api"],
      "nice_to_have": ["git"],
      "description": "Tuyển mobile dev"
    }
  }'
```
