(function ($) {
	
	$.fn.advancedSearch = function (options) {
        var element = $(this);
        var self = this;

        var menu = element.find(".criteria_menu");

        var criteriaList = $(this).find(".criteria-list")
        var criteria = options.criteria

        var formList = element.find(".forms li");
        formList.first().addClass("selected");

        var formFields = element.find(".fields");
        formFields.first().addClass("selected");
        formFields.first().find("li:first").addClass("selected");

        self.selectedField = "";

        var showCriteriaMenu = function () {
            disableSelectedFields();
            var position = $(this).position();
            menu.css("top", position.top + "px");
            menu.css("left", position.left + "px");
            menu.show();

            self.selectedField = $(this).parent();
        };

        var buildCriteria = function (condition) {
            var criteria = $("#criteria_template").tmpl(condition);
            criteria.appendTo(criteriaList);
            element.find(".select-criteria").trigger("click");
        };


        var selectForm = function (formLink) {
            formList.removeClass("selected");
            formLink.addClass("selected");
            formFields.removeClass("selected");

            var selectedFields = element.find("#" + formLink.attr("id") + "_fields");
            selectedFields.addClass("selected");
            selectedField = selectedFields.find("li:nth-child(" + (formList.index(formLink) + 1) + ")");
            selectedField.addClass("selected");
        }

        formList.click(function () {
            selectForm($(this));
        });

        element.find("ul.fields li").click(function () {
            var field = $(this);

            if ($(this).is(".disabled")) {
                return false;
            }

            self.selectedField.find(".select-criteria").text(field.find("a").text());
            self.selectedField.find(".criteria-field").val(field.find(".field").val());
            var field_type = field.find(".field_type").val();
            self.selectedField.find(".criteria-field-type").val(field_type);
            var criteria_values_span = self.selectedField.find(".criteria-values");
            var index = self.selectedField.find(".criteria-index").val()
            if (field_type == "select_box") {
                criteria_values_span.html("<select name='criteria_list[" + index + "][value]' class='criteria-value-select'/>")
                var select_box = $(self.selectedField.find(".criteria-value-select"));
                var select_options = field.find(".option_values").val();
                $.each(select_options.split(","), function (index, value) {
                    select_box.append("<option value=" + value + ">" + value + "</option>");
                });
            } else {
                criteria_values_span.html("<input type='text'  name='criteria_list[" + index + "][value]' class='criteria-value-text'/>")
            }
            self.selectedField.find(".criteria")
            menu.hide();
        });


        element.find(".add-criteria").live("click", function () {
            var last_criteria_index = criteriaList.find("p:last .criteria-index").val();
            var new_index = (last_criteria_index == undefined) ? 0 : (parseInt(last_criteria_index) + 1);
            buildCriteria({index:new_index, join:"AND", field_display_name:""});
        });


        element.find(".remove-criteria").live("click", function () {
            $(this).parents("p").remove();
        });

        var disableSelectedFields = function () {
            var selectedFields = $(".criteria-field").map(function () {
                return $(this).val();
            });
            $(".fields li").removeClass("disabled");
            $(".fields li").filter(function (index) {
                var fieldName = $(this).find(".field").val();
                return ($.inArray(fieldName, selectedFields) != -1);
            }).addClass("disabled");
        };


        element.find(".select-criteria").live("click", showCriteriaMenu);

        menu.find(".close-link").click(function () {
            menu.hide();
            var field = self.selectedField.find(".criteria-field-type").val();

            if (!field)
                self.selectedField.remove();
        });

        var createdByIsEmpty = function () {
            return ($('#created_by_value').val() == '');
        }
        var createdByOrganisationIsEmpty = function () {
            return ($('#created_by_organisation_value').val() == '');
        }

        var updatedByIsEmpty = function () {
            return ($('#updated_by_value').val() == '');
        }

        var dateValueIsValid = function (dateValue) {
            return (dateValue == '' || dateValue.match(/^\d\d\d\d-\d\d-\d\d$/));
        }

        var dateValueIsEmpty = function (){
            return (dateValue == '');
        }

        var createdAtIsEmpty = function () {
            return ($('#created_at_after_value').val() == '') && ($('#created_at_before_value').val() == '');
        }

        var updatedAtIsEmpty = function () {
            return ($('#updated_at_after_value').val() == '') && ($('#updated_at_before_value').val() == '');
        }

        var createdAtIsValid = function () {
            return dateValueIsValid($('#created_at_after_value').val()) && dateValueIsValid($('#created_at_before_value').val())
        }

        var updatedAtIsValid = function () {
            return dateValueIsValid($('#updated_at_after_value').val()) && dateValueIsValid($('#updated_at_before_value').val())
        }

	var validate = function(){
		var result = "";

		if (!createdAtIsValid()) {
			result=I18n.t("messages.enter_valid_date")
		}
	
		if (!updatedAtIsValid()) {
            result=I18n.t("messages.enter_valid_date")
        }

		$('.criteria-list .criteria-value-text').each(function(){
			if($(this).val() == "") { result = I18n.t("messages.enter_valid_field_value"); }
		});
		$('.criteria-list .criteria-value-select').each(function(){
			if($(this).val() == "") { result = I18n.t("messages.enter_valid_field_value"); }
		});

		if ((result == "") && ($('.criteria-list .criteria-value-text').length == 0) && ($('.criteria-list .criteria-value-select').length == 0)) {
			if (createdByIsEmpty() && createdByOrganisationIsEmpty() && updatedByIsEmpty() && createdAtIsEmpty() && updatedAtIsEmpty()) {
				result = I18n.t("messages.valid_search_criteria");
			}
		}
		return result;
	}

		element.find("form").submit(function() {
			result = validate();

			if(result == ''){
				$('.flash .error').hide();
				return true;
			} else {
				$('.flash .error').show();
				$('.flash .error').text(result);
				return false;
			}
		});
	},
	$('.datepicker').each(function(){$(this).datepicker()})
})(jQuery);

$(function(){
	$('.datepicker').each(function(){$(this).datepicker({ dateFormat: I18n.t("date_format") })})
})