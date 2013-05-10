
/*----------init------------*/
var currentP = 1;
var ajaxStatus = {};
var gradientCss = '';
var cmdsTimer = null;
var cmdRtnTimer = null;
var lineStatus = null;


$(document).ready(function(){
	$( '#leftM li a' ).click( function( ){
		var content = $(this).html();
		$( ".active" ).removeClass( "active" );
		$( this ).parents('li').addClass( "active" );
		var name = $( this ).attr( "name" )
		if( typeof name != "undefined" ){
			content = content.toLowerCase();
			$( '#curP' ).html( content.substring( content.indexOf('</i>'), content.length ) );
			loadData( name + ".html", function( msg ){ $('#content').html( msg ); } );
		}	
	});

	/*
	$( '#tabHead li a' ).live( "click" , function(){
		var name = $(this).attr('name');
		var content = $( this ).html();
		if( typeof name != "undefined" ){
			content = content.toLowerCase();
			$( '#curP' ).html( content.substring( content.indexOf('</i>'), content.length ) );
			loadData( name + ".html", function( msg ){ $('#content').html( msg ); } );
		}
	} );
	*/

	$('#checkall').live( "click" , function(){
		$( '.selection' ).each( function(){
			if( $(this).attr( "checked" ) != "checked" ){
				$(this).attr( 'checked', 'checked' );
			}
		} );
	} );

	$('#checkinverse').live( "click" , function(){
		$( '.selection' ).each( function(){
			if( $(this).attr( "checked" ) != "checked" ){
				$(this).attr( 'checked', true );
			}else{
				$(this).attr( 'checked', false );
			}
		} );
	} );

	index();

	$.ajaxSetup({	
		statusCode: {
			404: function(){
				dialogMsg="没有该请求，请重试！";
				newDialog( { title : '警告', content : dialogMsg, bodyClass : 'alter alert-error'} );
			},
			500: function(){
				dialogMsg="后台程序错误！";
				newDialog( { title : '警告', content : dialogMsg, bodyClass : 'alter alert-error'} );
			},
			403: rLogin
		}
	});
});


/*------tool------*/

function cleanPage(){
//$($($('.popover-inner')[0]).parent("div")[0]).attr("style","top: 278px; left: 1035.75px; display: none;")
	$('.popover-inner').each(function(){
		$($( this ).parent( "div" )[0]).attr("style","top: 278px; left: 1035.75px; display: none;");
	})



	
}


function rLogin(){
	var dialogMsg="会话已超时，请重新登录！";
	newDialog( {
		title : '警告',
		content : dialogMsg,
		button : [ { name : '关闭', sign : 'close', id: 'editB' } , { name : '确定', fname : 'toExit()' } ],
		bodyClass : 'alter alert-error'
	} );
}

function toExit(){
	window.location.href='/webPage/login.html';
}

function get_cookie( name ) {
	if( document.cookie == '' ){
		rLogin();
		return
	}
	var cookies = document.cookie.split( ';' );
	var key = '';
	var val = '';
	for ( i = 0; i < cookies.length; i++ ){
		var temp = cookies[ i ].split( '=' );
		if ( temp[ 0 ] == name || temp[ 0 ] == ' ' + name ){
			return temp[ 1 ];
		}
	}
	return null;
}

function changePwd(){
	var obj = { pwd_old : { placeholder : '请输入旧密码', name : '旧密码', type : 'password' },
	pwd : { placeholder :'请输入新密码最少6位', name : '新密码', type : 'password' },
	pwd_again : { placeholder :'请重复输入新密码', name : '新密码确定', type : 'password' }};
	var text = convert( obj, 1, '88px', null, '30px', null, 'form');
	var b = newDialog( {
		title : "修改系统参数",
		content : text,
		bodyClass : 'alert alert-warning',
		id : 'edit',
		action : '/manage/changePwd?name='+( get_cookie('user') || ''),
		method : 'post',
		button : [ { name : '关闭', sign : 'close', id: 'editB' } ,
				   { name : '确定', type : 1, fn : function(msg){
						//newDialog( { title : '提示', content : '请勾选要删除的设备！', bodyClass : 'alert alert-warning' } );
						}
					}
			     ]
	} );
}

