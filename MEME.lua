--[[
 NEXORA HUB v2  BLACK-WHITE LIGHTNING EDITION (ไฟล์เดียวรวมทุกส่วน)
 แก้ค่าตั้งต้นได้ที่ CFG ด้านล่าง โดยเฉพาะ DISCORD_LINK
]]
local CFG={
 LOGO_ID="91144361769901",
 LOGO_DARK=Color3.fromRGB(255,255,255), -- 255=สีเดิมของรูป (ยิ่งน้อยยิ่งเข้ม)
 DISCORD_ICON_ID="17056354182",
 DISCORD_LINK="https://discord.gg/YOUR_INVITE", -- <<< ใส่ลิงก์ดิสคอสของคุณตรงนี้
 NAME="NEXORA HUB",
 SETTINGS_FILE="NexoraHub_Settings_v2.json",
}

local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local LIN=Enum.EasingStyle.Linear
local SINE=Enum.EasingStyle.Sine
local IO=Enum.EasingDirection.InOut

local COL={
 Bg=Color3.fromRGB(6,6,6),
 Side=Color3.fromRGB(22,22,22),
 Chip=Color3.fromRGB(34,34,34),
 Purple=Color3.fromRGB(110,110,110),
 Pink=Color3.fromRGB(245,245,245),
 Text=Color3.fromRGB(245,245,245),
 Sub=Color3.fromRGB(165,165,165),
 Red=Color3.fromRGB(255,80,110),
 Green=Color3.fromRGB(90,230,160),
}
-- ธีมสี: 1=ขาว(ปกติ) 2=ม่วง 3=ฟ้า 4=แดง
local PRESETS={
 {Color3.fromRGB(110,110,110),Color3.fromRGB(245,245,245)},
 {Color3.fromRGB(140,80,255),Color3.fromRGB(215,125,255)},
 {Color3.fromRGB(50,130,255),Color3.fromRGB(110,220,255)},
 {Color3.fromRGB(235,50,70),Color3.fromRGB(255,130,150)},
}
local function make(c,p,par)
 local o=Instance.new(c)
 for k,v in pairs(p) do o[k]=v end
 o.Parent=par
 return o
end
local function round(o,r) return make("UICorner",{CornerRadius=UDim.new(0,r)},o) end

-- โหลดรูปจากไอดี: แข่งโหลดหลายแหล่งพร้อมกัน ใครเสร็จก่อนใช้อันนั้น (เร็วขึ้นมาก)
local CP=game:GetService("ContentProvider")
local imgCache={}
local function resolveImg(id)
 if imgCache[id] then return imgCache[id] end
 local c={}
 imgCache[id]=c
 for _,u in ipairs({"rbxassetid://"..id,"rbxthumb://type=Asset&id="..id.."&w=420&h=420"}) do
  task.spawn(function()
   local p=Instance.new("ImageLabel")
   p.Image=u
   pcall(function() CP:PreloadAsync({p}) end)
   if not c.url and p.IsLoaded then c.url=u end
   p:Destroy()
  end)
 end
 return c
end
local function setImg(o,id)
 local c=resolveImg(id)
 o.Image=c.url or ("rbxassetid://"..id)
 if c.url then return end
 task.spawn(function()
  local t=0
  while not c.url and t<8 do task.wait(.05) t+=.05 end
  if c.url then o.Image=c.url end
 end)
end
-- เริ่มโหลดรูปทันทีตั้งแต่บรรทัดแรก ก่อนสร้าง GUI
resolveImg(CFG.LOGO_ID)
resolveImg(CFG.DISCORD_ICON_ID)

-- ระบบเปลี่ยนสีธีม
local accents={}
local function onAccent(fn) accents[#accents+1]=fn fn(COL.Purple,COL.Pink) end
local function setAccent(a,b) COL.Purple=a COL.Pink=b for _,fn in ipairs(accents) do fn(a,b) end end
local function glow(o,t)
 local s=make("UIStroke",{Thickness=t or 1.5,Color=Color3.new(1,1,1),ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o)
 local g=make("UIGradient",{},s)
 onAccent(function(a,b) g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(.5,b),ColorSequenceKeypoint.new(1,a)}) end)
 TS:Create(g,TweenInfo.new(4,LIN,Enum.EasingDirection.In,-1),{Rotation=360}):Play()
 return s
end

-- สายฟ้าสีขาว: วาดจากเส้นหักมุม + ชั้นเรืองแสง แล้วค่อยๆ จางหาย
local WHITE=Color3.new(1,1,1)
local function bolt(par,x0,y0,x1,y1,o)
 o=o or {}
 local segs,jit,th=o.segs or 9,o.jit or 26,o.th or 2
 local z=o.z or 6
 local list={}
 local function line(ax,ay,bx,by,t)
  local dx,dy=bx-ax,by-ay
  local len=math.sqrt(dx*dx+dy*dy)
  local ang=math.deg(math.atan2(dy,dx))
  for _,l in ipairs({{t*4,.82},{t,0}}) do
   local f=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset((ax+bx)/2,(ay+by)/2),Size=UDim2.fromOffset(len+l[1]*.5,l[1]),Rotation=ang,BackgroundColor3=WHITE,BackgroundTransparency=l[2],BorderSizePixel=0,ZIndex=z},par)
   list[#list+1]={f,l[2]}
  end
 end
 local px,py=x0,y0
 for i=1,segs do
  local t=i/segs
  local nx=x0+(x1-x0)*t
  local ny=y0+(y1-y0)*t
  if i<segs then nx+=math.random(-jit,jit) ny+=math.random(-jit,jit)*.25 end
  line(px,py,nx,ny,th)
  if (o.branch~=false) and i>1 and i<segs and math.random()<.35 then
   line(nx,ny,nx+math.random(-jit*2,jit*2),ny+math.random(jit,jit*3)*((y1>=y0) and 1 or -1),math.max(th*.6,1))
  end
  px,py=nx,ny
 end
 task.delay(o.hold or .08,function()
  local fade=o.fade or .35
  for _,v in ipairs(list) do
   if v[1].Parent then TS:Create(v[1],TweenInfo.new(fade),{BackgroundTransparency=1}):Play() end
  end
  task.delay(fade+.05,function() for _,v in ipairs(list) do v[1]:Destroy() end end)
 end)
end

local parent=(gethui and gethui()) or game:GetService("CoreGui")
if parent:FindFirstChild("NexoraHubUI") then parent.NexoraHubUI:Destroy() end
if parent:FindFirstChild("NexoraLoading") then parent.NexoraLoading:Destroy() end

-- อ่านภาษาที่บันทึกไว้ (ไว้ใช้กับหน้าโหลด)
local savedLang="TH"
pcall(function()
 if isfile and isfile(CFG.SETTINGS_FILE) then
  local d=game:GetService("HttpService"):JSONDecode(readfile(CFG.SETTINGS_FILE))
  if d.lang=="EN" or d.lang=="TH" then savedLang=d.lang end
  if type(d.accent)=="number" and PRESETS[d.accent] then COL.Purple=PRESETS[d.accent][1] COL.Pink=PRESETS[d.accent][2] end
 end
end)

------------------------------------------------------------------
-- หน้าโหลด
------------------------------------------------------------------
local Loader={ready=false,done=false}
function Loader.finish(cb) Loader.cb=cb Loader.ready=true end
do
 local TH=(savedLang=="TH")
 local cam=workspace.CurrentCamera
 local vp=cam and cam.ViewportSize or Vector2.new(800,500)
 local kk=math.clamp(math.min(vp.X/820,vp.Y/520),.6,1.15)
 local CY=.42
 local ld=make("ScreenGui",{Name="NexoraLoading",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=999999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
 pcall(function() ld.ScreenInsets=Enum.ScreenInsets.None end)
 local root=make("CanvasGroup",{Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0},ld)
 local bgl=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Active=true},root)
 make("UIGradient",{Color=ColorSequence.new(COL.Purple:Lerp(Color3.new(),.76),Color3.new(0,0,0)),Rotation=90},bgl)

 -- เนบิวลา
 local function neb(x,y,s,col,dx,dy,t)
  local h=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromOffset(s,s),BackgroundTransparency=1},root)
  for i=1,4 do
   local k=1-(i-1)*.2
   local f=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(k,k),BackgroundColor3=col,BackgroundTransparency=.93,BorderSizePixel=0},h)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},f)
  end
  TS:Create(h,TweenInfo.new(t,SINE,IO,-1,true),{Position=UDim2.fromScale(x+dx,y+dy)}):Play()
 end
 neb(.2,.25,520,COL.Pink:Lerp(Color3.new(),.38),.06,.08,8)
 neb(.8,.75,560,COL.Purple:Lerp(Color3.new(),.18),-.07,-.06,10)
 neb(.75,.15,380,COL.Pink:Lerp(Color3.new(),.14),-.05,.08,7)

 -- ดาว
 for i=1,90 do
  local sz=math.random(1,3)
  local s=make("Frame",{Position=UDim2.fromScale(math.random(),math.random()),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(math.random()<.3) and COL.Pink or Color3.new(1,1,1),BackgroundTransparency=math.random(30,70)/100,BorderSizePixel=0},root)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},s)
  TS:Create(s,TweenInfo.new(math.random(8,25)/10,SINE,IO,-1,true),{BackgroundTransparency=.95}):Play()
 end

 -- ลำแสงหมุนด้านหลัง
 local rayHold=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,CY),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1},root)
 for i=1,12 do
  local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset((i%2==0) and 3 or 2,1800),BackgroundColor3=(i%2==0) and COL.Pink or COL.Purple,BorderSizePixel=0,Rotation=i*15},rayHold)
  make("UIGradient",{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,.8),NumberSequenceKeypoint.new(1,1)})},r)
 end
 TS:Create(rayHold,TweenInfo.new(20,LIN,Enum.EasingDirection.In,-1),{Rotation=360}):Play()

 -- อนุภาคลอยขึ้น
 task.spawn(function()
  while ld.Parent do
   local sz=math.random(2,4)
   local x=math.random()
   local p=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(x,0,1,10),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(math.random()<.5) and COL.Pink or Color3.new(1,1,1),BackgroundTransparency=.3,BorderSizePixel=0},root)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},p)
   local dur=math.random(30,60)/10
   TS:Create(p,TweenInfo.new(dur,LIN),{Position=UDim2.new(math.clamp(x+(math.random()-.5)*.1,0,1),0,-.05,0),BackgroundTransparency=1}):Play()
   task.delay(dur+.1,function() p:Destroy() end)
   task.wait(.1)
  end
 end)

 -- สายฟ้าขาวฟาดทั้งหน้าจอ + แฟลช
 local lflash=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=WHITE,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2},root)
 task.spawn(function()
  task.wait(.4)
  while ld.Parent do
   local W,H=vp.X,vp.Y
   local x=math.random(math.floor(W*.1),math.floor(W*.9))
   bolt(root,x,-10,x+math.random(-120,120),H*math.random(45,85)/100,{segs=11,jit=34,th=2.5,z=4,hold=.1,fade=.4})
   lflash.BackgroundTransparency=.9
   TS:Create(lflash,TweenInfo.new(.35),{BackgroundTransparency=1}):Play()
   task.wait(math.random(6,15)/10)
  end
 end)

 -- มุมกรอบ HUD
 local function bracket(ax,ay)
  local f=make("Frame",{AnchorPoint=Vector2.new(ax,ay),Position=UDim2.new(ax,(ax==0) and 20 or -20,ay,(ay==0) and 20 or -20),Size=UDim2.fromOffset(34,34),BackgroundTransparency=1,ZIndex=3},root)
  make("Frame",{AnchorPoint=Vector2.new(ax,ay),Position=UDim2.fromScale(ax,ay),Size=UDim2.new(1,0,0,2),BackgroundColor3=COL.Pink,BorderSizePixel=0},f)
  make("Frame",{AnchorPoint=Vector2.new(ax,ay),Position=UDim2.fromScale(ax,ay),Size=UDim2.new(0,2,1,0),BackgroundColor3=COL.Pink,BorderSizePixel=0},f)
  TS:Create(f,TweenInfo.new(1.2,SINE,IO,-1,true),{BackgroundTransparency=1}):Play()
 end
 bracket(0,0) bracket(1,0) bracket(0,1) bracket(1,1)

 -- กลุ่มกลาง
 local ctr=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,CY),Size=UDim2.fromOffset(340,340),BackgroundTransparency=1,ZIndex=5},root)
 local csc=make("UIScale",{Scale=kk},ctr)
 for i=1,4 do
  local sz=150+i*38
  local h=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(i%2==0) and COL.Pink or COL.Purple,BackgroundTransparency=.9},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},h)
  TS:Create(h,TweenInfo.new(1.4+i*.25,SINE,IO,-1,true),{Size=UDim2.fromOffset(sz+30,sz+30),BackgroundTransparency=.96}):Play()
 end
 local function ring(sz,th,c1,c2,speed,rev)
  local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(sz,sz),BackgroundTransparency=1},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
  local s=make("UIStroke",{Thickness=th,Color=Color3.new(1,1,1)},r)
  local g=make("UIGradient",{Color=ColorSequence.new(c1,c2),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.5,.15),NumberSequenceKeypoint.new(.62,1),NumberSequenceKeypoint.new(1,1)})},s)
  TS:Create(g,TweenInfo.new(speed,LIN,Enum.EasingDirection.In,-1),{Rotation=rev and -360 or 360}):Play()
 end
 ring(170,4,COL.Pink,COL.Purple,1.5,false)
 ring(208,2.5,COL.Pink,COL.Purple,2.4,true)
 ring(250,1.5,COL.Purple,COL.Pink,4,false)

 -- จุดโคจร
 local dots={}
 for i=1,8 do
  local sz=(i%2==0) and 6 or 4
  local d=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(i%2==0) and COL.Pink or Color3.new(1,1,1),BorderSizePixel=0},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},d)
  dots[i]=d
 end
 local orb=RS.RenderStepped:Connect(function()
  local t=os.clock()
  for i,d in ipairs(dots) do
   local a=t*(.9+(i%3)*.35)*((i%2==0) and 1 or -1)+i*(math.pi*2/8)
   local r=130+math.sin(t*1.5+i)*8
   d.Position=UDim2.new(.5,math.cos(a)*r,.5,math.sin(a)*r)
  end
 end)

 -- โลโก้กลาง
 local lgo=make("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(128,128),BackgroundColor3=COL.Side},ctr)
 round(lgo,64)
 make("UIStroke",{Color=Color3.new(1,1,1),Thickness=2,Transparency=.5},lgo)
 setImg(lgo,CFG.LOGO_ID)
 lgo.ImageColor3=CFG.LOGO_DARK
 local ls=make("UIScale",{Scale=0},lgo)
 TS:Create(ls,TweenInfo.new(.8,Enum.EasingStyle.Back),{Scale=1}):Play()
 task.delay(.9,function()
  if ld.Parent then TS:Create(ls,TweenInfo.new(1.1,SINE,IO,-1,true),{Scale=1.07}):Play() end
 end)

 -- ระลอกคลื่น
 task.spawn(function()
  task.wait(.5)
  while ld.Parent do
   local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(128,128),BackgroundTransparency=1},ctr)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
   local s=make("UIStroke",{Color=COL.Pink,Thickness=2,Transparency=.2},r)
   TS:Create(r,TweenInfo.new(1.8,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(330,330)}):Play()
   TS:Create(s,TweenInfo.new(1.8),{Transparency=1}):Play()
   task.delay(1.9,function() r:Destroy() end)
   task.wait(.9)
  end
 end)
 local function shock()
  local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(128,128),BackgroundTransparency=1},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
  local s=make("UIStroke",{Color=Color3.new(1,1,1),Thickness=4},r)
  TS:Create(r,TweenInfo.new(.7,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(1800,1800)}):Play()
  TS:Create(s,TweenInfo.new(.7),{Transparency=1}):Play()
 end

 -- ชื่อ + แถบโหลด
 local bot=make("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,CY,math.floor(168*kk)),Size=UDim2.fromOffset(340,90),BackgroundTransparency=1,ZIndex=5},root)
 make("UIScale",{Scale=kk},bot)
 local spaced=(CFG.NAME:gsub("(.)","%1 "))
 local ttl=make("TextLabel",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Text=spaced,MaxVisibleGraphemes=0,Font=Enum.Font.GothamBlack,TextSize=26,TextColor3=Color3.new(1,1,1)},bot)
 local tg=make("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,COL.Purple),ColorSequenceKeypoint.new(.5,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,COL.Pink)}),Offset=Vector2.new(-1,0)},ttl)
 TS:Create(tg,TweenInfo.new(1.6,LIN,Enum.EasingDirection.In,-1),{Offset=Vector2.new(1,0)}):Play()
 task.spawn(function()
  for i=0,#spaced do
   if not ld.Parent then return end
   ttl.MaxVisibleGraphemes=i
   task.wait(.07)
  end
 end)
 local barBg=make("Frame",{Position=UDim2.fromOffset(0,42),Size=UDim2.new(1,0,0,8),BackgroundColor3=COL.Chip,BorderSizePixel=0},bot)
 round(barBg,4)
 make("UIStroke",{Color=COL.Pink,Thickness=1,Transparency=.6},barBg)
 local barFill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ClipsDescendants=true},barBg)
 round(barFill,4)
 make("UIGradient",{Color=ColorSequence.new(COL.Purple,COL.Pink)},barFill)
 local bsh=make("Frame",{Size=UDim2.fromScale(.3,1),Position=UDim2.fromScale(-.4,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.55,BorderSizePixel=0},barFill)
 TS:Create(bsh,TweenInfo.new(1,Enum.EasingStyle.Quad,IO,-1),{Position=UDim2.fromScale(1.2,0)}):Play()
 local st=make("TextLabel",{Position=UDim2.fromOffset(0,56),Size=UDim2.new(1,-60,0,14),BackgroundTransparency=1,Text="",Font=Enum.Font.Gotham,TextSize=11,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left},bot)
 local pc=make("TextLabel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,56),Size=UDim2.fromOffset(56,14),BackgroundTransparency=1,Text="0%",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right},bot)

 local flash=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=20},root)

 local texts=TH and {"กำลังเริ่มระบบ...","กำลังโหลดทรัพยากร...","กำลังสร้างหน้าต่าง...","กำลังเชื่อมต่อ...","ใกล้เสร็จแล้ว..."} or {"Initializing...","Loading assets...","Building interface...","Connecting services...","Almost ready..."}
 task.spawn(function()
  local t0=os.clock()
  local cur=0
  while ld.Parent do
   local dt=RS.RenderStepped:Wait()
   local el=os.clock()-t0
   local goal=math.min(el/3,1)*92
   if (Loader.ready and el>=3) or el>25 then goal=100 end
   cur+=(goal-cur)*math.min(dt*5,1)
   if goal==100 and cur>99.5 then cur=100 end
   barFill.Size=UDim2.fromScale(cur/100,1)
   pc.Text=math.floor(cur).."%"
   st.Text=texts[math.clamp(math.floor(cur/20)+1,1,5)]
   if cur>=100 then break end
  end
  st.Text=TH and "พร้อมแล้ว ✔" or "Ready ✔"
  task.wait(.35)
  Loader.done=true
  shock()
  TS:Create(flash,TweenInfo.new(.15),{BackgroundTransparency=.6}):Play()
  TS:Create(csc,TweenInfo.new(.7,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Scale=kk*1.6}):Play()
  task.wait(.15)
  TS:Create(flash,TweenInfo.new(.5),{BackgroundTransparency=1}):Play()
  TS:Create(root,TweenInfo.new(.6,Enum.EasingStyle.Quad),{GroupTransparency=1}):Play()
  task.wait(.7)
  orb:Disconnect()
  ld:Destroy()
  if Loader.cb then task.spawn(Loader.cb) end
 end)
end

------------------------------------------------------------------
-- หน้าต่างหลัก
------------------------------------------------------------------
local state={scale=.9,alpha=0,key=true,lang=savedLang,fx=true}

local gui=make("ScreenGui",{Name="NexoraHubUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)

local win=make("CanvasGroup",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(540,376),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,GroupTransparency=1,Visible=false},gui)
round(win,26)
local bgf=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1)},win)
round(bgf,26) glow(bgf,1.5)
local bgg=make("UIGradient",{Rotation=90},bgf)
onAccent(function(a) bgg.Color=ColorSequence.new(a:Lerp(Color3.new(),.8),a:Lerp(Color3.new(),.97)) end)
local sc=make("UIScale",{Scale=.05},win)

local lang=savedLang
local labels={}
local langHooks={}
local function L(o,en,th)
 labels[#labels+1]={o,en,th}
 o.Text=(lang=="TH" and th) and th or en
 return o
end

-- ===== เอฟเฟกต์อวกาศ =====
local space=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ClipsDescendants=true},bgf)
local spaceOn=true
do
 local function blob(x,y,s,col,dx,dy,t)
  local h=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromOffset(s,s),BackgroundTransparency=1},space)
  local cs={}
  for i=1,4 do
   local k=1-(i-1)*.2
   local c=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(k,k),BackgroundTransparency=.93,BorderSizePixel=0},h)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},c)
   cs[i]=c
  end
  onAccent(function(a,b) local cc=col(a,b) for _,c in ipairs(cs) do c.BackgroundColor3=cc end end)
  TS:Create(h,TweenInfo.new(t,SINE,IO,-1,true),{Position=UDim2.fromScale(x+dx,y+dy)}):Play()
 end
 blob(.15,.25,280,function(a,b) return b:Lerp(Color3.new(),.38) end,.08,.1,9)
 blob(.85,.8,320,function(a,b) return a:Lerp(Color3.new(),.18) end,-.1,-.08,11)
 blob(.6,.1,220,function(a,b) return b:Lerp(Color3.new(),.14) end,-.06,.12,8)

 for i=1,52 do
  local sz=math.random(1,2)+((math.random()<.12) and 1 or 0)
  local s=make("Frame",{Position=UDim2.fromScale(math.random(),math.random()),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(math.random()<.3) and COL.Pink or Color3.new(1,1,1),BackgroundTransparency=math.random(30,70)/100,BorderSizePixel=0},space)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},s)
  TS:Create(s,TweenInfo.new(math.random(8,25)/10,SINE,IO,-1,true),{BackgroundTransparency=.95}):Play()
 end

 local planet=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.95,.07),Size=UDim2.fromOffset(60,60),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.3},space)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},planet)
 local pg=make("UIGradient",{Rotation=45},planet)
 onAccent(function(a,b) pg.Color=ColorSequence.new(b:Lerp(Color3.new(1,1,1),.1),a:Lerp(Color3.new(),.82)) end)
 local ringp=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(104,26),BackgroundTransparency=1,Rotation=-22},planet)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},ringp)
 local rps=make("UIStroke",{Color=COL.Pink,Thickness=2,Transparency=.5},ringp)
 onAccent(function(_,b) rps.Color=b end)
 TS:Create(planet,TweenInfo.new(7,SINE,IO,-1,true),{Position=UDim2.fromScale(.95,.1)}):Play()

 task.spawn(function()
  while gui:IsDescendantOf(game) do
   task.wait(math.random(25,60)/10)
   if spaceOn and win.Visible then
    local x,y=math.random(5,60)/100,math.random(0,30)/100
    local s=make("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromOffset(64,2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Rotation=35},space)
    make("UIGradient",{Transparency=NumberSequence.new(1,0)},s)
    TS:Create(s,TweenInfo.new(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.fromScale(x+.35,y+.4)}):Play()
    task.delay(.9,function() s:Destroy() end)
   end
  end
 end)
end
task.spawn(function()
 while gui:IsDescendantOf(game) do
  task.wait(math.random(15,40)/10)
  if spaceOn and win.Visible then
   local x=math.random(40,500)
   bolt(space,x,-6,x+math.random(-70,70),math.random(120,300),{segs=8,jit=22,th=1.6,z=2,hold=.07,fade=.3})
  end
 end
end)
local function setSpace(v) spaceOn=v space.Visible=v end

-- ===== แถบบน =====
local top=make("Frame",{Size=UDim2.new(1,0,0,46),BackgroundTransparency=1},win)
local lg=make("ImageLabel",{Size=UDim2.fromOffset(30,30),Position=UDim2.fromOffset(14,8),BackgroundColor3=COL.Side},top)
round(lg,15) glow(lg,1.5)
setImg(lg,CFG.LOGO_ID)
lg.ImageColor3=CFG.LOGO_DARK
local title=make("TextLabel",{Position=UDim2.fromOffset(52,4),Size=UDim2.fromOffset(150,20),BackgroundTransparency=1,Text=CFG.NAME,Font=Enum.Font.GothamBlack,TextSize=16,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left},top)
local tg=make("UIGradient",{Offset=Vector2.new(-1,0)},title)
onAccent(function(a,b) tg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(.5,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,b)}) end)
TS:Create(tg,TweenInfo.new(2.2,LIN,Enum.EasingDirection.In,-1,false,1.2),{Offset=Vector2.new(1,0)}):Play()
local sub=make("TextLabel",{Position=UDim2.fromOffset(52,24),Size=UDim2.new(1,-260,0,12),BackgroundTransparency=1,Text=game.Name,Font=Enum.Font.Gotham,TextSize=10,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},top)

