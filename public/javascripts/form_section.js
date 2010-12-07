$(document).ready(function() {
	initOrderingColumns();
	$("a.moveDown").click(moveDown);
	$("a.moveUp").click(moveUp);
	$("input#save_order").click(saveOrder);
});

function initOrderingColumns() {
	$("#form_sections tbody tr").each(function(index, element){
		$("a.moveDown", element).show();
		$("a.moveUp", element).show();
	});
	
	$("#form_sections tbody tr:nth-child(2)").each(function(index, element){
		$("a.moveDown", element).show();
		$("a.moveUp", element).hide();
	});
	
	$("#form_sections tbody tr:last").each(function(index, element){
		$("a.moveDown", element).hide();
		$("a.moveUp", element).show();
	});
	
	$("#form_sections tbody tr").each(function(index, element){	$(element).find(".updatedFormSectionOrder :input").val(index + 1); });
}

function moveUp()
{
	var row = $(this).parents("tr");
	var prevRow = row.prev("tr");
  prevRow.before(row);
	initOrderingColumns();
}

function moveDown()
{
	var row = $(this).parents("tr");
	var prevRow = row.next("tr");
  prevRow.after(row);
	initOrderingColumns();
}

function saveOrder(event) {
	var form_order = {};
	var updatedOrderings = $('.updatedFormSectionOrder :input');
	$.each(updatedOrderings, function() { 
	    var name = $(this).attr("name");
	    var id = /form_order\[(.*)\]/.exec(name)[1]
	    form_order[id] = $(this).attr("value");
	});

	$.ajax({
		type: "POST",
		data: {"form_order" : form_order},
		url: '/form_section/save_order',
		success: function(data) {
		            $("#form_sections").html($(data).find("#form_sections"));
					$("a.moveDown").bind("click", moveDown);
					$("a.moveUp").bind("click", moveUp);
					initOrderingColumns();		
		        }
	});
}