function exit_sys(){
	var b = newDialog( {
		title : "退出",
		content : "你确定要退出吗?",
		bodyClass : 'alert alert-warning',
		id : 'edit',
		action : '/exit/',
		method : 'get',
		button : [ { name : '关闭', sign : 'close', id: 'editB' } ,
				   { name : '确定', type : 1, fn : function(msg){
					   //newDialog( { title : '提示', content : '请勾选要删除的设备！', bodyClass : 'alert alert-warning' } );
							window.location.href='/webPage/login.html';
					}
				 } ]
	} );
}

function getParam(){
	loadData( '/iclock/sdk/param', function( msg ){
		try{
			var objs=eval(msg);
		}catch(e){
			eval("var objs=" + msg);
		}
		var text = convert( objs, 1, '18px', null, '30px', null, 'form');
		var b = newDialog( {
			button : [ { name : '关闭', sign : 'close', id: 'editB' } , { name : '确定', type : 1, fn : function(msg){
				//newDialog( { title : '提示', content : '修改成功！', bodyClass : 'alert alert-warning' } );
			} } ],
			title : "修改系统参数",
			content : text,
			bodyClass : 'alert alert-warning',
			id : 'edit',
			action : '/iclock/sdk/param',
			method : 'post'
		} );
	});
}

function doService( act ){
	loadData( '/manage/service?action=' + act, function( msg ){
		try{
			var objs=eval(msg);
		}catch(e){
			eval("var objs="+msg);
		}
		var result = ( objs.rst==0 ? '操作成功' : objs.msg );
		newDialog( { title : '提示', content : result, bodyClass : 'alert alert-success' } );
	} );
}

function service( id ){
	var objs = [ { act : 'stop', msg : 'ADMS的服务停止后，ADMS将无法使用，可能需要您手动启动，您确定要停止？', title : '停止服务' },
				{ act : 'restart', msg : '您确定要重新启用ADMS的服务吗？', title : '重启服务'},
				{ act : 'clean', msg : '您确定清除ADMS上错误日志、访问日志吗？', title : '清理无效数据'}];
	var obj = objs[ id ];
	newDialog( {
		button : [ { name : '关闭', sign : 'close' } , { name : '确定', fname : "doService(\'" + obj.act + "\')" }],
		title : obj.title,
		content : obj.msg,
		bodyClass : 'alert alert-warning'
	} );
}

function getStatus(){
	loadData( '/iclock/sdk/status/', function( msg ){
		try{
			var objs=eval(msg); 
		}catch(e){
		eval("var objs=" + msg);
		}
		var text = convert( objs, 1, '18px', null, '30px' );
		var b = newDialog({
			title : "查看系统状态",
			content : text,
			bodyClass : 'alert alert-success',
			id : 'view'
		});
	})
}

function setGradient(){
	if($.browser.msie) gradientCss = "filter: progid:DXImageTransform.Microsoft.gradient(startcolorstr=#f5f5f5,endcolorstr=#999999, gradientType=0 );";
	else if($.browser.safari) gradientCss = "background: -webkit-gradient(linear, 0 0, 0 bottom, from(#F5F5F5),to(grey) );";
	else if($.browser.mozilla) gradientCss = "background-image:-moz-linear-gradient(center top , #F5F5F5, grey);";
	else if($.browser.opera) gradientCss = "background: -o-linear-gradient(top, #F5F5F5,grey);";
}

function sysStatus(){
	$.ajax({
		url: '/iclock/sdk/status/',
		cache: false,
		dataType : 'text',
		type: 'get',
		success: function( msg ){
			var info = '';
			try{
				var objs=eval(msg);
			}catch(e){
				eval("var objs=" + msg);
			}
			if( objs && objs.ret < 0 ){
				if( objs.msg.indexOf("Softdog not found") > 0 ){
					$('#stausBar').css( {width:"650"});
					$('#warning').html('<span style="color:red;" >　请插入加密锁！</span>');	
					return 
				}else if( objs.msg.indexOf("Service has expired") > 0 ){					
					$('#stausBar').css( {width:"650"});
					$('#warning').html('<span style="color:red;" >　软件已过期，请与软件提供方联系！</span>');	
					return
				}else if( objs.msg.indexOf("Limited IP address") > 0 ){					
					$('#stausBar').css( {width:"650"});
					$('#warning').html('<span style="color:red;" >　您的IP没有使用ADMS的权利！</span>');	
					return
				}
			}else{
				$('#stausBar').css( {width:"550"});
				$('#warning').empty();
			}
			var dt = { "upload_read":"数据已读取", "upload_index":"数据已上传","device_count":"设备总数"}
			var status_rate = ( objs.upload_read - 1) / objs.upload_index * 100 ;
			var data = "数据已上传：" + objs.upload_index + '条<br>' + "数据已读取：" + ( objs.upload_read > 0 ? objs.upload_read - 1 : objs.upload_read ) + '条' ;
			var info = '<div id="showInfo" title="详细信息" data-content="' + data + '" class="progress progress-info progress-striped active" style="margin-bottom: 9px;width:120px;height:18px;' + gradientCss + '">' +
					   '<div class="bar" style="width: ' +  ( status_rate ) + '%"></div></div>';	
			$('#dev_sum').html( objs.device_count + '台' );
			//check_sum
			$('#check_sum').html( objs.check_count + '台' );
			$('#read_status').html( info );
			$("#showInfo").popover({placement:'bottom'});			
		}
	});	
	window.setTimeout( sysStatus, 1000*5 );
}

