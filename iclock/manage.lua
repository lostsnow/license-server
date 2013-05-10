local json = require"json"
local resp = require"resp"
local db_bak=require"db_bak"
local unesc = ngx.unescape_uri

local handle = {}

function readLogFromMysql(condition,flag)
	db_bak.init()
	local list=db_bak.mysql_query(condition,flag)
	return list
end 

--{id int(10), machinetype char(10), user varchar(5), date int(10) , sn char(15), mac char(18), lang char(4)} --数据库存储形式
testdata='{"size":3,"pages":1,"license":[{"id":1,"machinetype":"M880","user":"芸陞","date":123456789,"sn":"1234567890987","MAC":"00:AA:22:33:DD:FF","lang":"ES"},\
{"id":2,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":3,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"},  \
{"id":4,"machinetype":"F18","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":5,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":6,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":7,"machinetype":"UA200","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":8,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"},  \
{"id":9,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":10,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":11,"machinetype":"IFACE301","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":12,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":13,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":14,"machinetype":"Q18","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":15,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":16,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"},  \
{"id":17,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":18,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"},  \
{"id":19,"machinetype":"F18","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":20,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":21,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":22,"machinetype":"UA200","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":23,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"},  \
{"id":24,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":25,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":26,"machinetype":"IFACE301","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":27,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":28,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":29,"machinetype":"Q18","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":30,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":31,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":32,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":33,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"},  \
{"id":34,"machinetype":"F18","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":35,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":36,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":37,"machinetype":"UA200","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":38,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"},  \
{"id":39,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":40,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":41,"machinetype":"IFACE301","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":42,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":43,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":44,"machinetype":"Q18","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":45,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":46,"machinetype":"iclock360","user":"奈克斯","date":123456790,"sn":"1234567890988","MAC":"00:AA:22:33:DD:00","lang":"ES"}, \
{"id":47,"machinetype":"U160 ","user":"小小","date":123456791,"sn":"1234567890988","MAC":"00:AA:22:33:DD:F0","lang":"ES"}]}'


local function do_page( list, page, skip, total )
	local s_pos = ( page - 1 ) * skip + 1
	local e_pos = page * skip
	local pages = math.floor( total / skip )
	if total % skip ~= 0 then
		pages = pages + 1
	end
	if e_pos > total  then
		e_pos = total
	end

	if s_pos > total then
		return '开始位置已经超过记录总数！'
	end
	local result = {}
	if type( list ) == 'table' and #list == total then
		for i = s_pos, e_pos, 1 do
			table.insert( result, list[ i ] )
		end
	end
	return result, pages, s_pos, e_pos
end


function handle.GET_license(var)
	local condition={}
	condition.sn="sn="..ngx.var.arg_sn or ""
	local list=readLogFromMysql(condition,'licenselog')
	page=1
	local skip = ngx.var.arg_skip or 10
	local result={} 
	local total=0
	if list~=nil then
		total=#list
	end
	result.license, result.pages=do_page(list,page,skip,total)
	result.size=total
	if #(result.license)~=1 then
		return ngx.say("get license failed!")
	end
	ngx.say(result.license[1].content)
	return
end

function handle.GET_zipfile(var)
	local condition={}
	if ngx.var.arg_id~=nil then
		condition.id =  "id="..tostring(ngx.var.arg_id)
	end
	if ngx.var.arg_user~=nil then
		condition.user =  "user='"..ngx.unescape_uri(ngx.var.arg_user).."'"
	end
	page=ngx.var.arg_page or 1
	local skip = ngx.var.arg_skip or 10
	local result={} 

	local list = readLogFromMysql(condition,'zipfile')    --从数据库获取匹配的许可记录
