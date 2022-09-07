local stage = {}
local MAX_CODE_LINE = 800
--要忽略某些函数名的警告，只需要在 .luacheckrc 的 ignore 里面加入 code/要忽略的参数值就行了
stage.warnings = {
    ["900"] = { message_format = "UI代码（排除注释和空行）函数超过了{line_count} 行,总行数{total_line} ", fields = { "line_count" ,"total_line"} },
}
local function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

local function count_code_line_counts(chstate)
    local result = 0
    if chstate ~= nil and chstate.code_lines then
        for i, v in pairs(chstate.code_lines) do
            if v == true then
                result = result + 1
            end
        end
    end
    return result
end

--检测代码内容：不算注释和空格
function stage.run(chstate)
    local curFilePath = CUR_CHECK_FILE_PATH
    if curFilePath ~= nil then
        if ends_with(curFilePath, "View.lua") or ends_with(curFilePath, "ViewModel.lua") then
            local total_line = count_code_line_counts(chstate)
            if total_line > MAX_CODE_LINE then
                chstate:warn("900",1,1,0,{
                    line_count=MAX_CODE_LINE,
                    total_line =total_line
                })
            end
        end
    end
end
return stage
