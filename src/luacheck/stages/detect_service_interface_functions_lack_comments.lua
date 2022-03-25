
local stage = {}

--要忽略某些函数名的警告，只需要在 .luacheckrc 的 ignore 里面加入 code/要忽略的参数值就行了
stage.warnings = {
    ["811"] = {message_format = "Service 公开函数 {name} 必须要有注释 ", fields = {'name'}},
    ["812"] = {message_format = "Service 的Mgr 公开函数 {name} 必须要有注释", fields = {'name'}},
}

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

local function  check_single_function(node,chstate,isMgr)
    local cleanFunctionName = node.name:match("[^.:]+$")
    local func_begin_line = node.line
    if find_prev_comment_line(func_begin_line,chstate)<=0 then
        if isMgr then
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
        elseif  ends_with(curFilePath,SERVICE_MGR_SUFFIX) then
            local moduleName = get_module_name(chstate.source._bytes)
            local name_with_extension = curFilePath:match('[^\\]+$')
            local serviceMgrName = moduleName..SERVICE_MGR_SUFFIX
            if  name_with_extension ==serviceMgrName then
                --print("found service Mgr ",moduleName,name_without_extension)
                handle_nodes(chstate.ast,chstate,true)
            end
        end
    end

end
return stage