-- ตัวสลับภาษา (ใหญ่ ชัด มีไอคอนโลก)
local langF=make("Frame",{Size=UDim2.fromOffset(112,26),Position=UDim2.new(1,-190,0,10),BackgroundColor3=COL.Side},top)
round(langF,13)
local lfs=make("UIStroke",{Color=COL.Pink,Thickness=1,Transparency=.4},langF)
onAccent(function(a,b) lfs.Color=b end)
make("TextLabel",{Position=UDim2.fromOffset(6,0),Size=UDim2.fromOffset(18,26),BackgroundTransparency=1,Text="🌐",TextSize=13},langF)
local function lbtn(x,t)
 local b=make("TextButton",{Position=UDim2.fromOffset(x,3),Size=UDim2.fromOffset(40,20),BackgroundColor3=COL.Chip,Text=t,Font=Enum.Font.GothamBlack,TextSize=11,TextColor3=COL.Sub,AutoButtonColor=false},langF)
 round(b,10)
 return b
end
local thB=lbtn(26,"ไทย")
local enB=lbtn(68,"EN")
local curAcc=COL.Purple
local function paintLang()
 local th=(lang=="TH")
 TS:Create(thB,TweenInfo.new(.2),{BackgroundColor3=th and curAcc or COL.Chip,TextColor3=th and Color3.new(1,1,1) or COL.Sub}):Play()
 TS:Create(enB,TweenInfo.new(.2),{BackgroundColor3=(not th) and curAcc or COL.Chip,TextColor3=(not th) and Color3.new(1,1,1) or COL.Sub}):Play()
end
onAccent(function(a) curAcc=a paintLang() end)
local function setLang(l)
 lang=l state.lang=l
 for _,v in ipairs(labels) do v[1].Text=(l=="TH" and v[3]) and v[3] or v[2] end
 paintLang()
 for _,fn in ipairs(langHooks) do pcall(fn,l) end
 local n=getgenv().NX
 if n and n.save then n.save() end
end
thB.MouseButton1Click:Connect(function() setLang("TH") end)
enB.MouseButton1Click:Connect(function() setLang("EN") end)

local function tbtn(x,txt,col)
 local b=make("TextButton",{Size=UDim2.fromOffset(26,26),Position=UDim2.new(1,x,0,10),BackgroundColor3=col,Text=txt,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Color3.new(1,1,1),AutoButtonColor=false},top)
 round(b,13)
 b.MouseEnter:Connect(function() TS:Create(b,TweenInfo.new(.15),{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,x-2,0,8)}):Play() end)
 b.MouseLeave:Connect(function() TS:Create(b,TweenInfo.new(.15),{Size=UDim2.fromOffset(26,26),Position=UDim2.new(1,x,0,10)}):Play() end)
 return b
end
local minB=tbtn(-68,"–",COL.Purple)
local clsB=tbtn(-36,"X",COL.Red)
onAccent(function(a) minB.BackgroundColor3=a end)

-- ===== เมนูข้าง + หน้า =====
local side=make("Frame",{Position=UDim2.fromOffset(10,50),Size=UDim2.new(0,112,1,-60),BackgroundColor3=COL.Side,BackgroundTransparency=.45},win)
round(side,20)
local menu=make("ScrollingFrame",{Size=UDim2.new(1,0,1,-56),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},side)
make("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},menu)
make("UIPadding",{PaddingTop=UDim.new(0,10),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},menu)
local content=make("Frame",{Position=UDim2.fromOffset(130,50),Size=UDim2.new(1,-140,1,-60),BackgroundTransparency=1,ClipsDescendants=true},win)

local pages,btns,ord={}, {},0
local TI=TweenInfo.new(.3,Enum.EasingStyle.Quint)
local function selectPage(name)
 for n,p in pairs(pages) do
  if n==name then
   if not p.Visible then
    p.Visible=true p.Position=UDim2.fromOffset(18,0)
    TS:Create(p,TI,{Position=UDim2.new()}):Play()
   end
  else p.Visible=false end
 end
 for n,b in pairs(btns) do TS:Create(b,TI,{BackgroundTransparency=(n==name) and 0 or 1}):Play() end
end
local function section(en,th)
 ord+=1
 L(make("TextLabel",{LayoutOrder=ord,Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left},menu),en,th)
end
local function addPage(name,icon,en,th)
 ord+=1
 local b=make("TextButton",{LayoutOrder=ord,Size=UDim2.new(1,0,0,32),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},menu)
 round(b,16)
 local g=make("UIGradient",{},b)
 onAccent(function(a,c2) g.Color=ColorSequence.new(a,c2) end)
 make("TextLabel",{Position=UDim2.fromOffset(8,0),Size=UDim2.fromOffset(20,32),BackgroundTransparency=1,Text=icon,TextSize=14},b)
 L(make("TextLabel",{Position=UDim2.fromOffset(32,0),Size=UDim2.new(1,-36,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left},b),en,th)
 local p=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},content)
 pages[name]=p btns[name]=b
 b.MouseButton1Click:Connect(function() selectPage(name) end)
 return p
end
section("MAIN","หลัก")
addPage("home","⌂","HOME","HOME")
section("GAME","เกม")
addPage("farm","❀","FARM","ฟาร์ม")
addPage("buy","$","BUY","ซื้อ")
addPage("quest","!","QUEST","เควส")
addPage("dungeon","♜","DUNGEON","ดันเจี้ยน")
addPage("pvp","⚔","PVP","PVP")
addPage("race","✧","RACE","เผ่า")
addPage("wear","♛","WEAR","ของแต่งตัว")
addPage("esp","◉","ESP","ESP")
addPage("teleport","➤","TELEPORT","วาร์ป")
section("SYSTEM","ระบบ")
addPage("settings","☼","SETTINGS","SETTINGS")
selectPage("home")

-- ===== โลโก้ลอย + เอฟเฟกต์ =====
local LS=52
local logo=make("ImageButton",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(0,0),Position=UDim2.new(0,42,.5,0),BackgroundColor3=COL.Bg,Image="",AutoButtonColor=false},gui)
round(logo,26)
glow(logo,1.5)
setImg(logo,CFG.LOGO_ID)
logo.ImageColor3=CFG.LOGO_DARK
TS:Create(make("UIScale",{},logo),TweenInfo.new(1.8,SINE,IO,-1,true),{Scale=1.06}):Play()

local fxOn=true
local fxObjs={}
-- วงแหวนนีออนหมุนรอบโลโก้ (เห็นชัด เข้าใจง่าย)
local function fxRing(extra,th,speed,rev)
 local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(1,extra,1,extra),BackgroundTransparency=1},logo)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
 local s=make("UIStroke",{Thickness=th,Color=Color3.new(1,1,1)},r)
 local g=make("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.45,.1),NumberSequenceKeypoint.new(.6,1),NumberSequenceKeypoint.new(1,1)})},s)
 onAccent(function(a,b) g.Color=ColorSequence.new(b,a) end)
 TS:Create(g,TweenInfo.new(speed,LIN,Enum.EasingDirection.In,-1),{Rotation=rev and -360 or 360}):Play()
 fxObjs[#fxObjs+1]=r
end
fxRing(12,3,1.4,false)
fxRing(26,2,2.2,true)
local function setLogoFx(v)
 fxOn=v
 for _,r in ipairs(fxObjs) do r.Visible=v end
end
logo.MouseEnter:Connect(function() TS:Create(logo,TweenInfo.new(.2,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(LS+8,LS+8)}):Play() end)
logo.MouseLeave:Connect(function() TS:Create(logo,TweenInfo.new(.2,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(LS,LS)}):Play() end)

local function ripple()
 local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(1,1),BackgroundTransparency=1},logo)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
 local s=make("UIStroke",{Color=COL.Pink,Thickness=1.5,Transparency=.2},r)
 TS:Create(r,TweenInfo.new(1.4,Enum.EasingStyle.Quint),{Size=UDim2.fromScale(2.4,2.4)}):Play()
 TS:Create(s,TweenInfo.new(1.4),{Transparency=1}):Play()
 task.delay(1.5,function() r:Destroy() end)
end
local function burst()
 for i=1,10 do
  local a=math.rad(i*36)
  local d=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(5,5),BackgroundColor3=(i%2==0) and COL.Pink or COL.Purple},logo)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},d)
  TS:Create(d,TweenInfo.new(.7,Enum.EasingStyle.Quint),{Position=UDim2.new(.5,math.cos(a)*48,.5,math.sin(a)*48),BackgroundTransparency=1,Size=UDim2.fromOffset(2,2)}):Play()
  task.delay(.8,function() d:Destroy() end)
 end
end

local open,busy=false,false
local winPos=UDim2.new(.5,0,.5,0)
local function setOpen(v)
 if busy or v==open then return end
 busy=true open=v
 burst()
 logo.Rotation=0
 TS:Create(logo,TweenInfo.new(.6,Enum.EasingStyle.Back),{Rotation=360}):Play()
 task.delay(.65,function() logo.Rotation=0 busy=false end)
 if v then
  -- จำตำแหน่งเดิม และกันหลุดนอกจอ
  local av=gui.AbsoluteSize
  local hw,hh=540*state.scale/2,376*state.scale/2
  local ax=math.clamp(winPos.X.Scale*av.X+winPos.X.Offset,math.min(hw,av.X/2),math.max(av.X-hw,av.X/2))
  local ay=math.clamp(winPos.Y.Scale*av.Y+winPos.Y.Offset,math.min(hh,av.Y/2),math.max(av.Y-hh,av.Y/2))
  winPos=UDim2.fromOffset(ax,ay)
  win.Visible=true
  win.Position=logo.Position
  sc.Scale=.05 win.GroupTransparency=1
  local ti=TweenInfo.new(.55,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
  TS:Create(win,ti,{Position=winPos,GroupTransparency=state.alpha}):Play()
  TS:Create(sc,ti,{Scale=state.scale}):Play()
 else
  local ti=TweenInfo.new(.38,Enum.EasingStyle.Quint,Enum.EasingDirection.In)
  TS:Create(win,ti,{Position=logo.Position,GroupTransparency=1}):Play()
  TS:Create(sc,ti,{Scale=.05}):Play()
  task.delay(.4,function() if not open then win.Visible=false end end)
 end
end
local function resetPos()
 winPos=UDim2.new(.5,0,.5,0)
 logo.Position=UDim2.new(0,42,.5,0)
 if open then win.Position=winPos end
end

local function drag(handle,target,onClick,onEnd)
 local d,ds,sp,moved
 handle.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   d=true moved=false ds=i.Position sp=target.Position
   i.Changed:Connect(function()
    if i.UserInputState==Enum.UserInputState.End then
     d=false
     if onEnd then onEnd() end
     if onClick and not moved then onClick() end
    end
   end)
  end
 end)
 UIS.InputChanged:Connect(function(i)
  if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
   local v=i.Position-ds
   if v.Magnitude>6 then moved=true end
   target.Position=UDim2.new(sp.X.Scale,sp.X.Offset+v.X,sp.Y.Scale,sp.Y.Offset+v.Y)
  end
 end)
end
drag(top,win,nil,function() if open and not busy then winPos=win.Position end end)
drag(logo,logo,function() setOpen(not open) end)
minB.MouseButton1Click:Connect(function() setOpen(false) end)
clsB.MouseButton1Click:Connect(function() gui:Destroy() end)
UIS.InputBegan:Connect(function(i,gp)
 if not gp and state.key and i.KeyCode==Enum.KeyCode.RightShift then setOpen(not open) end
end)

task.spawn(function()
 while gui:IsDescendantOf(game) do
  if not open and fxOn then
   ripple()
   local a=math.rad(math.random(0,359))
   local c=LS/2
   bolt(logo,c+math.cos(a)*c*.9,c+math.sin(a)*c*.9,c+math.cos(a)*(c+34),c+math.sin(a)*(c+34),{segs=4,jit=8,th=1.4,z=3,hold=.06,fade=.25,branch=false})
  end
  task.wait(2.4)
 end
end)

getgenv().NX={COL=COL,make=make,round=round,glow=glow,L=L,setLang=setLang,getLang=function() return lang end,
 onLang=function(fn) langHooks[#langHooks+1]=fn end,
 content=content,sub=sub,side=side,pages=pages,onAccent=onAccent,setAccent=setAccent,setSpace=setSpace,
 setLogoFx=setLogoFx,resetPos=resetPos,setImg=setImg,CFG=CFG,gui=gui,
 state=state,win=win,sc=sc,setOpen=setOpen,isOpen=function() return open end}

------------------------------------------------------------------
-- หน้า HOME
------------------------------------------------------------------
do
local NX=getgenv().NX
local COL,make,round,glow,L=NX.COL,NX.make,NX.round,NX.glow,NX.L
local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local Stats=game:GetService("Stats")
local MPS=game:GetService("MarketplaceService")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.35,Enum.EasingStyle.Quint)
local c=NX.pages.home
local CEN=Enum.TextXAlignment.Center
local function T(en,th) return (NX.getLang()=="TH") and th or en end

local function txt(p,props)
 props.BackgroundTransparency=1
 props.Font=props.Font or Enum.Font.GothamBold
 props.TextColor3=props.TextColor3 or COL.Text
 props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
 return make("TextLabel",props,p)
end
local function pop(o,d)
 local s=make("UIScale",{Scale=0},o)
 task.delay(d,function() TS:Create(s,TweenInfo.new(.45,Enum.EasingStyle.Back),{Scale=1}):Play() end)
end
local function tag(p,props)
 props.AutomaticSize=Enum.AutomaticSize.X
 props.Size=UDim2.fromOffset(0,16)
 props.BackgroundColor3=COL.Bg
 props.BackgroundTransparency=.35
 props.Font=Enum.Font.GothamBold
 props.TextSize=9
 props.TextColor3=COL.Text
 local t=make("TextLabel",props,p)
 round(t,8)
 make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},t)
 return t
end

-- แถวหัวข้อ + แท็ก
local th=make("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},c)
local tl=L(txt(th,{Position=UDim2.fromOffset(2,0),Size=UDim2.fromOffset(110,20),Font=Enum.Font.GothamBlack,TextSize=17,TextColor3=Color3.new(1,1,1)}),"HOME","หน้าหลัก")
local tlg=make("UIGradient",{},tl)
NX.onAccent(function(a,b) tlg.Color=ColorSequence.new(a,b) end)
local tr=make("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,2),Size=UDim2.new(.7,0,0,16),BackgroundTransparency=1},th)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},tr)
L(tag(tr,{LayoutOrder=1}),"🎂 "..lp.AccountAge.." days","🎂 "..lp.AccountAge.." วัน")
tag(tr,{LayoutOrder=2,Text="🆔 "..lp.UserId})

-- โปรไฟล์
local pg=make("Frame",{Position=UDim2.fromOffset(0,26),Size=UDim2.new(1,-156,0,58),BackgroundTransparency=1},c)
local ring=make("Frame",{Position=UDim2.fromOffset(0,2),Size=UDim2.fromOffset(54,54),BackgroundTransparency=1},pg)
round(ring,27) glow(ring,1.5)
TS:Create(make("UIScale",{},ring),TweenInfo.new(1.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Scale=1.07}):Play()
local av=make("ImageLabel",{Size=UDim2.fromOffset(46,46),Position=UDim2.fromOffset(4,6),BackgroundColor3=COL.Side},pg)
round(av,23)
task.spawn(function()
 local ok,img=pcall(function() return Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
 if ok then av.Image=img end
end)
local nm=txt(pg,{Position=UDim2.fromOffset(66,4),Size=UDim2.new(1,-66,0,18),Text=lp.DisplayName,Font=Enum.Font.GothamBlack,TextSize=15,TextColor3=Color3.new(1,1,1),TextTruncate=Enum.TextTruncate.AtEnd})
local ng=make("UIGradient",{},nm)
NX.onAccent(function(a,b) ng.Color=ColorSequence.new(b,a) end)
txt(pg,{Position=UDim2.fromOffset(66,22),Size=UDim2.new(1,-66,0,12),Text="@"..lp.Name,Font=Enum.Font.Gotham,TextSize=10,TextColor3=COL.Sub,TextTruncate=Enum.TextTruncate.AtEnd})
local hpBack=make("Frame",{Position=UDim2.fromOffset(66,38),Size=UDim2.new(1,-66,0,16),BackgroundColor3=COL.Chip,BackgroundTransparency=.3},pg)
round(hpBack,8)
local fill=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=COL.Green,ClipsDescendants=true},hpBack)
round(fill,8)
local shine=make("Frame",{Size=UDim2.fromScale(.25,1),Position=UDim2.fromScale(-.3,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.7,BorderSizePixel=0},fill)
round(shine,8)
TS:Create(shine,TweenInfo.new(1.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,false,1),{Position=UDim2.fromScale(1.05,0)}):Play()
local hpTxt=txt(hpBack,{Size=UDim2.fromScale(1,1),Text="❤ -- / --",TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=CEN,ZIndex=2})
pop(pg,.05)

local function bindChar(ch)
 local hum=ch:WaitForChild("Humanoid",5)
 if not hum then return end
 local function upd()
  local r=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
  TS:Create(fill,TI,{Size=UDim2.fromScale(r,1),BackgroundColor3=COL.Red:Lerp(COL.Green,r)}):Play()
  hpTxt.Text="❤ "..math.floor(hum.Health).." / "..math.floor(hum.MaxHealth)
 end
 hum.HealthChanged:Connect(upd)
 hum:GetPropertyChangedSignal("MaxHealth"):Connect(upd)
 upd()
end
if lp.Character then task.spawn(bindChar,lp.Character) end
lp.CharacterAdded:Connect(bindChar)

-- ข้อมูลตัวละครฝั่งขวา
local rp=make("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,26),Size=UDim2.fromOffset(148,58),BackgroundTransparency=1},c)
local function pill(y,icon)
 local p=make("Frame",{Position=UDim2.fromOffset(0,y),Size=UDim2.new(1,0,0,26),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},rp)
 round(p,13) glow(p,1)
 return txt(p,{Size=UDim2.fromScale(1,1),TextSize=10,TextXAlignment=CEN,Text=icon.." --"})
end
local spdL=pill(0,"🏃")
local posL=pill(32,"📍")
pop(rp,.1)

-- กราฟ FPS / Ping
local N,W,H=26,144,30
local function chart(i,en,th2,unit,maxLbl,midLbl)
 local f=make("Frame",{Position=UDim2.new(i*.5,i*4,0,90),Size=UDim2.new(.5,-4,0,78),BackgroundColor3=COL.Chip,BackgroundTransparency=.35},c)
 round(f,18) glow(f,1.6)
 L(txt(f,{Position=UDim2.fromOffset(12,6),Size=UDim2.new(.5,0,0,10),TextSize=9,TextColor3=COL.Sub}),en,th2)
 local avg=txt(f,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,6),Size=UDim2.new(.5,0,0,10),TextSize=9,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Right})
 local v=txt(f,{Position=UDim2.fromOffset(12,15),Size=UDim2.new(.7,0,0,18),TextSize=16,Text="--"})
 local gf=make("Frame",{Position=UDim2.fromOffset(10,36),Size=UDim2.new(1,-20,0,38),BackgroundColor3=COL.Bg,BackgroundTransparency=.2},f)
 round(gf,10)
 local gs=make("UIStroke",{Color=COL.Pink,Thickness=1.4,Transparency=.05},gf)
 NX.onAccent(function(a,b) gs.Color=b end)
 local area=make("Frame",{Position=UDim2.fromOffset(26,4),Size=UDim2.fromOffset(W,H),BackgroundTransparency=1},gf)
 for g=0,2 do
  make("Frame",{Position=UDim2.new(0,0,g/2,g==2 and -1 or 0),Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.78,BorderSizePixel=0},area)
  txt(gf,{Position=UDim2.fromOffset(3,4+g*H/2-5),Size=UDim2.fromOffset(22,10),Font=Enum.Font.Gotham,TextSize=7,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Right,Text=(g==0) and maxLbl or ((g==1) and midLbl or "0")})
 end
 for g=1,3 do
  make("Frame",{Position=UDim2.new(g/4,0,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.9,BorderSizePixel=0},area)
 end
 local cols,segs={},{}
 for k=1,N do
  cols[k]=make("Frame",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.fromOffset((k-1)/(N-1)*W,H),Size=UDim2.fromOffset(math.ceil(W/N),0),BackgroundColor3=COL.Purple,BorderSizePixel=0},area)
  make("UIGradient",{Rotation=90,Transparency=NumberSequence.new(.5,1)},cols[k])
 end
 for k=1,N-1 do
  segs[k]=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(0,2),BackgroundColor3=COL.Purple,BorderSizePixel=0},area)
 end
 local dot=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(7,7),Position=UDim2.fromOffset(W,H),BackgroundColor3=Color3.new(1,1,1)},area)
 round(dot,4)
 pop(f,.15+i*.1)
 local vals,norm={},{}
 for k=1,N do vals[k]=0 norm[k]=0 end
 local ti=TweenInfo.new(.35,Enum.EasingStyle.Quint)
 return function(val,n,good)
  table.remove(vals,1) table.insert(vals,val)
  table.remove(norm,1) table.insert(norm,n)
  local s,cnt=0,0
  for _,x in ipairs(vals) do if x>0 then s+=x cnt+=1 end end
  avg.Text="avg "..math.floor(s/math.max(cnt,1))
  v.Text=val..unit
  local col=COL.Red:Lerp(COL.Green,good)
  TS:Create(v,ti,{TextColor3=col}):Play()
  local px,py={},{}
  for k=1,N do
   px[k]=(k-1)/(N-1)*W
   py[k]=H-math.max(norm[k],.05)*H
   cols[k].BackgroundColor3=col
   TS:Create(cols[k],ti,{Size=UDim2.fromOffset(math.ceil(W/N),H-py[k])}):Play()
  end
  for k=1,N-1 do
   local dx,dy=px[k+1]-px[k],py[k+1]-py[k]
   segs[k].BackgroundColor3=col
   TS:Create(segs[k],ti,{Position=UDim2.fromOffset(px[k]+dx/2,py[k]+dy/2),Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy)+1.5,2),Rotation=math.deg(math.atan2(dy,dx))}):Play()
  end
  dot.BackgroundColor3=col
  TS:Create(dot,ti,{Position=UDim2.fromOffset(W,py[N])}):Play()
 end
