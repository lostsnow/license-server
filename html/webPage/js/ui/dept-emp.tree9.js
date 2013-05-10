department=[];
show=0
check=0
function getDept_to_show_emp(lheight,lwidth,emp_w,ds){
	$("#show_dept_emp_tree").html(getLayout_html(lheight,lwidth,emp_w));
	ShowDept_Emp_Tree(ds);
        
}
function getLayout_html(lheight,lwidth,emp_w)
{
	lwidth=lwidth!=undefined?lwidth:260
	var w=$("#id_content").width()-5
	var emp_w=emp_w!=undefined?emp_w:w-lwidth-10
	
	var layout_html="<table width=100% ><tr><td class=border_td style='width:"+(lwidth!=undefined?lwidth:260)+"px;'>"
						+"<div >"
								+"<div id=id_opt_title>"
						        +"<span>"+gettext("Department")+"</span>"
								+"<span id=id_opt_tree>"
								+"<input type='checkbox' id='id_contain_chl'/>"+gettext("Contain Children")+"</span>"
								+"</div>"
						        +"<div id='showTree' style='overflow:auto;height:"+lheight+"px;width:"+(lwidth!=undefined?lwidth:260)+"px;'></div>"
						+"</div></td>"
						+"<td class='border_td'><div>"
							+"<div><span class='title_bar'>"+gettext("Employee")+"</span></div>"
								+"<div style='overflow:auto;height:"+lheight+"px;width:"+emp_w+"px;' id='id_emp'></div>"
						+"</div>"
						+"</td></tr></table>"
						+"<input type='hidden' value='' id='hidden_depts' />"
						+"<input type='hidden' value='' id='hidden_deptsName' />"
						+"<input type='hidden' value='' id='hidden_selDept' />"

//						+"<div id='hidden_selDept' style='display:none'></div>"
	return layout_html;
}
function getDept_and_emp_ex(lheight,lwidth,ds){
	if (page_tab==undefined) page_tab=''
	$("#show_dept_emp_tree_"+page_tab).html(getLayout_Dept_ex(lheight,lwidth)).bgiframe();
	ShowDept_Emp_ex(ds);
}

//加载提示项目显示样式
function gethrreminddiaplay(lheight,lwidth,ds){
	$("#"+page_tab).html(getLayout_ihrreminded(lheight,lwidth)).bgiframe();
	Showihrremined()
	
}

function getreverselist(lheight,lwidth,ds){
	$("#"+page_tab).html(getLayout_reverse(lheight,lwidth)).bgiframe();
	Showreverse()
	
}

function getLayout_Dept_ex(lheight,lwidth)
{	
	jqOptions.height=lheight-80;
	lwidth=lwidth!=undefined?lwidth:260
	w=$("#id_content").width()-5
	grid_w=w-lwidth-20
	var h=lheight-30
	var layout_html="<table width="+w+"px><tr><td class='border_td' style='width:"+lwidth+"px;'>"
						+"<div>"
								+"<div id='id_opt_title'>"
									+"<span>"+gettext("Department")+"</span>"
									+"<span id='id_opt_tree'>"
									+"<input type='checkbox' id='id_contain_chl_"+page_tab+"'/>"+gettext("Contain Children")+"</span>"
								+"</div>"
						        +"<div id='showTree' style='overflow:auto;height:"+h+"px;width:"+(lwidth!=undefined?lwidth:260)+"px;'></div>"
						+"</div></td>"
						+"<td class='border_td'><div>"
							+"<div><span class='title_bar'>"+gettext("Employee")+"</span></div>"
								+"<div id='id_empl' style='height:"+h+"px;width:"+grid_w+"px;'"+"><table id=id_"+page_tab+"grid ></table><div id=id_"+page_tab+"pager></div></div>"
						+"</div>"
						+"</td></tr></table>"
						+"<input type='hidden' value='' id='hidden_depts' />"
						+"<input type='hidden' value='' id='hidden_deptsName' />"
						+"<input type='hidden' value='' id='hidden_selDept' />"

//						+"<div id='hidden_selDept' style='display:none'></div>"
	return layout_html;
}

