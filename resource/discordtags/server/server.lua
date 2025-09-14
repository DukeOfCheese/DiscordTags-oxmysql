local activeHeadTagTracker = {}
local activeGangTagTracker = {}
local hidePrefix = {}
local hideAll = {}
local hideTags = {}
local headtagList = {}
local gangtagList = {}

function HideUserTag(src)
	local playerName = GetPlayerName(src)
	if playerName and GetIndex(hideTags, playerName) == nil then
		table.insert(hideTags, playerName)
		TriggerClientEvent('discordtags:HideTag', -1, hideTags, false)
	end
end

function ShowUserTag(src)
	local playerName = GetPlayerName(src)
	if playerName and GetIndex(hideTags, playerName) ~= nil then
		table.remove(hideTags, GetIndex(hideTags, playerName))
		TriggerClientEvent('discordtags:HideTag', -1, hideTags, false)
	end
end

function GetTagNameByIndex(source, type, index)
    local tags = GetUserTags(source, type)
    if tags and tags[index] then
        return tags[index]
    end
    return nil
end

function ToggleTag(source)
    local name = GetPlayerName(source)
    if HasValue(hidePrefix, name) then
        table.remove(hidePrefix, GetIndex(hidePrefix, name))
		TriggerClientEvent("discordtags:client:updateHeadtag", source, activeHeadTagTracker[source])
		TriggerClientEvent("discordtags:client:updateGangtag", source, activeGangTagTracker[source])
        TriggerClientEvent("discordtags:client:toggleTag", -1, hidePrefix, false)
		lib.notify(source, {
			title = 'Discord Tags',
			description = 'Your tags have been toggled on',
			type = 'success',
			duration = 5000,
		})
    else
        table.insert(hidePrefix, name)
		TriggerClientEvent("discordtags:client:updateHeadtag", source, '~r~Hidden')
		TriggerClientEvent("discordtags:client:updateGangtag", source, '~r~Hidden')
        TriggerClientEvent("discordtags:client:toggleTag", -1, hidePrefix, true)
		lib.notify(source, {
			title = 'Discord Tags',
			description = 'Your tags have been toggled off',
			type = 'error',
			duration = 5000,
		})
    end
end

function ToggleTagsAll(source)
    local name = GetPlayerName(source)
    if HasValue(hideAll, name) then
        table.remove(hideAll, GetIndex(hideAll, name))
        TriggerClientEvent("discordtags:client:toggleAllTags", source, false, false)
		lib.notify(source, {
			title = 'Discord Tags',
			description = 'All tags have been toggled on',
			type = 'success',
			duration = 5000,
		})
    else
        table.insert(hideAll, name)
        TriggerClientEvent("discordtags:client:toggleAllTags", source, true, false)
		lib.notify(source, {
			title = 'Discord Tags',
			description = 'All tags have been toggled off',
			type = 'error',
			duration = 5000,
		})
    end
end

function GetActiveUserTag(src, type)
	if type == 1 then
		if activeHeadTagTracker[tonumber(src)] ~= nil then
			return activeHeadTagTracker[tonumber(src)]
		end
	elseif type == 2 then
		if activeGangTagTracker[tonumber(src)] ~= nil then
			return activeGangTagTracker[tonumber(src)]
		end
	end
	return nil
end

function SetUserTag(source, type, tag)
	if type == 1 then
		activeHeadTagTracker[source] = tag
		TriggerClientEvent("discordtags:client:updateTags", -1, activeHeadTagTracker, activeGangTagTracker, false)
		TriggerClientEvent("discordtags:client:updateHeadtag", source, tag)
		return true
	else
		activeGangTagTracker[source] = tag
		TriggerClientEvent("discordtags:client:updateTags", -1, activeHeadTagTracker, activeGangTagTracker, false)
		TriggerClientEvent("discordtags:client:updateGangtag", source, tag)
		return true
	end
	return false
end

AddEventHandler('playerDropped', function (reason)
	activeHeadTagTracker[source] = nil
	activeGangTagTracker[source] = nil
end)

lib.callback.register('discordtags:server:getTags', function(source)
	local headtags = {}
	local gangtags = {}

	local highestHeadTag = ""
	local highestGangTag = ""

	local defaultHeadTag = nil
	local defaultGangTag = nil

	for i = 1, #headtagList do
		local role = headtagList[i]
		---@diagnostic disable-next-line: param-type-mismatch
		if IsPlayerAceAllowed(source, role.ace) or IsPlayerAceAllowed(source, Config.allTags) then
			Debug(GetPlayerName(source) .. " has headtag for: " .. role.label)
			table.insert(headtags, role.label)
			highestHeadTag = role.label
			if role.default then
				defaultHeadTag = role.label
			end
		else
			Debug(GetPlayerName(source) .. " has no permission for: " .. role.label)
		end
	end

	for i = 1, #gangtagList do
		local role = gangtagList[i]
		---@diagnostic disable-next-line: param-type-mismatch
		if IsPlayerAceAllowed(source, role.ace) or IsPlayerAceAllowed(source, Config.allTags) then
			Debug(GetPlayerName(source) .. " has gangtag for: " .. role.label)
			table.insert(gangtags, role.label)
			highestGangTag = role.label
			if role.default then
				defaultGangTag = role.label
			end
		else
			Debug(GetPlayerName(source) .. " has no permission for: " .. role.label)
		end
	end

	activeHeadTagTracker[source] = Config.AutoSetHighestRole and highestHeadTag or defaultHeadTag
	activeGangTagTracker[source] = Config.AutoSetHighestRole and highestGangTag or defaultGangTag

	TriggerClientEvent("discordtags:client:updateHeadtag", source, activeHeadTagTracker[source] == "" and "N/A" or activeHeadTagTracker[source])
	TriggerClientEvent("discordtags:client:updateGangtag", source, activeGangTagTracker[source] == "" and "N/A" or activeGangTagTracker[source])

	return headtags, gangtags, activeHeadTagTracker, activeGangTagTracker
end)