end
local updFps=chart(0,"⚡ FPS","⚡ FPS","","60","30")
local updPing=chart(1,"📡 Ping","📡 ปิง"," ms","300","150")

local frames,acc=0,0
local conn
conn=RS.RenderStepped:Connect(function(dt)
 if not c:IsDescendantOf(game) then conn:Disconnect() return end
 frames+=1 acc+=dt
 if acc<.6 then return end
 local fps=math.floor(frames/acc+.5)
 frames,acc=0,0
 local r=math.clamp(fps/60,0,1)
 updFps(fps,r,r)
 local ok,ms=pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
 if ok and ms then
  ms=math.floor(ms)
  local q=math.clamp(ms/300,0,1)
  updPing(ms,q,1-q)
 end
end)

-- ปกแมพ
local mp=make("Frame",{Position=UDim2.fromOffset(0,174),Size=UDim2.new(1,0,0,64),BackgroundTransparency=1,ClipsDescendants=true},c)
round(mp,20) glow(mp,1.6)
local aur=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},mp)
round(aur,20)
local ag=make("UIGradient",{},aur)
NX.onAccent(function(a,b) ag.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,a:Lerp(Color3.new(),.35)),ColorSequenceKeypoint.new(.5,a:Lerp(Color3.new(),.87)),ColorSequenceKeypoint.new(1,b:Lerp(Color3.new(),.18))}) end)
TS:Create(ag,TweenInfo.new(6,Enum.EasingStyle.Linear,Enum.EasingDirection.In,-1),{Rotation=360}):Play()
local img=make("ImageLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ImageTransparency=1,ScaleType=Enum.ScaleType.Crop},mp)
round(img,20)
local ov=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0},mp)
round(ov,20)
make("UIGradient",{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.8),NumberSequenceKeypoint.new(.5,.6),NumberSequenceKeypoint.new(1,.1)})},ov)
local sh=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(-.2,0,.5,0),Size=UDim2.new(0,28,2,0),Rotation=20,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.88,BorderSizePixel=0},mp)
TS:Create(sh,TweenInfo.new(2.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,false,1.5),{Position=UDim2.new(1.2,0,.5,0)}):Play()
L(txt(mp,{Position=UDim2.fromOffset(14,8),Size=UDim2.new(1,-190,0,12),Font=Enum.Font.Gotham,TextSize=10,TextColor3=COL.Pink}),"🗺 Current map","🗺 แมพที่เล่นอยู่")
local mn=txt(mp,{Position=UDim2.fromOffset(14,28),Size=UDim2.new(1,-28,0,28),Text=game.Name,Font=Enum.Font.GothamBlack,TextSize=17,TextTruncate=Enum.TextTruncate.AtEnd})
local mt=make("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,7),Size=UDim2.new(0,180,0,16),BackgroundTransparency=1},mp)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},mt)
local pl=tag(mt,{LayoutOrder=1,Text="👥 -- / --"})
local tm=tag(mt,{LayoutOrder=2,Text="⏱ 00:00:00"})
pop(mp,.3)

local srcs={
 "rbxthumb://type=GameIcon&id="..game.GameId.."&w=256&h=256",
 "rbxthumb://type=GameIcon&id="..game.GameId.."&w=150&h=150",
 "rbxthumb://type=Asset&id="..game.PlaceId.."&w=420&h=420",
}
task.spawn(function()
 for _,s in ipairs(srcs) do
  img.Image=s
  local t=0
  while not img.IsLoaded and t<3 do task.wait(.2) t+=.2 end
  if img.IsLoaded then TS:Create(img,TweenInfo.new(.8),{ImageTransparency=0}):Play() return end
 end
 img.Image=""
end)
task.spawn(function()
 local ok,info=pcall(function() return MPS:GetProductInfo(game.PlaceId) end)
 if ok and info then mn.Text=info.Name NX.sub.Text=info.Name end
end)

-- ชิปข้อมูลด้านล่าง (กดคัดลอกได้)
local cr=make("Frame",{Position=UDim2.fromOffset(0,244),Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},c)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},cr)
local function chipBtn(i,text,copyVal)
 local b=make("TextButton",{LayoutOrder=i,Size=UDim2.new(1/3,-3,1,0),BackgroundColor3=COL.Chip,BackgroundTransparency=.4,AutoButtonColor=false,Text=text,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=COL.Text},cr)
 round(b,11) glow(b,1)
 if copyVal then
  b.MouseButton1Click:Connect(function()
   pcall(function() setclipboard(copyVal) end)
   local old=b.Text
   b.Text="✔ copied"
   task.delay(1,function() b.Text=old end)
  end)
 end
 pop(b,.4+i*.05)
 return b
end
local memB=chipBtn(1,"🧠 -- MB")
chipBtn(2,"📍 "..game.PlaceId,tostring(game.PlaceId))
chipBtn(3,"🔗 "..string.sub(game.JobId,1,8),game.JobId)

-- ปุ่มคัดลอกลิงก์ Discord
local dc=make("TextButton",{Position=UDim2.fromOffset(0,272),Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.new(1,1,1),AutoButtonColor=false,Text="",ClipsDescendants=true},c)
round(dc,14)
local dcg=make("UIGradient",{Rotation=0},dc)
NX.onAccent(function(a,b) dcg.Color=ColorSequence.new(a:Lerp(Color3.new(),.73),a) end)
make("UIStroke",{Color=Color3.new(1,1,1),Transparency=.75,Thickness=1},dc)
local dci=make("ImageLabel",{Position=UDim2.fromOffset(9,5),Size=UDim2.fromOffset(28,28),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit},dc)
NX.setImg(dci,NX.CFG.DISCORD_ICON_ID)
txt(dc,{Position=UDim2.fromOffset(46,4),Size=UDim2.new(1,-140,0,16),Text="Discord",Font=Enum.Font.GothamBlack,TextSize=14,TextColor3=Color3.new(1,1,1)})
local dsub=L(txt(dc,{Position=UDim2.fromOffset(46,21),Size=UDim2.new(1,-140,0,12),Font=Enum.Font.Gotham,TextSize=9,TextColor3=Color3.fromRGB(225,225,225),TextTruncate=Enum.TextTruncate.AtEnd}),"Copy invite link","คัดลอกลิงก์เชิญ")
local dp=make("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),Size=UDim2.fromOffset(84,24),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.55},dc)
round(dp,12)
local dbl=L(txt(dp,{Size=UDim2.fromScale(1,1),TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=CEN}),"Copy","คัดลอก")
local dsh=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(-.2,0,.5,0),Size=UDim2.new(0,26,2,0),Rotation=20,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.8,BorderSizePixel=0},dc)
TS:Create(dsh,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,false,2),{Position=UDim2.new(1.2,0,.5,0)}):Play()
dc.MouseButton1Click:Connect(function()
 local ok=pcall(function() setclipboard(NX.CFG.DISCORD_LINK) end)
 dbl.Text=ok and T("✔ Copied","✔ คัดลอกแล้ว") or T("✖ Failed","✖ ไม่รองรับ")
 if not ok then dsub.Text=NX.CFG.DISCORD_LINK end
 task.delay(1.6,function()
  dbl.Text=T("Copy","คัดลอก")
  dsub.Text=T("Copy invite link","คัดลอกลิงก์เชิญ")
 end)
end)
pop(dc,.55)

-- สถานะใต้เมนูข้าง
local st=make("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,42),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},NX.side)
round(st,16)
local dot=make("Frame",{Position=UDim2.fromOffset(10,8),Size=UDim2.fromOffset(7,7),BackgroundColor3=COL.Green},st)
round(dot,4)
TS:Create(dot,TweenInfo.new(.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=.8}):Play()
L(txt(st,{Position=UDim2.fromOffset(22,4),Size=UDim2.new(1,-26,0,14),TextSize=10,TextColor3=COL.Green}),"Online","ออนไลน์")
local clk=txt(st,{Position=UDim2.fromOffset(10,20),Size=UDim2.new(1,-14,0,16),TextSize=14,Text=os.date("%H:%M:%S")})

-- ลูปอัปเดตสด
task.spawn(function()
 while c:IsDescendantOf(game) do
  local t=math.floor(workspace.DistributedGameTime)
  tm.Text=string.format("⏱ %02d:%02d:%02d",math.floor(t/3600),math.floor(t%3600/60),t%60)
  pl.Text="👥 "..#Players:GetPlayers().." / "..Players.MaxPlayers
  clk.Text=os.date("%H:%M:%S")
  local ok,mem=pcall(function() return math.floor(Stats:GetTotalMemoryUsageMb()) end)
  if ok then memB.Text="🧠 "..mem.." MB" end
  task.wait(1)
 end
end)
task.spawn(function()
 while c:IsDescendantOf(game) do
  local ch=lp.Character
  local hum=ch and ch:FindFirstChildOfClass("Humanoid")
  local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
  if hum then spdL.Text="🏃 "..(math.floor(hum.WalkSpeed*10)/10).." speed" end
  if hrp then
   local p=hrp.Position
   posL.Text=string.format("📍 %d, %d, %d",math.floor(p.X),math.floor(p.Y),math.floor(p.Z))
  end
  task.wait(.25)
 end
end)
end

------------------------------------------------------------------
-- หน้า SETTINGS
------------------------------------------------------------------
do
local NX=getgenv().NX
local COL,make,round,L=NX.COL,NX.make,NX.round,NX.L
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local TeleportService=game:GetService("TeleportService")
local Lighting=game:GetService("Lighting")
local Players=game:GetService("Players")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.2,Enum.EasingStyle.Quint)
local S=NX.state
local DEF={scale=.9,alpha=0,accent=1,space=true,afk=false,fps=0,key=true,fx=true,fov=70,fovOn=false,fullbright=false,boost=false}
for k,v in pairs(DEF) do if S[k]==nil then S[k]=v end end

-- โหลด/บันทึกการตั้งค่า (ถ้า executor รองรับ)
local FILE=NX.CFG.SETTINGS_FILE
pcall(function()
 if isfile and isfile(FILE) then
  for k,v in pairs(HttpService:JSONDecode(readfile(FILE))) do S[k]=v end
 end
end)
S.scale=.9 -- เริ่มที่ 90% ทุกครั้ง
local function clean(v,d)
 local t=type(v)
 if t=="number" then if v~=v or v==math.huge or v==-math.huge then return nil end return v end
 if t=="string" or t=="boolean" then return v end
 if t=="table" and d<3 then
  local o={}
  for k,x in pairs(v) do
   if type(k)=="string" then local y=clean(x,d+1) if y~=nil then o[k]=y end end
  end
  return o
 end
 return nil
end
local function save()
 local ok,e=pcall(function()
  if not writefile then return end
  local c={}
  for k,v in pairs(S) do
   if type(k)=="string" then local y=clean(v,0) if y~=nil then c[k]=y end end
  end
  writefile(FILE,HttpService:JSONEncode(c))
 end)
 if not ok then warn("[Nexora] save failed: "..tostring(e)) end
end
NX.save=save
task.spawn(function()
 while NX.gui.Parent do task.wait(8) save() end
end)
NX.gui.Destroying:Connect(save)
local function T(en,th) return (NX.getLang()=="TH") and th or en end

local sf=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},NX.pages.settings)
make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},sf)
make("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sf)
local ord=0
local ctrls={}

local function txt(p,props)
 props.BackgroundTransparency=1
 props.Font=props.Font or Enum.Font.GothamBold
 props.TextColor3=props.TextColor3 or COL.Text
 props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
 return make("TextLabel",props,p)
end
local function header(en,th,big)
 ord+=1
 local l=txt(sf,{LayoutOrder=ord,Size=UDim2.new(1,0,0,big and 22 or 16),Font=big and Enum.Font.GothamBlack or Enum.Font.GothamBold,TextSize=big and 17 or 10,TextColor3=big and Color3.new(1,1,1) or COL.Pink})
 if big then
  local g=make("UIGradient",{},l)
  NX.onAccent(function(a,b) g.Color=ColorSequence.new(a,b) end)
 end
 L(l,en,th)
end
local function row(h)
 ord+=1
 local r=make("Frame",{LayoutOrder=ord,Size=UDim2.new(1,0,0,h),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},sf)
 round(r,14)
 local s=make("UIStroke",{Color=COL.Pink,Transparency=.65,Thickness=1},r)
 NX.onAccent(function(a,b) s.Color=b end)
 return r
end
local function titles(r,en,th,dEn,dTh,w)
 L(txt(r,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,w or -80,0,16),TextSize=12}),en,th)
 if dEn then L(txt(r,{Position=UDim2.fromOffset(14,22),Size=UDim2.new(1,w or -80,0,14),Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub}),dEn,dTh) end
end

local function toggle(key,en,th,dEn,dTh,cb)
 local r=row(42)
 titles(r,en,th,dEn,dTh)
 local sw=make("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-52,.5,-10),BackgroundColor3=COL.Bg},r)
 round(sw,10)
 local knob=make("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
 round(knob,7)
 local function set(v,fire)
  S[key]=v
  TS:Create(sw,TI,{BackgroundColor3=v and COL.Purple or COL.Bg}):Play()
  TS:Create(knob,TI,{Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)}):Play()
  if fire then cb(v) save() end
 end
 sw.MouseButton1Click:Connect(function() set(not S[key],true) end)
 set(S[key],false)
 NX.onAccent(function() sw.BackgroundColor3=S[key] and COL.Purple or COL.Bg end)
 ctrls[key]=set
end

local function button(en,th,dEn,dTh,bEn,bTh,cb,dyn)
 local r=row(42)
 L(txt(r,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,-110,0,16),TextSize=12}),en,th)
 local d=txt(r,{Position=UDim2.fromOffset(14,22),Size=UDim2.new(1,-110,0,14),Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub,TextTruncate=Enum.TextTruncate.AtEnd})
 if dyn then d.Text=T(dEn,dTh) else L(d,dEn,dTh) end
 local b=make("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(84,26),BackgroundColor3=COL.Purple,Text="",AutoButtonColor=false},r)
 round(b,13)
 NX.onAccent(function(a) b.BackgroundColor3=a end)
 local bl=L(txt(b,{Size=UDim2.fromScale(1,1),TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Center}),bEn,bTh)
 b.MouseButton1Click:Connect(function() cb(d,bl,b) end)
 return d,bl
end

local function slider(key,en,th,min,max,fmt,onRelease,cb)
 local r=row(50)
 titles(r,en,th,nil,nil,-90)
 local vl=txt(r,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,6),Size=UDim2.fromOffset(70,16),TextSize=11,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right})
 local track=make("Frame",{Position=UDim2.new(0,14,0,34),Size=UDim2.new(1,-28,0,6),BackgroundColor3=COL.Bg},r)
 round(track,3)
 local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=COL.Purple},track)
 round(fill,3)
 local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.new(1,1,1)},track)
 round(knob,7)
 NX.onAccent(function(a) fill.BackgroundColor3=a end)
 local hit=make("TextButton",{Text="",BackgroundTransparency=1,Position=UDim2.new(0,14,0,22),Size=UDim2.new(1,-28,0,26)},r)
 local function show(v)
  local t=(v-min)/(max-min)
  fill.Size=UDim2.fromScale(t,1) knob.Position=UDim2.fromScale(t,.5)
  vl.Text=fmt(v)
 end
 local function set(v,fire)
  v=math.clamp(v,min,max) S[key]=v show(v)
  if fire then cb(v) end
 end
 local dragging=false
 local function fromX(x)
  local t=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
  local v=min+(max-min)*t
  S[key]=v show(v)
  if not onRelease then cb(v) end
 end
 local function isPtr(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
 hit.InputBegan:Connect(function(i) if isPtr(i) then dragging=true fromX(i.Position.X) end end)
 UIS.InputChanged:Connect(function(i)
  if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end
 end)
 UIS.InputEnded:Connect(function(i)
  if dragging and isPtr(i) then
   dragging=false
   if onRelease then cb(S[key]) end
   save()
  end
 end)
 show(S[key])
 ctrls[key]=set
end

-- ตัวเลือกหลายปุ่ม (ล็อก FPS)
local function segmented(key,en,th,opts,cb)
 local r=row(56)
 titles(r,en,th)
 local holder=make("Frame",{Position=UDim2.fromOffset(14,26),Size=UDim2.new(1,-28,0,24),BackgroundTransparency=1},r)
 make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},holder)
 local bs={}
 local function mark()
  for v,b in pairs(bs) do
   TS:Create(b,TI,{BackgroundColor3=(S[key]==v) and COL.Purple or COL.Bg}):Play()
  end
 end
 for _,o in ipairs(opts) do
  local b=make("TextButton",{Size=UDim2.new(1/#opts,-4,1,0),BackgroundColor3=COL.Bg,Text=o[2],Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Text,AutoButtonColor=false},holder)
  round(b,12)
  bs[o[1]]=b
  b.MouseButton1Click:Connect(function() S[key]=o[1] mark() cb(o[1]) save() end)
 end
 mark()
 NX.onAccent(function() mark() end)
 ctrls[key]=function(v,fire) S[key]=v mark() if fire then cb(v) end end
end

-- เลือกภาษา (ปุ่มใหญ่ ชัดเจน)
local function langRow()
 local r=row(60)
 titles(r,"Language","ภาษา (Language)")
 local holder=make("Frame",{Position=UDim2.fromOffset(14,26),Size=UDim2.new(1,-28,0,28),BackgroundTransparency=1},r)
 make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8)},holder)
 local bs={}
 local function mark()
  for v,b in pairs(bs) do
   local on=(NX.getLang()==v)
   TS:Create(b,TI,{BackgroundColor3=on and COL.Purple or COL.Bg,TextColor3=on and Color3.new(1,1,1) or COL.Sub}):Play()
  end
 end
 for _,o in ipairs({{"TH","🌐 ไทย"},{"EN","🌐 English"}}) do
  local b=make("TextButton",{Size=UDim2.new(.5,-4,1,0),BackgroundColor3=COL.Bg,Text=o[2],Font=Enum.Font.GothamBlack,TextSize=12,TextColor3=COL.Sub,AutoButtonColor=false},holder)
  round(b,14)
  bs[o[1]]=b
  b.MouseButton1Click:Connect(function() NX.setLang(o[1]) end)
 end
 NX.onLang(mark)
 NX.onAccent(function() mark() end)
end

-- เลือกสีธีม
local function colorRow()
 local r=row(56)
 titles(r,"Theme color","สีธีม")
 local holder=make("Frame",{Position=UDim2.fromOffset(14,26),Size=UDim2.new(1,-28,0,24),BackgroundTransparency=1},r)
 make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,10)},holder)
 local sts={}
 local function mark()
  for i,s in ipairs(sts) do s.Transparency=(S.accent==i) and 0 or 1 end
 end
 for i,p in ipairs(PRESETS) do
  local b=make("TextButton",{Size=UDim2.fromOffset(24,24),BackgroundColor3=p[1],Text="",AutoButtonColor=false},holder)
  round(b,12)
  make("UIGradient",{Color=ColorSequence.new(p[1],p[2]),Rotation=45},b)
  sts[i]=make("UIStroke",{Color=Color3.new(1,1,1),Thickness=2,Transparency=1},b)
  b.MouseButton1Click:Connect(function() S.accent=i mark() NX.setAccent(p[1],p[2]) save() end)
 end
 mark()
 ctrls.accent=function(i) if not PRESETS[i] then i=1 end S.accent=i mark() NX.setAccent(PRESETS[i][1],PRESETS[i][2]) end
end

-- ===== ค้นหาเซิร์ฟเวอร์ =====
local function httpGet(url)
 local ok,res=pcall(function() return game:HttpGet(url) end)
 if ok and res and #res>0 then return res end
 local req=(syn and syn.request) or (http and http.request) or http_request or request
 if req then
  local ok2,r=pcall(req,{Url=url,Method="GET"})
  if ok2 and r and r.Body then return r.Body end
 end
end
local function findLow(status)
 local best,cursor
 for page=1,5 do
  status("🔎 "..T("Searching... page ","กำลังค้นหา... หน้า ")..page)
  local url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor and ("&cursor="..cursor) or "")
  local body=httpGet(url)
  if not body then return nil,"http" end
  local ok,data=pcall(function() return HttpService:JSONDecode(body) end)
  if not ok or not data or not data.data then return nil,"parse" end
  for _,s in ipairs(data.data) do
   if s.id~=game.JobId and s.playing and s.playing<s.maxPlayers then
    if s.playing<=1 then return s end
    if not best or s.playing<best.playing then best=s end
   end
  end
  cursor=data.nextPageCursor
  if not cursor then break end
  task.wait(.5)
 end
 return nil,"none",best
