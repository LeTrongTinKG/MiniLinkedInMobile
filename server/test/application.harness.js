process.env.JWT_SECRET = "test-secret-with-more-than-thirty-two-characters";
process.env.NODE_ENV = "test";
process.env.AI_MODE = "mock";

const { store, installPrismaMock } = require("./application.prisma-mock");

installPrismaMock();

const applicationController = require("../src/controllers/application.controller");
const { authenticate, authorize } = require("../src/middleware/auth");
const { generateAccessToken } = require("../src/utils/token");
const { dispatch } = require("./helpers");

const USERS = {
  student1: { id: "student-1", email: "student1@school.edu.vn", role: "student" },
  student2: { id: "student-2", email: "student2@school.edu.vn", role: "student" },
  recruiter1: { id: "recruiter-1", email: "recruiter1@company.com", role: "recruiter" },
  recruiter2: { id: "recruiter-2", email: "recruiter2@other.com", role: "recruiter" },
};

function authReq(user, extra = {}) {
  const token = generateAccessToken(user);
  return { headers: { authorization: `Bearer ${token}` }, ...extra };
}

async function asRole(handler, role, user, extra = {}) {
  return dispatch(handler, authReq(user, extra), [authenticate, authorize(role)]);
}

const asStudent = (handler, extra = {}, user = USERS.student1) =>
  asRole(handler, "student", user, extra);
const asRecruiter = (handler, extra = {}, user = USERS.recruiter1) =>
  asRole(handler, "recruiter", user, extra);

function seedApp(overrides = {}) {
  const app = {
    id: "app-1",
    jobId: "job-1",
    studentId: "student-1",
    cvId: "cv-1",
    status: "submitted",
    matchScore: 80,
    matchedSkills: ["Flutter"],
    missingSkills: ["Dart"],
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
  store.applications.push(app);
  return app;
}

function resetStore() {
  store.appIdCounter = 0;
  store.users = [
    {
      ...USERS.student1,
      fullName: "Nguyễn Văn Sinh Viên",
      avatarUrl: "https://example.com/avatar-sv.png",
      studentProfile: {
        school: "Đại học Bách Khoa",
        major: "Công nghệ Thông tin",
        headline: "Fresher Flutter Dev",
        location: "TP. Hồ Chí Minh",
        graduationYear: 2026,
      },
    },
    { ...USERS.student2, fullName: "Trần Thị Sinh Viên 2", avatarUrl: null, studentProfile: null },
    { ...USERS.recruiter1, fullName: "Lê Tuyển Dụng", avatarUrl: null },
    { ...USERS.recruiter2, fullName: "Phạm Nhà Tuyển Dụng Khác", avatarUrl: null },
  ];
  store.jobs = [
    {
      id: "job-1",
      recruiterId: "recruiter-1",
      title: "Flutter Fresher Developer",
      companyName: "Tech Solutions",
      companyLogoUrl: null,
      location: "TP. Hồ Chí Minh",
      workMode: "hybrid",
      level: "fresher",
      salaryMin: 10000000,
      salaryMax: 15000000,
      description: "Lập trình Flutter",
      requiredSkills: ["Flutter", "Dart"],
      niceToHave: ["Node.js", "Git"],
      status: "open",
    },
    {
      id: "job-closed",
      recruiterId: "recruiter-1",
      title: "Backend Intern",
      companyName: "Tech Solutions",
      location: "Hà Nội",
      workMode: "remote",
      level: "intern",
      description: "Đã đóng",
      requiredSkills: ["Node.js"],
      niceToHave: [],
      status: "closed",
    },
  ];
  store.cvs = [
    {
      id: "cv-1",
      userId: "student-1",
      fileName: "NguyenVanA_Flutter_CV.pdf",
      fileUrl: "https://storage.supabase.co/cvs/cv-1.pdf",
      extractedSkills: { skills: ["Flutter", "Dart", "Git"] },
      isDefault: true,
    },
    {
      id: "cv-2",
      userId: "student-1",
      fileName: "NguyenVanA_Backend_CV.pdf",
      fileUrl: "https://storage.supabase.co/cvs/cv-2.pdf",
      extractedSkills: { skills: ["Node.js"] },
      isDefault: false,
    },
    {
      id: "cv-sv2",
      userId: "student-2",
      fileName: "TranThiB_CV.pdf",
      fileUrl: "https://storage.supabase.co/cvs/cv-sv2.pdf",
      extractedSkills: { skills: ["Flutter"] },
      isDefault: true,
    },
  ];
  store.applications = [];
}

module.exports = {
  store,
  USERS,
  applicationController,
  authenticate,
  authorize,
  dispatch,
  asStudent,
  asRecruiter,
  seedApp,
  resetStore,
};
