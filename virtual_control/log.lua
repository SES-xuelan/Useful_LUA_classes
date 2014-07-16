--[[
version 2.0
date 20130926
verify wayne
]]

local M = {}
local cfg={}
cfg.debug=true
cfg.debuglog=true
cfg.debugprint=true
function M.initInFileEnd()
    if not cfg.debug then return end
    if not (cfg.debugprint or cfg.debuglog) then return end
    M._resetLogFile(M._getDebugLogFile())
end

--[[
--wayne add
function wdebug(param)
    log.debug(debug.getinfo(2,"S").source, debug.getinfo(2,"l").currentline)
    log.debug(param)
end
]]
M.execFileName = ""
function M.Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

function M.debug(p1, p2, p3, p4, p5, p6)
    local logstr = M._paramstostring(p1, p2, p3, p4, p5, p6)
    --    if cfg.debugprint then
    --        print(logstr)
    --    end
    --    if cfg.debugprint then
    --        M._writeLogFile(M._getDebugLogFile(), logstr)
    --    end
    --todo michael modify
    local execFileName = debug.getinfo(2, "S").source
    local execFileNameShort = ""
    local execFileLine = debug.getinfo(2, "l").currentline
    if cfg.debugprint then
        if M.execFileName ~= execFileName then
            M.execFileName = execFileName
            local list = M.Split(execFileName, "/")
            if #list == 1 then list = M.Split(execFileName, "\\") end
            execFileNameShort = list[#list]
            print("\n" .. execFileNameShort)
        end
        print("Line" .. execFileLine .. ": " .. logstr)
    end

    if cfg.debuglog then
        if execFileNameShort ~= "" then M._writeLogFile(M._getDebugLogFile(), "\n" .. execFileNameShort) end
        M._writeLogFile(M._getDebugLogFile(), tostring(os.date()) .. " Line:" .. execFileLine .. ": " .. logstr)
    end
end

function M.error(p1, p2, p3, p4, p5, p6)
    local logstr = M._paramstostring(p1, p2, p3, p4, p5, p6)
    if not (cfg.errorprint or cfg.errorlog) then return end
    local execFileName = debug.getinfo(2, "S").source
    local execFileNameShort = ""
    local execFileLine = debug.getinfo(2, "l").currentline
    if cfg.errorprint then
        if M.execFileName ~= execFileName then
            M.execFileName = execFileName
            local list = M.Split(execFileName, "/")
            if #list == 1 then list = M.Split(execFileName, "\\") end
            execFileNameShort = list[#list]
            print("\n" .. execFileNameShort)
        end
        print("Line" .. execFileLine .. ": " .. logstr)
    end
    if cfg.errorlog then
        if execFileNameShort ~= "" then M._getErrorLogFile(M._getDebugLogFile(), "\n" .. execFileNameShort) end
        M._writeLogFile(M._getErrorLogFile(), tostring(os.date()) .. " Line:" .. execFileLine .. ": " .. logstr)
    end
    --    if cfg.errorprint then
    --        print(logstr)
    --    end
    --    if cfg.errorlog then
    --        M._writeLogFile(M._getErrorLogFile(), logstr)
    --    end
end

function M._table2str(t, maxlevel)
    local ret = ""
    local print_r_cache = {}
    local function sub_table2str(t, indent, level, maxlevel)
        local ret = ""
        level = level + 1
        if (print_r_cache[tostring(t)]) then
            ret = ret .. indent .. "*" .. tostring(t) .. "\n"
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        ret = ret .. indent .. "[" .. pos .. "] => " .. tostring(t) .. " {" .. "\n"


                        if (not maxlevel) or (level < maxlevel) then
                            ret = ret .. sub_table2str(val, indent .. string.rep(" ", string.len(pos) + 8), level, maxlevel)
                        else
                            ret = ret .. indent .. "more than " .. maxlevel .. " level" .. "\n"
                        end
                        ret = ret .. indent .. string.rep(" ", string.len(pos) + 6) .. "}" .. "\n"
                    elseif (type(val) == "string") then
                        ret = ret .. indent .. "[" .. pos .. '] => "' .. val .. '"' .. "\n"
                    else
                        ret = ret .. indent .. "[" .. pos .. "] => " .. tostring(val) .. "\n"
                    end
                end
            else
                ret = ret .. indent .. tostring(t) .. "\n"
            end
        end
        return ret
    end

    if (type(t) == "table") then
        ret = ret .. tostring(t) .. " {" .. "\n"
        ret = ret .. sub_table2str(t, "  ", 1, maxlevel)
        ret = ret .. "}" .. "\n"
    else
        ret = ret .. sub_table2str(t, "  ", 1, maxlevel)
    end
    ret = ret .. "\n"
    return ret
end

function M._tostring(p, maxlevel)
    if p == nil then return "nil" end
    if type(p) == "table" then return M._table2str(p, maxlevel) end
    return tostring(p)
end

function M._paramstostring(p1, p2, p3, p4, p5, p6)
    local logstr = ""
    if p6 ~= nil or logstr ~= "" then logstr = M._tostring(p6, 3) .. "\t" .. logstr end
    if p5 ~= nil or logstr ~= "" then logstr = M._tostring(p5, 3) .. "\t" .. logstr end
    if p4 ~= nil or logstr ~= "" then logstr = M._tostring(p4, 3) .. "\t" .. logstr end
    if p3 ~= nil or logstr ~= "" then logstr = M._tostring(p3, 3) .. "\t" .. logstr end
    if p2 ~= nil or logstr ~= "" then logstr = M._tostring(p2, 3) .. "\t" .. logstr end
    logstr = M._tostring(p1, 3) .. "\t" .. logstr
    return logstr
end



function M._getDebugLogFile()
    if system.getInfo("platformName") == "Android" then
        return "/sdcard/Download/" .. cfg.appName .. ".debug.log"
    else
        return system.pathForFile("debug.log", system.DocumentsDirectory)
    end
end

function M._getErrorLogFile()
    if system.getInfo("platformName") == "Android" then
        return "/sdcard/Download/" .. cfg.appName .. ".error.log"
    else
        return system.pathForFile("error.log", system.DocumentsDirectory)
    end
end

function M._resetLogFile(fn)
    local fhd = io.open(fn, "w")
    if fhd == nil then return end
    fhd:write("logstart:" .. os.date("%c"))
    fhd:write("\r\n")
    fhd:close()
end

function M._writeLogFile(fn, a)
    local fhd = io.open(fn, "ab")
    if fhd == nil then return end
    fhd:write(a)
    fhd:write("\r\n")
    fhd:close()
end

M.initInFileEnd()
return M