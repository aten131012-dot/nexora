-- NEXORA HUB Key System v10
-- StarterGui > LocalScript  (วางส่วนที่ 1 แล้วต่อด้วยส่วนที่ 2)

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera    = workspace.CurrentCamera

local LOGO_ID   = "rbxassetid://86383017875768"
local API       = "https://nexora-key.aten131012.workers.dev"
local KEYPAGE   = "https://nexorascript.netlify.app/#key"
local DISC_LINK = "https://discord.gg/vHRMNpDsQ4"

local LANG = {
	EN = {
		key_title   = "Enter Your Key",
		key_sub     = "Please enter the key you received to use the script.",
		placeholder = "Enter key...",
		confirm     = "CONFIRM",
		getkey      = "Copy Key Link",
		discord     = "Copy Discord",
		checking    = "Checking key...",
		granted     = "Access granted",
		wrong       = "Wrong key",
		server_err  = "Server error. Try again.",
		device_err  = "Key used on another device",
		empty       = "Enter your key first",
		copied      = "Copied!",
		copy_url    = "nexorascript.netlify.app/#key",
		disc_url    = "discord.gg/vHRMNpDsQ4",
	},
	TH = {
		key_title   = "ใส่คีย์ของคุณ",
		key_sub     = "กรุณากรอกคีย์ที่ได้รับเพื่อใช้งานสคริปต์",
		placeholder = "ใส่คีย์...",
		confirm     = "ยืนยัน",
		getkey      = "คัดลอกลิงก์คีย์",
		discord     = "คัดลอกดิสคอร์ด",
		checking    = "กำลังตรวจสอบ...",
		granted     = "เข้าใช้งานได้แล้ว",
		wrong       = "คีย์ไม่ถูกต้อง",
		server_err  = "เซิร์ฟเวอร์ผิดพลาด ลองใหม่",
		device_err  = "คีย์ถูกใช้บนอุปกรณ์อื่น",
		empty       = "กรุณาใส่คีย์ก่อน",
		copied      = "คัดลอกแล้ว!",
		copy_url    = "nexorascript.netlify.app/#key",
		disc_url    = "discord.gg/vHRMNpDsQ4",
	},
}
local currentLang = "TH"
local function T(k) return LANG[currentLang][k] end

local HWID
do
	local ok, id = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
	HWID = (ok and id and id ~= "") and id or tostring(player.UserId)
end

-- ════════ HELPERS ════════
local WHITE = Color3.new(1, 1, 1)
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end
local function corner(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, o) end
local function stroke(o, col, th, tr)
	return new("UIStroke", {Color = col, Thickness = th or 1, Transparency = tr or 0}, o)
end
local function tw(o, t, p, style, dir)
	TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), p):Play()
end

-- ════════ ROOT ════════
local ScreenGui = new("ScreenGui", {
	Name = "NexoraKey", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999,
}, playerGui)

local Backdrop = new("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1,
}, ScreenGui)

local BgLogo = new("ImageLabel", {
	Size = UDim2.fromOffset(220, 220), AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1,
	Image = LOGO_ID, ImageTransparency = 0.88, ScaleType = Enum.ScaleType.Fit, ZIndex = 2,
}, ScreenGui)
task.spawn(function()
	while BgLogo.Parent do
		tw(BgLogo, 2.8, {ImageTransparency = 0.80}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); task.wait(2.8)
		tw(BgLogo, 2.8, {ImageTransparency = 0.93}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); task.wait(2.8)
	end
end)

local LCanvas = new("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3,
}, ScreenGui)

-- ════════ CARD 400x204 (ย่อตามหน้าจออัตโนมัติ) ════════
local CARD_W, CARD_H, LEFT_W, RADIUS = 400, 204, 138, 18

local Card = new("Frame", {
	Name = "Card", Size = UDim2.fromOffset(CARD_W, CARD_H),
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.68, 0),
	BackgroundColor3 = Color3.fromRGB(8, 8, 8), BackgroundTransparency = 1,
	BorderSizePixel = 0, ZIndex = 10,
}, ScreenGui)
corner(Card, RADIUS)

-- ขอบเรืองแสงวิ่งรอบการ์ด
local CardStroke = stroke(Card, WHITE, 1.5, 0)
local CGrad = new("UIGradient", {
	Rotation = 0,
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.88),
		NumberSequenceKeypoint.new(0.40, 0.88),
		NumberSequenceKeypoint.new(0.50, 0),
		NumberSequenceKeypoint.new(0.60, 0.88),
		NumberSequenceKeypoint.new(1,   0.88),
	}),
}, CardStroke)
task.spawn(function()
	local r = 0
	while Card.Parent do r = (r + 2.2) % 360; CGrad.Rotation = r; task.wait(0.016) end
end)

