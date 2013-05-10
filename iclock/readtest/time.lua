local os=require"os"

local time=os.time()
print(type(time),time)

nowtime = os.date( "%Y-%m-%d %H:%M:%S", os.time() );
print(type(nowtime),nowtime)

function sub_datetime(time1,time2)
	if time1== nil or time1=='' or time2==nil or time2=='' then
        return ''
    end
    local y1,m1,d1,h1,mi1,s1=string.match(time1,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    local y2,m2,d2,h2,mi2,s2=string.match(time2,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")

    local sub=os.time({year=y1,month=m1,day=d1,hour=h1,min=mi1,sec=s1})-os.time({year=y2,month=m2,day=d2,hour=h2,min=mi2,sec=s2})
    return sub
end

local y1,m1,d1,h1,mi1,s1=string.match(nowtime,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
sub=os.time({year=y1,month=m1,day=d1,hour=h1,min=mi1,sec=s1})

--local sub=sub_datetime(nowtime)
print(type(sub),sub)