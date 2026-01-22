<?php

$nameservice = "db-sqli"; 
$username = "root";  # <--- do ở đây cấp quyền root
$password = "admin";
$dbname = "rce_db";

$conn = new mysqli($nameservice, $username, $password, $dbname);

if ($conn->connect_error) {
    die("connect failed". $conn->connect_error);
}

