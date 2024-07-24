<html>
    <head>
        <link rel="stylesheet" src="./css/rhandler.css" />

        <title> Register </title>
    </head>

    <body>
    
    <center>
    <?php
        $uname = trim($_POST["username"]);
        $pword = trim($_POST["password"]);

        if(empty($uname) || empty($pword)) {
            header("Location: ".$_SERVER["HTTP_REFERER"]);
        }
        else if(!file_exists("./data")) {
            mkdir("./data");
        }
        $pword = hash("sha256", $pword);

        $authfile = fopen("./data/.authfile", "a");
        fwrite($authfile, $uname.":".$pword."\n");
        fclose($authfile);

        echo "
            <h1> 
                    You have successfully <br/> registered!
            </h1>
        ";
    ?>
    </center>

    </body>
</html>