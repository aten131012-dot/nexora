--[[
 NEXORA HUB — PATCH รวม 4 หมวด (FULL)
 เกม: การแข่งขันตอบคำถามภาษาไทย (PlaceId: 121878558222387)

 วิธีใช้:
   ในไฟล์ GUI.lua เดิม หาบล็อก:
     section("MAIN","หลัก")
     addPage("home",...)
     section("SYSTEM","ระบบ")
     addPage("settings",...)
     selectPage("home")
   แล้วแทนที่ทั้งบล็อกนั้นด้วยเนื้อหาในไฟล์นี้
]]

-- ===== PART 1: เมนู =====
section("MAIN","หลัก")
addPage("home","⌂","HOME","HOME")
section("CHEAT","โกง")
addPage("auto","⚡","AUTO","AUTO")
addPage("buy","♢","BUY","BUY")
addPage("event","✦","EVENT","EVENT")
addPage("rank","♛","RANK","RANK")
section("SYSTEM","ระบบ")
addPage("settings","☼","SETTINGS","SETTINGS")
selectPage("home")

-- ===== PART 2: หน้า AUTO =====
do
local NX=getgenv().NX
local COL,make,round,glow,L=NX.COL,NX.make,NX.round,NX.glow,NX.L
local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.3,Enum.EasingStyle.Quint)
local c=NX.pages.auto
local function T(en,th) return (NX.getLang()=="TH") and th or en end

local scroll=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
 ScrollBarThickness=3,ScrollBarImageColor3=COL.Purple,BorderSizePixel=0,
 CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},c)
make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
make("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)},scroll)

local lo=0
local function hdr(en,th)
 lo+=1
 local f=make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},scroll)
 local lb=make("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
  Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Sub,
  TextXAlignment=Enum.TextXAlignment.Left},f)
 L(lb,en,th)
end

local function chip(en,th,desc_en,desc_th,onToggle)
 lo+=1
 local row=make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,52),BackgroundColor3=COL.Side,BackgroundTransparency=.5},scroll)
 round(row,12)
 local sw=make("TextButton",{Text="",AutoButtonColor=false,
  Size=UDim2.fromOffset(44,24),Position=UDim2.new(1,-50,0,14),
  BackgroundColor3=COL.Chip},row)
 round(sw,12)
 local sk=make("Frame",{Size=UDim2.fromOffset(18,18),Position=UDim2.fromOffset(3,3),
  BackgroundColor3=Color3.new(1,1,1)},sw)
 round(sk,9)
 local on=false
 local lbMain=make("TextLabel",{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-70,0,16),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,
  TextColor3=COL.Text,TextXAlignment=Enum.TextXAlignment.Left},row)
 L(lbMain,en,th)
 local lbSub=make("TextLabel",{Position=UDim2.fromOffset(12,26),Size=UDim2.new(1,-70,0,12),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,
  TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left},row)
 L(lbSub,desc_en,desc_th)
 NX.onAccent(function(a) if on then sw.BackgroundColor3=a end end)
 sw.MouseButton1Click:Connect(function()
  on=not on
  TS:Create(sw,TI,{BackgroundColor3=on and COL.Purple or COL.Chip}):Play()
  TS:Create(sk,TI,{Position=on and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)}):Play()
  if onToggle then onToggle(on) end
 end)
 return function() return on end
end

local Remotes=game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
local MatchInput=Remotes and Remotes:FindFirstChild("MatchInput")
local Match=Remotes and Remotes:FindFirstChild("Match")
local Solo=Remotes and Remotes:FindFirstChild("Solo")

-- AUTO SIT
hdr("⚡ AUTO SIT","⚡ ออโต้นั่ง")
local autoSitConn
chip("Auto Join Queue","ออโต้เข้าคิว",
 "Auto-presses Play button every 3s","กดเล่นอัตโนมัติทุก 3 วินาที",
 function(v)
  if autoSitConn then autoSitConn:Disconnect() autoSitConn=nil end
  if not v then return end
  autoSitConn=RS.Heartbeat:Connect(function()
   pcall(function()
    for _,pp in ipairs(workspace:GetDescendants()) do
     if pp:IsA("ProximityPrompt") and pp:GetAttribute("QuickJoin") then
      fireproximityprompt(pp)
     end
    end
   end)
   pcall(function()
    if Solo then Solo:FireServer("join") end
   end)
   task.wait(3)
  end)
 end)

