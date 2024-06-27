<?php
$uname = trim($_POST["username"]);
$pword = trim($_POST["password"]);

if(empty($uname) || empty($pword)) {
    header("Location: register.php");
}
else if(!file_exists("./data")) {
    mkdir("./data");
}
$pword = hash("sha256", $pword);

$authfile = fopen("./data/.authfile", "a");
fwrite($authfile, $uname.":".$pword."\n");
fclose($authfile);

echo "
    <center>
        <h1 style='font-size: 50px; color: rgb(26, 128, 26);'> 
            You have successfully <br/> registered!
        </h1>
    </center>
";

?>