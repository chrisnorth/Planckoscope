/*
 * 
 * Planckoscope v0.1.0
 * 
 * Written by Chris North for the Planck Royal Society Summer Science Exhibition 2013 as an educational resource.
 * 
 * This application requires Chromoscope v1.4.3. It will run locally or on a web server. To run locally you will need to download the appropriate tile sets and code.
 * 
 * Functions in v0.1.0 (beyond Chromoscope):
 *   - Adds a second label layer for 'Planck labels'
 *   - Allow the overlay of more than one layer
 *   - Add a hidable options box to the left side
 *   - Adds ability to change opacity of overlays
 *   - Displays info/help for overlay layers
 *   - Uses reregisterkey plugin to allow behaviour of keys to be changed
 *   - Regegisters '.' key to hide new displays
 * 
 * Future modifications planned:
 *   - More overlays
 *   - Support for adding KML tags
 *   - Better language support (currently only native-Chromoscope text is translated)
 * 
 */

function setupPlanck(){    
    $('#kiosk').disableTextSelect();
    //chromo.buildHelp(true);
    //animate options panel
    //process overlays
    //chromo.processOverlays();


    //*******************
    //re-register keys
    //*******************
    chromo.reregisterKey('.',function(){
	$(this.body+" h1").toggle();
	$(this.body+" h2").toggle();
	$(this.body+" .chromo_message").hide();
	$(this.body+" .chromo_layerswitcher").toggle();
	$(this.body+" .chromo_helplink").toggle();
	$(this.body+" .chromo_help").hide();
	$(this.body+" .chromo_info").hide();
	$(this.body+" .chromo_pingroups_list").toggle();
	$(this.body+" .chromo_title").toggle();
	$(this.body+" #kiosk").toggle();
	$(this.body+" #overlay").toggle();
    });

    chromo.reregisterKey(45,function(){ // user presses the - (45 for Firefox)
	this.changeMagnification(-1);
    });
    chromo.reregisterKey('c',function(){
	chromo.toggleAnnotationsByName('c');
	chromo.checkTiles(true)
	//console.log('toggled labels');
	if($('#kiosk #options #option-const #on-off').hasClass("off")){
	    $('#kiosk #options #option-const #on-off').removeClass("off").addClass("on");
        }else if($('#kiosk #options #option-const #on-off').hasClass("on")){
	    $('#kiosk #options #option-const #on-off').removeClass("on").addClass("off");};
    },'toggle constellation labels')

    chromo.reregisterKey('p',function(){
	chromo.toggleAnnotationsByName('p');
	chromo.checkTiles(true)
	//console.log('toggled planck');
	if($('#kiosk #options #option-labels #on-off').hasClass("off")){
	    $('#kiosk #options #option-labels #on-off').removeClass("off").addClass("on");
        }else if($('#kiosk #options #option-labels #on-off').hasClass("on")){
	    $('#kiosk #options #option-labels #on-off').removeClass("on").addClass("off");};
    },'toggle planck labels')


    //turn off annotations (normal labels already turned off)
    for(var i=0 ; i < chromo.annotations.length ; i++){
	var character = chromo.annotations[i].key;
	if (character != 'l') chromo.toggleAnnotationsByName(character)
	//console.log('turn off annotation ',character);
    };

    //********************************
    //make options buttons in overlay
    //********************************
    chromo.nann=0;
    for (var i=0 ; i < chromo.annotations.length ; i++){
	if (!isOverlay(chromo.annotations[i].key)) chromo.nann++ ;
    };
    chromo.nov = chromo.annotations.length - chromo.nann;
    //chromo.nov = 8;
    if (chromo.nov >0){


	//set up columns
	var colmax=3;
	if (chromo.nov > colmax) ncol=2;
	//console.log(chromo.nov/colmax,Math.ceil(chromo.nov/colmax));
	var ncol=Math.ceil(chromo.nov/colmax);
	var colwid = 150;
	var ovwid=Math.round(parseInt($(chromo.body+' #overlay').width()));
	ovwid = ovwid + ncol*(colwid+20)
	opwid = ncol*(colwid+20)
	console.log('ovwid:',ovwid,'opwid',opwid);
	$(chromo.body+' #overlay').css({
	    width:ovwid+'px',
	    left:-(ovwid+40)+'px',
	    opacity:1.0
	});
	$(chromo.body+' #overlay #options').css({width:opwid+'px'});
	for (var c=0;c<ncol;c++){
	    $(chromo.body+' #overlay #options').append('<div class="column" id="col'+(c+1)+'" style="top:0px;left:'+(260+(c)*colwid)+'px;width:'+colwid+'px;"></div>');
	};

	var ovx=0;
	var colid='col1'
        for (var i=0 ; i < chromo.annotations.length ; i++){
	    //add annotation buttons
	    if (isOverlay(chromo.annotations[i].key)){
		ovx++;
		colid='col'+Math.ceil(ovx/colmax);
		//console.log(ovx,colid);
		//if (ovx > colmax) colid='col2';
		divclass="option";
		divid="option-"+chromo.annotations[i].name;
		infoid="info-"+chromo.annotations[i].name;
		chromo.annotations[i].divid=divid;
		chromo.annotations[i].infoid=infoid;
		$(chromo.body+' #overlay #'+colid).append('<div id="'+divid+'" class="'+divclass+'">');
		$(chromo.body+' #overlay #'+colid+' #'+divid).append('<div id="on-off" class="off"></div>');
		$(chromo.body+' #overlay #'+colid+' #'+divid).append('<div class="label">'+chromo.annotations[i].title+'</div>');
		$(chromo.body+' #overlay #'+colid+' #'+divid+' .label').disableTextSelect();
		//sort out what happens on clicking the button
		$(chromo.body+' #overlay #'+colid+' #'+divid).click(function(){
		    //var srchid=$(chromo.body+' #overlay #'+colid+' #'+divid).id;
		    var srchid=this.id;
		    //console.log('looking for:',srchid);
		    for (var j=0 ; j < chromo.annotations.length ; j++){
			if (chromo.annotations[j].divid == srchid){
			    chromo.simulateKeyPress(chromo.annotations[j].key);
			    if ($(chromo.body+' #overlay #'+srchid+' #on-off').hasClass("off")){
				$(chromo.body+' #overlay #'+srchid+ ' #on-off').removeClass("off").addClass("on");
			    }else{
				$(chromo.body+' #overlay #'+srchid+' #on-off').removeClass("on").addClass("off");
			    };
			};
		    };
		});
		
		//add info button
		$(chromo.body+' #overlay #'+colid).append('<div class="info" id="'+infoid+'"></div>');
		$(chromo.body+' #overlay #'+colid+" #"+infoid).click(function(){
		    var srchid='more'+this.id;
		    //console.log('toggling',srchid,$(chromo.body+' #'+srchid).css('display'));
		    if ($(chromo.body+' #'+srchid).css('display')=='none'){
			$(chromo.body+' #'+srchid).show();
		    }else{
			$(chromo.body+' #'+srchid).hide();
		    }
		});

	    };
	};
	$(chromo.body+' .overlay_info').each(function(){
	    srchid=this.id;
	    //console.log(srchid);
	    $(this).prepend(chromo.createClose());
	    //$(this.body+" .chromo_close").bind('click',{id:'overlay_info'}, jQuery.proxy( this, "hide" ) );
	    $(chromo.body+' #'+srchid+' .chromo_close').on('click',{id:srchid},function(event){$(chromo.body+' #'+event.data.id).hide();});
	    if (chromo.wide < $(this).width()) $(this).css("width",w-50+"px");
	    //console.log(this,$(this).width());
	    chromo.centreDiv("#"+srchid)

	});

	var ovheight=Math.round(parseInt($(chromo.body+' #overlay').height()));
	colheight=40+(ncol+1)*40;
	if (ovheight < colheight){
	    $(chromo.body+' #overlay').css({height:colheight+"px"});
	    titbot=Math.round(parseInt($(chromo.body+' #overlay #menu-title').css('bottom')));
	    titbot=titbot+(colheight-ovheight)/2;
	    $(chromo.body+' #overlay #menu-title').css({bottom:titbot+"px"});
	}

	//add opacity changer
	opleft=260+colwid*(ncol-1)/2
	$(chromo.body+' #overlay #options').append('<div id="opcol" class="column" style="top:'+(colheight-40)+';left:'+opleft+'"></div>');
	$(chromo.body+' #overlay #options #opcol').append('<div class="option" id="opacity"></div>');
	$(chromo.body+' #overlay #options #opcol .option').append('<div id="on-off" class="null"></div>');
	$(chromo.body+' #overlay #options #opcol .option').append('<div class="op-pm"><div class="op-plus">+</div><div class="op-minus">-</div></div>')
	$(chromo.body+' #overlay #options #opcol .option').append('<div class="label">Opacity: <span class="opval">40</span>%</div>');
	$(chromo.body+' #overlay #options #opcol #opacity .label').click(function(){
	    console.log('resetting');
	    resetOpacity();
	});
	$(chromo.body+' #overlay #options #opcol .option .op-minus').click(function(){
	    console.log('minus');
	    changeOpacity(-10);
	});
	$(chromo.body+' #overlay #options #opcol .option .op-plus').click(function(){
	    console.log('plus');
	    changeOpacity(+10);
	});

	//toggleOverlay();


    }

    chromo.defaultOpacity=60; //default opacity for overlays
    resetOpacity(); //reset opacities to default value
    

    //////////////////////////////////
    // ADDITIONAL FUNCTIONS
    //////////////////////////////////
    
    function isOverlay(key){
	//check if a layer is an overlay layer or an annotation layer
	//flase if key is 'c' or 'p', true otherwise
	if (key == 'c' || key == 'p') return false;
	return true;
    }
    //set mouse click events options

    function showOverlayInfo(infoid){
	//show info for overlay layer
	$(chromo.body+' #'+infoid).show();
	//console.log('showing info',infoid);
    }
    function hideOverlayInfo(infoid){
	$(chromo.body+' #'+infoid).hide();
	//console.log('hiding info',infoid);
    }

    function changeOpacity(dOp){
	//change the opacity of an overlay layer by dOp (in %)

	opLabel=$(chromo.body+' .opval').text();
	opVal=parseInt(opLabel)
	console.log('label value: ',opVal);
	//calculate new opacity
	newOp=Math.round(opVal+dOp);
	//limit to range {0:1}
	if (newOp <= 10){newOp=10}
	if (newOp >= 100){newOp=100}
	for (var i=0; i < chromo.annotations.length; i++){
	    if (isOverlay(chromo.annotations[i].key)) {
		//get current opacity of layer (0 if not shown)
		var currOp=Math.round(parseFloat(getOpacity($(chromo.body+" ."+chromo.annotations[i].name)))*100);
		//get stored opacity of layer
		annOp=Math.round(parseFloat(chromo.annotations[i].opacity)*100)
		console.log('current: ',chromo.annotations[i].name, annOp, currOp);
		//change opacity for all overlay layers
		//chromo.annotations[i].opacity=newOp;
		$(chromo.body+' .opval').text(newOp);
		if(Math.abs(currOp-annOp)<1){
		    //if overlay is shown, set opacity
		    setOpacity($(chromo.body+' .'+chromo.annotations[i].name),newOp/100);
		    chromo.annotations[i].opacity=newOp/100;
		    console.log('changing: ',chromo.annotations[i].name,currOp,'->',newOp);
		}else{
		    console.log('not shown')
		    //change anyway
		    chromo.annotations[i].opacity=newOp/100;
		};
	    };
	};
    }


    function resetOpacity(){
	//reset opacity to default 
	defOp=chromo.defaultOpacity //default opacity
	for (var i=0; i < chromo.annotations.length; i++){
	    if (isOverlay(chromo.annotations[i].key)) {
		//get stored opacity of layer
		annOp=Math.round(parseFloat(chromo.annotations[i].opacity)*100)
		//get current opacity of layer (0 if not shown)
		var currOp=Math.round(parseFloat(getOpacity($(chromo.body+" ."+chromo.annotations[i].name)))*100);
		//change text in label
		$(chromo.body+' .opval').text(defOp);
		console.log('reseting: ',chromo.annotations[i].name,currOp,'->',defOp);
		if(Math.abs(currOp-annOp)<1){
		    //if overlay is shown, set opacity
		    setOpacity($(chromo.body+' .'+chromo.annotations[i].name),defOp/100);
		    //set stored opacity
		    chromo.annotations[i].opacity=defOp/100;
		}else{
		    //change anyway
		    chromo.annotations[i].opacity=defOp/100;
		}
	    }
	}
    }

    $('#kiosk .minmax').click(function(){
	toggleOptions();
    });
    $('#kiosk #menu-title').click(function(){
	toggleOptions();
    });
    
    $('#kiosk #option-overlay').click(function(){
	toggleOverlay();
    });
    
    $('#overlay .minmax').click(function(){
	toggleOverlay();
    });
    
    function toggleOptions(force){
	if (!force) force='none'
	//console.log(force);
        if($('#kiosk .minmax').hasClass("max") || force=='min'){
	    //minimize
	    $('#kiosk .minmax').removeClass("max").addClass("min");
	    $('#kiosk').animate({
                left:'-190px',
		opacity:0.6,
            });
	    toggleOverlay('off');
        }else if($('#kiosk .minmax').hasClass("min") || force=='max'){
	    //maximize
	    $('#kiosk .minmax').removeClass("min").addClass("max");
	    $('#kiosk').animate({
                left:'-15px',
		opacity:1.0,
	    });
	    if($('#overlay .minmax').hasClass("max")) toggleOverlay('max')
	    if($('#overlay .minmax').hasClass("min")) toggleOverlay('min')
        }
    }

    function toggleOverlay(force){
	if (!force) {
	    if($('#overlay .minmax').hasClass("max")) force='min'
	    if($('#overlay .minmax').hasClass("min")) force='max'
	}
        if(force=='min'){
	    //minimize
	    $('#overlay .minmax').removeClass("max").addClass("min");
	    $('#overlay').animate({
                left:-(ovwid-$('#kiosk').width()-50)+'px',
            });
	    $('#kiosk .option .arrow-left').addClass("arrow-right").removeClass("arrow-left");
        }else if(force=='max'){
	    //maximize
	    $('#overlay .minmax').removeClass("min").addClass("max");
	    $('#overlay').animate({
                left:'-15px',
	    }); 
	    $('#kiosk .option .arrow-right').addClass("arrow-left").removeClass("arrow-right");
	}else if(force=='off'){
	    $('#overlay').animate({
                left:-(ovwid+40)+'px',
            });
	};
    }

    //toggle constellation labels on click
    $('#kiosk #options #option-const').click(function(){
        chromo.simulateKeyPress('c');
    });

    //toggle Planck labels on click
    $('#kiosk #options #option-labels').click(function(){
	chromo.simulateKeyPress('p');
    });

    //toggle coordinates on click
    $('#kiosk #options .option-coord').click(function(){
	if($('#kiosk #options .option-coord #on-off').hasClass("gal")){
	    $('#kiosk #options .option-coord #on-off').removeClass("gal").addClass("eq");
	    $('#kiosk #options .option-coord .label').html("Equatorial");
	    //console.log('clicked coord')
	    //console.log($('#kiosk #options .option-coord .label').html())
	    chromo.switchCoordinateSystem('A')
	}else if($('#kiosk #options .option-coord #on-off').hasClass("eq")){
	    $('#kiosk #options .option-coord #on-off').removeClass("eq").addClass("gal");
	    $('#kiosk #options .option-coord .label').html("Galactic");
	    chromo.switchCoordinateSystem('G')
	}
    });

    //*********************************************
    /*  PLANCK RESULTS (CURRENTLY UNAVAILABLE)  */
    //*********************************************

    //toggle Planck results on click (CURRENTLY UNABAILABLE)
    $('#kiosk #options .option-kml').click(function(){
	toggleResults();
    });

    //toggle Planck results on click (CURRENTLY UNAVAILABLE)
    function toggleResults(){
        if($('#kiosk #options .option-kml #on-off').hasClass('off')){
	    kmlUrl='kml_files/results.kml';
	    removePins();
	    chromo.readKML(kmlUrl);
	    $('#kiosk #options .option-kml #on-off').removeClass("off").addClass("on");
        }else if($('#kiosk #options .option-kml #on-off').hasClass('on')){
	    kmlUrl='';
	    removePins();
	    chromo.readKML(kmlUrl);
	    $('#kiosk #options .option-kml #on-off').removeClass("on").addClass("off");
        }
    }
    
    //set 'r' key to toggle Planck results
    chromo.registerKey('r',function(){
	//alert('r')
	toggleResults();
    },'toggle Planck results')

    //remove pins from Chromo.
    function removePins(){
        //for(var i = 0; i <= chromo.pins.length;i++){
        //    chromo.removePin(i);
        //}
        //$('#body-holder-kml').remove();
	$('.pinholder').html("");
	chromo.kmls=[];
	chromo.pins=[];
    }
    
    $(".pin").live('click',function(){
	$(".moreinfo").fancybox({
		'width'			: 1000,
		'height'		: 600,
		'autoScale'		: false,
       		'transitionIn'		: 'fade',
       		'transitionOut'		: 'fade',
       		'type'			: 'iframe',
		'autoDimensions'	: 'false'	
       	});
	//$("#moreinfo").trigger('click');
	return false;
    });

    //Set up fancybox stuff


//});
}
