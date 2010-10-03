var RapidFTR = {};

// START: Tabs
RapidFTR.tabControl = function() {
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

    $(document.getElementById("enable_form")).click(function()
    {

        var form = document.getElementById("enable_or_disable_form_section");
        form.action = 'form_section/enable';
        form.submit();
        return true;
    });


    $(document.getElementById("disable_form")).click(function()
    {

        var form = document.getElementById("enable_or_disable_form_section");
        form.action = 'form_section/disable';
        form.submit();
        return true;
    });


    //hiding field direction buttons (first up button and second down)
    $("#formFields .up-link:first").hide();
    $("#formFields .down-link:last").hide();
};
RapidFTR.childPhotoRotation = {
    rotateClockwise: function(event) {
        RapidFTR.childPhotoRotation.childPicture().rotateRight(90, 'rel');
        self.photoOrientation.val((parseInt(self.photoOrientation.val()) + 90) % 360);
        event.preventDefault();
    },

    rotateAntiClockwise: function(event) {
        RapidFTR.childPhotoRotation.childPicture().rotateLeft(90, 'rel');
        self.photoOrientation.val((parseInt(self.photoOrientation.val()) - 90) % 360);
        event.preventDefault();
    },

    restoreOrientation: function(event) {
        RapidFTR.childPhotoRotation.childPicture().rotate(0, 'abs');
        self.photoOrientation.val(0);
        event.preventDefault();
    },

    childPicture : function(){
        return $("#child_picture");
    },

    init: function() {
        self.photoOrientation = $("#child_photo_orientation");
        $("#image_rotation_links .rotate_clockwise").click(this.rotateClockwise);
        $("#image_rotation_links .rotate_anti_clockwise").click(this.rotateAntiClockwise);
        $("#image_rotation_links .restore_image").click(this.restoreOrientation);
    }
};

$(document).ready(function() {
    RapidFTR.childPhotoRotation.init();
});