-- scale ตามหน้าจอ + intro
local Scale = new("UIScale", {}, Card)
local baseScale, introDone = 1, false
local function fit()
	local vp = camera.ViewportSize
	baseScale = math.clamp(math.min(vp.X * 0.9 / CARD_W, vp.Y * 0.66 / CARD_H), 0.55, 1)
	if introDone then Scale.Scale = baseScale end
end
fit()
Scale.Scale = baseScale * 0.88
camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)

-- ════════ LEFT PANEL (มุมซ้ายมน / ขวาเรียบ) ════════
local LeftPanel = new("Frame", {
	Size = UDim2.new(0, LEFT_W, 1, 0), BackgroundColor3 = Color3.fromRGB(5, 5, 5),
	BorderSizePixel = 0, ZIndex = 11,
}, Card)
corner(LeftPanel, RADIUS)
new("Frame", { -- ตัวอุดฝั่งขวาให้เรียบ
	Size = UDim2.new(0, RADIUS + 2, 1, 0), Position = UDim2.new(1, -(RADIUS + 2), 0, 0),
	BackgroundColor3 = Color3.fromRGB(5, 5, 5), BorderSizePixel = 0, ZIndex = 11,
}, LeftPanel)
new("Frame", {
	Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0),
	BackgroundColor3 = WHITE, BackgroundTransparency = 0.85, BorderSizePixel = 0, ZIndex = 12,
}, LeftPanel)

-- วงคลื่นแผ่ออกจากโลโก้
local Pulse = new("Frame", {
	Size = UDim2.fromOffset(110, 110), AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, ZIndex = 12,
}, LeftPanel)
corner(Pulse, 99)
local PStroke = stroke(Pulse, WHITE, 1.2, 0.5)
task.spawn(function()
	while Pulse.Parent do
		Pulse.Size = UDim2.fromOffset(110, 110); PStroke.Transparency = 0.5
		tw(Pulse, 1.9, {Size = UDim2.fromOffset(134, 134)})
		tw(PStroke, 1.9, {Transparency = 1})
		task.wait(2.2)
	end
end)

local Ring = new("ImageLabel", {
	Size = UDim2.fromOffset(130, 130), AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1,
	Image = "rbxassetid://6401145959", ImageTransparency = 0.8, ZIndex = 12,
}, LeftPanel)
local Logo = new("ImageLabel", {
	Size = UDim2.fromOffset(112, 112), AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1,
	Image = LOGO_ID, ScaleType = Enum.ScaleType.Fit, ZIndex = 13,
}, LeftPanel)
task.spawn(function()
	local r = 0
	while Ring.Parent do r = (r + 1.2) % 360; Ring.Rotation = r; task.wait(0.016) end
end)
task.spawn(function()
	while Logo.Parent do
		tw(Logo, 2, {ImageTransparency = 0.15}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); task.wait(2)
		tw(Logo, 2, {ImageTransparency = 0},    Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); task.wait(2)
	end
end)

-- อนุภาคลอยขึ้น
task.spawn(function()
	while LeftPanel.Parent do
		local s = math.random(2, 3)
		local x = math.random(18, LEFT_W - 18)
		local p = new("Frame", {
			Size = UDim2.fromOffset(s, s), Position = UDim2.fromOffset(x, CARD_H - 24),
			BackgroundColor3 = WHITE, BackgroundTransparency = 0.55, BorderSizePixel = 0, ZIndex = 12,
		}, LeftPanel)
		corner(p, 99)
		local life = math.random(30, 50) / 10
		TweenService:Create(p, TweenInfo.new(life, Enum.EasingStyle.Linear), {
			Position = UDim2.fromOffset(x + math.random(-12, 12), 24), BackgroundTransparency = 1,
		}):Play()
		task.delay(life + 0.1, function() p:Destroy() end)
		task.wait(0.4)
	end
end)

-- ════════ RIGHT PANEL ════════
local RP = new("Frame", {
	Size = UDim2.new(1, -LEFT_W, 1, 0), Position = UDim2.new(0, LEFT_W, 0, 0),
	BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 11,
}, Card)

