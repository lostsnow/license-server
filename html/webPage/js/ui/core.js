var g_url
var logtimer1,logtimer2;
var grid_fieldnames=[];
var grid_fieldcaptions=[];
var grid_disabledfields=[];
var tblName='';

options={pagerId:"pages", tblId:"tbl", showSelect: true, canSelectRow:false,showStyle:false,
	canEdit: true,
	canAdd: true,
	canDelete: true,
	canSearch: true, keyFieldIndex:"0", title:'',
	tblHeader:'',
	dlg_width:500,
	dlg_height:'auto',
	edit_col:1
};
var lang = {
		Pane:		"Pane"
	,	Open:		gettext("Open")	// eg: "Open Pane"
	,	Close:		gettext("Close")
	,	Resize:		gettext("Resize")
	,	Slide:		gettext("Slide Open")
	,	Pin:		"Pin"
	,	Unpin:		gettext("")
	,	selector:	"selector"
	,	msgNoRoom:	"Not enough room to show this pane."
	,	errContainerMissing:	"UI.Layout Initialization Error\n\nThe specified layout-container does not exist."
	,	errContainerHeight:		"UI.Layout Initialization Error\n\nThe layout-container \"CONTAINER\" has no height!"
	,	errButton:				"Error Adding Button \n\nInvalid "
	};

var layoutSettings_Outer = {
	name: "outerLayout" // NO FUNCTIONAL USE, but could be used by custom code to 'identify' a layout
	// options.defaults apply to ALL PANES - but overridden by pane-specific settings
,	defaults: {
		size:					"auto"
	,	applyDemoStyles: 		false		// NOTE: renamed from applyDefaultStyles for clarity
	,	minSize:				0
	,	paneClass:			"ui-layout-pane" 		// default = 'ui-layout-pane'
	,	resizerClass:			"ui-layout-resizer"	// default = 'ui-layout-resizer'
	,	togglerClass:			"ui-layout-toggler"	// default = 'ui-layout-toggler'
	,	buttonClass:			"button"	// default = 'ui-layout-button'
	,	contentSelector:		".ui-layout-content"	// inner div to auto-size so only it scrolls, not the entire pane!
	,	contentIgnoreSelector:	"span"		// 'paneSelector' for content to 'ignore' when measuring room for content
	,	togglerLength_open:		0			// WIDTH of toggler on north/south edges - HEIGHT on east/west edges
	,	togglerLength_closed:	0			// "100%" OR -1 = full height
	,	hideTogglerOnSlide:		true		// hide the toggler when pane is 'slid open'
	,	togglerTip_open:		gettext("Close")//lang.Close//"收起面板"
	,	togglerTip_closed:		gettext("Open")//lang.Open//"展开面板"
	,	resizerTip:				"Resize"//lang.Resize//"拖动面板"
	,	sliderTip:				"Slide Open"//lang.Slide//"展开面板"
	//	effect defaults - overridden on some panes
	,	fxName:					"slide"		// none, slide, drop, scale
	,	fxSpeed_open:			0
	,	fxSpeed_close:			0
	,	fxSettings_open:		{easing: "easeInQuint"}
	,	fxSettings_close:		{easing: "easeOutQuint"}
	,	onresize:			function () {  }
}

,	north: {
	    minSize:				0
	,   maxSize:                0
	,	spacing_open:			0			// cosmetic spacing
	,	togglerLength_open:		0			// HIDE the toggler button
	,	togglerLength_closed:	-1			// "100%" OR -1 = full width of pane
	,	resizable: 				false
	,	slidable:				false
	//	override default effect
	,	fxName:					"none"
	}
,	south: {
	    minSize:				28
	,   maxSize:                28
	,	spacing_closed:			0			// HIDE resizer & toggler when 'closed'
	,	resizable: 				false
	,	slidable:				false		// REFERENCE - cannot slide if spacing_closed = 0
	,	initClosed:				false
	}
,	west: {
		size:					200
	,	minSize:200
	,	spacing_open:           5
	,	spacing_closed:			21			// wider space when closed
	,	togglerLength_closed:	21			// make toggler 'square' - 21x21
	,	togglerAlign_closed:	"top"		// align to top of resizer
	,	togglerLength_open:		0			// NONE - using custom togglers INSIDE west-pane
//	,	togglerTip_open:		"收起主菜单"
//	,	togglerTip_closed:		"展开主菜单"
//	,	resizerTip_open:		"拖动面板"
	,	slideTrigger_open:		"click" 	// default
	,	resizable: 				true
	,	slidable:				false		// REFERENCE - cannot slide if spacing_closed = 0
	,	initClosed:				false
	,	onclose_end:			function () { menuClick(g_url); }
	,	onopen_end:			function () { menuClick(g_url); }

	//	add 'bounce' option to default 'slide' effect
	,	fxSettings_open:		{easing: "easeOutBounce"}
	}
,	east: {
		size:					"auto"
	,	resizable: 				true
	,	spacing_closed:			21			// wider space when closed
	,	togglerLength_closed:	21			// make toggler 'square' - 21x21
	,	togglerAlign_closed:	"top"		// align to top of resizer
	,	togglerLength_open:		0 			// NONE - using custom togglers INSIDE east-pane
//	,	togglerTip_open:		"关起工具箱"
//	,	togglerTip_closed:		"打开工具箱"
//	,	resizerTip_open:		"拖动面板"
	,	slideTrigger_open:		"click"
	,	initClosed:				true
	//	override default effect, speed, and settings
	,	fxName:					"drop"
	,	fxSpeed:				"normal"
	,	fxSettings:				{easing: ""} // nullify default easing
	}
,	center: {
		minWidth:				200
	,	minHeight:				200
	}
};


