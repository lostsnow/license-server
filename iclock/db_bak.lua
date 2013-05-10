local mysql = require"resty.mysql"
local ngx = require"ngx"

local type = type
local print=print
local pairs=pairs
local next=next
local string=string

--module("db_bak", package.seeall)
module("db_bak")

local dbmysql=mysql:new()

dbmysql:set_timeout(1000)



function init()
local ok, err, errno, sqlstate = dbmysql:connect{
                host = "127.0.0.1",
                port = 3306,
                database = "lqw",
                user = "root",
                password = "123456",
                max_packet_size = 1024 * 1024 }
		
		
if not ok then
	ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
	return
end


--mysql_create()



end

--TinyBlob 最大 255
--Blob 最大 65K
--MediumBlob 最大 16M
--LongBlob 最大 4G
function mysql_create(flag)
	if string.find(flag,'licenselog')~=nil then
	local res, err, errno, sqlstate =
               dbmysql:query("create table licenselog "
                         .. "(id int(10), "
			 .."machinetype char(10), "
			 .."user varchar(30), "
			 .."date int(20), "
			 .."sn char(20) primary key, "
			 .."mac char(20), "
			 .."lang char(10), "
			 .."mullang char(10), "
			 .."func varchar(300), "
			 .."contentlength int(10), "
			 .."content Blob)")
			 
	if not res then
                ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
	end
	end
	if string.find(flag,'filelog')~=nil then
	local res, err, errno, sqlstate = dbmysql:query("create table filelog " .. "(id int(10) primary key, ".."user varchar(30), ".."date int(20), ".."contentlength int(10))")
	--local res, err, errno, sqlstate = dbmysql:query("create table filelog " .. "(id int(10) primary key, ".."user varchar(30), ".."date int(20), ".."contentlength int(10), ".."content MediumBlob"..")")
	if not res then
                ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
                return
	end
	end
	if string.find(flag,'user')~=nil then
	local res, err, errno, sqlstate = dbmysql:query("create table user " .. "(name char(20) primary key, ".."password varchar(10), ".."privilege int(10))")
	if not res then
                ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
                return
	end
	end
end

function mysql_chgpwd(user)
	local res1, err1, errno1, sqlstate1 = dbmysql:query('select * from user where name="'..user.name..'"')
	if not res1 then
		ngx.say("bad result: ", err1, ": ", errno1, ": ", sqlstate1, ".")
		return res1
	end
	if not next(res1) then
		print("user is not exist")
		ngx.say('user is not exist')
	else
		sql='update user set password="'..user.password..'" where name="'..user.name..'"'
	end
	local res, err, errno, sqlstate = dbmysql:query(sql)
	if not res then
                ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
                return res
	end
		
end

function mysql_insert(log)		--这个地方应该添加table名参数，复用所有table的insert和update
	if type(log.sn)=='nil' then
		local res1, err1, errno1, sqlstate1 = dbmysql:query("select * from filelog where id="..log.id)
		if not res1 then
			ngx.say("bad result: ", err1, ": ", errno1, ": ", sqlstate1, ".")
			return res1
		end
		if not next(res1) then
			sql="insert into filelog values (".. log.id ..',"'..log.user .. '",'.. log.time ..','.. log.contentlength ..')'
			--sql="insert into filelog values (".. log.id ..',"'..log.user .. '",'.. log.time ..','.. log.contentlength ..',"'..log.content..'")'
		else
			sql='update filelog set user="'..log.user..'",date='.. log.time ..',contentlength='.. log.contentlength ..' where id=' ..log.id
		end
	
	else
		local res1, err1, errno1, sqlstate1 = dbmysql:query("select * from licenselog where sn="..log.sn)
		if not res1 then
			ngx.say("bad result: ", err1, ": ", errno1, ": ", sqlstate1, ".")
			return res1
		end
		if not next(res1) then
		sql = "insert into licenselog values ("
			.. log.id .. ',"'.. log.info .. '","'.. log.user .. '",'.. log.time .. ',"'.. log.sn .. '","'.. log.mac .. '","'.. log.lang ..'","'..log.mullang..'","'..log.func..'",'.. log.contentlength ..',"'..log.content..'")'
		else
		sql = 'update licenselog set id='.. log.id ..',machinetype="'..log.info..'",user="'..log.user..'",date='.. log.time ..',mac="'..log.mac..'",lang="'..log.lang..'",mullang="'..log.mullang..
			'",func="'..log.func..'",contentlength='.. log.contentlength ..',content="'..log.content..'" where sn="'..log.sn..'"'
		end
	end
	print(sql)
	local res, err, errno, sqlstate = dbmysql:query(sql)
	if not res then
                ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
                return res
	end
end

function mysql_query(condition,flag)      --select  * from licenselog
	print(type(condition))
	if type(condition)~="table" then
		--ngx.say("condition  should  be table")
	end
	local sql = ' '
	for k,v in pairs(condition) do
		if sql==' ' then
			sql=v
		elseif v~=nil then
			sql=sql.." and "..v
		end
	end
	if string.find(flag,'licenselog')~=nil then						--这个地方可以复用
		sqlstr="select * from licenselog where ("..sql..")"
		if next(condition)==nil then
			sqlstr="select * from licenselog"
		end
	end
	if string.find(flag,'zipfile')~=nil then
		sqlstr="select * from filelog where ("..sql..")"
		if next(condition)==nil then
			sqlstr="select * from filelog"
		end
	end
	if string.find(flag,'user')~=nil then
		sqlstr="select * from user where ("..sql..")"
		if next(condition)==nil then
			sqlstr="select * from user"
		end
	end
	print("***********sqlstr:",sqlstr)
	local res, err, errno, sqlstate =
                dbmysql:query(sqlstr)
	if not res then
		print("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
                ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
                return
	end
	print("query res type is :",type(res))
	return  res
end
--[[
local ok, err = dbmysql:set_keepalive(0, 100)
if not ok then
	ngx.say("failed to set keepalive: ", err)
	return
end
]]