module("utils", package.seeall)

local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next


function print_table(root, printl)
    if root == "" or next(root) ==nil   then
      return  print("{}")
    end
    local cache = { [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                table.insert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                table.insert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
            else
                table.insert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return table.concat(temp,"\n"..space)
    end
    if printl then
        print(_dump(root, "",""))
    else
        print(_dump(root, "",""))
    end
end

function compare_table(t1, t2)
    for k,v in pairs(t1) do
        if type({})==type(v) then
            return compare_table(v, t2[k])
        else
            if not (v==t2[k]) then
                return false
            end
        end
    end
    return true
end

--local lfs=require'lfs'
--[[
  读取指定目录内的文件列表
  @dir_path  要读取的目录
  @pattern   匹配的文件名模式。如果设置了该参数，只有满足指定模式的文件名才能读取
  @sub_dir   是否进入子目录。如果设置为 true 则进入子目录读取
  @files     初始的文件列表。如果设置了该参数，则把读取到的文件添加到该列表中
  返回文件名列表
]]
function get_dir_files(dir_path, pattern, sub_dir, files)
    -- print("get dir files: "..dir_path)
    files=files or {}
    if lfs.attributes(dir_path, "mode")~="directory" then
        print(dir_path .. " is not a directory: "..(lfs.attributes(dir_path, "mode") or 'nil'))
        return {}
    end
    for f in lfs.dir(dir_path) do
        local file=dir_path.."/"..f
        if f:sub(1,1)=="." then
            -- ignore
        elseif lfs.attributes(file,"mode") == "file" then
            if not pattern or string.find(f, pattern) then table.insert(files, file) end
        elseif lfs.attributes(file,"mode")== "directory" then
            if sub_dir then get_dir_files(file, sub_dir, files) end
        end
    end
    return files
end

function get_dir_dirs(dir_path, pattern, sub_dir, files)
    -- print("get dir files: "..dir_path)
    files=files or {}
    for f in lfs.dir(dir_path) do
        local file=dir_path.."/"..f
        if f:sub(1,1)=="." then
            -- ignore
        elseif lfs.attributes(file,"mode") == "file" then
            -- ignore
        elseif lfs.attributes(file,"mode")== "directory" then
            if not pattern or string.find(f, pattern) then table.insert(files, file) end
            if sub_dir then get_dir_files(file, sub_dir, files) end
        end
    end
    return files
end

--time1,time2时间类型为"2011-09-09 20:30:09"
--返回两时间相减得到的秒数
function sub_datetime(time1,time2)
	if time1== nil or time1=='' or time2==nil or time2=='' then
        return ''
    end
    local y1,m1,d1,h1,mi1,s1=string.match(time1,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    local y2,m2,d2,h2,mi2,s2=string.match(time2,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")

    local sub=os.time({year=y1,month=m1,day=d1,hour=h1,min=mi1,sec=s1})-os.time({year=y2,month=m2,day=d2,hour=h2,min=mi2,sec=s2})
    return sub
end

function copy_table(sch)
    if type(sch) ~= "table" then
        return nil
    end
    local new_tab = {}
    for i,v in pairs(sch) do
        local vtyp = type(v)
        if (vtyp == "table" ) then
            new_tab[i] = copy_table(v)
        else
            new_tab[i] = v
        end
    end
    return new_tab
end

--time字符串格式为“年-月-日”或“时：分：秒” ……
--det为分隔符
function detach_time(time,det)

    local n = string.find(time,det)
    local year = string.sub(time,1,n-1)
    local month = string.sub(time,n+1)
    n= string.find(month,det)
    local day = string.sub(month,n+1)
    month = string.sub(month,1,n-1)
    return year,month,day
end


--用来判断year年month月最后一天是几号
function last_day(year,month)
    local day_1={'01','03','05','07','08','10','12'}

    for k1,v1 in pairs(day_1) do
        if month == v1 then
            return 31
        end
    end
    if tonumber(month) == 2 then
        if  (0 == year%400) or ((0 == year%4) and (0 ~= year%100))  then
            return 29
        else
            return 28
        end
    else
        return 30
    end

end

--准确的得到表的长度
function length(data_table)
    if not data_table then return 0   end
    if type(data_table)~='table' then return 0 end
    local len = 0
    for k,v in pairs(data_table) do len = len+1 end
    return len
end

--去掉字符串左侧的空格
function left_trim(str)
  if type(str)~='string' then return str end
  local result_str=str
  for i=1,string.len(str),1 do
    local temp_str = string.sub(str,i,i)
    if temp_str ==" " then result_str=string.sub(str,i+1)
    else return result_str end
  end
  return result_str
end

--去掉字符串右侧的空格
function right_trim(str)
  if type(str)~='string' then return str end
  local result_str=str
  for i=string.len(str),0,-1 do
    local temp_str = string.sub(str,i,i);
    if temp_str == " " then result_str = string.sub(str,1,i-1)
    else return result_str  end
  end
  return result_str
end

--去掉字符串两侧的空格
function trim(str)
  if type(str)~='string' then return str end
  local result_str = "";
  result_str = left_trim(str)
  result_str = right_trim(result_str)
  return result_str
end

--使用分隔符sep分隔字符串str得到表
function split(str,sep,max)
  if type(str)~='string' or type(sep)~='string' then return str end
  str = trim(str)
  sep = trim(sep)
  local result_tab={}
  local index_num=1
  for i=1,string.len(str)+1,1 do
    local temp_num = string.find(str,sep)
    if temp_num~= nil  then
      local temp_str=string.sub(str,1,temp_num-1)
      temp_str = trim(temp_str)
      if temp_str~=nil and string.len(temp_str)~=0 and temp_str~=sep then
        table.insert(result_tab,temp_str)
        index_num = index_num+1
      end
      i = temp_num
      str = string.sub(str,temp_num+1)
    else
      if str~=nil and string.len(trim(str))>0 then table.insert(result_tab,str)--result_tab[index_num] = str
      end
      break
    end
	if max and max>0 and #result_tab==max then table.insert(result_tab,string.sub(str,i+1)) break end
  end
  return result_tab
end



function timeout(sec)
	local n,s,s0 = 0
	local t=os.date('%Y-%m-%d %H:%M:%S',os.time())
	local t2=addSec(t,sec)
	while true do
		t=os.date('%Y-%m-%d %H:%M:%S',os.time())
		if t == t2 then
			break;
		end;
	end
end

function addSec(datetime,att)
    if datetime==nil then
        return ""
    end
    if att=="" or att==nil or att==0 then att=1 end
    local n = string.find(datetime,' ')
    local date = string.sub(datetime,1,n-1)
    local time = string.sub(datetime,n+1)
    local hour,min,sec
    local y,m,d
    hour,min,sec=string.match(time,'(%d+):(%d+):(%d+)')
    y,m,d=string.match(date,'(%d+)-(%d+)-(%d+)')
    return os.date("%Y-%m-%d %H:%M:%S",os.time({year=y,month=m,day=d,hour=hour,min=min,sec=sec})+att)
end

function splitline(str,spliter)
	local data={}
	for k,v in string.gmatch(str,"([^\n"..spliter.."%s]*[%w]+)"..spliter.."([^\n]+)") do--(str,"(%w+)=([^=,]+)") do "(%w+)=([%w,:,;,-]*)"  "([%w%p]+)=([^\n]+)"
		data[k]=v
	end
	return data
end

function join(str,joiner)
	local str = string.gsub(str, "(.)", "%1"..joiner)
	local last=string.sub(str,#str)
	if string.match(last,'%c')==last then
		str=string.sub(str,'0',#str-1)
	end
	return str
end

function charset(str, fChar, tChar)
	local iconv = require "iconv_ffi"
	c = iconv.open( tChar, fChar )
	text, len = iconv.iconv( c, str )
	iconv.close( c )
	return text
end

--[[
--得到字符串的长度统计出字母、数字、汉字符号的个数
function length(str)
    local total=0--字母和符号的长度
    local total_c=0--字符串中汉字的个数
    for k in string.gmatch(str,"[%(%)%:%,%!%.%?%+%-%_%/%\%w%s%d%{%}]+") do
        total=total + #k
    end
    total_c=math.ceil((#str-total)/3)
    local all=0
    all=total + total_c
    return all
end
]]
function DtoX( cardNum )
	local num = string.format( '%x', cardNum )
	if #num < 8 then
		num = string.rep( 0, 8-#num )..num
	end

	local tmp = {}
	for i = 1, 8, 2 do
		table.insert( tmp, string.sub( num, i, i+1 ))
	end
	num = tmp[4]..tmp[3]..tmp[2]..tmp[1]..'00'
	return num
end

function XtoD( cardNum )
	local tmp = {}
	for i = 1, 8, 2 do
		table.insert( tmp, string.sub( cardNum, i, i+1 ))
	end

	local num = tmp[4]..tmp[3]..tmp[2]..tmp[1]
	num = '00'..string.format( '%d', '0x'..num )
	return num
end