function getLayout_ihrreminded(lheight,lwidth)
{	
	jqOptions.height=$("#id_content").height()-100;
	lwidth=lwidth!=undefined?lwidth:260
	w=$("#id_content").width()-5
	grid_w=w-lwidth-20
	var h=$("#id_content").height()-70
	var layout_html="<table  width="+w+"px><tr>"
						+"<td class='border_td' style='width:"+lwidth+"px;'><div>"
								+"<div id='id_opt_title'>"
									+"<span>"+gettext("人员日期提醒")+"</span>"

								+"</div>"
								+"<div id='showremindTree' style='overflow:auto;height:"+h+"px;width:"+(lwidth!=undefined?lwidth:260)+"px;'></div>"
						+"</div></td>"
					
						+"<td class='border_td'><div>"
								+"<div id='id_empl' style='height:"+h+"px;width:"+grid_w+"px;'"+"><table id=id_"+page_tab+"grid ></table><div id=id_"+page_tab+"pager></div></div>"
						+"</div>"
						+"</td></tr></table>"

//						+"<div id='hidden_selDept' style='display:none'></div>"
	return layout_html;
}

function getLayout_reverse(lheight,lwidth)
{	
	jqOptions.height=$("#id_content").height()-100;
	lwidth=lwidth!=undefined?lwidth:260
	w=$("#id_content").width()-5
	grid_w=w-lwidth-20
	var h=$("#id_content").height()-70
	var layout_html="<table  width="+w+"px><tr>"
						+"<td class='border_td' style='width:"+lwidth+"px;'><div>"
								+"<div id='id_opt_title'>"
									+"<span>"+gettext("人员异常查询")+"</span>"

								+"</div>"
								+"<div id='showreverseTree' style='overflow:auto;height:"+h+"px;width:"+(lwidth!=undefined?lwidth:260)+"px;'></div>"
						+"</div></td>"
					
						+"<td class='border_td'><div>"
								+"<div id='id_empl' style='height:"+h+"px;width:"+grid_w+"px;'"+"><table id=id_"+page_tab+"grid ></table><div id=id_"+page_tab+"pager></div></div>"
						+"</div>"
						+"</td></tr></table>"

//						+"<div id='hidden_selDept' style='display:none'></div>"
	return layout_html;
}

function IsContain(arr,value)
{
  for(var i=0;i<arr.length;i++)
  {
     if(arr[i]==value)
      return true;
  }
  return false;
}
//更新所选择的授权部门   
function click_dept_checkbox(obj){
	var selectDept=[];
	var deptid=$(obj).attr("alt");
	var deptName=$(obj).attr("alt2");
	if(typeof(selectDept)!='undefined'){
		var flag=IsContain(selectDept,deptid)
		if($(obj).attr("checked"))
			{
				if(!flag){   //选中  不存在 加入;
					if(selectDept.length==0)
						names+=deptName
					else
						names+=","+deptName
					selectDept.push(deptid);
				}
			}
		else
			{
				if(flag){  //不选中 存在 删除
					for(var i=0;i<selectDept.length;i++){
						if(deptid==selectDept[i])
							selectDept.splice(i,1)
					}
					names=names.replace(","+deptName," ")
				}	
			}
	}
}
//单击+号 自动将 已授权的部门 复选上
function show_selected_dept(){
	if(typeof(selectDept)!='undefined'){
		for(var i=0;i<selectDept.length;i++)
			{
				$.each($(".file input"),function(){
						if($(this).attr("alt")==selectDept[i]) 
							$(this).attr("checked","checked")
					
				});
				$.each($(".folder input"),function(){
					if($(this).attr("alt")==selectDept[i]) 
						$(this).attr("checked","checked")
				});
			}
	}

}

