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

        case "enquiries": $(".main_bar li a:contains('ENQUIRIES')").addClass("sel");
        break;

        case "forms": $(".main_bar li a:contains('FORMS')").addClass("sel");
        break;

        case "reports": $(".main_bar li a:contains('REPORTS')").addClass("sel");
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
                alert(I18n.t("messages.show_hide_forms"));
            } 
                else if(confirm(message)) {
    		    $("#enable_or_disable_form_section").attr("action", "form_section/" + action).submit();
    		return true;
			} else {
				return false;
			}
    };
  }
  
  $("#enable_form").click(toggleFormSection("enable", I18n.t("messages.show_forms")));
  $("#disable_form").click(toggleFormSection("disable", I18n.t("messages.hide_forms")));
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
        var WAITING_TIME = 250;
        self.photoOrientation = $("#child_photo_orientation");
        $("#image_rotation_links .rotate_clockwise").click(this.rotateClockwise);
        $("#image_rotation_links .rotate_anti_clockwise").click(this.rotateAntiClockwise);

        var restore_image_button = $("#image_rotation_links .restore_image")
        restore_image_button.click(this.restoreOrientation);
        if ($.browser.webkit){
            restore_image_button.click();
            setTimeout(function(){
                restore_image_button.click()
            }, WAITING_TIME);
        }
    }
};

RapidFTR.showDropdown = function(){

    $(".dropdown_form").click(function(event) {
        var dropdownDOM = $(".dropdown",this);
        RapidFTR.Utils.toggle(dropdownDOM);
    });

    $(".dropdown_btn").click( function(event){
        $(".dropdown").not(this).hide();
        $(".dropdown",this).show();
        event.stopPropagation();
    });

    $(".dropdown").click(function(event){
        event.stopPropagation();
    });

    $('html').click(function(event){

        $(".dropdown").children().each(function() {
            if ($(this).is('form')) {
                $(this).remove();
            }
        });
        $(".dropdown").hide();
    });
};

RapidFTR.Utils = {
    dehumanize: function(val){
        return jQuery.trim(val.toString()).replace(/\s/g, "_").replace(/\W/g, "").toLowerCase();
    },

    enableFormErrorChecking: function() {
        $('.dropdown').delegate(".mark-as-submit", 'click', function(){
            if(!$(this).siblings('input[type=text]').val()){
                alert($(this).attr('data-error-message'));
                return false;
            }
        });
    },

    toggle: function(selector) {
        selector.toggleClass('hide').show();
        if (selector.children().size() == 0) {
            selector.append(RapidFTR.Utils.generateForm(selector));
        }
    },

    generateForm: function(selector) {
        var form_action = selector.data('form_action');
        var form_id = selector.data('form_id');
        var authenticity_token =  selector.data('authenticity_token');
        var message_id = selector.data('message_id');
        var message = selector.data('message');
        var property = selector.data('property');
        var property_value = selector.data('property_value');
        var redirect_url = selector.data('request_url');
        var submit_label = selector.data('submit_label');
        var submit_error_message = selector.data('submit_error_message');

        return "<form accept-charset=\"UTF-8\" action=\""+ form_action +"\" class=\"edit_child\" " +
            "id=\""+ form_id +"\" method=\"post\">" +
            "<div style=\"margin:0;padding:0;display:inline\">" +
            "<input name=\"utf8\" type=\"hidden\" value=\"✓\">" +
            "<input name=\"_method\" type=\"hidden\" value=\"put\">" +
            "<input name=\"authenticity_token\" type=\"hidden\" value=\""+ authenticity_token +"\"></div>" +

            "<div class=\"mark-as-form\">" +
            "<h3><label for=\"child_"+ message_id +"\">"+ message +"</label></h3>" +
            "<input id=\"child_"+ message_id +"\" name=\"child["+ message_id +"]\" size=\"30\" type=\"text\" value=\"\">" +
            "<input id=\"child_"+ property +"\" name=\"child["+ property +"]\" type=\"hidden\" value=\""+ property_value +"\">" +
            "<input id=\"child_redirect_url\" name=\"redirect_url\" type=\"hidden\" value=\""+ redirect_url +"\">" +
            "<input class=\"mark-as-submit\" data-error-message=\""+ submit_error_message +"\" id=\"child_submit\"" +
            " name=\"commit\" type=\"submit\" value=\""+ submit_label +"\">" +
            "</div></form>"
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

RapidFTR.PasswordPrompt = (function() {
    var passwordDialog = null, targetEl = null, passwordEl = null;

    return {
        initialize: function() {
            passwordDialog = $("#password-prompt-dialog").dialog({
                autoOpen: false,
                modal: true,
                buttons: {
                    "OK" : function() {
                        var password = passwordEl.val();
                        var errorDiv = $("div#password-prompt-dialog .flash");
                        if (password == null || password == undefined || password.trim() == "") {
                            errorDiv.children(".error").text(I18n.t("encrypt.password_mandatory")).css('color', 'red');
                            errorDiv.show();
                            return false;
                        } else {
                            errorDiv.hide();
                            RapidFTR.PasswordPrompt.updateTarget();
                        }
                    }
                },
               close: function(){
                   $("div#password-prompt-dialog .flash .error").text("");
               }

            });
            passwordEl = $("#password-prompt-field");
            $(".password-prompt").each(RapidFTR.PasswordPrompt.initializeTarget);
        },

        initializeTarget: function() {
            var self = $(this), targetType = self.prop("tagName").toLowerCase();
            $("div#password-prompt-dialog .flash .error").text("");

            if (targetType == "a") {
                self.data("original-href", self.attr("href"));
            }

            self.click(function(e) {
                if (e["isTrigger"] && e["isTrigger"] == true) {
                    return true;
                } else {
                    targetEl = $(this);
                    passwordEl.val("");
                    passwordDialog.dialog("open");
                    return false;
                }
            });
        },

        updateTarget: function() {
            var password = passwordEl.val();
            var targetType = targetEl.prop("tagName").toLowerCase();

            passwordEl.val("");
            passwordDialog.dialog("close");

            if (targetType == "a") {
                var href = targetEl.data("original-href");
                href += (href.indexOf("?") == -1 ? "?" : "") + "&password=" + password;
                window.location = href;
            } else if (targetType == "input") {
                targetEl.closest("form").find("#hidden-password-field").val(password);
                targetEl.trigger("click");
            }
        }
    }
}) ();

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

  RapidFTR.PasswordPrompt.initialize();

    RapidFTR.Utils.enableFormErrorChecking();
    RapidFTR.showDropdown();

});
