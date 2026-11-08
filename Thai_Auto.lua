--[[
╔══════════════════════════════════════════════════════╗
║          NEXORA HUB v2 — Thai Quiz AUTO              ║
║  Game: การแข่งขันตอบคำถามภาษาไทย (121878558222387)  ║
║  หมวดหมู่: AUTO / BUY / EVENT / RANK                 ║
╚══════════════════════════════════════════════════════╝

แท็บ:
  ⚡ AUTO  — นั่งอัตโนมัติ, ตอบอักษรอัตโนมัติ, Auto-Play
  ♢  BUY   — ซื้อของในเกมอัตโนมัติ / Auto-Upgrade
  ✦ EVENT  — ระบบ Event อัตโนมัติ
  ♛ RANK   — Farm แรงค์ / Auto-Rank Loop
  ⚙ MISC  — ฟังก์ชันเสริม / โกง

Remote ที่ใช้ (จาก ReplicatedStorage.Remotes):
  Request  [RemoteFunction] — ส่ง action/request
  Match    [RemoteEvent]    — รับ/ส่ง match state
  MatchInput [RemoteEvent]  — ส่งคำตอบ keyboard
  Solo     [RemoteEvent]    — Solo mode
  Purchase [RemoteEvent]    — ซื้อของ
  Tables   [RemoteEvent]    — table/seat update
  Toast    [RemoteEvent]    — notification
]]

-- ════════════════════════════════════════════════
--  CORE SETUP
-- ════════════════════════════════════════════════
local Players        = game:GetService("Players")
local RS             = game:GetService("ReplicatedStorage")
local RunService     = game:GetService("RunService")
local TS             = game:GetService("TweenService")
local UIS            = game:GetService("UserInputService")
local lp             = Players.LocalPlayer
local char           = lp.Character or lp.CharacterAdded:Wait()
local Remotes        = RS:WaitForChild("Remotes", 10)

-- Remote handles
local rRequest   = Remotes and Remotes:FindFirstChild("Request")
local rMatch     = Remotes and Remotes:FindFirstChild("Match")
local rMatchInput= Remotes and Remotes:FindFirstChild("MatchInput")
local rSolo      = Remotes and Remotes:FindFirstChild("Solo")
local rPurchase  = Remotes and Remotes:FindFirstChild("Purchase")
local rTables    = Remotes and Remotes:FindFirstChild("Tables")

-- ════════════════════════════════════════════════
--  STATE
-- ════════════════════════════════════════════════
local STATE = {
    -- AUTO
    autoSit          = false,
    autoType         = false,
    autoPlay         = false,
    autoReveal       = false,
    autoSkipWrong    = false,
    answerDelay      = 0.3,
    preferTable      = 2,

    -- BUY
    autoBuyChair     = false,
    autoBuyOffers    = false,
    buyTargetChair   = "bow",
    coinThreshold    = 100,

    -- EVENT
    autoEvent        = false,
    eventType        = "none",

    -- RANK
    autoRank         = false,
    autoRankJoinAny  = false,
    rankTableTarget  = 2,

    -- STATUS
    currentMatchData = nil,
    currentQuestion  = nil,
    seatedAt         = nil,
    running          = true,
}

-- ════════════════════════════════════════════════
--  UTILITY
-- ════════════════════════════════════════════════
local function safeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[Thai-Auto] " .. tostring(err)) end
end

local function getLeaderstat(name)
    local ls = lp:FindFirstChild("leaderstats")
    if ls then
        local v = ls:FindFirstChild(name)
        return v and v.Value or 0
    end
    return 0
end

local function getCoins()   return getLeaderstat("เหรียญ") end
local function getLevel()   return getLeaderstat("เลเวล") end

local function wait(t) task.wait(t or 0.1) end

