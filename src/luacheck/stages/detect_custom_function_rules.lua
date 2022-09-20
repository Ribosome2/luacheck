
local stage = {}

stage.warnings = {
    ["800"] = {message_format = "函数 {name} 参数数量{argCount} 超过了规定的{maxCount}", fields = {'name','argCount','maxCount'}},
    ["801"] = {message_format = "函数 {name} 行数太多: 总共 {lineCount} 行 ", fields = {'name',"lineCount"}},
    ["802"] = {message_format = "参数 {name} 应该从以小写开头 ", fields = {'name'}},
}
local max_function_argument_count = 5
local max_function_line_count = 80

local function check_argument_naming(node,chstate)
    local args = node[1]
    if args then
        for i, arg in pairs(args) do
            local argName = arg[1]
            local nameLen=string.len(argName)
            if argName and  nameLen>0 then
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
        chstate:warn_range("800",node,{
            name=node.name,
            argCount=#args,
            maxCount=max_function_argument_count
        })
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

    for _, line in ipairs(chstate.lines) do
        if line.node then
            print("line----------------",line.node[1][1][1])
            if  line.node[1] and  line.node[1][1][1]=='self' then
                --chstate.node[1]
                print("memberFunctionLine ",line.node[2][1].line)
            end
        end

        if next(line.set_upvalues) then
            --print("set upvalue ",line.set_upvalues[1].lhs)
            --print("set upvalue ",line.set_upvalues.lhs[1].var.name)
            for i, set_upvalues in pairs(line.set_upvalues) do
                print("set upvalue--- ",set_upvalues[1].lhs[1].var.name)
                print("set upvalue line  ",GetVarDump(line))
            end
            --print("chstate--------- ",GetVarDump(line.set_upvalues))
        end

        if next(line.mutated_upvalues) then
            --print("set upvalue ",line.set_upvalues[1].lhs)
            --print("set upvalue ",line.set_upvalues.lhs[1].var.name)
            for i, mutated_upvalues in pairs(line.mutated_upvalues) do
                print("mutated_upvalues--- ",GetVarDump(mutated_upvalues))
                print("mutated_upvalues--- ",mutated_upvalues[1].lhs[1])
                print("mutated_upvalues line --- ",GetVarDump(line))
            end
            --print("chstate--------- ",GetVarDump(line.set_upvalues))
        end
    end
end
return stage
