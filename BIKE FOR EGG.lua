--[[
  BIKE FOR EGG — Mystrix Hub Logic + NexoraHub GUI
  GUI Framework: NexoraHub (GUI.lua)
  Logic Engine: Mystrix Hub BFE
  WindUI ถูกแทนที่ทั้งหมดด้วย NexoraHub
]]

-- ============================================================
-- SECTION 1: โหลด NexoraHub GUI (วางลิงก์จริงของคุณแทน)
-- ============================================================
local GUI_URL = "YOUR_NEXORAHUB_GUI_RAW_URL_HERE"
-- ถ้าไฟล์อยู่ local ให้ใช้: loadstring(readfile("NexoraHub.lua"))()
loadstring(game:HttpGet(GUI_URL))()

-- รอให้ NX พร้อม
local NX = getgenv().NX
while not NX do task.wait(0.1) NX = getgenv().NX end
local COL = NX.COL
local make = NX.make
local round = NX.round
local glow = NX.glow
local TS = game:GetService("TweenService")
local TI = TweenInfo.new(0.3, Enum.EasingStyle.Quint)

-- ============================================================
-- SECTION 2: Notify helper (แทน WindUI:Notify)
-- ============================================================
local notifQueue = {}
local notifActive = false

local function Notify(opts)
    -- opts: { Title, Content, Duration, Icon }
    table.insert(notifQueue, opts)
    if notifActive then return end
    notifActive = true
    task.spawn(function()
        while #notifQueue > 0 do
            local o = table.remove(notifQueue, 1)
            local sg = NX.gui
            if not sg or not sg.Parent then break end

            local iconMap = {
                ["circle-check"] = "✅", ["circle-alert"] = "⚠️",
                ["circle-x"] = "❌", ["triangle-alert"] = "⚠️",
                ["clipboard-check"] = "📋", ["clipboard"] = "📋",
                ["shield-alert"] = "🛡️", ["download"] = "⬇️",
                ["link"] = "🔗",
            }
            local ico = iconMap[o.Icon or ""] or "ℹ️"

            local notifFrame = make("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -10, 0, 10),
                Size = UDim2.fromOffset(0, 56),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = COL.Side,
                ClipsDescendants = true,
                ZIndex = 999,
            }, sg)
            round(notifFrame, 14)
            glow(notifFrame, 1)

            local pad = make("UIPadding", {
                PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
            }, notifFrame)

            make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = ico .. "  " .. (o.Title or ""),
                Font = Enum.Font.GothamBlack,
                TextSize = 13,
                TextColor3 = Color3.new(1, 1, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
            }, notifFrame)

            make("TextLabel", {
                Position = UDim2.fromOffset(0, 20),
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = o.Content or "",
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextColor3 = COL.Sub,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
            }, notifFrame)

            local sc = make("UIScale", {Scale = 0}, notifFrame)
            TS:Create(sc, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Scale = 1}):Play()
            task.wait((o.Duration or 3) + 0.4)
            TS:Create(sc, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Scale = 0}):Play()
            task.delay(0.35, function() pcall(function() notifFrame:Destroy() end) end)
            task.wait(0.4)
        end
        notifActive = false
    end)
end

-- ============================================================
-- SECTION 3: Core logic จาก Mystrix Hub (ไม่มี WindUI)
-- ============================================================

if getgenv().MystrixHub then
    if MystrixHub.ConnectionController and MystrixHub.ConnectionController.Connections then
        for k, v1 in next, MystrixHub.ConnectionController.Connections, nil do
            pcall(function() v1:Disconnect() end)
            MystrixHub.ConnectionController.Connections[k] = nil
        end
    end
    if MystrixHub.TasksController and MystrixHub.TasksController.Tasks then
        for k1, v2 in next, MystrixHub.TasksController.Tasks, nil do
            pcall(function() task.cancel(v2) end)
            MystrixHub.TasksController.Tasks[k1] = nil
        end
    end
    getgenv().MystrixHub = nil
    task.wait(0.2)
end

local v3 = setmetatable({}, {
    __index = function(_, arg2) return cloneref(game:GetService(arg2)) end,
})
local Players = v3.Players
local RunService = v3.RunService
local HttpService = v3.HttpService
local MarketplaceService = v3.MarketplaceService
local CoreGui = v3.CoreGui
local LocalPlayer = Players.LocalPlayer
local v4 = syn and syn.request or http_request or request

makefolder("WindUI")
makefolder("WindUI/BikeForEggs")

local v5 = getgenv()
local tbl = {
    Version = "v1.0", Discord = "46JkThWjPB", Logo = "rbxassetid://85997568026025",
    FolderName = "BikeForEggs", FolderPath = "WindUI/BikeForEggs",
    ExecDataFile = "WindUI/NebulAuth_ExecData.json", GameName = "Unknown Game",
    ServerName = "Mystrix Hub", MemberCount = "Fetching...", OnlineCount = "Fetching...",
}
local tbl1 = {
    BaseURL = "https://api.nebulauth.com",
    ApiToken = "mk_at_mqRNTHJ9GG0Xc7A1pWPb_OoCpshPMW-OSymq1encWnk",
    SigningSecret = "mk_sig_0GCXObajBi8W5Sv4PjJkvrieyXBOAiwehA-iD94OMHA",
    UseKeySystem = false,
}
tbl1.KeyResult = nil
tbl1.KeyError = nil
local tbl2 = {}
tbl2.CachedOffset = nil
tbl2.LastSync = 0
local tbl3 = {Player = LocalPlayer, PlayerGui = LocalPlayer.PlayerGui}
tbl3.HWID = nil
local tbl4 = {}
tbl4.Tabs = {}
tbl4.Drops = {}
local tbl5 = {Cache = {}}
tbl5.SelectedConfig = nil
tbl5.NameInput = "MystrixHub"
tbl5.LastConfigFile = "WindUI/BikeForEggs/LastConfig.txt"
tbl5.AutoLoadFile = "WindUI/BikeForEggs/AutoLoad.txt"
tbl5.ImportData = ""
local tbl6 = {
    StatusText = "Verified", KeyIdText = "N/A", KeyLabelText = "N/A", ExpiryText = "N/A",
    TimeLeftText = "Unlimited", HwidDisplay = "N/A", ResetText = "No", ExecCountStr = "INF",
}
local tbl7 = {Enabled = false, Running = false}
tbl7.Loop = nil
tbl7.SpecificEggNames = {}
tbl7.SelectedRarities = {}
tbl7.SelectedAreas = {}
tbl7.AreasNameById = {}
tbl7.EggLookup = {}
tbl7.FailCounts = {}
tbl7.LastTargetUid = nil
local tbl8 = {SelectedEggCategories = {}, SelectedPetCategories = {}, AutoEggsRunning = false}
tbl8.AutoEggsLoop = nil
tbl8.AutoPetsRunning = false
tbl8.AutoPetsLoop = nil
tbl8.Deps = {}
local tbl9 = {AutoTrailRunning = false}
tbl9.AutoTrailLoop = nil
tbl9.AutoBikeRunning = false
tbl9.AutoBikeLoop = nil
tbl9.AutoTreadmillRunning = false
tbl9.AutoTreadmillLoop = nil
tbl9.AutoPlotRunning = false
tbl9.AutoPlotLoop = nil
local tbl10 = {HatchSelectedEggs = {"All"}, PlaceSelectedEggs = {"Best"}, AutoHatchRunning = false}
tbl10.AutoHatchLoop = nil
tbl10.AutoPlaceRunning = false
tbl10.AutoPlaceLoop = nil
tbl10.AutoTreadmillRunning = false
tbl10.AutoTreadmillLoop = nil
tbl10.AutoClaimRunning = false
tbl10.AutoClaimLoop = nil
tbl10.AutoPlaceBestPetsRunning = false
tbl10.AutoPlaceBestPetsLoop = nil

v5.MystrixHub = {
    Meta = tbl, Auth = tbl1, TimeController = tbl2, PlayerController = tbl3,
    UIController = tbl4, ConfigController = tbl5, KeyDisplay = tbl6,
    FarmController = tbl7, SellController = tbl8, ShopController = tbl9,
    PlotController = tbl10, ConnectionController = {Connections = {}},
    TasksController = {Tasks = {}}, Functions = {},
}

local v6 = MystrixHub
v6.ConnectionController.Insert = function(arg1)
    table.insert(MystrixHub.ConnectionController.Connections, arg1)
end
v6.TasksController.Insert = function(arg1)
    table.insert(MystrixHub.TasksController.Tasks, arg1)
end

-- ===== ฟังก์ชัน Utility (Crypto, Time, Network) =====
v6.Functions.HexToBytes = function(arg1)
    return (arg1:gsub("..", function(a) return string.char(tonumber(a, 16)) end))
end
v6.Functions.BytesToHex = function(arg1)
    return (arg1:gsub(".", function(a) return string.format("%02x", string.byte(a)) end))
end
v6.Functions.IsHex = function(arg1, arg2)
    if not arg1 then return false end
    if arg2 and #arg1 ~= arg2 then return false end
    return arg1:match("^[0-9a-fA-F]+$") ~= nil
end
v6.Functions.NormaliseSHA256 = function(arg1)
    if not arg1 or arg1 == "" then return nil end
    if #arg1 == 64 and MystrixHub.Functions.IsHex(arg1, 64) then
        return MystrixHub.Functions.HexToBytes(arg1)
    end
    if #arg1 == 32 then return arg1 end
    if MystrixHub.Functions.IsHex(arg1) then return MystrixHub.Functions.HexToBytes(arg1) end
    return arg1
end
v6.Functions.SHA256Bytes = function(arg1)
    local v1, v2 = pcall(function() return crypt and crypt.hash and crypt.hash(arg1, "sha256") end)
    if v1 and v2 and v2 ~= "" then
        local v3 = MystrixHub.Functions.NormaliseSHA256(v2)
        if v3 then return v3 end
    end
    local v4, v5 = pcall(function() return HttpService:SHA256(arg1) end)
    if v4 and v5 and v5 ~= "" then
        local v6 = MystrixHub.Functions.NormaliseSHA256(v5)
        if v6 then return v6 end
    end
    return nil
