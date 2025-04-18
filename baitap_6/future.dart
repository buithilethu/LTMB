/*
Future là gì? 
Hãy tưởng tượng bạn gọi món ăn tại một nhà hàng: 
+ Bạn đặt món (gọi một hàm) 
+ Nhân viên phục vụ nói "vàng, tôi sẽ mang món ăn đến sau" (nhận về một Future) 
+ Bạn có thể làm việc khác trong lúc chờ đợi (tiếp tục chạy code) 
Khi môn ân được phục vụ (Future hoàn thành), bạn có thể thưởng thức nó (sử dụng kết quả) 
Future trong Dart cũng hoạt động tương tự. Đó là một cách để làm việc với các tác vụ mất thời gian
không phải chờ đợi (ví dụ: tải dữ liệ từ internet, đọc tệp).


Hiểu rõ về "async/await" 
async và await là hai từ khóa đặc biệt trong Dart giúp làm việc với Future dễ dàng hơn. 

Từ khóa async: 
- Khi thêm từ khóa async vào một hàm, bạn đang nói với Dart: "Hàm này sẽ chứa code bất đồng bộ" 
Một hàm được đánh dấu async sẽ luôn luôn trả về một Future (ngay cả khi bạn không khai bảo nó) 
I 

- Nếu bạn return một giá trị không phải Future từ một hàm async,
 Dant sẽ tự động đóng gói nó trong Future.
*/

// Hàm trả về Future
Future<String> taiDuLieu(){ 
    return Future.delayed( 
Duration (seconds: 2), 
() => "Dữ liệu đã tải xong "
    ) ; // Future.delayed 
}
// Hàm chính 
void hamChinh() async { 
print("Bắt đầu tải ..."); 
String ketQua = await taiDuLieu(); 
print("Kết quả: $ketQua"); 
print("Tiếp tục công việc khác"); 
} 

// Hàm chính 2
void hamChinh2() { 
    print("Bắt đầu tải ..."); 
    Future<String>ketQua = taiDuLieu();
    print("Kết quả: $ketQua");
    print("Teip61 tục công việc khác");
}

// Hàm chính 3
void hamChinh3() { 
    print("Bắt đầu tải ..."); 
    Future<String> future = taiDuLieu(); 
    print("Tiếp tục công việc khác trong khi đang tải"); 
    future.then((ketQua) { 
        print("Kết quả: $ketQua"); 
    }); 
}

//-----------------------------------

void main() {
    hamChinh3();
}