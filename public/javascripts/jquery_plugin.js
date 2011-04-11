(function($){

  $.fn.jqueryPlugin = function(method) {
    var methods = $.fn.jqueryPlugin.defaults;
    if ( methods[method] ) {
      return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      return methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' +  method + ' does not exist' );
    }    
  
  };
  
  $.fn.jqueryPlugin.defaults = { }
  
})(jQuery);

