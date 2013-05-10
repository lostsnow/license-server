require "luasql.mysql"
-- create environment object
env = assert (luasql.mysql())
-- connect to data source
con = assert (env:connect("lqw", "root", "123456", "127.0.0.1", 3306))

-- reset our table
res = con:execute"DROP TABLE people"               --建立新表people
res = assert (con:execute[[
CREATE TABLE people(              
    name varchar(50),
    email varchar(50)
)
]])
-- add a few elements
list = {
{ name="虚空假面", email="liu51574520@163.com", },
{ name="流浪剑客", email="515740520@qq.com", },
{ name="撼地神牛", email="117153115@qq.com", },
}
for i, p in pairs (list) do                                            --加入数据到people表
res = assert (con:execute(string.format([[
    INSERT INTO people                                         
    VALUES ('%s', '%s')]], p.name, p.email)
))
end
-- retrieve a cursor
cur = assert (con:execute"SELECT name, email from people")    --获取数据
--cur = assert (con:execute"SELECT * from people where name='芸'")
-- print all rows
print(type(tostring(cur)))
row = cur:fetch ({}, "a") -- the rows will be indexed by field names    --显示出来
while row do
print(string.format("Name: %s, E-mail: %s", row.name, row.email))
row = cur:fetch (row, "a") -- reusing the table of results
end
-- close everything
cur:close()
con:close()
env:close()