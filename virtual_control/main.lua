display.setStatusBar(display.HiddenStatusBar)
local widget = require"widget"
local vc = require("virtual_control")
log = require"log"
local settingsTable = {
    setting_mode = false, --- 是否为设置模式，设置模式可以移动按钮的位置，并且不触发按钮事件
    button_num = 2, --- 除了方向键，还有多少个按钮
    direction = {
        --- 方向键
        _show = true, --- 是否显示
        _type = "rocker", --- 方向键风格 button_only 仅方向键(支持4个方向)；rocker 8个方向的摇杆
        rocker_button_num = 8, --- 4或者8 识别几个方向
        _began = function(which) --- 被按下执行的function，which代表按下了哪个键（1234代表上下左右）
            print("direction began", which)
        end,
        _end = function(which) --- 弹起执行的function
            print("direction ended", which)
        end,
        rocker_event_time = 500, --- 多长时间(毫秒)执行一次rocker_event
        rocker_event = function(rocker_button_num, returns) --- rocker模式的事件处理
            print("rocker mode", rocker_button_num, returns)
        end,
        img_u = "img/up.png", --- 方向键图片
        img_u_o = "img/up_o.png",
        img_d = "img/down.png", --- 方向键图片
        img_d_o = "img/down_o.png",
        img_l = "img/left.png", --- 方向键图片
        img_l_o = "img/left_o.png",
        img_r = "img/right.png", --- 方向键图片
        img_r_o = "img/right_o.png",
        rocker_img = "img/rocker.png",
        rocker_img_o = "img/rocker.png",
        img_size = 100, --- 100代表：如果_type是button_only，则图片为100x200 ； 如果_type是rocker 则图片为100x100
        x = 300, --- 位置
        y = 300
    },
    button_1 = {
        --- 按钮1
        _show = true, --- 是否显示
        _began = function(which) --- 被按下执行的function，which代表按下了哪个键（1234代表上下左右）
            print("button_1 began", which)
        end,
        _end = function(which) --- 弹起执行的function
            print("button_1 ended", which)
        end,
        img = "img/btn.png", --- 按钮图片
        img_o = "img/btn_o.png",
        x = 300, --- 位置
        y = 600
    },
    button_2 = {
        --- 按钮2
        _show = true, --- 是否显示
        _began = function(which) --- 被按下执行的function，which代表按下了哪个键（1234代表上下左右）
            print("button_2 began", which)
        end,
        _end = function(which) --- 弹起执行的function
            print("button_2 ended", which)
        end,
        img = "img/btn.png", --- 按钮图片
        img_o = "img/btn_o.png",
        x = 300, --- 位置
        y = 700
    }
}

vc.init(settingsTable)

local btn = widget.newButton({
    x = 100,
    y = 100,
    label = "change_mode",
    onPress = function()
        local b = not vc.setting_mode
        vc.change_mode(b)
        if not b then
            log.debug(vc.export_settings())
        end
    end
})
local b = true
local btn1 = widget.newButton({
    x = 300,
    y = 100,
    label = "change_visible",
    onPress = function()
        if b then
            vc.hide()
        else
            vc.show()
        end
        b = not b
    end
})
