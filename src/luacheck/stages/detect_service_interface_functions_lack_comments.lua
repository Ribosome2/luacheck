
local stage = {}

stage.warnings = {
    ["811"] = {message_format = "Service 公开函数 {name} 必须要有注释 ", fields = {'name'}},
    ["812"] = {message_format = "Service 的Mgr 公开函数 {name} 必须要有注释", fields = {'name',"lineCount"}},
}


local function check_ignore_service_function(func_name)
    if CUSTOM_SERVICE_IGNORE_FUNCTION_NAMES then
        return CUSTOM_SERVICE_IGNORE_FUNCTION_NAMES[func_name]
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

local function  check_single_function(node,chstate)
    if check_ignore_service_function(node.name) then
        return
    end
    local func_begin_line = node.line
    if find_prev_comment_line(func_begin_line,chstate)<=0 then
        chstate:warn_range("811",node,{name=node.name})
    end
end


local function handle_nodes(nodes, chstate)
    local num_nodes = #nodes

    for index = 1, num_nodes do
        local node = nodes[index]
        if type(node) == "table" then
            local tag = node.tag
            if tag=="Function" then
                check_single_function(node,chstate)
            elseif tag == "Set" then
                handle_nodes(node[1],chstate)
                handle_nodes(node[2], chstate)
            end
        end
    end
end
local function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end


--对于对外界公开的函数Service接口函数，没有注释的情况进行警告
function stage.run(chstate)
    local curFileName = CUR_CHECK_FILE_PATH
    if curFileName ~=nil then
        if ends_with(curFileName,"Service.lua") then
            print("checking service file: ",curFileName)
            handle_nodes(chstate.ast,chstate)
        end
    end

end
return stage
