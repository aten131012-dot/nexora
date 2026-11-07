--[[
 NEXORA HUB v2  (ไฟล์เดียวรวมทุกส่วน)
 แก้ค่าตั้งต้นได้ที่ CFG ด้านล่าง โดยเฉพาะ DISCORD_LINK
]]
local CFG={
  LOGO_ID="91144361769901",
 LOGO_DARK=Color3.fromRGB(255,255,255), -- ขาวเต็ม = รูปแสดงสีจริง
 DISCORD_ICON_ID="17056354182",
 DISCORD_LINK="https://discord.gg/vHRMNpDsQ4", -- <<< ใส่ลิงก์ดิสคอสของคุณตรงนี้
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
 Bg=Color3.fromRGB(4,4,6),
 Side=Color3.fromRGB(16,16,19),
 Chip=Color3.fromRGB(26,26,31),
 Purple=Color3.fromRGB(95,95,105),
 Pink=Color3.fromRGB(240,240,245),
 Text=Color3.fromRGB(242,242,246),
 Sub=Color3.fromRGB(150,150,160),
 Red=Color3.fromRGB(255,80,110),
 Green=Color3.fromRGB(90,230,160),
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
 onAccent(function(a,b) g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,b),ColorSequenceKeypoint.new(.5,Color3.fromRGB(55,55,62)),ColorSequenceKeypoint.new(1,b)}) end)
 TS:Create(g,TweenInfo.new(2.5,LIN,Enum.EasingDirection.In,-1),{Rotation=360}):Play()
 return s
end

-- ⚡ สายฟ้า: เส้นหักมุมสุ่ม (พิกัดหน่วยเดียวกับพื้นที่ที่วาด)
local function bolt(par,x1,y1,x2,y2,col,th,segs,life)
 th=th or 2 segs=segs or 8 life=life or .35
 local dx,dy=x2-x1,y2-y1
 local dist=math.max(math.sqrt(dx*dx+dy*dy),1)
 local nx,ny=-dy/dist,dx/dist
 local pts={{x1,y1}}
 for i=1,segs-1 do
  local t=i/segs
  local j=(math.random()-.5)*dist*.22
  pts[#pts+1]={x1+dx*t+nx*j,y1+dy*t+ny*j}
 end
 pts[#pts+1]={x2,y2}
 local hold=make("Frame",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=6},par)
 local parts={}
 for i=1,#pts-1 do
  local a,b=pts[i],pts[i+1]
  local sx,sy=b[1]-a[1],b[2]-a[2]
  local len=math.sqrt(sx*sx+sy*sy)
  local ang=math.deg(math.atan2(sy,sx))
  for k=1,2 do
   parts[#parts+1]=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset((a[1]+b[1])/2,(a[2]+b[2])/2),Size=UDim2.fromOffset(len+th*((k==1) and 4 or 1),th*((k==1) and 3.5 or 1)),Rotation=ang,BackgroundColor3=col,BackgroundTransparency=(k==1) and .8 or 0,BorderSizePixel=0,ZIndex=6+k},hold)
  end
 end
 task.delay(life*.35,function()
  for _,f in ipairs(parts) do TS:Create(f,TweenInfo.new(life*.65),{BackgroundTransparency=1}):Play() end
 end)
 task.delay(life+.05,function() hold:Destroy() end)
 -- กิ่งแตกกลางสาย
 if segs>=6 then
  local m=pts[math.ceil(#pts/2)]
  bolt(par,m[1],m[2],m[1]+(math.random()-.5)*dist*.5,m[2]+dist*.25,col,th*.6,4,life)
 end
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
 make("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(30,14,66),Color3.fromRGB(3,2,10)),Rotation=90},bgl)

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
 neb(.2,.25,520,Color3.fromRGB(110,50,210),.06,.08,8)
 neb(.8,.75,560,Color3.fromRGB(40,80,220),-.07,-.06,10)
 neb(.75,.15,380,Color3.fromRGB(220,70,190),-.05,.08,7)

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
 ring(208,2.5,Color3.fromRGB(110,220,255),COL.Purple,2.4,true)
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
make("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(22,12,50),Color3.fromRGB(5,4,14)),Rotation=90},bgf)
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
  for i=1,4 do
   local k=1-(i-1)*.2
   local c=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(k,k),BackgroundColor3=col,BackgroundTransparency=.93,BorderSizePixel=0},h)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},c)
  end
  TS:Create(h,TweenInfo.new(t,SINE,IO,-1,true),{Position=UDim2.fromScale(x+dx,y+dy)}):Play()
 end
 blob(.15,.25,280,Color3.fromRGB(110,50,210),.08,.1,9)
 blob(.85,.8,320,Color3.fromRGB(40,80,220),-.1,-.08,11)
 blob(.6,.1,220,Color3.fromRGB(220,70,190),-.06,.12,8)

 for i=1,52 do
  local sz=math.random(1,2)+((math.random()<.12) and 1 or 0)
  local s=make("Frame",{Position=UDim2.fromScale(math.random(),math.random()),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(math.random()<.3) and COL.Pink or Color3.new(1,1,1),BackgroundTransparency=math.random(30,70)/100,BorderSizePixel=0},space)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},s)
  TS:Create(s,TweenInfo.new(math.random(8,25)/10,SINE,IO,-1,true),{BackgroundTransparency=.95}):Play()
 end

 local planet=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.95,.07),Size=UDim2.fromOffset(60,60),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.3},space)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},planet)
 make("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(200,130,255),Color3.fromRGB(35,18,85)),Rotation=45},planet)
 local ringp=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(104,26),BackgroundTransparency=1,Rotation=-22},planet)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},ringp)
 make("UIStroke",{Color=COL.Pink,Thickness=2,Transparency=.5},ringp)
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
local menu=make("ScrollingFrame",{Size=UDim2.new(1,0,1,-56),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},side)
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
 return L(make("TextLabel",{LayoutOrder=ord,Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left},menu),en,th)
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
local sysLabel=section("SYSTEM","ระบบ")
addPage("settings","☼","SETTINGS","SETTINGS")
selectPage("home")

-- ===== โลโก้ลอย + เอฟเฟกต์ =====
local LS=52
local logo=make("ImageButton",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(0,0),Position=UDim2.new(0,42,.5,0),BackgroundColor3=COL.Bg,Image="",AutoButtonColor=false},gui)
round(logo,26) glow(logo,1.5)
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
  if not open and fxOn then ripple() end
  task.wait(2.4)
 end
end)

getgenv().NX={COL=COL,make=make,round=round,glow=glow,L=L,setLang=setLang,getLang=function() return lang end,
 onLang=function(fn) langHooks[#langHooks+1]=fn end,
 content=content,sub=sub,side=side,pages=pages,onAccent=onAccent,setAccent=setAccent,setSpace=setSpace,
 setLogoFx=setLogoFx,resetPos=resetPos,setImg=setImg,CFG=CFG,gui=gui,
 state=state,win=win,sc=sc,setOpen=setOpen,isOpen=function() return open end,
 addPage=addPage,section=section,btns=btns,sysLabel=sysLabel,menu=menu}

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
local ag=make("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(90,50,200)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(30,20,90)),ColorSequenceKeypoint.new(1,Color3.fromRGB(190,100,240))})},aur)
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
make("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(88,101,242),Color3.fromRGB(140,90,255)),Rotation=0},dc)
make("UIStroke",{Color=Color3.new(1,1,1),Transparency=.75,Thickness=1},dc)
local dci=make("ImageLabel",{Position=UDim2.fromOffset(9,5),Size=UDim2.fromOffset(28,28),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit},dc)
NX.setImg(dci,NX.CFG.DISCORD_ICON_ID)
txt(dc,{Position=UDim2.fromOffset(46,4),Size=UDim2.new(1,-140,0,16),Text="Discord",Font=Enum.Font.GothamBlack,TextSize=14,TextColor3=Color3.new(1,1,1)})
local dsub=L(txt(dc,{Position=UDim2.fromOffset(46,21),Size=UDim2.new(1,-140,0,12),Font=Enum.Font.Gotham,TextSize=9,TextColor3=Color3.fromRGB(228,230,255),TextTruncate=Enum.TextTruncate.AtEnd}),"Copy invite link","คัดลอกลิงก์เชิญ")
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
local function save() pcall(function() if writefile then writefile(FILE,HttpService:JSONEncode(S)) end end) end
NX.save=save
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
local PRESETS={
 {Color3.fromRGB(140,80,255),Color3.fromRGB(215,125,255)},
 {Color3.fromRGB(50,130,255),Color3.fromRGB(110,220,255)},
 {Color3.fromRGB(255,70,160),Color3.fromRGB(255,150,210)},
 {Color3.fromRGB(35,200,120),Color3.fromRGB(140,255,190)},
 {Color3.fromRGB(255,130,40),Color3.fromRGB(255,205,90)},
}
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
 ctrls.accent=function(i) S.accent=i mark() NX.setAccent(PRESETS[i][1],PRESETS[i][2]) end
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
-- NEXORA FEATURES : ฟีเจอร์จากสคริปต์เดิม แยกเป็นหมวดในเมนูข้าง (TH/EN)
------------------------------------------------------------------
do
local okA,Adapter=pcall(function()
local NX=getgenv().NX
local COL,make,round,L=NX.COL,NX.make,NX.round,NX.L
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local TI=TweenInfo.new(.2,Enum.EasingStyle.Quint)
local LEFT=Enum.TextXAlignment.Left
local CEN=Enum.TextXAlignment.Center
local RIGHT=Enum.TextXAlignment.Right

-- ตั้งเป็น true ถ้าอยากให้มีหน้า "Scripts Extras" (ปุ่มโหลดสคริปต์จาก pastebin ภายนอก)
local SHOW_EXTRAS=false

local function T(en,th) return (NX.getLang()=="TH") and th or en end

-- ตารางแปล สเปน -> {อังกฤษ, ไทย}
local TR={
 ["Cabeza"]={"Head","หัว"},
 ["Torso"]={"Torso","ลำตัว"},
 ["Cuerpo Completo"]={"Full body","ทั้งตัว"},
 ["Ninguna"]={"None","ไม่มี"},
 ["Right Platforms"]={"Right platforms","แท่นฝั่งขวา"},
 ["Left Platforms"]={"Left platforms","แท่นฝั่งซ้าย"},
 ["Revolver + Recarga"]={"Revolver + Reload","รีวอลเวอร์ + รีโหลด"},
 ["Magia de Anime"]={"Anime Magic","เวทมนตร์อนิเมะ"},
 ["Láser + Recarga láser"]={"Laser + Laser Reload","เลเซอร์ + รีโหลดเลเซอร์"},
 ["Midnight"]={"Midnight","เที่ยงคืน"},
 ["Dark"]={"Dark","มืด"},
 ["Red"]={"Red","แดง"},
 ["Indigo"]={"Indigo","คราม"},

 ["Gráficos"]={"Graphics","กราฟิก"},
 ["Presets de Iluminación"]={"Lighting presets","พรีเซ็ตแสง"},
 ["Noche Sangrienta"]={"Bloody Night","คืนเลือด"},
 ["Atardecer Fantástico"]={"Fantasy Sunset","พระอาทิตย์ตกในฝัน"},
 ["Sin Vida"]={"Lifeless","ไร้ชีวิต"},

 ["Botones flotantes"]={"Floating buttons","ปุ่มลอยบนจอ"},
 ["Mostrar botones flotantes"]={"Show floating buttons","แสดงปุ่มลอย"},
 ["Restablecer posiciones"]={"Reset positions","รีเซ็ตตำแหน่ง"},

 ["Auto Shoot"]={"Auto Shoot","ยิงอัตโนมัติ"},
 ["Auto Shoot (Normal - Cabeza/Torso)"]={"Auto Shoot (Normal - Head/Torso)","ยิงอัตโนมัติ (ปกติ - หัว/ลำตัว)"},
 ["Auto Shoot (Agresivo - Hitbox Completa)"]={"Auto Shoot (Aggressive - Full hitbox)","ยิงอัตโนมัติ (ดุดัน - ฮิตบ็อกซ์เต็มตัว)"},
 ["Target: Parte del cuerpo"]={"Target: Body part","เป้าหมาย: ส่วนของร่างกาย"},
 ["Equipar pistola"]={"Equip gun","ถือปืนอัตโนมัติ"},
 ["Silent Aim + Fov"]={"Silent Aim + FOV","Silent Aim + FOV"},
 ["Silent Aim"]={"Silent Aim","Silent Aim"},
 ["Silent Aim (Con FOV)"]={"Silent Aim (with FOV)","Silent Aim (มีวง FOV)"},
 ["Mostrar Círculo FOV"]={"Show FOV circle","แสดงวงกลม FOV"},
 ["Tamaño del FOV"]={"FOV size","ขนาด FOV"},

 ["Kill All"]={"Kill All","Kill All"},
 ["Hitbox Expander"]={"Hitbox expander","ขยายฮิตบ็อกซ์"},
 ["Activar Hitbox"]={"Enable hitbox","เปิดฮิตบ็อกซ์"},
 ["Hitbox Invisible"]={"Invisible hitbox","ฮิตบ็อกซ์ล่องหน"},
 ["Tamaño de la Hitbox"]={"Hitbox size","ขนาดฮิตบ็อกซ์"},
 ["Color de la Hitbox"]={"Hitbox color","สีฮิตบ็อกซ์"},

 ["Invisible"]={"Invisible","ล่องหน"},

 ["Tramposo"]={"Movement","การเคลื่อนไหว"},
 ["Speed"]={"Speed","ความเร็ว"},
 ["Ajuste Speed"]={"Speed value","ปรับความเร็ว"},
 ["Salto Inf"]={"Infinite jump","กระโดดไม่จำกัด"},
 ["Ajuste Salto"]={"Jump power","ปรับแรงกระโดด"},

 ["Auto Teleport Main/Alt"]={"Auto Teleport Main/Alt","วาร์ปอัตโนมัติ หลัก/รอง"},
 ["Auto Teleport (Main)"]={"Auto Teleport (Main)","วาร์ปอัตโนมัติ (บัญชีหลัก)"},
 ["Auto Teleport (Alt)"]={"Auto Teleport (Alt)","วาร์ปอัตโนมัติ (บัญชีรอง)"},
 ["Tipo de Duelo"]={"Duel type","ประเภทดวล"},
 ["Fila de Plataformas"]={"Platform row","แถวแท่น"},

 ["Configuración de ESP"]={"ESP settings","ตั้งค่า ESP"},
 ["ESP Jugadores"]={"Player ESP","ESP ผู้เล่น"},
 ["Color del ESP"]={"ESP color","สี ESP"},
 ["Filtros de ESP"]={"ESP filters","ตัวกรอง ESP"},
 ["Mostrar Resplandor"]={"Show glow","แสดงเรืองแสง"},

 ["Farmeo de Evento"]={"Event farming","ฟาร์มอีเวนต์"},
 ["Auto Farmear Evento"]={"Auto farm event","ฟาร์มอีเวนต์อัตโนมัติ"},

 ["Paquetes Completos"]={"Full packs","ชุดแอนิเมชันเต็ม"},
 ["Elegir Paquete"]={"Choose pack","เลือกชุด"},
 ["Aplicar Paquete Completo"]={"Apply full pack","ใช้ชุดเต็ม"},
 ["Restaurar Default"]={"Restore default","คืนค่าเดิม"},
 ["Mezclador de Animaciones"]={"Animation mixer","ผสมแอนิเมชัน"},
 ["Reposo"]={"Idle","ยืนนิ่ง"},
 ["Caminar"]={"Walk","เดิน"},
 ["Correr"]={"Run","วิ่ง"},
 ["Saltar"]={"Jump","กระโดด"},
 ["Caer"]={"Fall","ตก"},
 ["Escalar"]={"Climb","ปีน"},
 ["Combinar y Aplicar"]={"Mix & apply","ผสมและใช้"},

 ["Sonido de Muerte"]={"Kill sound","เสียงตอนฆ่า"},
 ["Sonido de Kill"]={"Play kill sound","เปิดเสียงตอนฆ่า"},
 ["Sonido de muerte"]={"Kill sound choice","เลือกเสียงตอนฆ่า"},
 ["Disparo y Recarga"]={"Shoot & reload","ยิงและรีโหลด"},
 ["Recarga + disparo"]={"Reload + shoot sounds","เสียงรีโหลด + ยิง"},
 ["Sonido de disparo"]={"Shot sound","เสียงยิง"},
 ["Volumen"]={"Volume","ระดับเสียง"},

 ["Ahora suena"]={"Now playing","กำลังเล่น"},
 ["Sin canción seleccionada"]={"No song selected","ยังไม่ได้เลือกเพลง"},
 ["Controles"]={"Controls","ปุ่มควบคุม"},
 ["Anterior"]={"Previous","ก่อนหน้า"},
 ["Siguiente"]={"Next","ถัดไป"},
 ["Reproducir"]={"Play","เล่น"},
 ["Pausar"]={"Pause","พัก"},
 ["Detener"]={"Stop","หยุด"},

 ["Aplicar Headless"]={"Apply Headless","ใส่ Headless"},
 ["Aplicar Korblox"]={"Apply Korblox","ใส่ Korblox"},

 ["identidad falsa"]={"Fake identity","ตัวตนปลอม"},
 ["Activar Nombre Falso"]={"Enable fake name","เปิดชื่อปลอม"},
 ["Nuevo Nombre"]={"New name","ชื่อใหม่"},
 ["Escribe tu nombre falso..."]={"Type your fake name...","พิมพ์ชื่อปลอมของคุณ..."},

 ["Gestor de Configs"]={"Config manager","จัดการคอนฟิก"},
 ["Seleccionar Configuración"]={"Select config","เลือกคอนฟิก"},
 ["Actualizar Lista"]={"Refresh list","รีเฟรชรายการ"},
 ["Nombre para Guardar"]={"Save name","ชื่อที่จะบันทึก"},
 ["Ej: Config 1, Config 2..."]={"e.g. Config 1, Config 2...","เช่น Config 1, Config 2..."},
 ["Eliminar todos los guardados"]={"Delete all saves","ลบคอนฟิกทั้งหมด"},
 ["Guardar Configuración"]={"Save config","บันทึกคอนฟิก"},
 ["Cargar Configuración"]={"Load config","โหลดคอนฟิก"},

 ["Seleccionar fondo"]={"Select background","เลือกพื้นหลัง"},
 ["Aplicar"]={"Apply","ใช้"},
 ["Tema de la Interfaz"]={"UI theme","ธีมหน้าจอ"},
 ["Seleccionar Tema"]={"Select theme","เลือกธีม"},
 ["Scripts Extras"]={"Extra scripts","สคริปต์เสริม"},
 ["Copiar avatares"]={"Copy avatars","คัดลอกอวาตาร์"},
 ["mm2_legend"]={"● Innocent   ● Murderer   ● Sheriff   ● Gun","● คนธรรมดา   ● ฆาตกร   ● นายอำเภอ   ● ปืน"},
 ["mm2_secRadar"]={"Radar (ESP)","เรดาร์ (ESP)"},
 ["mm2_espRoles"]={"👁️ Role radar (through walls)","👁️ เรดาร์บทบาท (มองทะลุกำแพง)"},
 ["mm2_espGun"]={"🔫 Dropped gun scan","🔫 สแกนปืนตก"},
 ["mm2_espLine"]={"📏 Target lines","📏 เส้นล็อกเป้า"},
 ["mm2_espBox"]={"🟥 Target box + health bar","🟥 กรอบเป้าหมาย + หลอดเลือด"},
 ["mm2_xray"]={"🩻 X-ray (see-through map)","🩻 X-RAY มองทะลุแมพ"},
 ["mm2_secWarp"]={"Warp","วาร์ป"},
 ["mm2_wGun"]={"🔫 Auto grab gun (as innocent)","🔫 ดูดปืนอัตโนมัติ (คนธรรมดา)"},
 ["mm2_wMurder"]={"🔪 TP to murderer","🔪 ไปหาฆาตกร"},
 ["mm2_wSheriff"]={"🔫 TP to sheriff","🔫 ไปหานายอำเภอ"},
 ["mm2_wList"]={"👥 Select player","👥 เลือกผู้เล่น"},
 ["mm2_wGo"]={"🌀 TP to selected","🌀 วาร์ปไปหาเป้าหมาย"},
 ["mm2_secFling"]={"Fling","ฟลิ้ง"},
 ["mm2_fSheriff"]={"💥 Fling sheriff","💥 ฟลิ้ง นายอำเภอ"},
 ["mm2_fMurder"]={"💥 Fling murderer","💥 ฟลิ้ง ฆาตกร"},
 ["mm2_fGo"]={"💥 Fling selected","💥 ฟลิ้งเป้าหมาย"},
 ["mm2_secHunter"]={"Hunter mode","โหมดล่า"},
 ["mm2_mAuto"]={"🗡️ Auto kill (stab each player)","🗡️ ออโต้ฆ่า (แทงทีละคน)"},
 ["mm2_mAll"]={"💀 Kill all (pull in front)","💀 ฆ่าทั้งแมพ (ลากมาหน้า)"},
 ["mm2_mThrow"]={"🎯 Knife button (right side)","🎯 ปุ่มปามีด (ขวาจอ)"},
 ["mm2_sShoot"]={"🔫 Shoot button (right side)","🔫 ปุ่มยิงฆาตกร (ขวาจอ)"},
 ["mm2_aThrow"]={"🔪 Auto throw (visible only)","🔪 ปามีดอัตโนมัติ (เห็นตัวเท่านั้น)"},
 ["mm2_aShoot"]={"🎯 Auto shoot (visible only)","🎯 ยิงอัตโนมัติ (เห็นตัวเท่านั้น)"},
 ["mm2_secPlayer"]={"Player","ตัวละคร"},
 ["mm2_pNoclip"]={"👻 Ghost mode (noclip)","👻 โหมดผี (ทะลุ)"},
 ["mm2_pSpeed"]={"⚡ Speed +100","⚡ สปีด +100"},
 ["mm2_pJump"]={"🦘 Jump +100","🦘 กระโดด +100"},
 ["mm2_pFly"]={"🕊️ Fly mode","🕊️ โหมดบิน"},
 ["mm2_pTp"]={"📍 Click TP (TP NEXORA tool)","📍 วาร์ปจิ้มจอ (เครื่องมือ TP NEXORA)"},
 ["mm2_pAnti"]={"🛡️ Anti-fling","🛡️ กันฟลิ้ง"},
 ["mm2_secFarm"]={"Farm","ฟาร์ม"},
 ["mm2_cfCoin"]={"🪙 Coin float farm (speed 20, max 40)","🪙 ฟาร์มเหรียญลอย (ความเร็ว 20 ครบ 40)"},
 ["mm2_afk"]={"💤 Anti-AFK","💤 ANTI-AFK กันโดนเตะ"},
 ["mm2_candy"]={"🍬 Auto collect candy","🍬 ออโต้เก็บแคนดี้"},
 ["mm2_secAuto"]={"Auto event","ออโต้อีเวนท์"},
 ["mm2_claim"]={"🎁 Auto claim event rewards","🎁 ออโต้รับรางวัลอีเวนท์"},
 ["mm2_buy"]={"🛒 Auto buy event shop items","🛒 ออโต้ซื้อของอีเวนท์ในร้าน"},
 ["mm2_box"]={"📦 Auto open event mystery box","📦 ออโต้เปิดกล่องสุ่มอีเวนท์"},
 ["mm2_secSpots"]={"Lobby spots","จุดร้านค้าในล็อบบี้"},
 ["mm2_pCraft"]={"🔨 Open crafting","🔨 เปิดหน้าคราฟต์"},
 ["mm2_pBox"]={"📦 Open mystery box shop","📦 เปิดร้านกล่องสุ่ม"},
 ["mm2_pBundle"]={"🎒 Open item bundle shop","🎒 เปิดร้านชุดไอเทม"},
 ["mm2_pKnife"]={"🔪 Open knife shop","🔪 เปิดร้านมีด"},
 ["mm2_pGun"]={"🔫 Open gun shop","🔫 เปิดร้านปืน"},
 ["mm2_secEvent"]={"Event","อีเวนท์"},
 ["mm2_evHint"]={"Event items found on the map get their own switch here. Empty = no event right now.","ของอีเวนท์ที่เจอในแมพจะมีสวิตช์ให้ที่นี่ ถ้าว่าง = ตอนนี้ไม่มีอีเวนท์"},
}
local function tr(s)
 s=tostring(s or "")
 local e=TR[s]
 if e then return e[1],e[2] end
 return s,s
end

local function call(cb,where,...)
 if type(cb)~="function" then return end
 local ok,err=pcall(cb,...)
 if not ok then warn("[Nexora] "..tostring(where)..": "..tostring(err)) end
end

local function txt(p,props)
 props.BackgroundTransparency=1
 props.Font=props.Font or Enum.Font.GothamBold
 props.TextColor3=props.TextColor3 or COL.Text
 props.TextXAlignment=props.TextXAlignment or LEFT
 return make("TextLabel",props,p)
end

local function isPtr(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
local function isMove(i) return i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch end

local function newTab(sf)
 local tab={}
 local ord=0
 local function nxt() ord+=1 return ord end

 local function row(h,parent)
  local r=make("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},parent or sf)
  if not parent then r.LayoutOrder=nxt() end
  round(r,14)
  local s=make("UIStroke",{Color=COL.Pink,Transparency=.65,Thickness=1},r)
  NX.onAccent(function(a,b) s.Color=b end)
  return r
 end
 local function wrapper()
  local w=make("Frame",{LayoutOrder=nxt(),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},sf)
  make("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},w)
  return w
 end
 local function label(r,title,rightPad,top)
  local en,th=tr(title)
  local l=txt(r,{Position=UDim2.fromOffset(14,top and 6 or 0),Size=UDim2.new(1,-(rightPad or 70),0,top and 16 or 38),TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd})
  if not top then l.Size=UDim2.new(1,-(rightPad or 70),1,0) end
  L(l,en,th)
  return l
 end

 ---------------- Section / Space / Divider ----------------
 function tab:Section(o)
  local en,th=tr(o and o.Title or "")
  local l=txt(sf,{LayoutOrder=nxt(),Size=UDim2.new(1,0,0,16),TextSize=10,TextColor3=COL.Pink})
  L(l,string.upper(en),th)
  return {}
 end
 function tab:Space() end
 function tab:Divider() end

 ---------------- Toggle ----------------
 function tab:Toggle(o)
  local r=row(38)
  label(r,o.Title,70)
  local sw=make("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-52,.5,-10),BackgroundColor3=COL.Bg},r)
  round(sw,10)
  local knob=make("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
  round(knob,7)
  local obj={Value=(o.Value and true or false)}
  local function paint(anim)
   local v=obj.Value
   local pos=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)
   local col=v and COL.Purple or COL.Bg
   if anim then
    TS:Create(sw,TI,{BackgroundColor3=col}):Play()
    TS:Create(knob,TI,{Position=pos}):Play()
   else
    sw.BackgroundColor3=col knob.Position=pos
   end
  end
  function obj:Set(v)
   obj.Value=(v and true or false)
   paint(true)
   call(o.Callback,o.Title,obj.Value)
  end
  sw.MouseButton1Click:Connect(function() obj:Set(not obj.Value) end)
  NX.onAccent(function() paint(false) end)
  return obj
 end

 ---------------- Button ----------------
 function tab:Button(o)
  local r=row(38)
  label(r,o.Title,110)
  local b=make("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(84,26),BackgroundColor3=COL.Purple,Text="",AutoButtonColor=false},r)
  round(b,13)
  local variant=o.Variant
  NX.onAccent(function(a,c2)
   if variant=="Danger" then b.BackgroundColor3=COL.Red
   elseif variant=="Secondary" then b.BackgroundColor3=c2
   else b.BackgroundColor3=a end
  end)
  L(txt(b,{Size=UDim2.fromScale(1,1),TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=CEN}),"Run","กด")
  b.MouseButton1Click:Connect(function() call(o.Callback,o.Title) end)
  local obj={}
  function obj:Set() end
  return obj
 end

 ---------------- Slider ----------------
 function tab:Slider(o)
  local cfg=o.Value or {}
  local min,max=cfg.Min or 0,cfg.Max or 100
  local step=o.Step or 1
  if step<=0 then step=1 end
  local default=cfg.Default or min
  local dec=0
  if step<1 then dec=(step<.1) and 2 or 1 end
  local r=row(50)
  label(r,o.Title,100,true)
  local vl=txt(r,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,6),Size=UDim2.fromOffset(70,16),TextSize=11,TextColor3=COL.Pink,TextXAlignment=RIGHT})
  local track=make("Frame",{Position=UDim2.new(0,14,0,34),Size=UDim2.new(1,-28,0,6),BackgroundColor3=COL.Bg},r)
  round(track,3)
  local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=COL.Purple},track)
  round(fill,3)
  local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.new(1,1,1)},track)
  round(knob,7)
  NX.onAccent(function(a) fill.BackgroundColor3=a end)
  local hit=make("TextButton",{Text="",BackgroundTransparency=1,Position=UDim2.new(0,14,0,22),Size=UDim2.new(1,-28,0,26)},r)
  local obj={Value=default}
  local function snap(x)
   x=math.clamp(x,min,max)
   x=min+math.floor((x-min)/step+.5)*step
   return math.clamp(x,min,max)
  end
  local function show(x)
   local t=(max>min) and (x-min)/(max-min) or 0
   fill.Size=UDim2.fromScale(t,1)
   knob.Position=UDim2.fromScale(t,.5)
   vl.Text=string.format("%."..dec.."f",x)
  end
  function obj:Set(x,silent)
   x=snap(tonumber(x) or default)
   obj.Value=x
   show(x)
   if not silent then call(o.Callback,o.Title,x) end
  end
  local dragging=false
  local function fromX(px)
   local t=math.clamp((px-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
   local x=snap(min+(max-min)*t)
   if x~=obj.Value then
    obj.Value=x show(x)
    call(o.Callback,o.Title,x)
   end
  end
  hit.InputBegan:Connect(function(i) if isPtr(i) then dragging=true fromX(i.Position.X) end end)
  UIS.InputChanged:Connect(function(i) if dragging and isMove(i) then fromX(i.Position.X) end end)
  UIS.InputEnded:Connect(function(i) if dragging and isPtr(i) then dragging=false end end)
  obj:Set(default,true)
  return obj
 end

 ---------------- Dropdown ----------------
 function tab:Dropdown(o)
  local wrap=wrapper()
  local head=row(38,wrap)
  head.LayoutOrder=1
  label(head,o.Title,160)
  local vb=make("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(130,26),BackgroundColor3=COL.Bg,Text="",AutoButtonColor=false},head)
  round(vb,13)
  local vtxt=txt(vb,{Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-24,1,0),TextSize=10,TextColor3=COL.Pink,TextTruncate=Enum.TextTruncate.AtEnd})
  local arrow=txt(vb,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,0),Size=UDim2.fromOffset(12,26),Text="▾",TextSize=11,TextColor3=COL.Sub,TextXAlignment=CEN})
  local list=make("ScrollingFrame",{LayoutOrder=2,Visible=false,Size=UDim2.new(1,0,0,100),BackgroundColor3=COL.Chip,BackgroundTransparency=.4,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},wrap)
  round(list,12)
  make("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},list)
  make("UIPadding",{PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)},list)
  local obj={Value=o.Value,Values={}}
  local optBtns={}
  local function display(v)
   if v==nil then return "—" end
   local en,th=tr(v)
   return T(en,th)
  end
  local function mark()
   for v,b in pairs(optBtns) do
    b.BackgroundColor3=(v==obj.Value) and COL.Purple or COL.Bg
   end
   vtxt.Text=display(obj.Value)
  end
  local function build(values)
   for _,b in pairs(optBtns) do b:Destroy() end
   optBtns={}
   obj.Values=values or {}
   local n=0
   for i,v in ipairs(obj.Values) do
    local b=make("TextButton",{LayoutOrder=i,Size=UDim2.new(1,0,0,24),BackgroundColor3=COL.Bg,Text=display(v),Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Text,AutoButtonColor=false,TextTruncate=Enum.TextTruncate.AtEnd},list)
    round(b,10)
    optBtns[v]=b
    b.MouseButton1Click:Connect(function()
     list.Visible=false arrow.Text="▾"
     obj:Select(v)
    end)
    n+=1
   end
   list.Size=UDim2.new(1,0,0,math.min(n,6)*27+8)
   mark()
  end
  function obj:Select(v)
   obj.Value=v
   mark()
   call(o.Callback,o.Title,v)
  end
  function obj:Set(v) obj:Select(v) end
  function obj:Refresh(values) build(values) end
  vb.MouseButton1Click:Connect(function()
   list.Visible=not list.Visible
   arrow.Text=list.Visible and "▴" or "▾"
  end)
  NX.onLang(function()
   mark()
   for v,b in pairs(optBtns) do b.Text=display(v) end
  end)
  NX.onAccent(function() mark() end)
  build(o.Values)
  return obj
 end

 ---------------- Colorpicker ----------------
 function tab:Colorpicker(o)
  local wrap=wrapper()
  local head=row(38,wrap)
  head.LayoutOrder=1
  label(head,o.Title,70)
  local start=o.Default or Color3.new(1,1,1)
  local sw=make("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.fromOffset(36,22),BackgroundColor3=start,Text="",AutoButtonColor=false},head)
  round(sw,11)
  make("UIStroke",{Color=Color3.new(1,1,1),Transparency=.6,Thickness=1},sw)
  local panel=make("Frame",{LayoutOrder=2,Visible=false,Size=UDim2.new(1,0,0,88),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},wrap)
  round(panel,12)
  local obj={Value=start}
  local chans={}
  local function setColor(c,fire)
   obj.Value=c
   sw.BackgroundColor3=c
   local vals={c.R,c.G,c.B}
   for i=1,3 do
    if chans[i] then chans[i].show(math.floor(vals[i]*255+.5)) end
   end
   if fire then call(o.Callback,o.Title,c) end
  end
  local names={"R","G","B"}
  local cols={Color3.fromRGB(255,80,110),Color3.fromRGB(90,230,160),Color3.fromRGB(90,150,255)}
  for i=1,3 do
   local y=6+(i-1)*26
   txt(panel,{Position=UDim2.fromOffset(12,y),Size=UDim2.fromOffset(14,20),Text=names[i],TextSize=10,TextColor3=COL.Sub})
   local track=make("Frame",{Position=UDim2.new(0,32,0,y+7),Size=UDim2.new(1,-86,0,6),BackgroundColor3=COL.Bg},panel)
   round(track,3)
   local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=cols[i]},track)
   round(fill,3)
   local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(12,12),BackgroundColor3=Color3.new(1,1,1)},track)
   round(knob,6)
   local val=txt(panel,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,y),Size=UDim2.fromOffset(34,20),TextSize=10,TextColor3=COL.Pink,TextXAlignment=RIGHT})
   local hit=make("TextButton",{Text="",BackgroundTransparency=1,Position=UDim2.new(0,32,0,y),Size=UDim2.new(1,-86,0,20)},panel)
   local ch={v=0}
   function ch.show(n)
    ch.v=n
    fill.Size=UDim2.fromScale(n/255,1)
    knob.Position=UDim2.fromScale(n/255,.5)
    val.Text=tostring(n)
   end
   chans[i]=ch
   local dragging=false
   local function fromX(px)
    local t=math.clamp((px-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
    ch.v=math.floor(t*255+.5)
    local a,b,c=chans[1] and chans[1].v or 0,chans[2] and chans[2].v or 0,chans[3] and chans[3].v or 0
    setColor(Color3.fromRGB(a,b,c),true)
   end
   hit.InputBegan:Connect(function(inp) if isPtr(inp) then dragging=true fromX(inp.Position.X) end end)
   UIS.InputChanged:Connect(function(inp) if dragging and isMove(inp) then fromX(inp.Position.X) end end)
   UIS.InputEnded:Connect(function(inp) if dragging and isPtr(inp) then dragging=false end end)
  end
  setColor(start,false)
  sw.MouseButton1Click:Connect(function() panel.Visible=not panel.Visible end)
  function obj:Update(c) if typeof(c)=="Color3" then setColor(c,true) end end
  function obj:Set(c) obj:Update(c) end
  return obj
 end

 ---------------- Input ----------------
 function tab:Input(o)
  local r=row(38)
  label(r,o.Title,190)
  local box=make("TextBox",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(170,26),BackgroundColor3=COL.Bg,Text=o.Value or "",PlaceholderColor3=COL.Sub,TextColor3=COL.Text,Font=Enum.Font.Gotham,TextSize=11,ClearTextOnFocus=false,TextXAlignment=LEFT},r)
  round(box,13)
  make("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},box)
  local function ph()
   local en,th=tr(o.Placeholder or "")
   box.PlaceholderText=T(en,th)
  end
  ph()
  NX.onLang(ph)
  box.FocusLost:Connect(function() call(o.Callback,o.Title,box.Text) end)
  local obj={Value=box.Text}
  function obj:Set(t) box.Text=tostring(t) obj.Value=box.Text call(o.Callback,o.Title,box.Text) end
  return obj
 end

 ---------------- Paragraph ----------------
 function tab:Paragraph(o)
  local r=make("Frame",{LayoutOrder=nxt(),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=COL.Chip,BackgroundTransparency=.4},sf)
  round(r,14)
  local s=make("UIStroke",{Color=COL.Pink,Transparency=.65,Thickness=1},r)
  NX.onAccent(function(a,b) s.Color=b end)
  make("UIPadding",{PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8),PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)},r)
  make("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},r)
  local t=txt(r,{LayoutOrder=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextSize=12,TextWrapped=true})
  local d=txt(r,{LayoutOrder=2,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Font=Enum.Font.Gotham,TextSize=10,TextColor3=COL.Sub,TextWrapped=true,Text="",Visible=false})
  local en,th=tr(o.Title or "")
  L(t,en,th)
  if o.Desc then d.Text=o.Desc d.Visible=true end
  local obj={}
  function obj:SetTitle(s2) t.Text=tostring(s2) end
  function obj:SetDesc(s2) d.Text=tostring(s2) d.Visible=(tostring(s2)~="") end
  return obj
 end

 return tab
end

local function createTab(key,icon,en,th,hidden)
 local host
 if hidden then host=Instance.new("Frame") else host=NX.addPage("f_"..key,icon,en,th) end
 local sf=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},host)
 make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},sf)
 make("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sf)
 local big=txt(sf,{LayoutOrder=0,Size=UDim2.new(1,0,0,22),Font=Enum.Font.GothamBlack,TextSize=17,TextColor3=Color3.new(1,1,1)})
 local g=make("UIGradient",{},big)
 NX.onAccent(function(a,b) g.Color=ColorSequence.new(a,b) end)
 L(big,string.upper(en),th)
 return newTab(sf)
end

-- โครงเมนูข้าง: {หัวข้อEN, หัวข้อTH, {{key, ไอคอน, ชื่อEN, ชื่อTH}, ...}}
local layout={
 {"MM2","MM2",{
  {"MRadar","◐","RADAR","เรดาร์"},
  {"MWarp","➤","WARP","วาร์ป"},
  {"MFling","✹","FLING","ฟลิ้ง"},
  {"MHunter","✂","HUNTER","โหมดล่า"},
  {"MPlayer","♟","PLAYER","ตัวละคร"},
  {"MFarm","✪","COIN FARM","ฟาร์ม"},
  {"MEvent","✿","EVENT","อีเวนท์"},
 }},
 {"COMBAT","ต่อสู้",{
  {"Aim","◎","Aimbot","เล็งอัตโนมัติ"},
  {"Vis","◉","Visual","มองทะลุ"},
  {"KillAll","✖","Kill All","Kill All"},
  {"Invisible","◌","Invisible","ล่องหน"},
  {"Tramposo","⚡","Movement","เคลื่อนไหว"},
 }},
 {"FARM","ฟาร์ม",{
  {"Farm","★","Event Farm","ฟาร์มอีเวนต์"},
  {"RachaFarm","♨","Streak Farm","ฟาร์มสตรีค"},
 }},
 {"CUSTOM","ปรับแต่ง",{
  {"Animaciones","☺","Animations","แอนิเมชัน"},
  {"Sonidos","♪","Sounds","เสียง"},
  {"Music","♫","Music","เพลง"},
  {"Items","♛","Items","ไอเทม"},
  {"Identidad","☻","Identity","ชื่อปลอม"},
  {"Graficos","✦","Lighting","แสงฉาก"},
 }},
 {"TOOLS","เครื่องมือ",{
  {"Botones","▣","Buttons","ปุ่มลอย"},
  {"Guardado","▤","Configs","คอนฟิก"},
 }},
}

local Tabs={}
-- หมวดที่ซ่อนจากเมนูข้าง (ยังสร้างไว้เบื้องหลังให้โค้ดเดิมเรียกใช้ได้ แต่ไม่โชว์)
local HIDE={Aim=true,Vis=true,KillAll=true,Tramposo=true,Farm=true,RachaFarm=true,Botones=true,Guardado=true}
for _,grp in ipairs(layout) do
 local any=false
 for _,p in ipairs(grp[3]) do if not HIDE[p[1]] then any=true end end
 if any then NX.section(grp[1],grp[2]) end
 for _,p in ipairs(grp[3]) do
  Tabs[p[1]]=createTab(p[1],p[2],p[3],p[4],HIDE[p[1]] and true or false)
 end
end
-- หน้าที่ซ่อนไว้ (ยังสร้างให้โค้ดเดิมเรียกใช้ได้ แต่ไม่โชว์ในเมนู)
Tabs.Fondos=createTab("Fondos","","Backgrounds","พื้นหลัง",true)
Tabs.ExtrasScripts=createTab("ExtrasScripts","◈","Extras","เสริม",not SHOW_EXTRAS)

-- ย้าย SETTINGS ไปไว้ล่างสุดของเมนู
if NX.sysLabel then NX.sysLabel.LayoutOrder=9998 end
if NX.btns and NX.btns.settings then NX.btns.settings.LayoutOrder=9999 end

local WindUI={}
function WindUI:SetTheme() end
function WindUI:Notify() end
function WindUI:Popup() end
local Window={}
function Window:Toggle() end
function Window:Open() end
function Window:Close() end

return {WindUI=WindUI,Window=Window,Tabs=Tabs,T=T}
end)
if not okA then
 warn("[Nexora] feature pages failed: "..tostring(Adapter))
