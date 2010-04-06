// ccopy jQuery Plugin - Form field Carbon Copy

// Version 0.2
// (c) 2009 Rory Cottle
// Documentation available at www.blissfulthroes.com
// Dual licensed under MIT and GPL 2+ licenses
// http://www.opensource.org/licenses

// Dependencies:
// jQuery 1.2.6 (www.jquery.com)

// Description:
// Simple jQuery plugin allowing users to dynamically clone and remove form fields at the touch of a button. 
// Inspired in part by João Gradim's awesome Clonefield plugin. And whilst being inspired by Clonefield, ccopy was written entirely from scrap.
// However, ccopy allows cloning of multiple fields of different types within the same form without losing their order.
// In addition, multiple instances can be initiated with default values through the exposed functions.
 
// Defaults:
// - useCounter : default value is true. When set to true, the plugin will replace the name attribute of the target element (and further clones)
//   to match the new id. It will also append a hidden counter field, which can be used to count how many clones exist. This hidden field will take on the id of the
//   original element appened with '_counter'. 
//   If set to false, the name attribute will simply be appended with [] and no counter will be created. This is a more eloquent option, but IE doesn't like it
//   (hence useCounter defaulting to true)																																	   
// - copyClass : class added to each field
// - removeClass : class added to the Remove button (also used to generate it's id)
// - removeText : text to appear in the Remove button

// Usage:
// Example html -
//		<form action="index.php" method="post">
//		<label for="input">Input</label>
//		<input id="input" name="input" class="bubbly" value=""/>
//		<a id="addone" href="#">Add One</a>
//		<input type="submit" value="submit" name="submit" />
//		</form>	
//
// Typical initialization script (selector linked to form field id) -
// $(document).ready(function() {
// $('#addone').ccopy('input');
// });
//
// Set initial value of a field through the expose function ccopy.set (requires the field to be set has already
// been initialized as above) -
// $.fn.ccopy.set('addone', 'This is just a test');
//
// Create and set multiple clones of an already initialized form field
// (pass the exposed function an array of values to set, and watch the magic) -
// arrayVals = new Array('this is one', 'this is two', 'this is three');
// $.fn.ccopy.multiset('addone', arrayVals);
//
// Example of the first initialization script with different defaults set
// $('#addtwo').ccopy('text', {
// removeText : 'Kill The Last in Line',
// copyClass : 'differentClass'
// });

// Notes and Known Issues:
// - ccopy will recognize whether a cloned field has an associated label, and will clone it as well
// - ccopy will clone the initial element used as the selector as the Remove button (one of João Gradim's Clonefield innovations)
// - ccopy can recognize the difference between buttons and anchors/other elements used as the selector
// - ISSUE : <button> type elements seem to fire form submission when used as a selector (undetermined as to whether this is
//   related to ccopy or not - under investigation
// - ISSUE : When using the exposed functions to set and create elements, they must be fired immediately after the initializing
//   element, or the values being set may be set in the wrong order - example:
//   	$(document).ready(function() {
// 		$('#addone').ccopy('input');
// 		arrayVals = new Array('this is one', 'this is two', 'this is three');
// 		$.fn.ccopy.multiset('addone', arrayVals);
// 		});

// Example of accessing the posted data via PHP:
// useCounter = true -
//		$count = $_POST['input_counter'] // this would be the hidden counter
//		for($i = 1; $i <= $count; $i++)
// 		{
//			$input[] = $_POST['input_' . $i]; // add each input to an array called $input
//		}
//
// useCounter = false -
//		$input[] = $_POST['input'];