-- header (มุมขวาบนมน)
local HDR_H = 38
local HDR_COL = Color3.fromRGB(11, 11, 11)
local Header = new("Frame", {
	Size = UDim2.new(1, 0, 0, HDR_H), BackgroundColor3 = HDR_COL, BorderSizePixel = 0, ZIndex = 12,
}, RP)
corner(Header, RADIUS)
new("Frame", { -- อุดซ้าย
	Size = UDim2.new(0, RADIUS + 2, 1, 0), BackgroundColor3 = HDR_COL, BorderSizePixel = 0, ZIndex = 12,
}, Header)
new("Frame", { -- อุดล่าง
	Size = UDim2.new(1, 0, 0, HDR_H / 2), Position = UDim2.new(0, 0, 1, -HDR_H / 2),
	BackgroundColor3 = HDR_COL, BorderSizePixel = 0, ZIndex = 12,
}, Header)
new("Frame", {
	Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
	BackgroundColor3 = WHITE, BackgroundTransparency = 0.85, BorderSizePixel = 0, ZIndex = 13,
}, Header)
new("TextLabel", {
	Size = UDim2.new(0, 18, 1, 0), Position = UDim2.new(0, 10, 0, 0),
	BackgroundTransparency = 1, Text = "//", TextColor3 = WHITE, TextTransparency = 0.6,
	Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 13,
}, Header)
new("TextLabel", {
	Size = UDim2.new(0, 120, 0, 16), Position = UDim2.new(0, 30, 0, 5),
	BackgroundTransparency = 1, Text = "NEXORA HUB", TextColor3 = WHITE,
	Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
}, Header)
new("TextLabel", {
	Size = UDim2.new(0, 120, 0, 10), Position = UDim2.new(0, 30, 0, 23),
	BackgroundTransparency = 1, Text = "POWERED BY NEXORA", TextColor3 = Color3.fromRGB(100, 100, 100),
	Font = Enum.Font.Gotham, TextSize = 7, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
}, Header)

local LangBtn = new("TextButton", {
	Size = UDim2.fromOffset(32, 20), AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -40, 0.5, 0), BackgroundColor3 = Color3.fromRGB(18, 18, 18),
	BorderSizePixel = 0, AutoButtonColor = false, Text = "EN",
	TextColor3 = Color3.fromRGB(150, 150, 150), Font = Enum.Font.GothamBold, TextSize = 9, ZIndex = 15,
}, Header)
corner(LangBtn, 6)
local LangStroke = stroke(LangBtn, Color3.fromRGB(50, 50, 50))

local CloseBtn = new("TextButton", {
	Size = UDim2.fromOffset(24, 20), AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -10, 0.5, 0), BackgroundColor3 = Color3.fromRGB(18, 18, 18),
	BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 15,
}, Header)
corner(CloseBtn, 6)
local CloseStroke = stroke(CloseBtn, Color3.fromRGB(50, 50, 50))
local xBars = {}
for _, rot in ipairs({45, -45}) do
	table.insert(xBars, new("Frame", {
		Size = UDim2.fromOffset(10, 1.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Rotation = rot,
		BackgroundColor3 = Color3.fromRGB(150, 150, 150), BorderSizePixel = 0, ZIndex = 16,
	}, CloseBtn))
end

-- หัวข้อ
local KTitle = new("TextLabel", {
	Size = UDim2.new(1, -28, 0, 16), Position = UDim2.new(0, 14, 0, 46),
	BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(240, 240, 240),
	Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
}, RP)
local KSub = new("TextLabel", {
	Size = UDim2.new(1, -28, 0, 12), Position = UDim2.new(0, 14, 0, 62),
	BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(125, 125, 125),
	Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
}, RP)

-- ช่องใส่คีย์
local IWrap = new("Frame", {
	Size = UDim2.new(1, -28, 0, 32), Position = UDim2.new(0, 14, 0, 80),
	BackgroundColor3 = Color3.fromRGB(13, 13, 13), BorderSizePixel = 0, ZIndex = 12,
}, RP)
corner(IWrap, 8)
local IStroke = stroke(IWrap, Color3.fromRGB(48, 48, 48))

local LockLbl = new("TextLabel", {
	Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -26, 0, 0),
	BackgroundTransparency = 1, Text = "🔒", TextSize = 11,
	TextColor3 = Color3.fromRGB(150, 150, 150), Font = Enum.Font.GothamBold, ZIndex = 14,
}, IWrap)
local KeyInput = new("TextBox", {
	Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 10, 0, 0),
	BackgroundTransparency = 1, Text = "", PlaceholderColor3 = Color3.fromRGB(80, 80, 80),
	TextColor3 = Color3.fromRGB(220, 220, 220), Font = Enum.Font.Code, TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 13,
}, IWrap)
KeyInput.Focused:Connect(function()
	tw(IStroke, 0.2, {Color = Color3.fromRGB(210, 210, 210), Thickness = 1.5})
	tw(IWrap, 0.2, {BackgroundColor3 = Color3.fromRGB(18, 18, 18)})
end)
KeyInput.FocusLost:Connect(function()
	tw(IStroke, 0.2, {Color = Color3.fromRGB(48, 48, 48), Thickness = 1})
	tw(IWrap, 0.2, {BackgroundColor3 = Color3.fromRGB(13, 13, 13)})
end)

