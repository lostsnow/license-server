local ngx = require"ngx"
local json = require"json"
local table = require("table")
local pairs = pairs
local ipairs = ipairs
local type = type
local G = _G

module("resp")

function obj_text(obj, sep)
    if not (type(obj)=='table') then
        if type(obj)=='boolean' then
            return obj and 'true' or 'false'
		else if type(obj)=='userdata' then
			return ""
        else
            return ""..obj
        end end
    end
    local dt={}
    for k, v in pairs(obj) do
        if type(v)=='table' then
            dt[1+#dt]=k..'={'..obj_text(v)..'}'
		else if v==ngx.null then
			dt[1+#dt]=k.."=null"
        else
            dt[1+#dt]=k..'='..(v or "null")
        end end
    end
    return table.concat(dt, sep or "\t")
end

function send_lic(data)
	ngx.header['Content-Type']='application/octet-stream'
	ngx.header['Content-Length']=#data+17
	ngx.say(data)
end

--把一个对象（table）按照指定格式序列化并发送到客户端
function send_obj(object)
    local fmt=ngx.var.arg_format or 'json'  --默认为json格式
    local data
	if not object then
	    if fmt:find('text') then
        	ngx.header['Content-Type']='text/plain'
			data=""
		else
        	ngx.header["Content-Type"]='application/json; charset=utf-8'
			data="{}"
		end
	else
    if fmt:find('json') then
        local dt, dk={}, {}
        for k, v in pairs(object) do
            if type(k)=='number' then
                dt[k]=v
            else
                dk[k]=v
            end
        end
        if #dt>0 then dk['data_array']=dt end
        data=json.encode(dk)
        ngx.header["Content-Type"]='application/json; charset=utf-8'
    else
        local dt, dk={}, {}
        for k, v in pairs(object) do
            if type(k)~='number' then
                dt[1+#dt]=k..'='..obj_text(v)
            else
                dk[k]=v
            end
        end
        if #dk>0 then
            if #dt>0 then data=table.concat(dt, "\t").."\n\n" else data="" end
            for k, v in ipairs(dk) do
                data=data..obj_text(v).."\n"
            end
        else
            data=table.concat(dt, "\n").."\n"
        end
        ngx.header['Content-Type']='text/plain'
    end
	end
    ngx.header['Content-Length']=#data
    ngx.say(data)
end

function send_error(code, message)
    send_obj({error_code=code, message=message})
end    

