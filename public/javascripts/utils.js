RapidFTR.Utils = {
    dehumanize: function(val){
        return val.toString().trim().replace(/\s/\g, "_").replace(/\W/\g, "").toLowerCase()
    }
};


