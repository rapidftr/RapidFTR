$(function() {

    $(".mark-as-submit").click(function(){
        if(!$(this).siblings('input[type=text]').val()){
            alert($(this).attr('data-error-message'));
            return false;
        }
    });

    $(".child_list .child_summary_panel .action_panel li span.flag a").click( function(event){
        var e = $(this).parent().siblings('.dropdown');
        e.toggleClass("hide").show();
        event.stopPropagation();
    });
});