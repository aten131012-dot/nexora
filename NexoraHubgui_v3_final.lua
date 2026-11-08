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
local menu=make("Frame",{Size=UDim2.new(1,0,1,-56),BackgroundTransparency=1},side)
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
section("FARM","ฟาร์ม")
addPage("autofarm","⚒","AUTO FARM","ออโต้ฟาร์ม")
section("TOOLS","เครื่องมือ")
addPage("grabtools","🧲","GRAB TOOLS","จับ-ขว้าง")
section("SERVER","เซิร์ฟเวอร์")
addPage("servertools","⚡","SERVER TOOLS","เครื่องมือเซิร์ฟ")
selectPage("autofarm")

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

--================================================================
-- SHARED STATE + SAVE/LOAD (settings พื้นฐาน ไม่มีหน้า Settings)
--================================================================
do
local NX=getgenv().NX
local HttpService=game:GetService("HttpService")
local S=NX.state
local FILE=NX.CFG.SETTINGS_FILE
-- โหลดค่าที่บันทึกไว้
pcall(function()
 if isfile and isfile(FILE) then
  for k,v in pairs(HttpService:JSONDecode(readfile(FILE))) do S[k]=v end
 end
end)
S.scale=.9
local function save() pcall(function() if writefile then writefile(FILE,HttpService:JSONEncode(S)) end end) end
NX.save=save
-- โหลด accent ที่บันทึกไว้
local PRESETS_ref={{Color3.fromRGB(110,110,110),Color3.fromRGB(245,245,245)},{Color3.fromRGB(140,80,255),Color3.fromRGB(215,125,255)},{Color3.fromRGB(50,130,255),Color3.fromRGB(110,220,255)},{Color3.fromRGB(235,50,70),Color3.fromRGB(255,130,150)}}
if S.accent and PRESETS_ref[S.accent] then NX.setAccent(PRESETS_ref[S.accent][1],PRESETS_ref[S.accent][2]) end
end


--================================================================
-- หน้า AUTO FARM (PlaceId: 6961824067 — ยิงสิ่งต่างๆ และผู้คน)
--================================================================
do
local NX=getgenv().NX
local COL,make,round,L=NX.COL,NX.make,NX.round,NX.L
local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.2,Enum.EasingStyle.Quint)
local S=NX.state
local function save() if NX.save then NX.save() end end
local function T(en,th) return (NX.getLang()=="TH") and th or en end
local function alive() return NX.gui and NX.gui.Parent end

-- scroll container
local sf=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
 BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,
 AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},NX.pages.autofarm)
make("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},sf)
make("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sf)
local ord=0
local ctrls={}

-- widget helpers
local function txt(p,props)
 props.BackgroundTransparency=1
 props.Font=props.Font or Enum.Font.GothamBold
 props.TextColor3=props.TextColor3 or COL.Text
 props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
 return make("TextLabel",props,p)
end
local function header(en,th,big)
 ord+=1
 local l=txt(sf,{LayoutOrder=ord,
  Size=UDim2.new(1,0,0,big and 24 or 16),
  Font=big and Enum.Font.GothamBlack or Enum.Font.GothamBold,
  TextSize=big and 15 or 10,
  TextColor3=big and Color3.new(1,1,1) or COL.Pink})
 if big then
  local g=make("UIGradient",{Rotation=5},l)
  NX.onAccent(function(a,b) g.Color=ColorSequence.new(a,b) end)
 end
 L(l,en,th)
end
local function row(h)
 ord+=1
 local r=make("Frame",{LayoutOrder=ord,Size=UDim2.new(1,0,0,h),
  BackgroundColor3=COL.Chip,BackgroundTransparency=.4},sf)
 round(r,12)
 local s=make("UIStroke",{Transparency=.7,Thickness=1},r)
 NX.onAccent(function(a,b) s.Color=b end)
 return r
end
local function titles(r,en,th,dEn,dTh,rightPad)
 L(txt(r,{Position=UDim2.fromOffset(14,6),
  Size=UDim2.new(1,(rightPad or -60),0,16),TextSize=12}),en,th)
 if dEn then L(txt(r,{Position=UDim2.fromOffset(14,22),
  Size=UDim2.new(1,(rightPad or -60),0,13),
  Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub,TextWrapped=true}),dEn,dTh) end
end
local function toggle(key,en,th,dEn,dTh,cb)
 local r=row(42)
 titles(r,en,th,dEn,dTh)
 local sw=make("TextButton",{Text="",AutoButtonColor=false,
  Size=UDim2.fromOffset(36,20),Position=UDim2.new(1,-50,.5,-10),
  BackgroundColor3=COL.Bg},r)
 round(sw,10)
 local knob=make("Frame",{Size=UDim2.fromOffset(14,14),
  Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
 round(knob,7)
 local function set(v,fire)
  S[key]=v
  TS:Create(sw,TI,{BackgroundColor3=v and COL.Purple or COL.Bg}):Play()
  TS:Create(knob,TI,{Position=v and UDim2.fromOffset(19,3) or UDim2.fromOffset(3,3)}):Play()
  if fire and cb then cb(v) end
  if fire then save() end
 end
 sw.MouseButton1Click:Connect(function() set(not S[key],true) end)
 set(S[key] or false,false)
 NX.onAccent(function() sw.BackgroundColor3=S[key] and COL.Purple or COL.Bg end)
 ctrls[key]=set
end
local function slider(key,en,th,min,max,fmt,cb)
 local r=row(50)
 titles(r,en,th,nil,nil,-96)
 local vl=txt(r,{AnchorPoint=Vector2.new(1,0),
  Position=UDim2.new(1,-14,0,6),Size=UDim2.fromOffset(80,16),
  TextSize=11,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right})
 local track=make("Frame",{Position=UDim2.new(0,14,0,34),
  Size=UDim2.new(1,-28,0,6),BackgroundColor3=COL.Bg},r)
 round(track,3)
 local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=COL.Purple},track)
 round(fill,3)
 local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),
  Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(14,14),
  BackgroundColor3=Color3.new(1,1,1)},track)
 round(knob,7)
 NX.onAccent(function(a) fill.BackgroundColor3=a end)
 local hit=make("TextButton",{Text="",BackgroundTransparency=1,
  Position=UDim2.new(0,14,0,22),Size=UDim2.new(1,-28,0,26)},r)
 local function show(v)
  local t=(v-min)/(max-min)
  fill.Size=UDim2.fromScale(t,1)
  knob.Position=UDim2.fromScale(t,.5)
  vl.Text=fmt(v)
 end
 local function set(v)
  v=math.clamp(v,min,max) S[key]=v show(v)
  if cb then cb(v) end
 end
 local dragging=false
 local function fromX(x)
  local t=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
  set(min+(max-min)*t)
 end
 local function isPtr(i)
  return i.UserInputType==Enum.UserInputType.MouseButton1
   or i.UserInputType==Enum.UserInputType.Touch
 end
 hit.InputBegan:Connect(function(i) if isPtr(i) then dragging=true fromX(i.Position.X) end end)
 UIS.InputChanged:Connect(function(i)
  if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
   or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end
 end)
 UIS.InputEnded:Connect(function(i) if dragging and isPtr(i) then dragging=false save() end end)
 show(S[key] or min)
 ctrls[key]=set
