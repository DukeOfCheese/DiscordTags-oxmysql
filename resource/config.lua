Config = {}

Config.Debug = true

-- If true, the player's own headtag will be shown.
Config.ShowOwnTag = true

Config.Custombanner = {
	enabled = false,
	url = "https://files.catbox.moe/yd0389.png",
}

Config.Menu = {
	glare = false,
}

-- Format Display Name is the format of the player's headtag.
-- {HEADTAG} is the player's headtag.
-- {SPEAKING} is the player's speaking status aka colour.
-- {SERVER_ID} is the server's ID.
Config.FormatHeadtagDisplayName = "{HEADTAG} {SPEAKING}[{SERVER_ID}]"

-- Format Display Name is the format of the player's headtag.
-- {GANGTAG} is the player's gangtag.
-- {SPEAKING} is the player's speaking status aka colour.
-- {SERVER_ID} is the server's ID.
Config.FormatGangtagDisplayName = "{GANGTAG}"

-- Display Height is the height of the tag above the player.
-- a higher value will be higher above the player and a lower value will be lower.
Config.HeadtagDisplayHeight = 1.3
Config.GangtagDisplayHeight = 1.1

-- The distance you have to be within to see the tags.
Config.PlayerNamesDist = 15

-- If true, the search button for the tag menu will be enabled.
Config.EnableSearch = true

Config.menu = {
	x = 1400,
	y = 100,
}

-- HUD Configuration
Config.hud = {
    enabled = true,  -- Enable/disable the HUD
    position = {
        x = 30,      -- Distance from right edge of screen
        y = 30       -- Distance from top of screen
    }
}

-- If true, the highest role will be set automatically.
Config.AutoSetHighestRole = false 

-- If true, if a user hides their tags, their server ID is hidden too
Config.hideTagsServerID = true

 -- Relevant tag ACEs
 -- Ability to use all tags
Config.allTags = 'discordtags.all'

 -- Permission to use `/toggletags`
Config.hideTagsAce = 'discordtags.toggletags'

-- ## DEVELOPERS
-- NO THIS IS NOT A NO CLIP
-- this is the perm they need to trigger the server event to hide their full headtag and server id so when they are in no clip nothing is giving them away
-- that they are there
--[[
	Lua Server Event that triggers the client to hide their headtag and server id
	TriggerServerEvent("discordtags:server:noclip")
]]
Config.noclip = 'discordtags.noclip'

 -- Whether to use oxmysql as source of tags or rolelist below
 -- If this is set to true, tags below are ignored
Config.useDb = true

-- The Last in the index will be the highest role.
-- aka the highest role will be the last one in the table or the bottem one.
-- hey stinkers default can only be applied to one or it just will not work.... thats the point of a default role
-- *********************************************************
-- **************IGNORED IF USING DB ABOVE******************
-- *********************************************************
Config.headtagRoleList = {
	{ ace = "headtags.member", label = "~g~Member", default = true },
	{ ace = "headtags.developer", label = "~b~Developer"},
	{ ace = "headtags.staff", label = "~r~Staff"},
	{ ace = "headtags.owner", label = "~p~Owner"},
}

Config.gangtagRoleList = {
	{ ace = "gangtags.member", label = "~g~Grove Street"},
	{ ace = "gangtags.developer", label = "~b~Ballas"},
	{ ace = "gangtags.staff", label = "~r~Staff"},
}