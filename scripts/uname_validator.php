<?php
    // Check that a username is not already taken
    if(!array_key_exists("uname", $_POST) || !$_POST["uname"]) {
        http_response_code(400);
        echo "Incomplete request.";
        exit(); // no data, not taken
    }

    if(!file_exists("../data/.authfile")) {
        http_response_code(500);
        echo "Cannot validate right now.";
        exit();
    }

    $uname = $_POST["uname"];
    $authfile = fopen("../data/.authfile", "r");

    $line = fgets($authfile);
    while($line != null) {
        $curr = explode(":", $line)[0];
        if($curr == $uname) {
            echo 1; // taken
            exit();
        } 

        $line = fgets($authfile);
    }

    echo 0; // not taken
?>