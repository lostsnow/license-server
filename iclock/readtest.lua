local io=require"io"

--local file1="F:/new-server/data/1014/license.zip"
--local file2="F:/new-server/data/1014/license/00176110908c.lic"
local file3="F:/new-server/iclock/readtest/LANGUAGE"

local hg,msg = io.open("main","r")
local data = hg.read("*a")
print("read datalen:",#data)
hg:close()