// Chỉ httpAdapter và mockAdapter dùng file này.
// Phần còn lại của backend chỉ làm việc với camelCase.

const normalize = (arr) =>
  [...new Set((arr ?? []).map((s) => s.trim().toLowerCase()).filter(Boolean))];

function analyzeResultToCamel(raw) {
  return {
    skills: raw.skills ?? [],
    education: raw.education ?? null,
    experienceMonths: raw.experience_months ?? 0,
  };
}

function matchParamsToSnake(cvSkills, job) {
  return {
    cv_skills: cvSkills,
    job: {
      title: job.title,
      required_skills: job.requiredSkills ?? [],
      nice_to_have: job.niceToHave ?? [],
      description: job.description ?? "",
    },
  };
}

function matchResultToCamel(raw) {
  return {
    score: raw.score,
    matchedSkills: raw.matched_skills ?? [],
    missingSkills: raw.missing_skills ?? [],
    suggestion: raw.suggestion ?? "",
  };
}

module.exports = {
  normalize,
  analyzeResultToCamel,
  matchParamsToSnake,
  matchResultToCamel,
};
