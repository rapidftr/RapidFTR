var IdleSessionTimeout = {};

IdleSessionTimeout.start = function() {
    $("#dialog").dialog({
        autoOpen: false,
        modal: true,
        width: 400,
        height: 200,
        closeOnEscape: false,
        draggable: false,
        resizable: false,
        buttons: {
            'Yes, Keep Working': function() {
                $(this).dialog('close');
            },
            'No, Logoff': function() {
                $.idleTimeout.options.onTimeout.call(this);
            }
        }
    });

    $.idleTimeout('#dialog', 'div.ui-dialog-buttonpane button:first', {
        idleAfter: 900,
        pollingInterval: 180,
        warningLength: 300,
        keepAliveURL: '/active',
        serverResponseEquals: 'OK',
        onTimeout: function() {
            window.location = "/logout";
        },
        onIdle: function() {
            $(this).dialog("open");
        },
        onCountdown: function(counter) {
            $("#dialog-countdown").html(counter);
        },
        onResume: function() {
	    $.ajax({
		url: '/active',
		error: function(){
		},
		success: function(response){

		}
	    });
        }
    });
};


