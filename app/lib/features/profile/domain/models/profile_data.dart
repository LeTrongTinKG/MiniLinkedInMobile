/// Dữ liệu hồ sơ cá nhân với nguyên tắc Private by Default (F-002, Ticket 02).
class ProfileData {
  final String fullName;
  final String headline;
  final String location;
  final String school;
  final String major;
  final String about;
  final bool isPrivate;

  const ProfileData({
    required this.fullName,
    this.headline = '',
    this.location = 'TP. Hồ Chí Minh',
    this.school = '',
    this.major = '',
    this.about = '',
    this.isPrivate = true, // Mặc định riêng tư (Ticket 02)
  });

  ProfileData copyWith({
    String? fullName,
    String? headline,
    String? location,
    String? school,
    String? major,
    String? about,
    bool? isPrivate,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      headline: headline ?? this.headline,
      location: location ?? this.location,
      school: school ?? this.school,
      major: major ?? this.major,
      about: about ?? this.about,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'headline': headline,
        'location': location,
        'school': school,
        'major': major,
        'about': about,
        'isPrivate': isPrivate,
      };

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      fullName: json['fullName'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      location: json['location'] as String? ?? 'TP. Hồ Chí Minh',
      school: json['school'] as String? ?? '',
      major: json['major'] as String? ?? '',
      about: json['about'] as String? ?? '',
      isPrivate: json['isPrivate'] as bool? ?? true,
    );
  }
}
