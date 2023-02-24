
local stage = {}
local checkFunctionNames ={
    ["printError"]="请注意一下是不是应该留到线上,因为会增加报错率",
    ["clear"]=".clear的调用理解为清列表，注意看是否全清掉又重建的写法"
}
--检测一些特别的函数调用
stage.warnings = {
    ["1001"] = {message_format = "检测到调用了特殊函数{name}:{msg}  ", fields = {'name',"msg"}},
}


local function check_call_clear(chstate,line_item)
    --print("---------- ",GetVarDump(line_item))
    --local node =line_item.node[1]
    local node = line_item.node[1]
    if node[2] then  --有xxx.functionName 就会在第二个里面
        local callFuncName = node[2][1]
        ----print("calll----------- ",GetVarDump(line_item.node))
        if callFuncName~=nil and  checkFunctionNames[callFuncName]~=nil then
            chstate:warn_range("1001",line_item.node,{
                name=callFuncName,
                msg=checkFunctionNames[callFuncName]
            })
        end
    end

    return false
end


function stage.run(chstate)
    --print("----------------- ",GetVarDump(chstate))
    ----在build出来的exe没有用的
    --if GLOBAL_STAGES_CHECK_OPTIONS~=nil and GLOBAL_STAGES_CHECK_OPTIONS.check_special_function_calls~=true then
    --    return
    --end

    for i, v in pairs(chstate.lines) do
        for _, line_item in pairs(v.items) do
            if type(line_item)=="table" then
                if line_item.node and line_item.node.tag =="Call" then
                    --print("calll----------- ",line_item.node[1])
                    check_call_clear(chstate,line_item)
                    local callFuncName = line_item.node[1][1]
                    --print("calll----------- ",GetVarDump(line_item.node))
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