//单击 部门名称 ----- 人员 
function click_dept_file(obj){
		$("#id_addsch_tmpShift").attr("disabled","disabled");
		$.cookie("q","",{expires:0});
		var deptID=$(obj).attr("alt");
		var deptName=$(obj).attr("alt1")
		$("#hidden_selDept").val(deptID);
		$("#hidden_depts").val(deptID);
		$("#hidden_deptsName").val(deptName)
		renderEmpTbl(1,'id_cascadecheck');
}
function ShowDept_Emp_Tree(ds)
{
	var o = { showcheck: false,
		url: "/iclock/att/getData/?func=department" ,
		onnodeclick:function(item){
			//$("#id_addsch_tmpShift").attr("disabled","disabled");
			$.cookie("q","",{expires:0});
			var deptID=item.id;
			var deptName=item.text;
			$.cookie("dept_ids",deptID, { expires: 7 });
			$("#hidden_selDept").val(deptID);
			$("#hidden_deptsName").val(deptName);
			if (ds=='ENROLL')
				renderEmpTbl_Radio(1,'id_contain_chl')
			else
			renderEmpTbl(1,'id_contain_chl');

		}
	};
	$("#showTree").treeview(o);
	$("#id_emp").html("<div align='center'><h4><img src='/media/img/hint.gif'/>"+gettext("Click the department to show the employees!")+"</h4></div>");
}
function ShowDept_Emp_ex(ds)
{

	var o = { showcheck: false,
		url: "/iclock/att/getData/?func=department" ,
		onnodeclick:function(item){
			//$("#id_addsch_tmpShift").attr("disabled","disabled");
			$.cookie("q","",{expires:0});
			var deptID=item.id;
			var deptName=item.text;
			$.cookie("dept_ids",deptID, { expires: 7 });
			$("#show_dept_emp_tree_"+page_tab).find('#hidden_selDept').val(deptID);
			$("#show_dept_emp_tree_"+page_tab).find("#hidden_deptsName").val(deptName);
			if (page_tab=='id_empshifts')
				renderEmp_ex(1)

			else if (page_tab=='id_show_Shift')
				renderEmpListShiftsTbl(1,page_tab)
			else if (ds=='finger')
				renderEmp_finger(1)
			else if (ds=='face')
				renderEmp_face(1)
		}
	};
	$("#show_dept_emp_tree_"+page_tab).find("#showTree").treeview(o);
/*
	if (page_tab=='id_empshifts')
	{	
		urlStr="/iclock/data/employee/?t=employee_shift.js&DeptID__exact=-1"
		jqOptions.url=urlStr	
		jqOptions.pager='#id_'+page_tab+"_pager";
		$("#id_"+page_tab+"_grid").jqGrid(jqOptions);
	}
*/

//	$("#id_empl").html("<div align='center'><h4><img src='/media/img/hint.gif'/>"+gettext("Click the department to show the employees!")+"</h4></div>");
}
//加载提醒醒目
function Showihrremined()
{
    var ComeTime=$("#id_ComeTime").val();
	var o = { showcheck: false,
		url: "/iclock/att/getData/?func=ihrremind&cometime="+ComeTime ,
		onnodeclick:function(item){
			$.cookie("q","",{expires:0});
			var reminditem=item.id;
			$.cookie("reminditem",reminditem, { expires: 7 });
			showhrreminddetail(reminditem);
		}
	};
	$("#showremindTree").treeview(o);
	

}
function Showreverse()
{
	var o = { showcheck: false,
		url: "/iclock/att/getData/?func=reverse" ,
		onnodeclick:function(item){
			$.cookie("q","",{expires:0});
			var reminditem=item.id;
			$.cookie("reminditem",reminditem, { expires: 7 });
			showhreversedetail(reminditem);
		}
	};
	$("#showreverseTree").treeview(o);
	

}


