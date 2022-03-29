
local stage = {}

stage.warnings = {
    ["800"] = {message_format = "函数 {name} 参数太多了", fields = {'name'}},
    ["801"] = {message_format = "函数 {name} 行数太多: 总共 {lineCount} 行 ", fields = {'name',"lineCount"}},
    ["802"] = {message_format = "参数 {name} 应该从以小写开头 ", fields = {'name'}},
}
local max_function_argument_count = 4
local max_function_line_count = 80

local function check_argument_naming(node,chstate)
    local args = node[1]
    if args then
        for i, arg in pairs(args) do
            local argName = arg[1]
            local nameLen=string.len(argName)
            if argName and  nameLen>0 then
                print(" ",argName)
                local firstCh =string.sub(argName,1,1)
                if firstCh=="_" and nameLen>1  then
                    firstCh =string.sub(argName,2,2)
                end
                if firstCh>="A" and firstCh<="Z" then
                    chstate:warn_range("802",node,{name=argName})
                end
            end
        end
    end
end


local function  check_single_function(node,chstate)
    local args = node[1]
    check_argument_naming(node,chstate)
    if #args> max_function_argument_count then
        chstate:warn_range("800",node,{name=node.name})
    end
    if node.end_line and node.line then
        local lineCount = node.end_line - node.line
        if lineCount> max_function_line_count then
            chstate:warn_range("801",node,{
                name=node.name,
                lineCount=lineCount
            })
        end
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


function stage.run(chstate)
    handle_nodes(chstate.ast,chstate)
end
return stage