--	print("type of list is:",type(list))
--[[	
	if pcall(function() info=json.decode(testdata) end) then
			--resp.send_obj(result)
	end	
	list=info.license    --从测试数据中直接获得
]]
	                                                           --如果查询结果为nil  必须返回提示  否则出错!!!!
	local total=0
	if list~=nil then
		total=#list
	end
	result.license, result.pages=do_page(list,page,skip,total)
	result.size=total
	print(result.size,result.pages,type(result.license),#result.license)

	
	resp.send_obj(result)
end

function handle.GET_user(var)
	local condition={}
	if ngx.var.arg_name~=nil then
		condition.name =  "name='"..ngx.unescape_uri(ngx.var.arg_name).."'"
	end
	page=ngx.var.arg_page or 1
	local skip = ngx.var.arg_skip or 10
	local result={} 

	local list = readLogFromMysql(condition,'user')    --从数据库获取匹配的许可记录

	                                                           --如果查询结果为nil  必须返回提示  否则出错!!!!
	local total=0
	if list~=nil then
		total=#list
	end
	result.license, result.pages=do_page(list,page,skip,total)
	result.size=total
	print(result.size,result.pages,type(result.license),#result.license)

	
	resp.send_obj(result)
end




function handle.GET_log(var)
	local condition={}
	if ngx.var.arg_sn~=nil then
		condition.SNs =  "sn='"..ngx.var.arg_sn.."'"
	end
	if ngx.var.arg_mactype~=nil then
		condition.info =  "machinetype='"..ngx.var.arg_mactype.."'"
	end
	if ngx.var.arg_id~=nil then
		condition.id =  "id="..tostring(ngx.var.arg_id)
	end
	if ngx.var.arg_user~=nil then
		condition.user =  "user='"..ngx.unescape_uri(ngx.var.arg_user).."'"
	end
	if ngx.var.arg_mac~=nil then
		condition.mac= "mac='"..ngx.var.arg_mac.."'"
	end
	page=ngx.var.arg_page or 1
	local skip = ngx.var.arg_skip or 10
	local result={} 

	local list = readLogFromMysql(condition,'licenselog')    --从数据库获取匹配的许可记录
--	print("type of list is:",type(list))
--[[	
	if pcall(function() info=json.decode(testdata) end) then
			--resp.send_obj(result)
	end	
	list=info.license    --从测试数据中直接获得
]]
	                                                           --如果查询结果为nil  必须返回提示  否则出错!!!!
	local total=0
	if list~=nil then
		total=#list
	end
	result.license, result.pages=do_page(list,page,skip,total)
	result.size=total
	print(result.size,result.pages,type(result.license),#result.license)

	resp.send_obj(result)
end


function handle.POST_changePwd()
	local post = {}
	ngx.req.read_body()
	local s = ngx.var.request_body or ""
	for k,v in s:gmatch("([^&]-)=([^&]*)") do
		post[unesc(k)]=unesc(v)
	end
	local username=ngx.var.arg_name or ''
	local old = ( post.pwd_old or "" )
	local new_1 =( post.pwd or "" )
	local new_2 = ( post.pwd_again )
	if new_1 ~= new_2 or #new_1 < 6 then
		return resp.send_obj( { ret = -1, msg = '新旧密码必须一致，并且长度不得小于6位！' } )
	end
	local condition={}
	condition.username='name="'..username..'"' or ''
	db_bak.init()
	local list=db_bak.mysql_query(condition,'user')
	user=list[1]
	print(type(old),old,type(user.password),user.password)
	if user and user.password == old then
		user.password = new_1
		db_bak.init()
		db_bak.mysql_chgpwd(user)
		return resp.send_obj( { ret = 0, msg = '成功！'} )
	else
		return resp.send_obj( { ret = -1, msg = '旧密码不正确！' } )
	end
end

local f_name = ngx.var.request_method..'_'..ngx.var[1]
local fun = handle[f_name]

if fun then 
    fun(ngx.var)  
else  
    return resp.send_error(404, "ERROR: invalid web request handle '"..f_name.."'")
end
