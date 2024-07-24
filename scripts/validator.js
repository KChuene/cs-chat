$(document).ready(
    function() {
        clear_err();
        $("form").submit(
            function(event) {
                event.preventDefault();

                available_check();

                const formData = new FormData(event.target);
                const username = formData.get('username');
                const password = formData.get('password');

                fetch('/rhandler.php', {
                    method: 'POST',
                    body: JSON.stringify({ username, password }),
                    headers: {
                        'Content-Type': 'application/json'
                    }
                })
                .catch(error => {
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

function available_check() {
    var uname = $("#txt_uname").val().trim();

    $.ajax({
        url: "/scripts/uname_validator.php",
        type: "post",
        data: {uname: uname}
    })
    .done(
        function(response) {
            if(response != "") {
                if(response != 0) {
                    display_err("Username unavailable.");
                }
                else {
                    clear_err();
                    $("form").submit();
                }
            } 
        }
    )
    .fail(
        function(response) {
            display_err(response.responseText);
        }
    );
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