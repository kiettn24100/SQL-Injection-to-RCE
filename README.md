# SQL-Injection-to-RCE

# 1.Khái niệm

Đây cũng chỉ là một kĩ thuật SQL Injection khác thôi . 

Nhưng khác với các kỹ thuật khai thác còn lại chỉ có thể đọc được dữ liệu ở trong database , kỹ thuật này nó còn có thể chiếm quyền điều khiển máy chủ , thực hiện ghi File và thực thi lệnh trực tiếp 

# 2.Cơ chế 

Ở trong MySQL , chúng ta có thể sử dụng lệnh này để xuất kết quả ra một file
```sql
SELECT ... INTO OUTFILE ...
```
Giả sử chúng ta truyền vào
```sql
SELECT "<?php system($_GET['cmd']"; ?>" INTO OUT FILE 'var/www/html/shell.php'
```
Kết quả: Sau khi tạo file shell.php , chỉ cần truy cập vào đường dẫn `http://test.com/shell.php?cmd=whoami` để thực thi lệnh trên Server 

Có một hàm khác trong MySQL có chức năng đọc file hệ thống nữa là hàm `LOAD_FILE()` . Bạn cũng có thể sử dụng
```sql
SELECT LOAD_FILE('/etc/passwd')
```
Để đọc các file cấu hình của hệ thống 

Giờ vào cái chính 

# 3. Điều kiện để SQLi to RCE

Thứ nhất là quyền `root` hoặc `sa`. Giải thích dễ hiểu thì các bạn cứ hiểu thế này . Giả sử trong backend sẽ có đoạn này
```sql
$nameservice = "db-blind-sqli";
$username = "user";
$password = "123456";
$dbname = "blind_sqli_db";
```
Ở dòng `$username` đó , mỗi khi bạn vào trang web với quyền là một người dùng , thì cái username đó luôn luôn là user . Cái này ảnh hưởng đến quyền của bạn có thể sử dụng những câu lệnh với Database . 

Nhưng ở đây bạn phải phân biệt , bạn đăng nhập ở web nó khác với cái mà code web của bạn kết nối với Database . Với quyền user khi kết nối tới database thì Database nó chỉ cho code web của bạn gửi những câu lệnh chứa giả sử như `UNION` , `SELECT` , ... CÒn khi gửi những lệnh mà chứa các từ như `INTO OUT FILE` kia thì Database sẽ chặn ngay 

Vậy thì cái đầu tiên cần để có thể thực thi RCE được chính là `backend` nó set up là `$username = "root"` 

Tiếp tục , khi đã có quyền `root` kết nối với database thì Điều kiện cần tiếp theo đó chính là: 

Với quyền root đó , cũng cần phải có quyền để ghi file vào thư mục Web bởi vì không hẳn có root là có thể làm tất cả 

Giống như lúc nãy khi ta sử dụng 
```sql
SELECT "<?php system($_GET['cmd']"; ?>" INTO OUT FILE 'var/www/html/shell.php'
```
Chúng ta sẽ không thể chèn file `shell.php` kia vào trong thư mục `var/www/html` được nếu mà không có quyền root và không có quyền khi đè file vào thư mục Web

Đấy là đối với hệ quản trị cơ sở dữ liệu MySQL . 

Còn đối với MSSQL , thì sau khi có root thì các file `.dll` vốn thư viện hỗ trợ các chức năng thực hiện các câu lệnh CMD kia không được xóa đi 