else
 task.spawn(function()
  local okB,errB=pcall(function()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
while not player do
    task.wait()
    player = Players.LocalPlayer
end

local camera = workspace.CurrentCamera

local fovVisiblePreference = false
local fovRadius = 120
local autoShootEnabled = false
local autoShootAgresivoEnabled = false
local autoShootTargetPart = "Cabeza"
local silentAimManualEnabled = false
local silentAimFovEnabled = false
local silentAimTargetPart = "Cabeza"
local espEnabled = false
local espColor = Color3.fromRGB(255, 255, 255)
local espSettings = { Glow = true }
local KillAllEnabled = false
local hitboxEnabled = false
local hitboxInvisible = false
local hitboxSize = 3.5
local hitboxColor = Color3.fromRGB(255, 0, 0)
local fakeNameEnabled = false
local spoofNameText = "Nombre falso"
local InvisibilityActive = false

local animacionActualActiva = nil
local misAnimacionesOriginales = nil
local UIElements = {}

local nexvyrUpdateTargetFeatures
local nexvyrRefreshTargetMonitor
local nexvyrSetAimTarget
local nexvyrStartAutoShootWorker
local nexvyrStartSilentAimWorker
local nexvyrStartEquipWorker
local nexvyrStartESPWorker
local nexvyrStartHitboxWorker
local nexvyrStartAnimationWorker
local nexvyrStartFOVWorker
local equipGunEnabled = false
local nexvyrSetInvisibleWorker

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NexvyrHub_Overlays"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = player:WaitForChild("PlayerGui")

local espFolder = Instance.new("Folder")
espFolder.Name = "NexvyrESPFolder"
espFolder.Parent = screenGui

local WindUI, Window, Tabs = Adapter.WindUI, Adapter.Window, Adapter.Tabs
local NXT = Adapter.T

local isEnemy, estaEnLobby, IsInMatchStrict
local esEnemigoValido, esCuchillo, esPistola, obtenerPistola
do
    local playerGui = player:WaitForChild("PlayerGui")
    local dmvsInvalidateRedirectSelection
    local dmvsClearTargetParts
    local function dmvsDisconnectConnectionList(list)
        if not list then
            return
        end
        for i = #list, 1, -1 do
            local connection = list[i]
            list[i] = nil
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end
    end
    local dmvsIsInfectionMode
    local function dmvsIsTargetAlive(target)
        local character = target
        if typeof(target) == "Instance" and target:IsA("Player") then
            character = target.Character
        end
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            return false
        end
        if dmvsIsInfectionMode and dmvsIsInfectionMode() then
            return character:GetAttribute("InfectionDowned") ~= true
        end
        return humanoid.Health >= 99
    end
    local function dmvsGetInGameScoreboard()
        local gui = player:FindFirstChild("PlayerGui")
        local main = gui and gui:FindFirstChild("Main")
        local frame = main and main:FindFirstChild("MainGameFrame")
        return frame and frame:FindFirstChild("IngameScore") or nil
    end

    local dmvsTeamResolverState = {
        Snapshot = {},
        Scoreboard = nil,
        InGame = false,
        LocalGame = nil,
        LastRefresh = 0,
        RefreshInterval = 2,
        Dirty = true,
        WatchConnections = {},
    }

    local function dmvsInvalidateScoreboard()
        dmvsTeamResolverState.Dirty = true
    end

    local function dmvsWatchScoreboard(score)
        local state = dmvsTeamResolverState
        if state.Scoreboard == score then
            return
        end
        dmvsDisconnectConnectionList(state.WatchConnections)
        state.Scoreboard = score
        if not score then
            return
        end
        local watchTeams
        watchTeams = function()
            dmvsInvalidateScoreboard()
            dmvsDisconnectConnectionList(state.WatchConnections)
            state.WatchConnections[#state.WatchConnections + 1] =
                score.ChildAdded:Connect(watchTeams)
            state.WatchConnections[#state.WatchConnections + 1] =
                score.ChildRemoved:Connect(watchTeams)
            for _, name in ipairs({ "TeamRed", "TeamBlue" }) do
                local folder = score:FindFirstChild(name)
                if folder then
                    state.WatchConnections[#state.WatchConnections + 1] =
                        folder.ChildAdded:Connect(dmvsInvalidateScoreboard)
                    state.WatchConnections[#state.WatchConnections + 1] =
                        folder.ChildRemoved:Connect(dmvsInvalidateScoreboard)
                end
            end
        end
        watchTeams()
    end

    local function dmvsRefreshScoreboardTeams(force)
        local state = dmvsTeamResolverState
        local now = os.clock()
        local localGame = player:GetAttribute("Game")
        if
            not force
            and not state.Dirty
            and now - state.LastRefresh < state.RefreshInterval
            and state.LocalGame == localGame
            and (not state.Scoreboard or state.Scoreboard.Parent)
        then
            return state.Snapshot
        end

        state.LastRefresh = now
        state.LocalGame = localGame
        local snapshot = {}
        local score = dmvsGetInGameScoreboard()
        if score ~= state.Scoreboard then
            dmvsWatchScoreboard(score)
        end
        for _, teamName in ipairs({ "TeamRed", "TeamBlue" }) do
            local teamFolder = score and score:FindFirstChild(teamName)
            if teamFolder then
                local team = teamName == "TeamRed" and "Red" or "Blue"
                for _, entry in ipairs(teamFolder:GetChildren()) do
                    if entry:IsA("GuiObject") then
                        snapshot[string.lower(entry.Name)] = team
                    end
                end
            end
        end
        state.Snapshot = snapshot
        state.Dirty = false
        state.InGame = score ~= nil and snapshot[string.lower(player.Name)] ~= nil
        return snapshot
    end

    local dmvsInfectionRoleAttributes =
        { "InfectionInfected", "IsInfected", "Infected", "IsZombie", "Zombie" }
    local dmvsInfectionModeAttributes = { "GameMode", "MatchMode", "Mode" }
    local dmvsInfectionState = {
        Active = false,
        LastRefresh = -math.huge,
        RefreshInterval = 0.4,
        RoleTeams = {},
        Inferred = {},
        Targets = {},
        Converted = {},
        ConvertedAt = {},
        Pending = {},
        LateJoiners = {},
        LastLocalGame = nil,
        LastMatchId = nil,
        HasMatchContext = false,
        RoundEnded = false,
    }

    local function dmvsInfectionReadMarker(holder)
        if not holder then
            return nil
        end
        if holder:GetAttribute("InfectionPatientZero") == true then
            return true
        end
        local sawSurvivor = false
        for _, name in ipairs(dmvsInfectionRoleAttributes) do
            local value = holder:GetAttribute(name)
            if typeof(value) == "boolean" then
                if value then
                    return true
                end
                sawSurvivor = true
            elseif typeof(value) == "string" then
                local normalized = value:lower()
                if
                    normalized == "infected"
                    or normalized == "infection"
                    or normalized == "zombie"
                    or normalized == "true"
                then
                    return true
                end
                if normalized == "survivor" or normalized == "human" or normalized == "false" then
                    sawSurvivor = true
                end
            end
        end
        if sawSurvivor then
            return false
        end
        return nil
    end

    local function dmvsInfectionHasPatientZero(other)
        if other:GetAttribute("InfectionPatientZero") == true then
            return true
        end
        local character = other.Character
        if not character then
            return false
        end
        if character:GetAttribute("InfectionPatientZero") == true then
            return true
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        return humanoid ~= nil and humanoid:GetAttribute("InfectionPatientZero") == true
    end

    local function dmvsInfectionAttribute(playerInstance)
        if not playerInstance then
            return nil
        end
        local character = playerInstance.Character
        local characterStatus = dmvsInfectionReadMarker(character)
        local playerStatus = dmvsInfectionReadMarker(playerInstance)
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local humanoidStatus = dmvsInfectionReadMarker(humanoid)
        if characterStatus == true or playerStatus == true or humanoidStatus == true then
            return true
        end
        if characterStatus == false or playerStatus == false or humanoidStatus == false then
            return false
        end
        return nil
    end

    local function dmvsReadInfectionRoster(teams)
        local frame = playerGui:FindFirstChild("Main")
        frame = frame and frame:FindFirstChild("MainGameFrame")
        if not frame then
            return
        end
        local playerFrame = frame:FindFirstChild("PlayersFrame")
        local regularFrame = frame:FindFirstChild("IngameScore")
        local playerNames = {}
        local displayCandidates = {}
        local ambiguousDisplays = {}
        for _, other in ipairs(Players:GetPlayers()) do
            playerNames[other.Name:lower()] = other
            playerNames[tostring(other.UserId)] = other
            local displayKey = other.DisplayName:lower()
            if displayCandidates[displayKey] then
                ambiguousDisplays[displayKey] = true
            end
            displayCandidates[displayKey] = other
        end
        for displayKey, other in pairs(displayCandidates) do
            if not ambiguousDisplays[displayKey] and not playerNames[displayKey] then
                playerNames[displayKey] = other
            end
        end
        local function collect(group, team)
            if not group then
                return
            end
            for _, entry in ipairs(group:GetChildren()) do
                if entry:IsA("GuiObject") then
                    local other = playerNames[entry.Name:lower():gsub("^@", "")]
                    if not other then
                        local entryUserId = entry:GetAttribute("UserId")
                        if entryUserId then
                            other = playerNames[tostring(entryUserId)]
                        end
                    end
                    if not other then
                        for _, sub in ipairs(entry:GetDescendants()) do
                            if
                                sub:IsA("TextLabel")
                                and (sub.Name == "PlayerName" or sub.Name == "TextLabel")
                            then
                                other = playerNames[sub.Text:lower():gsub("^@", "")]
                                if other then
                                    break
                                end
                            end
                        end
                    end
                    if other then
                        teams[other] = team
                    end
                end
            end
        end
        if regularFrame then
            collect(regularFrame:FindFirstChild("TeamRed"), "Red")
            collect(regularFrame:FindFirstChild("TeamBlue"), "Blue")
        end
        if playerFrame then
            collect(playerFrame:FindFirstChild("TeamRedFrame"), "Red")
            collect(playerFrame:FindFirstChild("TeamBlueFrame"), "Blue")
        end
    end

    local function dmvsClearInfectionRound(ended)
        local state = dmvsInfectionState
        table.clear(state.Converted)
        table.clear(state.ConvertedAt)
        table.clear(state.Pending)
        table.clear(state.LateJoiners)
        table.clear(state.Inferred)
        table.clear(state.Targets)
        table.clear(state.RoleTeams)
        state.Active = false
        state.RoundEnded = ended == true
        state.LastRefresh = -math.huge
        if dmvsInvalidateRedirectSelection then
            dmvsInvalidateRedirectSelection()
        end
    end

    local function dmvsRefreshInfectionState(force)
        local state = dmvsInfectionState
        local now = os.clock()
        local localGame = player:GetAttribute("Game")
        local matchId = player:GetAttribute("MatchId")
        if
            state.HasMatchContext
            and (localGame ~= state.LastLocalGame or matchId ~= state.LastMatchId)
        then
            dmvsClearInfectionRound(false)
        end
        state.HasMatchContext = true
        state.LastLocalGame = localGame
        state.LastMatchId = matchId
        if not force and now - state.LastRefresh < state.RefreshInterval then
            return state
        end
        state.LastRefresh = now
        local regularRoster = dmvsRefreshScoreboardTeams(false)
        local foundPatientZero = false
        local ownCharacter = player.Character
        local myRoot = ownCharacter and ownCharacter:FindFirstChild("HumanoidRootPart")
        local allPlayers = Players:GetPlayers()
        for _, other in ipairs(allPlayers) do
            if dmvsInfectionHasPatientZero(other) then
                local compatible = other == player
                if not compatible then
                    compatible = true
                    local otherGame = other:GetAttribute("Game")
                    local otherMatch = other:GetAttribute("MatchId")
                    if
                        localGame ~= nil
                        and localGame ~= ""
                        and otherGame ~= nil
                        and otherGame ~= ""
                        and localGame ~= otherGame
                    then
                        compatible = false
                    end
                    if
                        (localGame == nil or localGame == "")
                        and otherGame ~= nil
                        and otherGame ~= ""
                    then
                        compatible = false
                    end
                    if
                        matchId ~= nil
                        and matchId ~= ""
                        and otherMatch ~= nil
                        and otherMatch ~= ""
                        and matchId ~= otherMatch
                    then
                        compatible = false
                    end
                    local theirCharacter = other.Character
                    local theirRoot = theirCharacter
                        and theirCharacter:FindFirstChild("HumanoidRootPart")
                    if
                        myRoot
                        and theirRoot
                        and (myRoot.Position - theirRoot.Position).Magnitude > 1200
                    then
                        compatible = false
                    end
                end
                if compatible then
                    foundPatientZero = true
                    break
                end
            end
        end
        local modeAttribute
        for _, name in ipairs(dmvsInfectionModeAttributes) do
            local value = player:GetAttribute(name)
            if typeof(value) == "string" and value ~= "" then
                modeAttribute = value:lower()
                break
            end
        end
        if not modeAttribute then
            for _, name in ipairs(dmvsInfectionModeAttributes) do
                local value = workspace:GetAttribute(name)
                if typeof(value) == "string" and value ~= "" then
                    modeAttribute = value:lower()
                    break
                end
            end
        end
        local active = not state.RoundEnded
            and (
                modeAttribute == "infection"
                or (
                    not modeAttribute
                    and (foundPatientZero or (state.Active and not dmvsTeamResolverState.InGame))
                )
            )
        if not active then
            if
                modeAttribute
                and modeAttribute ~= "infection"
                and next(state.LateJoiners) ~= nil
            then
                table.clear(state.LateJoiners)
            end
            if state.Active or next(state.Targets) ~= nil then
                if modeAttribute and modeAttribute ~= "infection" then
                    dmvsClearInfectionRound(false)
                else
                    state.Active = false
                    table.clear(state.Targets)
                    table.clear(state.Inferred)
                    table.clear(state.RoleTeams)
                    if dmvsInvalidateRedirectSelection then
                        dmvsInvalidateRedirectSelection()
                    end
                end
            end
            return state
        end
        state.Active = true
        local teams = {}
        dmvsReadInfectionRoster(teams)
        state.RoleTeams = teams
        local infectedTeam
        local ambiguousTeam = false
        local markers = {}
        for _, other in ipairs(allPlayers) do
            local marker = dmvsInfectionAttribute(other)
            markers[other] = marker
            if marker == true or state.Converted[other] == true then
                local team = teams[other]
                if team then
                    if infectedTeam and infectedTeam ~= team then
                        ambiguousTeam = true
                    end
                    infectedTeam = team
                end
            end
        end
        local inferred = {}
        if infectedTeam and not ambiguousTeam then
            for other, team in pairs(teams) do
                if team == infectedTeam and markers[other] ~= false then
                    inferred[other] = true
                end
            end
        end
        state.Inferred = inferred
        local function createTargets()
            local targets = {}
            for _, other in ipairs(allPlayers) do
                if
                    markers[other] == true
                    or state.Converted[other] == true
                    or (markers[other] ~= false and inferred[other] == true)
                then
                    targets[other] = true
                end
            end
            return targets
        end
        local targets = createTargets()
        local infectedRoots = {}
        for infectedPlayer in pairs(targets) do
            local infectedCharacter = infectedPlayer.Character
            local infectedRoot = infectedCharacter
                and infectedCharacter:FindFirstChild("HumanoidRootPart")
            if infectedRoot and infectedRoot:IsA("BasePart") then
                infectedRoots[#infectedRoots + 1] = infectedRoot
            end
        end
        for _, other in ipairs(allPlayers) do
            if
                other ~= player
                and state.LateJoiners[other]
                and markers[other] == nil
                and not targets[other]
                and other.Character
            then
                local rosterTeam = teams[other] or regularRoster[other.Name:lower()]
                local otherGame = other:GetAttribute("Game")
                local otherMatch = other:GetAttribute("MatchId")
                local sameGame = localGame ~= nil and localGame ~= "" and otherGame == localGame
                local sameMatch = matchId ~= nil and matchId ~= "" and otherMatch == matchId
                local differentGame = localGame ~= nil
                    and localGame ~= ""
                    and otherGame ~= nil
                    and otherGame ~= ""
                    and otherGame ~= localGame
                local differentMatch = matchId ~= nil
                    and matchId ~= ""
                    and otherMatch ~= nil
                    and otherMatch ~= ""
                    and otherMatch ~= matchId
                if not differentGame and not differentMatch then
                    local sharesInfectedTeam = false
                    for infectedPlayer in pairs(targets) do
                        local infectedRobloxTeam = infectedPlayer.Team
                        if
                            infectedRobloxTeam
                            and other.Team == infectedRobloxTeam
                            and (
                                markers[infectedPlayer] == true
                                or state.Converted[infectedPlayer] == true
                                or inferred[infectedPlayer] == true
                            )
                        then
                            sharesInfectedTeam = true
                            break
                        end
                    end
                    local nearInfected = false
                    if
                        not rosterTeam
                        and not sameGame
                        and not sameMatch
                        and not sharesInfectedTeam
                    then
                        local characterRoot = other.Character:FindFirstChild("HumanoidRootPart")
                        if characterRoot and characterRoot:IsA("BasePart") then
                            local position = characterRoot.Position
                            for _, infectedRoot in ipairs(infectedRoots) do
                                if (infectedRoot.Position - position).Magnitude <= 300 then
                                    nearInfected = true
                                    break
                                end
                            end
                        end
                    end
                    local participates = rosterTeam ~= nil
                        or sameGame
                        or sameMatch
                        or sharesInfectedTeam
                        or nearInfected
                    if
                        participates
                        and (
                            not infectedTeam
                            or ambiguousTeam
                            or not rosterTeam
                            or rosterTeam == infectedTeam
                        )
                    then
                        targets[other] = true
                    end
                end
            end
        end
        local pending = state.Pending
        local changed = true
        while changed do
            changed = false
            for index = #pending, 1, -1 do
                local entry = pending[index]
                if
                    now - entry.Time > 10
                    or entry.Killer.Parent ~= Players
                    or entry.Victim.Parent ~= Players
                then
                    table.remove(pending, index)
                elseif
                    targets[entry.Killer]
                    and not targets[entry.Victim]
                    and (
                        not state.ConvertedAt[entry.Killer]
                        or state.ConvertedAt[entry.Killer] <= entry.Time
                    )
                then
                    state.Converted[entry.Victim] = true
                    state.ConvertedAt[entry.Victim] = entry.Time
                    targets[entry.Victim] = true
                    table.remove(pending, index)
                    changed = true
                elseif targets[entry.Killer] then
                    table.remove(pending, index)
                end
            end
        end
        local previous = state.Targets
        local targetChanged = false
        for other in pairs(previous) do
            if not targets[other] then
                targetChanged = true
                break
            end
        end
        if not targetChanged then
            for other in pairs(targets) do
                if not previous[other] then
                    targetChanged = true
                    break
                end
            end
        end
        state.Targets = targets
        if targetChanged and dmvsInvalidateRedirectSelection then
            dmvsInvalidateRedirectSelection()
        end
        return state
    end

    dmvsIsInfectionMode = function()
        return dmvsRefreshInfectionState(false).Active
    end

    local function dmvsIsInfectedTarget(targetPlayer)
        if not targetPlayer then
            return false
        end
        local state = dmvsRefreshInfectionState(false)
        return state.Active and state.Targets[targetPlayer] == true
    end

    local function dmvsInfectionMatchAllowed(targetPlayer, allowMissingCharacter)
        if
            not targetPlayer
            or targetPlayer == player
            or not targetPlayer.Parent
            or (not allowMissingCharacter and not targetPlayer.Character)
        then
            return false
        end
        local myGame = player:GetAttribute("Game")
        local targetGame = targetPlayer:GetAttribute("Game")
        if
            myGame ~= nil
            and myGame ~= ""
            and targetGame ~= nil
            and targetGame ~= ""
            and myGame ~= targetGame
        then
            return false
        end
        if (myGame == nil or myGame == "") and targetGame ~= nil and targetGame ~= "" then
            return false
        end
        local myMatch = player:GetAttribute("MatchId")
        local targetMatch = targetPlayer:GetAttribute("MatchId")
        if
            myMatch ~= nil
            and myMatch ~= ""
            and targetMatch ~= nil
            and targetMatch ~= ""
            and myMatch ~= targetMatch
        then
            return false
        end
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local otherRoot = targetPlayer.Character
            and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and otherRoot and (myRoot.Position - otherRoot.Position).Magnitude > 1200 then
            return false
        end
        return true
    end

    local function dmvsInfectionMarkDirty()
        dmvsInfectionState.LastRefresh = -math.huge
    end

    local function dmvsInfectionOnKill(killer, victim)
        if
            typeof(killer) ~= "Instance"
            or not killer:IsA("Player")
            or typeof(victim) ~= "Instance"
            or not victim:IsA("Player")
            or killer == victim
            or not dmvsIsInfectionMode()
            or (killer ~= player and not dmvsInfectionMatchAllowed(killer, true))
            or (victim ~= player and not dmvsInfectionMatchAllowed(victim, true))
        then
            return
        end
        local state = dmvsRefreshInfectionState(false)
        if state.Targets[victim] then
            return
        end
        if state.Targets[killer] then
            state.Converted[victim] = true
            state.ConvertedAt[victim] = os.clock()
            state.LastRefresh = -math.huge
            dmvsRefreshInfectionState(true)
        else
            if #state.Pending >= 96 then
                table.remove(state.Pending, 1)
            end
            state.Pending[#state.Pending + 1] =
                { Killer = killer, Victim = victim, Time = os.clock() }
            state.LastRefresh = -math.huge
        end
    end

    local dmvsIsInSameGame
    dmvsIsInSameGame = function(targetPlayer)
        if not targetPlayer or targetPlayer == player or not targetPlayer.Parent then
            return false
        end

        if dmvsIsInfectionMode() then
            return dmvsInfectionMatchAllowed(targetPlayer) and dmvsIsInfectedTarget(targetPlayer)
        end

        local roster = dmvsRefreshScoreboardTeams(false)
        if not dmvsTeamResolverState.InGame or not roster[string.lower(targetPlayer.Name)] then
            return false
        end

        local myGame = player:GetAttribute("Game")
        local targetGame = targetPlayer:GetAttribute("Game")
        if myGame ~= nil and myGame ~= "" and targetGame ~= nil and targetGame ~= "" then
            if myGame ~= targetGame then
                return false
            end
        elseif (myGame == nil or myGame == "") and targetGame ~= nil and targetGame ~= "" then
            return false
        end

        local myMatch = player:GetAttribute("MatchId")
        local targetMatch = targetPlayer:GetAttribute("MatchId")
        if
            myMatch ~= nil
            and myMatch ~= ""
            and targetMatch ~= nil
            and targetMatch ~= ""
            and myMatch ~= targetMatch
        then
            return false
        end

        return true
    end

    local function dmvsResolvePlayerTeam(targetPlayer)
        if not targetPlayer then
            return nil
        end

        local snapshot = dmvsRefreshScoreboardTeams(false)
        local byName = snapshot[string.lower(targetPlayer.Name)]

        if not byName and targetPlayer.DisplayName then
            byName = snapshot[string.lower(targetPlayer.DisplayName)]
        end

        if byName then
            return byName
        end

        local attr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("team")
        if attr ~= nil and tostring(attr) ~= "" then
            return tostring(attr)
        end

        if targetPlayer.Team then
            return targetPlayer.Team.Name
        end

        local teamColor = targetPlayer.TeamColor
        if teamColor and teamColor.Name ~= "White" and teamColor.Name ~= "Medium stone grey" then
            return "Color:" .. teamColor.Name
        end

        return nil
    end

    local function dmvsPlayersAreEnemies(firstPlayer, secondPlayer)
        if not firstPlayer or not secondPlayer or firstPlayer == secondPlayer then
            return false
        end
        if dmvsIsInfectionMode() then
            return dmvsIsInfectedTarget(secondPlayer)
        end

        local firstTeam = dmvsResolvePlayerTeam(firstPlayer)
        local secondTeam = dmvsResolvePlayerTeam(secondPlayer)

        if firstTeam ~= nil and secondTeam ~= nil then
            return firstTeam ~= secondTeam
        end

        return true
    end

    local function updateMyTeam()
        dmvsInvalidateScoreboard()
        if dmvsInvalidateRedirectSelection then
            dmvsInvalidateRedirectSelection()
        end
    end

    local function updateEnemy()
        dmvsInvalidateScoreboard()
        dmvsInfectionMarkDirty()
        if dmvsInvalidateRedirectSelection then
            dmvsInvalidateRedirectSelection()
        end
    end

    local dmvsTeamPlayerConnections = {}
    local dmvsInfectionCharacterConnections = {}

    local function disconnectPlayerTeamEvents(p)
        dmvsDisconnectConnectionList(dmvsInfectionCharacterConnections[p])
        dmvsInfectionCharacterConnections[p] = nil
        local connections = dmvsTeamPlayerConnections[p]
        if connections then
            dmvsDisconnectConnectionList(connections)
            dmvsTeamPlayerConnections[p] = nil
        end
    end

    local function dmvsWatchInfectionCharacter(p, character)
        dmvsDisconnectConnectionList(dmvsInfectionCharacterConnections[p])
        dmvsInfectionCharacterConnections[p] = nil
        if not character then
            return
        end
        local connections = {}
        dmvsInfectionCharacterConnections[p] = connections
        local function changed(name)
            if
                name == "InfectionPatientZero"
                or name == "InfectionInfected"
                or name == "IsInfected"
                or name == "Infected"
                or name == "IsZombie"
                or name == "Zombie"
            then
                dmvsInfectionMarkDirty()
                updateEnemy()
            end
        end
        connections[#connections + 1] = character.AttributeChanged:Connect(changed)
        local function bindHumanoid(humanoid)
            if humanoid and humanoid:IsA("Humanoid") then
                connections[#connections + 1] = humanoid.AttributeChanged:Connect(changed)
            end
        end
        bindHumanoid(character:FindFirstChildOfClass("Humanoid"))
        connections[#connections + 1] = character.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                bindHumanoid(child)
                dmvsInfectionMarkDirty()
            end
        end)
    end

    local function setupPlayerEvents(p)
        if not p or p == player or not p.Parent then
            return
        end
        disconnectPlayerTeamEvents(p)
        dmvsTeamPlayerConnections[p] = {
            p:GetPropertyChangedSignal("Team"):Connect(updateEnemy),
            p:GetPropertyChangedSignal("TeamColor"):Connect(updateEnemy),
            p:GetAttributeChangedSignal("Team"):Connect(updateEnemy),
            p:GetAttributeChangedSignal("team"):Connect(updateEnemy),
            p:GetAttributeChangedSignal("Game"):Connect(updateEnemy),
            p:GetAttributeChangedSignal("MatchId"):Connect(updateEnemy),
            p.AttributeChanged:Connect(function(name)
                if
                    name == "InfectionPatientZero"
                    or name == "InfectionInfected"
                    or name == "IsInfected"
                    or name == "Infected"
                    or name == "IsZombie"
                    or name == "Zombie"
                then
                    dmvsInfectionMarkDirty()
                    updateEnemy()
                end
            end),
            p.CharacterAdded:Connect(function(character)
                dmvsWatchInfectionCharacter(p, character)
                dmvsInfectionMarkDirty()
                updateEnemy()
            end),
            p.CharacterRemoving:Connect(function(character)
                dmvsWatchInfectionCharacter(p, nil)
                dmvsInfectionMarkDirty()
                if dmvsClearTargetParts then
                    dmvsClearTargetParts(character)
                end
            end),
        }
        dmvsWatchInfectionCharacter(p, p.Character)
        updateEnemy()
    end

    local nexvyrTargetConnections = {}
    local nexvyrTargetMonitorActive = false
    local nexvyrTargetMonitorSession = 0
    local function nexvyrMonitorConnection(connection)
        nexvyrTargetConnections[#nexvyrTargetConnections + 1] = connection
        return connection
    end
    local function nexvyrStartTargetMonitor()
        if nexvyrTargetMonitorActive then
            return
        end
        nexvyrTargetMonitorActive = true
        nexvyrTargetMonitorSession += 1
        local session = nexvyrTargetMonitorSession
        local function localChanged()
            updateMyTeam()
            dmvsInfectionMarkDirty()
        end
        for _, name in ipairs({ "Team", "TeamColor" }) do
            nexvyrMonitorConnection(player:GetPropertyChangedSignal(name):Connect(localChanged))
        end
        for _, name in ipairs({ "Team", "team", "Game", "MatchId", "GameMode", "MatchMode", "Mode" }) do
            nexvyrMonitorConnection(player:GetAttributeChangedSignal(name):Connect(localChanged))
        end
        nexvyrMonitorConnection(player.AttributeChanged:Connect(function(name)
            if
                name == "InfectionPatientZero"
                or name == "InfectionInfected"
                or name == "IsInfected"
                or name == "Infected"
                or name == "IsZombie"
                or name == "Zombie"
            then
                dmvsInfectionMarkDirty()
            end
        end))
        nexvyrMonitorConnection(player.CharacterAdded:Connect(dmvsInfectionMarkDirty))
        nexvyrMonitorConnection(playerGui.DescendantAdded:Connect(function(instance)
            if
                instance.Name == "IngameScore"
                or instance.Name == "TeamRed"
                or instance.Name == "TeamBlue"
            then
                dmvsInvalidateScoreboard()
                dmvsInfectionMarkDirty()
            end
        end))
        nexvyrMonitorConnection(playerGui.DescendantRemoving:Connect(function(instance)
            if
                instance == dmvsTeamResolverState.Scoreboard
                or instance.Name == "IngameScore"
                or instance.Name == "TeamRed"
                or instance.Name == "TeamBlue"
            then
                dmvsInvalidateScoreboard()
                dmvsInfectionMarkDirty()
            end
        end))
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player then
                setupPlayerEvents(other)
            end
        end
        nexvyrMonitorConnection(Players.PlayerAdded:Connect(function(other)
            dmvsInfectionState.LateJoiners[other] = true
            setupPlayerEvents(other)
            dmvsInfectionMarkDirty()
        end))
        nexvyrMonitorConnection(Players.PlayerRemoving:Connect(function(other)
            disconnectPlayerTeamEvents(other)
            for i = #dmvsInfectionState.Pending, 1, -1 do
                local entry = dmvsInfectionState.Pending[i]
                if entry.Killer == other or entry.Victim == other then
                    table.remove(dmvsInfectionState.Pending, i)
                end
            end
            for _, bucket in ipairs({
                "Converted",
                "ConvertedAt",
                "LateJoiners",
                "Inferred",
                "Targets",
                "RoleTeams",
            }) do
                dmvsInfectionState[bucket][other] = nil
            end
            updateEnemy()
        end))
        dmvsInvalidateScoreboard()
        dmvsInfectionMarkDirty()
        task.spawn(function()
            local registered = {}
            local listeners = {
                ["RE/Combat/Killed"] = dmvsInfectionOnKill,
                ["RE/Match/PlayerRespawned"] = dmvsInfectionMarkDirty,
                ["RE/Match/StartRoundGui"] = function()
                    dmvsClearInfectionRound(false)
                end,
                ["RE/Match/MatchResults"] = function()
                    if dmvsInfectionState.Active then
                        dmvsClearInfectionRound(true)
                    end
                end,
            }
            while nexvyrTargetMonitorActive and session == nexvyrTargetMonitorSession do
                local packages = ReplicatedStorage:FindFirstChild("Packages")
                local networking = packages and packages:FindFirstChild("Networking")
                local finished = true
                for name, callback in pairs(listeners) do
                    if not registered[name] then
                        local remote = networking and networking:FindFirstChild(name)
                        if remote and remote:IsA("RemoteEvent") then
                            nexvyrMonitorConnection(remote.OnClientEvent:Connect(callback))
                            registered[name] = true
                        else
                            finished = false
                        end
                    end
                end
                if finished then
                    break
                end
                task.wait(2)
            end
        end)
    end
    local function nexvyrStopTargetMonitor()
        if not nexvyrTargetMonitorActive then
            return
        end
        nexvyrTargetMonitorActive = false
        nexvyrTargetMonitorSession += 1
        dmvsDisconnectConnectionList(nexvyrTargetConnections)
        for other in pairs(dmvsTeamPlayerConnections) do
            disconnectPlayerTeamEvents(other)
        end
        dmvsDisconnectConnectionList(dmvsTeamResolverState.WatchConnections)
        dmvsTeamResolverState.Scoreboard = nil
        dmvsTeamResolverState.Snapshot = {}
        dmvsTeamResolverState.InGame = false
        dmvsTeamResolverState.Dirty = true
        dmvsClearInfectionRound(false)
    end
    nexvyrRefreshTargetMonitor = function()
        if
            autoShootEnabled
            or autoShootAgresivoEnabled
            or silentAimManualEnabled
            or silentAimFovEnabled
            or equipGunEnabled
            or (espEnabled and espSettings.Glow)
            or hitboxEnabled
            or KillAllEnabled
        then
            nexvyrStartTargetMonitor()
        else
            nexvyrStopTargetMonitor()
        end
    end

    isEnemy = function(targetPlayer)
        if not dmvsIsInSameGame(targetPlayer) or not targetPlayer.Character then
            return false
        end
        if not dmvsIsTargetAlive(targetPlayer) then
            return false
        end
        return dmvsPlayersAreEnemies(player, targetPlayer)
    end
    local SAFE_ZONES = {
        { Center = Vector3.new(-320.50, 280.82, 16.00), Radius = 500 },
        { Center = Vector3.new(1564.14, -155.45, 40.04), Radius = 300 },
    }
    estaEnLobby = function()
        local character = player.Character
        if not character then
            return true
        end
        if character:FindFirstChildOfClass("ForceField") then
            return true
        end
        if player.Team then
            local name = player.Team.Name:lower()
            if
                name:find("lobby")
                or name:find("spectat")
                or name:find("espectador")
                or name:find("menu")
                or name:find("dead")
            then
                return true
            end
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, zone in ipairs(SAFE_ZONES) do
                if (root.Position - zone.Center).Magnitude <= zone.Radius then
                    return true
                end
            end
        end
        return false
    end
    IsInMatchStrict = function()
        if estaEnLobby() then
            return false
        end
        dmvsRefreshScoreboardTeams(false)
        return dmvsTeamResolverState.InGame or dmvsIsInfectionMode()
    end
    esEnemigoValido = function(other)
        if not isEnemy(other) then
            return false
        end
        local character = other.Character
        return character ~= nil
            and not character:FindFirstChildOfClass("ForceField")
            and dmvsIsTargetAlive(other)
    end
    esCuchillo = function(tool)
        if not tool or not tool:IsA("Tool") then
            return false
        end
        if tool:FindFirstChild("Slash") or tool:FindFirstChild("SlashStart") then
            return true
        end
        local name = tool.Name:lower()
        return name:find("knife", 1, true) ~= nil
            or name:find("cuchillo", 1, true) ~= nil
            or name:find("dagger", 1, true) ~= nil
    end
    esPistola = function(tool)
        if not tool or not tool:IsA("Tool") then
            return false
        end
        local beam = tool:FindFirstChild("showBeam")
        return beam ~= nil and beam:IsA("RemoteEvent")
    end
    obtenerPistola = function()
        local character = player.Character
        if character then
            for _, tool in ipairs(character:GetChildren()) do
                if esPistola(tool) then
                    return tool
                end
            end
        end
        local backpack = player:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if esPistola(tool) then
                    return tool
                end
            end
        end
        return nil
    end
end

local function estaRecargando(arma)
    if not arma or not arma:IsA("Tool") then
        return false
    end
    for _, name in ipairs({
        "Reloading",
        "IsReloading",
        "reloading",
        "isReloading",
        "Reload",
        "reload",
    }) do
        local v = arma:GetAttribute(name)
        if v == true or v == "true" then
            return true
        end
    end
    for _, child in ipairs(arma:GetChildren()) do
        if child:IsA("BoolValue") and child.Value == true then
            local n = string.lower(child.Name)
            if string.find(n, "reload") or string.find(n, "recarg") then
                return true
            end
        end
    end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            local animId = track.Animation and track.Animation.AnimationId or ""
            if string.find(string.lower(animId), "reload") then
                return true
            end
        end
    end
    for _, s in ipairs(arma:GetDescendants()) do
        if s:IsA("Sound") and s.Playing then
            local n = string.lower(s.Name)
            if string.find(n, "reload") or string.find(n, "recarg") then
                return true
            end
        end
    end
    return false
end

local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager
function ConnectionManager.new()
    return setmetatable({ Items = {} }, ConnectionManager)
end
function ConnectionManager:Add(task)
    self.Items[#self.Items + 1] = task
    return task
end
function ConnectionManager:Cleanup()
    for i = #self.Items, 1, -1 do
        local item = self.Items[i]
        self.Items[i] = nil
        local t = typeof(item)
        if t == "RBXScriptConnection" then
            pcall(function()
                item:Disconnect()
            end)
        elseif t == "Instance" then
            pcall(function()
                item:Destroy()
            end)
        elseif t == "function" then
            pcall(item)
        end
    end
end

local function limpiarHitboxes()
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        local character = targetPlayer.Character
        if character then
            local hitbox = character:FindFirstChild("GhostHitbox")
            if hitbox then
                hitbox:Destroy()
            end
        end
    end
end

local nexvyrHitboxWorkerRunning = false
nexvyrStartHitboxWorker = function()
    if nexvyrHitboxWorkerRunning or not hitboxEnabled then
        return
    end
    nexvyrHitboxWorkerRunning = true
    task.spawn(function()
        while hitboxEnabled do
            task.wait(0.2)
            if not hitboxEnabled then
                break
            end
            if not IsInMatchStrict() then
                limpiarHitboxes()
                continue
            end
            local tamanoObjetivo = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            local transObjetivo = hitboxInvisible and 1 or 0.6
            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                if targetPlayer ~= player and isEnemy(targetPlayer) then
                    local character = targetPlayer.Character
                    if character then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if rootPart and humanoid and humanoid.Health > 0 then
                            local hitbox = character:FindFirstChild("GhostHitbox")
                            if not hitbox then
                                hitbox = Instance.new("Part")
                                hitbox.Name = "GhostHitbox"
                                hitbox.Size = tamanoObjetivo
                                hitbox.Transparency = transObjetivo
                                hitbox.Color = hitboxColor
                                hitbox.CanCollide = false
                                hitbox.Massless = true
                                hitbox.CanQuery = true
                                hitbox.CFrame = rootPart.CFrame
                                hitbox.Parent = character
                                local weld = Instance.new("WeldConstraint")
                                weld.Part0 = rootPart
                                weld.Part1 = hitbox
                                weld.Parent = hitbox
                            else
                                if hitbox.Size ~= tamanoObjetivo then
                                    hitbox.Size = tamanoObjetivo
                                end
                                if hitbox.Transparency ~= transObjetivo then
                                    hitbox.Transparency = transObjetivo
                                end
                                if hitbox.Color ~= hitboxColor then
                                    hitbox.Color = hitboxColor
                                end
                                if not hitbox.CanQuery then
                                    hitbox.CanQuery = true
                                end
                            end
                        else
                            local hitbox = character:FindFirstChild("GhostHitbox")
                            if hitbox then
                                hitbox:Destroy()
                            end
                        end
                    end
                else
                    local char = targetPlayer.Character
                    if char then
                        local hb = char:FindFirstChild("GhostHitbox")
                        if hb then
                            hb:Destroy()
                        end
                    end
                end
            end
        end
        nexvyrHitboxWorkerRunning = false
        if not hitboxEnabled then
            limpiarHitboxes()
        end
    end)
end

local PadZoneConfig = {
    ["Right Platforms"] = {
        ["1v1"] = { ZoneName = "PadZone1", MainPad = "Pad1", AltPad = "Pad2" },
        ["2v2"] = { ZoneName = "PadZone2", MainPad = "Pad1", AltPad = "Pad2" },
        ["3v3"] = { ZoneName = "PadZone3", MainPad = "Pad1", AltPad = "Pad2" },
        ["4v4"] = { ZoneName = "PadZone4", MainPad = "Pad1", AltPad = "Pad2" },
    },
    ["Left Platforms"] = {
        ["1v1"] = { ZoneName = "PadZone5", MainPad = "Pad1", AltPad = "Pad2" },
        ["2v2"] = { ZoneName = "PadZone6", MainPad = "Pad1", AltPad = "Pad2" },
        ["3v3"] = { ZoneName = "PadZone7", MainPad = "Pad1", AltPad = "Pad2" },
        ["4v4"] = { ZoneName = "PadZone8", MainPad = "Pad1", AltPad = "Pad2" },
    },
}

AutoTeleportMainAlt = {}
AutoTeleportMainAlt.__index = AutoTeleportMainAlt

function AutoTeleportMainAlt.new()
    return setmetatable({
        Running = false,
        Connections = ConnectionManager.new(),
        Acc = 0,
        TickInterval = 0.5,
        ActiveRole = nil,
        DuelType = "1v1",
        PlatformRow = "Right Platforms",
        LastTeleport = 0,
        LastVote = 0,
        LastCancel = 0,
        TeleportCooldown = 0.5,
        VoteCooldown = 1,
        CancelCooldown = 1,
        VotedMap = nil,
        HighlightedPad = nil,
        PadColors = {},
    }, AutoTeleportMainAlt)
end

function AutoTeleportMainAlt:GetActiveRole()
    if self.ActiveRole == "Main" then
        return "Main"
    end
    if self.ActiveRole == "Alt" then
        return "Alt"
    end
    return nil
end

function AutoTeleportMainAlt:GetRoot()
    local char = player.Character
    if not char then
        return nil
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then
        return root
    end
    return nil
end

function AutoTeleportMainAlt:GetHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function AutoTeleportMainAlt:Attr(name)
    local v = player:GetAttribute(name)
    if typeof(v) == "string" and v ~= "" then
        return v
    end
    return nil
end

function AutoTeleportMainAlt:Snapshot()
    local gameAttr = self:Attr("Game")
    local mapAttr = self:Attr("Map")
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local alive = hum ~= nil and hum.Health > 0 and root ~= nil
    return {
        Game = gameAttr,
        Map = mapAttr,
        InGame = gameAttr ~= nil,
        InMap = gameAttr ~= nil and mapAttr ~= nil,
        Alive = alive,
    }
end

function AutoTeleportMainAlt:IsOnMatch()
    local s = self:Snapshot()
    return s and s.InGame == true and s.InMap ~= true and s.Alive
end

function AutoTeleportMainAlt:ResolvePad(role)
    local rowConfig = PadZoneConfig[self.PlatformRow] or PadZoneConfig["Right Platforms"]
    local cfg = rowConfig[self.DuelType] or rowConfig["1v1"]
    local padZones = workspace:FindFirstChild("PadZones")
    if not padZones then
        return nil
    end
    local zone = padZones:FindFirstChild(cfg.ZoneName)
    if not zone then
        return nil
    end
    local padName = (role == "Alt") and cfg.AltPad or cfg.MainPad
    local holder = zone:FindFirstChild(padName)
    if not holder then
        return nil
    end
    local pad = holder:FindFirstChild("Pad")
    if pad and pad:IsA("BasePart") then
        return pad
    end
    return nil
end

function AutoTeleportMainAlt:IsOnPad(pad)
    if not pad then
        return false
    end
    local root = self:GetRoot()
    if not root then
        return false
    end
    local rel = pad.CFrame:PointToObjectSpace(root.Position)
    local half = pad.Size / 2
    return math.abs(rel.X) <= half.X + 0.5
        and math.abs(rel.Z) <= half.Z + 0.5
        and rel.Y >= -(half.Y + 6)
        and rel.Y <= half.Y + 14
end

function AutoTeleportMainAlt:MarkPad(pad, isAlt)
    if not pad then
        self:UnmarkPad()
        return
    end
    if self.HighlightedPad == pad then
        return
    end
    self:UnmarkPad()
    self.HighlightedPad = pad
    self.PadColors[pad] = { Color = pad.Color, Transparency = pad.Transparency }
    pcall(function()
        pad.Color = isAlt and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(70, 145, 255)
        pad.Transparency = 0.5
    end)
end

function AutoTeleportMainAlt:UnmarkPad()
    if self.HighlightedPad and self.PadColors[self.HighlightedPad] then
        local pad = self.HighlightedPad
        local saved = self.PadColors[pad]
        pcall(function()
            if pad.Parent then
                pad.Color = saved.Color
                pad.Transparency = saved.Transparency
            end
        end)
    end
    self.HighlightedPad = nil
end

function AutoTeleportMainAlt:FindVoteRemote()
    local pkgs = ReplicatedStorage:FindFirstChild("Packages")
    local net = pkgs and pkgs:FindFirstChild("Networking")
    local r = net and net:FindFirstChild("RF/Voting/Vote")
    if r and r:IsA("RemoteFunction") then
        return r
    end
    return nil
end

function AutoTeleportMainAlt:FindVisibleMapVote()
    local pg = player:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local mv = main and main:FindFirstChild("MapVoting")
    local holder = mv and mv:FindFirstChild("VotingHolder")
    if not holder then
        return nil
    end
    for _, b in ipairs(holder:GetChildren()) do
        if b:IsA("ImageButton") and b.Visible and b.Name ~= "" then
            return b.Name
        end
    end
    return nil
end

function AutoTeleportMainAlt:VoteMap()
    local s = self:Snapshot()
    if not self:IsOnMatch() then
        return
    end
    if self.VotedMap == s.Game then
        return
    end
    local now = os.clock()
    if now - (self.LastVote or 0) < self.VoteCooldown then
        return
    end
    self.LastVote = now
    local target = self:FindVisibleMapVote()
    local rf = self:FindVoteRemote()
    if not (target and rf) then
        return
    end
    self.VotedMap = s.Game
    pcall(function()
        rf:InvokeServer(target)
    end)
end

function AutoTeleportMainAlt:FindSetStateRemote()
    local pkgs = ReplicatedStorage:FindFirstChild("Packages")
    local net = pkgs and pkgs:FindFirstChild("Networking")
    local r = net and net:FindFirstChild("RE/Match/SetStatePlr")
    if r and r:IsA("RemoteEvent") then
        return r
    end
    return nil
end

function AutoTeleportMainAlt:CancelQueue()
    local now = os.clock()
    if now - (self.LastCancel or 0) < self.CancelCooldown then
        return
    end
    local ev = self:FindSetStateRemote()
    if not ev then
        return
    end
    self.LastCancel = now
    pcall(function()
        ev:FireServer("REMOVE")
    end)
end

function AutoTeleportMainAlt:HideGameFrame()
    local pg = player:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local mgf = main and main:FindFirstChild("MainGameFrame")
    if mgf and mgf:IsA("GuiObject") then
        pcall(function()
            mgf.Visible = false
        end)
    end
end

function AutoTeleportMainAlt:HoldCenter()
    local hum = self:GetHumanoid()
    local root = self:GetRoot()
    if hum and root then
        pcall(function()
            hum:MoveTo(root.Position)
        end)
    end
end

function AutoTeleportMainAlt:Teleport(pad)
    if not pad then
        return
    end
    local root = self:GetRoot()
    local hum = self:GetHumanoid()
    if not (root and hum) then
        return
    end
    pcall(function()
        root.AssemblyAngularVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        self:CancelQueue()
        self:HideGameFrame()
        hum:MoveTo(pad.Position)
    end)
end

function AutoTeleportMainAlt:Process()
    if not self.Running then
        return
    end
    local s = self:Snapshot()
    if s.InGame then
        self:UnmarkPad()
        self:HoldCenter()
        self:VoteMap()
        return
    end
    local role = self:GetActiveRole()
    if not role then
        self:UnmarkPad()
        return
    end
    local pad = self:ResolvePad(role)
    self:MarkPad(pad, role == "Alt")
    if not pad then
        return
    end
    if self:IsOnPad(pad) then
        return
    end
    local now = os.clock()
    if now - (self.LastTeleport or 0) < self.TeleportCooldown then
        return
    end
    self.LastTeleport = now
    self:Teleport(pad)
end

function AutoTeleportMainAlt:Kick()
    if self.Running then
        self:Process()
    end
end

function AutoTeleportMainAlt:Start()
    if self.Running then
        return
    end
    self.Running = true
    self.Acc = 0
    self.LastTeleport = 0
    self.LastVote = 0
    self.LastCancel = 0
    self.Connections:Add(player:GetAttributeChangedSignal("Game"):Connect(function()
        task.defer(function()
            if self.Running then
                self:Process()
            end
        end)
    end))
    self.Connections:Add(player:GetAttributeChangedSignal("Map"):Connect(function()
        task.defer(function()
            if self.Running then
                self:Process()
            end
        end)
    end))
    self.Connections:Add(player:GetAttributeChangedSignal("Team"):Connect(function()
        task.defer(function()
            if self.Running then
                self:Process()
            end
        end)
    end))
    self.Connections:Add(RunService.Heartbeat:Connect(function(dt)
        if not self.Running then
            return
        end
        self.Acc = self.Acc + dt
        if self.Acc >= self.TickInterval then
            self.Acc = 0
            self:Process()
        end
    end))
    self:Process()
end

function AutoTeleportMainAlt:Stop()
    if not self.Running then
        return
    end
    self.Running = false
    self.Connections:Cleanup()
    self.Connections = ConnectionManager.new()
    self:UnmarkPad()
    self.VotedMap = nil
end

AutoTeleportMainAltInstance = AutoTeleportMainAlt.new()

local function IsRoundTimerActive()
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then
        return false
    end
    local main = gui:FindFirstChild("Main") or gui
    local gameFrame = main:FindFirstChild("MainGameFrame")
    if not gameFrame or not gameFrame.Visible then
        return false
    end
    local score = gameFrame:FindFirstChild("IngameScore")
    local timer = score and score:FindFirstChild("Timer")
    if not timer then
        return false
    end
    if not (timer:IsA("TextLabel") or timer:IsA("TextButton") or timer:IsA("TextBox")) then
        return false
    end
    local txt = tostring(timer.Text or ""):gsub("%s", "")
    if txt == "" then
        return false
    end
    if string.find(txt, "-") then
        return false
    end
    if txt == "0:00" or txt == "00:00" or txt == "0:0" then
        return false
    end
    return txt:match("^%d+:%d%d$") ~= nil
end

do
    local KILLALL_MOVE_SPEED = 39.9
    local KILLALL_APPROACH_DISTANCE = 2.5
    local KILLALL_APPROACH_TOLERANCE = 0.35
    local KILLALL_SWING_INTERVAL = 0.5
    local KILLALL_SAFE_GROUND_THRESHOLD = 3
    local KILLALL_STICK_MAX_TIME = 2.5
    local KILLALL_STICK_MAX_DISTANCE = 20
    local KILLALL_VOID_PROTECTION = 15
    local KILLALL_HEALTH_STALL_TIME = 1.5
    local KILLALL_TARGET_GRACE_TIME = 1.2
    local KILLALL_PITCH_DEGREES = 90
    local KILLALL_HEIGHT_OFFSET = 1.9
    local KILLALL_HIDE_DEPTH = 4
    local KILLALL_HIDE_DURATION = 0.5
    local KILLALL_KNIFE_RANGE_Y = 4.5
    local KILLALL_JITTER_AMPLITUDE = 0.8
    local KILLALL_JITTER_SWITCH_MIN = 0.05
    local KILLALL_JITTER_SWITCH_MAX = 0.12
    local KILLALL_JITTER_LERP_SPEED = 25
    local KILLALL_UNDERGROUND_DEPTH = 5
    local KILLALL_UNDERGROUND_TOLERANCE = 1.5
    local KILLALL_TRIGGER_RADIUS = 6.0
    local KILLALL_VALIDATION_TOLERANCE = 1.0
    local KILLALL_VALIDATION_FRAMES = 3

    local KillAll = {}
    KillAll.__index = KillAll

    function KillAll.new()
        return setmetatable({
            running = false,
            connections = ConnectionManager.new(),
            savedCollisions = {},
            swingAccumulator = 0,
            safePosition = nil,
            sticking = false,
            stickingStartTime = 0,
            lastEnemyHealth = nil,
            lastHealthChangeTime = 0,
            lastTargetSeenTime = 0,
            currentTarget = nil,
            lockedTargetPlayer = nil,
            lastStickTarget = nil,
            lastStickTargetHum = nil,
            hiding = false,
            hidingUntil = 0,
            targetFloor = nil,
            targetFloorY = nil,
            lastFloorTarget = nil,
            inKnifeRangeNow = false,
            forceDescent = false,
            jitterSide = 1,
            jitterCurrent = 0,
            jitterNextSwitch = 0,
            lastSetCFrame = nil,
            validFrames = 0,
            killActivated = false,
        }, KillAll)
    end

    function KillAll:DisableCollisions()
        local char = player.Character
        if not char then
            return
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                if self.savedCollisions[part] == nil then
                    self.savedCollisions[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end

    function KillAll:RestoreCollisions()
        for part, value in pairs(self.savedCollisions) do
            if part.Parent then
                pcall(function()
                    part.CanCollide = value
                end)
            end
        end
        table.clear(self.savedCollisions)
    end

    function KillAll:GetRoot(p)
        local char = p and p.Character
        if not char then
            return nil
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root
        end
        return nil
    end

    function KillAll:GetHumanoid(p)
        local char = p and p.Character
        return char and char:FindFirstChildOfClass("Humanoid") or nil
    end

    function KillAll:GetFloorY(targetRoot)
        local hum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
        local hip = hum and tonumber(hum.HipHeight) or 2
        return targetRoot.Position.Y - hip - targetRoot.Size.Y / 2
    end

    function KillAll:GetPlatformFloorY(targetRoot)
        if not targetRoot then
            return nil
        end
        if self.lastFloorTarget == targetRoot and self.targetFloorY then
            return self.targetFloorY
        end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { player.Character, targetRoot.Parent }
        local origin = targetRoot.Position + Vector3.new(0, 3, 0)
        local result = workspace:Raycast(origin, Vector3.new(0, -500, 0), params)
        if result then
            self.targetFloorY = result.Position.Y
            self.lastFloorTarget = targetRoot
            return self.targetFloorY
        end
        self.targetFloorY = self:GetFloorY(targetRoot)
        self.lastFloorTarget = targetRoot
        return self.targetFloorY
    end

    function KillAll:IsInKnifeRange(myRoot, targetRoot)
        if not myRoot or not targetRoot then
            return false
        end
        local delta = targetRoot.Position - myRoot.Position
        local horizontal = Vector3.new(delta.X, 0, delta.Z).Magnitude
        local vertical = math.abs(delta.Y)
        return horizontal <= (KILLALL_APPROACH_DISTANCE + KILLALL_APPROACH_TOLERANCE)
            and vertical <= KILLALL_KNIFE_RANGE_Y
    end

    function KillAll:IsLockedTargetValid()
        local lp = self.lockedTargetPlayer
        if not lp then
            return false
        end
        if not lp.Parent then
            return false
        end
        if not esEnemigoValido(lp) then
            return false
        end
        local char = lp.Character
        if not char then
            return false
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then
            return false
        end
        if hum.Health <= 0 then
            return false
        end
        return root
    end

    function KillAll:GetClosestEnemy()
        local myRoot = self:GetRoot(player)
        if not myRoot then
            return nil
        end
        local lockedRoot = self:IsLockedTargetValid()
        if lockedRoot then
            return lockedRoot
        end
        self.lockedTargetPlayer = nil
        self.currentTarget = nil
        local best, bestDist, bestPlayer = nil, nil, nil
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player and esEnemigoValido(other) then
                local hum = self:GetHumanoid(other)
                local root = self:GetRoot(other)
                if root and hum and hum.Health > 0 then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    if not bestDist or dist < bestDist then
                        best, bestDist, bestPlayer = root, dist, other
                    end
                end
            end
        end
        if bestPlayer then
            self.lockedTargetPlayer = bestPlayer
        end
        return best
    end

    function KillAll:IsInMatch()
        return IsRoundTimerActive()
    end

    function KillAll:ResetState()
        self.sticking = false
        self.stickingStartTime = 0
        self.lastEnemyHealth = nil
        self.lastHealthChangeTime = 0
        self.targetFloor = nil
        self.inKnifeRangeNow = false
        self.forceDescent = false
        self.jitterSide = 1
        self.jitterCurrent = 0
        self.jitterNextSwitch = 0
        self.lastSetCFrame = nil
        self.validFrames = 0
        self.killActivated = false
        self:RestoreCollisions()
        local hum = self:GetHumanoid(player)
        if hum and hum.PlatformStand then
            pcall(function()
                hum.PlatformStand = false
            end)
        end
    end

    function KillAll:ReturnToSafePosition(myRoot)
        if not self.safePosition or not myRoot then
            return
        end
        local currentY = myRoot.Position.Y
        if currentY < (self.safePosition.Y - KILLALL_SAFE_GROUND_THRESHOLD) then
            pcall(function()
                myRoot.CFrame = CFrame.new(self.safePosition)
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end

    function KillAll:ForceReturnToSafe(myRoot)
        if not self.safePosition or not myRoot then
            return
        end
        pcall(function()
            myRoot.CFrame = CFrame.new(self.safePosition)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    function KillAll:IsFallingIntoVoid(myRoot)
        if not self.safePosition or not myRoot then
            return false
        end
        return myRoot.Position.Y < (self.safePosition.Y - KILLALL_VOID_PROTECTION)
    end

    function KillAll:HideBelowMap()
        local myRoot = self:GetRoot(player)
        if not myRoot then
            return
        end
        local baseY = self.safePosition and self.safePosition.Y or myRoot.Position.Y
        local hideY = baseY - KILLALL_HIDE_DEPTH
        local currentX, currentZ = myRoot.Position.X, myRoot.Position.Z
        pcall(function()
            myRoot.CFrame = CFrame.new(currentX, hideY, currentZ)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
        self.hiding = true
        self.hidingUntil = os.clock() + KILLALL_HIDE_DURATION
    end

    function KillAll:IsKnife(tool)
        if not (tool and tool:IsA("Tool")) then
            return false
        end
        if tool:FindFirstChild("fire") or tool:FindFirstChild("showBeam") then
            return false
        end
        return tool:FindFirstChild("Slash") ~= nil or tool:FindFirstChild("SlashStart") ~= nil
    end

    function KillAll:FindKnife()
        local char = player.Character
        if char then
            for _, child in ipairs(char:GetChildren()) do
                if self:IsKnife(child) then
                    return child, true
                end
            end
        end
        local backpack = player:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, child in ipairs(backpack:GetChildren()) do
                if self:IsKnife(child) then
                    return child, false
                end
            end
        end
        return nil, false
    end

    function KillAll:SwingKnife(dt)
        self.swingAccumulator = self.swingAccumulator + dt
        if self.swingAccumulator < KILLALL_SWING_INTERVAL then
            return
        end
        self.swingAccumulator = 0
        local tool, equipped = self:FindKnife()
        if not tool then
            return
        end
        if not equipped then
            local hum = self:GetHumanoid(player)
            if not hum then
                return
            end
            pcall(function()
                hum:EquipTool(tool)
            end)
            if tool.Parent ~= player.Character then
                return
            end
        end
        pcall(function()
            tool:Activate()
        end)
    end

    function KillAll:UpdateJitter(dt)
        local now = os.clock()
        if now >= self.jitterNextSwitch then
            self.jitterSide = (math.random() < 0.5) and 1 or -1
            self.jitterNextSwitch = now
                + KILLALL_JITTER_SWITCH_MIN
                + math.random() * (KILLALL_JITTER_SWITCH_MAX - KILLALL_JITTER_SWITCH_MIN)
        end
        local targetOffset = self.jitterSide * KILLALL_JITTER_AMPLITUDE
        self.jitterCurrent = self.jitterCurrent
            + (targetOffset - self.jitterCurrent)
                * math.clamp(dt * KILLALL_JITTER_LERP_SPEED, 0, 1)
    end

    function KillAll:CheckServerValidation(myRoot)
        if self.killActivated then
            return true
        end
        if not self.lastSetCFrame then
            return false
        end
        local desiredPos = self.lastSetCFrame.Position
        local actualPos = myRoot.Position
        local diff = (actualPos - desiredPos).Magnitude
        if diff <= KILLALL_VALIDATION_TOLERANCE then
            self.validFrames = self.validFrames + 1
            if self.validFrames >= KILLALL_VALIDATION_FRAMES then
                self.killActivated = true
                self.swingAccumulator = KILLALL_SWING_INTERVAL
                return true
            end
        else
            self.validFrames = 0
        end
        return false
    end

    function KillAll:ForceUnderground(myRoot, targetRoot)
        if not myRoot or not targetRoot then
            return
        end
        local floorY = self:GetPlatformFloorY(targetRoot)
        if not floorY then
            return
        end
        local targetY = floorY - KILLALL_UNDERGROUND_DEPTH
        if myRoot.Position.Y > targetY + KILLALL_UNDERGROUND_TOLERANCE then
            pcall(function()
                myRoot.CFrame = CFrame.new(myRoot.Position.X, targetY, myRoot.Position.Z)
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end

    function KillAll:ApproachTarget(myRoot, targetRoot, dt)
        dt = dt or 0
        local myPos = myRoot.Position
        local targetPos = targetRoot.Position
        local deltaXZ = Vector3.new(targetPos.X - myPos.X, 0, targetPos.Z - myPos.Z)
        local hDist = deltaXZ.Magnitude
        if hDist <= KILLALL_TRIGGER_RADIUS then
            if not self.sticking then
                local lookTarget = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
                local targetCF = CFrame.lookAt(myPos, lookTarget)
                self.lastSetCFrame = targetCF
                pcall(function()
                    myRoot.CFrame = targetCF
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                end)
                if self:CheckServerValidation(myRoot) then
                    self.sticking = true
                    self.stickingStartTime = os.clock()
                    self.lastStickTarget = targetRoot
                    self.targetFloor = nil
                    self.forceDescent = true
                    local hum = self:GetHumanoid(targetRoot.Parent)
                    self.lastEnemyHealth = hum and hum.Health or nil
                    self.lastHealthChangeTime = os.clock()
                    self.lastStickTargetHum = hum
                    self.jitterCurrent = 0
                end
            end
            return
        end
        self.lastSetCFrame = nil
        self.validFrames = 0
        local dir = deltaXZ.Unit
        local perp = Vector3.new(-dir.Z, 0, dir.X)
        self:UpdateJitter(dt)
        local step = KILLALL_MOVE_SPEED * dt
        local travel = math.min(step, math.max(0, hDist - KILLALL_TRIGGER_RADIUS))
        local maxJitterByDistance = math.sqrt(math.max(0, travel * (2 * hDist - travel))) * 0.85
        local jitterFactor = math.clamp((hDist - KILLALL_TRIGGER_RADIUS) / 8, 0, 1)
        local desiredJitter = self.jitterCurrent * jitterFactor
        local actualJitter = math.clamp(desiredJitter, -maxJitterByDistance, maxJitterByDistance)
        local baseX = myPos.X + dir.X * travel
        local baseZ = myPos.Z + dir.Z * travel
        local newX = baseX + perp.X * actualJitter
        local newZ = baseZ + perp.Z * actualJitter
        local floorY = self:GetPlatformFloorY(targetRoot)
        local newY
        if floorY then
            newY = floorY - KILLALL_UNDERGROUND_DEPTH
        else
            newY = myPos.Y
        end
        local newPos = Vector3.new(newX, newY, newZ)
        local lookTarget = Vector3.new(targetPos.X, newPos.Y, targetPos.Z)
        local newCFrame = CFrame.lookAt(newPos, lookTarget)
        pcall(function()
            myRoot.CFrame = newCFrame
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    function KillAll:CanStickToTarget(myRoot, targetRoot)
        if not targetRoot or not targetRoot.Parent then
            return false
        end
        local targetPlayer = Players:GetPlayerFromCharacter(targetRoot.Parent)
        if not targetPlayer or not esEnemigoValido(targetPlayer) then
            return false
        end
        local targetHum = targetRoot.Parent:FindFirstChildOfClass("Humanoid")
        if not targetHum or targetHum.Health <= 0 then
            return false
        end
        local distHorizontal = (Vector3.new(myRoot.Position.X, 0, myRoot.Position.Z) - Vector3.new(
            targetRoot.Position.X,
            0,
            targetRoot.Position.Z
        )).Magnitude
        if distHorizontal > KILLALL_STICK_MAX_DISTANCE then
            return false
        end
        return true
    end

    function KillAll:StickToTarget(myRoot, targetRoot)
        local targetPos = targetRoot.Position
        local targetHum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
        local onGround = targetHum and targetHum.FloorMaterial ~= Enum.Material.Air
        if targetRoot ~= self.lastStickTarget then
            self.lastStickTarget = targetRoot
            self.targetFloor = nil
        end
        if onGround or not self.targetFloor then
            self.targetFloor = self:GetFloorY(targetRoot)
        end
        local myPos = myRoot.Position
        local dir = Vector3.new(myPos.X - targetPos.X, 0, myPos.Z - targetPos.Z)
        if dir.Magnitude < 0.05 then
            dir = Vector3.new(0, 0, 1)
        else
            dir = dir.Unit
        end
        local x = targetPos.X + dir.X * KILLALL_APPROACH_DISTANCE
        local z = targetPos.Z + dir.Z * KILLALL_APPROACH_DISTANCE
        local inRange = self:IsInKnifeRange(myRoot, targetRoot)
        local y
        if inRange and not self.forceDescent then
            y = myPos.Y
        else
            y = self.targetFloor - KILLALL_HEIGHT_OFFSET
            if inRange then
                self.forceDescent = false
            end
        end
        pcall(function()
            myRoot.CFrame = CFrame.new(x, y, z)
                * CFrame.Angles(math.rad(KILLALL_PITCH_DEGREES), 0, 0)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    function KillAll:CheckEnemyHealth(targetRoot)
        local targetHum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
        if not targetHum then
            return false
        end
        local currentHealth = targetHum.Health
        if self.lastEnemyHealth == nil then
            self.lastEnemyHealth = currentHealth
            self.lastHealthChangeTime = os.clock()
            return false
        end
        if currentHealth < self.lastEnemyHealth then
            self.lastEnemyHealth = currentHealth
            self.lastHealthChangeTime = os.clock()
            return false
        end
        if (os.clock() - self.lastHealthChangeTime) >= KILLALL_HEALTH_STALL_TIME then
            return true
        end
        return false
    end

    function KillAll:Update(dt)
        if not self:IsInMatch() then
            self:ResetState()
            self.currentTarget = nil
            self.lockedTargetPlayer = nil
            self.lastStickTarget = nil
            self.lastFloorTarget = nil
            self.targetFloorY = nil
            return
        end
        local myRoot = self:GetRoot(player)
        if not myRoot then
            self:ResetState()
            self.currentTarget = nil
            self.lockedTargetPlayer = nil
            return
        end
        if self.lastStickTargetHum then
            local hum = self.lastStickTargetHum
            if not hum.Parent or hum.Health <= 0 then
                self:HideBelowMap()
                self.inKnifeRangeNow = false
                self.forceDescent = false
                self.lastStickTargetHum = nil
                self.lastStickTarget = nil
                self.sticking = false
                self.stickingStartTime = 0
                self.lastEnemyHealth = nil
                self.lastHealthChangeTime = 0
                self.targetFloor = nil
                self.killActivated = false
                self.validFrames = 0
                self.lastSetCFrame = nil
                return
            end
        end
        if self.hiding then
            if os.clock() >= self.hidingUntil then
                self.hiding = false
            else
                pcall(function()
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                end)
                return
            end
        end
        if self:IsFallingIntoVoid(myRoot) then
            self:ForceReturnToSafe(myRoot)
            self:ResetState()
            self.currentTarget = nil
            self.lockedTargetPlayer = nil
            self.lastStickTarget = nil
            local hum = self:GetHumanoid(player)
            if hum then
                pcall(function()
                    hum.PlatformStand = false
                end)
            end
            return
        end
        local target = self:GetClosestEnemy()
        if target then
            self.currentTarget = target
            self.lastTargetSeenTime = os.clock()
        end
        if not target then
            local justLostTarget = (os.clock() - (self.lastTargetSeenTime or 0))
                < KILLALL_TARGET_GRACE_TIME
            local isUnderground = self.safePosition
                and myRoot.Position.Y < (self.safePosition.Y - 2)
            if justLostTarget and isUnderground then
                pcall(function()
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                end)
                return
            end
            self:ReturnToSafePosition(myRoot)
            self:ResetState()
            self.currentTarget = nil
            self.lockedTargetPlayer = nil
            self.lastStickTarget = nil
            self.lastFloorTarget = nil
            self.targetFloorY = nil
            if self.safePosition then
                local hum = self:GetHumanoid(player)
                if hum then
                    pcall(function()
                        hum.PlatformStand = false
                    end)
                end
            end
            return
        end
        self:DisableCollisions()
        if self.lastStickTarget then
            local inRange = self:IsInKnifeRange(myRoot, self.lastStickTarget)
            if inRange and not self.inKnifeRangeNow then
                self.swingAccumulator = KILLALL_SWING_INTERVAL
                self.inKnifeRangeNow = true
            elseif not inRange then
                self.inKnifeRangeNow = false
            end
        end
        self:SwingKnife(dt or 0)
        local hum = self:GetHumanoid(player)
        if hum and not hum.PlatformStand then
            pcall(function()
                hum.PlatformStand = true
            end)
        end
        if
            self.safePosition
            and myRoot.Position.Y >= (self.safePosition.Y - KILLALL_SAFE_GROUND_THRESHOLD)
        then
            self.safePosition =
                Vector3.new(myRoot.Position.X, self.safePosition.Y, myRoot.Position.Z)
        end
        if not self.sticking then
            self:ForceUnderground(myRoot, target)
        end
        if self.sticking then
            local lostTarget = (target ~= self.lastStickTarget)
            local timedOut = (os.clock() - self.stickingStartTime) > KILLALL_STICK_MAX_TIME
            local cannotStick = not self:CanStickToTarget(myRoot, target)
            local cannotKill = self:CheckEnemyHealth(target)
            if lostTarget or timedOut or cannotStick or cannotKill then
                self.sticking = false
                self.stickingStartTime = 0
                self.lastEnemyHealth = nil
                self.lastHealthChangeTime = 0
                self.targetFloor = nil
                self.inKnifeRangeNow = false
                self.forceDescent = false
                self.killActivated = false
                self.validFrames = 0
                self.lastSetCFrame = nil
                if lostTarget then
                    self.lastStickTarget = nil
                end
            else
                self:StickToTarget(myRoot, target)
                return
            end
        end
        self:ApproachTarget(myRoot, target, dt or 0)
    end

    function KillAll:Start()
        if self.running then
            return
        end
        self.running = true
        self.swingAccumulator = 0
        self.sticking = false
        self.stickingStartTime = 0
        self.lastEnemyHealth = nil
        self.lastHealthChangeTime = 0
        self.lastTargetSeenTime = 0
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        self.lastStickTarget = nil
        self.lastStickTargetHum = nil
        self.hiding = false
        self.hidingUntil = 0
        self.targetFloor = nil
        self.targetFloorY = nil
        self.lastFloorTarget = nil
        self.inKnifeRangeNow = false
        self.forceDescent = false
        self.jitterSide = 1
        self.jitterCurrent = 0
        self.jitterNextSwitch = 0
        self.lastSetCFrame = nil
        self.validFrames = 0
        self.killActivated = false
        local myRoot = self:GetRoot(player)
        if myRoot then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { player.Character }
            local origin = myRoot.Position + Vector3.new(0, 5, 0)
            local result = workspace:Raycast(origin, Vector3.new(0, -500, 0), params)
            if result then
                self.safePosition =
                    Vector3.new(myRoot.Position.X, result.Position.Y + 3, myRoot.Position.Z)
            else
                self.safePosition = myRoot.Position
            end
        else
            self.safePosition = nil
        end
        self.connections:Add(RunService.Heartbeat:Connect(function(dt)
            if not self.running then
                return
            end
            self:Update(dt)
        end))
        self.connections:Add(player.CharacterAdded:Connect(function()
            table.clear(self.savedCollisions)
            self.sticking = false
            self.safePosition = nil
            self.stickingStartTime = 0
            self.lastEnemyHealth = nil
            self.lastHealthChangeTime = 0
            self.lastTargetSeenTime = 0
            self.currentTarget = nil
            self.lockedTargetPlayer = nil
            self.lastStickTarget = nil
            self.lastStickTargetHum = nil
            self.hiding = false
            self.hidingUntil = 0
            self.targetFloor = nil
            self.targetFloorY = nil
            self.lastFloorTarget = nil
            self.inKnifeRangeNow = false
            self.forceDescent = false
            self.jitterSide = 1
            self.jitterCurrent = 0
            self.jitterNextSwitch = 0
            self.lastSetCFrame = nil
            self.validFrames = 0
            self.killActivated = false
        end))
    end

    function KillAll:Stop()
        if not self.running then
            return
        end
        local myRoot = self:GetRoot(player)
        if myRoot and self.safePosition then
            pcall(function()
                myRoot.CFrame = CFrame.new(self.safePosition)
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        self.running = false
        self.connections:Cleanup()
        self.connections = ConnectionManager.new()
        self:ResetState()
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        self.lastStickTarget = nil
        self.lastStickTargetHum = nil
        self.hiding = false
        self.hidingUntil = 0
        self.inKnifeRangeNow = false
        self.forceDescent = false
        self.killActivated = false
        self.targetFloorY = nil
        self.lastFloorTarget = nil
    end

    KillAllInstance = KillAll.new()
end

Tabs.ExtrasScripts:Section({ Title = "Scripts Extras", Icon = "solar:code-bold" })
Tabs.ExtrasScripts:Button({
    Title = "Copiar avatares",
    Icon = "solar:user-hand-up-bold",
    Variant = "Primary",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/5MA88wuB"))()
        end)
    end,
})

task.wait()

Tabs.Aim:Section({ Title = "Auto Shoot", Icon = "solar:target-bold" })

UIElements.TogAutoShoot = Tabs.Aim:Toggle({
    Title = "Auto Shoot (Normal - Cabeza/Torso)",
    Callback = function(Value)
        autoShootEnabled = Value
        if
            not Value
            and not autoShootEnabled
            and not autoShootAgresivoEnabled
            and nexvyrSetAimTarget
        then
            nexvyrSetAimTarget("Auto", nil)
        end
        if nexvyrUpdateTargetFeatures then
            nexvyrUpdateTargetFeatures()
        end
    end,
})

UIElements.TogAutoShootAgr = Tabs.Aim:Toggle({
    Title = "Auto Shoot (Agresivo - Hitbox Completa)",
    Callback = function(Value)
        autoShootAgresivoEnabled = Value
        if
            not Value
            and not autoShootEnabled
            and not autoShootAgresivoEnabled
            and nexvyrSetAimTarget
        then
            nexvyrSetAimTarget("Auto", nil)
        end
        if nexvyrUpdateTargetFeatures then
            nexvyrUpdateTargetFeatures()
        end
    end,
})

UIElements.DropAutoShootPart = Tabs.Aim:Dropdown({
    Title = "Target: Parte del cuerpo",
    Values = { "Cabeza", "Torso", "Cuerpo Completo" },
    Value = "Cabeza",
    Callback = function(Value)
        autoShootTargetPart = Value
    end,
})

UIElements.TogEquipGun = Tabs.Aim:Toggle({
    Title = "Equipar pistola",
    Value = false,
    Callback = function(Value)
        equipGunEnabled = Value
        if nexvyrUpdateTargetFeatures then
            nexvyrUpdateTargetFeatures()
        end
    end,
})

local nexvyrEquipWorkerRunning = false
nexvyrStartEquipWorker = function()
    if nexvyrEquipWorkerRunning or not equipGunEnabled then
        return
    end
    nexvyrEquipWorkerRunning = true
    task.spawn(function()
        local gunRayParams = RaycastParams.new()
        gunRayParams.FilterType = Enum.RaycastFilterType.Exclude
        while equipGunEnabled do
            task.wait(0.1)
            if not equipGunEnabled then
                break
            end
            if not IsInMatchStrict() then
                continue
            end
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum then
                continue
            end
            if hum.Health <= 0 then
                continue
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if not hrp then
                continue
            end
            local originPos = head and head.Position or hrp.Position
            local hayEnemigoVisible = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and esEnemigoValido(p) then
                    local pChar = p.Character
                    if pChar then
                        local targetPart = pChar:FindFirstChild("Head")
                            or pChar:FindFirstChild("UpperTorso")
                            or pChar:FindFirstChild("Torso")
                            or pChar:FindFirstChild("HumanoidRootPart")
                        if targetPart and targetPart:IsA("BasePart") then
                            gunRayParams.FilterDescendantsInstances = { char, pChar }
                            local result = workspace:Raycast(
                                originPos,
                                targetPart.Position - originPos,
                                gunRayParams
                            )
                            if not result and IsInMatchStrict() then
                                hayEnemigoVisible = true
                                break
                            end
                        end
                    end
                end
            end
            if not hayEnemigoVisible then
                continue
            end
            local pistola = obtenerPistola()
            if not pistola then
                continue
            end
            char = player.Character
            hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum then
                continue
            end
            pistola = obtenerPistola()
            if not pistola then
                continue
            end
            if pistola.Parent ~= char then
                pcall(function()
                    hum:EquipTool(pistola)
                end)
            end
            task.wait(0.35)
            if not equipGunEnabled then
                break
            end
            char = player.Character
            hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum then
                pcall(function()
                    hum:UnequipTools()
                end)
            end
            task.wait(1.9)
        end
        nexvyrEquipWorkerRunning = false
    end)
end

Tabs.Aim:Space()
Tabs.Aim:Divider()
Tabs.Aim:Space()

Tabs.Aim:Section({ Title = "Silent Aim + Fov", Icon = "solar:radar-bold" })

UIElements.TogSilentAimManual = Tabs.Aim:Toggle({
    Title = "Silent Aim",
    Callback = function(Value)
        silentAimManualEnabled = Value
        if
            not Value
            and not silentAimManualEnabled
            and not silentAimFovEnabled
            and nexvyrSetAimTarget
        then
            nexvyrSetAimTarget("Silent", nil)
        end
        if nexvyrUpdateTargetFeatures then
            nexvyrUpdateTargetFeatures()
        end
    end,
})

UIElements.DropSilentAimPart = Tabs.Aim:Dropdown({
    Title = "Target: Parte del cuerpo",
    Values = { "Cabeza", "Torso", "Cuerpo Completo" },
    Value = "Cabeza",
    Callback = function(Value)
        silentAimTargetPart = Value
    end,
})

UIElements.TogSilentAimFOV = Tabs.Aim:Toggle({
    Title = "Silent Aim (Con FOV)",
    Callback = function(Value)
        silentAimFovEnabled = Value
        if
            not Value
            and not silentAimManualEnabled
            and not silentAimFovEnabled
            and nexvyrSetAimTarget
        then
            nexvyrSetAimTarget("Silent", nil)
        end
        if nexvyrUpdateTargetFeatures then
            nexvyrUpdateTargetFeatures()
        end
    end,
})

UIElements.TogShowFOV = Tabs.Aim:Toggle({
    Title = "Mostrar Círculo FOV",
    Callback = function(Value)
        fovVisiblePreference = Value
        if nexvyrStartFOVWorker then
            nexvyrStartFOVWorker()
        end
    end,
})

UIElements.SliFOVSize = Tabs.Aim:Slider({
    Title = "Tamaño del FOV",
    Step = 1,
    Value = { Min = 10, Max = 800, Default = 120 },
    Callback = function(v)
        fovRadius = v
    end,
})

getgenv().NexvyrTargetPart = nil
local oldNexvyrHook = getgenv().__NexvyrDeferredNamecall
if oldNexvyrHook then
    oldNexvyrHook.Enabled = false
end

local nexvyrMouse = player:GetMouse()
local nexvyrAimTargets = { Auto = nil, Silent = nil }
local nexvyrAutoFireUntil = 0
local priorNexvyrAimCleanup = getgenv().__NexvyrDmvsAimCleanup
if type(priorNexvyrAimCleanup) == "function" then
    pcall(priorNexvyrAimCleanup)
end
getgenv().__NexvyrDmvsAimCleanup = nil
local nexvyrHooks = { Enabled = false, Metatable = nil, IndexHook = nil, NamecallHook = nil }
local nexvyrIsMadium = false
do
    local identify = type(getexecutorname) == "function" and getexecutorname or identifyexecutor
    if type(identify) == "function" then
        local ok, name = pcall(identify)
        nexvyrIsMadium = ok and tostring(name):lower():find("madium", 1, true) ~= nil or false
    end
end
local nexvyrDirectCalls = {}
pcall(function()
    nexvyrDirectCalls.Raycast = workspace.Raycast
end)
pcall(function()
    nexvyrDirectCalls.FindPartOnRay = workspace.FindPartOnRay
end)
pcall(function()
    nexvyrDirectCalls.FindPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList
end)
pcall(function()
    nexvyrDirectCalls.FindPartOnRayWithWhitelist = workspace.FindPartOnRayWithWhitelist
end)

local function nexvyrAimActive()
    return autoShootEnabled
        or autoShootAgresivoEnabled
        or silentAimManualEnabled
        or silentAimFovEnabled
end

local function nexvyrValidTarget(target)
    if typeof(target) ~= "Instance" or not target:IsA("BasePart") or not target.Parent then
        return false
    end
    local character = target:FindFirstAncestorOfClass("Model")
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

local function nexvyrSelectedAimTarget()
    local now = os.clock()
    local autoActive = autoShootEnabled or autoShootAgresivoEnabled
    if autoActive and now <= nexvyrAutoFireUntil and nexvyrValidTarget(nexvyrAimTargets.Auto) then
        return nexvyrAimTargets.Auto
    end
    if
        (silentAimManualEnabled or silentAimFovEnabled)
        and nexvyrValidTarget(nexvyrAimTargets.Silent)
    then
        return nexvyrAimTargets.Silent
    end
    if autoActive and nexvyrValidTarget(nexvyrAimTargets.Auto) then
        return nexvyrAimTargets.Auto
    end
    return nil
end

nexvyrSetAimTarget = function(source, target)
    if source ~= "Auto" and source ~= "Silent" then
        return
    end
    nexvyrAimTargets[source] = nexvyrValidTarget(target) and target or nil
    getgenv().NexvyrTargetPart = nexvyrSelectedAimTarget()
end

local function nexvyrGetAimPoint()
    if not nexvyrHooks.Enabled or not nexvyrAimActive() or estaEnLobby() then
        return nil
    end
    local char = player.Character
    if not char then
        return nil
    end
    local equipped = char:FindFirstChildOfClass("Tool")
    if not esPistola(equipped) then
        return nil
    end
    local target = nexvyrSelectedAimTarget()
    if not target then
        return nil
    end
    return target.Position, target
end

local function nexvyrLikelyWeaponOrigin(origin)
    if typeof(origin) ~= "Vector3" then
        return false
    end
    local currentCamera = workspace.CurrentCamera
    if currentCamera and (origin - currentCamera.CFrame.Position).Magnitude <= 3 then
        return true
    end
    local character = player.Character
    if not character then
        return false
    end
    local tool = character:FindFirstChildOfClass("Tool")
    local handle = tool and tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") and (origin - handle.Position).Magnitude <= 18 then
        return true
    end
    local head = character:FindFirstChild("Head")
    return head and (origin - head.Position).Magnitude <= 8 or false
end

local function nexvyrShotOrigin()
    local cam = workspace.CurrentCamera
    local cameraOrigin = cam and cam.CFrame.Position
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if cameraOrigin and head and (cameraOrigin - head.Position).Magnitude <= 1.75 then
        return cameraOrigin
    end
    local tool = char and char:FindFirstChildOfClass("Tool")
    local handle = tool and tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        return handle.Position
    end
    if head then
        return head.Position
    end
    return cameraOrigin
end

local function nexvyrRestoreHooks()
    nexvyrHooks.Enabled = false
    local mt = nexvyrHooks.Metatable
    if not mt or type(setreadonly) ~= "function" then
        return
    end
    local ok = pcall(setreadonly, mt, false)
    if not ok then
        return
    end
    pcall(function()
        if mt.__index == nexvyrHooks.IndexHook then
            mt.__index = nexvyrHooks.OriginalIndex
        end
        if nexvyrHooks.NamecallHook and mt.__namecall == nexvyrHooks.NamecallHook then
            mt.__namecall = nexvyrHooks.OriginalNamecall
        end
    end)
    pcall(setreadonly, mt, nexvyrHooks.WasReadonly)
    if
        mt.__index ~= nexvyrHooks.IndexHook
        and (not nexvyrHooks.NamecallHook or mt.__namecall ~= nexvyrHooks.NamecallHook)
    then
        nexvyrHooks.Metatable = nil
        nexvyrHooks.IndexHook = nil
        nexvyrHooks.NamecallHook = nil
    end
end

getgenv().__NexvyrDmvsAimCleanup = nexvyrRestoreHooks

local function nexvyrInstallHooks()
    if nexvyrHooks.Metatable then
        local mt = nexvyrHooks.Metatable
        local active = mt.__index == nexvyrHooks.IndexHook
        nexvyrHooks.Enabled = active
        return active
    end
    if type(getrawmetatable) ~= "function" or type(setreadonly) ~= "function" then
        warn("Nexvyr: este executor no permite instalar la redireccion del mouse.")
        return false
    end
    local ok, mt = pcall(getrawmetatable, nexvyrIsMadium and game or nexvyrMouse)
    if not ok or not mt then
        return false
    end
    local originalIndex, originalNamecall = mt.__index, mt.__namecall
    if type(originalIndex) ~= "function" and type(originalIndex) ~= "table" then
        return false
    end
    local wasReadonly = true
    if type(isreadonly) == "function" then
        local success, readonly = pcall(isreadonly, mt)
        if success and type(readonly) == "boolean" then
            wasReadonly = readonly
        end
    end
    local function originalLookup(self, key)
        if type(originalIndex) == "function" then
            return originalIndex(self, key)
        end
        return originalIndex[key]
    end
    local indexHook = function(self, key)
        if
            nexvyrHooks.Enabled
            and self == nexvyrMouse
            and (key == "Hit" or key == "Target" or key == "UnitRay" or (nexvyrIsMadium and key == "TargetSurface"))
            and (nexvyrIsMadium or type(checkcaller) ~= "function" or not checkcaller())
        then
            local ok, point, target = pcall(nexvyrGetAimPoint)
            if ok and point and target then
                if key == "Target" then
                    return target
                end
                if key == "TargetSurface" then
                    return Enum.NormalId.Front
                end
                if key == "Hit" then
                    if nexvyrIsMadium then
                        return CFrame.new(point)
                    end
                    local origin = nexvyrShotOrigin()
                    local direction = origin and point - origin
                    if direction and direction.Magnitude > 0.001 then
                        return CFrame.lookAt(point, point + direction.Unit)
                    end
                    return CFrame.new(point)
                end
                local originalRay = originalLookup(self, key)
                local origin = typeof(originalRay) == "Ray" and originalRay.Origin or nil
                if not origin then
                    local cam = workspace.CurrentCamera
                    origin = cam and cam.CFrame.Position or nexvyrShotOrigin()
                end
                local direction = origin and point - origin
                if direction and direction.Magnitude > 0.001 then
                    return Ray.new(origin, direction.Unit)
                end
            end
        end
        return originalLookup(self, key)
    end
    local namecallHook
    if
        not nexvyrIsMadium
        and type(originalNamecall) == "function"
        and type(getnamecallmethod) == "function"
        and type(checkcaller) == "function"
    then
        namecallHook = function(self, ...)
            if not nexvyrHooks.Enabled or checkcaller() then
                return originalNamecall(self, ...)
            end
            if self == workspace and not nexvyrHooks.ResolvingRay then
                local method = getnamecallmethod()
                local direct = method and nexvyrDirectCalls[method]
                if direct then
                    local args = table.pack(...)
                    local origin, length
                    if method == "Raycast" then
                        if typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                            origin, length = args[1], args[2].Magnitude
                        end
                    elseif typeof(args[1]) == "Ray" then
                        origin, length = args[1].Origin, args[1].Direction.Magnitude
                    end
                    if origin and length and length >= 50 and nexvyrLikelyWeaponOrigin(origin) then
                        nexvyrHooks.ResolvingRay = true
                        local success, point = pcall(nexvyrGetAimPoint)
                        nexvyrHooks.ResolvingRay = false
                        if success and point then
                            local toward = point - origin
                            if toward.Magnitude > 0.001 then
                                if method == "Raycast" then
                                    args[2] = toward.Unit * length
                                else
                                    args[1] = Ray.new(origin, toward.Unit * length)
                                end
                            end
                        end
                    end
                    return direct(self, table.unpack(args, 1, args.n))
                end
            end
            return originalNamecall(self, ...)
        end
    end
    if not pcall(setreadonly, mt, false) then
        return false
    end
    local installed = pcall(function()
        mt.__index = indexHook
        if namecallHook then
            mt.__namecall = namecallHook
        end
    end)
    if not installed then
        pcall(function()
            if mt.__index == indexHook then
                mt.__index = originalIndex
            end
            if namecallHook and mt.__namecall == namecallHook then
                mt.__namecall = originalNamecall
            end
        end)
        pcall(setreadonly, mt, wasReadonly)
        return false
    end
    pcall(setreadonly, mt, wasReadonly)
    nexvyrHooks.Metatable = mt
    nexvyrHooks.OriginalIndex = originalIndex
    nexvyrHooks.OriginalNamecall = originalNamecall
    nexvyrHooks.IndexHook = indexHook
    nexvyrHooks.NamecallHook = namecallHook
    nexvyrHooks.WasReadonly = wasReadonly
    nexvyrHooks.Enabled = true
    return true
end

local function nexvyrUpdateHook()
    if nexvyrAimActive() then
        nexvyrInstallHooks()
    else
        nexvyrAimTargets.Auto = nil
        nexvyrAimTargets.Silent = nil
        nexvyrAutoFireUntil = 0
        getgenv().NexvyrTargetPart = nil
        nexvyrRestoreHooks()
    end
end
local nexvyrUpdateTargetWorkers
nexvyrUpdateTargetFeatures = function()
    nexvyrRefreshTargetMonitor()
    nexvyrUpdateHook()
    if nexvyrUpdateTargetWorkers then
        nexvyrUpdateTargetWorkers()
    end
end

local nexvyrAutoShootWorkerRunning = false
nexvyrStartAutoShootWorker = function()
    if nexvyrAutoShootWorkerRunning or not (autoShootEnabled or autoShootAgresivoEnabled) then
        return
    end
    nexvyrAutoShootWorkerRunning = true
    task.spawn(function()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        while autoShootEnabled or autoShootAgresivoEnabled do
            task.wait(0.1)
            if not (autoShootEnabled or autoShootAgresivoEnabled) then
                break
            end
            if not nexvyrHooks.Enabled then
                continue
            end
            if not estaEnLobby() then
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    continue
                end
                local arma = char:FindFirstChildOfClass("Tool")
                if not arma or not arma:FindFirstChild("Handle") then
                    nexvyrSetAimTarget("Auto", nil)
                    continue
                end
                if not esPistola(arma) then
                    nexvyrSetAimTarget("Auto", nil)
                    continue
                end
                local closestTargetPart = nil
                local shortestDistance = math.huge
                local myPos = char.HumanoidRootPart.Position
                local head = char:FindFirstChild("Head")
                local headPos = head and head.Position or myPos
                local playersToCheck = {}
                for _, other in ipairs(Players:GetPlayers()) do
                    if other ~= player and isEnemy(other) and other.Character then
                        local enemyCharacter = other.Character
                        local humanoid = enemyCharacter:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            local root = enemyCharacter:FindFirstChild("HumanoidRootPart")
                            playersToCheck[#playersToCheck + 1] = {
                                Character = enemyCharacter,
                                Distance = root and (root.Position - myPos).Magnitude or math.huge,
                            }
                        end
                    end
                end
                table.sort(playersToCheck, function(a, b)
                    return a.Distance < b.Distance
                end)
                local raycastsRemaining = 192
                local function checkPart(part)
                    if not part or not part:IsA("BasePart") then
                        return
                    end
                    local dist = (part.Position - myPos).Magnitude
                    if dist >= shortestDistance then
                        return
                    end
                    local halfHeight = part.Size.Y / 2.1
                    local cframe = part.CFrame
                    local function visible(point)
                        if raycastsRemaining <= 0 then
                            return false
                        end
                        raycastsRemaining -= 1
                        return not workspace:Raycast(headPos, point - headPos, params)
                    end
                    if
                        visible(part.Position)
                        or visible(cframe * Vector3.new(0, halfHeight, 0))
                        or visible(cframe * Vector3.new(0, -halfHeight, 0))
                    then
                        shortestDistance = dist
                        closestTargetPart = part
                    end
                end
                for _, candidate in ipairs(playersToCheck) do
                    if raycastsRemaining <= 0 then
                        break
                    end
                    local enemyCharacter = candidate.Character
                    if enemyCharacter.Parent then
                        params.FilterDescendantsInstances = { char, enemyCharacter }
                        if autoShootAgresivoEnabled or autoShootTargetPart == "Cuerpo Completo" then
                            for _, part in ipairs(enemyCharacter:GetChildren()) do
                                if raycastsRemaining <= 0 then
                                    break
                                end
                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                    checkPart(part)
                                end
                            end
                        elseif autoShootTargetPart == "Cabeza" then
                            checkPart(enemyCharacter:FindFirstChild("Head"))
                        elseif autoShootTargetPart == "Torso" then
                            for _, partName in ipairs({ "UpperTorso", "Torso", "HumanoidRootPart" }) do
                                if raycastsRemaining <= 0 then
                                    break
                                end
                                checkPart(enemyCharacter:FindFirstChild(partName))
                            end
                        end
                    end
                end
                if closestTargetPart then
                    nexvyrAutoFireUntil = os.clock() + 0.35
                    nexvyrSetAimTarget("Auto", closestTargetPart)
                    pcall(function()
                        arma:Activate()
                        task.delay(0.05, function()
                            if arma.Parent == char then
                                arma:Deactivate()
                            end
                        end)
                    end)
                    task.wait(0.2)
                else
                    nexvyrSetAimTarget("Auto", nil)
                end
            end
        end
        nexvyrSetAimTarget("Auto", nil)
        nexvyrAutoShootWorkerRunning = false
    end)
end

local nexvyrSilentWorkerRunning = false
nexvyrStartSilentAimWorker = function()
    if nexvyrSilentWorkerRunning or not (silentAimManualEnabled or silentAimFovEnabled) then
        return
    end
    nexvyrSilentWorkerRunning = true
    task.spawn(function()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        while silentAimManualEnabled or silentAimFovEnabled do
            task.wait(0.1)
            if not (silentAimManualEnabled or silentAimFovEnabled) then
                break
            end
            if not estaEnLobby() then
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    continue
                end
                local closestTargetPart = nil
                local shortestDistToCenter = math.huge
                local shortestDistanceFisica = math.huge
                local myPos = char.HumanoidRootPart.Position
                local headPos = char:FindFirstChild("Head") and char.Head.Position or myPos
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and isEnemy(p) and p.Character then
                        local enemyHum = p.Character:FindFirstChild("Humanoid")
                        if enemyHum and enemyHum.Health > 0 then
                            local partesAEscanear = {}
                            if silentAimTargetPart == "Cabeza" then
                                local head = p.Character:FindFirstChild("Head")
                                if head then
                                    table.insert(partesAEscanear, head)
                                end
                            elseif silentAimTargetPart == "Torso" then
                                local partesClave = { "UpperTorso", "Torso", "HumanoidRootPart" }
                                for _, partName in ipairs(partesClave) do
                                    local part = p.Character:FindFirstChild(partName)
                                    if part and part:IsA("BasePart") then
                                        table.insert(partesAEscanear, part)
                                    end
                                end
                            elseif silentAimTargetPart == "Cuerpo Completo" then
                                for _, part in ipairs(p.Character:GetChildren()) do
                                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                        table.insert(partesAEscanear, part)
                                    end
                                end
                            end
                            params.FilterDescendantsInstances = { char, p.Character }
                            for _, part in ipairs(partesAEscanear) do
                                local distFisica = (part.Position - myPos).Magnitude
                                local currentCamera = workspace.CurrentCamera
                                if not currentCamera then
                                    continue
                                end
                                local pos2D, onScreen =
                                    currentCamera:WorldToViewportPoint(part.Position)
                                local distToCenter = (
                                    Vector2.new(pos2D.X, pos2D.Y)
                                    - currentCamera.ViewportSize / 2
                                ).Magnitude
                                local pasaFiltro = false
                                if silentAimFovEnabled then
                                    if
                                        onScreen
                                        and distToCenter <= fovRadius
                                        and distToCenter < shortestDistToCenter
                                    then
                                        pasaFiltro = true
                                    end
                                elseif silentAimManualEnabled then
                                    if distFisica < shortestDistanceFisica then
                                        pasaFiltro = true
                                    end
                                end
                                if pasaFiltro then
                                    local raycastResult =
                                        workspace:Raycast(headPos, part.Position - headPos, params)
                                    if not raycastResult then
                                        if silentAimFovEnabled then
                                            shortestDistToCenter = distToCenter
                                            closestTargetPart = part
                                        else
                                            shortestDistanceFisica = distFisica
                                            closestTargetPart = part
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if closestTargetPart then
                    nexvyrSetAimTarget("Silent", closestTargetPart)
                else
                    nexvyrSetAimTarget("Silent", nil)
                end
            end
        end
        nexvyrSetAimTarget("Silent", nil)
        nexvyrSilentWorkerRunning = false
    end)
end

nexvyrUpdateTargetWorkers = function()
    if autoShootEnabled or autoShootAgresivoEnabled then
        nexvyrStartAutoShootWorker()
    end
    if silentAimManualEnabled or silentAimFovEnabled then
        nexvyrStartSilentAimWorker()
    end
    if equipGunEnabled then
        nexvyrStartEquipWorker()
    end
end

Tabs.KillAll:Section({ Title = "Kill All", Icon = "solar:danger-triangle-bold" })

UIElements.TogKillAll = Tabs.KillAll:Toggle({
    Title = "Kill All",
    Value = false,
    Callback = function(Value)
        KillAllEnabled = Value
        if nexvyrRefreshTargetMonitor then
            nexvyrRefreshTargetMonitor()
        end
        if Value then
            KillAllInstance:Start()
        else
            KillAllInstance:Stop()
        end
    end,
})

Tabs.KillAll:Space()
Tabs.KillAll:Divider()
Tabs.KillAll:Space()
Tabs.KillAll:Section({ Title = "Hitbox Expander", Icon = "solar:box-bold" })

UIElements.TogHitbox = Tabs.KillAll:Toggle({
    Title = "Activar Hitbox",
    Value = false,
    Callback = function(Value)
        hitboxEnabled = Value
        if nexvyrRefreshTargetMonitor then
            nexvyrRefreshTargetMonitor()
        end
        if Value then
            nexvyrStartHitboxWorker()
        else
            limpiarHitboxes()
        end
    end,
})

UIElements.TogHitboxInvisible = Tabs.KillAll:Toggle({
    Title = "Hitbox Invisible",
    Value = false,
    Callback = function(Value)
        hitboxInvisible = Value
    end,
})

UIElements.SliHitboxSize = Tabs.KillAll:Slider({
    Title = "Tamaño de la Hitbox",
    Step = 0.5,
    Value = { Min = 1.0, Max = 28.0, Default = 3.5 },
    Callback = function(v)
        hitboxSize = v
    end,
})

UIElements.ColHitbox = Tabs.KillAll:Colorpicker({
    Title = "Color de la Hitbox",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(c)
        hitboxColor = c
    end,
})

Tabs.Invisible:Section({ Title = "Invisible", Icon = "solar:ghost-bold" })

local function AplicarInvisibilidadTransparencia(state)
    if player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                if state and v.Transparency == 0 then
                    v:SetAttribute("NexvyrOrigTrans", 0)
                    v.Transparency = 0.5
                elseif not state and v:GetAttribute("NexvyrOrigTrans") ~= nil then
                    v.Transparency = v:GetAttribute("NexvyrOrigTrans")
                    v:SetAttribute("NexvyrOrigTrans", nil)
                end
            end
        end
    end
end

UIElements.TogInvisible = Tabs.Invisible:Toggle({
    Title = "Invisible",
    Value = false,
    Callback = function(Value)
        InvisibilityActive = Value
        AplicarInvisibilidadTransparencia(Value)
        if nexvyrSetInvisibleWorker then
            nexvyrSetInvisibleWorker(Value)
        end
    end,
})

local nexvyrInvisibleConnection
nexvyrSetInvisibleWorker = function(state)
    if nexvyrInvisibleConnection then
        nexvyrInvisibleConnection:Disconnect()
        nexvyrInvisibleConnection = nil
    end
    if not state then
        return
    end
    nexvyrInvisibleConnection = RunService.Heartbeat:Connect(function()
        if not InvisibilityActive then
            return
        end
        local Char = player.Character
        if Char then
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            if Root and Hum and Hum.Health > 0 then
                if Root.Position.Y > 200 then
                    return
                end
                local oldCF = Root.CFrame
                local oldCamOffset = Hum.CameraOffset
                local invisCF = oldCF * CFrame.new(0, -40, 0)
                Root.CFrame = invisCF
                Hum.CameraOffset = invisCF:ToObjectSpace(CFrame.new(oldCF.Position)).Position
                RunService.RenderStepped:Wait()
                if Root.Parent and Hum.Parent then
                    Root.CFrame = oldCF
                    Hum.CameraOffset = oldCamOffset
                end
            end
        end
    end)
end

player.CharacterAdded:Connect(function(character)
    if InvisibilityActive then
        task.wait(0.5)
        AplicarInvisibilidadTransparencia(true)
    end
end)

Tabs.Tramposo:Section({ Title = "Tramposo", Icon = "solar:bolt-bold" })

local remote = ReplicatedStorage:WaitForChild("MovementState", 3)
local function notify(kind, on)
    if remote then
        remote:FireServer(kind, on)
    end
end

local SPEED = 28.7
local JUMP_POWER = 45
local SMOOTH = 14

local speedConn, jumpConn, requestConn
local smoothDir = Vector3.zero
local jumping = false
local vy = 0

local function getChar()
    local c = player.Character
    if not c then
        return
    end
    return c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
end

local function SetSpeed(state)
    if speedConn then
        speedConn:Disconnect()
        speedConn = nil
    end
    smoothDir = Vector3.zero
    if not state then
        return
    end

    speedConn = RunService.Stepped:Connect(function(_, dt)
        local hum, root = getChar()
        if not hum or not root or hum.Health <= 0 then
            return
        end

        local alpha = 1 - math.exp(-SMOOTH * dt)
        smoothDir = smoothDir:Lerp(hum.MoveDirection, alpha)

        if smoothDir.Magnitude > 0.01 then
            local extra = math.max(SPEED - hum.WalkSpeed, 0)
            root.CFrame = root.CFrame + smoothDir * extra * dt
        end
    end)
end

local function SetInfJump(state)
    if jumpConn then
        jumpConn:Disconnect()
        jumpConn = nil
    end
    if requestConn then
        requestConn:Disconnect()
        requestConn = nil
    end
    jumping = false
    vy = 0
    if not state then
        return
    end

    requestConn = UserInputService.JumpRequest:Connect(function()
        jumping = true
    end)

    jumpConn = RunService.Stepped:Connect(function(_, dt)
        local hum, root = getChar()
        if not hum or not root or hum.Health <= 0 then
            return
        end

        local held = UserInputService:IsKeyDown(Enum.KeyCode.Space) or hum.Jump
        if jumping and not held then
            jumping = false
        end

        local target = jumping and JUMP_POWER or 0
        vy = vy + (target - vy) * (1 - math.exp(-SMOOTH * dt))

        if vy > 0.5 then
            root.CFrame = root.CFrame + Vector3.new(0, vy * dt, 0)
            local v = root.AssemblyLinearVelocity
            if v.Y < 0 then
                root.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
            end
        end
    end)
end

UIElements.TogSpeed = Tabs.Tramposo:Toggle({
    Title = "Speed",
    Value = false,
    Callback = function(state)
        SetSpeed(state)
        notify("Speed", state)
    end,
})

UIElements.SliSpeed = Tabs.Tramposo:Slider({
    Title = "Ajuste Speed",
    Step = 1,
    Value = { Min = 1, Max = 100, Default = 29 },
    Callback = function(v)
        SPEED = v
    end,
})

UIElements.TogInfJump = Tabs.Tramposo:Toggle({
    Title = "Salto Inf",
    Value = false,
    Callback = function(state)
        SetInfJump(state)
        notify("Jump", state)
    end,
})

UIElements.SliJumpPower = Tabs.Tramposo:Slider({
    Title = "Ajuste Salto",
    Step = 1,
    Value = { Min = 1, Max = 100, Default = 45 },
    Callback = function(v)
        JUMP_POWER = v
    end,
})

Tabs.RachaFarm:Section({ Title = "Auto Teleport Main/Alt", Icon = "solar:map-arrow-square-bold" })

local autoTPMainToggle, autoTPAltToggle

autoTPMainToggle = Tabs.RachaFarm:Toggle({
    Title = "Auto Teleport (Main)",
    Value = false,
    Callback = function(value)
        if value then
            AutoTeleportMainAltInstance.ActiveRole = "Main"
            if autoTPAltToggle then
                pcall(function()
                    autoTPAltToggle:Set(false)
                end)
            end
            AutoTeleportMainAltInstance:Stop()
            AutoTeleportMainAltInstance:Start()
        else
            if AutoTeleportMainAltInstance.ActiveRole == "Main" then
                AutoTeleportMainAltInstance.ActiveRole = nil
                AutoTeleportMainAltInstance:Stop()
            end
        end
    end,
})

autoTPAltToggle = Tabs.RachaFarm:Toggle({
    Title = "Auto Teleport (Alt)",
    Value = false,
    Callback = function(value)
        if value then
            AutoTeleportMainAltInstance.ActiveRole = "Alt"
            if autoTPMainToggle then
                pcall(function()
                    autoTPMainToggle:Set(false)
                end)
            end
            AutoTeleportMainAltInstance:Stop()
            AutoTeleportMainAltInstance:Start()
        else
            if AutoTeleportMainAltInstance.ActiveRole == "Alt" then
                AutoTeleportMainAltInstance.ActiveRole = nil
                AutoTeleportMainAltInstance:Stop()
            end
        end
    end,
})

Tabs.RachaFarm:Dropdown({
    Title = "Tipo de Duelo",
    Values = { "1v1", "2v2", "3v3", "4v4" },
    Value = "1v1",
    Callback = function(value)
        if PadZoneConfig["Right Platforms"][value] then
            AutoTeleportMainAltInstance.DuelType = value
        else
            AutoTeleportMainAltInstance.DuelType = "1v1"
        end
        AutoTeleportMainAltInstance:Kick()
    end,
})

Tabs.RachaFarm:Dropdown({
    Title = "Fila de Plataformas",
    Values = { "Right Platforms", "Left Platforms" },
    Value = "Right Platforms",
    Callback = function(value)
        if PadZoneConfig[value] then
            AutoTeleportMainAltInstance.PlatformRow = value
        else
            AutoTeleportMainAltInstance.PlatformRow = "Right Platforms"
        end
        AutoTeleportMainAltInstance:Kick()
    end,
})

do
    Tabs.Vis:Section({ Title = "Configuración de ESP", Icon = "solar:eye-bold" })

    local activeESPs = {}
    local MAX_ESP_DISTANCE = 1500
    local function cleanESP(targetPlayer)
        local current = activeESPs[targetPlayer]
        if not current then
            return
        end
        if current.Highlight then
            current.Highlight:Destroy()
        end
        activeESPs[targetPlayer] = nil
    end
    local function cleanAllESPs()
        for other in pairs(activeESPs) do
            cleanESP(other)
        end
    end

    UIElements.TogEsp = Tabs.Vis:Toggle({
        Title = "ESP Jugadores",
        Callback = function(s)
            espEnabled = s
            if nexvyrRefreshTargetMonitor then
                nexvyrRefreshTargetMonitor()
            end
            if espEnabled and espSettings.Glow then
                nexvyrStartESPWorker()
            else
                cleanAllESPs()
            end
        end,
    })

    UIElements.ColEsp = Tabs.Vis:Colorpicker({
        Title = "Color del ESP",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(c)
            espColor = c
        end,
    })

    Tabs.Vis:Space()
    Tabs.Vis:Divider()
    Tabs.Vis:Space()
    Tabs.Vis:Section({ Title = "Filtros de ESP", Icon = "solar:filter-bold" })

    UIElements.TogEspGl = Tabs.Vis:Toggle({
        Title = "Mostrar Resplandor",
        Value = true,
        Callback = function(s)
            espSettings.Glow = s
            if nexvyrRefreshTargetMonitor then
                nexvyrRefreshTargetMonitor()
            end
            if s and espEnabled then
                nexvyrStartESPWorker()
            else
                cleanAllESPs()
            end
        end,
    })

    local nexvyrESPWorkerRunning = false
    nexvyrStartESPWorker = function()
        if nexvyrESPWorkerRunning or not espEnabled or not espSettings.Glow then
            return
        end
        nexvyrESPWorkerRunning = true
        task.spawn(function()
            local removingConnection = Players.PlayerRemoving:Connect(cleanESP)
            while espEnabled and espSettings.Glow do
                task.wait(0.2)
                if not espEnabled or not espSettings.Glow then
                    break
                end
                if IsInMatchStrict() then
                    local own = player.Character
                    local head = own and own:FindFirstChild("Head")
                    local pos = head and head.Position
                    for _, other in ipairs(Players:GetPlayers()) do
                        if other ~= player then
                            local character = other.Character
                            local enemyHead = character and character:FindFirstChild("Head")
                            if
                                enemyHead
                                and isEnemy(other)
                                and (
                                    not pos
                                    or (enemyHead.Position - pos).Magnitude <= MAX_ESP_DISTANCE
                                )
                            then
                                local activeEntry = activeESPs[other]
                                if
                                    activeEntry
                                    and (
                                        activeEntry.Char ~= character
                                        or not activeEntry.Highlight
                                        or activeEntry.Highlight.Parent ~= espFolder
                                    )
                                then
                                    cleanESP(other)
                                end
                                if not activeESPs[other] then
                                    local glow = Instance.new("Highlight")
                                    glow.Name = other.Name .. "_Glow"
                                    glow.FillTransparency = 1
                                    glow.OutlineTransparency = 0
                                    glow.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    glow.Adornee = character
                                    glow.Parent = espFolder
                                    activeESPs[other] = { Highlight = glow, Char = character }
                                end
                                local current = activeESPs[other].Highlight
                                if current.Enabled ~= espSettings.Glow then
                                    current.Enabled = espSettings.Glow
                                end
                                if current.OutlineColor ~= espColor then
                                    current.OutlineColor = espColor
                                end
                            else
                                cleanESP(other)
                            end
                        end
                    end
                else
                    cleanAllESPs()
                end
            end
            removingConnection:Disconnect()
            cleanAllESPs()
            nexvyrESPWorkerRunning = false
        end)
    end

    local FOVCircle
    local nexvyrFOVConnection
    nexvyrStartFOVWorker = function()
        if not fovVisiblePreference then
            if nexvyrFOVConnection then
                nexvyrFOVConnection:Disconnect()
                nexvyrFOVConnection = nil
            end
            if FOVCircle then
                FOVCircle.Visible = false
            end
            return
        end
        if not FOVCircle and Drawing then
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Filled = false
            FOVCircle.Thickness = 1
            FOVCircle.Visible = false
        end
        if not FOVCircle or nexvyrFOVConnection then
            return
        end
        nexvyrFOVConnection = RunService.RenderStepped:Connect(function()
            if not fovVisiblePreference then
                return
            end
            local currentCamera = workspace.CurrentCamera
            if not currentCamera then
                return
            end
            FOVCircle.Position = currentCamera.ViewportSize / 2
            FOVCircle.Radius = fovRadius
            FOVCircle.Color = silentAimFovEnabled
                    and getgenv().NexvyrTargetPart
                    and Color3.fromRGB(0, 255, 0)
                or Color3.fromRGB(255, 255, 255)
            FOVCircle.Visible = true
        end)
    end

    Tabs.Farm:Section({ Title = "Farmeo de Evento", Icon = "solar:gift-bold" })

    getgenv().AutoEventFarm = false
    local nexvyrFarmSession = 0
    local Networking = ReplicatedStorage:FindFirstChild("Packages")
        and ReplicatedStorage.Packages:FindFirstChild("Networking")
    local RemoteFarm = Networking and Networking:FindFirstChild("RE/Events/CollectEventSpawnable")

    Tabs.Farm:Toggle({
        Title = "Auto Farmear Evento",
        Callback = function(s)
            getgenv().AutoEventFarm = s
            nexvyrFarmSession += 1
            local session = nexvyrFarmSession
            if s then
                task.spawn(function()
                    while getgenv().AutoEventFarm and session == nexvyrFarmSession do
                        pcall(function()
                            if RemoteFarm then
                                RemoteFarm:FireServer()
                            else
                                Networking = ReplicatedStorage:FindFirstChild("Packages")
                                    and ReplicatedStorage.Packages:FindFirstChild("Networking")
                                RemoteFarm = Networking
                                    and Networking:FindFirstChild("RE/Events/CollectEventSpawnable")
                            end
                        end)
                        local char = player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local container = workspace:FindFirstChild("SpawnablesClient")
                            if container then
                                for _, obj in ipairs(container:GetChildren()) do
                                    if
                                        not getgenv().AutoEventFarm
                                        or session ~= nexvyrFarmSession
                                    then
                                        break
                                    end
                                    local touchPart = obj:FindFirstChild("Touch")
                                    if touchPart then
                                        pcall(function()
                                            firetouchinterest(hrp, touchPart, 0)
                                            firetouchinterest(hrp, touchPart, 1)
                                        end)
                                    end
                                end
                            end
                        end
                        task.wait(0.05)
                    end
                end)
            end
        end,
    })
end

do
    local animationData = {
        ["Old School"] = {
            Walk = 10921244891,
            Run = 10921240218,
            Jump = 10921242013,
            Fall = 10921241244,
            SwimIdle = 10921244018,
            Swim = 10921243048,
            Idle = 10921230744,
            Idle2 = 10921232093,
            Climb = 10921229866,
        },
        ["Adidas Sports"] = {
            Walk = 18537392113,
            Run = 18537384940,
            Jump = 18537380791,
            Fall = 18537367238,
            SwimIdle = 18537387180,
            Swim = 18537389531,
            Idle = 18537376492,
            Idle2 = 18537371272,
            Climb = 18537363391,
        },
        ["Adidas Community"] = {
            Walk = 122150855457006,
            Run = 82598234841035,
            Jump = 75290611992385,
            Fall = 98600215928904,
            SwimIdle = 109346520324160,
            Swim = 133308483266208,
            Idle = 122257458498464,
            Idle2 = 102357151005774,
            Climb = 88763136693023,
        },
        ["Adidas Aura"] = {
            Walk = 83842218823011,
            Run = 118320322718866,
            Jump = 109996626521204,
            Fall = 95603166884636,
            SwimIdle = 94922130551805,
            Swim = 134530128383903,
            Idle = 110211186840347,
            Idle2 = 114191137265065,
            Climb = 97824616490448,
        },
        ["Wicked Popular"] = {
            Walk = 92072849924640,
            Run = 72301599441680,
            Jump = 104325245285198,
            Fall = 121152442762481,
            Idle = 118832222982049,
            Idle2 = 76049494037641,
            SwimIdle = 113199415118199,
            Swim = 99384245425157,
            Climb = 131326830509784,
        },
        ["Elder"] = {
            Walk = 10921111375,
            Run = 10921104374,
            Jump = 10921107367,
            Fall = 10921105765,
            SwimIdle = 10921110146,
            Swim = 10921108971,
            Idle = 10921101664,
            Idle2 = 10921102574,
            Climb = 10921100400,
        },
        ["Zombie"] = {
            Walk = 10921355261,
            Run = 616163682,
            Jump = 10921351278,
            Fall = 10921350320,
            SwimIdle = 10921353442,
            Swim = 10921352344,
            Idle = 10921344533,
            Idle2 = 10921345304,
            Climb = 10921343576,
        },
        ["Mage"] = {
            Walk = 10921152678,
            Run = 10921148209,
            Jump = 10921149743,
            Fall = 10921148939,
            SwimIdle = 10921151661,
            Swim = 10921150788,
            Idle = 10921144709,
            Idle2 = 10921145797,
            Climb = 10921143404,
        },
        ["Catwalk Glam"] = {
            Walk = 109168724482748,
            Run = 81024476153754,
            Jump = 116936326516985,
            Fall = 92294537340807,
            SwimIdle = 98854111361360,
            Swim = 134591743181628,
            Idle = 133806214992291,
            Idle2 = 94970088341563,
            Climb = 119377220967554,
        },
        ["Astronaut"] = {
            Walk = 10921046031,
            Run = 10921039308,
            Jump = 10921042494,
            Fall = 10921040576,
            SwimIdle = 10921045006,
            Swim = 10921044000,
            Idle = 10921034824,
            Idle2 = 10921036806,
            Climb = 10921032124,
        },
        ['Wicked "Dancing Through Life"'] = {
            Walk = 73718308412641,
            Run = 135515454877967,
            Jump = 78508480717326,
            Fall = 78147885297412,
            SwimIdle = 129183123083281,
            Swim = 110657013921774,
            Idle = 92849173543269,
            Idle2 = 132238900951109,
            Climb = 129447497744818,
        },
        ["Werewolf"] = {
            Walk = 10921342074,
            Run = 10921336997,
            Fall = 10921337907,
            SwimIdle = 10921341319,
            Swim = 10921340419,
            Idle = 10921330408,
            Idle2 = 10921333667,
            Climb = 10921329322,
        },
        ["Superhero"] = {
            Walk = 10921298616,
            Run = 10921291831,
            Jump = 10921294559,
            Fall = 10921293273,
            SwimIdle = 10921297391,
            Swim = 10921295495,
            Idle = 10921288909,
            Idle2 = 10921290167,
            Climb = 10921286911,
        },
        ["Toy"] = {
            Walk = 10921312010,
            Run = 10921306285,
            Jump = 10921308158,
            Fall = 10921307241,
            SwimIdle = 10921310341,
            Swim = 10921309319,
            Idle = 10921301576,
            Climb = 10921300839,
        },
        ["No Boundaries"] = {
            Walk = 18747074203,
            Run = 18747070484,
            Jump = 18747069148,
            Fall = 18747062535,
            SwimIdle = 18747071682,
            Swim = 18747073181,
            Idle = 18747067405,
            Idle2 = 18747063918,
            Climb = 18747060903,
        },
        ["NFL"] = {
            Walk = 110358958299415,
            Run = 117333533048078,
            Jump = 119846112151352,
            Fall = 129773241321032,
            SwimIdle = 79090109939093,
            Swim = 132697394189921,
            Idle = 92080889861410,
            Idle2 = 74451233229259,
            Climb = 134630013742019,
        },
        ["Amazon Unboxed"] = {
            Walk = 90478085024465,
            Run = 134824450619865,
            Jump = 121454505477205,
            Fall = 94788218468396,
            SwimIdle = 129126268464847,
            Swim = 105962919001086,
            Idle = 98281136301627,
            Climb = 121145883950231,
        },
        ["Vampire"] = {
            Walk = 10921326949,
            Run = 10921320299,
            Jump = 10921322186,
            Fall = 10921321317,
            SwimIdle = 10921325443,
            Swim = 10921324408,
            Idle = 10921315373,
            Climb = 10921314188,
        },
        ["Ninja"] = {
            Walk = 656121766,
            Run = 656118852,
            Jump = 656117878,
            Fall = 656115606,
            SwimIdle = 656121397,
            Swim = 656119721,
            Idle = 656117400,
            Idle2 = 656118341,
            Climb = 656114359,
        },
        ["Robot"] = {
            Walk = 616095330,
            Run = 616091570,
            Jump = 616090535,
            Fall = 616087089,
            SwimIdle = 616094091,
            Swim = 616092998,
            Idle = 616088211,
            Idle2 = 616089559,
            Climb = 616086039,
        },
        ["Levitation"] = {
            Walk = 616013216,
            Run = 616010382,
            Jump = 616008936,
            Fall = 616005863,
            SwimIdle = 616012453,
            Swim = 616011509,
            Idle = 616006778,
            Idle2 = 616008087,
            Climb = 616003713,
        },
        ["Stylish"] = {
            Walk = 616146177,
            Run = 616140816,
            Jump = 616139451,
            Fall = 616134815,
            SwimIdle = 616144772,
            Swim = 616143378,
            Idle = 616136790,
            Idle2 = 616138447,
            Climb = 616133594,
        },
        ["Bubbly"] = {
            Walk = 910034870,
            Run = 910025107,
            Jump = 910016857,
            Fall = 910001910,
            SwimIdle = 910030921,
            Swim = 910028158,
            Idle = 910004836,
            Idle2 = 910009958,
            Climb = 909997997,
        },
        ["Cartoon"] = {
            Walk = 742640026,
            Run = 742638842,
            Jump = 742637942,
            Fall = 742637151,
            SwimIdle = 742639812,
            Swim = 742639220,
            Idle = 742637544,
            Idle2 = 742638445,
            Climb = 742636889,
        },
    }

    local function clearAllAnimations()
        local char = player.Character
        if not char then
            return
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            return
        end
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            track:Stop(0)
            track:Destroy()
        end
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0)
                track:Destroy()
            end
        end
        task.wait(0.1)
    end

    local function applyCustomAnims(customData)
        if not customData then
            return
        end
        local char = player.Character
        if not char then
            return
        end
        clearAllAnimations()
        local animate = char:FindFirstChild("Animate")
        if not animate then
            return
        end
        if not misAnimacionesOriginales then
            local function getAnim(folderName, animName)
                local folder = animate:FindFirstChild(folderName)
                if folder then
                    local anim = folder:FindFirstChild(animName)
                    if anim and anim:IsA("Animation") then
                        local idStr = anim.AnimationId:match("%d+")
                        if idStr then
                            return tonumber(idStr)
                        end
                    end
                end
                return nil
            end
            misAnimacionesOriginales = {
                Idle = getAnim("idle", "Animation1") or 507766666,
                Idle2 = getAnim("idle", "Animation2") or 507766951,
                Walk = getAnim("walk", "WalkAnim") or 507777826,
                Run = getAnim("run", "RunAnim") or 507767714,
                Jump = getAnim("jump", "JumpAnim") or 507765000,
                Climb = getAnim("climb", "ClimbAnim") or 507765644,
                Fall = getAnim("fall", "FallAnim") or 507767968,
                Swim = getAnim("swim", "Swim") or 507784897,
                SwimIdle = getAnim("swimidle", "SwimIdle") or 507785072,
            }
        end
        animate.Disabled = true
        task.wait(0.1)
        local function updateAnimation(folderName, animName, animId)
            if not animId then
                return
            end
            local folder = animate:FindFirstChild(folderName)
            if folder then
                local anim = folder:FindFirstChild(animName)
                if anim and anim:IsA("Animation") then
                    anim.AnimationId = "rbxassetid://" .. tostring(animId)
                end
            end
        end
        updateAnimation("idle", "Animation1", customData.Idle)
        updateAnimation("idle", "Animation2", customData.Idle2 or customData.Idle)
        updateAnimation("walk", "WalkAnim", customData.Walk)
        updateAnimation("run", "RunAnim", customData.Run)
        updateAnimation("jump", "JumpAnim", customData.Jump)
        updateAnimation("climb", "ClimbAnim", customData.Climb)
        updateAnimation("fall", "FallAnim", customData.Fall)
        updateAnimation("swim", "Swim", customData.Swim)
        updateAnimation("swimidle", "SwimIdle", customData.SwimIdle or customData.Swim)
        task.wait(0.1)
        animate.Disabled = false
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Landed)
            task.wait(0.05)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end

    local nexvyrAnimationWorkerRunning = false
    nexvyrStartAnimationWorker = function()
        if nexvyrAnimationWorkerRunning or not animacionActualActiva then
            return
        end
        nexvyrAnimationWorkerRunning = true
        task.spawn(function()
            while animacionActualActiva do
                task.wait(0.2)
                if not animacionActualActiva then
                    break
                end
                local char = player.Character
                if not char then
                    continue
                end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then
                    continue
                end
                if hum.Health <= 0 then
                    continue
                end
                if hum.MoveDirection.Magnitude >= 0.1 then
                    continue
                end
                local animate = char:FindFirstChild("Animate")
                if not animate then
                    continue
                end
                local walkIds = {}
                local walkFolder = animate:FindFirstChild("walk")
                local runFolder = animate:FindFirstChild("run")
                if walkFolder then
                    for _, anim in ipairs(walkFolder:GetChildren()) do
                        if anim:IsA("Animation") then
                            table.insert(walkIds, anim.AnimationId)
                        end
                    end
                end
                if runFolder then
                    for _, anim in ipairs(runFolder:GetChildren()) do
                        if anim:IsA("Animation") then
                            table.insert(walkIds, anim.AnimationId)
                        end
                    end
                end
                if #walkIds == 0 then
                    continue
                end
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        if track.Animation and table.find(walkIds, track.Animation.AnimationId) then
                            track:Stop(0)
                        end
                    end
                end
            end
            nexvyrAnimationWorkerRunning = false
        end)
    end

    player.CharacterAdded:Connect(function()
        if animacionActualActiva then
            task.spawn(function()
                task.wait(0.8)
                applyCustomAnims(animacionActualActiva)
            end)
        end
    end)

    local animList = { "Ninguno" }
    for name, _ in pairs(animationData) do
        table.insert(animList, name)
    end
    table.sort(animList)

    Tabs.Animaciones:Section({ Title = "Paquetes Completos", Icon = "solar:folder-with-files-bold" })
    local selectedBundleCompleto = "Ninguno"
    Tabs.Animaciones:Dropdown({
        Title = "Elegir Paquete",
        Values = animList,
        Value = "Ninguno",
        Callback = function(Value)
            selectedBundleCompleto = Value
        end,
    })

    Tabs.Animaciones:Button({
        Title = "Aplicar Paquete Completo",
        Callback = function()
            if selectedBundleCompleto == "Ninguno" then
                return
            end
            task.spawn(function()
                animacionActualActiva = animationData[selectedBundleCompleto]
                nexvyrStartAnimationWorker()
                applyCustomAnims(animacionActualActiva)
            end)
        end,
    })

    Tabs.Animaciones:Button({
        Title = "Restaurar Default",
        Callback = function()
            task.spawn(function()
                local defaultAnims = misAnimacionesOriginales
                    or {
                        Idle = 507766666,
                        Idle2 = 507766951,
                        Walk = 507777826,
                        Run = 507767714,
                        Jump = 507765000,
                        Climb = 507765644,
                        Fall = 507767968,
                        Swim = 507784897,
                        SwimIdle = 507785072,
                    }
                animacionActualActiva = nil
                applyCustomAnims(defaultAnims)
            end)
        end,
    })

    Tabs.Animaciones:Space()
    Tabs.Animaciones:Divider()
    Tabs.Animaciones:Space()
    Tabs.Animaciones:Section({ Title = "Mezclador de Animaciones", Icon = "solar:layers-bold" })

    local mixParts = {
        Idle = "Ninguno",
        Walk = "Ninguno",
        Run = "Ninguno",
        Jump = "Ninguno",
        Fall = "Ninguno",
        Climb = "Ninguno",
    }

    Tabs.Animaciones:Dropdown({
        Title = "Reposo",
        Values = animList,
        Value = "Ninguno",
        Callback = function(Value)
            mixParts.Idle = Value
        end,
    })
    Tabs.Animaciones:Dropdown({
        Title = "Caminar",
        Values = animList,
        Value = "Ninguno",
        Callback = function(Value)
            mixParts.Walk = Value
        end,
    })
    Tabs.Animaciones:Dropdown({
        Title = "Correr",
        Values = animList,
        Value = "Ninguno",
        Callback = function(Value)
            mixParts.Run = Value
        end,
    })
    Tabs.Animaciones:Dropdown({
        Title = "Saltar",
        Values = animList,
        Value = "Ninguno",
        Callback = function(Value)
            mixParts.Jump = Value
        end,
    })
    Tabs.Animaciones:Dropdown({
        Title = "Caer",
        Values = animList,
        Value = "Ninguno",
        Callback = function(Value)
            mixParts.Fall = Value
        end,
    })
    Tabs.Animaciones:Dropdown({
        Title = "Escalar",
        Values = animList,
        Value = "Ninguno",
        Callback = function(Value)
            mixParts.Climb = Value
        end,
    })

    Tabs.Animaciones:Button({
        Title = "Combinar y Aplicar",
        Callback = function()
            task.spawn(function()
                local customMix = {}
                if mixParts.Idle ~= "Ninguno" then
                    customMix.Idle = animationData[mixParts.Idle].Idle
                    customMix.Idle2 = animationData[mixParts.Idle].Idle2
                end
                if mixParts.Walk ~= "Ninguno" then
                    customMix.Walk = animationData[mixParts.Walk].Walk
                end
                if mixParts.Run ~= "Ninguno" then
                    customMix.Run = animationData[mixParts.Run].Run
                end
                if mixParts.Jump ~= "Ninguno" then
                    customMix.Jump = animationData[mixParts.Jump].Jump
                end
                if mixParts.Fall ~= "Ninguno" then
                    customMix.Fall = animationData[mixParts.Fall].Fall
                end
                if mixParts.Climb ~= "Ninguno" then
                    customMix.Climb = animationData[mixParts.Climb].Climb
                end
                local hasValues = false
                for _, v in pairs(customMix) do
                    if v then
                        hasValues = true
                        break
                    end
                end
                if hasValues then
                    animacionActualActiva = customMix
                    nexvyrStartAnimationWorker()
                    applyCustomAnims(animacionActualActiva)
                end
            end)
        end,
    })
end

local KillSoundEnabled = false
local RecargaDisparoEnabled = false
local SelectedKillSound = "Onichaaan"
local KillSoundVolume = 1

local KillSounds = {
    { Name = "Onichaaan", Id = "114361503583259" },
    { Name = "Omagaaa", Id = "4496966777" },
    { Name = "korummm", Id = "119896940405402" },
    { Name = "FAAAH XD", Id = "92076037937225" },
    { Name = "Campana meme", Id = "107378927201728" },
    { Name = "Enrique", Id = "100688006999379" },
    { Name = "Magia de anime", Id = "109296938403067" },
    { Name = "Risa anime", Id = "93739527256723" },
    { Name = "Gemido", Id = "94981264286350" },
    { Name = "Magic 2", Id = "100507897550384" },
    { Name = "OwO", Id = "71942674274967" },
    { Name = "SEMPAI >.<", Id = "115498703521334" },
    { Name = "Ahhh:3", Id = "83559496188823" },
    { Name = "ñyaa >//~//<", Id = "78798011197804" },
}

local KillSoundPlayer = Instance.new("Sound")
KillSoundPlayer.Name = "NexvyrKillSound"
KillSoundPlayer.Volume = 1
KillSoundPlayer.Looped = false
KillSoundPlayer.Parent = SoundService

local ShootReloadOptions = {
    ["Revolver + Recarga"] = { Shoot = "680140087", Reload = "138084889" },
    ["Magia de Anime"] = { Shoot = "109296938403067", Reload = nil },
    ["Láser + Recarga láser"] = { Shoot = "4400449399", Reload = "129456040607483" },
}
local SelectedShootReload = "Revolver + Recarga"

local SHOOT_SOUND_MAX_DURATION = 1.5
local shootSoundToken = 0
local lastShootSoundTime = 0
local SHOOT_SOUND_MIN_INTERVAL = 0.05

local ShootSoundPlayer = Instance.new("Sound")
ShootSoundPlayer.Name = "NexvyrShootSound"
ShootSoundPlayer.Volume = 1
ShootSoundPlayer.Looped = false
ShootSoundPlayer.Parent = SoundService

local ReloadSoundPlayer = Instance.new("Sound")
ReloadSoundPlayer.Name = "NexvyrReloadSound"
ReloadSoundPlayer.Volume = 1
ReloadSoundPlayer.Looped = false
ReloadSoundPlayer.Parent = SoundService

local function PlayShootSound()
    if not RecargaDisparoEnabled then
        return
    end
    local cfg = ShootReloadOptions[SelectedShootReload]
    if not cfg or not cfg.Shoot then
        return
    end
    local now = tick()
    if now - lastShootSoundTime < SHOOT_SOUND_MIN_INTERVAL then
        return
    end
    lastShootSoundTime = now
    shootSoundToken = shootSoundToken + 1
    local myToken = shootSoundToken
    ShootSoundPlayer:Stop()
    ShootSoundPlayer.SoundId = "rbxassetid://" .. cfg.Shoot
    ShootSoundPlayer.Volume = KillSoundVolume
    ShootSoundPlayer:Play()
    task.delay(SHOOT_SOUND_MAX_DURATION, function()
        if shootSoundToken == myToken and ShootSoundPlayer.Playing then
            ShootSoundPlayer:Stop()
        end
    end)
end

local function PlayReloadSound()
    if not RecargaDisparoEnabled then
        return
    end
    local cfg = ShootReloadOptions[SelectedShootReload]
    if not cfg or not cfg.Reload then
        return
    end
    ReloadSoundPlayer:Stop()
    ReloadSoundPlayer.SoundId = "rbxassetid://" .. cfg.Reload
    ReloadSoundPlayer.Volume = KillSoundVolume
    ReloadSoundPlayer:Play()
end

local nexvyrShootConnections = {}
local nexvyrFireWatched = setmetatable({}, { __mode = "k" })
local nexvyrToolWatched = setmetatable({}, { __mode = "k" })
local nexvyrShootRootWatched = setmetatable({}, { __mode = "k" })
local function nexvyrTrackShoot(connection)
    nexvyrShootConnections[#nexvyrShootConnections + 1] = connection
    return connection
end
local function nexvyrStopShootWatchers()
    dmvsDisconnectConnectionList(nexvyrShootConnections)
    table.clear(nexvyrFireWatched)
    table.clear(nexvyrToolWatched)
    table.clear(nexvyrShootRootWatched)
end
local nexvyrStartReloadWorker
local FIRE_SOUND_KEYWORDS = {
    "fire",
    "shoot",
    "shot",
    "gun",
    "burst",
    "shotgun",
    "gunshot",
    "muzzle",
    "rifle",
    "pistol",
    "shooting",
    "firing",
}

local function isFireSound(s)
    if not s:IsA("Sound") then
        return false
    end
    local n = string.lower(s.Name)
    for _, kw in ipairs(FIRE_SOUND_KEYWORDS) do
        if string.find(n, kw, 1, true) then
            return true
        end
    end
    return false
end

local function HookFireSound(s)
    if not s:IsA("Sound") then
        return
    end
    if not isFireSound(s) then
        return
    end
    if not RecargaDisparoEnabled or nexvyrFireWatched[s] then
        return
    end
    nexvyrFireWatched[s] = true
    nexvyrTrackShoot(s.Played:Connect(function()
        if not RecargaDisparoEnabled then
            return
        end
        local char = player.Character
        if not char then
            return
        end
        if
            s:IsDescendantOf(char)
            or s:IsDescendantOf(player:FindFirstChildOfClass("Backpack") or char)
        then
            PlayShootSound()
        end
    end))
end

local function HookShootOnTool(tool)
    if not tool or not tool:IsA("Tool") then
        return
    end
    for _, d in ipairs(tool:GetDescendants()) do
        HookFireSound(d)
    end
    if not nexvyrToolWatched[tool] and RecargaDisparoEnabled then
        nexvyrToolWatched[tool] = true
        nexvyrTrackShoot(tool.DescendantAdded:Connect(HookFireSound))
    end
end

local function HookShootOnRoot(root)
    if not root then
        return
    end
    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("Tool") then
            HookShootOnTool(child)
        end
    end
    nexvyrTrackShoot(root.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            HookShootOnTool(child)
        end
    end))
end

local nexvyrReloadRunning = false
nexvyrStartReloadWorker = function()
    if nexvyrReloadRunning or not RecargaDisparoEnabled then
        return
    end
    nexvyrReloadRunning = true
    task.spawn(function()
        local lastReloadState = false
        while RecargaDisparoEnabled do
            task.wait(0.05)
            if not RecargaDisparoEnabled then
                break
            end
            local char = player.Character
            if not char then
                lastReloadState = false
                continue
            end
            local arma = char:FindFirstChildOfClass("Tool")
            if not arma or esCuchillo(arma) then
                lastReloadState = false
                continue
            end
            local recargando = estaRecargando(arma)
            if recargando and not lastReloadState then
                PlayReloadSound()
            end
            lastReloadState = recargando
        end
        nexvyrReloadRunning = false
    end)
end

local function GetKillSoundIdByName(soundName)
    for _, s in ipairs(KillSounds) do
        if s.Name == soundName then
            return s.Id
        end
    end
    return KillSounds[1].Id
end

local function PlayKillSound()
    if not KillSoundEnabled then
        return
    end
    KillSoundPlayer:Stop()
    KillSoundPlayer.SoundId = "rbxassetid://" .. GetKillSoundIdByName(SelectedKillSound)
    KillSoundPlayer.Volume = KillSoundVolume
    KillSoundPlayer:Play()
end

local lastKillSoundTime = 0
local KILL_SOUND_COOLDOWN = 0.08
local function TryPlayKillSound()
    if not KillSoundEnabled then
        return
    end
    local now = tick()
    if now - lastKillSoundTime < KILL_SOUND_COOLDOWN then
        return
    end
    lastKillSoundTime = now
    PlayKillSound()
end

local nexvyrKillConnections = {}
local nexvyrKillWatchedStats = setmetatable({}, { __mode = "k" })
local nexvyrKillWatchedCharacters = setmetatable({}, { __mode = "k" })
local nexvyrKillWatchedPlayers = setmetatable({}, { __mode = "k" })
local nexvyrKillWatchedContainers = setmetatable({}, { __mode = "k" })
local function nexvyrTrackKill(connection)
    nexvyrKillConnections[#nexvyrKillConnections + 1] = connection
    return connection
end
local KILL_STAT_NAMES = {
    kos = true,
    kills = true,
    kill = true,
    ko = true,
    killed = true,
    eliminations = true,
    kills_count = true,
}

local function HookStatValue(stat)
    if not stat then
        return
    end
    if not (stat:IsA("IntValue") or stat:IsA("NumberValue")) then
        return
    end
    if not KILL_STAT_NAMES[string.lower(stat.Name)] then
        return
    end
    if not KillSoundEnabled or nexvyrKillWatchedStats[stat] then
        return
    end
    nexvyrKillWatchedStats[stat] = true
    local lastVal = stat.Value
    nexvyrTrackKill(stat:GetPropertyChangedSignal("Value"):Connect(function()
        if stat.Value > lastVal then
            TryPlayKillSound()
        end
        lastVal = stat.Value
    end))
end

local function HookLeaderstatsContainer(container)
    if not container or not KillSoundEnabled or nexvyrKillWatchedContainers[container] then
        return
    end
    nexvyrKillWatchedContainers[container] = true
    for _, stat in ipairs(container:GetChildren()) do
        HookStatValue(stat)
    end
    nexvyrTrackKill(container.ChildAdded:Connect(HookStatValue))
end

local KILL_ATTR_NAMES = { "KOs", "Kills", "kos", "kills", "KO", "killed", "Eliminations" }
local function nexvyrWatchLocalKillStats()
    for _, attrName in ipairs(KILL_ATTR_NAMES) do
        local lastVal = tonumber(player:GetAttribute(attrName))
        nexvyrTrackKill(player:GetAttributeChangedSignal(attrName):Connect(function()
            local newVal = tonumber(player:GetAttribute(attrName))
            if newVal ~= nil and lastVal ~= nil and newVal > lastVal then
                TryPlayKillSound()
            end
            lastVal = newVal
        end))
    end
    for _, name in ipairs({ "leaderstats", "Stats", "stats", "PlayerStats" }) do
        HookLeaderstatsContainer(player:FindFirstChild(name))
    end
    nexvyrTrackKill(player.ChildAdded:Connect(function(child)
        if
            child.Name == "leaderstats"
            or child.Name == "Stats"
            or child.Name == "stats"
            or child.Name == "PlayerStats"
        then
            HookLeaderstatsContainer(child)
        end
    end))
end

local function HookKillOnCharacter(other, character)
    if not KillSoundEnabled or nexvyrKillWatchedCharacters[character] then
        return
    end
    nexvyrKillWatchedCharacters[character] = true
    local waitConnection
    local function attachHumanoid(humanoid)
        if not KillSoundEnabled or not humanoid or not humanoid:IsA("Humanoid") then
            return
        end
        if waitConnection then
            waitConnection:Disconnect()
            waitConnection = nil
        end
        nexvyrTrackKill(humanoid.Died:Connect(function()
            if not KillSoundEnabled then
                return
            end
            local tag = humanoid:FindFirstChild("creator")
            if tag and tag.Value == player then
                TryPlayKillSound()
            end
        end))
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        attachHumanoid(humanoid)
    else
        waitConnection = nexvyrTrackKill(character.ChildAdded:Connect(attachHumanoid))
    end
end

local function HookKillPlayer(other)
    if other == player or not KillSoundEnabled or nexvyrKillWatchedPlayers[other] then
        return
    end
    nexvyrKillWatchedPlayers[other] = true
    if other.Character then
        HookKillOnCharacter(other, other.Character)
    end
    nexvyrTrackKill(other.CharacterAdded:Connect(function(character)
        HookKillOnCharacter(other, character)
    end))
end

local function nexvyrStartKillWatchers()
    if not KillSoundEnabled then
        return
    end
    nexvyrWatchLocalKillStats()
    for _, other in ipairs(Players:GetPlayers()) do
        HookKillPlayer(other)
    end
    nexvyrTrackKill(Players.PlayerAdded:Connect(HookKillPlayer))
end
local function nexvyrStopKillWatchers()
    dmvsDisconnectConnectionList(nexvyrKillConnections)
    table.clear(nexvyrKillWatchedStats)
    table.clear(nexvyrKillWatchedCharacters)
    table.clear(nexvyrKillWatchedPlayers)
    table.clear(nexvyrKillWatchedContainers)
end

local OriginalGunVolumes = {}
local HookedGunSounds = setmetatable({}, { __mode = "k" })

local function MuteOwnSound(s)
    if not RecargaDisparoEnabled or not s:IsA("Sound") then
        return
    end
    if
        s.Name == "NexvyrKillSound"
        or s.Name == "WindUI_MusicPlayer"
        or s.Name == "NexvyrShootSound"
        or s.Name == "NexvyrReloadSound"
    then
        return
    end
    if OriginalGunVolumes[s] == nil and s.Volume > 0 then
        OriginalGunVolumes[s] = s.Volume
    end
    if RecargaDisparoEnabled then
        s.Volume = 0
    end
    if not HookedGunSounds[s] then
        HookedGunSounds[s] = true
        nexvyrTrackShoot(s:GetPropertyChangedSignal("Volume"):Connect(function()
            if RecargaDisparoEnabled and s.Volume ~= 0 then
                OriginalGunVolumes[s] = s.Volume
                s.Volume = 0
            end
        end))
        nexvyrTrackShoot(s.Played:Connect(function()
            if RecargaDisparoEnabled then
                s.Volume = 0
            end
        end))
    end
end

local function HookOwnRoot(root)
    if not root then
        return
    end
    for _, d in ipairs(root:GetDescendants()) do
        MuteOwnSound(d)
    end
    nexvyrTrackShoot(root.DescendantAdded:Connect(MuteOwnSound))
end

local function ApplyMuteState(state)
    if state then
        for s in pairs(OriginalGunVolumes) do
            if s.Parent then
                s.Volume = 0
            end
        end
        if player.Character then
            for _, d in ipairs(player.Character:GetDescendants()) do
                MuteOwnSound(d)
            end
        end
        local backpack = player:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, d in ipairs(backpack:GetDescendants()) do
                MuteOwnSound(d)
            end
        end
    else
        for s, v in pairs(OriginalGunVolumes) do
            if s.Parent then
                s.Volume = v
            end
        end
    end
end

local function nexvyrStartShootWatchers()
    if not RecargaDisparoEnabled then
        return
    end
    local function attach(root)
        if not root or not RecargaDisparoEnabled or nexvyrShootRootWatched[root] then
            return
        end
        nexvyrShootRootWatched[root] = true
        HookOwnRoot(root)
        HookShootOnRoot(root)
    end
    attach(player.Character)
    attach(player:FindFirstChildOfClass("Backpack"))
    nexvyrTrackShoot(player.CharacterAdded:Connect(function(character)
        if not RecargaDisparoEnabled then
            return
        end
        attach(character)
        local backpack = player:FindFirstChildOfClass("Backpack")
        if backpack then
            attach(backpack)
        end
    end))
    nexvyrTrackShoot(player.ChildAdded:Connect(function(child)
        if child:IsA("Backpack") then
            attach(child)
        end
    end))
    nexvyrStartReloadWorker()
end

Tabs.Sonidos:Section({ Title = "Sonido de Muerte", Icon = "solar:speaker-bold" })

Tabs.Sonidos:Toggle({
    Title = "Sonido de Kill",
    Value = false,
    Callback = function(v)
        if KillSoundEnabled == v then
            return
        end
        KillSoundEnabled = v
        if v then
            nexvyrStartKillWatchers()
        else
            nexvyrStopKillWatchers()
            KillSoundPlayer:Stop()
        end
    end,
})

local KillSoundDropdownValues = {}
for _, s in ipairs(KillSounds) do
    table.insert(KillSoundDropdownValues, s.Name)
end

Tabs.Sonidos:Dropdown({
    Title = "Sonido de muerte",
    Values = KillSoundDropdownValues,
    Value = "Onichaaan",
    Callback = function(selected)
        SelectedKillSound = selected
    end,
})

Tabs.Sonidos:Section({ Title = "Disparo y Recarga", Icon = "solar:target-bold" })

Tabs.Sonidos:Toggle({
    Title = "Recarga + disparo",
    Value = false,
    Callback = function(v)
        if RecargaDisparoEnabled == v then
            return
        end
        RecargaDisparoEnabled = v
        if v then
            nexvyrStartShootWatchers()
            ApplyMuteState(true)
        else
            nexvyrStopShootWatchers()
            ShootSoundPlayer:Stop()
            ReloadSoundPlayer:Stop()
            ApplyMuteState(false)
            table.clear(OriginalGunVolumes)
            table.clear(HookedGunSounds)
        end
    end,
})

Tabs.Sonidos:Dropdown({
    Title = "Sonido de disparo",
    Values = { "Revolver + Recarga", "Magia de Anime", "Láser + Recarga láser" },
    Value = "Revolver + Recarga",
    Callback = function(selected)
        SelectedShootReload = selected
    end,
})

UIElements.SliKillSoundVolume = Tabs.Sonidos:Slider({
    Title = "Volumen",
    Step = 0.1,
    Value = { Min = 1, Max = 3, Default = 1 },
    Callback = function(v)
        KillSoundVolume = v
        KillSoundPlayer.Volume = v
        ShootSoundPlayer.Volume = v
        ReloadSoundPlayer.Volume = v
    end,
})

do
    local MusicPlayer = Instance.new("Sound")
    MusicPlayer.Name = "WindUI_MusicPlayer"
    MusicPlayer.Looped = false
    MusicPlayer.Volume = 0.5
    MusicPlayer.Parent = SoundService

    local SongList = {
        { Name = "Canción 1", Id = "84944985070181" },
        { Name = "Canción 2", Id = "87570666848900" },
        { Name = "Canción 3", Id = "82746224492420" },
        { Name = "Canción 4", Id = "71393805905055" },
        { Name = "Canción 5", Id = "75688616622595" },
        { Name = "Canción 6", Id = "135609653444873" },
        { Name = "Canción 7", Id = "93699644879957" },
        { Name = "Canción 8", Id = "110398343528156" },
        { Name = "Canción 9", Id = "138863509657081" },
        { Name = "Canción 10", Id = "115440201770223" },
        { Name = "Canción 11", Id = "128048502331483" },
        { Name = "Canción 12", Id = "135321902579514" },
        { Name = "Canción 13", Id = "131465489873214" },
    }

    local CurrentIndex = 1
    local ShuffleOn = false
    local NowPlayingParagraph

    local function UpdateNowPlaying()
        local song = SongList[CurrentIndex]
        if song and NowPlayingParagraph then
            NowPlayingParagraph:SetDesc(
                ("%s • ID: %s • %s"):format(
                    song.Name,
                    song.Id,
                    MusicPlayer.Playing and NXT("Playing", "กำลังเล่น") or NXT("Paused", "หยุดชั่วคราว")
                )
            )
        end
    end

    local function LoadSong(index)
        if not SongList[index] then
            return
        end
        CurrentIndex = index
        MusicPlayer:Stop()
        MusicPlayer.SoundId = "rbxassetid://" .. SongList[index].Id
        MusicPlayer:Play()
        UpdateNowPlaying()
    end

    local function PlaySong()
        if MusicPlayer.SoundId == "" then
            LoadSong(CurrentIndex)
        elseif not MusicPlayer.Playing then
            MusicPlayer:Resume()
        end
        UpdateNowPlaying()
    end

    local function PauseSong()
        if MusicPlayer.Playing then
            MusicPlayer:Pause()
        end
        UpdateNowPlaying()
    end

    local function StopSong()
        MusicPlayer:Stop()
        MusicPlayer.SoundId = ""
        UpdateNowPlaying()
    end

    local function NextSong()
        local nextIndex
        if ShuffleOn then
            nextIndex = math.random(1, #SongList)
        else
            nextIndex = CurrentIndex + 1
            if nextIndex > #SongList then
                nextIndex = 1
            end
        end
        LoadSong(nextIndex)
    end

    local function PrevSong()
        local prevIndex
        if ShuffleOn then
            prevIndex = math.random(1, #SongList)
        else
            prevIndex = CurrentIndex - 1
            if prevIndex < 1 then
                prevIndex = #SongList
            end
        end
        LoadSong(prevIndex)
    end

    MusicPlayer.Ended:Connect(function()
        NextSong()
    end)

    Tabs.Music:Section({ Title = "Ahora suena", Icon = "solar:music-note-bold" })
    NowPlayingParagraph = Tabs.Music:Paragraph({
        Title = "Sin canción seleccionada",
        Icon = "solar:music-note-2-bold",
    })

    Tabs.Music:Section({ Title = "Controles", Icon = "solar:tuning-2-bold" })
    Tabs.Music:Button({
        Title = "Anterior",
        Icon = "solar:skip-previous-bold",
        Variant = "Secondary",
        Callback = function()
            PrevSong()
        end,
    })
    Tabs.Music:Button({
        Title = "Siguiente",
        Icon = "solar:skip-next-bold",
        Variant = "Secondary",
        Callback = function()
            NextSong()
        end,
    })
    Tabs.Music:Button({
        Title = "Reproducir",
        Icon = "solar:play-circle-bold",
        Variant = "Primary",
        Callback = function()
            PlaySong()
        end,
    })
    Tabs.Music:Button({
        Title = "Pausar",
        Icon = "solar:pause-circle-bold",
        Variant = "Secondary",
        Callback = function()
            PauseSong()
        end,
    })
    Tabs.Music:Button({
        Title = "Detener",
        Icon = "solar:close-circle-bold",
        Variant = "Danger",
        Callback = function()
            StopSong()
        end,
    })
end

local Backgrounds = {
    {
        Name = "Fondo 0",
        ID = "9405835683",
        Reference = "rbxthumb://type=Asset&id=9405835683&w=420&h=420",
    },
    {
        Name = "Fondo 1",
        ID = "108657978883224",
        Reference = "rbxthumb://type=Asset&id=108657978883224&w=420&h=420",
    },
    {
        Name = "Fondo 2",
        ID = "11146353806",
        Reference = "rbxthumb://type=Asset&id=11146353806&w=420&h=420",
    },
    {
        Name = "Fondo 3",
        ID = "12687580616",
        Reference = "rbxthumb://type=Asset&id=12687580616&w=420&h=420",
    },
    {
        Name = "Fondo 4",
        ID = "17104722",
        Reference = "rbxthumb://type=Asset&id=17104722&w=420&h=420",
    },
    {
        Name = "Fondo 5",
        ID = "1941010929",
        Reference = "rbxthumb://type=Asset&id=1941010929&w=420&h=420",
    },
    {
        Name = "Fondo 6",
        ID = "134245569",
        Reference = "rbxthumb://type=Asset&id=134245569&w=420&h=420",
    },
    {
        Name = "Fondo 7",
        ID = "14653905878",
        Reference = "rbxthumb://type=Asset&id=14653905878&w=420&h=420",
    },
    {
        Name = "Fondo 8",
        ID = "14397445471",
        Reference = "rbxthumb://type=Asset&id=14397445471&w=420&h=420",
    },
}

local SelectedFondo = Backgrounds[1]
local SelectedTheme = "Dark"
local FondoNames = {}
for _, fondo in ipairs(Backgrounds) do
    table.insert(FondoNames, fondo.Name)
end

UIElements.DropFondo = Tabs.Fondos:Dropdown({
    Title = "Seleccionar fondo",
    Values = FondoNames,
    Value = SelectedFondo.Name,
    Callback = function(Value)
        for _, fondo in ipairs(Backgrounds) do
            if fondo.Name == Value then
                SelectedFondo = fondo
                break
            end
        end
    end,
})

local function FindBackground()
    local possibleRoots = {
        game:GetService("CoreGui"),
        game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui"),
    }
    for _, root in ipairs(possibleRoots) do
        if root then
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("ImageLabel") then
                    local image = obj.Image
                    if
                        image
                        and (
                            image:find("9405835683")
                            or image:find("108657978883224")
                            or image:find("11146353806")
                            or image:find("12687580616")
                            or image:find("17104722")
                            or image:find("1941010929")
                            or image:find("134245569")
                            or image:find("14653905878")
                            or image:find("14397445471")
                        )
                    then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

local function FixBackgroundLayer(Background)
    Background.ZIndex = 0
    Background.Active = false
    local Parent = Background.Parent
    if Parent then
        for _, obj in ipairs(Parent:GetDescendants()) do
            if obj:IsA("GuiObject") and obj ~= Background then
                if obj.ZIndex <= Background.ZIndex then
                    obj.ZIndex = Background.ZIndex + 1
                end
            end
        end
    end
end

local function ApplySelectedBackground()
    local Background = FindBackground()
    if Background then
        Background.Image = SelectedFondo.Reference
        FixBackgroundLayer(Background)
        return true
    end
    return false
end

Tabs.Fondos:Button({
    Title = "Aplicar",
    Callback = function()
        if not ApplySelectedBackground() then
            warn("No se encontró el fondo de WindUI.")
        end
    end,
})

Tabs.Fondos:Section({ Title = "Tema de la Interfaz", Icon = "solar:palette-bold" })

UIElements.DropTema = Tabs.Fondos:Dropdown({
    Title = "Seleccionar Tema",
    Icon = "solar:palette-bold",
    Values = { "Midnight", "Dark", "Red", "Indigo" },
    Value = "Dark",
    Callback = function(Value)
        SelectedTheme = Value
        pcall(function()
            WindUI:SetTheme(Value)
        end)
    end,
})

local KORBLOX_ASSETS = {
    ["Right Leg"] = {
        id = "rbxassetid://139607718",
        targetBodyPart = "RightUpperLeg",
        partsToHide = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
        scale = Vector3.new(1.0, 1.0, 1.0),
        audio = "rbxassetid://135315310485417",
        offset = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0),
    },
}

local KorbloxEnabled = false
local korbloxSavedTransparency = {}

local function attachKorbloxMesh(itemName, config)
    local character = player.Character
    if not character then
        return false
    end
    local targetPart = character:WaitForChild(config.targetBodyPart, 2)
    if not targetPart then
        return false
    end
    local oldAsset = character:FindFirstChild("Korblox_" .. itemName:gsub("%s+", ""))
    if oldAsset then
        oldAsset:Destroy()
    end
    for _, partName in ipairs(config.partsToHide) do
        local limb = character:FindFirstChild(partName)
        if limb and limb:IsA("BasePart") then
            if korbloxSavedTransparency[partName] == nil then
                korbloxSavedTransparency[partName] = limb.Transparency
            end
            limb.Transparency = 1
        end
    end
    local success, objects = pcall(function()
        return game:GetObjects(config.id)
    end)
    if not success or not objects or #objects == 0 then
        return false
    end
    local assetModel = objects[1]
    assetModel.Name = "Korblox_" .. itemName:gsub("%s+", "")
    local mainMesh = assetModel:IsA("BasePart") and assetModel
        or assetModel:FindFirstChildWhichIsA("BasePart", true)
    if not mainMesh then
        return false
    end
    mainMesh.Size = mainMesh.Size * config.scale
    mainMesh.CanCollide = false
    mainMesh.CFrame = targetPart.CFrame * config.offset
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = targetPart
    weld.Part1 = mainMesh
    weld.Parent = mainMesh
    assetModel.Parent = character
    if config.audio then
        local sound = Instance.new("Sound")
        sound.SoundId = config.audio
        sound.Volume = 0.5
        sound.Parent = mainMesh
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 3)
    end
    return true
end

local function applyKorblox()
    if not KorbloxEnabled then
        return
    end
    local config = KORBLOX_ASSETS["Right Leg"]
    local ok = attachKorbloxMesh("Right Leg", config)
    if not ok then
        task.wait(0.2)
        attachKorbloxMesh("Right Leg", config)
    end
end

local function removeKorblox()
    local character = player.Character
    if not character then
        return
    end
    local assetName = "Korblox_RightLeg"
    local asset = character:FindFirstChild(assetName)
    if asset then
        pcall(function()
            asset:Destroy()
        end)
    end
    for partName, orig in pairs(korbloxSavedTransparency) do
        local limb = character:FindFirstChild(partName)
        if limb and limb:IsA("BasePart") then
            pcall(function()
                limb.Transparency = orig
            end)
        end
    end
    korbloxSavedTransparency = {}
end

local HEADLESS_ASSET_ID = 134082579
local HeadlessEnabled = false
local insertedHeadlessAccessory = nil

local function setHeadlessTransparency(enabled)
    local character = player.Character
    if not character then
        return
    end
    local head = character:FindFirstChild("Head")
    if head then
        head.Transparency = enabled and 1 or 0
        local faceDecal = head:FindFirstChildOfClass("Decal")
        if faceDecal then
            faceDecal.Transparency = enabled and 1 or 0
        end
    end
end

local function setHeadless(enabled)
    local character = player.Character
    if not character then
        return
    end
    if enabled then
        character:WaitForChild("Head", 2)
        setHeadlessTransparency(true)
        if insertedHeadlessAccessory and insertedHeadlessAccessory.Parent ~= character then
            insertedHeadlessAccessory = nil
        end
        if insertedHeadlessAccessory then
            return
        end
        local success, result = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(HEADLESS_ASSET_ID))
        end)
        if success and result and #result > 0 then
            local rootModel = result[1]
            local model = nil
            if rootModel:IsA("Accessory") then
                model = rootModel
            else
                for _, descendant in ipairs(rootModel:GetDescendants()) do
                    if descendant:IsA("Accessory") then
                        model = descendant
                        break
                    end
                end
                model = model or (rootModel:IsA("Model") and rootModel or nil)
            end
            if model then
                if model:IsA("Accessory") then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    local addSuccess = humanoid
                        and pcall(function()
                            humanoid:AddAccessory(model)
                        end)
                    if not addSuccess then
                        model.Parent = character
                    end
                else
                    model.Parent = character
                end
                insertedHeadlessAccessory = model
            end
        else
            warn("[Headless] Failed to load headless asset: " .. tostring(result))
        end
    else
        setHeadlessTransparency(false)
        if insertedHeadlessAccessory then
            insertedHeadlessAccessory:Destroy()
            insertedHeadlessAccessory = nil
        end
    end
end

player.CharacterAdded:Connect(function(character)
    korbloxSavedTransparency = {}
    insertedHeadlessAccessory = nil
    if KorbloxEnabled then
        task.spawn(function()
            task.wait(0.1)
            applyKorblox()
        end)
    end
    if HeadlessEnabled then
        task.spawn(function()
            task.wait(0.1)
            setHeadless(true)
        end)
    end
end)

Tabs.Items:Section({ Title = "Items", Icon = "solar:crown-star-bold" })

UIElements.TogHeadless = Tabs.Items:Toggle({
    Title = "Aplicar Headless",
    Value = false,
    Callback = function(v)
        HeadlessEnabled = v
        if v then
            setHeadless(true)
        else
            setHeadless(false)
        end
    end,
})

UIElements.TogKorblox = Tabs.Items:Toggle({
    Title = "Aplicar Korblox",
    Value = false,
    Callback = function(v)
        KorbloxEnabled = v
        if v then
            applyKorblox()
        else
            removeKorblox()
        end
    end,
})

Tabs.Identidad:Section({ Title = "identidad falsa", Icon = "solar:user-id-bold" })

local function safeReplace(str, find, replace)
    local safeFind = find:gsub("[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1")
    return (str:gsub(safeFind, replace))
end

local originalData = {}
local visualConnections = {}
local nexvyrFakeTextConnections = setmetatable({}, { __mode = "k" })
local isWorkspaceLooping = false

local function processText(v, myName, myDisp)
    local parentGui = v:FindFirstAncestorWhichIsA("ScreenGui")
    if
        parentGui
        and (string.find(parentGui.Name, "WindUI") or (string.find(parentGui.Name, "Nexvyr") or string.find(parentGui.Name, "Nexora")))
    then
        return
    end
    if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
        local txt = v.Text
        local hasName = false
        if txt and txt ~= "" then
            if string.find(txt, myName, 1, true) or string.find(txt, myDisp, 1, true) then
                hasName = true
            end
        end
        if hasName and not originalData[v] then
            originalData[v] = {
                Text = txt,
                Color = v.TextColor3,
                TextTransp = v.TextTransparency,
                StrokeTransp = v.TextStrokeTransparency,
                Strokes = {},
            }
            for _, obj in pairs(v:GetChildren()) do
                if obj:IsA("UIStroke") then
                    originalData[v].Strokes[obj] = {
                        Enabled = obj.Enabled,
                        Transp = obj.Transparency,
                        Thickness = obj.Thickness,
                    }
                end
            end
        end
        if originalData[v] then
            if fakeNameEnabled then
                local newText = originalData[v].Text
                newText = safeReplace(newText, myName, spoofNameText)
                newText = safeReplace(newText, myDisp, spoofNameText)
                v.Text = newText
                v.TextTransparency = originalData[v].TextTransp
                v.TextStrokeTransparency = originalData[v].StrokeTransp
                v.TextColor3 = originalData[v].Color
                for _, obj in pairs(v:GetChildren()) do
                    if obj:IsA("UIStroke") and originalData[v].Strokes[obj] then
                        obj.Enabled = originalData[v].Strokes[obj].Enabled
                    end
                end
            else
                v.Text = originalData[v].Text
                v.TextColor3 = originalData[v].Color
                v.TextTransparency = originalData[v].TextTransp
                v.TextStrokeTransparency = originalData[v].StrokeTransp
                for _, obj in pairs(v:GetChildren()) do
                    if obj:IsA("UIStroke") and originalData[v].Strokes[obj] then
                        obj.Enabled = originalData[v].Strokes[obj].Enabled
                        obj.Transparency = originalData[v].Strokes[obj].Transp
                        obj.Thickness = originalData[v].Strokes[obj].Thickness
                    end
                end
            end
        end
    end
end

local function updateSystem()
    local myName = player.Name
    local myDisp = player.DisplayName
    task.spawn(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                for _, v in pairs(p.Character:GetDescendants()) do
                    if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
                        processText(v, myName, myDisp)
                    end
                end
            end
        end
        local pGui = player:FindFirstChild("PlayerGui")
        if pGui then
            for _, v in pairs(pGui:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
                    processText(v, myName, myDisp)
                end
            end
        end
    end)

    if fakeNameEnabled then
        if not isWorkspaceLooping then
            isWorkspaceLooping = true
            local function infectarTextoSeguro(v)
                local parentGui = v:FindFirstAncestorWhichIsA("ScreenGui")
                if
                    parentGui
                    and (
                        string.find(parentGui.Name, "WindUI")
                        or (string.find(parentGui.Name, "Nexvyr") or string.find(parentGui.Name, "Nexora"))
                    )
                then
                    return
                end
                if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
                    processText(v, myName, myDisp)
                    if not nexvyrFakeTextConnections[v] then
                        nexvyrFakeTextConnections[v] = true
                        table.insert(
                            visualConnections,
                            v:GetPropertyChangedSignal("Text"):Connect(function()
                                if
                                    isWorkspaceLooping
                                    and v.Text ~= spoofNameText
                                    and not string.find(v.Text, spoofNameText)
                                then
                                    originalData[v] = nil
                                    processText(v, myName, myDisp)
                                end
                            end)
                        )
                    end
                end
            end
            local pGui = player:FindFirstChild("PlayerGui")
            if pGui then
                table.insert(
                    visualConnections,
                    pGui.DescendantAdded:Connect(function(nuevoObjeto)
                        if
                            isWorkspaceLooping
                            and (
                                nuevoObjeto:IsA("TextLabel")
                                or nuevoObjeto:IsA("TextBox")
                                or nuevoObjeto:IsA("TextButton")
                            )
                        then
                            task.spawn(function()
                                infectarTextoSeguro(nuevoObjeto)
                            end)
                        end
                    end)
                )
            end
            local successCore, coreGui = pcall(function()
                return game:GetService("CoreGui")
            end)
            if successCore and coreGui then
                table.insert(
                    visualConnections,
                    coreGui.DescendantAdded:Connect(function(nuevoObjeto)
                        if
                            isWorkspaceLooping
                            and (
                                nuevoObjeto:IsA("TextLabel")
                                or nuevoObjeto:IsA("TextBox")
                                or nuevoObjeto:IsA("TextButton")
                            )
                        then
                            task.spawn(function()
                                infectarTextoSeguro(nuevoObjeto)
                            end)
                        end
                    end)
                )
            end
        end
    else
        isWorkspaceLooping = false
        for _, conn in ipairs(visualConnections) do
            conn:Disconnect()
        end
        visualConnections = {}
        table.clear(nexvyrFakeTextConnections)
        for v, data in pairs(originalData) do
            if v and v.Parent then
                v.Text = data.Text
                v.TextColor3 = data.Color
                v.TextTransparency = data.TextTransp
                v.TextStrokeTransparency = data.StrokeTransp
                for stroke, strokeData in pairs(data.Strokes) do
                    if stroke and stroke.Parent then
                        stroke.Enabled = strokeData.Enabled
                        stroke.Transparency = strokeData.Transp
                        stroke.Thickness = strokeData.Thickness
                    end
                end
            end
        end
        originalData = {}
    end
end

UIElements.TogFakeName = Tabs.Identidad:Toggle({
    Title = "Activar Nombre Falso",
    Value = false,
    Callback = function(s)
        fakeNameEnabled = s
        updateSystem()
    end,
})

UIElements.InpFakeName = Tabs.Identidad:Input({
    Title = "Nuevo Nombre",
    Placeholder = "Escribe tu nombre falso...",
    Callback = function(t)
        if t ~= "" then
            spoofNameText = t
            if fakeNameEnabled then
                updateSystem()
            end
        end
    end,
})

player.CharacterAdded:Connect(function()
    if fakeNameEnabled then
        task.wait(1)
        updateSystem()
    end
end)

do
    local configFolder = "NexvyrHub_Configs_WindUI"
    if isfolder and not isfolder(configFolder) then
        pcall(function()
            makefolder(configFolder)
        end)
    end

    local availableConfigs = { "Ninguna" }
    local selectedConfig = "Ninguna"
    local customConfigName = ""

    Tabs.Guardado:Section({ Title = "Gestor de Configs", Icon = "solar:diskette-bold" })
    local configDropdown = Tabs.Guardado:Dropdown({
        Title = "Seleccionar Configuración",
        Values = availableConfigs,
        Value = "Ninguna",
        Callback = function(Value)
            selectedConfig = Value
        end,
    })

    local function refreshConfigs()
        local list = {}
        if listfiles then
            pcall(function()
                for _, file in ipairs(listfiles(configFolder)) do
                    if file:match("%.json$") then
                        local name = file:match("([^/\\]+)%.json$")
                        if name then
                            table.insert(list, name)
                        end
                    end
                end
            end)
        end
        if #list == 0 then
            table.insert(list, "Ninguna")
        end
        pcall(function()
            configDropdown:Refresh(list)
            if selectedConfig == "Ninguna" or not table.find(list, selectedConfig) then
                configDropdown:Select(list[1])
                selectedConfig = list[1]
            end
        end)
    end

    Tabs.Guardado:Button({
        Title = "Actualizar Lista",
        Icon = "solar:refresh-bold",
        Variant = "Secondary",
        Callback = function()
            refreshConfigs()
        end,
    })
    Tabs.Guardado:Input({
        Title = "Nombre para Guardar",
        Placeholder = "Ej: Config 1, Config 2...",
        Icon = "solar:text-field-bold",
        Callback = function(Text)
            customConfigName = Text
        end,
    })

    local deleteConfirmPending = false
    local deleteConfirmTime = 0

    Tabs.Guardado:Button({
        Title = "Eliminar todos los guardados",
        Icon = "solar:trash-bin-trash-bold",
        Variant = "Danger",
        Callback = function()
            local now = os.clock()
            if deleteConfirmPending and (now - deleteConfirmTime) < 4 then
                deleteConfirmPending = false
                if listfiles then
                    pcall(function()
                        for _, file in ipairs(listfiles(configFolder)) do
                            if file:match("%.json$") then
                                pcall(function()
                                    delfile(file)
                                end)
                            end
                        end
                    end)
                end
                refreshConfigs()
            else
                deleteConfirmPending = true
                deleteConfirmTime = now
            end
        end,
    })

    local function secureLoadToggle(element, val)
        if not element or val == nil then
            return
        end
        pcall(function()
            element:Set(val)
        end)
    end

    Tabs.Guardado:Button({
        Title = "Guardar Configuración",
        Icon = "solar:diskette-bold",
        Variant = "Primary",
        Callback = function()
            local finalName = customConfigName:gsub("[^%w%s%-]", "")
            if finalName == "" then
                finalName = selectedConfig
            end
            if finalName == "" or finalName == "Ninguna" then
                return
            end
            local path = configFolder .. "/" .. finalName .. ".json"
            local configData = {
                ConfigName = finalName,
                Toggles = {
                    ["Auto Shoot"] = autoShootEnabled,
                    ["Auto Shoot Agresivo"] = autoShootAgresivoEnabled,
                    ["Equipar pistola"] = equipGunEnabled,
                    ["Silent Aim (Manual)"] = silentAimManualEnabled,
                    ["Silent Aim (FOV)"] = silentAimFovEnabled,
                    ["Mostrar Círculo FOV"] = fovVisiblePreference,
                    ["ESP Jugadores"] = espEnabled,
                    ["ESP Glow"] = espSettings.Glow,
                    ["Kill All"] = KillAllEnabled,
                    ["Hitbox Activar"] = hitboxEnabled,
                    ["Hitbox Invisible"] = hitboxInvisible,
                    ["Headless"] = HeadlessEnabled,
                    ["Korblox"] = KorbloxEnabled,
                    ["Nombre Falso"] = fakeNameEnabled,
                    ["Invisible"] = InvisibilityActive,
                },
                Sliders = {
                    ["Tamaño del FOV"] = fovRadius,
                    ["Tamaño de Hitbox"] = hitboxSize,
                    ["Volumen Kill Sound"] = KillSoundVolume,
                    ["Ajuste Speed"] = SPEED,
                    ["Ajuste Salto"] = JUMP_POWER,
                },
                Colors = {
                    ["Color de Hitbox"] = {
                        R = hitboxColor.R,
                        G = hitboxColor.G,
                        B = hitboxColor.B,
                    },
                    ["Color del ESP"] = { R = espColor.R, G = espColor.G, B = espColor.B },
                },
                Extras = {
                    ["Parte Silent Aim"] = silentAimTargetPart,
                    ["Fondo"] = SelectedFondo.Name,
                    ["Tema"] = SelectedTheme,
                    ["Nombre Falso Texto"] = spoofNameText,
                },
            }
            if writefile then
                local sEncode, encodedData = pcall(function()
                    return HttpService:JSONEncode(configData)
                end)
                if sEncode then
                    pcall(function()
                        writefile(path, encodedData)
                    end)
                    refreshConfigs()
                    pcall(function()
                        configDropdown:Select(finalName)
                    end)
                end
            end
        end,
    })

    Tabs.Guardado:Button({
        Title = "Cargar Configuración",
        Icon = "solar:folder-open-bold",
        Variant = "Primary",
        Callback = function()
            if selectedConfig == "Ninguna" or selectedConfig == "" then
                return
            end
            local path = configFolder .. "/" .. selectedConfig .. ".json"
            if isfile and isfile(path) then
                local success, decoded = pcall(function()
                    return HttpService:JSONDecode(readfile(path))
                end)
                if success and type(decoded) == "table" then
                    if decoded.Toggles then
                        if decoded.Toggles["Auto Shoot"] ~= nil then
                            autoShootEnabled = decoded.Toggles["Auto Shoot"]
                            secureLoadToggle(UIElements.TogAutoShoot, autoShootEnabled)
                        end
                        if decoded.Toggles["Auto Shoot Agresivo"] ~= nil then
                            autoShootAgresivoEnabled = decoded.Toggles["Auto Shoot Agresivo"]
                            secureLoadToggle(UIElements.TogAutoShootAgr, autoShootAgresivoEnabled)
                        end
                        if decoded.Toggles["Equipar pistola"] ~= nil then
                            equipGunEnabled = decoded.Toggles["Equipar pistola"]
                            secureLoadToggle(UIElements.TogEquipGun, equipGunEnabled)
                        end
                        if decoded.Toggles["Silent Aim (Manual)"] ~= nil then
                            silentAimManualEnabled = decoded.Toggles["Silent Aim (Manual)"]
                            secureLoadToggle(UIElements.TogSilentAimManual, silentAimManualEnabled)
                        end
                        if decoded.Toggles["Silent Aim (FOV)"] ~= nil then
                            silentAimFovEnabled = decoded.Toggles["Silent Aim (FOV)"]
                            secureLoadToggle(UIElements.TogSilentAimFOV, silentAimFovEnabled)
                        end
                        if decoded.Toggles["Mostrar Círculo FOV"] ~= nil then
                            fovVisiblePreference = decoded.Toggles["Mostrar Círculo FOV"]
                            secureLoadToggle(UIElements.TogShowFOV, fovVisiblePreference)
                        end
                        if decoded.Toggles["ESP Jugadores"] ~= nil then
                            espEnabled = decoded.Toggles["ESP Jugadores"]
                            secureLoadToggle(UIElements.TogEsp, espEnabled)
                        end
                        if decoded.Toggles["ESP Glow"] ~= nil then
                            espSettings.Glow = decoded.Toggles["ESP Glow"]
                            secureLoadToggle(UIElements.TogEspGl, espSettings.Glow)
                        end
                        if decoded.Toggles["Kill All"] ~= nil then
                            KillAllEnabled = decoded.Toggles["Kill All"]
                            secureLoadToggle(UIElements.TogKillAll, KillAllEnabled)
                            if KillAllEnabled then
                                KillAllInstance:Start()
                            else
                                KillAllInstance:Stop()
                            end
                        end
                        if decoded.Toggles["Hitbox Activar"] ~= nil then
                            hitboxEnabled = decoded.Toggles["Hitbox Activar"]
                            secureLoadToggle(UIElements.TogHitbox, hitboxEnabled)
                            if hitboxEnabled then
                                nexvyrStartHitboxWorker()
                            else
                                limpiarHitboxes()
                            end
                        end
                        if decoded.Toggles["Hitbox Invisible"] ~= nil then
                            hitboxInvisible = decoded.Toggles["Hitbox Invisible"]
                            secureLoadToggle(UIElements.TogHitboxInvisible, hitboxInvisible)
                        end
                        if decoded.Toggles["Headless"] ~= nil then
                            HeadlessEnabled = decoded.Toggles["Headless"]
                            secureLoadToggle(UIElements.TogHeadless, HeadlessEnabled)
                            if HeadlessEnabled then
                                setHeadless(true)
                            else
                                setHeadless(false)
                            end
                        end
                        if decoded.Toggles["Korblox"] ~= nil then
                            KorbloxEnabled = decoded.Toggles["Korblox"]
                            secureLoadToggle(UIElements.TogKorblox, KorbloxEnabled)
                            if KorbloxEnabled then
                                applyKorblox()
                            else
                                removeKorblox()
                            end
                        end
                        if decoded.Toggles["Nombre Falso"] ~= nil then
                            fakeNameEnabled = decoded.Toggles["Nombre Falso"]
                            secureLoadToggle(UIElements.TogFakeName, fakeNameEnabled)
                            updateSystem()
                        end
                        if decoded.Toggles["Invisible"] ~= nil then
                            InvisibilityActive = decoded.Toggles["Invisible"]
                            secureLoadToggle(UIElements.TogInvisible, InvisibilityActive)
                            AplicarInvisibilidadTransparencia(InvisibilityActive)
                            if nexvyrSetInvisibleWorker then
                                nexvyrSetInvisibleWorker(InvisibilityActive)
                            end
                        end
                    end
                    if decoded.Sliders then
                        if decoded.Sliders["Tamaño del FOV"] ~= nil then
                            fovRadius = decoded.Sliders["Tamaño del FOV"]
                            secureLoadToggle(UIElements.SliFOVSize, fovRadius)
                        end
                        if decoded.Sliders["Tamaño de Hitbox"] ~= nil then
                            hitboxSize = decoded.Sliders["Tamaño de Hitbox"]
                            secureLoadToggle(UIElements.SliHitboxSize, hitboxSize)
                        end
                        if decoded.Sliders["Volumen Kill Sound"] ~= nil then
                            KillSoundVolume = decoded.Sliders["Volumen Kill Sound"]
                            KillSoundPlayer.Volume = KillSoundVolume
                            ShootSoundPlayer.Volume = KillSoundVolume
                            ReloadSoundPlayer.Volume = KillSoundVolume
                            secureLoadToggle(UIElements.SliKillSoundVolume, KillSoundVolume)
                        end
                        if decoded.Sliders["Ajuste Speed"] ~= nil then
                            SPEED = decoded.Sliders["Ajuste Speed"]
                            secureLoadToggle(UIElements.SliSpeed, SPEED)
                        end
                        if decoded.Sliders["Ajuste Salto"] ~= nil then
                            JUMP_POWER = decoded.Sliders["Ajuste Salto"]
                            secureLoadToggle(UIElements.SliJumpPower, JUMP_POWER)
                        end
                    end
                    if decoded.Colors then
                        if decoded.Colors["Color de Hitbox"] then
                            hitboxColor = Color3.new(
                                decoded.Colors["Color de Hitbox"].R,
                                decoded.Colors["Color de Hitbox"].G,
                                decoded.Colors["Color de Hitbox"].B
                            )
                            if UIElements.ColHitbox then
                                pcall(function()
                                    UIElements.ColHitbox:Update(hitboxColor)
                                end)
                            end
                        end
                        if decoded.Colors["Color del ESP"] then
                            local cEsp = Color3.new(
                                decoded.Colors["Color del ESP"].R,
                                decoded.Colors["Color del ESP"].G,
                                decoded.Colors["Color del ESP"].B
                            )
                            espColor = cEsp
                            if UIElements.ColEsp then
                                pcall(function()
                                    UIElements.ColEsp:Update(cEsp)
                                end)
                            end
                        end
                    end
                    if decoded.Extras then
                        if decoded.Extras["Parte Silent Aim"] then
                            silentAimTargetPart = decoded.Extras["Parte Silent Aim"]
                            if UIElements.DropSilentAimPart then
                                pcall(function()
                                    UIElements.DropSilentAimPart:Select(silentAimTargetPart)
                                end)
                            end
                        end
                        if decoded.Extras["Fondo"] then
                            for _, fondo in ipairs(Backgrounds) do
                                if fondo.Name == decoded.Extras["Fondo"] then
                                    SelectedFondo = fondo
                                    break
                                end
                            end
                            if UIElements.DropFondo then
                                pcall(function()
                                    UIElements.DropFondo:Select(SelectedFondo.Name)
                                end)
                            end
                            ApplySelectedBackground()
                        end
                        if decoded.Extras["Tema"] then
                            SelectedTheme = decoded.Extras["Tema"]
                            if UIElements.DropTema then
                                pcall(function()
                                    UIElements.DropTema:Select(SelectedTheme)
                                end)
                            end
                            pcall(function()
                                WindUI:SetTheme(SelectedTheme)
                            end)
                        end
                        if decoded.Extras["Nombre Falso Texto"] then
                            spoofNameText = decoded.Extras["Nombre Falso Texto"]
                            secureLoadToggle(UIElements.InpFakeName, spoofNameText)
                            if fakeNameEnabled then
                                updateSystem()
                            end
                        end
                    end
                    if nexvyrUpdateTargetFeatures then
                        nexvyrUpdateTargetFeatures()
                    end
                    if nexvyrStartFOVWorker then
                        nexvyrStartFOVWorker()
                    end
                end
            end
        end,
    })

    task.spawn(function()
        task.wait(1)
        refreshConfigs()
    end)
end

do
    Tabs.Graficos:Section({ Title = "Presets de Iluminación", Icon = "solar:palette-bold" })

    local nocheSangrientaEffects = {}
    local atardecerEffects = {}
    local sinVidaEffects = {}
    local nocheSangrientaSkyFolder = nil

    local function SaveLightingOriginal(tag)
        local Lighting = game:GetService("Lighting")
        if Lighting:GetAttribute("OrigSaved_" .. tag) then
            return
        end
        Lighting:SetAttribute("Orig_Ambient_" .. tag, Lighting.Ambient)
        Lighting:SetAttribute("Orig_OutdoorAmbient_" .. tag, Lighting.OutdoorAmbient)
        Lighting:SetAttribute("Orig_Brightness_" .. tag, Lighting.Brightness)
        Lighting:SetAttribute("Orig_ClockTime_" .. tag, Lighting.ClockTime)
        Lighting:SetAttribute("Orig_FogColor_" .. tag, Lighting.FogColor)
        Lighting:SetAttribute("Orig_FogEnd_" .. tag, Lighting.FogEnd)
        Lighting:SetAttribute("Orig_FogStart_" .. tag, Lighting.FogStart)
        Lighting:SetAttribute("Orig_ColorShift_Top_" .. tag, Lighting.ColorShift_Top)
        Lighting:SetAttribute("Orig_ColorShift_Bottom_" .. tag, Lighting.ColorShift_Bottom)
        Lighting:SetAttribute("Orig_ExposureCompensation_" .. tag, Lighting.ExposureCompensation)
        Lighting:SetAttribute("Orig_GlobalShadows_" .. tag, Lighting.GlobalShadows)
        Lighting:SetAttribute(
            "Orig_EnvironmentDiffuseScale_" .. tag,
            Lighting.EnvironmentDiffuseScale
        )
        Lighting:SetAttribute(
            "Orig_EnvironmentSpecularScale_" .. tag,
            Lighting.EnvironmentSpecularScale
        )
        Lighting:SetAttribute("OrigSaved_" .. tag, true)
    end

    local function RestoreLighting(tag)
        local Lighting = game:GetService("Lighting")
        if not Lighting:GetAttribute("OrigSaved_" .. tag) then
            return
        end
        Lighting.Ambient = Lighting:GetAttribute("Orig_Ambient_" .. tag)
        Lighting.OutdoorAmbient = Lighting:GetAttribute("Orig_OutdoorAmbient_" .. tag)
        Lighting.Brightness = Lighting:GetAttribute("Orig_Brightness_" .. tag)
        Lighting.ClockTime = Lighting:GetAttribute("Orig_ClockTime_" .. tag)
        Lighting.FogColor = Lighting:GetAttribute("Orig_FogColor_" .. tag)
        Lighting.FogEnd = Lighting:GetAttribute("Orig_FogEnd_" .. tag)
        Lighting.FogStart = Lighting:GetAttribute("Orig_FogStart_" .. tag)
        Lighting.ColorShift_Top = Lighting:GetAttribute("Orig_ColorShift_Top_" .. tag)
        Lighting.ColorShift_Bottom = Lighting:GetAttribute("Orig_ColorShift_Bottom_" .. tag)
        Lighting.ExposureCompensation = Lighting:GetAttribute("Orig_ExposureCompensation_" .. tag)
        Lighting.GlobalShadows = Lighting:GetAttribute("Orig_GlobalShadows_" .. tag)
        Lighting.EnvironmentDiffuseScale =
            Lighting:GetAttribute("Orig_EnvironmentDiffuseScale_" .. tag)
        Lighting.EnvironmentSpecularScale =
            Lighting:GetAttribute("Orig_EnvironmentSpecularScale_" .. tag)
        Lighting:SetAttribute("OrigSaved_" .. tag, nil)
    end

    local function ClearEffects(list)
        for _, v in ipairs(list) do
            pcall(function()
                v:Destroy()
            end)
        end
        table.clear(list)
    end

    local function ApplyNocheSangrienta(state)
        local Lighting = game:GetService("Lighting")
        if state then
            SaveLightingOriginal("NS")
            ClearEffects(nocheSangrientaEffects)

            if nocheSangrientaSkyFolder then
                nocheSangrientaSkyFolder:Destroy()
            end
            nocheSangrientaSkyFolder = Instance.new("Folder")
            nocheSangrientaSkyFolder.Name = "NS_SkyX"
            nocheSangrientaSkyFolder.Parent = workspace

            local function makeBeam(angle)
                local beam = Instance.new("Part")
                beam.Anchored = true
                beam.CanCollide = false
                beam.CanQuery = false
                beam.Material = Enum.Material.Neon
                beam.Color = Color3.fromRGB(255, 55, 55)
                beam.Transparency = 0.1
                beam.Size = Vector3.new(2600, 26, 26)
                beam.CFrame = CFrame.new(0, 3200, -2200) * CFrame.Angles(0, 0, math.rad(angle))
                beam.Parent = nocheSangrientaSkyFolder
                table.insert(nocheSangrientaEffects, beam)
            end
            makeBeam(45)
            makeBeam(-45)

            local glowPart = Instance.new("Part")
            glowPart.Anchored = true
            glowPart.CanCollide = false
            glowPart.CanQuery = false
            glowPart.Material = Enum.Material.Neon
            glowPart.Color = Color3.fromRGB(255, 110, 110)
            glowPart.Transparency = 0.65
            glowPart.Shape = Enum.PartType.Ball
            glowPart.Size = Vector3.new(420, 420, 420)
            glowPart.CFrame = CFrame.new(0, 3200, -2200)
            glowPart.Parent = nocheSangrientaSkyFolder
            table.insert(nocheSangrientaEffects, glowPart)

            local light1 = Instance.new("PointLight")
            light1.Color = Color3.fromRGB(255, 80, 80)
            light1.Range = 300
            light1.Brightness = 3
            light1.Parent = glowPart
            table.insert(nocheSangrientaEffects, light1)

            local sky = Instance.new("Sky")
            sky.Name = "NS_Sky"
            sky.StarCount = 9000
            sky.MoonAngularSize = 30
            sky.SunAngularSize = 0
            sky.CelestialBodiesShown = true
            sky.Parent = Lighting
            table.insert(nocheSangrientaEffects, sky)

            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "NS_CC"
            cc.Brightness = 0.05
            cc.Contrast = 0.32
            cc.Saturation = -0.15
            cc.TintColor = Color3.fromRGB(255, 130, 130)
            cc.Parent = Lighting
            table.insert(nocheSangrientaEffects, cc)

            local bloom = Instance.new("BloomEffect")
            bloom.Name = "NS_Bloom"
            bloom.Intensity = 1
            bloom.Size = 90
            bloom.Threshold = 0.45
            bloom.Parent = Lighting
            table.insert(nocheSangrientaEffects, bloom)

            local blur = Instance.new("BlurEffect")
            blur.Name = "NS_Blur"
            blur.Size = 3
            blur.Parent = Lighting
            table.insert(nocheSangrientaEffects, blur)

            local atmo = Instance.new("Atmosphere")
            atmo.Name = "NS_Atmo"
            atmo.Density = 0.42
            atmo.Offset = 0
            atmo.Color = Color3.fromRGB(60, 12, 12)
            atmo.Decay = Color3.fromRGB(80, 20, 20)
            atmo.Glare = 0.5
            atmo.Haze = 1.6
            atmo.Parent = Lighting
            table.insert(nocheSangrientaEffects, atmo)

            Lighting.ClockTime = 0
            Lighting.Brightness = 1.2
            Lighting.Ambient = Color3.fromRGB(130, 110, 110)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 140, 140)
            Lighting.FogColor = Color3.fromRGB(22, 5, 5)
            Lighting.FogEnd = 1200
            Lighting.FogStart = 150
            Lighting.ColorShift_Top = Color3.fromRGB(125, 25, 25)
            Lighting.ColorShift_Bottom = Color3.fromRGB(65, 8, 8)
            Lighting.ExposureCompensation = -0.2
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 0.5
            Lighting.EnvironmentSpecularScale = 0.5
        else
            ClearEffects(nocheSangrientaEffects)
            if nocheSangrientaSkyFolder then
                nocheSangrientaSkyFolder:Destroy()
                nocheSangrientaSkyFolder = nil
            end
            RestoreLighting("NS")
        end
    end

    local function ApplyAtardecer(state)
        local Lighting = game:GetService("Lighting")
        if state then
            SaveLightingOriginal("AF")
            ClearEffects(atardecerEffects)

            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "AF_CC"
            cc.Brightness = 0.05
            cc.Contrast = 0.14
            cc.Saturation = 0.22
            cc.TintColor = Color3.fromRGB(255, 205, 165)
            cc.Parent = Lighting
            table.insert(atardecerEffects, cc)

            local bloom = Instance.new("BloomEffect")
            bloom.Name = "AF_Bloom"
            bloom.Intensity = 0.32
            bloom.Size = 40
            bloom.Threshold = 0.92
            bloom.Parent = Lighting
            table.insert(atardecerEffects, bloom)

            local rays = Instance.new("SunRaysEffect")
            rays.Name = "AF_Rays"
            rays.Intensity = 0.15
            rays.Spread = 0.9
            rays.Parent = Lighting
            table.insert(atardecerEffects, rays)

            local sky = Instance.new("Sky")
            sky.Name = "AF_Sky"
            sky.SunAngularSize = 18
            sky.MoonAngularSize = 0
            sky.StarCount = 2000
            sky.Parent = Lighting
            table.insert(atardecerEffects, sky)

            local atmo = Instance.new("Atmosphere")
            atmo.Name = "AF_Atmo"
            atmo.Density = 0.36
            atmo.Offset = 0.1
            atmo.Color = Color3.fromRGB(255, 185, 135)
            atmo.Decay = Color3.fromRGB(255, 125, 85)
            atmo.Glare = 0.2
            atmo.Haze = 1.2
            atmo.Parent = Lighting
            table.insert(atardecerEffects, atmo)

            Lighting.ClockTime = 6.3
            Lighting.Brightness = 2.4
            Lighting.Ambient = Color3.fromRGB(85, 62, 55)
            Lighting.OutdoorAmbient = Color3.fromRGB(125, 92, 80)
            Lighting.FogColor = Color3.fromRGB(240, 185, 145)
            Lighting.FogEnd = 2500
            Lighting.FogStart = 200
            Lighting.ColorShift_Top = Color3.fromRGB(255, 185, 105)
            Lighting.ColorShift_Bottom = Color3.fromRGB(205, 105, 85)
            Lighting.ExposureCompensation = 0.08
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 0.8
            Lighting.EnvironmentSpecularScale = 0.6
        else
            ClearEffects(atardecerEffects)
            RestoreLighting("AF")
        end
    end

    local function ApplySinVida(state)
        local Lighting = game:GetService("Lighting")
        if state then
            SaveLightingOriginal("SV")
            ClearEffects(sinVidaEffects)

            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "SV_CC"
            cc.Brightness = 0.05
            cc.Contrast = 0.22
            cc.Saturation = -1
            cc.TintColor = Color3.fromRGB(222, 226, 232)
            cc.Parent = Lighting
            table.insert(sinVidaEffects, cc)

            local bloom = Instance.new("BloomEffect")
            bloom.Name = "SV_Bloom"
            bloom.Intensity = 1.25
            bloom.Size = 75
            bloom.Threshold = 0.38
            bloom.Parent = Lighting
            table.insert(sinVidaEffects, bloom)

            local sky = Instance.new("Sky")
            sky.Name = "SV_Sky"
            sky.StarCount = 0
            sky.SunAngularSize = 0
            sky.MoonAngularSize = 0
            sky.CelestialBodiesShown = false
            sky.Parent = Lighting
            table.insert(sinVidaEffects, sky)

            local atmo = Instance.new("Atmosphere")
            atmo.Name = "SV_Atmo"
            atmo.Density = 0.3
            atmo.Offset = 0.1
            atmo.Color = Color3.fromRGB(180, 185, 190)
            atmo.Decay = Color3.fromRGB(140, 145, 150)
            atmo.Glare = 0
            atmo.Haze = 1.0
            atmo.Parent = Lighting
            table.insert(sinVidaEffects, atmo)

            Lighting.ClockTime = 14
            Lighting.Brightness = 2.2
            Lighting.Ambient = Color3.fromRGB(92, 96, 100)
            Lighting.OutdoorAmbient = Color3.fromRGB(132, 136, 140)
            Lighting.FogColor = Color3.fromRGB(172, 176, 180)
            Lighting.FogEnd = 3000
            Lighting.FogStart = 200
            Lighting.ColorShift_Top = Color3.fromRGB(152, 156, 160)
            Lighting.ColorShift_Bottom = Color3.fromRGB(122, 126, 130)
            Lighting.ExposureCompensation = 0
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 0.6
            Lighting.EnvironmentSpecularScale = 0.3
        else
            ClearEffects(sinVidaEffects)
            RestoreLighting("SV")
        end
    end

    local nocheTog, atardecerTog, sinVidaTog

    nocheTog = Tabs.Graficos:Toggle({
        Title = "Noche Sangrienta",
        Value = false,
        Callback = function(state)
            if state then
                if atardecerTog then
                    pcall(function()
                        atardecerTog:Set(false)
                    end)
                end
                if sinVidaTog then
                    pcall(function()
                        sinVidaTog:Set(false)
                    end)
                end
            end
            ApplyNocheSangrienta(state)
        end,
    })

    atardecerTog = Tabs.Graficos:Toggle({
        Title = "Atardecer Fantástico",
        Value = false,
        Callback = function(state)
            if state then
                if nocheTog then
                    pcall(function()
                        nocheTog:Set(false)
                    end)
                end
                if sinVidaTog then
                    pcall(function()
                        sinVidaTog:Set(false)
                    end)
                end
            end
            ApplyAtardecer(state)
        end,
    })

    sinVidaTog = Tabs.Graficos:Toggle({
        Title = "Sin Vida",
        Value = false,
        Callback = function(state)
            if state then
                if nocheTog then
                    pcall(function()
                        nocheTog:Set(false)
                    end)
                end
                if atardecerTog then
                    pcall(function()
                        atardecerTog:Set(false)
                    end)
                end
            end
            ApplySinVida(state)
        end,
    })
end

do
    local TweenService = game:GetService("TweenService")

    local BTN_SIZE = 56
    local GREEN = Color3.fromRGB(144, 238, 144)
    local ICON_OFF = Color3.fromRGB(235, 235, 245)
    local BG_OFF = Color3.fromRGB(18, 18, 26)
    local BG_ON = Color3.fromRGB(20, 40, 30)
    local TI = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local floatGui = Instance.new("ScreenGui")
    floatGui.Name = "NexvyrHub_FloatingButtons"
    floatGui.ResetOnSpawn = false
    floatGui.IgnoreGuiInset = true
    floatGui.DisplayOrder = 1000
    floatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    floatGui.Enabled = false
    floatGui.Parent = player:WaitForChild("PlayerGui")

    local function tween(obj, props, info)
        TweenService:Create(obj, info or TI, props):Play()
    end

    local function viewport()
        local vp = floatGui.AbsoluteSize
        if vp.X < 10 then
            local cam = workspace.CurrentCamera
            vp = cam and cam.ViewportSize or Vector2.new(800, 600)
        end
        return vp
    end

    local function clampPos(x, y)
        local vp = viewport()
        return math.clamp(x, 0, math.max(0, vp.X - BTN_SIZE)),
            math.clamp(y, 0, math.max(0, vp.Y - BTN_SIZE))
    end

    local function makeIconKit(holder, paints)
        local function F(x, y, w, h, round, noPaint)
            local f = Instance.new("Frame")
            f.BorderSizePixel = 0
            f.BackgroundColor3 = ICON_OFF
            f.Position = UDim2.fromOffset(x, y)
            f.Size = UDim2.fromOffset(w, h)
            if round then
                local c = Instance.new("UICorner")
                c.CornerRadius = round == true and UDim.new(1, 0) or UDim.new(0, round)
                c.Parent = f
            end
            f.Parent = holder
            if not noPaint then
                paints[#paints + 1] = { f, "BackgroundColor3" }
            end
            return f
        end
        local function R(x, y, w, h, thick)
            local f = Instance.new("Frame")
            f.BorderSizePixel = 0
            f.BackgroundTransparency = 1
            f.Position = UDim2.fromOffset(x, y)
            f.Size = UDim2.fromOffset(w, h)
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(1, 0)
            c.Parent = f
            local s = Instance.new("UIStroke")
            s.Color = ICON_OFF
            s.Thickness = thick
            s.Parent = f
            f.Parent = holder
            paints[#paints + 1] = { s, "Color" }
            return f
        end
        return F, R
    end

    local Icons = {
        ESP = function(F, R)
            R(0, 6, 30, 18, 2.2)
            F(11, 11, 8, 8, true)
        end,
        AutoShoot = function(F, R)
            R(5, 5, 20, 20, 2)
            F(14, 0, 2, 8)
            F(14, 22, 2, 8)
            F(0, 14, 8, 2)
            F(22, 14, 8, 2)
            F(13.5, 13.5, 3, 3, true)
        end,
        SilentAim = function(F, R)
            R(1, 1, 28, 28, 2)
            R(8, 8, 14, 14, 2)
            F(12.5, 12.5, 5, 5, true)
            local l = F(0, 0, 2.4, 16)
            l.AnchorPoint = Vector2.new(0.5, 0.5)
            l.Position = UDim2.fromOffset(22, 8)
            l.Rotation = 45
        end,
        Invisible = function(F, R)
            F(5, 3, 20, 20, true)
            F(5, 13, 20, 9)
            F(5, 18, 6.6, 6.6, true)
            F(11.7, 18, 6.6, 6.6, true)
            F(18.4, 18, 6.6, 6.6, true)
            local e1 = F(10, 10, 3, 5, true, true)
            local e2 = F(17, 10, 3, 5, true, true)
            e1.BackgroundColor3 = BG_OFF
            e2.BackgroundColor3 = BG_OFF
        end,
    }

    local defs = {
        {
            Name = "ESP",
            Ui = "TogEsp",
            Get = function()
                return espEnabled
            end,
        },
        {
            Name = "AutoShoot",
            Ui = "TogAutoShootAgr",
            Get = function()
                return autoShootAgresivoEnabled
            end,
        },
        {
            Name = "SilentAim",
            Ui = "TogSilentAimManual",
            Get = function()
                return silentAimManualEnabled
            end,
        },
        {
            Name = "Invisible",
            Ui = "TogInvisible",
            Get = function()
                return InvisibilityActive
            end,
        },
    }

    local buttons = {}

    local function createButton(def, index)
        local btn = Instance.new("TextButton")
        btn.Name = def.Name
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Active = true
        btn.BorderSizePixel = 0
        btn.BackgroundColor3 = BG_OFF
        btn.BackgroundTransparency = 0.12
        btn.Size = UDim2.fromOffset(BTN_SIZE, BTN_SIZE)
        btn.Parent = floatGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.new(1, 1, 1)
        stroke.Transparency = 0.75
        stroke.Thickness = 1.5
        stroke.Parent = btn

        local scale = Instance.new("UIScale")
        scale.Scale = 1
        scale.Parent = btn

        local holder = Instance.new("Frame")
        holder.BackgroundTransparency = 1
        holder.AnchorPoint = Vector2.new(0.5, 0.5)
        holder.Position = UDim2.fromScale(0.5, 0.5)
        holder.Size = UDim2.fromOffset(30, 30)
        holder.Parent = btn

        local paints = {}
        local F, R = makeIconKit(holder, paints)
        Icons[def.Name](F, R)

        local function homePos()
            local vp = viewport()
            return clampPos(vp.X - BTN_SIZE - 16, vp.Y * 0.28 + (index - 1) * (BTN_SIZE + 10))
        end
        local function goHome()
            local x, y = homePos()
            btn.Position = UDim2.fromOffset(x, y)
        end
        goHome()

        local isOn = nil
        local function setVisual(on, instant)
            if isOn == on then
                return
            end
            local first = isOn == nil
            isOn = on
            local info = (instant or first) and TweenInfo.new(0) or TI
            tween(
                btn,
                {
                    BackgroundColor3 = on and BG_ON or BG_OFF,
                    BackgroundTransparency = on and 0.05 or 0.12,
                },
                info
            )
            tween(
                stroke,
                {
                    Color = on and GREEN or Color3.new(1, 1, 1),
                    Transparency = on and 0 or 0.75,
                    Thickness = on and 2.5 or 1.5,
                },
                info
            )
            for _, p in ipairs(paints) do
                tween(p[1], { [p[2]] = on and GREEN or ICON_OFF }, info)
            end
            if not instant and not first then
                tween(
                    scale,
                    { Scale = 1.14 },
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                )
                task.delay(0.1, function()
                    tween(
                        scale,
                        { Scale = 1 },
                        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    )
                end)
            end
        end

        local dragging, moved = false, false
        local dragInput, startMouse, startPos

        btn.InputBegan:Connect(function(input)
            if
                input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch
            then
                return
            end
            dragging, moved = true, false
            dragInput = input
            startMouse = Vector2.new(input.Position.X, input.Position.Y)
            startPos = Vector2.new(btn.Position.X.Offset, btn.Position.Y.Offset)
            tween(
                scale,
                { Scale = 0.9 },
                TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            )
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging then
                return
            end
            if input ~= dragInput and input.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
            end
            local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
            if not moved and delta.Magnitude > 7 then
                moved = true
                tween(scale, { Scale = 1.08 }, TweenInfo.new(0.12))
            end
            if moved then
                local x, y = clampPos(startPos.X + delta.X, startPos.Y + delta.Y)
                btn.Position = UDim2.fromOffset(x, y)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if not dragging or input ~= dragInput then
                return
            end
            dragging = false
            tween(
                scale,
                { Scale = 1 },
                TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            )
            if not moved then
                local newState = not def.Get()
                local el = UIElements[def.Ui]
                if el then
                    pcall(function()
                        el:Set(newState)
                    end)
                end
                setVisual(def.Get() == true)
            end
        end)

        buttons[#buttons + 1] = {
            Sync = function()
                setVisual(def.Get() == true)
            end,
            Reclamp = function()
                local x, y = clampPos(btn.Position.X.Offset, btn.Position.Y.Offset)
                btn.Position = UDim2.fromOffset(x, y)
            end,
            Home = goHome,
        }
    end

    for i, def in ipairs(defs) do
        createButton(def, i)
    end

    floatGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        for _, b in ipairs(buttons) do
            b.Reclamp()
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.2)
            if floatGui.Enabled then
                for _, b in ipairs(buttons) do
                    b.Sync()
                end
            end
        end
    end)

    Tabs.Botones:Section({ Title = "Botones flotantes", Icon = "solar:gamepad-bold" })

    UIElements.TogFloatButtons = Tabs.Botones:Toggle({
        Title = "Mostrar botones flotantes",
        Value = false,
        Callback = function(v)
            floatGui.Enabled = v
            if v then
                for _, b in ipairs(buttons) do
                    b.Sync()
                end
            end
        end,
    })

    Tabs.Botones:Button({
        Title = "Restablecer posiciones",
        Icon = "solar:refresh-bold",
        Variant = "Secondary",
        Callback = function()
            for _, b in ipairs(buttons) do
                b.Home()
            end
        end,
    })
end


-- ====================================================================
-- NEXORA | MM2 : ฟังก์ชันที่ย้ายมาจาก MM2 V8.1 (ยกเว้นหน้าหลัก/ตั้งค่า)
-- หมวดใหม่ในเมนูข้าง: RADAR / WARP / FLING / HUNTER / PLAYER / FARM / EVENT
-- ====================================================================
do
local okM, errM = pcall(function()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local NXH = getgenv().NX
local env = getgenv()

local function T(en, th) return (NXH.getLang() == "TH") and th or en end

local MM = { dead = false }
local conns, cleanups = {}, {}
local function bind(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end
local function onUnload(fn) cleanups[#cleanups + 1] = fn end
local function unload()
    if MM.dead then return end
    MM.dead = true
    for _, f in ipairs(cleanups) do pcall(f) end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    if env.NX_MM2_UNLOAD == unload then env.NX_MM2_UNLOAD = nil end
end
if env.NX_MM2_UNLOAD then pcall(env.NX_MM2_UNLOAD) end
env.NX_MM2_UNLOAD = unload
pcall(function() if NXH.gui then NXH.gui.Destroying:Connect(unload) end end)

local function mk(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
local function corner(o, r) return mk("UICorner", { CornerRadius = UDim.new(0, r) }, o) end

-- ชั้นแสดงผลของ MM2 (ปุ่มขวาจอ + เส้น/กรอบ ESP + ข้อความแจ้งเตือน)
local oldUi = playerGui:FindFirstChild("NEXORA_MM2_UI")
if oldUi then oldUi:Destroy() end
local overlay = mk("ScreenGui", {
    Name = "NEXORA_MM2_UI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 998,
}, playerGui)
onUnload(function() overlay:Destroy() end)

local toastL = mk("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -60),
    Size = UDim2.fromOffset(280, 30), BackgroundColor3 = Color3.fromRGB(14, 10, 26),
    BackgroundTransparency = 0.1, TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold,
    TextSize = 12, Visible = false, ZIndex = 50, Text = "",
}, overlay)
corner(toastL, 12)
local toastId = 0
local function toast(en, th)
    toastId += 1
    local id = toastId
    toastL.Text = T(en, th)
    toastL.Visible = true
    task.delay(1.8, function()
        if id == toastId then toastL.Visible = false end
    end)
end

local ESP = { roles = false, gun = false, lines = false, boxes = false }
local K = { auto = false, all = false, throw = false, shoot = false, aThrow = false, aShoot = false }
local P = { noclip = false, speed = false, jump = false, fly = false, tp = false, anti = false }
local FLAGS = { flinging = false, floating = false, warpGun = false }

local function myParts()
    local c = player.Character
    return c, c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

local function hasTag(inst, tag)
    local ok, r = pcall(function() return inst:HasTag(tag) end)
    return ok and r
end

---------------------------------------------------------------- ข้อมูลบทบาท
local playerData = {}
local pEsp, gEsp, known, roleCache, vis = {}, {}, {}, {}, {}
local ev, fn

local function setData(d)
    if type(d) == "table" then playerData = d end
end

local function findRemote(names, class)
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA(class) and names[d.Name] then return d end
    end
end

local function fetchNow()
    if fn then
        local ok, d = pcall(function() return fn:InvokeServer() end)
        if ok then setData(d) end
    end
end

task.spawn(function()
    for _ = 1, 40 do
        ev = ev or findRemote({ PlayerDataChanged = true }, "RemoteEvent")
        fn = fn or findRemote({ GetCurrentPlayerData = true, GetPlayerData = true }, "RemoteFunction")
        if (ev and fn) or MM.dead then break end
        task.wait(0.5)
    end
    if ev then bind(ev.OnClientEvent, setData) end
    while not MM.dead do
        if fn and (ESP.roles or ESP.gun or ESP.lines or ESP.boxes or FLAGS.warpGun) then
            fetchNow()
        end
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
            if hasTag(t, "Weapon_Knife") or n:find("knife") then return "Murderer" end
            if hasTag(t, "Weapon_Gun") or n == "gun" or n:find("revolver") then return "Sheriff" end
        end
    end
    return nil
end

local function getRole(plr)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum or hum.Health <= 0 then return nil end
    local d = playerData[plr.Name]
    if type(d) == "table" then
        if d.Dead == true then return nil end
        local r = roleFromText(d.Role)
        if r then return r end
    end
    local r = toolRole(char)
    if not r and plr:FindFirstChild("Backpack") then r = toolRole(plr.Backpack) end
    return r or "Innocent"
end

local function distTo(pos)
    local _, hrp = myParts()
    return hrp and math.floor((hrp.Position - pos).Magnitude) or 0
end

---------------------------------------------------------------- ESP engine
local RC = {
    Innocent = Color3.fromRGB(60, 255, 90),
    Murderer = Color3.fromRGB(255, 40, 40),
    Sheriff = Color3.fromRGB(60, 140, 255),
}
local GUN_COL = Color3.fromRGB(255, 220, 0)
local ROLE_TXT = {
    TH = { Innocent = "คนธรรมดา", Murderer = "ฆาตกร", Sheriff = "นายอำเภอ" },
    EN = { Innocent = "Innocent", Murderer = "Murderer", Sheriff = "Sheriff" },
}

local function makeTag(adornee, parent, w, h, offset)
    local g = mk("BillboardGui", {
        Name = "NX_TAG", Adornee = adornee, AlwaysOnTop = true, Size = UDim2.fromOffset(w, h),
        StudsOffset = offset, ResetOnSpawn = false,
    }, parent)
    local l = mk("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
        TextSize = 14, TextStrokeTransparency = 0.15, TextStrokeColor3 = Color3.new(0, 0, 0),
        TextWrapped = true, Text = "",
    }, g)
    return g, l
end

local function makeHL(target, color, fillT)
    return mk("Highlight", {
        Name = "NX_HL", Adornee = target, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        FillColor = color, OutlineColor = color, FillTransparency = fillT, OutlineTransparency = 0,
    }, target)
end

local function clearPlayer(plr)
    local e = pEsp[plr]
    if e then
        pcall(function() e.hl:Destroy() end)
        pcall(function() e.gui:Destroy() end)
        pEsp[plr] = nil
    end
end

local function applyPlayer(plr, role)
    local char = plr.Character
    local head = char and char:FindFirstChild("Head")
    if not (char and head) then clearPlayer(plr) return end
    local e = pEsp[plr]
    if e and (e.char ~= char or not e.hl.Parent or not e.gui.Parent) then
        clearPlayer(plr)
        e = nil
    end
    if not e then
        local hl = makeHL(char, RC[role], 0.55)
        local g, l = makeTag(head, head, 170, 40, Vector3.new(0, 2.6, 0))
        e = { char = char, hl = hl, gui = g, label = l }
        pEsp[plr] = e
    end
    local c = RC[role]
    e.hl.FillColor = c
    e.hl.OutlineColor = c
    e.label.TextColor3 = c
    local rt = ROLE_TXT[NXH.getLang() == "TH" and "TH" or "EN"][role]
    e.label.Text = plr.DisplayName .. "\n" .. rt .. " [" .. distTo(head.Position) .. "m]"
end

local function clearAllPlayers()
    for plr in pairs(pEsp) do clearPlayer(plr) end
end

local function getVis(plr)
    local v = vis[plr]
    if v then return v end
    local line = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Visible = false }, overlay)
    local box = mk("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false }, overlay)
    local bs = mk("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1, 1, 1), Thickness = 2 }, box)
    local hpBg = mk("Frame", { BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderSizePixel = 0, Visible = false }, overlay)
    local hpFill = mk("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = RC.Innocent, BorderSizePixel = 0,
    }, hpBg)
    v = { line = line, box = box, bs = bs, hpBg = hpBg, hpFill = hpFill }
    vis[plr] = v
    return v
end

local function hideVis(v)
    v.line.Visible = false
    v.box.Visible = false
    v.hpBg.Visible = false
end

local function clearVis(plr)
    local v = vis[plr]
    if v then
        v.line:Destroy()
        v.box:Destroy()
        v.hpBg:Destroy()
        vis[plr] = nil
    end
end

local function drawPlayer(cam, plr, v, origin)
    local role = roleCache[plr]
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (role and hrp) then hideVis(v) return end
    local p, onScreen = cam:WorldToViewportPoint(hrp.Position)
    if not (onScreen and p.Z > 0) then hideVis(v) return end

    local c = RC[role]
    if ESP.lines then
        local d = Vector2.new(p.X, p.Y) - origin
        v.line.BackgroundColor3 = c
        v.line.Size = UDim2.fromOffset(d.Magnitude, 2)
        v.line.Position = UDim2.fromOffset(origin.X + d.X / 2, origin.Y + d.Y / 2)
        v.line.Rotation = math.deg(math.atan2(d.Y, d.X))
        v.line.Visible = true
    else
        v.line.Visible = false
    end

    if ESP.boxes then
        local t = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
        local b = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
        local h = math.abs(b.Y - t.Y)
        local w = h * 0.55
        v.box.Position = UDim2.fromOffset(p.X - w / 2, t.Y)
        v.box.Size = UDim2.fromOffset(w, h)
        v.bs.Color = c
        v.box.Visible = true
        local frac = hum and math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1) or 1
        v.hpBg.Position = UDim2.fromOffset(p.X - w / 2 - 7, t.Y)
        v.hpBg.Size = UDim2.fromOffset(4, h)
        v.hpFill.Size = UDim2.fromScale(1, frac)
        v.hpFill.BackgroundColor3 = Color3.fromHSV(frac * 0.33, 1, 1)
        v.hpBg.Visible = true
    else
        v.box.Visible = false
        v.hpBg.Visible = false
    end
end

local wasVis = false
bind(RunService.RenderStepped, function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    if not (ESP.lines or ESP.boxes) then
        if wasVis then
            for _, v in pairs(vis) do hideVis(v) end
            wasVis = false
        end
        return
    end
    wasVis = true
    local origin = Vector2.new(vp.X / 2, 0)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then drawPlayer(cam, plr, getVis(plr), origin) end
    end
    for plr in pairs(vis) do
        if not plr.Parent then clearVis(plr) end
    end
end)

---------------------------------------------------------------- ปืนที่ตก
local lastGunScan = 0

local function isDrop(inst)
    local n = inst.Name:lower()
    if (n:find("gundrop") or n:find("droppedgun")) and (inst:IsA("BasePart") or inst:IsA("Model")) then
        return true
    end
    if inst:IsA("Tool") and hasTag(inst, "Weapon_Gun") and not Players:GetPlayerFromCharacter(inst.Parent) then
        return true
    end
    return false
end

local function adorneePart(inst)
    if inst:IsA("BasePart") then return inst end
    return inst:FindFirstChildWhichIsA("BasePart", true)
end

local function pretty(s) return (tostring(s):gsub("(%l)(%u)", "%1 %2")) end

local function gunName()
    for _, d in pairs(playerData) do
        if type(d) == "table" and roleFromText(d.Role) == "Sheriff" and d.Gun then return pretty(d.Gun) end
    end
    for _, d in pairs(playerData) do
        if type(d) == "table" and d.Gun then return pretty(d.Gun) end
    end
    return nil
end

local function clearGun(inst)
    local e = gEsp[inst]
    if e then
        pcall(function() e.hl:Destroy() end)
        pcall(function() e.gui:Destroy() end)
        gEsp[inst] = nil
    end
end

local function gunGone(inst)
    return not inst:IsDescendantOf(workspace)
        or (inst:IsA("Tool") and Players:GetPlayerFromCharacter(inst.Parent) ~= nil)
end

local function updateGuns()
    local name = gunName() or "Gun"
    for inst in pairs(known) do
        if gunGone(inst) then
            clearGun(inst)
            known[inst] = nil
        else
            local part = adorneePart(inst)
            if part then
                local e = gEsp[inst]
                if e and (not e.hl.Parent or not e.gui.Parent) then
                    clearGun(inst)
                    e = nil
                end
                if not e then
                    local hl = makeHL(inst, GUN_COL, 0.3)
                    local g, l = makeTag(part, part, 170, 40, Vector3.new(0, 2, 0))
                    l.TextColor3 = GUN_COL
                    l.TextSize = 15
                    e = { hl = hl, gui = g, label = l }
                    gEsp[inst] = e
                end
                e.label.Text = "🔫 " .. name .. "\n[" .. distTo(part.Position) .. "m]"
            end
        end
    end
end

local function clearAllGuns()
    for inst in pairs(gEsp) do clearGun(inst) end
end

bind(workspace.DescendantAdded, function(d)
    if isDrop(d) then known[d] = true end
end)

local function scanDrops()
    local d = workspace:FindFirstChild("GunDrop", true)
    if d and isDrop(d) then known[d] = true end
end

local function gunPart()
    for inst in pairs(known) do
        if gunGone(inst) then
            known[inst] = nil
        else
            local p = adorneePart(inst)
            if p then return p end
        end
    end
    if os.clock() - lastGunScan > 2 then
        lastGunScan = os.clock()
        scanDrops()
    end
    return nil
end

-- ลูปหลักของ ESP
task.spawn(function()
    local gunWas, lastScan = false, 0
    while not MM.dead do
        task.wait(0.2)
        local ok, err = pcall(function()
            if ESP.roles or ESP.lines or ESP.boxes then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then roleCache[plr] = getRole(plr) end
                end
            end
            for plr in pairs(roleCache) do
                if not plr.Parent then roleCache[plr] = nil end
            end
            if ESP.roles then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then
                        local role = roleCache[plr]
                        if role then applyPlayer(plr, role) else clearPlayer(plr) end
                    end
                end
                for plr in pairs(pEsp) do
                    if not plr.Parent then clearPlayer(plr) end
                end
            else
                clearAllPlayers()
            end
            if ESP.gun then
                if not gunWas or os.clock() - lastScan > 3 then
                    scanDrops()
                    lastScan = os.clock()
                end
                updateGuns()
            else
                clearAllGuns()
            end
            gunWas = ESP.gun
        end)
        if not ok then warn("[NXMM2 ESP]", err) end
    end
end)

onUnload(function()
    ESP.roles, ESP.gun, ESP.lines, ESP.boxes = false, false, false, false
    clearAllPlayers()
    clearAllGuns()
    for plr in pairs(vis) do clearVis(plr) end
end)

---------------------------------------------------------------- รายชื่อผู้เล่น (ใช้ร่วมกันหลายหมวด)
local dropdowns = {}
local function playerNames()
    local l = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then l[#l + 1] = p.Name end
    end
    table.sort(l)
    return l
end
local function refreshAllDropdowns()
    local n = playerNames()
    for _, d in ipairs(dropdowns) do pcall(function() d:Refresh(n) end) end
end
bind(Players.PlayerAdded, function() task.delay(0.3, refreshAllDropdowns) end)
bind(Players.PlayerRemoving, function() task.delay(0.3, refreshAllDropdowns) end)

---------------------------------------------------------------- หมวด RADAR
do
    local tab = Tabs.MRadar
    tab:Paragraph({ Title = "mm2_legend" })
    tab:Section({ Title = "mm2_secRadar" })
    tab:Toggle({ Title = "mm2_espRoles", Value = false, Callback = function(v) ESP.roles = v end })
    tab:Toggle({ Title = "mm2_espGun", Value = false, Callback = function(v) ESP.gun = v end })
    tab:Toggle({ Title = "mm2_espLine", Value = false, Callback = function(v) ESP.lines = v end })
    tab:Toggle({ Title = "mm2_espBox", Value = false, Callback = function(v) ESP.boxes = v end })

    -- X-RAY : ทำให้ทุกอย่างในแมพใส (ฝั่งเราเท่านั้น)
    local XR = { on = false, parts = setmetatable({}, { __mode = "k" }) }

    local function isChar(d)
        local a = d.Parent
        while a and a ~= workspace do
            if a:IsA("Model") and Players:GetPlayerFromCharacter(a) then return true end
            a = a.Parent
        end
        return false
    end

    local function xrPart(d)
        if d:IsA("BasePart") and not d:IsA("Terrain") and not XR.parts[d]
            and not d.Name:lower():find("coin") and not isChar(d) then
            XR.parts[d] = true
            d.LocalTransparencyModifier = 0.7
        end
    end

    bind(workspace.DescendantAdded, function(d)
        if XR.on then xrPart(d) end
    end)

    local function xrOn()
        XR.on = true
        task.spawn(function()
            local n = 0
            for _, d in ipairs(workspace:GetDescendants()) do
                if not XR.on then return end
                xrPart(d)
                n += 1
                if n % 400 == 0 then task.wait() end
            end
        end)
    end

    local function xrOff()
        XR.on = false
        for p in pairs(XR.parts) do
            pcall(function() p.LocalTransparencyModifier = 0 end)
            XR.parts[p] = nil
        end
    end

    tab:Toggle({ Title = "mm2_xray", Value = false, Callback = function(v)
        if v then xrOn() else xrOff() end
    end })
    onUnload(xrOff)
end

---------------------------------------------------------------- หมวด WARP
do
    local tab = Tabs.MWarp

    local function warpTo(plr)
        local c = player.Character
        local tc = plr and plr.Character
        local th = tc and tc:FindFirstChild("HumanoidRootPart")
        if c and th and c:FindFirstChild("HumanoidRootPart") then
            c:PivotTo(th.CFrame * CFrame.new(0, 0, 3))
            return true
        end
        return false
    end

    local function warpToRole(role, missEn, missTh)
        fetchNow()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and getRole(plr) == role then
                if not warpTo(plr) then toast("Failed (no character)", "ทำไม่ได้ (ไม่พบตัวละคร)") end
                return
            end
        end
        toast(missEn, missTh)
    end

    tab:Section({ Title = "mm2_secWarp" })
    tab:Toggle({ Title = "mm2_wGun", Value = false, Callback = function(v) FLAGS.warpGun = v end })
    tab:Button({ Title = "mm2_wMurder", Callback = function()
        warpToRole("Murderer", "Murderer not found", "ไม่พบฆาตกร")
    end })
    tab:Button({ Title = "mm2_wSheriff", Callback = function()
        warpToRole("Sheriff", "Sheriff not found", "ไม่พบนายอำเภอ")
    end })

    local sel
    dropdowns[#dropdowns + 1] = tab:Dropdown({ Title = "mm2_wList", Values = playerNames(), Callback = function(v) sel = v end })
    tab:Button({ Title = "mm2_wGo", Callback = function()
        local plr = sel and Players:FindFirstChild(sel)
        if not plr then toast("No player selected", "ยังไม่ได้เลือกผู้เล่น") return end
        if not warpTo(plr) then toast("Failed (no character)", "ทำไม่ได้ (ไม่พบตัวละคร)") end
    end })

    -- ดูดปืนอัตโนมัติ (ตอนเป็นคนธรรมดา)
    task.spawn(function()
        local busy = false
        while not MM.dead do
            task.wait(0.4)
            if FLAGS.warpGun and not busy and getRole(player) == "Innocent" then
                local part = gunPart()
                local c = player.Character
                if part and c and c:FindFirstChild("HumanoidRootPart") then
                    busy = true
                    local back = c:GetPivot()
                    c:PivotTo(part.CFrame)
                    task.wait(0.4)
                    c = player.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then c:PivotTo(back) end
                    task.wait(2)
                    busy = false
                end
            end
        end
    end)
end

---------------------------------------------------------------- หมวด HUNTER
do
    local tab = Tabs.MHunter
    local RANGE_GUN, RANGE_KNIFE = 250, 150 -- ระยะสูงสุดของโหมดอัตโนมัติ (แก้เลขได้)

    local function alive(plr)
        local ch = plr.Character
        local h = ch and ch:FindFirstChildOfClass("Humanoid")
        local r = ch and ch:FindFirstChild("HumanoidRootPart")
        if h and r and h.Health > 0 then return ch, r end
        return nil
    end

    local function hasRemote(t, words)
        for _, d in ipairs(t:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                local n = d.Name:lower()
                for _, w in ipairs(words) do
                    if n:find(w, 1, true) then return true end
                end
            end
        end
        return false
    end

    local function isKnife(t)
        if not t:IsA("Tool") then return false end
        return t.Name:lower():find("knife") ~= nil or hasTag(t, "Weapon_Knife") or hasRemote(t, { "throw" })
    end

    local function isGun(t)
        if not t:IsA("Tool") or isKnife(t) then return false end
        local n = t.Name:lower()
        return n:find("gun") ~= nil or n:find("revolver") ~= nil or hasTag(t, "Weapon_Gun")
            or hasRemote(t, { "shoot", "createbeam" })
    end

    local function findTool(test)
        local c = player.Character
        if c then
            for _, t in ipairs(c:GetChildren()) do if test(t) then return t end end
        end
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do if test(t) then return t end end
        end
        return nil
    end

    -- ถืออยู่แล้วก็ใช้เลย ถ้ายังไม่ถือ รอจนสวมเสร็จ (สูงสุด 1 วินาที)
    local function equip(t)
        if not t then return nil end
        local c, _, hum = myParts()
        if not (c and hum) then return nil end
        if t.Parent ~= c then
            pcall(function() hum:EquipTool(t) end)
            local t0 = os.clock()
            while t.Parent ~= c and os.clock() - t0 < 1 do task.wait(0.05) end
        end
        if t.Parent == c then return t end
        return nil
    end
    local function equipKnife() return equip(findTool(isKnife)) end
    local function equipGun() return equip(findTool(isGun)) end

    local function pickRemote(tool, names)
        local list = {}
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then list[#list + 1] = d end
        end
        for _, w in ipairs(names) do
            for _, d in ipairs(list) do
                if d.Name:lower() == w then return d end
            end
        end
        for _, w in ipairs(names) do
            for _, d in ipairs(list) do
                if d.Name:lower():find(w, 1, true) then return d end
            end
        end
        return nil
    end

    local function dumpRemotes(tag, tool)
        local names = {}
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                names[#names + 1] = d.Name
                print("[NX " .. tag .. "]", d:GetFullName(), d.ClassName)
            end
        end
        return #names > 0 and table.concat(names, ",") or "-"
    end

    local function fire(remote, ...)
        local a = table.pack(...)
        if remote:IsA("RemoteFunction") then
            task.spawn(function() pcall(function() remote:InvokeServer(table.unpack(a, 1, a.n)) end) end)
        else
            pcall(function() remote:FireServer(table.unpack(a, 1, a.n)) end)
        end
    end

    local function handPos()
        local c, hrp = myParts()
        local hand = c and (c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm"))
        local p = hand or hrp
        return p and p.Position
    end

    -- เล็งนำเป้าเล็กน้อยตามความเร็วที่เดิน
    local function aimPoint(r, from)
        local v = r.AssemblyLinearVelocity
        local lead = Vector3.new(v.X, 0, v.Z)
        if lead.Magnitude > 60 then lead = lead.Unit * 60 end
        local t = math.clamp((r.Position - from).Magnitude / 140, 0, 0.35)
        return r.Position + lead * t
    end

    -- เห็นตัวจริงไหม: ยิงเส้นจากหัวเราไปหาเป้า ถ้ากำแพงหรือผู้เล่นอื่นบังจะไม่เห็น
    local function canSee(targetChar, part)
        local c, hrp = myParts()
        if not (c and hrp and part and part.Parent) then return false end
        local origin = (c:FindFirstChild("Head") or hrp).Position
        local dir = part.Position - origin
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.IgnoreWater = true
        local ignore = { c }
        for _ = 1, 8 do
            params.FilterDescendantsInstances = ignore
            local res = workspace:Raycast(origin, dir, params)
            if not res then return true end
            local hit = res.Instance
            if hit:IsDescendantOf(targetChar) then return true end
            local m = hit:FindFirstAncestorOfClass("Model")
            if m and m:FindFirstChildOfClass("Humanoid") then return false end
            if hit.CanCollide then return false end
            ignore[#ignore + 1] = hit
        end
        return false
    end

    local function throwAt(r, silent)
        local knife = equipKnife()
        if not knife then
            if not silent then toast("No knife found", "ไม่พบมีดในตัว") end
            return false
        end
        local from = handPos()
        if not from then return false end
        local aim = aimPoint(r, from)
        local rem = pickRemote(knife, { "throw", "knifethrown", "throwknife" })
        if rem then
            fire(rem, CFrame.new(from), CFrame.new(aim))
            return true
        end
        local list = dumpRemotes("KNIFE", knife)
        if not silent then
            toast("Weapon remote not found: " .. list, "ไม่พบรีโมตอาวุธ: " .. list)
            pcall(function() knife:Activate() end)
        end
        return false
    end

    local function shootAt(r, silent)
        local gun = equipGun()
        if not gun then
            if not silent then toast("No gun found", "ไม่พบปืนในตัว") end
            return false
        end
        local from = handPos()
        if not from then return false end
        local aim = aimPoint(r, from)
        local rem = pickRemote(gun, { "shoot" })
        if rem then
            fire(rem, CFrame.new(from), CFrame.new(aim)) -- ปืนรุ่นใหม่
            return true
        end
        rem = pickRemote(gun, { "createbeam", "fire", "shot" })
        if rem then
            fire(rem, 1, aim, "AH2") -- ปืนรุ่นเก่า
            return true
        end
        local list = dumpRemotes("GUN", gun)
        if silent then return false end
        toast("Weapon remote not found: " .. list, "ไม่พบรีโมตอาวุธ: " .. list)
        local cam = workspace.CurrentCamera
        if cam then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, r.Position) end
        pcall(function() gun:Activate() end)
        return true
    end

    local function murdererTarget(fresh)
        if fresh then fetchNow() end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and getRole(plr) == "Murderer" then
                local ch, r = alive(plr)
                if ch then return r, ch end
            end
        end
        return nil
    end

    local function nearest(rangeMax, needVisible)
        local _, hrp = myParts()
        if not hrp then return nil end
        local best, bch, bd
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local ch, r = alive(plr)
                if ch then
                    local d = (r.Position - hrp.Position).Magnitude
                    if (not rangeMax or d <= rangeMax) and (not bd or d < bd) then
                        if not needVisible or canSee(ch, r) then
                            best, bch, bd = r, ch, d
                        end
                    end
                end
            end
        end
        return best, bch
    end

    local function stab(knife, targetRoot)
        pcall(function() knife:Activate() end)
        local handle = knife:FindFirstChild("Handle")
        if firetouchinterest and handle then
            pcall(firetouchinterest, targetRoot, handle, 0)
            pcall(firetouchinterest, targetRoot, handle, 1)
        end
    end

    -- ออโต้ฆ่า
    task.spawn(function()
        while not MM.dead do
            task.wait(0.15)
            if K.auto then
                local ok, err = pcall(function()
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if not K.auto then break end
                        if plr ~= player then
                            local ch, r = alive(plr)
                            local _, hrp = myParts()
                            if ch and hrp then
                                local knife = equipKnife()
                                if not knife then toast("No knife found", "ไม่พบมีดในตัว") task.wait(1) break end
                                local pos = (r.CFrame * CFrame.new(0, 0, 3)).Position
                                hrp.CFrame = CFrame.lookAt(pos, r.Position)
                                task.wait(0.12)
                                stab(knife, r)
                                task.wait(0.35)
                            end
                        end
                    end
                end)
                if not ok then warn("[NXMM2 KILL]", err) end
            end
        end
    end)

    -- ฆ่าทั้งแมพ (ลากมาข้างหน้าเฉพาะฝั่งเรา)
    bind(RunService.Heartbeat, function()
        if not K.all then return end
        local _, hrp = myParts()
        if not hrp then return end
        local n = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local ch, r = alive(plr)
                if ch then
                    n += 1
                    local col = (n - 1) % 5 - 2
                    local row = math.floor((n - 1) / 5)
                    r.CFrame = hrp.CFrame * CFrame.new(col * 2, 0, -4 - row * 2)
                    r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)

    task.spawn(function()
        while not MM.dead do
            task.wait(0.3)
            if K.all then
                pcall(function()
                    local knife = equipKnife()
                    if not knife then return end
                    pcall(function() knife:Activate() end)
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= player then
                            local ch, r = alive(plr)
                            if ch then stab(knife, r) end
                        end
                    end
                end)
            end
        end
    end)

    -- ปุ่มปามีด / ปุ่มยิง ข้างขวาจอ
    local function sideButton(y, textEn, textTh, color, bg)
        local b = mk("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.45, y),
            Size = UDim2.fromOffset(70, 70), BackgroundColor3 = bg, TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold, TextSize = 13, Text = "", AutoButtonColor = false,
            Visible = false, ZIndex = 20,
        }, overlay)
        corner(b, 16)
        mk("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = color, Thickness = 2.5 }, b)
        local function setText() b.Text = T(textEn, textTh) end
        setText()
        pcall(function() NXH.onLang(setText) end)
        return b
    end

    local throwBtn = sideButton(0, "🔪\nTHROW", "🔪\nปามีด", Color3.fromRGB(255, 70, 85), Color3.fromRGB(70, 16, 30))
    local shootBtn = sideButton(84, "🔫\nSHOOT", "🔫\nยิง", Color3.fromRGB(60, 140, 255), Color3.fromRGB(16, 40, 90))

    local busyT = false
    throwBtn.Activated:Connect(function()
        if busyT then return end
        busyT = true
        local ok, err = pcall(function()
            local r = nearest(nil, true)
            if not r then r = nearest(nil, false) end
            if not r then toast("No target found", "ไม่พบเป้าหมาย") return end
            if throwAt(r, false) then toast("🔪 Thrown", "🔪 ปาแล้ว") end
        end)
        if not ok then warn("[NXMM2 THROW]", err) end
        busyT = false
    end)

    local busyS = false
    shootBtn.Activated:Connect(function()
        if busyS then return end
        busyS = true
        local ok, err = pcall(function()
            local r = murdererTarget(true)
            if not r then toast("Murderer not found", "ไม่พบฆาตกร") return end
            if shootAt(r, false) then toast("🔫 Shot", "🔫 ยิงแล้ว") end
        end)
        if not ok then warn("[NXMM2 SHOOT]", err) end
        busyS = false
    end)

    -- ปามีด/ยิง อัตโนมัติ: ทำงานเฉพาะตอนมองเห็นเป้าจริง
    local lastFetch = 0
    task.spawn(function()
        local lastS, lastT = 0, 0
        while not MM.dead do
            task.wait(0.1)
            if (K.aShoot or K.aThrow) and not FLAGS.flinging then
                pcall(function()
                    local c, hrp, hum = myParts()
                    if not (c and hrp and hum and hum.Health > 0) then return end

                    if K.aShoot and os.clock() - lastS > 0.4 and findTool(isGun) then
                        if os.clock() - lastFetch > 1.5 then
                            lastFetch = os.clock()
                            fetchNow()
                        end
                        local r, ch = murdererTarget(false)
                        if r and (r.Position - hrp.Position).Magnitude <= RANGE_GUN and canSee(ch, r) then
                            if shootAt(r, true) then lastS = os.clock() else lastS = os.clock() + 2 end
                        end
                    end

                    if K.aThrow and os.clock() - lastT > 0.8 and findTool(isKnife) then
                        local r = nearest(RANGE_KNIFE, true)
                        if r then
                            if throwAt(r, true) then lastT = os.clock() else lastT = os.clock() + 2 end
                        end
                    end
                end)
            end
        end
    end)

    tab:Section({ Title = "mm2_secHunter" })
    tab:Toggle({ Title = "mm2_mAuto", Value = false, Callback = function(v) K.auto = v end })
    tab:Toggle({ Title = "mm2_mAll", Value = false, Callback = function(v) K.all = v end })
    tab:Toggle({ Title = "mm2_mThrow", Value = false, Callback = function(v) K.throw = v throwBtn.Visible = v end })
    tab:Toggle({ Title = "mm2_sShoot", Value = false, Callback = function(v) K.shoot = v shootBtn.Visible = v end })
    tab:Toggle({ Title = "mm2_aThrow", Value = false, Callback = function(v) K.aThrow = v end })
    tab:Toggle({ Title = "mm2_aShoot", Value = false, Callback = function(v) K.aShoot = v end })

    onUnload(function()
        for k in pairs(K) do K[k] = false end
    end)
end

---------------------------------------------------------------- หมวด FLING
do
    local tab = Tabs.MFling
    local busy = false
    local TIMEOUT, ROUNDS = 2.5, 3

    local function hb() RunService.Heartbeat:Wait() end

    local function zeroAll(c)
        for _, d in ipairs(c:GetChildren()) do
            if d:IsA("BasePart") then
                d.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                d.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end
    end

    local function flingPlayer(plr)
        if busy then toast("Already flinging", "กำลังฟลิ้งอยู่") return end
        local c = player.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local tch = plr and plr.Character
        local troot = tch and tch:FindFirstChild("HumanoidRootPart")
        local thum = tch and tch:FindFirstChildOfClass("Humanoid")
        if not (hrp and hum and hum.Health > 0 and troot and thum and thum.Health > 0) then
            toast("Failed (no character)", "ทำไม่ได้ (ไม่พบตัวละคร)")
            return
        end

        busy = true
        FLAGS.flinging = true
        local homeCF = hrp.CFrame
        local startPos = troot.Position
        local cam = workspace.CurrentCamera
        local oldSubject = cam and cam.CameraSubject
        local oldFall = workspace.FallenPartsDestroyHeight
        pcall(function() workspace.FallenPartsDestroyHeight = 0 / 0 end)
        pcall(function() cam.CameraSubject = thum end)

        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(9e8, 9e8, 9e8)
        bv.Parent = hrp

        local function pose(offset, ang)
            local cf = CFrame.new(troot.Position) * offset * ang
            pcall(function() c:PivotTo(cf) end)
            hrp.AssemblyLinearVelocity = Vector3.new(9e7, 9e8, 9e7)
            hrp.AssemblyAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
            hb()
        end

        local function targetGone()
            return not (plr.Parent and plr.Character == tch and troot.Parent) or thum.Health <= 0
        end

        local flung = false
        local ok, err = pcall(function()
            for _ = 1, ROUNDS do
                local t0 = os.clock()
                local angle = 0
                while true do
                    if targetGone() or hum.Health <= 0 or not hrp.Parent then break end
                    local spd = troot.AssemblyLinearVelocity.Magnitude
                    if spd > 500 or (troot.Position - startPos).Magnitude > 300 then
                        flung = true
                        break
                    end
                    if os.clock() - t0 > TIMEOUT then break end
                    if spd < 50 then
                        angle += 100
                        local lead = CFrame.new(thum.MoveDirection * spd / 10)
                        local a = CFrame.Angles(math.rad(angle), 0, 0)
                        pose(CFrame.new(0, 1.5, 0) * lead, a)
                        pose(CFrame.new(0, -1.5, 0) * lead, a)
                        pose(CFrame.new(2.25, 1.5, -2.25) * lead, a)
                        pose(CFrame.new(-2.25, -1.5, 2.25) * lead, a)
                        pose(CFrame.new(0, 1.5, 0) * CFrame.new(thum.MoveDirection), a)
                        pose(CFrame.new(0, -1.5, 0) * CFrame.new(thum.MoveDirection), a)
                    else
                        local ws = thum.WalkSpeed
                        pose(CFrame.new(0, 1.5, ws), CFrame.Angles(math.rad(90), 0, 0))
                        pose(CFrame.new(0, -1.5, -ws), CFrame.Angles(0, 0, 0))
                        pose(CFrame.new(0, 1.5, ws), CFrame.Angles(math.rad(90), 0, 0))
                        pose(CFrame.new(0, 1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        pose(CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                        pose(CFrame.new(0, 1.5, 0), CFrame.Angles(0, 0, 0))
                    end
                end
                if flung or targetGone() or hum.Health <= 0 then break end
            end
        end)
        if not ok then warn("[NXMM2 FLING]", err) end

        bv:Destroy()
        pcall(function() cam.CameraSubject = oldSubject or hum end)
        for i = 1, 90 do
            if not (hrp.Parent and c.Parent) then break end
            pcall(function() c:PivotTo(homeCF * CFrame.new(0, 0.5, 0)) end)
            zeroAll(c)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            hb()
            if i >= 12 and (hrp.Position - homeCF.Position).Magnitude < 15 then break end
        end
        pcall(function() workspace.FallenPartsDestroyHeight = oldFall end)
        FLAGS.flinging = false
        busy = false
        toast("Fling finished ✓", "ฟลิ้งเสร็จแล้ว ✓")
    end

    local function flingRole(role, missEn, missTh)
        fetchNow()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and getRole(plr) == role then
                task.spawn(flingPlayer, plr)
                return
            end
        end
        toast(missEn, missTh)
    end

    tab:Section({ Title = "mm2_secFling" })
    tab:Button({ Title = "mm2_fSheriff", Variant = "Secondary", Callback = function()
        flingRole("Sheriff", "Sheriff not found", "ไม่พบนายอำเภอ")
    end })
    tab:Button({ Title = "mm2_fMurder", Variant = "Danger", Callback = function()
        flingRole("Murderer", "Murderer not found", "ไม่พบฆาตกร")
    end })

    local sel
    dropdowns[#dropdowns + 1] = tab:Dropdown({ Title = "mm2_wList", Values = playerNames(), Callback = function(v) sel = v end })
    tab:Button({ Title = "mm2_fGo", Callback = function()
        local plr = sel and Players:FindFirstChild(sel)
        if not plr then toast("No player selected", "ยังไม่ได้เลือกผู้เล่น") return end
        task.spawn(flingPlayer, plr)
    end })

    onUnload(function() FLAGS.flinging = false end)
end

---------------------------------------------------------------- หมวด PLAYER
do
    local tab = Tabs.MPlayer
    local WALK_BASE, WALK_ADD = 16, 100
    local JUMP_BASE, JUMP_ADD = 50, 100
    local FLY_SPEED = 66

    local orig = setmetatable({}, { __mode = "k" })
    local noclipWas = false
    bind(RunService.Stepped, function()
        local c = player.Character
        if not c then return end
        if P.noclip and not FLAGS.flinging then
            noclipWas = true
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("BasePart") then
                    if orig[d] == nil then orig[d] = d.CanCollide end
                    d.CanCollide = false
                end
            end
        elseif noclipWas then
            noclipWas = false
            for part, v in pairs(orig) do
                if part.Parent then part.CanCollide = v end
                orig[part] = nil
            end
        end
    end)

    bind(RunService.Heartbeat, function()
        local _, _, hum = myParts()
        if not hum then return end
        if P.speed then hum.WalkSpeed = WALK_BASE + WALK_ADD end
        if P.jump then
            hum.UseJumpPower = true
            hum.JumpPower = JUMP_BASE + JUMP_ADD
        end
    end)

    local flyBV, flyBG
    local function stopFly()
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        local _, _, hum = myParts()
        if hum then hum.AutoRotate = true end
    end

    local function startFly()
        local _, hrp, hum = myParts()
        if not hrp then return end
        stopFly()
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 9e4
        flyBG.CFrame = hrp.CFrame
        flyBG.Parent = hrp
        if hum then hum.AutoRotate = false end
    end

    bind(RunService.RenderStepped, function()
        if not P.fly then return end
        if FLAGS.flinging or FLAGS.floating then
            if flyBV then stopFly() end
            return
        end
        local _, hrp, hum = myParts()
        local cam = workspace.CurrentCamera
        if not (hrp and hum and cam) then return end
        if not (flyBV and flyBV.Parent == hrp) then startFly() end
        if not flyBV then return end
        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local fl = Vector3.new(look.X, 0, look.Z)
        local fr = Vector3.new(right.X, 0, right.Z)
        local vel = Vector3.new(0, 0, 0)
        local md = hum.MoveDirection
        if md.Magnitude > 0.05 and fl.Magnitude > 0.01 and fr.Magnitude > 0.01 then
            vel = (look * md:Dot(fl.Unit) + right * md:Dot(fr.Unit)) * FLY_SPEED
        end
        flyBV.Velocity = vel
        if flyBG and fl.Magnitude > 0.01 then
            flyBG.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + fl)
        end
    end)

    local tpTool
    local function giveTool()
        if tpTool and tpTool.Parent then return end
        local bp = player:FindFirstChild("Backpack")
        if not bp then return end
        tpTool = Instance.new("Tool")
        tpTool.Name = "TP NEXORA"
        tpTool.ToolTip = "TP NEXORA"
        tpTool.RequiresHandle = false
        tpTool.CanBeDropped = false
        tpTool.Activated:Connect(function()
            local c = player.Character
            local mouse = player:GetMouse()
            if c and mouse and mouse.Hit then
                c:PivotTo(CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)))
            end
        end)
        tpTool.Parent = bp
    end

    task.spawn(function()
        while not MM.dead do
            task.wait(1)
            if P.tp then giveTool() end
        end
    end)

    bind(RunService.Stepped, function()
        if not P.anti or FLAGS.flinging then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                for _, d in ipairs(plr.Character:GetDescendants()) do
                    if d:IsA("BasePart") then d.CanCollide = false end
                end
            end
        end
    end)

    bind(RunService.Heartbeat, function()
        if not P.anti or FLAGS.flinging then return end
        local _, hrp = myParts()
        if hrp and (hrp.AssemblyLinearVelocity.Magnitude > 250 or hrp.AssemblyAngularVelocity.Magnitude > 60) then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end)

    tab:Section({ Title = "mm2_secPlayer" })
    tab:Toggle({ Title = "mm2_pNoclip", Value = false, Callback = function(v) P.noclip = v end })
    tab:Toggle({ Title = "mm2_pSpeed", Value = false, Callback = function(v)
        P.speed = v
        if not v then
            local _, _, hum = myParts()
            if hum then hum.WalkSpeed = WALK_BASE end
        end
    end })
    tab:Toggle({ Title = "mm2_pJump", Value = false, Callback = function(v)
        P.jump = v
        if not v then
            local _, _, hum = myParts()
            if hum then hum.JumpPower = JUMP_BASE end
        end
    end })
    tab:Toggle({ Title = "mm2_pFly", Value = false, Callback = function(v)
        P.fly = v
        if not v then stopFly() end
    end })
    tab:Toggle({ Title = "mm2_pTp", Value = false, Callback = function(v)
        P.tp = v
        if v then giveTool() elseif tpTool then tpTool:Destroy() tpTool = nil end
    end })
    tab:Toggle({ Title = "mm2_pAnti", Value = false, Callback = function(v) P.anti = v end })

    onUnload(function()
        for k in pairs(P) do P[k] = false end
        stopFly()
        local _, _, hum = myParts()
        if hum then
            hum.WalkSpeed = WALK_BASE
            hum.JumpPower = JUMP_BASE
        end
        for part, v in pairs(orig) do
            if part.Parent then part.CanCollide = v end
            orig[part] = nil
        end
        if tpTool then tpTool:Destroy() tpTool = nil end
    end)
end

---------------------------------------------------------------- หมวด FARM
do
    local tab = Tabs.MFarm
    local LIMIT = 40
    local SPEED = 20 -- ความเร็วลอย (แก้เลขนี้ได้)
    local FARM = { on = false }
    local collected, lastCont, lastFind = 0, nil, 0
    local done, target, tStart, tLimit, arrT = {}, nil, 0, 3, nil
    local lastTouch = 0
    local fv, fg = nil, nil
    local floating = false
    local orig = setmetatable({}, { __mode = "k" })
    local toastedDone = false

    tab:Section({ Title = "mm2_secFarm" })
    local countP = tab:Paragraph({ Title = "🪙 0 / " .. LIMIT })

    local function coinPart(o)
        if o:IsA("BasePart") then return o end
        return o:FindFirstChildWhichIsA("BasePart", true)
    end

    local function nextCoin(cont, hrp)
        local best, bd
        for _, o in ipairs(cont:GetChildren()) do
            local p = coinPart(o)
            if p and p.Parent and not done[p] then
                local d = (p.Position - hrp.Position).Magnitude
                if not bd or d < bd then best, bd = p, d end
            end
        end
        return best, bd
    end

    local function release()
        if fv then fv:Destroy() fv = nil end
        if fg then fg:Destroy() fg = nil end
        for part, v in pairs(orig) do
            if part.Parent then part.CanCollide = v end
            orig[part] = nil
        end
        if floating then
            floating = false
            FLAGS.floating = false
            local _, _, hum = myParts()
            if hum then
                hum.PlatformStand = false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end
        end
    end

    local function engage(hrp, hum)
        if not (fv and fv.Parent == hrp) then
            if fv then fv:Destroy() end
            fv = Instance.new("BodyVelocity")
            fv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
            fv.Velocity = Vector3.new(0, 0, 0)
            fv.Parent = hrp
        end
        if not (fg and fg.Parent == hrp) then
            if fg then fg:Destroy() end
            fg = Instance.new("BodyGyro")
            fg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
            fg.P = 1e5
            fg.D = 1e3
            fg.CFrame = hrp.CFrame
            fg.Parent = hrp
        end
        floating = true
        FLAGS.floating = true
        hum.PlatformStand = true
    end

    local function resetRound()
        release()
        collected = 0
        done = {}
        target, arrT = nil, nil
        toastedDone = false
    end
    bind(player.CharacterAdded, resetRound)

    local function setCount()
        pcall(function()
            countP:SetTitle("🪙 " .. collected .. " / " .. LIMIT
                .. (collected >= LIMIT and "  ✓" or (floating and "  ☁️" or "")))
        end)
    end
    task.spawn(function()
        while not MM.dead do
            task.wait(0.5)
            setCount()
        end
    end)

    bind(RunService.Stepped, function()
        if not floating then return end
        local c = player.Character
        if not c then return end
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("BasePart") then
                if orig[d] == nil then orig[d] = d.CanCollide end
                d.CanCollide = false
            end
        end
    end)

    bind(RunService.Heartbeat, function()
        if not FARM.on or FLAGS.flinging then release() return end
        local c, hrp, hum = myParts()
        if not (c and hrp and hum and hum.Health > 0) then release() return end

        if os.clock() - lastFind > 1 or (lastCont and not lastCont.Parent) then
            lastFind = os.clock()
            local f = workspace:FindFirstChild("CoinContainer", true)
            if f ~= lastCont then
                lastCont = f
                resetRound()
            end
        end
        local cont = lastCont

        if collected >= LIMIT then
            release()
            if not toastedDone then
                toastedDone = true
                toast("All coins collected ✓", "เก็บเหรียญครบแล้ว ✓")
            end
            return
        end
        if not cont then release() return end

        if target then
            if not target.Parent then
                done[target] = true
                collected += 1
                target, arrT = nil, nil
            elseif os.clock() - tStart > tLimit then
                done[target] = true
                target, arrT = nil, nil
            end
        end
        if not target then
            local coin, d0 = nextCoin(cont, hrp)
            if not coin then release() return end
            target = coin
            tStart = os.clock()
            tLimit = 1.5 + (d0 / SPEED) * 1.5
        end

        engage(hrp, hum)
        local to = target.Position - hrp.Position
        local dist = to.Magnitude
        if dist < 1.2 then
            fv.Velocity = Vector3.new(0, 0, 0)
        else
            fv.Velocity = to.Unit * math.min(SPEED, math.max(dist * 6, 12))
            local flat = Vector3.new(to.X, 0, to.Z)
            if flat.Magnitude > 0.5 then
                fg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flat)
            end
        end

        if dist < 2.5 then
            arrT = arrT or os.clock()
            if os.clock() - arrT > 0.4 then
                done[target] = true
                collected += 1
                target, arrT = nil, nil
            end
        else
            arrT = nil
        end

        if target and dist < 6 and firetouchinterest and os.clock() - lastTouch > 0.15 then
            lastTouch = os.clock()
            pcall(firetouchinterest, hrp, target, 0)
            pcall(firetouchinterest, hrp, target, 1)
        end
    end)

    tab:Toggle({ Title = "mm2_cfCoin", Value = false, Callback = function(v)
        FARM.on = v
        if not v then release() end
    end })
    onUnload(function() FARM.on = false release() end)

    local afkOn = false
    bind(player.Idled, function()
        if afkOn then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end
    end)
    tab:Toggle({ Title = "mm2_afk", Value = false, Callback = function(v) afkOn = v end })
end

---------------------------------------------------------------- หมวด EVENT
-- สแกนหาของอีเวนท์ในแมพเอง แล้วสร้างสวิตช์ให้ทีละชนิดอัตโนมัติ (ไม่มีอีเวนท์ = หมวดว่าง)
do
    local tab = Tabs.MEvent
    local EV = { active = {}, groups = {} }

    -- คำที่ใช้เดาว่าเป็นของอีเวนท์ (เติมเองได้ถ้าแอดมินตั้งชื่อแปลก)
    local KEYWORDS = {
        "shell", "seashell", "clam", "pearl", "candy", "pumpkin", "egg", "snowflake",
        "gift", "present", "token", "orb", "crystal", "gem", "collect", "event",
        "star", "ticket", "treat", "candies", "halloween", "spooky",
    }

    local function matchName(n)
        n = n:lower()
        if n:find("coin") then return false end
        for _, k in ipairs(KEYWORDS) do
            if n:find(k, 1, true) then return true end
        end
        return false
    end

    local function candyLike(s) return tostring(s):lower():find("cand", 1, true) ~= nil end
    local CANDY_COLORS = { Purple = true, Green = true, Cyan = true, Orange = true, Pink = true }
    local function attrId(d)
        for _, k in ipairs({ "CoinID", "CoinType", "ItemType", "Type", "EventItem" }) do
            local v = d:GetAttribute(k)
            if type(v) == "string" and v ~= "" then return v end
        end
        return nil
    end

    local function inChar(d)
        local a = d.Parent
        while a and a ~= workspace do
            if (a:IsA("Model") and Players:GetPlayerFromCharacter(a)) or a:IsA("Tool") then
                return true
            end
            a = a.Parent
        end
        return false
    end

    local SPEED = 20
    local release
    local fv, fg, floating = nil, nil, false
    local orig = setmetatable({}, { __mode = "k" })
    local done = setmetatable({}, { __mode = "k" })
    local target, tStart, tLimit, arrT, lastTouch = nil, 0, 3, nil, 0

    tab:Section({ Title = "mm2_secEvent" })
    tab:Toggle({ Title = "mm2_candy", Value = false, Callback = function(v)
        EV.active["Candy"] = v or nil
        if not v and not next(EV.active) then release() end
    end })
    tab:Paragraph({ Title = "mm2_evHint" })

    function release()
        if fv then fv:Destroy() fv = nil end
        if fg then fg:Destroy() fg = nil end
        for p, v in pairs(orig) do
            if p.Parent then p.CanCollide = v end
            orig[p] = nil
        end
        if floating then
            floating = false
            FLAGS.floating = false
            local _, _, hum = myParts()
            if hum then
                hum.PlatformStand = false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end
        end
        target, arrT = nil, nil
    end

    local function addGroup(name)
        EV.groups[name] = { items = setmetatable({}, { __mode = "k" }) }
        if name == "Candy" then return end
        tab:Toggle({ Title = "🎁 " .. name, Value = false, Callback = function(v)
            EV.active[name] = v or nil
            if not v and not next(EV.active) then release() end
        end })
    end

    local function consider(d)
        if not d:IsA("BasePart") or d:IsA("Terrain") then return end
        local inCont = d:FindFirstAncestor("CoinContainer") ~= nil
        if not inCont and not d:FindFirstChildWhichIsA("TouchTransmitter") then return end
        if inChar(d) then return end
        local id = attrId(d)
        local name
        if candyLike(d.Name) or (d.Parent and candyLike(d.Parent.Name)) or (id and candyLike(id))
            or (inCont and CANDY_COLORS[d.Name]) then
            name = "Candy"
        elseif inCont and id and id:lower() ~= "coin" then
            name = id
        elseif matchName(d.Name) then
            name = d.Name
        elseif d.Parent and d.Parent ~= workspace and matchName(d.Parent.Name) then
            name = d.Parent.Name
        end
        if not name then return end
        if not EV.groups[name] then addGroup(name) end
        EV.groups[name].items[d] = true
    end

    bind(workspace.DescendantAdded, function(d) task.defer(consider, d) end)

    task.spawn(function()
        local n = 0
        for _, d in ipairs(workspace:GetDescendants()) do
            if MM.dead then return end
            pcall(consider, d)
            n += 1
            if n % 300 == 0 then task.wait() end
        end
    end)

    local function nextItem(hrp)
        local best, bd
        for name in pairs(EV.active) do
            local g = EV.groups[name]
            if g then
                for p in pairs(g.items) do
                    if p.Parent and p:IsDescendantOf(workspace) and not done[p] then
                        local d = (p.Position - hrp.Position).Magnitude
                        if not bd or d < bd then best, bd = p, d end
                    end
                end
            end
        end
        return best, bd
    end

    bind(RunService.Stepped, function()
        if not floating then return end
        local c = player.Character
        if not c then return end
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("BasePart") then
                if orig[d] == nil then orig[d] = d.CanCollide end
                d.CanCollide = false
            end
        end
    end)

    bind(RunService.Heartbeat, function()
        if not next(EV.active) or FLAGS.flinging then
            if floating then release() end
            return
        end
        if FLAGS.floating and not floating then return end -- ฟาร์มเหรียญกำลังลอยอยู่

        local c, hrp, hum = myParts()
        if not (c and hrp and hum and hum.Health > 0) then release() return end

        if target then
            if not target.Parent or os.clock() - tStart > tLimit then
                done[target] = true
                target, arrT = nil, nil
            end
        end
        if not target then
            local item, d0 = nextItem(hrp)
            if not item then release() return end
            target = item
            tStart = os.clock()
            tLimit = 1.5 + (d0 / SPEED) * 1.5
        end

        if not (fv and fv.Parent == hrp) then
            if fv then fv:Destroy() end
            fv = Instance.new("BodyVelocity")
            fv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
            fv.Velocity = Vector3.new(0, 0, 0)
            fv.Parent = hrp
        end
        if not (fg and fg.Parent == hrp) then
            if fg then fg:Destroy() end
            fg = Instance.new("BodyGyro")
            fg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
            fg.P = 1e5
            fg.D = 1e3
            fg.CFrame = hrp.CFrame
            fg.Parent = hrp
        end
        floating = true
        FLAGS.floating = true
        hum.PlatformStand = true

        local to = target.Position - hrp.Position
        local dist = to.Magnitude
        if dist < 1.2 then
            fv.Velocity = Vector3.new(0, 0, 0)
        else
            fv.Velocity = to.Unit * math.min(SPEED, math.max(dist * 6, 12))
        end

        if dist < 2.5 then
            arrT = arrT or os.clock()
            if os.clock() - arrT > 0.4 then
                done[target] = true
                target, arrT = nil, nil
            end
        else
            arrT = nil
        end

        if target and dist < 6 and firetouchinterest and os.clock() - lastTouch > 0.15 then
            lastTouch = os.clock()
            pcall(firetouchinterest, hrp, target, 0)
            pcall(firetouchinterest, hrp, target, 1)
        end
    end)

    onUnload(function()
        EV.active = {}
        release()
    end)
end


---------------------------------------------------------------- EVENT : ออโต้รับรางวัล / ซื้อของ / เปิดกล่อง (ผ่านปุ่มใน UI ของเกม)
do
    local tab = Tabs.MEvent
    local AUTO = { claim = false, buy = false, box = false }

    -- กดปุ่มใน UI ของเกมโดยเรียกการเชื่อมต่อของปุ่มตรงๆ (ต้องใช้ตัวรันที่รองรับ getconnections หรือ firesignal)
    local function clickBtn(b)
        local fired = false
        if getconnections then
            for _, sig in ipairs({ b.Activated, b.MouseButton1Click }) do
                pcall(function()
                    for _, c in ipairs(getconnections(sig)) do
                        pcall(function() c:Fire() end)
                        fired = true
                    end
                end)
                if fired then break end
            end
        end
        if not fired and firesignal then
            pcall(function() firesignal(b.Activated) fired = true end)
            if not fired then pcall(function() firesignal(b.MouseButton1Click) fired = true end) end
        end
        return fired
    end

    local function isBtn(o) return o:IsA("TextButton") or o:IsA("ImageButton") end

    local function cross() return playerGui:FindFirstChild("CrossPlatform") end
    local function evRoot()
        local c = cross()
        return c and c:FindFirstChild("Halloween2026")
    end

    -- แถวที่เป็นของแลกด้วย Robux จะไม่กด (กันเด้งหน้าต่างซื้อ)
    local function robuxRow(btn)
        local a = btn.Parent
        for _ = 1, 4 do
            if not a then break end
            local r = a:FindFirstChild("RobuxCost", true) or a:FindFirstChild("RobuxIcon", true)
            if r then return true end
            a = a.Parent
        end
        return false
    end

    local function path(root, ...)
        local o = root
        for _, n in ipairs({ ... }) do
            o = o and o:FindFirstChild(n)
        end
        return o
    end

    -- ออโต้รับรางวัล: เพลงบัตรผ่าน (Battle Pass) + เควสอีเวนท์
    local function claimAll()
        local ev = evRoot()
        if not ev then return end
        local spots = {
            path(ev, "MainEvent", "Main", "BattlePass", "Rewards"),
            path(ev, "MainEvent", "Main", "Quests"),
            path(ev, "MainEvent", "Main", "QuestBoard"),
            path(ev, "Event", "Main", "Rewards"),
        }
        for _, root in pairs(spots) do
            for _, d in ipairs(root:GetDescendants()) do
                if not (AUTO.claim and not MM.dead) then return end
                if isBtn(d) and d.Name == "ActionButton" and d.Visible and not robuxRow(d) then
                    clickBtn(d)
                    task.wait(0.15)
                end
            end
        end
    end

    -- ออโต้ซื้อของอีเวนท์ในร้าน (เฉพาะแถวที่เป็นของอีเวนท์ ไม่เอาแถว Robux)
    local function buyAll()
        local c = cross()
        local shop = c and c:FindFirstChild("Shop")
        if not shop then return end
        for _, d in ipairs(shop:GetDescendants()) do
            if not (AUTO.buy and not MM.dead) then return end
            if isBtn(d) and d.Name == "ActionButton" and d.Visible then
                local row = d.Parent and d.Parent.Parent
                local isEvent = row and (row:GetAttribute("ItemType") == "Event" or row.Name:find("Halloween2026"))
                if isEvent and not robuxRow(d) then
                    clickBtn(d)
                    task.wait(0.4)
                end
            end
        end
    end

    -- ออโต้เปิดกล่องสุ่มอีเวนท์ (ปุ่มจ่ายด้วยเหรียญอีเวนท์)
    local function openBox()
        local ev = evRoot()
        local btn = path(ev, "MainEvent", "Main", "MysteryBox", "BuyFrame", "Currency", "Button")
        if btn and isBtn(btn) then clickBtn(btn) end
    end

    task.spawn(function()
        while not MM.dead do
            task.wait(3)
            if AUTO.claim then pcall(claimAll) end
            if AUTO.buy then pcall(buyAll) end
        end
    end)
    task.spawn(function()
        while not MM.dead do
            task.wait(1.5)
            if AUTO.box then pcall(openBox) end
        end
    end)

    tab:Section({ Title = "mm2_secAuto" })
    tab:Toggle({ Title = "mm2_claim", Value = false, Callback = function(v) AUTO.claim = v end })
    tab:Toggle({ Title = "mm2_buy", Value = false, Callback = function(v) AUTO.buy = v end })
    tab:Toggle({ Title = "mm2_box", Value = false, Callback = function(v) AUTO.box = v end })

    onUnload(function() for k in pairs(AUTO) do AUTO[k] = false end end)

    -- ปุ่มลัดจุดร้านค้าในล็อบบี้ (ใช้พร็อมต์ของเกมโดยตรง)
    local function usePrompt(partName)
        local part = workspace:FindFirstChild(partName, true)
        local pp = part and part:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not pp then toast("Spot not found (go to lobby)", "ไม่พบจุดนี้ (ต้องอยู่ล็อบบี้)") return end
        if fireproximityprompt then
            pcall(function() pp.HoldDuration = 0 end)
            pcall(fireproximityprompt, pp)
        else
            local c = player.Character
            if c and part:IsA("BasePart") then c:PivotTo(part.CFrame * CFrame.new(0, 0, 4)) end
        end
    end

    tab:Section({ Title = "mm2_secSpots" })
    tab:Button({ Title = "mm2_pCraft", Callback = function() usePrompt("CraftingPrompt") end })
    tab:Button({ Title = "mm2_pBox", Callback = function() usePrompt("MysteryBoxPrompt") end })
    tab:Button({ Title = "mm2_pBundle", Callback = function() usePrompt("ItemBundlePrompt") end })
    tab:Button({ Title = "mm2_pKnife", Callback = function() usePrompt("KnifePrompt") end })
    tab:Button({ Title = "mm2_pGun", Callback = function() usePrompt("GunPrompt") end })
end

end) -- pcall MM2
if not okM then warn("[Nexora] MM2 module error: " .. tostring(errM)) end
end

do
    local WINDOW_KEY = Enum.KeyCode.LeftControl
    local windowOpen = true

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if input.KeyCode ~= WINDOW_KEY then
            return
        end
        if UserInputService:GetFocusedTextBox() then
            return
        end
        if pcall(function()
            Window:Toggle()
        end) then
            return
        end
        windowOpen = not windowOpen
        pcall(function()
            if windowOpen then
                Window:Open()
            else
                Window:Close()
            end
        end)
    end)
end
  end)
  if not okB then warn("[Nexora] features error: "..tostring(errB)) end
 end)
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
