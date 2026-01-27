<?php

$nameservice = "localhost"; 
$username = "admin";  
$password = "12345678";
$dbname = "sqllab";

$conn = new mysqli($nameservice, $username, $password, $dbname);

if ($conn->connect_error) {
    die("connect failed". $conn->connect_error);
}



