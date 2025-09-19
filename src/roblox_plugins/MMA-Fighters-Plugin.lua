--!strict
-- Roblox Studio Plugin: Utils
-- Toolbar "Utils" with:
-- 1) Build Export Folder
-- 2) Check code (audit + save JSON split if needed)
-- 3) View Audit Report (CRITICAL + HIGH only, clickable)

local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local toolbar = plugin:CreateToolbar("Utils")

-- Keep last audit results in memory (with Instances)
local lastAuditReport = nil
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
-- [2] SCRIPT AUDITOR (part 1)
----------------------------------------------------------------------

local auditorButton = toolbar:CreateButton(
    "Check code",
    "Audit all scripts and save report in ServerStorage/AuditReport",
    "rbxassetid://4458901886"
)

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
		local code = lines[i]:gsub("%-%-.*", ""):gsub("%s+$", "")
		if code:match("%f[%w_]wait%f[^%w_]") or code:match("task%.wait%s*%(") or code:match("RunService%.Heartbeat:Connect") then
			return true
		end
	end
	return false
end

local function nearHasPcall(lines, idx, radius)
	local fromI = math.max(1, idx - radius)
	local toI = math.min(#lines, idx + radius)
	for i = fromI, toI do
		local code = lines[i]:gsub("%-%-.*", ""):gsub("%s+$", "")
		if code:match("%f[%w_]pcall%f[^%w_]") then
			return true
		end
	end
	return false
end

local function hasDebounceVar(lines, idx, radius)
	local fromI = math.max(1, idx - radius)
	local toI = math.min(#lines, idx + radius)
	for i = fromI, toI do
		local code = lines[i]:gsub("%-%-.*", ""):gsub("%s+$", "")
		if code:match("[Dd]ebounce") or code:match("isProcessing") or code:match("cooldown") then
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

local function getFullNameFast(inst)
	local ok, name = pcall(function() return inst:GetFullName() end)
	if ok then
		return "game." .. name:gsub("^game%.", "") -- clean prefix
	end
	local names = {}
	local cur = inst
	while cur do
		table.insert(names, 1, cur.Name)
		cur = cur.Parent
	end
	return "game." .. table.concat(names, ".")
end




-- Analyse un script (ignore commentaires)
local function analyzeSource(src)
	local findings = {}
	if not src or src == "" then return findings end

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
		local code = l:gsub("%-%-.*", ""):gsub("%s+$", "")
		if code == "" then continue end

		if code:match("%f[%w_]wait%f[^%w_]") and not code:match("task%.wait") then
			addFinding(Severities.Medium, i, "WAIT_DEPRECATED", "Use task.wait() instead of wait().")
		end
		if code:match("%f[%w_]spawn%f[^%w_]") then
			addFinding(Severities.Medium, i, "SPAWN_DEPRECATED", "spawn() is deprecated. Use task.spawn().")
		end
		if code:match("%f[%w_]delay%f[^%w_]") then
			addFinding(Severities.Medium, i, "DELAY_DEPRECATED", "delay() is deprecated. Use task.delay().")
		end
		if code:match(":connect%(") then
			addFinding(Severities.Low, i, "CONNECT_LOWERCASE", "Use :Connect() instead of :connect().")
		end
		if code:match("while%s+true%s+do") and not hasWaitInBlock(lines, i, i + 20) then
			addFinding(Severities.Critical, i, "TIGHT_LOOP", "Infinite loop without yield.")
		end
		if code:match("SetAsync%s*%(") or code:match("UpdateAsync%s*%(") or code:match("GetAsync%s*%(") then
			if not nearHasPcall(lines, i, 8) then
				addFinding(Severities.High, i, "DATASTORE_NO_PCALL", "DataStore call without pcall.")
			end
		end
		if code:match("OnServerEvent%s*:%s*Connect%s*%(") then
			if not nearHasPcall(lines, i, 12) and not code:match("typeof%(") and not code:match("type%(") then
				addFinding(Severities.High, i, "REMOTE_NO_VALIDATION", "OnServerEvent without argument validation.")
			end
		end
		if code:match("%.Touched%s*:%s*Connect%s*%(") then
			if not hasDebounceVar(lines, i, 10) then
				addFinding(Severities.Medium, i, "TOUCHED_NO_DEBOUNCE", ".Touched without debounce.")
			end
		end
		if code:match("Humanoid%s*:%s*LoadAnimation%s*%(") then
			addFinding(Severities.Medium, i, "LOADANIMATION_DEPRECATED", "Use Animator:LoadAnimation() instead.")
		end
		if code:match("Body(Position|Gyro|Velocity)") or code:match("BodyPosition") or code:match("BodyGyro") or code:match("BodyVelocity") then
			addFinding(Severities.Low, i, "BODYMOVER_DEPRECATED", "BodyMovers are deprecated.")
		end
		if code:match("Players%.LocalPlayer") and i <= 20 and not code:match("WaitForChild%(") then
			addFinding(Severities.Low, i, "LOCALPLAYER_AT_START", "Accessing LocalPlayer too early.")
		end
	end

	return findings
end

local function analyzeAll()
	local summary = {
		CRITICAL = { count = 0, paths = {} },
		HIGH     = { count = 0, paths = {} },
		MEDIUM   = { count = 0, paths = {} },
		LOW      = { count = 0, paths = {} },
		INFO     = { count = 0, paths = {} },
	}
	local results = {}

	local exportFolder = ServerStorage:FindFirstChild("_ScriptExport")

	for _, inst in ipairs(game:GetDescendants()) do
		if exportFolder and inst:IsDescendantOf(exportFolder) then
			continue
		end

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
						inst = inst, -- keep direct reference
						className = inst.ClassName,
						findings = findings
					})
				end
			end
		end
	end

	return { summary = summary, results = results }
