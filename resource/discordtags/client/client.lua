local isMenuOpen = false
local playerNamesDist2 = Config.PlayerNamesDist * Config.PlayerNamesDist
local searchQuery = ""

htPrefixes = {}
gtPrefixes = {}
local headtags = {}
local gangtags = {}

local activeHeadTagTracker = {}
local activeGangTagTracker = {}

local hidePrefix = {}
local hideTags = {}
local hideAll = false
local noclip = {}

function DrawText3D(coords, text, size, font)
    local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)

    local camCoords = GetFinalRenderedCamCoord()
    local distance = #(vector - camCoords)

    size = size or 1
    font = font or 0

    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0, 0.55 * scale)
    SetTextFont(font)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()

    BeginTextCommandDisplayText("STRING")
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(vector.x, vector.y, vector.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

RegisterNetEvent("discordtags:client:hideTag", function(arr, error)
	hideTags = arr
end)

RegisterNetEvent("discordtags:client:toggleAllTags", function(val, error)
	hideAll = val
end)

RegisterNetEvent("discordtags:client:toggleTag", function(arr, error)
	hidePrefix = arr
end)

RegisterNetEvent("discordtags:client:updateTags", function(activeHeadTagTrack, activeGangTagTrack, error)
	activeHeadTagTracker = activeHeadTagTrack
    activeGangTagTracker = activeGangTagTrack
end)

RegisterNetEvent("discordtags:client:noclip", function(player)
    noclip[player] = not noclip[player]
    Debug("Noclip toggled for player " .. player .. ": " .. tostring(noclip[player]))
end)


Citizen.CreateThread(function()
	Citizen.Wait(100);
	SendNUIMessage({
		type = 'config',
		enabled = Config.hud.enabled,
		position = Config.hud.position
	})

    headtags, gangtags, activeHeadTagTracker, activeGangTagTracker = lib.callback.await('discordtags:server:getTags')
end)

RegisterNetEvent('discordtags:client:updateHeadtag', function(headtag)
    if headtag == nil then headtag = 'N/A' return end
	SendNUIMessage({
		type = 'updateHeadtag',
		headtag = tostring(headtag),
	})
end)

RegisterNetEvent('discordtags:client:updateGangtag', function(gangtag)
    if gangtag == nil then gangtag = 'N/A' return end
	SendNUIMessage({
		type = 'updateGangtag',
		gangtag = tostring(gangtag),
	})
end)

local function TriggerTagUpdate()
    if hideAll then return end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local activePlayers = GetActivePlayers()

    for i = 0, #activePlayers do
        local targetPed = GetPlayerPed(activePlayers[i])
        if NetworkIsPlayerActive(activePlayers[i]) then
            local serverId = GetPlayerServerId(activePlayers[i])
            if noclip[serverId] then goto continue end

            local activeHeadTag = activeHeadTagTracker[GetPlayerServerId(activePlayers[i])] or ''
            local activeGangTag = activeGangTagTracker[GetPlayerServerId(activePlayers[i])] or ''
            local targetCoords = GetEntityCoords(targetPed)
            local dx, dy, dz = playerCoords.x - targetCoords.x, playerCoords.y - targetCoords.y, playerCoords.z - targetCoords.z
            local distance2 = dx*dx + dy*dy + dz*dz

            if distance2 < playerNamesDist2 then
                local playName = GetPlayerName(activePlayers[i])

                if targetPed == playerPed and not Config.ShowOwnTag then
                    goto continue
                end

                if HasValue(hideTags, playName) then goto continue end

                if HasValue(hidePrefix, playName) then
                    if targetPed ~= playerPed or Config.ShowOwnTag and not Config.hideTagsServerID then
                        DrawText3D(vector3(targetCoords.x, targetCoords.y, targetCoords.z + Config.HeadtagDisplayHeight), "~w~[" .. serverId .. "]", 1, 0)
                    end
                    goto continue
                end

                if targetPed ~= playerPed and not HasEntityClearLosToEntity(playerPed, targetPed, 17) then
                    goto continue
                end

                local headtagName = Config.FormatHeadtagDisplayName
                local gangtagName = Config.FormatGangtagDisplayName
                local color = NetworkIsPlayerTalking(activePlayers[i]) and "~b~" or "~w~"

                headtagName = headtagName:gsub("{HEADTAG}", activeHeadTag):gsub("{SERVER_ID}", serverId):gsub("{SPEAKING}", color)
                gangtagName = gangtagName:gsub("{GANGTAG}", activeGangTag)

                DrawText3D(vector3(targetCoords.x, targetCoords.y, targetCoords.z + Config.HeadtagDisplayHeight), color .. headtagName, 1, 0)
                DrawText3D(vector3(targetCoords.x, targetCoords.y, targetCoords.z + Config.GangtagDisplayHeight), color .. gangtagName)
            end
            ::continue::
        end
    end
end

Citizen.CreateThread(function()
    while true do
        TriggerTagUpdate()
        Citizen.Wait(0)
    end
end)


CreateThread(function()
    if not Config.Custombanner.enabled then return end

    local RuntimeTXD = CreateRuntimeTxd('discordtags:banner')
    local Object = CreateDui(Config.Custombanner.url, 512, 128)

    local dui = GetDuiHandle(Object)
    CreateRuntimeTextureFromDuiHandle(RuntimeTXD, 'discordtags:banner', dui)
end)

local headtagMenu = RageUI.CreateMenu("Headtag Menu", "~b~Headtag Menu | By JoeV2 and DukeOfCheese", 1400, 100, (Config.Custombanner.enabled and 'headtag:banner' or nil), (Config.Custombanner.enabled and 'headtag:banner' or nil), 255, 255, 255, 255)
headtagMenu:SetTotalItemsPerPage(8)
headtagMenu:DisplayGlare(Config.Menu.glare)


---@diagnostic disable-next-line: inject-field
headtagMenu.Closed = function()
    isMenuOpen = false
end

RegisterCommand('headtags', function()
    if isMenuOpen then
        isMenuOpen = false
        RageUI.CloseAll()
    else
        OpenHeadtagMenu()
    end
end, false)

function OpenHeadtagMenu()
    if isMenuOpen then return end

    -- local headtags = lib.callback.await('discordtags:return-tags', 1)
    -- local headtags = htPrefixes[cache.serverId]

    if not headtags or #headtags == 0 then
        lib.notify({
            title = 'Headtags',
            description = 'You don\'t have access to any headtags',
            type = 'error',
            duration = 5000
        })
        return
    end

    isMenuOpen = true
    searchQuery = ""
    RageUI.Visible(headtagMenu, true)

    Citizen.CreateThread(function()
        while isMenuOpen do
            Wait(1)
            RageUI.IsVisible(headtagMenu, function()
                if Config.EnableSearch then
                    RageUI.Button("Search Tags", searchQuery == "" and "Click to search tags" or "Current search: " .. searchQuery, { RightLabel = "" }, true, {
                        onSelected = function()
                            local input = lib.inputDialog('Headtag Search', {
                                { type = 'input', label = 'Search Query', description = 'Enter text to filter tags' }
                            })
                            if input then
                                searchQuery = input[1]:lower()
                            end
                        end
                    }, nil)
                end

                RageUI.Separator("")


                local foundMatch = false
                for i = 1, #headtags do
                    local tag = headtags[i]
                    if not Config.EnableSearch or searchQuery == "" or string.find(string.lower(tag), searchQuery) then
                        foundMatch = true
                        RageUI.Button('~y~[' .. i .. ']~s~ ' .. tag, "Select headtag " .. tag, { --[[ RightLabel = "→→→" ]]}, true, {
                            onSelected = function()
                                TriggerServerEvent('discordtags:server:setHeadTag', tag)
                            end
                        }, nil)
                    end
                end

                if Config.EnableSearch and not foundMatch and searchQuery ~= "" then
                    lib.notify({
                        title = 'Headtag Search',
                        description = 'No headtags found matching: ' .. searchQuery,
                        type = 'error',
                        duration = 5000
                    })
                    searchQuery = ""
                end

                if Config.EnableSearch and searchQuery ~= "" then
                    RageUI.Button("Clear Search", "Clear current search filter", { RightLabel = "→→→" }, true, {
                        onSelected = function()
                            searchQuery = ""
                        end
                    }, nil)
                end
            end)

            if not RageUI.Visible(headtagMenu) then
                isMenuOpen = false
                break
            end
        end
    end)
end

local gangtagMenu = RageUI.CreateMenu("Gangtag Menu", "~b~Gangtag Menu | By JoeV2 and DukeOfCheese", 1400, 100, (Config.Custombanner.enabled and 'gangtag:banner' or nil), (Config.Custombanner.enabled and 'gangtag:banner' or nil), 255, 255, 255, 255)
gangtagMenu:SetTotalItemsPerPage(8)
gangtagMenu:DisplayGlare(Config.Menu.glare)


gangtagMenu.Closed = function()
    isMenuOpen = false
end

RegisterCommand('gangtags', function()
    if isMenuOpen then
        isMenuOpen = false
        RageUI.CloseAll()
    else
        OpenGangtagMenu()
    end
end, false)

function OpenGangtagMenu()
    if isMenuOpen then return end

    -- local gangtags = lib.callback.await('discordtags:return-tags', 2)
    -- local gangtags = gtPrefixes[cache.serverId]

    if not gangtags or #gangtags == 0 then
        lib.notify({
            title = 'Gangtag Menu',
            description = 'You don\'t have access to any gangtags',
            type = 'error',
            duration = 5000
        })
        return
    end

    isMenuOpen = true
    searchQuery = ""
    RageUI.Visible(gangtagMenu, true)

    Citizen.CreateThread(function()
        while isMenuOpen do
            Wait(1)
            RageUI.IsVisible(gangtagMenu, function()
                if Config.EnableSearch then
                    RageUI.Button("Search Tags", searchQuery == "" and "Click to search tags" or "Current search: " .. searchQuery, { RightLabel = "" }, true, {
                        onSelected = function()
                            local input = lib.inputDialog('Gangtag Search', {
                                { type = 'input', label = 'Search Query', description = 'Enter text to filter tags' }
                            })
                            if input then
                                searchQuery = input[1]:lower()
                            end
                        end
                    }, nil)
                end

                RageUI.Separator("")


                local foundMatch = false
                for i = 1, #gangtags do
                    local tag = gangtags[i]
                    if not Config.EnableSearch or searchQuery == "" or string.find(string.lower(tag), searchQuery) then
                        foundMatch = true
                        RageUI.Button('~y~[' .. i .. ']~s~ ' .. tag, "Select gangtag " .. tag, { --[[ RightLabel = "→→→" ]]}, true, {
                            onSelected = function()
                                TriggerServerEvent('discordtags:server:setGangTag', tag)
                            end
                        }, nil)
                    end
                end

                if Config.EnableSearch and not foundMatch and searchQuery ~= "" then
                    lib.notify({
                        title = 'Gangtag Search',
                        description = 'No gangtags found matching: ' .. searchQuery,
                        type = 'error',
                        duration = 5000
                    })
                    searchQuery = ""
                end

                if Config.EnableSearch and searchQuery ~= "" then
                    RageUI.Button("Clear Search", "Clear current search filter", { RightLabel = "→→→" }, true, {
                        onSelected = function()
                            searchQuery = ""
                        end
                    }, nil)
                end
            end)

            if not RageUI.Visible(gangtagMenu) then
                isMenuOpen = false
                break
            end
        end
    end)
end