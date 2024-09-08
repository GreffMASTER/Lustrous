local inputman = {}

local action_meta = {
    __index = {
        id = '',
        name = '',
        keys = {},
        buttons = {},
    }
}

local MAX_BINDS_PER_ACTION = 2

local func_actionPressed
local func_actionReleased

local actions = {}
local actionsKB = {}
local actionsPAD = {}
local reservedKeys = {}
local reservedButtons = {}

function inputman.load(funcPressed, funcReleased)
    print('Loading INPUTMAN')
    funcPressed = funcPressed or function(action_id) end
    funcReleased = funcReleased or function(action_id) end
    func_actionPressed = funcPressed
    func_actionReleased = funcReleased
    actions = {}
    actionsKB = {}
    actionsPAD = {}
    reservedKeys = {}
    reservedButtons = {}
end

function inputman.newAction(action_id, action_name)
    action_id = action_id or ''
    action_name = action_name or ''

    local action = setmetatable({}, action_meta)
    action.id = action_id
    action.name = action_name
    actions[action_id] = action
end

function inputman.addReservedKey(key)
    reservedKeys[key] = true
end

function inputman.removeReservedKey(key)
    reservedKeys[key] = nil
end

function inputman.bindKeyToAction(key, action_id)
    key = key or ''
    action_id = action_id or ''
    local action = actions[action_id]
    if not action then
        print('failed to find', action_id)
        return false
    end
    if reservedKeys[key] then
        print(key, 'is reserved')
        return false
    end
    table.insert(action.keys, 1, key)
    if #action.keys > MAX_BINDS_PER_ACTION then
        local prevkey = action.keys[#action.keys]
        actionsKB[prevkey] = nil
        table.remove(action.keys, #action.keys)
    end
    actionsKB[key] = action
    return true
end

function inputman.keypressed(key, scancode, isrepeat)
    local action = actionsKB[key]
    if not action then
        return
    end
    if action.keys[1] == key or action.keys[2] == key then
        func_actionPressed(action.id, isrepeat)
    end
end

function inputman.keyreleased(key, scancode)
    local action = actionsKB[key]
    if not action then
        return
    end
    if action.keys[1] == key or action.keys[2] == key then
        func_actionReleased(action.id)
    end
end

return inputman