AddEventHandler('playerDropped', function()
    if activeHeadTagTracker[source] then
        activeHeadTagTracker[source] = nil
    end
	if activeGangTagTracker[source] then
		activeGangTagTracker[source] = nil
	end
end)

RegisterNetEvent('discordtags:server:setHeadTag', function(tag)
	local ped = source
	local success = SetUserTag(ped, 1, tag)

	if success then
		lib.notify(ped, {
			title = 'Headtags',
			description = 'Set your headtag to ' .. RemovePrefixes(tag),
			type = 'success',
			duration = 5000,
		})
	else
		lib.notify(ped, {
			title = 'Headtags',
			description = 'Failed to set headtag',
			type = 'error',
			duration = 5000,
		})
	end
end)

RegisterNetEvent('discordtags:server:setGangTag', function(index)
	local src = source
	local success = SetUserTag(src, 2, index)

	if success then
		local tagName = GetTagNameByIndex(src, 2, index)
		lib.notify(src, {
			title = 'Gangtags',
			description = 'Set your gangtag to ' .. RemovePrefixes(tagName),
			type = 'success',
			duration = 5000,
		})
	else
		lib.notify(src, {
			title = 'Gangtags',
			description = 'Failed to set gangtag',
			type = 'error',
			duration = 5000,
		})
	end
end)

RegisterNetEvent('discordtags:server:toggleTag', function()
    ToggleTag(source)
end)

RegisterNetEvent('discordtags:server:toggleAllTags', function()
    ToggleTagsAll(source)
end)

lib.callback.register('discordtags:return-tags', function(source, type)
    local tags = GetUserTags(source, type)
    return tags
end)

RegisterNetEvent('discordtags:server:noclip', function()
    local source = source
	if not IsPlayerAceAllowed(source, Config.noclip) then return end
    TriggerClientEvent("discordtags:client:noclip", -1, source)
end)

CreateThread(function()
	if not Config.useDb then
		local htCount = 0
		local gtCount = 0
		local htRoles = {}
		local gtRoles = {}

		for i = 1, #Config.headtagRoleList do
			local role = Config.headtagRoleList[i]
			if role.default then
				htCount = htCount + 1
				table.insert(htRoles, role.label)
			end
		end

		for i = 1, #Config.gangtagRoleList do
			local role = Config.gangtagRoleList[i]
			if role.default then
				gtCount = gtCount + 1
				table.insert(gtRoles, role.label)
			end
		end

		if htCount > 1 then
			print("^1[WARNING]^3 Multiple default roles detected in Config.headtagRoleList!")
			print("^1[WARNING]^3 Found " .. htCount .. " default roles: " .. table.concat(htRoles, ", "))
			print("^1[WARNING]^3 Only the first default role will be used: " .. htRoles[1])
			print("^1[WARNING]^3 Please ensure only one role has default = true in your config^7")
		elseif gtCount > 1 then
			print("^1[WARNING]^3 Multiple default roles detected in Config.gangtagRoleList!")
			print("^1[WARNING]^3 Found " .. gtCount .. " default roles: " .. table.concat(gtRoles, ", "))
			print("^1[WARNING]^3 Only the first default role will be used: " .. gtRoles[1])
			print("^1[WARNING]^3 Please ensure only one role has default = true in your config^7")
		else
			for i = 1, #Config.headtagRoleList do
				local role = Config.headtagRoleList[i]
				table.insert(headtagList, { label = role.label, ace = role.ace })
			end

			for i = 1, #Config.gangtagRoleList do
				local role = Config.gangtagRoleList[i]
				table.insert(gangtagList, { label = role.label, ace = role.ace })
			end
		end
	else
		if GetResourceState('oxmysql') ~= "started" then
			print("^1[ERROR]^3 oxmysql is not started and cannot load tags!")
		else
			local htResponse = MySQL.query.await('SELECT `label`, `ace` FROM `discordtags` WHERE `tagtype` = ? OR `tagtype` = ?', { "headtag", "both" })
			if htResponse then
				for i = 1, #htResponse do
					local row = htResponse[i]
					table.insert(headtagList, { label = row.label, ace = row.ace })
				end
			else
				print("^1[WARNING]^s No headtags found in your database!")
			end

			local gtResponse = MySQL.query.await('SELECT `label`, `ace` FROM `discordtags` WHERE `tagtype` = ? OR `tagtype` = ?', { "gangtag", "both" })
			if gtResponse then
				for i = 1, #gtResponse do
					local row = gtResponse[i]
					table.insert(gangtagList, { label = row.label, ace = row.ace })
				end
			else
				print("^1[WARNING]^s No gangtags found in your database!")
			end
		end
	end
end)

RegisterCommand("toggletags", function(source)
	if IsPlayerAceAllowed(source, Config.hideTagsAce) then
		ToggleTag(source)
	else
		lib.notify(source, {
			title = 'Discord Tags',
			description = 'No permission to hide tags',
			type = 'error',
			duration = 5000,
		})
	end
end)

RegisterCommand("hidetags", function(source)
	ToggleTagsAll(source)
end)