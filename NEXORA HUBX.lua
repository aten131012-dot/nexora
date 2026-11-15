-- NEXORA HUB Key System v5
-- StarterGui > LocalScript

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local LOGO_ID = "rbxassetid://86383017875768"
local API     = "https://nexora-key.aten131012.workers.dev"
local KEYPAGE = "https://nexorascript.netlify.app/#key"

local LANG = {
	EN = {
		placeholder  = "Enter key...",
		confirm      = "CONFIRM",
		getkey       = "★  GET KEY",
		footer       = "© NEXORA HUB",
		checking     = "…  Checking key.",
		granted      = "✓  Access granted.",
		wrong        = "✗  Wrong key.",
		server_err   = "✗  Server error. Try again.",
		device_err   = "✗  Key used on another device.",
		empty        = "⚠  Enter your key first.",
		copied       = "✓  Link copied!",
		copy_url     = "nexorascript.netlify.app/#key",
	},
	TH = {
		placeholder  = "ใส่คีย์...",
		confirm      = "ยืนยัน",
		getkey       = "★  รับคีย์",
		footer       = "© NEXORA HUB",
		checking     = "…  กำลังตรวจสอบ.",
		granted      = "✓  เข้าใช้งานได้แล้ว",
		wrong        = "✗  คีย์ไม่ถูกต้อง",
		server_err   = "✗  เซิร์ฟเวอร์ผิดพลาด ลองใหม่",
		device_err   = "✗  คีย์ถูกใช้บนอุปกรณ์อื่น",
		empty        = "⚠  กรุณาใส่คีย์ก่อน",
		copied       = "✓  คัดลอกลิงก์แล้ว!",
		copy_url     = "nexorascript.netlify.app/#key",
	},
}
local currentLang = "EN"
local function T(k) return LANG[currentLang][k] end

local HWID
do
	local ok, id = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
	HWID = (ok and id and id ~= "") and id or tostring(player.UserId)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexoraKey"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = playerGui

local Backdrop = Instance.new("Frame")
Backdrop.Size = UDim2.fromScale(1, 1)
Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Backdrop.BackgroundTransparency = 1
Backdrop.BorderSizePixel = 0
Backdrop.ZIndex = 1
Backdrop.Parent = ScreenGui

local BgLogo = Instance.new("ImageLabel")
BgLogo.Size = UDim2.new(0, 280, 0, 280)
BgLogo.AnchorPoint = Vector2.new(0.5, 0.5)
BgLogo.Position = UDim2.fromScale(0.5, 0.5)
BgLogo.BackgroundTransparency = 1
BgLogo.Image = LOGO_ID
BgLogo.ImageTransparency = 0.82
BgLogo.ScaleType = Enum.ScaleType.Fit
BgLogo.ZIndex = 2
BgLogo.Parent = ScreenGui

task.spawn(function()
	while true do
		TweenService:Create(BgLogo, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { ImageTransparency = 0.74 }):Play()
		task.wait(2.5)
		TweenService:Create(BgLogo, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { ImageTransparency = 0.88 }):Play()
		task.wait(2.5)
	end
end)

local LCanvas = Instance.new("Frame")
LCanvas.Size = UDim2.fromScale(1, 1)
LCanvas.BackgroundTransparency = 1
LCanvas.BorderSizePixel = 0
LCanvas.ZIndex = 3
LCanvas.Parent = ScreenGui

local Card = Instance.new("Frame")
Card.Name = "Card"
Card.Size = UDim2.new(0, 310, 0, 380)
Card.AnchorPoint = Vector2.new(0.5, 0.5)
Card.Position = UDim2.fromScale(0.5, 0.5)
Card.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Card.BackgroundTransparency = 0.08
Card.BorderSizePixel = 0
Card.ZIndex = 10
Card.Parent = ScreenGui

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 24)
CardCorner.Parent = Card

local CardStroke = Instance.new("UIStroke")
CardStroke.Color = Color3.fromRGB(255, 255, 255)
CardStroke.Thickness = 1
CardStroke.Transparency = 0.65
CardStroke.Parent = Card

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.AnchorPoint = Vector2.new(1, 0)
CloseBtn.Position = UDim2.new(1, 24, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseBtn.BackgroundTransparency = 1
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.ZIndex = 15
CloseBtn.Parent = Card

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseBtn

task.delay(0.65, function()
	TweenService:Create(CloseBtn, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -10, 0, 10),
		BackgroundTransparency = 0,
	}):Play()