local Status = new("TextLabel", {
	Size = UDim2.new(1, -28, 0, 12), Position = UDim2.new(0, 14, 0, 114),
	BackgroundTransparency = 1, Text = "", TextColor3 = Color3.fromRGB(255, 80, 80),
	Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
}, RP)

-- ปุ่มยืนยัน + แสงวิ่งผ่าน
local ConfirmBtn = new("TextButton", {
	Size = UDim2.new(1, -28, 0, 32), Position = UDim2.new(0, 14, 0, 128),
	BackgroundColor3 = Color3.fromRGB(228, 228, 228), BorderSizePixel = 0, AutoButtonColor = false,
	TextColor3 = Color3.new(0, 0, 0), Font = Enum.Font.GothamBold, TextSize = 12,
	ZIndex = 12, ClipsDescendants = true,
}, RP)
corner(ConfirmBtn, 8)
local CSh = new("Frame", {
	Size = UDim2.new(0, 44, 2, 0), Position = UDim2.new(0, -70, -0.5, 0), Rotation = 14,
	BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 13,
}, ConfirmBtn)
new("UIGradient", {
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.35), NumberSequenceKeypoint.new(1, 1),
	}),
}, CSh)
task.spawn(function()
	while ConfirmBtn.Parent do
		CSh.Position = UDim2.new(0, -70, -0.5, 0)
		tw(CSh, 0.9, {Position = UDim2.new(1, 30, -0.5, 0)})
		task.wait(3.4)
	end
end)
ConfirmBtn.MouseEnter:Connect(function() tw(ConfirmBtn, 0.15, {BackgroundColor3 = WHITE}) end)
ConfirmBtn.MouseLeave:Connect(function() tw(ConfirmBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(228, 228, 228)}) end)
ConfirmBtn.MouseButton1Down:Connect(function() tw(ConfirmBtn, 0.08, {BackgroundColor3 = Color3.fromRGB(185, 185, 185)}) end)

-- success overlay
local SOv = new("Frame", {
	Size = UDim2.new(1, -28, 0, 32), Position = UDim2.new(0, 14, 0, 128),
	BackgroundColor3 = Color3.fromRGB(65, 205, 125), BackgroundTransparency = 1,
	BorderSizePixel = 0, ZIndex = 14, Visible = false,
}, RP)
corner(SOv, 8)
local SLbl = new("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, TextColor3 = Color3.new(0, 0, 0),
	Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 15,
}, SOv)
local function playSuccessAnim()
	SLbl.Text = T("granted"); SLbl.TextTransparency = 1
	SOv.BackgroundTransparency = 1; SOv.Visible = true
	tw(SOv, 0.25, {BackgroundTransparency = 0})
	tw(SLbl, 0.3, {TextTransparency = 0})
end
-- ════════ ปุ่มคัดลอก ════════
local BTN_Y = 166
local GREEN = Color3.fromRGB(65, 205, 125)
local AMBER = Color3.fromRGB(235, 180, 40)
local BLURPLE = Color3.fromRGB(110, 120, 255)