jq_Options={
   	url:'',
	mtype:"POST",
	postData:{},
	datatype: "json",
	colModel:[],
	autowidth: true,
	shrinkToFit:false,
   	rowNum:30,
	rownumber:true,
	multiselect:true,
   	rowList:[50,100],
   	pager: '#id_pager',
   	sortname: '',
	viewrecords: true,
	multiboxonly:true,
	sortorder: "asc",
	jsonReader: {repeatitems : false},
	height:300,
	gridComplete: function(){
			preprocessEdit();
		}
	};
timepickerOptions={
	inline: true,
	buttonImage: '/media/img/icon_clock.gif',
	buttonText:gettext("Time"),
	buttonImageOnly: true,		
	showOn:'button',//在输入框旁边显示按钮触发，默认为：focus。还可以设置为both  
	showButtonPanel: true,  
	autoSize:false
//	hourText:gettext('Hour'),
//	minuteText:gettext('Minute'),
//	timeText:gettext('Time'),
//	timeOnlyTitle:gettext('Choose Time'),
//	currentText:gettext('Now')
	};
datepickerOptions={
	dateFormat:'yy-mm-dd',
	inline: true,
	changeMonth: true,
	buttonImage: '/media/img/calendar.gif',
//	buttonText:gettext("Calendars"),
	buttonImageOnly: true,		
	showOn:'button',//在输入框旁边显示按钮触发，默认为：focus。还可以设置为both  
	showButtonPanel: true,  
	autoSize:false
//	showTimepicker:false
	};


datetimepickerOptions={
	dateFormat:'yy-mm-dd',
	inline: true,
	changeMonth: true,
	buttonImage: '/media/img/calendar.gif',
	//buttonText:gettext("Calendars"),
	buttonImageOnly: true,		
	showOn:'button',//在输入框旁边显示按钮触发，默认为：focus。还可以设置为both  
	showButtonPanel: true,  
	autoSize:false,
	timeOnly: false
//	hourText:gettext('Hour'),
//	minuteText:gettext('Minute'),
//	timeText:gettext('Time'),
//	timeOnlyTitle:gettext('Choose Time'),
//	currentText:gettext('Now')
	}

//copy jq_Options对象,
function copyObj(obj){
   var jp=new Object()
   for(p in obj){
      jp[p]=obj[p]
   }
  return jp;
}


function initwindow()
{
	var outerLayout = $("body").layout(layoutSettings_Outer);

	var westSelector = ".ui-layout-west";

	$("<span></span>").addClass("pin-button").prependTo(westSelector);
	outerLayout.addPinBtn(westSelector +" .pin-button", "west");

	$("<span></span>").attr("id", "west-closer").prependTo(westSelector);
	outerLayout.addCloseBtn("#west-closer", "west");
	if ( $.browser.msie && parseInt($.browser.version) <= 6 ) 
	{
		$(".ui-layout-content").css("position","static")
		$(".nav li").sfHover();
	}
}


