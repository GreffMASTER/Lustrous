local fontman = {}

local default_font = {
    path = nil,
    sizes = {}
}

local font_table = {
    ['default'] = default_font
}

function fontman.loadFont(font_id, font_path)
    print(string.format('FONTMAN: Loading a font \"%s\" from path \"%s\"...', font_id, font_path))
    if font_table[font_id] then
        error(string.format('FONTMAN: Font with the id \"%s\" already exists'))
    end
    local status, _ = pcall(love.graphics.newFont, font_path)
    if not status then -- failed to load the custom font, use default instead
        print(string.format('FONTMAN: Error, failed to load the font \"%s\" from path \"%s\"; using default font instead', font_id, font_path))
        return false
    end
    local new_font_tab = {
        path = font_path,
        sizes = {}
    }
    font_table[font_id] = new_font_tab
    return true
end

local function getFontFromFontTable(font_size, font_tab)
    if not font_tab.sizes[font_size] then -- size not found, make new font for this size
        if font_tab.path then -- is custom font (has path to font file)
            print(string.format('Creating new \"%s\" font of size %i', font_tab.path, font_size))
            local status, new_font = pcall(love.graphics.newFont, font_tab.path, font_size)
            if not status then
                error('The font file has been removed (probably)')
            end
            font_tab.sizes[font_size] = new_font
            return new_font
        end
        -- use default
        print(string.format('Creating new default font of size %i', font_size))
        local new_font = love.graphics.newFont(font_size)
        font_tab.sizes[font_size] = new_font
        return new_font
    end
    return font_tab.sizes[font_size]
end

function fontman.getFont(font_size, font_id)
    font_id = font_id or 'default'
    if type(font_size) ~= 'number' then
        error('The \"size\" argument must be a number')
    end

    local font_tab = font_table[font_id]
    if not font_tab then
        font_tab = font_table.default
    end
    return getFontFromFontTable(font_size, font_tab)
end

return fontman