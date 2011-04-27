(function($){

  var self = this;
  self.selectedFields = [];

  var methods = {
    init : function( options ) {
      var element = $(this);
      self.element = element;
      self.options = options;
      
      element.find(".form").live("click", function() { 
          methods.select_form.apply(element, $(this))
      });
      
      element.find(".field:not(.prev-selected)").live("click", function(){
        methods.select.apply(element, $(this)) 
      });

      element.find(".close-link").live("click", function() { methods.hide.apply(element) } );
    },

    select: function(selectElement){
      methods.hide.apply(self.element);
      var selectedField = { field_name: $(selectElement).find(".field-name").val(), 
                            display_name: $(selectElement).find(".display-name").val(), 
                            form_name: $(self.selectedForm).find(".form-name").val(),
                            order: self.selectedFields.length + 1  };
      self.selectedFields.push(selectedField);
      self.options.itemSelected(actionElement, selectedField);
    },

    show : function(args) {
      var menu = $(this);
      methods.reset.apply(menu);
      if(args.actionElement && args.actionElement.position().top && args.actionElement.position().left && args.actionElement.width()){
        self.actionElement = args.actionElement;
        menu.css("top", self.actionElement.position().top + "px");
        menu.css("left", self.actionElement.position().left + self.actionElement.width() +  "px");
      }
      menu.show();
    },

    hide : function( ) { $(this).hide(); },

    reset : function( ) {
      
      var firstForm = $(self.element).find(".form").first();
      methods.select_form.apply($(self.element), firstForm);
      $.each(self.selectedFields, function(index, element){
       $(self.element).find('#field-'+element.field_name).addClass("prev-selected");
      });
    },
    
    select_form : function(form){
        if(self.selectedForm){
          self.selectedForm.removeClass("selected");
          $(this).find("#fields-for-"+self.selectedForm.attr("id")).removeClass("selected");
        }
        $(form).addClass("selected");
        $(this).find("#fields-for-"+$(form).attr("id")).addClass("selected");
        self.selectedForm = $(form);
    }
    
  };

  $.extend(true, jQuery.fn.jqueryPlugin.defaults, methods);

  $.fn.formFields = function(method){
      jQuery.fn.jqueryPlugin.apply($(this), arguments);
  }
  
  
})(jQuery);

