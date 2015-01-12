local keys, err = dymanic_block_ips_pool:get_keys()
if keys then
    for _, key in ipairs(keys) do
        local value, err = dymanic_block_ips_pool:get(key)
        local space = string.rep(" ", 17 - #key)
        ngx.say(key .. space .. value)
    end
end