end

-- ===== ค่าตั้งต้น =====
local FD={
 fCollect=false, fRange=50, fPrompt=false,
 fCoin=false,    fCoinWarp=false,
 fHop=false,     fHopMin=10,
}
for k,v in pairs(FD) do if S[k]==nil then S[k]=v end end

-- ===== game remotes (PlaceId: 6961824067) =====
local RS_rep=game:GetService("ReplicatedStorage")
local SlotEvents_folder=RS_rep:FindFirstChild("SlotEvents")
local function fireSlotTime()
 local r=SlotEvents_folder and SlotEvents_folder:FindFirstChild("SlotTime")
 if r then pcall(function() r:FireServer() end) end
end

-- ===== helpers =====
local TeleportService=game:GetService("TeleportService")
local function myRoot()
 local c=lp.Character return c and c:FindFirstChild("HumanoidRootPart")
end
local function isCoinPart(p)
 local n=p.Name:lower()
 return n:find("coin")~=nil or n:find("money")~=nil or n:find("cash")~=nil
  or n:find("gem")~=nil or n:find("crystal")~=nil or n:find("star")~=nil
  or n:find("token")~=nil or n:find("gold")~=nil
end

-- ===== stat counter =====
local stat={items=0, hopAt=nil}
NX.farmStat=stat

-- 1) Auto Collect (TouchInterest)
task.spawn(function()
 while alive() do
  if S.fCollect then
   local hrp=myRoot()
   if hrp then
    for _,d in ipairs(workspace:GetDescendants()) do
     if d:IsA("BasePart") and not d.Anchored then
      local dist=(d.Position-hrp.Position).Magnitude
      if dist<S.fRange then
       pcall(function()
        local touch=d:FindFirstChildOfClass("TouchTransmitter")
        if touch then firetouchinterest(hrp,d,0) end
       end)
      end
     end
    end
   end
   task.wait(.15)
  else task.wait(.5) end
 end
end)

-- 2) Auto Proximity Prompt
task.spawn(function()
 while alive() do
  if S.fPrompt then
   local hrp=myRoot()
   if hrp then
    for _,d in ipairs(workspace:GetDescendants()) do
     if d:IsA("ProximityPrompt") then
      local part=d.Parent
      if part and part:IsA("BasePart") then
       local dist=(part.Position-hrp.Position).Magnitude
       if dist<d.MaxActivationDistance+5 then
        pcall(function() fireproximityprompt(d) end)
       end
      end
     end
    end
   end
   task.wait(.4)
  else task.wait(.5) end
 end
end)

-- 3) Walk-to-coin (non-warp)
task.spawn(function()
 while alive() do
  if S.fCoin and not S.fCoinWarp then
   local hrp=myRoot()
   local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
   if hrp and hum then
    local best,bestD
    for _,d in ipairs(workspace:GetDescendants()) do
     if d:IsA("BasePart") and isCoinPart(d) then
      local dist=(d.Position-hrp.Position).Magnitude
      if dist<400 and (not bestD or dist<bestD) then best=d bestD=dist end
     end
    end
    if best then pcall(function() hum:MoveTo(best.Position) end) end
   end
   task.wait(1)
  else task.wait(.5) end
 end
end)

-- 4) Coin Warp — วาร์ป + firetouchinterest + SlotTime remote
task.spawn(function()
 while alive() do
  if S.fCoinWarp then
   local hrp=myRoot()
   if hrp then
    local best,bestD
    for _,d in ipairs(workspace:GetDescendants()) do
     if d:IsA("BasePart") and isCoinPart(d) then
      local dist=(d.Position-hrp.Position).Magnitude
      if dist>2 and dist<400 and (not bestD or dist<bestD) then best=d bestD=dist end
     end
    end
    if best then
     pcall(function() hrp.CFrame=CFrame.new(best.Position+Vector3.new(0,2,0)) end)
     task.wait(0.05)
     pcall(function()
      local touch=best:FindFirstChildOfClass("TouchTransmitter")
       or best:FindFirstChild("TouchInterest")
      if touch then firetouchinterest(hrp,best,0) end
      fireSlotTime()
     end)
     stat.items+=1
    end
   end
   task.wait(.15)
  else task.wait(.5) end
 end
end)

