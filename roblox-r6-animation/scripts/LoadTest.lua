-- run in the Edit datamodel through execute_luau while scripts/serve.js serves the skill's scripts folder
-- (node serve.js <outDir> <path to roblox-r6-animation/scripts> 8767): pulls the module sources into a fresh
-- ServerStorage.PoserTest folder, a new ModuleScript each run because the Edit VM caches require, checks the syntax
-- first and returns the folder path; the place's own modules are not touched. Delete the folder when the task ends.
local PORT = 8767
local NAMES = {"Tw", "Poser", "Feet", "WeaponRig", "ExampleClips", "ExampleMoves", "ExampleSword"}
local HttpService = game:GetService("HttpService")
local was = HttpService.HttpEnabled
HttpService.HttpEnabled = true
local sources = {}
for _, name in ipairs(NAMES) do
	local ok, src = pcall(HttpService.GetAsync, HttpService, ("http://127.0.0.1:%d/stand/%s.lua"):format(PORT, name))
	if not ok then
		HttpService.HttpEnabled = was
		error(name .. ": " .. tostring(src))
	end
	local fn, err = loadstring(src)
	if not fn then
		HttpService.HttpEnabled = was
		error(name .. " syntax: " .. tostring(err))
	end
	sources[name] = src
end
HttpService.HttpEnabled = was
local old = game.ServerStorage:FindFirstChild("PoserTest")
if old then
	old:Destroy()
end
local root = Instance.new("Folder")
root.Name = "PoserTest"
local modules = Instance.new("Folder")
modules.Name = "Modules"
modules.Parent = root
for _, name in ipairs(NAMES) do
	local m = Instance.new("ModuleScript")
	m.Name = name
	m.Source = sources[name]
	m.Parent = modules
end
root.Parent = game.ServerStorage
return root:GetFullName()
