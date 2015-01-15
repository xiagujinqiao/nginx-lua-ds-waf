nginx-lua-ds-waf
================

基于openresty/lua-nginx-module的WAF系统

A WAF based on openresty/lua-nginx-module

Dependencies:
----

- openresty or nginx with openresty/lua-nginx-module
- couchdb
- Tieske/uuid
- mpx/lua-cjson
- pintsized/lua-resty-http

Installation:

将代码放在位于nginx根目录下的lua/nginx-lua-ds-waf/下

Put the code into the directory lua/nginx-lua-ds-waf which is located in the root directory of the nginx


在nginx.conf的http段中添加如下配置：

Add the config below to the http seg in nginx.conf:

    lua_package_path "/usr/local/nginx/lua/nginx-lua-ds-waf/?.lua;;";
    lua_shared_dict dymanic_block_ips_pool 10m;
    init_by_lua_file lua/nginx-lua-ds-waf/init.lua;
    access_by_lua_file lua/nginx-lua-ds-waf/waf.lua;
    

WAF相关的配置在config.lua中，需要保证nginx的worker process对日志文件有读写权限

You can config WAF with the file config.lua,and you must make the worker process of nginx have the read and write permission to the log file
