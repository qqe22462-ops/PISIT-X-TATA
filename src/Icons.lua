--[[
	PISIT HUB | Icons.lua
	--------------------------------------------------------------------
	Small registry mapping icon names to Roblox asset/image ids.

	PISIT HUB does not bundle a full icon-font, but exposes an easily
	extensible table so users of the library can register their own
	icons (e.g. from a Lucide/Feather rbxassetid spritesheet) and
	reference them by name everywhere: Section:CreateButton({Icon="settings"}).
--]]

local Icons = {}

-- Default placeholder set. Replace these ids with your own uploaded
-- icon assets. "logo" is used by the Notification system (icon "P").
Icons.Registry = {
	logo      = "rbxassetid://0",
	settings  = "rbxassetid://0",
	search    = "rbxassetid://0",
	close     = "rbxassetid://0",
	minimize  = "rbxassetid://0",
	check     = "rbxassetid://0",
	chevron   = "rbxassetid://0",
	warning   = "rbxassetid://0",
	success   = "rbxassetid://0",
	error     = "rbxassetid://0",
	info      = "rbxassetid://0",
	keybind   = "rbxassetid://0",
	color     = "rbxassetid://0",
}

--- Registers or overwrites an icon id.
function Icons.Register(name, assetId)
	Icons.Registry[name] = assetId
end

--- Fetches an icon id by name, falling back to a transparent 1x1 if
-- the icon does not exist (prevents red "missing texture" boxes).
function Icons.Get(name)
	return Icons.Registry[name] or "rbxasset://textures/ui/GuiImagePlaceholder.png"
end

return Icons
