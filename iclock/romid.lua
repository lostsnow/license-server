function getmacstr2(romid)	--4900000044F86A44
	ptr=1
	local result={}
	for i=1,8 do
		result[i]=string.sub(romid,ptr,ptr+1)
		ptr=ptr+2
		print(i,result[i])
	end
	return result[8]..result[7]..result[6]..result[5]..result[4]..result[3]..result[2]..result[1]
end
	
local ret = getmacstr2("4900000044F86A44")
print(ret)