-- 5) Server Hop
local hopBusy=false
local function httpGet(url)
 local ok,res=pcall(function() return game:HttpGet(url) end)
 if ok and res and #res>0 then return res end
 local req=(syn and syn.request) or (http and http.request) or http_request or request
 if req then
  local ok2,r=pcall(req,{Url=url,Method="GET"})
  if ok2 and r and r.Body then return r.Body end
 end
end
local function findRandom()
 local body=httpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
 if not body then return nil,"http" end
 local ok,data=pcall(function()
  return game:GetService("HttpService"):JSONDecode(body)
 end)
 if not ok or not data or not data.data then return nil,"parse" end
 local list={}
 for _,s in ipairs(data.data) do
  if s.id~=game.JobId and s.playing and s.maxPlayers and s.playing<s.maxPlayers then
   list[#list+1]=s
  end
 end
 if #list==0 then return nil,"none" end
 return list[math.random(#list)]
end
NX.findRandom=findRandom

local function hopNow(statusCb)
 if hopBusy then return end hopBusy=true
 task.spawn(function()
  local s,err=findRandom()
  if s then
   if statusCb then statusCb("🚀 "..(T("Teleporting...","กำลังวาร์ป..."))) end
   pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,lp) end)
   task.wait(10)
  else
   if statusCb then
    statusCb("❌ "..((err=="none") and T("No server","ไม่พบเซิร์ฟ") or T("Failed","ล้มเหลว")))
   end
  end
  hopBusy=false
 end)
end

local hopStatusText=""
task.spawn(function()
 while alive() do
  if S.fHop then
   stat.hopAt=stat.hopAt or (os.clock()+S.fHopMin*60)
   if os.clock()>=stat.hopAt then
    stat.hopAt=os.clock()+S.fHopMin*60
    hopNow(function(t) hopStatusText=t end)
   end
  else stat.hopAt=nil end
  task.wait(1)
 end
end)

-- ===== BUILD UI =====
header("AUTO FARM","ออโต้ฟาร์ม",true)

-- Collect
header("COLLECT","เก็บไอเทม")
toggle("fCollect","Auto Collect","เก็บของอัตโนมัติ",
 "Touch nearby items to collect","สัมผัสไอเทมในระยะเก็บ")
slider("fRange","Range","ระยะเก็บ",5,100,
 function(v) return math.floor(v).." studs" end)
toggle("fPrompt","Auto Prompt","กดปุ่มอัตโนมัติ",
 "Fire proximity prompts in range","ยิง ProximityPrompt ในระยะ")

-- Coins
header("COINS","เหรียญ / ของหล่น")
toggle("fCoin","Auto Farm Coin","ฟาร์มเหรียญ (เดิน)",
 "Walk toward nearest coin","เดินหาเหรียญที่ใกล้สุด")
toggle("fCoinWarp","Coin Warp Farm","ฟาร์มเหรียญ (วาร์ป)",
 "Warp + SlotTime remote","วาร์ปตรง + ยิง SlotTime ของเกม")

-- Stat row
do
 local r=row(30)
 local d=txt(r,{Position=UDim2.fromOffset(14,7),
  Size=UDim2.new(1,-16,0,20),TextSize=9,TextColor3=COL.Sub})
 task.spawn(function()
  while r.Parent do
   local parts={"💰 "..stat.items.." items"}
   if stat.hopAt then
    parts[#parts+1]="⏱ hop in "..math.max(0,math.floor(stat.hopAt-os.clock())).."s"
   end
   if hopStatusText~="" then parts[#parts+1]=hopStatusText end
   d.Text=table.concat(parts,"  │  ")
   task.wait(1)
  end
 end)
end

-- Server Hop
header("SERVER HOP","สลับเซิร์ฟเวอร์")
toggle("fHop","Auto Server Hop","สลับเซิร์ฟอัตโนมัติ",
 "Hop to random server on timer","สลับเซิร์ฟสุ่มตามช่วงเวลา")
slider("fHopMin","Interval","ทุกกี่นาที",1,60,
 function(v) return math.floor(v).." min" end)

-- manual hop button
do
 ord+=1
 local r=row(36)
 local b=make("TextButton",{Size=UDim2.new(1,-28,0,22),
  Position=UDim2.fromOffset(14,7),
  BackgroundColor3=COL.Purple,Text="",AutoButtonColor=false},r)
 round(b,11)
 local bg=make("UIGradient",{Rotation=5},b)
 NX.onAccent(function(a,c2) bg.Color=ColorSequence.new(a,c2) end)
 L(txt(b,{Size=UDim2.fromScale(1,1),TextSize=11,TextColor3=Color3.new(1,1,1),
  TextXAlignment=Enum.TextXAlignment.Center}),"Hop Now","สลับตอนนี้")
 b.MouseButton1Click:Connect(function()
  hopNow(function(t) hopStatusText=t end)
 end)
end

NX.resetFarm=function()
 for k,v in pairs(FD) do if ctrls[k] then ctrls[k](v,true) end S[k]=v end save()
end
end


--================================================================
-- หน้า GRAB TOOLS (PlaceId: 6961824067)
--================================================================
do
local NX=getgenv().NX
local COL,make,round,L=NX.COL,NX.make,NX.round,NX.L
local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.2,Enum.EasingStyle.Quint)
local S=NX.state
local function save() if NX.save then NX.save() end end
local function T(en,th) return (NX.getLang()=="TH") and th or en end
local function alive() return NX.gui and NX.gui.Parent end

-- scroll container
local sf=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
 BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,
 AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},NX.pages.grabtools)