end
v6.Functions.SHA256 = function(arg1)
    local v1 = MystrixHub.Functions.SHA256Bytes(arg1)
    if not v1 then return "" end
    return MystrixHub.Functions.BytesToHex(v1)
end
v6.Functions.HMACSHA256 = function(arg1, arg2)
    local v1 = #arg1 > 64 and MystrixHub.Functions.SHA256Bytes(arg1) or arg1
    if not v1 then return "" end
    while #v1 < 64 do v1 = v1 .. "\0" end
    local t1, t2 = {}, {}
    for i = 1, 64 do
        local v2 = string.byte(v1, i)
        t1[i] = string.char(bit32.bxor(v2, 54))
        t2[i] = string.char(bit32.bxor(v2, 92))
    end
    local v3 = MystrixHub.Functions.SHA256Bytes(table.concat(t1) .. arg2)
    if not v3 then return "" end
    return MystrixHub.Functions.SHA256(table.concat(t2) .. v3)
end
v6.Functions.CleanKey = function(arg1)
    if not arg1 then return "" end
    return (tostring(arg1):match("^%s*(.-)%s*$"):gsub("[%z\1-\8\11\12\14-\31\127]", ""):gsub("​", ""):gsub(" ", ""):gsub("\239\187\191", ""):gsub("[^%w%-_]", ""))
end
v6.Functions.MakeRawRequest = function(arg1, arg2, arg3, arg4)
    local t = {Url = arg1, Method = arg2 or "GET"}
    if arg3 then t.Headers = arg3 end
    if arg4 then t.Body = arg4 end
    if v4 then
        local v1, v2 = pcall(v4, t)
        if v1 and v2 then return v2 end
    end
    if syn and syn.request then
        local v3, v5 = pcall(syn.request, t)
        if v3 and v5 then return v5 end
    end
    if http and http.request then
        local v6, v7 = pcall(http.request, t)
        if v6 and v7 then return v7 end
    end
    return nil
end
v6.Functions.TryParseUnixMs = function(arg1)
    if not (arg1 and arg1.Body) then return nil end
    local v1, v2 = pcall(function() return HttpService:JSONDecode(arg1.Body) end)
    if not v1 or not v2 then return nil end
    if v2.unixtime then return math.floor(v2.unixtime * 1000) end
    if v2.now then return math.floor(v2.now * 1000) end
    if v2.dateTime then
        local v3, v4 = pcall(function() return DateTime.fromIsoDate(v2.dateTime) end)
        if v3 and v4 then return v4.UnixTimestampMillis end
    end
    if v2.utc_datetime then
        local v5, v6 = pcall(function() return DateTime.fromIsoDate(v2.utc_datetime) end)
        if v5 and v6 then return v6.UnixTimestampMillis end
    end
    return nil
end
v6.Functions.SyncServerTime = function()
    local TC = MystrixHub.TimeController
    if TC.CachedOffset ~= nil and os.time() - TC.LastSync < 60 then return true end
    for _, url in ipairs({"https://worldtimeapi.org/api/timezone/Etc/UTC", "https://timeapi.io/api/Time/current/zone?timeZone=UTC"}) do
        local v2, v3 = pcall(MystrixHub.Functions.MakeRawRequest, url, "GET", {Accept = "application/json"}, nil)
        if v2 and v3 then
            local v4 = MystrixHub.Functions.TryParseUnixMs(v3)
            if v4 then
                TC.CachedOffset = v4 - DateTime.now().UnixTimestampMillis
                TC.LastSync = os.time()
                return true
            end
        end
    end
    TC.CachedOffset = 0
    TC.LastSync = os.time()
    return false
end
v6.Functions.GetAccurateTimestampMs = function(arg1)
    local TC = MystrixHub.TimeController
    if TC.CachedOffset == nil then MystrixHub.Functions.SyncServerTime() end
    return tostring(DateTime.now().UnixTimestampMillis + (TC.CachedOffset or 0) + (arg1 or 0))
end
v6.Functions.GetHWID = function()
    local str
    for _, fn in ipairs({
        function() return gethwid and gethwid() end,
        function() return game:GetService("RbxAnalyticsService"):GetClientId() end,
        function() return game:GetService("UserIdService"):GetUserId() end,
    }) do
        local v2, v3 = pcall(fn)
        if v2 and v3 and v3 ~= "" then str = tostring(v3) break end
    end
    if not str or str == "" then
        str = MystrixHub.Functions.SHA256("USER_" .. (LocalPlayer and LocalPlayer.UserId or 0) .. "_" .. game.PlaceId):sub(1, 32)
    end
    return str
end

-- ===== ฟังก์ชัน Farm =====
v6.Functions.Farm_GetAssets = function()
    local Directory = game:GetService("ReplicatedStorage"):FindFirstChild("Directory")
    local v1 = Directory and Directory:FindFirstChild("Assets")
    if not v1 or not v1:IsA("ModuleScript") then return nil end
    local v2, v3 = pcall(require, v1)
    if v2 and type(v3) == "table" and type(v3.Directory) == "table" then return v3 end
    return nil
end
v6.Functions.Farm_GetEggCmds = function()
    local Library = game:GetService("ReplicatedStorage"):FindFirstChild("Library")
    local v1 = Library and Library:FindFirstChild("Client")
    local v2 = v1 and v1:FindFirstChild("EggCmds")
    if not v2 or not v2:IsA("ModuleScript") then return nil end
    local v3, v4 = pcall(require, v2)
    if v3 and type(v4) == "table" then return v4 end
    return nil
end
v6.Functions.Farm_GetPlotCmds = function()
    local Library = game:GetService("ReplicatedStorage"):FindFirstChild("Library")
    local v1 = Library and Library:FindFirstChild("Client")
    local v2 = v1 and v1:FindFirstChild("PlotCmds")
    if not v2 or not v2:IsA("ModuleScript") then return nil end
    local v3, v4 = pcall(require, v2)
    if v3 and type(v4) == "table" then return v4 end
    return nil
end
v6.Functions.Farm_Teleport = function(arg1)
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    pcall(function()
        HRP.CFrame = CFrame.new(arg1)
        HRP.AssemblyLinearVelocity = Vector3.zero
        HRP.AssemblyAngularVelocity = Vector3.zero
    end)
end
v6.Functions.Farm_IsCarrying = function()
    local v1 = MystrixHub.Functions.Farm_GetEggCmds()
    if not v1 then return false end
    local v2, v3 = pcall(function() return v1.GetAreaEggSnapshot() end)
    if not v2 or type(v3) ~= "table" then return false end
    for _, v4 in ipairs(v3.Records) do
        if v4.CarrierUserId == LocalPlayer.UserId then return true end
    end
    return false
end
v6.Functions.Farm_FindEggModel = function(arg1)
    for _, v1 in ipairs(workspace:GetDescendants()) do
        if v1:IsA("Model") then
            local v2 = v1:GetAttribute("EggUid") or v1:GetAttribute("Uid")
            if tostring(v2) == tostring(arg1) then return v1 end
        end
    end
    return nil
end
v6.Functions.Farm_GetRarityName = function(arg1, arg2)
    if not arg2 or not arg2.Directory or not arg2.Directory[arg1] then return "Unknown", 0 end
    local Rarity = arg2.Directory[arg1].Rarity
    if type(Rarity) == "table" then
        return Rarity.DisplayName or Rarity._id or Rarity.Name or "Unknown", tonumber(Rarity.RarityNumber) or 0
    end
    return "Unknown", 0
end
v6.Functions.Farm_GetEggsList = function()
    local v1 = MystrixHub.Functions.Farm_GetAssets()
    if not v1 then return {} end
    local tbl = {}
    for k, v2 in pairs(v1.Directory) do
        if type(k) == "string" and type(v2) == "table" and v2.Egg ~= nil and type(v2.Rarity) == "table" then
            local num = tonumber(v2.Rarity.RarityNumber) or 0
            local str = v2.Rarity.DisplayName or v2.Rarity._id or v2.Rarity.Name or "Unknown"
            table.insert(tbl, {name = k, rarity = str, rarityNum = num})
        end
    end
    table.sort(tbl, function(a, b)
        if a.rarityNum ~= b.rarityNum then return a.rarityNum > b.rarityNum end
        return a.name < b.name
    end)
    local result = {}
    for _, v3 in ipairs(tbl) do
        table.insert(result, "[" .. v3.rarity .. "] " .. v3.name)
    end
    return result
end
v6.Functions.Farm_GetRaritiesList = function()
    local v1 = MystrixHub.Functions.Farm_GetAssets()
    if not v1 then return {} end
    local seen, result = {}, {}
    for _, v2 in pairs(v1.Directory) do
        if type(v2) == "table" and type(v2.Rarity) == "table" then
            local name = v2.Rarity.DisplayName or v2.Rarity._id or v2.Rarity.Name
            if name and not seen[name] then
                seen[name] = true
                table.insert(result, name)
            end
        end
    end
    table.sort(result)
    return result
end
v6.Functions.Farm_GetAreasList = function()
    local v1 = MystrixHub.Functions.Farm_GetEggCmds()
    if not v1 then return {} end
    local v2, v3 = pcall(function() return v1.GetAreaEggSnapshot() end)
    if not v2 or type(v3) ~= "table" then return {} end
    local seen, result = {}, {}
    for _, v4 in ipairs(v3.Records) do
        local AreaId = v4.AreaId
        if AreaId and not seen[AreaId] then
            seen[AreaId] = true
            local name = MystrixHub.FarmController.AreasNameById[AreaId] or AreaId
            table.insert(result, name)
            MystrixHub.FarmController.AreasNameById[AreaId] = name
        end
    end
    table.sort(result)
    return result