local function makeCopyBtn(anchorX, posX, accent)
	local b = new("TextButton", {
		Size = UDim2.new(0.5, -18, 0, 30), AnchorPoint = Vector2.new(anchorX, 0),
		Position = UDim2.new(posX, anchorX == 1 and -14 or 14, 0, BTN_Y),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15), BorderSizePixel = 0,
		AutoButtonColor = false, Text = "", ZIndex = 12,
	}, RP)
	corner(b, 8)
	local s = stroke(b, Color3.fromRGB(45, 45, 45))
	local bar = new("Frame", {
		Size = UDim2.fromOffset(3, 12), AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 8, 0.5, 0), BackgroundColor3 = accent,
		BorderSizePixel = 0, ZIndex = 13,
	}, b)
	corner(bar, 2)
	local lbl = new("TextLabel", {
		Size = UDim2.new(1, -22, 1, 0), Position = UDim2.new(0, 18, 0, 0),
		BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(190, 190, 190),
		Font = Enum.Font.GothamMedium, TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
	}, b)
	b.MouseEnter:Connect(function()
		tw(b, 0.12, {BackgroundColor3 = Color3.fromRGB(24, 24, 24)})
		tw(s, 0.12, {Color = accent})
		tw(lbl, 0.12, {TextColor3 = WHITE})
		tw(bar, 0.15, {Size = UDim2.fromOffset(3, 18)})
	end)
	b.MouseLeave:Connect(function()
		tw(b, 0.12, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)})
		tw(s, 0.12, {Color = Color3.fromRGB(45, 45, 45)})
		tw(lbl, 0.12, {TextColor3 = Color3.fromRGB(190, 190, 190)})
		tw(bar, 0.15, {Size = UDim2.fromOffset(3, 12)})
	end)
	b.MouseButton1Down:Connect(function() tw(b, 0.06, {BackgroundColor3 = Color3.fromRGB(34, 34, 34)}) end)
	return b, lbl, s, bar
end

local GKBtn,   GKLbl,   GKStroke,   GKBar   = makeCopyBtn(0, 0, AMBER)
local DiscBtn, DLbl,    DiscStroke, DiscBar = makeCopyBtn(1, 1, BLURPLE)

local function wireCopy(btn, lbl, strokeObj, bar, accent, link, idleKey, urlKey)
	local locked = false
	btn.MouseButton1Click:Connect(function()
		if locked then return end
		locked = true
		local ok = pcall(function() setclipboard(link) end)
		lbl.Text = ok and T("copied") or T(urlKey)
		if ok then
			tw(bar, 0.15, {BackgroundColor3 = GREEN})
			tw(strokeObj, 0.15, {Color = GREEN})
			tw(btn, 0.15, {BackgroundColor3 = Color3.fromRGB(14, 28, 20)})
		end
		task.wait(2)
		lbl.Text = T(idleKey)
		tw(bar, 0.25, {BackgroundColor3 = accent})
		tw(strokeObj, 0.25, {Color = Color3.fromRGB(45, 45, 45)})
		tw(btn, 0.25, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)})
		locked = false
	end)
end
wireCopy(GKBtn,   GKLbl, GKStroke,   GKBar,   AMBER,   KEYPAGE,   "getkey",  "copy_url")
wireCopy(DiscBtn, DLbl,  DiscStroke, DiscBar, BLURPLE, DISC_LINK, "discord", "disc_url")

-- ════════ ปุ่มปิด ════════
CloseBtn.MouseEnter:Connect(function()
	tw(CloseStroke, 0.15, {Color = Color3.fromRGB(255, 90, 90)})
	for _, b in ipairs(xBars) do tw(b, 0.15, {BackgroundColor3 = Color3.fromRGB(255, 90, 90)}) end
end)
CloseBtn.MouseLeave:Connect(function()
	tw(CloseStroke, 0.15, {Color = Color3.fromRGB(50, 50, 50)})
	for _, b in ipairs(xBars) do tw(b, 0.15, {BackgroundColor3 = Color3.fromRGB(150, 150, 150)}) end
end)
CloseBtn.MouseButton1Click:Connect(function()
	introDone = false
	tw(Scale, 0.35, {Scale = baseScale * 0.88}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	TweenService:Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 0.38, 0), BackgroundTransparency = 1}):Play()
	tw(Backdrop, 0.35, {BackgroundTransparency = 1})
	task.wait(0.5); ScreenGui:Destroy()
end)

-- ════════ LANG ════════
local function applyLang()
	KTitle.Text = T("key_title"); KSub.Text = T("key_sub")
	KeyInput.PlaceholderText = T("placeholder")
	ConfirmBtn.Text = T("confirm")
	GKLbl.Text = T("getkey"); DLbl.Text = T("discord")
	LangBtn.Text = (currentLang == "EN") and "TH" or "EN"
end
applyLang()

