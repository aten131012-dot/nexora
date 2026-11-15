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
local HUB_TITLE = "NEXORA MM2"
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
local SAVE_FILE = "MM2_settings.json"
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
local AUTORUN_FILE = "MM2.lua" -- ชื่อไฟล์สคริปต์ในโฟลเดอร์ workspace ของตัวรัน
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
makePage("radar")
makePage("warp")
makePage("fling")
makePage("hunter")
makePage("player")
makePage("coinfarm")
makePage("event")
makePage("music")
makePage("identity")
makePage("invisible")
makePage("animations")
makePage("items")
makePage("lighting")

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
navBtn("star", "📡 เรดาร์", "📡 RADAR", "radar", false)
navBtn("star", "🚀 WARP", "🚀 WARP", "warp", false)
navBtn("star", "💥 FLING", "💥 FLING", "fling", false)
navBtn("star", "🎯 HUNTER", "🎯 HUNTER", "hunter", false)
navBtn("user", "🧍 PLAYER", "🧍 PLAYER", "player", false)
navBtn("star", "🪙 COIN FARM", "🪙 COIN FARM", "coinfarm", false)
navBtn("list", "🎉 EVENT", "🎉 EVENT", "event", false)
navBtn("list", "🎵 MUSIC", "🎵 MUSIC", "music", false)
navBtn("user", "🎭 IDENTITY", "🎭 IDENTITY", "identity", false)
navBtn("star", "👻 INVISIBLE", "👻 INVISIBLE", "invisible", false)
navBtn("list", "🕺 ANIMATIONS", "🕺 ANIMATIONS", "animations", false)
navBtn("list", "🎒 ITEMS", "🎒 ITEMS", "items", false)
navBtn("list", "💡 LIGHTING", "💡 LIGHTING", "lighting", false)
navBtn("gear", "⚙️ ตั้งค่า", "⚙️ SETTINGS", "settings", true)
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

