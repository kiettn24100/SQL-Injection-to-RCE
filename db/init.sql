CREATE DATABASE IF NOT EXISTS sqllab;
USE sqllab;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(50) NOT NULL
);


INSERT IGNORE INTO users (username, password) VALUES ('admin', 'flag{sqli_injection}');
