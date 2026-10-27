import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _headlineController;
  late final TextEditingController _locationController;
  late final TextEditingController _schoolController;
  late final TextEditingController _majorController;
  late final TextEditingController _aboutController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _headlineController = TextEditingController(
      text: 'Sinh viên CNTT năm 4 · tìm thực tập Flutter',
    );
    _locationController = TextEditingController(text: 'TP. Hồ Chí Minh');
    _schoolController = TextEditingController(text: 'Đại học Khoa học Tự nhiên');
    _majorController = TextEditingController(text: 'Công nghệ Thông tin');
    _aboutController = TextEditingController(
      text: 'Đam mê lập trình di động Flutter, đang tìm cơ hội thực tập.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _locationController.dispose();
    _schoolController.dispose();
    _majorController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật hồ sơ thành công!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Lưu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 16),
              _buildSectionTitle('Thông tin cơ bản'),
              _buildTextField('Họ và tên', _nameController, isRequired: true),
              _buildTextField('Chức danh / Headline', _headlineController),
              _buildTextField('Khu vực', _locationController),
              const SizedBox(height: 16),
              _buildSectionTitle('Học vấn'),
              _buildTextField('Trường đại học', _schoolController),
              _buildTextField('Chuyên ngành', _majorController),
              const SizedBox(height: 16),
              _buildSectionTitle('Giới thiệu bản thân'),
              _buildTextField('Mô tả ngắn', _aboutController, maxLines: 3),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: Color(0xFFCFDAF7),
            child: Icon(Icons.person, size: 50, color: AppTheme.primaryBlue),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng chọn avatar đang cập nhật')),
                  );
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
        validator: isRequired
            ? (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng không để trống' : null
            : null,
      ),
    );
  }
}
