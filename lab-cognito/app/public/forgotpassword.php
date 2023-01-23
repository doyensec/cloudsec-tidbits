<?php
require '../vendor/autoload.php';

use AWSCognitoApp\AWSCognitoWrapper;

$wrapper = new AWSCognitoWrapper();
$wrapper->initialize();

$entercode = false;

if(isset($_POST['action'])) {

    if($_POST['action'] === 'code') {
        $username = $_POST['username'] ?? '';

        $error = $wrapper->sendPasswordResetMail($username);

        if(empty($error)) {
            header('Location: forgotpassword.php?username=' . $username);
        }
    }

    if($_POST['action'] == 'reset') {

        $code = $_POST['code'] ?? '';
        $password = $_POST['password'] ?? '';
        $username = $_GET['username'] ?? '';
        try {
            $error = $wrapper->resetPassword($code, $password, $username);
            if(empty($error)) {
                header('Location: index.php?reset');
            }
        } catch (Exception $err){
            $err = "Something went wrong";
        }
    }
}

if(isset($_GET['username'])) {
    $entercode = true;
}
?>

<!doctype html>
<html>
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
            <?php if($entercode) { ?>
            <h1 class="h2 mb-3 fw-normal">Reset password</h1>
            <p class="h6">If your account was found, an e-mail has been sent to the associated e-mail adress. Enter the code and your new password.</p>
            <div class="form-floating">
            <form method='post' action=''>
                <input type='text' class="form-control" placeholder='Code' name='code' /><br />
                <input type='password' class="form-control" placeholder='Password' name='password' /><br />
                <input type='hidden' name='action' value='reset' />
                <input type='submit' class="w-100 btn btn-lg btn-primary" value='Reset password' />
            </form>
            </div>
            <?php } else { ?>
            <h1 class="h2 mb-3 fw-normal">Forgotten password</h1>
            <p class="h6">Enter your username and we will sent you a reset code to your e-mail adress.</p>
            <div class="form-floating">
                <form method='post' action=''>
                    <input type='text' class="form-control" placeholder='Username' name='username' /><br />
                    <input type='hidden' name='action' value='register' />
                    <input type='hidden' name='action' value='code' />
                    <input type='submit' class="w-100 btn btn-lg btn-primary" value='Receive code' />
                </form>
            </div>
            <?php }?>
        </main>
    </body>
</html>
