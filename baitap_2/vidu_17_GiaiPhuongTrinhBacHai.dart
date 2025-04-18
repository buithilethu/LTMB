//giải phương trình bật 2
import 'dart:io';
import 'dart:math';

void main() {
  stdout.write("Nhập hệ số a: ");
  double? a = double.tryParse(stdin.readLineSync() ?? '');

  stdout.write("Nhập hệ số b: ");
  double? b = double.tryParse(stdin.readLineSync() ?? '');

  stdout.write("Nhập hệ số c: ");
  double? c = double.tryParse(stdin.readLineSync() ?? '');

  if (a == null || b == null || c == null) {
    print("Vui lòng nhập số hợp lệ!");
    return;
  }

  if (a == 0) {
    if (b == 0) {
      print(c == 0 ? "Phương trình có vô số nghiệm." : "Phương trình vô nghiệm.");
    } else {
      double x = -c / b;
      print("Phương trình có một nghiệm: x = $x");
    }
    return;
  }

  double delta = b * b - 4 * a * c;

  if (delta > 0) {
    double x1 = (-b + sqrt(delta)) / (2 * a);
    double x2 = (-b - sqrt(delta)) / (2 * a);
    print("Phương trình có hai nghiệm phân biệt:");
    print("x1 = $x1");
    print("x2 = $x2");
  } else if (delta == 0) {
    double x = -b / (2 * a);
    print("Phương trình có nghiệm kép: x = $x");
  } else {
    print("Phương trình vô nghiệm.");
  }
}