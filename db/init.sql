CREATE DATABASE IF NOT EXISTS sqllab;
USE sqllab;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(50) NOT NULL
);


INSERT IGNORE INTO users (username, password) VALUES ('admin', 'flag{sqli_injection}');



-- tạo ra user01 , password 12345678
CREATE USER IF NOT EXISTS 'user01'@'%' IDENTIFIED BY '12345678';
GRANT ALL PRIVILEGES ON sqllab.* TO 'user01'@'%';
-- cấp quyền FILE , các bạn cứ hiểu như user thường kết nối với db chỉ được dùng các câu lệnh như union , select , update ,...
-- nếu dùng INTO OUTFILE là nó lỗi ngay
GRANT FILE ON *.* TO 'user01'@'%'; 
FLUSH PRIVILEGES;
