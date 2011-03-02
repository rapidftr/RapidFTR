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
				
		self.selected_field = "";
		
		var buildCriteria = function(condition) {
			var criteria = $("#criteria_template").tmpl(condition);
			criteria.appendTo( criteriaList );			
			
		};
		
		$.each(criteria, function(index, element){
			buildCriteria(element);
		});
		
		var selectForm = function(formLink){
				formList.removeClass("selected");
				formId = formLink.attr("id");
				formLink.addClass("selected");
				formFields.removeClass("selected");

				var selected_fields = element.find("#" + formId + "_fields");
				selected_fields.addClass("selected");
				selected_field = selected_fields.find("li:nth-child(" + (formList.index(formLink) + 1) + ")");
				selected_field.addClass("selected");
		}
		
		formList.click(function(){ selectForm($(this)); });
			
		element.find("ul.fields li").click(function(){
			var field = $(this);
			self.selected_field.find(".select-criteria").text(field.find("a").text());
			self.selected_field.find(".criteria-field").val(field.find("input[type='hidden']").val())
			menu.hide();
		});
		
		
		element.find(".add-criteria").live("click", function() { 
			var index = criteriaList.find("p:last .criteria-index").val() + 1;
			buildCriteria({index: index, join: "AND", field_display_name: ""}) 
		});
		
		element.find(".remove-criteria").live("click", function(){
			$(this).parents("p").remove();
		});
		
		var selectCriteria = function(){
			var position = $(this).position()
			menu.css("top", position.top + "px");
			menu.css("left", position.left + "px");
			menu.show();
			self.selected_field = $(this).parent();
		}
		
		element.find(".select-criteria").live("click", selectCriteria);
		
		menu.find(".close-link").click(function(){
			menu.hide();
		});
		
		var validate = function(){
			var result = "";
			$('.criteria-list .criteria-field').each(function(){
				if($(this).val() == "") { result = 'Please select a valid field name.'; }
			});
			
			$('.criteria-list .criteria-value').each(function(){
				if($(this).val() == "") { result = 'Please enter a valid field value.'; }
			});
			return result;
		}
		
		element.find("form").submit(function() { 
			result = validate();
			$('.form-error').text(result);
			if(result == ''){ return true;}
			return false;
		});
		
		
		
	}
})(jQuery);