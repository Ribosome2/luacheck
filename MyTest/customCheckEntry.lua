local appendSearchPath= function(path)
    package.path = package.path..path
end
--这里根据luarocks 的路径改一下
appendSearchPath(';C:/luarocks-3.8.0-win32/src/luarocks/?.lua')
appendSearchPath(';../src/?/init.lua')
appendSearchPath(';../src/?.lua')
require("luacheck.main")