make("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},sf)
make("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sf)
local ord=0
local ctrls={}

-- widget helpers (copy pattern)
local function txt(p,props)
 props.BackgroundTransparency=1
 props.Font=props.Font or Enum.Font.GothamBold
 props.TextColor3=props.TextColor3 or COL.Text
 props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
 return make("TextLabel",props,p)
end
local function header(en,th,big)
 ord+=1
 local l=txt(sf,{LayoutOrder=ord,
  Size=UDim2.new(1,0,0,big and 24 or 16),
  Font=big and Enum.Font.GothamBlack or Enum.Font.GothamBold,
  TextSize=big and 15 or 10,
  TextColor3=big and Color3.new(1,1,1) or COL.Pink})
 if big then
  local g=make("UIGradient",{Rotation=5},l)
  NX.onAccent(function(a,b) g.Color=ColorSequence.new(a,b) end)
 end
 L(l,en,th)
end
local function row(h)
 ord+=1
 local r=make("Frame",{LayoutOrder=ord,Size=UDim2.new(1,0,0,h),
  BackgroundColor3=COL.Chip,BackgroundTransparency=.4},sf)
 round(r,12)
 local s=make("UIStroke",{Transparency=.7,Thickness=1},r)
 NX.onAccent(function(a,b) s.Color=b end)
 return r
end
local function titles(r,en,th,dEn,dTh,rightPad)
 L(txt(r,{Position=UDim2.fromOffset(14,6),
  Size=UDim2.new(1,(rightPad or -60),0,16),TextSize=12}),en,th)
 if dEn then L(txt(r,{Position=UDim2.fromOffset(14,22),
  Size=UDim2.new(1,(rightPad or -60),0,13),
  Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub,TextWrapped=true}),dEn,dTh) end
end
local function toggle(key,en,th,dEn,dTh,cb)
 local r=row(42)
 titles(r,en,th,dEn,dTh)
 local sw=make("TextButton",{Text="",AutoButtonColor=false,
  Size=UDim2.fromOffset(36,20),Position=UDim2.new(1,-50,.5,-10),
  BackgroundColor3=COL.Bg},r)
 round(sw,10)
 local knob=make("Frame",{Size=UDim2.fromOffset(14,14),
  Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
 round(knob,7)
 local function set(v,fire)
  S[key]=v
  TS:Create(sw,TI,{BackgroundColor3=v and COL.Purple or COL.Bg}):Play()
  TS:Create(knob,TI,{Position=v and UDim2.fromOffset(19,3) or UDim2.fromOffset(3,3)}):Play()
  if fire and cb then cb(v) end
  if fire then save() end
 end
 sw.MouseButton1Click:Connect(function() set(not S[key],true) end)
 set(S[key] or false,false)
 NX.onAccent(function() sw.BackgroundColor3=S[key] and COL.Purple or COL.Bg end)
 ctrls[key]=set
end
local function slider(key,en,th,min,max,fmt,cb)
 local r=row(50)
 titles(r,en,th,nil,nil,-96)
 local vl=txt(r,{AnchorPoint=Vector2.new(1,0),
  Position=UDim2.new(1,-14,0,6),Size=UDim2.fromOffset(80,16),
  TextSize=11,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right})
 local track=make("Frame",{Position=UDim2.new(0,14,0,34),
  Size=UDim2.new(1,-28,0,6),BackgroundColor3=COL.Bg},r)
 round(track,3)
 local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=COL.Purple},track)
 round(fill,3)
 local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),
  Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(14,14),
  BackgroundColor3=Color3.new(1,1,1)},track)
 round(knob,7)
 NX.onAccent(function(a) fill.BackgroundColor3=a end)
 local hit=make("TextButton",{Text="",BackgroundTransparency=1,
  Position=UDim2.new(0,14,0,22),Size=UDim2.new(1,-28,0,26)},r)
 local function show(v)
  local t=(v-min)/(max-min)
  fill.Size=UDim2.fromScale(t,1)
  knob.Position=UDim2.fromScale(t,.5)
  vl.Text=fmt(v)
 end
 local function set(v)
  v=math.clamp(v,min,max) S[key]=v show(v) if cb then cb(v) end
 end
 local dragging=false
 local function fromX(x)
  local t=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
  set(min+(max-min)*t)
 end
 local function isPtr(i)
  return i.UserInputType==Enum.UserInputType.MouseButton1
   or i.UserInputType==Enum.UserInputType.Touch
 end
 hit.InputBegan:Connect(function(i) if isPtr(i) then dragging=true fromX(i.Position.X) end end)
 UIS.InputChanged:Connect(function(i)
  if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
   or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end
 end)
 UIS.InputEnded:Connect(function(i) if dragging and isPtr(i) then dragging=false save() end end)
 show(S[key] or min)
 ctrls[key]=set