function menuClick(url,obj)
{
	if (typeof url=='undefined'||url=='')return;
	if (typeof logtimer1!='undefined')
		clearTimeout(logtimer1);
	if (typeof logtimer2!='undefined')
		clearTimeout(logtimer2);
	savecookie("search_urlstr",url);
	g_url=url;
	if (typeof(obj) != 'undefined'){
		$("#menu_div li").each(function(){
			$(this).css('background',"")
			$(this).find("a").css('border','1px solid #ffffff')
		})
		$(obj).css('background',"transparent url('../media/img/new_top_back.png') repeat-x bottom right")
		$(obj).find("a").css('border','1px solid #7bc4ff')
	}
	if(url=="/iclock/iacc/Map_Monitor/"){
		window.open("/iclock/iacc/Map_Monitor/","","fullscreen=yes");//"","height=800, width=1000, top=0, left=0, toolbar=no,menubar=no, scrollbars=no, resizable=no,location=no, status=no"
		return false;	
	}
//	if(url=="/iclock/iacc/RealMonitorIaccess/"){//门禁记录监控
//		window.open("/iclock/iacc/RealMonitorIaccess/","","fullscreen=yes");//"","height=800, width=1000, top=0, left=0, toolbar=no,menubar=no, scrollbars=no, resizable=no,location=no, status=no"
//		return false;	
//	}
	
	if(url.indexOf("?")!=-1){
		urll=url+"&stamp="+new Date().toUTCString();
	}
	else{
		urll=url+"?stamp="+new Date().toUTCString();
	}

        $.ajax({
            type: "GET",
            url:urll,
            data:'',
            dataType:"text",
            success:function(data){
		$('#id_content').empty()
		$('#id_content').html(data);
            },
            error:function(){
		alert("Server error")
            }
        });





}
/*
function ajaxPost(dataStr,urlAddr,dataType)
{
	dataType=typeof(dataType) == 'undefined' ? 'html' : dataType;
	var ret=''
	$.ajax({
			type:"POST",
			url:urlAddr,
			dataType:dataType,
			data:dataStr,
			success:function(msgback){
				alert(msgback);		
				ret=msgback;		
				}
			});	
	return ret;			
}
*/
function preprocessEdit()
{
	if (typeof canEdit=="function")
		canEdit()
}

function get_grid_fields(jqOptions)
{
			grid_fieldnames=[];
			grid_fieldcaptions=[];
			for (var i=0;i<jqOptions.colModel.length;i++)
			{
				if ((typeof jqOptions.colModel[i].label=='undefined') || ((jqOptions.colModel[i].hidden!='undefined')&&(jqOptions.colModel[i].hidden)))
					continue;

				grid_fieldnames.push(jqOptions.colModel[i].name);
				grid_fieldcaptions.push(jqOptions.colModel[i].label);
			}	
}

function ShowCustomField()
{
			var block_html="<div>"
				+		'<form id="id_form"><table>'
				+	createFieldsChk()
				+ 	"</table></form>"
				+"</div>"
				$("#id_fields_selected").html(block_html);
				showSelected_Fields();
				if(typeof canDefine!='undefined'&&!canDefine)
					$('#btn_DefineField').attr('disabled','true')
				showFields ()


		$("#btn_DefineField").click(function(){
			var sFields=getunSelected_Fields();
			var queryStr="tblName="+tblName+"&Fields="+sFields
			
			$.post("/iclock/att/saveFields/", 
				queryStr,
				function (ret, textStatus) {
					if(ret.ret==0)
					{
						hideFields_define();
						menuClick(g_url);	
					}
				},
				"json");

		});


}

function createFieldsChk(){
	//get_grid_fields()
	var html="<tr><td>"
		   +"<div id='select_div'>"
		   +"<input type='checkbox' id='is_select_all_Field'  onclick='check_all_for_row_Fields(this.checked);' />"
		   +gettext('Selected:')+" <span id='selected_count_Fields'>0</span>)"
	   +"</td></tr>";
		for(var i=0;i<grid_fieldnames.length;i++)
			{
				if(isDisabled(grid_fieldnames[i]))
					html+="<tr><td><input type='checkbox'  alt='"+grid_fieldnames[i]+"' class='class_select_Fields' onclick='showSelected_Fields();'/>"+grid_fieldcaptions[i]+"</td></tr>"
				else if(grid_fieldnames[i]=='PIN' ||grid_fieldnames[i]=='EName'||i==0 )
					html+="<tr><td><input type='checkbox' checked  disabled/>"+grid_fieldcaptions[i]+"</td></tr>"
				else
					html+="<tr><td><input type='checkbox'  alt='"+grid_fieldnames[i]+"' class='class_select_Fields' onclick='showSelected_Fields();' checked/>"+grid_fieldcaptions[i]+"</td></tr>"
			}
		return html;
}
function isDisabled(fieldname){
	for(var i=0;i<grid_disabledfields.length;i++)
	   if(grid_disabledfields[i]==fieldname)
			   return 1;
	return 0;	
}
function hiddenfields(jqOptions)
{
	for(var i=0;i<jqOptions.colModel.length;i++)
	{
		if(isDisabled(jqOptions.colModel[i].name)){
			jqOptions.colModel[i].hidden=true;
		}
	}
}
function showFields () {
	var top =  $(".customlink").position().top;
	var left = $(".customlink").position().left;
	
	$("#show_field_selected").css({position: 'absolute',display:"block",top: top+24,left: left});
}