end

auditorButton.Click:Connect(function()
    local t0 = os.clock()
    local report = analyzeAll()
	lastAuditReport = report  -- keep it for the viewer
    local dt = os.clock() - t0

    local exportFolder = ServerStorage:FindFirstChild("_ScriptExport")

	-- Count all scripts parsed (excluding _ScriptExport)
	local totalScripts = 0
	for _, inst in ipairs(game:GetDescendants()) do
		if inst:IsA("Script") or inst:IsA("LocalScript") or inst:IsA("ModuleScript") then
			if not (exportFolder and inst:IsDescendantOf(exportFolder)) then
				totalScripts += 1
			end
		end
	end

    local s = report.summary
    warn(("[Audit] %d scripts parsed. Findings: CRIT=%d, HIGH=%d, MED=%d, LOW=%d, INFO=%d (%.2fs)")
        :format(totalScripts, s.CRITICAL.count, s.HIGH.count, s.MEDIUM.count, s.LOW.count, s.INFO.count, dt))

    -- TODO: saveAuditReport implementation with JSON split if >200k length
end)

-- TODO: saveAuditReport implementation with JSON split if >200k length


----------------------------------------------------------------------
-- [3] VIEWER
----------------------------------------------------------------------

local viewerButton = toolbar:CreateButton(
    "View Audit Report",
    "Open a window to view CRITICAL and HIGH issues",
    "rbxassetid://4458901886"
)

local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Right,
    true, true, 400, 500, 200, 200
)
local widget = plugin:CreateDockWidgetPluginGui("AuditReportViewer", widgetInfo)
widget.Title = "Audit Report Viewer"

local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(1,0,1,0)
scrolling.CanvasSize = UDim2.new(0,0,0,0)
scrolling.ScrollBarThickness = 6
scrolling.BackgroundTransparency = 1
scrolling.Parent = widget

local uiList = Instance.new("UIListLayout")
uiList.Parent = scrolling
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0,6)

local function addLabel(parent, text, textSize, bold, color, height)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, height or 24)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.TextSize = textSize or 14
    lbl.TextColor3 = color or Color3.fromRGB(230,230,230)
    lbl.Font = bold and Enum.Font.SourceSansBold or Enum.Font.SourceSans
    lbl.Parent = parent
    return lbl
end

local function clearUI()
    for _, c in ipairs(scrolling:GetChildren()) do
        if c:IsA("TextLabel") or c:IsA("Frame") then
            c:Destroy()
        end
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


local function addScriptCard(scriptInfo, findings)
	local path = scriptInfo.path
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30 + (#findings*20))
    frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    frame.BorderSizePixel = 0
    frame.Parent = scrolling

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = frame

    addLabel(frame, path, 14, true, Color3.fromRGB(200,200,255), 24)

    for i, f in ipairs(findings) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 20)
        btn.Position = UDim2.new(0, 10, 0, 20 + (i-1)*20)
        btn.BackgroundTransparency = 1
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = ("[%s] line %d: %s"):format(f.severity, f.line, f.message)
        btn.TextSize = 13
        btn.TextColor3 = f.severity == "CRITICAL" and Color3.fromRGB(255,70,70) or Color3.fromRGB(255,170,60)
        btn.Parent = frame

        btn.MouseButton1Click:Connect(function()
			local inst = scriptInfo.inst
			if inst then
				game.Selection:Set({inst})
				if plugin.OpenScript then
					pcall(function() plugin:OpenScript(inst, f.line) end)
				end
			else
				warn("Script not found: " .. path)
			end
		end)
    end
end

local function loadReport()
    clearUI()

    if not lastAuditReport then
        addLabel(scrolling, "No AuditReport in memory. Run 'Check code' first.", 16, true, Color3.fromRGB(200,80,80), 28)
        return
    end

    local data = lastAuditReport
    local s = data.summary

    local critCount = s.CRITICAL.count
    local highCount = s.HIGH.count
    local medCount = s.MEDIUM.count
    local lowCount = s.LOW.count

    local total = critCount + highCount + medCount + lowCount
    local critPct = total > 0 and math.floor((critCount / total) * 100) or 0
    local highPct = total > 0 and math.floor((highCount / total) * 100) or 0
    local medPct = total > 0 and math.floor((medCount / total) * 100) or 0
    local lowPct = total > 0 and math.floor((lowCount / total) * 100) or 0

    addLabel(scrolling, "=== Audit Summary ===", 18, true, Color3.fromRGB(230,230,80), 28)
    addLabel(scrolling, ("Critical: %d (%d%%)"):format(critCount, critPct), 16, false, Color3.fromRGB(255,70,70), 24)
    addLabel(scrolling, ("High: %d (%d%%)"):format(highCount, highPct), 16, false, Color3.fromRGB(255,170,60), 24)
    addLabel(scrolling, ("Medium: %d (%d%%)"):format(medCount, medPct), 16, false, Color3.fromRGB(255,255,100), 24)
    addLabel(scrolling, ("Low: %d (%d%%)"):format(lowCount, lowPct), 16, false, Color3.fromRGB(180,180,180), 24)

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
            addScriptCard(scriptInfo, relevant) -- scriptInfo contient inst
        end
    end

    scrolling.CanvasSize = UDim2.new(0,0,0,uiList.AbsoluteContentSize.Y+20)
end

viewerButton.Click:Connect(function()
    widget.Enabled = true
    loadReport()
end)
