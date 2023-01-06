CUSTOM_SERVICE_IGNORE_FUNCTION_NAMES={
    ["OnLogin"]=true,
}

ignore = {
    --Service 公开函数 {name} 必须要有注释
    "811/OnLogin",
    "812/OnLogin",
}

custom_check_options={
    check_special_function_calls=false
}