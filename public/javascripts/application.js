var RapidFTR = {};

RapidFTR.backButton = function(selector){
	$(".back a").click(function(e){
		e.preventDefault();
		history.go(-1);	
	});
}
RapidFTR.tabControl = function() {
  $(".tab").hide();
  $(".tab-handles li:first").addClass("current").show();
  $(".tab:first").show();

  $(".tab-handles a").click(function() {

    $(".tab-handles li").removeClass("current");
    $(".tab").hide();

    var activeTab = $(this).attr("href");

    $(this).parent().addClass("current");
    $(activeTab).show();

    return false;
  });
}

RapidFTR.enableSubmitLinks = function() {
  $(".submit-form").click(function() {
    var formToSubmit = $(this).attr("href");
    $(formToSubmit).submit();
    return false;
  });
}

RapidFTR.activateToggleFormSectionLinks = function() {
  var toggleFormSection = function(action) {
    return function() {
			if (confirm("Are you sure you want to " + action + "?")) {
    		$("#enable_or_disable_form_section").attr("action", "form_section/" + action).submit();
    		return true;
			} else {
				return false;
			}
    };
  }
  
  $("#enable_form").click(toggleFormSection("enable"));
  $("#disable_form").click(toggleFormSection("disable"));
}

RapidFTR.hideDirectionalButtons = function() {
  $("#formFields .up-link:first").hide();
  $("#formFields .down-link:last").hide();
}

RapidFTR.followTextFieldControl = function(selector, followSelector, transformFunction) {
  $(selector).keyup(function() {
    var val = $(this).val();
    var transformed = transformFunction(val);
    $(followSelector).val(transformed);
  });
}

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
});

$(document).ready(function() {
  RapidFTR.tabControl();
  RapidFTR.enableSubmitLinks();
  RapidFTR.activateToggleFormSectionLinks();
  RapidFTR.hideDirectionalButtons();
  RapidFTR.backButton();
  RapidFTR.followTextFieldControl("#field_display_name", "#field_name", RapidFTR.Utils.dehumanize);
  RapidFTR.childPhotoRotation.init();
});
