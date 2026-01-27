# SQL-Injection-to-RCE

Trước hết thì cần hiểu cấu trúc của cái phần tổ chức của một trang web

để mình nói qua đoạn này cho các bạn hiểu , các website hiện này thường thì sẽ chạy trên 1 máy chủ ảo .

Tức là , có một cái máy chủ vật lý , trong đó sẽ chứa rất nhiều máy chủ ảo . Và để 1 website hoạt động thì sẽ có một hoặc nhiều container có các chức năng xử lý khác nhau tạo nên 1 trang web

Nói dễ hiểu thì , giả sử máy chủ vật lý sẽ có một ổ cứng khoảng 10.000GB tùy loại , và sử dụng khoảng 100GB cho một máy chủ ảo (dạng dạng thế) . Tiếp tục một website khi chạy trên cái máy chủ ảo thì nó có thể có 2 container là container web và container db đang chạy trên máy chủ ảo đó 

2 cái container đó nó nằm trên 2 đường dẫn khác nhau trong thư mục của máy chủ ảo
```
/var/lib/docker/<container_id_web>
```
```
/var/lib/docker/<container_id_db>
```
RỒi giờ vào cái chính.

Giả sử trang `banhangonline.com` , ở đó nó sẽ có các chức năng như Đăng kí , Đăng nhập , Hiển thị thông tin sản phẩm , Thanh toán ,...

website đó chạy trên một máy chủ ảo , chúng có 3 Container riêng biệt để xử lý.

- Container web: xử lý cái phần giao diện , chứa html , css , js

- Container xử lý logic: nó chứa những code xử lý như register.php , buy.php , login.php , index.php

- Container xử lý database: cái này chứa dữ liệu . Xử lý những truy vấn sql 

Giả sử khi mà bấm vào xem cái áo thun 

Container web sẽ gửi yêu cầu đến cái container xử lý logic , hãy đưa thông tin cái áo id=10 đây

Container xử lý logic nó lại gửi một truy vấn rằng
```sql
SELECT * FROM product WHERE id=10
```
Gửi cái truy vấn đó đến Container xử lý database cũng thông qua network

Container xử lý database nó tìm trong ổ cứng của nó , lấy dữ liệu rồi gửi lại và cứ thế hiển thị ra màn hình

Tương tự nếu mà chúng ta đăng nhập hay đăng kí cũng thế 

Container web gửi dữ liệu user đã đăng kí đến Container logic rồi từ đó gửi truy vấn
```sql
INSERT INTO users(username,password) values('abc123','12345678')
```
Gửi đến Container Database , rồi nó thực hiện câu truy vấn đó , lưu vào trong database

Vậy nếu ở cái chức năng hiển thị thông tin sản phẩm nó bị lỗi SQLi, chúng ta chèn được câu truy vấn thực hiện RCE thì sao 
```sql
SELECT '<?php system('whoami'); ?>' INTO OUTFILE 'var/www/html/shell.php'
```
Lúc này tương tự vào đến Container db xử lý , nó thực hiện ghi file shell.php vào trong `var/www/html` của container db 

Vậy thì chúng ta làm được gì không , khi truy cập lại vào `banhangonline/shell.php` thì Container web nó tìm kiếm trong `var/www/html` của nó coi có shell.php nào không

Và kết quả là chắc chắn 404 not found rồi. Bởi vì mỗi một container nó sẽ có một đường dẫn ổ cứng riêng của nó 

Của container web
```
/var/lib/docker/<container_id_web>/var/www/html
```
Của container db
```
/var/lib/docker/<container_id_db>/var/www/html
```
Các bạn đã thấy sự khác biệt chưa . Chính vì Container db thực hiện truy vấn chèn shell.php vào trong `/var/www/html`. Cho nên nó đã chèn vào trong Container của nó 

Mà ở cái dùng để hiển thị giao diện web , cái mà chúng ta thấy được lại là do Container web xử lý ra


Vậy để khi mà chúng ta truy vấn ghi file shell.php được thực hiện ở Container db mà muốn bên container web bị dính file shell.php kia thì cái `/var/www/html` phải là cái dùng chung giữa container db và container web

Điều đó chỉ có thể khi mà , chức năng xử lý web và xử lý db nó cùng một container Hoặc là cả 2 cái `/var/www/html` của 2 container web và db phải cùng mount tới một volume 

Nhưng mà từ xa xưa h các website thường làm vẫn là nhét database , web server , code vào chung một container , cái cách đó gọi là Monolithic Architecture , còn cái mà tách từng container riêng kia gọi là Micro Architecture.

Bản chất thì khi mà gửi dữ liệu hợp lệ thì cái dữ liệu đó sẽ luôn được đưa đến `/var/lib/mysql` như vầy . Còn cái `/var/www/html` là cái folder chứa những file `.html`, `.php` để hiển thị ra giao diện người dùng 

**TÓM LẠI , ĐIỀU KIỆN THỨ NHẤT ĐỂ SQLI TO RCE ĐƯỢC LÀ PHẢI CÙNG CHUNG 1 CONTAINER VÀ FOLDER MÀ DB NÓ GHI FILE VÀO PHẢI LÀ CÁI FOLDER MÀ WEB SERVER NÓ CÓ THỂ ĐỌC VÀ THỰC THI ĐƯỢC**


-----