end
local function findRandom()
 local body=httpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
 if not body then return nil,"http" end
 local ok,data=pcall(function() return HttpService:JSONDecode(body) end)
 if not ok or not data or not data.data then return nil,"parse" end
 local list={}
 for _,s in ipairs(data.data) do
  if s.id~=game.JobId and s.playing and s.playing<s.maxPlayers then list[#list+1]=s end
 end
 if #list==0 then return nil,"none" end
 return list[math.random(#list)]
end

-- ===== ฟังก์ชันเสริม =====
local afkConn
local function setAFK(v)
 if afkConn then afkConn:Disconnect() afkConn=nil end
 if v then
  local VU=game:GetService("VirtualUser")
  afkConn=lp.Idled:Connect(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
 end
end

local lightBackup
local function setFull(v)
 pcall(function()
  if v then
   if not lightBackup then
    lightBackup={Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,FogEnd=Lighting.FogEnd,GlobalShadows=Lighting.GlobalShadows,Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient}
   end
   Lighting.Brightness=2
   Lighting.ClockTime=14
   Lighting.FogEnd=1e6
   Lighting.GlobalShadows=false
   Lighting.Ambient=Color3.fromRGB(180,180,180)
   Lighting.OutdoorAmbient=Color3.fromRGB(180,180,180)
  elseif lightBackup then
   for k,val in pairs(lightBackup) do Lighting[k]=val end
   lightBackup=nil
  end
 end)
end

local boostedFx,boostQ={},nil
local function setBoost(v)
 if v then
  pcall(function()
   if not boostQ then boostQ=settings().Rendering.QualityLevel end
   settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
  end)
  pcall(function()
   for _,o in ipairs(workspace:GetDescendants()) do
    if (o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") or o:IsA("Beam")) and o.Enabled then
     o.Enabled=false
     boostedFx[#boostedFx+1]=o
    end
   end
  end)
 else
  pcall(function()
   if boostQ then settings().Rendering.QualityLevel=boostQ boostQ=nil end
  end)
  for _,o in ipairs(boostedFx) do pcall(function() o.Enabled=true end) end
  boostedFx={}
 end
end

local origFov
local function applyFov(v)
 local cam=workspace.CurrentCamera
 if cam then cam.FieldOfView=v end
end
local function setFovOn(v)
 local cam=workspace.CurrentCamera
 if not cam then return end
 if v then
  origFov=origFov or cam.FieldOfView
  cam.FieldOfView=S.fov
 elseif origFov then
  cam.FieldOfView=origFov
  origFov=nil
 end
end

------------------------------------------------------------------
-- สร้างเมนูตั้งค่า
------------------------------------------------------------------
header("SETTINGS","ตั้งค่า",true)

header("LANGUAGE","ภาษา")
langRow()

header("SERVER","เซิร์ฟเวอร์")
local pending,searching
button("Find empty server","หาเซิร์ฟเวอร์คนน้อย","Find a server with 0-1 players and join","ค้นหาเซิร์ฟที่มี 0–1 คน แล้ววาร์ปไป","Search","ค้นหา",function(d,bl)
 if searching then return end
 if pending then
  d.Text="🚀 "..T("Teleporting...","กำลังวาร์ป...")
  pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,pending.id,lp) end)
  return
 end
 searching=true
 task.spawn(function()
  local s,err,best=findLow(function(t) d.Text=t end)
  searching=false
  if s then
   d.Text="✅ "..T("Found ","พบเซิร์ฟ ")..s.playing..T(" player, joining..."," คน กำลังวาร์ป...")
   pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,lp) end)
  elseif best then
   pending=best
   d.Text="⚠ "..T("None with 0-1. Lowest: ","ไม่พบ 0–1 คน ต่ำสุดคือ ")..best.playing..T(" - press again to join"," คน กดอีกครั้งเพื่อไป")
   bl.Text=T("Join","ไป")
  else
   d.Text="❌ "..((err=="none") and T("No server found","ไม่พบเซิร์ฟเวอร์") or T("Request failed (HttpGet blocked?)","เรียกข้อมูลไม่ได้ (executor อาจไม่รองรับ)"))
  end
 end)
end,true)
local hopping
button("Server hop","สุ่มเปลี่ยนเซิร์ฟเวอร์","Join a random different server","สุ่มเข้าเซิร์ฟเวอร์อื่น","Hop","สลับ",function(d)
 if hopping then return end
 hopping=true
 d.Text="🔎 "..T("Searching...","กำลังค้นหา...")
 task.spawn(function()
  local s,err=findRandom()
  hopping=false
  if s then
   d.Text="🚀 "..T("Teleporting...","กำลังวาร์ป...")
   pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,lp) end)
  else
   d.Text="❌ "..((err=="none") and T("No server found","ไม่พบเซิร์ฟเวอร์") or T("Request failed","เรียกข้อมูลไม่ได้"))
  end
 end)
end,true)
button("Rejoin","รีจอยเซิร์ฟเวอร์นี้","Rejoin the current server","เข้าเซิร์ฟเวอร์เดิมใหม่","Rejoin","รีจอย",function()
 if #Players:GetPlayers()<=1 then
  pcall(function() TeleportService:Teleport(game.PlaceId,lp) end)
 else
  pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,lp) end)
 end
end)
button("Copy Job ID","คัดลอก Job ID","Copy this server's ID","คัดลอกไอดีเซิร์ฟเวอร์นี้","Copy","คัดลอก",function(d,bl)
 pcall(function() setclipboard(game.JobId) end)
 local o=bl.Text bl.Text="✔"
 task.delay(1,function() bl.Text=o end)
end)
button("Copy game link","คัดลอกลิงก์เกม","Copy this game's Roblox link","คัดลอกลิงก์เกมนี้","Copy","คัดลอก",function(d,bl)
 pcall(function() setclipboard("https://www.roblox.com/games/"..game.PlaceId) end)
 local o=bl.Text bl.Text="✔"
 task.delay(1,function() bl.Text=o end)
end)

header("APPEARANCE","หน้าตา GUI")
slider("scale","GUI size","ขนาด GUI",.7,1.3,function(v) return math.floor(v*100+.5).."%" end,true,function(v)
 if NX.isOpen() then TS:Create(NX.sc,TweenInfo.new(.25,Enum.EasingStyle.Quint),{Scale=v}):Play() end
end)
slider("alpha","Transparency","ความโปร่งใส",0,.6,function(v) return math.floor(v*100+.5).."%" end,false,function(v)
 if NX.isOpen() then NX.win.GroupTransparency=v end
end)
colorRow()
toggle("space","Space effects","เอฟเฟกต์อวกาศ","Stars, nebula, shooting stars","ดาว เนบิวลา ดาวตก",function(v) NX.setSpace(v) end)
toggle("fx","Logo effects","เอฟเฟกต์โลโก้","Orbit, shine and ripple on the logo","วงโคจร แสงวิบ และระลอกที่โลโก้",function(v) NX.setLogoFx(v) end)
button("Reset GUI position","รีเซ็ตตำแหน่ง GUI","Move window and logo back to default","ย้ายหน้าต่างและโลโก้กลับที่เดิม","Reset","รีเซ็ต",function(d,bl)
 NX.resetPos()
 local o=bl.Text bl.Text="✔"
 task.delay(1,function() bl.Text=o end)
end)

