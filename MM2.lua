-- GUINO1 : ตัวแสดงข้อผิดพลาดบนจอ (ใช้ได้แม้สคริปต์หลักพัง)
local __errCount = 0
local function showError(where, err)
	local msg = "[GUINO1] " .. tostring(where) .. "\n" .. tostring(err)
	pcall(warn, msg)
	pcall(function()
		__errCount = __errCount + 1
		local sg = Instance.new("ScreenGui")
		sg.Name = "GUINO1_ERR"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		local box = Instance.new("TextButton")
		box.Size = UDim2.new(1, -20, 0, 130)
		box.Position = UDim2.fromOffset(10, 10 + (__errCount - 1) * 138)
		box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		box.BackgroundTransparency = 0.05
		box.TextColor3 = Color3.new(1, 1, 1)
		box.TextWrapped = true
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.TextYAlignment = Enum.TextYAlignment.Top
		box.TextSize = 12
		box.Font = Enum.Font.Code
		box.Text = "GUINO1 รันไม่ผ่านบางส่วน - แคปหน้าจอนี้ส่งมาได้เลย (แตะเพื่อปิด)\n" .. string.sub(msg, 1, 700)
		box.Parent = sg
		box.MouseButton1Click:Connect(function() sg:Destroy() end)
		local ok = pcall(function() sg.Parent = gethui() end)
		if not ok or not sg.Parent then
			sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end
	end)
end

local function __main()
--[[
  GUINO1  |  NEXORA HUB GUI  (Roblox LocalScript / executor)
  ไฟล์เดียวจบ: หน้าโหลด + หน้าต่าง + หมวดหน้าหลัก + หมวดตั้งค่า
  - Studio: วางใน LocalScript (StarterGui)
  - ตัวรันสคริปต์: เปิดไฟล์นี้แล้วรันทั้งไฟล์
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ===================== CONFIG =====================
local HUB_TITLE = "NEXORA HUB"
local LOGO_ID = "rbxassetid://86383017875768"
local BG_ID = "rbxassetid://103808357914530"
local DISCORD_ICON = "rbxassetid://8387379664" -- รูปปุ่ม Discord
local DISCORD_LINK = "https://discord.gg/vHRMNpDsQ4"
local BG_DIM = 0.3 -- ความมืดทับภาพพื้นหลัง 0-1
local MIN_LOAD = 4.5 -- วินาทีขั้นต่ำของหน้าโหลด
local WIN_W, WIN_H = 540, 330
local WHITE = Color3.new(1, 1, 1)
local EFFECTS_ON = true
local lang = "TH"
local VERSION = "GUINO1 v2"

-- เสียง: {id, ความดัง, ความเร็ว} (ใส่ rbxassetid://ไอดีของคุณแทนได้)
local SOUND_ON = true
local MASTER_VOL = 0.5 -- ความดังรวม 0-1 (ปรับได้ในหน้า ตั้งค่า)
local SFX = {
	click = {"rbxasset://sounds/electronicpingshort.wav", 0.5, 1.2},
	note = {"rbxasset://sounds/electronicpingshort.wav", 0.45, 1.0},
	tick = {"rbxasset://sounds/electronicpingshort.wav", 0.25, 1.4},
	whoosh = {"rbxasset://sounds/swordslash.wav", 0.35, 1.0},
	boom = {"rbxasset://sounds/impact_explosion_03.mp3", 0.3, 0.9},
}
-- ==================================================

-- ===== โหลดการตั้งค่าที่บันทึกไว้ (ถ้าเครื่องรองรับ readfile) =====
local SAVE_FILE = "GUINO1_settings.json"
local function loadSaved()
	local ok, data = pcall(function()
		if isfile and readfile and isfile(SAVE_FILE) then
			return HttpService:JSONDecode(readfile(SAVE_FILE))
		end
	end)
	if ok and type(data) == "table" then return data end
	return {}
end
local SAVED = loadSaved()
local AUTOSAVE = (SAVED.autosave ~= false)
if SAVED.sound ~= nil then SOUND_ON = SAVED.sound and true or false end
if tonumber(SAVED.vol) then MASTER_VOL = math.clamp(tonumber(SAVED.vol), 0, 1) end
if SAVED.fx ~= nil then EFFECTS_ON = SAVED.fx and true or false end
if tonumber(SAVED.dim) then BG_DIM = math.clamp(tonumber(SAVED.dim), 0, 0.8) end
if SAVED.lang == "EN" or SAVED.lang == "TH" then lang = SAVED.lang end

-- รันสคริปต์อัตโนมัติหลังเข้าเกมใหม่/ย้ายเซิร์ฟ (ตั้งค่าได้ในหน้า ตั้งค่า)
local AUTORUN_FILE = "GUINO1.lua" -- ชื่อไฟล์สคริปต์ในโฟลเดอร์ workspace ของตัวรัน
local AUTORUN_ON = (SAVED.autorun == true)
local AUTORUN_URL = (type(SAVED.autorunUrl) == "string") and SAVED.autorunUrl or ""

local T = {
	TH = {s1 = "ตรวจสอบระบบ", s2 = "โหลดทรัพยากร", s3 = "เชื่อมต่อโมดูล", s4 = "พร้อมใช้งาน"},
	EN = {s1 = "Checking system", s2 = "Loading assets", s3 = "Linking modules", s4 = "Ready"},
}

-- ฟอนต์ (ถ้าเครื่องไม่มีจะใช้ Gotham แทน)
local function pickFont(name, fallback)
	local ok, f = pcall(function() return Enum.Font[name] end)
	return (ok and f) or fallback
end
local TITLE_FONT = pickFont("Michroma", Enum.Font.GothamBlack)
local HUD_FONT = pickFont("Sarpanch", Enum.Font.GothamBold)

-- ===== ธีมสี (ค่าเริ่มต้น = ขาว) =====
local THEMES = {
	{"ขาว", "White", Color3.fromRGB(235, 235, 235)},
	{"แดง", "Red", Color3.fromRGB(226, 52, 72)},
	{"เขียว", "Green", Color3.fromRGB(28, 190, 120)},
	{"ฟ้า", "Cyan", Color3.fromRGB(70, 190, 255)},
	{"ม่วง", "Purple", Color3.fromRGB(165, 110, 255)},
	{"ทอง", "Gold", Color3.fromRGB(255, 190, 60)},
}
local themeIdx = math.clamp(math.floor(tonumber(SAVED.theme) or 1), 1, #THEMES)
local ACCENT = THEMES[themeIdx][3]
local accentFns = {}
local function onAccent(fn)
	accentFns[#accentFns + 1] = fn
	fn(ACCENT)
end
local function setAccent(i)
	themeIdx = i
	ACCENT = THEMES[i][3]
	for _, f in ipairs(accentFns) do f(ACCENT) end
end
-- สีตัวอักษรที่อ่านออกบนพื้นสี accent
local function onAccentText(c)
	return (0.299 * c.R + 0.587 * c.G + 0.114 * c.B > 0.6) and Color3.fromRGB(10, 10, 10) or WHITE
end

-- helpers
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end
local function corner(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, o) end
local function stroke(o, c, tr, th)
	return new("UIStroke", {Color = c, Transparency = tr or 0.5, Thickness = th or 1}, o)
end
local function tw(o, t, props, style, dir)
	local tween = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tween:Play()
	return tween
end

-- แสงวิ่งรอบขอบ (สีตามธีม)
local spinners = {}
local COMET = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.5, 0.88),
	NumberSequenceKeypoint.new(1, 0),
})
local function glow(parent, thickness, speed)
	local s = new("UIStroke", {Color = ACCENT, Thickness = thickness or 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, parent)
	local g = new("UIGradient", {Transparency = COMET}, s)
	table.insert(spinners, {g = g, speed = speed or 90})
	onAccent(function(c) s.Color = c end)
	return s, g
end

-- สายฟ้าขาว (ang เป็นเรเดียน) แตกกิ่งได้
local function bolt(parent, x, y, ang, len, thick, z, depth)
	depth = depth or 0
	local pts = {Vector2.new(x, y)}
	local segs = math.random(4, 7)
	local cx, cy = x, y
	for _ = 1, segs do
		local a = ang + math.rad(math.random(-45, 45))
		cx = cx + math.cos(a) * len / segs
		cy = cy + math.sin(a) * len / segs
		pts[#pts + 1] = Vector2.new(cx, cy)
	end
	local frames = {}
	for i = 1, #pts - 1 do
		local p1, p2 = pts[i], pts[i + 1]
		local d = p2 - p1
		local mid = UDim2.fromOffset((p1.X + p2.X) / 2, (p1.Y + p2.Y) / 2)
		local rot = math.deg(math.atan2(d.Y, d.X))
		for _, layer in ipairs({{thick * 3, 0.8}, {thick, 0}}) do
			frames[#frames + 1] = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = mid, Size = UDim2.fromOffset(d.Magnitude + 1, layer[1]), Rotation = rot, BackgroundColor3 = WHITE, BackgroundTransparency = layer[2], BorderSizePixel = 0, ZIndex = z or 20}, parent)
		end
	end
	if depth < 1 and len > 20 then
		for _ = 1, 2 do
			if math.random() < 0.6 then
				local p = pts[math.random(2, #pts - 1)]
				bolt(parent, p.X, p.Y, ang + math.rad(math.random(-70, 70)), len * 0.5, math.max(1, thick - 1), z, depth + 1)
			end
		end
	end
	task.delay(0.07, function()
		for _, f in ipairs(frames) do tw(f, 0.2, {BackgroundTransparency = 1}) end
		task.delay(0.22, function()
			for _, f in ipairs(frames) do f:Destroy() end
		end)
	end)
end

-- คลื่นกระแทกวงกลม
local function shock(parent, x, y, size, dur, z)
	dur = dur or 0.6
	local f = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(4, 4), BackgroundTransparency = 1, ZIndex = z or 20}, parent)
	corner(f, 1000)
	local s = stroke(f, WHITE, 0, 2)
	tw(f, dur, {Size = UDim2.fromOffset(size, size)})
	tw(s, dur, {Transparency = 1, Thickness = 0.5})
	task.delay(dur + 0.05, function() f:Destroy() end)
end

-- ประกาย
local function spark(parent, x, y, ang, dist, size, z)
	size = size or 3
	local f = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(size, size), Rotation = math.random(0, 90), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = z or 20}, parent)
	local d = 0.35 + math.random() * 0.3
	tw(f, d, {Position = UDim2.fromOffset(x + math.cos(ang) * dist, y + math.sin(ang) * dist), BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 1)})
	task.delay(d + 0.05, function() f:Destroy() end)
end
local function burst(parent, x, y, n, dist, z)
	for _ = 1, n do
		spark(parent, x, y, math.random() * math.pi * 2, dist * (0.5 + math.random() * 0.7), math.random(2, 4), z)
	end
end

-- แฟลชขาว
local function flashFrame(parent, z, strength, dur)
	dur = dur or 0.25
	local f = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1 - (strength or 0.8), BorderSizePixel = 0, ZIndex = z or 30}, parent)
	tw(f, dur, {BackgroundTransparency = 1})
	task.delay(dur + 0.05, function() f:Destroy() end)
end

-- เสียงนุ่ม: บีบช่วงความสูงต่ำให้แคบ + ตัดเสียงแหลม + คุมความดังรวม
local function softPitch(sp)
	return math.clamp(0.8 + (sp - 0.7) * 0.35, 0.55, 1.5)
end
local function sfx(name, vol, speed)
	if not SOUND_ON or MASTER_VOL <= 0 then return end
	local d = SFX[name]
	if not d then return end
	local s = Instance.new("Sound")
	s.SoundId = d[1]
	s.Volume = (vol or d[2]) * MASTER_VOL
	s.PlaybackSpeed = softPitch(speed or d[3])
	pcall(function()
		local eq = Instance.new("EqualizerSoundEffect")
		eq.HighGain = -18
		eq.MidGain = -3
		eq.LowGain = 2
		eq.Parent = s
	end)
	s.Parent = SoundService
	s:Play()
	s.Ended:Connect(function() s:Destroy() end)
	task.delay(6, function()
		if s.Parent then s:Destroy() end
	end)
end
local function sfxSeq(name, speeds, gap, vol)
	for i, sp in ipairs(speeds) do
		task.delay((i - 1) * gap, function() sfx(name, vol, sp) end)
	end
end

-- เอฟเฟคปุ่ม: ชี้ขยาย / กดยุบ
local function fx(btn, hoverColor)
	local us = new("UIScale", {Scale = 1}, btn)
	local rest = btn.BackgroundColor3
	local hovered = false
	btn.MouseEnter:Connect(function()
		hovered = true
		tw(us, 0.12, {Scale = 1.1})
		tw(btn, 0.12, {BackgroundColor3 = hoverColor})
	end)
	btn.MouseLeave:Connect(function()
		hovered = false
		tw(us, 0.12, {Scale = 1})
		tw(btn, 0.12, {BackgroundColor3 = rest})
	end)
	btn.MouseButton1Down:Connect(function() tw(us, 0.08, {Scale = 0.9}) end)
	btn.MouseButton1Up:Connect(function()
		tw(us, 0.12, {Scale = hovered and 1.1 or 1}, Enum.EasingStyle.Back)
	end)
end

local dragMoved = 0
local function makeDrag(handle, target)
	local dragging, dStart, sPos
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, dStart, sPos, dragMoved = true, i.Position, target.Position, 0
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - dStart
			dragMoved = math.max(dragMoved, d.Magnitude)
			target.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
		end
	end)
end

-- gui
pcall(function()
	local hui = gethui and gethui()
	for _, parent in ipairs({LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer, hui or LocalPlayer}) do
		local old = parent:FindFirstChild("NEXORA_HIDDEN_GUI")
		if old then old:Destroy() end
	end
end)
local gui = new("ScreenGui", {Name = "NEXORA_HIDDEN_GUI", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, nil)
pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)
local okHui = pcall(function() gui.Parent = gethui() end)
if not okHui or not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(800, 400)
local base = math.clamp(math.min(vp.X / (WIN_W + 40), vp.Y / (WIN_H + 30)), 0.55, 1)

-- ลูปกลางตัวเดียว (Heartbeat)
local frameFns = {}
local T0 = os.clock()
local function onFrame(fn)
	frameFns[fn] = true
	return function() frameFns[fn] = nil end
end
local hb
hb = RunService.Heartbeat:Connect(function(dt)
	if not gui.Parent then hb:Disconnect() return end
	local t = os.clock() - T0
	for fn in pairs(frameFns) do fn(t, dt) end
end)
onFrame(function(t)
	for _, s in ipairs(spinners) do s.g.Rotation = (t * s.speed) % 360 end
end)

-- ===== รันสคริปต์อัตโนมัติหลังย้ายเซิร์ฟ/เข้าใหม่ (ต้องใช้ตัวรันที่รองรับ queue_on_teleport) =====
local function autorunCode()
	if AUTORUN_URL ~= "" then
		return string.format("loadstring(game:HttpGet(%q))()", AUTORUN_URL)
	end
	return string.format("local f = %q if isfile and isfile(f) then loadstring(readfile(f))() end", AUTORUN_FILE)
end
local lastQueue = -100
local function queueAutorun()
	local q = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
	if not q then return false end
	if os.clock() - lastQueue < 20 then return true end
	lastQueue = os.clock()
	return (pcall(q, autorunCode()))
end
pcall(function()
	LocalPlayer.OnTeleport:Connect(function(state)
		if AUTORUN_ON and (state == Enum.TeleportState.Started or state == Enum.TeleportState.RequestedFromServer) then
			queueAutorun()
		end
	end)
end)

-- ตัวกันพัง: ถ้าส่วนไหนผิดพลาดจะแสดงข้อความบนจอ (แตะเพื่อปิด) และส่วนอื่นยังทำงานต่อ
local function guard(where, fn)
	local ok, err = xpcall(fn, function(e) return tostring(e) .. "\n" .. debug.traceback("", 2) end)
	if not ok then showError(where, err) end
	return ok
end

