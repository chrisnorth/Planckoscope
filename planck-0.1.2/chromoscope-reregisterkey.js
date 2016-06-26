/*
 * Part of Planckoscope v0.1.0
 * Plug-in for Chromoscope (v1.4.3) to allow the reregistering of keys
 * Allows the default Chromoscope behaviour to be changed
 */

(function ($) {

    function init(chromo) {
	
		// Re-register (i.e. replace) keyboard commands and associated functions
		chromo.reregisterKey = function(charCode,fn,txt){
			//copied from chromo.registerKey from 1.4.3/chromoscope.js
			if(typeof charCode!="object") charCode = [charCode];
			for(c = 0 ; c < charCode.length ; c++){
				ch = (typeof charCode[c]=="string") ? charCode[c].charCodeAt(0) : charCode[c];
				available = true;
				for(i = 0 ; i < this.keys.length ; i++){
					//console.log('trying ',this.keys[i].charCode);
					if(this.keys[i].charCode == ch) {
						available = false;
						//replace key
						//NEW: replace key entry
						this.keys[i]={charCode:ch,char:String.fromCharCode(ch),fn:fn,txt:txt};
						//END
					}
				}
				if(available){
					this.keys.push({charCode:ch,char:String.fromCharCode(ch),fn:fn,txt:txt});
					if(this.phrasebook.alignment=="right"){
						a = '<strong>'+String.fromCharCode(ch)+'</strong>'
						b = txt;
					}else{
						b = '<strong>'+String.fromCharCode(ch)+'</strong>'
						a = txt;
					}
					//if(txt) $(this.body+" .chromo_controlkeys").append('<li>'+a+' - '+b+'</li>');
				}
			}
			//chromo.buildHelp(true);
			return this;
		}

    }
    $.chromoscope.plugins.push({
		init: init,
		name: 'reregisterkey',
		version: '1.0'
    });	
})(jQuery);
