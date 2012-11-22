$(document).ready(function () {
    $(".device_blacklist_check_box").click(function (event) {
        setModalText();
        var _this = this;
        $("#modal-dialog").dialog({
            modal:true,
            width:400,
            title:'Blacklist Device',
            height:200,
            buttons:{
                'Yes':function () {
                    $(this).dialog('close');
                    updateBlackListFlag(_this);
                },
                'Cancel':function () {
                    $(this).dialog('close');
                }
            }
        });
        $('#modal-dialog').dialog("open");
        event.preventDefault();
    })
});

function updateBlackListFlag(check_box) {
    var $checkbox = $(".device_blacklist_check_box");
    $.ajax({
        url:"/devices/update_blacklist",
        type:"POST",
        dataType:'json',
        data:{blacklisted:!($(check_box).is(':checked')), imei:$(check_box).attr('id')},
        success:function (json) {
            if (json.status == 'ok') {
                location.reload();
            }
        }
    })
}

function setModalText() {
    var next_state__as_checked = $(".device_blacklist_check_box").is(':checked');
    if (next_state__as_checked) {
        $("#modal-dialog").text("Do you want to add this device to blacklist?");
    } else {
        $("#modal-dialog").text("Do you want to remove this device from blacklist?");
    }
}