-- ===================== NX Compatibility Bridge (ให้ MM2 functions ใช้งานได้) =====================
-- MM2 ใช้ getgenv().NX เป็น bridge — สร้างให้ตรงกับ Pages/helpers ของ GUINO1
do
	local function nxLang() return lang end
	local nxLangHooks = {}
	local function nxSetLang(l)
		lang = l
		applyLang()
		for _, fn in ipairs(nxLangHooks) do pcall(fn, l) end
	end
	-- pages ของ MM2 ใช้ชื่อ "mm_xxx" — แมปกลับไปหา Pages ของ GUINO1
	local nxPages = setmetatable({}, {
		__index = function(_, k)
			-- ตรงๆ: mm_radar → Pages.radar ฯลฯ
			local mapped = k:gsub("^mm_", "")
			if mapped == "farm" then mapped = "coinfarm" end
			return Pages[mapped] or Pages[k]
		end
	})
	-- เพิ่ม alias ตรงๆ ด้วย (identity/invisible/animations/items/lighting/music/event ไม่มี mm_ prefix ใน MM2)
	for _, k in ipairs({"identity","invisible","animations","items","lighting","music","event","radar","warp","fling","hunter","player","coinfarm"}) do
		nxPages[k] = Pages[k]
	end
	nxPages["mm_farm"] = Pages.coinfarm
	-- NX.L = ฟังก์ชัน tr ของ GUINO1 (register ภาษา)
	local function nxL(obj, en, th)
		return tr(obj, th, en) -- GUINO1 tr(obj, th, en) — MM2 L(obj, en, th) สลับ order
	end
	getgenv().NX = {
		COL = {
			Bg    = Color3.fromRGB(12, 12, 12),
			Side  = Color3.fromRGB(22, 22, 22),
			Chip  = Color3.fromRGB(34, 34, 34),
			Purple= ACCENT,
			Pink  = WHITE,
			Text  = WHITE,
			Sub   = GRAY,
			Red   = Color3.fromRGB(255, 80, 110),
			Green = Color3.fromRGB(90, 230, 160),
		},
		make      = new,
		round     = function(o, r) return corner(o, r) end,
		glow      = function(o, t)
			local s = new("UIStroke", {Thickness = t or 1.5, Color = ACCENT, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
			onAccent(function(c) s.Color = c end)
			return s
		end,
		L         = nxL,
		setLang   = nxSetLang,
		getLang   = nxLang,
		onLang    = function(fn) nxLangHooks[#nxLangHooks+1] = fn end,
		content   = Content,
		sub       = SubLbl,
		side      = Side,
		pages     = nxPages,
		onAccent  = onAccent,
		setAccent = function(a, _) setAccent(1) end, -- ใช้ GUINO1 theme system
		setSpace  = function() end,
		setLogoFx = function() end,
		resetPos  = function() end,
		setImg    = function() end,
		CFG       = { DISCORD_LINK = DISCORD_LINK },
		gui       = gui,
		state     = { lang = lang, key = true },
		win       = Win,
		sc        = scale,
		setOpen   = function(v) if v then openWin() else closeWin() end end,
		isOpen    = function() return opened end,
	}
	-- sync COL.Purple กับ ACCENT เมื่อ theme เปลี่ยน
	onAccent(function(c)
		getgenv().NX.COL.Purple = c
		getgenv().NX.COL.Pink = onAccentText(c) == WHITE and Color3.fromRGB(200,200,200) or WHITE
	end)
end

-- ===================== MM2 Feature Sections (ย้ายมาจาก MM2.lua) =====================
guard("mm2_features", function()

local NX = getgenv().NX
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local env = getgenv()

local function T(en, th) return (NX.getLang() == "TH") and th or en end
local MM = { dead = false }
local conns, cleanups = {}, {}
local function bind(sig, fn) local c = sig:Connect(fn) conns[#conns+1]=c return c end
local function onUnload(fn) cleanups[#cleanups+1]=fn end
local function unload()
	if MM.dead then return end
	MM.dead = true
	for _, f in ipairs(cleanups) do pcall(f) end
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	if env.NX_MM2_UNLOAD == unload then env.NX_MM2_UNLOAD = nil end
end
if env.NX_MM2_UNLOAD then pcall(env.NX_MM2_UNLOAD) end
env.NX_MM2_UNLOAD = unload
pcall(function() if NX.gui then NX.gui.Destroying:Connect(unload) end end)

local function mk(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end
local function corner2(o, r) return mk("UICorner", {CornerRadius = UDim.new(0, r)}, o) end

-- overlay สำหรับ ESP / toast / timer
local oldUi = playerGui:FindFirstChild("NEXORA_MM2_UI")
if oldUi then oldUi:Destroy() end
local overlay = mk("ScreenGui", {Name="NEXORA_MM2_UI", ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=998}, playerGui)
onUnload(function() overlay:Destroy() end)

local toastL = mk("TextLabel", {AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,1,-60), Size=UDim2.fromOffset(280,30),
	BackgroundColor3=Color3.fromRGB(14,10,26), BackgroundTransparency=0.1, TextColor3=Color3.new(1,1,1),
	Font=Enum.Font.GothamBold, TextSize=12, Visible=false, ZIndex=50, Text=""}, overlay)
corner2(toastL, 12)
local toastId = 0
local function toast(en, th)
	toastId += 1; local id = toastId
	toastL.Text = T(en, th); toastL.Visible = true
	task.delay(1.8, function() if id==toastId then toastL.Visible=false end end)
end

-- Round Timer UI
local timerHolder = mk("Frame", {AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,0,10),
	Size=UDim2.fromOffset(200,48), BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.35,
	BorderSizePixel=0, ZIndex=45, Visible=false}, overlay)
corner2(timerHolder, 14)
mk("UIStroke", {Color=Color3.new(1,1,1), Thickness=1.2, Transparency=0.5, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, timerHolder)
mk("UIGradient", {Rotation=90, Color=ColorSequence.new(Color3.fromRGB(30,30,30), Color3.fromRGB(0,0,0))}, timerHolder)
local timerPhase = mk("TextLabel", {AnchorPoint=Vector2.new(0.5,0), Position=UDim2.fromOffset(100,4), Size=UDim2.new(1,-8,0,14),
	BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=10, TextColor3=Color3.fromRGB(180,180,180), Text="WAITING", ZIndex=46}, timerHolder)
local timerNum = mk("TextLabel", {AnchorPoint=Vector2.new(0.5,0), Position=UDim2.fromOffset(100,18), Size=UDim2.new(1,-8,0,24),
	BackgroundTransparency=1, Font=Enum.Font.GothamBlack, TextSize=22, TextColor3=Color3.new(1,1,1), Text="--:--", ZIndex=46}, timerHolder)
task.spawn(function()
	while overlay.Parent do
		task.wait(math.random(18,35)/10)
		if timerHolder.Visible then
			local s = mk("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(math.random()*0.7+0.1,0,0.5,0),
				Size=UDim2.fromOffset(1,42), Rotation=math.random(-15,15), BackgroundColor3=Color3.new(1,1,1),
				BackgroundTransparency=0.3, BorderSizePixel=0, ZIndex=47}, timerHolder)
			game:GetService("TweenService"):Create(s, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play()
			task.delay(0.35, function() s:Destroy() end)
		end
	end
end)
task.spawn(function()
	while not MM.dead do
		task.wait(0.5)
		local ok = pcall(function()
			local hud = playerGui:FindFirstChild("Hud") or playerGui:FindFirstChild("MainGui")
				or playerGui:FindFirstChild("HUD") or playerGui:FindFirstChild("GameGui")
			if not hud then timerHolder.Visible=false return end
			local function findTimer(parent)
				for _, d in ipairs(parent:GetDescendants()) do
					if d:IsA("TextLabel") or d:IsA("TextBox") then
						local t = d.Text or ""
						if t:match("^%d+:%d%d$") or t:match("^%d%d:%d%d$") then return d end
					end
				end
			end
			local tl = findTimer(hud)
			if tl then
				timerHolder.Visible = true; timerNum.Text = tl.Text
				local par = tl.Parent; local phaseText = ""
				if par then
					for _, c in ipairs(par:GetChildren()) do
						if (c:IsA("TextLabel") or c:IsA("TextBox")) and c ~= tl then
							local t2 = (c.Text or ""):lower()
							if t2:find("inter") or t2:find("wait") or t2:find("รอ") then phaseText="⏳ รอรอบถัดไป"
							elseif t2:find("round") or t2:find("game") or t2:find("play") then phaseText="⚔️ รอบกำลังดำเนิน" end
						end
					end
				end
				timerPhase.Text = phaseText ~= "" and phaseText or "⏱ เวลาที่เหลือ"
			else
				local gt = math.floor(workspace.DistributedGameTime)
				timerNum.Text = string.format("%d:%02d", math.floor(gt/60)%60, gt%60)
				timerPhase.Text = "⏱ เวลาในเกม"; timerHolder.Visible = true
			end
		end)
		if not ok then timerHolder.Visible = false end
	end
	timerHolder.Visible = false
end)

local ESP = { roles=false, gun=false, lines=false, boxes=false }
local K = { auto=false, all=false, throw=false, shoot=false, aThrow=false, aShoot=false, aThrowWall=false, aShootWall=false }
local P = { noclip=false, speed=false, jump=false, fly=false, tp=false, anti=false }
local FLAGS = { flinging=false, floating=false, warpGun=false }

local function myParts()
	local c = player.Character
	return c, c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end
local function hasTag(inst, tag)
	local ok, r = pcall(function() return inst:HasTag(tag) end); return ok and r
end

-- ข้อมูลบทบาท
local playerData = {}
local pEsp, gEsp, known, roleCache, vis = {}, {}, {}, {}, {}
local ev, fn

local function setData(d) if type(d)=="table" then playerData=d end end
local function findRemote(names, class)
	for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
		if d:IsA(class) and names[d.Name] then return d end
	end
end
local function fetchNow()
	if fn then local ok, d = pcall(function() return fn:InvokeServer() end) if ok then setData(d) end end
end
task.spawn(function()
	for _ = 1, 40 do
		ev = ev or findRemote({PlayerDataChanged=true}, "RemoteEvent")
		fn = fn or findRemote({GetCurrentPlayerData=true, GetPlayerData=true}, "RemoteFunction")
		if (ev and fn) or MM.dead then break end; task.wait(0.5)
	end
	if ev then bind(ev.OnClientEvent, setData) end
	while not MM.dead do
		if fn and (ESP.roles or ESP.gun or ESP.lines or ESP.boxes or FLAGS.warpGun) then fetchNow() end
		task.wait(1.5)
	end
end)

local function roleFromText(r)
	r = tostring(r or ""):lower()
	if r:find("murder") then return "Murderer" end
	if r:find("sheriff") or r:find("hero") then return "Sheriff" end
	return nil
end
local function toolRole(parent)
	for _, t in ipairs(parent:GetChildren()) do
		if t:IsA("Tool") then
			local n = t.Name:lower()
			if hasTag(t,"Weapon_Knife") or n:find("knife") then return "Murderer" end
			if hasTag(t,"Weapon_Gun") or n=="gun" or n:find("revolver") then return "Sheriff" end
		end
	end
	return nil
end
local function getRole(plr)
	local char = plr.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not char or not hum or hum.Health<=0 then return nil end
	local d = playerData[plr.Name]
	if type(d)=="table" then
		if d.Dead==true then return nil end
		local r = roleFromText(d.Role); if r then return r end
	end
	local r = toolRole(char)
	if not r and plr:FindFirstChild("Backpack") then r=toolRole(plr.Backpack) end
	return r or "Innocent"
end
local function gunPart()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local c = plr.Character
			if c then
				for _, t in ipairs(c:GetChildren()) do
					if t:IsA("Tool") then
						local n = t.Name:lower()
						if hasTag(t,"Weapon_Gun") or n=="gun" or n:find("revolver") then
							local h = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart")
							if h then return h end
						end
					end
				end
			end
		end
	end
	return nil
end

-- ===================== หมวด RADAR =====================
do
	local tab = { _page = NX.pages["radar"] }
	-- helper สร้าง elements ใน tab โดยตรง
	local sf = mk("ScrollingFrame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0,
		ScrollBarThickness=3, ScrollBarImageColor3=Color3.new(1,1,1), ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(), ScrollingDirection=Enum.ScrollingDirection.Y}, tab._page)
	mk("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, sf)
	mk("UIPadding", {PaddingRight=UDim.new(0,6), PaddingBottom=UDim.new(0,8)}, sf)
	local ordR = 0
	local function rowR(h)
		ordR+=1
		local r = mk("Frame", {LayoutOrder=ordR, Size=UDim2.new(1,0,0,h), BackgroundColor3=Color3.fromRGB(14,14,14), BackgroundTransparency=0.25, BorderSizePixel=0}, sf)
		corner2(r,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r); return r
	end
	local function hdR(th, en)
		ordR+=1
		local h = mk("Frame",{LayoutOrder=ordR,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},sf)
		local bar = mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h)
		corner2(bar,2); onAccent(function(c) bar.BackgroundColor3=c end)
		tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT), th, en)
	end
	local function togR(th, en, cb)
		local r = rowR(38)
		tr(mkLabel(r,12,0,220,38,"",13,WHITE,HUD_FONT), th, en)
		local track = mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
			Size=UDim2.fromOffset(42,22),BackgroundColor3=Color3.fromRGB(50,50,50),Text="",AutoButtonColor=false},r)
		corner2(track,11)
		local knob = mk("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(170,170,170),BorderSizePixel=0},track)
		corner2(knob,8)
		local state = false
		local function paint(anim)
			local d = anim and 0.15 or 0
			TweenService:Create(track,TweenInfo.new(d),{BackgroundColor3=state and ACCENT or Color3.fromRGB(50,50,50)}):Play()
			TweenService:Create(knob,TweenInfo.new(d),{Position=state and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0)}):Play()
		end
		onAccent(function() paint(false) end); paint(false)
		track.MouseButton1Click:Connect(function() state=not state paint(true) pcall(cb,state) end)
	end

	hdR("// 📡 เรดาร์ MM2", "// 📡 RADAR MM2")
	togR("ESP บทบาท (Murderer/Sheriff/Innocent)", "Role ESP", function(v) ESP.roles=v end)
	togR("ESP ปืน (แสดงตำแหน่งปืน)", "Gun ESP", function(v) ESP.gun=v end)
	togR("ESP เส้นเชื่อม", "Line ESP", function(v) ESP.lines=v end)
	togR("ESP กรอบ", "Box ESP", function(v) ESP.boxes=v end)

	-- X-Ray
	local XR = { on=false, parts={} }
	local function isChar(d)
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character and d:IsDescendantOf(plr.Character) then return true end
		end
		return false
	end
	local function xrPart(d)
		if d:IsA("BasePart") and not d:IsA("Terrain") and not XR.parts[d]
			and not d.Name:lower():find("coin") and not isChar(d) then
			XR.parts[d]=true; d.LocalTransparencyModifier=0.7
		end
	end
	bind(workspace.DescendantAdded, function(d) if XR.on then xrPart(d) end end)
	local function xrOn()
		XR.on=true
		task.spawn(function()
			local n=0
			for _, d in ipairs(workspace:GetDescendants()) do
				if not XR.on then return end; xrPart(d); n+=1
				if n%400==0 then task.wait() end
			end
		end)
	end
	local function xrOff()
		XR.on=false
		for p in pairs(XR.parts) do pcall(function() p.LocalTransparencyModifier=0 end); XR.parts[p]=nil end
	end
	togR("X-Ray (ทะลุกำแพง)", "X-Ray", function(v) if v then xrOn() else xrOff() end end)
	onUnload(xrOff)

	-- ESP draw loop
	local espFrames = {}
	local function clearEsp()
		for _, f in ipairs(espFrames) do pcall(function() f:Destroy() end) end; espFrames={}
	end
	local cam = workspace.CurrentCamera
	local espGui = mk("ScreenGui",{Name="NX_ESP",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=997},playerGui)
	onUnload(function() espGui:Destroy() end)
	bind(RunService.RenderStepped, function()
		clearEsp()
		if not (ESP.roles or ESP.gun or ESP.lines or ESP.boxes) then return end
		local myChar = player.Character
		local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr==player then continue end
			local ch = plr.Character
			local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			if not (hrp and hum and hum.Health>0) then continue end
			local role = getRole(plr)
			local col = role=="Murderer" and Color3.fromRGB(255,60,60)
				or role=="Sheriff" and Color3.fromRGB(60,120,255)
				or Color3.fromRGB(180,180,180)
			-- screen pos
			local ok, pos = pcall(function() return cam:WorldToViewportPoint(hrp.Position) end)
			if not (ok and pos.Z>0) then continue end
			if ESP.roles then
				local lbl = mk("TextLabel",{Position=UDim2.fromOffset(pos.X-40,pos.Y-18),Size=UDim2.fromOffset(80,16),
					BackgroundTransparency=1,TextColor3=col,Font=Enum.Font.GothamBold,TextSize=11,
					Text=(role or "?").." "..plr.DisplayName,ZIndex=10},espGui)
				espFrames[#espFrames+1]=lbl
			end
			if ESP.boxes then
				local box = mk("Frame",{Position=UDim2.fromOffset(pos.X-18,pos.Y-28),Size=UDim2.fromOffset(36,56),
					BackgroundTransparency=1,BorderSizePixel=0},espGui)
				mk("UIStroke",{Color=col,Thickness=1.5},box)
				espFrames[#espFrames+1]=box
			end
			if ESP.lines and myHrp then
				local ok2, myPos = pcall(function() return cam:WorldToViewportPoint(myHrp.Position) end)
				if ok2 and myPos.Z>0 then
					local vp2 = cam.ViewportSize
					local dx,dy = pos.X-myPos.X, pos.Y-myPos.Y
					local dist = math.sqrt(dx*dx+dy*dy)
					local line = mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),
						Position=UDim2.fromOffset((myPos.X+pos.X)/2,(myPos.Y+pos.Y)/2),
						Size=UDim2.fromOffset(dist,1),Rotation=math.deg(math.atan2(dy,dx)),
						BackgroundColor3=col,BorderSizePixel=0,BackgroundTransparency=0.4},espGui)
					espFrames[#espFrames+1]=line
				end
			end
		end
	end)
end -- RADAR

-- ===================== หมวด WARP =====================
do
	local warpSF = mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y}, NX.pages["warp"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},warpSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},warpSF)

	local function warpTo(plr)
		local c=player.Character; local tc=plr and plr.Character
		local th=tc and tc:FindFirstChild("HumanoidRootPart")
		if c and th and c:FindFirstChild("HumanoidRootPart") then c:PivotTo(th.CFrame*CFrame.new(0,0,3)) return true end
		return false
	end
	local function warpToRole(role,missEn,missTh)
		fetchNow()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr~=player and getRole(plr)==role then
				if not warpTo(plr) then toast("Failed (no character)","ทำไม่ได้ (ไม่พบตัวละคร)") end return
			end
		end
		toast(missEn,missTh)
	end

	-- section header
	local ordW=0
	local function hdW(th,en)
		ordW+=1
		local h=mk("Frame",{LayoutOrder=ordW,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},warpSF)
		local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h)
		corner2(bar,2); onAccent(function(c) bar.BackgroundColor3=c end)
		tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en)
	end
	local function btnW(th,en,cb)
		ordW+=1
		local r=mk("Frame",{LayoutOrder=ordW,Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},warpSF)
		corner2(r,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r)
		local b=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(80,26),
			BackgroundColor3=ACCENT,Text="",AutoButtonColor=false},r)
		corner2(b,10); onAccent(function(c) b.BackgroundColor3=c end)
		tr(mkLabel(r,12,0,250,36,"",13,WHITE,HUD_FONT),th,en)
		tr(mkLabel(b,0,0,80,26,"",11,WHITE,HUD_FONT,Enum.TextXAlignment.Center),"GO","ทำ")
		b.MouseButton1Click:Connect(function() sfx("click",nil,1.5) pcall(cb) end)
	end
	local function togW(th,en,cb)
		ordW+=1
		local r=mk("Frame",{LayoutOrder=ordW,Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},warpSF)
		corner2(r,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r)
		tr(mkLabel(r,12,0,220,38,"",13,WHITE,HUD_FONT),th,en)
		local track=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.fromOffset(42,22),BackgroundColor3=Color3.fromRGB(50,50,50),Text="",AutoButtonColor=false},r)
		corner2(track,11)
		local knob=mk("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(170,170,170),BorderSizePixel=0},track)
		corner2(knob,8)
		local state=false
		local function paint(anim)
			local d=anim and 0.15 or 0
			TweenService:Create(track,TweenInfo.new(d),{BackgroundColor3=state and ACCENT or Color3.fromRGB(50,50,50)}):Play()
			TweenService:Create(knob,TweenInfo.new(d),{Position=state and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0)}):Play()
		end
		onAccent(function() paint(false) end); paint(false)
		track.MouseButton1Click:Connect(function() state=not state paint(true) pcall(cb,state) end)
	end

	hdW("// 🚀 WARP","// 🚀 WARP")
	togW("ดูดปืนอัตโนมัติ","Auto Warp to Gun", function(v) FLAGS.warpGun=v end)
	btnW("วาร์ปหาฆาตกร","Warp to Murderer", function() warpToRole("Murderer","Murderer not found","ไม่พบฆาตกร") end)
	btnW("วาร์ปหานายอำเภอ","Warp to Sheriff", function() warpToRole("Sheriff","Sheriff not found","ไม่พบนายอำเภอ") end)

	-- Player Card Picker
	hdW("🌀 เลือกผู้เล่นที่จะวาร์ป","🌀 Select Player to Warp")
	local gridW=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=ordW+1},warpSF)
	ordW+=1
	mk("UIGridLayout",{CellSize=UDim2.fromOffset(112,56),CellPadding=UDim2.fromOffset(5,5),SortOrder=Enum.SortOrder.LayoutOrder},gridW)
	mk("UIPadding",{PaddingLeft=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},gridW)
	local warpCards,warpSelected={},nil

	local function clearWarpCards()
		for _,c2 in ipairs(warpCards) do pcall(function() c2:Destroy() end) end; warpCards={}; warpSelected=nil
	end
	local function makeWarpCard(plr)
		local card=Instance.new("TextButton"); card.Size=UDim2.fromOffset(116,54); card.BackgroundColor3=Color3.fromRGB(18,22,32)
		card.AutoButtonColor=false; card.Text=""; card.BorderSizePixel=0; card.Parent=gridW
		Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
		local stroke=Instance.new("UIStroke"); stroke.Thickness=1.5; stroke.Color=ACCENT
		stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; stroke.Parent=card
		onAccent(function(a) if card.Parent then stroke.Color=a end end)
		local av=Instance.new("ImageLabel"); av.Size=UDim2.fromOffset(38,38); av.Position=UDim2.fromOffset(7,8)
		av.BackgroundColor3=Color3.fromRGB(32,38,52); av.BorderSizePixel=0; av.Parent=card
		Instance.new("UICorner",av).CornerRadius=UDim.new(0,8)
		task.spawn(function()
			local ok,img=pcall(function() return Players:GetUserThumbnailAsync(plr.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48) end)
			if ok and av.Parent then av.Image=img end
		end)
		local roleBadge=Instance.new("TextLabel"); roleBadge.Size=UDim2.fromOffset(36,12); roleBadge.Position=UDim2.fromOffset(7,42)
		roleBadge.BackgroundColor3=Color3.fromRGB(40,40,55); roleBadge.Text="..."; roleBadge.Font=Enum.Font.GothamBold
		roleBadge.TextSize=8; roleBadge.TextColor3=Color3.new(1,1,1); roleBadge.TextXAlignment=Enum.TextXAlignment.Center
		roleBadge.BorderSizePixel=0; roleBadge.Parent=card; Instance.new("UICorner",roleBadge).CornerRadius=UDim.new(0,4)
		task.spawn(function()
			while card.Parent do task.wait(1)
				local r=getRole(plr)
				if r=="Murderer" then roleBadge.Text="🔪" roleBadge.BackgroundColor3=Color3.fromRGB(120,20,20)
				elseif r=="Sheriff" then roleBadge.Text="🔫" roleBadge.BackgroundColor3=Color3.fromRGB(20,80,140)
				else roleBadge.Text="●" roleBadge.BackgroundColor3=Color3.fromRGB(40,40,55) end
			end
		end)
		local nm=Instance.new("TextLabel"); nm.Size=UDim2.new(1,-52,0,18); nm.Position=UDim2.fromOffset(50,8)
		nm.BackgroundTransparency=1; nm.Text=plr.DisplayName; nm.Font=Enum.Font.GothamBold; nm.TextSize=11
		nm.TextColor3=Color3.new(1,1,1); nm.TextTruncate=Enum.TextTruncate.AtEnd; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.Parent=card
		local un=Instance.new("TextLabel"); un.Size=UDim2.new(1,-52,0,13); un.Position=UDim2.fromOffset(50,27)
		un.BackgroundTransparency=1; un.Text="@"..plr.Name; un.Font=Enum.Font.Gotham; un.TextSize=9
		un.TextColor3=GRAY; un.TextTruncate=Enum.TextTruncate.AtEnd; un.TextXAlignment=Enum.TextXAlignment.Left; un.Parent=card
		local tapStart
		card.InputBegan:Connect(function(inp)
			if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then tapStart=inp.Position end
		end)
		card.InputEnded:Connect(function(inp)
			if (inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1) and tapStart then
				if (inp.Position-tapStart).Magnitude<20 then
					warpSelected=plr
					for _,c2 in ipairs(warpCards) do local s2=c2:FindFirstChildOfClass("UIStroke") if s2 then s2.Color=ACCENT s2.Thickness=1.5 end c2.BackgroundColor3=Color3.fromRGB(18,22,32) end
					stroke.Color=WHITE; stroke.Thickness=2.5; card.BackgroundColor3=Color3.fromRGB(20,45,80)
				end
				tapStart=nil
			end
		end)
		warpCards[#warpCards+1]=card
	end
	local function refreshWarpCards() clearWarpCards() for _,plr in ipairs(Players:GetPlayers()) do if plr~=player then makeWarpCard(plr) end end end
	refreshWarpCards()
	Players.PlayerAdded:Connect(refreshWarpCards)
	Players.PlayerRemoving:Connect(function() task.wait(0.1) refreshWarpCards() end)

	-- Warp button
	local btnRowW=mk("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=1000},warpSF)
	local llW=Instance.new("UIListLayout"); llW.FillDirection=Enum.FillDirection.Horizontal; llW.Padding=UDim.new(0,8)
	llW.HorizontalAlignment=Enum.HorizontalAlignment.Center; llW.VerticalAlignment=Enum.VerticalAlignment.Center; llW.Parent=btnRowW
	local function mkWBtn(txt2,col,cb)
		local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(118,26); b.BackgroundColor3=col; b.Text=txt2
		b.Font=Enum.Font.GothamBold; b.TextSize=11; b.TextColor3=Color3.new(1,1,1); b.AutoButtonColor=false; b.Parent=btnRowW
		Instance.new("UICorner",b).CornerRadius=UDim.new(0,10); b.MouseButton1Click:Connect(cb)
	end
	mkWBtn("🌀 WARP!",Color3.fromRGB(30,80,180),function()
		if not warpSelected then toast("No player selected","ยังไม่ได้เลือกผู้เล่น") return end
		if not warpTo(warpSelected) then toast("Failed (no character)","ไม่พบตัวละครเป้าหมาย") end
		toast("🌀 Warped!","🌀 วาร์ปแล้ว!")
	end)

	-- Auto warp to gun
	task.spawn(function()
		local busy=false
		while not MM.dead do task.wait(0.4)
			if FLAGS.warpGun and not busy and getRole(player)=="Innocent" then
				local part=gunPart(); local c=player.Character
				if part and c and c:FindFirstChild("HumanoidRootPart") then
					busy=true; local back=c:GetPivot()
					c:PivotTo(part.CFrame); task.wait(0.4)
					c=player.Character
					if c and c:FindFirstChild("HumanoidRootPart") then c:PivotTo(back) end
					task.wait(2); busy=false
				end
			end
		end
	end)
end -- WARP

-- ===================== หมวด FLING =====================
do
	local flingSF=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},NX.pages["fling"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},flingSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},flingSF)
	local ordF=0
	local function hdF(th,en) ordF+=1 local h=mk("Frame",{LayoutOrder=ordF,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},flingSF) local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h) corner2(bar,2) onAccent(function(c) bar.BackgroundColor3=c end) tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en) end
	local function btnF(th,en,col,cb) ordF+=1 local r=mk("Frame",{LayoutOrder=ordF,Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},flingSF) corner2(r,12) mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r) local b=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(80,26),BackgroundColor3=col or ACCENT,Text="",AutoButtonColor=false},r) corner2(b,10) if not col then onAccent(function(c) b.BackgroundColor3=c end) end tr(mkLabel(r,12,0,250,36,"",13,WHITE,HUD_FONT),th,en) tr(mkLabel(b,0,0,80,26,"",11,WHITE,HUD_FONT,Enum.TextXAlignment.Center),"GO","ทำ") b.MouseButton1Click:Connect(function() sfx("click",nil,1.5) pcall(cb) end) end

	local busy=false
	local TIMEOUT,ROUNDS=3,4
	local function hbF() RunService.Heartbeat:Wait() end
	local function zeroAll(c) for _,d in ipairs(c:GetChildren()) do if d:IsA("BasePart") then d.AssemblyLinearVelocity=Vector3.new(0,0,0) d.AssemblyAngularVelocity=Vector3.new(0,0,0) end end end
	local function flingPlayer(plr)
		if busy then toast("Already flinging","กำลังฟลิ้งอยู่") return end
		local c=player.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart"); local hum=c and c:FindFirstChildOfClass("Humanoid")
		local tch=plr and plr.Character; local troot=tch and tch:FindFirstChild("HumanoidRootPart"); local thum=tch and tch:FindFirstChildOfClass("Humanoid")
		if not (hrp and hum and hum.Health>0 and troot and thum and thum.Health>0) then toast("Failed (no character)","ทำไม่ได้ (ไม่พบตัวละคร)") return end
		busy=true; FLAGS.flinging=true
		local homeCF=hrp.CFrame; local startPos=troot.Position
		local cam=workspace.CurrentCamera; local oldSubject=cam and cam.CameraSubject
		local oldFall=workspace.FallenPartsDestroyHeight
		pcall(function() workspace.FallenPartsDestroyHeight=-math.huge end)
		pcall(function() cam.CameraSubject=thum end)
		local bvTarget=Instance.new("BodyVelocity"); bvTarget.MaxForce=Vector3.new(math.huge,math.huge,math.huge); bvTarget.Velocity=Vector3.new(0,0,0); bvTarget.Parent=troot
		local function targetGone() return not (plr.Parent and plr.Character==tch and troot.Parent) or thum.Health<=0 end
		local flung=false
		pcall(function()
			for _=1,ROUNDS do
				local t0=os.clock(); local angle=0
				while true do
					if targetGone() or hum.Health<=0 or not hrp.Parent then break end
					local spd=troot.AssemblyLinearVelocity.Magnitude; local dist=(troot.Position-startPos).Magnitude
					if spd>800 or dist>500 then flung=true break end
					if os.clock()-t0>TIMEOUT then break end
					angle+=120
					local ang=CFrame.Angles(math.rad(angle),math.rad(angle*0.5),0)
					for _,off in ipairs({CFrame.new(0,1.2,0.5),CFrame.new(0,-1.2,0.5),CFrame.new(0.5,1.2,0),CFrame.new(-0.5,-1.2,0),CFrame.new(0,0.5,1.2)}) do
						pcall(function() c:PivotTo(CFrame.new(troot.Position)*off*ang) end)
						hrp.AssemblyLinearVelocity=Vector3.new(9e5,9e5,9e5); bvTarget.Velocity=Vector3.new(9e5,9e5,9e5)
						hbF(); if flung then break end
					end
					if flung then break end
				end
				if flung then break end
			end
		end)
		bvTarget:Destroy(); pcall(function() cam.CameraSubject=oldSubject or hum end)
		for i=1,60 do
			if not (hrp.Parent and c.Parent) then break end
			pcall(function() c:PivotTo(homeCF) end); zeroAll(c)
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end); hbF()
			if (hrp.Position-homeCF.Position).Magnitude<8 then break end
		end
		pcall(function() workspace.FallenPartsDestroyHeight=oldFall end)
		FLAGS.flinging=false; busy=false
		if flung then toast("💥 Flung out!","💥 กระเด็นออกแมพแล้ว!") else toast("Fling done","ฟลิ้งเสร็จ") end
	end
	local function flingRole(role,missEn,missTh)
		fetchNow()
		for _,plr in ipairs(Players:GetPlayers()) do if plr~=player and getRole(plr)==role then task.spawn(flingPlayer,plr) return end end
		toast(missEn,missTh)
	end

	hdF("// 💥 FLING","// 💥 FLING")
	btnF("ฟลิ้งนายอำเภอ","Fling Sheriff",nil,function() flingRole("Sheriff","Sheriff not found","ไม่พบนายอำเภอ") end)
	btnF("ฟลิ้งฆาตกร","Fling Murderer",Color3.fromRGB(180,30,50),function() flingRole("Murderer","Murderer not found","ไม่พบฆาตกร") end)

	-- Player card picker (Fling)
	hdF("⚡ เลือกผู้เล่นที่จะฟลิ้ง","⚡ Select Player to Fling")
	local gridF=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=ordF+1},flingSF)
	ordF+=1
	mk("UIGridLayout",{CellSize=UDim2.fromOffset(112,56),CellPadding=UDim2.fromOffset(5,5),SortOrder=Enum.SortOrder.LayoutOrder},gridF)
	mk("UIPadding",{PaddingLeft=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},gridF)
	local flingCards,flingSelected={},nil
	local function clearFlingCards() for _,c2 in ipairs(flingCards) do pcall(function() c2:Destroy() end) end flingCards={} flingSelected=nil end
	local function makeFlingCard(plr)
		local card=Instance.new("TextButton"); card.Size=UDim2.fromOffset(116,54); card.BackgroundColor3=Color3.fromRGB(22,22,32)
		card.AutoButtonColor=false; card.Text=""; card.BorderSizePixel=0; card.Parent=gridF
		Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
		local stroke=Instance.new("UIStroke"); stroke.Thickness=1.5; stroke.Color=ACCENT
		stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; stroke.Parent=card
		onAccent(function(a) if card.Parent then stroke.Color=a end end)
		local av=Instance.new("ImageLabel"); av.Size=UDim2.fromOffset(38,38); av.Position=UDim2.fromOffset(7,8)
		av.BackgroundColor3=Color3.fromRGB(38,38,52); av.BorderSizePixel=0; av.Parent=card
		Instance.new("UICorner",av).CornerRadius=UDim.new(0,8)
		task.spawn(function() local ok,img=pcall(function() return Players:GetUserThumbnailAsync(plr.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48) end) if ok and av.Parent then av.Image=img end end)
		local nm=Instance.new("TextLabel"); nm.Size=UDim2.new(1,-52,0,18); nm.Position=UDim2.fromOffset(50,8)
		nm.BackgroundTransparency=1; nm.Text=plr.DisplayName; nm.Font=Enum.Font.GothamBold; nm.TextSize=11
		nm.TextColor3=Color3.new(1,1,1); nm.TextTruncate=Enum.TextTruncate.AtEnd; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.Parent=card
		local un=Instance.new("TextLabel"); un.Size=UDim2.new(1,-52,0,13); un.Position=UDim2.fromOffset(50,27)
		un.BackgroundTransparency=1; un.Text="@"..plr.Name; un.Font=Enum.Font.Gotham; un.TextSize=9
		un.TextColor3=GRAY; un.TextTruncate=Enum.TextTruncate.AtEnd; un.TextXAlignment=Enum.TextXAlignment.Left; un.Parent=card
		local tapStartF
		card.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then tapStartF=inp.Position end end)
		card.InputEnded:Connect(function(inp)
			if (inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1) and tapStartF then
				if (inp.Position-tapStartF).Magnitude<20 then
					flingSelected=plr
					for _,c2 in ipairs(flingCards) do local s2=c2:FindFirstChildOfClass("UIStroke") if s2 then s2.Color=ACCENT s2.Thickness=1.5 end c2.BackgroundColor3=Color3.fromRGB(22,22,32) end
					stroke.Color=WHITE; stroke.Thickness=2.5; card.BackgroundColor3=Color3.fromRGB(50,28,80)
				end
				tapStartF=nil
			end
		end)
		flingCards[#flingCards+1]=card
	end
	local function refreshFlingCards() clearFlingCards() for _,plr in ipairs(Players:GetPlayers()) do if plr~=player then makeFlingCard(plr) end end end
	refreshFlingCards()
	Players.PlayerAdded:Connect(refreshFlingCards)
	Players.PlayerRemoving:Connect(function() task.wait(0.1) refreshFlingCards() end)

	-- Fling button
	local btnRowF=mk("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=1000},flingSF)
	local llF=Instance.new("UIListLayout"); llF.FillDirection=Enum.FillDirection.Horizontal; llF.Padding=UDim.new(0,8)
	llF.HorizontalAlignment=Enum.HorizontalAlignment.Center; llF.VerticalAlignment=Enum.VerticalAlignment.Center; llF.Parent=btnRowF
	local function mkFBtn(txt2,col,cb) local b=Instance.new("TextButton") b.Size=UDim2.fromOffset(118,26) b.BackgroundColor3=col b.Text=txt2 b.Font=Enum.Font.GothamBold b.TextSize=11 b.TextColor3=Color3.new(1,1,1) b.AutoButtonColor=false b.Parent=btnRowF Instance.new("UICorner",b).CornerRadius=UDim.new(0,10) b.MouseButton1Click:Connect(cb) end
	mkFBtn("💥 FLING!",Color3.fromRGB(160,25,55),function()
		if not flingSelected then toast("No player selected","ยังไม่ได้เลือกผู้เล่น") return end
		task.spawn(flingPlayer,flingSelected)
	end)
	onUnload(function() FLAGS.flinging=false end)
end -- FLING

-- ===================== หมวด HUNTER =====================
do
	local hunterSF=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},NX.pages["hunter"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},hunterSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},hunterSF)
	local ordH=0
	local function hdH(th,en) ordH+=1 local h=mk("Frame",{LayoutOrder=ordH,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},hunterSF) local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h) corner2(bar,2) onAccent(function(c) bar.BackgroundColor3=c end) tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en) end
	local function togH(th,en,cb)
		ordH+=1
		local r=mk("Frame",{LayoutOrder=ordH,Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},hunterSF)
		corner2(r,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r)
		tr(mkLabel(r,12,0,220,38,"",13,WHITE,HUD_FONT),th,en)
		local track=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.fromOffset(42,22),BackgroundColor3=Color3.fromRGB(50,50,50),Text="",AutoButtonColor=false},r)
		corner2(track,11)
		local knob=mk("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(170,170,170),BorderSizePixel=0},track)
		corner2(knob,8); local state=false
		local function paint(anim) local d=anim and 0.15 or 0 TweenService:Create(track,TweenInfo.new(d),{BackgroundColor3=state and ACCENT or Color3.fromRGB(50,50,50)}):Play() TweenService:Create(knob,TweenInfo.new(d),{Position=state and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0)}):Play() end
		onAccent(function() paint(false) end); paint(false)
		track.MouseButton1Click:Connect(function() state=not state paint(true) pcall(cb,state) end)
	end

	local RANGE_GUN,RANGE_KNIFE=250,150
	local function alive(plr) local ch=plr.Character local h=ch and ch:FindFirstChildOfClass("Humanoid") local r=ch and ch:FindFirstChild("HumanoidRootPart") if h and r and h.Health>0 then return ch,r end return nil end
	local function hasRemote(t,words) for _,d in ipairs(t:GetDescendants()) do if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then local n=d.Name:lower() for _,w in ipairs(words) do if n:find(w,1,true) then return true end end end end return false end
	local function isKnife(t) if not t:IsA("Tool") then return false end return t.Name:lower():find("knife")~=nil or hasTag(t,"Weapon_Knife") or hasRemote(t,{"throw"}) end
	local function isGun(t) if not t:IsA("Tool") or isKnife(t) then return false end local n=t.Name:lower() return n:find("gun")~=nil or n:find("revolver")~=nil or hasTag(t,"Weapon_Gun") or hasRemote(t,{"shoot","createbeam"}) end
	local function findTool(test) local c=player.Character if c then for _,t in ipairs(c:GetChildren()) do if test(t) then return t end end end local bp=player:FindFirstChild("Backpack") if bp then for _,t in ipairs(bp:GetChildren()) do if test(t) then return t end end end return nil end
	local function equip(t) if not t then return nil end local c,_,hum=myParts() if not (c and hum) then return nil end if t.Parent~=c then pcall(function() hum:EquipTool(t) end) local t0=os.clock() while t.Parent~=c and os.clock()-t0<1 do task.wait(0.05) end end if t.Parent==c then return t end return nil end
	local function equipKnife() return equip(findTool(isKnife)) end
	local function equipGun() return equip(findTool(isGun)) end
	local function pickRemote(tool,names)
		local list={} for _,d in ipairs(tool:GetDescendants()) do if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then list[#list+1]=d end end
		for _,w in ipairs(names) do for _,d in ipairs(list) do if d.Name:lower()==w then return d end end end
		for _,w in ipairs(names) do for _,d in ipairs(list) do if d.Name:lower():find(w,1,true) then return d end end end
		return nil
	end
	local function fire(remote,...) local a=table.pack(...) if remote:IsA("RemoteFunction") then task.spawn(function() pcall(function() remote:InvokeServer(table.unpack(a,1,a.n)) end) end) else pcall(function() remote:FireServer(table.unpack(a,1,a.n)) end) end end
	local function handPos() local c,hrp=myParts() local hand=c and (c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm")) local p=hand or hrp return p and p.Position end
	local function aimPoint(r,from) local v=r.AssemblyLinearVelocity local lead=Vector3.new(v.X,0,v.Z) if lead.Magnitude>60 then lead=lead.Unit*60 end local t=math.clamp((r.Position-from).Magnitude/140,0,0.35) return r.Position+lead*t end
	local function canSee(targetChar,part)
		local c,hrp=myParts() if not (c and hrp and part and part.Parent) then return false end
		local origin=(c:FindFirstChild("Head") or hrp).Position; local dir=part.Position-origin
		local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.IgnoreWater=true
		local ignore={c}
		for _=1,8 do params.FilterDescendantsInstances=ignore local res=workspace:Raycast(origin,dir,params) if not res then return true end local hit=res.Instance if hit:IsDescendantOf(targetChar) then return true end local m=hit:FindFirstAncestorOfClass("Model") if m and m:FindFirstChildOfClass("Humanoid") then return false end if hit.CanCollide then return false end ignore[#ignore+1]=hit end
		return false
	end
	local function throwAt(r,silent)
		local knife=equipKnife() if not knife then if not silent then toast("No knife found","ไม่พบมีดในตัว") end return false end
		local from=handPos() if not from then return false end
		local aim=aimPoint(r,from); local rem=pickRemote(knife,{"throw","knifethrown","throwknife"})
		if rem then fire(rem,aim,CFrame.new(from,aim)) return true end
		return false
	end
	local function shootAt(r,silent)
		local gun=equipGun() if not gun then if not silent then toast("No gun found","ไม่พบปืนในตัว") end return false end
		local from=handPos() if not from then return false end
		local aim=aimPoint(r,from); local rem=pickRemote(gun,{"shoot","fire","createbeam","bulletspawned"})
		if rem then fire(rem,aim,CFrame.new(from,aim)) return true end
		return false
	end
	local function nearest(checkCanSee)
		local c,hrp=myParts() if not hrp then return nil end
		local best,bd=nil,RANGE_KNIFE
		for _,plr in ipairs(Players:GetPlayers()) do
			if plr==player then continue end
			local ch,r=alive(plr) if not (ch and r) then continue end
			local d=(r.Position-hrp.Position).Magnitude if d>=bd then continue end
			if checkCanSee~=false and not canSee(ch,r) then continue end
			best,bd=r,d
		end
		return best
	end
	local function murdererTarget(checkCanSee)
		local c,hrp=myParts() if not hrp then return nil end
		local best,bd=nil,RANGE_GUN
		for _,plr in ipairs(Players:GetPlayers()) do
			if plr==player or getRole(plr)~="Murderer" then continue end
			local ch,r=alive(plr) if not (ch and r) then continue end
			local d=(r.Position-hrp.Position).Magnitude if d>=bd then continue end
			if checkCanSee~=false and not canSee(ch,r) then continue end
			best,bd=r,d
		end
		return best
	end
	local lastFetch=0

	hdH("// 🎯 HUNTER","// 🎯 HUNTER")
	togH("ขว้างมีดอัตโนมัติ (ทะลุกำแพง)","Auto Throw (through walls)",function(v) K.aThrowWall=v end)
	togH("ยิงปืนอัตโนมัติ (ทะลุกำแพง)","Auto Shoot (through walls)",function(v) K.aShootWall=v end)
	togH("ขว้างมีด (เห็นเป้า)","Auto Throw (LoS)",function(v) K.aThrow=v end)
	togH("ยิงปืน (เห็นเป้า)","Auto Shoot (LoS)",function(v) K.aShoot=v end)

	task.spawn(function()
		local lastSW,lastTW=0,0
		while not MM.dead do task.wait(0.1)
			if (K.aShootWall or K.aThrowWall or K.aThrow or K.aShoot) and not FLAGS.flinging then
				pcall(function()
					local c,hrp,hum=myParts() if not (c and hrp and hum and hum.Health>0) then return end
					if K.aShootWall and os.clock()-lastSW>0.5 and findTool(isGun) then
						if os.clock()-lastFetch>1.5 then lastFetch=os.clock() fetchNow() end
						local r=murdererTarget(false) if r then if shootAt(r,true) then lastSW=os.clock() else lastSW=os.clock()+2 end end
					end
					if K.aThrowWall and os.clock()-lastTW>0.9 and findTool(isKnife) then
						local r=nearest(false) if r then if throwAt(r,true) then lastTW=os.clock() else lastTW=os.clock()+2 end end
					end
					if K.aShoot and os.clock()-lastSW>0.5 and findTool(isGun) then
						if os.clock()-lastFetch>1.5 then lastFetch=os.clock() fetchNow() end
						local r=murdererTarget(true) if r then if shootAt(r,true) then lastSW=os.clock() else lastSW=os.clock()+2 end end
					end
					if K.aThrow and os.clock()-lastTW>0.9 and findTool(isKnife) then
						local r=nearest(true) if r then if throwAt(r,true) then lastTW=os.clock() else lastTW=os.clock()+2 end end
					end
				end)
			end
		end
	end)
	onUnload(function() for k in pairs(K) do K[k]=false end end)
end -- HUNTER

-- ===================== หมวด PLAYER =====================
do
	local playerSF=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},NX.pages["player"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},playerSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},playerSF)
	local ordP=0
	local function hdP(th,en) ordP+=1 local h=mk("Frame",{LayoutOrder=ordP,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},playerSF) local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h) corner2(bar,2) onAccent(function(c) bar.BackgroundColor3=c end) tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en) end
	local function togP(th,en,cb)
		ordP+=1
		local r=mk("Frame",{LayoutOrder=ordP,Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},playerSF)
		corner2(r,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r)
		tr(mkLabel(r,12,0,220,38,"",13,WHITE,HUD_FONT),th,en)
		local track=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.fromOffset(42,22),BackgroundColor3=Color3.fromRGB(50,50,50),Text="",AutoButtonColor=false},r)
		corner2(track,11)
		local knob=mk("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(170,170,170),BorderSizePixel=0},track)
		corner2(knob,8); local state=false
		local function paint(anim) local d=anim and 0.15 or 0 TweenService:Create(track,TweenInfo.new(d),{BackgroundColor3=state and ACCENT or Color3.fromRGB(50,50,50)}):Play() TweenService:Create(knob,TweenInfo.new(d),{Position=state and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0)}):Play() end
		onAccent(function() paint(false) end); paint(false)
		track.MouseButton1Click:Connect(function() state=not state paint(true) pcall(cb,state) end)
	end

	local WALK_BASE,WALK_ADD=16,100
	local JUMP_BASE,JUMP_ADD=50,100
	local FLY_SPEED=66
	local origColl=setmetatable({},{__mode="k"})
	local noclipWas=false
	bind(RunService.Stepped,function()
		local c=player.Character if not c then return end
		if P.noclip and not FLAGS.flinging then noclipWas=true for _,d in ipairs(c:GetDescendants()) do if d:IsA("BasePart") then if origColl[d]==nil then origColl[d]=d.CanCollide end d.CanCollide=false end end
		elseif noclipWas then noclipWas=false for part,v in pairs(origColl) do if part.Parent then part.CanCollide=v end origColl[part]=nil end end
	end)
	bind(RunService.Heartbeat,function()
		local _,_,hum=myParts() if not hum then return end
		if P.speed then hum.WalkSpeed=WALK_BASE+WALK_ADD end
		if P.jump then hum.UseJumpPower=true hum.JumpPower=JUMP_BASE+JUMP_ADD end
	end)
	local flyBV,flyBG
	local function stopFly() if flyBV then flyBV:Destroy() flyBV=nil end if flyBG then flyBG:Destroy() flyBG=nil end local _,_,hum=myParts() if hum then hum.AutoRotate=true end end
	local function startFly()
		local _,hrp,hum=myParts() if not hrp then return end stopFly()
		flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(9e9,9e9,9e9); flyBV.Velocity=Vector3.new(0,0,0); flyBV.Parent=hrp
		flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(9e9,9e9,9e9); flyBG.P=9e4; flyBG.CFrame=hrp.CFrame; flyBG.Parent=hrp
		if hum then hum.AutoRotate=false end
	end
	bind(RunService.RenderStepped,function()
		if not P.fly then return end
		if FLAGS.flinging or FLAGS.floating then if flyBV then stopFly() end return end
		local _,hrp,hum=myParts(); local cam=workspace.CurrentCamera
		if not (hrp and hum and cam) then return end
		if not (flyBV and flyBV.Parent==hrp) then startFly() end
		if not flyBV then return end
		local look=cam.CFrame.LookVector; local right=cam.CFrame.RightVector
		local fl=Vector3.new(look.X,0,look.Z); local fr=Vector3.new(right.X,0,right.Z)
		local vel=Vector3.new(0,0,0); local md=hum.MoveDirection
		if md.Magnitude>0.05 and fl.Magnitude>0.01 and fr.Magnitude>0.01 then
			vel=(look*md:Dot(fl.Unit)+right*md:Dot(fr.Unit))*FLY_SPEED
		end
		flyBV.Velocity=vel
		if flyBG and fl.Magnitude>0.01 then flyBG.CFrame=CFrame.lookAt(hrp.Position,hrp.Position+fl) end
	end)
	local tpTool
	local function giveTool()
		if tpTool and tpTool.Parent then return end
		local bp=player:FindFirstChild("Backpack") if not bp then return end
		tpTool=Instance.new("Tool"); tpTool.Name="TP NEXORA"; tpTool.ToolTip="TP NEXORA"
		tpTool.RequiresHandle=false; tpTool.CanBeDropped=false
		tpTool.Activated:Connect(function()
			local c=player.Character; local mouse=player:GetMouse()
			if c and mouse and mouse.Hit then c:PivotTo(CFrame.new(mouse.Hit.Position+Vector3.new(0,3,0))) end
		end)
		tpTool.Parent=bp
	end
	task.spawn(function() while not MM.dead do task.wait(1) if P.tp then giveTool() end end end)
	bind(RunService.Stepped,function()
		if not P.anti or FLAGS.flinging then return end
		for _,plr in ipairs(Players:GetPlayers()) do if plr~=player and plr.Character then for _,d in ipairs(plr.Character:GetDescendants()) do if d:IsA("BasePart") then d.CanCollide=false end end end end
	end)
	bind(RunService.Heartbeat,function()
		if not P.anti or FLAGS.flinging then return end
		local _,hrp=myParts()
		if hrp and (hrp.AssemblyLinearVelocity.Magnitude>250 or hrp.AssemblyAngularVelocity.Magnitude>60) then
			hrp.AssemblyLinearVelocity=Vector3.new(0,0,0); hrp.AssemblyAngularVelocity=Vector3.new(0,0,0)
		end
	end)

	hdP("// 🧍 PLAYER","// 🧍 PLAYER")
	togP("Noclip (ทะลุกำแพง)","Noclip", function(v) P.noclip=v end)
	togP("Speed (วิ่งเร็ว)","Speed", function(v) P.speed=v if not v then local _,_,hum=myParts() if hum then hum.WalkSpeed=WALK_BASE end end end)
	togP("High Jump (กระโดดสูง)","High Jump", function(v) P.jump=v if not v then local _,_,hum=myParts() if hum then hum.JumpPower=JUMP_BASE end end end)
	togP("Fly (บิน)","Fly", function(v) P.fly=v if not v then stopFly() end end)
	togP("TP Tool (เครื่องมือเทเลพอร์ต)","TP Tool", function(v) P.tp=v if v then giveTool() elseif tpTool then tpTool:Destroy() tpTool=nil end end)
	togP("Anti-Fling (กันโดนฟลิ้ง)","Anti-Fling", function(v) P.anti=v end)

	onUnload(function()
		for k in pairs(P) do P[k]=false end; stopFly()
		local _,_,hum=myParts() if hum then hum.WalkSpeed=WALK_BASE hum.JumpPower=JUMP_BASE end
		for part,v in pairs(origColl) do if part.Parent then part.CanCollide=v end origColl[part]=nil end
		if tpTool then tpTool:Destroy() tpTool=nil end
	end)
