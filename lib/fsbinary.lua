local fsb = {}

-- READ FUNCTIONS

function fsb.readInt8(file, signed)
    signed = signed or false

    local data = file:read(1)
    if signed then
        return love.data.unpack('b',data)
    else
        return love.data.unpack('B',data)
    end
end

function fsb.readInt16(file, signed, endian)
    signed = signed or false
    endian = endian or false

    local data = file:read(2)
    if endian then
        if signed then
            return love.data.unpack('>h',data)
        else
            return love.data.unpack('>H',data)
        end
    else
        if signed then
            return love.data.unpack('<h',data)
        else
            return love.data.unpack('<H',data)
        end
    end
end

function fsb.readInt32(file, signed, endian)
    signed = signed or false
    endian = endian or false
    local data = file:read(4)
    if endian then
        if signed then
            return love.data.unpack('>i4',data)
        else
            return love.data.unpack('>I4',data)
        end
    else
        if signed then
            return love.data.unpack('<i4',data)
        else
            return love.data.unpack('<I4',data)
        end      
    end
end

function fsb.readFloat(file)
    local data = file:read(4)
    return love.data.unpack('f', data)
end

function fsb.readNullTermString(file)
    local outstr = ''
    while not file:isEOF() do
        local char = file:read(1)
        if string.byte(char) == 0 then break end
        outstr = outstr .. char
    end
    return outstr
end

function fsb.readSetLenString(file, length)
    local outstr = ''
    for i=1,length,1 do
        local char = file:read(1)
        outstr = outstr .. char
        if file:isEOF() then break end
    end
    return outstr
end

-- WRITE FUNCTIONS

function fsb.writeInt8(file, value)
    file:write(love.data.pack('string','B',value))
    return true
end

function fsb.writeInt16(file, value, endian)
    endian = endian or 'little'
    if endian == 'little' then
        file:write(love.data.pack('string','<H',value))
    else
        file:write(love.data.pack('string','>H',value))
    end
    return true
end

function fsb.writeInt32(file, value, endian)
    endian = endian or 'little'
    if endian == 'little' then
        file:write(love.data.pack('string','<I4',value))
    else
        file:write(love.data.pack('string','>I4',value))
    end
    return true
end

function fsb.writeFloat(file, value)
    file:write(love.data.pack('string','f',value))
    return true
end

return fsb