-- ===================== หน้าต่าง + หัวเรื่อง + แถบข้าง =====================
local Win = new("Frame", {Name = "Win", Size = UDim2.fromOffset(WIN_W, WIN_H), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Visible = false}, gui)
local scale = new("UIScale", {Scale = base}, Win)
local Main = new("CanvasGroup", {Name = "Main", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(12, 12, 12), BorderSizePixel = 0, GroupTransparency = 1}, Win)
corner(Main, 16)
local Rim = new("Frame", {Name = "Rim", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 5}, Win)
corner(Rim, 16)
glow(Rim, 2.5, 90)
local Rim2 = new("Frame", {Name = "Rim2", Size = UDim2.new(1, 8, 1, 8), Position = UDim2.fromOffset(-4, -4), BackgroundTransparency = 1, ZIndex = 5}, Win)
corner(Rim2, 20)
glow(Rim2, 1, -150)

new("ImageLabel", {Name = "Background", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = BG_ID, ScaleType = Enum.ScaleType.Crop, ZIndex = 1}, Main)
local Dim = new("Frame", {Name = "Dim", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1 - BG_DIM, BorderSizePixel = 0, ZIndex = 1}, Main)

-- แสงสแกนไล่ลง + ฝุ่นแสงลอย
local Scan = new("Frame", {Size = UDim2.new(1, 0, 0, 70), Position = UDim2.fromOffset(0, -70), BackgroundColor3 = WHITE, BackgroundTransparency = 0.88, BorderSizePixel = 0, ZIndex = 2}, Main)
new("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 1),
})}, Scan)
local dust = {}
for i = 1, 16 do
	local sz = math.random(1, 3)
	local f = new("Frame", {Size = UDim2.fromOffset(sz, sz), BackgroundColor3 = WHITE, BackgroundTransparency = 0.4 + math.random() * 0.4, BorderSizePixel = 0, ZIndex = 2}, Main)
	dust[i] = {f = f, x = math.random(0, WIN_W), y = math.random(0, WIN_H), sp = 10 + math.random() * 25, ph = math.random() * 6.28}
end
onFrame(function(t, dt)
	Scan.Position = UDim2.fromOffset(0, ((t * 0.3) % 1) * (WIN_H + 140) - 70)
	for _, p in ipairs(dust) do
		p.y = p.y - p.sp * dt
		if p.y < -4 then
			p.y = WIN_H + 4
			p.x = math.random(0, WIN_W)
		end
		p.f.Position = UDim2.fromOffset(p.x + math.sin(t + p.ph) * 8, p.y)
	end
end)

-- หัวเรื่อง: โลโก้ + ชื่อ + คำรอง (สไตล์ MOBILE INTERFACE)
local Top = new("Frame", {Name = "Top", Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 40), BackgroundColor3 = Color3.fromRGB(8, 8, 8), BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 3}, Main)
corner(Top, 12)
stroke(Top, Color3.fromRGB(120, 120, 120), 0.65, 1)
local Logo = new("ImageLabel", {Name = "Logo", Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(7, 5), BackgroundTransparency = 1, Image = LOGO_ID, ZIndex = 4}, Top)
corner(Logo, 9)
local logoStroke = stroke(Logo, ACCENT, 0.1, 1.5)
onAccent(function(c) logoStroke.Color = c end)
local TitleLbl = new("TextLabel", {Position = UDim2.fromOffset(46, 4), Size = UDim2.fromOffset(220, 18), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Font = TITLE_FONT, TextSize = 12, TextColor3 = WHITE, Text = HUB_TITLE, ZIndex = 4}, Top)
new("UIGradient", {Color = ColorSequence.new(WHITE, Color3.fromRGB(150, 150, 150)), Rotation = 90}, TitleLbl)
new("UIStroke", {Color = WHITE, Thickness = 1, Transparency = 0.85}, TitleLbl)
local SubLbl = new("TextLabel", {Position = UDim2.fromOffset(46, 22), Size = UDim2.fromOffset(220, 14), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Font = HUD_FONT, TextSize = 11, TextColor3 = ACCENT, Text = "MOBILE INTERFACE", ZIndex = 4}, Top)
onAccent(function(c) SubLbl.TextColor3 = c end)

-- ปุ่มแบนเรียบ กดแล้วมีประกาย + เสียงนุ่ม
local function topBtn(txt, w, off)
	local b = new("TextButton", {Size = UDim2.fromOffset(w, 26), Position = UDim2.new(1, -(off + w), 0.5, -13), BackgroundColor3 = Color3.fromRGB(32, 32, 32), BackgroundTransparency = 0.15, Text = txt, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = WHITE, RichText = true, AutoButtonColor = false, ZIndex = 4}, Top)
	corner(b, 8)
	stroke(b, Color3.fromRGB(110, 110, 110), 0.35, 1)
	fx(b, Color3.fromRGB(58, 58, 58))
	b.MouseButton1Click:Connect(function()
		burst(b, w / 2, 13, 7, 18, 30)
		sfx("click", nil, 1.7 + math.random() * 0.5)
	end)
	return b
end
local BtnClose = topBtn("×", 26, 8)
local BtnMin = topBtn("-", 26, 38)
local BtnSize = topBtn("□", 26, 68)

-- ปุ่มภาษา แสดงเป็น TH/EN (ภาษาที่ใช้อยู่เป็นตัวขาว)
local function langText()
	if lang == "TH" then
		return '<font color="rgb(255,255,255)">TH</font><font color="rgb(120,120,120)">/EN</font>'
	end
	return '<font color="rgb(120,120,120)">TH/</font><font color="rgb(255,255,255)">EN</font>'
end
local BtnLang = topBtn("", 54, 98)
BtnLang.Font = TITLE_FONT
BtnLang.TextSize = 9
BtnLang.Text = langText()
makeDrag(Top, Win)

-- แถบข้าง (โปรไฟล์ + เมนูใหญ่ สไตล์ในภาพ)
local SIDE_W = 130
local Side = new("Frame", {Name = "Side", Position = UDim2.fromOffset(6, 52), Size = UDim2.new(0, SIDE_W, 1, -58), BackgroundColor3 = Color3.fromRGB(10, 10, 10), BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 3}, Main)
corner(Side, 14)
stroke(Side, Color3.fromRGB(120, 120, 120), 0.65, 1)

-- ===================== ตรรกะหน้าต่าง + แถบข้าง + โลโก้ลอย =====================
local Content = new("Frame", {Name = "Content", Position = UDim2.fromOffset(6 + SIDE_W + 6, 52), Size = UDim2.new(1, -(6 + SIDE_W + 12), 1, -58), BackgroundTransparency = 1, ZIndex = 3}, Main)

-- ภาษา: ข้อความสองภาษาที่สลับได้
local langRegs = {}
local function applyOne(e) e.o.Text = (lang == "TH") and e.th or e.en end
local function tr(obj, th, en)
	local e = {o = obj, th = th, en = en}
	langRegs[#langRegs + 1] = e
	applyOne(e)
	return e
end
local function applyLang()
	for _, e in ipairs(langRegs) do applyOne(e) end
end

-- ตัวช่วย UI
local GRAY = Color3.fromRGB(180, 180, 180)
local function copyText(s)
	local f = setclipboard or toclipboard or (syn and syn.write_clipboard)
	if f then
		local ok = pcall(f, s)
		return ok
	end
	return false
end
local function mkLabel(parent, x, y, w, h, text, size, color, font, align)
	return new("TextLabel", {Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundTransparency = 1, Text = text or "", TextSize = size or 12, TextColor3 = color or WHITE, Font = font or Enum.Font.GothamBold, TextXAlignment = align or Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5}, parent)
end
local function mkCard(parent, h, order)
	local f = new("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = Color3.fromRGB(14, 14, 14), BackgroundTransparency = 0.25, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 4}, parent)
	corner(f, 12)
	stroke(f, Color3.fromRGB(120, 120, 120), 0.6, 1)
	return f
end
-- เอฟเฟคปุ่มกว้าง (ไม่ขยายขนาด)
local function fxFlat(btn, hoverColor)
	local rest = btn.BackgroundColor3
	btn.MouseEnter:Connect(function() tw(btn, 0.12, {BackgroundColor3 = hoverColor}) end)
	btn.MouseLeave:Connect(function() tw(btn, 0.12, {BackgroundColor3 = rest}) end)
	btn.MouseButton1Down:Connect(function() tw(btn, 0.08, {BackgroundTransparency = 0.5}) end)
	btn.MouseButton1Up:Connect(function() tw(btn, 0.12, {BackgroundTransparency = 0.15}) end)
end

-- ป้ายแจ้งเตือนเล็กๆ ด้านล่างหน้าต่าง
local Toast = new("TextLabel", {AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 28), Size = UDim2.fromOffset(280, 26), BackgroundColor3 = Color3.fromRGB(235, 235, 235), BackgroundTransparency = 0.05, TextColor3 = Color3.fromRGB(10, 10, 10), Font = HUD_FONT, TextSize = 13, Text = "", ZIndex = 40}, Main)
corner(Toast, 13)
local toastId = 0
local function toast(th, en)
	toastId = toastId + 1
	local id = toastId
	Toast.Text = (lang == "TH") and th or (en or th)
	tw(Toast, 0.2, {Position = UDim2.new(0.5, 0, 1, -10)}, Enum.EasingStyle.Back)
	task.delay(1.8, function()
		if id == toastId then tw(Toast, 0.2, {Position = UDim2.new(0.5, 0, 1, 28)}) end
	end)
end
local function copyToast(s, th, en)
	if copyText(s) then
		toast(th, en)
	else
		toast("เครื่องนี้ไม่รองรับการคัดลอก", "Copy not supported here")
	end
end

-- ค่าที่บันทึกได้ + ฟังก์ชันบันทึก
local userScale = tonumber(SAVED.scale) and math.clamp(tonumber(SAVED.scale), 0.7, 1.4) or 1
local uiOpacity = tonumber(SAVED.opacity) and math.clamp(tonumber(SAVED.opacity), 0.5, 1) or 1
local saveQueued = false
local function saveSettings(force)
	if (not AUTOSAVE and not force) or not writefile or saveQueued then return end
	saveQueued = true
	task.delay(0.6, function()
		saveQueued = false
		pcall(function()
			writefile(SAVE_FILE, HttpService:JSONEncode({
				sound = SOUND_ON, vol = MASTER_VOL, fx = EFFECTS_ON, dim = BG_DIM,
				scale = userScale, opacity = uiOpacity, theme = themeIdx, lang = lang, autosave = AUTOSAVE,
				autorun = AUTORUN_ON, autorunUrl = AUTORUN_URL,
			}))
		end)
	end)
end

-- ฟังก์ชันเซิร์ฟเวอร์ (เติมไว้ในหมวดตั้งค่า ใช้ร่วมกับหน้าหลัก)
local SRV = {}

-- สายฟ้ารอบหน้าต่าง
local function strikeWin(big)
	local side = math.random(1, 4)
	local x, y, ang
	if side == 1 then x, y, ang = math.random(20, WIN_W - 20), 0, -90
	elseif side == 2 then x, y, ang = math.random(20, WIN_W - 20), WIN_H, 90
	elseif side == 3 then x, y, ang = 0, math.random(20, WIN_H - 20), 180
	else x, y, ang = WIN_W, math.random(20, WIN_H - 20), 0 end
	bolt(Win, x, y, math.rad(ang + math.random(-25, 25)), big and math.random(60, 110) or math.random(30, 70), big and 3 or 2, 20)
end

-- เปิด/ปิดหน้าต่าง (มีเสียงนุ่ม)
local isBig = false
local opened = false
local function target() return base * userScale * (isBig and 1.2 or 1) end
local function openWin()
	if opened then return end
	opened = true
	Win.Visible = true
	scale.Scale = target() * 0.8
	tw(scale, 0.3, {Scale = target()}, Enum.EasingStyle.Back)
	tw(Main, 0.22, {GroupTransparency = 1 - uiOpacity})
	if EFFECTS_ON then
		flashFrame(Main, 30, 0.55, 0.45)
		shock(Win, WIN_W / 2, WIN_H / 2, 760, 0.7, 25)
		for _ = 1, 6 do strikeWin(true) end
	end
	sfx("whoosh", 0.45, 1.5)
	sfxSeq("note", {1.4, 1.9}, 0.07, 0.4)
end
local function closeWin()
	if not opened then return end
	opened = false
	tw(scale, 0.18, {Scale = target() * 0.85})
	tw(Main, 0.18, {GroupTransparency = 1})
	sfx("whoosh", 0.4, 0.9)
	sfxSeq("note", {1.5, 1.1}, 0.07, 0.35)
	task.delay(0.2, function()
		if not opened then Win.Visible = false end
	end)
end

-- หน้า (Pages)
local Pages, NavBtns = {}, {}
local currentTab
local function makePage(name)
	local p = new("ScrollingFrame", {Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = WHITE, ScrollBarImageTransparency = 0.5, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, ZIndex = 3}, Content)
	new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, p)
	new("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)}, p)
	Pages[name] = p
	return p
end
makePage("home")
makePage("settings")

-- ไอคอนวาดจากกรอบ (เห็นชัวร์ ไม่พึ่งฟอนต์/อิโมจิ): บ้าน + เฟือง
local function makeIcon(kind, parent, x, y, sc)
	local box = new("Frame", {Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1, ZIndex = 6}, parent)
	if sc then new("UIScale", {Scale = sc}, box) end
	local parts = {}
	local function part(px, py, w, h, r, rot, keep)
		local f = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(px, py), Size = UDim2.fromOffset(w, h), Rotation = rot or 0, BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 6}, box)
		if r and r > 0 then corner(f, r) end
		if not keep then parts[#parts + 1] = f end
		return f
	end
	local hole
	if kind == "home" then
		part(11, 9, 13, 13, 2, 45)
		part(11, 15, 14, 10, 2, 0)
		hole = part(11, 17, 4, 6, 1, 0, true)
	elseif kind == "user" then
		part(11, 7, 9, 9, 4, 0)
		part(11, 17, 15, 9, 4, 0)
		hole = part(11, 11, 1, 1, 0, 0, true)
	elseif kind == "list" then
		part(11, 5, 16, 3, 1, 0)
		part(11, 11, 16, 3, 1, 0)
		part(11, 17, 16, 3, 1, 0)
		hole = part(11, 11, 1, 1, 0, 0, true)
	elseif kind == "star" then
		part(11, 11, 13, 13, 2, 0)
		part(11, 11, 13, 13, 2, 45)
		hole = part(11, 11, 5, 5, 2, 0, true)
	else
		part(11, 11, 19, 4, 1, 0)
		part(11, 11, 19, 4, 1, 90)
		part(11, 11, 19, 4, 1, 45)
		part(11, 11, 19, 4, 1, -45)
		part(11, 11, 14, 14, 7, 0)
		hole = part(11, 11, 6, 6, 3, 0, true)
	end
	return {
		setColor = function(c) for _, f in ipairs(parts) do f.BackgroundColor3 = c end end,
		setHole = function(c) hole.BackgroundColor3 = c end,
	}
end

-- สไตล์ปุ่มเมนู: ปุ่มที่เลือก = พื้นสี accent + แถบขาวด้านซ้าย (เหมือนในภาพ)
local NAV_IDLE = Color3.fromRGB(30, 30, 30)
local function styleNav()
	for n, nb in pairs(NavBtns) do
		local on = (n == currentTab)
		local fg = on and onAccentText(ACCENT) or GRAY
		tw(nb.b, 0.18, {BackgroundColor3 = on and ACCENT or NAV_IDLE, BackgroundTransparency = on and 0 or 0.2})
		tw(nb.ind, 0.18, {BackgroundTransparency = on and 0 or 1})
		nb.ind.BackgroundColor3 = onAccentText(ACCENT)
		tw(nb.lb, 0.18, {TextColor3 = fg})
		nb.ic.setColor(fg)
		nb.ic.setHole(on and ACCENT or NAV_IDLE)
	end
end
onAccent(styleNav)

local function selectTab(name, silent)
	if currentTab == name then return end
	currentTab = name
	for n, p in pairs(Pages) do p.Visible = (n == name) end
	styleNav()
	local pg = Pages[name]
	pg.Position = UDim2.fromOffset(0, 10)
	tw(pg, 0.2, {Position = UDim2.fromOffset(0, 0)})
	if not silent then sfx("click", nil, 1.5) end
end

-- เพิ่มหมวดใหม่: navBtn("home"|"gear"|"user"|"list"|"star", "ชื่อไทย", "EN NAME", "ชื่อหน้า", false) + makePage("ชื่อหน้า")
local NAV_H = 34
local navTop = 0
local function navBtn(kind, th, en, name, atBottom)
	local yTop = 8 + navTop * (NAV_H + 6)
	if not atBottom then navTop = navTop + 1 end
	local b = new("TextButton", {AnchorPoint = Vector2.new(0, atBottom and 1 or 0), Position = UDim2.new(0, 8, atBottom and 1 or 0, atBottom and -8 or yTop), Size = UDim2.new(1, -16, 0, NAV_H), BackgroundColor3 = NAV_IDLE, BackgroundTransparency = 0.2, Text = "", AutoButtonColor = false, ZIndex = 4}, Side)
	corner(b, 10)
	stroke(b, Color3.fromRGB(120, 120, 120), 0.7, 1)
	local ind = new("Frame", {Size = UDim2.fromOffset(3, 16), Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = WHITE, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 6}, b)
	corner(ind, 2)
	local ic = makeIcon(kind, b, 12, 8, 0.8)
	local lb = new("TextLabel", {Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Font = HUD_FONT, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = GRAY, ZIndex = 6}, b)
	tr(lb, th, en)
	NavBtns[name] = {b = b, ind = ind, ic = ic, lb = lb}
	b.MouseButton1Click:Connect(function() selectTab(name) end)
end

navBtn("home", "หน้าหลัก", "HOME", "home", false)

-- ===== หมวด MM2 =====
makePage("mm_radar")
makePage("mm_warp")
makePage("mm_fling")
makePage("mm_hunter")
makePage("mm_player")
makePage("mm_farm")
makePage("mm_event")
makePage("music")
makePage("identity")
makePage("invisible")
makePage("animations")
makePage("items")
makePage("lighting")

-- section label สไตล์ mini (วางบนแถบข้าง)
local function sideSection(th, en)
	local lbl = new("TextLabel", {
		Size = UDim2.new(1, -16, 0, 16),
		Position = UDim2.new(0, 8, 0, 8 + navTop * (NAV_H + 6)),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextColor3 = Color3.fromRGB(100, 100, 100),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
	}, Side)
	tr(lbl, th, en)
	navTop = navTop + 1
end

sideSection("── MM2 ──", "── MM2 ──")
navBtn("list",  "เรดาร์",   "RADAR",   "mm_radar",  false)
navBtn("list",  "วาร์ป",    "WARP",    "mm_warp",   false)
navBtn("star",  "ฟลิ้ง",    "FLING",   "mm_fling",  false)
navBtn("list",  "โหมดล่า", "HUNTER",  "mm_hunter", false)
navBtn("user",  "ตัวละคร", "PLAYER",  "mm_player", false)
navBtn("star",  "ฟาร์ม",   "FARM",    "mm_farm",   false)
navBtn("star",  "อีเวนท์", "EVENT",   "mm_event",  false)
sideSection("── CUSTOM ──", "── CUSTOM ──")
navBtn("list",  "เพลง",    "MUSIC",   "music",     false)
navBtn("user",  "ชื่อปลอม","IDENTITY","identity",  false)
navBtn("list",  "ล่องหน",  "INVIS",   "invisible", false)
navBtn("list",  "แอนิเมชัน","ANIM",   "animations",false)
navBtn("star",  "ไอเทม",   "ITEMS",   "items",     false)
navBtn("list",  "แสงฉาก",  "LIGHTING","lighting",  false)

navBtn("gear", "ตั้งค่า", "SETTINGS", "settings", true)
selectTab("home", true)

-- ตัวสุ่มค่าสถานะกลาง (ทุก 0.25 วินาที ทำงานเฉพาะตอนเปิดหน้าต่าง)
local Stats = game:GetService("Stats")
local sampleCbs = {}
local function onSample(cb) sampleCbs[#sampleCbs + 1] = cb end
local S = {fps = 60, ping = 0, mem = 0}
do
	local acc, frames = 0, 0
	onFrame(function(t, dt)
		acc = acc + dt
		frames = frames + 1
		if acc < 0.25 then return end
		S.fps = frames / acc
		acc, frames = 0, 0
		if not opened then return end
		S.ping, S.mem = 0, 0
		pcall(function() S.ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
		pcall(function() S.mem = Stats:GetTotalMemoryUsageMb() end)
		for _, cb in ipairs(sampleCbs) do cb(S, t) end
	end)
end
-- ปุ่มบนแถบ
BtnLang.MouseButton1Click:Connect(function()
	lang = (lang == "TH") and "EN" or "TH"
	BtnLang.Text = langText()
	applyLang()
	saveSettings()
	sfxSeq("note", {1.6, 2.1}, 0.06, 0.4)
end)
BtnSize.MouseButton1Click:Connect(function()
	isBig = not isBig
	if opened then tw(scale, 0.2, {Scale = target()}) end
end)
BtnMin.MouseButton1Click:Connect(closeWin)
BtnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

-- โลโก้ลอย (แสดงตลอด)
local Float = new("Frame", {Name = "Float", Size = UDim2.fromOffset(64, 64), Position = UDim2.new(0, 16, 0.5, -32), BackgroundTransparency = 1, Visible = false, ZIndex = 10}, gui)
local FI = new("Frame", {Name = "FI", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 10}, Float)
local FS = new("UIScale", {Scale = 1}, FI)
local RingA = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(58, 58), BackgroundTransparency = 1, ZIndex = 11}, FI)
corner(RingA, 16)
glow(RingA, 2, 140)
local RingB = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(72, 72), BackgroundTransparency = 1, ZIndex = 11}, FI)
corner(RingB, 20)
glow(RingB, 1.5, -100)
local FloatBtn = new("ImageButton", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(46, 46), BackgroundColor3 = Color3.fromRGB(12, 12, 12), Image = LOGO_ID, AutoButtonColor = false, ZIndex = 12}, FI)
corner(FloatBtn, 12)
fx(FloatBtn, Color3.fromRGB(40, 40, 40))
makeDrag(FloatBtn, Float)
FloatBtn.MouseButton1Click:Connect(function()
	if dragMoved < 6 then
		shock(FI, 32, 32, 150, 0.6, 9)
		burst(FI, 32, 32, 10, 34, 14)
		if opened then closeWin() else openWin() end
	end
end)

