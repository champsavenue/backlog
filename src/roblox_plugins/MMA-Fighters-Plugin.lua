--!strict
-- Roblox Studio Plugin: Utils
-- Toolbar "Utils" with:
-- 1) Build Export Folder
-- 2) Check code (audit + save JSON split in AuditReport_PartXXX)
-- 3) View Audit Report in a DockWidget

local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local toolbar = plugin:CreateToolbar("Utils")

----------------------------------------------------------------------
-- [1] EXPORT SCRIPTS
----------------------------------------------------------------------

local exportButton = toolbar:CreateButton(
    "Build Export Folder",
    "Export all scripts into ServerStorage/_ScriptExport",
    "rbxassetid://4458901886"
)

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
	local root = ServerStorage:FindFirstChild("_ScriptExport")
	if root then root:Destroy() end
	root = Instance.new("Folder")
	root.Name = "_ScriptExport"
	root.Parent = ServerStorage

	local count = 0
	for _, inst in ipairs(game:GetDescendants()) do
		if inst:IsA("LuaSourceContainer") then
			local parts = fullPathParts(inst)
			local filename = safeName(parts[#parts]) .. extFor(inst)
			parts[#parts] = nil

			local parent: Instance = root
			for _, seg in ipairs(parts) do
				parent = ensureFolder(parent, seg)
			end

			local mod = Instance.new("ModuleScript")
			mod.Name = createOrUniqueName(parent, filename)

			local ok, src = pcall(function()
				return (inst :: LuaSourceContainer).Source
			end)
			if ok and typeof(src) == "string" then
				(mod :: ModuleScript).Source = src
			else
				(mod :: ModuleScript).Source = "-- [Error] Unable to read: " .. inst:GetFullName()
			end

			mod.Parent = parent
			count += 1
		end
	end

	return root, count
end

exportButton.Click:Connect(function()
	local t0 = os.clock()
	local _, n = rebuildExportFolder()
	local dt = os.clock() - t0
	warn(("[Export] %d scripts copied into ServerStorage/_ScriptExport in %.2fs"):format(n, dt))
end)

----------------------------------------------------------------------
-- [2] SCRIPT AUDITOR
----------------------------------------------------------------------

local auditorButton = toolbar:CreateButton(
    "Check code",
    "Audit all scripts and save report in ServerStorage/AuditReport",
    "rbxassetid://4458901886"
)

-- Severity ranking
local Severities = {
	Critical = 4,
	High = 3,
	Medium = 2,
	Low = 1,
	Info = 0,
}
local function rankToText(n)
	for k,v in pairs(Severities) do
		if v == n then return string.upper(k) end
	end
	return "INFO"
end

-- Helpers
local function hasWaitInBlock(lines, startIdx, endIdx)
	for i = startIdx, math.min(endIdx, #lines) do
		local l = lines[i]
		if l:match("%f[%w_]wait%f[^%w_]") or l:match("task%.wait%s*%(") or l:match("RunService%.Heartbeat:Connect") then
			return true
		end
	end
	return false
end

local function nearHasPcall(lines, idx, radius)
	local fromI = math.max(1, idx - radius)
	local toI = math.min(#lines, idx + radius)
	for i = fromI, toI do
		if lines[i]:match("%f[%w_]pcall%f[^%w_]") then
			return true
		end
	end
	return false
end

local function hasDebounceVar(lines, idx, radius)
	local fromI = math.max(1, idx - radius)
	local toI = math.min(#lines, idx + radius)
	for i = fromI, toI do
		local l = lines[i]
		if l:match("[Dd]ebounce") or l:match("isProcessing") or l:match("cooldown") then
			return true
		end
	end
	return false
end

local function safeGetSource(scr)
	local ok, src = pcall(function() return scr.Source end)
	if ok and typeof(src) == "string" then
		return src
	end
	return nil
end

-- Full path helper (with "game.")
local function getFullNameFast(inst)
	local ok, name = pcall(function() return inst:GetFullName() end)
	if ok then
		return "game." .. name
	end
	local names = {}
	local cur = inst
	while cur do
		table.insert(names, 1, cur.Name)
		cur = cur.Parent
	end
	return "game." .. table.concat(names, ".")
end

-- Analyze one script
local function analyzeSource(src)
	local findings = {}
	if not src or src == "" then
		return findings
	end

	local lines = {}
	for s in (src .. "\n"):gmatch("(.-)\r?\n") do
		table.insert(lines, s)
	end

	local function addFinding(sev, line, code, msg)
		table.insert(findings, {
			severity = rankToText(sev),
			line = line,
			code = code,
			message = msg,
		})
	end

	for i, l in ipairs(lines) do
		if l:match("%f[%w_]wait%f[^%w_]") and not l:match("task%.wait") then
			addFinding(Severities.Medium, i, "WAIT_DEPRECATED", "Use task.wait() instead of wait().")
		end
		if l:match("%f[%w_]spawn%f[^%w_]") then
			addFinding(Severities.Medium, i, "SPAWN_DEPRECATED", "spawn() is deprecated. Use task.spawn().")
		end
		if l:match("%f[%w_]delay%f[^%w_]") then
			addFinding(Severities.Medium, i, "DELAY_DEPRECATED", "delay() is deprecated. Use task.delay().")
		end
		if l:match(":connect%(") then
			addFinding(Severities.Low, i, "CONNECT_LOWERCASE", "Use :Connect() instead of :connect().")
		end
		if l:match("while%s+true%s+do") and not hasWaitInBlock(lines, i, i + 20) then
			addFinding(Severities.Critical, i, "TIGHT_LOOP", "Infinite loop without yield.")
		end
		if l:match("SetAsync%s*%(") or l:match("UpdateAsync%s*%(") or l:match("GetAsync%s*%(") then
			if not nearHasPcall(lines, i, 8) then
				addFinding(Severities.High, i, "DATASTORE_NO_PCALL", "DataStore call without pcall.")
			end
		end
		if l:match("OnServerEvent%s*:%s*Connect%s*%(") then
			if not nearHasPcall(lines, i, 12) and not l:match("typeof%(") and not l:match("type%(") then
				addFinding(Severities.High, i, "REMOTE_NO_VALIDATION", "OnServerEvent without argument validation.")
			end
		end
		if l:match("%.Touched%s*:%s*Connect%s*%(") then
			if not hasDebounceVar(lines, i, 10) then
				addFinding(Severities.Medium, i, "TOUCHED_NO_DEBOUNCE", ".Touched without debounce.")
			end
		end
		if l:match("Humanoid%s*:%s*LoadAnimation%s*%(") then
			addFinding(Severities.Medium, i, "LOADANIMATION_DEPRECATED", "Use Animator:LoadAnimation() instead.")
		end
		if l:match("Body(Position|Gyro|Velocity)") or l:match("BodyPosition") or l:match("BodyGyro") or l:match("BodyVelocity") then
			addFinding(Severities.Low, i, "BODYMOVER_DEPRECATED", "BodyMovers are deprecated.")
		end
		if l:match("Players%.LocalPlayer") and i <= 20 and not l:match("WaitForChild%(") then
			addFinding(Severities.Low, i, "LOCALPLAYER_AT_START", "Accessing LocalPlayer too early.")
		end
	end

	return findings
end

-- Analyze all scripts
local function analyzeAll()
	local summary = {
		CRITICAL = { count = 0, paths = {} },
		HIGH     = { count = 0, paths = {} },
		MEDIUM   = { count = 0, paths = {} },
		LOW      = { count = 0, paths = {} },
		INFO     = { count = 0, paths = {} },
	}
	local results = {}

	for _, inst in ipairs(game:GetDescendants()) do
		if inst:IsA("Script") or inst:IsA("LocalScript") or inst:IsA("ModuleScript") then
			local src = safeGetSource(inst)
			if src then
				local findings = analyzeSource(src)
				if #findings > 0 then
					local path = getFullNameFast(inst)

					local seenSeverities = {}
					for _, f in ipairs(findings) do
						local sev = f.severity
						if summary[sev] then
							summary[sev].count += 1
							if not seenSeverities[sev] then
								table.insert(summary[sev].paths, path)
								seenSeverities[sev] = true
							end
						end
					end

					table.insert(results, {
						path = path,
						className = inst.ClassName,
						findings = findings,
					})
				end
			end
		end
	end

	return {
		summary = summary,
		results = results,
	}
end

-- Save JSON report (with chunking if >200k chars)
local function saveAuditReport(reportTable)
	local json = HttpService:JSONEncode(reportTable)

	-- Cleanup old reports
	for _, c in ipairs(ServerStorage:GetChildren()) do
		if c.Name:match("^AuditReport") then
			c:Destroy()
		end
	end

	local chunkSize = 180000
	if #json <= chunkSize then
		-- Fits in one ModuleScript
		local mod = Instance.new("ModuleScript")
		mod.Name = "AuditReport"
		mod.Source = "-- Audit Report (JSON)\nreturn " .. string.format("%q", json)
		mod.Parent = ServerStorage
	else
		-- Split into parts
		local parts = {}
		for i = 1, #json, chunkSize do
			table.insert(parts, json:sub(i, i + chunkSize - 1))
		end

		-- Loader
		local loader = Instance.new("ModuleScript")
		loader.Name = "AuditReport"
		loader.Source = [[
			local ServerStorage = game:GetService("ServerStorage")
			local parts = {}
			for _, mod in ipairs(ServerStorage:GetChildren()) do
				if mod.Name:match("^AuditReport_Part") then
					table.insert(parts, require(mod))
				end
			end
			table.sort(parts, function(a,b) return a.index < b.index end)
			local chunks = {}
			for _, p in ipairs(parts) do
				table.insert(chunks, p.data)
			end
			return table.concat(chunks)
		]]
		loader.Parent = ServerStorage

		for i, chunk in ipairs(parts) do
			local mod = Instance.new("ModuleScript")
			mod.Name = ("AuditReport_Part%03d"):format(i)
			mod.Source = string.format("return { index = %d, data = %q }", i, chunk)
			mod.Parent = ServerStorage
		end

		warn(("[Audit] Report saved in %d parts (ServerStorage/AuditReport)."):format(#parts))
	end
end

auditorButton.Click:Connect(function()
	local report = analyzeAll()
	saveAuditReport(report)
end)

----------------------------------------------------------------------
-- [3] VIEWER (Critical + High, grouped per script, clickable links)
----------------------------------------------------------------------

local viewerButton = toolbar:CreateButton(
    "View Audit Report",
    "Open a window to view CRITICAL and HIGH issues",
    "rbxassetid://4458901886"
)

local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Right,
    true, true, 600, 500, 400, 300
)

local widget = plugin:CreateDockWidgetPluginGui("AuditReportViewer", widgetInfo)
widget.Title = "Audit Report Viewer"

local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(1,0,1,0)
scrolling.CanvasSize = UDim2.new(0,0,0,0)
scrolling.ScrollBarThickness = 8
scrolling.BackgroundColor3 = Color3.fromRGB(35,35,35)
scrolling.Parent = widget

local uiList = Instance.new("UIListLayout")
uiList.Parent = scrolling
uiList.Padding = UDim.new(0,8)

local function clearUI()
	for _, c in ipairs(scrolling:GetChildren()) do
		if not c:IsA("UIListLayout") then c:Destroy() end
	end
end

-- Convert "game.StarterGui.Foo.Bar" → Instance
local function getInstanceFromPath(path: string): Instance?
	if not path:match("^game%.") then return nil end
	local parts = string.split(path, ".")
	local current: Instance = game
	for i = 2, #parts do -- skip "game"
		if current then
			current = current:FindFirstChild(parts[i])
		else
			return nil
		end
	end
	return current
end

-- Styled label (optionally clickable)
local function addLabel(parent, text, size, bold, color, height, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, height or 22)
	btn.BackgroundTransparency = 1
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.TextYAlignment = Enum.TextYAlignment.Top
	btn.TextWrapped = true
	btn.Text = text
	btn.Font = bold and Enum.Font.SourceSansBold or Enum.Font.SourceSans
	btn.TextSize = size
	btn.TextColor3 = color
	btn.AutoButtonColor = onClick ~= nil
	btn.Parent = parent

	if onClick then
		btn.MouseButton1Click:Connect(onClick)
	end

	return btn
end

-- Card per script
local function addScriptCard(scriptPath, findings)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -10, 0, 0)
	frame.BackgroundColor3 = Color3.fromRGB(45,45,45)
	frame.BorderSizePixel = 0
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.Parent = scrolling

	local uiListInner = Instance.new("UIListLayout")
	uiListInner.Parent = frame
	uiListInner.Padding = UDim.new(0,4)

	-- Title
	addLabel(frame, scriptPath, 16, true, Color3.fromRGB(200,200,255), 26)

	-- Findings
	for _, f in ipairs(findings) do
		local color = (f.severity == "CRITICAL") and Color3.fromRGB(255,70,70) or Color3.fromRGB(255,170,60)
		addLabel(
			frame,
			string.format("   [%s] Line %d: %s", f.severity, f.line, f.message),
			14, false, color, 20,
			function()
				local inst = getInstanceFromPath(scriptPath)
				if inst then
					game.Selection:Set({inst})
					if plugin.OpenScript then
						pcall(function() plugin:OpenScript(inst, f.line) end)
					end
				else
					warn("Script not found: " .. scriptPath)
				end
			end
		)
	end
end

local function loadReport()
	clearUI()

	local mod = ServerStorage:FindFirstChild("AuditReport")
	if not mod or not mod:IsA("ModuleScript") then
		addLabel(scrolling, "No AuditReport found. Run 'Check code' first.", 16, true, Color3.fromRGB(200,80,80), 28)
		return
	end

	local success, report = pcall(require, mod)
	if not success then
		addLabel(scrolling, "Failed to load AuditReport.", 16, true, Color3.fromRGB(200,80,80), 28)
		return
	end

	local data
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(report)
	end)
	if ok then data = decoded else addLabel(scrolling, "Invalid JSON in AuditReport", 16, true, Color3.fromRGB(200,80,80), 28) return end

	-- Group by script
	for _, scriptInfo in ipairs(data.results) do
		local relevant = {}
		for _, f in ipairs(scriptInfo.findings) do
			if f.severity == "CRITICAL" or f.severity == "HIGH" then
				table.insert(relevant, f)
			end
		end

		if #relevant > 0 then
			table.sort(relevant, function(a,b)
				if a.severity == b.severity then
					return a.line < b.line
				end
				return (a.severity == "CRITICAL")
			end)
			addScriptCard(scriptInfo.path, relevant)
		end
	end

	scrolling.CanvasSize = UDim2.new(0,0,0,uiList.AbsoluteContentSize.Y+20)
end

viewerButton.Click:Connect(function()
	widget.Enabled = true
	loadReport()
end)


----------------------------------------------------------------------
-- End of Plugin
----------------------------------------------------------------------
