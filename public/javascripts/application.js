var RapidFTR = {};

RapidFTR.maintabControl = function(){
    var currentURL = window.location.href;
    var module = currentURL.split("/");
    var moduleName = module[3];
    switch (moduleName)
    {
        case "children" : $(".main_bar li a:contains('CHILDREN')").addClass("sel");
        break;

        case "formsections" : $(".main_bar li a:contains('FORMS')").addClass("sel");
        break;

        case "users":
        case "roles":   $(".main_bar li a:contains('USERS')").addClass("sel");
        break;

        case "devices":   $(".main_bar li a:contains('DEVICES')").addClass("sel");
        break;
    }


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
  var toggleFormSection = function(action, message) {
    return function() {
            if(!$('#form_sections input:checked').length) {
                alert("Please select form(s) you want to show/hide.");
            } 
                else if(confirm(message)) {
    		    $("#enable_or_disable_form_section").attr("action", "form_section/" + action).submit();
    		return true;
			} else {
				return false;
			}
    };
  }
  
  $("#enable_form").click(toggleFormSection("enable", "Are you sure you want to make these form(s) visible?"));
  $("#disable_form").click(toggleFormSection("disable", "Are you sure you want to hide these form(s)?"));
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

RapidFTR.showDropdown = function(){
    $(".dropdown_btn").click( function(event){
        $(".dropdown").not(this).hide();
        $(".dropdown",this).show();
        event.stopPropagation();
    });
    $(".dropdown").click(function(event){
        event.stopPropagation();
    });
    $('html').click(function(event){
        $(".dropdown").hide();
    });
};

RapidFTR.Utils = {
    dehumanize: function(val){
        return jQuery.trim(val.toString()).replace(/\s/g, "_").replace(/\W/g, "").toLowerCase();
    }
};

RapidFTR.validateSearch = function() {
  var query = $("#query").val();
  if (query == undefined || query == null || query.toString().trim() == "") {
    alert("Please enter a search query");
    return false;
  }

  return true;
}

$(document).ready(function() {
});

$(document).ready(function() {
  RapidFTR.maintabControl();
  RapidFTR.tabControl();
  RapidFTR.enableSubmitLinks();
  RapidFTR.activateToggleFormSectionLinks();
  RapidFTR.hideDirectionalButtons();
  RapidFTR.followTextFieldControl("#field_display_name", "#field_name", RapidFTR.Utils.dehumanize);
  RapidFTR.childPhotoRotation.init();
    $('#dialog').hide();
    if (window.location.href.indexOf('login') === -1) {
    IdleSessionTimeout.start();
  }
    RapidFTR.showDropdown();

});