// 渲染 人员
function renderEmpTbl(p,checkid){
	deptID=$.cookie("dept_ids");
	var ischecked=0;
	if($("#"+checkid).attr("checked"))
		ischecked=1;
	var thtml='empsInDept.html'
	if(checkid=='id_contain_chl')
		thtml='empsInDepts.html'
	if(deptID!='')
	{
		if($.cookie("q")==null||$.cookie("q")=="")
			var urlStr="/iclock/att/getData/?func=employees&l=50&t="+thtml+"&DeptID__DeptID__in="+deptID+"&p="+p+"&isContainChild="+ischecked;
		else
			var urlStr="/iclock/att/getData/?func=employees&l=50&t="+thtml+"&DeptID__DeptID__in="+deptID+"&q="+$.cookie("q")+"&p="+p+"&isContainChild="+ischecked
	}
	else
	{
		if($.cookie("q")==null||$.cookie("q")=="")
			var urlStr="/iclock/att/getData/?func=employees&l=50&t="+thtml+"&p="+p;
		else
			var urlStr="/iclock/att/getData/?func=employees&l=50&t="+thtml+"&q="+$.cookie("q")+"&p="+p
		
		
	}

	var text=$.ajax({
		type:"POST",
		url: urlStr,
		async: false
		}).responseText;
	if ($("#id_form").is("div"))
	{
	    $("#id_form").find("#id_emp").html(text);
	}else if($("#show_dept_emp_tree").is("div")){
		$("#show_dept_emp_tree").find("#id_emp").html(text)
	}
	else
	{
	    $("#id_emp").html(text);
	}
	
}
function renderEmpTbl_Radio(p,checkid){
	deptID=$.cookie("dept_ids");
	var ischecked=0;
	if($("#"+checkid).attr("checked"))
		ischecked=1;
	if($.cookie("q")==null||$.cookie("q")=="")
		urlStr="/iclock/att/getData/?func=employees&l=50&t=empsInDept_radio.html&DeptID__DeptID__in="+deptID+"&p="+p+"&isContainChild="+ischecked;
	else
		urlStr="/iclock/att/getData/?func=employees&l=50&t=empsInDept_radio.html&DeptID__DeptID__in="+deptID+"&q="+$.cookie("q")+"&p="+p+"&isContainChild="+ischecked
	var text=$.ajax({
		type:"POST",
		url: urlStr,
		async: false
		}).responseText;
	if ($("#id_form").is("div"))
	{
	    $("#id_form").find("#id_emp").html(text);
	}else if($("#show_dept_emp_tree").is("div")){
		$("#show_dept_emp_tree").find("#id_emp").html(text)
	}
	else
	{
	    $("#id_emp").html(text);
	}
}

function renderEmp_ex(p){
	//deptID=$.cookie("dept_ids");
	deptID=$("#show_dept_emp_tree_"+page_tab).find("#hidden_selDept").val()
	var ischecked=0;
	if($("#id_contain_chl_"+page_tab).attr("checked"))
		ischecked=1;
	if($.cookie("q")==null||$.cookie("q")=="")
		urlStr="/iclock/data/employee/?t=employee_shift.js&deptIDs="+deptID+"&isContainChild="+ischecked
	else
		urlStr="/iclock/data/employee/?t=employee_shift.js&deptIDs="+deptID+"&q="+$.cookie("q")+"&p="+p+"&isContainChild="+ischecked
	jqOptions.url=urlStr	
	jqOptions.pager='#id_'+page_tab+'pager';
	$("#id_"+page_tab+"grid").jqGrid('GridUnload')
	$("#id_"+page_tab+"grid").jqGrid(jqOptions)
//	$("#id_"+page_tab+"_grid").jqGrid('setGridParam',{url:urlStr}).trigger("reloadGrid");

/*
	var text=$.ajax({
		type:"POST",
		url: urlStr,
		async: false
		}).responseText;
	if ($("#id_form").is("div"))
	{
	    $("#id_form").find("#id_empl").html(text);
	}else if($("#show_dept_emp_tree").is("div")){
		$("#show_dept_emp_tree").find("#id_empl").html(text)
	}
	else
	{
	    $("#id_empl").html(text);
	}
*/


	
}