end
v6.Functions.Farm_FindBestTarget = function()
    local FarmController = MystrixHub.FarmController
    local v1 = MystrixHub.Functions.Farm_GetEggCmds()
    if not v1 then return nil end
    local v2, v3 = pcall(function() return v1.GetAreaEggSnapshot() end)
    if not v2 or type(v3) ~= "table" then return nil end
    local Assets = MystrixHub.Functions.Farm_GetAssets()
    local tbl = {}
    for _, v5 in ipairs(v3.Records) do
        if v5.CarrierUserId == nil then
            if v5.State == "Slot" or v5.State == "Dropped" then
                local _, v6 = MystrixHub.Functions.Farm_GetRarityName(v5.AssetCategory, Assets)
                table.insert(tbl, {Record = v5, RarityNum = v6, Uid = v5.Uid})
            end
        end
    end
    if #tbl == 0 then return nil end
    local filtered = {}
    for _, v8 in ipairs(tbl) do
        if (FarmController.FailCounts[v8.Uid] or 0) < 2 then
            table.insert(filtered, v8)
        end
    end
    if #filtered == 0 then
        FarmController.FailCounts = {}
        filtered = tbl
    end
    local function best(arr)
        if #arr == 0 then return nil end
        local v1 = arr[1]
        for i = 2, #arr do
            local v2 = arr[i]
            if v2.RarityNum > v1.RarityNum then
                v1 = v2
            elseif v2.RarityNum == v1.RarityNum and tostring(v2.Uid) < tostring(v1.Uid) then
                v1 = v2
            end
        end
        return v1
    end
    if #FarmController.SpecificEggNames > 0 then
        local names = {}
        for _, n in ipairs(FarmController.SpecificEggNames) do names[n] = true end
        local sub = {}
        for _, v10 in ipairs(filtered) do
            if names[v10.Record.AssetCategory] then table.insert(sub, v10) end
        end
        if #sub > 0 then return best(sub) end
    end
    if #FarmController.SelectedRarities > 0 then
        local rar = {}
        for _, r in ipairs(FarmController.SelectedRarities) do rar[r] = true end
        local sub = {}
        for _, v12 in ipairs(filtered) do
            if rar[MystrixHub.Functions.Farm_GetRarityName(v12.Record.AssetCategory, Assets)] then
                table.insert(sub, v12)
            end
        end
        if #sub > 0 then return best(sub) end
    end
    if #FarmController.SelectedAreas > 0 then
        local areas = {}
        for _, a in ipairs(FarmController.SelectedAreas) do areas[a] = true end
        local sub = {}
        for _, v14 in ipairs(filtered) do
            local AreaId = v14.Record.AreaId
            local aname = FarmController.AreasNameById[AreaId] or AreaId
            if aname and areas[aname] then table.insert(sub, v14) end
        end
        if #sub > 0 then return best(sub) end
    end
    return nil
end
v6.Functions.Farm_StealEgg = function(arg1)
    if not arg1 or not arg1.Uid then return false end
    local FC = MystrixHub.FarmController
    FC.FailCounts = FC.FailCounts or {}
    local v1 = MystrixHub.Functions.Farm_GetEggCmds()
    if not v1 then return false end
    local v2, v3 = pcall(function() return v1.GetAreaEggSnapshot() end)
    if not v2 or type(v3) ~= "table" then return false end
    local pos, canSteal = nil, false
    for _, v4 in ipairs(v3.Records) do
        if v4.Uid == arg1.Uid then
            if v4.CarrierUserId == nil and (v4.State == "Slot" or v4.State == "Dropped") then
                canSteal = true
                if v4.BottomCFrame then
                    local ok, p = pcall(function() return v4.BottomCFrame.Position end)
                    if ok and p then pos = p end
                end
            end
            break
        end
    end
    if not canSteal then FC.FailCounts[arg1.Uid] = 999 return false end
    if not pos then
        local model = MystrixHub.Functions.Farm_FindEggModel(arg1.Uid)
        if model then
            local ok, p = pcall(function() return model:GetPivot().Position end)
            if ok and p then pos = p end
        end
    end
    if not pos then return false end
    FC.LastTargetUid = arg1.Uid
    MystrixHub.Functions.Farm_Teleport(pos + Vector3.new(0, 2, 0))
    pcall(function() v1.RequestCarryAreaEgg(arg1.Uid) end)
    local model2 = MystrixHub.Functions.Farm_FindEggModel(arg1.Uid)
    if model2 and fireproximityprompt then
        local pp = model2:FindFirstChild("CarryAreaEgg", true)
        if pp and pp:IsA("ProximityPrompt") then pcall(fireproximityprompt, pp) end
    end
    local deadline = tick() + 1
    while tick() < deadline do
        if MystrixHub.Functions.Farm_IsCarrying() then
            FC.FailCounts[arg1.Uid] = nil
            return true
        end
        task.wait(0.03)
    end
    MystrixHub.Functions.Farm_Teleport(pos + Vector3.new(0, 2, 0))
    pcall(function() v1.RequestCarryAreaEgg(arg1.Uid) end)
    if model2 and fireproximityprompt then
        local pp2 = model2:FindFirstChild("CarryAreaEgg", true)
        if pp2 and pp2:IsA("ProximityPrompt") then pcall(fireproximityprompt, pp2) end
    end
    local deadline2 = tick() + 0.5
    while tick() < deadline2 do
        if MystrixHub.Functions.Farm_IsCarrying() then
            FC.FailCounts[arg1.Uid] = nil
            return true
        end
        task.wait(0.03)
    end
    if not MystrixHub.Functions.Farm_IsCarrying() then
        FC.FailCounts[arg1.Uid] = (FC.FailCounts[arg1.Uid] or 0) + 1
    end
    return MystrixHub.Functions.Farm_IsCarrying()
end
v6.Functions.Farm_ReturnToBase = function()
    local v1 = MystrixHub.Functions.Farm_GetPlotCmds()
    if not v1 then return false end
    local v2, v3 = pcall(function() return v1.GetPlotData() end)
    if not v2 or type(v3) ~= "table" then return false end
    local Position
    if v3.PetArea and v3.PetArea.Position then
        Position = v3.PetArea.Position
    elseif v3.CenterPoint and v3.CenterPoint.CFrame then
        Position = v3.CenterPoint.CFrame.Position
    elseif v3.CenterPoint and v3.CenterPoint.Position then
        Position = v3.CenterPoint.Position
    end
    if not Position then return false end
    MystrixHub.Functions.Farm_Teleport(Position + Vector3.new(0, 5, 0))
    task.wait(0.03)
    if MystrixHub.Functions.Farm_IsCarrying() then
        MystrixHub.Functions.Farm_Teleport(Position + Vector3.new(0, 5, 0))
    end
    return true
end
v6.Functions.Farm_WaitClaim = function()
    local deadline = tick() + 2.5
    while tick() < deadline do
        if not MystrixHub.Functions.Farm_IsCarrying() then return true end
        task.wait(0.03)
    end
    return not MystrixHub.Functions.Farm_IsCarrying()
end
v6.Functions.Farm_RunOnce = function()
    if not MystrixHub.FarmController.Enabled then return false, "disabled" end
    if MystrixHub.Functions.Farm_IsCarrying() then
        MystrixHub.Functions.Farm_ReturnToBase()
        MystrixHub.Functions.Farm_WaitClaim()
        return true, "claimed"
    end
    local target = MystrixHub.Functions.Farm_FindBestTarget()
    if not target then return false, "no target" end
    if MystrixHub.Functions.Farm_StealEgg(target.Record) then
        MystrixHub.Functions.Farm_ReturnToBase()
        MystrixHub.Functions.Farm_WaitClaim()
        return true, "stolen"
    end
    return false, "steal failed"
end
v6.Functions.StartAutoFarm = function()
    local FC = MystrixHub.FarmController
    if FC.Running then return end
    FC.FailCounts = {}
    FC.Enabled = true
    FC.Running = true
    FC.Loop = task.spawn(function()
        while FC.Enabled do
            local v1, v2 = pcall(MystrixHub.Functions.Farm_RunOnce)
            if not v1 then task.wait(0.2)
            elseif v2 == false then task.wait(0.1) end
            task.wait(0.03)
        end
        FC.Running = false
    end)
    MystrixHub.TasksController.Insert(FC.Loop)
end
v6.Functions.StopAutoFarm = function()
    local FC = MystrixHub.FarmController
    FC.Enabled = false
    FC.Running = false
    FC.FailCounts = {}
    FC.LastTargetUid = nil
    if FC.Loop then task.cancel(FC.Loop) FC.Loop = nil end
end

-- ===== ฟังก์ชัน Sell =====
v6.Functions.Sell_LoadDeps = function()
    local Deps = MystrixHub.SellController.Deps
    if Deps.Save and Deps.Network and Deps.EggItemUtil and Deps.AssetItemSerialization and Deps.GetPriceValueForItem then
        return Deps
    end
    local Library = game:GetService("ReplicatedStorage"):FindFirstChild("Library")
    local v1 = Library and Library:FindFirstChild("Client")
    local v2 = Library and Library:FindFirstChild("Util")
    if not Deps.Save and v1 then
        local Save = v1:FindFirstChild("Save")
        if Save and Save:IsA("ModuleScript") then
            local ok, m = pcall(require, Save)
            if ok and type(m) == "table" and type(m.Get) == "function" then Deps.Save = m end
        end
    end
    if not Deps.Network and v1 then
        local Network = v1:FindFirstChild("Network")
        if Network and Network:IsA("ModuleScript") then
            local ok, m = pcall(require, Network)
            if ok and type(m) == "table" then Deps.Network = m end
        end
    end
    if not Deps.EggItemUtil and v2 then
        local EggItemUtil = v2:FindFirstChild("EggItemUtil")
        if EggItemUtil and EggItemUtil:IsA("ModuleScript") then
            local ok, m = pcall(require, EggItemUtil)
            if ok and type(m) == "table" then Deps.EggItemUtil = m end
        end
    end
    if not Deps.AssetItemSerialization and v2 then
        local AIS = v2:FindFirstChild("AssetItemSerialization")
        if AIS and AIS:IsA("ModuleScript") then
            local ok, m = pcall(require, AIS)
            if ok and type(m) == "table" then Deps.AssetItemSerialization = m end
        end
    end
    if not Deps.GetPriceValueForItem and v2 then
        local GPVFI = v2:FindFirstChild("GetPriceValueForItem")
        if GPVFI and GPVFI:IsA("ModuleScript") then
            local ok, m = pcall(require, GPVFI)
            if ok and type(m) == "function" then Deps.GetPriceValueForItem = m end
        end
    end
    return Deps