function index(){
	setGradient();
	$($("#leftM li a")[ 0 ]).trigger('click');
	$('#username').html( ( get_cookie('user') || '') );
	sysStatus();
}

function isNull( val){
	if ( val==null || typeof val =='undefined' ) return true
	return false;
}

function pageInit( pages , size , flag ){
	if( typeof( pages ) == 'undefined' || typeof( size ) == 'undefined' ){ return; }
	var html = '<span style="color:#0088CC">共' + size + '条&nbsp;</span><ul>';
	if( flag ) html = '<span style="color:#0088CC">共' + size + '批次&nbsp;</span><ul>';
	if( currentP != 1 ) html += '<li><a href="javascript:toPage(\'up\')">上一页</a></li>';
	var start = 1, end = pages, index = 1, list = {};
	if( pages > 5 ){
		mid = '......'
		if ( currentP < 3 ){
			end = 3;
		}else if( currentP != pages ){
			start = currentP - 3 + 1;
			end = currentP;
		}else if( currentP == pages ){
			start = currentP - 3;
			end = currentP -1;
		}
		for( var i = start; i <= end; i++ ){
			var c = i == currentP ? 'class="active"' : "";
			list[ index++ ] = { 'class':c, 'page':i, 'e':"javascript:toPage(" + i + ")" };
		}
		list[ index++ ] = { 'class':'', 'page':'......', 'e':"javascript:void(0);" };
		var c = pages == currentP ? 'class="active"' : "";
		list[ index++ ] = { 'class':c, 'page':pages, 'e':"javascript:toPage(" + pages + ")" };
	}else if( pages == 5 ){
		for( var i = 1; i <= 5; i++ ){
			var c = i == currentP ? 'class="active"' : "";
			list[ index++ ] = { 'class':c, 'page':i, 'e':"javascript:toPage(" + i + ")" };
		}
	}else{
		for( var i = 1; i <= pages; i++ ){
			var c = (i == currentP ? 'class="active"' : "");
			list[ index++ ] = { 'class':c, 'page':i, 'e':"javascript:toPage(" + i + ")" };
		}
	}
	
	for( var o in list ){
		var l = list[ o ];
		html += '<li ' + l['class'] + ' ><a href="' + l.e + '">' + l.page + '</a></li>';
	}
	if( currentP != pages ) html += '<li><a href="javascript:toPage(\'down\')">下一页</a></li>';
	html += '<li>去<input type="text" id="toP" style="width:15px;"/>页&nbsp;<span style="color:#0088CC; cursor:pointer;" onclick="javascript:toPage(0)" >确定</span></li>';
	html += '</ul>';
	$('#pageM').html( html );
}


function toPage( num ){
	if( num == 'up' ){
		num = --currentP;
	}else if( num == 'down' ){
		num = ++currentP;
	}else if( num==0 ) {
		num = $('#toP').val();
		if( num == '' ) num = 0;
		if( data && (num < 1 || num > data.pages ) ) {
			newDialog( { title : '提示', content : '请合理输入，员码范围：1~' + data.pages + '!', bodyClass : 'alert-danger', id : 'pageInfo' } );
			return;
		}
	}
	currentP = num ;
	doit();
}