function renderEmp_finger(p){
	//deptID=$.cookie("dept_ids");
	deptID=$("#show_dept_emp_tree_"+page_tab).find("#hidden_selDept").val()
	var ischecked=0;
	if($("#id_contain_chl_"+page_tab).attr("checked"))
		ischecked=1;
	if($.cookie("q")==null||$.cookie("q")=="")
		urlStr="/iclock/data/fptemp/?UserID__OffDuty__lt=1&deptIDs="+deptID+"&isContainChild="+ischecked
	else
		urlStr="/iclock/data/fptemp/?UserID__OffDuty__lt=1&deptIDs="+deptID+"&q="+$.cookie("q")+"&p="+p+"&isContainChild="+ischecked
	jqOptions.url=urlStr	
	jqOptions.pager="#id_pager";
	var height=$("#id_empl").height()-60;
	jqOptions.height=height;	
	$("#id_grid").jqGrid('GridUnload')
	$("#id_grid").jqGrid(jqOptions)
	//$("#id_"+page_tab+"_grid").jqGrid('setGridParam',{url:urlStr}).trigger("reloadGrid");
}

function renderEmp_face(p){
	//deptID=$.cookie("dept_ids");
	deptID=$("#show_dept_emp_tree_"+page_tab).find("#hidden_selDept").val()
	var ischecked=0;
	if($("#id_contain_chl_"+page_tab).attr("checked"))
		ischecked=1;
	if($.cookie("q")==null||$.cookie("q")=="")
		urlStr="/iclock/data/facetemp/?UserID__OffDuty__lt=1&deptIDs="+deptID+"&isContainChild="+ischecked
	else
		urlStr="/iclock/data/facetemp/?UserID__OffDuty__lt=1&deptIDs="+deptID+"&q="+$.cookie("q")+"&p="+p+"&isContainChild="+ischecked
	jqOptions.url=urlStr	
	jqOptions.pager="#id_pager";
	//jqOptions.autowidth=true
	var height=$("#id_empl").height()-60;
	jqOptions.height=height;	
	$("#id_grid").jqGrid('GridUnload')
	$("#id_grid").jqGrid(jqOptions)
	//$("#id_"+page_tab+"_grid").jqGrid('setGridParam',{url:urlStr}).trigger("reloadGrid");
}


/**
function renderDevsTb(p){
	urlStr="/iclock/att/getData/?func=devs&l=10&t=devsInUserAC.html&p="+p;
	var text=$.ajax({
		type:"POST",
		url: urlStr,
		async: false
		}).responseText;
	if ($("#id_form").is("div"))
	{
	    $("#id_form").find("#id_devs").html(text);
	}
	else
	{
	    $("#id_devs").html(text);
	}
	
}

function showSelected_dev(){
    var c = 0;
	$("#id_addsch_tmpShift").attr("disabled","disabled");
    $.each($(".class_select_dev"),function(){
			if(this.checked) c+=1;})
    $("#selected_count_dev").html("" + c);
}
function check_all_for_row_dev(checked) {

    if (checked) {
        $(".class_select_dev").attr("checked", "true");
    } else {
        $(".class_select_dev").removeAttr("checked");
    }
    showSelected_dev();
}


**/
function getDeptTree(s,c){   //得到部门树
	show=s;
	check=c;
	var tree="<ul id='deptBrowser' class='filetree' style='margin-left:0px;color: black;'>";
	tree+=getTreeString(department,show,check)+"</ul>"

	tree+="<input type='hidden' value='' id='hidden_depts' />"
		+"<input type='hidden' value='' id='hidden_deptsName' />"
		+"<input type='hidden' value='' id='hidden_selDept' />"
	return tree;
}


function showSelected_emp(){
    var c = 0;
	$("#id_addsch_tmpShift").attr("disabled","disabled");
    $.each($(".class_select_emp"),function(){
			if(this.checked) c+=1;})
    $("#selected_count").html("" + c);
}