end
v6.Functions.Sell_GetSellableEggs = function()
    local v1 = MystrixHub.Functions.Sell_LoadDeps()
    if not v1.Save or not v1.EggItemUtil then return {} end
    local ok, saveData = pcall(function() return v1.Save.Get() end)
    if not ok or type(saveData) ~= "table" then return {} end
    local inventory = saveData.EggInventory or {}
    local Assets = MystrixHub.Functions.Farm_GetAssets()
    local result = {}
    for k, v6 in pairs(inventory) do
        if type(v6) == "table" and v6.Placement == nil then
            local ok2, egg = pcall(function() return v1.EggItemUtil.DeserializeSavedEgg(v6) end)
            if ok2 and type(egg) == "table" then
                local cat = egg.AssetCategory
                local ok3, price = pcall(function() return v1.EggItemUtil.GetSellPrice(egg) end)
                local rarity, rarityNum = "Unknown", 0
                if Assets and Assets.Directory[cat] then
                    local R = Assets.Directory[cat].Rarity
                    if type(R) == "table" then
                        rarity = R.DisplayName or R._id or R.Name or "Unknown"
                        rarityNum = tonumber(R.RarityNumber) or 0
                    end
                end
                table.insert(result, {uid = k, category = cat, price = ok3 and math.floor(price) or 0, rarity = rarity, rarityNum = rarityNum})
            end
        end
    end
    return result
end
v6.Functions.Sell_GetSellablePets = function()
    local v1 = MystrixHub.Functions.Sell_LoadDeps()
    if not v1.Save or not v1.AssetItemSerialization or not v1.GetPriceValueForItem then return {} end
    local ok, saveData = pcall(function() return v1.Save.Get() end)
    if not ok or type(saveData) ~= "table" then return {} end
    local inventory = saveData.Inventory or {}
    local equipped = saveData.EquippedAssets or {}
    local favorites = saveData.FavoriteAssets or {}
    local Assets = MystrixHub.Functions.Farm_GetAssets()
    local mult = LocalPlayer:GetAttribute("VIP") and 2 or 1
    local result = {}
    for k, v9 in pairs(inventory) do
        if type(v9) == "table" then
            if not table.find(equipped, k) and not favorites[k] then
                local ok2, item = pcall(function() return v1.AssetItemSerialization.Deserialize(v9) end)
                if ok2 and type(item) == "table" then
                    if not item.IsFavorite and not item.InFuse then
                        local cat = item.Category
                        local ok3, price = pcall(function() return v1.GetPriceValueForItem(v9) * 1.33 * mult end)
                        local rarity, rarityNum = "Unknown", 0
                        if Assets and Assets.Directory[cat] then
                            local R = Assets.Directory[cat].Rarity
                            if type(R) == "table" then
                                rarity = R.DisplayName or R._id or R.Name or "Unknown"
                                rarityNum = tonumber(R.RarityNumber) or 0
                            end
                        end
                        table.insert(result, {uid = k, category = cat, price = ok3 and math.floor(price) or 0, rarity = rarity, rarityNum = rarityNum})
                    end
                end
            end
        end
    end
    return result
end
v6.Functions.Sell_GetAllEggCategories = function()
    local v1 = MystrixHub.Functions.Farm_GetAssets()
    if not v1 then return {} end
    local tbl = {}
    for k, v2 in pairs(v1.Directory) do
        if type(k) == "string" and type(v2) == "table" and v2.Egg ~= nil and type(v2.Rarity) == "table" then
            local num = tonumber(v2.Rarity.RarityNumber)
            table.insert(tbl, {name = k, rarity = v2.Rarity.DisplayName or v2.Rarity._id or v2.Rarity.Name or "Unknown", rarityNum = num or 0})
        end
    end
    table.sort(tbl, function(a, b)
        if a.rarityNum ~= b.rarityNum then return a.rarityNum > b.rarityNum end
        return a.name < b.name
    end)
    local result = {}
    for _, v3 in ipairs(tbl) do table.insert(result, "[" .. v3.rarity .. "] " .. v3.name) end
    return result
end
v6.Functions.Sell_GetAllPetCategories = function()
    local v1 = MystrixHub.Functions.Farm_GetAssets()
    if not v1 then return {} end
    local tbl = {}
    for k, v2 in pairs(v1.Directory) do
        if type(k) == "string" and type(v2) == "table" and v2.Egg == nil and type(v2.Rarity) == "table" then
            if v2.DisplayName ~= nil or v2.Icon ~= nil then
                local num = tonumber(v2.Rarity.RarityNumber)
                table.insert(tbl, {name = k, rarity = v2.Rarity.DisplayName or v2.Rarity._id or v2.Rarity.Name or "Unknown", rarityNum = num or 0})
            end
        end
    end
    table.sort(tbl, function(a, b)
        if a.rarityNum ~= b.rarityNum then return a.rarityNum > b.rarityNum end
        return a.name < b.name
    end)
    local result = {}
    for _, v3 in ipairs(tbl) do table.insert(result, "[" .. v3.rarity .. "] " .. v3.name) end
    return result
end
v6.Functions.Sell_SellEgg = function(arg1)
    local Deps = MystrixHub.Functions.Sell_LoadDeps()
    if not Deps.Network or not Deps.EggItemUtil then return false end
    local ok, saveData = pcall(function() return Deps.Save.Get() end)
    if not ok or type(saveData) ~= "table" then return false end
    local eggData = saveData.EggInventory and saveData.EggInventory[arg1]
    if not eggData then return false end
    local ok2, egg = pcall(function() return Deps.EggItemUtil.DeserializeSavedEgg(eggData) end)
    if not ok2 then return false end
    local SellEgg = Deps.Network.NET_MAP and Deps.Network.NET_MAP.Eggs and Deps.Network.NET_MAP.Eggs.SELL_EGG
    if not SellEgg then return false end
    local ok3 = pcall(function() Deps.Network.Invoke(SellEgg, arg1) end)
    return ok3
end
v6.Functions.Sell_SellPet = function(arg1)
    local Deps = MystrixHub.Functions.Sell_LoadDeps()
    if not Deps.Network then return false end
    local SellPet = Deps.Network.NET_MAP and Deps.Network.NET_MAP.Assets and Deps.Network.NET_MAP.Assets.SELL_ASSET
    if not SellPet then return false end
    local ok = pcall(function() Deps.Network.Invoke(SellPet, arg1) end)
    return ok
end
v6.Functions.Sell_AllEggs = function()
    local SC = MystrixHub.SellController
    local eggs = MystrixHub.Functions.Sell_GetSellableEggs()
    local catMap = {}
    for _, c in ipairs(SC.SelectedEggCategories) do catMap[c] = true end
    local count = 0
    for _, egg in ipairs(eggs) do
        if catMap[egg.category] then
            if MystrixHub.Functions.Sell_SellEgg(egg.uid) then
                count += 1
                task.wait(0.1)
            end
        end
    end
    return count
end
v6.Functions.Sell_AllPets = function()
    local SC = MystrixHub.SellController
    local pets = MystrixHub.Functions.Sell_GetSellablePets()
    local catMap = {}
    for _, c in ipairs(SC.SelectedPetCategories) do catMap[c] = true end
    local count = 0
    for _, pet in ipairs(pets) do
        if catMap[pet.category] then
            if MystrixHub.Functions.Sell_SellPet(pet.uid) then
                count += 1
                task.wait(0.1)
            end
        end
    end
    return count
end
v6.Functions.Sell_StartAutoEggs = function()
    local SC = MystrixHub.SellController
    if SC.AutoEggsRunning then return end
    SC.AutoEggsRunning = true
    SC.AutoEggsLoop = task.spawn(function()
        while SC.AutoEggsRunning do
            pcall(MystrixHub.Functions.Sell_AllEggs)
            task.wait(5)
        end
    end)
    MystrixHub.TasksController.Insert(SC.AutoEggsLoop)
end
v6.Functions.Sell_StopAutoEggs = function()
    local SC = MystrixHub.SellController
    SC.AutoEggsRunning = false
    if SC.AutoEggsLoop then task.cancel(SC.AutoEggsLoop) SC.AutoEggsLoop = nil end
end
v6.Functions.Sell_StartAutoPets = function()
    local SC = MystrixHub.SellController
    if SC.AutoPetsRunning then return end
    SC.AutoPetsRunning = true
    SC.AutoPetsLoop = task.spawn(function()
        while SC.AutoPetsRunning do
            pcall(MystrixHub.Functions.Sell_AllPets)
            task.wait(5)
        end
    end)
    MystrixHub.TasksController.Insert(SC.AutoPetsLoop)
end
v6.Functions.Sell_StopAutoPets = function()
    local SC = MystrixHub.SellController
    SC.AutoPetsRunning = false
    if SC.AutoPetsLoop then task.cancel(SC.AutoPetsLoop) SC.AutoPetsLoop = nil end
end

-- ===== ฟังก์ชัน Shop =====
v6.Functions.Shop_GetSaveModule = function()
    local Library = game:GetService("ReplicatedStorage"):FindFirstChild("Library")
    local v1 = Library and Library:FindFirstChild("Client")
    local v2 = v1 and v1:FindFirstChild("Save")
    if not v2 or not v2:IsA("ModuleScript") then return nil end
    local ok, m = pcall(require, v2)
    if ok and type(m) == "table" then return m end
    return nil
end
v6.Functions.Shop_GetNetworkModule = function()
    local Library = game:GetService("ReplicatedStorage"):FindFirstChild("Library")
    local v1 = Library and Library:FindFirstChild("Client")
    local v2 = v1 and v1:FindFirstChild("Network")
    if not v2 or not v2:IsA("ModuleScript") then return nil end
    local ok, m = pcall(require, v2)
    if ok and type(m) == "table" then return m end
    return nil
end
v6.Functions.Shop_GetTrailsData = function()
    local Directory = game:GetService("ReplicatedStorage"):FindFirstChild("Directory")
    local v1 = Directory and Directory:FindFirstChild("Trails")
    if not v1 or not v1:IsA("ModuleScript") then return nil end
    local ok, m = pcall(require, v1)
    if ok and type(m) == "table" then return m end
    return nil
end
v6.Functions.Shop_GetBikeCatalog = function()
    local OurBikeSystem = game:GetService("ReplicatedStorage"):FindFirstChild("OurBikeSystem")
    if not OurBikeSystem then return nil end
    local v1 = OurBikeSystem:FindFirstChild("BikeCatalog")
    if not v1 or not v1:IsA("ModuleScript") then return nil end
    local ok, m = pcall(require, v1)
    if ok and type(m) == "table" and #m > 0 then return m end
    return nil
