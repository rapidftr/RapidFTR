var IdleSessionTimeout = {};

IdleSessionTimeout.start = function() {
    var keep_working = I18n.t("messages.keep_working")
    var logoff = I18n.t("messages.logoff")
    $("#dialog").dialog({
        autoOpen: false,
        modal: true,
        width: 400,
        height: 200,
        closeOnEscape: false,
        draggable: false,
        resizable: false,
        buttons: {
            keep_working: function() {
                $(this).dialog('close');
            },
            logoff: function() {
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
            // the dialog is closed by a button in the dialog
            // no need to do anything else
        }
    });
};


