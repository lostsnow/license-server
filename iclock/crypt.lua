local licence=require"license"
local lfs=require"lfs"
local db=require"db"
local db_bak=require"db_bak"



local date=require("os").date
local date1=date("%Y-%m-%d")
--print("date1:"..date1)
local date2=date("%Y-%m-%d %H:%M:%S")
--print("date2:"..date2)

module("crypt", package.seeall)



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

function getmacstr(mac)
	local t=split(mac,':')
--	return t[1]..t[2]..t[3]..t[4]..t[5]..t[6]
	return string.upper(t[1])..string.upper(t[2])..string.upper(t[3])..string.upper(t[4])..string.upper(t[5])..string.upper(t[6])
end

function getromidstr(romid)	--4900000044F86A44
	ptr=1
	local result={}
	for i=1,8 do
		result[i]=string.sub(romid,ptr,ptr+1)
		ptr=ptr+2
		print(i,result[i])
	end
	return result[8]..result[7]..result[6]..result[5]..result[4]..result[3]..result[2]..result[1]
end

function Str16ToNum10(v)
	local num =  tonumber("0x" .. v)
	return num
end

function Num10ToStr16(v)
	local s = string.format("%02x",v)
	return string.upper(s)
end

function getlist(mac1_str,mac2_str)
	local mac1_num={}
	local mac2_num={}
	local maclist = {}
	for i=1,6 do
		mac1_num[i] = Str16ToNum10(mac1_str[i])            --mac地址由十六进制string转为十进制number
		mac2_num[i] = Str16ToNum10(mac2_str[i])
	end
	local firstmac=mac1_str[1]..':'..mac1_str[2]..':'..mac1_str[3]..':'..mac1_str[4]..':'..mac1_str[5]..':'..mac1_str[6]			--把第一个mac地址加入到table中
	table.insert(maclist,firstmac)
	num=(mac2_num[4]-mac1_num[4])*256*256+(mac2_num[5]-mac1_num[5])*256+(mac2_num[6]-mac1_num[6])
	if num >0 then
	for j=1,num do
		if mac1_num[6]<255 then
			mac1_num[6]=mac1_num[6]+1
		else
			mac1_num[6]=0
			if mac1_num[5]<255 then
				mac1_num[5]=mac1_num[5]+1
			else
				mac1_num[5]=0
				mac1_num[4]=mac1_num[4]+1
			end
		end
		local macstr = Num10ToStr16(mac1_num[1])..':'..Num10ToStr16(mac1_num[2])..':'..Num10ToStr16(mac1_num[3])..':'..Num10ToStr16(mac1_num[4])..':'..Num10ToStr16(mac1_num[5])..':'..Num10ToStr16(mac1_num[6])
		table.insert(maclist,macstr)
	end
	end
	return num+1,maclist
end
--[[
	--现在的范围为后面3个地址
	--获取mac地址列表
]]
function getmaclist(mac1,mac2)        
	local mac1_str=split(mac1,':')
	local mac2_str=split(mac2,':')
	local number,maclist = getlist(mac1_str,mac2_str)
	return number,maclist
end

