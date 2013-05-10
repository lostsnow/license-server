require "luasql.mysql"
-- create environment object
env = assert (luasql.mysql())
-- connect to data source
con = assert (env:connect("lqw", "root", "123456", "127.0.0.1", 3306))

-- reset our table
res = con:execute"DROP TABLE people"               --�����±�people
res = assert (con:execute[[
CREATE TABLE people(              
    name varchar(50),
    email varchar(50)
)
]])
-- add a few elements
list = {
{ name="��ռ���", email="liu51574520@163.com", },
{ name="���˽���", email="515740520@qq.com", },
{ name="������ţ", email="117153115@qq.com", },
}
for i, p in pairs (list) do                                            --�������ݵ�people��
res = assert (con:execute(string.format([[
    INSERT INTO people                                         
    VALUES ('%s', '%s')]], p.name, p.email)
))
end
-- retrieve a cursor
cur = assert (con:execute"SELECT name, email from people")    --��ȡ����
--cur = assert (con:execute"SELECT * from people where name='ܿ'")
-- print all rows
print(type(tostring(cur)))
row = cur:fetch ({}, "a") -- the rows will be indexed by field names    --��ʾ����
while row do
print(string.format("Name: %s, E-mail: %s", row.name, row.email))
row = cur:fetch (row, "a") -- reusing the table of results
end
-- close everything
cur:close()
con:close()
env:close()