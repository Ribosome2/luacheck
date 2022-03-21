local core_utils = require "luacheck.core_utils"

local stage = {}

stage.warnings = {
    ["800"] = {message_format = "function has too many arguments ", fields = {}},
}


local function detect_functions_argument_in_line(chstate, line)
    local is_top_line = line == chstate.top_line

    for _, item in ipairs(line.items) do
        print("tag ",item.tag)
        if item.lines then
            for i, v in pairs(item.lines) do
                if v.tag=="Function" then
                    print("item----",GetVarDump(v))
                end
            end
        end

    end
end

-- Warns about assignments, field accesses, and mutations of global variables,
-- tracing through localizing assignments such as `local t = table`.
function stage.run(chstate)
    print("try check argument count ---------")
    for _, line in ipairs(chstate.lines) do
        detect_functions_argument_in_line(chstate, line)
    end
end
return stage
