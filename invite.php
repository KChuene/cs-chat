<?php
$valid_options = ["-len", "-email"];

if(!($argc > 0) || in_array("--help", $argv)) { 
    usage(); 
    return;
}

$len   = safe_read($argv, "-len", true);
$email = safe_read($argv, "-email", false);

$register_keys = read_keys();
$key = generate_invite_key($len);

$tries_left = 3;
while(in_array($key, $register_keys) && $tries_left > 0) {
    $key = generate_invite_key();
    $tries_left--;
}

if(in_array($key, $register_keys)) {
    exit("[!] Took to long to generate unique key. Try again.");
} 

save_key($key);
echo "[i] Invite key is ".$key.".\n";
echo "[i] Invite link: http://localhost:8080/register?key=".$key."\n"; 
echo "[+] Done.";

function safe_read(array $args, string $option, bool $required) {
    global $valid_options;

    if(!in_array($option, $args)) {
        if($required) {
            exit("[!] ".$option." option is required.");
        } else {
            return "";
        }
    }

    $opt_index = array_search($option, $args);
    $opt_value = (($opt_index + 1) >= count($args))? null: $args[$opt_index + 1];

    if(in_array($opt_value, $valid_options)) {
        exit("[!] Expected value for option ".$option.", but option found.");
    }
    else if(!$opt_value) {
        exit("[!] Value required for option ".$option.".");
    }

    return $opt_value;
}

function usage() {
    echo "
        usage: program.php -len <number> [-email <example@domain.com>]\n\n
        -len\t Length of the invite key.
        -email\tInvitee email to send invitation to.
    ";
}

function generate_invite_key(int $length) {
    global $register_keys;
    $length = ($length > 20)? 20: (($length < 10)? 10: $length); # 10 <= length <= 20

    $chars = [];
    echo "[i] Generating invite key of length ".$length.".\n";
    for($count= 1; $count<= $length ; $count++) { 
        $heads = rand(0, 1);
        
        if($heads) {
            array_push($chars, chr( rand(48, 57) )); # Lower alphabet
        }
        else {
            array_push($chars, chr( rand(97, 122) )); # Upper alphabet
        }
    }

    return implode("", $chars);
}

function save_key(string $key) {
    if(!file_exists("./data")) {
        mkdir("./data");
    }

    $keys_file = fopen("./data/.registerkeys", "a");
    fwrite($keys_file, $key."\n");
    fclose($keys_file); 
}

function read_keys() {
    if(!file_exists("./data/.registerfile")) {
        return [];
    }

    $handle = fopen("./data/.registerkeys", "r");

    $keys = [];
    $line = fgets($handle);
    while($line) {
        array_push($keys, $line);
        $line = fgets($handle);
    }

    return $keys;
}
?>