(function($) 
{
	// Plugin Definition ***************************************************************
	$.fn.ccopy = function(id, options)
	{
		debug(this);
		
		// Plugin Defaults ***************************************************************
		var defaults = {
			useCounter : true,
			copyClass : 'ccopy',
			removeClass : 'removeccopy',
			removeText : 'Remove Last Entry'
		};
		// Build main options before element iteration
		var opts = $.extend(defaults, options);
		
		$this = $(this);
		var nolabel = true;
		var o = ($.meta) ? $.extend({}, opts, $this.data()) : opts;
		
		// Make sure there is only one target element
		var counter = $('#' + id).length;
		if(counter <= 1)
		{
			// Re label target element and assign new name and id base on originally supplied
			var newid = id + "_" + counter;
			var name = $('#' + id).attr("name");
			if(o.useCounter)
			{
				$('#' + id).attr("name", id + "_" + counter);
				var hiddenCounter = '<input type="hidden" name="' + id + '_counter" id="' + id + '_counter" value="' + counter + '"/>';
				$(this).after(hiddenCounter);
			}
			else
			{
				$('#' + id).attr("name", name + "[]");
			}
			$('#' + id).attr("id", newid);
			
			var newclass = id + '_' + o.copyClass;
			$('#' + newid).addClass(newclass);
			
			if($("label[for='" + id + "']").text())
			{
				var labeltxt = $("label[for='" + id + "']").text();
				$("label[for='" + id + "']").text(labeltxt + ' ' + counter);
				$("label[for='" + id + "']").attr('for', id + "_" + counter);
				nolabel = false;
			}
			
			// Add Remove button
			var removeclass = $(this).attr("class");
			var removeid = $(this).attr("id");
			
			var isbutton = $("#" + removeid + ":button").length;
						
			makeme = $(this).clone();
			makeme.addClass( removeid + "_" + o.removeClass);
			makeme.attr("id", removeid + "_" + o.removeClass);
			if(isbutton < 1)
			{
				makeme.html(o.removeText);
			}
			else
			{
				makeme.val(o.removeText);
			}
			makeme.insertAfter($(this));
			
			// Bind click event to Remove button
			makeme.bind("click.killme", function()
			{	
				var count = $('.' + newclass).length;
				if(count > 1)
				{
					var removeclone = id + "_" + count;
					if(!nolabel)
					{
						$("label[for='" + removeclone + "']").remove();
					}
					$("#" + removeclone).remove();
					// Focus on the previous field
					var prev = count - 1;
					if(o.useCounter)
					{
						$('#' + id + '_counter').val(prev);
					}
					$("#" + id + "_" + prev).focus();
				}
			});
			// Store data for exposed functions
			$this.data("linkedTo", {current : newid});
							
			return this.each(function() 
			{
				// Iterate and initialize each matched element
				$this.click(function()
				{
					
					var total = $('.' + newclass).length;
					var current = total;
					var next = total + 1;
					
					var cloned = id + "_" + current;
					var clone =  id + "_" + next;
					
					if(!nolabel)
					{
						var newlabel = labeltxt + " " + next;
					
						$("label[for='" + cloned + "']").clone(true)
						.attr('for', clone)
						.html(newlabel)
						.insertAfter($('#' + cloned));
					}
									
					addme = $('#' + cloned).clone(true);
					addme.attr('id', clone);
					if(o.useCounter)
					{
						addme.attr('name', clone);
						$('#' + id + '_counter').val(next);
					}
					addme.val('');
					addme.insertAfter((nolabel) ? $('#' + id + "_" + current) : $("label[for='" + clone + "']"));
					
					// Store data for exposed functions
					$this.data("linkedTo", {current : clone});
									
					// Focus on the newly created clone
					$('#' + clone).focus();
				});
			});
		}
		else
		{
			alert("You have duplicate ids within your page.\nNot only will ccopy fail, it will invalidate your xhtml...");
		}
	};
	
	// Private function for debugging  ***************************************************************
	function debug($obj) 
	{
		if (window.console && window.console.log)
		{
			window.console.log('ccopy count: ' + $obj.size());
		}
	}
	
	// Exposed functions  ***************************************************************
	// Set value for one ccopy element
	$.fn.ccopy.set = function(id, val)
	{
		var linkedId = $("#" + id).data("linkedTo").current;
		$("#" + linkedId).val(val);
	};
	
	// Set multiple values for elements and create new clones if needed
	$.fn.ccopy.multiset = function(id, valArray)
	{
		for(i = 0; i < valArray.length; i++)
		{
			if(i > 0)
			{
				$("#" + id).click();
			}
			$.fn.ccopy.set(id, valArray[i]);
		}
	};
})(jQuery);