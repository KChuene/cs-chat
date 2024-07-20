<html>
<head>
    <title> CS Chat | Register </title>
    
    <link href='./css/register.css' rel='stylesheet' />
    
    <script src="./scripts/jquery-3.7.1.min.js"></script>
    <script src="./scripts/validator.js"></script>
</head>

<body>
    <center>
    <?php
        if(!array_key_exists("key", $_GET) || !$_GET["key"]) {
            echo "
                <h1> 404 </h1>
                <h3> Page Not Found </h3>
            ";
            exit();
        }

        if(!file_exists("./data/.registerkeys")) {
            echo "
                <h1> Oops! </h1>
                <h3> Service Temporarily Unavailable</h3>
            ";
            exit();
        }

        $key = $_GET["key"];
        $handle = fopen("./data/.registerkeys", "r");

        $authorized = false;
        $line = trim(fgets($handle));
        while($line) {
            if($key == $line) {
                $authorized = true;
                break;
            }
            $line = trim(fgets($handle));
        }

        if($authorized) {
            include("register.form.html");
        }
        else {
            echo "
                <h1> Forbidden </h1>
                <h3> Provided Key is Not Unauthorized </h3>
            ";
        }
    ?>
    </center>
</body>
</html>