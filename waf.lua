local localtime = ngx.localtime()

local request_method = ngx.var.request_method
local request_uri = ngx.unescape_uri(ngx.var.request_uri)
local server_protocol = ngx.var.server_protocol

local headers = ngx.req.get_headers()
local remote_addr = headers["X-Real-IP"] or ngx.var.remote_addr
local http_user_agent = ngx.var.http_user_agent
local http_referer = ngx.var.http_referer
local http_cookie = ngx.var.http_cookie

local httpc = http.new()

function log_file(module_name, why)
    local http_user_agent = http_user_agent or "-"
    local http_referer = http_referer or "-"
    local line = string.format([[%s "%s" : %s [%s] "%s %s %s" "%s" "%s"]] .. "\n", module_name, why, remote_addr, localtime, request_method, request_uri, server_protocol, http_referer, http_user_agent)
    log_fd:write(line)
    log_fd:flush()
end

function log_couchdb(module_name, why)
    local db = config.couchdb_url .. string.lower(module_name)
    local res, err = httpc:request_uri(db, {
        method = "PUT",
    })
    local doc = {
        why = why,
        remote_addr = remote_addr,
        localtime = localtime,
        request_method = request_method,
        request_uri = request_uri,
        server_protocol = server_protocol,
        http_referer = http_referer,
        http_user_agent = http_user_agent,
    }
    local res, err = httpc:request_uri(db .. "/" .. uuid(), {
        method = "PUT",
        body = cjson.encode(doc),
    })
end

function log(module_name, why)
    log_file(module_name, why)
    log_couchdb(module_name, why)
end

function block_ip_module()
    for _, block_ip in ipairs(config.block_ips) do
        if remote_addr == block_ip then
            log("BLOCK_IP_MODULE", block_ip)
            if config.mode == "enable" then ngx.exit(403) end
        end
    end
end

function block_url_module()
    for _, block_url_char in ipairs(config.block_url_chars) do
        if ngx.re.match(request_uri, block_url_char, "sjo") then
            log("BLOCK_URL_MODULE", block_url_char)
            if config.mode == "enable" then ngx.exit(403) end
        end
    end
end

function block_user_agent_module()
    if http_user_agent ~= nil then
        for _, block_user_agent in ipairs(config.block_user_agents) do
            if ngx.re.match(http_user_agent, block_user_agent, "isjo") then
                log("BLOCK_USER_AGENT_MODULE", block_user_agent)
                if config.mode == "enable" then ngx.exit(403) end
            end
        end
    end
end

function block_cookie_module()
    if http_cookie ~= nil then
        for _, block_cookie_char in ipairs(config.block_cookie_chars) do
            if ngx.re.match(http_cookie, block_cookie_char, "sjo") then
                log("BLOCK_COOKIE_MODULE", block_cookie_char)
                if config.mode == "enable" then ngx.exit(403) end
            end
        end
    end
end

function dymanic_block_ip_module()
    dymanic_block_ips_pool:safe_add(remote_addr, 1, 60, 0)
    dymanic_block_ips_pool:incr(remote_addr, 1)
    local access_num, err = dymanic_block_ips_pool:get(remote_addr)
    if access_num and access_num > config.dymanic_block_ips_rate then
        log("DYMANIC_BLOCK_IP_MODULE", remote_addr .. "(" .. access_num .. ")")
        if config.mode == "enable" then ngx.exit(403) end
    end
end

if config.mode == "enable" or config.mode == "audit" then
    block_ip_module()
    block_url_module()
    block_user_agent_module()
    block_cookie_module()
    dymanic_block_ip_module()
else
end