end -- PLAYER

-- ===================== หมวด COIN FARM =====================
do
	local farmSF=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},NX.pages["coinfarm"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},farmSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},farmSF)
	local ordFm=0
	local function hdFm(th,en) ordFm+=1 local h=mk("Frame",{LayoutOrder=ordFm,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},farmSF) local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h) corner2(bar,2) onAccent(function(c) bar.BackgroundColor3=c end) tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en) end

	local LIMIT,SPEED=40,20
	local FARM={on=false}
	local collected,lastCont,lastFind=0,nil,0
	local done,target,tStart,tLimit,arrT={},nil,0,3,nil
	local lastTouch=0; local fv,fg=nil,nil; local floating=false
	local origFarm=setmetatable({},{__mode="k"}); local toastedDone=false

	hdFm("// 🪙 COIN FARM","// 🪙 COIN FARM")

	-- counter paragraph
	local cntRow=mk("Frame",{LayoutOrder=ordFm+1,Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},farmSF)
	ordFm+=1; corner2(cntRow,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},cntRow)
	local cntLbl=mkLabel(cntRow,12,0,300,36,"🪙 0 / "..LIMIT,13,WHITE,HUD_FONT)

	local function coinPart(o) if o:IsA("BasePart") then return o end return o:FindFirstChildWhichIsA("BasePart",true) end
	local function nextCoin(cont,hrp) local best,bd for _,o in ipairs(cont:GetChildren()) do local p=coinPart(o) if p and p.Parent and not done[p] then local d=(p.Position-hrp.Position).Magnitude if not bd or d<bd then best,bd=p,d end end end return best,bd end
	local function releaseFarm()
		if fv then fv:Destroy() fv=nil end if fg then fg:Destroy() fg=nil end
		for part,v in pairs(origFarm) do if part.Parent then part.CanCollide=v end origFarm[part]=nil end
		if floating then floating=false FLAGS.floating=false local _,_,hum=myParts() if hum then hum.PlatformStand=false pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end end
	end
	local function engageFarm(hrp,hum)
		if not (fv and fv.Parent==hrp) then if fv then fv:Destroy() end fv=Instance.new("BodyVelocity") fv.MaxForce=Vector3.new(1e7,1e7,1e7) fv.Velocity=Vector3.new(0,0,0) fv.Parent=hrp end
		if not (fg and fg.Parent==hrp) then if fg then fg:Destroy() end fg=Instance.new("BodyGyro") fg.MaxTorque=Vector3.new(1e7,1e7,1e7) fg.P=1e5 fg.D=1e3 fg.CFrame=hrp.CFrame fg.Parent=hrp end
		floating=true; FLAGS.floating=true; hum.PlatformStand=true
	end
	local function resetRound() releaseFarm() collected=0 done={} target,arrT=nil,nil toastedDone=false end
	bind(player.CharacterAdded,resetRound)
	task.spawn(function()
		while not MM.dead do task.wait(0.5)
			cntLbl.Text="🪙 "..collected.." / "..LIMIT..(collected>=LIMIT and "  ✓" or (floating and "  ☁️" or ""))
		end
	end)
	bind(RunService.Stepped,function()
		if not floating then return end
		local c=player.Character if not c then return end
		for _,d in ipairs(c:GetDescendants()) do if d:IsA("BasePart") then if origFarm[d]==nil then origFarm[d]=d.CanCollide end d.CanCollide=false end end
	end)
	bind(RunService.Heartbeat,function()
		if not FARM.on then return end
		local c,hrp,hum=myParts() if not (c and hrp and hum and hum.Health>0) then return end
		if collected>=LIMIT then if not toastedDone then toastedDone=true releaseFarm() toast("🪙 ครบ "..LIMIT.." เหรียญแล้ว!","🪙 Collected "..LIMIT.." coins!") end return end
		local cont=lastCont
		if not cont or not cont.Parent or os.clock()-lastFind>3 then
			lastFind=os.clock()
			for _,f in ipairs(workspace:GetDescendants()) do
				if f:IsA("Folder") or f:IsA("Model") then
					local n=f.Name:lower() if n:find("coin") then cont=f lastCont=f break end
				end
			end
		end
		if not cont then return end
		if not target or not target.Parent or done[target] then
			target,_=nextCoin(cont,hrp) arrT=nil tStart=os.clock()
		end
		if not target then releaseFarm() return end
		engageFarm(hrp,hum)
		local dir=(target.Position-hrp.Position) local dist=dir.Magnitude
		if dist<3 then
			done[target]=true; collected+=1; target=nil
			if collected>=LIMIT then releaseFarm() end
			return
		end
		fv.Velocity=dir.Unit*math.min(dist*4,SPEED*2)
		if os.clock()-tStart>tLimit then done[target]=true target=nil tStart=os.clock() end
	end)

	-- toggle
	local togFmRow=mk("Frame",{LayoutOrder=ordFm+1,Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},farmSF)
	ordFm+=1; corner2(togFmRow,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},togFmRow)
	tr(mkLabel(togFmRow,12,0,220,38,"",13,WHITE,HUD_FONT),"เปิด/ปิด Auto Farm","Auto Farm On/Off")
	local track=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.fromOffset(42,22),BackgroundColor3=Color3.fromRGB(50,50,50),Text="",AutoButtonColor=false},togFmRow)
	corner2(track,11)
	local knobFm=mk("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(170,170,170),BorderSizePixel=0},track)
	corner2(knobFm,8); local farmState=false
	local function paintFm(anim) local d=anim and 0.15 or 0 TweenService:Create(track,TweenInfo.new(d),{BackgroundColor3=farmState and ACCENT or Color3.fromRGB(50,50,50)}):Play() TweenService:Create(knobFm,TweenInfo.new(d),{Position=farmState and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0)}):Play() end
	onAccent(function() paintFm(false) end); paintFm(false)
	track.MouseButton1Click:Connect(function()
		farmState=not farmState; FARM.on=farmState; paintFm(true)
		if not farmState then releaseFarm() end
	end)
	onUnload(function() FARM.on=false releaseFarm() end)
