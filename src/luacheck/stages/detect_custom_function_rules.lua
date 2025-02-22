local stage = {}

stage.warnings = {
    ["800"] = { message_format = "函数 {name} 参数数量{argCount} 超过了规定的{maxCount}", fields = { 'name', 'argCount', 'maxCount' } },
    ["801"] = { message_format = "函数 {name} 行数太多: 总共 {lineCount} 行 ", fields = { 'name', "lineCount" } },
    ["802"] = { message_format = "参数 {name} 应该从以小写开头 ", fields = { 'name' } },
    ["803"] = { message_format = "在成员函数{name} 里修改外部local变量{varName}(重新设值)  多实例的时候容易出bug ", fields = { 'name','varName' } },
    ["804"] = { message_format = "在成员函数{name} 里修改外部local变量{varName}（修改字段）  多实例的时候容易出bug ", fields = { 'name','varName' } },
}
local max_function_argument_count = 5
local max_function_line_count = 80

local function check_argument_naming(node, chstate)
    local args = node[1]
    if args then
        for i, arg in pairs(args) do
            local argName = arg[1]
            local nameLen = string.len(argName)
            if argName and nameLen > 0 then
                local firstCh = string.sub(argName, 1, 1)
                if firstCh == "_" and nameLen > 1 then
                    firstCh = string.sub(argName, 2, 2)
                end
                if firstCh >= "A" and firstCh <= "Z" then
                    chstate:warn_range("802", node, { name = argName })
                end
            end
        end
    end
end

local function check_is_member_function(args)
    if args and #args > 0 then
        local argName = args[1][1]
        return argName == 'self'
    end
    return false
end

local function check_change_upvalue_in_member_function(chstate, node, change_upvalue_lines_map)
    for line_index = node.line, node.end_line do
        local change_node = change_upvalue_lines_map[line_index]
        if change_node ~= nil and change_node.lhsVarLineIndex < node.line then
            if change_node.is_mutated then
                chstate:warn_range("804", change_node.node, {
                    name = node.name,
                    varName = change_node.varName,
                })
            else
                chstate:warn_range("803", change_node.node, {
                    name = node.name,
                    varName = change_node.varName,
                })
            end

            --print("------------- ",GetVarDump(node))
        end
    end
end

local function check_single_function(node, chstate, change_upvalue_lines_map)
    local args = node[1]
    check_argument_naming(node, chstate)
    if #args > max_function_argument_count then
        chstate:warn_range("800", node, {
            name = node.name,
            argCount = #args,
            maxCount = max_function_argument_count
        })
    end
    if node.end_line and node.line then
        local lineCount = node.end_line - node.line
        if lineCount > max_function_line_count then
            chstate:warn_range("801", node, {
                name = node.name,
                lineCount = lineCount
            })
        end
        if next(change_upvalue_lines_map) and  check_is_member_function(args) then
            --print("function Node ",node.name , GetVarDump(node))
            check_change_upvalue_in_member_function(chstate, node, change_upvalue_lines_map)
        end
    end
end

local function handle_nodes(nodes, chstate, change_upvalue_lines_map)
    local num_nodes = #nodes

    for index = 1, num_nodes do
        local node = nodes[index]
        if type(node) == "table" then
            local tag = node.tag
            if tag == "Function" then
                check_single_function(node, chstate, change_upvalue_lines_map)
            elseif tag == "Set" then
                handle_nodes(node[1], chstate, change_upvalue_lines_map)
                handle_nodes(node[2], chstate, change_upvalue_lines_map)
            end
        end
    end
end

local function fill_change_upvalues_line(chstate)
    local change_upvalue_lines_map = {}
    for _, line in ipairs(chstate.lines) do
        if next(line.set_upvalues) then
            --print("set upvalue ",line.set_upvalues.lhs[1].var.name)
            for i, set_upvalues in pairs(line.set_upvalues) do
                --print("set upvalue1111111 --- ",GetVarDump(set_upvalues))
                local line_index = set_upvalues[1].node.line
                local varName = set_upvalues[1].lhs[1].var.name
                --print("set upvalue--- ",line_index,set_upvalues[1].lhs[1].var.name)
                local lhsVarLineIndex = set_upvalues[1].lhs[1].var.node.line --被赋值的upvalue的定义行号
                change_upvalue_lines_map[line_index] = {
                    node = set_upvalues[1].node,
                    lhsVarLineIndex = lhsVarLineIndex,
                    varName = varName
                }
                --print("set upvalue var from line   ", GetVarDump(set_upvalues[1].lhs))
                --print("set upvalue line var  ", lhsVarLineIndex)
            end
        end

        if next(line.mutated_upvalues) then
            for i, mutated_upvalues in pairs(line.mutated_upvalues) do
                --print("mutated_upvalues use value --- ",GetVarDump(mutated_upvalues))

                for i, used_value in pairs(mutated_upvalues[1].used_values) do
                    if type(used_value) == "table" then
                        local varName = used_value[1].var_node[1]
                        local lhsVarLineIndex = used_value[1].var_node.line
                        --print("mutated_upvalues frome line  ", lhsVarLineIndex)
                        local line_index = mutated_upvalues[1].node.line
                        change_upvalue_lines_map[line_index] = {
                            node = mutated_upvalues[1].node,
                            lhsVarLineIndex = lhsVarLineIndex,
                            is_mutated = true,
                            varName =varName
                        }
                    end
                end
            end
        end
    end
    return change_upvalue_lines_map
end

function stage.run(chstate)
    --print("chstate --------- ",GetVarDump(chstate))
    local change_upvalue_lines_map = fill_change_upvalues_line(chstate)
    handle_nodes(chstate.ast, chstate, change_upvalue_lines_map)

end
return stage
