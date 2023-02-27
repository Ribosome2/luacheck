
local stage = {}

--要忽略某些函数名的警告，只需要在 .luacheckrc 的 ignore 里面加入 code/要忽略的参数值就行了
stage.warnings = {
    ["814"] = {message_format = "文件 {name} 有函数但是没有实际逻辑,看看是不是应该删掉这个文件 ", fields = {'name'}},
}

local ignoreFunctionNames ={
    ["Init"]=true,
    ["Dispose"]=true,
    ["OnLogin"]=true,
    ["AddListeners"]=true,
    ["RemoveListeners"]=true,
    ["ctor"]=true,
}



local function is_any_code_lines_in_function(node,chstate)
    local rawLineCount = node.end_line - node.line
    if rawLineCount>1 then
        --只计算函数内容的行，不算function 和 end
        local start_line = node.line +1
        local end_line = node.end_line-1
        for line_index = start_line, end_line do
            if chstate.code_lines[line_index]==true then
               return true
            end
        end
    end
    return false
end

local function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end
local function  check_single_function(node,chstate,resultTable)
   resultTable.hasFunction =true
   resultTable.warnNode =node
    if node.name~=nil then
        --print(curFilePath,"好像是没有用的文件")
        local cleanFunctionName = node.name:match("[^.:]+$")
        --chstate:warn_range("814",warnNode,{
        --    name=cleanFunctionName,
        --})
        --特殊函数里面会生成一些骨架，没法判断是否有用，全部忽略
        if (cleanFunctionName=="Init" and ends_with(CUR_CHECK_FILE_PATH,"ViewModel.lua") or
                (  ignoreFunctionNames[cleanFunctionName]==nil)) then
            if resultTable.isAllFunctionEmpty then
                if node.end_line and node.line then
                    if  is_any_code_lines_in_function(node,chstate) then
                        --print("found function  ",cleanFunctionName)
                        resultTable.isAllFunctionEmpty= false
                    end
                end
            end
        end
    end
end


local function handle_nodes(nodes, chstate,resultTable)
    local num_nodes = #nodes

    for index = 1, num_nodes do
        local node = nodes[index]
        if type(node) == "table" then
            local tag = node.tag
            if tag=="Function" then
                check_single_function(node,chstate,resultTable)
            elseif tag == "Set" then
                handle_nodes(node[1],chstate,resultTable)
                handle_nodes(node[2], chstate,resultTable)
            end
        end
    end
end


--对于对外界公开的函数Service接口函数，没有注释的情况进行警告
function stage.run(chstate)
    local resultTable={
        hasFunction =false,
        isAllFunctionEmpty = true
    }

    local curFilePath = CUR_CHECK_FILE_PATH
    if curFilePath ~=nil then
        handle_nodes(chstate.ast,chstate,resultTable)
    end

    if resultTable.hasFunction and resultTable.isAllFunctionEmpty then
        local name_with_extension = curFilePath:match('[^\\]+$')
        chstate:warn_range("814",resultTable.warnNode,{
            name=name_with_extension,
        })
        --print(curFilePath,"好像是没有用的文件")
    end
end
return stage
