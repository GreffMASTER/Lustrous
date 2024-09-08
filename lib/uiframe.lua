local uiframe = {}



function uiframe.draw(img, x, y, w, h)
    local wscale = w - 64; if wscale < 0 then wscale = 0 end
    local hscale = h - 64; if hscale < 0 then hscale = 0 end

    local q_tl = love.graphics.newQuad(0, 0, 64, 64, 512, 512)
    local q_tr = love.graphics.newQuad(64, 0, 64, 64, 512, 512)
    local q_bl = love.graphics.newQuad(0, 64, 64, 64, 512, 512)
    local q_br = love.graphics.newQuad(64, 64, 64, 64, 512, 512)

    local q_t = love.graphics.newQuad(64, 0, 1, 64, 512, 512)
    local q_b = love.graphics.newQuad(64, 64, 1, 64, 512, 512)
    local q_l = love.graphics.newQuad(0, 64, 64, 1, 512, 512)
    local q_r = love.graphics.newQuad(64, 64, 64, 1, 512, 512)

    local q_c = love.graphics.newQuad(64, 64, 1, 1, 512, 512)

    love.graphics.draw(img, q_tl, x, y)
    love.graphics.draw(img, q_tr, x + w, y)

    love.graphics.draw(img, q_bl, x, y + h)
    love.graphics.draw(img, q_br, x + w, y + h)

    love.graphics.draw(img, q_t, x+64, y, 0, wscale, 1)
    love.graphics.draw(img, q_b, x+64, y+h, 0, wscale, 1)

    love.graphics.draw(img, q_l, x, y+64, 0, 1, hscale)
    love.graphics.draw(img, q_r, x+w, y+64, 0, 1, hscale)

    love.graphics.draw(img, q_c, x+64, y+64, 0, wscale, hscale)

    q_tl:release()
    q_tr:release()
    q_bl:release()
    q_br:release()

    q_t:release()
    q_b:release()
    q_l:release()
    q_r:release()

    q_c:release()
end

return uiframe