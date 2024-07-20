document.writeln("<h1> Spaces not allowed </h1>");
$(document).ready(
    function() {
        $("txt_error").hide();

        $("txt_uname").onchange(
            function() {
                var uname = $("txt_uname").val.trim();
                if(uname == '') {
                    console.log("Spaces not allowed");
                    $("txt_error").text = "Spaces are ignored.";
                    $("txt_error").show();
                    // $("txt_uname").clear();
                    return;
                }

                check(uname);
            }
        );
    }
);

function check(uname) {
    console.log("Just checking");
    $.ajax({
        url: "validator.php",
        type: "post",
        data: {uname: uname},
        success: function(response) {
            if(response != 0) {
                $("txt_error").text = "Username unavailable.";
                $("txt_error").show();
            } else {
                clear_err();
            }
        }
    }

    );
}

function clear_err() {
    $("txt_error").text = "";
    $("txt_error").hide();
}