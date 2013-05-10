local resp = require"resp"
--local ngx = require"ngx"
local lfs = require"lfs"
local json = require"json"
local mysql = require"resty.mysql"
local os = require"os"
local db_bak=require"db_bak"

local crypt=require"crypt"

--[[
local date=require("os").date
local curdate=os.date("%Y-%m-%d")
print("date:"..curdate)
]]
local iclock = {}
local ret = {object=0,objects=1}



function savelog(log)                            
	db_bak.init()
	db_bak.mysql_insert(log)
end

function checklanguage(param)
	local language={"E","S","ES"}					--在这个地方添加语言参数
	for k,v in pairs(language) do
		if string.find(param,v)~=nil then
			return 0,'language param is ok'
		end
	end
	return -1,'invalid language param'
end


function split(str, symbol)
    local len = #symbol
    local t = {}
    local i = string.find(str,symbol)
    local j=1 
    while i do
        table.insert(t,string.sub(str,j,i-1))
        j=i+len
        i=string.find(str,symbol,j)
    end 
    table.insert(t,string.sub(str,j,#str))
    return t
end

all_device={}
param={}
macstr=''


							--SNs的检测并没有验证SNs的有效性和MAC地址格式的正确性
function checkSNs(SNs)			--未完成部分,解析出SNs之后,保存到一个全局table中去
	local device=split(SNs,',')
	for k,v in pairs(device) do
		print("CHECK SNs:", v)
		local group={}
		local dev1={}
		local dev2={}
		if string.find(v,'-')~=nil then 
			local i=string.find(v,'-')
			print ("this is a #############device range")
			local str1=string.sub(v,1,i-1)
			local str2=string.sub(v,i+1,#v)
			print("str1:",str1,"str2",str2)			--这个地方可以加入简单验证，-后面的要比前面的大
			
			--解析出sn和mac地址 
			local m1 =string.find(str1,'|')
			local sn1=string.sub(str1,1,m1-1)
			local mac1=string.sub(str1,m1+1,#v)
			dev1.sn=sn1
			dev1.mac=mac1
			table.insert(group,dev1)
			local m2 =string.find(str2,'|')
			local sn2=string.sub(str2,1,m2-1)
			local mac2=string.sub(str2,m2+1,#v)
			dev2.sn=sn2
			dev2.mac=mac2
			table.insert(group,dev2)
		else
			print ("this a ##############sigle device")
			local m=string.find(v,'|')
			local sn=string.sub(v,1,m-1)
			local mac=string.sub(v,m+1,#v)
			print("sn:",sn,"mac:",mac)
			macstr=crypt.getmacstr(mac)
			dev1.sn=sn
			dev1.mac=mac
			table.insert(group,dev1)
			table.insert(group,dev1)
		end
		table.insert(all_device,group)
	end
	return 0,'SNS check ok!'
end

function checklog(log,fileflag)    --fileflag  0:表示带有mac地址  1:表示不带mac地址，从许可文件解析出来
	if type(log.info)==nil then 
		return -1,'invalid machinetype'
	end
	if tonumber(log.id)==nil then                 
		return -1,'invalid id'
	end
	if type(log.user)==nil then
		return -1,'invalid user'
	end
	--[[
	if type(log.last_id)~=nil and tonumber(log.last_id)==nil then               --last_id为可选参数 
		return -1,'invalid last_id'
	end
	]]
	if log.lang~="" then
	local ret,msg = checklanguage(log.lang)                          --语言参数应该是几个固定的可选参数
	if ret==-1 then 
		print ("Error:",msg)
		return -1,msg
	end
	end
	if log.mullang~="" then
	local ret,msg = checklanguage(log.mullang)                          
	if ret==-1 then 
		print ("Error:",msg)
		return -1,msg
	end
	end
	if fileflag==0 then
		ret,msg = checkSNs(log.SNs)
			if ret==-1 then
			print("Error",msg)
			return -1,msg
		end
	end
	return 0,'log check ok!'
end


--分2步来完成-------( 1 )------发送文件，并保存，返回id
function iclock.POST_zipfile(var)
	local log = {}
	log.id =  ngx.var.arg_id or ""
	log.user =  ngx.unescape_uri(ngx.var.arg_user) or ""
	local time = os.time()
	log.time=time
	--print ('reciving param:SNs:'..log.SNs..' info:'..log.info..' id:'..log.id..' last_id:'..log.last_id..' user:'..log.user..' lang:'..log.lang)

	if log.id=="" then 
		return ngx.say("Error: invalid id!")
	end
	if log.user=="" then
		return ngx.say("Error: user is nil!")
	end
	
	ngx.req.read_body()			--读取content的内容
	local data=ngx.req.get_body_data() or ""
	if data=="" then 
		return ngx.say("Error: post content data is nil !") 
	end
	log.contentlength=#data
--	log.content=data
							--新建文件夹    新建的文件路径目前为绝对路径   在nginx.conf中修改
							--这个地方如果id号和以前的一样，要先进行一次文件夹的删除操作，把之前的所有错误的许可以及zip文件都给删掉
	local fdir = ngx.var.post_zip_path..log.id..'/'
	local ret ,msg=lfs.mkdir(fdir)
	fdir=fdir.."zip/"
	lfs.mkdir(fdir)
	local fname= log.id..".zip"
	local fh, msg = io.open(fdir..fname, "w+b")
	if fh==nil then
		print("open "..fdir..fname.." failed "..msg)
		ngx.say("save file failed !")
		return
	end
	fh:write(data)
	fh:close()	
	

	
							--zip文件解压处理  --解压命令7z x "d:\File.7z" -y -aos -o"d:\Mydir"
	local extrfilepath=ngx.var.post_zip_path..log.id..'/extr/'
	lfs.mkdir(extrfilepath)
	local cmd='7z x "'..fdir..fname..'" -y -aos -o"'..extrfilepath..'"'
	local ret7z = os.execute(cmd)
	if ret7z~= 0 then
		return ngx.say("Error:extrac zip file failed!")
	end
							
	ret,msg=savelog(log)			--保存许可生成记录到MYSQL
	print (ret,msg)
	if ret==-1 then 
		return ngx.say("Error:",msg)
	end

	print("save zip file finished!")
	return ngx.say("save zip file finished!")
end

function iclock.POST_parampermit(var)
	local log = {}
	log.SNs =  ngx.var.arg_SNs   --判断SNs里面是否有mac地址，如果没有，则mac地址由许可文件获取
	log.info =  ngx.var.arg_info 
	log.id =  ngx.var.arg_id 
	log.user =  ngx.unescape_uri(ngx.var.arg_user)
	log.lang =  ngx.var.arg_lang or ""
	log.mullang=ngx.var.arg_mullang or ""
	log.func = ngx.var.arg_func or ""
	local time = os.time()
	log.time=time
	local fileflag=1
	if string.find(log.SNs,':')~=nil then
		fileflag=0
	end

	local licensepath=ngx.var.post_zip_path..log.id..'/license/'
	lfs.mkdir(licensepath)	
	local rcvmac=''
	if fileflag==1 then			--接收许可文件，用来获取mac地址
		local rcvlicfile=ngx.var.post_zip_path..log.id..'/license/'..log.SNs..'.lic'
		ngx.req.read_body()			--读取content的内容
		local data=ngx.req.get_body_data() or ""
		if data=="" then 
			return ngx.say("Error: post content data is nil !") 
		end	
		
		local fh, msg = io.open(rcvlicfile, "w+b")		--写入以SN.lic命令的文件中
		if fh==nil then
			print("open "..rcvlicfile.." failed "..msg)
			ngx.say("save file failed !")
			return
		end
		fh:write(data)
		fh:close()	
	
	
		local ret,msg= crypt.GetMacFromFile(rcvlicfile)
		if ret==-1 then
			return ngx.say(msg)
		end
		if string.find(msg,':')=='nil' then
			return ngx.say("Error,Decode mac from file failed!")
		end
		rcvmac=msg
		ngx.say(msg)
		print("rcv mac from file:",msg)
		
		local group={}
		local dev={}
		dev.sn=log.SNs
		dev.mac=msg
		table.insert(group,dev)
		table.insert(group,dev)
		table.insert(all_device,group)
	end
	
	local ret,msg=checklog(log,fileflag)          --检测发送过来的请求，是否符合标准
	print (ret,msg)
	if ret==-1 then 
		return ngx.say("Error:",msg)
	end
	
	
							--生成许可部分
	local extrfilepath=ngx.var.post_zip_path..log.id..'/extr/'
--	lfs.mkdir(extrfilepath)
	
	local count = 0
	for k,v in pairs(all_device) do
		if type(v)=="table" then 
			print("all_device:",v[1].sn..','..v[1].mac..','..v[2].sn..','..v[2].mac)
			local num = crypt.makelicense(v[1],v[2],log,extrfilepath,licensepath,fileflag)
			--count=count+num
		end
	end
--[[	
							--许可处理部分，是压缩成zip文件返回还是直接对应着序列号保存到东莞SQLServer里面
	--压缩成zip文件
	local srcfile=licensepath.."*.lic"
	local destfile=ngx.var.post_zip_path..log.id..'/license.zip'
	local cmd2='7z a '..destfile..' '..srcfile
	ret7z=os.execute(cmd2)
	if ret7z~=0 then 
		return ngx.say("Error: compress zip failed!")
	end
]]	
	if fileflag==1 then
		macstr = crypt.getmacstr(rcvmac)
	end

end


--直接一步完成压缩文件的发送和许可文件的返回
function iclock.POST_permit(var)
	local log = {}
	log.SNs =  ngx.var.arg_SNs
	log.info =  ngx.var.arg_info 
	log.id =  ngx.var.arg_id 
	log.last_id =  ngx.var.arg_last_id 
	log.user =  ngx.unescape_uri(ngx.var.arg_user)
	log.lang =  ngx.var.arg_lang or ""
	log.mullang=ngx.var.arg_mullang or ""
	local time = os.time()
	log.func = ngx.var.arg_func or ""
	log.time=time
	print ('reciving param:SNs:'..log.SNs..' info:'..log.info..' id:'..log.id..' last_id:'..log.last_id..' user:'..log.user..' lang:'..log.lang)

	local ret,msg=checklog(log,0)          --检测发送过来的请求，是否符合标准
	print (ret,msg)
	if ret==-1 then 
		return ngx.say("Error:",msg)
	end
	
	ngx.req.read_body()			--读取content的内容
	local data=ngx.req.get_body_data() or ""
	--print ('reciving data:',data,'type(data):',type(data))
	if data=="" then 
		return ngx.say("Error: post content data is nil !") 
	end
							--新建文件夹    新建的文件路径目前为绝对路径   在nginx.conf中修改
	local fdir = ngx.var.post_zip_path..log.id..'/'
	local ret ,msg=lfs.mkdir(fdir)
	fdir=fdir.."zip/"
	lfs.mkdir(fdir)
	local fname= log.id..".zip"
	local fh, msg = io.open(fdir..fname, "w+b")
	if fh==nil then
		print("open "..fdir..fname.." failed "..msg)
		ngx.say("open "..fdir..fname.." failed "..msg)
		return
	end
									--将content的内容写入到zip文件中    test OK!  写入后可以解压
--	--[[
	local fh2,msg2=io.open("F:/new-server/data/999/zip/txt.zip","r+b")
	local data2=fh2:read("*a")
	print("ziplength:",#data2)
	fh2:close()
--	]]
	fh:write(data)
	fh:close()
							--zip文件解压处理  --解压命令7z x "d:\File.7z" -y -aos -o"d:\Mydir"
	local extrfilepath=ngx.var.post_zip_path..log.id..'/extr/'
	lfs.mkdir(extrfilepath)
	local cmd='7z x "'..fdir..fname..'" -y -aos -o"'..extrfilepath..'"'
	--local cmd='7z x "'..ngx.var.post_zip_path.."999/zip/main.zip"..'" -y -aos -o"'..extrfilepath..'"'    --仅测试用，解压文件999/zip/main.zip
	local ret7z = os.execute(cmd)
	if ret7z~= 0 then
		print("Error:extrac zip file failed!")
	end
--	print("type7z:"..type(ret7z).." ret7z:"..ret7z)
							--生成许可部分
	local licensepath=ngx.var.post_zip_path..log.id..'/license/'
	lfs.mkdir(licensepath)
	
	local count = 0
	for k,v in pairs(all_device) do
		if type(v)=="table" then 
			print("all_device:",v[1].sn..','..v[1].mac..','..v[2].sn..','..v[2].mac)
			local num = crypt.makelicense(v[1],v[2],log,extrfilepath,licensepath,0)
			count=count+num
		end
	end
--	print("!!!!makelicense num :",count)
	
							--许可处理部分，是压缩成zip文件返回还是直接对应着序列号保存到东莞SQLServer里面
	--压缩成zip文件
	local srcfile=licensepath.."*.lic"
	local destfile=ngx.var.post_zip_path..log.id..'/license.zip'
	local cmd2='7z a '..destfile..' '..srcfile
	ret7z=os.execute(cmd2)
	if ret7z~=0 then 
		print("Error: compress zip failed!")
	end
	
	local fh3,msg3=io.open(destfile,"r+b")
--	local fh3,msg3=io.open(licensepath..'00176110908c.lic',"r+b")
	local data3=fh3:read("*a")
	print("read data3 is :",#data3)
	resp.send_lic(data3)
	fh3:close()
--	ngx.say("finished!")
							
end

local f_name=ngx.var.request_method..'_'..ngx.var[1]


local fun = iclock[f_name]

if  fun then
	fun(ngx.var)
else
--	ngx.status=404
--	return resp.send_error(404,"ERROR: invalid device request '"..f_name.."'")
	return ngx.say("just test")
end