function check_all_for_row_emp(checked) {

    if (checked) {
        $(".class_select_emp").attr("checked", "true");
    } else {
        $(".class_select_emp").removeAttr("checked");
    }
    showSelected_emp();
}


function getSelected_emp() {
	var emp=[];
	$.each($(".class_select_emp"),function(){
			if(this.checked)
				emp.push(this.id)
	});
	return emp;
}

function getSelected_emp_ex(page_style) {
	var emp=$("#id_"+page_style+"grid").jqGrid('getGridParam','selarrrow');
	if(typeof emp=='undefined') emp=[]
	return emp
}
function getSelected_empNames_ex(page_style){
	var emp=$("#id_"+page_style+"grid").jqGrid('getGridParam','selarrrow');
	var empNames=[];
	if(typeof emp=='undefined') return empNames;
	for(var i=0;i<emp.length;i++)
	{
		pin=$("#id_"+page_style+"grid").jqGrid('getCell',emp[i],3);
		empNames.push(pin)
	}

return empNames;
}
function getSelected_empPin_ex(page_style){
	var emp=$("#id_"+page_style+"grid").jqGrid('getGridParam','selarrrow');
	var empNames=[];
	if(typeof emp=='undefined') return empNames;
	
	for(var i=0;i<emp.length;i++)
	{
		pin=$("#id_"+page_style+"grid").jqGrid('getCell',emp[i],2);
		empNames.push(pin)
	}

return empNames;
}

function getSelected_empPin() {
	var pin=[];
	$.each($(".class_select_emp"),function(){
			if(this.checked) 
				pin.push(this.alt)
	});
	return pin;
}
function getSelected_empid() {
	var id=[];
	$.each($(".class_select_emp"),function(){
			if(this.checked) 
				id.push(this.id)
	});
	return id;
}

function getSelected_empNames(){
	var empNames=[];
	$.each($(".class_select_emp"),function(){
			if(this.checked)
				empNames.push(this.name)
	});
	return empNames;
}
function getSelected_dept(tree_obj) {//得到所有选中部门的ID
	var dept=[];
	if ( typeof tree_obj == "string" )
	{
		//temp_dept=$(tree_obj)
		dept=$(tree_obj).getTSVs()
		//dept=temp_dept.getTSVs()
	}
	else
		dept=$("#id_dept").getTSVs();
	return dept;
}
function getSelected_depts() {//设备部门查询得到所有选中部门的ID
	var dept=[];
	dept=$("#id_depts").getTSVs();
	return dept;
}

function getSelected_Autued_dept() {//设备得到所有选中授权部门的ID
	var dept=[];
	dept=$("#id_Authed_dept").getTSVs();
	return dept;
}
function getSelected_deptNamess() {//设备部门查询得到所有选中部门的名称
	var deptNames=[];
	obj=$("#id_depts").getTSNs();
	for(var i=0;i<obj.length;i++){
		deptNames.push(obj[i].text);
	}
	return formatArrayEx(deptNames);
}

function getSelected_deptNames() {//得到所有选中部门的名称
	var deptNames=[];
	obj=$("#id_dept").getTSNs();
	for(var i=0;i<obj.length;i++){
		deptNames.push(obj[i].text);
	}
	return formatArrayEx(deptNames);
}
function getSelected_Autued_deptNames() {//设备得到所有选中授权部门的名称
	var deptNames=[];
	obj=$("#id_Authed_dept").getTSNs();
	for(var i=0;i<obj.length;i++){
		deptNames.push(obj[i].text);
	}
	return formatArrayEx(deptNames);
}

function showDeptment () {
	var top =  $("#department").position().top;
	var left =  $("#department").position().left;
	var d_height=$("#department").height();
	$("#show_deptment").css("display","block").css({position: 'absolute',"top": top+d_height+6+'px',"left": left+'px'});
	$("#show_deptment").bgiframe();
}
function showDeptments () {
	var top =  $("#departments").position().top;
	var left =  $("#departments").position().left;
	var d_height=$("#departments").height();
	$("#show_deptments").css("display","block").css({position: 'absolute',"top": top+d_height+6+'px',"left": left+'px'});
}

