local io=require"io"

--local file1="F:/new-server/data/1014/license.zip"
--local file2="F:/new-server/data/1014/license/00176110908c.lic"
local file3="F:/new-server/iclock/readtest/main"

local hg,msg = io.open("main","r+b")
local data = hg:read("*a")
print("read datalen:",#data)

local hg2,msg2=io.open("main_bak","w+b")
hg2:write(data)
hg2:close()

hg:close()