--[[
local str1="01:02:03:04:00:2F"
local str2="01:02:03:04:00:34"

num,list=getmaclist(str1,str2)
print(num)
for k,v in pairs(list) do
	print(v)
end
]]
--[[

	--配置许可设置参数

                      -- S      2013-12-29   
function setparam(lang,date)
	local set_date = license.SetLicValidPeriodToLic(date)
	local set_lang = license.SetDefaultLngToLic(lang)
	local set_mul = license.SetMultLngSupportToLic("ES")
	local set_func = license.SetMachineFuncToLic("~IsOnlyRFMachine=0:fingerFunOn=1")
	return set_date,set_lang,set_sn,set_mul,set_func
end


	--根据mac地址生成许可文件

function makelicense(mac1,mac2,lang,date,basepath,platform,machinetype)
	local num,list = getmaclist(mac1,mac2)
	for k,v in pairs(list) do
		local a,b,c,d,func = setparam(lang,date)
		local macstr =  getmacstr(v)
		local LicFileName = basepath..platform..'/'..machinetype..'/'..date.."/License/"..macstr..".lic"
		license.SetMachineSNToLic("2068042200068")
		local e = license.SetMACToLic(v,#v)
		local en = license.EncodeLicenseFile(LicFileName)
		print(v,a,b,c,d,func,e,en)
		--遍历文件夹下所有文件，除去文件夹，进行单个文件签名
		local index=1
		for file in lfs.dir(basepath..platform..'/'..machinetype..'/'..date..'/') do
			if file~="." and file~=".." then
			local f = basepath..platform..'/'..machinetype..'/'..date..'/'..file
				local attr = lfs.attributes (f)
				if attr.mode~="directory" then
					LicFileName = basepath..platform..'/'..machinetype..'/'..date.."/License/"..macstr..".lic"
					local sign = license.SignFileToLicense(f,LicFileName, v)
					print("return sign:",sign,f)
					index=index+1
				end
			end
		end
	end
end


local basepath = "F:/makelicense/"
local platform = "ZEM510"
local machinetype = "iclock660"
local date = "2013-12-21"
local mac1="00:17:61:00:00:02"
local mac2="00:17:61:00:00:06"
local lang = "S"
makelicense(mac1,mac2,lang,date,basepath,platform,machinetype)

]]

function GetMacFromFile(fileName)
	local ret = license.DecodeLicenseFile(fileName)
	print("******ret:"..ret)
	if ret<0 then
		return -1,"DecodeLicenseFile failed"
	end
	local strMac = license.GetMACFromLic(strMac,17)
	return 0,strMac
end

function setparam(param)
	if param.enddate~=nil then
		set_date = license.SetLicValidPeriodToLic(param.enddate)
		print("88888set_date",set_date,param.enddate)
	end
	if param.lang~="" then
		set_lang = license.SetDefaultLngToLic(param.lang)
		print("88888set_lang",set_lang,param.lang)
	end
	if param.mullang~="" then
		set_mul = license.SetMultLngSupportToLic(param.mullang)
		print("88888set_mul",set_mul,param.mullang)
	end
	if param.func~="" then
		set_func = license.SetMachineFuncToLic(param.func)
	end
	return set_date,set_lang,set_mul,set_func
end


function makelicense(device1,device2,param,srcpath,destpath,fileflag)
	local num,list = getmaclist(device1.mac,device2.mac)
	local sn=tonumber(device1.sn)
	local count=0
	for k,v in pairs(list) do
		count=count+1
		local set_date,set_lang,set_mul,set_func = setparam(param)
		local macstr =  getmacstr(v)
		local LicFileName = destpath..macstr..".lic"
		local sn_set = license.SetMachineSNToLic(tostring(sn))
		param.sn=tostring(sn)
		param.mac=v
		sn=sn+1
		if fileflag~=1 then
			local mac_set = license.SetMACToLic(v,#v)
		end
		local licret = license.EncodeLicenseFile(LicFileName)
	--	print(v,set_date,set_lang,set_mul,set_func,sn_set,mac_set,licret)
		--遍历文件夹下所有文件，除去文件夹，进行单个文件签名
		local index=1
		local romid = license.GetROMIDFromLic(romid)
		print("romid:"..romid)
		v2=getromidstr(romid)
		for file in lfs.dir(srcpath) do
			if file~="." and file~=".." then
				if string.find(file,'language')~=nil then
					if string.find(file,'language'..param.lang..'.tgz')~=nil then		--语言包只签名对应lang的文件，其他的语言包忽略
					local f = srcpath..file
					local attr = lfs.attributes (f)
					if attr.mode~="directory" then                                                 
						LicFileName = destpath..macstr..".lic"
						local sign = license.SignFileToLicense(f,LicFileName, v2)	--4900000044F86A44
					--	local sign = license.SignFileToLicense(f,LicFileName, '446AF84400000049')
				--		print("return sign:",sign,f)
						index=index+1
					end
					end
				else
					local f = srcpath..file
					local attr = lfs.attributes (f)
					if attr.mode~="directory" then                                                 --设置过滤掉文件夹
						LicFileName = destpath..macstr..".lic"
						local sign = license.SignFileToLicense(f,LicFileName, v2)
						print("return sign:",sign,f)
						index=index+1
					end
				end
			end
		end
		
		local fh3,msg3=io.open(LicFileName,"r+b")            --单个文件的时候才能返回许可的内容 
		if fh3==nil then
			print("open mac.lic failed "..msg3)
			return ngx.say("open mac.lic failed "..msg3)
		end
		local data3=fh3:read("*a")
		print("send lic lenght :"..#data3)
		resp.send_lic(data3)
		param.contentlength=#data3
		param.content=data3
		db_bak.init()
		db_bak.mysql_insert(param)
		fh3:close()
	end
	return count
end

--test OK
--[[
local device1={sn="1234567890123",mac="00:17:61:00:00:02"}
local device2={sn="1234567890123",mac="00:17:61:00:00:02"}
local param={enddate="2013-12-12",lang="S",multlang="ES",func="~IsOnlyRFMachine=0:fingerFunOn=1"}

local srcpath="F:/new-server/data/999/extr/"
local destpath="F:/new-server/data/999/license/"

local num = makelicense(device1,device2,param,srcpath,destpath)
]]
--print "test crypt end!"