function hideDeptment () {
	$("#show_deptment").css("display","none").css("top", -1000).css("left",  -1000);
}
function hide_Autued_Deptment () {
	$("#show_Autued_deptment").css("display","none").css("top", -1000).css("left",  -1000);
}
function hideDeptments () {
	$("#show_deptments").css("display","none").css("top", -1000).css("left",  -1000);
}

function hideFields () {
	$("#show_field").css("display","none").css("top", -1600).css("left",  -1600);
}
function save_hideDeptment (){//保存选中部门
	hideDeptment ();
	var dept_ids=getSelected_dept();
	$.cookie("dept_ids",dept_ids, { expires: 7 });
	var dept_names=getSelected_deptNames();
	$("#department").val(dept_names);
	//renderEmpTbl(1);
	$.each($(".class_select_emp"),function(){
			this.checked=false
	});

	$.cookie("emp",'', { expires: 7 });


}

function showEmployee () {
	var top =  $("#Employee").position().top;
	var left =  $("#Employee").position().left;
	var e_height=$("#Employee").height();

	$("#show_emp").css("display","block").css("top", top+e_height+6).css("left", left);
	$.cookie("pin","", { expires: 0 });
}
function hideEmployee () {
	$("#show_emp").css("display","none").css("top", -1500).css("left",  -1500);
}
function save_hideEmployee(){//保存选中人员
	$("#show_emp").css("display","none").css("top", -1500).css("left",  -1500);
	showEmployeeEmployee();
}
function showEmployeeEmployee () {
	names=getSelected_empNames();
	$("#Employee").val(names);

}

//创建员工部门树对话框
function createDeptDlg(url,urlstr,title){
			var block_html="<div id='dlg_to_dev' "
			+"<table width=100%>"
			+"<tr>"
			+"<td colspan='3' style='padding: 0;'><div id='show_dept_emp_tree' style='min-height: 200px;'></div></td></tr>"
			+"<tr><td colspan='3'><span><img src='../media/img/hint.gif'></img>"+gettext("Click department and do not select employe that will be transfer the whole department of employees to device")+"</span>&nbsp;</td></tr>"
			+"</table></br>"
			+"<span id='span_del_alldev' style='margin-left:0px;'><input type='checkbox' id='id_ForAllDev' value='1' />"+gettext("From All Devices")+"</span>"
			+"<div id='faceorfp'>"
			+"<tr><td colspan='3'><span><img src='../media/img/hint.gif'></img>"+gettext("Single transmission fingerprint or facial or PIC can be the default for sending all")+"</span>&nbsp;</td></tr>"
			+"</br><span id='span_fp_face' style='margin-left:0px;'><input type='checkbox' id='id_Forfp' value='1' />"+gettext("Fingerprint only")+"<input type='checkbox' id='id_Forface' value='1' />"+gettext("Face only")+"<input type='checkbox' id='id_ForPIC' value='1' />"+gettext("PIC only")+"</span>"
			+"</div>"
			+"<span id='span_del_sys'style='margin-left:80px;display:none'><input type='checkbox' id='id_delFrmSys' value='1' />"+gettext("Delete fingers from system")+"</span><span id='id_error' style='display:none;float:right'></span>"
			+"</div>"
			$(block_html).dialog({	modal:true,
						 width: 850,
					  height:520,
					  title:title,
					buttons:[{id:"btnShowOK",text:gettext("Submit"),click:function(){}},
							 {id:"btnShowCancel",text:gettext("Return"),click:function(){$(this).dialog("close"); }
							}],
					close:function(){$("#dlg_to_dev").remove();}		

						})
			getDept_to_show_emp(285,300,500);
			return block_html;

}
