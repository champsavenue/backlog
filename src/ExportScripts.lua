--!strict
-- Plugin: Build _ScriptExport folder (ServerStorage) mirroring Roblox tree with ModuleScripts
-- Étapes d'usage :
-- 1) Plugins → Build Export Folder → crée ServerStorage/_ScriptExport
-- 2) Right-click sur _ScriptExport → Save to File... → choisir .rbxmx
-- 3) Script Python (ci-dessous) → produit un .zip avec l'arborescence et les .lua

local toolbar = plugin:CreateToolbar("Export Scripts")
local button = toolbar:CreateButton("Build Export Folder", "Crée ServerStorage/_ScriptExport avec tous les scripts", "rbxassetid://4458901886")

local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local function safeName(s: string): string
	s = s:gsub("[%c%z]", "")
	s = s:gsub("[%/%\\%:%*%?%\"%<%>%|]", "-")
	s = s:gsub("%s+$", "")
	if #s == 0 then s = "Unnamed" end
	return s
end

local function extFor(inst: Instance): string
	if inst.ClassName == "Script" then
		return ".server.lua"
	elseif inst.ClassName == "LocalScript" then
		return ".client.lua"
	elseif inst.ClassName == "ModuleScript" then
		return ".lua"
	else
		return ".lua"
	end
end

local function fullPathParts(inst: Instance): {string}
	-- ex: {"ServerScriptService","Folder","MyScript.server.lua"}
	local parts = {}
	local current: Instance? = inst
	while current and current ~= game do
		table.insert(parts, 1, safeName(current.Name))
		current = current.Parent
	end
	return parts
end

local function ensureFolder(parent: Instance, name: string): Instance
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("Folder") then
		return existing
	end
	if existing then
		existing:Destroy()
	end
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

local function createOrUniqueName(parent: Instance, base: string): string
	if not parent:FindFirstChild(base) then
		return base
	end
	local i = 2
	while parent:FindFirstChild(("%s (%d)"):format(base, i)) do
		i += 1
	end
	return ("%s (%d)"):format(base, i)
end

local function rebuildExportFolder(): (Instance, number)
	-- Reset
	local root = ServerStorage:FindFirstChild("_ScriptExport")
	if root then root:Destroy() end
	root = Instance.new("Folder")
	root.Name = "_ScriptExport"
	root.Parent = ServerStorage

	local count = 0

	for _, inst in ipairs(game:GetDescendants()) do
		if inst:IsA("LuaSourceContainer") then
			local parts = fullPathParts(inst)
			-- Dernier élément sera le nom de fichier + extension
			local filename = safeName(parts[#parts]) .. extFor(inst)
			parts[#parts] = nil -- on gardera seulement les dossiers

			-- Construire l'arborescence sous _ScriptExport
			local parent: Instance = root
			for _, seg in ipairs(parts) do
				parent = ensureFolder(parent, seg)
			end

			-- Créer un ModuleScript (nom = filename)
			local mod = Instance.new("ModuleScript")
			mod.Name = createOrUniqueName(parent, filename)

			-- Copier la source
			local ok, src = pcall(function()
				-- @ts-ignore
				return (inst :: LuaSourceContainer).Source
			end)
			if ok and typeof(src) == "string" then
				-- @ts-ignore
				(mod :: ModuleScript).Source = src
			else
				-- @ts-ignore
				(mod :: ModuleScript).Source = "-- [Erreur] Impossible de lire: " .. inst:GetFullName()
			end

			mod.Parent = parent
			count += 1
		end
	end

	return root, count
end

button.Click:Connect(function()
	local t0 = os.clock()
	local _, n = rebuildExportFolder()
	local dt = os.clock() - t0
	warn(("[Export] %d scripts copiés dans ServerStorage/_ScriptExport en %.2fs"):format(n, dt))
end)
