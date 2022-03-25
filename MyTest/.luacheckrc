print("check config file got read ",debug.traceback())
CUSTOM_SERVICE_IGNORE_FUNCTION_NAMES={
    ["OnLogin"]=true,
}

std = {
    read_globals = {
        CUSTOM_SERVICE_IGNORE_FUNCTION_NAMES={
            ["OnLogin"]=true,
        }
    } -- these globals can only be accessed.
}