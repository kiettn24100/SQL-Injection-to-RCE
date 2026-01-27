<?php

$nameservice = "sqli-to-rce"; 
$username = "admin";  # <--- do ở đây cấp quyền root
$password = "12345678";
$dbname = "rcelab";

$conn = new mysqli($nameservice, $username, $password, $dbname);

if ($conn->connect_error) {
    die("connect failed". $conn->connect_error);
}


