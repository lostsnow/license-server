local ffi = require 'ffi'
local setmetatable = setmetatable
local rawset = rawset
local string = require"string"
local tonumber = tonumber
local print = print

module"iconv_ffi"

ffi.cdef [[
extern  int _libiconv_version; /* Likewise */
typedef void* iconv_t;
iconv_t libiconv_open (const char* /*tocode*/, const char* /*fromcode*/);
int libiconv (iconv_t /*cd*/,
	char ** __restrict /*inbuf*/,  size_t * __restrict /*inbytesleft*/,
	char ** __restrict /*outbuf*/, size_t * __restrict /*outbytesleft*/);
int libiconv_close (iconv_t /*cd*/);
]]

-- setup library & remove FT_ prefix
local lib   = ffi.os == 'Linux' and ffi.C or ffi.load 'libiconv2'
local iconv = {}
setmetatable(iconv, {
  __index = function(t, n)
    local s = lib['libiconv_'..n]
    rawset(t, n, s)
    return s
  end
})

local charptr = ffi.typeof('char *[1]')
local sizeptr = ffi.typeof('size_t[1]')
local chara   = ffi.typeof('char [?]')
local charp   = ffi.typeof('char *')
local uint16a = ffi.typeof('uint16_t [?]')

function iconv.iconv(ic, str, uint16)
  local len       = string.len(str)

  local insize    = sizeptr(len)
  local inbuf     = chara(len+1, str)
  local inbufptr  = charptr(inbuf)

  local outsize   = sizeptr(2*len)
  local outbuf, outbufptr
  if uint16 then
    outbuf        = uint16a(len)
    outbufptr     = charptr(ffi.cast(charp, outbuf))
  else
    outbuf        = chara(2*len)
    outbufptr     = charptr(outbuf)
  end

  local ret=lib.libiconv(ic, inbufptr, insize, outbufptr, outsize)
  local outlen = 2*len - outsize[0]
  if uint16 then
    return outbuf, tonumber(outlen / 2)
  end
  return ffi.string(outbuf, outlen), outlen
end

return iconv

