var RapidFTR = {};

// START: Tabs
RapidFTR.tabControl = function(){
	$(".tab").hide(); //Hide all content
	$(".tab-handles li:first").addClass("current").show(); //Activate first tab
	$(".tab:first").show(); //Show first tab content

	//On Click Event
	$(".tab-handles a").click(function() {

		$(".tab-handles li").removeClass("current"); //Remove any "active" class
		$(".tab").hide(); //Hide all tab content

		var activeTab = $(this).attr("href"); //Find the href attribute value to identify the active tab + content

		$(this).parent().addClass("current"); //Add "active" class to selected tab
		$(activeTab).show(); //Fade in the active ID content
		return false;
	});

    // submitting forms with links
    $(".submit-form").click(function()
    {
        var formToSubmit = $(this).attr("href");
        $(formToSubmit).submit();
        return false;
    });


    //hiding field direction buttons (first up button and second down)
    $("#formFields .up-link:first").hide();
    $("#formFields .down-link:last").hide();
};
