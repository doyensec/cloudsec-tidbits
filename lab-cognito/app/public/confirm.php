<?php
require '../vendor/autoload.php';

use AWSCognitoApp\AWSCognitoWrapper;

$wrapper = new AWSCognitoWrapper();
$wrapper->initialize();

if(isset($_POST['action'])) {
    $username = $_POST['username'] ?? '';
    $confirmation = $_POST['confirmation'] ?? '';

    $error = $wrapper->confirmSignup($username, $confirmation);

    if(empty($error)) {
        header('Location: index.php?confirmed');
    }
}

$username = $_GET['username'] ?? '';
?>

<!doctype html>
<html>
    <head>
        <meta charset='utf-8'>
        <meta http-equiv='x-ua-compatible' content='ie=edge'>
        <title>AWS Cognito App - CloudSecPill2</title>
        <meta name='viewport' content='width=device-width, initial-scale=1'>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="">
        <meta name="generator" content="Hugo 0.98.0">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
    
        <!-- Custom styles for this template -->
        <link href="signin.css" rel="stylesheet">
  </head>
    </head>
    <body class="text-center">
        <main class="form-signin w-100 m-auto">
            <p style='color: red;'><?php echo $error;?></p>
            <h1 class="h3 mb-3 fw-normal">Confirm signup</h1>
            <form method='post' action=''>
                <input type='text' class="form-control" placeholder='Username' name='username' value='<?php echo $username;?>' /><br />
                <input type='text' class="form-control" placeholder='Confirmation code' name='confirmation' /><br />
                <input type='hidden' name='action' value='confirm' />
                <input type='submit' class="w-100 btn btn-lg btn-primary" value='Confirm' />
            </form>
        </main>
    </body>
</html>