end -- COIN FARM

-- ===================== หมวด EVENT =====================
do
	local eventSF=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},NX.pages["event"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},eventSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},eventSF)
	local ordEv=0
	local function hdEv(th,en) ordEv+=1 local h=mk("Frame",{LayoutOrder=ordEv,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},eventSF) local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h) corner2(bar,2) onAccent(function(c) bar.BackgroundColor3=c end) tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en) end
	local function rowEv(h2) ordEv+=1 local r=mk("Frame",{LayoutOrder=ordEv,Size=UDim2.new(1,0,0,h2),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},eventSF) corner2(r,12) mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r) return r end

	hdEv("// 🎉 EVENT","// 🎉 EVENT")
	local infoRow=rowEv(50)
	local infoLbl=mkLabel(infoRow,12,4,370,42,"",11,GRAY,HUD_FONT)
	infoLbl.TextWrapped=true; infoLbl.TextYAlignment=Enum.TextYAlignment.Top
	tr(infoLbl,"แสดงข้อมูล event ที่กำลังดำเนินในเกม (อ่านจาก ReplicatedStorage)","Displays active event data from ReplicatedStorage")

	task.spawn(function()
		while not MM.dead do task.wait(3)
			pcall(function()
				local evFolder=ReplicatedStorage:FindFirstChild("Event") or ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("GameEvents")
				if evFolder then
					local lines={}
					for _,v in ipairs(evFolder:GetDescendants()) do
						if v:IsA("StringValue") or v:IsA("BoolValue") or v:IsA("IntValue") or v:IsA("NumberValue") then
							lines[#lines+1]=v.Name.." = "..tostring(v.Value)
						end
					end
					infoLbl.Text=#lines>0 and table.concat(lines,"\n") or T("No event data found","ไม่พบข้อมูล event")
				else
					infoLbl.Text=T("No event folder in ReplicatedStorage","ไม่พบ Event folder ใน ReplicatedStorage")
				end
			end)
		end
	end)
end -- EVENT

-- ===================== หมวด MUSIC =====================
do
	local musicSF=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},NX.pages["music"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},musicSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},musicSF)
	local ordMu=0
	local function hdMu(th,en) ordMu+=1 local h=mk("Frame",{LayoutOrder=ordMu,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},musicSF) local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h) corner2(bar,2) onAccent(function(c) bar.BackgroundColor3=c end) tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en) end
	local function rowMu(h2) ordMu+=1 local r=mk("Frame",{LayoutOrder=ordMu,Size=UDim2.new(1,0,0,h2),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},musicSF) corner2(r,12) mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r) return r end
	local function btnMu(th,en,cb) local r=rowMu(36) tr(mkLabel(r,12,0,250,36,"",13,WHITE,HUD_FONT),th,en) local b=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(80,26),BackgroundColor3=ACCENT,Text="",AutoButtonColor=false},r) corner2(b,10) onAccent(function(c) b.BackgroundColor3=c end) tr(mkLabel(b,0,0,80,26,"",11,WHITE,HUD_FONT,Enum.TextXAlignment.Center),"GO","ทำ") b.MouseButton1Click:Connect(function() sfx("click",nil,1.5) pcall(cb) end) end

	local MusicPlayer=Instance.new("Sound"); MusicPlayer.Volume=0.5; MusicPlayer.Parent=game:GetService("SoundService")
	local SongList={
		{Name="Spooky Scary Skeletons",Id="142376088"},
		{Name="Sans Undertale",Id="469500782"},
		{Name="Megalovania",Id="249054973"},
		{Name="Take On Me",Id="142452081"},
		{Name="Coffin Dance",Id="5932401751"},
		{Name="Among Us Theme",Id="6033476021"},
	}
	local currentSong=0
	local function LoadSong(i)
		currentSong=i; MusicPlayer.SoundId="rbxassetid://"..SongList[i].Id
		MusicPlayer:Play(); toast("🎵 "..SongList[i].Name,"🎵 "..SongList[i].Name)
	end

	hdMu("// 🎵 MUSIC","// 🎵 MUSIC")
	btnMu("▶ เล่นเพลงถัดไป","▶ Next Song",function()
		currentSong=currentSong%#SongList+1; LoadSong(currentSong)
	end)
	btnMu("⏹ หยุดเพลง","⏹ Stop Music",function()
		MusicPlayer:Stop(); toast("⏹ หยุดเพลงแล้ว","⏹ Music stopped")
	end)

	-- Volume slider
	local volRow=rowMu(50)
	tr(mkLabel(volRow,12,5,260,16,"",13,WHITE,HUD_FONT),"ระดับเสียง","Volume")
	local volLbl=mkLabel(volRow,0,5,370,16,"50%",12,GRAY,HUD_FONT,Enum.TextXAlignment.Right)
	local volTrack=mk("TextButton",{Position=UDim2.new(0,12,0,30),Size=UDim2.new(1,-24,0,6),BackgroundColor3=Color3.fromRGB(50,50,50),Text="",AutoButtonColor=false},volRow)
	corner2(volTrack,3)
	local volFill=mk("Frame",{Size=UDim2.fromScale(0.5,1),BackgroundColor3=ACCENT,BorderSizePixel=0},volTrack)
	corner2(volFill,3); onAccent(function(c) volFill.BackgroundColor3=c end)
	local volKnob=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=WHITE,BorderSizePixel=0},volFill)
	corner2(volKnob,7)
	local volDrag=false
	local function setVol(x) local t=math.clamp((x-volTrack.AbsolutePosition.X)/math.max(1,volTrack.AbsoluteSize.X),0,1) volFill.Size=UDim2.fromScale(t,1) volKnob.Position=UDim2.fromScale(t,0.5) MusicPlayer.Volume=t volLbl.Text=math.floor(t*100).."%"	end
	volTrack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then volDrag=true setVol(i.Position.X) end end)
	UIS.InputChanged:Connect(function(i) if volDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setVol(i.Position.X) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then volDrag=false end end)

	-- Song list
	hdMu("🎵 รายการเพลง","🎵 Song List")
	for i,sng in ipairs(SongList) do
		local r=rowMu(36)
		mkLabel(r,12,0,250,36,sng.Name,12,WHITE,HUD_FONT)
		local b=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(60,24),BackgroundColor3=ACCENT,Text="▶",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=WHITE,AutoButtonColor=false},r)
		corner2(b,10); onAccent(function(c) b.BackgroundColor3=c end)
		local idx=i; b.MouseButton1Click:Connect(function() sfx("click",nil,1.5) LoadSong(idx) end)
	end
	onUnload(function() MusicPlayer:Stop() MusicPlayer:Destroy() end)
