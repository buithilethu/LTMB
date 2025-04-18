/*
BÀI TẬP: Cấu trúc dữ liệu trong Dart
====================================
Bài 1: List
 
Có bao nhiêu cách để khai báo một List trong đoạn code? Liệt kê và giải thích từng cách.
----------------------------------------------------------------
Cách 1: Sử dụng danh sách kiểu động (List<dynamic>)
var myList = [1, 2, 3]; // Danh sách có thể chứa bất kỳ kiểu dữ liệu nào
Cách 2: Xác định kiểu dữ liệu của List
List<int> numbers = [1, 2, 3, 4, 5]; // Chỉ chứa số nguyên
Cách 3: Sử dụng constructor List.empty()
var emptyList = List.empty(growable: true); // Danh sách rỗng có thể thay đổi kích thước
Cách 4: Sử dụng List.filled()
var filledList = List.filled(5, 0); // List gồm 5 phần tử có giá trị mặc định là 0
Cách 5: Sử dụng List.generate()
var generatedList = List.generate(5, (index) => index * 2); // [0, 2, 4, 6, 8]
----------------------------------------------------------------
Cho List ['A', 'B', 'C']. Viết code để:
 
Thêm phần tử 'D' vào cuối List
Chèn phần tử 'X' vào vị trí thứ 1
Xóa phần tử 'B'
--------------------------------------------------------------------------------------------------------------
In ra độ dài của List
 void main() {
  List<String> myList = ['A', 'B', 'C'];

  // Thêm phần tử 'D' vào cuối List
  myList.add('D');

  // Chèn phần tử 'X' vào vị trí thứ 1
  myList.insert(1, 'X');

  // Xóa phần tử 'B'
  myList.remove('B');

  // In ra độ dài của List
  print(myList.length); // Kết quả: 4

  // In ra danh sách
  print(myList); // ['A', 'X', 'C', 'D']
}
 ----------------------------------------------------------------
Đoạn code sau sẽ cho kết quả gì?
 
dartCopyvar list = [1, 2, 3, 4, 5];
list.removeWhere((e) => e % 2 == 0);
print(list);
[1,3,5]
 -----------------------------------------------
Giải thích sự khác nhau giữa các phương thức:
 
remove() và removeAt()
add() và insert()
addAll() và insertAll()
------remove() vs removeAt()------

remove(value): Xóa phần tử đầu tiên có giá trị bằng value.
removeAt(index): Xóa phần tử tại vị trí index trong List.
------add() vs insert()------

add(value): Thêm phần tử vào cuối List.
insert(index, value): Chèn phần tử vào vị trí index.
------addAll() vs insertAll()------

addAll(list): Thêm toàn bộ danh sách vào cuối List.
insertAll(index, list): Chèn danh sách vào vị trí index.

 
====================================
Bài 2: Set
 
Set khác List ở những điểm nào? Nêu ít nhất 3 điểm khác biệt.

- Không chứa phần tử trùng lặp.
- Các phần tử không có thứ tự cố định.
- Tìm kiếm phần tử nhanh hơn List.
Cho hai Set:
 
dartCopyvar set1 = {1, 2, 3};
var set2 = {3, 4, 5};
Tính kết quả của:
 
Union (hợp) ---  print(set1.union(set2)); // {1, 2, 3, 4, 5}
Intersection (giao) ---    print(set1.intersection(set2)); // {3}
Difference (hiệu) của set1 với set2 ---   print(set1.difference(set2)); // {1, 2}
 
 
Đoạn code sau sẽ cho kết quả gì?
 
dartCopyvar mySet = Set.from([1, 2, 2, 3, 3, 4]);
print(mySet.length);
 
 -->> 4
 
====================================
Bài 3: Map
 
Viết code để thực hiện các yêu cầu sau với Map:
 
dartCopyMap<String, dynamic> user = {
  'name': 'Nam',
  'age': 20,
  'isStudent': true
};
 
Thêm email: 'nam@gmail.com'
Cập nhật age thành 21
Xóa trường isStudent
Kiểm tra xem Map có chứa key 'phone' không
---------------------------------------------
void main() {
  Map<String, dynamic> user = {
    'name': 'Nam',
    'age': 20,
    'isStudent': true
  };

  // Thêm email
  user['email'] = 'nam@gmail.com';

  // Cập nhật tuổi thành 21
  user['age'] = 21;

  // Xóa trường isStudent
  user.remove('isStudent');

  // Kiểm tra key 'phone' có tồn tại không
  print(user.containsKey('phone')); // false
}
 ------------------------------------------
So sánh hai cách truy cập giá trị trong Map:
 
dartCopyuser['phone']
user['phone'] ?? 'Không có số điện thoại'
- user['phone'] trả về null nếu không có key phone.
- user['phone'] ?? 'Không có số điện thoại' trả về 'Không có số điện thoại' nếu key không tồn tại.
Viết một hàm nhận vào một Map và in ra tất cả các cặp key-value, mỗi cặp trên một dòng.
 -----------------
 void printMap(Map<dynamic, dynamic> map) {
  map.forEach((key, value) {
    print('$key: $value');
  });
}

void main() {
  Map<String, dynamic> user = {
    'name': 'Nam',
    'age': 21,
    'email': 'nam@gmail.com'
  };

  printMap(user);
}
----------------
====================================
Phần 4: Runes
 
Runes được sử dụng để làm gì?
- Runes trong Dart dùng để đại diện cho ký tự Unicode.
- Dùng để biểu diễn các emoji, ký tự đặc biệt.
Cho ví dụ cụ thể.


------------------------------
Viết code để:
 
 
Tạo một Runes chứa ký tự emoji cười 😀
Chuyển đổi Runes đó thành String
In ra số lượng điểm mã của Runes
 ---------
 void main() {
  // Tạo một Runes chứa ký tự emoji cười 😀
  Runes emoji = Runes('\u{1F600}');

  // Chuyển đổi Runes thành String
  String emojiString = String.fromCharCodes(emoji);

  // In ra số lượng điểm mã của Runes
  print(emojiString); // 😀
  print(emoji.length); // 1
}
------------
*/