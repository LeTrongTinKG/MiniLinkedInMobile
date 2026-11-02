import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'domain/repositories/profile_repository.dart';
import 'presentation/viewmodels/profile_edit_view_model.dart';
import 'domain/models/profile_data.dart';
import 'widgets/profile_privacy_card.dart';
import '../auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) {
        final repo = c.read<ProfileRepository>();
        final vm = ProfileEditViewModel(repo);
        final user = c.read<AuthProvider>().currentUser;
        vm.init(ProfileData(
          fullName: user?.displayName ?? '',
          headline: 'Sinh viên CNTT · tìm thực tập',
          location: 'TP. Hồ Chí Minh',
          school: 'Đại học Khoa học Tự nhiên',
          major: 'Công nghệ Thông tin',
          about: 'Đam mê lập trình Flutter, muốn tìm cơ hội thực tập thực tế.',
          isPrivate: true, // Mặc định riêng tư (Ticket 02)
        ));
        return vm;
      },
      child: const _EditProfileForm(),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm();

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _headlineCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _schoolCtrl;
  late final TextEditingController _majorCtrl;
  late final TextEditingController _aboutCtrl;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileEditViewModel>().profile;
    _nameCtrl = TextEditingController(text: p.fullName);
    _headlineCtrl = TextEditingController(text: p.headline);
    _locationCtrl = TextEditingController(text: p.location);
    _schoolCtrl = TextEditingController(text: p.school);
    _majorCtrl = TextEditingController(text: p.major);
    _aboutCtrl = TextEditingController(text: p.about);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _headlineCtrl.dispose();
    _locationCtrl.dispose();
    _schoolCtrl.dispose();
    _majorCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(ProfileEditViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    vm.updateField(
      fullName: _nameCtrl.text,
      headline: _headlineCtrl.text,
      location: _locationCtrl.text,
      school: _schoolCtrl.text,
      major: _majorCtrl.text,
      about: _aboutCtrl.text,
    );
    final ok = await vm.save();
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật hồ sơ thành công!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileEditViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: vm.saving ? null : () => _save(vm),
            child: vm.saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Lưu',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfilePrivacyCard(vm: vm),
              const SizedBox(height: 16),
              _buildSectionTitle('Thông tin cơ bản'),
              _buildTextField('Họ và tên', _nameCtrl, isRequired: true),
              _buildTextField('Chức danh / Headline', _headlineCtrl),
              _buildTextField('Khu vực', _locationCtrl),
              const SizedBox(height: 16),
              _buildSectionTitle('Học vấn'),
              _buildTextField('Trường đại học', _schoolCtrl),
              _buildTextField('Chuyên ngành', _majorCtrl),
              const SizedBox(height: 16),
              _buildSectionTitle('Giới thiệu bản thân'),
              _buildTextField('Mô tả ngắn', _aboutCtrl, maxLines: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      );

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool isRequired = false,
    int maxLines = 1,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surface,
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        validator: isRequired
            ? (v) => (v == null || v.trim().isEmpty)
                ? 'Vui lòng không để trống'
                : null
            : null,
      ),
    );
  }
}