-- AUTO ANSWER
hdr("⚡ AUTO ANSWER","⚡ ออโต้ตอบ")
local autoAnsConn
local ansDelay=0.3

chip("Auto Answer (Random)","ออโต้ตอบ (สุ่ม)",
 "Randomly clicks answer tiles","สุ่มกดคำตอบในแมทช์",
 function(v)
  if autoAnsConn then autoAnsConn:Disconnect() autoAnsConn=nil end
  if not v then return end
  autoAnsConn=RS.Heartbeat:Connect(function()
   pcall(function()
    local pg=lp.PlayerGui
    local kh=pg:FindFirstChild("KHRush") or pg:FindFirstChild("KHGame")
    if not kh then return end
    local tiles={}
    for _,v in ipairs(kh:GetDescendants()) do
     if v:IsA("TextButton") and v.Name=="Tile" and v.Visible then
      tiles[#tiles+1]=v
     end
    end
    if #tiles>0 then
     local pick=tiles[math.random(1,#tiles)]
     task.delay(ansDelay,function()
      pcall(function() pick:GetPropertyChangedSignal("Active") end)
      pcall(function()
       if MatchInput then
        for i,t in ipairs(tiles) do
         if t==pick then MatchInput:FireServer(i-1) break end
        end
       end
      end)
     end)
    end
   end)
   task.wait(1.5)
  end)
 end)

chip("Auto Answer (First)","ออโต้ตอบ (ตัวแรก)",
 "Always picks the first tile","กดคำตอบตัวแรกเสมอ",
 function(v)
  if v then
   task.spawn(function()
    while v do
     pcall(function()
      if MatchInput then MatchInput:FireServer(0) end
     end)
     task.wait(1.2)
    end
   end)
  end
 end)

-- AUTO PLAY
hdr("⚡ AUTO PLAY","⚡ ออโต้เล่น")
local autoPlayConn
chip("Auto Solo Play","ออโต้เล่นเดี่ยว",
 "Auto-enters and plays solo matches","เข้าและเล่นโหมดเดี่ยวอัตโนมัติ",
 function(v)
  if autoPlayConn then autoPlayConn:Disconnect() autoPlayConn=nil end
  if not v then return end
  task.spawn(function()
   while v do
    pcall(function()
     if Solo then Solo:FireServer("start") end
    end)
    task.wait(5)
   end
  end)
 end)

chip("Auto Match Play","ออโต้เล่นแมทช์",
 "Auto-joins and answers multiplayer matches","เข้าและตอบโหมดหลายคนอัตโนมัติ",
 function(v)
  if not v then return end
  task.spawn(function()
   while v do
    pcall(function()
     if Match then Match:FireServer("ready") end
    end)
    task.wait(4)
   end
  end)
 end)

end -- end AUTO page

-- ===== PART 3: หน้า BUY =====
do
local NX=getgenv().NX
local COL,make,round,glow,L=NX.COL,NX.make,NX.round,NX.glow,NX.L
local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.3,Enum.EasingStyle.Quint)
local c=NX.pages.buy
local function T(en,th) return (NX.getLang()=="TH") and th or en end

local scroll=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
 ScrollBarThickness=3,ScrollBarImageColor3=COL.Purple,BorderSizePixel=0,
 CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},c)
make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
make("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)},scroll)

local lo=0
local function hdr(en,th)
 lo+=1
 local f=make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},scroll)
 L(make("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
  Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Sub,
  TextXAlignment=Enum.TextXAlignment.Left},f),en,th)
end

local function chip(en,th,desc_en,desc_th,onToggle)
 lo+=1
 local row=make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,52),BackgroundColor3=COL.Side,BackgroundTransparency=.5},scroll)
 round(row,12)
 local sw=make("TextButton",{Text="",AutoButtonColor=false,
  Size=UDim2.fromOffset(44,24),Position=UDim2.new(1,-50,0,14),
  BackgroundColor3=COL.Chip},row)
 round(sw,12)
 local sk=make("Frame",{Size=UDim2.fromOffset(18,18),Position=UDim2.fromOffset(3,3),
  BackgroundColor3=Color3.new(1,1,1)},sw)
 round(sk,9)
 local on=false
 L(make("TextLabel",{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-70,0,16),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,
  TextColor3=COL.Text,TextXAlignment=Enum.TextXAlignment.Left},row),en,th)
 L(make("TextLabel",{Position=UDim2.fromOffset(12,26),Size=UDim2.new(1,-70,0,12),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,
  TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left},row),desc_en,desc_th)
 NX.onAccent(function(a) if on then sw.BackgroundColor3=a end end)
 sw.MouseButton1Click:Connect(function()
  on=not on
  TS:Create(sw,TI,{BackgroundColor3=on and COL.Purple or COL.Chip}):Play()
  TS:Create(sk,TI,{Position=on and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)}):Play()
  if onToggle then onToggle(on) end
 end)
