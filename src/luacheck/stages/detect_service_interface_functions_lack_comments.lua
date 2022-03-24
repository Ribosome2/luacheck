
local stage = {}

stage.warnings = {
    ["811"] = {message_format = "Service 公开函数 {name} 必须要有注释 ", fields = {'name'}},
    ["812"] = {message_format = "Service 的Mgr 公开函数 {name} 必须要有注释", fields = {'name',"lineCount"}},
}


local function  check_single_function(node,chstate)
    local args = node[1]

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


--对于对外界公开的函数Service接口函数，没有注释的情况进行警告
function stage.run(chstate)
    print("检测命名规范")
    handle_nodes(chstate.ast,chstate)
end
return stage
