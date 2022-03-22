local core_utils = require "luacheck.core_utils"

local stage = {}

stage.warnings = {
    ["800"] = {message_format = "function {name} has too many arguments ", fields = {'name'}},
    ["801"] = {message_format = "function {name} is too big: takes {lineCount} lines ", fields = {'name',"lineCount"}},
}
local max_function_argument_count = 4
local max_function_line_count = 80

--allow to override this in config
if CUSTOM_MAX_ARGUMENT_COUNT then
    max_function_argument_count = CUSTOM_MAX_ARGUMENT_COUNT
end

if CUSTOM_MAX_FUNCTION_LINE_COUNT then
    max_function_line_count = CUSTOM_MAX_FUNCTION_LINE_COUNT
end

local function  check_single_function(node,chstate)

    local args = node[1]
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
