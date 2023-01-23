<?php
require '../vendor/autoload.php';

use AWSCognitoApp\AWSCognitoWrapper;

$wrapper = new AWSCognitoWrapper();
$wrapper->initialize();

if(isset($_POST['action'])) {

    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';
    $role = 'user';

    if($_POST['action'] === 'register') {
        $email = $_POST['email'] ?? '';
        $error = $wrapper->signup($username, $email, $password, $role);

        if(empty($error)) {
            header('Location: confirm.php?username=' . $username);
            exit;
        } else {
          $err = $error;
        }
    }

    if($_POST['action'] === 'login') {
        $error = $wrapper->authenticate($username, $password);

        if(empty($error)) {
            header('Location: secure.php');
            exit;
        } else {
          $error = "Login error";
        }
    }
}

$message = '';
if(isset($_GET['reset'])) {
    $message = 'Your password has been reset. You can now login with your new password';
} elseif(isset($_GET['confirmed'])) {
    $message = 'Your email is now confirmed. You can now login with your new account';
}
?>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="generator" content="Hugo 0.98.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>

    <title>AWS Cognito App - CloudSecPill2</title>
   
    <!-- Custom styles for this template -->
    <link href="signin.css" rel="stylesheet">
  </head>
  <body class="text-center">
    <main class="form-signin w-100 m-auto">
        <p style='color: red;'><?php echo $err;?></p>
        <p style='color: green;'><?php echo $message;?></p>
        <h1 class="h3 mb-3 fw-normal">Please Sign In</h1>
        <div class="form-floating">
          <form method='post' action=''>
                <input type='text' class="form-control" placeholder='Username' name='username' /><br />
                <input type='password' class="form-control" placeholder='Password' name='password' /><br />
                <input type='hidden' name='action' value='login' />
                <input type='submit' class="w-100 btn btn-lg btn-primary" value='Login' />
          </form>
          <p><a href='/forgotpassword.php' class="link-primary">Forgot password?</a></p>
        </div>
        <h1 class="h3 mb-3 fw-normal"><br>Or<br></h1>
        <div class="form-floating">
          <form method='post' action=''>
                <input type='text' class="form-control" placeholder='Username' name='username' /><br />
                <input type='text' class="form-control" placeholder='Email' name='email' /><br />
                <input type='password' class="form-control" placeholder='Password' name='password' /><br />
                <input type='hidden' name='action' value='register' />
                <input type='submit' class="w-100 btn btn-lg btn-primary" value='Sign Up' />
          </form>
        </div>
    </main>
  </body>
</html>
