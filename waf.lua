local localtime = ngx.localtime()

local request_method = ngx.var.request_method
local request_uri = ngx.var.request_uri
local server_protocol = ngx.var.server_protocol

local headers = ngx.req.get_headers()
local remote_addr = headers["X-Real-IP"] or ngx.var.remote_addr
local http_user_agent = ngx.var.http_user_agent
local http_referer = ngx.var.http_referer
local http_cookie = ngx.var.http_cookie

function log(module_name)
    local http_user_agent = http_user_agent or "-"
    local http_referer = http_referer or "-"
    local line = string.format([[%s: %s [%s] "%s %s %s" "%s" "%s"]] .. "\n", module_name, remote_addr, localtime, request_method, request_uri, server_protocol, http_referer, http_user_agent )
    log_fd:write(line)
    log_fd:flush()
end

function block_ips_module()
    for _, block_ip in ipairs(config.block_ips) do
        if remote_addr == block_ip then
            log("BLOCK_IP_MODULE")
            ngx.exit(403)
        end
    end
end

function block_url_chars_module()
    for _, block_url_char in ipairs(config.block_url_chars) do
        if ngx.re.match(request_uri, block_url_char, "isjo") then
            log("BLOCK_URL_MODULE")
            ngx.exit(403)
        end
    end
end

function block_user_agents_module()
    if http_user_agent ~= nil then
        for _, block_user_agent in ipairs(config.block_user_agents) do
            if ngx.re.match(http_user_agent, block_user_agent, "isjo") then
                log("BLOCK_USER_AGENT_MODULE")
                ngx.exit(403)
            end
        end
    end
end

function block_cookie_chars_module()
    if http_cookie ~= nil then
        for _, block_cookie_char in ipairs(config.block_cookie_chars) do
            if ngx.re.match(http_cookie, block_cookie_char, "isjo") then
                log("BLOCK_COOKIE_MODULE")
                ngx.exit(403)
            end
        end
    end
end

block_ips_module()
block_url_chars_module()
block_user_agents_module()
block_cookie_chars_module()
