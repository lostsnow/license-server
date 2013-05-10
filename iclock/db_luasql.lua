require "luasql.mysql"

module("db_luasql", package.seeall)
env = assert (luasql.mysql())

con = assert (env:connect("lqw", "root", "123456", "127.0.0.1", 3306))
print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")

function mysql_create()
	res = assert (con:execute[[
	CREATE TABLE licenselog(   
	id int(10),
	machinetype char(10),
	user varchar(10),
	date int(20),
	sn varchar(20),
	mac varchar(20),
	lang char(10)
	)
	]])
	return res
end

function mysql_insert(log)
	res=assert(con:execute(string.format([[
    INSERT INTO licenselog                                         
    VALUES ('%d', '%s','%s','%d','%s','%s','%s')]],log.id,log.machinetype,log.user,log.date,log.sn,log.mac,log.lang)))
    return	res
end


function mysql_query(condition)
	if type(condition)~=table then
		--ngx.say("condition  should  be table")
	end
	local sql
	local list={}
	for k,v in pairs(condition) do
		print(sql,v)
		if type(sql)=="nil" then
			sql=v
		elseif v~=nil then
			sql=sql.." and "..v
		end
	end
	local sqlstr="select * from licenselog where ("..sql..")"
	print(sqlstr)
	local cur=assert(con:execute(sqlstr))
	local row=cur:fetch({},"a")
	print("row:",type(row))
	while row do
	print("row1:",type(row))
		table.insert(list,row)
		row=cur:fetch(row,"a")
	end
	print(type(list))
	return list
end

function mysql_close()
	con:close()
	env:close()
end

		--test mysql
--[[
local condition={}
local log={}
	log.id =1000
	log.machinetype="M880"
	log.user="СС"                               --注意汉字写入的格式为 Code Page Property
	log.date=1234567890
	log.sn="1234567890987"
	log.mac="00:AA:99:FF:EE:88"
	log.lang="SE"
table.insert(condition,"user='СС'")

res = con:execute"DROP TABLE licenselog"
mysql_create()
mysql_insert(log)
list = mysql_query(condition)
print(type(list))
for k,v in pairs(list) do
	print(type(v))
	for i,j in pairs(v) do
		print(j)
	end
end
--mysql_close()
]]