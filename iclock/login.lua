local json = require"json"
local date = require( 'os' ).date
local table = require("table")
local resp = require"resp"
local lfs = require"lfs"
local obj_text = resp.obj_text
local send_obj = resp.send_obj
local send_error = resp.send_error
local unesc = ngx.unescape_uri
local null = ngx.null
local utils = require "utils"
local printTbl = utils.print_table
local Redis = require("resty.redis")
local db_bak=require"db_bak"

local time_format_iso="%Y-%m-%d %H:%M:%S"  --2012-03-21 19:31:02


local redis = Redis:new()

local function set_redis(redis)
    redis:set_timeout(1000) -- 1 sec
    local ok, err = redis:connect("127.0.0.1", 6379)
    if not ok then
        ngx.say("failed to connect: ", err)
        return
    end
end
--set_redis(redis)




local tinsert=table.insert
local unesc=ngx.unescape_uri
local iclock_path=ngx.var.iclock_path

local post={}
local s=ngx.var.request_body or ""
for k,v in s:gmatch("([^&]-)=([^&]*)") do
    post[unesc(k)]=unesc(v)
end
local username=(post.username or "")
local password=(post.password or "")
print("&&&&&:"..username.." *****password:"..password.."*****ngx.var.remote_addr:"..ngx.var.remote_addr)
local SESSION_EXPIRE = 2 * 60 * 60 --session失效时间2小时
local session
local i=nil




--{ user : { name = 'admin' , pwd = '123456' } }


--检查用户名/密码检验
--return : table为true ,nil 为false
local function check()
	local user_str, err=redis:get( 'user' )
	if user_str == null then
		local info = { name = 'admin', pwd = '123456' }
		user_str = json.encode( info )
		redis:set( 'user', user_str )
	end

	local user
    if pcall( function() user = json.decode( user_str ) end ) then
		if user.name == username and user.pwd == password then
			return user
		end
    end
	return nil
end

local function check_admin(username,password)
	local condition={}
	condition.username='name="'..username..'"' or ''
	condition.password='password="'..password..'"' or ''
	db_bak.init()
	local list=db_bak.mysql_query(condition,'user')
	return list
	
end

--创建session
local function create_session( user )  --根据用户名创建session_id 并返回，写入session文件
    --登录用户名 设备序列号 设备目录 用户登录时间 用户IP地址
    math.randomseed(os.time())
    local session_id
    local set={}
    local dev={}
    repeat
        session_id = os.time() .. math.random( 999999999 )
    until true

    local session={
        username = user.name,
        data_dir = iclock_path,
        login_time = os.date( "%Y-%m-%d %H:%M:%S", os.time() ),
        remote_addr = ngx.var.remote_addr,
        session_id = session_id
    }
    print(session.username,session.data_dir,session.login_time,session.remote_addr,session.session_id)
	--保存登录并且设备失效时间为2小时后失效
--	redis:set( 'session_' .. session_id, json.encode( session ) )
--	redis:expire( 'session_' .. session_id, SESSION_EXPIRE )
    return session
end


function fun()
	if username=="" or password=="" then
        return -3, "必须输入用户名和密码！"
	end

	local user = check_admin(username,password)
--[[	for k,v in pairs(user) do
		print('K:'..type(k)..'V:'..type(v)..'privilege:'.. v.privilege)
	end]]
	if not next(user) then
		return -1, '用户名与密码不匹配！'
	else
		if user[1].privilege~=1 then
			return -1,'非法管理员'
		end
		session = create_session( user )
	end

    local login_url = ngx.var.arg_next
    local ld={
        last_login=session.login_time,
        last_ip=session.remote_addr,
        _id=session.session_id,
        company=session.company
        };

	ld.username=session.username
	local login_url = '/webPage/index.html'
---[[
	ngx.say('<html><head><META HTTP-EQUIV="Set-Cookie" CONTENT="session_id='.. session.session_id ..'; expires=Friday, 31-Dec-20 23:59:59 GMT; path=/">'..
			'<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' ..'<META HTTP-EQUIV="Set-Cookie" CONTENT="user='.. username ..'; expires=Friday, 31-Dec-20 23:59:59 GMT; path=/">'..
            '<script>top.location.href="'.. login_url ..'";</script>' ..
            '<META HTTP-EQUIV="Refresh" CONTENT="0;URL='..login_url..'"></head><body>Login as: ' .. username .. '</body></html>')

    --]]
	return 0, "OK"

end

local ret,msg=fun()
if ret == 0 then
	return
else
	local cur = lfs.currentdir()
    local fn = "html/webPage/loginError.html"
    local f=io.open( fn, "r" )
    local content
    if f then
        content = f:read( 2*1024*1024 )
        f:close()
		local info = string.gsub( content, '请输入正确的用户名和密码 !', msg )
		return ngx.say( info )
    else
        return
    end

end