end -- MUSIC

-- ===================== หมวด IDENTITY =====================
do
	local idSF=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},NX.pages["identity"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},idSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},idSF)
	local ordId=0
	local function hdId(th,en) ordId+=1 local h=mk("Frame",{LayoutOrder=ordId,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},idSF) local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h) corner2(bar,2) onAccent(function(c) bar.BackgroundColor3=c end) tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en) end
	local function rowId(h2) ordId+=1 local r=mk("Frame",{LayoutOrder=ordId,Size=UDim2.new(1,0,0,h2),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},idSF) corner2(r,12) mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r) return r end

	local lp=Players.LocalPlayer
	local fakeNameEnabled=false; local spoofNameText="Nexora"
	local originalData={}; local visualConnections={}; local isWorkspaceLooping=false
	local function safeReplace(str,find2,replace) local sf2=find2:gsub("[%-%^%$%(%)%%%.%[%]%*%+%?]","%%%1") return (str:gsub(sf2,replace)) end
	local function processText(v,myName,myDisp)
		local parentGui=v:FindFirstAncestorWhichIsA("ScreenGui")
		if parentGui and (string.find(parentGui.Name,"NexoraHubUI") or string.find(parentGui.Name,"NEXORA")) then return end
		if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
			local t=v.Text if t and t~="" and (string.find(t,myName,1,true) or string.find(t,myDisp,1,true)) then
				if not originalData[v] then originalData[v]={Text=t,Color=v.TextColor3} end
			end
			if originalData[v] then
				if fakeNameEnabled then local nt=originalData[v].Text nt=safeReplace(nt,myName,spoofNameText) nt=safeReplace(nt,myDisp,spoofNameText) v.Text=nt
				else v.Text=originalData[v].Text v.TextColor3=originalData[v].Color end
			end
		end
	end
	local function updateIdSystem()
		local myName=lp.Name; local myDisp=lp.DisplayName
		task.spawn(function()
			for _,p in pairs(Players:GetPlayers()) do if p.Character then for _,v in pairs(p.Character:GetDescendants()) do pcall(processText,v,myName,myDisp) end end end
			local pGui=lp:FindFirstChild("PlayerGui") if pGui then for _,v in pairs(pGui:GetDescendants()) do pcall(processText,v,myName,myDisp) end end
		end)
		if fakeNameEnabled and not isWorkspaceLooping then
			isWorkspaceLooping=true
			local pGui=lp:FindFirstChild("PlayerGui")
			if pGui then table.insert(visualConnections,pGui.DescendantAdded:Connect(function(o) if isWorkspaceLooping and (o:IsA("TextLabel") or o:IsA("TextBox") or o:IsA("TextButton")) then task.spawn(processText,o,myName,myDisp) end end)) end
		elseif not fakeNameEnabled then
			isWorkspaceLooping=false for _,conn in ipairs(visualConnections) do conn:Disconnect() end visualConnections={}
			for v,data in pairs(originalData) do if v and v.Parent then v.Text=data.Text v.TextColor3=data.Color end end originalData={}
		end
	end
	lp.CharacterAdded:Connect(function() if fakeNameEnabled then task.wait(1) updateIdSystem() end end)

	hdId("// 🎭 IDENTITY","// 🎭 IDENTITY")
	local togIdRow=rowId(42)
	tr(mkLabel(togIdRow,12,6,250,16,"",12,WHITE,HUD_FONT),"ชื่อปลอม","Fake Name")
	tr(mkLabel(togIdRow,12,22,250,14,"",9,GRAY,Enum.Font.Gotham),"แทนชื่อคุณในทุก UI","Replace your name in all UI")
	local swId=mk("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(42,22),Position=UDim2.new(1,-52,0.5,-11),BackgroundColor3=Color3.fromRGB(50,50,50)},togIdRow)
	corner2(swId,11)
	local knobId=mk("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(170,170,170),BorderSizePixel=0},swId)
	corner2(knobId,8); local idState=false
	local function paintId(anim) local d=anim and 0.15 or 0 TweenService:Create(swId,TweenInfo.new(d),{BackgroundColor3=idState and ACCENT or Color3.fromRGB(50,50,50)}):Play() TweenService:Create(knobId,TweenInfo.new(d),{Position=idState and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0)}):Play() end
	onAccent(function() paintId(false) end); paintId(false)
	swId.MouseButton1Click:Connect(function() idState=not idState paintId(true) fakeNameEnabled=idState updateIdSystem() end)

	hdId("✏️ ใส่ชื่อใหม่","✏️ New Name")
	local inpRow=rowId(42)
	tr(mkLabel(inpRow,12,4,300,14,"",11,WHITE,HUD_FONT),"พิมพ์ชื่อปลอม","Type fake name below")
	local inpBox=mk("TextBox",{Position=UDim2.fromOffset(14,22),Size=UDim2.new(1,-28,0,14),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=WHITE,PlaceholderText="Nexora...",PlaceholderColor3=GRAY,TextXAlignment=Enum.TextXAlignment.Left},inpRow)
	inpBox.FocusLost:Connect(function() if inpBox.Text~="" then spoofNameText=inpBox.Text if fakeNameEnabled then updateIdSystem() end end end)
	local arRow=rowId(36)
	local apB=mk("TextButton",{Position=UDim2.fromOffset(10,8),Size=UDim2.fromOffset(84,20),BackgroundColor3=ACCENT,Text="",AutoButtonColor=false},arRow)
	corner2(apB,10); onAccent(function(c) apB.BackgroundColor3=c end)
	tr(mkLabel(apB,0,0,84,20,"",10,WHITE,HUD_FONT,Enum.TextXAlignment.Center),"ใช้งาน","Apply")
	apB.MouseButton1Click:Connect(function() if inpBox.Text~="" then spoofNameText=inpBox.Text end idState=true paintId(false) fakeNameEnabled=true updateIdSystem() end)
	local rsB=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(84,20),BackgroundColor3=Color3.fromRGB(180,30,50),Text="",AutoButtonColor=false},arRow)
	corner2(rsB,10); tr(mkLabel(rsB,0,0,84,20,"",10,WHITE,HUD_FONT,Enum.TextXAlignment.Center),"คืนค่า","Reset")
	rsB.MouseButton1Click:Connect(function() idState=false paintId(false) fakeNameEnabled=false updateIdSystem() end)