LangBtn.MouseEnter:Connect(function()
	tw(LangStroke, 0.15, {Color = Color3.fromRGB(180, 180, 180)})
	tw(LangBtn, 0.15, {TextColor3 = WHITE})
end)
LangBtn.MouseLeave:Connect(function()
	tw(LangStroke, 0.15, {Color = Color3.fromRGB(50, 50, 50)})
	tw(LangBtn, 0.15, {TextColor3 = Color3.fromRGB(150, 150, 150)})
end)
LangBtn.MouseButton1Click:Connect(function()
	currentLang = (currentLang == "EN") and "TH" or "EN"
	applyLang()
end)

-- ════════ LIGHTNING ════════
local lightOn = true
local function bolt()
	local b = new("Frame", {
		BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 4,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(math.random(22, 100) / 1000, 0, math.random(1, 2) / 1000, 0),
		Position = UDim2.fromScale(0.5 + (math.random() - 0.5) * 0.34, 0.5 + (math.random() - 0.5) * 0.34),
		Rotation = math.random(0, 360),
	}, LCanvas)
	corner(b, 99)
	TweenService:Create(b, TweenInfo.new(0.26, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
	task.delay(0.31, function() b:Destroy() end)
end
task.spawn(function()
	while lightOn do
		for _ = 1, math.random(1, 3) do bolt(); task.wait(0.03) end
		task.wait(math.random(10, 24) / 10)
	end
end)

-- ════════ SHAKE ════════
local function shake()
	for _, x in ipairs({-8, 8, -5, 5, -2, 2, 0}) do
		TweenService:Create(Card, TweenInfo.new(0.04), {Position = UDim2.new(0.5, x, 0.5, 0)}):Play()
		task.wait(0.04)
	end
	Card.Position = UDim2.fromScale(0.5, 0.5)
end

-- ════════ API ════════
local function check(k)
	local ok, res = pcall(function()
		return game:HttpGet(API .. "/api/key/check?key=" .. HttpService:UrlEncode(k) .. "&hwid=" .. HttpService:UrlEncode(HWID))
	end)
	if not ok then return false, "server" end
	local ok2, d = pcall(function() return HttpService:JSONDecode(res) end)
	if not ok2 or type(d) ~= "table" then return false, "server" end
	if d.ok then return true end
	return false, d.error or "key"
end

-- ════════ CONFIRM ════════
local busy = false
local function confirm()
	if busy then return end
	local k = (KeyInput.Text:gsub("%s+", ""))
	if k == "" then
		Status.TextColor3 = Color3.fromRGB(255, 180, 0)
		Status.Text = T("empty"); shake(); return
	end
	busy = true
	Status.TextColor3 = Color3.fromRGB(170, 170, 170); Status.Text = T("checking")
	local valid, why = check(k)
	if valid then
		ConfirmBtn.Visible = false; Status.Text = ""; playSuccessAnim()
		tw(CardStroke, 0.3, {Color = GREEN})
		for i = 1, 10 do task.delay(i * 0.05, bolt) end
		lightOn = false; task.wait(1.6)
		introDone = false
		tw(Scale, 0.45, {Scale = baseScale * 0.88}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		TweenService:Create(Card, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, 0, 0.38, 0), BackgroundTransparency = 1}):Play()
		tw(Backdrop, 0.4, {BackgroundTransparency = 1})
		task.wait(0.6); ScreenGui:Destroy()
		local okR, errR = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/aten131012-dot/nexora/refs/heads/main/NEXORAHUB.txt"))()
		end)
		if not okR then warn("NEXORA:", errR) end
	else
		local msg = T("wrong")
		if why == "server" then msg = T("server_err") elseif why == "device" then msg = T("device_err") end
		Status.TextColor3 = Color3.fromRGB(255, 70, 70); Status.Text = msg
		tw(CardStroke, 0.15, {Color = Color3.fromRGB(255, 70, 70)})
		shake()
		for i = 1, 5 do task.delay(i * 0.05, bolt) end
		task.wait(0.8)
		tw(CardStroke, 0.4, {Color = WHITE})
		busy = false
	end
end

ConfirmBtn.MouseButton1Click:Connect(confirm)
KeyInput.FocusLost:Connect(function(enter) if enter then confirm() end end)

-- ════════ ENTRANCE ════════
tw(Backdrop, 0.28, {BackgroundTransparency = 0.22})
task.wait(0.04)
tw(Scale, 0.5, {Scale = baseScale}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
TweenService:Create(Card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 0.06,
}):Play()
task.delay(0.55, function() introDone = true; fit() end)
