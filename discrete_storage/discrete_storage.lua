--------------------------------------------------------
---
--- Created by Albert
--- 2014-07-02 10:50 AM.
--- 说明:离散存储数据（数字）
---
--------------------------------------------------------
local M = { vars = {} }

--[[
vars={
    key1={---真实值的集合
            1,3,5,1
        }
    },
    key2={
        ...
    }
}
--]]

function M.init(min, max)
    M.min = min or 3
    M.max = max or 10
    M.max = M.max - 1
end

function M.set_value(key, val) --- 设定值（初始化）
    if M.min == nil or M.max == nil then
        M.init()
    end
    val = tonumber(val) or 0
    math.randomseed(tostring(os.clock() * 1000000):reverse():sub(1, 8))
    M.vars[key] = {}
    local val_numbers = math.random(M.min, M.max) --- 分割为几个变量来共同存储【变量数为 val_numbers+1】
    local nums = M.to_manynum(val, val_numbers)
    for i = 1, val_numbers do
        M.vars[key][i] = nums[i]
    end
    log.debug(M.vars)
end

function M.get_value(key) --- 获取值
    if not M.vars[key] then return 0 end

    local vals_total = 0
    for i = 1, #M.vars[key] do
        vals_total = vals_total + M.vars[key][i]
    end
    return vals_total
end

function M.value_add(key, add_num) --- 改变值
    if not M.vars[key] then return end

    local add_table = M.to_manynum(add_num, #M.vars[key])
    for i = 1, #M.vars[key] do
        M.vars[key][i] = M.vars[key][i] + add_table[i]
    end
    log.debug(M.vars)
end

function M.getIntPart(x)
    if x <= 0 then
        return math.ceil(x)
    end
    if math.ceil(x) == x then
        x = math.ceil(x)
    else
        x = math.ceil(x) - 1
    end
    return x
end

function M.to_manynum(num, howmany) --- 将一个数分割为若干个数
    local t = {}
    local val_numbers_total = 0
    for i = 1, howmany - 1 do
        local tmp_num = math.random(0, num)
        t[i] = tmp_num
        val_numbers_total = val_numbers_total + tmp_num
    end
    t[howmany] = num - val_numbers_total
    return t
end

return M