end

local function btn(en,th,fn)
 lo+=1
 local row=make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,38),BackgroundTransparency=1},scroll)
 local b=make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundColor3=COL.Side,
  AutoButtonColor=false,Text="",BorderSizePixel=0},row)
 round(b,10)
 NX.onAccent(function(a,c2)
  make("UIGradient",{Color=ColorSequence.new(a,c2)},b)
 end)
 L(make("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
  Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.new(1,1,1)},b),en,th)
 b.MouseButton1Click:Connect(function() pcall(fn) end)
end

local Remotes=game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
local Purchase=Remotes and Remotes:FindFirstChild("Purchase")
local Request=Remotes and Remotes:FindFirstChild("Request")

hdr("♢ AUTO BUY","♢ ออโต้ซื้อ")

chip("Auto Buy Cheapest","ออโต้ซื้อถูกสุด",
 "Buy the cheapest shop item in loop","ซื้อของถูกสุดในร้านซ้ำๆ",
 function(v)
  if not v then return end
  task.spawn(function()
   while v do
    pcall(function()
     if Purchase then Purchase:FireServer("buy",1) end
    end)
    task.wait(2)
   end
  end)
 end)

chip("Auto Buy Chair Decor","ออโต้ซื้อตกแต่งเก้าอี้",
 "Loop-buy chair decoration items","ซื้อของตกแต่งเก้าอี้ซ้ำๆ",
 function(v)
  if not v then return end
  task.spawn(function()
   local items={"Bow","Crown","Star","Halo","Heart","Gem","Moon","Lotus","Flame","Mango"}
   local i=1
   while v do
    pcall(function()
     if Purchase then Purchase:FireServer("chairDecor",items[i]) end
    end)
    i=i%#items+1
    task.wait(2.5)
   end
  end)
 end)

hdr("♢ REQUEST","♢ รีเควสต์")

btn("Request StarterPack","รีเควสต์สตาร์ทเตอร์แพ็ค",function()
 if Request then Request:InvokeServer("starterPack") end
end)
btn("Request DoubleCoins","รีเควสต์เหรียญสองเท่า",function()
 if Request then Request:InvokeServer("doubleCoins") end
end)
btn("Request Profile Data","รีเควสต์ข้อมูลโปรไฟล์",function()
 if Request then
  local data=Request:InvokeServer("profile")
  if data then
   local Remotes2=game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
   local Toast=Remotes2 and Remotes2:FindFirstChild("Toast")
   if Toast then Toast:FireServer("Profile: "..tostring(data)) end
  end
 end
end)

end -- end BUY page

-- ===== PART 3 (ต่อ): หน้า EVENT =====
do
local NX=getgenv().NX
local COL,make,round,glow,L=NX.COL,NX.make,NX.round,NX.glow,NX.L
local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.3,Enum.EasingStyle.Quint)
local c=NX.pages.event
local function T(en,th) return (NX.getLang()=="TH") and th or en end

local scroll=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
 ScrollBarThickness=3,ScrollBarImageColor3=COL.Purple,BorderSizePixel=0,
 CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},c)
make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
make("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)},scroll)

local lo=0
local function hdr(en,th)
 lo+=1
 local f=make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},scroll)
 L(make("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
  Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Sub,
  TextXAlignment=Enum.TextXAlignment.Left},f),en,th)
end

local function chip(en,th,desc_en,desc_th,onToggle)
 lo+=1
 local row=make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,52),BackgroundColor3=COL.Side,BackgroundTransparency=.5},scroll)
 round(row,12)
 local sw=make("TextButton",{Text="",AutoButtonColor=false,
  Size=UDim2.fromOffset(44,24),Position=UDim2.new(1,-50,0,14),
  BackgroundColor3=COL.Chip},row)
 round(sw,12)
 local sk=make("Frame",{Size=UDim2.fromOffset(18,18),Position=UDim2.fromOffset(3,3),
  BackgroundColor3=Color3.new(1,1,1)},sw)
 round(sk,9)
 local on=false
 L(make("TextLabel",{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-70,0,16),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,
  TextColor3=COL.Text,TextXAlignment=Enum.TextXAlignment.Left},row),en,th)
 L(make("TextLabel",{Position=UDim2.fromOffset(12,26),Size=UDim2.new(1,-70,0,12),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,
  TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left},row),desc_en,desc_th)
 NX.onAccent(function(a) if on then sw.BackgroundColor3=a end end)
 sw.MouseButton1Click:Connect(function()
  on=not on
  TS:Create(sw,TI,{BackgroundColor3=on and COL.Purple or COL.Chip}):Play()
  TS:Create(sk,TI,{Position=on and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)}):Play()
  if onToggle then onToggle(on) end
 end)
