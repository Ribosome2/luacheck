
local stage = {}

--要忽略某些函数名的警告，只需要在 .luacheckrc 的 ignore 里面加入 code/要忽略的参数值就行了
stage.warnings = {
    ["811"] = {message_format = "Service 公开函数 {name} 必须要有注释 ", fields = {'name'}},
    ["812"] = {message_format = "Service 的Mgr 公开函数 {name} 必须要有注释", fields = {'name'}},
    ["813"] = {message_format = "Service 函数 {name} 只应提供对外接口，不能有具体逻辑(逻辑内容理论上只能一行）", fields = {'name'}},
}

local function begins_with(str,target_str)
    if string.len(str)>=string.len(target_str) then
        local subStr = string.sub(str,0,string.len(target_str))
        if subStr==target_str then
            return true
        end
    end
    return false
end

local function find_prev_comment_line(start_line,chstate)
    local result =-1
    --只认紧跟函数名的上一行的注释
    local target_comment_line = start_line-1
    for i, comment_item in pairs(chstate.comments) do
        if comment_item.line==target_comment_line then
            --如果有必要，可以加是否是什么都没写的空注释
            result =comment_item.line
            break
        end
    end
    return result
end

local function count_code_lines_in_function(node,chstate)
    local rawLineCount = node.end_line - node.line
    local count =0
    if rawLineCount>1 then
        --只计算函数内容的行，不算function 和 end
        local start_line = node.line +1
        local end_line = node.end_line-1
        for line_index = start_line, end_line do
            if chstate.code_lines[line_index]==true then
                --print("add line count",line_index)
                count = count+1
            end
        end
    end
    return count
end

--Service只提供对外接口，理论上不能超过一行
local function  check_service_function_line_count(node,chstate)
    local MAX_LINE_COUNT_FOR_SERVICE_FUNCTION =1
    if node.end_line and node.line then
        local lineCount = count_code_lines_in_function(node,chstate)
        --print("function  line count ",node.name,lineCount)
        if lineCount> MAX_LINE_COUNT_FOR_SERVICE_FUNCTION then
            local cleanFunctionName = node.name:match("[^.:]+$")
            chstate:warn_range("813",node,{
                name=cleanFunctionName,
            })
        end
    end
end



local function  check_single_function(node,chstate,isMgr)
    local cleanFunctionName = node.name:match("[^.:]+$")
    local func_begin_line = node.line
    local firstCh =string.sub(cleanFunctionName,1,1)
    if firstCh=="_" then
        -- '_'开始的认为是非公开函数
        return
    end

    if isMgr~=true then
        check_service_function_line_count(node,chstate)
    end
    if find_prev_comment_line(func_begin_line,chstate)<=0 then
        if isMgr then
            if begins_with(cleanFunctionName,"Get")
                    or begins_with(cleanFunctionName,"Set") then
                return
            end
            chstate:warn_range("812",node,{name=cleanFunctionName})
        else
            chstate:warn_range("811",node,{name=cleanFunctionName})
        end
    end
end


local function handle_nodes(nodes, chstate,isMgr)
    local num_nodes = #nodes

    for index = 1, num_nodes do
        local node = nodes[index]
        if type(node) == "table" then
            local tag = node.tag
            if tag=="Function" then
                check_single_function(node,chstate,isMgr)
            elseif tag == "Set" then
                handle_nodes(node[1],chstate,isMgr)
                handle_nodes(node[2], chstate,isMgr)
            end
        end
    end
end
local function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

local function get_module_name(source_str)
    for module_name in source_str:gmatch "AQ.(%w+)" do
        return module_name
    end
    return nil
end


local SERVICE_MGR_SUFFIX="Mgr.lua"
--对于对外界公开的函数Service接口函数，没有注释的情况进行警告
function stage.run(chstate)
    local curFilePath = CUR_CHECK_FILE_PATH
    if curFilePath ~=nil then
        if ends_with(curFilePath,"Service.lua") then
            handle_nodes(chstate.ast,chstate)
        --elseif  ends_with(curFilePath,SERVICE_MGR_SUFFIX) then
        --    local moduleName = get_module_name(chstate.source._bytes)
        --    if moduleName ~=nil then
        --        local name_with_extension = curFilePath:match('[^\\]+$')
        --        local serviceMgrName = moduleName..SERVICE_MGR_SUFFIX
        --        if  name_with_extension ==serviceMgrName then
        --            --print("found service Mgr ",moduleName,name_without_extension)
        --            handle_nodes(chstate.ast,chstate,true)
        --        end
        --    end
        end
    end

end
return stage
