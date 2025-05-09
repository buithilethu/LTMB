import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

// Lớp LoginScreen là một StatefulWidget, dùng để tạo giao diện đăng nhập
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// Lớp state của LoginScreen, quản lý trạng thái giao diện
class _LoginScreenState extends State<LoginScreen> {
  // Key để quản lý form, dùng để kiểm tra dữ liệu nhập vào
  final _formKey = GlobalKey<FormState>();
  // Controller để quản lý dữ liệu nhập vào ô username
  final _usernameController = TextEditingController();
  // Controller để quản lý dữ liệu nhập vào ô password
  final _passwordController = TextEditingController();
  // Biến trạng thái để hiển thị loading khi đang xử lý đăng nhập
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold cung cấp cấu trúc cơ bản cho giao diện
      body: SafeArea(
        // SafeArea đảm bảo nội dung không bị che bởi notch hoặc thanh trạng thái
        child: SingleChildScrollView(
          // Cho phép cuộn nội dung nếu nội dung vượt quá màn hình
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            // Sắp xếp các widget theo chiều dọc
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // Khoảng cách phía trên
              Center(
                // Căn giữa icon khóa
                child: Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 16), // Khoảng cách giữa icon và text
              Center(
                // Căn giữa tiêu đề và mô tả
                child: Column(
                  children: [
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        // Tiêu đề lớn, đậm, màu xanh đậm
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        // Mô tả phụ, màu xám
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32), // Khoảng cách trước form
              Card(
                // Card tạo hiệu ứng nổi cho form đăng nhập
                elevation: 8, // Độ nâng của card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Bo góc card
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    // Form để quản lý và kiểm tra dữ liệu nhập
                    key: _formKey,
                    child: Column(
                      children: [
                        // Ô nhập username
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          icon: Icons.person,
                          validator: (value) {
                            // Kiểm tra dữ liệu nhập
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16), // Khoảng cách giữa các ô
                        // Ô nhập password
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock,
                          obscureText: true, // Ẩn ký tự khi nhập mật khẩu
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Hiển thị loading hoặc nút đăng nhập
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          // Nút đăng nhập
                          onPressed: () async {
                            // Kiểm tra form hợp lệ
                            if (_formKey.currentState!.validate()) {
                              // Bật trạng thái loading
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                // In log để debug
                                print('Attempting login for username: ${_usernameController.text}');
                                // Lấy thông tin người dùng từ database
                                final user = await DatabaseHelper.instance.getUser(_usernameController.text);
                                // Kiểm tra username và password
                                if (user != null && user.password == _passwordController.text) {
                                  print('Login successful for user: ${user.username}, id: ${user.id}');
                                  // Cập nhật thời gian hoạt động gần nhất
                                  await DatabaseHelper.instance.updateLastActive(user.id);
                                  // Chuyển hướng đến màn hình tasks và truyền thông tin user
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/tasks',
                                    arguments: user,
                                  );
                                } else {
                                  // Thông báo lỗi nếu username hoặc password sai
                                  print('Login failed: Invalid username or password');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Invalid username or password')),
                                  );
                                }
                              } catch (e) {
                                // Xử lý lỗi nếu có
                                print('Login error: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Login error: $e')),
                                );
                              } finally {
                                // Tắt trạng thái loading
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50), // Nút chiếm toàn chiều rộng
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Bo góc nút
                            ),
                            backgroundColor: Colors.blue.shade700, // Màu nền nút
                            foregroundColor: Colors.white, // Màu chữ/icon
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Nút chuyển hướng đến màn hình đăng ký
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            'Don’t have an account? Sign Up',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tạo widget TextFormField tái sử dụng
  Widget _buildTextField({
    required TextEditingController controller, // Controller để quản lý dữ liệu nhập
    required String label, // Nhãn của ô nhập
    required IconData icon, // Icon hiển thị bên trái
    bool obscureText = false, // Ẩn ký tự (dùng cho mật khẩu)
    String? Function(String?)? validator, // Hàm kiểm tra dữ liệu
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Bo góc ô nhập
        ),
        filled: true,
        fillColor: Colors.grey.shade50, // Màu nền nhạt
      ),
    );
  }
}