function createFm( option ){
	var relate = [ 'select', 'textarea', 'radio', 'checkbox', 'text', 'password', 'file' ];
	var type = option.formType || "0";
	var row = '<tr><td>' + option.field || "" + '</td><td>:</td><td>';
	var action = ' ';
	if( !isNull(option.eventName) && !isNull(option.fn) ){
		action += eventName + '=' + "javascript:" + option.fn + "();"
	}
	if( type = '0' ){//select
		var values = '';
		for( var v in option.opt ) values += '<option value="' + option.opt[v] + '">' + v + '</option>';
		row += '<div class="controls"><select id="' + ( option.id || '' ) + '"' + action + '>' + values + '</select>';
	}else if( type == '1' ){//textarea
		row += '<textarea name="' + option.name || '' + '" id="' + option.id || '' + '" cols="' + option.param.cols || '45' +
			   '" rows="' + option.param.rows || '5' + '"' + action + '>' + option['default'] || ''+ '</textarea>';
	}else if( type == '2' || type == '3' ){//radio
		for( var i in option.opt ){
			var op = option.opt[i];
			row += '<input type="' + relate[ type ] + '" name="' + option.name || '' + '" id="' + op.id || '' + '" value="' + op.value || '' + '"' + action + ' />' + op.show || "" + "&nbsp;&nbsp;";
		}
	}else{
		t = type;
		row += '<input type="' + relate[ type ] + '" name="' + option.name || "" + '" id="' + option.id || '' + '" value="' + option.value + '"' + action + '>'
	}
	row += '</td><td><span class="help-inline">' + option.help || "" + '</span></td></tr>';
}

/*
{
table:[{field:'', name:'user', id:"",placeholder:"", formType:"",eventName:"",fn:"", help:""},...],
content:'html'
}*/
function handDialog( param ){
	if ( !isNull(param) ){
		if( isNull( param.title ) ) return 'title is null';
		if( !isNull( param.warning ) ){
			var warn = "";
			for( var i = 0; i < param.warning.length; i++ ){
				warn += param.warning[ i ];
			}
			param.warning = warn;
		}
		if( !isNull(param.table) && isNull( param.content ) ){
			var content = '<table>';
			for( var i = 0; i < param.table.length; i++ ){
				content += createFm( param.table[i] );
			}
			content += '</table>';
			param['body'] = content;
		}else if( isNull( param.table ) && !isNull( param.content ) ){
			param['body'] = param.content;
		}else{
			return 'content is null'
		}
	}
}

/*
{
title : string,
id : "",
bodyClass:"";
warning: {str1,str2},
table:[{field:'', name:'user', id:"",placeholder:"", formType:"",eventName:"",fn:"", help:""},...],
content:'html'
yText:"",
nText:"",
button:[{id:'',name:'',type:'', eventName:'', fn:"", sign:'close'}]//type:1==postdata
yFn:function(){},
nFn:function(){},
url:""
method:""
}*/
function newDialog( param ){
	handDialog( param );
	var id = 'model';//isNull( id ) ? 'model' : id;
	var html = '';
	//<form action="" name="abc" id="frm' + id + '" method="' + ( param['method'] || '' ) + '" class=""><fieldset>
	html = '<div class="modal hide" id="' + id + '"><div class="modal-header"><button class="close" data-dismiss="modal">×</button><h3>' + ( param.title || '' ) + '</h3></div>' +
		   '<div class="modal-body">' ;
	if( !isNull( param.warning ) ){
		html += '<div class="alert ' + (param['bodyClass'] || '') + '"><a class="close" data-dismiss="alert" href="#">×</a>';
		for( var i in param.warning ){
			html += '<i class="icon-exclamation-sign icon-red"></i>' + param.warning[i] || "" + '<br/>';
		}
		html += '</div>';
	}
	if( !isNull( param['body'] ) ) html += '<div class="' + (param['bodyClass'] || '') + '"><form id="editFrm">' + param['body'] + '</form></div>';
	html += '</div><div class="modal-footer">';
	if( !isNull( param['button'] ) ){
		var relate = [ 'button', 'submit', 'reset' ];
		for( var i in param['button'] ){
			var btn = param[ 'button' ][ i ];
			var btnId = isNull( btn['id'] ) && ( btn['sign'] != 'close' ) ? "" : ' id="'+ btn['id'] +'" ';
			var eventN = isNull( btn[ 'eventName' ] ) ? "onClick" : btn[ 'eventName' ];
			var e = isNull( btn[ 'fname' ] ) ? "" : (' ' + eventN + '="' + btn[ 'fname' ] + '" ');
			if( btn['type'] == 1 ) e = ' onClick="postData(\'' + param[ 'action' ] + '\', \'editFrm\' ,' + btn[ 'fn' ] +',\'' + param[ 'method' ] + '\' )"';
			var diff = ' class="btn btn-primary btn-large" ';
			if( btn['sign'] == 'close' ){ diff = ' class="btn btn-large" data-dismiss="modal" '; btnId = ' id="clsBtn" '}
			html += '<button ' + diff + btnId + e + '> ' + btn['name'] || '' + '</button>';
		}
	}else{
		html += '<a href="javascript:void(0);" class="btn btn-large" data-dismiss="modal">关闭</a>'
	}
	html += '</div></div>';//</fieldset></form>';
	if( typeof( $( '#' + id ) ) == 'object' ) $( '#' + id ).remove();
	$( html ).appendTo('body');
	$( '#' + id ).modal('show');
}


