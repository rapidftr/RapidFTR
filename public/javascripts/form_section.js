$(document).ready(function() {
    initOrderingColumns();
    setTranslationFields($("#locale option:selected"));
    $("a.delete").click(deleteItem);
    $("a.moveDown").click(moveDown);
    $("a.moveUp").click(moveUp);
    $("input#save_order").click(saveOrder);
    $("input#save_field_order").click(saveFieldOrder);
    $("a.add_field").click(toggleFieldPanel);
    $("ul.field_types a").click(showFieldDetails);
    $(document).delegate("select.fieldLocation", "change", saveFieldLocation);
    $(".field_details_panel a.link_cancel").click(toggleFieldPanel);
    $(".field_details_panel input#add_field_btn").click(addFieldToTable);
    $(".field_hide_show").bind('change',fieldHideShow);
    triggerErrors();
    var rows = $("table#form_sections tbody");
    rows.sortable({
      update: function(){
        var fieldNames = [];
        $(this).find("tr").each(function(index, ele){
          fieldNames.push($(ele).attr("data"));
        });
        $.post($($.find("#save_order_url")).val(), {'field_names' : fieldNames});
      }
    });
});


function fieldHideShow(){
  $.post($($.find("#toggle_url")).val(), {'id' : $(this).val()}); 
    $("table#form_sections tbody").sortable();
    $(".link_moveto").click(showMovePanel);
});

function showMovePanel(){
    $(this).toggleClass("sel");
    $(this).siblings("div.move_to_panel").toggleClass("hide");
}

function triggerErrors(){
    if(show_add_field){
        toggleFieldPanel(null, getFieldDetails(field_type));
        $("ul.field_types a").removeClass("sel");
        $("#"+field_type).addClass("sel");
    }
}

function toggleFieldPanel(event, div_to_show){
    if(div_to_show === undefined){
        div_to_show = "#field_details";
    }
    $(div_to_show).slideDown();
    $(".field_details_overlay").css("height",$(document).height());
    $(".field_details_panel").css("top", scrollY + 150);
    $(".translation_lang_selected").text($("#locale option:selected").text());
    $("#err_msg_panel").hide();
    $(".field_details_overlay").toggleClass("hide");
    $(".field_details_panel").toggleClass("hide");
}

function addFieldToTable(){
    var fieldtype1 = ["text_field","text_area","numeric_field","date_field"];
    var fieldtype2 = ["check_box","radio_btn","select_box"];
    var selFieldType = $("ul.field_types a.sel")[0].id;
    console.log(selFieldType);
    var newField, errMsg = "";

    if ($.inArray(selFieldType, fieldtype1) > -1){

        if ($(".field_details_panel .default_lang_panel #txt_display_name").val() != ""){
            newField += "<tr>";
            newField += "<td class='cell_display_name'>" + $(".field_details_panel .default_lang_panel #txt_display_name").val() + "<input type='hidden' value=" +$(".field_details_panel .translation_lang_panel #txt_display_name").val() + " />" + "</td>";
            newField += "<td class='cell_help_text'>" + $(".field_details_panel .default_lang_panel #txt_help_text").val() + "<input type='hidden' value=" +$(".field_details_panel .translation_lang_panel #txt_help_text").val() + " />"  + "</td>";
            newField += "<td class='cell_options'>" + "</td>";
            newField += "<td class='cell_fieldtype'>" + selFieldType +"</td>";
            newField += "<td class='cell_hide'>" + "<input type='checkbox' /> " + "</td>";
            newField += "<td class='cell_moveup'>" + "<a href='javascript:void(0)' class='up_arrow'></a>" + "</td>";
            newField += "<td class='cell_movedown'>" + "<a href='javascript:void(0)' class='down_arrow'></a>" + "</td>";
            newField += "<td class='cell_actions'>" + "<a href='javascript:void(0)' class='edit'>Edit</a> <a href='javascript:void(0)' class='delete'>Delete</a>" + "</td>";
            newField += "</tr>";

            $("table#form_sections").append(newField);
            toggleFieldPanel();
        }
        else{
            errMsg = "Display name cannot be empty. Please enter a valid display name";
            $("#err_msg_panel").html(errMsg);
            $("#err_msg_panel").show("fast");
        }

    }
    else{
        console.log($(".field_details_panel .default_lang_panel #txt_display_name_options").val());
        if (($(".field_details_panel .default_lang_panel #txt_display_name_options").val() != "") && ($(".field_details_panel .default_lang_panel #txt_options").val() != "")){
            console.log("in");
            newField += "<tr>";
            newField += "<td class='cell_display_name'>" + $(".field_details_panel .default_lang_panel #txt_display_name_options").val() + "<input type='hidden' value=" +$(".field_details_panel .translation_lang_panel #txt_display_name").val() + " />" + "</td>";
            newField += "<td class='cell_help_text'>" + $(".field_details_panel .default_lang_panel #txt_help_text_options").val() + "<input type='hidden' value=" +$(".field_details_panel .translation_lang_panel #txt_help_text").val() + " />"  + "</td>";
            newField += "<td class='cell_options'>" + $(".field_details_panel .default_lang_panel #txt_options").val() + "</td>";
            newField += "<td class='cell_fieldtype'>" + selFieldType +"</td>";
            newField += "<td class='cell_hide'>" + "<input type='checkbox' /> " + "</td>";
            newField += "<td class='cell_moveup'>" + "<a href='javascript:void(0)' class='up_arrow'></a>" + "</td>";
            newField += "<td class='cell_movedown'>" + "<a href='javascript:void(0)' class='down_arrow'></a>" + "</td>";
            newField += "<td class='cell_actions'>" + "<a href='javascript:void(0)' class='edit'>Edit</a> <a href='javascript:void(0)' class='delete'>Delete</a>" + "</td>";
            newField += "</tr>";

            $("table#form_sections").append(newField);
            toggleFieldPanel();
        }
        else{
            errMsg = "Display name or options cannot be empty. Please enter a valid display name and options";
            $("#err_msg_panel").html(errMsg);
            $("#err_msg_panel").show("fast");
            console.log(errMsg);
        }

    }
}