end
v6.Functions.Shop_GetBikeShopRequest = function()
    local OurBikeSystem = game:GetService("ReplicatedStorage"):FindFirstChild("OurBikeSystem")
    if not OurBikeSystem then return nil end
    local v1 = OurBikeSystem:FindFirstChild("ShopRequest") or OurBikeSystem:WaitForChild("ShopRequest", 5)
    if v1 and v1:IsA("RemoteFunction") then return v1 end
    return nil
end
v6.Functions.Shop_BuyBestTrail = function()
    local v1 = MystrixHub.Functions.Shop_GetTrailsData()
    local v2 = MystrixHub.Functions.Shop_GetSaveModule()
    local v3 = MystrixHub.Functions.Shop_GetNetworkModule()
    if not v1 or not v2 or not v3 then return false, "missing" end
    if not v3.NET_MAP or not v3.NET_MAP.Trails then return false, "no netmap" end
    local ok, saveData = pcall(function() return v2.Get() end)
    if not ok or type(saveData) ~= "table" then return false, "no save" end
    local money = tonumber(saveData.Money) or 0
    local trailInv = saveData.TrailInventory or {}
    local EquippedTrail = saveData.EquippedTrail
    local bestOwned, bestOwnedSpeed = nil, 0
    for k, _ in pairs(trailInv) do
        if v1.Directory[k] then
            local spd = tonumber(v1.Directory[k].SpeedMultiplier) or 1
            if spd > bestOwnedSpeed then bestOwnedSpeed = spd bestOwned = k end
        end
    end
    local bestBuy, bestBuySpeed = nil, bestOwnedSpeed
    for k, v in pairs(v1.Directory) do
        if type(k) == "string" and type(v) == "table" then
            if v.DisplayInShop and not v.RobuxOnly and not trailInv[k] then
                local price = tonumber(v.Price) or 0
                local spd = tonumber(v.SpeedMultiplier) or 1
                if price > 0 and price <= money and spd > bestBuySpeed then
                    bestBuySpeed = spd
                    bestBuy = {Id = k, Data = v}
                end
            end
        end
    end
    local Trails = v3.NET_MAP.Trails
    if bestBuy then
        pcall(function() v3.Invoke(Trails.REQUEST_PURCHASE, bestBuy.Id) end)
        task.wait(0.35)
        pcall(function() v3.Invoke(Trails.REQUEST_SELECT, bestBuy.Id) end)
        return true, "bought " .. bestBuy.Id
    end
    if bestOwned and EquippedTrail ~= bestOwned then
        pcall(function() v3.Invoke(Trails.REQUEST_SELECT, bestOwned) end)
        return true, "equipped " .. bestOwned
    end
    return false, "up to date"
end
v6.Functions.Shop_BuyBestBike = function()
    local catalog = MystrixHub.Functions.Shop_GetBikeCatalog()
    local shopReq = MystrixHub.Functions.Shop_GetBikeShopRequest()
    local saveModule = MystrixHub.Functions.Shop_GetSaveModule()
    if not catalog or not shopReq then return false, "missing" end
    local money = 0
    if saveModule then
        local ok, saveData = pcall(function() return saveModule.Get() end)
        if ok and type(saveData) == "table" then money = tonumber(saveData.Money) or 0 end
    end
    local ok2, state = pcall(function() return shopReq:InvokeServer("State") end)
    if not ok2 or type(state) ~= "table" then return false, "state failed" end
    local owned = state.Owned or {}
    local equipped = state.Equipped or "Bicycle"
    if type(state.Money) == "number" and state.Money > money then money = state.Money end
    local bikes = {}
    for _, b in ipairs(catalog) do
        if type(b) == "table" and type(b.Id) == "string" and not b.AdminOnly and not b.RobuxOnly then
            table.insert(bikes, b)
        end
    end
    table.sort(bikes, function(a, b) return (tonumber(a.SpeedMultiplier) or 1) > (tonumber(b.SpeedMultiplier) or 1) end)
    local bestOwnedSpeed = 1
    for _, bike in ipairs(bikes) do
        if owned[bike.Id] == true then
            local spd = tonumber(bike.SpeedMultiplier) or 1
            if spd > bestOwnedSpeed then bestOwnedSpeed = spd end
        end
    end
    for _, bike in ipairs(bikes) do
        local spd = tonumber(bike.SpeedMultiplier) or 1
        local price = tonumber(bike.Price) or 0
        if not owned[bike.Id] and spd > bestOwnedSpeed and price > 0 and price <= money then
            local ok3, res = pcall(function() return shopReq:InvokeServer("Buy", bike.Id) end)
            if ok3 and type(res) == "table" and res.Ok then
                Notify({Title = "Bike Shop", Content = "Bought: " .. bike.Id, Duration = 3, Icon = "circle-check"})
                return true, "bought " .. bike.Id
            end
            task.wait(0.2)
        end
    end
    local bestId, bestSpd = nil, 1
    for _, bike in ipairs(bikes) do
        if owned[bike.Id] == true then
            local spd = tonumber(bike.SpeedMultiplier) or 1
            if spd > bestSpd then bestSpd = spd bestId = bike.Id end
        end
    end
    if bestId and equipped ~= bestId then
        pcall(function() return shopReq:InvokeServer("Equip", bestId) end)
        return true, "equipped " .. bestId
    end
    return false, "up to date"
end
v6.Functions.Shop_StartAutoTrail = function()
    local SC = MystrixHub.ShopController
    if SC.AutoTrailRunning then return end
    SC.AutoTrailRunning = true
    SC.AutoTrailLoop = task.spawn(function()
        while SC.AutoTrailRunning do
            pcall(MystrixHub.Functions.Shop_BuyBestTrail)
            task.wait(5)
        end
    end)
    MystrixHub.TasksController.Insert(SC.AutoTrailLoop)
end
v6.Functions.Shop_StopAutoTrail = function()
    local SC = MystrixHub.ShopController
    SC.AutoTrailRunning = false
    if SC.AutoTrailLoop then task.cancel(SC.AutoTrailLoop) SC.AutoTrailLoop = nil end
end
v6.Functions.Shop_StartAutoBike = function()
    local SC = MystrixHub.ShopController
    if SC.AutoBikeRunning then return end
    SC.AutoBikeRunning = true
    SC.AutoBikeLoop = task.spawn(function()
        while SC.AutoBikeRunning do
            pcall(MystrixHub.Functions.Shop_BuyBestBike)
            task.wait(5)
        end
    end)
    MystrixHub.TasksController.Insert(SC.AutoBikeLoop)
end
v6.Functions.Shop_StopAutoBike = function()
    local SC = MystrixHub.ShopController
    SC.AutoBikeRunning = false
    if SC.AutoBikeLoop then task.cancel(SC.AutoBikeLoop) SC.AutoBikeLoop = nil end
end
v6.Functions.Shop_UpgradeTreadmill = function()
    local Library = game:GetService("ReplicatedStorage"):FindFirstChild("Library")
    local v1 = Library and Library:FindFirstChild("Client")
    local v2 = v1 and v1:FindFirstChild("BaseUpgradeClient")
    if not v2 or not v2:IsA("ModuleScript") then return false end
    local ok, m = pcall(require, v2)
    if not ok or type(m) ~= "table" then return false end
    local net = MystrixHub.Functions.Shop_GetNetworkModule()
    if not net or not net.NET_MAP or not net.NET_MAP.Treadmills then return false end
    pcall(function() net.Invoke(net.NET_MAP.Treadmills.REQUEST_UPGRADE) end)
    return true
end
v6.Functions.Shop_UpgradePlot = function()
    local net = MystrixHub.Functions.Shop_GetNetworkModule()
    if not net or not net.NET_MAP or not net.NET_MAP.Plot then return false end
    pcall(function() net.Invoke(net.NET_MAP.Plot.REQUEST_UPGRADE) end)
    return true
end
v6.Functions.Shop_StartAutoTreadmill = function()
    local SC = MystrixHub.ShopController
    if SC.AutoTreadmillRunning then return end
    SC.AutoTreadmillRunning = true
    SC.AutoTreadmillLoop = task.spawn(function()
        while SC.AutoTreadmillRunning do
            pcall(MystrixHub.Functions.Shop_UpgradeTreadmill)
            task.wait(3)
        end
    end)
    MystrixHub.TasksController.Insert(SC.AutoTreadmillLoop)
end
v6.Functions.Shop_StopAutoTreadmill = function()
    local SC = MystrixHub.ShopController
    SC.AutoTreadmillRunning = false
    if SC.AutoTreadmillLoop then task.cancel(SC.AutoTreadmillLoop) SC.AutoTreadmillLoop = nil end
end
v6.Functions.Shop_StartAutoPlot = function()
    local SC = MystrixHub.ShopController
    if SC.AutoPlotRunning then return end
    SC.AutoPlotRunning = true
    SC.AutoPlotLoop = task.spawn(function()
        while SC.AutoPlotRunning do
            pcall(MystrixHub.Functions.Shop_UpgradePlot)
            task.wait(3)
        end
    end)
    MystrixHub.TasksController.Insert(SC.AutoPlotLoop)
end
v6.Functions.Shop_StopAutoPlot = function()
    local SC = MystrixHub.ShopController
    SC.AutoPlotRunning = false
    if SC.AutoPlotLoop then task.cancel(SC.AutoPlotLoop) SC.AutoPlotLoop = nil end
end

-- ===== ฟังก์ชัน Plot =====
v6.Functions.Plot_CountPlacedEggs = function()
    local v1 = MystrixHub.Functions.Farm_GetPlotCmds()
    if not v1 then return 0 end
    local ok, plotData = pcall(function() return v1.GetPlotData() end)
    if not ok or type(plotData) ~= "table" then return 0 end
    local Deps = MystrixHub.Functions.Sell_LoadDeps()
    if not Deps.Save then return 0 end
    local ok2, saveData = pcall(function() return Deps.Save.Get() end)
    if not ok2 or type(saveData) ~= "table" then return 0 end
    local inv = saveData.EggInventory or {}
    local count = 0
    for _, v in pairs(inv) do
        if type(v) == "table" and v.Placement ~= nil then count += 1 end
    end
    return count