end

local Remotes=game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
local Match=Remotes and Remotes:FindFirstChild("Match")
local Solo=Remotes and Remotes:FindFirstChild("Solo")

hdr("✦ AUTO EVENT","✦ ออโต้อีเวนท์")

chip("Auto Streak Event","ออโต้สตรีคอีเวนท์",
 "Keep winning streak for event rewards","รักษาสตรีคเพื่อรับรางวัลอีเวนท์",
 function(v)
  if not v then return end
  task.spawn(function()
   while v do
    pcall(function()
     if Match then Match:FireServer("streakEvent") end
    end)
    task.wait(3)
   end
  end)
 end)

chip("Auto Daily Challenge","ออโต้ชาเลนจ์รายวัน",
 "Auto-complete daily challenge quests","ทำชาเลนจ์รายวันอัตโนมัติ",
 function(v)
  if not v then return end
  task.spawn(function()
   while v do
    pcall(function()
     if Solo then Solo:FireServer("dailyChallenge") end
    end)
    task.wait(4)
   end
  end)
 end)

chip("Auto Gift Collect","ออโต้เก็บของขวัญ",
 "Collect all pending gift rewards","เก็บรางวัลของขวัญที่รอรับทั้งหมด",
 function(v)
  if not v then return end
  task.spawn(function()
   while v do
    pcall(function()
     local Req=Remotes and Remotes:FindFirstChild("Request")
     if Req then Req:InvokeServer("collectGift") end
    end)
    task.wait(5)
   end
  end)
 end)

chip("Auto Prank Event","ออโต้อีเวนท์แกล้ง",
 "Spam prank actions in event","กดแกล้งผู้เล่นในอีเวนท์ซ้ำๆ",
 function(v)
  if not v then return end
  task.spawn(function()
   while v do
    pcall(function()
     local pg=lp.PlayerGui
     for _,sg in ipairs(pg:GetChildren()) do
      local pb=sg:FindFirstChild("PrankButton",true)
      if pb and pb:IsA("TextButton") then pb:GetPropertyChangedSignal("Active") end
     end
     local Req=Remotes and Remotes:FindFirstChild("Request")
     if Req then Req:InvokeServer("prank",Players:GetPlayers()[math.random(1,#Players:GetPlayers())].UserId) end
    end)
    task.wait(2)
   end
  end)
 end)

end -- end EVENT page

-- ===== PART 4: หน้า RANK =====
do
local NX=getgenv().NX
local COL,make,round,glow,L=NX.COL,NX.make,NX.round,NX.glow,NX.L
local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.3,Enum.EasingStyle.Quint)
local c=NX.pages.rank
local function T(en,th) return (NX.getLang()=="TH") and th or en end

local scroll=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
 ScrollBarThickness=3,ScrollBarImageColor3=COL.Purple,BorderSizePixel=0,
 CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},c)
make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
make("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)},scroll)

local lo=0
local function hdr(en,th)
 lo+=1
 local f=make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},scroll)
 L(make("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
  Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Sub,
  TextXAlignment=Enum.TextXAlignment.Left},f),en,th)
end

