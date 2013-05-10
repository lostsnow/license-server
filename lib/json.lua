--[[
	Licensed according to the included 'LICENSE' document
	Author: Thomas Harning Jr <harningt@gmail.com>
]]
local decode = require("json.decode")
local encode = require("json.encode")
local util = require("json.util")
local print = print
module("json")
_M.decode = decode
_M.encode = encode
_M.util = util

local s=[[
{"devices": ["2180011450012", "2180011450019", "2180011450020"],
   "operations": [
     {"operation": "delete", "entities": [
        {"entity": "employee", "pin": "11520"}
        ]},
     {"operation": "save", "entities": [
        {"entity": "deparment", "code": "11", "name": "技术部"},
        {"entity": "deparment", "code": "12", "name": "研发部"},
        {"entity": "employee", "pin": "12900", "name": "刘壮志", "dept": "11"},
        {"entity": "employee", "pin": "12901", "name": "陈晓阳", "dept": "12", "card": "19182892"},
        {"entity": "fingerprint", "pin": "12900", "finger_id": "1", "template": "... ..."}
        ]},
     {"operation": "set", "options": [{"volume": "22"}, {"": ""}]},
     {"operation": "reboot"},
   ]
}

]]

-- local d=decode(s)
-- print(#d.devices)
