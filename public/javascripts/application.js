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

RapidFTR.activateFormValidation = function(){
    $("form.validate").validate({
      showErrors: function(errorMap, errorList) {
        if (errorList.length === 0) {
          $("#errorExplanation").hide();
        } else {
          $("#errorExplanation").show();
          var message = "1 error prohibited this child from being saved";
          if (errorList.length > 1) {
            message = errorList.length + " errors prohibited this child from being saved";
          }
        
          $("#errorList").html('');
          $("#errorExplanation .title").text(message);
          $.each(errorList, function(){
            $("#errorList").append("<li>" + this.message + "</li>");
          });
        }
    	}
  	});
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
  RapidFTR.activateFormValidation();
  RapidFTR.hideDirectionalButtons();
  RapidFTR.backButton();
  RapidFTR.followTextFieldControl("#field_display_name", "#field_name", RapidFTR.Utils.dehumanize);
  RapidFTR.childPhotoRotation.init();
});

// Allows you to specify a validated input's message as an html attribute
// <input class='number' message='Must be a number!!!1 1' />
$.validator.prototype.formatAndAdd = function( element, rule ) {
 var message = this.defaultMessage( element, rule.method ),
   theregex = /\$?\{(\d+)\}/g;
 if ( typeof message == "function" ) {
   message = message.call(this, rule.parameters, element);
 } else if (theregex.test(message)) {
   message = jQuery.format(message.replace(theregex, '{$1}'), rule.parameters);
 }     
 
 var custom_message;
 if (custom_message = $(element).attr('message')){
   message = custom_message;
 }
 
 this.errorList.push({
   message: message,
   element: element
 });
 
 this.errorMap[element.name] = message;
 this.submitted[element.name] = message;
}