Tiếp theo hãy xét đến từng lớp bảo mật , cái đầu tiên đó chính là cái quyền để có thể thực hiện các thao tác nhập và xuất dữ liệu của MySQL 

Biến `secure_file_priv` . Biến này được tạo ra để giới hạn các thao tác nhập và xuất dữ liệu với những câu lệnh như `SELECT .... INTO OUTFILE ....` , đây là những lệnh chỉ được thực hiện bởi những người dùng có đặc quyền 

Biến `secure_file_priv` có thể được thiết lập như sau:

 - Nếu để trống , biến này sẽ không có tác dụng , tức là tất cả mọi người dù có là ai thì đều có thể thực hiện được việc ghi file , chèn file vào bất cứ folder nào 

 - Nếu được thiết lập bằng với tên của một thư mục , thì lúc này MySQL nó sẽ quy định all user chỉ có thể nhập xuất dữ liệu với các tệp trong thư mục đó 

 - Nếu để bằng với NULL , thì MySQL sẽ vô hiệu hóa các thao tác nhập xuất dữ liệu , kể cả khi bạn có quyền root nhưng cái biến này bằng NULL thì bạn cũng không có quyền ghi file vào trong bất cứ folder nào 

(Nguồn: https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_secure_file_priv)

Vậy thì như đã nói trên , để có thể thực hiện việc ghi file RCE được thì buộc điều kiện cái biến `secure_file_priv` nó phải là trống hoặc phải bằng với tên thư mục mình cần ghi File vào đó

----

Sau khi đã có quyền của MySQL thì chúng ta cần thêm quyền từ hệ điều hành Linux , nó có cho phép MySQL thực hiện ghi File hoặc thực thi File trên Folder đấy hay không

(nguồn: https://viblo.asia/p/chmod-777-no-thuc-su-nghia-la-gi-E375zw4JKGW)

Trong Linux , có 2 phần thường lấy ra để xác định việc kiểm soát file , đó là `Classes` và `Permission`. Classes xác định ai có thể truy cập vào file còn `Permission` xác định loại hành động có thể thực hiện với File

Classes có 3 loại gồm: Owner (người tạo ra các file folder) , Group(một nhóm người có chung permission) , Others(những người dùng khác trong hệ thống)

Permission có 3 loại gồm: Read(chỉ đọc) , Write(được quyền ghi vào folder , sửa đổi nội dung file), excute(được quyền thực thi file)

Tiếp theo mình sẽ nói đến cái con số 777 , 775 ,644 , ... cho các bạn dễ hiểu . Chữ số đầu tiên sẽ đại diện cho quyền của owner , chữ số thứ hai sẽ là quyền của Group , chữ số thứ 3 sẽ là quyền của Other

Với các quyền nói nôm na là nó được gán với các con số , quyền Read số 4 , quyền Write số 2 , quyền excute số 1 , Nếu owner có cả 3 quyền thì sẽ là 4+2+1 = 7 , Nếu group chỉ có read và write thì sẽ là 4+2 = 6 , và Other chỉ có quyền Read thì sẽ là 4

Vậy là chúng ta đã thiết lập được xong quyền thao tác với file đối với 3 loại đối tượng ở trong một Folder bằng con số 764

Và tương tự , Ở đây chúng ta cần `Mysql` thực hiện ghi file vào trong folder `/var/www/html` , ở folder này thì web server chính là Owner còn Mysql thuộc others , Vì thế để Mysql có thể ghi file được vào folder thì chúng ta cần quyền Execute và quyền Write là được tức là Other lúc này sẽ là số 3 hoặc số 7 (Có thể ko cần read cũng được)

Lưu í ở đây nữa , nếu chỉ cần other là số 7 thì chưa hết được , có thể các bạn thắc mắc vậy thì Owner là số 4 cũng được mà đúng ko ? Nhưng khi Owner là số 4 , ở trong thư mục /var/www/html , Web Server nó là Owner , nếu nó chỉ có quyền đọc thì làm sao mà có thể thực thi được đúng ko ? Vậy thì bây giờ Owner cần Read và Execute , Group thì cái gì cũng được, Còn Other thì phải có quyền Write và Execute (Nhắc lại đây là quyền đối với một Folder nhá)


**ĐIỀU KIỆN THỨ 3: Set quyền đối với folder /var/www/html là 777 hoặc 503 hoặc 753 ,.... đều được**

----

Chúng ta đã có quyền chèn file vào folder `/var/www/html` , có `secure_file_priv` = rỗng tức là có thêm quyền ghi file vào bất cứ folder nào rồi 

Nhưng vẫn chưa đủ , được quyền ghi file vào bất cứ folder nào nhưng liệu có quyền thực hiện lệnh ghi file không mới là vấn đề 

Giống như việc , khi bạn là user thường , thì bạn chỉ có quyền thực hiện các lệnh như SELECT , UPDATE , DELETE bình thường thôi . Còn cái `SELECT .... INTO OUTFILE ...` kia thì chỉ dành cho người có quyền cao hơn trong hệ thống 

Nói tóm lại: **ĐIỀU KIỆN THỨ 4: BẠN CÓ QUYỀN ROOT HOẶC NẾU LÀ USER THƯỜNG THỈ PHẢI ĐƯỢC CẤP QUYỀN THỰC HIỆN CÁC CÂU LỆNH TỐI CAO ĐÓ**