-- จุดแสงโคจรรอบโลโก้ลอย
local orb = {}
for i = 1, 3 do
	local d = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(5, 5), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 13}, FI)
	corner(d, 3)
	stroke(d, WHITE, 0.6, 2)
	orb[i] = {f = d, sp = 1.6 + i * 0.5, ph = i * 2.1, r = 38 + i * 2}
end
onFrame(function(t)
	FI.Position = UDim2.new(0.5, 0, 0.5, math.sin(t * 2.2) * 3)
	for _, o in ipairs(orb) do
		local a = t * o.sp + o.ph
		o.f.Position = UDim2.fromOffset(32 + math.cos(a) * o.r, 32 + math.sin(a) * o.r)
	end
end)

-- สายฟ้ารอบโลโก้ลอย
local function strikeFloat()
	local side = math.random(1, 4)
	local x, y, ang
	if side == 1 then x, y, ang = math.random(10, 54), 3, -90
	elseif side == 2 then x, y, ang = math.random(10, 54), 61, 90
	elseif side == 3 then x, y, ang = 3, math.random(10, 54), 180
	else x, y, ang = 61, math.random(10, 54), 0 end
	bolt(FI, x, y, math.rad(ang + math.random(-25, 25)), math.random(14, 30), 1, 20)
end

-- ตัวจัดจังหวะสายฟ้า/คลื่น (ปิดได้ในหน้า ตั้งค่า)
task.spawn(function()
	local nextBigT = 0
	while gui.Parent do
		task.wait(0.22 + math.random() * 0.5)
		if opened and EFFECTS_ON then
			strikeWin(false)
			if math.random() < 0.4 then task.delay(0.06, strikeWin) end
			if os.clock() > nextBigT and math.random() < 0.18 then
				nextBigT = os.clock() + 3
				for _ = 1, 3 do strikeWin(true) end
				flashFrame(Main, 30, 0.3, 0.3)
				sfx("boom", 0.2, 1.8)
			end
		end
	end
end)
task.spawn(function()
	while gui.Parent do
		task.wait(0.35 + math.random() * 0.45)
		if Float.Visible and EFFECTS_ON then strikeFloat() end
	end
end)
task.spawn(function()
	while gui.Parent do
		task.wait(2.2)
		if Float.Visible and EFFECTS_ON then shock(FI, 32, 32, 130, 0.9, 9) end
	end
end)

-- คีย์ลัด RightShift เปิด/ปิด GUI
UIS.InputBegan:Connect(function(i, gp)
	if gp or not Float.Visible then return end
	if i.KeyCode == Enum.KeyCode.RightShift then
		if opened then closeWin() else openWin() end
	end
end)

local function runLoading()

-- ===================== หน้าโหลด: สร้างฉาก =====================
local L = {}
L.root = new("CanvasGroup", {Name = "Loading", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(4, 4, 4), BorderSizePixel = 0, ZIndex = 100}, gui)
L.bg = new("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1.1, 1.1), BackgroundTransparency = 1, Image = BG_ID, ImageTransparency = 0.5, ScaleType = Enum.ScaleType.Crop, ZIndex = 101}, L.root)
new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 102}, L.root)

-- ขอบมืด (vignette)
local function vig(pos, size, rot)
	local f = new("Frame", {Position = pos, Size = size, BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 102}, L.root)
	new("UIGradient", {Rotation = rot, Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1),
	})}, f)
end
vig(UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.3), 90)
vig(UDim2.fromScale(0, 0.7), UDim2.fromScale(1, 0.3), 270)
vig(UDim2.fromScale(0, 0), UDim2.fromScale(0.25, 1), 0)
vig(UDim2.fromScale(0.75, 0), UDim2.fromScale(0.25, 1), 180)

-- แสงสแกน + ฝุ่นแสง
L.scan = new("Frame", {Size = UDim2.new(1, 0, 0, 90), BackgroundColor3 = WHITE, BackgroundTransparency = 0.88, BorderSizePixel = 0, ZIndex = 103}, L.root)
new("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 1),
})}, L.scan)
L.dust = {}
for i = 1, 34 do
	local sz = math.random(1, 3)
	local f = new("Frame", {Size = UDim2.fromOffset(sz, sz), BackgroundColor3 = WHITE, BackgroundTransparency = 0.3 + math.random() * 0.5, BorderSizePixel = 0, ZIndex = 103}, L.root)
	L.dust[i] = {f = f, x = math.random(), y = math.random(), sp = 0.04 + math.random() * 0.1, ph = math.random() * 6.28}
end

-- กรอบมุม HUD + ข้อความมุมจอ
local function bracket(ax, ay)
	local h = new("Frame", {AnchorPoint = Vector2.new(ax, ay), Position = UDim2.new(ax, ax == 0 and 16 or -16, ay, ay == 0 and 16 or -16), Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1, ZIndex = 104}, L.root)
	for _, sz in ipairs({UDim2.new(1, 0, 0, 2), UDim2.new(0, 2, 1, 0)}) do
		new("Frame", {AnchorPoint = Vector2.new(ax, ay), Position = UDim2.fromScale(ax, ay), Size = sz, BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 104}, h)
	end
end
bracket(0, 0)
bracket(1, 0)
bracket(0, 1)
bracket(1, 1)
new("TextLabel", {Position = UDim2.fromOffset(52, 18), Size = UDim2.fromOffset(260, 14), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Font = HUD_FONT, TextSize = 12, TextColor3 = Color3.fromRGB(200, 200, 200), Text = "NEXORA // BOOT SEQUENCE", ZIndex = 104}, L.root)
new("TextLabel", {AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -52, 1, -18), Size = UDim2.fromOffset(120, 14), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, Font = HUD_FONT, TextSize = 12, TextColor3 = Color3.fromRGB(200, 200, 200), Text = "GUINO1", ZIndex = 104}, L.root)

-- เวที (กลางจอ)
L.stage = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(320, 400), BackgroundTransparency = 1, ZIndex = 104}, L.root)
new("UIScale", {Scale = math.clamp(vp.Y / 430, 0.5, 1.5)}, L.stage)
L.CX, L.CY = 160, 170

-- วงแหวนหมุน
local function ring(size, th, speed)
	local f = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(L.CX, L.CY), Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, ZIndex = 104}, L.stage)
	corner(f, size)
	glow(f, th, speed)
	return f
end
ring(260, 2, 60)
ring(292, 1.5, -95)

-- โลโก้ + กรอบแสง + ภาพซ้อนกลิตช์
local LR = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(L.CX, L.CY), Size = UDim2.fromOffset(100, 100), BackgroundTransparency = 1, ZIndex = 105}, L.stage)
corner(LR, 26)
glow(LR, 3, 150)
L.ghosts = {}
for i = 1, 2 do
	local g = new("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(L.CX, L.CY), Size = UDim2.fromOffset(84, 84), BackgroundTransparency = 1, Image = LOGO_ID, ImageTransparency = 1, ZIndex = 105}, L.stage)
	corner(g, 18)
	L.ghosts[i] = g
end
L.logo = new("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(L.CX, L.CY), Size = UDim2.fromOffset(84, 84), BackgroundColor3 = Color3.fromRGB(12, 12, 12), Image = LOGO_ID, ZIndex = 106}, L.stage)
corner(L.logo, 18)
L.logoScale = new("UIScale", {Scale = 1}, L.logo)

-- ตัวการ์ตูนนินจา (ประกอบจาก Frame ในแคนวาส เพื่อทำภาพเงาตามหลังได้)
L.runner = new("CanvasGroup", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(100, 74), BackgroundTransparency = 1, ZIndex = 108}, L.stage)
do
	local R = L.runner
	local SUIT = Color3.fromRGB(178, 178, 178)
	local SUIT2 = Color3.fromRGB(135, 135, 135)
	local HEAD = Color3.fromRGB(238, 238, 238)
	local VISOR = Color3.fromRGB(8, 8, 8)

	local function box(x, y, w, h, c, r, z)
		local f = new("Frame", {Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundColor3 = c, BorderSizePixel = 0, ZIndex = z}, R)
		corner(f, r)
		return f
	end
	-- แขน/ขา 2 ท่อน หมุนที่ข้อต่อ (holder กลาง)
	local function limb(px, py, w, l1, l2, c, z, foot)
		local h1 = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(px, py), Size = UDim2.fromOffset(w, l1 * 2), BackgroundTransparency = 1, ZIndex = z}, R)
		corner(new("Frame", {Position = UDim2.fromOffset(0, l1), Size = UDim2.fromOffset(w, l1), BackgroundColor3 = c, BorderSizePixel = 0, ZIndex = z}, h1), 2)
		local h2 = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(w / 2, l1 * 2), Size = UDim2.fromOffset(w, l2 * 2), BackgroundTransparency = 1, ZIndex = z}, h1)
		corner(new("Frame", {Position = UDim2.fromOffset(0, l2), Size = UDim2.fromOffset(w, l2), BackgroundColor3 = c, BorderSizePixel = 0, ZIndex = z}, h2), 2)
		corner(new("Frame", {Position = UDim2.fromOffset(0, l2 * 2 - 4), Size = UDim2.fromOffset(w + (foot and 4 or 0), 4), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = z}, h2), 2)
		return h1, h2
	end

	-- ผ้าพันคอ 5 ท่อน (ต่อกันเป็นโซ่ ยื่นไปทางหลัง)
	local scarf = {}
	local parentS = R
	for i = 1, 5 do
		local hh = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = (i == 1) and UDim2.fromOffset(44, 16) or UDim2.fromOffset(0, 2), Size = UDim2.fromOffset(16, 4), BackgroundTransparency = 1, ZIndex = 2}, parentS)
		corner(new("Frame", {Size = UDim2.fromOffset(8, 4), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 2}, hh), 2)
		scarf[i] = hh
		parentS = hh
	end

	local legB1, legB2 = limb(48, 40, 5, 8, 8, SUIT2, 1, true)
	local armB1, armB2 = limb(50, 27, 4, 6, 6, SUIT2, 1, false)
	box(45, 24, 10, 16, SUIT, 4, 3)
	box(49, 26, 2, 11, WHITE, 1, 4)
	box(42, 8, 16, 16, HEAD, 8, 4)
	local visor = box(48, 13, 10, 5, VISOR, 2, 5)
	stroke(visor, WHITE, 0.5, 1.5)
	box(52, 15, 2, 2, WHITE, 1, 6)
	box(55, 15, 2, 2, WHITE, 1, 6)
	local legF1, legF2 = limb(52, 40, 5, 8, 8, SUIT, 6, true)
	local armF1, armF2 = limb(50, 27, 4, 6, 6, SUIT, 6, false)

	L.rp = {legB1 = legB1, legB2 = legB2, armB1 = armB1, armB2 = armB2, legF1 = legF1, legF2 = legF2, armF1 = armF1, armF2 = armF2, scarf = scarf}
