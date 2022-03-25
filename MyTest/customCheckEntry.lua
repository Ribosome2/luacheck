local appendSearchPath= function(path)
    package.path = package.path..path
end
--这里根据luarocks 的路径改一下
appendSearchPath(';C:/luarocks-3.8.0-win32/src/luarocks/?.lua')
appendSearchPath(';../src/?/init.lua')
appendSearchPath(';../src/?.lua')
require("VarDumpUtil")
--CUSTOM_MAX_ARGUMENT_COUNT=4
--CUSTOM_MAX_FUNCTION_LINE_COUNT=80

--require("luacheck.main")

function TestFunctionEnvironment()
    --[[
    　当我们在全局环境中定义变量时经常会有命名冲突，尤其是在使用一些库的时候，变量声明可能会发生覆盖，这时候就需要一个非全局的环境来解决这问题。setfenv函数可以满足我们的需求。
　　setfenv(f, table)：设置一个函数的环境
　　（1）当第一个参数为一个函数时，表示设置该函数的环境
　　（2）当第一个参数为一个数字时，为1代表当前函数，2代表调用自己的函数，3代表调用自己的函数的函数，以此类推
　　所谓函数的环境，其实一个环境就是一个表，该函数被限定为只能访问该表中的域，或在函数体内自己定义的变量。下面这个例子，设定当前函数的环境为一个空表，那么在设定执行以后，来自全局的print函数将不可见，所以调用会失败。
    ]]
    local new_function_environment ={}
    setfenv(1,new_function_environment)
    print(1)
end
TestFunctionEnvironment()