function showFieldDetails(){
    $("ul.field_types a").removeClass("sel");
    $(this).addClass("sel");
    $("#err_msg_panel").hide();


    $("#field_details_options, #field_details").hide();

    $("input[type='text'],textarea ").val("");
    var _this = this;
    $(".field_type").each(function(){
        $(this).val(_this.id);
    })
    $(getFieldDetails(this.id)).slideDown("fast");
}

function getFieldDetails(field_type){
    var fields_with_options = ["check_box","radio_btn","select_box"];
    return $.inArray(field_type, fields_with_options) > -1 ? "#field_details_options" : "#field_details";
}

function onFormSectionDetailsEditPage() {
    return $('#editFormDetails').length === 1;
}

function nameIsTheFirstRow(){
  return $("#nameRow").index() == 0;
}

function initOrderingColumns() {
    var mainContainer = "form_sections";

    $("#" + mainContainer + " tbody tr").each(function(index, element) {
        $("a.moveDown", element).show();
        $("a.moveUp", element).show();
    });

    var fieldToStartFrom = 1;
    if (onFormSectionDetailsEditPage() && !nameIsTheFirstRow()){
        fieldToStartFrom = 0;
    }

    $("#"+mainContainer+" tbody tr:eq("+fieldToStartFrom+")").each(function(index, element){

	$("a.moveUp", element).hide();
    $("a.moveDown",element).css("display","inline");

    });

    $("#" + mainContainer + " tbody tr:last").each(function(index, element) {
        $("a.moveDown", element).hide();
        $("a.moveUp", element).show();
    });

    $("#" + mainContainer + " tbody tr").each(function(index, element) {
        $(element).find(".updatedFormSectionOrder :input").val(index + 1);
    });
}
function moveUp() {
    var row = $(this).parents("tr");
    var prevRow = row.prev("tr");
    prevRow.before(row);
    initOrderingColumns();
    return false;
}
function changeDirection(fieldName, isUp) {
    var curAction = $('#changeDirection').attr('action');
    if (isUp) {
        curAction += 'move_up';
    } else {
        curAction += 'move_down';
    }
    $('#changeDirection').attr('action', curAction);
    $('#changeDirectionFieldName').val(fieldName);
    $('#changeDirectionSubmit').click();
}
function deleteItem() {
    var td = $(this).parents("td");
    var fieldName = td.find("input[name=field_name]").val();
    $('#deleteFieldName').val(fieldName);
    if (confirm(I18n.t("messages.delete_item"))) {
        $('#'+fieldName+'deleteSubmit').click();
    }
}
function moveDown() {
    var row = $(this).parents("tr");
    var prevRow = row.next("tr");
    prevRow.after(row);
    initOrderingColumns();
    return false;
}

function callback(data) {
    if ($('#form_sections').length === 1) {
        $("#form_sections").html($(data).find("#form_sections"));
        $("a.moveDown").bind("click", moveDown);
        $("a.moveUp").bind("click", moveUp);
        initOrderingColumns();
        $("#successNotice").show();
    }
}
function saveOrder(event) {
    var form_order = getUpdatedOrderings('.updatedFormSectionOrder :input');


    $.ajax({

        url: '/form_section/save_form_order',
        type: "POST",
        data: {"form_order" : form_order},
        success: function(data) {
            callback(data);
        }
    });
}

function saveFieldOrder(event) {
    var form_order = getUpdatedOrderings('.updatedFormSectionOrder :input');
    var formId = $('#sectionId').html();
   var saveFieldOrderURL=$(this).data('submit_url');

    $.ajax({
        url: saveFieldOrderURL,
        type: "POST",
        data: {
            "form_order" : form_order,
            "formId" : formId
        },
        success: function(data) {
           callback(data);
        }
    });
}

function saveFieldLocation(event) {
    var name = $(this).attr("name");
    var id = /(.*)_destination_form_id/.exec(name)[1];
    var to_form_section = $(this).attr("value");
    var selection = this.options[this.selectedIndex].text;
    var formId = $('#sectionId').html();
    var message = confirm(I18n.t("messages.move_item", {selection_key: selection}));
    if (message) {
        $.ajax({
            url: '/fields/' + id,
            type: "PUT",
            data: {
                "destination_form_id" : to_form_section,
                "form_section_id" : formId
            },
            success:function(data, status, xmlHttpRequest) {
                location.reload();
            },
            error: function(xmlHttpRequest, status, error) {
                alert("in error " + error);
            }
        });

    }

}

function getUpdatedOrderings(inputSelector) {
    var form_order = {};
    var updatedOrderings = $(inputSelector);
    $.each(updatedOrderings, function() {
        var name = $(this).attr("name");
        var id = /form_order\[(.*)\]/.exec(name)[1];
        form_order[id] = $(this).attr("value");
    });
    return form_order;
}


function setTranslationFields(element) {
    var locale = $(element).val();
    $(".translation_forms").hide();
    $("div ." + locale).show();
}
$(function() {
    $("#locale").change( function(event){
        setTranslationFields(event.target);
    });
});
