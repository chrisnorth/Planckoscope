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
		    if(txt) $(this.body+" .chromo_controlkeys").append('<li>'+a+' - '+b+'</li>');
		}
	    }
	    chromo.rebuildHelp(true);
	    return this;
	}

	chromo.rebuildHelp = function(overwrite){
	    //copy of chromo.buildHelp from 1.4.3/chromoscope.js 
	    // Construct the help box
	    var txt = this.phrasebook.helpdesc;
	    if(this.phrasebook.translator) txt += '<br /><br />'+this.phrasebook.name+': '+this.phrasebook.translator;
	    if($(this.body+" .chromo_help").length == 0) $(this.body).append('<div class="chromo_help">'+txt+'</div>');
	    else{ if(overwrite) $(this.body+' .chromo_help').html(txt); }
	    var buttons = "<li><a href=\"#\" onClick=\"javascript:simulateKeyPress('k')\">Hide/show the wavelength slider</a></li>";
	    buttons += "<li><a href=\"#\" onClick=\"javascript:simulateKeyPress('+')\">Zoom in</a></li>";
	    buttons += "<li><a href=\"#\" onClick=\"javascript:simulateKeyPress('-')\">Zoom out</a></li>";
	    var h = (this.phrasebook.helpmenu) ? this.phrasebook.helpmenu : this.phrasebook.help;
	    var keys = this.buildKeyItem("h",h);
	    for(var i=0 ; i < this.spectrum.length ; i++){
		if(this.spectrum[i].key) {
		    if(typeof this.spectrum[i].title=="object"){
			var l = (!this.spectrum[i].title[this.langshort]) ? 'en' : this.langshort;
			var t = this.spectrum[i].title[l]
		    }else{
			if(this.phrasebook[this.spectrum[i].title]) var t = this.phrasebook[this.spectrum[i].title];
			else var t = this.spectrum[i].title;
		    }
		    var s = this.phrasebook.switchtext.replace("__WAVELENGTH__",t)
		    keys += this.buildKeyItem(this.spectrum[i].key,s);
		}
	    }
	    for(var i=0 ; i < this.annotations.length ; i++){
		if(this.annotations[i].key){
		    //NEW: Do the same with annotations as with wavelengths
		    if(typeof this.annotations[i].title=="object"){
			var l = (!this.annotations[i].title[this.langshort]) ? 'en' : this.langshort;
			var t = this.annotations[i].title[l]
		    }else{
			if(this.phrasebook[this.annotations[i].title]) var t = this.phrasebook[this.annotations[i].title];
			else var t = this.annotations[i].title;
		    }
		    var s = this.phrasebook.switchannotation.replace("__ANNOTATION__",t)
		    //END
		    keys += this.buildKeyItem(this.annotations[i].key,s);
		}
	    }
		keys += this.buildKeyItem(".",this.phrasebook.showhide);
		keys += this.buildKeyItem("&uarr;",this.phrasebook.up);
		keys += this.buildKeyItem("&darr;",this.phrasebook.down);
		keys += this.buildKeyItem("+",this.phrasebook.zoomin);
		keys += this.buildKeyItem("&minus;",this.phrasebook.zoomout);
		$(this.body+" .chromo_controlbuttons").html(buttons);
		$(this.body+" .chromo_controlkeys").html(keys);

		if(!this.ignorekeys || !this.container){
			$(this.body+" .chromo_help").prepend(this.createClose());
			var w = (this.wide > 600) ? 600 : this.wide;
			$(this.body+" .chromo_help").css("width",(w-50)+"px");
		}

		// Construct the help link
		if($(this.body+" .chromo_helplink").length == 0) $(this.body).append('<p class="chromo_helplink"></p>');

		this.centreDiv(".chromo_help");
		$(this.body+" .chromo_help").attr('dir',(this.phrasebook.alignment=="right" ? 'rtl' : 'ltr'));
	}



    }
    $.chromoscope.plugins.push({
	init: init,
	name: 'reregisterkey',
	version: '1.0'
    });	
})(jQuery);
