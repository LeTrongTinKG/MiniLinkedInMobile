// j(title, recruiterEmail, companyName, level, workMode, location, salary, required, nice, desc)
const j = (title, rec, company, level, wm, loc, sal, req, nice, desc) => ({
  title, recruiterEmail: rec, companyName: company,
  level, workMode: wm, location: loc,
  salaryMin: sal[0], salaryMax: sal[1],
  requiredSkills: req, niceToHave: nice,
  description: desc, status: "open",
});

const FPT = "recruiter1@fpt.com";
const VNG = "recruiter2@vng.com";
const SPE = "recruiter3@shopee.com";

module.exports = [
  // ── FPT Software ──────────────────────────────────────────────────────────
  j("Flutter Mobile Intern", FPT, "FPT Software", "intern", "hybrid", "Hà Nội",
    [3_000_000, 5_000_000], ["flutter", "dart", "git"], ["firebase", "rest api"],
    "Tham gia phát triển ứng dụng mobile Flutter cho khách hàng doanh nghiệp. Được mentor trực tiếp bởi senior engineer."),

  j("ReactJS Frontend Intern", FPT, "FPT Software", "intern", "remote", "Hà Nội",
    [3_000_000, 5_000_000], ["react", "javascript", "html", "css"], ["typescript", "tailwind"],
    "Xây dựng và tối ưu giao diện web với ReactJS. Làm việc trong môi trường Agile."),

  j("Node.js Backend Intern", FPT, "FPT Software", "intern", "onsite", "Hà Nội",
    [3_000_000, 5_000_000], ["nodejs", "javascript", "rest api"], ["postgresql", "docker"],
    "Phát triển REST API với Node.js và Express. Hỗ trợ team backend trong các sprint 2 tuần."),

  j("Python AI/ML Intern", FPT, "FPT Software", "intern", "hybrid", "Hà Nội",
    [3_000_000, 5_000_000], ["python", "machine learning", "git"], ["tensorflow", "pandas"],
    "Hỗ trợ nghiên cứu và xây dựng mô hình AI cho các sản phẩm nội bộ của FPT."),

  j("Java Backend Fresher", FPT, "FPT Software", "fresher", "onsite", "Hà Nội",
    [7_000_000, 10_000_000], ["java", "spring boot", "sql", "git"], ["docker", "microservices"],
    "Phát triển backend với Java Spring Boot, tham gia đầy đủ vòng đời phần mềm từ thiết kế đến deploy."),

  j("ReactJS Fresher Developer", FPT, "FPT Software", "fresher", "hybrid", "Hà Nội",
    [7_000_000, 12_000_000], ["react", "typescript", "javascript"], ["redux", "graphql"],
    "Xây dựng SPA với React + TypeScript. Phối hợp chặt với team UX/UI và backend."),

  j("Flutter Fresher Developer", FPT, "FPT Software", "fresher", "remote", "Hà Nội",
    [7_000_000, 10_000_000], ["flutter", "dart", "rest api", "git"], ["firebase", "bloc"],
    "Phát triển app cross-platform Flutter cho thị trường Nhật Bản và Đông Nam Á."),

  j("Junior Node.js Backend", FPT, "FPT Software", "junior", "hybrid", "Hà Nội",
    [12_000_000, 18_000_000], ["nodejs", "typescript", "postgresql", "docker"], ["kubernetes", "redis"],
    "Thiết kế và triển khai microservice với Node.js. Chịu trách nhiệm technical design cho một module."),

  j("Junior DevOps Engineer", FPT, "FPT Software", "junior", "onsite", "Hà Nội",
    [15_000_000, 20_000_000], ["docker", "kubernetes", "linux", "ci/cd"], ["terraform", "aws"],
    "Quản lý hạ tầng CI/CD, tự động hóa deployment cho hơn 20 ứng dụng nội bộ."),

  j("Junior Full Stack Developer", FPT, "FPT Software", "junior", "remote", "Hà Nội",
    [12_000_000, 18_000_000], ["react", "nodejs", "postgresql", "docker"], ["graphql", "redis"],
    "Phụ trách end-to-end một tính năng: từ database đến giao diện người dùng."),

  // ── VNG Corporation ───────────────────────────────────────────────────────
  j("Flutter Mobile Intern", VNG, "VNG Corporation", "intern", "onsite", "Hồ Chí Minh",
    [3_000_000, 5_000_000], ["flutter", "dart"], ["firebase", "state management"],
    "Gia nhập team phát triển Zalo mini app. Học kiến trúc clean code và review code hàng ngày."),

  j("Data Engineer Intern", VNG, "VNG Corporation", "intern", "hybrid", "Hồ Chí Minh",
    [3_000_000, 5_000_000], ["python", "sql"], ["spark", "kafka", "airflow"],
    "Hỗ trợ xây dựng data pipeline xử lý hàng triệu sự kiện mỗi ngày từ sản phẩm Zalo."),

  j("QA Automation Intern", VNG, "VNG Corporation", "intern", "onsite", "Hồ Chí Minh",
    [2_500_000, 4_000_000], ["python", "selenium", "git"], ["appium", "postman"],
    "Viết automation test cho web và mobile app. Tham gia regression testing mỗi sprint."),

  j("iOS Developer Fresher", VNG, "VNG Corporation", "fresher", "remote", "Hồ Chí Minh",
    [8_000_000, 12_000_000], ["swift", "ios", "xcode", "git"], ["combine", "swiftui"],
    "Phát triển tính năng mới cho Zalo iOS. Hơn 10 triệu người dùng thật sẽ dùng code của bạn."),

  j("Android Developer Fresher", VNG, "VNG Corporation", "fresher", "onsite", "Hồ Chí Minh",
    [8_000_000, 12_000_000], ["kotlin", "android", "android studio", "git"], ["jetpack compose", "coroutines"],
    "Phát triển và tối ưu hiệu năng ứng dụng Zalo Android trên các dòng máy tầm trung."),

  j("Data Analyst Fresher", VNG, "VNG Corporation", "fresher", "hybrid", "Hồ Chí Minh",
    [7_000_000, 10_000_000], ["sql", "python", "excel"], ["tableau", "bigquery"],
    "Phân tích hành vi người dùng và đo lường A/B test cho các tính năng mới của Zalo."),

  j("React Native Junior Developer", VNG, "VNG Corporation", "junior", "hybrid", "Hồ Chí Minh",
    [12_000_000, 18_000_000], ["react native", "javascript", "typescript", "rest api"], ["redux", "reanimated"],
    "Lead phát triển một module trong ứng dụng 10+ triệu người dùng. Mentoring cho 1-2 intern."),

  j("Backend Go Junior Developer", VNG, "VNG Corporation", "junior", "onsite", "Hồ Chí Minh",
    [15_000_000, 22_000_000], ["go", "postgresql", "redis", "docker"], ["kafka", "grpc"],
    "Xây dựng service hiệu năng cao với Go, xử lý hàng nghìn request mỗi giây."),

  j("Junior Cloud/AWS Engineer", VNG, "VNG Corporation", "junior", "remote", "Hồ Chí Minh",
    [15_000_000, 20_000_000], ["aws", "docker", "kubernetes", "linux"], ["terraform", "monitoring"],
    "Thiết kế và vận hành hạ tầng cloud cho các sản phẩm VNG với SLA 99.9%."),

  j("Junior Machine Learning Engineer", VNG, "VNG Corporation", "junior", "hybrid", "Hồ Chí Minh",
    [15_000_000, 22_000_000], ["python", "machine learning", "pytorch", "sql"], ["mlops", "huggingface"],
    "Nghiên cứu và triển khai mô hình AI cho tính năng gợi ý nội dung trên Zalo."),

  // ── Shopee Vietnam ────────────────────────────────────────────────────────
  j("Frontend Vue.js Intern", SPE, "Shopee Vietnam", "intern", "hybrid", "Hồ Chí Minh",
    [3_000_000, 5_000_000], ["vue", "javascript", "html", "css"], ["typescript", "pinia"],
    "Xây dựng component giao diện cho trang Shopee với Vue 3. Code review hàng ngày."),

  j("Backend Python Intern", SPE, "Shopee Vietnam", "intern", "onsite", "Hồ Chí Minh",
    [3_000_000, 5_000_000], ["python", "fastapi", "sql", "git"], ["redis", "docker"],
    "Phát triển REST API với Python FastAPI, làm việc trong team 5-6 engineer."),

  j("React Native Mobile Intern", SPE, "Shopee Vietnam", "intern", "remote", "Hồ Chí Minh",
    [3_000_000, 5_000_000], ["react native", "javascript"], ["typescript", "expo"],
    "Tham gia xây dựng tính năng mới trên Shopee App (iOS & Android) phục vụ triệu người dùng."),

  j("PHP Backend Fresher", SPE, "Shopee Vietnam", "fresher", "onsite", "Hồ Chí Minh",
    [7_000_000, 10_000_000], ["php", "mysql", "rest api", "git"], ["laravel", "redis"],
    "Phát triển và bảo trì hệ thống backend PHP phục vụ hàng triệu đơn hàng mỗi ngày."),

  j("Vue.js Frontend Fresher", SPE, "Shopee Vietnam", "fresher", "hybrid", "Hồ Chí Minh",
    [7_000_000, 10_000_000], ["vue", "typescript", "html", "css"], ["nuxt", "tailwind"],
    "Xây dựng và tối ưu giao diện Shopee Seller Center cho hàng triệu nhà bán hàng."),

  j("SQL/Database Fresher Developer", SPE, "Shopee Vietnam", "fresher", "onsite", "Hồ Chí Minh",
    [6_000_000, 9_000_000], ["sql", "postgresql", "mysql", "git"], ["mongodb", "query optimization"],
    "Thiết kế schema database, tối ưu query, và hỗ trợ migration dữ liệu cho các sản phẩm Shopee."),

  j("Junior Kotlin Android Developer", SPE, "Shopee Vietnam", "junior", "onsite", "Hồ Chí Minh",
    [13_000_000, 18_000_000], ["kotlin", "android", "jetpack compose", "git"], ["coroutines", "hilt"],
    "Lead phát triển module thanh toán trên Shopee Android App. Review code cho fresher."),

  j("Junior Swift iOS Developer", SPE, "Shopee Vietnam", "junior", "hybrid", "Hồ Chí Minh",
    [13_000_000, 18_000_000], ["swift", "ios", "swiftui", "git"], ["combine", "core data"],
    "Xây dựng tính năng live streaming mua sắm trên Shopee iOS với SwiftUI."),

  j("Junior TypeScript Developer", SPE, "Shopee Vietnam", "junior", "remote", "Hồ Chí Minh",
    [12_000_000, 18_000_000], ["typescript", "react", "nodejs", "postgresql"], ["graphql", "jest"],
    "Phát triển full stack TypeScript cho Shopee Seller Portal, phụ trách 1-2 tính năng."),

  j("Junior PostgreSQL DBA", SPE, "Shopee Vietnam", "junior", "onsite", "Hồ Chí Minh",
    [12_000_000, 16_000_000], ["postgresql", "sql", "linux", "backup"], ["replication", "performance tuning"],
    "Quản trị và tối ưu hóa database PostgreSQL cho hệ thống xử lý hàng triệu transaction/ngày."),
];
