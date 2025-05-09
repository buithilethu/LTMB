import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

// Lớp RegisterScreen là một StatefulWidget, dùng để tạo giao diện đăng ký tài khoản
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

// Lớp state của RegisterScreen, quản lý trạng thái giao diện
class _RegisterScreenState extends State<RegisterScreen> {
  // Key để quản lý form, dùng để kiểm tra dữ liệu nhập vào
  final _formKey = GlobalKey<FormState>();
  // Controller để quản lý dữ liệu nhập vào ô username
  final _usernameController = TextEditingController();
  // Controller để quản lý dữ liệu nhập vào ô password
  final _passwordController = TextEditingController();
  // Controller để quản lý dữ liệu nhập vào ô email
  final _emailController = TextEditingController();
  // Biến lưu vai trò người dùng, mặc định là 'user'
  String _role = 'user';
  // Biến trạng thái để hiển thị loading khi đang xử lý đăng ký
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
              const SizedBox(height: 20), // Khoảng cách phía trên
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  // Tiêu đề lớn, đậm, màu xanh đậm
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to get started!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  // Mô tả phụ, màu xám
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32), // Khoảng cách trước form
              Card(
                // Card tạo hiệu ứng nổi cho form đăng ký
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
                            // Kiểm tra mật khẩu
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            // Yêu cầu mật khẩu chứa cả chữ và số
                            if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{6,}$').hasMatch(value)) {
                              return 'Password must contain letters and numbers';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Ô nhập email
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress, // Bàn phím tối ưu cho email
                          validator: (value) {
                            // Kiểm tra định dạng email
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Dropdown để chọn vai trò (user hoặc admin)
                        DropdownButtonFormField<String>(
                          value: _role, // Giá trị hiện tại
                          items: [
                            DropdownMenuItem(value: 'user', child: Text('User')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          ],
                          onChanged: (value) {
                            // Cập nhật vai trò khi người dùng chọn
                            setState(() {
                              _role = value!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Role',
                            prefixIcon: Icon(Icons.admin_panel_settings),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12), // Bo góc
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Hiển thị loading hoặc nút đăng ký
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          // Nút đăng ký
                          onPressed: () async {
                            // Kiểm tra form hợp lệ
                            if (_formKey.currentState!.validate()) {
                              // Bật trạng thái loading
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                // In log để debug
                                print('Checking username: ${_usernameController.text}');
                                // Kiểm tra username đã tồn tại chưa
                                final existingUser = await DatabaseHelper.instance.getUser(_usernameController.text);
                                if (existingUser != null) {
                                  print('Username already exists: ${_usernameController.text}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Username already exists')),
                                  );
                                  return;
                                }

                                // Tạo đối tượng User mới
                                final now = DateTime.now();
                                final user = User(
                                  id: now.toString(), // Sử dụng thời gian làm ID (không tối ưu)
                                  username: _usernameController.text,
                                  password: _passwordController.text,
                                  email: _emailController.text,
                                  role: _role,
                                  avatar: null,
                                  createdAt: now,
                                  lastActive: now,
                                );

                                // In log và thêm user vào database
                                print('Inserting user: ${user.toMap()}');
                                await DatabaseHelper.instance.insertUser(user);
                                print('User registered successfully: ${user.username}');

                                // Thông báo đăng ký thành công
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Registration successful! Please login.')),
                                );
                                // Quay lại màn hình trước (thường là LoginScreen)
                                Navigator.pop(context);
                              } catch (e) {
                                // Xử lý lỗi nếu có
                                print('Registration error: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Registration error: $e')),
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
                            'Sign Up',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Nút chuyển hướng đến màn hình đăng nhập
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Already have an account? Sign In',
                    style: TextStyle(color: Colors.blue.shade700),
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
    TextInputType? keyboardType, // Loại bàn phím (ví dụ: email)
    String? Function(String?)? validator, // Hàm kiểm tra dữ liệu
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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