
--[[
local Redis = require("resty.redis")
local redis = Redis:new()

local function  set_redis(redis)
    redis:set_timeout(1000) -- 1 sec

    local ok, err = redis:connect("127.0.0.1", 6379)
    if not ok then
        ngx.say("failed to connect: ", err)
        return
    end
end
set_redis(redis)

local function parse_session( cookies )
    for k, v in string.gmatch( cookies, "([^;= ]+)=(%w+)" ) do
        if k == 'session_id' then
            return v
        end
    end
end


local session_id = parse_session( ngx.var.http_cookie or "" )
if session_id ~= nil then
	redis:del( 'session_' .. session_id )
end
]]
local url = "/../webPage/login.html"
url = "/login/"
print('@@@@@@@@@@@@', url)
ngx.location.capture( url )

