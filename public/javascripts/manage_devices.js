$(document).ready(function () {
    $(".device_blacklist_check_box").change(updateBlackListFlag)
});

function updateBlackListFlag() {
    $.ajax({
        url:"/devices/update_blacklist",
        type:"POST",
        data:{blacklisted:$(this).is(':checked'), id:$(this).attr('id')},
        success:function () {
            alert("Successfully Updated");
        }
    })
}
