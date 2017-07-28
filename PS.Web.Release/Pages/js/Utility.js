/**
 * FileName: Utility.js
 * Author: Gary Fu
 * Create: June 27, 2008
 * Web utility 
 */


String.prototype.rTrim=rTrim;
String.prototype.lTrim=lTrim;
String.prototype.trim=trim;
 

function rTrim() {
    var orgStr= this.toString();
    var str=orgStr;
    while( str.length >0) {
        if (str.charAt(str.length-1) != ' '){
            break;
        }
        str=str.substring(0, str.length-1) ;
    }
    return str ;
};
 

function lTrim() {
    var orgStr= this.toString();
    var str=orgStr;
    while (str.length>0){
        if (str.charAt(0) != ' '){
            break;
        }
        str=str.substring(1, str.length) ;
    }
    return str;
};
 

function trim() {
    var orgStr= this.toString();
    var str=orgStr;
    return str=(str.lTrim()).rTrim();
};

function replaceCharacters(conversionString,inChar,outChar) {
  var convertedString = conversionString.split(inChar);
  convertedString = convertedString.join(outChar);
  return convertedString;
}


function isInteger(input) {
	return (/(^-?\d+$)/).test(input);
};

function isNumeric(input) {
	return (/(^-?\d\d*[\.|,]\d*$)|(^-?\d\d*$)|(^-?[\.|,]\d\d*$)/).test(input);
};

function isDate(input) {
	var r =  input.match(/^(\d{1,4})(-|\/)(\d{1,2})\2(\d{1,2})$/);    
    if(r == null)
		return false;
		
	var d = new Date(r[1], r[3]-1, r[4]);   
    return(d.getFullYear()==r[1]&&(d.getMonth()+1)==r[3]&&d.getDate()==r[4]); 
};

function isEmail(input) {
    //return((/^[a-zA-Z]+([\.-]?[a-zA-Z]+)*@[a-zA-Z]+([\.-]?[a-zA-Z]+)*(\.\w{2,5})+$/).test(input));
    return((/^[a-zA-Z0-9]+([\.-]?[a-zA-Z0-9]+)*@[a-zA-Z0-9]+([\.-]?[a-zA-Z0-9]+)*(\.\w{2,5})+$/).test(input));
    //return (/^w+([-+.]w+)*@w+([-.]w+)*.w+([-.]w+)*).test(input);
};

function isCharacter(input) {
    return ((/^\w*$/).test(input));
};

var isFile = function(input, extend) {
	if(!input) return false;
	if(typeof input != 'string') return false;
	var lastDotIndex = input.lastIndexOf('.');
	if(lastDotIndex < 0) return false;
	var ext = input.substring(lastDotIndex+1).toUpperCase();
	if(typeof extend == 'string')
	  return ext == extend.toUpperCase();
	for(var i=0; i<extend.length; i++) {
	  if(ext == extend[i].toUpperCase())
	    return true;
	}
	return false;
};

function getSelectText(selectEl) {
    var returnString = "";
        
    for(var i=0; i<selectEl.options.length; i++)
    {
        if(selectEl.options[i].selected) {
            if(i>0)
                returnString += ",";
            returnString += selectEl.options[i].text;
        }
    }

    return returnString;
};

function setSelectedByValue(selectEl, valString) {
    var find = false;
    for(var i=0; i<selectEl.options.length; i++) {
        if(selectEl.options[i].value == valString) {
            selectEl.options.selectedIndex = i;
            find = true;
            break;
        }
    }
    if(!find) {
        selectEl.options.add(new Option(valString,valString));
        selectEl.options.selectedIndex = selectEl.options.length-1;
    }
};

var _TEMP_CONTAINER = null;
function removeTag(input) {
  if(_TEMP_CONTAINER == null)
    _TEMP_CONTAINER = document.createElement('DIV');
  _TEMP_CONTAINER.innerHTML = input;
  try {
    var result;
    if(document.all)
      result = _TEMP_CONTAINER.innerText;
    else
      result = _TEMP_CONTAINER.contentText;
    return result.trim();
  } catch(e){
    return input;
  } 
}

