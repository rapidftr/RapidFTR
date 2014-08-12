$(document).ready(function() {
    if($('div.form_page').length == 0){
      return;
    }

    $(".form_section_delete").click(deleteFormSection);
    $("a.delete").click(deleteItem);
    $("a.add_field").click(toggleFieldPanel);
    $("ul.field_types a").click(showFieldDetails);
    $(".field_details_panel a.link_cancel").click(toggleFieldPanel);
    $(".field_hide_show").bind('change',fieldHideShow);
    $(".link_moveto").click(showMovePanel);
    triggerErrors();
    var rows = $("table#form_sections tbody");
    rows.sortable({
      update: function(){
        var datas = [];
        $(this).find("tr").each(function(index, ele){
          datas.push($(ele).attr("data"));
        });
        $.post($($.find("#save_order_url")).val(), {'ids' : datas});
      }
    });
    $(".field_location").bind('change', changeForm);

    function changeForm(event){
      var parent_div = $($(event.target).parent());
      parent_div.find(".destination_form_id").val($(this).val());
      parent_div.find("form").submit();
    }

    function fieldHideShow(){
      $.post($($.find("#toggle_url")).val(), {'id' : $(this).val()}); 
      $("table#form_sections tbody").sortable();
    }

    function showMovePanel(){
        $(this).toggleClass("sel");
        $(this).siblings("div.move_to_panel").toggleClass("hide");
    }

    function triggerErrors(){
        if((typeof(show_add_field) != 'undefined') && (show_add_field)){
            toggleFieldPanel(null, getFieldDetails(field_type));
            $("ul.field_types a").removeClass("sel");
            $("#"+field_type).addClass("sel");
        }
    }

    function toggleFieldPanel(event, div_to_show){
        resetAddField();
        if(div_to_show === undefined){
            div_to_show = "#field_details";
        }
        var edit_url = $($("#edit_url")).val();
        if(event != null && $(event.target).hasClass("add_field") && edit_url.indexOf(window.location.pathname) < 0){
          window.location = edit_url + "?show_add_field=true";
          return;
        }
        $(div_to_show).slideDown();
        $(".field_details_overlay").css("height",$(document).height());
        $(".field_details_panel").css("top", scrollY + 150);
        $(".translation_lang_selected").text($("#locale option:selected").text());
        $("#err_msg_panel").hide();
        $(".field_details_overlay").toggleClass("hide");
        $(".field_details_panel").toggleClass("hide");
    }

    function resetAddField(){
        $('#field_details_options').hide();
        $('#field_details').hide();
        $("ul.field_types a").removeClass("sel");
        $("ul.field_types a#text_field").addClass("sel");
    }

    function showFieldDetails(){
        $("ul.field_types a").removeClass("sel");
        $(this).addClass("sel");
        $("#err_msg_panel").hide();


        $("#field_details_options, #field_details").hide();

        $(".field_details_panel input[type='text'], .field_details_panel textarea").val("");
        var _this = this;
        $(".field_type").each(function(){
            $(this).val(_this.id);
        })
        $(getFieldDetails(this.id)).slideDown("fast");
    }

    function getFieldDetails(field_type){
        var fields_with_options = ["check_boxes","radio_button","select_box"];
        return $.inArray(field_type, fields_with_options) > -1 ? "#field_details_options" : "#field_details";
    }

    function deleteItem() {
        var td = $(this).parents("td");
        var fieldName = td.find("input[name=field_name]").val();
        $('#deleteFieldName').val(fieldName);
        if (confirm(I18n.t("messages.delete_item"))) {
            $('#'+fieldName+'deleteSubmit').click();
        }
    }

    function deleteFormSection() {
        if (confirm(I18n.t("messages.delete_form_section"))) {
            $('#formSectionDeleteSubmit').click();
        }
    }
});

function setTranslationFields(element) {
    var locale = $(element).val();
    $(".translation_forms").hide();
    $("div ." + locale).show();
}
$(function() {
    $(".locale").change( function(event){
        setTranslationFields(event.target);
    });
});