local function chip(en,th,desc_en,desc_th,onToggle)
 lo+=1
 local row=make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,52),BackgroundColor3=COL.Side,BackgroundTransparency=.5},scroll)
 round(row,12)
 local sw=make("TextButton",{Text="",AutoButtonColor=false,
  Size=UDim2.fromOffset(44,24),Position=UDim2.new(1,-50,0,14),
  BackgroundColor3=COL.Chip},row)
 round(sw,12)
 local sk=make("Frame",{Size=UDim2.fromOffset(18,18),Position=UDim2.fromOffset(3,3),
  BackgroundColor3=Color3.new(1,1,1)},sw)
 round(sk,9)
 local on=false
 L(make("TextLabel",{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-70,0,16),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,
  TextColor3=COL.Text,TextXAlignment=Enum.TextXAlignment.Left},row),en,th)
 L(make("TextLabel",{Position=UDim2.fromOffset(12,26),Size=UDim2.new(1,-70,0,12),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,
  TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left},row),desc_en,desc_th)
 NX.onAccent(function(a) if on then sw.BackgroundColor3=a end end)
 sw.MouseButton1Click:Connect(function()
  on=not on
  TS:Create(sw,TI,{BackgroundColor3=on and COL.Purple or COL.Chip}):Play()
  TS:Create(sk,TI,{Position=on and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)}):Play()
  if onToggle then onToggle(on) end
 end)
end

local Remotes=game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
local Match=Remotes and Remotes:FindFirstChild("Match")
local Solo=Remotes and Remotes:FindFirstChild("Solo")
local Request=Remotes and Remotes:FindFirstChild("Request")

hdr("♛ AUTO RANK","♛ ออโต้แรงค์")

chip("Auto Ranked Match","ออโต้แมทช์แรงค์",
 "Auto-enter ranked mode and answer","เข้าโหมดแรงค์และตอบคำถามอัตโนมัติ",
 function(v)
  if not v then return end
  task.spawn(function()
   while v do
    pcall(function()
     local pg=lp.PlayerGui
     for _,sg in ipairs(pg:GetDescendants()) do
      if sg:IsA("TextButton") and sg.Name=="RankedButton" then
       sg:GetPropertyChangedSignal("Active")
       if Match then Match:FireServer("ranked","join") end
      end
     end
    end)
    task.wait(5)
   end
  end)
 end)

chip("Auto Ranked Answer","ออโต้ตอบแรงค์",
 "Auto-answer questions in ranked mode","ตอบคำถามในโหมดแรงค์อัตโนมัติ",
 function(v)
  if not v then return end
  task.spawn(function()
   while v do
    pcall(function()
     local MatchInput=Remotes and Remotes:FindFirstChild("MatchInput")
     if MatchInput then MatchInput:FireServer(math.random(0,3)) end
    end)
    task.wait(1.8)
   end
  end)
 end)

hdr("♛ RANK FARM","♛ ฟาร์มแรงค์")

chip("Fast Win Farm","ฟาร์มชนะเร็ว",
 "Fire win signals to farm rank points","ยิงสัญญาณชนะเพื่อฟาร์มแรงค์พอยต์",
 function(v)
  if not v then return end
  task.spawn(function()
   while v do
    pcall(function()
     if Match then Match:FireServer("win") end
     if Request then Request:InvokeServer("rankReward") end
    end)
    task.wait(3)
   end
  end)
 end)

chip("Streak Protector","ป้องกันสตรีคหาย",
 "Fire streak-keep signal every loop","ยิงสัญญาณรักษาสตรีคซ้ำๆ",
 function(v)
  if not v then return end
  task.spawn(function()
   while v do
    pcall(function()
     local MatchInput=Remotes and Remotes:FindFirstChild("MatchInput")
     if MatchInput then MatchInput:FireServer(0) end
    end)
    task.wait(2.5)
   end
  end)
 end)

end -- end RANK page

-- ===== PART 4 (ต่อ): CHEAT STATUS PANEL บน HOME =====
do
local NX=getgenv().NX
local COL,make,round,L=NX.COL,NX.make,NX.round,NX.L
local c=NX.pages.home

local scroll=c:FindFirstChildOfClass("ScrollingFrame")
if scroll then
 local lo=1000

 make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,1),
  BackgroundColor3=COL.Purple,BackgroundTransparency=.6},scroll)

 lo+=1
 local statusHdr=make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},scroll)
 L(make("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
  Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Sub,
  TextXAlignment=Enum.TextXAlignment.Left},statusHdr),"CHEAT STATUS","สถานะโกง")

 lo+=1
 local statusRow=make("Frame",{LayoutOrder=lo,Size=UDim2.new(1,0,0,42),
  BackgroundColor3=COL.Side,BackgroundTransparency=.5},scroll)
 round(statusRow,12)
 local statusLbl=make("TextLabel",{Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,1,0),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,
  TextColor3=COL.Sub,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},statusRow)
 statusLbl.Text="⚡ AUTO   ♢ BUY   ✦ EVENT   ♛ RANK\nเปิดหน้าแต่ละแท็บเพื่อเปิดใช้งาน"
end
end