function ajaxRequest(url) {
    var xmlhttp;
    if (window.XMLHttpRequest) {
        xmlhttp = new XMLHttpRequest();
        xmlhttp.open("GET",url,false);
        xmlhttp.send(null);
    }
    else if (window.ActiveXObject) {
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP")
        if (xmlhttp) {
            xmlhttp.open("GET",url,false);
            xmlhttp.send();
        }
    }
    if(xmlhttp.readyState==4) {
        if(xmlhttp.status==200) {
            return xmlhttp.responseText;
        }
    }
    return xmlhttp.statusText;
};

var __popUpWin=0;
function popUpDialog(url, opener, width, height, scroll, resizable) {
    if(width == null)
      width = screen.width - 20;
    if(height == null)
      height = screen.height - 50;
    if(scroll == null)
		  scroll = 'auto';
	  if(resizable == null)
		  resizable = 'no';
	  if(isNumeric(width))
		  width += 'px';
	  if(isNumeric(height))
		  height += 'px;'
  if(document.all) {
	  var sFeatures='dialogHeight:'+height+';dialogWidth:'+width+';resizable:'+resizable+';center:yes;status:no;'+
		  'help:no;scroll:'+scroll;
	  try{return window.showModalDialog(url,opener,sFeatures);}catch(e){return false;}
	} else {
	  if(__popUpWin) {
      if(!__popUpWin.closed) __popUpWin.close();
    }
    var left = 20;
    var top = 20;
    __popUpWin = open(url, '__popUpWin', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars='+scroll+',resizable='+resizable+',copyhistory=yes,width='+width+',height='+height+',left='+left+', top='+top+',screenX='+left+',screenY='+top+'');
	}
};

function openChoose(caller, rootPath, type, dependELid) {
  var width = 250;
  var height = 450;
  var hideDisabled = false;
  switch(type.toUpperCase()) {
    case 'DEPARTMENT' :
      if(dependELid) { 
        var el = document.getElementById(dependELid);
        if(el.value == '') {
          alert('Segment must choose first.');
          break;
        }
      }
      hideDisabled = false;
      if(3 in caller){
        hideDisabled = caller[3];
      }
      popUpDialog(rootPath+'Common/Select_Department.aspx?hd='+hideDisabled+'&s='+(el.value)+'&ran='+escape(new Date()), caller, width, height, 'no', 'no');
    break;
	
	case 'PROJECT' :
		if(dependELid) {
        var el = document.getElementById(dependELid);
        if(el.value == '') {
          alert('Segment must choose first.');
          break;
        }
      }
      popUpDialog(rootPath+'Common/Select_Project.aspx?s='+(el.value)+'&ran='+escape(new Date()), caller, width, height, 'no', 'no');
    break;
    
    default:
      hideDisabled = false;
      if(2 in caller){
        hideDisabled = caller[2];
      }
      popUpDialog(rootPath+'Common/Select_Segment.aspx?hd='+hideDisabled+'&ran='+escape(new Date()), caller, width, height, 'no','no');
    break;
  }
};



var popUpWin=0;
function openWin(URLStr, width, height, left, top)
{
  if(popUpWin)
  {
    if(!popUpWin.closed) popUpWin.close();
  }
  if(!left)
    left = (screen.width-width) / 2;
  if(!top)
    top = (screen.height-height) / 2;
  popUpWin = open(URLStr, 'popUpWin', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no,copyhistory=yes,width='+width+',height='+height+',left='+left+', top='+top+',screenX='+left+',screenY='+top+'');
}


function get_hex_color (r, g, b) { var hexstring = "0123456789abcdef"; var hex_color = hexstring . charAt (Math . floor (r / 16)) + hexstring . charAt (r % 16) + hexstring . charAt (Math . floor (g / 16)) + hexstring . charAt (g % 16) + hexstring . charAt (Math . floor (b / 16)) + hexstring . charAt (b % 16); return hex_color; }
function brighten_red (element) { 
  red += inc; 
  if (red >= 256) { 
    //setTimeout ("brighten_green ();", delay, element); 
    setTimeout(function(){brighten_green(element)}, delay);
    return; 
  } 
  element.style.backgroundColor = get_hex_color (red, 0, 0); 
  //setTimeout ("brighten_red ();", delay); 
  setTimeout(function(){brighten_red(element)}, delay);
} red = 0;

function brighten_green (element) { 
  green += inc;
  if (green >= 256) { 
    //setTimeout ("brighten_blue ();", delay, element); 
    setTimeout(function(){brighten_blue(element)}, delay);
    return; 
  } 
  element.style.backgroundColor = get_hex_color (255, green, 0); 
  //setTimeout ("brighten_green ();", delay, element); 
  setTimeout(function(){brighten_green(element)}, delay);
} green = 0;
 
function brighten_blue (element) { 
  blue += inc; 
  if (blue >= 256) { 
    element.style.backgroundColor = ''; 
    return; 
  } 
  element.style.backgroundColor = get_hex_color (255, 255, blue); 
  //setTimeout ("brighten_blue ();", delay, element); 
  setTimeout(function(){brighten_blue(element)}, delay);
} blue = 0;

function fade(element) {
  red=green=blue=0;
  inc = 8; delay = 15;
  brighten_green (element);
  //alert(element.attributes.style = null);
}


function requiredFieldValidate(elementIDArrs) {
  var element;
  for(var i=0; i<elementIDArrs.length; i++){
    element = document.getElementById(elementIDArrs[i]);
    if(element) {
      if(element.disabled)
        continue;
      if(element.value.trim() == ''){
        if(!document.all){alert('Required field must NOT be left blank.');}
        fade(element);
        try{element.select();element.focus();}catch(e){}
        return false;
      }
    }
  }
  return true;
}

// Segment & Department
function _openChooseWindow(param, virtualPath, type, clearType) {
  var currentEL = document.getElementById(param[1]+'_hidden');
  var oVal = currentEL.value;
  openChoose(param, virtualPath, type);
  var nwVal = currentEL.value;
  if(oVal != nwVal)
    clearDP(clearType, param[1]);
}
function clearDP(type, segmentELID) {try{
  var deptELID1 = segmentELID.replace('Segment', 'Department');
  var deptELID2 = deptELID1 + '_hidden';
	switch(type.toUpperCase()) {
	  case 'MAIN' :
	    document.getElementById(deptELID1).value =
				document.getElementById(deptELID2).value = '';
	  break;

	} } catch(e) {confirm(e);}
}



function initSelectElements() {
	var selELs = document.getElementsByTagName('SELECT');
	for(var i=0; i<selELs.length; i++) {
		el = selELs[i];
		if(!el.disabled) {
		  var options = el.options;
		  for(var j=0; j<options.length; j++){
		    options[j].title = options[j].text;
		  }
		}
	}
}
function _selOnMouseOver(el, ElCopy) {
	//var offsetWidth = el.offsetWidth;
	//var scrollWidth = el.scrollWidth;
	//var sw = offsetWidth - el.clientWidth;
	var oWidth = 0;
	if( ElCopy.style.width != '' ) {
		oWidth = parseInt(ElCopy.style.width);
	}
	//if(offsetWidth < scrollWidth + sw) {
		if(el.parentElement.tagName.toUpperCase() != 'BODY'){ 
			el.parentElement.appendChild(ElCopy);
		} 
		//el.style.width = scrollWidth + sw + 'px';
		el.style.width = '';
		el.style.className = '';
		if(el.offsetWidth < oWidth) 
			el.style.width = oWidth + 'px';
		el.style.position = 'absolute';
		el.onblur = function(){_selOnMouseOut(this, ElCopy);};
	//}
}
function _selOnMouseOut(el, ElCopy) {
	el.style.position = '';
	el.className = ElCopy.className;
	el.style.width = ElCopy.style.width;
	if(ElCopy.parentElement){
 		ElCopy.parentElement.removeChild(ElCopy);
	}
}