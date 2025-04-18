void main() {
  // int : kiểu số nguyên
  int x =100;
  // double : là kiểu số thực
  double y = 100.5;
  // num : có thể chứa số nguyên hoặc chứa số thực
  num z = 10;
  num t = 10.75;
  // chuyển chuỗi sang số nguyên
  var one = int.parse('1');
  print(one==1?"TRUE":"FALSE");
  // chuyển chuỗi sang số thực
  var onePointOne = double.parse('1.1');
  print(onePointOne==1.1);
  // số nguyên => chuỗi
  String oneAsString =1.toString();
  print(oneAsString);
  //số thực -> chuỗi
  String piAsString =3.14259.toStringAsFixed(2);
  print(piAsString);
}