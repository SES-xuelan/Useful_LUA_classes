--------------------------------------------------------
---
--- Created by Albert
--- 2014-06-30 13:13 PM.
--- 说明：虚拟控制
---
--------------------------------------------------------
local widget = require"widget"
local M = {}

function M.init(settings_table)
    M.settingsTable = settings_table
    M.setting_mode = M.settingsTable.setting_mode
    --- -direction
    if M.settingsTable.direction._show then
        if M.settingsTable.direction._type == "button_only" then
            M._ctrl = M._ctrl or {}
            local options1 = {
                x = M.settingsTable.direction.x,
                y = M.settingsTable.direction.y - M.settingsTable.direction.img_size,
                defaultFile = M.settingsTable.direction.img_u,
                overFile = M.settingsTable.direction.img_u_o,
                onEvent = function(event)
                --mgr_audio.playSound("click")
                    M.direction4_ontouch(1, event)
                end
            }
            M._ctrl[1] = widget.newButton(options1) --- UP
            local options2 = {
                x = M.settingsTable.direction.x,
                y = M.settingsTable.direction.y + M.settingsTable.direction.img_size,
                defaultFile = M.settingsTable.direction.img_d,
                overFile = M.settingsTable.direction.img_d_o,
                onEvent = function(event)
                --mgr_audio.playSound("click")
                    M.direction4_ontouch(2, event)
                end
            }
            M._ctrl[2] = widget.newButton(options2) --- Down
            local options3 = {
                x = M.settingsTable.direction.x - M.settingsTable.direction.img_size,
                y = M.settingsTable.direction.y,
                defaultFile = M.settingsTable.direction.img_l,
                overFile = M.settingsTable.direction.img_l_o,
                onEvent = function(event)
                --mgr_audio.playSound("click")
                    M.direction4_ontouch(3, event)
                end
            }
            M._ctrl[3] = widget.newButton(options3) --- Left
            local options4 = {
                x = M.settingsTable.direction.x + M.settingsTable.direction.img_size,
                y = M.settingsTable.direction.y,
                defaultFile = M.settingsTable.direction.img_r,
                overFile = M.settingsTable.direction.img_r_o,
                onEvent = function(event)
                --mgr_audio.playSound("click")
                    M.direction4_ontouch(4, event)
                end
            }
            M._ctrl[4] = widget.newButton(options4) --- Right
        elseif M.settingsTable.direction._type == "rocker" then
            local options = {
                x = M.settingsTable.direction.x,
                y = M.settingsTable.direction.y,
                defaultFile = M.settingsTable.direction.rocker_img,
                overFile = M.settingsTable.direction.rocker_img_o,
                onEvent = function(event)
                --mgr_audio.playSound("click")
                    M.direction8_ontouch(M.settingsTable.direction.rocker_button_num, event)
                end
            }
            M.rocker_ctrl = widget.newButton(options)
        end
    end
    --- buttons
    M._button = {}
    for i = 1, M.settingsTable.button_num do
        local options = {
            x = M.settingsTable["button_" .. tostring(i)].x,
            y = M.settingsTable["button_" .. tostring(i)].y,
            defaultFile = M.settingsTable["button_" .. tostring(i)].img,
            overFile = M.settingsTable["button_" .. tostring(i)].img_o,
            onEvent = function(event)
            --mgr_audio.playSound("click")
                M.button_ontouch(i, event)
            end
        }
        M._button[i] = widget.newButton(options)
    end
end

function M.change_mode(value)
    M.setting_mode = value
end

function M.button_ontouch(buttonindex, event)
    local t = event.target or event
    local phase = event.phase
    if "began" == phase then
        local parent = t.parent --- -这4句确定父窗体并设置焦点
        parent:insert(t)
        display.getCurrentStage():setFocus(t)
        t.isFocus = true
        if M.setting_mode then
            t.x0 = event.x - t.x
            t.y0 = event.y - t.y
        else
            M.settingsTable["button_" .. tostring(buttonindex)]._began(buttonindex)
        end
    elseif t.isFocus then
        if "moved" == phase then
            if M.setting_mode then
                t.x = event.x - t.x0
                t.y = event.y - t.y0
            end
        elseif "ended" == phase or "cancelled" == phase then
            display.getCurrentStage():setFocus(nil)
            t.isFocus = false
            if M.setting_mode then

            else
                M.settingsTable["button_" .. tostring(buttonindex)]._end(buttonindex)
            end
        end
    end
end

function M.direction4_ontouch(direction_num, event)
    --- direction_num :上下左右分别用u d l r 表示
    local udlrtable = { "u", "d", "l", "r" }
    local t = event.target or event
    local phase = event.phase
    if "began" == phase then
        local parent = t.parent --- -这4句确定父窗体并设置焦点
        parent:insert(t)
        display.getCurrentStage():setFocus(t)
        t.isFocus = true
        if M.setting_mode then
            t.startX, t.startY = t.x, t.y
            t.x0 = event.x - t.x
            t.y0 = event.y - t.y
            M.relative_position = {} --- 相对位置
            for i = 1, 4 do
                M.relative_position[i] = {}
                M.relative_position[i][1] = M._ctrl[i].x - t.startX
                M.relative_position[i][2] = M._ctrl[i].y - t.startY
            end
        else
            M.settingsTable.direction._began(udlrtable[direction_num])
        end
    elseif t.isFocus then
        if "moved" == phase then
            if M.setting_mode then
                t.x = event.x - t.x0
                t.y = event.y - t.y0
                for i = 1, 4 do
                    M._ctrl[i].x = t.x + M.relative_position[i][1]
                    M._ctrl[i].y = t.y + M.relative_position[i][2]
                end
            end
        elseif "ended" == phase or "cancelled" == phase then
            display.getCurrentStage():setFocus(nil)
            t.isFocus = false
            if M.setting_mode then

            else
                M.settingsTable.direction._end(udlrtable[direction_num])
            end
        end
    end
