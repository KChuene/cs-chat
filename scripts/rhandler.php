
<?php
    $uname = safe_read( $_POST, "username" );
    $pword = safe_read( $_POST, "password" );
    $authfile_path = "../data/.authfile";

    if(!file_exists($authfile_path)) {
        if(!file_exists("../data")) {
            mkdir("../data");
        }
    }

    if(empty($uname) || empty($pword)) {
        bye(-1, "Username and password required.");
    }

    $name_taken = is_unavailable($uname);
    if(!$name_taken) {
        $pword = hash("sha256", $pword);

        try {
            $authfile = fopen($authfile_path, "a");
            fwrite($authfile, $uname.":".$pword."\n");
            fclose($authfile);

            bye(0, "Registered.");
        }
        catch(_) {
            bye("Cannot register right now.");
        }
    }
    else {
        bye(-1, "Username is unavailable.");
    }

    function safe_read(array $data, string $key) {
        $fail = "";
        if(!array_key_exists($key, $data) || !$data[$key]) {
            return $fail;
        }

        return $data[ $key ];
    }


    function is_unavailable(string $uname) {
        global $authfile_path;
        if(!file_exists($authfile_path)) {
            return false;
        }

        $authfile = fopen($authfile_path, "r");
        $line = fgets($authfile);
        while($line != null) {
            $curr = explode(":", $line)[0];
            if($curr == $uname) {
                return true; // taken
            } 
    
            $line = fgets($authfile);
        }
        return false; // not taken
    }

    function bye(int $code, string $res) {
        $status = set_status($code, $res);
        echo json_encode($status);
        exit();
    }

    function set_status(int $code, string $message) {
        return array([
            "code" => $code,
            "mesg" => $message
        ]);
    }
?>