end
local function choiceRow(key,en,th,opts)
 local r=row(56)
 titles(r,en,th,nil,nil,-6)
 local holder=make("Frame",{Position=UDim2.fromOffset(14,26),
  Size=UDim2.new(1,-28,0,22),BackgroundTransparency=1},r)
 make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,
  Padding=UDim.new(0,4)},holder)
 local bs={}
 local function mark()
  for v,b in pairs(bs) do
   TS:Create(b,TI,{BackgroundColor3=(S[key]==v) and COL.Purple or COL.Bg}):Play()
  end
 end
 for _,o in ipairs(opts) do
  local b=make("TextButton",{Size=UDim2.new(1/#opts,-4,1,0),
   BackgroundColor3=COL.Bg,Text=o[2],
   Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Text,
   AutoButtonColor=false},holder)
  round(b,11)
  bs[o[1]]=b
  b.MouseButton1Click:Connect(function() S[key]=o[1] mark() save() end)
 end
 mark()
 NX.onAccent(function() mark() end)
end
local function actionBtn(en,th,cb)
 ord+=1
 local r=row(36)
 local b=make("TextButton",{Size=UDim2.new(1,-28,0,22),
  Position=UDim2.fromOffset(14,7),
  BackgroundColor3=COL.Purple,Text="",AutoButtonColor=false},r)
 round(b,11)
 local bg=make("UIGradient",{Rotation=5},b)
 NX.onAccent(function(a,c2) bg.Color=ColorSequence.new(a,c2) end)
 L(txt(b,{Size=UDim2.fromScale(1,1),TextSize=11,TextColor3=Color3.new(1,1,1),
  TextXAlignment=Enum.TextXAlignment.Center}),en,th)
 b.MouseButton1Click:Connect(cb)
 return b
end

-- ===== ค่าตั้งต้น =====
local FD={
 gGrabNearest=false, gGrabAction="throw",
 gKillGrab=false, gFreezeGrab=false,
 gThrowPower=120,
}
for k,v in pairs(FD) do if S[k]==nil then S[k]=v end end

-- ===== game remotes =====
local RS_rep=game:GetService("ReplicatedStorage")
local GrabEvents_folder=RS_rep:FindFirstChild("GrabEvents")
local HoldEvents_folder=RS_rep:FindFirstChild("HoldEvents")
local CharacterEvents_folder=RS_rep:FindFirstChild("CharacterEvents")
local PlayerEvents_folder=RS_rep:FindFirstChild("PlayerEvents")

local function getRemote(folder,name)
 if not folder then return nil end
 return folder:FindFirstChild(name)
end

-- ===== grab logic =====
local function myRoot()
 local c=lp.Character return c and c:FindFirstChild("HumanoidRootPart")
end

local function getNearestPlayer(maxDist)
 maxDist=maxDist or 999
 local best,bestD,bestChar
 for _,p in ipairs(Players:GetPlayers()) do
  if p~=lp and p.Character then
   local hrp=p.Character:FindFirstChild("HumanoidRootPart")
   local myHRP=myRoot()
   if hrp and myHRP then
    local d=(hrp.Position-myHRP.Position).Magnitude
    if d<maxDist and (not bestD or d<bestD) then
     best=p bestD=d bestChar=p.Character
    end
   end
  end
 end
 return best,bestChar,bestD
end

local function gameCreateGrab(target)
 local hrp=myRoot()
 local CreateGrabLine=getRemote(GrabEvents_folder,"CreateGrabLine")
 local SetNetworkOwner=getRemote(GrabEvents_folder,"SetNetworkOwner")
 if not (hrp and CreateGrabLine) then return false end
 local targetHRP=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
 if not targetHRP then return false end
 pcall(function() CreateGrabLine:FireServer(targetHRP) end)
 if SetNetworkOwner then
  pcall(function() SetNetworkOwner:FireServer(targetHRP) end)
 end
 return true
end

local function gameThrowPlayer(target,power)
 local hrp=myRoot()
 local ExtendGrabLine=getRemote(GrabEvents_folder,"ExtendGrabLine")
 local EndGrabEarly=getRemote(GrabEvents_folder,"EndGrabEarly")
 if not hrp then return end
 local targetHRP=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
 if not targetHRP then return end
 local dir=(targetHRP.Position-hrp.Position).Unit+Vector3.new(0,.4,0)
 if ExtendGrabLine then pcall(function() ExtendGrabLine:FireServer(targetHRP) end) end
 pcall(function() targetHRP.AssemblyLinearVelocity=dir*(power or 120) end)
 if EndGrabEarly then
  task.delay(.05,function() pcall(function() EndGrabEarly:FireServer() end) end)
 end
end

local function gameDropPlayer(target)
 local HoldDrop=getRemote(HoldEvents_folder,"Drop")
 local DestroyGrabLine=getRemote(GrabEvents_folder,"DestroyGrabLine")
 if HoldDrop then pcall(function() HoldDrop:InvokeServer() end) end
 if DestroyGrabLine then pcall(function() DestroyGrabLine:FireServer() end) end
end

local function gameKillPlayer(target)
 -- fire RagdollPlayer + RagdollRemote combo
 local RagdollPlayer=getRemote(PlayerEvents_folder,"RagdollPlayer")
 local RagdollRemote=getRemote(CharacterEvents_folder,"RagdollRemote")
 local HoldUse=getRemote(HoldEvents_folder,"Use")
 local HoldHold=getRemote(HoldEvents_folder,"Hold")
 if not target.Character then return end
 local targetHRP=target.Character:FindFirstChild("HumanoidRootPart")
 if not targetHRP then return end
 pcall(function() if RagdollPlayer then RagdollPlayer:FireServer(target) end end)
 pcall(function() if RagdollRemote then RagdollRemote:FireServer(true) end end)
 if HoldHold then pcall(function() HoldHold:InvokeServer(targetHRP) end) end
 task.delay(.1,function()
  if HoldUse then pcall(function() HoldUse:FireServer() end) end
 end)
end

local function gameFreezePlayer(target)
 local CreateGrabLine=getRemote(GrabEvents_folder,"CreateGrabLine")
 local SetNetworkOwner=getRemote(GrabEvents_folder,"SetNetworkOwner")
 local DestroyGrabLine=getRemote(GrabEvents_folder,"DestroyGrabLine")
 local RagdollRemote=getRemote(CharacterEvents_folder,"RagdollRemote")
 if not target.Character then return end
 local targetHRP=target.Character:FindFirstChild("HumanoidRootPart")
 if not targetHRP then return end
 pcall(function()
  if CreateGrabLine then CreateGrabLine:FireServer(targetHRP) end
  if SetNetworkOwner then SetNetworkOwner:FireServer(targetHRP) end
  if RagdollRemote then RagdollRemote:FireServer(true) end
  targetHRP.Anchored=true
 end)
 task.delay(5,function()
  pcall(function()
   targetHRP.Anchored=false
   if RagdollRemote then RagdollRemote:FireServer(false) end
   if DestroyGrabLine then DestroyGrabLine:FireServer() end
  end)
 end)
end

-- ===== auto-grab loop =====
task.spawn(function()
 while alive() do
  if S.gGrabNearest then
   local target,_,dist=getNearestPlayer(100)
   if target then
    local ok=gameCreateGrab(target)
    if ok then
     task.wait(.3)
     local action=S.gGrabAction or "throw"
     if action=="throw" then
      gameThrowPlayer(target,S.gThrowPower or 120)
      task.wait(.8)
     elseif action=="kill" then
      gameKillPlayer(target)
      task.wait(1)
     else -- none — just hold briefly then drop
      task.wait(.5)
      gameDropPlayer(target)
     end
    end
   end
   task.wait(.5)
  else task.wait(.5) end
 end
end)

-- kill grab loop (20-stud radius)
task.spawn(function()
 while alive() do
  if S.gKillGrab then
   for _,p in ipairs(Players:GetPlayers()) do
    if p~=lp and p.Character then
     local hrp=p.Character:FindFirstChild("HumanoidRootPart")
     local myHRP=myRoot()
     if hrp and myHRP and (hrp.Position-myHRP.Position).Magnitude<20 then
      gameKillPlayer(p)
     end
    end
   end
   task.wait(.4)
  else task.wait(.5) end
 end
end)

-- freeze grab loop
task.spawn(function()
 while alive() do
  if S.gFreezeGrab then
   local target=getNearestPlayer(80)
   if target then gameFreezePlayer(target) end
   task.wait(6) -- slightly longer than 5s freeze
  else task.wait(.5) end
 end
end)

-- ===== BUILD UI =====
header("GRAB TOOLS","เครื่องมือจับ-ขว้าง",true)

header("AUTO GRAB","จับอัตโนมัติ")
toggle("gGrabNearest","Auto Grab Nearest","จับคนใกล้สุดอัตโนมัติ",
 "Grab nearest player continuously","จับผู้เล่นที่ใกล้ที่สุดต่อเนื่อง")
choiceRow("gGrabAction","After Grab:","หลังจับ:",{
 {"throw","⚾ Throw"},{"kill","💀 Kill"},{"none","✋ None"},
})
slider("gThrowPower","Throw Power","แรงขว้าง",20,300,
 function(v) return math.floor(v) end)

header("SPECIAL GRABS","จับพิเศษ")
toggle("gKillGrab","Kill Grab","จับฆ่า (20 studs)",
 "Kill all players within 20 studs","กำจัดผู้เล่นในรัศมี 20 studs")
toggle("gFreezeGrab","Freeze Grab","แช่แข็ง",
 "Anchor nearest player for 5 sec","แช่แข็งคนใกล้สุด 5 วินาที")

header("MANUAL","กดเอง")
actionBtn("⚾ Throw Nearest","ขว้างคนใกล้สุด",function()
 local t=getNearestPlayer(100)
 if not t then return end
 local ok=gameCreateGrab(t)
 if ok then task.wait(.2) gameThrowPlayer(t,S.gThrowPower or 120) end
end)
actionBtn("💀 Kill Nearest","ฆ่าคนใกล้สุด",function()
 local t=getNearestPlayer(50)
 if t then gameKillPlayer(t) end
end)
actionBtn("🧊 Freeze Nearest","แช่แข็งคนใกล้สุด",function()
 local t=getNearestPlayer(80)
 if t then gameFreezePlayer(t) end
end)

NX.resetGrab=function()
 for k,v in pairs(FD) do if ctrls[k] then ctrls[k](v,true) end S[k]=v end save()
end
end


--================================================================
-- หน้า SERVER TOOLS (PlaceId: 6961824067)
-- LAG FIX: S.lagActive starts false, loop is ONLY started on button click
--================================================================
do
local NX=getgenv().NX
local COL,make,round,L=NX.COL,NX.make,NX.round,NX.L
local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.2,Enum.EasingStyle.Quint)
local S=NX.state
local function save() if NX.save then NX.save() end end
local function T(en,th) return (NX.getLang()=="TH") and th or en end
local function alive() return NX.gui and NX.gui.Parent end