end

function M.direction8_ontouch(rocker_button_num, event)
    --- 上下左右分别用u d l r 表示
    --- 左上 lu ； 右上 ru； 左下 ld；右下 rd
    local udlrtable = { "u", "d", "l", "r", "lu", "ru", "ld", "rd" }
    local max_move = 50
    local t = event.target or event
    local phase = event.phase
    if "began" == phase then
        local parent = t.parent --- -这4句确定父窗体并设置焦点
        parent:insert(t)
        display.getCurrentStage():setFocus(t)
        t.isFocus = true
        t.startX, t.startY = t.x, t.y
        t.x0 = event.x - t.x
        t.y0 = event.y - t.y
    elseif t.isFocus then
        if "moved" == phase then
            if M.setting_mode then
                t.x = event.x - t.x0
                t.y = event.y - t.y0
            else
                local moved_x = event.x - t.x0 - t.startX
                local moved_y = event.y - t.y0 - t.startY
                local moved_line = math.sqrt(moved_x ^ 2 + moved_y ^ 2)
                if moved_line < max_move then
                    t.x = event.x - t.x0
                    t.y = event.y - t.y0
                else
                    t.x = max_move * moved_x / moved_line + t.startX
                    t.y = max_move * moved_y / moved_line + t.startY
                end
                local return_direction
                if rocker_button_num == 4 then
                    if math.abs(moved_x) > math.abs(moved_y) then --- X轴移动大于Y轴移动
                        if moved_x > 0 then
                            return_direction = 4 --- R
                        else
                            return_direction = 3 --- L
                        end
                    else
                        if moved_y > 0 then
                            return_direction = 2 --- D
                        else
                            return_direction = 1 --- U
                        end
                    end
                else
                    local tan22_5 = 0.4142135623731 --- tan22.5°
                    local tan67_5 = 2.4142135623731 --- tan67.5°
                    local abs_movedx = math.abs(moved_x)
                    local abs_movedy = math.abs(moved_y)
                    if abs_movedx > abs_movedy then --- X轴移动大于Y轴移动
                        if moved_x > 0 then
                            if abs_movedy / abs_movedx <= tan22_5 then
                                return_direction = 4 --- R
                            else
                                if moved_y < 0 then
                                    return_direction = 6 --- RU
                                else
                                    return_direction = 8 --- RD
                                end
                            end
                        else
                            if abs_movedy / abs_movedx <= tan22_5 then
                                return_direction = 3 --- L
                            else
                                if moved_y < 0 then
                                    return_direction = 5 --- LU
                                else
                                    return_direction = 7 --- LD
                                end
                            end
                        end
                    else --- Y轴移动大于X轴移动
                        if moved_y > 0 then
                            if abs_movedy / abs_movedx >= tan67_5 then
                                return_direction = 2 --- D
                            else
                                if moved_x < 0 then
                                    return_direction = 7 --- LD
                                else
                                    return_direction = 8 --- RD
                                end
                            end
                        else
                            if abs_movedy / abs_movedx >= tan67_5 then
                                return_direction = 1 --- U
                            else
                                if moved_x < 0 then
                                    return_direction = 5 --- LU
                                else
                                    return_direction = 6 --- RU
                                end
                            end
                        end
                    end
                end
                if M.direction8_timer then
                    timer.cancel(M.direction8_timer)
                    M.direction8_timer = nil
                end
                M.direction8_timer = timer.performWithDelay(M.settingsTable.direction.rocker_event_time,
                    function()
                        M.settingsTable.direction.rocker_event(rocker_button_num, udlrtable[return_direction])
                    end, 0)

                --log.debug(moved_x,moved_y)
            end
        elseif "ended" == phase or "cancelled" == phase then
            display.getCurrentStage():setFocus(nil)
            t.isFocus = false
            if M.setting_mode then

            else
                timer.cancel(M.direction8_timer)
                M.direction8_timer = nil
                t.x, t.y = t.startX, t.startY
            end
        end
    end
end

function M.show() --- 显示按钮们
    if M._ctrl then
        for i = 1, #M._ctrl do
            M._ctrl[i].isVisible = true
        end
    end
    if M.rocker_ctrl then
        M.rocker_ctrl.isVisible = true
    end
    if M._button then
        for i = 1, M.settingsTable.button_num do
            M._button[i].isVisible = true
        end
    end
end

function M.hide() --- 隐藏按钮们
    if M._ctrl then
        for i = 1, #M._ctrl do
            M._ctrl[i].isVisible = false
        end
    end
    if M.rocker_ctrl then
        M.rocker_ctrl.isVisible = false
    end
    if M._button then
        for i = 1, M.settingsTable.button_num do
            M._button[i].isVisible = false
        end
    end
end

function M.export_settings() --- 返回所有按钮的设置（以便储存到本地，下次直接load，无需再次调整位置）
    if M.settingsTable.direction._show then
        if M.settingsTable.direction._type == "button_only" then
            M.settingsTable.direction.x = M._ctrl[3].x
            M.settingsTable.direction.y = M._ctrl[1].y
        else
            M.settingsTable.direction.x = M.rocker_ctrl.x
            M.settingsTable.direction.y = M.rocker_ctrl.y
        end
    end
    for i = 1, M.settingsTable.button_num do
        M.settingsTable["button_" .. tostring(i)].x = M._button[i].x
        M.settingsTable["button_" .. tostring(i)].y = M._button[i].y
    end
    return M.settingsTable
end

return M