end
v6.Functions.Plot_GetNetworkRemote = function(arg1)
    local RS2 = game:GetService("ReplicatedStorage")
    for _, v in ipairs(RS2:GetDescendants()) do
        if v.Name == arg1 and (v:IsA("RemoteFunction") or v:IsA("RemoteEvent")) then
            return v
        end
    end
    return nil
end
v6.Functions.Plot_GetFreePlacement = function(arg1)
    if not arg1 or not arg1.Slots then return nil end
    for _, slot in ipairs(arg1.Slots) do
        if not slot.Occupied then return slot.CFrame end
    end
    return nil
end
v6.Functions.Plot_HatchOne = function(arg1)
    local v1 = MystrixHub.Functions.Farm_GetPlotCmds()
    if not v1 then return false end
    local HatchEgg = MystrixHub.Functions.Plot_GetNetworkRemote("Eggs: RequestHatchEgg")
    if not HatchEgg then return false end
    local ok, res = pcall(function() return HatchEgg:InvokeServer(arg1.uid) end)
    return ok and res
end
v6.Functions.Plot_GetEggsList = function()
    local result = {"All"}
    local Deps = MystrixHub.Functions.Sell_LoadDeps()
    if not Deps.Save then return result end
    local ok, saveData = pcall(function() return Deps.Save.Get() end)
    if not ok or type(saveData) ~= "table" then return result end
    local inv = saveData.EggInventory or {}
    local seen = {}
    for _, v in pairs(inv) do
        if type(v) == "table" and v.Placement ~= nil then
            local cat = v.AssetCategory
            if cat and not seen[cat] then
                seen[cat] = true
                table.insert(result, cat)
            end
        end
    end
    return result
end
v6.Functions.Plot_GetEggsListForPlace = function()
    local result = {"Best"}
    local Deps = MystrixHub.Functions.Sell_LoadDeps()
    if not Deps.Save or not Deps.EggItemUtil then return result end
    local ok, saveData = pcall(function() return Deps.Save.Get() end)
    if not ok or type(saveData) ~= "table" then return result end
    local inv = saveData.EggInventory or {}
    local seen = {}
    for _, v in pairs(inv) do
        if type(v) == "table" and v.Placement == nil then
            local ok2, egg = pcall(function() return Deps.EggItemUtil.DeserializeSavedEgg(v) end)
            if ok2 and type(egg) == "table" and egg.AssetCategory and not seen[egg.AssetCategory] then
                seen[egg.AssetCategory] = true
                table.insert(result, egg.AssetCategory)
            end
        end
    end
    return result
end
v6.Functions.Plot_RunHatchOnce = function()
    local PC = MystrixHub.PlotController
    local Deps = MystrixHub.Functions.Sell_LoadDeps()
    if not Deps.Save or not Deps.EggItemUtil then return false end
    local ok, saveData = pcall(function() return Deps.Save.Get() end)
    if not ok or type(saveData) ~= "table" then return false end
    local inv = saveData.EggInventory or {}
    local selectedMap = {}
    for _, s in ipairs(PC.HatchSelectedEggs) do selectedMap[s] = true end
    local targets = {}
    for k, v in pairs(inv) do
        if type(v) == "table" and v.Placement ~= nil then
            if selectedMap["All"] or selectedMap[v.AssetCategory] then
                table.insert(targets, {uid = k, data = v})
            end
        end
    end
    if #targets == 0 then return false end
    for _, egg in ipairs(targets) do
        if MystrixHub.Functions.Plot_HatchOne(egg) then return true end
    end
    return false
end
v6.Functions.Plot_StartAutoHatch = function()
    local PC = MystrixHub.PlotController
    if PC.AutoHatchRunning then return end
    PC.AutoHatchRunning = true
    PC.AutoHatchLoop = task.spawn(function()
        while PC.AutoHatchRunning do
            pcall(MystrixHub.Functions.Plot_RunHatchOnce)
            task.wait(0.6)
        end
    end)
    MystrixHub.TasksController.Insert(PC.AutoHatchLoop)
end
v6.Functions.Plot_StopAutoHatch = function()
    local PC = MystrixHub.PlotController
    PC.AutoHatchRunning = false
    if PC.AutoHatchLoop then task.cancel(PC.AutoHatchLoop) PC.AutoHatchLoop = nil end
end
v6.Functions.Plot_StartAutoPlace = function()
    local PC = MystrixHub.PlotController
    if PC.AutoPlaceRunning then return end
    PC.AutoPlaceRunning = true
    PC.AutoPlaceLoop = task.spawn(function()
        while PC.AutoPlaceRunning do
            pcall(MystrixHub.Functions.Plot_RunPlaceOnce)
            task.wait(1.5)
        end
    end)
    MystrixHub.TasksController.Insert(PC.AutoPlaceLoop)
end
v6.Functions.Plot_StopAutoPlace = function()
    local PC = MystrixHub.PlotController
    PC.AutoPlaceRunning = false
    if PC.AutoPlaceLoop then task.cancel(PC.AutoPlaceLoop) PC.AutoPlaceLoop = nil end
end
v6.Functions.Plot_RunPlaceOnce = function()
    local PC = MystrixHub.PlotController
    local v2 = MystrixHub.Functions.Farm_GetPlotCmds()
    if not v2 then return false end
    local ok, plotData = pcall(function() return v2.GetPlotData() end)
    if not ok or type(plotData) ~= "table" then return false end
    local placed = MystrixHub.Functions.Plot_CountPlacedEggs()
    if placed >= 10 then return false end
    local Deps = MystrixHub.Functions.Sell_LoadDeps()
    if not Deps.Save or not Deps.EggItemUtil then return false end
    local ok2, saveData = pcall(function() return Deps.Save.Get() end)
    if not ok2 or type(saveData) ~= "table" then return false end
    local inv = saveData.EggInventory or {}
    local selectedMap = {}
    local useBest = false
    for _, s in ipairs(PC.PlaceSelectedEggs) do
        if s == "Best" or s == "All" then useBest = true
        else selectedMap[s] = true end
    end
    local Assets = MystrixHub.Functions.Farm_GetAssets()
    local candidates = {}
    for k, v in pairs(inv) do
        if type(v) == "table" and v.Placement == nil then
            local ok3, egg = pcall(function() return Deps.EggItemUtil.DeserializeSavedEgg(v) end)
            if ok3 and type(egg) == "table" then
                local cat = egg.AssetCategory
                if cat and (useBest or selectedMap[cat]) then
                    local score = 0
                    if Assets and Assets.Directory[cat] and Assets.Directory[cat].Rarity then
                        score = tonumber(Assets.Directory[cat].Rarity.RarityNumber) or 0
                    end
                    table.insert(candidates, {uid = k, cat = cat, score = score})
                end
            end
        end
    end
    if #candidates == 0 then return false end
    table.sort(candidates, function(a, b) return a.score > b.score end)
    local best = candidates[1]
    local freePlot = MystrixHub.Functions.Plot_GetFreePlacement(plotData)
    if not freePlot then return false end
    local equipRemote = MystrixHub.Functions.Plot_GetNetworkRemote("Eggs: RequestEquipTool")
    local placeRemote = MystrixHub.Functions.Plot_GetNetworkRemote("Eggs: RequestPlaceEgg")
    if not equipRemote or not placeRemote then return false end
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return false end
    pcall(function() Humanoid:UnequipTools() end)
    task.wait(0.15)
    local ok4, equipped = pcall(function() return equipRemote:InvokeServer(best.uid) end)
    if not ok4 or not equipped then return false end
    task.wait(0.4)
    local ok5, placed2 = pcall(function() return placeRemote:InvokeServer({Uid = best.uid, LocalCFrame = freePlot}) end)
    task.wait(0.15)
    pcall(function() Humanoid:UnequipTools() end)
    return ok5 and placed2
end
v6.Functions.Plot_StartAutoTreadmill = function()
    local PC = MystrixHub.PlotController
    if PC.AutoTreadmillRunning then return end
    PC.AutoTreadmillRunning = true
    PC.AutoTreadmillLoop = task.spawn(function()
        while PC.AutoTreadmillRunning do
            local net = MystrixHub.Functions.Shop_GetNetworkModule()
            if net and net.NET_MAP and net.NET_MAP.Treadmills then
                pcall(function() net.Invoke(net.NET_MAP.Treadmills.REQUEST_EQUIP_STATIC) end)
            end
            task.wait(2)
        end
    end)
    MystrixHub.TasksController.Insert(PC.AutoTreadmillLoop)
end
v6.Functions.Plot_StopAutoTreadmill = function()
    local PC = MystrixHub.PlotController
    PC.AutoTreadmillRunning = false
    if PC.AutoTreadmillLoop then task.cancel(PC.AutoTreadmillLoop) PC.AutoTreadmillLoop = nil end
end
v6.Functions.Plot_StartAutoClaim = function()
    local PC = MystrixHub.PlotController
    if PC.AutoClaimRunning then return end
    PC.AutoClaimRunning = true
    PC.AutoClaimLoop = task.spawn(function()
        while PC.AutoClaimRunning do
            pcall(function()
                local v1 = MystrixHub.Functions.Farm_GetPlotCmds()
                if v1 then
                    local ok, pd = pcall(function() return v1.GetPlotData() end)
                    if ok and pd and v1.ClaimAllEggs then
                        pcall(function() v1.ClaimAllEggs() end)
                    end
                end
            end)
            task.wait(2)
        end
    end)
    MystrixHub.TasksController.Insert(PC.AutoClaimLoop)
end
v6.Functions.Plot_StopAutoClaim = function()
    local PC = MystrixHub.PlotController
    PC.AutoClaimRunning = false
    if PC.AutoClaimLoop then task.cancel(PC.AutoClaimLoop) PC.AutoClaimLoop = nil end
end

