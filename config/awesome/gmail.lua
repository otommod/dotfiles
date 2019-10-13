local gears     = require("gears")
local naughty   = require("naughty")
local wibox     = require("wibox")
local helpers   = require("lain.helpers")
local json      = require("json")

local lgi       = require("lgi")
local gio       = lgi.Gio
local soup      = lgi.Soup


local function factory(args)
    local gmail         = { widget = wibox.widget.textbox() }
    local args          = args or {}
    local refresh_token = args.refresh_token
    local client_id     = args.client_id
    local client_secret = args.client_secret
    local is_plain      = args.is_plain or false
    local timeout       = args.timeout or 60
    local notify        = args.notify or true
    local settings      = args.settings or function() end

    local access_token = ""
    local unread = {}
    local session = soup.Session()

    local function send(msg, cb)
        session:send_async(msg, nil, function(_, result)
            local stream, err = session:send_finish(result, err)

            if err ~= nil then
                gears.debug.print_warning("gmail.lua: " .. err.message)
                return
            elseif msg.status_code ~= 200 then
                gears.debug.print_warning(("gmail.lua: HTTP status %d"):format(msg.status_code))
                local handler = cb[("on_http_%d"):format(msg.status_code)]
                if handler then handler(msg) end
                return
            end

            gio.Async.start(function()
                local buffers = {}
                repeat
                    local chunk = assert(stream:async_read_bytes(8192))
                    table.insert(buffers, chunk.data)
                until #chunk == 0
                stream:async_close()

                local body = table.concat(buffers)
                local reply = assert(json.decode(body), "gmail.lua: malformed json")
                cb.on_success(reply)
            end)()
        end)
    end

    local function refresh_access_token(callback)
        local msg = soup.Message.new("POST", "https://www.googleapis.com/oauth2/v4/token")
        msg:set_request("application/x-www-form-urlencoded", soup.MemoryUse.COPY,
            soup.form_encode_hash {
                client_id = client_id,
                client_secret = client_secret,
                refresh_token = refresh_token,
                grant_type = "refresh_token"
            })

        send(msg, {
            on_success = function(reply)
                access_token = reply.access_token
                callback()
            end,
        })
    end

    function gmail.update()
        local old_unread = unread
        local unread_new = 0
        local unread_length = 0
        unread = {}

        local function do_update(page_token)
            local msg = soup.Message.new("GET",
                ("https://www.googleapis.com/gmail/v1/users/me/messages?q=%s&pageToken=%s"):format("is%3Aunread", page_token))
            msg.request_headers:append("Authorization", "Bearer " .. access_token)

            send(msg, {
                on_http_401 = function()
                    refresh_access_token(function() do_update(page_token) end)
                end,
                on_success = function(reply)
                    for i, m in ipairs(reply.messages) do
                        unread[m.id] = true
                        unread_length = unread_length + 1
                        if not old_unread[m.id] then
                            unread_new = unread_new + 1
                        end
                    end

                    if reply.nextPageToken then
                        do_update(reply.nextPageToken)
                    else
                        if notify and unread_new > 0 then
                            naughty.notify {
                                title = "You've got mail",
                                text = ("You have %d new messages"):format(unread_new),
                            }
                        end

                        mailcount = unread_length
                        widget = gmail.widget
                        settings()
                    end
                end,
            })
        end

        do_update("")
    end

    local function get_cred(v, cb)
        if is_plain then
            cb(v)
        elseif type(v) == "function" then
            cb(v())
        elseif type(v) == "string" or type(v) == "table" then
            helpers.async(v, function(stdout)
                cb(stdout:gsub("\n", ""))
            end)
        end
    end

    get_cred(refresh_token, function(v)
        refresh_token = v
        get_cred(client_id, function(v)
            client_id = v
            get_cred(client_secret, function(v)
                client_secret = v

                gmail.update()
                gmail.timer = gears.timer {
                    autostart = true,
                    timeout = timeout,
                    callback = gmail.update,
                }
            end)
        end)
    end)

    return gmail
end

return factory
