RapidFTR.Utils = {
    dehumanize: function(val){
		return jQuery.trim(val.toString()).replace(/\s/g, "_").replace(/\W/g, "").toLowerCase();
    }
};