end -- IDENTITY

-- ===================== หมวด INVISIBLE =====================
do
	local invSF=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},NX.pages["invisible"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},invSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},invSF)
	local ordInv=0
	local function hdInv(th,en) ordInv+=1 local h=mk("Frame",{LayoutOrder=ordInv,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},invSF) local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h) corner2(bar,2) onAccent(function(c) bar.BackgroundColor3=c end) tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en) end
	local function rowInv(h2) ordInv+=1 local r=mk("Frame",{LayoutOrder=ordInv,Size=UDim2.new(1,0,0,h2),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},invSF) corner2(r,12) mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r) return r end
	local lp=Players.LocalPlayer
	local InvisibilityActive=false; local nexvyrInvisibleConnection=nil
	local function AplicarTransparencia(state)
		if lp.Character then for _,v in pairs(lp.Character:GetDescendants()) do if v:IsA("BasePart") then
			if state and v.Transparency==0 then v:SetAttribute("NX_OrigTrans",0) v.Transparency=0.5
			elseif not state and v:GetAttribute("NX_OrigTrans")~=nil then v.Transparency=v:GetAttribute("NX_OrigTrans") v:SetAttribute("NX_OrigTrans",nil) end
		end end end
	end
	local function setInvisibleWorker(state)
		if nexvyrInvisibleConnection then nexvyrInvisibleConnection:Disconnect() nexvyrInvisibleConnection=nil end
		if not state then return end
		nexvyrInvisibleConnection=RunService.Heartbeat:Connect(function()
			if not InvisibilityActive then return end
			local Char=lp.Character if Char then local Root=Char:FindFirstChild("HumanoidRootPart") local Hum=Char:FindFirstChildOfClass("Humanoid")
				if Root and Hum and Hum.Health>0 and Root.Position.Y<200 then
					local oldCF=Root.CFrame local oldCamOffset=Hum.CameraOffset
					Root.CFrame=oldCF*CFrame.new(0,-40,0); Hum.CameraOffset=(oldCF*CFrame.new(0,-40,0)):ToObjectSpace(CFrame.new(oldCF.Position)).Position
					RunService.RenderStepped:Wait()
					if Root.Parent and Hum.Parent then Root.CFrame=oldCF Hum.CameraOffset=oldCamOffset end
				end
			end
		end)
	end
	lp.CharacterAdded:Connect(function(character) if InvisibilityActive then task.wait(0.5) AplicarTransparencia(true) end end)

	hdInv("// 👻 INVISIBLE","// 👻 INVISIBLE")
	local invTogRow=rowInv(42)
	tr(mkLabel(invTogRow,12,6,250,16,"",12,WHITE,HUD_FONT),"โหมดผี (ล่องหน)","Ghost Mode (Invisible)")
	tr(mkLabel(invTogRow,12,22,250,14,"",9,GRAY,Enum.Font.Gotham),"ซ่อนตัวละครจากผู้เล่นอื่น","Hides character from others")
	local swInv=mk("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(42,22),Position=UDim2.new(1,-52,0.5,-11),BackgroundColor3=Color3.fromRGB(50,50,50)},invTogRow)
	corner2(swInv,11)
	local knobInv=mk("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(170,170,170),BorderSizePixel=0},swInv)
	corner2(knobInv,8); local invState=false
	local function paintInv(anim) local d=anim and 0.15 or 0 TweenService:Create(swInv,TweenInfo.new(d),{BackgroundColor3=invState and ACCENT or Color3.fromRGB(50,50,50)}):Play() TweenService:Create(knobInv,TweenInfo.new(d),{Position=invState and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0)}):Play() end
	onAccent(function() paintInv(false) end); paintInv(false)
	swInv.MouseButton1Click:Connect(function() invState=not invState paintInv(true) InvisibilityActive=invState AplicarTransparencia(invState) setInvisibleWorker(invState) end)
	local noteRow=rowInv(50)
	local noteLbl=mkLabel(noteRow,12,4,370,42,"",10,GRAY,HUD_FONT)
	noteLbl.TextWrapped=true; noteLbl.TextYAlignment=Enum.TextYAlignment.Top
	tr(noteLbl,"โหมดล่องหนใช้การเลื่อนตำแหน่ง ทำงานได้ดีที่สุดเมื่อยืนนิ่ง อาจไม่ทำงานในบางเซิร์ฟ","Invisible mode uses position offset. Works best when standing still. May not work in all servers.")
	onUnload(function() if nexvyrInvisibleConnection then nexvyrInvisibleConnection:Disconnect() end InvisibilityActive=false AplicarTransparencia(false) end)
end -- INVISIBLE

-- ===================== หมวด ANIMATIONS =====================
do
	local animSF=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},NX.pages["animations"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},animSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},animSF)
	local ordAn=0
	local function hdAn(th,en) ordAn+=1 local h=mk("Frame",{LayoutOrder=ordAn,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},animSF) local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h) corner2(bar,2) onAccent(function(c) bar.BackgroundColor3=c end) tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en) end
	local lp=Players.LocalPlayer
	local emoteAnims={
		{Name="R15 Laugh",Id="3576823512"},{Name="R15 Point",Id="3576823512"},{Name="Tpose",Id="3576823512"},
		{Name="Dance",Id="507771019"},{Name="Wave",Id="507770239"},{Name="Cheer",Id="507770677"},
		{Name="Laugh",Id="507770818"},{Name="Point",Id="507770453"},
	}
	local currentAnim,animTrack=nil,nil
	local function stopAnim() if animTrack then pcall(function() animTrack:Stop() end) animTrack=nil end currentAnim=nil end
	local function playAnim(id)
		stopAnim()
		local char=lp.Character if not char then return end
		local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
		local animator=hum:FindFirstChildOfClass("Animator") if not animator then animator=Instance.new("Animator") animator.Parent=hum end
		local anim=Instance.new("Animation"); anim.AnimationId="rbxassetid://"..id
		local ok,track=pcall(function() return animator:LoadAnimation(anim) end)
		if ok and track then track:Play() animTrack=track currentAnim=id end
		anim:Destroy()
	end

	hdAn("// 🕺 ANIMATIONS","// 🕺 ANIMATIONS")
	for _,e in ipairs(emoteAnims) do
		ordAn+=1
		local r=mk("Frame",{LayoutOrder=ordAn,Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},animSF)
		corner2(r,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r)
		mkLabel(r,12,0,250,36,e.Name,13,WHITE,HUD_FONT)
		local b=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(80,26),BackgroundColor3=ACCENT,Text="",AutoButtonColor=false},r)
		corner2(b,10); onAccent(function(c) b.BackgroundColor3=c end)
		tr(mkLabel(b,0,0,80,26,"",11,WHITE,HUD_FONT,Enum.TextXAlignment.Center),"เล่น","Play")
		local eid=e.Id; b.MouseButton1Click:Connect(function() sfx("click",nil,1.5) playAnim(eid) end)
	end
	local stopRow=mk("Frame",{LayoutOrder=ordAn+1,Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},animSF)
	ordAn+=1; corner2(stopRow,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},stopRow)
	local stopB=mk("TextButton",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(0.6,0,0,26),BackgroundColor3=Color3.fromRGB(180,30,50),Text="",AutoButtonColor=false},stopRow)
	corner2(stopB,10)
	tr(mkLabel(stopB,0,0,0,0,"",11,WHITE,HUD_FONT,Enum.TextXAlignment.Center),"⏹ หยุดแอนิเมชัน","⏹ Stop Animation")
	stopB.Size=UDim2.new(0.6,0,0,26)
	stopB.MouseButton1Click:Connect(function() sfx("click",nil,1.5) stopAnim() end)
	onUnload(stopAnim)
