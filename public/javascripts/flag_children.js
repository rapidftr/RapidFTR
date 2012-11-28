$(function() {
    $(".mark-as-form").hide();

    $(".mark-as-submit").click(function(){
        if(!$(this).siblings('input[type=text]').val()){
            alert($(this).attr('data-error-message'));
            return false;
        }
    });


    $(".child_list .child_summary_panel .action_panel li.flag a").click( function(){
        $(this).parent().siblings('form').children('.mark-as-form').toggle();
    });
});