-- ===== FetchDiscordInfo =====
v6.Functions.FetchDiscordInfo = function()
    local ok, res = pcall(MystrixHub.Functions.MakeRawRequest,
        "https://discord.com/api/v9/invites/" .. MystrixHub.Meta.Discord .. "?with_counts=true",
        "GET", {Accept = "application/json"}, nil)
    if ok and res and res.Body then
        local ok2, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if ok2 and data then
            if data.guild and data.guild.name then MystrixHub.Meta.ServerName = data.guild.name end
            MystrixHub.Meta.MemberCount = data.approximate_member_count and tostring(data.approximate_member_count) or "N/A"
            MystrixHub.Meta.OnlineCount = data.approximate_presence_count and tostring(data.approximate_presence_count) or "N/A"
            return true
        end
    end
    MystrixHub.Meta.MemberCount = "Unavailable"
    MystrixHub.Meta.OnlineCount = "Unavailable"
    return false
end

-- ============================================================
-- SECTION 4: Init
-- ============================================================
MystrixHub.PlayerController.HWID = MystrixHub.Functions.GetHWID()
MystrixHub.Functions.SyncServerTime()
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    MystrixHub.Meta.GameName = info.Name or "Unknown Game"
end)
task.spawn(function()
    MystrixHub.Functions.FetchDiscordInfo()
end)

-- ============================================================
-- SECTION 5: สร้างหน้าต่าง NexoraHub
-- ============================================================

-- เปลี่ยน CFG ของ NexoraHub ให้ตรงกับ BIKE FOR EGG
NX.CFG.NAME = "BIKE FOR EGG"
NX.CFG.DISCORD_LINK = "https://discord.gg/" .. MystrixHub.Meta.Discord

-- helper สร้าง page content frame ที่ scroll ได้
local function makePage(pageFrame)
    local scroll = make("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = COL.Purple,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    }, pageFrame)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
    }, scroll)
    make("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
    }, scroll)
    return scroll
end

