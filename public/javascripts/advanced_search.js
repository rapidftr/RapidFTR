(function($){
	$.fn.advancedSearch = function(options){
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

		var buildCriteria = function(condition) {
			var criteria = $("#criteria_template").tmpl(condition);
			criteria.appendTo( criteriaList );
		};

		$.each(criteria, function(index, element){
			buildCriteria(element);
		});

		var selectForm = function(formLink){
			formList.removeClass("selected");
			formLink.addClass("selected");
			formFields.removeClass("selected");

			var selectedFields = element.find("#" + formLink.attr("id") + "_fields");
			selectedFields.addClass("selected");
			selectedField = selectedFields.find("li:nth-child(" + (formList.index(formLink) + 1) + ")");
			selectedField.addClass("selected");
		}

		formList.click(function(){ selectForm($(this)); });

		element.find("ul.fields li").click(function(){
			var field = $(this);

			if ($(this).is(".disabled")) {
				return false;
			}

			self.selectedField.find(".select-criteria").text(field.find("a").text());
			self.selectedField.find(".criteria-field").val(field.find("input[type='hidden']").val());
			menu.hide();
		});

        	
		element.find(".add-criteria").live("click", function() {
            var last_criteria_index = criteriaList.find("p:last .criteria-index").val();
            var new_index = (last_criteria_index == undefined) ? 0 : (parseInt(last_criteria_index)+1);
			buildCriteria({index: new_index, join: "AND", field_display_name: ""});
		});
        

		element.find(".remove-criteria").live("click", function(){
			$(this).parents("p").remove();
		});

		var disableSelectedFields = function() {
			var selectedFields = $(".criteria-field").map(function(){
				return $(this).val();
			});
			$(".fields li").removeClass("disabled");
			$(".fields li").filter(function(index) {
				var fieldName = $(this).find(".field").val();
				return ($.inArray(fieldName, selectedFields) != -1);
			}).addClass("disabled");
		};

		var showCriteriaMenu = function()	{
			disableSelectedFields();
			var position = $(this).position();
			menu.css("top", position.top + "px");
			menu.css("left", position.left + "px");
			menu.show();

			self.selectedField = $(this).parent();
		};

		element.find(".select-criteria").live("click", showCriteriaMenu);

		menu.find(".close-link").click(function(){
			menu.hide();
		});

        var enableInputByCheckbox = function(checkbox, inputElement) {
            if (checkbox.is(':checked')) {
                inputElement.removeAttr('disabled');
            } else {
                inputElement.attr('disabled', true);
            }
        }

        $('#created_by').bind('click', function() {
            enableInputByCheckbox($(this), $('#created_by_value'));
        });
        $('#updated_by').bind('click', function() {
            enableInputByCheckbox($(this), $('#updated_by_value'));
        });

        var filterSelected = function() {
            return $('#created_by').is(':checked') || $('#updated_by').is(':checked')
        }

        var createdByIsValid = function() {
            return (!$('#created_by').is(':checked')) || ($('#created_by_value').val() != '');
        }

        var updatedByIsValid = function() {
            return (!$('#updated_by').is(':checked')) || ($('#updated_by_value').val() != '');
        }

		var validate = function(){
			var result = "";
            if(!filterSelected()) {
                $('.criteria-list .criteria-value').each(function(){
                    if($(this).val() == "") { result = 'Please enter a valid field value.'; }
                });
                $('.criteria-list .criteria-field').each(function(){
                    if($(this).val() == "") { result = 'Please select a valid field name.'; }
                });
            }
            if (!createdByIsValid()) {
                result="Please enter a valid 'Created by' value."
            }
            if (!updatedByIsValid()) {
                result="Please enter a valid 'Updated by' value."
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
	}
})(jQuery);