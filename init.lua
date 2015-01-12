config = require("config")

log_fd = io.open(config.log_pwd.."waf.log","ab")

dymanic_block_ips_pool = ngx.shared.dymanic_block_ips_pool

function dserror(err)
    if err then
        ngx.log(ngx.ERR, err)
    end
end

function split(str, sep)
    local fields = {}
    str:gsub("[^"..sep.."]+", function(c) fields[#fields+1] = c end)
    return fields
end

