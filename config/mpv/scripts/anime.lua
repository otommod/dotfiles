local osx = require('lib.os')
local mpv = require('lib.mpv')
local path = require('lib.path')
local utils = require('lib.utils')

local gfy = require('gfy')


function check_path(directory, filename)
    if not path.ensuredir(directory) then
        mpv.msg.error(
            ("Cannot find or create directory '%s'"):format(directory))
        return false
    end

    if not path.validname(filename) then
        mpv.msg.error(("Invalid filename '%s'"):format(filename))
        return false
    end
    return true
end

function calculate_filename(dir_template, file_template, filetype)
    local dir = path.normpath(path.expanduser(parse_vars(dir_template)))
    local file = parse_vars(file_template) ..path.extsep.. filetype
    return dir, file
end

function execute_on_file(dir_template, file_template, filetype,
                         action, success_message, failure_message)
    local dir, file = calculate_filename(dir_template, file_template, filetype)

    if not check_path(dir, file) then
        mpv.show(failure_message)
        return
    end

    local p = path.join(dir, file)
    if not path.exists(p) then
        action(p)
        mpv.show(success_message:format(file))
    else
        mpv.msg.warn(("File already exists '%s'"):format(file))
    end
end


function normalize_anime(name)
    name = name:gsub('^[[(].-[])]', '')
    name = name:gsub('[[(].*[])]$', '')
    name = name:gsub('[_.]', ' ')
    name = name:strip()
    return name
end

function parse_vars(str)
    return mpv.parse_vars(str, function (s)
        if s == 'anime' then return opts.name end
        if s == 'episode' then return mpv.get('playlist-pos') + 1 end

        if s == 'playtime' then
            return utils.format_time(mpv.get('playback-time'), true) end

        if s == 'start-time' then
            return utils.format_time(recorder.st or 0, true) end
        if s == 'end-time'   then
            return utils.format_time(recorder.et or 0,  true) end

        return nil
    end)
end


function take_screenshot()
    execute_on_file(
        opts['screens-dir'], opts['screens-file'], opts['screens-type'],
        function(p) mpv.do_('screenshot_to_file', p) end,
        "Screenshot: '%s'", "Failled to take screenshot!")
end
function gfy_toggle()
    if recorder.recording then
        recorder:finish()
        execute_on_file(
            opts['gfy-dir'], opts['gfy-file'], opts['gfy-type'],
            function(p) recorder:write(p) end,
            "GFY: '%s'", "Failed to create GFY!")
    else
        recorder:start()
    end
end
function gfy_cancel()
    recorder:cancel()
end


function setup_script_messages()
    mpv.register_script_message('calculate-filename', function()
        print(calculate_filename(opts['screens-dir'], opts['screens-file'],
                                 opts['screens-type']))
    end)

    mpv.register_script_message('take-screenshot', take_screenshot)
    mpv.register_script_message('gfy-toggle',      gfy_toggle)
    mpv.register_script_message('gfy-cancel',      gfy_cancel)
    mpv.enable_key_bindings('anime')
end

function do_opts()
    local function find_anime_name(_, p)
        local rel = path.normpath(p)
        local abs = path.normpath(path.join(osx.getcwd(), rel))

        local name = path.basename(path.dirname(abs))
        for _, v in ipairs(opts['base-dir']) do
            if v == path.dirname(rel) or v == path.dirname(abs) then
                name, _ = path.splitext(path.basename(abs))
            end
        end

        opts.name = normalize_anime(name)
        print(("now watching '%s'"):format(opts.name))
    end

    local opts = {
        ['mode'] = false,

        ['name'] = '',
        ['base-dir'] = '',

        ['screens-dir'] = '.',
        ['screens-file'] = 'shot-${playtime}',
        ['screens-type'] = 'jpg',

        ['gfy-dir'] = '.',
        ['gfy-file'] = 'gfy-${start-time}-${end-time}',
        ['gfy-type'] = 'mp4'
    }
    mpv.options.read(opts)
    if not opts.mode then return nil end  -- master doesn't want us to load :(

    if opts.name == '' then
        mpv.observe_property('path', 'string', find_anime_name)
    end

    opts['base-dir'] = mpv.options.parse_list(opts['base-dir'])
    for i, v in ipairs(opts['base-dir']) do
        opts['base-dir'][i] = path.normpath(path.expanduser(v))
    end

    return opts
end

function main()
    opts = do_opts()
    if not opts then return end

    setup_script_messages()
    recorder = gfy.GFYRecorder.new()
end

main()