header("GRAPHICS","กราฟิก")
do
 local r=row(58)
 L(txt(r,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,-150,0,16),TextSize=12}),"Field of view (FOV)","มุมมอง (FOV)")
 local vl=txt(r,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-100,0,6),Size=UDim2.fromOffset(50,16),TextSize=11,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right})
 local st=txt(r,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-58,0,7),Size=UDim2.fromOffset(30,14),Font=Enum.Font.GothamBlack,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right})
 local sw=make("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-52,0,5),BackgroundColor3=COL.Bg},r)
 round(sw,10)
 local sk=make("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
 round(sk,7)
 local track=make("Frame",{Position=UDim2.new(0,14,0,40),Size=UDim2.new(1,-28,0,6),BackgroundColor3=COL.Bg},r)
 round(track,3)
 local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=COL.Purple},track)
 round(fill,3)
 local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.new(1,1,1)},track)
 round(knob,7)
 NX.onAccent(function(a) fill.BackgroundColor3=a if S.fovOn then sw.BackgroundColor3=a end end)
 local hit=make("TextButton",{Text="",BackgroundTransparency=1,Position=UDim2.new(0,14,0,28),Size=UDim2.new(1,-28,0,26)},r)
 local function showV(v)
  local t=(v-50)/70
  fill.Size=UDim2.fromScale(t,1) knob.Position=UDim2.fromScale(t,.5)
  vl.Text=math.floor(v+.5).."°"
 end
 local function setV(v,fire)
  v=math.clamp(v,50,120) S.fov=v showV(v)
  if fire and S.fovOn then applyFov(v) end
 end
 local function setOn(v,fire)
  S.fovOn=v
  TS:Create(sw,TI,{BackgroundColor3=v and COL.Purple or COL.Bg}):Play()
  TS:Create(sk,TI,{Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)}):Play()
  TS:Create(fill,TI,{BackgroundTransparency=v and 0 or .6}):Play()
  st.Text=v and "ON" or "OFF"
  st.TextColor3=v and COL.Green or COL.Sub
  if fire then setFovOn(v) save() end
 end
 sw.MouseButton1Click:Connect(function() setOn(not S.fovOn,true) end)
 local dragging=false
 local function isPtr(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
 local function fromX(x)
  local t=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
  setV(50+70*t,true)
 end
 hit.InputBegan:Connect(function(i) if isPtr(i) then dragging=true fromX(i.Position.X) end end)
 UIS.InputChanged:Connect(function(i)
  if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end
 end)
 UIS.InputEnded:Connect(function(i)
  if dragging and isPtr(i) then dragging=false save() end
 end)
 setV(S.fov,false) setOn(S.fovOn,false)
 ctrls.fov=setV ctrls.fovOn=setOn
end
toggle("fullbright","Fullbright","แสงสว่างเต็มที่","Remove darkness and fog","ลบความมืดและหมอก",setFull)
toggle("boost","FPS booster","เพิ่ม FPS","Lower quality + disable particles","ลดกราฟิกและปิดพาร์ติเคิล",setBoost)

header("GENERAL","ทั่วไป")
toggle("afk","Anti-AFK","กันหลุดเมื่อ AFK","Prevents idle kick (20 min)","กันโดนเตะเมื่อไม่ขยับ",setAFK)
segmented("fps","FPS cap","ล็อก FPS",{{30,"30"},{60,"60"},{120,"120"},{240,"240"},{0,"∞"}},function(v)
 pcall(function() if setfpscap then setfpscap(v==0 and 999 or v) end end)
end)
toggle("key","Hotkey (RightShift)","คีย์ลัด (RightShift)","Show / hide GUI with RightShift","ซ่อน/แสดง GUI ด้วย RightShift",function(v) S.key=v end)
button("Reset character","รีเซ็ตตัวละคร","Respawn your character","เกิดใหม่","Reset","รีเซ็ต",function()
 local ch=lp.Character
 local h=ch and ch:FindFirstChildOfClass("Humanoid")
 if h then h.Health=0 end
end)

header("COMMUNITY","ชุมชน")
button("Discord","ดิสคอส","Copy the Discord invite link","คัดลอกลิงก์เชิญดิสคอส","Copy","คัดลอก",function(d,bl)
 local ok=pcall(function() setclipboard(NX.CFG.DISCORD_LINK) end)
 local o=bl.Text bl.Text=ok and "✔" or "✖"
 task.delay(1,function() bl.Text=o end)
end)

header("MANAGE","จัดการ")
button("Reset settings","รีเซ็ตการตั้งค่า","Restore default GUI settings","คืนค่าตั้งต้นของ GUI","Reset","รีเซ็ต",function()
 for k,v in pairs(DEF) do S[k]=v end
 for k,v in pairs(DEF) do
  if ctrls[k] then ctrls[k](v,true) end
 end
 save()
end)
button("Unload GUI","ปิดสคริปต์","Remove the GUI and undo changes","ลบ GUI และคืนค่าที่แก้ไว้","Unload","ปิด",function()
 setFull(false) setBoost(false) setAFK(false) setFovOn(false)
 NX.gui:Destroy()
end)

-- ใช้ค่าที่บันทึกไว้ตอนเริ่ม
ctrls.accent(S.accent)
NX.setSpace(S.space)
NX.setLogoFx(S.fx)
setAFK(S.afk)
pcall(function() if setfpscap and S.fps~=0 then setfpscap(S.fps) end end)
if S.fullbright then setFull(true) end
if S.boost then setBoost(true) end
if S.fovOn then setFovOn(true) end
task.spawn(function()
 while NX.gui.Parent do
  if S.fovOn and S.fov then applyFov(S.fov) end
  task.wait(.5)
 end
end)
end

------------------------------------------------------------------
-- หน้าเกม: ฟาร์ม / ซื้อ / เควส / ดันเจี้ยน(เรด) / PVP / ESP / วาร์ป
-- เกม: [อัพเดท 4] ทะเลเมม (PlaceId 10260193230)
------------------------------------------------------------------
do
local okG,errG=pcall(function()
local NX=getgenv().NX
local COL,make,round,L=NX.COL,NX.make,NX.round,NX.L
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local Players=game:GetService("Players")
local WS=game:GetService("Workspace")
local RepS=game:GetService("ReplicatedStorage")
local VIM=game:GetService("VirtualInputManager")
local StarterGui=game:GetService("StarterGui")
local RunS=game:GetService("RunService")
local conns={}
local G={}   -- ฟังก์ชันที่ใช้ข้ามส่วน
local lp=Players.LocalPlayer
local S=NX.state
local TI=TweenInfo.new(.2,Enum.EasingStyle.Quint)
local function T(en,th) return (NX.getLang()=="TH") and th or en end

NX.Features=NX.Features or {}
local Features=NX.Features
local UI={}      -- UI[key](value,fire) ตั้งค่าสวิตช์จากโค้ด
local function save() if NX.save then NX.save() end end
local drag={}
conns[#conns+1]=UIS.InputChanged:Connect(function(i)
 local d=drag.cur
 if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then d.move(i.Position.X) end
end)
conns[#conns+1]=UIS.InputEnded:Connect(function(i)
 local d=drag.cur
 if d and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then drag.cur=nil d.done() end
end)
local function fire(key,v)
 local f=Features[key]
 if f then
  task.spawn(function()
   local ok,e=pcall(f,v)
   if not ok then warn("[Nexora] "..key..": "..tostring(e)) end
  end)
 end
end

------------------------------------------------------------------
-- ตัวสร้างหน้า (toggle / slider / segmented / picker / button / status)
------------------------------------------------------------------
local function build(pageName)
 local sf=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},NX.pages[pageName])
 make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},sf)
 make("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sf)
 local ord=0
 local P={toggles={}}

 local function txt(p,props)
  props.BackgroundTransparency=1
  props.Font=props.Font or Enum.Font.GothamBold
  props.TextColor3=props.TextColor3 or COL.Text
  props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
  return make("TextLabel",props,p)
 end
 local function row(h)
  ord+=1
  local r=make("Frame",{LayoutOrder=ord,Size=UDim2.new(1,0,0,h),BackgroundColor3=COL.Chip,BackgroundTransparency=.4,ClipsDescendants=true},sf)
  round(r,14)
  return r
 end
 local function titles(r,en,th,dEn,dTh,w)
  L(txt(r,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,w or -80,0,16),TextSize=12}),en,th)
  if dEn then L(txt(r,{Position=UDim2.fromOffset(14,22),Size=UDim2.new(1,w or -80,0,14),Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub}),dEn,dTh) end
 end

 function P.header(en,th,big)
  ord+=1
  local l=txt(sf,{LayoutOrder=ord,Size=UDim2.new(1,0,0,big and 22 or 16),Font=big and Enum.Font.GothamBlack or Enum.Font.GothamBold,TextSize=big and 17 or 10,TextColor3=big and Color3.new(1,1,1) or COL.Pink})
  if big then
   local g=make("UIGradient",{},l)
   NX.onAccent(function(a,b) g.Color=ColorSequence.new(a,b) end)
  end
  L(l,en,th)
 end

 function P.toggle(key,en,th,dEn,dTh)
  if S[key]==nil then S[key]=false end
  local r=row(42)
  titles(r,en,th,dEn,dTh)
  local sw=make("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-52,.5,-10),BackgroundColor3=COL.Bg},r)
  round(sw,10)
  local knob=make("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
  round(knob,7)
  local function set(v,doFire)
   S[key]=v
   TS:Create(sw,TI,{BackgroundColor3=v and COL.Purple or COL.Bg}):Play()
   TS:Create(knob,TI,{Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)}):Play()
   if doFire then fire(key,v) save() end
  end
  sw.MouseButton1Click:Connect(function() set(not S[key],true) end)
  set(S[key],false)
  NX.onAccent(function() sw.BackgroundColor3=S[key] and COL.Purple or COL.Bg end)
  UI[key]=set
  P.toggles[#P.toggles+1]=key
 end

 function P.slider(key,en,th,min,max,default,fmt)
  if S[key]==nil then S[key]=default end
  local r=row(50)
  titles(r,en,th,nil,nil,-90)
  local vl=txt(r,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,6),Size=UDim2.fromOffset(70,16),TextSize=11,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right})
  local track=make("Frame",{Position=UDim2.new(0,14,0,34),Size=UDim2.new(1,-28,0,6),BackgroundColor3=COL.Bg},r)
  round(track,3)
  local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=COL.Purple},track)
  round(fill,3)
  local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.new(1,1,1)},track)
  round(knob,7)
  NX.onAccent(function(a) fill.BackgroundColor3=a end)
  local hit=make("TextButton",{Text="",BackgroundTransparency=1,Position=UDim2.new(0,14,0,22),Size=UDim2.new(1,-28,0,26)},r)
  local function show(v)
   local t=math.clamp((v-min)/(max-min),0,1)
   fill.Size=UDim2.fromScale(t,1) knob.Position=UDim2.fromScale(t,.5)
   vl.Text=fmt and fmt(v) or tostring(v)
  end
  local function isPtr(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
  local function fromX(x)
   local t=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
   local v=min+(max-min)*t
   v=math.floor(v*100+.5)/100
   S[key]=v show(v)
   fire(key,v)
  end
  hit.InputBegan:Connect(function(i)
   if isPtr(i) then
    drag.cur={move=fromX,done=save}
    fromX(i.Position.X)
   end
  end)
  show(S[key])
 end

 -- opts = {{ค่า,"EN","ไทย"},...}
 function P.segmented(key,en,th,opts,default)
  if S[key]==nil then S[key]=default or opts[1][1] end
  local r=row(56)
  titles(r,en,th)
  local holder=make("Frame",{Position=UDim2.fromOffset(14,26),Size=UDim2.new(1,-28,0,24),BackgroundTransparency=1},r)
  make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},holder)
  local bs={}
  local function mark()
   for v,b in pairs(bs) do TS:Create(b,TI,{BackgroundColor3=(S[key]==v) and COL.Purple or COL.Bg}):Play() end
  end
  for _,o in ipairs(opts) do
   local b=make("TextButton",{Size=UDim2.new(1/#opts,-4,1,0),BackgroundColor3=COL.Bg,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Text,AutoButtonColor=false},holder)
   L(b,o[2],o[3])
   round(b,12)
   bs[o[1]]=b
   b.MouseButton1Click:Connect(function() S[key]=o[1] mark() fire(key,o[1]) save() end)
  end
  mark()
  NX.onAccent(function() mark() end)
 end

 -- รายการเลือก: multi=true เลือกได้หลายอัน (S[key] เป็นตาราง ชื่อ->true)
 function P.picker(key,en,th,opts,default,multi)
  if S[key]==nil then S[key]=multi and {} or (default or opts[1]) end
  if multi and type(S[key])~="table" then S[key]={} end
  local r=row(42)
  titles(r,en,th,nil,nil,-110)
  local vl=txt(r,{Position=UDim2.fromOffset(14,22),Size=UDim2.new(1,-110,0,14),Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub,TextTruncate=Enum.TextTruncate.AtEnd})
  local ob=make("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,8),Size=UDim2.fromOffset(84,26),BackgroundColor3=COL.Purple,Text="▼",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Color3.new(1,1,1),AutoButtonColor=false},r)
  round(ob,13)
  NX.onAccent(function(a) ob.BackgroundColor3=a end)
  local list=make("ScrollingFrame",{Position=UDim2.fromOffset(8,46),Size=UDim2.new(1,-16,0,130),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},r)
  make("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},list)
  local btns={}
  local O={}
  local opened=false
  local function summary()
   if multi then
    local names={}
    for k,v in pairs(S[key]) do if v then names[#names+1]=k end end
    table.sort(names)
    vl.Text=(#names==0) and T("(none = all)","(ไม่เลือก = ทั้งหมด)") or table.concat(names,", ")
   else
    vl.Text=tostring(S[key])
   end
  end
  local function mark()
   for name,bt in pairs(btns) do
    local on=multi and S[key][name] or ((not multi) and S[key]==name)
    bt.BackgroundColor3=on and COL.Purple or COL.Bg
   end
  end
  local function setOpen(v)
   opened=v
   TS:Create(r,TI,{Size=UDim2.new(1,0,0,v and 184 or 42)}):Play()
   ob.Text=v and "▲" or "▼"
  end
  local optList,built=opts,false
  local function buildBtns()
   built=true
   for _,b2 in pairs(btns) do b2:Destroy() end
   btns={}
   for i,name in ipairs(optList) do
    local bt=make("TextButton",{LayoutOrder=i,Size=UDim2.new(1,-6,0,24),BackgroundColor3=COL.Bg,Text=name,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Text,AutoButtonColor=false},list)
    round(bt,10)
    btns[name]=bt
    bt.MouseButton1Click:Connect(function()
     if multi then S[key][name]=(not S[key][name]) or nil
     else S[key]=name setOpen(false) end
     mark() summary() fire(key,S[key]) save()
    end)
   end
   mark()
  end
  function O.setOptions(newOpts)
   optList=newOpts
   for _,b2 in pairs(btns) do b2:Destroy() end
   btns={}
   built=false
   if opened then buildBtns() end
   summary()
  end
  ob.MouseButton1Click:Connect(function()
   if not opened and not built then buildBtns() end
   setOpen(not opened)
  end)
  summary()
  return O
 end

 function P.button(key,en,th,dEn,dTh,bEn,bTh)
  local r=row(42)
  L(txt(r,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,-110,0,16),TextSize=12}),en,th)
  L(txt(r,{Position=UDim2.fromOffset(14,22),Size=UDim2.new(1,-110,0,14),Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub,TextTruncate=Enum.TextTruncate.AtEnd}),dEn,dTh)
  local b=make("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(84,26),BackgroundColor3=COL.Purple,Text="",AutoButtonColor=false},r)
  round(b,13)
  NX.onAccent(function(a) b.BackgroundColor3=a end)
  local bl=L(txt(b,{Size=UDim2.fromScale(1,1),TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Center}),bEn,bTh)
  b.MouseButton1Click:Connect(function()
   fire(key,true)
   local o=bl.Text bl.Text="✔"
   task.delay(1,function() bl.Text=o end)
  end)
 end

 -- แถวแสดงสถานะ (คืนฟังก์ชันตั้งข้อความ)
 function P.status(en,th)
  local r=row(36)
  L(txt(r,{Position=UDim2.fromOffset(14,3),Size=UDim2.new(1,-28,0,14),Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub}),en,th)
  local v=txt(r,{Position=UDim2.fromOffset(14,17),Size=UDim2.new(1,-28,0,16),TextSize=11,TextColor3=COL.Pink,TextTruncate=Enum.TextTruncate.AtEnd})
  v.Text="-"
  return function(t) v.Text=t end
 end

 return P
end

------------------------------------------------------------------
-- ข้อมูลเกม (จากไฟล์ดัมพ์)
------------------------------------------------------------------
local BOSSES={"Walter Dog","Snow Tree","Sus Face","Gorilla King","Obamid","Pink Absorber","Giant Pumpkin","Evil Noob","Lord Sus","Meme Beast","Moai","Rick Roller","MrBeast","Super Popcat","Maxwell The Cat","Reverse Master"}
local BOSSSET={} for _,b in ipairs(BOSSES) do BOSSSET[b]=true end
local SEA_MOBS={["Killerfish"]=true,["Staring Fish"]=true}   -- สัตว์ทะเล (ปรับได้)
local RAID_BOSSES={"Meme Beast","Evil Noob","Giant Pumpkin","Lord Sus"}
local WEAPONS={"Katana","Flame Katana","Purple Katana","Yellow Blade","Pixel Sword","Floppa","Banana","Hanger","Pink Hammer","Pumpkin","Portal","Popcat","Bonk","Card"}
local POWERS={"Barrier Power","Bomb Power","Flame Power","Floppa Power","Fly Power","Invisible Power","Paw Power","Spin Power","Dark Power","Snow Power","Dog Power","Gold Power","Water Power","Ice Power","Sand Power","Moai Power","Dough Power","Diamond Power"}
local ITEMS={"Cat Food","Awakening Orb","Cheems Cola","Quest Scroll","Ball","Meme Cube","Flame Orb","Noob Head","Sussy Orb","Money Bag"}
local HAKI={"FlashStep","Aura","Instinct"}
local ACCESSORIES={"Floppa Head","Floppa Hat","Egg Doge","Sus Face","Giant Banana","Obamid","Moai Face","MrBeast","Noob Friend","Rick Buddy","Pumpkin Head","Sus Pals","Floppa Pet","Popcat Pet"}
-- ของสวมใส่ -> มอนที่ดรอป (เดาจากชื่อ แก้ได้ถ้าไม่ตรง)
local DROP_MAP={["Floppa Head"]="Big Floppa",["Floppa Hat"]="Golden Floppa",["Egg Doge"]="Egg Dog",["Sus Face"]="Sus Face",["Giant Banana"]="Banana Cat",["Obamid"]="Obamid",["Moai Face"]="Moai",["MrBeast"]="MrBeast",["Noob Friend"]="Evil Noob",["Rick Buddy"]="Rick Roller",["Pumpkin Head"]="Giant Pumpkin",["Sus Pals"]="Lord Sus",["Floppa Pet"]="Floppa",["Popcat Pet"]="Popcat"}
-- ถ้ารู้ว่าบอสตัวไหนรับเควสจาก NPC ชื่ออะไร ใส่ตรงนี้ เช่น ["Gorilla King"]="Floppa Quest 12"
local BOSS_QUEST={}
local STAT_ROWS={"Health","Melee","Power","Sword"}   -- แถวในหน้า Stats ของเกม
local ISLANDS={"Spawn","Floppa Island","Sand Island","Snow Island","Moai Island","Pumpkin Island","Gorilla Island","Sus Island","Sus Mountain","MrBeast Island","Forgotten Island","Noob Arena","Pvp Arena","Heaven"}
local KEYS={"Z","X","C","V","F","G","B"}
local WEAR_LIST={"Egg Doge","Floppa Hat","Obamid","Sus Face","Giant Banana","Popcat Pet","Rick Buddy","Moai Face","MrBeast","Noob Friend","Sus Pals","Pumpkin Head"}
local WEAR_LABEL={MrBeast="Mr Beast"}
local function accKey(n) return "acc_"..(n:lower():gsub("[^%w]+","_")) end
local STYLES={"Baller"}
local DEFAULT_SKILL={Z=true,X=true,C=true,V=true}   -- ไม่รวม F (บินของ Dog Power)
-- บอสที่ต้องเสกที่แท่น (ข้อมูลจากแท่น Summon ในเกม)
local SUMMON_BOSS={
 ["Evil Noob"]={item="Noob Head",island="Moai Island"},
 ["Giant Pumpkin"]={item="Flame Orb",island="Pumpkin Island"},
 ["Lord Sus"]={item="Sussy Orb",island="Forgotten Island"},
}
local SUMMON_LIST={"Evil Noob","Giant Pumpkin","Lord Sus"}
local NORMAL_BOSSES={}
for _,n in ipairs(BOSSES) do
 if not SUMMON_BOSS[n] and n~="Meme Beast" then NORMAL_BOSSES[#NORMAL_BOSSES+1]=n end
end

------------------------------------------------------------------
-- ตัวช่วยโลกเกม
------------------------------------------------------------------
local function path(o,...)
 for _,n in ipairs({...}) do o=o and o:FindFirstChild(n) end
 return o
end
local function root() local c=lp.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c=lp.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function alive() local h=hum() return h~=nil and h.Health>0 end
local function pd(n) local f=lp:FindFirstChild("PlayerData") local v=f and f:FindFirstChild(n) return v and v.Value end
local function notify(title,text)
 pcall(function() StarterGui:SetCore("SendNotification",{Title=title,Text=text,Duration=6}) end)
end
task.defer(function()
 local n=0
 for _ in pairs(S) do n+=1 end
 notify("Nexora",T("Settings loaded: ","โหลดการตั้งค่าแล้ว: ")..n)
 if not writefile then notify("Nexora",T("Executor cannot save settings","executor ไม่รองรับ writefile ตั้งค่าจะไม่ถูกบันทึก")) end
end)
if not S.mig_v5 then S.atk_click=false S.mig_v5=true end
if S.aim_cam==nil then S.aim_cam=true end
if type(S.sea_pick)~="table" or next(S.sea_pick)==nil then S.sea_pick={["Meme Beast"]=true} end
local function setCF(cf)
 local r=root()
 if r then
  r.CFrame=cf
  r.AssemblyLinearVelocity=Vector3.zero
  r.AssemblyAngularVelocity=Vector3.zero
 end
end
local function partOf(o)
 if not o then return nil end
 if o:IsA("BasePart") then return o end
 if o:IsA("Model") then return o.PrimaryPart or o:FindFirstChild("HumanoidRootPart") or o:FindFirstChildWhichIsA("BasePart",true) end
 return o:FindFirstChildWhichIsA("BasePart",true)
end
local function dist(p)
 local r=root()
 return (r and p) and (r.Position-p.Position).Magnitude or math.huge
end

-- กดปุ่ม GUI ด้วยการเรียกสัญญาณที่เกมผูกไว้ (ไม่ต้องรู้ชื่อ Remote)
local function press(b)
 if not b then return false end
 local ok=false
 for _,sig in ipairs({"MouseButton1Click","Activated","MouseButton1Down","MouseButton1Up"}) do
  pcall(function()
   if getconnections then
    for _,c in ipairs(getconnections(b[sig])) do c:Fire() ok=true end
   end
  end)
  if ok then break end
 end
 if not ok then pcall(function() if firesignal then firesignal(b.MouseButton1Click) ok=true end end) end
 return ok
end
local function shown(o)
 while o and o~=game do
  if o:IsA("GuiObject") and not o.Visible then return false end
  if o:IsA("ScreenGui") and not o.Enabled then return false end
  o=o.Parent
 end
 return true
end
local function btnByText(rootObj,words)
 if not rootObj then return nil end
 for _,d in ipairs(rootObj:GetDescendants()) do
  if d:IsA("GuiButton") and shown(d) then
   local s=(d:IsA("TextButton") and d.Text or ""):lower()..d.Name:lower()
   for _,c in ipairs(d:GetDescendants()) do if c:IsA("TextLabel") then s=s..c.Text:lower() end end
   for _,w in ipairs(words) do if s:find(w,1,true) then return d end end
  end
 end
end
local function pgui() return lp:FindFirstChild("PlayerGui") end
local function pressProx(pp)
 if not pp then return false end
 pcall(function() pp.HoldDuration=0 pp.MaxActivationDistance=40 pp.RequiresLineOfSight=false end)
 if fireproximityprompt then
  local ok=pcall(fireproximityprompt,pp)
  return ok
 end
 return false
end

-- ลูปเปิด/ปิดตามสวิตช์
local running={}
local function loop(key,interval,fn)
 Features[key]=function(v)
  if not v then running[key]=nil return end
  if running[key] then return end
  local token={}
  running[key]=token
  while running[key]==token and S[key] do
   local ok,e=pcall(fn)
   if not ok then warn("[Nexora] "..key..": "..tostring(e)) end
   task.wait(interval)
  end
  if running[key]==token then running[key]=nil end
 end
end
-- โหมดฟาร์ม: เปิดอันหนึ่ง อันอื่นปิดเอง
local MODES={"aura","farm_level","farm_near","farm_boss","farm_sea","farm_summon","farm_item","race_quest","race_orb","race_reroll","roll_power","quest_sel","pvp_hunt"}
for _,a in ipairs(WEAR_LIST) do MODES[#MODES+1]=accKey(a) end
local function only(key)
 for _,k in ipairs(MODES) do
  if k~=key and S[k] then
   if UI[k] then UI[k](false,true) else S[k]=false fire(k,false) end
  end
 end
end
local releaseTarget=function() end
local function modeLoop(key,interval,fn)
 loop(key,interval,fn)
 local base=Features[key]
 Features[key]=function(v)
  if v then only(key) else releaseTarget() end
  base(v)
 end
end

------------------------------------------------------------------
-- อาวุธ / โจมตี / สกิล
------------------------------------------------------------------
local EQUIP_KEY={fist="CombatEquip",sword="SwordEquip",power="PowerEquip"}
local lastEquip=0
local function equipSelected(kind)
 local c=lp.Character
 if not c then return end
 local name=pd(EQUIP_KEY[kind or S.weapon_kind or "fist"])
 if not name or name=="" then return end
 if c:FindFirstChild(name) then return end
 if os.clock()-lastEquip<1 then return end
 lastEquip=os.clock()
 local tool=lp.Backpack:FindFirstChild(name)
 local h=hum()
 if tool and h then pcall(function() h:EquipTool(tool) end) end
end
local function tapKey(k)
 local kc=Enum.KeyCode[k]
 if not kc then return end
 pcall(function()
  VIM:SendKeyEvent(true,kc,false,game)
  task.wait(.03)
  VIM:SendKeyEvent(false,kc,false,game)
 end)
end
local function skillContainer()
 local c=lp.Character
 local tool=c and c:FindFirstChildOfClass("Tool")
 local g=pgui()
 if not tool or not g then return nil end
 for _,n in ipairs({"Power","Weapon","FightingStyle"}) do
  local sg=g:FindFirstChild(n)
  if sg and sg:GetAttribute("Tool")==tool.Name then return sg:FindFirstChild("Skill_Container") end
 end
end
local function castSkills(set)
 local none=(set==nil) or next(set)==nil
 local cont=skillContainer()
 for _,k in ipairs(KEYS) do
  local want=none and DEFAULT_SKILL[k] or (set and set[k])
  if want then
   local fr=cont and cont:FindFirstChild(k)
   if fr then
    if fr:GetAttribute("Cooldown")~=true then
     local btn=fr:FindFirstChild(k,true)
     if not (btn and press(btn)) then tapKey(k) end
    end
   elseif not cont then
    tapKey(k)
   end
  end
 end
end

------------------------------------------------------------------
-- มอนสเตอร์ / เป้าหมาย
------------------------------------------------------------------
local function norm(s) return (tostring(s):lower():gsub("[%s_%-]","")) end
local function nameMatches(modelName,target)
 local a,b2=norm(modelName),norm(target)
 return a==b2 or (#b2>2 and a:find(b2,1,true)~=nil) or (#a>2 and b2:find(a,1,true)~=nil)
end
local function isDummy(m)
 local n=m.Name:lower()
 return n=="training log" or n:find("training",1,true)~=nil or n:find("dummy",1,true)~=nil
end
local function aliveMobs(filter)
 local out={}
 local f=WS:FindFirstChild("Monster")
 if f then
  for _,m in ipairs(f:GetChildren()) do
   local h=m:FindFirstChildOfClass("Humanoid")
   local r=m:FindFirstChild("HumanoidRootPart")
   if h and r and h.Health>0 and (S.hit_dummy or not isDummy(m)) and ((not filter) or filter(m)) then out[#out+1]=m end
  end
 end
 return out
end
local function closest(list)
 local r=root()
 if not r then return nil end
 local best,bd
 for _,m in ipairs(list) do
  local p=m:FindFirstChild("HumanoidRootPart")
  if p then
   local d=(p.Position-r.Position).Magnitude
   if not bd or d<bd then best,bd=m,d end
  end
 end
 return best,bd
end
-- ล็อกกล้องไปที่เป้าหมาย ให้สกิลที่เล็งตามกล้อง/เมาส์โดนตัวจริง
local Ctl={target=nil,kind=nil,stamp=0}
local offCache=setmetatable({},{__mode="k"})
local HOVER_GAP=4   -- ลอยเหนือหัวกี่ studs (ปรับที่นี่)
local lastHit,lastEq=0,0
local function ctlActive()
 local t=Ctl.target
 return t~=nil and t.Parent~=nil and os.clock()-Ctl.stamp<.45
end
releaseTarget=function() Ctl.target=nil end
-- โหมดต่างๆ เรียก engage ทุกรอบเพื่อ "ต่ออายุ" เป้าหมาย: ปิดโหมดเมื่อไหร่ ตัวควบคุมหยุดตีภายใน 0.45 วิ
local function engage(m,kind)
 Ctl.target=m Ctl.kind=kind Ctl.stamp=os.clock()
end
-- เลือกเป้าหมายแบบล็อก: ถ้าเป้าเดิมยังไม่ตายและตรงเงื่อนไข ก็ตีตัวเดิมต่อ (ไม่เที่ยวเปลี่ยนตัว)
local function sticky(filter)
 local t=Ctl.target
 if t and t.Parent then
  local h=t:FindFirstChildOfClass("Humanoid")
  if h and h.Health>0 and ((not filter) or filter(t)) then return t end
 end
 return (closest(aliveMobs(filter)))
end
local function hoverOn(model)
 local mr=model:FindFirstChild("HumanoidRootPart")
 if not mr then return end
 local off=offCache[model]
 if not off then
  local ok,cf,size=pcall(function() return model:GetBoundingBox() end)
  off=ok and math.max(1.5,(cf.Position.Y+size.Y/2)-mr.Position.Y) or 3
  offCache[model]=off
 end
 local p=mr.Position
 setCF(CFrame.lookAt(Vector3.new(p.X,p.Y+off+HOVER_GAP,p.Z),p+Vector3.new(0,0,.3)))
end
conns[#conns+1]=RunS.Heartbeat:Connect(function()
 if not ctlActive() then return end
 local m=Ctl.target
 local h=m:FindFirstChildOfClass("Humanoid")
 if not h or h.Health<=0 then Ctl.target=nil return end
 if not alive() then return end
 hoverOn(m)
 local now=os.clock()
 local c=lp.Character
 local t=c and c:FindFirstChildOfClass("Tool")
 local cd=math.clamp((t and t:GetAttribute("Attack_Cooldown")) or .2,.1,1)
 if now-lastHit>=cd then
  lastHit=now
  if now-lastEq>.5 then lastEq=now equipSelected(Ctl.kind) end
  if t then pcall(function() t:Activate() end) end
  if S.atk_click and not NX.isOpen() then
   pcall(function()
    local vp=WS.CurrentCamera.ViewportSize
    VIM:SendMouseButtonEvent(vp.X*.5,vp.Y*.5,0,true,game,1)
    VIM:SendMouseButtonEvent(vp.X*.5,vp.Y*.5,0,false,game,1)
   end)
  end
 end
end)
-- ล็อกกล้องไปที่เป้าหมาย ให้สกิลที่เล็งตามกล้องโดนตัวจริง
RunS:BindToRenderStep("NexoraAim",Enum.RenderPriority.Camera.Value+1,function()
 if S.aim_cam==false or not ctlActive() then return end
 local cam=WS.CurrentCamera
 local p=Ctl.target:FindFirstChild("HumanoidRootPart")
 if cam and p then cam.CFrame=CFrame.lookAt(cam.CFrame.Position,p.Position) end
end)
local function goSpawn(name)
 local f=path(WS,"Location","Enemy_Location")
 local loc=f and f:FindFirstChild(name)
 if f and not loc then
  for _,p in ipairs(f:GetChildren()) do if nameMatches(p.Name,name) then loc=p break end end
 end
 if loc and dist(loc)>60 then
  setCF(CFrame.new(loc.Position+Vector3.new(0,6,0)))
  return true
 end
 return loc~=nil
end
local function farmNames(names)
 if not alive() then return false end
 local m=sticky(function(x) return names[x.Name] end)
 if m then engage(m) return true end
 for n in pairs(names) do if goSpawn(n) then break end end
 return false
end

------------------------------------------------------------------
-- เควส (ตรวจจาก QuestFolder + ProximityPrompt ของ NPC)
------------------------------------------------------------------
local function slots()
 local out={}
 local qf=lp:FindFirstChild("QuestFolder")
 if qf then
  for _,s in ipairs(qf:GetChildren()) do
   local t=s:FindFirstChild("Target")
   local a=s:FindFirstChild("Amount")
   local n=s:FindFirstChild("Need")
   local g=s:FindFirstChild("QuestGiver")
   if t and t.Value~="" and t.Value~="None" then
    out[#out+1]={target=t.Value,amount=a and a.Value or 0,need=n and n.Value or 1,giver=g and g.Value or ""}
   end
  end
 end
 return out
end
local function questNpc(name)
 return path(WS,"NPCs","Quests_Npc",name)
end
local function goTalk(name)
 if not name or name=="" then return false end
 local npc=questNpc(name)
 if not npc then
  local loc=path(WS,"Location","QuestLocaion",name)
  if loc then
   setCF(CFrame.new(loc.Position+Vector3.new(0,4,0)))
   local t=0
   while not questNpc(name) and t<4 do task.wait(.2) t+=.2 end
   npc=questNpc(name)
  end
 end
 local pp=npc and npc:FindFirstChildWhichIsA("ProximityPrompt",true)
 if not pp then return false end
 local part=pp.Parent:IsA("BasePart") and pp.Parent or partOf(npc)
 if part then setCF(part.CFrame+Vector3.new(0,3,0)) end
 task.wait(.25)
 pressProx(pp)
 return true
end
local function pressAccept()
 local b=btnByText(path(pgui(),"QuestGui"),{"accept","yes","confirm","claim"})
 if b then press(b) end
end
local lastTurn=0
local QUEST_FALLBACK={[1]=1,[2]=50,[3]=100}
for n=4,32 do QUEST_FALLBACK[n]=150+(n-4)*50 end
for n=33,46 do QUEST_FALLBACK[n]=1700+(n-33)*50 end
local questLevelCache
local function questLevels()
 if questLevelCache then return questLevelCache end
 local t={}
 local g=pgui()
 local gg=g and g:FindFirstChild("GameGui")
 local qt=gg and gg:FindFirstChild("Quest_Tracker",true)
 local cont=qt and qt.Parent:FindFirstChild("Container")
 if cont then
  for _,f in ipairs(cont:GetChildren()) do
   local n=f.Name:match("^Floppa Quest (%d+)$")
   local lv=f:GetAttribute("NeededLevel")
   if n and type(lv)=="number" then t[tonumber(n)]=lv end
  end
 end
 for n,lv in pairs(QUEST_FALLBACK) do if t[n]==nil then t[n]=lv end end
 questLevelCache=t
 return t
end
local function bestQuestFor(level)
 local best,bl
 for n,lv in pairs(questLevels()) do
  if lv<=level and (not bl or lv>bl or (lv==bl and n>best)) then best,bl=n,lv end
 end
 return best,bl
end
local function waitSlot(sec)
 local t=0
 while t<sec do
  if #slots()>0 then return true end
  task.wait(.25) t+=.25
 end
 return false
end
local blockedUntil=0
local function acceptQuest(status)
 local lvl=pd("Level")
 if not lvl then
  if status then status(T("Level not found - export game data","ไม่พบเลเวล - กดส่งออกข้อมูลเกม")) end
  blockedUntil=os.clock()+20
  return false
 end
 local n,need=bestQuestFor(lvl)
 if not n then
  if status then status(T("No quest for this level","ยังไม่มีเควสสำหรับเลเวลนี้")) end
  blockedUntil=os.clock()+20
  return false
 end
 for _,q in ipairs({n,n-1}) do
  if #slots()>0 then return true end   -- มีเควสแล้ว ห้ามรับซ้ำ
  if q>=1 and path(WS,"Location","QuestLocaion","Floppa Quest "..q) then
   if status then status("Lv "..lvl.."  →  Floppa Quest "..q.." (Lv "..tostring(questLevels()[q] or "?")..")") end
   goTalk("Floppa Quest "..q)
   task.wait(.4)
   pressAccept()
   if waitSlot(2.5) then
    local s=slots()[1]
    if s and s.giver~="" and s.giver~="Floppa Quest "..q and status then status("⚠ "..s.giver) end
    return true
   end
  end
 end
 blockedUntil=os.clock()+20
 if status then status(T("Could not take quest ","รับเควสไม่สำเร็จ ")..n) end
 return false
end
-- ทำเควส 1 รอบ: รับ -> ฟาร์มเป้าหมาย -> ส่ง  (npcName=nil = เลือกตามเลเวลอัตโนมัติ)
local function questStep(npcName,status)
 if not alive() then return end
 local ss=slots()
 if #ss==0 then
  if os.clock()<blockedUntil then
   -- เลเวลยังไม่ถึง: ตีมอนใกล้ตัวระหว่างรอ แล้วลองรับเควสใหม่
   if not npcName then
    local m=sticky(function(x) return not BOSSSET[x.Name] end)
    if m then engage(m) end
   end
   return
  end
  if npcName then
   local nn=tonumber((npcName):match("^Floppa Quest (%d+)$"))
   local need=nn and questLevels()[nn]
   local lvl=pd("Level") or 0
   if need and lvl<need then
    if status then status(T("Need level ","ต้องเลเวล ")..need.."  (Lv "..lvl..")") end
    return
   end
   if status then status(T("Taking quest...","กำลังรับเควส...")) end
   goTalk(npcName) task.wait(.4) pressAccept()
   if not waitSlot(2.5) then
    blockedUntil=os.clock()+15
    if status then status(T("Cannot take this quest (level?)","รับเควสนี้ไม่ได้ (เลเวลไม่พอ?)")) end
   end
  else
   acceptQuest(status)
  end
  return
 end
 local pick
 for _,s in ipairs(ss) do if s.amount<s.need then pick=s break end end
 if not pick then
  if os.clock()-lastTurn>3 then
   lastTurn=os.clock()
   if status then status(T("Turning in quest","กำลังส่งเควส")) end
   goTalk(ss[1].giver~="" and ss[1].giver or npcName)
   task.wait(.8) pressAccept()
  end
  return
 end
 if status then status("Lv "..tostring(pd("Level") or "?").."  "..pick.target.."  "..pick.amount.."/"..pick.need) end
 local m=sticky(function(x) return nameMatches(x.Name,pick.target) end)
 if m then engage(m) else
  if not goSpawn(pick.target) then
   local any=sticky(function(x) return not BOSSSET[x.Name] end)
   if any then engage(any) end
  end
 end
end

------------------------------------------------------------------
-- ESP
------------------------------------------------------------------
local EGP=(gethui and gethui()) or game:GetService("CoreGui")
local espObjs={}
local function espClear(key)
 local t=espObjs[key]
 if t then
  for _,e in pairs(t) do pcall(function() e.gui:Destroy() end) pcall(function() e.hl:Destroy() end) end
 end
 espObjs[key]=nil
end
local function espUpdate(key,items,color)
 local t=espObjs[key] or {}
 espObjs[key]=t
 local seen={}
 for _,it in ipairs(items) do
  local inst=it.inst
  local part=partOf(inst)
  if inst and inst.Parent and part then
   seen[inst]=true
   local e=t[inst]
   if not e then
    local gui=make("BillboardGui",{Name="NXEsp",AlwaysOnTop=true,Size=UDim2.fromOffset(160,28),StudsOffset=Vector3.new(0,3,0),Adornee=part},EGP)
    local lbl=make("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=color,TextStrokeTransparency=.3},gui)
    local hl=make("Highlight",{FillColor=color,OutlineColor=color,FillTransparency=.75,Adornee=inst:IsA("Model") and inst or part},EGP)
    e={gui=gui,hl=hl,lbl=lbl}
    t[inst]=e
   end
   local s=it.label
   if S.esp_dist then s=s.."  ["..math.floor(dist(part)).."m]" end
   e.lbl.Text=s
  end
 end
 for inst,e in pairs(t) do
  if not seen[inst] then
   pcall(function() e.gui:Destroy() end) pcall(function() e.hl:Destroy() end)
   t[inst]=nil
  end
 end
end
local chestCache,chestAt={},0
local ESPS={
 esp_player={Color3.fromRGB(255,80,110),function()
  local o={}
  for _,p in ipairs(Players:GetPlayers()) do
   if p~=lp and p.Character then o[#o+1]={inst=p.Character,label=p.Name} end
  end
  return o end},
 esp_npc={Color3.fromRGB(90,230,160),function()
  local o={}
  local f=WS:FindFirstChild("NPCs")
  if f then
   for _,g in ipairs(f:GetChildren()) do
    for _,n in ipairs(g:GetChildren()) do if n:IsA("Model") then o[#o+1]={inst=n,label=n.Name} end end
   end
  end
  return o end},
 esp_fruit={Color3.fromRGB(255,200,80),function()
  local o={}
  local f=path(WS,"SpawningPower","Spawned_Powers")
  if f then for _,c in ipairs(f:GetChildren()) do o[#o+1]={inst=c,label="⚡ "..c.Name} end end
  return o end},
 esp_chest={Color3.fromRGB(255,170,40),function()
  if os.clock()-chestAt>60 then
   chestAt=os.clock() chestCache={}
   local isl=WS:FindFirstChild("Island")
   for _,d in ipairs(isl and isl:GetDescendants() or {}) do
    if (d:IsA("Model") or d:IsA("BasePart")) and d.Name:lower():find("chest",1,true) then chestCache[#chestCache+1]={inst=d,label="📦 "..d.Name} end
   end
  end
  return chestCache end},
 esp_item={Color3.fromRGB(120,200,255),function()
  local o={}
  local f=WS:FindFirstChild("Dropped_Items")
  if f then for _,c in ipairs(f:GetChildren()) do o[#o+1]={inst=c,label=c.Name} end end
  return o end},
 esp_boss={Color3.fromRGB(215,125,255),function()
  local o={}
  for _,m in ipairs(aliveMobs(function(x) return BOSSSET[x.Name] end)) do o[#o+1]={inst=m,label="👑 "..m.Name} end
  return o end},
}

------------------------------------------------------------------
-- สร้างหน้า
------------------------------------------------------------------
local pageList={}

-- ======================= ฟาร์ม =======================
local SEA_OPTS={}
for _,n in ipairs(BOSSES) do SEA_OPTS[#SEA_OPTS+1]=n end
for _,n in ipairs({"Capybara","The Stone","Killer Nugget","Epic Doge","Speedy Cheems","Tanky Moai","Killerfish","Staring Fish"}) do SEA_OPTS[#SEA_OPTS+1]=n end
local setBossStatus,setRaidStatus,setTimerStatus,setFarmStatus
do
 local P=build("farm") pageList[#pageList+1]=P
 P.header("FARM","ฟาร์ม",true)

 P.header("KILL AURA","ตีออร่า")
 P.toggle("aura","Kill aura (0.1s)","ตีออร่า (ทุก 0.1 วิ)","Hover above the head and hit what is in range","ลอยเหนือหัวมอนแล้วตีทุกตัวในระยะ")
 P.slider("aura_range","Aura range","ระยะออร่า",10,150,40,function(v) return math.floor(v).." studs" end)
 P.toggle("reach","Long range hit","ตีระยะไกล","Enlarge the weapon hitbox","ขยายฮิตบ็อกซ์ของอาวุธ")
 P.slider("reach_size","Reach size","ขนาดระยะ",4,40,15,function(v) return math.floor(v).."" end)

 P.header("WEAPON","อาวุธ")
 P.segmented("weapon_kind","Attack with","ใช้อะไรตี",{{"fist","Fist","หมัด"},{"power","Power","ผล"},{"sword","Sword","ดาบ"}},"fist")
 P.toggle("aim_cam","Aim camera at target","ล็อกกล้องไปที่เป้าหมาย","Helps skills hit. Turn off to look around freely","ช่วยให้สกิลโดน ปิดถ้าอยากหมุนกล้องเอง")
 P.toggle("atk_click","Simulated click","คลิกจำลอง","Interferes with scrolling game menus. Only if attacks do nothing","จะรบกวนการเลื่อนเมนูในเกม เปิดเฉพาะเมื่อตีไม่ออก")
 P.picker("sea_pick","Sea boss","เลือกเจ้าทะเล (ไม่เลือก = หาเอง)",SEA_OPTS,nil,true)
 P.toggle("farm_sea","Auto sea boss (Meme Beast)","ตีเจ้าทะเล (Meme Beast)","Spawns randomly in the sea every ~30 min. Drops Meme Cube (50%) and Portal","เกิดสุ่มกลางทะเลทุก ~30 นาที ดรอป Meme Cube (50%) และ Portal")

 P.header("STATS","อัปสเต็ก")
 P.picker("stat_pick","Stats to upgrade","เลือกสเต็กที่จะอัป",STAT_ROWS,nil,true)
 P.toggle("stat_auto","Auto upgrade stats","อัปสเต็กอัตโนมัติ","Pick several = split evenly, one = focus","เลือกหลายอัน = แบ่งเท่าๆ กัน, เลือกอันเดียว = เน้นอันเดียว")

 P.header("AUTO FARM","ออโต้ฟาร์ม")
 setFarmStatus=P.status("Farm status","สถานะฟาร์ม")
 P.toggle("farm_level","Auto farm level","ฟาร์มเลเวลอัตโนมัติ","Takes only your current main quest, farms its target, turns in","รับเฉพาะเควสหลักของเลเวลตัวเอง ฟาร์มเป้าหมาย แล้วส่งเควส")
 P.toggle("farm_near","Farm nearest mob","ฟาร์มมอนที่ใกล้ที่สุด","Attack the closest monster","ตีมอนสเตอร์ที่ใกล้ตัวที่สุด")
 P.toggle("hit_dummy","Hit training logs","ตีหุ่นไม้ (Training Log)","Off = wooden dummies are skipped","ปิด = ข้ามหุ่นไม้")
 P.header("BOSS","บอสที่เกิดเอง")
 P.picker("boss_pick","Boss","เลือกบอส",NORMAL_BOSSES,NORMAL_BOSSES[1],false)
 P.toggle("farm_boss","Auto boss","ออโต้ตีบอส","Wait at spawn, fight the boss when it appears","รอที่จุดเกิด ตีบอสเมื่อบอสเกิด")
 P.toggle("farm_boss_quest","Do boss quest","ทำเควสบอสด้วย","Use the quest while fighting (needs BOSS_QUEST set or active quest)","ทำเควสควบคู่ (ต้องมีเควสค้างหรือกำหนด BOSS_QUEST)")
 P.header("SUMMON BOSS","บอสที่ต้องเสก")
 P.picker("summon_pick","Boss to summon","เลือกบอสที่จะเสก",SUMMON_LIST,SUMMON_LIST[1],false)
 P.toggle("farm_summon","Auto summon + fight","เสกบอสและตีอัตโนมัติ","Evil Noob = Noob Head, Giant Pumpkin = Flame Orb, Lord Sus = Sussy Orb. Finds the item if missing","Evil Noob = Noob Head, Giant Pumpkin = Flame Orb, Lord Sus = Sussy Orb ถ้าไม่มีของจะไปหามาให้")
 P.header("FIND ITEM","หาไอเทม")
 P.picker("item_pick","Item to find","เลือกไอเทมที่ต้องการ",ITEMS,ITEMS[1],false)
 P.slider("item_want","Amount wanted","จำนวนที่ต้องการ",1,50,1,function(v) return math.floor(v).."" end)
 P.toggle("farm_item","Auto find item","หาไอเทมอัตโนมัติ","Buys it, or farms the monster that drops it","ซื้อ หรือไปตีมอนที่ดรอปของนั้น")

 P.header("SKILLS","สกิล")
 P.toggle("skill_auto","Auto skill","ใช้สกิลอัตโนมัติ","Press skill keys repeatedly","กดปุ่มสกิลต่อเนื่อง")
 P.picker("skill_keys","Skill keys","ปุ่มสกิล",KEYS,nil,true)
 P.toggle("auto_haki","Auto Aura haki","ออโต้เปิดฮาคิออร่า","Keeps Aura haki on while you own it","เปิดฮาคิออร่าค้างไว้ถ้ามีฮาคินี้แล้ว")
 P.toggle("pickup_near","Auto pickup drops","เก็บของดรอปอัตโนมัติ","Picks up drops within 30 studs","เก็บของที่ตกใกล้ๆ (ภายใน 30 studs)")

 P.header("BOSS & RAID","บอสและเรด")
 P.toggle("esp_boss","Boss ESP","Boss ESP","Show boss position","แสดงตำแหน่งบอส")
 P.toggle("boss_track","Boss Tracker","Boss Tracker","Track alive bosses","ติดตามบอสที่เกิดอยู่")
 setBossStatus=P.status("Bosses alive","บอสที่เกิดอยู่")
 P.toggle("boss_alert","Auto Boss Alert","Auto Boss Alert","Alert when a boss is close (200 studs)","เตือนเมื่อบอสอยู่ใกล้ (200 studs)")
 P.toggle("boss_spawn_notif","Boss Spawn Notification","Boss Spawn Notification","Notify when a boss spawns","แจ้งเตือนเมื่อบอสเกิด")
 P.toggle("raid_track","Raid Tracker","Raid Tracker","Raid state, wave and players","สถานะเรด เวฟ และจำนวนผู้เล่น")
 setRaidStatus=P.status("Raid","เรด")
 P.toggle("raid_timer","Raid Timer","Raid Timer","Show raid time left","แสดงเวลาที่เหลือของเรด")
 setTimerStatus=P.status("Raid time","เวลาเรด")

 P.header("DEBUG","เก็บข้อมูลให้ผู้พัฒนา")
 P.button("dump_modules","Export game data","ส่งออกข้อมูลเกม","Player data, quests, mobs, tables to NexoraDump.txt","ข้อมูลผู้เล่น เควส มอน ตาราง -> NexoraDump.txt","Export","ส่งออก")
 P.button("dump_gui","Export GUI text","ส่งออกข้อความ GUI","Shop / quest / raid texts to NexoraGui.txt","ข้อความร้านค้า/เควส/เรด -> NexoraGui.txt","Export","ส่งออก")
 P.toggle("remote_log","Record remotes","บันทึก Remote","Do each action once, then turn off. Saves NexoraRemoteLog.txt","ทำแต่ละอย่างหนึ่งครั้งแล้วปิด บันทึกลง NexoraRemoteLog.txt")
end

-- ======================= ซื้อ =======================
local setBuyStatus,setRollStatus
do
 local P=build("buy") pageList[#pageList+1]=P
 P.header("BUY","ซื้อ",true)
 setBuyStatus=P.status("Buy status","สถานะการซื้อ")
 P.header("ROLL POWER","สุ่มผล (Gacha)")
 setRollStatus=P.status("Roll status","สถานะการสุ่ม")
 P.picker("roll_npc","Gacha NPC","เลือกตู้สุ่ม",{"Floppa Gacha","Doge Gacha"},"Floppa Gacha",false)
 P.picker("roll_want","Stop when you get","หยุดเมื่อได้",POWERS,nil,true)
 P.slider("roll_delay","Delay between rolls","หน่วงเวลาระหว่างสุ่ม",1,10,2,function(v) return v.."s" end)
 P.slider("roll_max","Max rolls","สุ่มสูงสุดกี่ครั้ง",1,1000,100,function(v) return math.floor(v).."" end)
 P.toggle("roll_power","Auto roll power","ออโต้สุ่มผล","Rolls until you get a wanted power (costs in-game currency)","สุ่มจนได้ผลที่เลือก (เสียเงินในเกม)")
 P.header("FIGHTING STYLE","สไตล์การต่อสู้")
 P.picker("buy_style_pick","Styles","เลือกสไตล์",STYLES,nil,true)
 P.toggle("buy_style","Auto learn fighting style","เรียนสไตล์อัตโนมัติ","Talks to Maxwell for the selected style","คุยกับ Maxwell เพื่อเรียนสไตล์ที่เลือก")
 P.header("AUTO BUY","ซื้ออัตโนมัติ")
 P.picker("buy_item_pick","Items","เลือกไอเทม",ITEMS,nil,true)
 P.toggle("buy_items","Auto Buy Items","Auto Buy Items","Buy the selected items","ซื้อไอเทมที่เลือกอัตโนมัติ")
 P.picker("buy_weapon_pick","Weapons","เลือกอาวุธ",WEAPONS,nil,true)
 P.toggle("buy_weapons","Auto Buy Weapons","Auto Buy Weapons","Buy the selected weapons you don't own","ซื้ออาวุธที่เลือกและยังไม่มี")
 P.picker("buy_power_pick","Powers (fruits)","เลือกผลปีศาจ (Power)",POWERS,nil,true)
 P.toggle("buy_fruits","Auto Buy Fruits","Auto Buy Fruits","Buy the selected powers you don't own","ซื้อผล/พลังที่เลือกและยังไม่มี")
 P.picker("buy_haki_pick","Haki / abilities","เลือกฮาคิ",HAKI,nil,true)
 P.toggle("buy_haki","Auto Buy Haki","ซื้อฮาคิอัตโนมัติ","FlashStep / Aura / Instinct","FlashStep / Aura / Instinct")
 P.header("CHECK","ตรวจสอบ")
 P.slider("buy_interval","Check every","ตรวจสินค้าทุก",5,120,20,function(v) return math.floor(v).."s" end)
 P.toggle("buy_restock","Auto Restock Check","Auto Restock Check","Re-check shops every interval","ตรวจร้านซ้ำตามช่วงเวลา")
 P.toggle("buy_alert","Auto Purchase Alert","Auto Purchase Alert","Notify after a purchase","แจ้งเตือนเมื่อซื้อสำเร็จ")
 P.header("DROPPED POWERS","ผลที่ตกพื้น/เกิดในแมพ")
 P.picker("pw_pick","Powers to grab","ผลที่จะเก็บ",POWERS,nil,true)
 P.toggle("pw_grab","Warp to spawned power","วาร์ปไปเก็บผลทันที","Go grab a power the moment it spawns or is dropped","วาร์ปไปเก็บทันทีเมื่อผลเกิดหรือมีคนวาง")
 P.toggle("pw_return","Return after grab","กลับจุดเดิมหลังเก็บ","","")
 P.toggle("pw_notify","Notify on power spawn","แจ้งเตือนเมื่อมีผลเกิด","","")
end

-- ======================= เควส =======================
local setQuestStatus
do
 local P=build("quest") pageList[#pageList+1]=P
 P.header("QUEST","เควส",true)
 setQuestStatus=P.status("Quest status","สถานะเควส")
 local qn={}
 for i=1,46 do qn[#qn+1]="Floppa Quest "..i end
 qn[#qn+1]="Cool Floppa Quest"
 qn[#qn+1]="Floppa Quest [Special]"
 qn[#qn+1]="Floppa Quest [Race]"
 P.picker("quest_pick","Quest NPC","เลือกเควส (รวมเควสลับ)",qn,"Floppa Quest 1",false)
 P.toggle("quest_sel","Auto selected quest","ทำเควสที่เลือกอัตโนมัติ","Take it, do it, turn it in, repeat","รับ ทำ ส่ง แล้วทำซ้ำ")
 P.header("AUTO","อัตโนมัติ")
 P.toggle("quest_accept","Auto accept quest","รับเควสอัตโนมัติ","Accept the best quest for your level when none is active","รับเควสที่เหมาะกับเลเวลเมื่อไม่มีเควส")
 P.toggle("quest_claim","Auto turn in","ส่งเควสอัตโนมัติ","Go back to the quest giver when finished","กลับไปส่งเควสเมื่อทำครบ")
 P.toggle("quest_cool","Cool Floppa quest","เควสลับ Cool Floppa","Loop the hidden Cool Floppa quest","ทำเควสลับ Cool Floppa ซ้ำ")
end

-- ======================= ดันเจี้ยน (เรด) =======================
local setDgStatus
do
 local P=build("dungeon") pageList[#pageList+1]=P
 P.header("DUNGEON","ดันเจี้ยน (เรด)",true)
 setDgStatus=P.status("Dungeon status","สถานะดันเจี้ยน")
 P.picker("dg_boss","Raid boss","เลือกบอสเรด",RAID_BOSSES,RAID_BOSSES[1],false)
 P.slider("dg_wave","Stop at wave","หยุดที่เวฟ",1,50,50,function(v) return math.floor(v).."" end)
 P.toggle("dg_enter","Auto Enter Dungeon","Auto Enter Dungeon","Stand in the raid area and press Start","ไปยืนที่จุดเรดและกด Start อัตโนมัติ")
 P.toggle("dg_clear","Auto Dungeon Clear","Auto Dungeon Clear","Fight everything during the raid","ตีมอนทั้งหมดระหว่างเรด")
 P.toggle("dg_reward","Auto Dungeon Rewards","Auto Dungeon Rewards","Press claim buttons after the raid","กดรับรางวัลหลังเรดจบ")
 P.toggle("dg_next","Auto Next","Auto Next","Press next / continue / replay","กด Next / Continue / Replay อัตโนมัติ")
end

-- ======================= PVP =======================
local setPvpStatus,pvpPicker
do
 local P=build("pvp") pageList[#pageList+1]=P
 if S.pvp_only==nil then S.pvp_only=true end
 P.header("PVP","PVP",true)
 setPvpStatus=P.status("PvP status","สถานะ PvP")
 P.segmented("pvp_weapon","Attack with","ใช้อะไรตี",{{"fist","Fist","หมัด"},{"power","Power","ผล"},{"sword","Sword","ดาบ"}},"fist")
 pvpPicker=P.picker("pvp_name","Target player","เลือกผู้เล่นเป้าหมาย",{"Nearest"},"Nearest",false)
 P.toggle("pvp_hunt","Hunt players","ล่าผู้เล่น","Warp above the player's head, follow and spam skills until down","วาร์ปไปเหนือหัวผู้เล่น ตามติด ใช้สกิลรัวจนล้ม")
 P.toggle("pvp_enable","Auto enable PvP","เปิด PvP ให้อัตโนมัติ","Press the PvP button when yours is off","กดปุ่ม PvP เมื่อของเราปิดอยู่")
 P.toggle("pvp_only","Only PvP-enabled players","เฉพาะคนที่เปิด PvP","Skip players whose PvP is off","ข้ามคนที่ปิด PvP")
 P.toggle("pvp_skill","Spam skills","ใช้สกิลรัว","","")
 P.picker("pvp_keys","Skill keys","ปุ่มสกิล",KEYS,nil,true)
 P.toggle("pvp_safe","Skip safezone","ข้ามคนในเซฟโซน","","")
 P.toggle("pvp_friend","Skip friends","ข้ามเพื่อน","","")
 P.slider("pvp_hp","Retreat when HP below","ถอยเมื่อ HP ต่ำกว่า",0,100,20,function(v) return math.floor(v).."%" end)
end

-- ======================= เผ่า =======================
local RACES={"Fish","Rabbit","Bird"}
local setRaceStatus
do
 local P=build("race") pageList[#pageList+1]=P
 P.header("RACE","เผ่า",true)
 setRaceStatus=P.status("Race status","สถานะเผ่า")

 P.header("REROLL","สุ่มเผ่า")
 P.picker("race_want","Wanted races","เผ่าที่ต้องการ",RACES,nil,true)
 P.slider("race_delay","Delay between rerolls","หน่วงเวลาระหว่างสุ่ม",1,10,3,function(v) return v.."s" end)
 P.slider("race_max","Max rerolls","สุ่มสูงสุดกี่ครั้ง",1,200,30,function(v) return math.floor(v).."" end)
 P.toggle("race_reroll","Auto reroll race","สุ่มเผ่าอัตโนมัติ","Talks to Watermelon Man until you get a wanted race (may cost in-game money)","คุยกับ Watermelon Man จนได้เผ่าที่เลือก (อาจเสียเงินในเกม)")
 P.button("race_tp","Go to Watermelon Man","ไปหา Watermelon Man","Teleport to the race reroll NPC","วาร์ปไปหา NPC สุ่มเผ่า","Go","ไป")

 P.header("EVOLUTION","วิวัฒนาการ / ตื่นพลัง")
 P.slider("race_orb_want","Awakening Orbs wanted","จำนวน Awakening Orb ที่ต้องการ",1,20,1,function(v) return math.floor(v).."" end)
 P.toggle("race_orb","Auto find Awakening Orb","หาของวิวัฒนาการอัตโนมัติ","Buys it, or farms the monster that drops it","ซื้อ หรือไปตีมอนที่ดรอป")
 P.toggle("race_awaken","Auto awaken","ตื่นพลังเผ่าอัตโนมัติ","Uses an Awakening Orb from the inventory if not awakened yet","ใช้ Awakening Orb จากกระเป๋าเมื่อยังไม่ตื่นพลัง")
 P.toggle("race_quest","Race quest","ทำเควสเผ่า","Floppa Quest [Race]","เควสเผ่า (Floppa Quest [Race])")

 P.header("ABILITY","สกิลเผ่า")
 P.toggle("race_skill","Auto race skill","ใช้สกิลเผ่าอัตโนมัติ","Presses the race skill button when enemies are near","กดปุ่มสกิลเผ่าเมื่อมีศัตรูใกล้ๆ")
end

-- ======================= ของแต่งตัว =======================
local setWearStatus
do
 local P=build("wear") pageList[#pageList+1]=P
 P.header("WEARABLES","ของแต่งตัว",true)
 setWearStatus=P.status("Wearable status","สถานะ")
 for _,a in ipairs(WEAR_LIST) do
  local src=DROP_MAP[a]
  local name=WEAR_LABEL[a] or a
  P.toggle(accKey(a),name,name,"Farms until you own it  ·  from: "..(src or "?"),"ฟาร์มจนได้ของนี้  ·  จาก: "..(src or "?"))
 end
end

-- ======================= ESP =======================
do
 local P=build("esp") pageList[#pageList+1]=P
 P.header("ESP","ESP",true)
 P.toggle("esp_player","Player ESP","Player ESP","Show players","แสดงตำแหน่งผู้เล่น")
 P.toggle("esp_npc","NPC ESP","NPC ESP","Show NPCs","แสดงตำแหน่ง NPC")
 P.toggle("esp_fruit","Fruit ESP","Fruit ESP","Show spawned powers","แสดงตำแหน่งผลปีศาจ (Power ที่เกิดในแมพ)")
 P.toggle("esp_chest","Chest ESP","Chest ESP","Show chests","แสดงตำแหน่งหีบสมบัติ")
 P.toggle("esp_item","Item ESP","Item ESP","Show dropped items","แสดงตำแหน่งไอเทมที่ตกพื้น")
 P.toggle("esp_dist","Distance Display","Distance Display","Show distance in studs","แสดงระยะห่าง")
end

-- ======================= วาร์ป =======================
local npcOpts={}
do
 local f=WS:FindFirstChild("NPCs")
 if f then
  for _,g in ipairs(f:GetChildren()) do
   for _,n in ipairs(g:GetChildren()) do if n:IsA("Model") then npcOpts[#npcOpts+1]=n.Name end end
  end
 end
 table.sort(npcOpts)
 if #npcOpts==0 then npcOpts={"Doge"} end
end
local shopOpts={}
do
 local f=path(WS,"NPCs","Shop_Npc")
 if f then for _,n in ipairs(f:GetChildren()) do shopOpts[#shopOpts+1]=n.Name end end
 if #shopOpts==0 then shopOpts={"Doge","Cheems","Floppa Gacha","Doge Gacha","Hanger"} end
end
do
 local P=build("teleport") pageList[#pageList+1]=P
 P.header("TELEPORT","วาร์ป",true)
 P.picker("tp_island","Island","เลือกเกาะ",ISLANDS,"Spawn",false)
 P.button("tp_island_go","Teleport Island","Teleport Island","Warp to the selected island","วาร์ปไปเกาะที่เลือก","Go","ไป")
 P.picker("tp_npc","NPC","เลือก NPC",npcOpts,npcOpts[1],false)
 P.button("tp_npc_go","Teleport to NPC","Teleport to NPC","Warp to the selected NPC","วาร์ปไปหา NPC ที่เลือก","Go","ไป")
 P.picker("tp_shop","Shop","เลือกร้านค้า",shopOpts,shopOpts[1],false)
 P.button("tp_shop_go","Teleport to Shop","Teleport to Shop","Warp to the selected shop","วาร์ปไปร้านที่เลือก","Go","ไป")
 P.header("MOVEMENT","การเคลื่อนที่")
 P.toggle("speed_on","Speed Control","Speed Control","Apply the speed below","ใช้ความเร็วตามค่าด้านล่าง")
 P.slider("speed_val","Walk speed","ความเร็วเดิน",16,250,50,function(v) return math.floor(v).."" end)
 P.toggle("jump_on","Jump Control","Jump Control","Apply the jump power below","ใช้พลังกระโดดตามค่าด้านล่าง")
 P.slider("jump_val","Jump power","พลังกระโดด",50,300,100,function(v) return math.floor(v).."" end)
 P.header("CHEATS","ฟังก์ชันโกง")
 P.toggle("noclip","Noclip","ทะลุสิ่งกีดขวาง","Walk through walls","เดินทะลุกำแพง")
 P.toggle("inf_jump","Infinite jump","กระโดดไม่จำกัด","Jump again in the air","กระโดดซ้ำกลางอากาศได้")
 P.toggle("float_on","Walk on air / water","เดินบนอากาศ / ผิวน้ำ","Keeps a platform at your current height","สร้างแท่นใต้เท้าที่ความสูงตอนเปิด")
 P.button("spawn_boat","Spawn boat","เรียกเรือ","Uses the nearest boat spawner NPC","ใช้ NPC เรียกเรือที่ใกล้ที่สุด","Spawn","เรียก")
 P.button("set_spawn","Set spawn point","ตั้งจุดเกิด","Uses the nearest bed NPC","ใช้ NPC ตั้งจุดเกิดที่ใกล้ที่สุด","Set","ตั้ง")
end

------------------------------------------------------------------
-- ฟีเจอร์: ฟาร์ม
------------------------------------------------------------------
modeLoop("farm_level",.15,function()
 questStep(nil,setFarmStatus)
end)
modeLoop("farm_near",.15,function()
 if not alive() then return end
 local m=sticky(function(x) return not BOSSSET[x.Name] end)
 if m then setFarmStatus(m.Name) engage(m) else setFarmStatus(T("No mobs nearby","ไม่มีมอนสเตอร์")) end
end)
local function findSeaBoss()
 local picked=S.sea_pick or {}
 local any=false
 for _,v in pairs(picked) do if v then any=true end end
 local best,bh
 for _,m in ipairs(aliveMobs()) do
  local ok
  if any then ok=picked[m.Name] else ok=(m.Name=="Meme Beast") end
  if ok then
   local h=m:FindFirstChildOfClass("Humanoid")
   if h and (not bh or h.MaxHealth>bh) then best,bh=m,h.MaxHealth end
  end
 end
 return best
end
local seenSea=false
modeLoop("farm_sea",.15,function()
 if not alive() then return end
 local m=findSeaBoss()
 if m then
  local h=m:FindFirstChildOfClass("Humanoid")
  if not seenSea then
   seenSea=true
   S.sea_seen=os.time() save()
   notify(T("Sea boss spawned","เจ้าทะเลเกิดแล้ว"),m.Name)
  end
  setFarmStatus("🌊 "..m.Name.."  "..math.floor(h.Health).."/"..math.floor(h.MaxHealth))
  engage(m)
 else
  seenSea=false
  local txt=T("Waiting for Meme Beast (every ~30 min)","รอ Meme Beast เกิดกลางทะเล (ทุก ~30 นาที)")
  if S.sea_seen then
   local left=(S.sea_seen+1800)-os.time()
   if left>0 then txt=txt.."  ~"..string.format("%d:%02d",math.floor(left/60),left%60) end
  end
  setFarmStatus(txt)
 end
end)
modeLoop("farm_boss",.15,function()
 if not alive() then return end
 local boss=S.boss_pick
 if S.farm_boss_quest then
  local ss=slots()
  if #ss>0 then questStep(nil,setFarmStatus) return end
  if BOSS_QUEST[boss] then questStep(BOSS_QUEST[boss],setFarmStatus) return end
 end
 local ok=farmNames({[boss]=true})
 setFarmStatus(boss..(ok and "" or T(" (waiting for spawn)"," (รอเกิด)")))
end)
local function itemCount(name)
 local v=path(lp,"Items","ItemStorage",name)
 return v and v.Value or 0
end
local dropCache={}
local function dropSource(item)
 if dropCache[item]~=nil then return dropCache[item] or nil end
 local found=false
 local m=path(RepS,"ModuleScript","Item_Drop")
 local ok,t=pcall(function() return require(m) end)
 if ok and type(t)=="table" then
  local el=path(WS,"Location","Enemy_Location")
  local function isMob(n) return type(n)=="string" and el~=nil and el:FindFirstChild(n)~=nil end
  local function has(tb,depth)
   if depth>4 then return false end
   for k,v in pairs(tb) do
    if k==item or v==item then return true end
    if type(v)=="table" and has(v,depth+1) then return true end
   end
   return false
  end
  for k,v in pairs(t) do
   if type(v)=="table" then
    if isMob(k) and has(v,0) then found=k break end
    if k==item then
     for kk,vv in pairs(v) do
      if isMob(vv) then found=vv break elseif isMob(kk) then found=kk break end
     end
     if found then break end
    end
   end
  end
 end
 dropCache[item]=found
 return found or nil
end
local lastBuyTry=0
-- หาไอเทม: ลองซื้อก่อน ไม่ได้ก็ไปตีมอนที่ดรอป
local function findItem(item,status)
 if os.clock()-lastBuyTry>60 and G.tryBuy then
  lastBuyTry=os.clock()
  if status then status(T("Trying to buy ","กำลังลองซื้อ ")..item) end
  if G.tryBuy(item,"Shop_Npc") then return end
 end
 local src=dropSource(item)
 if src then
  if status then status(T("Farming ","ฟาร์ม ")..src..T(" for "," เพื่อได้ ")..item.."  ("..itemCount(item)..")") end
  farmNames({[src]=true})
 else
  if status then status(T("Don't know where ","ไม่รู้แหล่งดรอปของ ")..item..T(" drops - export game data"," - กดส่งออกข้อมูลเกม")) end
 end
end
local altarCache={}
local function altarFor(boss)
 local a=altarCache[boss]
 if a and a.Parent then return a end
 local isl=WS:FindFirstChild("Island")
 if isl then
  for _,d in ipairs(isl:GetDescendants()) do
   if d:IsA("ProximityPrompt") and d.Name=="SummonPrompt" and d:GetAttribute("Boss")==boss then
    altarCache[boss]=d
    return d
   end
  end
 end
end
local lastSummon=0
local function summonStep(boss,status)
 local info=SUMMON_BOSS[boss]
 if not info then return end
 local m=sticky(function(x) return x.Name==boss end)
 if m then
  local h=m:FindFirstChildOfClass("Humanoid")
  status(boss.."  "..math.floor(h.Health).."/"..math.floor(h.MaxHealth))
  engage(m)
  return
 end
 if os.clock()-lastSummon<25 then status(T("Waiting for ","รอ ")..boss..T(" to appear"," เกิด")) return end
 if itemCount(info.item)<=0 then
  findItem(info.item,status)
  return
 end
 local pp=altarFor(boss)
 if not pp then
  status(T("Going to altar: ","ไปที่แท่น: ")..info.island)
  local sp=path(WS,"Location","Teleport",info.island)
  if sp then setCF(sp.CFrame+Vector3.new(0,5,0)) end
  task.wait(2)
  return
 end
 local part=pp.Parent:IsA("BasePart") and pp.Parent or partOf(pp.Parent)
 if part then setCF(part.CFrame+Vector3.new(0,4,0)) end
 task.wait(.4)
 status(T("Summoning ","กำลังเสก ")..boss)
 pressProx(pp)
 lastSummon=os.clock()
end
modeLoop("farm_summon",.15,function()
 if not alive() then return end
 summonStep(S.summon_pick or SUMMON_LIST[1],setFarmStatus)
end)
modeLoop("farm_item",.1,function()
 if not alive() then return end
 local item=S.item_pick or ITEMS[1]
 local want=S.item_want or 1
 if itemCount(item)>=want then
  setFarmStatus(item.." "..itemCount(item).."/"..math.floor(want).."  ✔")
  return
 end
 findItem(item,setFarmStatus)
end)

-- ===== ของแต่งตัว: ทุกชิ้นเป็นฟังก์ชันแยกกัน =====
local function owns(cat,name)
 local v=path(lp,"Items",cat,name)
 return v~=nil and v.Value>0
end
for _,a in ipairs(WEAR_LIST) do
 local key=accKey(a)
 local label=WEAR_LABEL[a] or a
 modeLoop(key,.15,function()
  if not alive() then return end
  if owns("Accessory",a) then
   setWearStatus(label.." ✔ "..T("owned","มีแล้ว"))
   notify(T("Got it","ได้แล้ว"),label)
   if UI[key] then UI[key](false,true) end
   return
  end
  local src=dropSource(a) or DROP_MAP[a]
  if not src then setWearStatus(T("Unknown source: ","ไม่รู้แหล่งดรอป: ")..label) return end
  setWearStatus(label.."  ←  "..src)
  if SUMMON_BOSS[src] then summonStep(src,setWearStatus) else farmNames({[src]=true}) end
 end)
end

-- ===== สุ่มผล (Gacha) =====
do
 local rolls,lastRoll,animating,lastText=0,0,false,""
 modeLoop("roll_power",.3,function()
  if not alive() then return end
  local gf=path(pgui(),"GachaGui","GachaFrame")
  local ci=gf and gf:FindFirstChild("CurrenItem")
  if gf and shown(gf) then
   animating=true
   if ci and ci.Text~="" then lastText=ci.Text end
   setRollStatus(T("Rolling... ","กำลังสุ่ม... ")..lastText)
   return
  end
  if animating then
   animating=false
   setRollStatus(T("Got: ","ได้: ")..lastText.."  (#"..rolls..")")
   for p,on in pairs(S.roll_want or {}) do
    local base=(p:lower():gsub(" power$",""))
    if on and lastText:lower():find(base,1,true) then
     notify(T("Got the power","ได้ผลที่ต้องการ"),lastText)
     if UI.roll_power then UI.roll_power(false,true) end
     return
    end
   end
  end
  if rolls>=(S.roll_max or 100) then
   setRollStatus(T("Reached max rolls","สุ่มครบจำนวนสูงสุดแล้ว"))
   if UI.roll_power then UI.roll_power(false,true) end
   return
  end
  if os.clock()-lastRoll<(S.roll_delay or 2) then return end
  local npc=path(WS,"NPCs","Shop_Npc",S.roll_npc or "Floppa Gacha")
  local pp=npc and npc:FindFirstChild("Random_Power",true)
  if not pp then
   -- NPC ยังไม่โหลด: ไปที่จุดเกิดหลักก่อนให้ NPC โหลด
   local sp=path(WS,"Location","Teleport","Spawn")
   if sp then setCF(sp.CFrame+Vector3.new(0,5,0)) end
   setRollStatus(T("Loading gacha NPC...","กำลังโหลดตู้สุ่ม..."))
   task.wait(2)
   return
  end
  local part=pp.Parent:IsA("BasePart") and pp.Parent or partOf(npc)
  if part and dist(part)>10 then setCF(part.CFrame+Vector3.new(0,3,0)) task.wait(.3) end
  pressProx(pp)
  rolls+=1
  lastRoll=os.clock()
  setRollStatus(T("Roll #","สุ่มครั้งที่ ")..rolls)
 end)
 local baseRoll=Features.roll_power
 Features.roll_power=function(v)
  if v then rolls=0 animating=false end
  baseRoll(v)
 end
end
loop("buy_style",1,function()
 for name,on in pairs(S.buy_style_pick or {}) do
  if on and alive() and not owns("FightingStyle",name) then
   setBuyStatus(T("Trying: ","กำลังลองซื้อ: ")..name)
   if G.tryBuy and G.tryBuy(name,"FightingStyle_Npc") and S.buy_alert then notify(T("Purchase","ซื้อ"),name) end
   task.wait(2)
  end
 end
 task.wait(S.buy_interval or 20)
end)

-- ===== เผ่า =====
do
 local function raceName() return tostring(pd("Race") or "") end
 local function awakenedFlag()
  local r=raceName():lower()
  for _,n in ipairs(RACES) do
   if r:find(n:lower(),1,true) then return pd(n.."Awaken"),n end
  end
  return nil,nil
 end
 local function findNpc(name)
  local f=WS:FindFirstChild("NPCs")
  return f and f:FindFirstChild(name,true)
 end
 -- สถานะ
 task.spawn(function()
  while NX.gui.Parent do
   local flag,n=awakenedFlag()
   local txt=T("Race: ","เผ่า: ")..(raceName()~="" and raceName() or "?")
   if n then txt=txt..(flag and T("  · awakened ✔","  · ตื่นพลังแล้ว ✔") or T("  · not awakened","  · ยังไม่ตื่นพลัง")) end
   txt=txt.."  · Orb "..itemCount("Awakening Orb")
   if not (S.race_reroll or S.race_orb or S.race_quest) then setRaceStatus(txt) end
   task.wait(1)
  end
 end)
 -- สุ่มเผ่า
 local rerolls=0
 modeLoop("race_reroll",.5,function()
  if not alive() then return end
  local want=S.race_want or {}
  local any=false
  for _,v in pairs(want) do if v then any=true end end
  if not any then setRaceStatus(T("Pick wanted races first","เลือกเผ่าที่ต้องการก่อน")) return end
  local cur=raceName()
  for r,on in pairs(want) do
   if on and cur:lower():find(r:lower(),1,true) then
    setRaceStatus(T("Got ","ได้เผ่า ")..cur.." ✔")
    notify(T("Race","เผ่า"),cur)
    if UI.race_reroll then UI.race_reroll(false,true) end
    return
   end
  end
  if rerolls>=(S.race_max or 30) then
   setRaceStatus(T("Reached max rerolls","สุ่มครบจำนวนสูงสุดแล้ว"))
   if UI.race_reroll then UI.race_reroll(false,true) end
   return
  end
  local npc=findNpc("Watermelon Man")
  local pp=npc and npc:FindFirstChild("Reroll_Race",true)
  if not pp then
   setRaceStatus(T("Watermelon Man not found - walk near him once","ไม่พบ Watermelon Man - เดินไปใกล้ๆ ก่อนครั้งหนึ่ง"))
   task.wait(2)
   return
  end
  local part=pp.Parent:IsA("BasePart") and pp.Parent or partOf(npc)
  if part then setCF(part.CFrame+Vector3.new(0,3,0)) end
  task.wait(.3)
  rerolls+=1
  setRaceStatus(T("Rerolling #","สุ่มครั้งที่ ")..rerolls.."  ("..cur..")")
  pressProx(pp)
  task.wait(.8)
  local c=btnByText(pgui(),{"reroll","confirm","yes","ยืนยัน"})
  if c then press(c) end
  task.wait(S.race_delay or 3)
 end)
 local baseR=Features.race_reroll
 Features.race_reroll=function(v)
  if v then rerolls=0 end
  baseR(v)
 end
 -- หา Awakening Orb
 modeLoop("race_orb",.1,function()
  if not alive() then return end
  local want=S.race_orb_want or 1
  if itemCount("Awakening Orb")>=want then
   setRaceStatus("Awakening Orb "..itemCount("Awakening Orb").."/"..math.floor(want).."  ✔")
   return
  end
  findItem("Awakening Orb",setRaceStatus)
 end)
 -- ใช้ Awakening Orb จากกระเป๋า (ทดลอง: กดปุ่มไอเทมแล้วกดปุ่มใช้)
 loop("race_awaken",3,function()
  local flag=awakenedFlag()
  if flag==true then return end
  if itemCount("Awakening Orb")<=0 then return end
  local g=pgui()
  if not g then return end
  local btn
  for _,d in ipairs(g:GetDescendants()) do
   if d.Name=="Awakening Orb" and d:IsA("TextButton") then btn=d break end
  end
  if not btn then
   setRaceStatus(T("Open your inventory once so the item shows up","เปิดกระเป๋าหนึ่งครั้งเพื่อให้ไอเทมขึ้นก่อน"))
   return
  end
  press(btn)
  task.wait(.4)
  local ub=btnByText(g,{"use","ใช้","awaken","consume"})
  if ub then
   press(ub)
   setRaceStatus(T("Used Awakening Orb","ใช้ Awakening Orb แล้ว"))
  else
   setRaceStatus(T("Use button not found","ไม่พบปุ่มใช้ไอเทม"))
  end
 end)
 -- เควสเผ่า
 modeLoop("race_quest",.15,function()
  questStep("Floppa Quest [Race]",setRaceStatus)
 end)
 -- สกิลเผ่า
 local lastRace=0
 loop("race_skill",1,function()
  if not alive() or os.clock()-lastRace<3 then return end
  if ctlActive() then
   local btn=path(pgui(),"Mobile","RaceSkill","Button")
   if btn and press(btn) then lastRace=os.clock() end
  end
 end)
 Features.race_tp=function()
  local npc=findNpc("Watermelon Man")
  local p=npc and partOf(npc)
  if p then setCF(p.CFrame+Vector3.new(0,4,3)) else notify("Nexora",T("Watermelon Man not loaded","ยังไม่โหลด Watermelon Man")) end
 end
end

loop("skill_auto",.35,function()
 if not alive() or not ctlActive() then return end
 castSkills(S.skill_keys)
end)
-- ตีออร่า: ล็อกมอนใกล้สุดในระยะ ลอยเหนือหัวแล้วตีจนตาย แล้วค่อยเลือกตัวถัดไปในระยะ
modeLoop("aura",.15,function()
 if not alive() then return end
 local m=sticky()
 local p=m and m:FindFirstChild("HumanoidRootPart")
 if p and dist(p)<=(S.aura_range or 40) then engage(m) end
end)

-- ตีระยะไกล: ขยายฮิตบ็อกซ์อาวุธที่ถืออยู่
do
 local orig={}
 local function restore()
  for h,sz in pairs(orig) do pcall(function() h.Size=sz end) end
  orig={}
 end
 loop("reach",.5,function()
  local c=lp.Character
  local tool=c and c:FindFirstChildOfClass("Tool")
  local h=tool and tool:FindFirstChild("Handle")
  if h then
   if not orig[h] then orig[h]=h.Size end
   local s=S.reach_size or 15
   h.Massless=true h.CanCollide=false
   h.Size=Vector3.new(s,s,s)
  end
 end)
 local base=Features.reach
 Features.reach=function(v)
  base(v)
  if not v then restore() end
 end
end

-- อัปสเต็กผ่านปุ่มในหน้า Stats ของเกม
do
 local listCache
 local function statsList()
  if listCache and listCache.Parent then return listCache end
  local g=pgui()
  if not g then return nil end
  for _,d in ipairs(g:GetDescendants()) do
   if d.Name=="Stats_Handler" then
    local l=d.Parent:FindFirstChild("List")
    if l then listCache=l return l end
   end
  end
 end
 local function upgrade(rowName,amount)
  local list=statsList()
  local fr=list and list:FindFirstChild(rowName)
  local ub=fr and fr:FindFirstChild("UpButton",true)
  if not ub then return false end
  press(ub)
  task.wait(.35)
  local amt=pgui():FindFirstChild("Amount_Frame",true)
  local input=amt and amt:FindFirstChild("Input",true)
  local go=amt and path(amt,"UpgradeFrame","Button")
  if input and go then
   input.Text=tostring(amount)
   task.wait(.1)
   press(go)
   task.wait(.3)
   local cl=path(amt,"CloseFrame","Button")
   if cl then press(cl) end
   return true
  end
  return false
 end
 loop("stat_auto",2,function()
  local pts=pd("SkillPoint") or 0
  if pts<=0 then return end
  local chosen={}
  for _,n in ipairs(STAT_ROWS) do if S.stat_pick and S.stat_pick[n] then chosen[#chosen+1]=n end end
  if #chosen==0 then return end
  local each=math.floor(pts/#chosen)
  if each<=0 then each=pts chosen={chosen[1]} end
  for _,n in ipairs(chosen) do
   upgrade(n,each)
   task.wait(.3)
  end
 end)
end

-- ตัวติดตามบอส / เรด / แจ้งเตือน
do
 local known={}
 local ticker=false
 local function raidArea()
  local isl=WS:FindFirstChild("Island")
  return isl and isl:FindFirstChild("Raid_Area",true)
 end
 local function raidGui() return path(pgui(),"RaidGui","RaidFrame") end
 task.spawn(function()
  while NX.gui.Parent do
   local ok,e=pcall(function()
    local bosses=aliveMobs(function(x) return BOSSSET[x.Name] end)
    -- Boss tracker
    if S.boss_track then
     local parts={}
     for _,b in ipairs(bosses) do parts[#parts+1]=b.Name.." ("..math.floor(dist(b:FindFirstChild("HumanoidRootPart"))).."m)" end
     setBossStatus(#parts>0 and table.concat(parts,", ") or T("No boss alive","ไม่มีบอสเกิด"))
    end
    -- Spawn notification / near alert
    local nowSet={}
    for _,b in ipairs(bosses) do
     nowSet[b]=true
     if not known[b] then
      known[b]=true
      if S.boss_spawn_notif then notify(T("Boss spawned","บอสเกิดแล้ว"),b.Name) end
     end
     if S.boss_alert and dist(b:FindFirstChild("HumanoidRootPart"))<200 and not known[b.Name.."_near"] then
      known[b.Name.."_near"]=os.clock()
      notify(T("Boss nearby","บอสอยู่ใกล้"),b.Name)
     end
    end
    for k in pairs(known) do
     if typeof(k)=="Instance" and not nowSet[k] then known[k]=nil end
    end
    for k,v in pairs(known) do
     if type(k)=="string" and type(v)=="number" and os.clock()-v>60 then known[k]=nil end
    end
    -- Raid tracker / timer
    local rf=raidGui()
    if S.raid_track then
     local ra=raidArea()
     local parts={}
     if rf and shown(rf) then
      local w=rf:FindFirstChild("Wave")
      parts[#parts+1]=T("In raid","กำลังเรด")..(w and (" · "..w.Text) or "")
     else
      parts[#parts+1]=T("Raid idle","เรดยังไม่เริ่ม")
     end
     if ra then
      parts[#parts+1]=(ra:GetAttribute("Current_Player") or 0).."/"..(ra:GetAttribute("Max_Players") or "?")
     end
     setRaidStatus(table.concat(parts,"  "))
    end
    if S.raid_timer then
     local tl=rf and rf:FindFirstChild("TimeLeft")
     setTimerStatus((tl and shown(tl) and tl.Text~="") and tl.Text or T("-","-"))
    end
    -- ESP
    for key,def in pairs(ESPS) do
     if S[key] then espUpdate(key,def[2](),def[1]) elseif espObjs[key] then espClear(key) end
    end
   end)
   if not ok then warn("[Nexora] ticker: "..tostring(e)) end
   task.wait(.4)
  end
 end)
end

local function writeOut(file,lines)
 pcall(function() writefile(file,table.concat(lines,"\n")) end)
 notify("Nexora",file)
end
Features.dump_modules=function()
 local function ser(v,depth,seen)
  if type(v)=="table" then
   if depth>4 or seen[v] then return "{...}" end
   seen[v]=true
   local parts,n={},0
   for k,x in pairs(v) do
    n+=1
    if n>400 then parts[#parts+1]="..." break end
    parts[#parts+1]=string.rep(" ",depth+1)..tostring(k).."="..ser(x,depth+1,seen)
   end
   return "{\n"..table.concat(parts,",\n").."\n"..string.rep(" ",depth).."}"
  end
  return tostring(v)
 end
 local function p3(p) return string.format("%.0f, %.0f, %.0f",p.X,p.Y,p.Z) end
 local out={}
 out[#out+1]="=== PlayerData ==="
 local pdF=lp:FindFirstChild("PlayerData")
 if pdF then for _,v in ipairs(pdF:GetChildren()) do if v:IsA("ValueBase") then out[#out+1]=v.Name.." = "..tostring(v.Value) end end end
 out[#out+1]="=== QuestFolder ==="
 local qf=lp:FindFirstChild("QuestFolder")
 if qf then
  for _,s in ipairs(qf:GetChildren()) do
   local row={s.Name}
   for _,v in ipairs(s:GetChildren()) do if v:IsA("ValueBase") then row[#row+1]=v.Name.."="..tostring(v.Value) end end
   out[#out+1]=table.concat(row,"  ")
  end
 end
 out[#out+1]="=== Monsters alive ==="
 for _,m in ipairs(aliveMobs()) do
  local h=m:FindFirstChildOfClass("Humanoid")
  local ok,_,size=pcall(function() return m:GetBoundingBox() end)
  out[#out+1]=m.Name.." hp="..math.floor(h.Health).."/"..math.floor(h.MaxHealth).." pos="..p3(m.HumanoidRootPart.Position)..(ok and (" size="..p3(size)) or "")
 end
 out[#out+1]="=== Enemy_Location ==="
 local el=path(WS,"Location","Enemy_Location")
 if el then for _,p in ipairs(el:GetChildren()) do if p:IsA("BasePart") then out[#out+1]=p.Name.." "..p3(p.Position) end end end
 out[#out+1]="=== QuestLocaion ==="
 local ql=path(WS,"Location","QuestLocaion")
 if ql then for _,p in ipairs(ql:GetChildren()) do if p:IsA("BasePart") then out[#out+1]=p.Name.." "..p3(p.Position) end end end
 out[#out+1]="=== Quests_Npc ==="
 local qn=path(WS,"NPCs","Quests_Npc")
 if qn then for _,n in ipairs(qn:GetChildren()) do local pt=partOf(n) out[#out+1]=n.Name.." "..(pt and p3(pt.Position) or "?") end end
 out[#out+1]="=== ItemStorage ==="
 local ist=path(lp,"Items","ItemStorage")
 if ist then for _,v in ipairs(ist:GetChildren()) do if v:IsA("ValueBase") then out[#out+1]=v.Name.." = "..tostring(v.Value) end end end
 out[#out+1]="=== Misc_Npc ==="
 local mn=path(WS,"NPCs","Misc_Npc")
 if mn then for _,n in ipairs(mn:GetChildren()) do local pt=partOf(n) out[#out+1]=n.Name.." "..(pt and p3(pt.Position) or "?") end end
 out[#out+1]="=== Raid_Area ==="
 local isl=WS:FindFirstChild("Island")
 local ra=isl and isl:FindFirstChild("Raid_Area",true)
 if ra then out[#out+1]=p3(ra.Position) end
 local f=path(RepS,"ModuleScript")
 for _,n in ipairs({"Quest_Settings","GachaChance","MonsterSettings","Item_Drop","ItemSettings","NPCTalks"}) do
  local m=f and f:FindFirstChild(n)
  local ok,r=pcall(function() return require(m) end)
  out[#out+1]="=== "..n.." ===\n"..(ok and ser(r,0,{}) or ("ERR "..tostring(r)))
 end
 writeOut("NexoraDump.txt",out)
end
Features.dump_gui=function()
 local out={}
 local g=pgui()
 if g then
  for _,d in ipairs(g:GetDescendants()) do
   if d:IsA("TextLabel") or d:IsA("TextButton") then
    local t=d.Text
    if t~="" and #out<8000 then out[#out+1]=(d:GetFullName():gsub("^.-PlayerGui%.","")).." | "..t end
   end
  end
 end
 writeOut("NexoraGui.txt",out)
end
do
 local logBuf,hooked={},false
 local function sv(v,d)
  local t=typeof(v)
  if t=="string" then return '"'..v..'"'
  elseif t=="Instance" then return "<"..v:GetFullName()..">"
  elseif t=="table" then
   if d>=2 then return "{...}" end
   local parts,n={},0
   for k,x in pairs(v) do
    n+=1
    if n>12 then parts[#parts+1]="..." break end
    parts[#parts+1]=tostring(k).."="..sv(x,d+1)
   end
   return "{"..table.concat(parts,",").."}"
  end
  return tostring(v)
 end
 local function flush() pcall(function() writefile("NexoraRemoteLog.txt",table.concat(logBuf,"\n")) end) end
 Features.remote_log=function(v)
  if not v then flush() return end
  if not (hookmetamethod and getnamecallmethod) then
   notify("Nexora",T("Executor has no hookmetamethod","executor ไม่รองรับ hookmetamethod"))
   if UI.remote_log then UI.remote_log(false,false) end
   return
  end
  if not hooked then
   hooked=true
   local old
   old=hookmetamethod(game,"__namecall",(newcclosure or function(f) return f end)(function(self,...)
    local m=getnamecallmethod()
    if S.remote_log and (m=="FireServer" or m=="InvokeServer") then
     local args=table.pack(...)
     pcall(function()
      if typeof(self)=="Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
       local parts={}
       for i=1,args.n do parts[#parts+1]=sv(args[i],0) end
       logBuf[#logBuf+1]=string.format("[%.2f] %s:%s(%s)",os.clock(),self:GetFullName(),m,table.concat(parts,", "))
       if #logBuf>1500 then table.remove(logBuf,1) end
      end
     end)
    end
    return old(self,...)
   end))
  end
  task.spawn(function()
   while S.remote_log and NX.gui.Parent do task.wait(3) flush() end
  end)
 end
end

------------------------------------------------------------------
-- ฟีเจอร์: เควส
------------------------------------------------------------------
modeLoop("quest_sel",.15,function()
 questStep(S.quest_pick,setQuestStatus)
end)
loop("quest_accept",2,function()
 if alive() and #slots()==0 then setQuestStatus(T("Taking quest...","กำลังรับเควส...")) acceptQuest(setQuestStatus) end
end)
loop("quest_claim",2,function()
 if not alive() then return end
 for _,s in ipairs(slots()) do
  if s.amount>=s.need and os.clock()-lastTurn>3 then
   lastTurn=os.clock()
   goTalk(s.giver)
   task.wait(.8)
   pressAccept()
   break
  end
 end
end)
loop("quest_cool",2,function()
 if #slots()==0 then goTalk("Cool Floppa Quest") task.wait(.7) pressAccept() end
end)

------------------------------------------------------------------
-- ฟีเจอร์: ซื้อ
------------------------------------------------------------------
do
 local function ownedCheck(kind,name)
  if kind=="weapon" then local v=path(lp,"Items","Weapon",name) return v and v.Value>0
  elseif kind=="power" then local v=path(lp,"Items","Power",name) return v and v.Value>0
  elseif kind=="haki" then local v=path(lp,"Ability",name) return v and v.Value==true end
  return false
 end
 local function findNamed(rootObj,name)
  if not rootObj then return nil end
  for _,d in ipairs(rootObj:GetDescendants()) do
   if d.Name==name and d:IsA("GuiObject") and shown(d) then return d end
  end
 end
 local function closeGuis()
  local c=btnByText(pgui(),{"close"})
  if c then press(c) end
 end
 -- เปิดร้าน/NPC ด้วย ProximityPrompt แล้วหาปุ่มซื้อของชื่อนั้น
 local function tryBuy(name,npcFolder)
  local f=path(WS,"NPCs",npcFolder)
  if not f then return false end
  for _,npc in ipairs(f:GetChildren()) do
   local pp=npc:FindFirstChildWhichIsA("ProximityPrompt",true)
   local part=partOf(npc)
   if pp and part then
    setCF(part.CFrame+Vector3.new(0,3,0))
    task.wait(.3)
    pressProx(pp)
    task.wait(.7)
    local item=findNamed(pgui(),name)
    if item then
     local b=btnByText(item,{"buy","purchase","ซื้อ"}) or (item:IsA("GuiButton") and item or nil)
     if b then
      press(b)
      task.wait(.4)
      local c=btnByText(pgui(),{"confirm","yes","ยืนยัน"})
      if c then press(c) end
      task.wait(.3)
      closeGuis()
      return true
     end
    end
    closeGuis()
   end
  end
  return false
 end
 G.tryBuy=tryBuy
 local function buyGroup(pickKey,kind,folder)
  local picked=S[pickKey] or {}
  for name,on in pairs(picked) do
   if on and alive() then
    if not (kind and ownedCheck(kind,name)) then
     setBuyStatus(T("Trying: ","กำลังลองซื้อ: ")..name)
     local ok=tryBuy(name,folder)
     if ok and S.buy_alert then notify(T("Purchase","ซื้อ"),name) end
     task.wait(1)
    end
   end
  end
 end
 local function runBuy(key,pickKey,kind,folder)
  loop(key,1,function()
   buyGroup(pickKey,kind,folder)
   local wait=S.buy_restock and (S.buy_interval or 20) or 8
   setBuyStatus(T("Next check in ","ตรวจรอบถัดไปใน ")..math.floor(wait).."s")
   task.wait(wait)
  end)
 end
 runBuy("buy_items","buy_item_pick",nil,"Shop_Npc")
 runBuy("buy_weapons","buy_weapon_pick","weapon","Shop_Npc")
 runBuy("buy_fruits","buy_power_pick","power","Shop_Npc")
 runBuy("buy_haki","buy_haki_pick","haki","AbilityTrainer_Npc")

 -- ผลที่เกิด/ตกพื้น: วาร์ปไปเก็บ
 local notified={}
 local function sources()
  local o={}
  for _,f in ipairs({path(WS,"SpawningPower","Spawned_Powers"),WS:FindFirstChild("Dropped_Items")}) do
   if f then for _,c in ipairs(f:GetChildren()) do o[#o+1]=c end end
  end
  return o
 end
 local function wanted(c)
  local sel=S.pw_pick or {}
  local any=false
  for k,v in pairs(sel) do if v then any=true if c.Name:find(k,1,true) then return true end end end
  return not any
 end
 loop("pw_grab",.5,function()
  if not alive() then return end
  for _,c in ipairs(sources()) do
   if wanted(c) then
    local part=partOf(c)
    if part then
     local r=root()
     local back=r and r.CFrame
     setCF(part.CFrame+Vector3.new(0,3,0))
     task.wait(.25)
     local pp=c:FindFirstChildWhichIsA("ProximityPrompt",true)
     if pp then pressProx(pp) end
     pcall(function()
      if firetouchinterest and root() then firetouchinterest(root(),part,0) firetouchinterest(root(),part,1) end
     end)
     task.wait(.4)
     if S.pw_return and back then setCF(back) end
     break
    end
   end
  end
 end)
 task.spawn(function()
  while NX.gui.Parent do
   if S.pw_notify then
    for _,c in ipairs(sources()) do
     if not notified[c] then
      notified[c]=true
      notify(T("Power spawned","มีผลเกิด"),c.Name)
     end
    end
   end
   task.wait(1)
  end
 end)
end

------------------------------------------------------------------
-- ฟีเจอร์: ดันเจี้ยน (เรด)
------------------------------------------------------------------
do
 local function raidArea()
  local isl=WS:FindFirstChild("Island")
  return isl and isl:FindFirstChild("Raid_Area",true)
 end
 local function inRaid()
  local rf=path(pgui(),"RaidGui","RaidFrame")
  return rf~=nil and shown(rf)
 end
 local function curWave()
  local w=path(pgui(),"RaidGui","RaidFrame","Wave")
  local n=w and tostring(w.Text):match("(%d+)")
  return n and tonumber(n) or 0
 end
 loop("dg_enter",1,function()
  if not alive() then return end
  if curWave()>=(S.dg_wave or 50) and inRaid() then setDgStatus(T("Stop wave reached","ถึงเวฟที่กำหนดแล้ว")) return end
  if inRaid() then setDgStatus(T("In raid","กำลังเรด")) return end
  local ra=raidArea()
  if not ra then setDgStatus(T("Raid area not loaded","ยังไม่พบจุดเรด")) return end
  if dist(ra)>12 then setCF(CFrame.new(ra.Position+Vector3.new(0,4,0))) end
  local sb=path(pgui(),"RaidGui","RaidFrame","Start_Button")
  if sb and shown(sb) then press(sb) end
  setDgStatus(T("Waiting in raid area","รอที่จุดเรด").." "..(ra:GetAttribute("Current_Player") or 0).."/"..(ra:GetAttribute("Max_Players") or "?"))
 end)
 loop("dg_clear",.05,function()
  if not alive() or not inRaid() then return end
  local want=S.dg_boss
  local m=sticky(function(x) return x.Name==want end)
  if not m then m=sticky() end
  if m then setDgStatus(T("Fighting ","กำลังสู้ ")..m.Name) engage(m) end
 end)
 loop("dg_reward",1.5,function()
  local g=pgui()
  local b=btnByText(g and (g:FindFirstChild("RewardScreen") or g),{"claim","collect","รับ"})
  if b and not inRaid() then press(b) end
 end)
 loop("dg_next",2,function()
  local b=btnByText(pgui(),{"next","continue","replay","again"})
  if b then press(b) end
 end)
end

------------------------------------------------------------------
-- ฟีเจอร์: PVP (ฆ่าผู้เล่นเท่านั้น ไม่ยุ่งกับมอน)
------------------------------------------------------------------
do
 local friendCache={}
 local function isFriend(p)
  if friendCache[p.UserId]==nil then
   local ok,r=pcall(function() return lp:IsFriendsWith(p.UserId) end)
   friendCache[p.UserId]=ok and r or false
  end
  return friendCache[p.UserId]
 end
 local function pvpOff(p)
  return p:GetAttribute("PvpDisabled")~=nil or (p.Character~=nil and p.Character:GetAttribute("PvpDisabled")~=nil)
 end
 local function candidate(p)
  if p==lp or not p.Character then return false end
  local h=p.Character:FindFirstChildOfClass("Humanoid")
  local r=p.Character:FindFirstChild("HumanoidRootPart")
  if not h or not r or h.Health<=0 then return false end
  if S.pvp_safe and p.Character:GetAttribute("Safezone") then return false end
  if S.pvp_only and pvpOff(p) then return false end
  if S.pvp_friend and isFriend(p) then return false end
  return true
 end
 local function pickTarget()
  local want=S.pvp_name
  if want and want~="Nearest" then
   local p=Players:FindFirstChild(want)
   return (p and candidate(p)) and p or nil
  end
  local best,bd
  for _,p in ipairs(Players:GetPlayers()) do
   if candidate(p) then
    local d=dist(p.Character.HumanoidRootPart)
    if not bd or d<bd then best,bd=p,d end
   end
  end
  return best
 end
 loop("pvp_enable",3,function()
  if pvpOff(lp) then
   local g=pgui()
   local b=g and g:FindFirstChild("PvpDisabled",true)
   if b and b:IsA("GuiButton") then press(b) end
  end
 end)
 local retreatUntil=0
 modeLoop("pvp_hunt",.15,function()
  if not alive() then return end
  local h=hum()
  if h and h.MaxHealth>0 and (h.Health/h.MaxHealth*100)<(S.pvp_hp or 20) then
   retreatUntil=os.clock()+6
   local sp=path(WS,"Location","Teleport","Spawn")
   if sp then setCF(sp.CFrame+Vector3.new(0,4,0)) end
  end
  if os.clock()<retreatUntil then setPvpStatus(T("Retreating...","กำลังถอย...")) return end
  local p
  local cur=Ctl.target
  local curP=cur and Players:GetPlayerFromCharacter(cur)
  local want=S.pvp_name
  if curP and candidate(curP) and (not want or want=="Nearest" or want==curP.Name) then p=curP else p=pickTarget() end
  if not p then setPvpStatus(T("No target","ไม่มีเป้าหมาย")) return end
  local th=p.Character:FindFirstChildOfClass("Humanoid")
  setPvpStatus(p.Name.."  "..math.floor(th and th.Health or 0))
  engage(p.Character,S.pvp_weapon or "fist")
  if S.pvp_skill then castSkills(S.pvp_keys) end
 end)
 local function refresh()
  local names={"Nearest"}
  for _,p in ipairs(Players:GetPlayers()) do if p~=lp then names[#names+1]=p.Name end end
  pvpPicker.setOptions(names)
 end
 Players.PlayerAdded:Connect(refresh)
 Players.PlayerRemoving:Connect(function() task.delay(.2,refresh) end)
 refresh()
end

------------------------------------------------------------------
-- ฟีเจอร์: วาร์ป / ความเร็ว / กระโดด
------------------------------------------------------------------
do
 local ncConn
 Features.noclip=function(v)
  if ncConn then ncConn:Disconnect() ncConn=nil end
  if not v then return end
  ncConn=RunS.Stepped:Connect(function()
   if not S.noclip then return end
   local c=lp.Character
   if c then
    for _,p in ipairs(c:GetChildren()) do
     if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end
    end
   end
  end)
  conns[#conns+1]=ncConn
 end
 conns[#conns+1]=UIS.JumpRequest:Connect(function()
  if S.inf_jump then
   local h=hum()
   if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
  end
 end)
 local plat,fConn,fY
 local function stopFloat()
  if fConn then fConn:Disconnect() fConn=nil end
  if plat then plat:Destroy() plat=nil end
 end
 Features.float_on=function(v)
  stopFloat()
  if not v then return end
  local r=root()
  if not r then return end
  fY=r.Position.Y-3.2
  plat=Instance.new("Part")
  plat.Name="NexoraFloat" plat.Anchored=true plat.CanCollide=true plat.Transparency=1
  plat.Size=Vector3.new(14,1,14)
  plat.Parent=WS
  fConn=RunS.Heartbeat:Connect(function()
   local rr=root()
   if not S.float_on or not rr or not plat then return end
   plat.CFrame=CFrame.new(rr.Position.X,fY,rr.Position.Z)
  end)
  conns[#conns+1]=fConn
 end
 NX.gui.Destroying:Connect(function() pcall(stopFloat) end)
 loop("auto_haki",3,function()
  if not alive() then return end
  local ab=path(lp,"Ability","Aura")
  if not (ab and ab.Value==true) then return end
  local c=lp.Character
  local t=c and c:FindFirstChildOfClass("Tool")
  if t and t:GetAttribute("Aura")==false then
   local btn=path(pgui(),"Mobile","Aura","Button")
   if btn then press(btn) end
  end
 end)
 loop("pickup_near",.7,function()
  local f=WS:FindFirstChild("Dropped_Items")
  if not f or not alive() then return end
  for _,c in ipairs(f:GetChildren()) do
   local p=partOf(c)
   if p and dist(p)<30 then
    local pp=c:FindFirstChildWhichIsA("ProximityPrompt",true)
    if pp then pressProx(pp) end
   end
  end
 end)
 local function useNpcPrompt(folder,promptName)
  local f=path(WS,"NPCs",folder)
  local best,bd
  if f then
   for _,n in ipairs(f:GetChildren()) do
    local pp=n:FindFirstChild(promptName,true)
    local p=pp and partOf(n)
    if p then
     local d=dist(p)
     if not bd or d<bd then best,bd=pp,d end
    end
   end
  end
  if not best then notify("Nexora",T("NPC not loaded - walk near it","ยังไม่โหลด NPC - เดินเข้าใกล้ก่อน")) return end
  local part=best.Parent:IsA("BasePart") and best.Parent or partOf(best.Parent)
  if part then setCF(part.CFrame+Vector3.new(0,3,0)) end
  task.wait(.4)
  pressProx(best)
 end
 Features.spawn_boat=function() useNpcPrompt("BoatSpawner_Npc","Spawn_Boat") end
 Features.set_spawn=function() useNpcPrompt("SetSpawn_Npc","Set_BedPoint") end
end
Features.tp_island_go=function()
 local sp=path(WS,"Location","Teleport",S.tp_island or "Spawn")
 if sp and root() then setCF(sp.CFrame+Vector3.new(0,5,0)) end
end
Features.tp_npc_go=function()
 local f=WS:FindFirstChild("NPCs")
 if not f then return end
 for _,g in ipairs(f:GetChildren()) do
  local n=g:FindFirstChild(S.tp_npc or "")
  local p=n and partOf(n)
  if p then setCF(p.CFrame+Vector3.new(0,4,3)) return end
 end
end
Features.tp_shop_go=function()
 local n=path(WS,"NPCs","Shop_Npc",S.tp_shop or "")
 local p=n and partOf(n)
 if p then setCF(p.CFrame+Vector3.new(0,4,3)) end
end
do
 local sConn,jConn
 local function stopS() if sConn then sConn:Disconnect() sConn=nil end end
 local function stopJ() if jConn then jConn:Disconnect() jConn=nil end end
 Features.speed_on=function(v)
  stopS()
  if not v then
   local h=hum()
   if h then h.WalkSpeed=16 end
   return
  end
  sConn=RunS.Heartbeat:Connect(function(dt)
   if not S.speed_on then stopS() return end
   local h,r=hum(),root()
   if not h or not r or h.Health<=0 then return end
   local want=S.speed_val or 50
   local cur=h.WalkSpeed
   h.WalkSpeed=want
   local md=h.MoveDirection
   -- เกมรีเซ็ตความเร็วกลับ: ดันตัวละครตามทิศเดินเองเพื่อชดเชย
   if md.Magnitude>0 and cur<want-1 then
    r.CFrame=r.CFrame+md*(want-cur)*dt
   end
  end)
  conns[#conns+1]=sConn
 end
 local boosted=false
 Features.jump_on=function(v)
  stopJ()
  if not v then
   local h=hum()
   if h then h.JumpPower=50 end
   return
  end
  jConn=RunS.Heartbeat:Connect(function()
   if not S.jump_on then stopJ() return end
   local h,r=hum(),root()
   if not h or not r or h.Health<=0 then return end
   local jp=S.jump_val or 100
   h.UseJumpPower=true
   h.JumpPower=jp
   if h:GetState()==Enum.HumanoidStateType.Jumping then
    if not boosted then
     boosted=true
     local vel=r.AssemblyLinearVelocity
     r.AssemblyLinearVelocity=Vector3.new(vel.X,jp,vel.Z)
    end
   else
    boosted=false
   end
  end)
  conns[#conns+1]=jConn
 end
end

------------------------------------------------------------------
-- เปิดฟีเจอร์ที่บันทึกไว้ + ปิดทั้งหมดเมื่อปิดสคริปต์
------------------------------------------------------------------
task.defer(function()
 for _,P in ipairs(pageList) do
  for _,k in ipairs(P.toggles) do
   if S[k] and Features[k] and not running[k] then fire(k,true) end
  end
 end
end)
NX.gui.Destroying:Connect(function()
 pcall(function() RunS:UnbindFromRenderStep("NexoraAim") end)
 for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
 for k in pairs(running) do running[k]=nil end
 for k in pairs(espObjs) do espClear(k) end
end)
end)
if not okG then warn("[Nexora] game pages error: "..tostring(errG)) end
end

------------------------------------------------------------------
-- เริ่มทำงาน: รอหน้าโหลดจบ แล้วเด้งโลโก้ + เปิดหน้าต่าง
------------------------------------------------------------------
do
 local NX=getgenv().NX
 NX.setLang(NX.state.lang or "TH")
 Loader.finish(function()
  if not NX.gui.Parent then return end
  TS:Create(logo,TweenInfo.new(.5,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(LS,LS)}):Play()
  task.delay(.6,function() NX.setOpen(true) end)
 end)
end