end)

CloseBtn.MouseEnter:Connect(function()
	TweenService:Create(CloseBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(55,55,55), TextColor3 = Color3.fromRGB(255,255,255) }):Play()
	TweenService:Create(CloseBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Rotation = 90 }):Play()
end)
CloseBtn.MouseLeave:Connect(function()
	TweenService:Create(CloseBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(30,30,30), TextColor3 = Color3.fromRGB(160,160,160) }):Play()
	TweenService:Create(CloseBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Rotation = 0 }):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
	TweenService:Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5,0,0.35,0), BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(Backdrop, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
	task.wait(0.5)
	ScreenGui:Destroy()
end)

local LangBtn = Instance.new("TextButton")
LangBtn.Size = UDim2.new(0, 44, 0, 24)
LangBtn.AnchorPoint = Vector2.new(1, 0)
LangBtn.Position = UDim2.new(1, -44, 0, 14)
LangBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
LangBtn.BorderSizePixel = 0
LangBtn.Text = "TH"
LangBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
LangBtn.Font = Enum.Font.GothamBold
LangBtn.TextSize = 11
LangBtn.ZIndex = 15
LangBtn.Parent = Card

local LangCorner = Instance.new("UICorner")
LangCorner.CornerRadius = UDim.new(0, 8)
LangCorner.Parent = LangBtn

local LangStroke = Instance.new("UIStroke")
LangStroke.Color = Color3.fromRGB(55, 55, 55)
LangStroke.Thickness = 1
LangStroke.Parent = LangBtn

local KeyInput, Status, ConfirmBtn, GetKeyBtn, Footer

local function applyLang()
	if KeyInput   then KeyInput.PlaceholderText = T("placeholder") end
	if ConfirmBtn then ConfirmBtn.Text = T("confirm") end
	if GetKeyBtn  then GetKeyBtn.Text  = T("getkey")  end
	if Footer     then Footer.Text     = T("footer")  end
	LangBtn.Text = (currentLang == "EN") and "TH" or "EN"
end

LangBtn.MouseEnter:Connect(function()
	TweenService:Create(LangStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(180,180,180) }):Play()
	TweenService:Create(LangBtn, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(255,255,255) }):Play()
end)
LangBtn.MouseLeave:Connect(function()
	TweenService:Create(LangStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(55,55,55) }):Play()
	TweenService:Create(LangBtn, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(160,160,160) }):Play()
end)
LangBtn.MouseButton1Click:Connect(function()
	currentLang = (currentLang == "EN") and "TH" or "EN"
	TweenService:Create(LangBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(60,60,60) }):Play()
	task.wait(0.12)
	TweenService:Create(LangBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(28,28,28) }):Play()
	applyLang()
end)

-- PART 2

local Ring = Instance.new("ImageLabel")
Ring.Size = UDim2.new(0, 86, 0, 86)
Ring.AnchorPoint = Vector2.new(0.5, 0)
Ring.Position = UDim2.new(0.5, 0, 0, 20)
Ring.BackgroundTransparency = 1
Ring.Image = "rbxassetid://6401145959"
Ring.ImageColor3 = Color3.fromRGB(255, 255, 255)
Ring.ImageTransparency = 0.75
Ring.ZIndex = 10
Ring.Parent = Card

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 72, 0, 72)
Logo.AnchorPoint = Vector2.new(0.5, 0)
Logo.Position = UDim2.new(0.5, 0, 0, 27)
Logo.BackgroundTransparency = 1
Logo.Image = LOGO_ID
Logo.ScaleType = Enum.ScaleType.Fit
Logo.ZIndex = 11
Logo.Parent = Card

task.spawn(function()
	local r = 0
	while true do
		r = (r + 1) % 360
		Ring.Rotation = r
		task.wait(0.016)
	end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 26)
Title.AnchorPoint = Vector2.new(0.5, 0)
Title.Position = UDim2.new(0.5, 0, 0, 108)
Title.BackgroundTransparency = 1
Title.Text = "NEXORA HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.ZIndex = 11
Title.Parent = Card

local Rule = Instance.new("Frame")
Rule.Size = UDim2.new(0, 180, 0, 1)
Rule.AnchorPoint = Vector2.new(0.5, 0)
Rule.Position = UDim2.new(0.5, 0, 0, 142)
Rule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Rule.BackgroundTransparency = 0.75
Rule.BorderSizePixel = 0
Rule.ZIndex = 11
Rule.Parent = Card