end -- ANIMATIONS

-- ===================== หมวด ITEMS =====================
do
	local itemSF=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},NX.pages["items"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},itemSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},itemSF)
	local ordIt=0
	local function hdIt(th,en) ordIt+=1 local h=mk("Frame",{LayoutOrder=ordIt,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},itemSF) local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h) corner2(bar,2) onAccent(function(c) bar.BackgroundColor3=c end) tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en) end
	local function togIt(th,en,desc,cb)
		ordIt+=1
		local r=mk("Frame",{LayoutOrder=ordIt,Size=UDim2.new(1,0,0,desc and 46 or 38),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},itemSF)
		corner2(r,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r)
		tr(mkLabel(r,12,6,220,16,"",12,WHITE,HUD_FONT),th,en)
		if desc then tr(mkLabel(r,12,22,220,14,"",9,GRAY,Enum.Font.Gotham),desc,desc) end
		local track=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.fromOffset(42,22),BackgroundColor3=Color3.fromRGB(50,50,50),Text="",AutoButtonColor=false},r)
		corner2(track,11)
		local knob=mk("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(170,170,170),BorderSizePixel=0},track)
		corner2(knob,8); local state=false
		local function paint(anim) local d=anim and 0.15 or 0 TweenService:Create(track,TweenInfo.new(d),{BackgroundColor3=state and ACCENT or Color3.fromRGB(50,50,50)}):Play() TweenService:Create(knob,TweenInfo.new(d),{Position=state and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0)}):Play() end
		onAccent(function() paint(false) end); paint(false)
		track.MouseButton1Click:Connect(function() state=not state paint(true) pcall(cb,state) end)
	end
	local lp=Players.LocalPlayer
	local HeadlessEnabled=false
	local function setHeadlessTransparency(enabled)
		local char=lp.Character if not char then return end
		for _,name in ipairs({"Head","face"}) do local part=char:FindFirstChild(name) if part and part:IsA("BasePart") then part.Transparency=enabled and 1 or 0 for _,d in ipairs(part:GetDescendants()) do if d:IsA("Decal") or d:IsA("SpecialMesh") then d.Transparency=enabled and 1 or 0 end end end end
	end
	local KorbloxEnabled=false; local korbloxParts={}
	local function removeKorblox() for _,p in ipairs(korbloxParts) do pcall(function() p:Destroy() end) end korbloxParts={} local char=lp.Character if not char then return end local rightLeg=char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("Right Leg") if rightLeg and rightLeg:IsA("BasePart") then rightLeg.Transparency=0 end end
	local function applyKorblox()
		removeKorblox()
		local char=lp.Character if not char then return end
		local root=char:FindFirstChild("HumanoidRootPart"); local rightLeg=char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("Right Leg")
		if not (root and rightLeg) then return end; rightLeg.Transparency=1
		local part=mk("Part",{Name="KorbloxMesh",Anchored=false,CanCollide=false,Size=Vector3.new(1,1,1),CFrame=rightLeg.CFrame,Parent=char})
		mk("SpecialMesh",{MeshType=Enum.MeshType.FileMesh,MeshId="rbxassetid://19380685",TextureId="rbxassetid://26424018",Scale=Vector3.new(1,1,1)},part)
		mk("WeldConstraint",{Part0=part,Part1=rightLeg,Parent=part}); korbloxParts={part}
	end
	lp.CharacterAdded:Connect(function() task.wait(0.5) if HeadlessEnabled then setHeadlessTransparency(true) end if KorbloxEnabled then task.spawn(applyKorblox) end end)

	hdIt("// 🎒 ITEMS","// 🎒 ITEMS")
	togIt("หัวล่องหน","Headless Head","ทำให้หัวของคุณล่องหน",function(v) HeadlessEnabled=v setHeadlessTransparency(v) end)
	togIt("ขา Korblox","Korblox Deathspeaker","ใส่เมช Korblox ขาขวา",function(v) KorbloxEnabled=v if v then task.spawn(applyKorblox) else removeKorblox() end end)
	local noteItRow=mk("Frame",{LayoutOrder=ordIt+1,Size=UDim2.new(1,0,0,50),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},itemSF)
	ordIt+=1; corner2(noteItRow,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},noteItRow)
	local notItLbl=mkLabel(noteItRow,12,4,370,42,"",10,GRAY,HUD_FONT); notItLbl.TextWrapped=true; notItLbl.TextYAlignment=Enum.TextYAlignment.Top
	tr(notItLbl,"แสดงผลฝั่งตัวเองเท่านั้น ผู้เล่นอื่นยังเห็นหัวอยู่ รีเซ็ตเมื่อเกิดใหม่","Client-side only. Other players can still see your head. Resets on respawn.")
	onUnload(function() setHeadlessTransparency(false) removeKorblox() end)
end -- ITEMS

