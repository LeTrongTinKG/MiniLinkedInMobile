import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../providers/auth_provider.dart';

/// Khối Form nhập liệu và xác thực đăng ký tài khoản.
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, required this.auth, required this.isLoading});

  final AuthProvider auth;
  final bool isLoading;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    String? nErr;
    String? eErr;
    String? pErr;
    String? cErr;

    if (name.isEmpty) {
      nErr = 'Vui lòng nhập họ và tên';
    }

    if (email.isEmpty) {
      eErr = 'Vui lòng nhập email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      eErr = 'Email không hợp lệ';
    }

    if (password.isEmpty) {
      pErr = 'Vui lòng nhập mật khẩu';
    } else if (password.length < 6) {
      pErr = 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    if (confirm != password) {
      cErr = 'Mật khẩu xác nhận không khớp';
    }

    setState(() {
      _nameError = nErr;
      _emailError = eErr;
      _passwordError = pErr;
      _confirmError = cErr;
    });

    return nErr == null && eErr == null && pErr == null && cErr == null;
  }

  void _submit() {
    if (_validate()) {
      widget.auth.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          controller: _nameController,
          placeholder: 'Họ và tên',
          leadingIcon: Icons.person_outline,
          errorText: _nameError,
          enabled: !widget.isLoading,
          onChanged: (_) {
            if (_nameError != null) setState(() => _nameError = null);
          },
        ),
        const SizedBox(height: 10),
        AppTextField(
          controller: _emailController,
          placeholder: 'example@email.com',
          keyboardType: TextInputType.emailAddress,
          leadingIcon: Icons.email_outlined,
          errorText: _emailError,
          enabled: !widget.isLoading,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        const SizedBox(height: 10),
        AppTextField(
          controller: _passwordController,
          placeholder: 'Mật khẩu',
          obscureText: _obscurePassword,
          leadingIcon: Icons.lock_outline,
          trailingIcon: _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onTrailingTap: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          errorText: _passwordError,
          enabled: !widget.isLoading,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
        ),
        const SizedBox(height: 10),
        AppTextField(
          controller: _confirmController,
          placeholder: 'Xác nhận mật khẩu',
          obscureText: _obscureConfirm,
          leadingIcon: Icons.lock_outline,
          trailingIcon: _obscureConfirm
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onTrailingTap: () {
            setState(() => _obscureConfirm = !_obscureConfirm);
          },
          errorText: _confirmError,
          enabled: !widget.isLoading,
          onChanged: (_) {
            if (_confirmError != null) setState(() => _confirmError = null);
          },
        ),
        const SizedBox(height: 18),
        AppButton(
          label: 'Tạo tài khoản',
          loading: widget.isLoading,
          fullWidth: true,
          onPressed: _submit,
        ),
      ],
    );
  }
}