local InputWrap = Instance.new("Frame")
InputWrap.Size = UDim2.new(0, 266, 0, 44)
InputWrap.AnchorPoint = Vector2.new(0.5, 0)
InputWrap.Position = UDim2.new(0.5, 0, 0, 158)
InputWrap.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
InputWrap.BorderSizePixel = 0
InputWrap.ZIndex = 11
InputWrap.Parent = Card

local IWCorner = Instance.new("UICorner")
IWCorner.CornerRadius = UDim.new(0, 12)
IWCorner.Parent = InputWrap

local IWStroke = Instance.new("UIStroke")
IWStroke.Color = Color3.fromRGB(55, 55, 55)
IWStroke.Thickness = 1
IWStroke.Parent = InputWrap

KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -16, 1, 0)
KeyInput.Position = UDim2.new(0, 12, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = ""
KeyInput.PlaceholderText = T("placeholder")
KeyInput.PlaceholderColor3 = Color3.fromRGB(65, 65, 65)
KeyInput.TextColor3 = Color3.fromRGB(210, 210, 210)
KeyInput.Font = Enum.Font.Code
KeyInput.TextSize = 13
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.ClearTextOnFocus = false
KeyInput.ZIndex = 12
KeyInput.Parent = InputWrap

KeyInput.Focused:Connect(function()
	TweenService:Create(IWStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(200,200,200), Thickness = 1.5 }):Play()
end)
KeyInput.FocusLost:Connect(function()
	TweenService:Create(IWStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(55,55,55), Thickness = 1 }):Play()
end)

Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 16)
Status.AnchorPoint = Vector2.new(0.5, 0)
Status.Position = UDim2.new(0.5, 0, 0, 208)
Status.BackgroundTransparency = 1
Status.Text = ""
Status.TextColor3 = Color3.fromRGB(255, 80, 80)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Center
Status.ZIndex = 11
Status.Parent = Card

ConfirmBtn = Instance.new("TextButton")
ConfirmBtn.Size = UDim2.new(0, 266, 0, 44)
ConfirmBtn.AnchorPoint = Vector2.new(0.5, 0)
ConfirmBtn.Position = UDim2.new(0.5, 0, 0, 232)
ConfirmBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
ConfirmBtn.BorderSizePixel = 0
ConfirmBtn.Text = T("confirm")
ConfirmBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ConfirmBtn.Font = Enum.Font.GothamBold
ConfirmBtn.TextSize = 14
ConfirmBtn.ZIndex = 11
ConfirmBtn.Parent = Card

local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(0, 12)
CBCorner.Parent = ConfirmBtn

ConfirmBtn.MouseEnter:Connect(function()
	TweenService:Create(ConfirmBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(255,255,255) }):Play()
end)
ConfirmBtn.MouseLeave:Connect(function()
	TweenService:Create(ConfirmBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(240,240,240) }):Play()
end)

local SuccessOverlay = Instance.new("Frame")
SuccessOverlay.Size = UDim2.new(0, 266, 0, 44)
SuccessOverlay.AnchorPoint = Vector2.new(0.5, 0)
SuccessOverlay.Position = UDim2.new(0.5, 0, 0, 232)
SuccessOverlay.BackgroundColor3 = Color3.fromRGB(100, 255, 160)
SuccessOverlay.BackgroundTransparency = 1
SuccessOverlay.BorderSizePixel = 0
SuccessOverlay.ZIndex = 13
SuccessOverlay.Visible = false
SuccessOverlay.Parent = Card

local SOCorner = Instance.new("UICorner")
SOCorner.CornerRadius = UDim.new(0, 12)
SOCorner.Parent = SuccessOverlay

local CheckCircle = Instance.new("Frame")
CheckCircle.Size = UDim2.new(0, 28, 0, 28)
CheckCircle.AnchorPoint = Vector2.new(0, 0.5)
CheckCircle.Position = UDim2.new(0, 10, 0.5, 0)
CheckCircle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CheckCircle.BackgroundTransparency = 0.65
CheckCircle.BorderSizePixel = 0
CheckCircle.ZIndex = 14
CheckCircle.Parent = SuccessOverlay

local CCCorner = Instance.new("UICorner")
CCCorner.CornerRadius = UDim.new(1, 0)
CCCorner.Parent = CheckCircle

