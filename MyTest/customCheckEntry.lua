local appendSearchPath= function(path)
    package.path = package.path..path
end
--这里根据luarocks 的路径改一下
appendSearchPath(';C:/luarocks-3.8.0-win32/src/luarocks/?.lua')
appendSearchPath(';../src/?/init.lua')
appendSearchPath(';../src/?.lua')
require("VarDumpUtil")
CUSTOM_MAX_ARGUMENT_COUNT=4
CUSTOM_MAX_FUNCTION_LINE_COUNT=80

CUSTOM_SERVICE_IGNORE_FUNCTION_NAMES={
    ["OnLogin"]=true,
}
require("luacheck.main")

