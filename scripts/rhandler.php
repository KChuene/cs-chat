
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
        if(!is_secure_pass($pword)) {
            bye(-1, "Password does not meet requirements.");
        }

        $pword = hash("sha256", $pword);

        try {
            $authfile = fopen($authfile_path, "a");
            fwrite($authfile, $uname.":".$pword."\n");
            fclose($authfile);

            bye(0, "Registered.");
        }
        catch(_) {
            bye(-1, "Cannot register right now.");
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

    function is_secure_pass(string $pword) {
        /*
            POLICY
            * Minimum length of 12
            * At least 2 special character
            * At least 2 numbers
            * At least 4 alphabets
        */

        
        if($pword.count() >= 12) {
            $s_chars = [
                "`","~","!","@","#","$","%","^",
                "&","*","(",")","-","_","+","=",
                "{","}","[","]",":",";","'","\"",
                "<",">",",",".","?","/","|","\\"
            ];

            $sc_count = $n_count = $alpha_count = 0;
            foreach($pword as $pwd_chr) {
                if(in_array($pwd_chr, $s_chars)) {
                    $sc_count++;
                }
                elseif(is_numeric($pwd_chr)) {
                    $n_count++;
                }
                elseif(ctype_alpha($pwd_chr)) {
                    $alpha_count++;
                }
            }

            return $sc_count >= 2 && $n_count >= 2 && $alpha_count >= 4;
        }

        return false;
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