-- helper สร้าง section header
local function sectionLabel(parent, text, order)
    local lbl = make("TextLabel", {
        LayoutOrder = order or 0,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "▸ " .. text,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = COL.Sub,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
    return lbl
end

-- helper สร้าง toggle row
local toggleOrder = 0
local function makeToggle(parent, label, desc, onToggle)
    toggleOrder += 1
    local row = make("Frame", {
        LayoutOrder = toggleOrder,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = COL.Chip,
        BackgroundTransparency = 0.4,
    }, parent)
    round(row, 14)

    make("TextLabel", {
        Position = UDim2.fromOffset(12, 6),
        Size = UDim2.new(1, -70, 0, 16),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = COL.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    if desc and desc ~= "" then
        make("TextLabel", {
            Position = UDim2.fromOffset(12, 24),
            Size = UDim2.new(1, -70, 0, 14),
            BackgroundTransparency = 1,
            Text = desc,
            Font = Enum.Font.Gotham,
            TextSize = 9,
            TextColor3 = COL.Sub,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
    end

    local sw = make("TextButton", {
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromOffset(38, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = COL.Bg,
    }, row)
    round(sw, 10)
    local knob = make("Frame", {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, sw)
    round(knob, 7)

    local state = false
    local function set(v)
        state = v
        TS:Create(sw, TI, {BackgroundColor3 = v and COL.Purple or COL.Bg}):Play()
        TS:Create(knob, TI, {Position = v and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)}):Play()
        onToggle(v)
    end
    sw.MouseButton1Click:Connect(function() set(not state) end)
    NX.onAccent(function() sw.BackgroundColor3 = state and COL.Purple or COL.Bg end)
    return set
end

-- helper สร้าง button row
local function makeButton(parent, label, desc, btnText, onClick)
    toggleOrder += 1
    local row = make("Frame", {
        LayoutOrder = toggleOrder,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = COL.Chip,
        BackgroundTransparency = 0.4,
    }, parent)
    round(row, 14)
    make("TextLabel", {
        Position = UDim2.fromOffset(12, 6),
        Size = UDim2.new(1, -110, 0, 16),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = COL.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    if desc and desc ~= "" then
        make("TextLabel", {
            Position = UDim2.fromOffset(12, 24),
            Size = UDim2.new(1, -110, 0, 14),
            BackgroundTransparency = 1,
            Text = desc,
            Font = Enum.Font.Gotham,
            TextSize = 9,
            TextColor3 = COL.Sub,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
    end
    local btn = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(84, 26),
        BackgroundColor3 = COL.Purple,
        Text = btnText,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
    }, row)
    round(btn, 13)
    NX.onAccent(function(a) btn.BackgroundColor3 = a end)
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- helper dropdown (multi-select จำลอง)
local function makeDropdown(parent, label, values, onSelect)
    toggleOrder += 1
    local row = make("Frame", {
        LayoutOrder = toggleOrder,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = COL.Chip,
        BackgroundTransparency = 0.4,
        ClipsDescendants = false,
    }, parent)
    round(row, 14)
    make("TextLabel", {
        Position = UDim2.fromOffset(12, 6),
        Size = UDim2.new(1, -14, 0, 14),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = COL.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local display = make("TextButton", {
        Position = UDim2.fromOffset(12, 22),
        Size = UDim2.new(1, -24, 0, 16),
        BackgroundColor3 = COL.Bg,
        Text = "เลือก...",
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = COL.Sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        ClipsDescendants = true,
    }, row)
    round(display, 8)
    make("UIPadding", {PaddingLeft = UDim.new(0, 6)}, display)

    -- popup
    local popupOpen = false
    local popup
    local selected = {}

    local function refreshDisplay()
        local names = {}
        for k in pairs(selected) do table.insert(names, k) end
        display.Text = #names > 0 and table.concat(names, ", ") or "เลือก..."
        onSelect(names)
    end

    display.MouseButton1Click:Connect(function()
        if popup then popup:Destroy() popup = nil popupOpen = false return end
        popupOpen = true
        popup = make("Frame", {
            Position = UDim2.new(0, 0, 1, 2),
            Size = UDim2.new(1, 0, 0, math.min(#values * 24 + 8, 150)),
            BackgroundColor3 = COL.Side,
            ZIndex = 50,
            ClipsDescendants = true,
        }, row)
        round(popup, 10)
        glow(popup, 1)
        local scroll2 = make("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            CanvasSize = UDim2.new(0, 0, 0, #values * 24 + 4),
            BorderSizePixel = 0,
            ZIndex = 51,
        }, popup)
        for _, val in ipairs(values) do
            local item = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Text = (selected[val] and "✔ " or "   ") .. val,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextColor3 = selected[val] and COL.Pink or COL.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = 52,
            }, scroll2)
            make("UIPadding", {PaddingLeft = UDim.new(0, 8)}, item)
            item.MouseButton1Click:Connect(function()
                if selected[val] then selected[val] = nil
                else selected[val] = true end
                item.Text = (selected[val] and "✔ " or "   ") .. val
                item.TextColor3 = selected[val] and COL.Pink or COL.Text
                refreshDisplay()
            end)
        end
        make("UIListLayout", {Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder}, scroll2)
        -- เปลี่ยน size ของ row ให้รองรับ popup
        row.Size = UDim2.new(1, 0, 0, 44 + popup.AbsoluteSize.Y + 4)
    end)

    return refreshDisplay
end

-- ============================================================
-- SECTION 6: สร้าง Pages
-- ============================================================
local pages = NX.pages

-- เพิ่ม pages ใหม่ผ่าน NX (ถ้า NX expose addPage)
-- NexoraHub ตั้งต้นมีแค่ home กับ settings
-- เราต้องเพิ่ม pages เพิ่มเติมผ่าน menu

-- เข้าถึง menu ภายใน NX
local nxGui = NX.gui
local nxWin = nxGui:FindFirstChildOfClass("CanvasGroup") -- win
local nxSide -- หา side
for _, c in ipairs(nxWin:GetChildren()) do
    if c:IsA("Frame") and c.Size == UDim2.new(0, 130, 1, 0) then nxSide = c break end
    if c:IsA("Frame") and c.Name == "Side" then nxSide = c break end
end

-- ดึง content frame และ menu frame
local nxContent, nxMenu
for _, c in ipairs(nxWin:GetChildren()) do
    if c:IsA("Frame") then
        for _, cc in ipairs(c:GetChildren()) do
            if cc:IsA("ScrollingFrame") then nxMenu = cc break end
        end
    end
end
-- content คือ frame ที่ pages ถูก parent
local nxContentParent
for _, c in ipairs(nxWin:GetChildren()) do
    if c:IsA("Frame") and c ~= nxSide then
        for _, cc in ipairs(c:GetChildren()) do
            if cc:IsA("Frame") and not cc:IsA("ScrollingFrame") then
                nxContentParent = c break
            end
        end
        if nxContentParent then break end
    end
end
-- fallback: ดึงจาก NX.content
nxContent = NX.content

-- helper: เพิ่ม page ใหม่ใน NexoraHub
local function addBFEPage(icon, name)
    local menu = nxMenu
    local contentParent = nxContent

    -- button ใน sidebar
    local btn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, menu)
    round(btn, 16)
    local bg = make("UIGradient", {}, btn)
    NX.onAccent(function(a, b) bg.Color = ColorSequence.new(a, b) end)
    make("TextLabel", {
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.fromOffset(20, 32),
        BackgroundTransparency = 1,
        Text = icon,
        TextSize = 14,
    }, btn)
    make("TextLabel", {
        Position = UDim2.fromOffset(32, 0),
        Size = UDim2.new(1, -36, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = name,
    }, btn)

    -- page frame
    local page = make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
    }, contentParent)

    btn.MouseButton1Click:Connect(function()
        -- hide all
        for _, c in ipairs(contentParent:GetChildren()) do
            if c:IsA("Frame") then c.Visible = false end
        end
        for _, b in ipairs(menu:GetChildren()) do
            if b:IsA("TextButton") then
                TS:Create(b, TI, {BackgroundTransparency = 1}):Play()
            end
        end
        page.Visible = true
        TS:Create(btn, TI, {BackgroundTransparency = 0}):Play()
    end)

    pages[name] = page
    return page, btn
end

-- ===== PAGE: FARM =====
local farmPage, farmBtn = addBFEPage("🥚", "Farm")
local farmScroll = makePage(farmPage)
toggleOrder = 0

sectionLabel(farmScroll, "เลือกไข่", 1)
local farmEggList = MystrixHub.Functions.Farm_GetEggsList()
makeDropdown(farmScroll, "🥚 ไข่ที่ต้องการ", farmEggList, function(vals)
    local names = {}
    for _, v in ipairs(vals) do
        local n = v:match("^%[[^%]]+%]%s*(.+)$")
        if n then table.insert(names, n) end
    end
    MystrixHub.FarmController.SpecificEggNames = names
end)

local rarList = MystrixHub.Functions.Farm_GetRaritiesList()
makeDropdown(farmScroll, "💎 ความหายาก (Rarity)", rarList, function(vals)
    MystrixHub.FarmController.SelectedRarities = vals
end)

local areaList = MystrixHub.Functions.Farm_GetAreasList()
makeDropdown(farmScroll, "🗺️ พื้นที่ (Area)", areaList, function(vals)
    MystrixHub.FarmController.SelectedAreas = vals
end)

sectionLabel(farmScroll, "ควบคุม", 10)
makeToggle(farmScroll, "🤖 Auto Farm", "ขโมยไข่อัตโนมัติ", function(v)
    local FC = MystrixHub.FarmController
    if v then
        if #FC.SpecificEggNames == 0 and #FC.SelectedRarities == 0 and #FC.SelectedAreas == 0 then
            Notify({Title = "Farm", Content = "เลือกตัวกรองอย่างน้อย 1 อย่างก่อน!", Duration = 3, Icon = "circle-alert"})
            return
        end
        MystrixHub.Functions.StartAutoFarm()
    else
        MystrixHub.Functions.StopAutoFarm()
    end
end)

-- ===== PAGE: SELL =====
local sellPage = addBFEPage("💰", "Sell")
local sellScroll = makePage(sellPage)
toggleOrder = 0

sectionLabel(sellScroll, "ไข่ (Eggs)", 1)
local eggCatList = MystrixHub.Functions.Sell_GetAllEggCategories()
makeDropdown(sellScroll, "🥚 เลือกหมวดไข่", eggCatList, function(vals)
    local cats = {}
    for _, v in ipairs(vals) do
        local n = v:match("^%[[^%]]+%]%s*(.+)$") or v
        table.insert(cats, n)
    end
    MystrixHub.SellController.SelectedEggCategories = cats
end)

makeToggle(sellScroll, "🤖 Auto Sell Eggs", "ขายไข่อัตโนมัติ", function(v)
    if v then
        if #MystrixHub.SellController.SelectedEggCategories == 0 then
            Notify({Title = "Sell", Content = "เลือกหมวดไข่ก่อน!", Duration = 3, Icon = "circle-alert"})
            return
        end
        MystrixHub.Functions.Sell_StartAutoEggs()
    else
        MystrixHub.Functions.Sell_StopAutoEggs()
    end
end)

makeButton(sellScroll, "ขายไข่ทันที", "ขายไข่ที่เลือกทั้งหมด", "ขาย", function()
    task.spawn(function()
        local n = MystrixHub.Functions.Sell_AllEggs()
        if n > 0 then
            Notify({Title = "Sell", Content = "ขายไข่ไป " .. n .. " ใบ", Duration = 3, Icon = "circle-check"})
        else
            Notify({Title = "Sell", Content = "ไม่มีไข่ที่จะขาย", Duration = 3, Icon = "circle-alert"})
        end
    end)
end)

sectionLabel(sellScroll, "สัตว์เลี้ยง (Pets)", 20)
local petCatList = MystrixHub.Functions.Sell_GetAllPetCategories()
makeDropdown(sellScroll, "🐾 เลือกหมวด Pet", petCatList, function(vals)
    local cats = {}
    for _, v in ipairs(vals) do
        local n = v:match("^%[[^%]]+%]%s*(.+)$") or v
        table.insert(cats, n)
    end
    MystrixHub.SellController.SelectedPetCategories = cats
end)

makeToggle(sellScroll, "🤖 Auto Sell Pets", "ขาย Pet อัตโนมัติ", function(v)
    if v then
        if #MystrixHub.SellController.SelectedPetCategories == 0 then
            Notify({Title = "Sell", Content = "เลือกหมวด Pet ก่อน!", Duration = 3, Icon = "circle-alert"})
            return
        end
        MystrixHub.Functions.Sell_StartAutoPets()
    else
        MystrixHub.Functions.Sell_StopAutoPets()
    end
end)

makeButton(sellScroll, "ขาย Pet ทันที", "ขาย Pet ที่เลือกทั้งหมด", "ขาย", function()
    task.spawn(function()
        local n = MystrixHub.Functions.Sell_AllPets()
        if n > 0 then
            Notify({Title = "Sell", Content = "ขาย Pet ไป " .. n .. " ตัว", Duration = 3, Icon = "circle-check"})
        else
            Notify({Title = "Sell", Content = "ไม่มี Pet ที่จะขาย", Duration = 3, Icon = "circle-alert"})
        end
    end)
end)

-- ===== PAGE: SHOP =====
local shopPage = addBFEPage("🛒", "Shop")
local shopScroll = makePage(shopPage)
toggleOrder = 0

sectionLabel(shopScroll, "ซื้อ (Buy)", 1)
makeToggle(shopScroll, "🛤️ Auto Buy Best Trail", "ซื้อ Trail ที่เร็วที่สุดอัตโนมัติ", function(v)
    if v then MystrixHub.Functions.Shop_StartAutoTrail()
    else MystrixHub.Functions.Shop_StopAutoTrail() end
end)

makeToggle(shopScroll, "🚲 Auto Buy Best Bike", "ซื้อจักรยานที่เร็วที่สุดอัตโนมัติ", function(v)
    if v then MystrixHub.Functions.Shop_StartAutoBike()
    else MystrixHub.Functions.Shop_StopAutoBike() end
end)

sectionLabel(shopScroll, "อัปเกรด (Upgrade)", 10)
makeToggle(shopScroll, "🏃 Auto Upgrade Treadmill", "อัปเกรดลู่วิ่งอัตโนมัติ", function(v)
    if v then MystrixHub.Functions.Shop_StartAutoTreadmill()
    else MystrixHub.Functions.Shop_StopAutoTreadmill() end
end)

makeToggle(shopScroll, "🗺️ Auto Upgrade Plot", "อัปเกรดแปลงอัตโนมัติ", function(v)
    if v then MystrixHub.Functions.Shop_StartAutoPlot()
    else MystrixHub.Functions.Shop_StopAutoPlot() end
end)

-- ===== PAGE: PLOT =====
local plotPage = addBFEPage("🗺️", "Plot")
local plotScroll = makePage(plotPage)
toggleOrder = 0

sectionLabel(plotScroll, "ฟัก (Hatch)", 1)
local hatchEggList = MystrixHub.Functions.Plot_GetEggsList()
makeDropdown(plotScroll, "🥚 ไข่ที่จะฟัก", hatchEggList, function(vals)
    MystrixHub.PlotController.HatchSelectedEggs = #vals > 0 and vals or {"All"}
end)

makeToggle(plotScroll, "🤖 Auto Hatch", "ฟักไข่อัตโนมัติ", function(v)
    if v then MystrixHub.Functions.Plot_StartAutoHatch()
    else MystrixHub.Functions.Plot_StopAutoHatch() end
end)

makeButton(plotScroll, "ฟักทันที", "ฟักไข่ที่พร้อมทั้งหมด", "ฟัก", function()
    task.spawn(function()
        local count = 0
        for _ = 1, 20 do
            local ok, res = pcall(MystrixHub.Functions.Plot_RunHatchOnce)
            if ok and res then count += 1 task.wait(0.6)
            else break end
        end
        if count > 0 then
            Notify({Title = "Hatch", Content = "ฟักไปแล้ว " .. count .. " ใบ", Duration = 3, Icon = "circle-check"})
        else
            Notify({Title = "Hatch", Content = "ไม่มีไข่ที่พร้อมฟัก", Duration = 3, Icon = "circle-alert"})
        end
    end)
end)

sectionLabel(plotScroll, "วาง (Place)", 20)
local placeEggList = MystrixHub.Functions.Plot_GetEggsListForPlace()
makeDropdown(plotScroll, "🥚 ไข่ที่จะวาง", placeEggList, function(vals)
    MystrixHub.PlotController.PlaceSelectedEggs = #vals > 0 and vals or {"Best"}
end)

makeToggle(plotScroll, "🤖 Auto Place", "วางไข่ในแปลงอัตโนมัติ", function(v)
    if v then MystrixHub.Functions.Plot_StartAutoPlace()
    else MystrixHub.Functions.Plot_StopAutoPlace() end
end)

makeButton(plotScroll, "วางทันที", "วางไข่ในช่องว่างที่มี", "วาง", function()
    task.spawn(function()
        local count, lastErr = 0, ""
        for _ = 1, 10 do
            local ok, res, reason = pcall(MystrixHub.Functions.Plot_RunPlaceOnce)
            if not ok then lastErr = tostring(res) break end
            if res then count += 1 task.wait(1.2)
            else lastErr = tostring(reason or "unknown") break end
        end
        if count > 0 then
            Notify({Title = "Place", Content = "วางไข่ไปแล้ว " .. count .. " ใบ", Duration = 3, Icon = "circle-check"})
        else
            Notify({Title = "Place Failed", Content = lastErr, Duration = 5, Icon = "circle-alert"})
        end
    end)
end)

sectionLabel(plotScroll, "อื่นๆ", 30)
makeToggle(plotScroll, "🏃 Auto Treadmill", "วิ่งลู่วิ่งอัตโนมัติ", function(v)
    if v then MystrixHub.Functions.Plot_StartAutoTreadmill()
    else MystrixHub.Functions.Plot_StopAutoTreadmill() end
end)

makeToggle(plotScroll, "📦 Auto Claim", "เก็บไข่จากแปลงอัตโนมัติ", function(v)
    if v then MystrixHub.Functions.Plot_StartAutoClaim()
    else MystrixHub.Functions.Plot_StopAutoClaim() end
end)

-- ===== เลือก page แรก =====
-- NexoraHub เริ่มที่ home อยู่แล้ว ไม่ต้องทำอะไรเพิ่ม

Notify({
    Title = "BIKE FOR EGG",
    Content = "โหลดสำเร็จ! NexoraHub GUI พร้อมใช้งาน",
    Duration = 4,
    Icon = "circle-check",
})
