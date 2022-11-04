
local stage = {}
local checkFunctionNames ={
    ["printError"]="请注意一下是不是应该留在线上去,因为会增加报错率"
}
--检测一些特别的函数调用
stage.warnings = {
    ["1001"] = {message_format = "检测到调用了特殊函数{name}:{msg}  ", fields = {'name',"msg"}},
}


--对于对外界公开的函数Service接口函数，没有注释的情况进行警告

function stage.run(chstate)
    --print("----------------- ",GetVarDump(chstate))

    for i, v in pairs(chstate.lines) do
        for _, line_item in pairs(v.items) do
            if type(line_item)=="table" then
                if line_item.node and line_item.node.tag =="Call" then
                    print("calll----------- ",GetVarDump(line_item.node))
                    local callFuncName = line_item.node[1][1]
                    if checkFunctionNames[callFuncName]~=nil then
                        chstate:warn_range("1001",line_item.node,{
                            name=callFuncName,
                            msg=checkFunctionNames[callFuncName]
                        })
                    end
                    --print("Call----------  ",callFuncName)
                end
                --print("LInes item  node  ,",line_item,item_key)
            end
            --if line_item[2] ~=nil and line_item[2].node and line_item[2].node.tag=="Call" then
            --    print("Call----------  ",line_item[2].node[1][1])
            --end
        end
    end


end
return stage
