var FormFields = {
  init : function(options, elem) {
    this.options = $.extend({},this.options,options);
    this.elem  = elem;
    this.$elem = $(elem);
    this._build();
    return this;
  },

  _build : function() {
    var self = this;
    self.$elem.find(".form").live("click", function() { 
      self.selectForm($(this));
    });
    self.$elem.find(".field:not(.prev-selected)").live("click", function(){
      self.selectItem($(this)); 
    });
    self.$elem.find(".close-link").live("click", function() { 
      self.hide();
    });
  },
  
  selectForm : function(form){
    var self = this;
    var selectedForm = self.$elem.find(".form.selected");
    if(selectedForm){
      selectedForm.removeClass("selected");
      self.$elem.find("#fields-for-"+selectedForm.attr("id")).removeClass("selected");
    }
    $(form).addClass("selected");
    self.$elem.find("#fields-for-"+$(form).attr("id")).addClass("selected");
  },
  
  selectItem: function(selectElement){
    var self = this;
    self.hide();
    var selectedField = { field_name: $(selectElement).find(".field-name").val(), 
                          display_name: $(selectElement).find(".display-name").val(), 
                          form_id: self.$elem.find(".form.selected").find(".form-id").val() };
    self.options.onItemSelect(selectedField);
  },
  
  show : function(args) {
    var self = this;
    self.reset(args.prevSelectedFields);
    if(args.actionElement && args.actionElement.position().top && args.actionElement.position().left && args.actionElement.width()){
      self.$elem.css("top", args.actionElement.position().top + "px");
      self.$elem.css("left", args.actionElement.position().left + args.actionElement.width() +  "px");
    }
    self.$elem.show();
  },

  hide : function( ) {var self = this; self.$elem.hide(); },

  reset : function(prevSelectedFields) {
    var self = this;
    var firstForm = self.$elem.find(".form").first();
    self.selectForm(firstForm);
    $.each(prevSelectedFields, function(index, field_name){
     self.$elem.find('#field-'+field_name).addClass("prev-selected");
    });
  }
};

$.plugin('formFields', FormFields);

