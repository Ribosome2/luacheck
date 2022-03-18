local M = {}
KyleProtoFmt = M
local indentSymbol ="\t"
function Msg_Format_Indent(write, msg, indent)
    local appendLine =function(content,lineIndent )
        if content then
            lineIndent = lineIndent or indent
            write('\n')
            write(string.rep(indentSymbol, lineIndent))
            write(content)
        end
    end
end


function M.Format(msg,indent)
    if indent==nil then
        indent=1
    end
    local out = {}
    local write = function(value)
        out[#out + 1] = value
    end
    local makeIndent =function()
        write(string.rep(indentSymbol, indent))
    end
    write("{")
    Msg_Format_Indent(write, msg, indent+1)
    write('\n')
    makeIndent(indent)
    write("}")
    return table.concat(out)
end
function KyleProtoFmt.ProtoBufToTableFormat(msg,indent)
    return M.Format(msg,indent)
end
function IsProtoBuffTable(tableObj )
    if tableObj and rawget(tableObj, "_fields") and  tableObj['_fields'] and tableObj.ListFields  then
        if type(tableObj.ListFields)=='function' then
            return true
        end
    end
    return false
end


function GetVarDump(value,ignoreFunction , depth, key,stackDepth)
    if value== nil then
        return "nil value"
    end
    stackDepth = stackDepth or 0
    depth = depth or -1
    stackDepth=stackDepth+1
    depth = depth + 1
    --to prevent stack overflow
    if stackDepth>8 then
        return nil
    end

    local contentStr = ""
    local addContent =function(str )
        if str~=nil and str ~='' then
            contentStr =string.format('%s%s', contentStr,tostring(str))
        end
    end
    local makeIndent =function(indent)
        indent = indent or depth
        addContent(string.rep(indentSymbol, indent))
    end
    local addLine=function(str ,indent)
        addContent('\n')
        makeIndent(indent)
        if str~=nil and str ~='' then
            contentStr =string.format('%s%s', contentStr,tostring(str))
        end
    end
    local linePrefix = ""
    if key ~= nil then
        linePrefix = tostring(key).." = "
    end

    if type(value) == 'table' then
        if IsProtoBuffTable(value )==true then
            addLine(string.format('%s(protoData)',linePrefix))
            addContent(tostring(KyleProtoFmt.ProtoBufToTableFormat(value,depth)))
            return contentStr
        else
            addLine(linePrefix)
            addContent('{')
            local mTable = getmetatable(value)
            if mTable == nil then
                for tableKey, tableValue in pairs(value) do
                    if value~=tableValue then
                        local content  = GetVarDump(tableValue,ignoreFunction, depth, tableKey,stackDepth)
                        if content==nil then
                            --reachMaxStack
                        else
                            addContent(content)
                        end
                    end
                end
            else
                addContent(string.format('(metatable)%s{',linePrefix))
                for someKey,someValue in pairs(value) do
                    if someValue ~= value then
                        local content  = GetVarDump(someValue ,ignoreFunction, depth, someKey,stackDepth,ignoreFunction)
                        addContent(tostring(content))
                    end
                end
            end
            addLine('}')
        end

    elseif type(value) == 'function'  then
        if ignoreFunction~=true then
            addLine(string.format('%s =  %s (%s)',tostring(key),tostring(value),type(value)))
        end
    elseif  type(value) == 'thread' or type(value) == 'userdata'  or value == nil     then
        addLine(string.format('%s =  %s (%s)',tostring(key),tostring(value),type(value)))
    else
        addLine(string.format('%s =  %s (%s)',tostring(key),tostring(value),type(value)))
    end
    return contentStr
end

function GetNodeStr(root,prefix)
    local treeStr =""
    prefix = prefix.."  "
    if root and root.gameObject.activeInHierarchy then
        treeStr =string.format("%s%s%s\n",treeStr,prefix,root.gameObject.name)
        local childCount = root.childCount
        for index = 1, childCount do
            local child = root:GetChild(index - 1)
            treeStr=treeStr..GetNodeStr(child,prefix)
        end
    end
    return treeStr
end