function postData( url, frmID, fn, method){
	if( url.indexOf( 'SN=' ) == url.length - 3 ) url += $( '#SN' ).val() || $('#sn').val();
	var frmD = $( '#' + frmID ).serialize();
	loadData( url, fn, frmD, ( method || 'get' ), 'json' );
}

/*使用ajax加载数据*/
function loadData( url, executeFn, data, method, dataType ){
	if( url.indexOf( '.html' ) > 0 ){
		currentP = 1;
		url = '/webPage/' + url;
	}
	$( '#clsBtn' ).trigger( 'click' );
	url = isNull( url ) ? "" : url;
	exectueFn = isNull( executeFn ) ? function(msg){} : executeFn;
	method = isNull( method ) ? "get" : method;
	dataType = isNull( dataType ) ? "text" : dataType;
	data = data || "";
	complete = {};
	$.ajax({
		url: url,
		cache: false,
		data : data,
		dataType : dataType,
		type: method,
		complete:function( status ){
			ajaxStatus = status;
		},
		success: function(html){
			if( method == 'post' ){
				try{
					var objs=eval(html);
				}catch(e){
					eval("var objs=" + html);
				}
				var cls = ''
				if( objs.ret < 0 ) cls = 'alert alert-warning';
				else cls = 'alert alert-success';
				newDialog( { title : '提示', content : ( objs.msg ||'操作成功！' ), bodyClass : cls } );
			}
			executeFn(html);
		}
	});
}






function online(){
	$.ajax({
		url: '/manage/status',
		dataType : 'json',
		type: 'post',
		data:sns,
		success: function(msg){
			try{
				var objs=eval(msg);
			}catch(e){
				eval("var objs=" + msg);
			}
			if( !isNull( objs ) && !isNull( sns ) ){
				for( var sn in sns ){
					var row = objs[ sn ]
					if( row.online != sns[ sn ] ){
						if( row.online ) $( '#line' + sn ).html( '　　<i class="icon-ok icon-green popover-help-username"></i>' );
						else $( '#line' + sn ).html( '　　<i class="icon-ban-circle icon-red popover-help-username"></i>' );
					}
					if ( row[ 'cmd_index' ] == 0 ){
						bar = '无命令';
					}else{
						var rate = ( row[ 'cmd_end' ] / row[ 'cmd_index' ] * 100 );
						$('#bar' + sn ).attr("style", "width:" + rate + "%");
						var msg = "待下发命令：" + (row.cmd_index - row.cmd_end ) + "条<br>已下发命令：" + row.cmd_end + "条<br>命令总条数：" + row.cmd_index + "条";
						$('#info' + sn ).attr( "data-content", msg  );
						/*
						var msg = "待下发命令：" + (row.cmd_index - row.cmd_end ) + "条<br>已下发命令：" + row.cmd_end + "条<br>命令总条数：" + row.cmd_index + "条";
						bar = '<div  name="showInfo" title="详细信息" data-content="' + msg + 
							  '"  class="progress progress-success progress-striped active" style="margin-bottom: 9px;width:100px;height:15px;' + gradientCss + '">' +
						  	  '<div class="bar"  id="bar' + ( sn || '' ) + '" style="width: ' +  rate + '%"></div></div>';	
							  */
					} 
					
					//$( '#status' + sn ).html( bar );
					sns[ sn ] = row.online;
				}
			}
		}
	});
	lineStatus = setTimeout( online, 1000 * 3 );
}