-- scroll container
local sf=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
 BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,
 AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},NX.pages.servertools)
make("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},sf)
make("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sf)
local ord=0
local ctrls={}

-- widget helpers
local function txt(p,props)
 props.BackgroundTransparency=1
 props.Font=props.Font or Enum.Font.GothamBold
 props.TextColor3=props.TextColor3 or COL.Text
 props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
 return make("TextLabel",props,p)
end
local function header(en,th,big)
 ord+=1
 local l=txt(sf,{LayoutOrder=ord,
  Size=UDim2.new(1,0,0,big and 24 or 16),
  Font=big and Enum.Font.GothamBlack or Enum.Font.GothamBold,
  TextSize=big and 15 or 10,
  TextColor3=big and Color3.new(1,1,1) or COL.Pink})
 if big then
  local g=make("UIGradient",{Rotation=5},l)
  NX.onAccent(function(a,b) g.Color=ColorSequence.new(a,b) end)
 end
 L(l,en,th)
end
local function row(h)
 ord+=1
 local r=make("Frame",{LayoutOrder=ord,Size=UDim2.new(1,0,0,h),
  BackgroundColor3=COL.Chip,BackgroundTransparency=.4},sf)
 round(r,12)
 local s=make("UIStroke",{Transparency=.7,Thickness=1},r)
 NX.onAccent(function(a,b) s.Color=b end)
 return r
end
local function titles(r,en,th,dEn,dTh,rightPad)
 L(txt(r,{Position=UDim2.fromOffset(14,6),
  Size=UDim2.new(1,(rightPad or -60),0,16),TextSize=12}),en,th)
 if dEn then L(txt(r,{Position=UDim2.fromOffset(14,22),
  Size=UDim2.new(1,(rightPad or -60),0,13),
  Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub,TextWrapped=true}),dEn,dTh) end
end
local function actionBtn(en,th,cb)
 ord+=1
 local r=row(36)
 local b=make("TextButton",{Size=UDim2.new(1,-28,0,22),
  Position=UDim2.fromOffset(14,7),
  BackgroundColor3=COL.Purple,Text="",AutoButtonColor=false},r)
 round(b,11)
 local bg=make("UIGradient",{Rotation=5},b)
 NX.onAccent(function(a,c2) bg.Color=ColorSequence.new(a,c2) end)
 L(txt(b,{Size=UDim2.fromScale(1,1),TextSize=11,TextColor3=Color3.new(1,1,1),
  TextXAlignment=Enum.TextXAlignment.Center}),en,th)
 b.MouseButton1Click:Connect(cb)
 return b
end
local function statusRow(initEn,initTh)
 ord+=1
 local r=row(26)
 local d=txt(r,{Position=UDim2.fromOffset(14,5),
  Size=UDim2.new(1,-20,0,16),TextSize=9,TextColor3=COL.Sub})
 L(d,initEn,initTh)
 return d
end

-- =========================================================
-- LAG SERVER — CRITICAL FIX
-- S.lagActive is HARDCODED to false on load.
-- The loop is only spawned when the user presses the button.
-- It never runs at script startup.
-- =========================================================

-- Force lagActive off on every script load — never read from saved state
S.lagActive=false

local lagThread=nil
local lagStatusLbl=nil

local RS_rep=game:GetService("ReplicatedStorage")
local GameCorrectionEvents=RS_rep:FindFirstChild("GameCorrectionEvents")
local function getRemote(folder,name)
 if not folder then return nil end
 return folder:FindFirstChild(name)
end

local function stopLag()
 S.lagActive=false
 if lagThread then
  task.cancel(lagThread)
  lagThread=nil
 end
 -- clean up any lag parts we created
 for _,v in ipairs(workspace:GetDescendants()) do
  if v:IsA("BasePart") and v.Name=="__nx_lag_part__" then
   pcall(function() v:Destroy() end)
  end
 end
 if lagStatusLbl then L(lagStatusLbl,"⬛ Stopped","⬛ หยุดแล้ว") end
end

local function startLag()
 if S.lagActive then return end   -- already running
 S.lagActive=true
 if lagStatusLbl then L(lagStatusLbl,"🔴 Active — lagging server","🔴 กำลังทำให้เซิร์ฟแลค") end

 lagThread=task.spawn(function()
  local StopAllVelocity=getRemote(GameCorrectionEvents,"StopAllVelocity")
  local myId=lp.UserId

  -- Part flood table — reuse to avoid memory blowup
  local lagParts={}
  local LAG_PART_COUNT=30

  -- create lag parts once
  for i=1,LAG_PART_COUNT do
   local p=Instance.new("Part")
   p.Name="__nx_lag_part__"
   p.Size=Vector3.new(1,1,1)
   p.Anchored=false
   p.CanCollide=false
   p.Transparency=1
   p.Parent=workspace
   lagParts[i]=p
  end

  while S.lagActive and alive() do
   -- 1) fire StopAllVelocity for every other player
   if StopAllVelocity then
    for _,p in ipairs(Players:GetPlayers()) do
     if p.UserId~=myId and p.Character then
      local hrp=p.Character:FindFirstChild("HumanoidRootPart")
      if hrp then
       pcall(function() StopAllVelocity:FireServer(hrp) end)
      end
     end
    end
   end

   -- 2) physics-spam all lag parts simultaneously
   for _,p in ipairs(lagParts) do
    pcall(function()
     p.CFrame=CFrame.new(math.random(-500,500),math.random(50,200),math.random(-500,500))
     p.AssemblyLinearVelocity=Vector3.new(math.random(-200,200),math.random(-200,200),math.random(-200,200))
    end)
   end

   task.wait(0.03) -- very fast loop = maximum lag on server
  end

  -- clean up parts when loop ends
  for _,p in ipairs(lagParts) do
   pcall(function() p:Destroy() end)
  end
  lagParts={}

  if lagStatusLbl and not S.lagActive then
   L(lagStatusLbl,"⬛ Stopped","⬛ หยุดแล้ว")
  end
 end)