local CheckMark = Instance.new("TextLabel")
CheckMark.Size = UDim2.fromScale(1, 1)
CheckMark.BackgroundTransparency = 1
CheckMark.Text = "✓"
CheckMark.TextColor3 = Color3.fromRGB(100, 255, 160)
CheckMark.Font = Enum.Font.GothamBold
CheckMark.TextSize = 16
CheckMark.TextXAlignment = Enum.TextXAlignment.Center
CheckMark.ZIndex = 15
CheckMark.Parent = CheckCircle

local SuccessLabel = Instance.new("TextLabel")
SuccessLabel.Size = UDim2.new(1, -58, 1, 0)
SuccessLabel.Position = UDim2.new(0, 48, 0, 0)
SuccessLabel.BackgroundTransparency = 1
SuccessLabel.Text = ""
SuccessLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
SuccessLabel.Font = Enum.Font.GothamBold
SuccessLabel.TextSize = 13
SuccessLabel.TextXAlignment = Enum.TextXAlignment.Left
SuccessLabel.ZIndex = 14
SuccessLabel.Parent = SuccessOverlay

local function playSuccessAnim()
	SuccessLabel.Text = T("granted")
	SuccessOverlay.Visible = true
	SuccessOverlay.BackgroundTransparency = 1
	CheckCircle.BackgroundTransparency = 1
	CheckMark.TextTransparency = 1
	SuccessLabel.TextTransparency = 1

	TweenService:Create(SuccessOverlay, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
	task.wait(0.1)
	CheckCircle.Size = UDim2.new(0, 10, 0, 10)
	TweenService:Create(CheckCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 28, 0, 28),
		BackgroundTransparency = 0.65,
	}):Play()
	TweenService:Create(CheckMark, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
	TweenService:Create(SuccessLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
end

GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0, 266, 0, 36)
GetKeyBtn.AnchorPoint = Vector2.new(0.5, 0)
GetKeyBtn.Position = UDim2.new(0.5, 0, 0, 286)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
GetKeyBtn.BorderSizePixel = 0
GetKeyBtn.Text = T("getkey")
GetKeyBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
GetKeyBtn.Font = Enum.Font.Gotham
GetKeyBtn.TextSize = 12
GetKeyBtn.ZIndex = 11
GetKeyBtn.Parent = Card

local GKCorner = Instance.new("UICorner")
GKCorner.CornerRadius = UDim.new(0, 12)
GKCorner.Parent = GetKeyBtn

local GKStroke = Instance.new("UIStroke")
GKStroke.Color = Color3.fromRGB(55, 55, 55)
GKStroke.Thickness = 1
GKStroke.Parent = GetKeyBtn

local function burstStars()
	for i = 1, 8 do
		local star = Instance.new("TextLabel")
		star.Size = UDim2.new(0, 14, 0, 14)
		star.BackgroundTransparency = 1
		star.Text = "★"
		star.TextColor3 = Color3.fromRGB(255, 215, 0)
		star.Font = Enum.Font.GothamBold
		star.TextSize = 12
		star.ZIndex = 20
		star.AnchorPoint = Vector2.new(0.5, 0.5)
		star.Position = UDim2.new(0.5, 0, 0, 304)
		star.Parent = Card
		local angle = (i / 8) * math.pi * 2
		local dist = 38 + math.random(0, 20)
		local tx = math.cos(angle) * dist
		local ty = math.sin(angle) * dist
		TweenService:Create(star, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, tx, 0, 304 + ty),
			TextTransparency = 1,
		}):Play()
		task.delay(0.55, function() star:Destroy() end)
	end
end

task.spawn(function()
	while GetKeyBtn and GetKeyBtn.Parent do
		TweenService:Create(GetKeyBtn, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextColor3 = Color3.fromRGB(255,210,60) }):Play()
		task.wait(1.2)
		TweenService:Create(GetKeyBtn, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextColor3 = Color3.fromRGB(140,100,0) }):Play()
		task.wait(1.2)
	end
end)

GetKeyBtn.MouseEnter:Connect(function()
	TweenService:Create(GKStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(255,215,0) }):Play()
	TweenService:Create(GetKeyBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(18,14,0), TextColor3 = Color3.fromRGB(255,230,80) }):Play()
end)
GetKeyBtn.MouseLeave:Connect(function()
	TweenService:Create(GKStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(55,55,55) }):Play()
	TweenService:Create(GetKeyBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(0,0,0) }):Play()
