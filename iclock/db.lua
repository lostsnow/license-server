local mysql = require "resty.mysql"
module("db", package.seeall)


function fun()
          --  local mysql = require "resty.mysql"
            local dbmysql = mysql:new()

            dbmysql:set_timeout(1000) -- 1 sec
	    ngx.say("before connect")
            local ok, err, errno, sqlstate = dbmysql:connect{
                host = "127.0.0.1",
                port = 3306,
                database = "lqw",
                user = "root",
                password = "123456",
                max_packet_size = 1024 * 1024 }
		ngx.say("after connect")
            if not ok then
                ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
                return
            end
	    ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)

            ngx.say("connected to mysql.")

            local res, err, errno, sqlstate =
                dbmysql:query("drop table if exists cats")
            if not res then
                ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
                return
            end

            res, err, errno, sqlstate =
                dbmysql:query("create table cats "
                         .. "(id serial primary key, "
                         .. "name varchar(5))")
            if not res then
                ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
                return
            end

            ngx.say("table cats created.")

            res, err, errno, sqlstate =
                dbmysql:query("insert into cats (name) "
                         .. "values (\'Bbbb\'),(\'\'),(null)")
            if not res then
                ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
                return
            end

            ngx.say(res.affected_rows, " rows inserted into table cats ",
                    "(last insert id: ", res.insert_id, ")")

            res, err, errno, sqlstate =
                dbmysql:query("select * from cats order by id asc")
            if not res then
                ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
                return
            end

            local cjson = require "cjson"
            ngx.say("result: ", cjson.encode(res))

            -- put it into the connection pool of size 100,
            -- with 0 idle timeout
            local ok, err = dbmysql:set_keepalive(0, 100)
            if not ok then
                ngx.say("failed to set keepalive: ", err)
                return
            end

            -- or just close the connection right away:
            -- local ok, err = dbmysql:close()
            -- if not ok then
            --     ngx.say("failed to close: ", err)
            --     return
            -- end
end