<?php
require '../vendor/autoload.php';

use AWSCognitoApp\AWSCognitoWrapper;

$wrapper = new AWSCognitoWrapper();
$wrapper->initialize();

if(!$wrapper->isAuthenticated()) {
    header('Location: /');
    exit;
}

$user = $wrapper->getUser();
$pool = $wrapper->getPoolMetadata();
$users = $wrapper->getPoolUsers();

$UserAttributes = $user->get('UserAttributes');
foreach($UserAttributes as $attr) {
    if (array_values($attr)[0] == 'custom:Role'){
        $current_role = array_values($attr)[1];
    } elseif (array_values($attr)[0] == 'name'){
        $current_username = array_values($attr)[1];
    }
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
    <body>
        <header>
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
            <div class="container-fluid">
                <a href="#" class="navbar-brand">Authenticated User Page</a>
                <button type="button" class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#navbarCollapse1">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarCollapse1">
                    <div class="navbar-nav">
                        <a href="/logout.php" class="nav-item nav-link">Logout</a>
                    </div>
                </div>
            </div>
        </nav>
        </header>
        <main>
  <div class="album py-5 ">
    <div class="container">

      <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3">
        <div class="col">
        <div class="alert alert-success position-relative" role="alert">
            <h4 class="alert-heading">Welcome <strong><?php echo $current_username;?> <br>(Role : <?php echo $current_role ?>)</strong></h4>
            <p>You are succesfully authenticated. Here are some <em>secret</em> information about this user pool.</p>
            <hr>
            <p class="mb-0"><b>Id:</b> <?php echo $pool['Id'];?></p>
            <p class="mb-0"><b>Name:</b> <?php echo $pool['Name'];?></p>
            <p class="mb-0"><b>CreationDate:</b> <br><?php echo $pool['CreationDate'];?></p>
        </div>
        </div>
        <div class="col">
        <?php if($current_role == 'admin'){ ?>
            <h1 class="h2 mb-3 fw-normal">Here is the users list :</h1>
            <ul class='list-group'>
        <?php
            foreach($users as $user_single) {
                $role_attribute_index = array_search('custom:Role', array_column($user_single['Attributes'], 'Name'));
                $role = $user_single['Attributes'][$role_attribute_index]['Value'];
                $email_attribute_index = array_search('email', array_column($user_single['Attributes'], 'Name'));
                $email = $user_single['Attributes'][$email_attribute_index]['Value'];
                echo "<li class='list-group-item'>{$user_single['Username']} ({$role}) ({$email})</li>";
            }
        ?>
        </ul>
         <?php } else { ?>
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
            <strong>Holy guacamole!</strong><br> You are just a normal user.<br> Sorry, you can't see the other users list.
            </div>
         <?php }?>
        </div>
</div>
</div>
        </main>
        
    
    </body>
</html>
