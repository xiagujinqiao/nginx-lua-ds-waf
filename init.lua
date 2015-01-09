config = require("config")

log_fd = io.open(config.log_pwd.."waf.log","ab")

function split(str, sep)
    local fields = {}
    str:gsub("[^"..sep.."]+", function(c) fields[#fields+1] = c end)
    return fields
end