function copy_array( json ){
	if(typeof json == 'number' || typeof json == 'string' || typeof json == 'boolean'){
		return json;
	}else if(typeof json == 'object'){
		if(json instanceof Array){
			var newArr = [], i, len = json.length;
			for(i = 0; i < len; i++){
				newArr[i] = arguments.callee(json[i]);
			}
			return newArr;
		}else{
			var newObj = {};
			for(var name in json){
				newObj[name] = arguments.callee(json[name]);
			}
			return newObj;
		}
	}
}

function copy_array_self( obj ){
	var new_arry = {};
	if( obj instanceof Array ){
		for( i = 0; i < obj.length; i++ ){
			var val = obj[ i ];
			if( val instanceof Array ){
				new_arry[ i ] = copy_array( val );
			}else{
				new_arry[ i ] = val;
			}
		}
	}else{
		return null;
	}
	return new_arry;
}

function convert( obj , row , fieldW, valueW, height, cutFld, flag ,help){
	var table = '';
	row = isNull( row ) ? 1 : row;
	if( !isNull( obj ) ){
		var fldW = isNull( fieldW ) ? '' : ' width="' + fieldW + '" ';
		var valW = isNull( valueW ) ? '' : ' width="' + valueW + '" ';
		var hgtW = isNull( height ) ? '' : ' height="' + height + '" ';
		table = '<table border="1px" width="100%">';
		var array = [];
		for( var o in obj){
			if( cutFld && cutFld[o] == '' ) continue;
			var title = o;
			if ( typeof obj[ o ] == 'object' && obj[ o ][ 'name' ] ) title = obj[ o ][ 'name' ];
			var val = '<td align="right" ' + fldW + ' ><strong>' + title + '</strong>:</td><td align="left" ' + valW + ' style="vertical-align:middle">';// + obj[o] + '</td>';
			if( typeof( obj[o]) == 'object' ){
				var tmp = obj[o];
				if( tmp["placeholder"] || tmp[ "helper" ] || tmp[ "name" ]){
					if ( tmp[ 'show' ] ){
						val += ( tmp[ 'value' ] || "" ) + '<input type="hidden" name="' + o + '" value="' + tmp[ 'value' ] + '" /></td>';
					}else{
						var holder = tmp[ 'placeholder' ]? '" placeholder="' + tmp[ 'placeholder' ] + '"' :"";
						var hlpr = tmp[ "helper" ] ? '<span class="add-on"><i class="icon-question-sign icon-blue popover-help-username" data-content="' + tmp[ 'helper' ] + '" data-original-title="帮助"></i></span>' : '';
						var tp = tmp[ 'type' ] ? tmp[ 'type' ] : 'text';
						var value = '';
						if ( tmp[ 'value' ] ) value = ' value="' + tmp[ 'value' ] + '"';
						val += '<input type="' + tp + '" name="' + ( o || '' ) + '" id="' + ( o || '' ) + holder + '" ' + value + ' />' + hlpr + '</td>';
					}
				}else{
					var v = '<table width="95%" >';
					for( var o2 in tmp ) v += "<tr><td>" + o2 + ":" + tmp[o2] + "</td></tr>";
					val += v + '</table></td>';
				}
			}else{
				obj[o] += "";
				if( flag=='form' ){
					var fldV = help == 'help' ? '"placeholder ="' : '" value="';
					val += '<input type="text" name="' + ( o || '' ) + '" id="' + ( o || '' ) + fldV + ( obj[o] || '' ) + '" /></td>';
				}else{
					if( typeof( obj[o] ) == 'string' && obj[o].length>50 ){
						var text = '<textarea rows="2" cols="30" id="textarea" disabled="disabled" style="width: 400px; height: 70px;" >' + obj[ o ] + '</textarea>';
						val += text + '</td>';
					}else val += obj[o] + '</td>';
				}
			}
			array.push( val );
		}
		var len = array.length;
		for( var i = 0 ; i < len; i++ ){
			var tr = '<tr ' + hgtW + ' >';
			for( var r = 1; r <= row; r++ ){
				i = i + r -1;
				if( i >= len ) break;
				tr += array[ i ];
			}
			table += tr + '</tr>';
		}
		table += '</table>';
	}
	return table;
}
/*-----end tool-------*/
