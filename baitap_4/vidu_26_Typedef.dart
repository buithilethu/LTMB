
/*
Typedefs trong Dart là một cách ngắn gọn để tạo ra các alias (bí danh) cho  các loại
dữ liệu. Điều này giúp mã nguồn trở nên rõ ràng và dễ đọc hơn, đặc biệt khi làm việc 
với các loại dữ liệu phức tạp.
*/

typedef InList = List<int>;

typedef ListMapper <X> = Map<X, List<X>>;

void main(){
  InList l1 = [1,2,3,4,5];
  print(l1);

  InList l2 = [1,2,3,4,5,6,7];
  

  Map<String, List<String>> m1 = {}; // khá dài
  ListMapper<String> m2 = {}; //m1 và m2 là cùng một kiểu


}