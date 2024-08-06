$(document).ready(
    function() {
        clear_err();
        $("form").submit(
            function(event) {
                event.preventDefault();

                const formData = new FormData(event.target);
                const uname = formData.get('username').trim();
                const pword = formData.get('password').trim();

                var pwordPolicyMet = policy_check()
                if(uname == "" || pword == "" || !pwordPolicyMet) {
                    return;
                }

                $.ajax({
                    url: "/scripts/rhandler.php",
                    method: 'post',
                    data: { username: uname, password: pword }
                })
                .done(re => {
                    const data = json_parse(re);

                    if(data != null && data.length > 0) {
                        if(data[0].code != 0) {
                            display_err(data[0].mesg);
                        } 
                        else {
                            location.replace("/welcome.html");
                        }
                    }
                })
                .fail(_ => {
                    display_err("Could not reach server.");
                });
            }
        );
    }
);

function whitespace_check() {
    var uname = $("#txt_uname").val();

    if(uname.length > 0 && uname.trim() == '') {
        display_err("Spaces are ignored.");

        $("#txt_uname").value = "";
        return;
    }
    else {
        clear_err()
    }
}

function policy_check() {
    var pword = $("#txt_pword").val();

    const s_chars = [
        "`","~","!","@","#","$","%","^",
        "&","*","(",")","-","_","+","=",
        "{","}","[","]",":",";","'","\"",
        "<",">",",",".","?","/","|","\\"
    ];

    sc_count = n_count = alpha_count = 0;
    s_chars.forEach(function(pwd_char) {
        if(s_chars.includes(pwd_char)) {
            sc_count++;
        }
        else if(!isNaN(pwd_char)) {
            n_count++;
        }
        else if(/^[a-zA-Z]$/.test(pwd_char)) {
            alpha_count++;
        }
    });  
    
    /*
    POLICY
    * Minimum length of 12
    * At least 2 special character
    * At least 2 numbers
    * At least 4 alphabets
    */
    set_policy(pword.length >= 12, sc_count >= 2, n_count >= 2, alpha_count >= 4);
    return pword.length >= 12 && sc_count >= 2 && n_count >= 2 && alpha_count >= 4;
}

function set_policy(length, sc_count, n_count, alpha_count) {
    const failIcon = "/images/icons/cross.png";
    const succIcon = "/images/icons/check.png"; 

    $("plc_length_ico").src = (length)? succIcon: failIcon;
    $("plc_schars_ico").src = (sc_count)? succIcon: failIcon;
    $("plc_number_ico").src = (n_count)? succIcon: failIcon;
    $("plc_alphas_ico").src = (alpha_count)? succIcon: failIcon;
}


function display_err(err) {
    $("#txt_error").text(err);
    $("#txt_error").show();  
}

function clear_err() {
    $("#txt_error").text("");
    $("#txt_error").hide();
}

function json_parse(data) {
    try {
        return JSON.parse(data);
    }
    catch(e) {
        return null;
    }
}