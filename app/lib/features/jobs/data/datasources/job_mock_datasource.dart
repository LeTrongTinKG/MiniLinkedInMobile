import '../models/job_model.dart';
import '../../domain/entities/job_filter.dart';
import 'job_datasource.dart';

/// Mock Data Source phục vụ phát triển giao diện Task F5 với dữ liệu giả lập
class JobMockDataSource implements JobDataSource {
  // Danh sách dữ liệu mẫu mô phỏng thị trường IT cho sinh viên
  final List<JobModel> _mockJobs = [
    JobModel(
      id: 'job-1',
      recruiterId: 'rec-1',
      title: 'Flutter Developer Intern',
      companyName: 'FPT Software',
      companyLogoUrl: 'https://images.unsplash.com/photo-1542744094-3a31f272c490?w=128&q=80',
      location: 'Hà Nội (Khu CNC Hòa Lạc)',
      workMode: 'hybrid',
      level: 'intern',
      salaryMin: 300,
      salaryMax: 600,
      description:
          'Tham gia phát triển ứng dụng di động đa nền tảng Flutter. Làm việc với REST API, State Management (Provider/BLoC), tối ưu hóa hiệu năng giao diện.',
      requiredSkills: ['Flutter', 'Dart', 'REST API', 'Git'],
      niceToHave: ['Firebase', 'CI/CD', 'BLoC'],
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    JobModel(
      id: 'job-2',
      recruiterId: 'rec-2',
      title: 'Fresher Backend Engineer (Node.js)',
      companyName: 'VNG Corporation',
      companyLogoUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=128&q=80',
      location: 'TP. Hồ Chí Minh (Quận 7)',
      workMode: 'onsite',
      level: 'fresher',
      salaryMin: 500,
      salaryMax: 900,
      description:
          'Xây dựng hệ thống Backend API với Express.js/Nest.js, thiết kế cơ sở dữ liệu PostgreSQL và triển khai caching với Redis cho hàng triệu người dùng.',
      requiredSkills: ['Node.js', 'Express', 'PostgreSQL', 'Git', 'SQL'],
      niceToHave: ['Docker', 'Redis', 'NestJS', 'Prisma'],
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    JobModel(
      id: 'job-3',
      recruiterId: 'rec-3',
      title: 'Frontend ReactJS Intern',
      companyName: 'Tiki Corporation',
      companyLogoUrl: 'https://images.unsplash.com/photo-1551434678-e076c223a692?w=128&q=80',
      location: 'TP. Hồ Chí Minh (Tân Bình)',
      workMode: 'hybrid',
      level: 'intern',
      salaryMin: 250,
      salaryMax: 500,
      description:
          'Hỗ trợ đội ngũ Frontend phát triển các trang chức năng trên sàn thương mại điện tử bằng ReactJS, TypeScript và Tailwind CSS.',
      requiredSkills: ['React', 'JavaScript', 'HTML/CSS', 'Git'],
      niceToHave: ['TypeScript', 'TailwindCSS', 'Redux'],
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    JobModel(
      id: 'job-4',
      recruiterId: 'rec-4',
      title: 'Junior Mobile Developer (Flutter & React Native)',
      companyName: 'Shopee Vietnam',
      companyLogoUrl: null,
      location: 'TP. Hồ Chí Minh (Quận 1)',
      workMode: 'onsite',
      level: 'junior',
      salaryMin: 800,
      salaryMax: 1300,
      description:
          'Phát triển ứng dụng mua sắm trực tuyến, tích hợp thanh toán điện tử, xử lý animation mượt mà và viết unit tests.',
      requiredSkills: ['Flutter', 'Dart', 'React Native', 'REST API'],
      niceToHave: ['Native Android/iOS', 'GraphQL', 'Clean Architecture'],
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    JobModel(
      id: 'job-5',
      recruiterId: 'rec-5',
      title: 'AI / Machine Learning Fresher',
      companyName: 'VinAI Research',
      companyLogoUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=128&q=80',
      location: 'Hà Nội (Cầu Giấy)',
      workMode: 'onsite',
      level: 'fresher',
      salaryMin: 700,
      salaryMax: 1200,
      description:
          'Nghiên cứu và triển khai các mô hình NLP, trích xuất dữ liệu tài liệu PDF (OCR) và mô hình so khớp ngữ nghĩa (Sentence Transformers).',
      requiredSkills: ['Python', 'PyTorch', 'NLP', 'Git'],
      niceToHave: ['FastAPI', 'Docker', 'Transformers', 'HuggingFace'],
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    JobModel(
      id: 'job-6',
      recruiterId: 'rec-6',
      title: 'Fullstack Web Intern (VueJS & Laravel)',
      companyName: 'Rikkeisoft',
      companyLogoUrl: null,
      location: 'Đà Nẵng (Hải Châu)',
      workMode: 'onsite',
      level: 'intern',
      salaryMin: 200,
      salaryMax: 400,
      description:
          'Làm quen với quy trình phát triển phần mềm cho thị trường Nhật Bản. Xây dựng CRUD API bằng Laravel và giao diện VueJS.',
      requiredSkills: ['PHP', 'Laravel', 'VueJS', 'MySQL'],
      niceToHave: ['Tiếng Nhật N3/N4', 'Git', 'Bootstrap'],
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    JobModel(
      id: 'job-7',
      recruiterId: 'rec-7',
      title: 'Remote Golang Backend Fresher',
      companyName: 'Techcombank Digital',
      companyLogoUrl: 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=128&q=80',
      location: 'Toàn quốc',
      workMode: 'remote',
      level: 'fresher',
      salaryMin: 600,
      salaryMax: 1000,
      description:
          'Xây dựng các microservices hiệu năng cao bằng Golang, kiến trúc Event-Driven với Apache Kafka và gRPC.',
      requiredSkills: ['Golang', 'PostgreSQL', 'Docker', 'Git'],
      niceToHave: ['Kafka', 'gRPC', 'Kubernetes'],
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    JobModel(
      id: 'job-8',
      recruiterId: 'rec-8',
      title: 'QA / QC Tester Intern (Manual & Automation)',
      companyName: 'KMS Technology',
      companyLogoUrl: null,
      location: 'TP. Hồ Chí Minh (Tân Bình)',
      workMode: 'hybrid',
      level: 'intern',
      salaryMin: 250,
      salaryMax: 450,
      description:
          'Viết test cases, thực hiện kiểm thử chức năng, API testing bằng Postman và tìm hiểu kiểm thử tự động với Selenium/Playwright.',
      requiredSkills: ['Test Cases', 'Postman', 'SQL', 'Git'],
      niceToHave: ['Selenium', 'Python', 'Jira'],
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    JobModel(
      id: 'job-9',
      recruiterId: 'rec-9',
      title: 'Junior DevOps Engineer',
      companyName: 'Momo (M-Service)',
      companyLogoUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=128&q=80',
      location: 'TP. Hồ Chí Minh (Quận 7)',
      workMode: 'hybrid',
      level: 'junior',
      salaryMin: 900,
      salaryMax: 1500,
      description:
          'Quản lý hạ tầng đám mây AWS, xây dựng pipeline CI/CD với GitLab CI, giám sát hệ thống bằng Prometheus & Grafana.',
      requiredSkills: ['Linux', 'Docker', 'CI/CD', 'AWS', 'Git'],
      niceToHave: ['Kubernetes', 'Terraform', 'Prometheus'],
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    JobModel(
      id: 'job-10',
      recruiterId: 'rec-10',
      title: 'Java Spring Boot Fresher',
      companyName: 'Viettel Telecom',
      companyLogoUrl: null,
      location: 'Hà Nội (Nam Từ Liêm)',
      workMode: 'onsite',
      level: 'fresher',
      salaryMin: 550,
      salaryMax: 950,
      description:
          'Phát triển các phân hệ dịch vụ viễn thông và thanh toán, áp dụng Spring Boot, Spring Security và cơ sở dữ liệu Oracle.',
      requiredSkills: ['Java', 'Spring Boot', 'SQL', 'Git'],
      niceToHave: ['Oracle', 'Hibernate', 'Microservices'],
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
  ];

  @override
  Future<List<JobModel>> getJobs({JobFilter? filter}) async {
    // Giả lập độ trễ mạng thực tế 400ms
    await Future.delayed(const Duration(milliseconds: 400));

    if (filter == null || !filter.hasFilter) {
      return List.from(_mockJobs);
    }

    return _mockJobs.where((job) {
      // 1. Lọc theo từ khóa keyword (so khớp title, companyName hoặc requiredSkills)
      if (filter.keyword.trim().isNotEmpty) {
        final query = filter.keyword.trim().toLowerCase();
        final matchTitle = job.title.toLowerCase().contains(query);
        final matchCompany = job.companyName.toLowerCase().contains(query);
        final matchLocation = job.location.toLowerCase().contains(query);
        final matchSkill = job.requiredSkills
            .any((s) => s.toLowerCase().contains(query));

        if (!matchTitle && !matchCompany && !matchLocation && !matchSkill) {
          return false;
        }
      }

      // 2. Lọc theo WorkMode
      if (filter.workMode != null) {
        if (job.workMode.toLowerCase() != filter.workMode!.name.toLowerCase()) {
          return false;
        }
      }

      // 3. Lọc theo Level
      if (filter.level != null) {
        if (job.level.toLowerCase() != filter.level!.name.toLowerCase()) {
          return false;
        }
      }

      // 4. Lọc theo danh sách kỹ năng được chọn
      if (filter.selectedSkills.isNotEmpty) {
        final jobSkillsLower =
            job.requiredSkills.map((s) => s.toLowerCase()).toSet();
        final hasAnySkill = filter.selectedSkills.any(
          (skill) => jobSkillsLower.contains(skill.toLowerCase()),
        );
        if (!hasAnySkill) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Future<JobModel?> getJobById(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    try {
      return _mockJobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getAvailableSkills() async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Gom toàn bộ kỹ năng từ các jobs và loại bỏ trùng lặp
    final Set<String> skills = {};
    for (final job in _mockJobs) {
      skills.addAll(job.requiredSkills);
    }
    final sortedSkills = skills.toList()..sort();
    return sortedSkills;
  }
}

