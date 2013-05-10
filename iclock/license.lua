local ffi = require"ffi"
local type = type
local print = print
local tostring = tostring
local string = string
local table=table
local pairs=pairs
local tonumber=tonumber
module("license", package.seeall)

ffi.cdef[[
	int SetMACToLic(char *strMac, int maxLen);
	int SetMachineSNToLic(const char *strMachineSN);
	int SetMultLngSupportToLic(const char *strMultLngSupport);
	int SetDefaultLngToLic(const char *strDefaultLng);
	int SetMachineFuncToLic(const char *MachineFunc);
	int SetLicValidPeriodToLic(const char *strDate);
	int EncodeLicenseFile(const char *fileName);
	int SignFileToLicense(const char *sigFileName,const char *licFileName, const char *keyValue);
	int DecodeLicenseFile(const char *fileName);
	int GetMACFromLic(const char *strMac,int len);	
	int GetROMIDFromLic(const char *romid);
]]

local crypt = ffi.load("crypt.dll")

function DecodeLicenseFile(fileName)
	local str = fileName..'\0'
	local strfilename = ffi.new("char["..#str.."]",str)
	return crypt.DecodeLicenseFile(strfilename)
end

function GetROMIDFromLic(romid)
	local romid= ffi.new("char[?]",16)
	crypt.GetROMIDFromLic(romid)
	return ffi.string(romid,16)
end

function GetMACFromLic(strMac,len)
	local strMac= ffi.new("char[?]",17)
	crypt.GetMACFromLic(strMac,len)
	return ffi.string(strMac,17)
end

function SetMACToLic(strMac, maxLen)
	local str=strMac..'\0'
	local strmac = ffi.new("char["..#str.."]",str)
	return crypt.SetMACToLic(strmac,maxLen)
end

function SetMachineSNToLic(strMachineSN)
	local str=strMachineSN..'\0'
	local strmachinesn =  ffi.new("char["..#str.."]",str)
	return crypt.SetMachineSNToLic(strmachinesn)
end

function SetMultLngSupportToLic(strMultLngSupport)
	local str=strMultLngSupport..'\0'
	local strmultlngsupport = ffi.new("char["..#str.."]",str)
	return crypt.SetMultLngSupportToLic(strmultlngsupport)
end

function SetDefaultLngToLic(strDefaultLng)
	local str=strDefaultLng..'\0'
	local strdefaultlng = ffi.new("char["..#str.."]",str)
	return crypt.SetDefaultLngToLic(strdefaultlng)
end

function SetMachineFuncToLic(MachineFunc)
	local str=MachineFunc..'\0'
	local machinefunc = ffi.new("char["..#str.."]",str)
	return crypt.SetMachineFuncToLic(machinefunc)
end

function SetLicValidPeriodToLic(strDate)
	local str=strDate..'\0'
	local strdate = ffi.new("char["..#strDate.."]",strDate)
	return crypt.SetLicValidPeriodToLic(strdate)
end

function EncodeLicenseFile(filename)
	local str=filename..'\0'
	local fileName = ffi.new("char["..#str.."]",str)
	return crypt.EncodeLicenseFile(fileName)
end

function SignFileToLicense(sigFileName,licFileName,keyValue)
	local str1=sigFileName..'\0'
	local str2=licFileName..'\0'
	local str3=keyValue..'\0'
	local sigfilename = ffi.new("char["..#str1.."]",str1)
	local licfilename = ffi.new("char["..#str2.."]",str2)
	local keyvalue = ffi.new("char["..#str3.."]",str3)
	return crypt.SignFileToLicense(sigfilename,licfilename,keyvalue)
end


--local a=string.format("%02x",31)
--print(string.upper(a))

--[[
function getNum(v)
	local num =  tonumber("0x" .. v)
	return num
end
print(getNum("B"),type(getNum("B")))
]]