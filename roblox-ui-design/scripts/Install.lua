local HttpService = game:GetService("HttpService")
local ScriptEditorService = game:GetService("ScriptEditorService")

return function(names, parent, port)
	port = port or 8775
	local was = HttpService.HttpEnabled
	HttpService.HttpEnabled = true
	local done = {}
	for _, name in names do
		local ok, src = pcall(HttpService.GetAsync, HttpService, ("http://127.0.0.1:%d/src/%s.lua"):format(port, name))
		if not ok then
			HttpService.HttpEnabled = was
			error(name .. ": " .. tostring(src))
		end
		local fn, err = loadstring(src)
		if not fn then
			HttpService.HttpEnabled = was
			error(name .. " syntax: " .. tostring(err))
		end
		local m = parent:FindFirstChild(name)
		if m then
			ScriptEditorService:UpdateSourceAsync(m, function()
				return src
			end)
		else
			m = Instance.new("ModuleScript")
			m.Name = name
			m.Source = src
			m.Parent = parent
		end
		table.insert(done, m:GetFullName())
	end
	HttpService.HttpEnabled = was
	return table.concat(done, ", ")
end