function hideFields_define(){
	$("#id_fields_selected").html("");
	$("#show_field_selected").css("display","none").css("top", -1600).css("left",  -1600);
}
function showSelected_Fields() {
    var c = 0;
    $.each($(".class_select_Fields"),function(){
			if(this.checked) c+=1;})
    $("#selected_count_Fields").html("" + c);
}
function showSelected_Fields() {
    var c = 0;
    $.each($(".class_select_Fields"),function(){
			if(this.checked) c+=1;})
    $("#selected_count_Fields").html("" + c);
}
function check_all_for_row_Fields(checked) {

    if (checked) {
        $(".class_select_Fields").attr("checked", "true");
    } else {
        $(".class_select_Fields").removeAttr("checked");
    }
    showSelected_Fields();
}
function getunSelected_Fields()
{
	var sFields=[]
	$.each($(".class_select_Fields"),function(){
		   if(!this.checked) 
			   sFields.push(this.alt)
   });
   return sFields;
}

function formToRequestString(form_obj)
 {
      var query_string='';
      var and='';
      for (var i=0;i<form_obj.length ;i++ )
      {
          e=form_obj[i];
          if (e.name) {
              if (e.type=='select-one') {
                  element_value=e.options[e.selectedIndex].value;
              } else if (e.type=='select-multiple') {
                  for (var n=0;n<e.length;n++) {
                      var op=e.options[n];
                      if (op.selected) {
                          query_string+=and+e.name+'='+encodeURIComponent(op.value);
                          and="&"
                      }
                  }
                  continue;
              } else if (e.type=='checkbox' || e.type=='radio') {
                  if (e.checked==false) {   
                      continue;   
                  }   
                  element_value=e.value;
              } else if (typeof e.value != 'undefined') {
                  element_value=e.value;
              } else {
                  continue;
              }
              query_string+=and+e.name+'='+encodeURIComponent(element_value);
              and="&"
          }
      }
      return query_string;
 }
function showsubmenu(widgetId)
{
	var submenu=$('#'+widgetId);
	 if(submenu.css('display') != 'none')
	{
		submenu.css('display',"none")
	}
	else
		submenu.css('display',"block")



}

function savecookie(name,value,expires){
	if (typeof expires == 'undefined')
		expires=30;
	return $.cookie(name,value, { expires:expires });
	//$.cookie("search_urlstr",url, { expires: 7 });
}

function loadcookie(name)
{
	return $.cookie(name);
}



function clickexport(disabledfields,att){
	var urlstr=$.cookie("search_urlstr");
	if(urlstr.indexOf("/data/")!=-1){
		urlstr=urlstr.replace("/data/","/export/");
	}else if(urlstr.indexOf("/att/")!=-1){
		urlstr=urlstr.replace("/att/","/export/")
	}else if(urlstr.indexOf("/iacc/")!=-1){
		urlstr=urlstr.replace("/iacc/","/export/")
	}
	disabled=disabledfields.join(',') 
	var sqlstr={'page':1,'rows':100000000,'disabledfields':disabled}
	$.blockUI({title:'',theme: true ,baseZ:10000,message: '<h1><img src="/media/img/loading.gif" /> <br>'+gettext('Please wait...')+'</br></h1>'});
	if(urlstr.indexOf("ihrreports")!=-1){
		var ComeTime=$("#id_ComeTime").val();
		uid=$.cookie("reminditem");
		var sqlstr={'page':1,'rows':100000000,'disabledfields':disabled,'cometime':ComeTime,'uid':uid}
	}
	$.ajax({ 
			type: "POST",
			url:urlstr,
			data:sqlstr,
			success:function(json){
			 window.location.href=json;
			$.unblockUI()
			}
	});
}

function stripHtml(h_data)
{
	return $.jgrid.stripHtml(h_data)
}
function saveHome()
{
	$.post("/iclock/att/saveHome/", 
		{url:g_url},
		function (ret, textStatus) {
			if(ret.ret==0)
			{
				//var i=ret.indexOf("message=\"");
				var message=ret.message;
				alert(message);

			}
		},
		"json");

}
function reloadData()
{
	$("#id_grid").trigger('reloadGrid');
}
function unescapeHTML(str) {   
  str = String(str).replace(/&gt;/g, '>').replace(/&lt;/g, '<').replace(/&quot;/g, '"').replace(/&amp;/g, '&');   
  return str;   
}   

