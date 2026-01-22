<?php
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);


    session_start();
    include 'db.php';
    $message = '';

    if ($_SERVER["REQUEST_METHOD"] === "POST") {
        if (isset($_POST["username"]) && isset($_POST["password"])) {
            $username = $_POST["username"];
            $password = $_POST["password"];

    $sql = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";

    $result = $conn->query($sql);

    if($result-> num_rows > 0){
        $message = 'Login thành công';
    }else {
        $message = 'Login thất bại';
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SQL Injection to RCE</title>
</head>
<body>
    <h2>Đăng nhập</h2>
    <form method="POST" action="login.php">
        <label for ="username">username</label>
        <input type="text" name="username"></br>
        <label for="password">password</label>
        <input type="password" name="password"></br>
        <button type="submit" name="login" value="login">login</button>
    </form>
</br>
<?php echo $message; ?>
</body>
</html>