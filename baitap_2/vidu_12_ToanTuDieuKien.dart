/*
 expr1 ? expr2 : expr3;
 Nếu expr1 đúng , trả về expr2; ngược lại , trả về expr3

expr1 ??  expr2;
nếu expr1 không null thì trả về giá trị của nó ;
ngược lại trả về expr2



*/
void main() {
  var kiemTra = (100%2==0)?"100 là số chẵn":"100 là số lẻ";
  print(kiemTra);

  var x = 100 ;
  var y = x ?? 50;
  print(y); // in ra 100

  int ? z ;
  y = z ?? 30;
  print(y); // in ra 30 
}