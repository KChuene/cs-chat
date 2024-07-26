$(document).ready(
    function() {
        clear_err();
        $("form").submit(
            function(event) {
                event.preventDefault();

                const formData = new FormData(event.target);
                const uname = formData.get('username').trim();
                const pword = formData.get('password').trim();

                if(uname == "" || pword == "") {
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