local utils = require "luacheck.utils"

local stage = {}




-- Warns about u
-- are accessed but never set or set but never accessed.
-- Warns about unused recursive functions.
function stage.run(chstate)
    print("this is my own detect stage")
end

return stage
