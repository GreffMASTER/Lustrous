local profile = {
    name = '',
    avatar = 'lustrous.bloxy',
    settings = {
        flip_z_x = false
    },
    statistics = {
        score = {
            club = 0,
            ta = {}
        },
        level = 0
    },
}

profile.__index = profile

local liblmu = require 'lib.lmu'

function profile:getScore(mode, tatime)
    if mode == 'club' then
        return self.statistics.score.club
    elseif mode == 'ta' then
        self.statistics.score.ta[tatime] = self.statistics.score.ta[tatime] or 0
        return self.statistics.score.ta[tatime]
    else
        return 0
    end
end

function profile:getLevel()
    return self.statistics.level
end

function profile:setNewScore(score, mode, tatime)
    if mode == 'club' then
        if score > self.statistics.score.club then
            self.statistics.score.club = score
        end
        return
    end
    if mode == 'ta' then
        self.statistics.score.ta[tatime] = self.statistics.score.ta[tatime] or 0
        if score > self.statistics.score.ta[tatime] then
            self.statistics.score.ta[tatime] = score
        end
        return
    end
end

function profile:setNewLevel(level)
    if level > self.statistics.level then
        self.statistics.level = level
    end
end

function profile:save()
    local sav = {
        name = self.name,
        avatar = self.avatar,
        statistics = self.statistics
    }
    local r, ok = pcall(liblmu.saveLMUFile, 'aprilfools.lmu', sav, true)
    if not r or not ok then
        print('WARNING! Failed to save the profile!')
        print(ok)
    end
end

local function validateAvatar(ident)
    if not ident or type(ident) ~= 'string' then return false end
    for k,v in pairs(_AVATARS) do
        if k == ident then
            return true
        end
    end
    return false
end

function profile.load()
    local t, err = liblmu.loadLMUFile('aprilfools.lmu')
    if not t then
        print('Failed to load profile.')
        print(err)
        return nil
    end

    if not t.name or type(t.name) ~= 'string' then
        print('Wrong profile name')
        return nil
    end

    if not validateAvatar(t.avatar) then
        print('Wrong avatar name, setting to default')
        t.avatar = 'lustrous.bloxy'
    end

    if t.statistics then
        if type(t.statistics.score) == 'number' then t.statistics.score = {club = t.statistics.score, ta = {}} end
        t.statistics.score = t.statistics.score or {club = 0, ta = {}}
        t.statistics.level = t.statistics.level or 0
    end

    local inst = setmetatable({}, profile)
    inst.name = string.sub(t.name, 0, 16)   -- limit to 16 chars
    inst.avatar = t.avatar
    inst.statistics = t.statistics or {score = {club = 0, ta = {}}, level = 0}
    if not _AVATARS[inst.avatar] then error('Default avatar not found! Cannot proceed!') end
    return inst
end

function profile.new()
    print('Creating new profile...')
    local inst = setmetatable({}, profile)
    return inst
end

return profile