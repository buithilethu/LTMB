import 'dart:io';

void main(){
  // nhập tên người dùng
  stdout.write('Enter your name:');
  String name = stdin.readLineSync()!;

  // Nhập tuổi người dùng
  stdout.write('Enter your age:');
  int age = int.parse(stdin.readLineSync()!);

  print("xin chào:$name,tuổi của bạn là:$age");
}