-- ===================== หมวด LIGHTING =====================
do
	local litSF=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Color3.new(1,1,1),ScrollBarImageTransparency=0.5,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},NX.pages["lighting"])
	mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},litSF)
	mk("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},litSF)
	local ordLi=0
	local Lighting=game:GetService("Lighting")
	local function hdLi(th,en) ordLi+=1 local h=mk("Frame",{LayoutOrder=ordLi,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},litSF) local bar=mk("Frame",{Position=UDim2.fromOffset(2,4),Size=UDim2.fromOffset(3,12),BackgroundColor3=ACCENT,BorderSizePixel=0},h) corner2(bar,2) onAccent(function(c) bar.BackgroundColor3=c end) tr(mkLabel(h,12,3,300,14,"",11,WHITE,TITLE_FONT),th,en) end
	local function togLi(th,en,desc,initState,cb)
		ordLi+=1
		local r=mk("Frame",{LayoutOrder=ordLi,Size=UDim2.new(1,0,0,desc and 46 or 38),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},litSF)
		corner2(r,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},r)
		tr(mkLabel(r,12,6,220,16,"",12,WHITE,HUD_FONT),th,en)
		if desc then tr(mkLabel(r,12,22,220,14,"",9,GRAY,Enum.Font.Gotham),desc,desc) end
		local track=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.fromOffset(42,22),BackgroundColor3=Color3.fromRGB(50,50,50),Text="",AutoButtonColor=false},r)
		corner2(track,11)
		local knob=mk("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(170,170,170),BorderSizePixel=0},track)
		corner2(knob,8); local state=initState or false
		local function paint(anim) local d=anim and 0.15 or 0 TweenService:Create(track,TweenInfo.new(d),{BackgroundColor3=state and ACCENT or Color3.fromRGB(50,50,50)}):Play() TweenService:Create(knob,TweenInfo.new(d),{Position=state and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0)}):Play() end
		onAccent(function() paint(false) end); paint(false)
		track.MouseButton1Click:Connect(function() state=not state paint(true) pcall(cb,state) end)
		return {Set=function(_,v) state=v paint(false) end}
	end
	local function SaveLighting(tag) if Lighting:GetAttribute("OrigSaved_"..tag) then return end local props={"Ambient","OutdoorAmbient","Brightness","ClockTime","FogColor","FogEnd","FogStart","ColorShift_Top","ColorShift_Bottom","ExposureCompensation","GlobalShadows","EnvironmentDiffuseScale","EnvironmentSpecularScale"} for _,k in ipairs(props) do Lighting:SetAttribute("Orig_"..k.."_"..tag,Lighting[k]) end Lighting:SetAttribute("OrigSaved_"..tag,true) end
	local function RestoreLighting(tag) if not Lighting:GetAttribute("OrigSaved_"..tag) then return end local props={"Ambient","OutdoorAmbient","Brightness","ClockTime","FogColor","FogEnd","FogStart","ColorShift_Top","ColorShift_Bottom","ExposureCompensation","GlobalShadows","EnvironmentDiffuseScale","EnvironmentSpecularScale"} for _,k in ipairs(props) do Lighting[k]=Lighting:GetAttribute("Orig_"..k.."_"..tag) end Lighting:SetAttribute("OrigSaved_"..tag,nil) end
	local function ClearEffects(list) for _,v in ipairs(list) do pcall(function() v:Destroy() end) end table.clear(list) end
	local nocheSangrientaEffects,atardecerEffects,sinVidaEffects={},{},{}
	local nocheSangrientaSkyFolder=nil
	local nocheTog,atardecerTog,sinVidaTog

	local function ApplyNocheSangrienta(state)
		if state then
			SaveLighting("NS"); ClearEffects(nocheSangrientaEffects)
			if nocheSangrientaSkyFolder then nocheSangrientaSkyFolder:Destroy() end
			nocheSangrientaSkyFolder=Instance.new("Folder"); nocheSangrientaSkyFolder.Name="NX_NS_Sky"; nocheSangrientaSkyFolder.Parent=workspace
			local sky=Instance.new("Sky"); sky.StarCount=9000 sky.MoonAngularSize=30 sky.SunAngularSize=0 sky.CelestialBodiesShown=true sky.Parent=Lighting table.insert(nocheSangrientaEffects,sky)
			local cc=Instance.new("ColorCorrectionEffect"); cc.Brightness=0.05 cc.Contrast=0.32 cc.Saturation=-0.15 cc.TintColor=Color3.fromRGB(255,130,130) cc.Parent=Lighting table.insert(nocheSangrientaEffects,cc)
			local bloom=Instance.new("BloomEffect"); bloom.Intensity=1 bloom.Size=90 bloom.Threshold=0.45 bloom.Parent=Lighting table.insert(nocheSangrientaEffects,bloom)
			local atmo=Instance.new("Atmosphere"); atmo.Density=0.42 atmo.Color=Color3.fromRGB(60,12,12) atmo.Decay=Color3.fromRGB(80,20,20) atmo.Glare=0.5 atmo.Haze=1.6 atmo.Parent=Lighting table.insert(nocheSangrientaEffects,atmo)
			Lighting.ClockTime=0 Lighting.Brightness=1.2 Lighting.Ambient=Color3.fromRGB(130,110,110) Lighting.OutdoorAmbient=Color3.fromRGB(180,140,140)
			Lighting.FogColor=Color3.fromRGB(22,5,5) Lighting.FogEnd=1200 Lighting.FogStart=150
			Lighting.ColorShift_Top=Color3.fromRGB(125,25,25) Lighting.ColorShift_Bottom=Color3.fromRGB(65,8,8) Lighting.GlobalShadows=true
		else ClearEffects(nocheSangrientaEffects) if nocheSangrientaSkyFolder then nocheSangrientaSkyFolder:Destroy() nocheSangrientaSkyFolder=nil end RestoreLighting("NS") end
	end
	local function ApplyAtardecer(state)
		if state then
			SaveLighting("AF"); ClearEffects(atardecerEffects)
			local cc=Instance.new("ColorCorrectionEffect"); cc.Brightness=0.05 cc.Contrast=0.14 cc.Saturation=0.22 cc.TintColor=Color3.fromRGB(255,205,165) cc.Parent=Lighting table.insert(atardecerEffects,cc)
			local bloom=Instance.new("BloomEffect"); bloom.Intensity=0.32 bloom.Size=40 bloom.Threshold=0.92 bloom.Parent=Lighting table.insert(atardecerEffects,bloom)
			local rays=Instance.new("SunRaysEffect"); rays.Intensity=0.15 rays.Spread=0.9 rays.Parent=Lighting table.insert(atardecerEffects,rays)
			local sky=Instance.new("Sky"); sky.SunAngularSize=18 sky.StarCount=2000 sky.Parent=Lighting table.insert(atardecerEffects,sky)
			local atmo=Instance.new("Atmosphere"); atmo.Density=0.36 atmo.Color=Color3.fromRGB(255,185,135) atmo.Decay=Color3.fromRGB(255,125,85) atmo.Glare=0.2 atmo.Haze=1.2 atmo.Parent=Lighting table.insert(atardecerEffects,atmo)
			Lighting.ClockTime=6.3 Lighting.Brightness=2.4 Lighting.Ambient=Color3.fromRGB(85,62,55) Lighting.OutdoorAmbient=Color3.fromRGB(125,92,80)
			Lighting.FogColor=Color3.fromRGB(240,185,145) Lighting.FogEnd=2500 Lighting.FogStart=200
			Lighting.ColorShift_Top=Color3.fromRGB(255,185,105) Lighting.ColorShift_Bottom=Color3.fromRGB(205,105,85) Lighting.GlobalShadows=true
		else ClearEffects(atardecerEffects) RestoreLighting("AF") end
	end
	local function ApplySinVida(state)
		if state then
			SaveLighting("SV"); ClearEffects(sinVidaEffects)
			local cc=Instance.new("ColorCorrectionEffect"); cc.Brightness=0.05 cc.Contrast=0.22 cc.Saturation=-1 cc.TintColor=Color3.fromRGB(222,226,232) cc.Parent=Lighting table.insert(sinVidaEffects,cc)
			local bloom=Instance.new("BloomEffect"); bloom.Intensity=1.25 bloom.Size=75 bloom.Threshold=0.38 bloom.Parent=Lighting table.insert(sinVidaEffects,bloom)
			local sky=Instance.new("Sky"); sky.StarCount=0 sky.SunAngularSize=0 sky.MoonAngularSize=0 sky.CelestialBodiesShown=false sky.Parent=Lighting table.insert(sinVidaEffects,sky)
			local atmo=Instance.new("Atmosphere"); atmo.Density=0.3 atmo.Color=Color3.fromRGB(180,185,190) atmo.Decay=Color3.fromRGB(140,145,150) atmo.Glare=0 atmo.Haze=1.0 atmo.Parent=Lighting table.insert(sinVidaEffects,atmo)
			Lighting.ClockTime=14 Lighting.Brightness=2.2 Lighting.Ambient=Color3.fromRGB(92,96,100) Lighting.OutdoorAmbient=Color3.fromRGB(132,136,140)
			Lighting.FogColor=Color3.fromRGB(172,176,180) Lighting.FogEnd=3000 Lighting.FogStart=200
			Lighting.ColorShift_Top=Color3.fromRGB(152,156,160) Lighting.ColorShift_Bottom=Color3.fromRGB(122,126,130) Lighting.GlobalShadows=true
		else ClearEffects(sinVidaEffects) RestoreLighting("SV") end
	end

	hdLi("// 💡 LIGHTING","// 💡 LIGHTING")
	nocheTog=togLi("🔴 คืนเลือด","🔴 Bloody Night","Dark red horror atmosphere",false,function(state)
		if state then if atardecerTog then pcall(function() atardecerTog:Set(false) end) end if sinVidaTog then pcall(function() sinVidaTog:Set(false) end) end end
		ApplyNocheSangrienta(state)
	end)
	atardecerTog=togLi("🌅 พระอาทิตย์ตก","🌅 Sunset","Warm golden sunset glow",false,function(state)
		if state then if nocheTog then pcall(function() nocheTog:Set(false) end) end if sinVidaTog then pcall(function() sinVidaTog:Set(false) end) end end
		ApplyAtardecer(state)
	end)
	sinVidaTog=togLi("⬜ ไร้ชีวิต (ขาวดำ)","⬜ Lifeless (Grayscale)","Desaturated bleak world",false,function(state)
		if state then if nocheTog then pcall(function() nocheTog:Set(false) end) end if atardecerTog then pcall(function() atardecerTog:Set(false) end) end end
		ApplySinVida(state)
	end)

	-- Brightness slider
	hdLi("🔆 ปรับเร็ว","🔆 Quick Adjust")
	local briRow=mk("Frame",{LayoutOrder=ordLi+1,Size=UDim2.new(1,0,0,50),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},litSF)
	ordLi+=1; corner2(briRow,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},briRow)
	tr(mkLabel(briRow,12,5,260,16,"",13,WHITE,HUD_FONT),"ความสว่าง","Brightness")
	local briLbl=mkLabel(briRow,0,5,370,16,"",12,GRAY,HUD_FONT,Enum.TextXAlignment.Right)
	local briTrack=mk("TextButton",{Position=UDim2.new(0,12,0,30),Size=UDim2.new(1,-24,0,8),BackgroundColor3=Color3.fromRGB(50,50,50),Text="",AutoButtonColor=false},briRow)
	corner2(briTrack,4)
	local briFill=mk("Frame",{Size=UDim2.fromScale(0.5,1),BackgroundColor3=ACCENT,BorderSizePixel=0},briTrack)
	corner2(briFill,4); onAccent(function(c) briFill.BackgroundColor3=c end)
	local briKnob=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=WHITE,BorderSizePixel=0},briFill)
	corner2(briKnob,7); local briDrag=false
	local function setBri(x) local t=math.clamp((x-briTrack.AbsolutePosition.X)/math.max(1,briTrack.AbsoluteSize.X),0,1) briFill.Size=UDim2.fromScale(t,1) briKnob.Position=UDim2.fromScale(t,0.5) Lighting.Brightness=t*5 briLbl.Text=string.format("%.1f",t*5) end
	briTrack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then briDrag=true setBri(i.Position.X) end end)
	UIS.InputChanged:Connect(function(i) if briDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setBri(i.Position.X) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then briDrag=false end end)
	do local t=math.clamp(Lighting.Brightness/5,0,1) briFill.Size=UDim2.fromScale(t,1) briKnob.Position=UDim2.fromScale(t,0.5) briLbl.Text=string.format("%.1f",Lighting.Brightness) end

	-- Reset
	local rstRow=mk("Frame",{LayoutOrder=ordLi+1,Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(14,14,14),BackgroundTransparency=0.25,BorderSizePixel=0},litSF)
	ordLi+=1; corner2(rstRow,12); mk("UIStroke",{Color=Color3.fromRGB(120,120,120),Transparency=0.6,Thickness=1},rstRow)
	local rstB=mk("TextButton",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(160,24),BackgroundColor3=ACCENT,Text="",AutoButtonColor=false},rstRow)
	corner2(rstB,12); onAccent(function(c) rstB.BackgroundColor3=c end)
	tr(mkLabel(rstB,0,0,0,0,"",11,WHITE,HUD_FONT,Enum.TextXAlignment.Center),"คืนค่าแสงฉาก","Restore Lighting")
	rstB.Size=UDim2.fromOffset(160,24)
	rstB.MouseButton1Click:Connect(function()
		if nocheTog then pcall(function() nocheTog:Set(false) end) end
		if atardecerTog then pcall(function() atardecerTog:Set(false) end) end
		if sinVidaTog then pcall(function() sinVidaTog:Set(false) end) end
		for _,tag in ipairs({"NS","AF","SV"}) do RestoreLighting(tag) end
		toast("คืนค่าแสงฉากแล้ว","Lighting restored")
	end)
	onUnload(function()
		if nocheTog then pcall(function() nocheTog:Set(false) end) end
		if atardecerTog then pcall(function() atardecerTog:Set(false) end) end
		if sinVidaTog then pcall(function() sinVidaTog:Set(false) end) end
		for _,tag in ipairs({"NS","AF","SV"}) do RestoreLighting(tag) end
	end)
end -- LIGHTING

end) -- guard("mm2_features")

guard("settings", buildSettings)

end

local __ok, __err = xpcall(__main, function(e) return tostring(e) .. "\n" .. debug.traceback("", 2) end)
if not __ok then showError("main", __err) end
