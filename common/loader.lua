local loader = {}

local song_meta = require 'common.song'
local song_ta_meta = require 'common.song_ta'
local avatar_meta = require 'common.avatar'

local song_min_ver = 1
local song_max_ver = 1
local avatar_min_ver = 1
local avatar_max_ver = 1

local function loadAvatar(fname)
    local av = require( 'avatars.'..string.sub(fname, 0, -5) )
    if getmetatable(av) ~= avatar_meta then
        draw_progress_text('Error, avatar \"'..fname..'\" has missing or incorrect metatable!')
        return
    end
    if av.version < avatar_min_ver then
        draw_progress_text('Error in avatar \"'..fname..'\", avatar version is outdated! Please update the \"version\" field.')
        return
    end
    if av.version > avatar_max_ver then
        draw_progress_text('Error in avatar \"'..fname..'\", this version of the avatar is unsuppored! Please update your game.')
        return
    end
    if av.ident == '' then
        draw_progress_text('Error in avatar \"'..fname..'\", field \"ident\" is unpopulated!')
        return
    end
    if _AVATARS[av.ident] then
        draw_progress_text('Error, \"'..av.ident..'\" is already taken!')
        return
    end
    if av.frontend.name == '' then
        draw_progress_text('Error in avatar \"'..fname..'\", field \"frontend.name\" is unpopulated!')
        return
    end
    if av.frontend.author == '' then
        draw_progress_text('Error in avatar \"'..fname..'\", field \"frontend.author\" is unpopulated!')
        return
    end
    
    _AVATARS[av.ident] = av
end

local function loadSong(fname)
    local sn = require( 'songs.'..string.sub(fname, 0, -5) )
    local sn_meta = getmetatable(sn)
    if sn_meta ~= song_meta and sn_meta ~= song_ta_meta then
        draw_progress_text('Error, song \"'..fname..'\" has missing or incorrect metatable!')
        return
    end
    if sn.version < song_min_ver then
        draw_progress_text('Error in song \"'..fname..'\", song version is outdated! Please update the \"version\" field.')
        return
    end
    if sn.version > song_max_ver then
        draw_progress_text('Error in song \"'..fname..'\", this version of the song is unsuppored! Please update your game.')
        return
    end
    if sn.ident == '' then
        draw_progress_text('Error in song \"'..fname..'\", field \"ident\" is unpopulated!')
        return
    end
    if _AVATARS[sn.ident] then
        draw_progress_text('Error, \"'..sn.ident..'\" is already taken!')
        return
    end
    if sn.frontend.title == '' then
        draw_progress_text('Error in song \"'..fname..'\", field \"frontend.title\" is unpopulated!')
        return
    end
    if sn.frontend.artist == '' then
        draw_progress_text('Error in song \"'..fname..'\", field \"frontend.artist\" is unpopulated!')
        return
    end
    if sn.frontend.skin_author == '' then
        draw_progress_text('Error in song \"'..fname..'\", field \"frontend.skin_author\" is unpopulated!')
        return
    end
    assert(sn.drawBlock ~= nil, 'oops')
    if sn_meta == song_meta then
        _SONGS[sn.ident] = sn
    elseif sn_meta == song_ta_meta then
        _SONGS_TA[sn.ident] = sn
    end
end

function loader.mountContentPack(path)
    local status, ret = pcall(function()
        local file = love.filesystem.newFile(path, 'r')
        local data = file:read('data')
        file:close()

        return love.filesystem.mount(data, '', true)
    end)
    if not status then
        print(string.format('Error, failed to open content pack \"%s\"', path))
        return false
    end
    return ret
end

function loader.loadAvatars()
    -- mount custom avatars
    local avfiles = love.filesystem.getDirectoryItems( 'custom/avatars/' )
    for k,v in pairs( avfiles ) do
        local ext = string.sub( v, -4 )
        if ext == '.zip' then
            v = 'custom/avatars/'..v
            print('Mounting \"'..v..'\"')
            local r = love.filesystem.mount(v, 'avatars', true)
            if not r then
                print('Failed to mount \"'..v..'\"')
            end
        end
    end

    local avfiles = love.filesystem.getDirectoryItems( 'avatars/' )
    for k,v in pairs( avfiles ) do
        local ext = string.sub( v, -4 )
        if ext == '.lua' then
            loadAvatar(v)
        end
    end
end

function loader.loadSongs()
    -- mount custom songs
    local snfiles = love.filesystem.getDirectoryItems( 'custom/songs/' )
    for k,v in pairs( snfiles ) do
        local ext = string.sub( v, -4 )
        if ext == '.zip' then
            v = 'custom/songs/'..v
            print('Mounting \"'..v..'\"')
            local r = love.filesystem.mount(v, 'songs', true)
            if not r then
                print('Failed to mount \"'..v..'\"')
            end
        end
    end
    local songfiles = love.filesystem.getDirectoryItems( 'songs/' )
    for k,v in pairs( songfiles ) do
        if string.sub( v, -4 ) == '.lua' then
            draw_progress_text('Loading song no. '..(k*0.5)..': \"'..v..'\"')
            loadSong(v)
        end
    end
end

return loader