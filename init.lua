config = require("config")
http = require("resty.http")
uuid = require("resty.uuid")
cjson = require("cjson")

log_fd = io.open(config.log_pwd.."waf.log","ab")
dymanic_block_ips_pool = ngx.shared.dymanic_block_ips_pool

function dslog(...)
    ngx.log(ngx.ERR, ...)
end

function split(str, sep)
    local fields = {}
    str:gsub("[^"..sep.."]+", function(c) fields[#fields+1] = c end)
    return fields
end

