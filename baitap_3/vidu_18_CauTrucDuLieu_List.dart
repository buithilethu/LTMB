void main(){
  List<String> list1=['A', 'B', 'C', 'D', 'E', 'F'];
  var list2 =[1,2,3];
  List<String> list3=[];
  var list4=List<int>.filled(3,0);
  print(list4);

  list1.add('D');//thêm 1 phần tử
  list1.addAll(['A','C']);//thêm nhiều phần tử
  list1.insert(0, 'Z');//chèn 1
  list1.insertAll(1,['1','0']); // chèn nhiều phần tử
  print(list1);

  //2.xóa phần từ trong list
  list1.remove('A');
  list1.removeAt(0);
  list1.removeLast;
  list1.removeWhere((e)=>e=='B');
  list1.clear();
  print(list1);
  //3. truy cập phần tử
  print(list2[0]);//lấy phần tử tại vị trí 0;
  print(list2.first);
  print(list2.last);
  print(list2.length);
  // 4.Kiểm tra
  print(list2.isEmpty); // kiểm tra  rỗng
  print('List3: ${list3.isNotEmpty?'không rỗng':'rỗng'}');
  print(list4.contains('1'));
  print(list4.contains('0'));
  print(list4.indexOf(0));
  print(list4.lastIndexOf(0));

  //5. Biến đổi
  list4=[2,1,3,9,0,10];
  print(4);
  list4.sort();//sắp xếp tăng dần
  print(list4);
//sắp xếp giảm dần
  list4.reversed;//đảo ngược
  print(list4.reversed);
list4 = list4.reversed.toList();
  print(list4);

  // 7. Cắt và nối 
   var subList = list4.sublist(1,3);// cắt một sublist từ 1 ->3
   print(subList);
  var str_joined= list4.join(",");
   print(str_joined);
   //8. Duyệt các phần tử bên trong list
   list4.forEach((element){
     print(element);
   });
  
}

