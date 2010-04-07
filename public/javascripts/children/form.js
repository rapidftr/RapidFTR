RapidFTR.RowCloner = {
  add_click_handler: function(){
    var last_row = $('.relation_row:last');
    var cloned_row = $('.relation_row:first').clone(); 

    //update ids, fors, names, etc to ensure uniqueness
    var new_index = last_row.data('row_index') + 1;
    cloned_row.data('row_index',new_index);
    cloned_row.find("label").each( function(i,element){
      RapidFTR.RowCloner.replace_index_in_attribute(element,'for',new_index);
    });
    cloned_row.find("select,input").each( function(i,element){
      RapidFTR.RowCloner.replace_index_in_attribute(element,'id',new_index);
      RapidFTR.RowCloner.replace_index_in_attribute(element,'name',new_index);
    });

    //clear text boxes
    cloned_row.find("input[type='text']").val('');


    //attach click handler to remove the row
    cloned_row.find('.remove_row').show().click( function() {
      $(this).parent('.relation_row').slideUp('fast',function(){$(this).remove();});
    });

    //add new row to DOM and display
    cloned_row.hide().insertAfter(last_row).slideDown('fast');
  },

  replace_index_in_attribute: function(element,attr_name,index) {
    var new_attr_value = $(element).attr(attr_name).replace( '0', index );
    $(element).attr( attr_name, new_attr_value );
  },

  setup: function(){
    $('#add_row').click( RapidFTR.RowCloner.add_click_handler ); 
    $('.relation_row:first .remove_row').hide();
  }
}

$(document).ready( RapidFTR.RowCloner.setup );
