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
        elseif(not_unique_uname($uname)) {
            echo "<h1> Username is unavailable.</h1>";
            return;
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


        function not_unique_uname(string $uname) {
            $authfile = fopen("./data/.authfile", "r");

            $line = fgets($authfile);
            while($line != null) {
                $curr = explode(":", $line)[0];
                if($curr == $uname) {
                    return true;
                } 

                $line = fgets($authfile);
            }
            return false;
        }
    ?>
    </center>

    </body>
</html>