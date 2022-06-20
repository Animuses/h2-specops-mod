game:detour("_ID42407", "_ID23778", function()
    missionover(false)
end)

function missionover(success, timeoverride)
    game:ontimeout(function()
        game:setblur(6, 1)
    end, 100)

    game:ambientstop(2)
    game:musicstop(true)

    player:allowjump(false)
    player:disableweapons()
    player:disableusability()
    player:enableinvulnerability()

    local text = game:newhudelem()
    text.font = "bank"
    text.glowalpha = 0.3

    if (success) then
        text.color = vector:new(0.8, 0.8, 1)
        text.glowcolor = vector:new(0.301961, 0.301961, 0.6)
        text:settext("Mission Success!")
        player:playlocalsound("h1_arcademode_mission_success")
    else
        text.hidwhendead = false
        text.color = vector:new(1, 0.4, 0.4)
        text.glowcolor = vector:new(0.7, 0.2, 0.2)
        text:settext("Mission Failed!")
        player:playlocalsound("h1_arcademode_mission_fail")
    end

    text.horzalign = "center"
    text.alignx = "center"
    text.fontscale = 1.2
    text.y = 220
    text:setpulsefx(60, 2500, 500)

    local finaltime = 0
    if (timeoverride) then
        finaltime = timeoverride
        game:setdvar("so_mission_time", timeoverride)
    else
        local time = game:gettime()
        if (starttime) then
            local total = time - starttime
            finaltime = total
            game:setdvar("so_mission_time", total)
        else
            game:setdvar("so_mission_time", 0)
        end
    end

    local mapname = game:getdvar("so_mapname")
    local stats = sostats.getmapstats(mapname)
    if (stats.besttime == nil or type(stats.besttime) ~= "number" or stats.besttime > finaltime) then
        stats.besttime = finaltime
    end

    local stars = type(map.calculatestars) == "function" and map.calculatestars(finaltime) or game:getdvarint("g_gameskill")
    if (stats.stars == nil or type(stats.stars) ~= "number" or stats.stars < stars) then
        stats.stars = stars
    end

    sostats.setmapstats(mapname, stats)

    local ai = game:getaiarray()
    for i = 1, #ai do
        ai[i]:delete()
    end

    local spawners = game:getspawnerarray()
    for i = 1, #spawners do
        spawners[i]:delete()
    end

    game:ontimeout(function()
        player:freezecontrols(true)
        game:setdvar("ui_so_mission_over", success and 1 or 2)

        game:setsaveddvar("hud_showstance", 0)
        game:setsaveddvar("actionSlotsHide", 1)
        game:setsaveddvar("ui_hideCompassTicker", 1)
        game:setsaveddvar("ammoCounterHide", 1)
    end, 3000)
end