end

-- =========================================================
-- SHUTDOWN SERVER
-- =========================================================
local ShowShutdownEvent=RS_rep:FindFirstChild("ShowShutdownEvent")
local TeleportService=game:GetService("TeleportService")

local function shutdownServer(stayInGame)
 -- 1) fire game's real shutdown remote
 if ShowShutdownEvent then
  pcall(function() ShowShutdownEvent:FireServer() end)
 end

 -- 2) kick all other players via teleport-to-nowhere trick
 for _,p in ipairs(Players:GetPlayers()) do
  if p~=lp then
   pcall(function()
    local ch=p.Character
    if ch then
     local hum=ch:FindFirstChildOfClass("Humanoid")
     if hum then hum.Health=0 end
    end
    TeleportService:TeleportAsync(game.PlaceId,{p})
   end)
  end
 end

 -- 3) handle self
 if not stayInGame then
  task.delay(1.5,function()
   pcall(function() TeleportService:TeleportAsync(game.PlaceId,{lp}) end)
  end)
 end
end

-- =========================================================
-- BUILD UI
-- =========================================================
header("SERVER TOOLS","เครื่องมือเซิร์ฟ",true)

-- LAG SERVER
header("LAG SERVER","ทำให้เซิร์ฟแลค")
do
 local r=row(42)
 titles(r,"Lag Server","ทำให้เซิร์ฟแลค",
  "Everyone lags except you","ทุกคนแลค ยกเว้นเรา")

 -- toggle button (manual on/off — NOT a toggle that persists via state)
 local sw=make("TextButton",{Text="",AutoButtonColor=false,
  Size=UDim2.fromOffset(36,20),Position=UDim2.new(1,-50,.5,-10),
  BackgroundColor3=COL.Bg},r)
 round(sw,10)
 local knob=make("Frame",{Size=UDim2.fromOffset(14,14),
  Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
 round(knob,7)

 local function visualSet(v)
  TS:Create(sw,TI,{BackgroundColor3=v and COL.Purple or COL.Bg}):Play()
  TS:Create(knob,TI,{Position=v and UDim2.fromOffset(19,3) or UDim2.fromOffset(3,3)}):Play()
 end
 NX.onAccent(function() visualSet(S.lagActive) end)

 sw.MouseButton1Click:Connect(function()
  if S.lagActive then
   stopLag()
   visualSet(false)
  else
   startLag()      -- this sets S.lagActive=true internally
   visualSet(true)
  end
 end)
end

-- status label
do
 lagStatusLbl=statusRow("⬛ Stopped","⬛ หยุดแล้ว")
end

-- SHUTDOWN
header("SHUTDOWN SERVER","ปิดเซิร์ฟเวอร์")
do
 local r=row(50)
 titles(r,"Shutdown Server","ปิดเซิร์ฟเวอร์",
  "Kick all, choose to stay or leave","เตะทุกคน เลือกอยู่หรือออก")

 local staying=false -- local UI state only
 local stayBtn=make("TextButton",{
  Size=UDim2.fromOffset(80,20),
  Position=UDim2.new(1,-96,.5,-10),
  BackgroundColor3=COL.Chip,Text="",AutoButtonColor=false},r)
 round(stayBtn,10)
 local stayLbl=txt(stayBtn,{Size=UDim2.fromScale(1,1),TextSize=10,
  TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Center})
 local function updateStay()
  L(stayLbl,staying and "Stay ✓" or "Leave →",staying and "อยู่ ✓" or "ออก →")
  TS:Create(stayBtn,TI,{BackgroundColor3=staying and COL.Purple or COL.Chip}):Play()
 end
 stayBtn.MouseButton1Click:Connect(function() staying=not staying updateStay() end)
 updateStay()
end
actionBtn("⚡ SHUTDOWN NOW","⚡ ปิดเซิร์ฟเวอร์ทันที",function()
 -- read the Stay button state through upvalue 'staying' in row above
 -- Since we can't easily share the upvalue, we store it in NX
 shutdownServer(NX._svStay or false)
end)
-- patch: wire Stay toggle to NX._svStay
do
 local r=row(36)
 titles(r,"Stay in server?","อยู่ในเซิร์ฟต่อ?",
  "Toggle before pressing shutdown","สลับก่อนกด Shutdown")
 local sw=make("TextButton",{Text="",AutoButtonColor=false,
  Size=UDim2.fromOffset(36,20),Position=UDim2.new(1,-50,.5,-10),
  BackgroundColor3=COL.Bg},r)
 round(sw,10)
 local knob=make("Frame",{Size=UDim2.fromOffset(14,14),
  Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
 round(knob,7)
 NX._svStay=false
 local function set(v)
  NX._svStay=v
  TS:Create(sw,TI,{BackgroundColor3=v and COL.Purple or COL.Bg}):Play()
  TS:Create(knob,TI,{Position=v and UDim2.fromOffset(19,3) or UDim2.fromOffset(3,3)}):Play()
 end
 sw.MouseButton1Click:Connect(function() set(not NX._svStay) end)
 NX.onAccent(function() sw.BackgroundColor3=NX._svStay and COL.Purple or COL.Bg end)
end

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
