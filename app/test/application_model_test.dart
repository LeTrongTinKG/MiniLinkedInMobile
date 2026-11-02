import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/applications/data/application_model.dart';
import 'package:app/features/applications/domain/entities/application_entity.dart';
import 'package:app/features/cv/data/models/cv_model.dart';
import 'package:app/features/jobs/domain/entities/job_match.dart';

void main() {
  group('applicationFromJson', () {
    test('đọc đủ job, sinh viên, CV và điểm match', () {
      final app = applicationFromJson({
        'id': 'a1',
        'jobId': 'j1',
        'matchScore': 72,
        'matchedSkills': ['flutter'],
        'missingSkills': ['git'],
        'status': 'shortlisted',
        'createdAt': '2026-10-27T03:00:00.000Z',
        'job': {'id': 'j1', 'title': 'Flutter Intern', 'companyName': 'FPT', 'location': 'HN'},
        'student': {
          'fullName': 'An',
          'studentProfile': {'school': 'UIT', 'major': 'CNTT'},
        },
        'cv': {'fileName': 'cv.pdf', 'fileUrl': 'https://x/cv.pdf'},
      });
      expect(app.jobTitle, 'Flutter Intern');
      expect(app.studentName, 'An');
      expect(app.studentMajor, 'CNTT');
      expect(app.matchScore, 72);
      expect(app.missingSkills, ['git']);
      expect(app.status, ApplicationStatus.shortlisted);
    });

    test('thiếu job/student/cv vẫn không lỗi (phản hồi tạo đơn và đổi trạng thái)', () {
      final app = applicationFromJson({'id': 'a2', 'status': 'submitted'});
      expect(app.jobTitle, '');
      expect(app.cvFileName, '');
      expect(app.matchScore, 0);
      expect(app.status, ApplicationStatus.submitted);
    });

    test('trạng thái lạ rơi về submitted', () {
      expect(ApplicationStatus.fromString('???'), ApplicationStatus.submitted);
    });

    test('copyWith chỉ đổi trạng thái', () {
      final app = applicationFromJson({'id': 'a3', 'matchScore': 40});
      final updated = app.copyWith(status: ApplicationStatus.rejected);
      expect(updated.status, ApplicationStatus.rejected);
      expect(updated.matchScore, 40);
    });
  });

  group('JobMatch.fromJson', () {
    test('đọc điểm, kỹ năng khớp/thiếu và gợi ý', () {
      final match = JobMatch.fromJson({
        'score': 50,
        'matchedSkills': ['nodejs'],
        'missingSkills': ['react', 'docker'],
        'suggestion': 'Học thêm react, docker',
      });
      expect(match.score, 50);
      expect(match.missingSkills, ['react', 'docker']);
      expect(match.suggestion, 'Học thêm react, docker');
    });
  });

  group('CvModel.fromJson', () {
    Map<String, dynamic> cv(dynamic skills) => {
          'id': 'c1',
          'fileName': 'cv.pdf',
          'fileUrl': 'https://x/cv.pdf',
          'extractedSkills': skills,
        };

    test('đọc kỹ năng từ object { skills: [...] } do server trả', () {
      final model = CvModel.fromJson(cv({'skills': ['flutter', 'dart'], 'education': null}));
      expect(model.extractedSkills, ['flutter', 'dart']);
    });

    test('vẫn đọc được dạng danh sách thuần và null', () {
      expect(CvModel.fromJson(cv(['git'])).extractedSkills, ['git']);
      expect(CvModel.fromJson(cv(null)).extractedSkills, isEmpty);
    });
  });
}
