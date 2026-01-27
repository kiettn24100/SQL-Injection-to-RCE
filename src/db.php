<?php

$nameservice = "localhost"; 
$username = "admin";  
$password = "12345678";
# $dbname = "sqllab";

# cái image này vì nó không có tự động tạo db nên nếu mà ở đây mình add thêm $dbname vào thì nó sẽ báo lỗi unknow database liền , các bạn có thể tự test , cứ thêm $dbname vào
# mở kết nối tới db và dùng lệnh thực thi khởi tạo database 
$conn = new mysqli($nameservice, $username, $password);
if ($conn->connect_error) {
    die("Kết nối thất bại: " . $conn->connect_error);
}
# kiểm tra kết nối 
echo "Kết nối thành công";

# bởi vì dùng cái image lampstack này , Cái Image này được thiết kế để người dùng tự tạo Database bằng tay (vào phpMyAdmin bấm nút tạo, hoặc gõ lệnh).
# Nó không có cơ chế tự động đọc file .sql khi khởi động như các Image MySQL chuyên dụng (mysql/mariadb).
# vì vậy phải dùng multi_query trong db.php để ép nó tạo database
# nguồn: https://hub.docker.com/r/mattrayner/lamp
$query = file_get_contents('/var/www/html/init.sql');
$conn->multi_query($query);
$conn->select_db("sqllab");

$conn->close();
sleep(1);
# kết nối cũ dùng để khởi tạo rồi thì đóng lại và mở kết nối này để kết nối với sqllab dùng cho login.php
$conn = new mysqli($nameservice, $username, $password);
if ($conn->connect_error) {
    die("Kết nối lại thất bại: " . $conn->connect_error);
}
echo "Kết nối thành công";


if (!$conn->select_db("sqllab")) { 
    die("Không thể chọn database: " . $conn->error);
}
?>