end

-- ชื่อ + % + แถบโหลด + สถานะ
L.title = new("TextLabel", {Position = UDim2.fromOffset(0, -4), Size = UDim2.fromOffset(320, 26), BackgroundTransparency = 1, Font = TITLE_FONT, TextSize = 18, TextColor3 = WHITE, Text = "", ZIndex = 106}, L.stage)
new("UIGradient", {Color = ColorSequence.new(WHITE, Color3.fromRGB(150, 150, 150)), Rotation = 90}, L.title)
new("UIStroke", {Color = WHITE, Thickness = 2, Transparency = 0.8}, L.title)
L.pct = new("TextLabel", {Position = UDim2.fromOffset(0, 328), Size = UDim2.fromOffset(320, 30), BackgroundTransparency = 1, Font = TITLE_FONT, TextSize = 22, TextColor3 = WHITE, Text = "0%", ZIndex = 106}, L.stage)
new("UIGradient", {Color = ColorSequence.new(WHITE, Color3.fromRGB(150, 150, 150)), Rotation = 90}, L.pct)
local Bar = new("Frame", {Position = UDim2.fromOffset(60, 364), Size = UDim2.fromOffset(200, 8), BackgroundColor3 = Color3.fromRGB(40, 40, 40), BorderSizePixel = 0, ZIndex = 106}, L.stage)
corner(Bar, 4)
stroke(Bar, WHITE, 0.6, 1)
L.fill = new("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 107}, Bar)
corner(L.fill, 4)
L.shim = new("Frame", {Size = UDim2.new(0, 36, 1, 0), Position = UDim2.fromScale(-0.2, 0), BackgroundColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 108}, L.fill)
L.status = new("TextLabel", {Position = UDim2.fromOffset(0, 378), Size = UDim2.fromOffset(320, 16), BackgroundTransparency = 1, Font = HUD_FONT, TextSize = 13, TextColor3 = Color3.fromRGB(190, 190, 190), Text = "", ZIndex = 106}, L.stage)

-- ===================== หน้าโหลด: ลูปแอนิเมชัน + เสียงเปิดตัว + ฉากจบ =====================
local lstart = os.clock()
local assetsDone = false
task.spawn(function()
	pcall(function() ContentProvider:PreloadAsync({L.bg, L.logo}) end)
	assetsDone = true
end)

-- เสียงเปิดตัว: หวือ + บูมทุ้ม + โน้ตไล่ขึ้น
sfx("whoosh", 0.6, 0.7)
sfx("boom", 0.4, 0.7)
sfxSeq("note", {0.8, 1.0, 1.2, 1.6}, 0.12, 0.4)

local CX, CY = L.CX, L.CY
local HF = 58 -- ระยะเท้าจากกลางโลโก้ (ปรับให้วิ่งชิดกรอบ)
local nextGhost, nextSpark, nextCrackle, nextShock, nextGlitch, nextBig, nextTip = 0, 0, 0, 0, 1.2, 2.2, 0
local glitchUntil, shakeUntil = 0, 0
local lastN, lastDecile = 0, 0
local finished = false

local function finish()
	L.status.Text = T[lang].s4
	flashFrame(L.root, 120, 1, 0.7)
	shock(L.stage, CX, CY, 520, 0.8, 110)
	task.delay(0.12, function() shock(L.stage, CX, CY, 420, 0.8, 110) end)
	for i = 1, 10 do
		local ang = (i / 10) * math.pi * 2 + math.random() * 0.3
		bolt(L.stage, CX + math.cos(ang) * 55, CY + math.sin(ang) * 55, ang, math.random(80, 140), 3, 110)
	end
	burst(L.stage, CX, CY, 28, 150, 110)
	sfx("whoosh", 0.6, 1.0)
	sfx("boom", 0.5, 1.2)
	sfxSeq("note", {1.0, 1.25, 1.5, 2.0, 2.5}, 0.07, 0.45)
	L.logoScale.Scale = 1.25
	tw(L.logoScale, 0.4, {Scale = 1}, Enum.EasingStyle.Back)
	task.wait(0.45)
	local fade = tw(L.root, 0.5, {GroupTransparency = 1})
	Float.Visible = true
	FS.Scale = 0
	tw(FS, 0.5, {Scale = 1}, Enum.EasingStyle.Back)
	task.delay(0.15, openWin)
	fade.Completed:Connect(function() L.root:Destroy() end)
end

local stopLoop
stopLoop = onFrame(function(_, dt)
	if not L.root.Parent then stopLoop() return end
	local e = os.clock() - lstart

	-- พื้นหลังซูมช้า, สแกน, ฝุ่นแสง
	local z = 1.08 + 0.04 * math.sin(e * 0.6)
	L.bg.Size = UDim2.fromScale(z, z)
	L.scan.Position = UDim2.new(0, 0, ((e * 0.35) % 1.3) - 0.15, 0)
	for _, p in ipairs(L.dust) do
		p.y = p.y - p.sp * dt
		if p.y < -0.02 then
			p.y = 1.02
			p.x = math.random()
		end
		p.f.Position = UDim2.fromScale(p.x + math.sin(e + p.ph) * 0.01, p.y)
	end

	-- โลโก้หายใจ + กลิตช์
	L.logoScale.Scale = 1 + 0.03 * math.sin(e * 5)
	if e >= nextGlitch then
		glitchUntil = e + 0.14
		nextGlitch = e + 1.0 + math.random() * 1.2
		sfx("tick", 0.3, 2.8)
	end
	if e < glitchUntil then
		L.ghosts[1].Position = UDim2.fromOffset(CX + 4, CY)
		L.ghosts[2].Position = UDim2.fromOffset(CX - 4, CY + 1)
		L.ghosts[1].ImageTransparency = 0.45
		L.ghosts[2].ImageTransparency = 0.45
		L.logo.Position = UDim2.fromOffset(CX + math.random(-2, 2), CY + math.random(-1, 1))
	else
		L.ghosts[1].ImageTransparency = 1
		L.ghosts[2].ImageTransparency = 1
		L.logo.Position = UDim2.fromOffset(CX, CY)
	end

	-- นินจาวิ่งรอบกรอบโลโก้ (เท้าชี้เข้าหาโลโก้ เอนตัวไปข้างหน้า)
	local a = e * 2.6
	local c, sn = math.abs(math.cos(a)), math.abs(math.sin(a))
	local r = HF / (c ^ 4 + sn ^ 4) ^ 0.25 + 24 + 3 * math.abs(math.sin(e * 16))
	local rx, ry = CX + r * math.cos(a), CY + r * math.sin(a)
	L.runner.Position = UDim2.fromOffset(rx, ry)
	L.runner.Rotation = math.deg(a) + 100

	-- แกว่งแขนขา ผ้าพันคอพลิ้ว
	local ph = e * 15
	local P = L.rp
	P.legF1.Rotation = -math.sin(ph) * 52
	P.legF2.Rotation = math.max(0, 28 + 36 * math.sin(ph + 1.3))
	P.legB1.Rotation = math.sin(ph) * 52
	P.legB2.Rotation = math.max(0, 28 + 36 * math.sin(ph + 1.3 + math.pi))
	P.armF1.Rotation = math.sin(ph) * 45
	P.armF2.Rotation = -(35 + 20 * math.sin(ph))
	P.armB1.Rotation = -math.sin(ph) * 45
	P.armB2.Rotation = -(35 - 20 * math.sin(ph))
	for i, s in ipairs(P.scarf) do s.Rotation = math.sin(e * 14 - i * 0.9) * 16 - 4 end

	-- ภาพเงาตามหลัง
	if e >= nextGhost then
		nextGhost = e + 0.07
		local g = L.runner:Clone()
		g.ZIndex = 107
		g.GroupTransparency = 0.55
		g.Parent = L.stage
		tw(g, 0.3, {GroupTransparency = 1})
		task.delay(0.33, function() g:Destroy() end)
	end

	-- ประกายใต้เท้า
	if e >= nextSpark then
		nextSpark = e + 0.07
		local px, py = rx - math.cos(a) * 19, ry - math.sin(a) * 19
		spark(L.stage, px, py, a - math.pi / 2 + (math.random() - 0.5) * 1.2, 14 + math.random() * 14, math.random(2, 3), 107)
	end

	-- สายฟ้าแลบจากโลโก้
	if e >= nextCrackle then
		nextCrackle = e + 0.12 + math.random() * 0.18
		local ang = math.random() * math.pi * 2
		bolt(L.stage, CX + math.cos(ang) * 48, CY + math.sin(ang) * 48, ang, math.random(40, 85), 2, 107)
	end

	-- คลื่นกระแทกจากโลโก้
	if e >= nextShock then
		nextShock = e + 1.1
		shock(L.stage, CX, CY, 320, 1.0, 104)
	end

	-- ฟ้าผ่าลงจากบนจอ + จอสั่น + แฟลช + เสียงตูม
	if e >= nextBig then
		nextBig = e + 1.8 + math.random() * 1.5
		local sw = L.root.AbsoluteSize.X
		bolt(L.root, math.random(0, math.max(1, math.floor(sw))), 0, math.pi / 2 + (math.random() - 0.5) * 0.5, math.random(160, 260), 3, 110)
		flashFrame(L.root, 109, 0.25, 0.3)
		shakeUntil = e + 0.14
		sfx("boom", 0.35, 0.9)
	end
	if e < shakeUntil then
		L.stage.Position = UDim2.new(0.5, math.random(-3, 3), 0.5, math.random(-3, 3))
	else
		L.stage.Position = UDim2.fromScale(0.5, 0.5)
	end

	-- ชื่อพิมพ์ทีละตัว (มีเสียงติ๊ก) + กระพริบ
	local title = HUB_TITLE
	local n = math.min(#title, math.floor(e / 0.1))
	if n > lastN then
		lastN = n
		sfx("tick", 0.25, 2.2 + n * 0.05)
	end
	L.title.Text = title:sub(1, n)
	L.title.TextTransparency = (math.random() < 0.02) and 0.6 or 0

	-- ความคืบหน้า
	local p = math.min(e / MIN_LOAD, 1)
	if not assetsDone and e < 9 then p = math.min(p, 0.95) end
	L.fill.Size = UDim2.new(p, 0, 1, 0)
	L.shim.Position = UDim2.new(((e * 0.9) % 1.4) - 0.2, 0, 0, 0)
	L.pct.Text = math.floor(p * 100) .. "%"
	local key = p < 0.25 and "s1" or p < 0.55 and "s2" or p < 0.9 and "s3" or "s4"
	L.status.Text = T[lang][key] .. string.rep(".", math.floor(e * 3) % 4)

	-- เสียงติ๊งทุก 10%
	local dec = math.floor(p * 10)
	if dec > lastDecile then
		lastDecile = dec
		sfx("note", 0.3, 1.0 + p)
	end

	-- ประกายที่ปลายแถบ
	if p > 0.02 and e >= nextTip then
		nextTip = e + 0.09
		spark(L.stage, 60 + 200 * p, 368, -math.pi / 2 + (math.random() - 0.5) * 1.5, 12 + math.random() * 10, 2, 107)
	end

	if p >= 1 and not finished then
		finished = true
		stopLoop()
		task.defer(finish)
	end
end)

end
if not guard("loading", runLoading) then
	Float.Visible = true
	openWin()
end

-- ===================== หมวดหน้าหลัก =====================
local function buildHome()
	local P = Pages.home
	local MarketplaceService = game:GetService("MarketplaceService")
	local CW = 384 -- ความกว้างการ์ด
	local FONT = Enum.Font.GothamBold
	local GN = 28 -- จำนวนจุดบนกราฟ

	local function gradText(lbl)
		new("UIGradient", {Color = ColorSequence.new(WHITE, Color3.fromRGB(150, 150, 150)), Rotation = 90}, lbl)
	end
	-- หัวข้อการ์ด: แท่งสี accent + ชื่อ
	local function heading(card, th, en)
		local bar = new("Frame", {Position = UDim2.fromOffset(12, 9), Size = UDim2.fromOffset(3, 12), BackgroundColor3 = ACCENT, BorderSizePixel = 0, ZIndex = 6}, card)
		corner(bar, 2)
		onAccent(function(c) bar.BackgroundColor3 = c end)
		tr(mkLabel(card, 20, 8, 250, 14, "", 10, WHITE, TITLE_FONT), th, en)
	end
	-- มุมกรอบสไตล์ HUD
	local function brackets(card)
		for _, c in ipairs({{0, 0}, {1, 0}, {0, 1}, {1, 1}}) do
			local ax, ay = c[1], c[2]
			local h = new("Frame", {AnchorPoint = Vector2.new(ax, ay), Position = UDim2.new(ax, ax == 0 and 3 or -3, ay, ay == 0 and 3 or -3), Size = UDim2.fromOffset(9, 9), BackgroundTransparency = 1, ZIndex = 7}, card)
			for _, sz in ipairs({UDim2.new(1, 0, 0, 1), UDim2.new(0, 1, 1, 0)}) do
				local ln = new("Frame", {AnchorPoint = Vector2.new(ax, ay), Position = UDim2.fromScale(ax, ay), Size = sz, BackgroundColor3 = ACCENT, BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 7}, h)
				onAccent(function(col) ln.BackgroundColor3 = col end)
			end
		end
	end
	-- ช่องข้อมูลเล็ก (ป้ายเล็ก + ค่า)
	local function chip(parent, x, y, w, h, th, en, vs)
		local c = new("Frame", {Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundColor3 = Color3.fromRGB(8, 8, 8), BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 6}, parent)
		corner(c, 8)
		stroke(c, Color3.fromRGB(120, 120, 120), 0.65, 1)
		tr(mkLabel(c, 7, 2, w - 14, 11, "", 9, GRAY, HUD_FONT), th, en)
		local v = mkLabel(c, 7, 12, w - 14, h - 13, "-", vs or 12, WHITE, FONT)
		return v, c
	end
	local function tapCopy(parent, text, th, en)
		local b = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 9}, parent)
		b.MouseButton1Click:Connect(function()
			sfx("click", nil, 1.5)
			copyToast(text, th, en)
		end)
	end
	-- ปุ่มสั้นในการ์ด
	local function qbtn(parent, x, y, w, h, th, en, cb)
		local b = new("TextButton", {Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundColor3 = Color3.fromRGB(32, 32, 32), BackgroundTransparency = 0.15, Font = FONT, TextSize = 11, TextColor3 = WHITE, AutoButtonColor = false, ZIndex = 6}, parent)
		corner(b, 8)
		stroke(b, Color3.fromRGB(110, 110, 110), 0.4, 1)
		fxFlat(b, Color3.fromRGB(58, 58, 58))
		tr(b, th, en)
		b.MouseButton1Click:Connect(function()
			sfx("click", nil, 1.6)
			cb()
		end)
		return b
	end

	-- ===== 1) ตัวละคร =====
	local c1 = mkCard(P, 96, 1)
	brackets(c1)
	local ringF = new("Frame", {Position = UDim2.fromOffset(8, 12), Size = UDim2.fromOffset(72, 72), BackgroundTransparency = 1, ZIndex = 5}, c1)
	corner(ringF, 20)
	glow(ringF, 2, 110)
	local pic = new("ImageLabel", {Position = UDim2.fromOffset(13, 17), Size = UDim2.fromOffset(62, 62), BackgroundColor3 = Color3.fromRGB(30, 30, 30), Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150", ZIndex = 6}, c1)
	corner(pic, 16)
	local nm = mkLabel(c1, 90, 12, 230, 22, LocalPlayer.DisplayName, 17, WHITE, Enum.Font.GothamBlack)
	gradText(nm)
	mkLabel(c1, 90, 34, 230, 14, "@" .. LocalPlayer.Name, 12, GRAY, HUD_FONT)
	local idV, idC = chip(c1, 90, 56, 92, 30, "ไอดี • แตะคัดลอก", "ID • TAP COPY", 11)
	idV.Text = tostring(LocalPlayer.UserId)
	tapCopy(idC, tostring(LocalPlayer.UserId), "คัดลอก ID แล้ว", "ID copied")
	local ageV = chip(c1, 188, 56, 86, 30, "อายุบัญชี", "ACCOUNT AGE", 11)
	ageV.Text = LocalPlayer.AccountAge .. " d"
	local clockV = chip(c1, 280, 56, 92, 30, "เวลาเครื่อง", "LOCAL TIME", 11)
	local live = new("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 14), Size = UDim2.fromOffset(8, 8), BackgroundColor3 = ACCENT, BorderSizePixel = 0, ZIndex = 7}, c1)
	corner(live, 4)
	onAccent(function(c) live.BackgroundColor3 = c end)
	tr(mkLabel(c1, 250, 11, 110, 14, "", 10, GRAY, HUD_FONT, Enum.TextXAlignment.Right), "ออนไลน์", "ONLINE")

	-- ===== เลือด (แถบแบ่งช่อง) =====
	local hc = mkCard(P, 62, 2)
	brackets(hc)
	heading(hc, "// เลือด", "// HEALTH")
	local hBig = mkLabel(hc, 0, 7, CW - 12, 20, "- / -", 15, WHITE, TITLE_FONT, Enum.TextXAlignment.Right)
	gradText(hBig)
	local SEG = 24
	local segW = (CW - 24 - 2 * (SEG - 1)) / SEG
	local segs = {}
	for i = 1, SEG do
		local sgm = new("Frame", {Position = UDim2.fromOffset(12 + (i - 1) * (segW + 2), 34), Size = UDim2.fromOffset(segW, 16), BackgroundColor3 = ACCENT, BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 6}, hc)
		corner(sgm, 3)
		segs[i] = sgm
	end
	onAccent(function(c)
		for _, sgm in ipairs(segs) do sgm.BackgroundColor3 = c end
	end)

	-- ===== 2) แมพ =====
	local c2 = mkCard(P, 108, 3)
	brackets(c2)
	local mapBg = new("ImageLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ImageTransparency = 0.82, ScaleType = Enum.ScaleType.Crop, ZIndex = 4}, c2)
	corner(mapBg, 12)
	local mapImg = new("ImageLabel", {Position = UDim2.fromOffset(10, 14), Size = UDim2.fromOffset(80, 80), BackgroundColor3 = Color3.fromRGB(30, 30, 30), ZIndex = 6}, c2)
	corner(mapImg, 14)
	local mapStroke = stroke(mapImg, ACCENT, 0.2, 1.5)
	onAccent(function(c) mapStroke.Color = c end)
	task.spawn(function()
		local cands = {
			"rbxthumb://type=GameIcon&id=" .. game.PlaceId .. "&w=150&h=150",
			"rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150",
			"rbxthumb://type=Asset&id=" .. game.PlaceId .. "&w=150&h=150",
		}
		for _, u in ipairs(cands) do
			mapImg.Image = u
			pcall(function() ContentProvider:PreloadAsync({mapImg}) end)
			if mapImg.IsLoaded then break end
		end
		mapBg.Image = mapImg.Image
	end)
	local mapName = mkLabel(c2, 100, 10, 270, 20, (game.Name ~= "" and game.Name) or "Place", 15, WHITE, Enum.Font.GothamBlack)
	gradText(mapName)
	task.spawn(function()
		local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
		if ok and info and info.Name then mapName.Text = info.Name end
	end)
	local pV, pC = chip(c2, 100, 36, 132, 30, "ไอดีแมพ • Place ID", "PLACE ID", 11)
	pV.Text = tostring(game.PlaceId)
	tapCopy(pC, tostring(game.PlaceId), "คัดลอก Place ID แล้ว", "Place ID copied")
	local uV, uC = chip(c2, 238, 36, 132, 30, "Universe ID", "UNIVERSE ID", 11)
	uV.Text = tostring(game.GameId)
	tapCopy(uC, tostring(game.GameId), "คัดลอก Universe ID แล้ว", "Universe ID copied")
	local jV, jC = chip(c2, 100, 70, 132, 30, "Job ID", "JOB ID", 11)
	jV.Text = (game.JobId ~= "" and string.sub(game.JobId, 1, 14) .. "..") or "-"
	tapCopy(jC, game.JobId, "คัดลอก Job ID แล้ว", "Job ID copied")
	local plV = chip(c2, 238, 70, 132, 30, "ผู้เล่นในแมพ", "PLAYERS", 11)

	-- ===== 3) Discord (ใช้รูปไอคอนที่กำหนด) =====
	local dc = new("TextButton", {Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = Color3.fromRGB(32, 32, 32), BackgroundTransparency = 0.15, Text = "", AutoButtonColor = false, LayoutOrder = 4, ZIndex = 4}, P)
	corner(dc, 12)
	local dcStroke = stroke(dc, ACCENT, 0.5, 1)
	onAccent(function(c) dcStroke.Color = c end)
	fxFlat(dc, Color3.fromRGB(58, 58, 58))
	local dcIcon = new("ImageLabel", {Position = UDim2.fromOffset(10, 9), Size = UDim2.fromOffset(40, 40), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Image = DISCORD_ICON, ScaleType = Enum.ScaleType.Fit, ZIndex = 6}, dc)
	corner(dcIcon, 10)
	local dcFallback = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = TITLE_FONT, TextSize = 14, TextColor3 = WHITE, Text = "DC", Visible = false, ZIndex = 7}, dcIcon)
	task.spawn(function()
		pcall(function() ContentProvider:PreloadAsync({dcIcon}) end)
		if not dcIcon.IsLoaded then
			local idNum = string.match(DISCORD_ICON, "%d+")
			if idNum then dcIcon.Image = "rbxthumb://type=Asset&id=" .. idNum .. "&w=150&h=150" end
			pcall(function() ContentProvider:PreloadAsync({dcIcon}) end)
		end
		if not dcIcon.IsLoaded then
			dcIcon.Image = ""
			dcFallback.Visible = true
		end
	end)
	mkLabel(dc, 60, 8, 200, 18, "Discord", 15, WHITE, Enum.Font.GothamBlack)
	tr(mkLabel(dc, 60, 26, 220, 13, "", 10, GRAY, HUD_FONT), "แตะเพื่อคัดลอกลิงก์เข้าร่วม", "TAP TO COPY THE INVITE LINK")
	mkLabel(dc, 60, 39, 220, 13, DISCORD_LINK, 10, WHITE, HUD_FONT)
	local pill = new("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(56, 26), BackgroundColor3 = ACCENT, BorderSizePixel = 0, ZIndex = 6}, dc)
	corner(pill, 13)
	local pillTxt = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = FONT, TextSize = 11, TextColor3 = onAccentText(ACCENT), Text = "COPY", ZIndex = 7}, pill)
	onAccent(function(c)
		pill.BackgroundColor3 = c
		pillTxt.TextColor3 = onAccentText(c)
	end)
	dc.MouseButton1Click:Connect(function()
		burst(dc, 300, 29, 8, 26, 10)
		sfx("click", nil, 1.7)
		copyToast(DISCORD_LINK, "คัดลอกลิงก์ Discord แล้ว", "Discord link copied")
	end)

	-- ===== 4) คำสั่งด่วน =====
	local qa = mkCard(P, 112, 5)
	brackets(qa)
	heading(qa, "// คำสั่งด่วน", "// QUICK ACTIONS")
	local bw3 = (CW - 20 - 12) / 3
	local function qpos(col, row) return 10 + col * (bw3 + 6), 30 + row * 38 end
	local function addQ(col, row, th, en, cb)
		local x, y = qpos(col, row)
		qbtn(qa, x, y, bw3, 32, th, en, cb)
	end
	addQ(0, 0, "คัดลอกชื่อ", "Copy name", function()
		copyToast(LocalPlayer.Name, "คัดลอกชื่อแล้ว", "Name copied")
	end)
	addQ(1, 0, "ลิงก์โปรไฟล์", "Profile link", function()
		copyToast("https://www.roblox.com/users/" .. LocalPlayer.UserId .. "/profile", "คัดลอกลิงก์โปรไฟล์แล้ว", "Profile link copied")
	end)
	addQ(2, 0, "ลิงก์เกม", "Game link", function()
		copyToast("https://www.roblox.com/games/" .. game.PlaceId, "คัดลอกลิงก์เกมแล้ว", "Game link copied")
	end)
	addQ(0, 1, "รีเซ็ตตัวละคร", "Reset char", function()
		local ch = LocalPlayer.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Health = 0
			toast("รีเซ็ตตัวละครแล้ว", "Character reset")
		else
			toast("ไม่พบตัวละคร", "Character not found")
		end
	end)
	addQ(1, 1, "สุ่มย้ายเซิร์ฟ", "Server hop", function() SRV.hop() end)
	addQ(2, 1, "เข้าเกมใหม่", "Rejoin", function() SRV.rejoin() end)

	-- ===== 5) ประสิทธิภาพ: กราฟเส้นสด =====
	local sc = mkCard(P, 226, 6)
	brackets(sc)
	heading(sc, "// ประสิทธิภาพ", "// PERFORMANCE")

	local function makeLine(parent, x, y, w, h)
		local area = new("Frame", {Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 6}, parent)
		for i = 1, 3 do
			new("Frame", {Position = UDim2.fromOffset(0, math.floor(h * i / 4)), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.9, BorderSizePixel = 0, ZIndex = 6}, area)
		end
		local bw = w / (GN - 1)
		local cols, lines = {}, {}
		local colored = {}
		for i = 1, GN do
			local c = new("Frame", {AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromOffset((i - 1) * bw, h), Size = UDim2.fromOffset(bw + 1, 1), BackgroundColor3 = ACCENT, BorderSizePixel = 0, Visible = false, ZIndex = 6}, area)
			new("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.72),
				NumberSequenceKeypoint.new(1, 1),
			})}, c)
			cols[i] = c
			colored[#colored + 1] = c
		end
		for i = 1, GN - 1 do
			local ln = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(2, 2), BackgroundColor3 = ACCENT, BorderSizePixel = 0, Visible = false, ZIndex = 7}, area)
			lines[i] = ln
			colored[#colored + 1] = ln
		end
		local dot = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(6, 6), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 8}, area)
		corner(dot, 3)
		local dotStroke = stroke(dot, ACCENT, 0.3, 2)
		onAccent(function(c)
			for _, f in ipairs(colored) do f.BackgroundColor3 = c end
			dotStroke.Color = c
		end)
		return {cols = cols, lines = lines, dot = dot, w = w, h = h}
	end
	local function drawLine(g, hist, mx)
		local w, h = g.w, g.h
		local off = GN - #hist
		local bw = w / (GN - 1)
		local pts = {}
		for i = 1, GN do
			local v = hist[i - off]
			if v then
				pts[i] = Vector2.new((i - 1) * bw, h - 3 - math.clamp(v / mx, 0, 1) * (h - 8))
			end
		end
		for i = 1, GN do
			local p = pts[i]
			local col = g.cols[i]
			if p then
				col.Visible = true
				col.Position = UDim2.fromOffset(p.X, h)
				col.Size = UDim2.fromOffset(bw + 1, h - p.Y)
			else
				col.Visible = false
			end
		end
		for i = 1, GN - 1 do
			local a, b = pts[i], pts[i + 1]
			local ln = g.lines[i]
			if a and b then
				local d = b - a
				ln.Visible = true
				ln.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
				ln.Size = UDim2.fromOffset(d.Magnitude + 1, 2)
				ln.Rotation = math.deg(math.atan2(d.Y, d.X))
			else
				ln.Visible = false
			end
		end
		local last = pts[GN]
		if last then g.dot.Position = UDim2.fromOffset(last.X, last.Y) end
	end
	local function panel(x, title)
		local pw = 177
		local pf = new("Frame", {Position = UDim2.fromOffset(x, 28), Size = UDim2.fromOffset(pw, 120), BackgroundColor3 = Color3.fromRGB(8, 8, 8), BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 5}, sc)
		corner(pf, 10)
		stroke(pf, Color3.fromRGB(120, 120, 120), 0.65, 1)
		mkLabel(pf, 8, 6, 70, 12, title, 10, GRAY, TITLE_FONT)
		local state = mkLabel(pf, 0, 6, pw - 8, 12, "-", 9, WHITE, HUD_FONT, Enum.TextXAlignment.Right)
		local big = mkLabel(pf, 8, 18, 120, 28, "-", 22, WHITE, TITLE_FONT)
		gradText(big)
		local info = mkLabel(pf, 8, 46, pw - 16, 12, "", 9, GRAY, HUD_FONT)
		return {big = big, state = state, info = info, g = makeLine(pf, 6, 62, pw - 12, 52)}
	end
	local pFps = panel(10, "FPS")
	local pPing = panel(197, "PING")

	local V = {}
	local cw3 = (CW - 20 - 12) / 3
	local function chipAt(col, row, th, en, vs)
		return chip(sc, 10 + col * (cw3 + 6), 156 + row * 36, cw3, 30, th, en, vs)
	end
	V.mem = chipAt(0, 0, "หน่วยความจำ", "MEMORY")
	V.players = chipAt(1, 0, "ผู้เล่น", "PLAYERS")
	V.time = chipAt(2, 0, "เวลาที่อยู่", "SESSION")
	V.speed = chipAt(0, 1, "ความเร็ววิ่ง", "WALKSPEED")
	V.jump = chipAt(1, 1, "แรงกระโดด", "JUMP")
	V.pos = chipAt(2, 1, "ตำแหน่ง", "POSITION", 10)

	local fpsHist, pingHist = {}, {}
	local function push(h, v)
		h[#h + 1] = v
		if #h > GN then table.remove(h, 1) end
	end
	local function stat(h)
		local sum, mn, mx = 0, math.huge, 0
		for _, v in ipairs(h) do
			sum = sum + v
			if v < mn then mn = v end
			if v > mx then mx = v end
		end
		return sum / math.max(#h, 1), (mn == math.huge) and 0 or mn, mx
	end
	local function updPanel(pn, hist, floorMax, bigText, stTh, stEn)
		local avg, mn, mx = stat(hist)
		drawLine(pn.g, hist, math.max(floorMax, mx * 1.1))
		pn.big.Text = bigText
		pn.state.Text = (lang == "TH") and stTh or stEn
		pn.info.Text = string.format("MIN %d   AVG %d   MAX %d", math.floor(mn + 0.5), math.floor(avg + 0.5), math.floor(mx + 0.5))
	end

	-- ===== 6) รายชื่อผู้เล่นในเซิร์ฟ =====
	local pl = new("Frame", {Size = UDim2.new(1, 0, 0, 40), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(14, 14, 14), BackgroundTransparency = 0.25, BorderSizePixel = 0, LayoutOrder = 7, ZIndex = 4}, P)
	corner(pl, 12)
	stroke(pl, Color3.fromRGB(120, 120, 120), 0.6, 1)
	new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, pl)
	new("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, pl)
	local plHead = new("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Font = TITLE_FONT, TextSize = 10, TextColor3 = WHITE, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0, ZIndex = 5}, pl)
	local plHeadE = tr(plHead, "// ผู้เล่นในเซิร์ฟ", "// PLAYERS IN SERVER")
	local plRows = {}
	local function refreshPlayers()
		for _, r in ipairs(plRows) do r:Destroy() end
		plRows = {}
		local list = Players:GetPlayers()
		plHeadE.th = "// ผู้เล่นในเซิร์ฟ (" .. #list .. ")"
		plHeadE.en = "// PLAYERS IN SERVER (" .. #list .. ")"
		applyOne(plHeadE)
		for i = 1, math.min(#list, 12) do
			local p = list[i]
			local r = new("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(8, 8, 8), BackgroundTransparency = 0.2, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 5}, pl)
			corner(r, 8)
			local hs = new("ImageLabel", {Position = UDim2.fromOffset(4, 4), Size = UDim2.fromOffset(22, 22), BackgroundColor3 = Color3.fromRGB(30, 30, 30), Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=48&h=48", ZIndex = 6}, r)
			corner(hs, 11)
			mkLabel(r, 32, 2, 200, 14, p.DisplayName .. ((p == LocalPlayer) and "  (YOU)" or ""), 11)
			mkLabel(r, 32, 15, 200, 12, "@" .. p.Name, 9, GRAY, HUD_FONT)
			local cb = new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(62, 20), BackgroundColor3 = Color3.fromRGB(32, 32, 32), BackgroundTransparency = 0.15, Font = FONT, TextSize = 10, TextColor3 = WHITE, AutoButtonColor = false, ZIndex = 6}, r)
			corner(cb, 6)
			stroke(cb, Color3.fromRGB(110, 110, 110), 0.4, 1)
			fxFlat(cb, Color3.fromRGB(58, 58, 58))
			tr(cb, "คัดลอก ID", "COPY ID")
			cb.MouseButton1Click:Connect(function()
				sfx("click", nil, 1.6)
				copyToast(tostring(p.UserId), "คัดลอก ID ผู้เล่นแล้ว", "Player ID copied")
			end)
			plRows[#plRows + 1] = r
		end
	end
	refreshPlayers()
	local pendingRefresh = false
	local function queueRefresh()
		if pendingRefresh then return end
		pendingRefresh = true
		task.delay(0.5, function()
			pendingRefresh = false
			if gui.Parent then refreshPlayers() end
		end)
	end
	Players.PlayerAdded:Connect(queueRefresh)
	Players.PlayerRemoving:Connect(queueRefresh)

	-- ===== อัปเดตสด =====
	onFrame(function(t)
		if opened and currentTab == "home" then
			live.BackgroundTransparency = (math.sin(t * 4) + 1) / 2 * 0.8
		end
	end)
	onSample(function(s, t)
		if currentTab ~= "home" then return end
		clockV.Text = os.date("%H:%M:%S")
		local ch = LocalPlayer.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		if hum then
			local mx = math.max(hum.MaxHealth, 1)
			local ratio = math.clamp(hum.Health / mx, 0, 1)
			local lit = math.floor(ratio * SEG + 0.5)
			local blink = ratio < 0.3 and math.floor(t * 4) % 2 == 0
			for i = 1, SEG do
				segs[i].BackgroundTransparency = (i <= lit) and (blink and 0.6 or 0) or 0.82
			end
			hBig.Text = math.floor(hum.Health + 0.5) .. " / " .. math.floor(mx + 0.5)
			V.speed.Text = tostring(math.floor(hum.WalkSpeed * 10 + 0.5) / 10)
			local jp = hum.UseJumpPower and hum.JumpPower or hum.JumpHeight
			V.jump.Text = tostring(math.floor(jp * 10 + 0.5) / 10)
		end
		if hrp then
			local p = hrp.Position
			V.pos.Text = string.format("%d, %d, %d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z))
		end

		push(fpsHist, s.fps)
		push(pingHist, s.ping)
		local fWord = (s.fps >= 55 and {"ลื่นไหล", "SMOOTH"}) or (s.fps >= 30 and {"พอใช้", "OK"}) or {"กระตุก", "LOW"}
		local pWord = (s.ping <= 80 and {"ดีมาก", "GOOD"}) or (s.ping <= 160 and {"พอใช้", "OK"}) or {"สูง", "HIGH"}
		updPanel(pFps, fpsHist, 60, tostring(math.floor(s.fps + 0.5)), fWord[1], fWord[2])
		updPanel(pPing, pingHist, 100, math.floor(s.ping) .. " ms", pWord[1], pWord[2])

		V.mem.Text = math.floor(s.mem) .. " MB"
		V.players.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
		plV.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers
		local sec = math.floor(t)
		V.time.Text = string.format("%02d:%02d:%02d", sec // 3600, (sec % 3600) // 60, sec % 60)
	end)
end

guard("home", buildHome)

-- ===================== MM2 PAGES =====================
-- helper: สร้าง Toggle สไตล์ GUINO1 บนหน้า MM2
local function mm2Toggle(page, th, en, initState, cb)
	local r = mkCard(page, 38, nil)
	local lb = new("TextLabel", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = WHITE, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, r)
	tr(lb, th, en)
	local track = new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(42, 22), BackgroundColor3 = Color3.fromRGB(50, 50, 50), Text = "", AutoButtonColor = false, ZIndex = 5}, r)
	corner(track, 11)
	stroke(track, Color3.fromRGB(120, 120, 120), 0.4, 1)
	local knob = new("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.fromRGB(170, 170, 170), BorderSizePixel = 0, ZIndex = 6}, track)
	corner(knob, 8)
	local state = initState
	local function render(anim)
		local d = anim and 0.15 or 0
		tw(track, d, {BackgroundColor3 = state and ACCENT or Color3.fromRGB(50, 50, 50)})
		tw(knob, d, {Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(170, 170, 170)})
	end
	render(false)
	onAccent(function() render(false) end)
	track.MouseButton1Click:Connect(function()
		state = not state
		render(true)
		sfx("click", nil, 1.5)
		cb(state)
	end)
	return track
end

local function mm2Section(page, th, en)
	local h = new("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, ZIndex = 5}, page)
	local bar = new("Frame", {Position = UDim2.fromOffset(2, 4), Size = UDim2.fromOffset(3, 12), BackgroundColor3 = ACCENT, BorderSizePixel = 0, ZIndex = 5}, h)
	corner(bar, 2)
	onAccent(function(c) bar.BackgroundColor3 = c end)
	tr(mkLabel(h, 12, 3, 300, 14, "", 11, WHITE, TITLE_FONT), th, en)
end

local function mm2Btn(page, th, en, cb)
	local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(32, 32, 32), BackgroundTransparency = 0.15, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE, AutoButtonColor = false, ZIndex = 4}, page)
	corner(b, 10)
	stroke(b, Color3.fromRGB(110, 110, 110), 0.4, 1)
	fxFlat(b, Color3.fromRGB(58, 58, 58))
	tr(b, th, en)
	b.MouseButton1Click:Connect(function() sfx("click", nil, 1.6) cb() end)
	return b
end

-- ===== RADAR =====
local function buildRadar()
	local P = Pages.mm_radar
	mm2Section(P, "// เรดาร์ MM2", "// MM2 RADAR")
	local radarOn = false
	local radarConn
	mm2Toggle(P, "เรดาร์ผู้เล่น (ESP)", "Player Radar (ESP)", false, function(v)
		radarOn = v
		if v then
			radarConn = RunService.RenderStepped:Connect(function()
				local lp = Players.LocalPlayer
				local ch = lp and lp.Character
				local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= lp then
						local pc = p.Character
						local pp = pc and pc:FindFirstChild("HumanoidRootPart")
						if pp then
							local d = math.floor((hrp.Position - pp.Position).Magnitude)
							-- แสดง highlight ถ้ารองรับ
							pcall(function()
								local hum = pc:FindFirstChildOfClass("Humanoid")
								if hum then hum.HealthDisplayDistance = 999 hum.NameDisplayDistance = 999 end
							end)
						end
					end
				end
			end)
		else
			if radarConn then radarConn:Disconnect() radarConn = nil end
		end
	end)
	mm2Toggle(P, "แสดงชื่อผู้เล่นทุกคน", "Show all player names", false, function(v)
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Players.LocalPlayer then
				pcall(function()
					local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum.NameDisplayDistance = v and 999 or 100 end
				end)
			end
		end
	end)
	mm2Toggle(P, "แสดง HP ผู้เล่นทุกคน", "Show all player HP", false, function(v)
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Players.LocalPlayer then
				pcall(function()
					local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum.HealthDisplayDistance = v and 999 or 100 end
				end)
			end
		end
	end)
end
guard("mm_radar", buildRadar)

-- ===== WARP =====
local function buildWarp()
	local P = Pages.mm_warp
	local TeleportService = game:GetService("TeleportService")
	mm2Section(P, "// วาร์ป", "// WARP / TELEPORT")
	local lbl = mkLabel(P, 0, 0, 384, 14, "", 10, GRAY, HUD_FONT)
	tr(lbl, "แตะที่ชื่อผู้เล่นเพื่อวาร์ปไปหา", "Tap a player name to teleport to them")
	local list = mkCard(P, 20, nil)
	list.AutomaticSize = Enum.AutomaticSize.Y
	new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, list)
	new("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)}, list)
	local function refreshWarp()
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		local lp = Players.LocalPlayer
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				local b = new("TextButton", {Size = UDim2.new(1,0,0,30), BackgroundColor3 = Color3.fromRGB(32,32,32), BackgroundTransparency = 0.2, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE, AutoButtonColor = false, ZIndex = 5}, list)
				corner(b, 8)
				fxFlat(b, Color3.fromRGB(58,58,58))
				tr(b, p.DisplayName .. " (@" .. p.Name .. ")", p.DisplayName .. " (@" .. p.Name .. ")")
				b.MouseButton1Click:Connect(function()
					sfx("click", nil, 1.6)
					local pc = p.Character
					local pp = pc and pc:FindFirstChild("HumanoidRootPart")
					local lch = lp.Character
					local lhrp = lch and lch:FindFirstChild("HumanoidRootPart")
					if pp and lhrp then
						lhrp.CFrame = pp.CFrame + Vector3.new(0, 3, 0)
						toast("วาร์ปไปหา " .. p.Name, "Warped to " .. p.Name)
					else
						toast("ไม่พบตัวละคร", "Character not found")
					end
				end)
			end
		end
	end
	refreshWarp()
	Players.PlayerAdded:Connect(refreshWarp)
	Players.PlayerRemoving:Connect(refreshWarp)
	mm2Btn(P, "รีเฟรชรายชื่อ", "Refresh list", refreshWarp)
end
guard("mm_warp", buildWarp)

-- ===== FLING =====
local function buildFling()
	local P = Pages.mm_fling
	mm2Section(P, "// ฟลิ้ง", "// FLING")
	local flingOn = false
	local flingConn
	local speedVal = 300
	mm2Toggle(P, "เปิดฟลิ้ง (กดเข้าหาคน)", "Enable Fling (walk into players)", false, function(v)
		flingOn = v
		if v then
			flingConn = RunService.Stepped:Connect(function()
				local lp = Players.LocalPlayer
				local ch = lp and lp.Character
				local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= lp then
						local pc = p.Character
						local pp = pc and pc:FindFirstChild("HumanoidRootPart")
						if pp and (hrp.Position - pp.Position).Magnitude < 8 then
							local dir = (pp.Position - hrp.Position).Unit
							pcall(function() pp.AssemblyLinearVelocity = dir * speedVal + Vector3.new(0, speedVal * 0.5, 0) end)
						end
					end
				end
			end)
		else
			if flingConn then flingConn:Disconnect() flingConn = nil end
		end
	end)
	local speedLbl = mkLabel(P, 0, 0, 384, 14, "ความแรง: " .. speedVal, 11, GRAY, HUD_FONT)
	local track = new("TextButton", {Size = UDim2.new(1,0,0,8), BackgroundColor3 = Color3.fromRGB(50,50,50), Text = "", AutoButtonColor = false, ZIndex = 5}, P)
	corner(track, 4)
	local fill = new("Frame", {Size = UDim2.fromScale((speedVal-50)/(1000-50),1), BackgroundColor3 = ACCENT, BorderSizePixel = 0, ZIndex = 6}, track)
	corner(fill, 4)
	onAccent(function(c) fill.BackgroundColor3 = c end)
	local dragging = false
	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local t = math.clamp((i.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
			speedVal = math.floor(50 + t * 950)
			fill.Size = UDim2.fromScale(t, 1)
			speedLbl.Text = "ความแรง: " .. speedVal
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end
guard("mm_fling", buildFling)

-- ===== HUNTER =====
local function buildHunter()
	local P = Pages.mm_hunter
	mm2Section(P, "// โหมดล่า", "// HUNTER MODE")
	mm2Toggle(P, "ไฮไลท์ผู้ต้องสงสัย", "Highlight suspects", false, function(v)
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Players.LocalPlayer then
				pcall(function()
					local ch = p.Character
					if ch then
						for _, part in ipairs(ch:GetDescendants()) do
							if part:IsA("BasePart") then
								part.Material = v and Enum.Material.Neon or Enum.Material.SmoothPlastic
							end
						end
					end
				end)
			end
		end
	end)
	mm2Toggle(P, "สปีดสำหรับล่า", "Speed boost for hunting", false, function(v)
		local ch = Players.LocalPlayer.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v and 32 or 16 end
	end)
	mm2Toggle(P, "กระโดดสูงสำหรับล่า", "High jump for hunting", false, function(v)
		local ch = Players.LocalPlayer.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum then hum.JumpPower = v and 80 or 50 end
	end)
end
guard("mm_hunter", buildHunter)

-- ===== PLAYER =====
local function buildPlayer()
	local P = Pages.mm_player
	mm2Section(P, "// ตัวละคร", "// PLAYER MODS")
	local lp = Players.LocalPlayer
	local function getHum()
		local ch = lp.Character
		return ch and ch:FindFirstChildOfClass("Humanoid")
	end
	local function getHRP()
		local ch = lp.Character
		return ch and ch:FindFirstChild("HumanoidRootPart")
	end
	local function labelSlider(th, en, minV, maxV, init, apply)
		local card = mkCard(P, 50, nil)
		tr(mkLabel(card, 12, 4, 300, 16, "", 12), th, en)
		local valLbl = mkLabel(card, 0, 4, 372, 16, tostring(init), 11, GRAY, HUD_FONT, Enum.TextXAlignment.Right)
		local track = new("TextButton", {Position = UDim2.new(0,12,0,30), Size = UDim2.new(1,-24,0,8), BackgroundColor3 = Color3.fromRGB(50,50,50), Text = "", AutoButtonColor = false, ZIndex = 5}, card)
		corner(track, 4)
		local fill = new("Frame", {Size = UDim2.fromScale(math.clamp((init-minV)/(maxV-minV),0,1),1), BackgroundColor3 = ACCENT, BorderSizePixel = 0, ZIndex = 6}, track)
		corner(fill, 4)
		onAccent(function(c) fill.BackgroundColor3 = c end)
		local function fromX(x)
			local t = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
			local v = math.floor(minV + (maxV - minV) * t)
			fill.Size = UDim2.fromScale(t, 1)
			valLbl.Text = tostring(v)
			apply(v)
		end
		local d = false
		track.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				d = true fromX(i.Position.X)
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fromX(i.Position.X) end
		end)
		UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end
		end)
	end
	labelSlider("ความเร็วเดิน", "WalkSpeed", 0, 200, 16, function(v)
		local h = getHum() if h then h.WalkSpeed = v end
	end)
	labelSlider("แรงกระโดด", "JumpPower", 0, 200, 50, function(v)
		local h = getHum() if h then h.JumpPower = v end
	end)
	mm2Toggle(P, "โน้คลิปผ่านกำแพง", "Noclip", false, function(v)
		local conn
		if v then
			conn = RunService.Stepped:Connect(function()
				local ch = lp.Character
				if ch then
					for _, p in ipairs(ch:GetDescendants()) do
						if p:IsA("BasePart") then p.CanCollide = false end
					end
				end
			end)
		else
			if conn then conn:Disconnect() conn = nil end
			local ch = lp.Character
			if ch then
				for _, p in ipairs(ch:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = true end
				end
			end
		end
	end)
	mm2Toggle(P, "บินได้", "Fly mode", false, function(v)
		local ch = lp.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		if hrp then
			local bg = hrp:FindFirstChildOfClass("BodyGyro")
			local bv = hrp:FindFirstChildOfClass("BodyVelocity")
			if v then
				local g = Instance.new("BodyGyro") g.MaxTorque = Vector3.new(1e5,1e5,1e5) g.P = 1e4 g.Parent = hrp
				local vel = Instance.new("BodyVelocity") vel.MaxForce = Vector3.new(1e5,1e5,1e5) vel.Velocity = Vector3.zero vel.Parent = hrp
				local conn
				conn = RunService.RenderStepped:Connect(function()
					if not hrp or not hrp.Parent then conn:Disconnect() return end
					local cam = workspace.CurrentCamera
					local dir = Vector3.zero
					if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
					if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
					if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
					if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
					if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
					if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
					local spd = 50
					vel.Velocity = dir.Magnitude > 0 and dir.Unit * spd or Vector3.zero
					g.CFrame = cam.CFrame
				end)
			else
				if bg then bg:Destroy() end
				if bv then bv:Destroy() end
			end
		end
	end)
end
guard("mm_player", buildPlayer)

-- ===== FARM =====
local function buildFarm()
	local P = Pages.mm_farm
	mm2Section(P, "// ฟาร์มเหรียญ", "// COIN FARM")
	mm2Toggle(P, "เก็บเหรียญอัตโนมัติ (ถ้ารองรับ)", "Auto collect coins (if supported)", false, function(v)
		if v then
			task.spawn(function()
				while v do
					for _, obj in ipairs(workspace:GetDescendants()) do
						if obj.Name:lower():find("coin") or obj.Name:lower():find("gold") then
							local lp = Players.LocalPlayer
							local ch = lp and lp.Character
							local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
							if hrp and obj:IsA("BasePart") then
								pcall(function() hrp.CFrame = CFrame.new(obj.Position) end)
							end
						end
					end
					task.wait(0.1)
				end
			end)
		end
	end)
	mkLabel(P, 0, 0, 384, 30, "⚠ ใช้ในเกมที่เหรียญสัมผัสได้เท่านั้น", 10, GRAY, HUD_FONT)
end
guard("mm_farm", buildFarm)

-- ===== EVENT =====
local function buildEvent()
	local P = Pages.mm_event
	mm2Section(P, "// อีเวนท์", "// EVENT")
	mkLabel(P, 0, 0, 384, 20, "เครื่องมืออีเวนท์ MM2 ตามฤดูกาล", 11, GRAY, HUD_FONT)
	mm2Btn(P, "เก็บไอเทมอีเวนท์อัตโนมัติ", "Auto collect event items", function()
		task.spawn(function()
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj.Name:lower():find("event") or obj.Name:lower():find("candy") or obj.Name:lower():find("egg") then
					local lp = Players.LocalPlayer
					local ch = lp and lp.Character
					local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
					if hrp and obj:IsA("BasePart") then
						pcall(function() hrp.CFrame = CFrame.new(obj.Position) end)
						task.wait(0.05)
					end
				end
			end
			toast("สแกนเสร็จแล้ว", "Scan complete")
		end)
	end)
end
guard("mm_event", buildEvent)

-- ===== MUSIC =====
local function buildMusic()
	local P = Pages.music
	mm2Section(P, "// เพลง", "// MUSIC")
	local curSound
	local function playId(id)
		if curSound then pcall(function() curSound:Destroy() end) end
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://" .. tostring(id)
		s.Volume = MASTER_VOL
		s.Looped = true
		s.Parent = SoundService
		s:Play()
		curSound = s
		toast("เล่นเพลง ID: " .. id, "Playing ID: " .. id)
	end
	local tb = new("TextBox", {Size = UDim2.new(1,0,0,30), BackgroundColor3 = Color3.fromRGB(8,8,8), BackgroundTransparency = 0.2, Font = HUD_FONT, TextSize = 12, TextColor3 = WHITE, PlaceholderText = "ใส่ Sound ID ที่นี่...", Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, P)
	corner(tb, 10)
	stroke(tb, Color3.fromRGB(110,110,110), 0.4, 1)
	new("UIPadding", {PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10)}, tb)
	mm2Btn(P, "เล่นเพลง", "Play Music", function()
		local id = tonumber(tb.Text)
		if id then playId(id) else toast("ใส่ Sound ID ให้ถูกต้อง", "Enter a valid Sound ID") end
	end)
	mm2Btn(P, "หยุดเพลง", "Stop Music", function()
		if curSound then pcall(function() curSound:Destroy() end) curSound = nil end
		toast("หยุดเพลงแล้ว", "Music stopped")
	end)
end
guard("music", buildMusic)

-- ===== IDENTITY =====
local function buildIdentity()
	local P = Pages.identity
	mm2Section(P, "// ชื่อปลอม", "// FAKE IDENTITY")
	local tb = new("TextBox", {Size = UDim2.new(1,0,0,30), BackgroundColor3 = Color3.fromRGB(8,8,8), BackgroundTransparency = 0.2, Font = HUD_FONT, TextSize = 12, TextColor3 = WHITE, PlaceholderText = "ใส่ชื่อใหม่...", Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, P)
	corner(tb, 10)
	stroke(tb, Color3.fromRGB(110,110,110), 0.4, 1)
	new("UIPadding", {PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10)}, tb)
	mm2Btn(P, "ตั้งชื่อปลอม (เฉพาะ GUI)", "Set fake name (GUI only)", function()
		local n = tb.Text
		if n ~= "" then
			pcall(function()
				local ch = Players.LocalPlayer.Character
				local hum = ch and ch:FindFirstChildOfClass("Humanoid")
				if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
			end)
			toast("ซ่อนชื่อจริงแล้ว: " .. n, "Real name hidden: " .. n)
		else
			toast("ใส่ชื่อก่อน", "Enter a name first")
		end
	end)
	mm2Btn(P, "รีเซ็ตชื่อ", "Reset name", function()
		pcall(function()
			local ch = Players.LocalPlayer.Character
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject end
		end)
		toast("รีเซ็ตชื่อแล้ว", "Name reset")
	end)
end
guard("identity", buildIdentity)

-- ===== INVISIBLE =====
local function buildInvisible()
	local P = Pages.invisible
	mm2Section(P, "// ล่องหน", "// INVISIBLE")
	mm2Toggle(P, "ล่องหน (ซ่อนตัวละคร)", "Invisible (hide character)", false, function(v)
		local lp = Players.LocalPlayer
		local ch = lp and lp.Character
		if ch then
			for _, part in ipairs(ch:GetDescendants()) do
				if part:IsA("BasePart") or part:IsA("Decal") then
					pcall(function() part.LocalTransparencyModifier = v and 1 or 0 end)
				end
			end
		end
		toast(v and "ล่องหนแล้ว" or "แสดงตัวแล้ว", v and "Invisible" or "Visible")
	end)
	mkLabel(P, 0, 0, 384, 30, "⚠ เฉพาะไคลเอนต์ ผู้เล่นอื่นยังเห็นคุณ", 10, GRAY, HUD_FONT)
end
guard("invisible", buildInvisible)

-- ===== ANIMATIONS =====
local function buildAnimations()
	local P = Pages.animations
	mm2Section(P, "// แอนิเมชัน", "// ANIMATIONS")
	local anims = {
		{"R15 Dance",   "507771019"},
		{"R15 Swim",    "507784897"},
		{"Superheroes", "507785153"},
		{"Robot",       "507766388"},
		{"Ninja",       "507776104"},
	}
	for _, a in ipairs(anims) do
		local name, id = a[1], a[2]
		mm2Btn(P, name, name, function()
			local lp = Players.LocalPlayer
			local ch = lp and lp.Character
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			if hum then
				local track = hum:LoadAnimation(Instance.new("Animation"))
				pcall(function()
					local anim = Instance.new("Animation")
					anim.AnimationId = "rbxassetid://" .. id
					local t = hum:LoadAnimation(anim)
					t:Play()
				end)
			else
				toast("ไม่พบตัวละคร", "Character not found")
			end
		end)
	end
end
guard("animations", buildAnimations)

-- ===== ITEMS =====
local function buildItems()
	local P = Pages.items
	mm2Section(P, "// ไอเทม", "// ITEMS")
	mkLabel(P, 0, 0, 384, 20, "ค้นหาไอเทมในเกมปัจจุบัน", 11, GRAY, HUD_FONT)
	local list = mkCard(P, 20, nil)
	list.AutomaticSize = Enum.AutomaticSize.Y
	new("UIListLayout", {Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder}, list)
	new("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)}, list)
	local function scanItems()
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
		end
		local found = 0
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Tool") and found < 20 then
				found = found + 1
				local b = new("TextButton", {Size = UDim2.new(1,0,0,26), BackgroundColor3 = Color3.fromRGB(32,32,32), BackgroundTransparency = 0.2, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = WHITE, AutoButtonColor = false, ZIndex = 5, Text = obj.Name}, list)
				corner(b, 7)
				fxFlat(b, Color3.fromRGB(58,58,58))
				b.MouseButton1Click:Connect(function()
					sfx("click", nil, 1.6)
					local lp = Players.LocalPlayer
					local ch = lp and lp.Character
					local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
					if hrp and obj.Parent then
						pcall(function() hrp.CFrame = CFrame.new(obj:IsA("Tool") and obj.Handle and obj.Handle.Position or hrp.Position) end)
					end
				end)
			end
		end
		if found == 0 then
			local l = mkLabel(list, 0, 0, 384, 20, "ไม่พบไอเทมในเกม", 10, GRAY, HUD_FONT)
			l.Size = UDim2.new(1,0,0,20)
		end
	end
	scanItems()
	mm2Btn(P, "สแกนไอเทมใหม่", "Rescan items", scanItems)
end
guard("items", buildItems)

-- ===== LIGHTING =====
local function buildLighting()
	local P = Pages.lighting
	local Lighting = game:GetService("Lighting")
	mm2Section(P, "// แสงฉาก", "// SCENE LIGHTING")
	mm2Toggle(P, "Fullbright (สว่างสุด)", "Fullbright (max brightness)", false, function(v)
		pcall(function()
			Lighting.Brightness = v and 10 or 2
			Lighting.ClockTime = v and 14 or 14
			Lighting.FogEnd = v and 1e6 or 1e4
			Lighting.GlobalShadows = not v
		end)
	end)
	local ambients = {
		{"กลางวัน", "Daytime",    14, Color3.fromRGB(255,255,255)},
		{"夕方",    "Sunset",     17.5, Color3.fromRGB(255,180,100)},
		{"กลางคืน","Night",       0, Color3.fromRGB(50,50,100)},
		{"ตีสี่",   "Late Night", 4, Color3.fromRGB(20,20,60)},
	}
	for _, a in ipairs(ambients) do
		local th, en, clock, amb = a[1], a[2], a[3], a[4]
		mm2Btn(P, th, en, function()
			pcall(function()
				Lighting.ClockTime = clock
				Lighting.Ambient = amb
			end)
			toast("ตั้งค่าแสงเป็น " .. th, "Lighting set to " .. en)
		end)
	end
end
guard("lighting", buildLighting)

-- ===================== หมวดตั้งค่า =====================
local function buildSettings()
	local P = Pages.settings
	local TeleportService = game:GetService("TeleportService")
	local Lighting = game:GetService("Lighting")
	local FONT = Enum.Font.GothamBold
	local CW = 384
	local MAXP = 1 -- ถือว่า "ว่าง" เมื่อมีผู้เล่นไม่เกินกี่คน
	local order = 0
	local function nextOrder()
		order = order + 1
		return order
	end
	local function pct(v) return math.floor(v * 100 + 0.5) .. "%" end

	local function section(th, en)
		local h = new("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = nextOrder(), ZIndex = 5}, P)
		local bar = new("Frame", {Position = UDim2.fromOffset(2, 4), Size = UDim2.fromOffset(3, 12), BackgroundColor3 = ACCENT, BorderSizePixel = 0, ZIndex = 5}, h)
		corner(bar, 2)
		onAccent(function(c) bar.BackgroundColor3 = c end)
		tr(mkLabel(h, 12, 3, 300, 14, "", 11, WHITE, TITLE_FONT), th, en)
	end
	local function row(h) return mkCard(P, h, nextOrder()) end

	-- สวิตช์เปิด/ปิด
	local function toggle(th, en, init, cb)
		local r = row(38)
		local lb = new("TextLabel", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1, Font = FONT, TextSize = 13, TextColor3 = WHITE, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, r)
		tr(lb, th, en)
		local track = new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(42, 22), BackgroundColor3 = Color3.fromRGB(50, 50, 50), Text = "", AutoButtonColor = false, ZIndex = 5}, r)
		corner(track, 11)
		stroke(track, Color3.fromRGB(120, 120, 120), 0.4, 1)
		local knob = new("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.fromRGB(170, 170, 170), BorderSizePixel = 0, ZIndex = 6}, track)
		corner(knob, 8)
		local state = init
		local function render(anim)
			local d = anim and 0.15 or 0
			tw(track, d, {BackgroundColor3 = state and ACCENT or Color3.fromRGB(50, 50, 50)})
			tw(knob, d, {Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = state and onAccentText(ACCENT) or Color3.fromRGB(170, 170, 170)})
		end
		render(false)
		onAccent(function() render(false) end)
		track.MouseButton1Click:Connect(function()
			state = not state
			render(true)
			sfx("click", nil, 1.5)
			cb(state)
		end)
	end

	-- สไลเดอร์
	local function slider(th, en, minV, maxV, init, fmt, cb)
		local r = row(48)
		tr(mkLabel(r, 12, 5, 260, 16, "", 13), th, en)
		local val = mkLabel(r, 0, 5, 372, 16, fmt(init), 12, GRAY, HUD_FONT, Enum.TextXAlignment.Right)
		local track = new("TextButton", {Position = UDim2.new(0, 12, 0, 31), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = Color3.fromRGB(50, 50, 50), Text = "", AutoButtonColor = false, ZIndex = 5}, r)
		corner(track, 3)
		local fill = new("Frame", {Size = UDim2.fromScale(math.clamp((init - minV) / (maxV - minV), 0, 1), 1), BackgroundColor3 = ACCENT, BorderSizePixel = 0, ZIndex = 6}, track)
		corner(fill, 3)
		onAccent(function(c) fill.BackgroundColor3 = c end)
		local knob = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 7}, fill)
		corner(knob, 7)
		local function setFrac(f)
			f = math.clamp(f, 0, 1)
			fill.Size = UDim2.fromScale(f, 1)
			local v = minV + (maxV - minV) * f
			val.Text = fmt(v)
			cb(v)
		end
		local function fromInput(pos)
			setFrac((pos.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X))
		end
		local dragging = false
		track.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				fromInput(i.Position)
				i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				fromInput(i.Position)
			end
		end)
	end

	-- แถวปุ่ม (หลายปุ่มเรียงกัน)
	local function buttons(items)
		local r = row(36)
		local n = #items
		local gap = 6
		local w = (CW - 16 - gap * (n - 1)) / n
		for i, it in ipairs(items) do
			local b = new("TextButton", {Position = UDim2.fromOffset(8 + (i - 1) * (w + gap), 5), Size = UDim2.fromOffset(w, 26), BackgroundColor3 = Color3.fromRGB(32, 32, 32), BackgroundTransparency = 0.15, Font = FONT, TextSize = 11, TextColor3 = WHITE, AutoButtonColor = false, ZIndex = 5}, r)
			corner(b, 8)
			stroke(b, Color3.fromRGB(110, 110, 110), 0.4, 1)
			fxFlat(b, Color3.fromRGB(58, 58, 58))
			tr(b, it[1], it[2])
			b.MouseButton1Click:Connect(function()
				sfx("click", nil, 1.6)
				it[3](b)
			end)
		end
		return r
	end

	-- ช่องกรอกข้อความ
	local function inputRow(th, en, init, placeholder, cb)
		local r = row(58)
		tr(mkLabel(r, 12, 5, 360, 16, "", 13), th, en)
		local tb = new("TextBox", {Position = UDim2.fromOffset(10, 26), Size = UDim2.new(1, -20, 0, 26), BackgroundColor3 = Color3.fromRGB(8, 8, 8), BackgroundTransparency = 0.2, Font = HUD_FONT, TextSize = 12, TextColor3 = WHITE, PlaceholderText = placeholder, PlaceholderColor3 = Color3.fromRGB(120, 120, 120), Text = init, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, r)
		corner(tb, 8)
		stroke(tb, Color3.fromRGB(110, 110, 110), 0.4, 1)
		new("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, tb)
		tb.FocusLost:Connect(function() cb(tb.Text) end)
	end

	-- ===== เซิร์ฟเวอร์ =====
	section("// เซิร์ฟเวอร์", "// SERVER")
	buttons({
		{"หาเซิร์ฟ 0-1 คน", "Find 0-1 player", function() SRV.search() end},
		{"สุ่มย้ายเซิร์ฟ", "Server hop", function() SRV.hop() end},
		{"เข้าเกมใหม่", "Rejoin", function() SRV.rejoin() end},
	})
	local statusRow = row(28)
	local statusLbl = mkLabel(statusRow, 12, 0, 360, 28, "", 11, GRAY, HUD_FONT)
	statusLbl.TextYAlignment = Enum.TextYAlignment.Center
	local statusE = tr(statusLbl, "พร้อมค้นหาเซิร์ฟเวอร์", "Ready to search")
	local function setStatus(th, en)
		statusE.th, statusE.en = th, en
		applyOne(statusE)
	end
	local results = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nextOrder(), ZIndex = 4}, P)
	new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, results)
	buttons({
		{"คัดลอก Job ID", "Copy Job ID", function()
			copyToast(game.JobId, "คัดลอก Job ID แล้ว", "Job ID copied")
		end},
		{"คัดลอกโค้ดเข้าเซิร์ฟ", "Copy join script", function()
			local s = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game.Players.LocalPlayer)', game.PlaceId, game.JobId)
			copyToast(s, "คัดลอกโค้ดแล้ว", "Script copied")
		end},
	})

	local function httpGet(url)
		local ok, res = pcall(function() return game:HttpGet(url) end)
		if ok and type(res) == "string" and #res > 0 then return res end
		local req = (syn and syn.request) or request or http_request or (http and http.request)
		if req then
			local ok2, r = pcall(req, {Url = url, Method = "GET"})
			if ok2 and type(r) == "table" then
				local body = r.Body or r.body
				if type(body) == "string" and #body > 0 then return body end
			end
		end
		local ok3, res3 = pcall(function() return HttpService:GetAsync(url) end)
		if ok3 and type(res3) == "string" then return res3 end
		return nil
	end
	local function fetchServers(maxPages)
		local all = {}
		local cursor = ""
		for _ = 1, maxPages do
			local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&excludeFullGames=true&limit=100"
			if cursor ~= "" then url = url .. "&cursor=" .. cursor end
			local body = httpGet(url)
			if not body then break end
			local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
			if not ok or type(data) ~= "table" or type(data.data) ~= "table" then break end
			for _, s in ipairs(data.data) do all[#all + 1] = s end
			if not data.nextPageCursor then break end
			cursor = data.nextPageCursor
		end
		return all
	end
	local function joinServer(id)
		toast("กำลังย้ายเซิร์ฟเวอร์...", "Teleporting...")
		local ok = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer) end)
		if not ok then toast("ย้ายเซิร์ฟไม่สำเร็จ", "Teleport failed") end
	end
	local function clearResults()
		for _, c in ipairs(results:GetChildren()) do
			if c:IsA("Frame") then c:Destroy() end
		end
	end
	local function addResult(s, i)
		local r = mkCard(results, 32, i)
		local txt = string.format("%d/%d PLAYERS  •  PING %s  •  FPS %s", s.playing or 0, s.maxPlayers or 0, s.ping and (s.ping .. " ms") or "-", s.fps and tostring(math.floor(s.fps)) or "-")
		local l = mkLabel(r, 12, 0, 270, 32, txt, 11, WHITE, HUD_FONT)
		l.TextYAlignment = Enum.TextYAlignment.Center
		local jb = new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(66, 22), BackgroundColor3 = ACCENT, Font = FONT, TextSize = 12, TextColor3 = onAccentText(ACCENT), AutoButtonColor = false, ZIndex = 6}, r)
		corner(jb, 8)
		onAccent(function(c)
			jb.BackgroundColor3 = c
			jb.TextColor3 = onAccentText(c)
		end)
		tr(jb, "เข้าร่วม", "Join")
		jb.MouseButton1Click:Connect(function()
			sfx("click", nil, 1.6)
			joinServer(s.id)
		end)
	end

	local busy = false
	SRV.search = function()
		if busy then return end
		busy = true
		clearResults()
		setStatus("กำลังค้นหาเซิร์ฟเวอร์...", "Searching servers...")
		task.spawn(function()
			local list = fetchServers(3)
			local low = {}
			for _, s in ipairs(list) do
				if s.id ~= game.JobId and (s.playing or 0) <= MAXP then low[#low + 1] = s end
			end
			local near = false
			if #low == 0 then
				near = true
				for _, s in ipairs(list) do
					if s.id ~= game.JobId then low[#low + 1] = s end
				end
			end
			table.sort(low, function(a, b) return (a.playing or 0) < (b.playing or 0) end)
			if #list == 0 then
				setStatus("ดึงข้อมูลไม่ได้ (เน็ตหรือโดนจำกัดความถี่) ลองใหม่อีกครั้ง", "Could not fetch servers (network or rate limit). Try again")
			elseif #low == 0 then
				setStatus("ไม่พบเซิร์ฟเวอร์อื่น", "No other servers found")
			else
				for i = 1, math.min(#low, 8) do addResult(low[i], i) end
				if near then
					setStatus("ไม่มีเซิร์ฟ 0-1 คน แสดงเซิร์ฟที่คนน้อยที่สุดแทน", "No 0-1 player servers. Showing the emptiest ones")
				else
					setStatus("พบ " .. #low .. " เซิร์ฟที่มี 0-1 คน", "Found " .. #low .. " servers with 0-1 players")
				end
			end
			busy = false
		end)
	end
	SRV.hop = function()
		if busy then return end
		busy = true
		setStatus("กำลังหาเซิร์ฟเวอร์ให้ย้าย...", "Looking for a server...")
		task.spawn(function()
			local list = fetchServers(2)
			local pool = {}
			for _, s in ipairs(list) do
				if s.id ~= game.JobId and (s.playing or 0) < (s.maxPlayers or 0) then pool[#pool + 1] = s end
			end
			busy = false
			if #pool == 0 then
				setStatus("ไม่พบเซิร์ฟเวอร์ให้ย้าย", "No server to hop to")
				toast("ไม่พบเซิร์ฟเวอร์ให้ย้าย", "No server to hop to")
				return
			end
			joinServer(pool[math.random(1, #pool)].id)
		end)
	end
	SRV.rejoin = function()
		toast("กำลังเข้าเกมใหม่...", "Rejoining...")
		pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
	end

	-- ===== รูปลักษณ์ =====
	section("// รูปลักษณ์", "// APPEARANCE")
	do
		local r = row(60)
		tr(mkLabel(r, 12, 5, 300, 16, "", 13), "ธีมสี", "Theme color")
		local rings = {}
		for i, th in ipairs(THEMES) do
			local b = new("TextButton", {Position = UDim2.fromOffset(12 + (i - 1) * 42, 26), Size = UDim2.fromOffset(30, 30), BackgroundColor3 = th[3], Text = "", AutoButtonColor = false, ZIndex = 5}, r)
			corner(b, 15)
			rings[i] = stroke(b, WHITE, (i == themeIdx) and 0 or 1, 2)
			b.MouseButton1Click:Connect(function()
				setAccent(i)
				for j, st in ipairs(rings) do st.Transparency = (j == i) and 0 or 1 end
				sfx("click", nil, 1.6)
				saveSettings()
			end)
		end
	end
	slider("ความมืดพื้นหลัง", "Background dim", 0, 0.8, BG_DIM, pct, function(v)
		BG_DIM = v
		Dim.BackgroundTransparency = 1 - v
		saveSettings()
	end)
	slider("ขนาด GUI", "GUI size", 0.7, 1.4, userScale, pct, function(v)
		userScale = v
		if opened then scale.Scale = target() end
		saveSettings()
	end)
	slider("ความโปร่งใสหน้าต่าง", "Window opacity", 0.5, 1, uiOpacity, pct, function(v)
		uiOpacity = v
		if opened then Main.GroupTransparency = 1 - v end
		saveSettings()
	end)

	-- ===== เสียงและเอฟเฟค =====
	section("// เสียงและเอฟเฟค", "// SOUND & EFFECTS")
	toggle("เสียง", "Sound", SOUND_ON, function(v)
		SOUND_ON = v
		saveSettings()
	end)
	slider("ระดับเสียง", "Volume", 0, 1, MASTER_VOL, pct, function(v)
		MASTER_VOL = v
		saveSettings()
	end)
	toggle("เอฟเฟค (สายฟ้า/ประกาย)", "Effects (lightning/sparks)", EFFECTS_ON, function(v)
		EFFECTS_ON = v
		saveSettings()
	end)

	-- ===== เครื่องมือในเกม =====
	section("// เครื่องมือในเกม", "// GAME TOOLS")
	local camNow = workspace.CurrentCamera
	slider("มุมมองกล้อง (FOV)", "Camera FOV", 50, 120, camNow and camNow.FieldOfView or 70, function(v) return math.floor(v + 0.5) .. " deg" end, function(v)
		pcall(function() workspace.CurrentCamera.FieldOfView = v end)
	end)

	local afkConn
	toggle("กันโดนเตะเมื่อ AFK", "Anti-AFK", false, function(v)
		if v then
			afkConn = LocalPlayer.Idled:Connect(function()
				pcall(function()
					local VU = game:GetService("VirtualUser")
					VU:CaptureController()
					VU:ClickButton2(Vector2.new())
				end)
			end)
		elseif afkConn then
			afkConn:Disconnect()
			afkConn = nil
		end
	end)

	local rejoinConn
	toggle("เข้าเกมใหม่อัตโนมัติเมื่อหลุด", "Auto rejoin on disconnect", false, function(v)
		if v then
			task.spawn(function()
				pcall(function()
					local CoreGui = game:GetService("CoreGui")
					local overlay = CoreGui:WaitForChild("RobloxPromptGui", 5):WaitForChild("promptOverlay", 5)
					rejoinConn = overlay.ChildAdded:Connect(function(c)
						if c.Name == "ErrorPrompt" then
							task.wait(1.5)
							pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
						end
					end)
				end)
			end)
		elseif rejoinConn then
			rejoinConn:Disconnect()
			rejoinConn = nil
		end
	end)

	local saved
	toggle("โหมดประหยัด FPS", "FPS saver", false, function(v)
		pcall(function()
			if v then
				saved = {shadows = Lighting.GlobalShadows, quality = settings().Rendering.QualityLevel}
				Lighting.GlobalShadows = false
				settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			elseif saved then
				Lighting.GlobalShadows = saved.shadows
				settings().Rendering.QualityLevel = saved.quality
			end
		end)
	end)

	local caps = {30, 60, 120, 999}
	local capI = 0
	buttons({
		{"จำกัด FPS", "FPS cap", function(b)
			if not setfpscap then
				toast("เครื่องนี้ไม่รองรับจำกัด FPS", "FPS cap not supported")
				return
			end
			capI = capI % #caps + 1
			setfpscap(caps[capI])
			b.Text = "FPS: " .. (caps[capI] >= 999 and "MAX" or tostring(caps[capI]))
		end},
		{"รีเซ็ตตำแหน่ง GUI", "Reset GUI position", function()
			Win.Position = UDim2.fromScale(0.5, 0.5)
			Float.Position = UDim2.new(0, 16, 0.5, -32)
			toast("รีเซ็ตตำแหน่งแล้ว", "Position reset")
		end},
	})

	-- ===== ระบบ =====
	section("// ระบบ", "// SYSTEM")
	toggle("บันทึกการตั้งค่าอัตโนมัติ", "Auto-save settings", AUTOSAVE, function(v)
		AUTOSAVE = v
		saveSettings(true)
	end)
	local function debugInfo()
		local ex = "?"
		pcall(function()
			if identifyexecutor then ex = identifyexecutor() end
		end)
		return string.format("%s | exec=%s | place=%d | job=%s | players=%d | fps=%d | ping=%d | view=%dx%d | lang=%s", VERSION, tostring(ex), game.PlaceId, game.JobId, #Players:GetPlayers(), math.floor(S.fps), math.floor(S.ping), math.floor(vp.X), math.floor(vp.Y), lang)
	end
	buttons({
		{"คัดลอกข้อมูลดีบัก", "Copy debug info", function()
			copyToast(debugInfo(), "คัดลอกข้อมูลดีบักแล้ว", "Debug info copied")
		end},
		{"ล้างค่าที่บันทึก", "Clear saved settings", function()
			pcall(function()
				if isfile and delfile and isfile(SAVE_FILE) then delfile(SAVE_FILE) end
			end)
			toast("ล้างค่าที่บันทึกแล้ว (มีผลตอนรันใหม่)", "Saved settings cleared (applies next run)")
		end},
	})

	-- ===== รันสคริปต์อัตโนมัติหลังเข้าเกมใหม่ =====
	toggle("รันสคริปต์อัตโนมัติหลังเข้าเกมใหม่", "Auto-run script after rejoin", AUTORUN_ON, function(v)
		AUTORUN_ON = v
		saveSettings()
		if v then
			if queueAutorun() then
				toast("ตั้งคิวรันอัตโนมัติแล้ว", "Auto-run queued")
			else
				toast("ตัวรันนี้ไม่รองรับ queue_on_teleport", "Executor lacks queue_on_teleport")
			end
		end
	end)
	inputRow("ลิงก์สคริปต์ (เว้นว่าง = ใช้ไฟล์ GUINO1.lua)", "Script URL (empty = use GUINO1.lua)", AUTORUN_URL, "https://...", function(txt)
		local u = (txt or ""):gsub("^%s+", ""):gsub("%s+$", "")
		AUTORUN_URL = u
		saveSettings()
		toast("บันทึกลิงก์สคริปต์แล้ว", "Script URL saved")
	end)
	buttons({
		{"ทดสอบตั้งคิวรัน", "Test queue", function()
			if queueAutorun() then
				toast("ตั้งคิวแล้ว จะรันตอนย้ายเซิร์ฟครั้งถัดไป", "Queued for the next teleport")
			else
				toast("ตัวรันนี้ไม่รองรับ queue_on_teleport", "Executor lacks queue_on_teleport")
			end
		end},
		{"ติดตั้ง autoexec", "Install autoexec", function()
			local ok = pcall(function()
				if makefolder and isfolder and not isfolder("autoexec") then makefolder("autoexec") end
				writefile("autoexec/GUINO1_loader.lua", autorunCode())
			end)
			toast(ok and "เขียนไฟล์ autoexec แล้ว" or "เขียนไฟล์ autoexec ไม่ได้", ok and "autoexec file written" or "Could not write autoexec file")
		end},
	})

	local hint = row(46)
	local hl = mkLabel(hint, 12, 4, 360, 38, "", 11, GRAY, HUD_FONT)
	hl.TextWrapped = true
	hl.TextYAlignment = Enum.TextYAlignment.Center
	tr(hl, "คีย์ลัด: กด RightShift เพื่อเปิด/ปิด GUI  •  " .. VERSION, "Hotkey: press RightShift to toggle the GUI  •  " .. VERSION)
end

guard("settings", buildSettings)

end

local __ok, __err = xpcall(__main, function(e) return tostring(e) .. "\n" .. debug.traceback("", 2) end)
if not __ok then showError("main", __err) end
