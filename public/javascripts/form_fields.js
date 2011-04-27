var FormFields = {
  init : function(options, elem) {
    this.options = $.extend({},this.options,options);
    this.elem  = elem;
    this.$elem = $(elem);
    this.selectedFields = [];
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
    if(this.selectedForm){
      this.selectedForm.removeClass("selected");
      this.$elem.find("#fields-for-"+this.selectedForm.attr("id")).removeClass("selected");
    }
    $(form).addClass("selected");
    this.$elem.find("#fields-for-"+$(form).attr("id")).addClass("selected");
    this.selectedForm = $(form);
  },
  
  selectItem: function(selectElement){
    this.hide();
    var selectedField = { field_name: $(selectElement).find(".field-name").val(), 
                          display_name: $(selectElement).find(".display-name").val(), 
                          form_name: $(this.selectedForm).find(".form-name").val(),
                          order: this.selectedFields.length + 1  };
    this.selectedFields.push(selectedField);
    this.options.itemSelected(this.actionElement, selectedField);
  },
  
  show : function(args) {
    this.reset();
    if(args.actionElement && args.actionElement.position().top && args.actionElement.position().left && args.actionElement.width()){
      this.actionElement = args.actionElement;
      this.$elem.css("top", this.actionElement.position().top + "px");
      this.$elem.css("left", this.actionElement.position().left + this.actionElement.width() +  "px");
    }
    this.$elem.show();
  },

  hide : function( ) { this.$elem.hide(); },

  reset : function( ) {
    var firstForm = this.$elem.find(".form").first();
    this.selectForm(firstForm);
    $.each(this.selectedFields, function(index, element){
     this.$elem.find('#field-'+element.field_name).addClass("prev-selected");
    });
  }
};

$.plugin('formFields', FormFields);