local function getTables()
    local list = {}
    local folder = workspace:FindFirstChild("Tables")
    if folder then
        for _, m in ipairs(folder:GetChildren()) do
            if m:IsA("Model") then
                list[#list+1] = m
            end
        end
    end
    return list
end

local function getEmptySeat(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("Seat") and not v:FindFirstChildOfClass("Weld") then
            return v
        end
    end
end

local function sitDown(seat)
    safeCall(function()
        local chr = lp.Character
        if chr then
            local hum = chr:FindFirstChildOfClass("Humanoid")
            if hum then seat:Sit(hum) end
        end
    end)
end

-- ════════════════════════════════════════════════
--  MATCH STATE
-- ════════════════════════════════════════════════
local matchPhase   = "idle"
local questionText = ""
local stripData    = {}

if rMatch then
    rMatch.OnClientEvent:Connect(function(data)
        safeCall(function()
            if type(data) ~= "table" then return end
            if data.phase    then matchPhase   = data.phase end
            if data.question then questionText = tostring(data.question) end
            if data.strip    then stripData    = data.strip end
            STATE.currentMatchData = data
        end)
    end)
end

-- ════════════════════════════════════════════════
--  AUTO — นั่งโต๊ะอัตโนมัติ
-- ════════════════════════════════════════════════
local function tryAutoSit()
    if not STATE.autoSit then return end
    if STATE.seatedAt then return end

    local chr = lp.Character
    if not chr then return end
    local hum = chr:FindFirstChildOfClass("Humanoid")
    if not hum or hum.SeatPart then return end

    local tables = getTables()
    local best = nil

    -- หาโต๊ะตามขนาดที่ต้องการก่อน
    if STATE.preferTable > 0 then
        for _, t in ipairs(tables) do
            local seats = t:GetAttribute("Seats") or 0
            if seats == STATE.preferTable then
                local empty = getEmptySeat(t)
                if empty then best = empty break end
            end
        end
    end

    -- fallback: โต๊ะอะไรก็ได้
    if not best then
        for _, t in ipairs(tables) do
            local empty = getEmptySeat(t)
            if empty then best = empty break end
        end
    end

    if best then
        STATE.seatedAt = best
        sitDown(best)
    end
end

RunService.Heartbeat:Connect(function()
    if not STATE.running then return end
    local chr = lp.Character
    if chr then
        local hum = chr:FindFirstChildOfClass("Humanoid")
        if hum and not hum.SeatPart then
            STATE.seatedAt = nil
        end
    end
end)

-- ════════════════════════════════════════════════
--  AUTO — ตอบคำถาม / พิมพ์อักษร
-- ════════════════════════════════════════════════
local function getMatchUI()
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local kh = pg:FindFirstChild("KHRush")
    if not kh then return nil end
    return kh:FindFirstChild("Match")
end

local function getTypeBox()
    local match = getMatchUI()
    if not match then return end
    return match:FindFirstChildWhichIsA("TextBox", true)
end

local function getKeyboard()
    local match = getMatchUI()
    if not match then return end
    return match:FindFirstChild("ThaiKeyboard", true)
end

-- กดปุ่มตัวอักษรบน keyboard
local function typeCharacter(c)
    local kb = getKeyboard()
    if not kb then return false end
    for _, row_ in ipairs(kb:GetChildren()) do
        if row_:IsA("Frame") then
            for _, btn in ipairs(row_:GetChildren()) do
                if btn:IsA("TextButton") then
                    local body  = btn:FindFirstChild("Body")
                    local inner = body and body:FindFirstChild("Inner")
                    local face  = inner and inner:FindFirstChild("Face")
                    local lbl   = face and face:FindFirstChild("Label")
                    if lbl and lbl.Text == c then
                        safeCall(function() btn.MouseButton1Click:Fire() end)
                        safeCall(function()
                            local vp = game:GetService("VirtualInputManager")
                            local px = btn.AbsolutePosition.X + 5
                            local py = btn.AbsolutePosition.Y + 5
                            vp:SendMouseButtonEvent(px, py, 0, true,  game, 0)
                            task.wait(0.02)
                            vp:SendMouseButtonEvent(px, py, 0, false, game, 0)
                        end)
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ส่งคำตอบผ่าน MatchInput remote โดยตรง
local function submitAnswerDirect(answer)
    if rMatchInput then
        safeCall(function() rMatchInput:FireServer(answer) end)
    end
end

-- ส่งผ่าน TypeBox
local function submitAnswerUI(answer)
    local tb = getTypeBox()
    if tb then tb.Text = answer end
end

-- Auto-type ทีละตัว
local function autoTypeAnswer(answer)
    if not STATE.autoType then return end
    for i = 1, #answer do
        typeCharacter(answer:sub(i, i))
        wait(0.08)
    end
end

-- ════════════════════════════════════════════════
--  AUTO — กด Reveal / Action / Submit
-- ════════════════════════════════════════════════
local function clickRevealButton()
    local match = getMatchUI()
    if not match then return end
    local rb = match:FindFirstChild("RevealButton", true)
    if rb and rb:IsA("TextButton") then
        safeCall(function() rb.MouseButton1Click:Fire() end)
    end
end

local function clickSubmitButton()
    local match = getMatchUI()
    if not match then return end
    local bottom = match:FindFirstChild("Bottom", true)
    if not bottom then return end
    local action = bottom:FindFirstChild("Action", true)
    if action and action:IsA("TextButton") then
        local kind = action:GetAttribute("Kind")
        if kind ~= "disabled" then
            safeCall(function() action.MouseButton1Click:Fire() end)
        end
    end
end

-- ════════════════════════════════════════════════
--  AUTO — อ่านตัวอักษรจาก Reel Strip
-- ════════════════════════════════════════════════
local function getStripLetters()
    local match = getMatchUI()
    if not match then return {} end
    local strip = match:FindFirstChild("Strip", true)
    if not strip then return {} end
    local letters = {}
    for _, child in ipairs(strip:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            local text = child:FindFirstChildWhichIsA("TextLabel")
            if text and text.Text ~= "" then
                letters[#letters+1] = text.Text
            end
        end
    end
    return letters
end

-- ════════════════════════════════════════════════
--  AUTO PLAY LOOP
-- ════════════════════════════════════════════════
local lastQuestion = ""
local function autoPlayLoop()
    while STATE.running and STATE.autoPlay do
        wait(0.5)
        local match = getMatchUI()
        if not match or not match.Visible then
            wait(1)
            goto continue
        end

        local letters = getStripLetters()

        if STATE.autoReveal then
            wait(STATE.answerDelay)
            clickRevealButton()
            wait(0.5)
        end

        if #letters > 0 then
            local answer = table.concat(letters, "")
            if answer ~= lastQuestion then
                lastQuestion = answer
                wait(STATE.answerDelay)
                submitAnswerDirect(answer)
            end
        end

        clickSubmitButton()
        ::continue::
    end
end

-- ════════════════════════════════════════════════
--  BUY
-- ════════════════════════════════════════════════
local function tryAutoBuy()
    if not (STATE.autoBuyChair or STATE.autoBuyOffers) then return end
    if getCoins() < STATE.coinThreshold then return end

    local function triggerPrompt(shop, remoteAction)
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v:GetAttribute("Shop") == shop then
                safeCall(function()
                    if rPurchase then rPurchase:FireServer(remoteAction) end
                    v:InputHoldBegin()
                    task.wait(0.5)
                    v:InputHoldEnd()
                end)
                return
            end
        end
    end

    if STATE.autoBuyChair  then triggerPrompt("chairs", "chair_" .. STATE.buyTargetChair) end
    if STATE.autoBuyOffers then triggerPrompt("offers", "offer_best") end
end

-- ════════════════════════════════════════════════
--  EVENT
-- ════════════════════════════════════════════════
local function tryAutoEvent()
    if not STATE.autoEvent then return end

    if STATE.eventType == "ranked" then
        local pg = lp:FindFirstChild("PlayerGui")
        if pg then
            local kh = pg:FindFirstChild("KHRush")
            local hud = kh and kh:FindFirstChild("Hud")
            local rb  = hud and hud:FindFirstChild("RankedButton", true)
            if rb and rb:IsA("TextButton") then
                safeCall(function() rb.MouseButton1Click:Fire() end)
            end
        end

    elseif STATE.eventType == "solo" then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Part") and v.Name == "SoloDesk" then
                local pp = v:FindFirstChildOfClass("ProximityPrompt")
                if pp then
                    safeCall(function()
                        if rSolo then rSolo:FireServer("join") end
                        pp:InputHoldBegin()
                        task.wait(0.5)
                        pp:InputHoldEnd()
                    end)
                end
            end
        end
    end
end

-- ════════════════════════════════════════════════
--  RANK LOOP
-- ════════════════════════════════════════════════
local function autoRankLoop()
    while STATE.running and STATE.autoRank do
        wait(1)
        if not STATE.seatedAt then
            STATE.autoSit = true
            STATE.preferTable = STATE.rankTableTarget
            tryAutoSit()
            wait(2)
        end
        if STATE.seatedAt then
            STATE.autoPlay   = true
            STATE.autoReveal = true
        end
        wait(2)
    end
end

-- ════════════════════════════════════════════════
--  MISC / CHEAT
-- ════════════════════════════════════════════════
local function setSpeed(speed)
    local chr = lp.Character
    if chr then
        local hum = chr:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = speed end
    end
end

local afkConn
local function setAntiAFK(enabled)
    if afkConn then afkConn:Disconnect() afkConn = nil end
    if enabled then
        local VU = game:GetService("VirtualUser")
        afkConn = lp.Idled:Connect(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end

local function tryCoinFarm()
    if not rRequest then return end
    safeCall(function() rRequest:InvokeServer("reward", "daily") end)
    safeCall(function() rRequest:InvokeServer("reward", "streak") end)
end

local function autoClickTile(tileIndex)
    local pg  = lp:FindFirstChild("PlayerGui")
    local kh  = pg and pg:FindFirstChild("KHRush")
    local hud = kh and kh:FindFirstChild("Hud")
    local tiles = hud and hud:FindFirstChild("Tiles")
    if not tiles then return end
    local btns = {}
    for _, v in ipairs(tiles:GetChildren()) do
        if v:IsA("TextButton") then btns[#btns+1] = v end
    end
    local target = btns[tileIndex]
    if target then safeCall(function() target.MouseButton1Click:Fire() end) end
end

local function speedAnswerFirst()
    autoClickTile(1)
    clickSubmitButton()
end

-- ════════════════════════════════════════════════
--  MAIN LOOPS
-- ════════════════════════════════════════════════
task.spawn(function()
    while STATE.running do
        wait(0.5)
        safeCall(tryAutoSit)
        safeCall(tryAutoBuy)
        safeCall(tryAutoEvent)
    end
end)

task.spawn(function()
    while STATE.running do
        wait(0.3)
        if STATE.autoPlay then
            safeCall(function()
                local match = getMatchUI()
                if match and match.Visible then
                    local letters = getStripLetters()
                    if #letters > 0 then
                        submitAnswerDirect(table.concat(letters,""))
                    end
                    if STATE.autoReveal then clickRevealButton() end
                    clickSubmitButton()
                end
            end)
        end
    end
end)

task.spawn(function()
    while STATE.running do
        wait(1)
        if STATE.autoRank then safeCall(autoRankLoop) end
    end
end)

-- ════════════════════════════════════════════════
--  NEXORA HUB GUI INTEGRATION
-- ════════════════════════════════════════════════
task.spawn(function()
    local t = 0
    while not getgenv().NX and t < 15 do
        wait(0.5); t += 0.5
    end

    local NX = getgenv().NX
    if not NX then
        warn("[Thai-Auto] ไม่พบ NEXORA HUB — รัน GUI.lua ก่อน")
        return
    end

    local COL  = NX.COL
    local make = NX.make
    local round= NX.round
    local L    = NX.L
    local pages= NX.pages

    local TI = TweenInfo.new(0.2, Enum.EasingStyle.Quint)

    -- ── หา menu container ──
    local menuFrame
    for _, v in ipairs(NX.side:GetChildren()) do
        if v:IsA("Frame") and v:FindFirstChildOfClass("UIListLayout") then
            menuFrame = v; break
        end
    end
    if not menuFrame then menuFrame = NX.side end

    -- ── Page factory ──
    local pageOrd = {v=30}
    local function addPage(name, icon, en, th)
        pageOrd.v += 1
        local b = make("TextButton", {
            LayoutOrder = pageOrd.v,
            Size = UDim2.new(1,0,0,32),
            BackgroundColor3 = Color3.new(1,1,1),
            BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false
        }, menuFrame)
        round(b, 16)
        local g = make("UIGradient", {}, b)
        NX.onAccent(function(a, c2) g.Color = ColorSequence.new(a, c2) end)
        make("TextLabel", {Position=UDim2.fromOffset(8,0), Size=UDim2.fromOffset(20,32),
            BackgroundTransparency=1, Text=icon, TextSize=14}, b)
        L(make("TextLabel", {Position=UDim2.fromOffset(32,0), Size=UDim2.new(1,-36,1,0),
            BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=12,
            TextColor3=Color3.new(1,1,1), TextXAlignment=Enum.TextXAlignment.Left}, b), en, th)

        local p = make("Frame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Visible=false}, NX.content)
        pages[name] = p

        b.MouseButton1Click:Connect(function()
            for n, pg in pairs(pages) do
                pg.Visible = (n == name)
            end
            for _, bb in ipairs(menuFrame:GetChildren()) do
                if bb:IsA("TextButton") then
                    TS:Create(bb, TI, {BackgroundTransparency=(bb==b and 0 or 1)}):Play()
                end
            end
        end)
        return p
    end

    -- ── Scroll wrapper ──
    local function makeScroll(parent)
        local sf = make("ScrollingFrame", {
            Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
            BorderSizePixel=0, ScrollBarThickness=2,
            ScrollBarImageColor3=COL.Pink,
            AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new()
        }, parent)
        make("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, sf)
        make("UIPadding", {PaddingRight=UDim.new(0,6), PaddingBottom=UDim.new(0,8)}, sf)
        return sf
    end

    -- ── UI helpers ──
    local rowOrd = {v=0}

    local function row(sf, h)
        rowOrd.v += 1
        local r = make("Frame", {LayoutOrder=rowOrd.v, Size=UDim2.new(1,0,0,h),
            BackgroundColor3=COL.Chip, BackgroundTransparency=0.4}, sf)
        round(r, 14)
        local s = make("UIStroke", {Color=COL.Pink, Transparency=0.65, Thickness=1}, r)
        NX.onAccent(function(_, b) s.Color = b end)
        return r
    end

    local function txt(p, props)
        props.BackgroundTransparency = 1
        props.Font = props.Font or Enum.Font.GothamBold
        props.TextColor3 = props.TextColor3 or COL.Text
        props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
        return make("TextLabel", props, p)
    end

    local function header(sf, en, th)
        rowOrd.v += 1
        local l = txt(sf, {LayoutOrder=rowOrd.v, Size=UDim2.new(1,0,0,22),
            Font=Enum.Font.GothamBlack, TextSize=17, TextColor3=Color3.new(1,1,1)})
        local g = make("UIGradient",{},l)
        NX.onAccent(function(a,b) g.Color = ColorSequence.new(a,b) end)
        L(l, en, th)
    end

    local function toggle(sf, key, en, th, dEn, dTh, cb)
        local r = row(sf, 42)
        L(txt(r,{Position=UDim2.fromOffset(14,6), Size=UDim2.new(1,-80,0,16), TextSize=12}), en, th)
        if dEn then
            L(txt(r,{Position=UDim2.fromOffset(14,22), Size=UDim2.new(1,-80,0,14),
                Font=Enum.Font.Gotham, TextSize=9, TextColor3=COL.Sub}), dEn, dTh)
        end
        local sw = make("TextButton", {Text="", AutoButtonColor=false,
            Size=UDim2.fromOffset(38,20), Position=UDim2.new(1,-52,.5,-10),
            BackgroundColor3=COL.Bg}, r)
        round(sw, 10)
        local knob = make("Frame", {Size=UDim2.fromOffset(14,14),
            Position=UDim2.fromOffset(3,3), BackgroundColor3=Color3.new(1,1,1)}, sw)
        round(knob, 7)
        local function set(v)
            STATE[key] = v
            TS:Create(sw, TI, {BackgroundColor3 = v and COL.Purple or COL.Bg}):Play()
            TS:Create(knob, TI, {Position = v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)}):Play()
            if cb then pcall(cb, v) end
        end
        sw.MouseButton1Click:Connect(function() set(not STATE[key]) end)
        set(STATE[key])
        NX.onAccent(function() sw.BackgroundColor3 = STATE[key] and COL.Purple or COL.Bg end)
    end

    local function button(sf, en, th, dEn, dTh, bEn, bTh, cb)
        local r = row(sf, 42)
        L(txt(r,{Position=UDim2.fromOffset(14,6), Size=UDim2.new(1,-110,0,16), TextSize=12}), en, th)
        local d = txt(r,{Position=UDim2.fromOffset(14,22), Size=UDim2.new(1,-110,0,14),
            Font=Enum.Font.Gotham, TextSize=9, TextColor3=COL.Sub,
            TextTruncate=Enum.TextTruncate.AtEnd})
        L(d, dEn, dTh)
        local btn = make("TextButton", {AnchorPoint=Vector2.new(1,.5),
            Position=UDim2.new(1,-10,.5,0), Size=UDim2.fromOffset(84,26),
            BackgroundColor3=COL.Purple, Text="", AutoButtonColor=false}, r)
        round(btn, 13)
        NX.onAccent(function(a) btn.BackgroundColor3 = a end)
        L(txt(btn,{Size=UDim2.fromScale(1,1), TextSize=10, TextColor3=Color3.new(1,1,1),
            TextXAlignment=Enum.TextXAlignment.Center}), bEn, bTh)
        btn.MouseButton1Click:Connect(function() pcall(cb, d) end)
        return d
    end

    local function segmented(sf, opts, stateKey, cb)
        local r = row(sf, 32)
        local h = make("Frame",{Position=UDim2.fromOffset(6,4), Size=UDim2.new(1,-12,0,24),
            BackgroundTransparency=1}, r)
        make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,4)}, h)
        local btns = {}
        local function mark()
            for k, b in pairs(btns) do
                TS:Create(b, TI, {BackgroundColor3=(k==STATE[stateKey]) and COL.Purple or COL.Bg}):Play()
            end
        end
        for _, o in ipairs(opts) do
            local b = make("TextButton", {Size=UDim2.new(1/#opts,-4,1,0),
                BackgroundColor3=COL.Bg, Text=o[2], Font=Enum.Font.GothamBold,
                TextSize=10, TextColor3=COL.Text, AutoButtonColor=false}, h)
            round(b, 11)
            btns[o[1]] = b
            b.MouseButton1Click:Connect(function()
                STATE[stateKey] = o[1]; mark()
                if cb then pcall(cb, o[1]) end
            end)
        end
        NX.onAccent(mark); mark()
        return btns
    end

    -- ════════════════════════════════════════════
    --  Section header ใน side menu
    -- ════════════════════════════════════════════
    pageOrd.v += 1
    local secLbl = make("TextLabel", {
        LayoutOrder = pageOrd.v,
        Size = UDim2.new(1,0,0,14),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = COL.Pink,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "THAI QUIZ"
    }, menuFrame)
    NX.onAccent(function(_, b) secLbl.TextColor3 = b end)

    -- ════════════════════════════════════════════
    --  PAGE ⚡ AUTO
    -- ════════════════════════════════════════════
    rowOrd.v = 0
    local pAuto = addPage("auto", "⚡", "AUTO", "ออโต้")
    local sfAuto = makeScroll(pAuto)

    header(sfAuto, "⚡ AUTO SYSTEM", "⚡ ระบบออโต้")

    -- stats live
    local statR = row(sfAuto, 36)
    local statL = txt(statR,{Position=UDim2.fromOffset(10,8), Size=UDim2.new(1,-20,0,20),
        TextSize=10, TextColor3=COL.Pink, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Center})
    statL.Text = "🪙 -- เหรียญ  |  ⭐ เลเวล --"
    task.spawn(function()
        while pAuto.Parent do
            statL.Text = string.format("🪙 %d เหรียญ  |  ⭐ เลเวล %d", getCoins(), getLevel())
            wait(1)
        end
    end)

    toggle(sfAuto, "autoSit", "🪑 Auto Sit", "🪑 นั่งอัตโนมัติ",
        "เข้าไปนั่งโต๊ะโดยอัตโนมัติ", "หาโต๊ะและนั่งอัตโนมัติ", nil)

    toggle(sfAuto, "autoType", "⌨ Auto Type", "⌨ พิมพ์อัตโนมัติ",
        "พิมพ์ตัวอักษรบน keyboard", "พิมพ์อักษรไทยอัตโนมัติ", nil)

    toggle(sfAuto, "autoPlay", "▶ Auto Play", "▶ เล่นอัตโนมัติ",
        "เล่นเกมและตอบคำถามอัตโนมัติ", "ตอบคำถามอัตโนมัติ",
        function(v) if v then task.spawn(autoPlayLoop) end end)

    toggle(sfAuto, "autoReveal", "🔍 Auto Reveal", "🔍 ใบ้อัตโนมัติ",
        "กดปุ่ม Reveal อัตโนมัติ", "ใช้ใบ้ทันที", nil)

    -- เลือกขนาดโต๊ะ
    local sizeR = row(sfAuto, 56)
    L(txt(sizeR,{Position=UDim2.fromOffset(14,6), Size=UDim2.new(1,-20,0,16), TextSize=12}),
        "Table Seat Count", "ขนาดโต๊ะที่ต้องการ")
    local szH = make("Frame",{Position=UDim2.fromOffset(14,26), Size=UDim2.new(1,-28,0,24),
        BackgroundTransparency=1}, sizeR)
    make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5)}, szH)
    local szBtns = {}
    for _, sz in ipairs({2,3,4,5}) do
        local sb = make("TextButton",{Size=UDim2.new(.25,-4,1,0), BackgroundColor3=COL.Bg,
            Text=sz.." ที่", Font=Enum.Font.GothamBold, TextSize=10, TextColor3=COL.Text,
            AutoButtonColor=false}, szH)
        round(sb, 11)
        szBtns[sz] = sb
        sb.MouseButton1Click:Connect(function()
            STATE.preferTable = sz
            for k, b in pairs(szBtns) do
                TS:Create(b, TI, {BackgroundColor3=(k==sz) and COL.Purple or COL.Bg}):Play()
            end
        end)
    end
    if szBtns[2] then TS:Create(szBtns[2], TI, {BackgroundColor3=COL.Purple}):Play() end
    NX.onAccent(function()
        for k, b in pairs(szBtns) do
            b.BackgroundColor3 = (k==STATE.preferTable) and COL.Purple or COL.Bg
        end
    end)

    button(sfAuto, "🏃 นั่งโต๊ะเดี๋ยวนี้", "🏃 นั่งทันที",
        "บังคับนั่งโต๊ะทันที", "บังคับนั่งทันที", "GO", "ไป",
        function()
            STATE.autoSit = true
            tryAutoSit()
        end)

    button(sfAuto, "⚡ ตอบทันที (tile 1)", "⚡ ตอบ tile แรก",
        "กดคำตอบแรกและ submit", "กดตอบอัตโนมัติ", "ตอบ", "ตอบ",
        function(d)
            speedAnswerFirst()
            d.Text = "✔ ส่งแล้ว"
            task.delay(1, function() d.Text = "กดตอบอัตโนมัติ" end)
        end)

    button(sfAuto, "🪄 ส่งคำตอบ (Remote)", "🪄 ส่งผ่าน Remote",
        "ส่งคำตอบผ่าน MatchInput โดยตรง", "bypass UI ส่งคำตอบ", "ส่ง", "ส่ง",
        function(d)
            local letters = getStripLetters()
            if #letters > 0 then
                local ans = table.concat(letters,"")
                submitAnswerDirect(ans)
                d.Text = "✔ ส่ง: " .. ans
            else
                d.Text = "❌ ไม่พบตัวอักษร"
            end
            task.delay(2, function() d.Text = "bypass UI ส่งคำตอบ" end)
        end)

    button(sfAuto, "⏹ ปิดออโต้ทั้งหมด", "⏹ ปิดทั้งหมด",
        "ปิด autoSit / autoPlay / autoReveal", "ปิด loop ทั้งหมด", "ปิด", "ปิด",
        function(d)
            STATE.autoSit    = false
            STATE.autoPlay   = false
            STATE.autoReveal = false
            STATE.autoType   = false
            d.Text = "✔ ปิดแล้ว"
            task.delay(2, function() d.Text = "ปิด loop ทั้งหมด" end)
        end)

    -- ════════════════════════════════════════════
    --  PAGE ♢ BUY
    -- ════════════════════════════════════════════
    rowOrd.v = 0
    local pBuy = addPage("buy", "♢", "BUY", "ซื้อ")
    local sfBuy = makeScroll(pBuy)

    header(sfBuy, "♢ AUTO BUY", "♢ ซื้ออัตโนมัติ")

    local buyR = row(sfBuy, 32)
    local buyL = txt(buyR,{Position=UDim2.fromOffset(10,8), Size=UDim2.new(1,-20,0,16),
        TextSize=10, TextColor3=COL.Pink, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Center})
    task.spawn(function()
        while pBuy.Parent do
            buyL.Text = string.format("🪙 %d เหรียญ  (ซื้อเมื่อ ≥ %d)", getCoins(), STATE.coinThreshold)
            wait(1)
        end
    end)

    toggle(sfBuy, "autoBuyChair", "🪑 Auto Buy Chair", "🪑 ซื้อเก้าอี้อัตโนมัติ",
        "ซื้อ chair decor เมื่อเหรียญพอ", "เปิด shop → ซื้ออัตโนมัติ", nil)

    toggle(sfBuy, "autoBuyOffers", "🎁 Auto Buy Offers", "🎁 ซื้อ Offer อัตโนมัติ",
        "ซื้อ offers/promotions อัตโนมัติ", "ซื้อ offer ที่มีอยู่", nil)

    button(sfBuy, "🛒 ซื้อเดี๋ยวนี้", "🛒 ซื้อทันที",
        "บังคับซื้อ ไม่สนใจ threshold", "ซื้อทันที", "ซื้อ", "ซื้อ",
        function(d)
            d.Text = "🔄 กำลังซื้อ..."
            STATE.coinThreshold = 0
            tryAutoBuy()
            STATE.coinThreshold = 100
            task.delay(1.5, function()
                d.Text = string.format("✔ เหรียญเหลือ %d", getCoins())
                task.delay(2, function() d.Text = "ซื้อทันที" end)
            end)
        end)

    button(sfBuy, "🎁 Claim Reward", "🎁 รับรางวัล",
        "ขอ daily/streak reward ผ่าน Remote", "รับรางวัลรายวัน", "รับ", "รับ",
        function(d)
            tryCoinFarm()
            d.Text = "✔ ส่ง request แล้ว"
            task.delay(2, function() d.Text = "รับรางวัลรายวัน" end)
        end)

    button(sfBuy, "📦 ซื้อ Chair: bow", "📦 ซื้อ bow chair",
        "ซื้อ bow decor โดยตรง", "ใช้ Purchase remote", "ซื้อ", "ซื้อ",
        function(d)
            if rPurchase then
                safeCall(function() rPurchase:FireServer("chair", "bow") end)
                d.Text = "✔ ส่ง request"
            else
                d.Text = "❌ ไม่พบ remote"
            end
            task.delay(2, function() d.Text = "ใช้ Purchase remote" end)
        end)

    -- ════════════════════════════════════════════
    --  PAGE ✦ EVENT
    -- ════════════════════════════════════════════
    rowOrd.v = 0
    local pEvent = addPage("event", "✦", "EVENT", "อีเวนท์")
    local sfEvent = makeScroll(pEvent)

    header(sfEvent, "✦ AUTO EVENT", "✦ อีเวนท์อัตโนมัติ")

    toggle(sfEvent, "autoEvent", "✦ Auto Join Event", "✦ เข้า Event อัตโนมัติ",
        "เข้าร่วม event อัตโนมัติ", "เปิด/ปิดการเข้า event", nil)

    -- เลือก event type
    local evR = row(sfEvent, 56)
    L(txt(evR,{Position=UDim2.fromOffset(14,6), Size=UDim2.new(1,-20,0,16), TextSize=12}),
        "Event Type", "ประเภท Event")
    local evH = make("Frame",{Position=UDim2.fromOffset(14,26), Size=UDim2.new(1,-28,0,24),
        BackgroundTransparency=1}, evR)
    make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5)}, evH)
    local evBtns = {}
    for _, et in ipairs({{"none","ปกติ"},{"ranked","แรงค์"},{"solo","Solo"}}) do
        local eb = make("TextButton",{Size=UDim2.new(1/3,-4,1,0), BackgroundColor3=COL.Bg,
            Text=et[2], Font=Enum.Font.GothamBold, TextSize=10, TextColor3=COL.Text,
            AutoButtonColor=false}, evH)
        round(eb, 11)
        evBtns[et[1]] = eb
        eb.MouseButton1Click:Connect(function()
            STATE.eventType = et[1]
            for k, b in pairs(evBtns) do
                TS:Create(b, TI, {BackgroundColor3=(k==et[1]) and COL.Purple or COL.Bg}):Play()
            end
        end)
    end
    if evBtns["none"] then TS:Create(evBtns["none"], TI, {BackgroundColor3=COL.Purple}):Play() end
    NX.onAccent(function()
        for k, b in pairs(evBtns) do b.BackgroundColor3=(k==STATE.eventType) and COL.Purple or COL.Bg end
    end)

    button(sfEvent, "🏆 เข้า Ranked ทันที", "🏆 Ranked ทันที",
        "กดปุ่ม Ranked ใน HUD", "เข้าแข่ง ranked", "เข้า", "เข้า",
        function(d)
            STATE.eventType = "ranked"
            tryAutoEvent()
            d.Text = "✔ กด Ranked แล้ว"
            task.delay(2, function() d.Text = "เข้าแข่ง ranked" end)
        end)

    button(sfEvent, "🧑 เข้า Solo ทันที", "🧑 Solo ทันที",
        "กด Solo desk prompt ทันที", "เข้าเล่น Solo", "เข้า", "เข้า",
        function(d)
            STATE.eventType = "solo"
            tryAutoEvent()
            d.Text = "✔ กด Solo แล้ว"
            task.delay(2, function() d.Text = "เข้าเล่น Solo" end)
        end)

    button(sfEvent, "🎯 Auto Event Loop", "🎯 Event Loop",
        "เข้า event ซ้ำๆ อัตโนมัติ", "loop เข้า event ต่อเนื่อง", "Loop", "Loop",
        function(d)
            STATE.autoEvent = true
            d.Text = "✔ Event Loop ON"
            task.spawn(function()
                while STATE.autoEvent do
                    tryAutoEvent()
                    wait(5)
                end
            end)
            task.delay(2, function() d.Text = "loop เข้า event ต่อเนื่อง" end)
        end)

    -- ════════════════════════════════════════════
    --  PAGE ♛ RANK
    -- ════════════════════════════════════════════
    rowOrd.v = 0
    local pRank = addPage("rank", "♛", "RANK", "แรงค์")
    local sfRank = makeScroll(pRank)

    header(sfRank, "♛ AUTO RANK FARM", "♛ ฟาร์มแรงค์อัตโนมัติ")

    local rkR = row(sfRank, 36)
    local rkL = txt(rkR,{Position=UDim2.fromOffset(10,8), Size=UDim2.new(1,-20,0,20),
        TextSize=10, TextColor3=COL.Pink, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Center})
    task.spawn(function()
        while pRank.Parent do
            rkL.Text = string.format("⭐ เลเวล %d  |  🪙 %d เหรียญ", getLevel(), getCoins())
            wait(1)
        end
    end)

    toggle(sfRank, "autoRank", "♛ Auto Rank Farm", "♛ Farm แรงค์อัตโนมัติ",
        "นั่ง → ตอบ → วนซ้ำเพื่อ exp", "farm exp อัตโนมัติ",
        function(v) if v then task.spawn(autoRankLoop) end end)

    toggle(sfRank, "autoRankJoinAny", "🪑 Join Any Table", "🪑 นั่งโต๊ะอะไรก็ได้",
        "นั่งโต๊ะแรกที่ว่าง ไม่เลือกขนาด", "ไม่เลือกโต๊ะ",
        function(v) if v then STATE.preferTable = 0 end end)

    -- ขนาดโต๊ะสำหรับ rank
    local rkSzR = row(sfRank, 56)
    L(txt(rkSzR,{Position=UDim2.fromOffset(14,6), Size=UDim2.new(1,-20,0,16), TextSize=12}),
        "Preferred Table Size", "ขนาดโต๊ะที่ต้องการ")
    local rkSzH = make("Frame",{Position=UDim2.fromOffset(14,26), Size=UDim2.new(1,-28,0,24),
        BackgroundTransparency=1}, rkSzR)
    make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5)}, rkSzH)
    local rkSzBtns = {}
    for _, sz in ipairs({2,3,4,5}) do
        local sb = make("TextButton",{Size=UDim2.new(.25,-4,1,0), BackgroundColor3=COL.Bg,
            Text=sz.." ที่", Font=Enum.Font.GothamBold, TextSize=10, TextColor3=COL.Text,
            AutoButtonColor=false}, rkSzH)
        round(sb, 11)
        rkSzBtns[sz] = sb
        sb.MouseButton1Click:Connect(function()
            STATE.rankTableTarget = sz
            STATE.preferTable = sz
            for k, b in pairs(rkSzBtns) do
                TS:Create(b, TI, {BackgroundColor3=(k==sz) and COL.Purple or COL.Bg}):Play()
            end
        end)
    end
    if rkSzBtns[2] then TS:Create(rkSzBtns[2], TI, {BackgroundColor3=COL.Purple}):Play() end
    NX.onAccent(function()
        for k, b in pairs(rkSzBtns) do
            b.BackgroundColor3 = (k==STATE.rankTableTarget) and COL.Purple or COL.Bg
        end
    end)

    button(sfRank, "🚀 Start Full Farm", "🚀 เริ่ม Farm ทั้งหมด",
        "เปิด Sit + Play + Reveal + Rank", "เปิด farm เต็มรูปแบบ", "START", "เริ่ม",
        function(d)
            STATE.autoRank   = true
            STATE.autoSit    = true
            STATE.autoPlay   = true
            STATE.autoReveal = true
            d.Text = "✔ Farm ON"
            task.spawn(autoRankLoop)
            task.spawn(autoPlayLoop)
            task.delay(2, function() d.Text = "เปิด farm เต็มรูปแบบ" end)
        end)

    button(sfRank, "⏹ หยุด Farm ทั้งหมด", "⏹ หยุด Farm",
        "ปิด loop ทั้งหมด", "หยุดการ farm", "STOP", "หยุด",
        function(d)
            STATE.autoRank   = false
            STATE.autoSit    = false
            STATE.autoPlay   = false
            STATE.autoReveal = false
            STATE.autoEvent  = false
            d.Text = "✔ หยุดแล้ว"
            task.delay(2, function() d.Text = "หยุดการ farm" end)
        end)

    button(sfRank, "📊 ดูสถิติตอนนี้", "📊 ดูสถิติ",
        "เหรียญ / เลเวล ตอนนี้", "อัปเดตสถิติ", "ดู", "ดู",
        function(d)
            d.Text = string.format("🪙%d  ⭐Lv%d", getCoins(), getLevel())
            task.delay(3, function() d.Text = "อัปเดตสถิติ" end)
        end)

    print("[Thai-Auto] ✔ โหลดสำเร็จ — 4 หมวดหมู่พร้อมใช้งาน (AUTO / BUY / EVENT / RANK)")
end)

-- ════════════════════════════════════════════════
--  CLEANUP on respawn
-- ════════════════════════════════════════════════
lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    STATE.seatedAt = nil
end)

print([[
╔════════════════════════════════╗
║  Thai Quiz Auto — โหลดสำเร็จ  ║
║  รัน GUI.lua ก่อน แล้วรันไฟล์นี้  ║
╚════════════════════════════════╝
⚡ AUTO  — นั่ง / ตอบ / เล่นอัตโนมัติ
♢  BUY   — ซื้อของ / รับรางวัล
✦ EVENT  — เข้า Ranked / Solo
♛ RANK   — Farm แรงค์วนซ้ำ
]])