end)
GetKeyBtn.MouseButton1Click:Connect(function()
	burstStars()
	local ok = pcall(function() setclipboard(KEYPAGE) end)
	if ok then
		GetKeyBtn.Text = "✓  " .. T("copied")
		TweenService:Create(GKStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(100,255,160) }):Play()
	else
		GetKeyBtn.Text = T("copy_url")
		TweenService:Create(GetKeyBtn, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(255,220,80) }):Play()
	end
	task.wait(2.5)
	TweenService:Create(GKStroke, TweenInfo.new(0.3), { Color = Color3.fromRGB(55,55,55) }):Play()
	GetKeyBtn.Text = T("getkey")
end)

Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -20, 0, 14)
Footer.AnchorPoint = Vector2.new(0.5, 0)
Footer.Position = UDim2.new(0.5, 0, 0, 356)
Footer.BackgroundTransparency = 1
Footer.Text = T("footer")
Footer.TextColor3 = Color3.fromRGB(38, 38, 38)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 10
Footer.TextXAlignment = Enum.TextXAlignment.Center
Footer.ZIndex = 11
Footer.Parent = Card

-- PART 3

local lightOn = true
local function bolt()
	local b = Instance.new("Frame")
	b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	b.BorderSizePixel = 0
	b.ZIndex = 4
	b.AnchorPoint = Vector2.new(0.5, 0.5)
	b.Size = UDim2.new(math.random(30,110)/1000, 0, math.random(1,2)/1000, 0)
	b.Position = UDim2.fromScale(0.5+(math.random()-0.5)*0.32, 0.5+(math.random()-0.5)*0.32)
	b.Rotation = math.random(0, 360)
	b.Parent = LCanvas
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1,0)
	c.Parent = b
	TweenService:Create(b, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
	task.delay(0.35, function() b:Destroy() end)
end

task.spawn(function()
	while lightOn do
		for _ = 1, math.random(1,3) do bolt() task.wait(0.03) end
		task.wait(math.random(10,22)/10)
	end
end)

local function shake()
	for _, x in ipairs({-9,9,-6,6,-3,3,0}) do
		TweenService:Create(Card, TweenInfo.new(0.04), { Position = UDim2.new(0.5,x,0.5,0) }):Play()
		task.wait(0.04)
	end
end

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

local busy = false
local function confirm()
	if busy then return end
	local k = (KeyInput.Text:gsub("%s+", ""))
	if k == "" then
		Status.TextColor3 = Color3.fromRGB(255,180,0)
		Status.Text = T("empty")
		shake() return
	end

	busy = true
	Status.TextColor3 = Color3.fromRGB(200,200,200)
	Status.Text = T("checking")
	local valid, why = check(k)

	if valid then
		ConfirmBtn.Visible = false
		Status.Text = ""
		playSuccessAnim()
		TweenService:Create(CardStroke, TweenInfo.new(0.3), { Color = Color3.fromRGB(100,255,160), Transparency = 0 }):Play()
		for i = 1,10 do task.delay(i*0.05, bolt) end
		lightOn = false
		task.wait(1.6)
		TweenService:Create(Card, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5,0,0.35,0), BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(Backdrop, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
		task.wait(0.6)
		ScreenGui:Destroy()
		local okRun, errRun = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/aten131012-dot/OBFNEXORA/refs/heads/main/NEXORA"))()
		end)
		if not okRun then warn("NEXORA:", errRun) end
	else
		local msg = T("wrong")
		if why == "server" then msg = T("server_err")
		elseif why == "device" then msg = T("device_err") end
		Status.TextColor3 = Color3.fromRGB(255,70,70)
		Status.Text = msg
		TweenService:Create(CardStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(255,70,70), Transparency = 0 }):Play()
		shake()
		for i = 1,5 do task.delay(i*0.05, bolt) end
		task.wait(0.8)
		TweenService:Create(CardStroke, TweenInfo.new(0.4), { Color = Color3.fromRGB(255,255,255), Transparency = 0.65 }):Play()
		busy = false
	end
end

ConfirmBtn.MouseButton1Click:Connect(confirm)
KeyInput.FocusLost:Connect(function(e) if e then confirm() end end)

Backdrop.BackgroundTransparency = 1
Card.Position = UDim2.new(0.5, 0, 0.65, 0)
Card.BackgroundTransparency = 1

TweenService:Create(Backdrop, TweenInfo.new(0.4), { BackgroundTransparency = 0.25 }):Play()
task.wait(0.1)
TweenService:Create(Card, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 0.08,
}):Play()
