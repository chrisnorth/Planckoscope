(function ($) {

    function init(chromo) {
	
	chromo.addOverlayLayer = function(input){
	    //console.log('adding overlay');
	    if (!this.overlays){
		this.overlays = new Array();
	    }
	    this.overlays[this.overlays.length] = new OverlayLayer(input);
	    console.log(input.name);
	    if(typeof input.key=="string"){
		var character = input.key;
		console.log('register',character);
		this.registerKey(input.key,function(){
		    this.toggleOverlaysByName(character);
		    this.checkTiles(true);
		});
	    }
	    return this;
	}
	
	chromo.processOverlays = function(){
	    for(var i=0 ; i < this.overlays.length ; i++){
		var a = this.overlays[i];
		if(a.name) $(this.body+" .chromo_innerDiv").append('<div class="overlay '+a.name+'"></div>');
		setOpacity($(this.body+" ."+a.name),a.opacity);
		//turn off overlay initially
		this.toggleOverlaysByName(a.key);
	    }
	    $(this.body+" .pinholder").css({"z-index":this.spectrum.length+this.annotations.length+this.overlays.length+1,left:0,top:0,width:this.mapSize*2,height:this.mapSize,position:'absolute'});
	}

	function OverlayLayer(input){
	    console.log('OL:',input.name);
	    //copy of ChromoscopeLayer(input) from 1.4.3/chromocope.js 
	    if(input){
		this.useasdefault = (input.useasdefault) ? true : false;	
		this.layer = (input.layer) ? input.layer : null;
		this.opacity = (input.opacity) ? input.opacity : 0.0;
		this.title = (input.title) ? input.title : '';
		this.name = (input.name) ? input.name : '';
		this.attribution = (input.attribution) ? input.attribution : '';
		this.key = (input.key) ? input.key : '';
		this.tiles = (input.tiles) ? input.tiles : '';
		this.tiles_eq = (input.tiles_eq) ? input.tiles_eq : '';
		this.ext = (input.ext) ? input.ext : 'jpg';
		this.range = {longitude:[-180,180],latitude:[-90,90],x:[0,0],y:[0,0]};
		this.limitrange = false;
		this.blank = (input.blank) ? input.blank : 'blank.jpg';
		if(typeof input.range=="object"){
		    if(typeof input.range.longitude=="object") this.range.longitude = input.range.longitude;
		    if(typeof input.range.latitude=="object") this.range.latitude = input.range.latitude;
		    this.limitrange = true;
		}
	    }
	}
	//console.log('hello')
	
	chromo.toggleOverlaysByName = function(character){
	    if(!character) return;
	    for(var i=0 ; i < this.overlays.length ; i++){
		if(character == this.overlays[i].key){
		    console.log('toggle ',this.overlays[i].name,' from opacity ',getOverlayOpacity($(this.body+" ."+this.overlays[i].name)));
		    if(getOverlayOpacity($(this.body+" ."+this.overlays[i].name)) == this.overlays[i].opacity) setOverlayOpacity($(this.body+" ."+this.overlays[i].name),0);
		    else setOverlayOpacity($(this.body+" ."+this.overlays[i].name),this.overlays[i].opacity);
		    console.log('  toggled to opacity ',getOverlayOpacity($(this.body+" ."+this.overlays[i].name)));
		}
	    }
	}

	// ===================================
	// Generic functions that are independent 
	// of the chromo container
	// copied from 1.4.3/chromoscope.js
	function getOverlayOpacity(el){
	    if(typeof el=="string") el = $(el);
	    if(jQuery.browser.msie) return (el.css("filter").replace(/[^0-9.]*/g,""))/100;
	    else return parseFloat(el.css("opacity")).toFixed(3); // Only need 3dp precision - this stops floating point errors in Chrome
	}
	
	// A cross browser way to set the opacity of an element
	// Usage: setOpacity($("#chromo_message"),0.4)
	function setOverlayOpacity(el,opacity){
	    if(typeof el=="string") el = $(el);
	    if(jQuery.browser.msie){
		el.css("filter","alpha(opacity="+Math.floor(opacity*100)+")");
		el.children().css("filter","alpha(opacity="+Math.floor(opacity*100)+")");
	    }else el.css("opacity",opacity);
	}

    }
    $.chromoscope.plugins.push({
	init: init,
	name: 'addoverlay',
	version: '1.0'
    });
    
})(jQuery);

/*(function ($) {

    function init(chromo) {
	
	
	function OverlayLayer(input){
	    return new ChromoscopeLayer(input);
	}
	
	chromo.toggleOverlaysByName = function(character){
	    if(!character) return;
	    for(var i=0 ; i < this.overlays.length ; i++){
		if(character == this.overlays[i].key){
		    if(getOpacity($(this.body+" ."+this.overlays[i].name)) == this.overlays[i].opacity) setOpacity($(this.body+" ."+this.overlays[i].name),0);
		    else setOpacity($(this.body+" ."+this.overlays[i].name),this.overlays[i].opacity);
		}
	    }
	}
	
	$.chromoscope.plugins.push({
	    init: init,
	    name: 'overlay',
	    version: '1.0'
	});
    }	
})(jQuery);*/

 