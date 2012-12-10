$(function() {
    $(".action_panel li span.flag a").click( function(event){
        var dropdownDOM = $(this).parent().siblings('.dropdown');
        RapidFTR.Utils.toggle(dropdownDOM);
        event.stopPropagation();
    });
});