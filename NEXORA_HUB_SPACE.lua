-- NEXORA HUB | SPACE EDITION v1.0 (ไฟล์เดียว)
-- GUI อวกาศ: ดาวระยิบ ดาวตก เนบิวลา ขอบเรืองแสง โลโก้เรืองแสง
-- หมวด: หน้าหลัก / ESP (เส้น กรอบ ล็อกหัว Hitbox เช็คทีม) / เครื่องมือ (บิน สปีด กระโดด Noclip TP รถ กันฟลิ้ง รายชื่อผู้เล่น) / แกล้ง (หัวโต หน้าตลก สีรุ้ง ผี เต้น ragdoll เดินช้า ฯลฯ) / ตั้งค่า (มีเข้าเซิร์ฟคนน้อย)

local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local Stats=game:GetService("Stats")
local Lighting=game:GetService("Lighting")
local MPS=game:GetService("MarketplaceService")
local GS=game:GetService("GuiService")
local TP=game:GetService("TeleportService")
local LP=Players.LocalPlayer
local PG=LP:WaitForChild("PlayerGui")
local LOGO="rbxassetid://76604071298329"
local GB,GM=Enum.Font.GothamBold,Enum.Font.GothamMedium
if PG:FindFirstChild("NexoraHub") then PG.NexoraHub:Destroy() end

local TH=(function()
 local d=os.date("*t")
 local m,dy=d.month,d.day
 if (m==10 and dy>=15) or (m==11 and dy<=2) then
  return {name="HALLOWEEN",bg=Color3.fromRGB(14,6,4),acc=Color3.fromRGB(255,110,20),acc2=Color3.fromRGB(150,255,60),cy=Color3.fromRGB(255,170,60)}
 elseif m==12 and dy>=10 then
  return {name="XMAS",bg=Color3.fromRGB(6,16,10),acc=Color3.fromRGB(220,40,50),acc2=Color3.fromRGB(255,215,120),cy=Color3.fromRGB(90,230,140)}
 elseif m==1 and dy<=3 then
  return {name="NEW YEAR",bg=Color3.fromRGB(10,8,4),acc=Color3.fromRGB(255,200,60),acc2=Color3.fromRGB(255,240,180),cy=Color3.fromRGB(120,200,255)}
 elseif m==2 and dy>=10 and dy<=14 then
  return {name="VALENTINE",bg=Color3.fromRGB(20,6,14),acc=Color3.fromRGB(255,80,150),acc2=Color3.fromRGB(255,190,220),cy=Color3.fromRGB(255,140,190)}
 elseif m==4 and dy>=12 and dy<=16 then
  return {name="SONGKRAN",bg=Color3.fromRGB(4,14,26),acc=Color3.fromRGB(40,170,255),acc2=Color3.fromRGB(170,235,255),cy=Color3.fromRGB(120,255,230)}
 end
 return {name="NEXORA",bg=Color3.fromRGB(10,6,8),acc=Color3.fromRGB(214,36,52),acc2=Color3.fromRGB(255,110,120),cy=Color3.fromRGB(255,96,110)}
end)()
local C={bg=TH.bg,panel=Color3.fromRGB(28,12,15),side=Color3.fromRGB(16,8,10),acc=TH.acc,acc2=TH.acc2,cy=TH.cy,txt=Color3.fromRGB(255,246,246),dim=Color3.fromRGB(200,170,175),off=Color3.fromRGB(52,26,30)}
local WHITE=Color3.new(1,1,1)

-- ===== ตัวช่วยพื้นฐาน =====
local Lang,reg="th",{}
local function tr(o,th,en) reg[#reg+1]={o,th,en} o.Text=(Lang=="th") and th or en end
local function setLang(l) Lang=l for _,r in ipairs(reg) do r[1].Text=(l=="th") and r[2] or r[3] end end
local function new(c,p,par) local o=Instance.new(c) for k,v in pairs(p) do o[k]=v end o.Parent=par return o end
local function round(o,r) new("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function circle(o) new("UICorner",{CornerRadius=UDim.new(0.5,0)},o) end
local function stroke(o,c,t) return new("UIStroke",{Color=c or C.acc,Thickness=t or 1.5},o) end
local function grad(par,c1,c2,rot) return new("UIGradient",{Color=ColorSequence.new(c1,c2),Rotation=rot or 0},par) end

local conns={}
local function bind(sig,fn) local c=sig:Connect(fn) conns[#conns+1]=c return c end
local spinG={}
local function spin(g,s) spinG[#spinG+1]={g,s} end
local FX=true

local function Drag(h,t,onClick)
 local d,s,sp,moved
 h.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   d=true s=i.Position sp=t.Position moved=false
   i.Changed:Connect(function()
    if i.UserInputState==Enum.UserInputState.End then d=false if onClick and not moved then onClick() end end
   end)
  end
 end)
 bind(UIS.InputChanged,function(i)
  if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
   local dl=i.Position-s
   if dl.Magnitude>6 then moved=true end
   t.Position=UDim2.new(sp.X.Scale,sp.X.Offset+dl.X,sp.Y.Scale,sp.Y.Offset+dl.Y)
  end
 end)
end

-- ===== หน้าต่างหลัก =====
local SG=new("ScreenGui",{Name="NexoraHub",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PG)
local Main=new("Frame",{Size=UDim2.new(0.74,0,0.82,0),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=C.bg,ClipsDescendants=true},SG)
round(Main,14)
new("UISizeConstraint",{MaxSize=Vector2.new(600,400),MinSize=Vector2.new(400,290)},Main)
local MScale=new("UIScale",{Scale=1},Main)
local baseScale=1
local MStroke=stroke(Main,Color3.fromRGB(214,36,52),2.5)
local MGrad=new("UIGradient",{Color=ColorSequence.new{
 ColorSequenceKeypoint.new(0,C.acc),ColorSequenceKeypoint.new(0.35,C.cy),
 ColorSequenceKeypoint.new(0.7,Color3.fromRGB(70,20,150)),ColorSequenceKeypoint.new(1,C.acc2)}},MStroke)
spin(MGrad,2)

-- ===== พื้นหลังอวกาศ =====
local Space=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=WHITE,ClipsDescendants=true,ZIndex=0},Main)
round(Space,14)
new("UIGradient",{Color=ColorSequence.new{
 ColorSequenceKeypoint.new(0,Color3.fromRGB(6,4,18)),ColorSequenceKeypoint.new(0.6,Color3.fromRGB(24,10,56)),
 ColorSequenceKeypoint.new(1,Color3.fromRGB(10,24,58))},Rotation=90},Space)
local Stars=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},Space)
local n1=new("Frame",{Size=UDim2.new(0,300,0,300),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=C.acc,BackgroundTransparency=0.84,BorderSizePixel=0},Stars) circle(n1)
local n2=new("Frame",{Size=UDim2.new(0,240,0,240),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=C.cy,BackgroundTransparency=0.9,BorderSizePixel=0},Stars) circle(n2)
local stars={}
local starCols={WHITE,Color3.fromRGB(200,170,255),C.cy}
for i=1,55 do
 local sz=math.random(1,3)
 local f=new("Frame",{Size=UDim2.new(0,sz,0,sz),BackgroundColor3=starCols[math.random(1,3)],BorderSizePixel=0},Stars)
 stars[i]={f=f,x=math.random(),y=math.random(),sp=math.random(10,50)/1000,tw=math.random(10,30)/10,ph=math.random()*6}
 f.Position=UDim2.new(stars[i].x,0,stars[i].y,0)
end
local t0=0
bind(RS.RenderStepped,function(dt)
 if not FX then return end
 t0+=dt
 for _,s in ipairs(spinG) do s[1].Rotation=(s[1].Rotation+s[2]*dt*60)%360 end
 if not Main.Visible then return end
 for _,s in ipairs(stars) do
  local x=s.x-s.sp*dt
  if x<0 then x=1 s.y=math.random() end
  s.x=x
  s.f.Position=UDim2.new(x,0,s.y,0)
  s.f.BackgroundTransparency=0.15+0.7*math.abs(math.sin(t0*s.tw+s.ph))
 end
 n1.Position=UDim2.new(0.25+0.08*math.sin(t0*0.25),0,0.35+0.1*math.cos(t0*0.2),0)
 n2.Position=UDim2.new(0.8+0.07*math.cos(t0*0.22),0,0.7+0.1*math.sin(t0*0.3),0)
 n1.BackgroundTransparency=0.8+0.06*math.sin(t0)
end)
task.spawn(function()
 while SG.Parent do
  task.wait(math.random(25,60)/10)
  if FX and Main.Visible then
   local sx=math.random(40,100)/100
   local s=new("Frame",{Size=UDim2.new(0,90,0,2),Position=UDim2.new(sx,0,0,math.random(0,60)),BackgroundColor3=WHITE,BorderSizePixel=0,Rotation=-28},Stars)
   new("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}},s)
   TS:Create(s,TweenInfo.new(0.9,Enum.EasingStyle.Quad),{Position=UDim2.new(sx-0.5,0,0.9,0)}):Play()
   task.delay(0.95,function() s:Destroy() end)
  end
 end
end)

-- ===== แถบชื่อ =====
local Title=new("Frame",{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1},Main)
local tl=new("TextLabel",{Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text="NEXORA HUB  ·  "..TH.name,TextColor3=WHITE,Font=GB,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left},Title)
local tg=grad(tl,C.cy,C.acc2) spin(tg,1.5)
local Close=new("TextButton",{Size=UDim2.new(0,28,0,24),Position=UDim2.new(1,-38,0,7),BackgroundColor3=C.off,Text="X",TextColor3=C.txt,Font=GB,TextSize=13},Title)
round(Close,6)
Drag(Title,Main)

local Side=new("Frame",{Size=UDim2.new(0,132,1,-48),Position=UDim2.new(0,6,0,42),BackgroundColor3=C.side,BackgroundTransparency=0.35},Main)
round(Side,10) new("UIListLayout",{Padding=UDim.new(0,6)},Side)
new("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)},Side)
local Content=new("Frame",{Size=UDim2.new(1,-150,1,-48),Position=UDim2.new(0,144,0,42),BackgroundColor3=C.side,BackgroundTransparency=0.4,ClipsDescendants=true},Main)
round(Content,10)

-- ===== เปิด/ปิด GUI (มีแอนิเมชัน) =====
local shown=true
local function Show(v)
 shown=v
 if v then
  Main.Visible=true Main.Position=UDim2.new(0.5,0,0.5,0) MScale.Scale=baseScale*0.7
  TS:Create(MScale,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=baseScale}):Play()
 else
  TS:Create(MScale,TweenInfo.new(.2),{Scale=baseScale*0.7}):Play()
  task.delay(0.2,function() if not shown then Main.Visible=false end end)
 end
end
Close.MouseButton1Click:Connect(function() Show(false) end)

-- ===== โลโก้เปิด/ปิด (เรืองแสง + วงคลื่น) =====
local LH=new("Frame",{Size=UDim2.new(0,56,0,56),Position=UDim2.new(0,14,0.5,-28),BackgroundTransparency=1},SG)
local function ring(delay)
 local r=new("Frame",{Size=UDim2.new(0,56,0,56),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1},LH)
 circle(r)
 local s=stroke(r,C.cy,2)
 task.spawn(function()
  task.wait(delay)
  while SG.Parent do
   r.Visible=FX
   r.Size=UDim2.new(0,56,0,56) s.Transparency=0.2
   TS:Create(r,TweenInfo.new(1.6,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,92,0,92)}):Play()
   TS:Create(s,TweenInfo.new(1.6),{Transparency=1}):Play()
   task.wait(1.6)
  end
 end)
end
ring(0) ring(0.8)
local Logo=new("ImageButton",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.bg,Image=LOGO},LH)
circle(Logo)
local ls=stroke(Logo,WHITE,2.5)
spin(grad(ls,C.acc,C.cy),3)
Drag(Logo,LH,function() Show(not shown) end)

-- ===== แท็บ =====
local tabs={{"home","หน้าหลัก","Home"},{"esp","ESP","ESP"},{"tools","เครื่องมือ","Tools"},{"troll","แกล้ง","Troll"},{"set","ตั้งค่า","Settings"}}
local pages,btns,bars={},{},{}
local function Pick(id)
 for k,p in pairs(pages) do
  if k==id then
   p.Position=UDim2.new(0,24,0,0) p.Visible=true
   TS:Create(p,TweenInfo.new(.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)}):Play()
  else p.Visible=false end
 end
 for k,b in pairs(btns) do
  local on=(k==id)
  TS:Create(b,TweenInfo.new(.2),{BackgroundColor3=on and C.acc or C.panel,BackgroundTransparency=on and 0.1 or 0.35}):Play()
  TS:Create(bars[k],TweenInfo.new(.2),{BackgroundTransparency=on and 0 or 1}):Play()
 end
end
for _,t in ipairs(tabs) do
 local b=new("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.panel,BackgroundTransparency=0.35,TextColor3=C.txt,Font=GB,TextSize=14},Side)
 round(b,8) tr(b,t[2],t[3]) btns[t[1]]=b
 local bar=new("Frame",{Size=UDim2.new(0,3,0.6,0),Position=UDim2.new(0,0,0.2,0),BackgroundColor3=C.cy,BackgroundTransparency=1,BorderSizePixel=0},b)
 circle(bar) bars[t[1]]=bar
 local p=new("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.cy,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},Content)
 new("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},p)
 new("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,10),PaddingBottom=UDim.new(0,8)},p)
 pages[t[1]]=p
 b.MouseButton1Click:Connect(function() Pick(t[1]) end)
end

-- ===== ตัวสร้างปุ่ม/สวิตช์/สไลเดอร์ =====
local function Header(p,th,en)
 local f=new("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1},p)
 local l=new("TextLabel",{Size=UDim2.new(1,0,1,-2),BackgroundTransparency=1,TextColor3=C.cy,Font=GB,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left},f)
 tr(l,th,en)
 new("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.acc,BackgroundTransparency=0.4,BorderSizePixel=0},f)
end
local function Empty(p)
 local l=new("TextLabel",{Size=UDim2.new(1,0,0,150),BackgroundTransparency=1,TextColor3=C.dim,Font=GB,TextSize=15,TextWrapped=true},p)
 tr(l,"หมวดนี้ยังว่างอยู่\nเร็ว ๆ นี้","This category is empty\nComing soon")
end
local function Button(p,th,en,cb)
 local b=new("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=WHITE,TextColor3=C.txt,Font=GB,TextSize=14,AutoButtonColor=false},p)
 round(b,8)
 grad(b,Color3.fromRGB(150,22,34),Color3.fromRGB(64,10,16),90)
 local bs=stroke(b,C.cy,1) bs.Transparency=0.5
 tr(b,th,en)
 b.MouseEnter:Connect(function() TS:Create(bs,TweenInfo.new(.15),{Transparency=0}):Play() end)
 b.MouseLeave:Connect(function() TS:Create(bs,TweenInfo.new(.15),{Transparency=0.5}):Play() end)
 b.MouseButton1Down:Connect(function() TS:Create(b,TweenInfo.new(.08),{Size=UDim2.new(1,-4,0,36)}):Play() end)
 b.MouseButton1Up:Connect(function() TS:Create(b,TweenInfo.new(.12,Enum.EasingStyle.Back),{Size=UDim2.new(1,0,0,38)}):Play() end)
 b.MouseButton1Click:Connect(cb) return b
end
local function Toggle(p,th,en,df,cb,dth,den)
 local r=new("Frame",{Size=UDim2.new(1,0,0,dth and 56 or 40),BackgroundColor3=C.panel,BackgroundTransparency=0.2},p) round(r) stroke(r,C.acc,1).Transparency=0.6
 local l=new("TextLabel",{Size=UDim2.new(1,-76,0,20),Position=UDim2.new(0,12,0,dth and 6 or 10),BackgroundTransparency=1,TextColor3=C.txt,Font=GB,TextSize=15,TextStrokeTransparency=0.6,TextXAlignment=Enum.TextXAlignment.Left},r)
 tr(l,th,en)
 if dth then
  local d=new("TextLabel",{Size=UDim2.new(1,-76,0,26),Position=UDim2.new(0,12,0,26),BackgroundTransparency=1,TextColor3=C.dim,Font=GM,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},r)
  tr(d,dth,den)
 end
 local sw=new("TextButton",{Size=UDim2.new(0,46,0,24),Position=UDim2.new(1,-58,0.5,-12),BackgroundColor3=C.off,Text="",AutoButtonColor=false},r) circle(sw)
 local gs=stroke(sw,C.cy,1.5) gs.Transparency=1
 local kn=new("Frame",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=C.txt},sw) circle(kn)
 local on=false
 local function set(v)
  on=v
  TS:Create(sw,TweenInfo.new(.15),{BackgroundColor3=v and C.acc or C.off}):Play()
  TS:Create(kn,TweenInfo.new(.15),{Position=v and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play()
  TS:Create(gs,TweenInfo.new(.15),{Transparency=v and 0 or 1}):Play()
  cb(v)
 end
 sw.MouseButton1Click:Connect(function() set(not on) end)
 if df then set(true) end
 return set
end
local function Slider(p,th,en,mn,mx,df,cb)
 local r=new("Frame",{Size=UDim2.new(1,0,0,54),BackgroundColor3=C.panel,BackgroundTransparency=0.2},p) round(r)
 local l=new("TextLabel",{Size=UDim2.new(1,-76,0,22),Position=UDim2.new(0,12,0,4),BackgroundTransparency=1,TextColor3=C.txt,Font=GB,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},r)
 tr(l,th,en)
 local v=new("TextLabel",{Size=UDim2.new(0,56,0,22),Position=UDim2.new(1,-64,0,4),BackgroundTransparency=1,Text=tostring(df),TextColor3=C.cy,Font=GB,TextSize=14},r)
 local bar=new("Frame",{Size=UDim2.new(1,-24,0,8),Position=UDim2.new(0,12,0,38),BackgroundColor3=C.off},r) circle(bar)
 local fill=new("Frame",{Size=UDim2.new((df-mn)/(mx-mn),0,1,0),BackgroundColor3=C.acc},bar) circle(fill)
 local drag=false
 local function upd(x)
  local a=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
  local val=math.floor(mn+(mx-mn)*a+0.5)
  fill.Size=UDim2.new(a,0,1,0) v.Text=tostring(val) cb(val)
 end
 bar.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true upd(i.Position.X) end
 end)
 bind(UIS.InputChanged,function(i)
  if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end
 end)
 bind(UIS.InputEnded,function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
 end)
 cb(df)
 return r
end

-- ===== หน้าหลัก =====
local H=pages.home
local N=30
local function fpsColor(f)
 if f>=55 then return Color3.fromRGB(80,255,160) end
 if f>=30 then return Color3.fromRGB(255,210,90) end
 return Color3.fromRGB(255,95,120)
end

-- โปรไฟล์ + เลือด
local hero=new("Frame",{Size=UDim2.new(1,0,0,96),BackgroundColor3=C.panel,BackgroundTransparency=0.2,BorderSizePixel=0},H)
round(hero,14) stroke(hero,C.acc,1).Transparency=0.4
local avBg=new("Frame",{Size=UDim2.new(0,68,0,68),Position=UDim2.new(0,12,0.5,-34),BackgroundColor3=C.bg,BorderSizePixel=0},hero) circle(avBg)
local av=new("ImageLabel",{Size=UDim2.new(1,-6,1,-6),Position=UDim2.new(0,3,0,3),BackgroundColor3=C.bg,BorderSizePixel=0},avBg) circle(av)
spin(grad(stroke(avBg,WHITE,2),C.cy,C.acc),4)
task.spawn(function()
 local ok,img=pcall(function() return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.AvatarBust,Enum.ThumbnailSize.Size420x420) end)
 if ok then av.Image=img end
end)
local nameL=new("TextLabel",{Size=UDim2.new(1,-100,0,22),Position=UDim2.new(0,92,0,14),BackgroundTransparency=1,TextColor3=C.txt,Font=GB,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Text=LP.DisplayName.." (@"..LP.Name..")"},hero)
local tagL=new("TextLabel",{Size=UDim2.new(1,-100,0,16),Position=UDim2.new(0,92,0,36),BackgroundTransparency=1,TextColor3=C.cy,Font=GB,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},hero)
tagL.Text=(TH.name=="NEXORA") and "NEXORA HUB" or ("EVENT · "..TH.name)
local hpBg=new("Frame",{Size=UDim2.new(1,-104,0,8),Position=UDim2.new(0,92,0,60),BackgroundColor3=C.off,BorderSizePixel=0},hero) circle(hpBg)
local hpFill=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=WHITE,BorderSizePixel=0},hpBg) circle(hpFill)
grad(hpFill,Color3.fromRGB(80,255,160),C.cy)
local hpL=new("TextLabel",{Size=UDim2.new(1,-104,0,16),Position=UDim2.new(0,92,0,72),BackgroundTransparency=1,TextColor3=C.dim,Font=GM,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},hero)

-- แถบสถิติ 4 ช่อง
local row=new("Frame",{Size=UDim2.new(1,0,0,62),BackgroundTransparency=1,BorderSizePixel=0},H)
local function statTile(i)
 local f=new("Frame",{Position=UDim2.new(i*0.25,3,0,0),Size=UDim2.new(0.25,-6,1,0),BackgroundColor3=C.panel,BackgroundTransparency=0.25,BorderSizePixel=0},row)
 round(f,12) stroke(f,C.acc,1).Transparency=0.6
 local k=new("TextLabel",{Size=UDim2.new(1,-10,0,14),Position=UDim2.new(0,8,0,6),BackgroundTransparency=1,TextColor3=C.dim,Font=GM,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},f)
 local v=new("TextLabel",{Size=UDim2.new(1,-10,0,26),Position=UDim2.new(0,8,0,22),BackgroundTransparency=1,TextColor3=C.txt,Font=GB,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},f)
 return k,v
end
local k1,fpsL=statTile(0)
local k2,pingL=statTile(1)
local k3,plrL=statTile(2)
local k4,clkL=statTile(3)
tr(k1,"FPS","FPS") tr(k2,"ปิง","PING") tr(k3,"ผู้เล่น","PLAYERS") tr(k4,"เวลา","TIME")

-- กราฟ FPS สด
local gph=new("Frame",{Size=UDim2.new(1,0,0,74),BackgroundColor3=C.panel,BackgroundTransparency=0.25,BorderSizePixel=0},H)
round(gph,12) stroke(gph,C.acc,1).Transparency=0.6
local gt=new("TextLabel",{Size=UDim2.new(1,-16,0,16),Position=UDim2.new(0,10,0,5),BackgroundTransparency=1,TextColor3=C.cy,Font=GB,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},gph)
tr(gt,"กราฟ FPS (สด)","FPS GRAPH (live)")
local gArea=new("Frame",{Size=UDim2.new(1,-20,1,-30),Position=UDim2.new(0,10,0,24),BackgroundTransparency=1,BorderSizePixel=0},gph)
local bars,hist={},{}
for i=1,N do
 hist[i]=0
 local b=new("Frame",{Size=UDim2.new(1/N,-2,0.02,0),Position=UDim2.new((i-1)/N,1,1,0),AnchorPoint=Vector2.new(0,1),BackgroundColor3=C.acc,BorderSizePixel=0},gArea)
 round(b,2)
 bars[i]=b
end

-- การ์ดแมพ
local mc=new("Frame",{Size=UDim2.new(1,0,0,80),BackgroundColor3=C.panel,BackgroundTransparency=0.25,BorderSizePixel=0},H)
round(mc,12) stroke(mc,C.acc,1).Transparency=0.6
local mi=new("ImageLabel",{Size=UDim2.new(0,60,0,60),Position=UDim2.new(0,10,0.5,-30),BackgroundColor3=C.bg,BorderSizePixel=0,Image="rbxthumb://type=GameIcon&id="..game.GameId.."&w=150&h=150"},mc)
round(mi,10) stroke(mi,C.acc,1.5)
local mapTag=new("TextLabel",{Size=UDim2.new(1,-92,0,14),Position=UDim2.new(0,82,0,10),BackgroundTransparency=1,TextColor3=C.cy,Font=GB,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},mc)
tr(mapTag,"แมพที่เล่นอยู่","Current Map")
local mapName=new("TextLabel",{Size=UDim2.new(1,-92,0,20),Position=UDim2.new(0,82,0,28),BackgroundTransparency=1,Text=game.Name,TextColor3=C.txt,Font=GB,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},mc)
new("TextLabel",{Size=UDim2.new(1,-92,0,14),Position=UDim2.new(0,82,0,52),BackgroundTransparency=1,Text="ID: "..game.PlaceId,TextColor3=C.dim,Font=GM,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},mc)
task.spawn(function()
 local ok,i=pcall(function() return MPS:GetProductInfo(game.PlaceId) end)
 if ok and i and i.Name then mapName.Text=i.Name end
end)

-- อัปเดตค่าทุก 0.5 วินาที (เบาเครื่อง)
local fr,ac=0,0
bind(RS.RenderStepped,function(dt)
 fr+=1 ac+=dt
 if ac>=0.5 then
  local fps=math.floor(fr/ac) fr,ac=0,0
  local ok,pg=pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
  local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid")
  local hp,mh=h and math.floor(h.Health) or 0,h and math.floor(h.MaxHealth) or 100
  hpFill.Size=UDim2.new(math.clamp(hp/math.max(mh,1),0,1),0,1,0)
  hpL.Text=(Lang=="th" and "เลือด " or "HP ")..hp.." / "..mh
  fpsL.Text=tostring(fps)
  fpsL.TextColor3=fpsColor(fps)
  pingL.Text=(ok and tostring(pg) or "-").." ms"
  plrL.Text=tostring(#Players:GetPlayers())
  clkL.Text=os.date("%H:%M:%S")
  for i=1,N-1 do hist[i]=hist[i+1] end
  hist[N]=math.clamp(fps,0,144)
  for i=1,N do
   bars[i].Size=UDim2.new(1/N,-2,math.max(hist[i]/144,0.02),0)
   bars[i].BackgroundColor3=fpsColor(hist[i])
  end
 end
end)

-- ภาษา
local lc=new("Frame",{Size=UDim2.new(1,0,0,70),BackgroundColor3=C.panel,BackgroundTransparency=0.25,BorderSizePixel=0},H)
round(lc,12) stroke(lc,C.acc,1).Transparency=0.6
new("TextLabel",{Size=UDim2.new(1,-20,0,20),Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,Text="ภาษา / Language",TextColor3=C.txt,Font=GB,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left},lc)
local function langBtn(txt,x,code)
 local b=new("TextButton",{Size=UDim2.new(0.5,-16,0,30),Position=UDim2.new(x,x==0 and 10 or 6,0,32),BackgroundColor3=WHITE,Text=txt,TextColor3=WHITE,TextStrokeTransparency=0.35,TextStrokeColor3=Color3.new(0,0,0),Font=GB,TextSize=14,AutoButtonColor=false},lc)
 round(b,8) grad(b,Color3.fromRGB(150,22,34),Color3.fromRGB(64,10,16),90)
 b.MouseButton1Click:Connect(function() setLang(code) end)
end
langBtn("English",0,"en") langBtn("ไทย",0.5,"th")

-- ===== ESP / ล็อกหัว / Hitbox =====
local E=pages.esp
if PG:FindFirstChild("NexoraTracers") then PG.NexoraTracers:Destroy() end
local TG=new("ScreenGui",{Name="NexoraTracers",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=5},PG)
local ESP={on=false,fill=true,box=true,line=true,name=true,dist=true,hp=true,team=true,lock=false,hb=false,hbSize=12}
local obj,hbo={},{}

-- เช็คทีมสดทุกครั้ง: ถ้ามีคนเข้าทีมเพิ่ม/เปลี่ยนทีม จะรู้ทันที
local function isTeam(p)
 if not ESP.team then return false end
 if LP.Neutral or not LP.Team then return false end
 return p.Team==LP.Team
end

local function clr(p)
 local o=obj[p]
 if o then pcall(function() o.hl:Destroy() o.bx:Destroy() o.bb:Destroy() o.ln:Destroy() end) obj[p]=nil end
end
local function mk(p)
 local ch=p.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return end
 local hl=new("Highlight",{FillColor=C.acc,OutlineColor=C.cy,FillTransparency=0.6,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},ch)
 local bx=new("SelectionBox",{Adornee=ch,Color3=C.acc,SurfaceTransparency=1,LineThickness=0.05},ch)
 local bb=new("BillboardGui",{Size=UDim2.new(0,170,0,52),StudsOffset=Vector3.new(0,3.6,0),AlwaysOnTop=true,Adornee=hrp},ch)
 local t=new("TextLabel",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,TextColor3=C.txt,TextStrokeTransparency=0.3,Font=GB,TextSize=13},bb)
 local hbg=new("Frame",{Size=UDim2.new(0.6,0,0,6),Position=UDim2.new(0.2,0,0,38),BackgroundColor3=C.off,BorderSizePixel=0},bb) circle(hbg)
 local hf=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(80,255,160),BorderSizePixel=0},hbg) circle(hf)
 local ln=new("Frame",{AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=C.acc,BorderSizePixel=0,Size=UDim2.new(0,0,0,2),Visible=false},TG)
 obj[p]={hl=hl,bx=bx,bb=bb,t=t,hbg=hbg,hf=hf,ln=ln,ch=ch}
end

-- Hitbox: ขยาย HumanoidRootPart (สีอ่อน โปร่งใส)
local function hbRestore(p)
 local o=hbo[p]
 if o then pcall(function() o.part.Size=o.size o.part.Transparency=o.tr o.part.Color=o.col o.part.CanCollide=o.cc end) hbo[p]=nil end
end
local function hitbox(p,team)
 local ch=p.Character local r=ch and ch:FindFirstChild("HumanoidRootPart")
 if not ESP.hb or team or not r then hbRestore(p) return end
 local o=hbo[p]
 if o and o.part~=r then hbo[p]=nil o=nil end
 if not o then hbo[p]={part=r,size=r.Size,tr=r.Transparency,col=r.Color,cc=r.CanCollide} end
 local s=ESP.hbSize
 r.Size=Vector3.new(s,s,s) r.Transparency=0.85 r.Color=C.acc2 r.CanCollide=false
end

-- ลูปช้า: สร้าง/อัปเดต ESP + Hitbox
task.spawn(function()
 while SG.Parent do
  task.wait(0.25)
  for _,p in ipairs(Players:GetPlayers()) do
   if p~=LP then
    local team=isTeam(p)
    if not ESP.on then clr(p)
    else
     local o=obj[p]
     if o and o.ch~=p.Character then clr(p) o=nil end
     if not o then mk(p) o=obj[p] end
     if o then
      local col=team and C.cy or C.acc
      o.hl.Enabled=ESP.fill o.hl.FillColor=col
      o.bx.Enabled=ESP.box o.bx.Color3=col
      o.ln.BackgroundColor3=col
      local h=o.ch:FindFirstChildOfClass("Humanoid")
      local r=o.ch:FindFirstChild("HumanoidRootPart")
      local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
      local s=""
      if ESP.name then s=p.DisplayName end
      if ESP.dist and r and mr then s=s..(s~="" and "  " or "").."["..math.floor((r.Position-mr.Position).Magnitude).."m]" end
      if ESP.hp and h then s=s..(s~="" and "\n" or "").."HP "..math.floor(h.Health) end
      o.t.Text=s
      o.hbg.Visible=(ESP.hp and h~=nil)
      if h then o.hf.Size=UDim2.new(math.clamp(h.Health/math.max(h.MaxHealth,1),0,1),0,1,0) end
     end
    end
    hitbox(p,team)
   end
  end
 end
end)
Players.PlayerRemoving:Connect(function(p) clr(p) hbRestore(p) end)

-- ลูปเร็ว: เส้นลากไปหัว + ล็อกหัวคนใกล้สุด
bind(RS.RenderStepped,function()
 local c=workspace.CurrentCamera
 if not c then return end
 for _,o in pairs(obj) do
  local head=o.ch and o.ch:FindFirstChild("Head")
  local ok=false
  if ESP.on and ESP.line and head then
   local v,on=c:WorldToViewportPoint(head.Position)
   if on then
    local A=Vector2.new(c.ViewportSize.X/2,0)
    local B=Vector2.new(v.X,v.Y)
    local d=B-A
    local m=(A+B)/2
    o.ln.Size=UDim2.new(0,d.Magnitude,0,2)
    o.ln.Position=UDim2.fromOffset(m.X,m.Y)
    o.ln.Rotation=math.deg(math.atan2(d.Y,d.X))
    ok=true
   end
  end
  o.ln.Visible=ok
 end
 if ESP.lock then
  local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
  if mr then
   local best,bd
   for _,p in ipairs(Players:GetPlayers()) do
    if p~=LP and not isTeam(p) then
     local ch=p.Character
     local h=ch and ch:FindFirstChild("Head")
     local hm=ch and ch:FindFirstChildOfClass("Humanoid")
     if h and hm and hm.Health>0 then
      local d=(h.Position-mr.Position).Magnitude
      if not bd or d<bd then best,bd=h,d end
     end
    end
   end
   if best then c.CFrame=CFrame.new(c.CFrame.Position,best.Position) end
  end
 end
end)

-- การ์ดข้อมูลทีม (อัปเดตสด)
Header(E,"ข้อมูลทีม","Team Info")
local tinfo=new("TextLabel",{Size=UDim2.new(1,0,0,78),BackgroundColor3=C.panel,BackgroundTransparency=0.2,TextColor3=C.txt,Font=GM,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},E)
round(tinfo)
new("UIPadding",{PaddingTop=UDim.new(0,6),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,8)},tinfo)
task.spawn(function()
 while SG.Parent do
  local th=Lang=="th"
  local tm=LP.Team
  local has=tm and not LP.Neutral
  local names,n={},0
  if has then
   for _,p in ipairs(Players:GetPlayers()) do
    if p~=LP and p.Team==tm then n+=1 if n<=6 then names[#names+1]=p.DisplayName end end
   end
  end
  local list=n>0 and (table.concat(names,", ")..(n>6 and " ..." or "")) or "-"
  tinfo.Text=(th and "แมพ: " or "Map: ")..mapName.Text.."\n"
   ..(th and "ทีมของเรา: " or "My team: ")..(has and tm.Name or (th and "ไม่มีทีม" or "No team")).."\n"
   ..(th and "เพื่อนร่วมทีม " or "Teammates ")..n..": "..list
  task.wait(0.5)
 end
end)

Header(E,"มองเห็นผู้เล่น (ESP)","Player ESP")
Toggle(E,"เปิด ESP","ESP On",false,function(v) ESP.on=v end,"เปิดแล้วเลือกแบบที่ต้องการด้านล่าง","Turn on, then pick the styles below")
Toggle(E,"เส้นลากไปหาผู้เล่น","Tracer Lines",true,function(v) ESP.line=v end,"เส้นสีม่วงจากกลางบนจอไปที่หัวผู้เล่น","Purple line from top-center of the screen to each head")
Toggle(E,"กรอบสีม่วง","Purple Box",true,function(v) ESP.box=v end,"กรอบรอบตัวผู้เล่น ไม่รวมตัวเรา","Box around every other player")
Toggle(E,"ไฮไลต์ตัวผู้เล่น","Highlight Players",true,function(v) ESP.fill=v end)
Toggle(E,"แสดงชื่อ","Show Name",true,function(v) ESP.name=v end)
Toggle(E,"แสดงระยะ","Show Distance",true,function(v) ESP.dist=v end)
Toggle(E,"แสดงเลือด","Show Health",true,function(v) ESP.hp=v end,"ตัวเลขและแถบเลือดเหนือหัว","Number and bar above the head")

Header(E,"ล็อกเป้า","Aim")
Toggle(E,"ล็อกหัว","Head Lock",false,function(v) ESP.lock=v end,"กล้องล็อกไปที่หัวของคนที่อยู่ใกล้ที่สุด","Camera locks on the head of the nearest player")
Toggle(E,"ไม่ล็อกทีมตัวเอง","Skip My Team",true,function(v) ESP.team=v end,"เช็คทีมสดตลอด มีคนเข้าทีมเพิ่มก็จะไม่ล็อกให้ (ใช้กับ Hitbox ด้วย)","Re-checks teams live, new teammates are skipped (also used by Hitbox)")

Header(E,"Hitbox","Hitbox")
local hbRow
Toggle(E,"ขยาย Hitbox","Expand Hitbox",false,function(v) ESP.hb=v if hbRow then hbRow.Visible=v end end,"เปิดแล้วจะมีแถบให้ลากปรับขนาด ยิ่งใหญ่ยิ่งโดนง่าย","A size slider appears. Bigger means easier to hit")
hbRow=Slider(E,"ขนาด Hitbox","Hitbox Size",2,60,12,function(v) ESP.hbSize=v end)
hbRow.Visible=false

-- ===== เครื่องมือ =====
local T=pages.tools
local S={fly=false,flyspd=80,speed=false,spd=50,jump=false,jp=100,inf=false,noclip=false,tp=false,car=false,carspd=100,anti=false}
local function hum() local c=LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function root() local c=LP.Character return c and c:FindFirstChild("HumanoidRootPart") end

-- สวิตช์ + แถบสไลเดอร์ที่โผล่เมื่อเปิด
local function ToggleSlider(p,th,en,dth,den,sth,sen,mn,mx,df,onT,onS)
 local row
 Toggle(p,th,en,false,function(v) if row then row.Visible=v end onT(v) end,dth,den)
 row=Slider(p,sth,sen,mn,mx,df,onS)
 row.Visible=false
end

Header(T,"การเคลื่อนที่","Movement")
-- บิน
ToggleSlider(T,"บิน","Fly","บังคับด้วยจอยสติ๊ก/WASD เงยกล้องขึ้นลงเพื่อขึ้น-ลง (PC: Space ขึ้น, Ctrl ลง)","Move with joystick/WASD, tilt the camera to go up/down (PC: Space up, Ctrl down)",
 "ความเร็วบิน","Fly Speed",10,1000,80,function(v) S.fly=v end,function(v) S.flyspd=v end)
local bv,bg
bind(RS.RenderStepped,function()
 local r,h=root(),hum()
 if not S.fly or not r or not h then
  if bv or bg then
   if bv then bv:Destroy() bv=nil end
   if bg then bg:Destroy() bg=nil end
   if h then h.PlatformStand=false end
  end
  return
 end
 if bv and bv.Parent~=r then bv,bg=nil,nil end
 if not bv then
  bv=new("BodyVelocity",{MaxForce=Vector3.new(1e9,1e9,1e9),Velocity=Vector3.zero},r)
  bg=new("BodyGyro",{MaxTorque=Vector3.new(1e9,1e9,1e9),P=9e4},r)
 end
 h.PlatformStand=true
 local cam=workspace.CurrentCamera
 local lv=cam.CFrame.LookVector
 local flat=Vector3.new(lv.X,0,lv.Z)
 if flat.Magnitude>0 then bg.CFrame=CFrame.lookAt(r.Position,r.Position+flat) end
 local mv=h.MoveDirection
 local v=Vector3.zero
 if mv.Magnitude>0 and flat.Magnitude>0 then
  v=mv*S.flyspd+Vector3.new(0,lv.Y*mv:Dot(flat.Unit)*S.flyspd,0)
 end
 local up=0
 if UIS:IsKeyDown(Enum.KeyCode.Space) then up+=1 end
 if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then up-=1 end
 bv.Velocity=v+Vector3.new(0,up*S.flyspd,0)
end)

-- ปรับสปีดวิ่ง
ToggleSlider(T,"ปรับสปีดวิ่ง","Walk Speed","เปิดแล้วลากแถบเพื่อกำหนดความเร็ววิ่ง","Turn on, then drag the bar to set run speed",
 "ความเร็ววิ่ง","Speed",16,500,50,function(v) S.speed=v local h=hum() if h and not v then h.WalkSpeed=16 end end,function(v) S.spd=v end)
-- ปรับกระโดด
ToggleSlider(T,"ปรับกระโดด","Jump Power","เปิดแล้วลากแถบเพื่อกำหนดแรงกระโดด","Turn on, then drag the bar to set jump power",
 "แรงกระโดด","Jump",50,500,100,function(v) S.jump=v local h=hum() if h and not v then h.JumpPower=50 end end,function(v) S.jp=v end)
bind(RS.Heartbeat,function()
 local h=hum() if not h then return end
 if S.speed then h.WalkSpeed=S.spd end
 if S.jump then h.UseJumpPower=true h.JumpPower=S.jp end
end)

Toggle(T,"กระโดดไม่จำกัด","Infinite Jump",false,function(v) S.inf=v end,"กดกระโดดกลางอากาศได้เรื่อย ๆ","Jump again in mid-air, as many times as you like")
bind(UIS.JumpRequest,function() local h=hum() if S.inf and h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)

Toggle(T,"ทะลุทุกอย่าง (Noclip)","Noclip",false,function(v) S.noclip=v end,"เดินทะลุกำแพงและวัตถุทุกชนิด","Walk through walls and any object")
bind(RS.Stepped,function()
 if S.noclip and LP.Character then
  for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
 end
end)

-- เทเลพอร์ต: ได้ไอเทม TP NEXORA
Header(T,"เทเลพอร์ต","Teleport")
local tpTool
local function giveTP()
 if tpTool then tpTool:Destroy() end
 tpTool=new("Tool",{Name="TP NEXORA",RequiresHandle=false,CanBeDropped=false,ToolTip="Tap anywhere to teleport"})
 tpTool.Activated:Connect(function()
  local r=root() local m=LP:GetMouse()
  if r and m.Hit then
   r.CFrame=CFrame.new(m.Hit.Position+Vector3.new(0,3.5,0))*(r.CFrame-r.CFrame.Position)
  end
 end)
 tpTool.Parent=LP:FindFirstChildOfClass("Backpack") or LP:WaitForChild("Backpack")
end
Toggle(T,"เทเลพอร์ต (TP NEXORA)","Teleport (TP NEXORA)",false,function(v)
 S.tp=v
 if v then giveTP() elseif tpTool then tpTool:Destroy() tpTool=nil end
end,"เปิดแล้วจะได้ไอเทมชื่อ TP NEXORA ถือแล้วแตะที่จุดไหนของแมพ จะวาร์ปไปตรงนั้น","Gives you a tool named TP NEXORA. Hold it and tap anywhere on the map to teleport there")
bind(LP.CharacterAdded,function() if S.tp then task.wait(0.6) giveTP() end end)

-- รถ
Header(T,"รถ","Vehicle")
local seatOrig={}
local function restoreSeats() for s,m in pairs(seatOrig) do pcall(function() s.MaxSpeed=m end) end seatOrig={} end
ToggleSlider(T,"ปรับสปีดรถ","Car Speed","ใช้ตอนนั่งรถ ได้ผลกับรถที่ใช้ VehicleSeat ส่วนใหญ่","Use while seated. Works with most cars that use a VehicleSeat",
 "ความเร็วรถ","Car Speed",20,500,100,function(v) S.car=v if not v then restoreSeats() end end,function(v) S.carspd=v end)
bind(RS.Heartbeat,function()
 local h=hum() local seat=h and h.SeatPart
 if S.car and seat and seat:IsA("VehicleSeat") then
  if not seatOrig[seat] then seatOrig[seat]=seat.MaxSpeed end
  seat.MaxSpeed=S.carspd
  if seat.Throttle~=0 then
   local part=seat.AssemblyRootPart or seat
   local look=seat.CFrame.LookVector
   local vel=part.AssemblyLinearVelocity
   part.AssemblyLinearVelocity=Vector3.new(look.X*S.carspd*seat.Throttle,vel.Y,look.Z*S.carspd*seat.Throttle)
  end
 end
end)

-- ป้องกันการฟลิ้ง
Header(T,"ป้องกัน","Protection")
Toggle(T,"ป้องกันการฟลิ้ง","Anti-Fling",false,function(v) S.anti=v end,"กันคนอื่นชนแล้วเราปลิว: ปิดการชนกับผู้เล่นอื่น และหยุดแรงหมุน/แรงเหวี่ยงที่ผิดปกติ","Stops others from flinging you: disables collision with other players and cancels abnormal spin/velocity")
local acnt=0
bind(RS.Stepped,function()
 if not S.anti then return end
 acnt+=1
 if acnt%2==0 then
  for _,p in ipairs(Players:GetPlayers()) do
   if p~=LP and p.Character then
    for _,x in ipairs(p.Character:GetChildren()) do if x:IsA("BasePart") then x.CanCollide=false end end
   end
  end
 end
 local r,h=root(),hum()
 if r and h and not S.fly and not h.SeatPart then
  if r.AssemblyAngularVelocity.Magnitude>60 then r.AssemblyAngularVelocity=Vector3.zero end
  if r.AssemblyLinearVelocity.Magnitude>350 then r.AssemblyLinearVelocity=Vector3.zero end
 end
end)

-- ===== เครื่องมือเสริม =====
local LT0={Ambient=Lighting.Ambient,Outdoor=Lighting.OutdoorAmbient,Bright=Lighting.Brightness,Clock=Lighting.ClockTime,Fog=Lighting.FogEnd,Zoom=LP.CameraMaxZoomDistance}
local TX={fb=false,day=false,clk=14,nofog=false,fov=false,fv=90,nofall=false,void=false,freeze=false,fps=false,fp=120,del=false}
local atmo={}

Header(T,"มุมมองและแสง","Vision & Light")
Toggle(T,"มองเห็นในที่มืด (Fullbright)","Fullbright",false,function(v)
 TX.fb=v
 if not v then Lighting.Ambient=LT0.Ambient Lighting.OutdoorAmbient=LT0.Outdoor Lighting.Brightness=LT0.Bright end
end,"สว่างทั่วแมพ ไม่มีมุมมืด","Bright everywhere, no dark corners")
ToggleSlider(T,"ปรับเวลา (กลางวัน/กลางคืน)","Time Of Day","เปลี่ยนเวลาในแมพเฉพาะฝั่งเรา ลากแถบ 0–24 ชั่วโมง","Changes the time for you only. Drag 0–24 hours",
 "เวลา (ชั่วโมง)","Hour",0,24,14,function(v) TX.day=v if not v then Lighting.ClockTime=LT0.Clock end end,function(v) TX.clk=v end)
Toggle(T,"ลบหมอก","No Fog",false,function(v)
 TX.nofog=v
 if not v then
  Lighting.FogEnd=LT0.Fog
  for a,d in pairs(atmo) do pcall(function() a.Density=d end) end
  atmo={}
 end
end,"มองไกลชัด ไม่มีหมอกบัง","See far with no fog in the way")
ToggleSlider(T,"ปรับมุมกล้อง (FOV)","Field Of View","ยิ่งมากยิ่งเห็นกว้าง","Higher means a wider view",
 "องศา","Degrees",30,120,90,function(v) TX.fov=v local c=workspace.CurrentCamera if c and not v then c.FieldOfView=70 end end,function(v) TX.fv=v end)
Toggle(T,"ซูมกล้องไกลสุด","Max Zoom",false,function(v)
 if v then LP.CameraMaxZoomDistance=100000 LP.CameraMinZoomDistance=0.5 else LP.CameraMaxZoomDistance=LT0.Zoom end
end,"ถอยกล้องออกไปไกลได้ไม่จำกัด","Pull the camera back as far as you want")
bind(RS.Heartbeat,function()
 if TX.fb then Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1) Lighting.Brightness=2 end
 if TX.day then Lighting.ClockTime=TX.clk end
 if TX.nofog then
  Lighting.FogEnd=1e9
  for _,a in ipairs(Lighting:GetChildren()) do
   if a:IsA("Atmosphere") then
    if atmo[a]==nil then atmo[a]=a.Density end
    a.Density=0
   end
  end
 end
 if TX.fov then local c=workspace.CurrentCamera if c then c.FieldOfView=TX.fv end end
end)

Header(T,"ตัวละครเสริม","Character+")
Toggle(T,"ลงพื้นนุ่ม (Safe Landing)","Safe Landing",false,function(v) TX.nofall=v end,"ชะลอความเร็วก่อนถึงพื้น ช่วยกันดาเมจตกจากที่สูงในเกมที่คิดจากความเร็วตก","Slows you just above the ground to avoid fall damage in games that use fall speed")
Toggle(T,"กันตกเหว (Anti-Void)","Anti-Void",false,function(v) TX.void=v end,"ถ้าตกลงใต้แมพ จะวาร์ปกลับจุดล่าสุดที่ยืนบนพื้น","If you fall below the map, returns you to your last safe spot")
Toggle(T,"แช่แข็งตัว (Freeze)","Freeze",false,function(v) TX.freeze=v local r=root() if r then r.Anchored=v end end,"ล็อกตัวไว้กับที่ ไม่ขยับ","Locks you in place")
local rp=RaycastParams.new()
rp.FilterType=Enum.RaycastFilterType.Exclude
local safe
bind(RS.Heartbeat,function()
 local r,h=root(),hum()
 if not r or not h or h.Health<=0 then return end
 if h.FloorMaterial~=Enum.Material.Air then safe=r.CFrame+Vector3.new(0,3,0) end
 if TX.void and safe and (r.Position.Y<safe.Position.Y-25 or r.Position.Y<workspace.FallenPartsDestroyHeight+80) then
  r.AssemblyLinearVelocity=Vector3.zero r.AssemblyAngularVelocity=Vector3.zero r.CFrame=safe
 end
 if TX.nofall then
  local v=r.AssemblyLinearVelocity
  if v.Y<-70 then
   rp.FilterDescendantsInstances={LP.Character}
   if workspace:Raycast(r.Position,Vector3.new(0,-16,0),rp) then r.AssemblyLinearVelocity=Vector3.new(v.X,-25,v.Z) end
  end
 end
end)

Header(T,"ตำแหน่ง","Position")
local function Label(p,th,en)
 local l=new("TextLabel",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,TextColor3=C.dim,Font=GM,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},p)
 if th then tr(l,th,en) end
 return l
end
local posL=Label(T)
posL.TextColor3=C.cy
local savedCF
task.spawn(function()
 while SG.Parent do
  local r=root()
  if r then
   local p=r.Position
   posL.Text=string.format("X %.0f   Y %.0f   Z %.0f   %s",p.X,p.Y,p.Z,savedCF and "[SAVED]" or "")
  end
  task.wait(0.3)
 end
end)
Button(T,"📍 บันทึกตำแหน่งนี้","📍 Save Position",function() local r=root() if r then savedCF=r.CFrame end end)
Button(T,"↩ วาร์ปกลับตำแหน่งที่บันทึก","↩ Back To Saved",function() local r=root() if r and savedCF then r.CFrame=savedCF end end)
Button(T,"🏠 วาร์ปไปจุดเกิด","🏠 Teleport To Spawn",function()
 local r=root() if not r then return end
 for _,o in ipairs(workspace:GetDescendants()) do
  if o:IsA("SpawnLocation") then r.CFrame=o.CFrame+Vector3.new(0,5,0) return end
 end
end)
Button(T,"♻ เกิดใหม่ตรงที่เดิม","♻ Respawn Here",function()
 local r,h=root(),hum() if not r or not h then return end
 local cf=r.CFrame
 h.Health=0
 task.spawn(function()
  local c=LP.CharacterAdded:Wait()
  local nr=c:WaitForChild("HumanoidRootPart",5)
  if nr then task.wait(0.3) nr.CFrame=cf end
 end)
end)
Button(T,"📋 คัดลอกพิกัด","📋 Copy Coordinates",function()
 local r=root()
 if r then local p=r.Position pcall(function() setclipboard(string.format("Vector3.new(%.1f, %.1f, %.1f)",p.X,p.Y,p.Z)) end) end
end)

Header(T,"ยูทิลิตี้","Utilities")
ToggleSlider(T,"ปลดล็อก FPS","FPS Unlock","ต้องใช้ตัวรันสคริปต์ที่รองรับ setfpscap","Needs an executor that supports setfpscap",
 "FPS สูงสุด","Max FPS",30,360,120,function(v) TX.fps=v pcall(function() setfpscap(v and TX.fp or 60) end) end,function(v) TX.fp=v if TX.fps then pcall(function() setfpscap(v) end) end end)
local delTool
local delList={}
local function giveDel()
 if delTool then delTool:Destroy() end
 delTool=new("Tool",{Name="DELETE NEXORA",RequiresHandle=false,CanBeDropped=false,ToolTip="Tap an object to hide it"})
 delTool.Activated:Connect(function()
  local t=LP:GetMouse().Target
  if t and t:IsA("BasePart") and not (LP.Character and t:IsDescendantOf(LP.Character)) then
   delList[#delList+1]={t,t.Transparency,t.CanCollide,t.CanQuery}
   t.Transparency=1 t.CanCollide=false t.CanQuery=false
  end
 end)
 delTool.Parent=LP:FindFirstChildOfClass("Backpack") or LP:WaitForChild("Backpack")
end
local function undoDel()
 for _,d in ipairs(delList) do pcall(function() d[1].Transparency=d[2] d[1].CanCollide=d[3] d[1].CanQuery=d[4] end) end
 delList={}
end
Toggle(T,"ไอเทมลบวัตถุ (DELETE NEXORA)","Delete Tool",false,function(v)
 TX.del=v
 if v then giveDel() elseif delTool then delTool:Destroy() delTool=nil end
end,"ได้ไอเทมแตะวัตถุไหนก็ซ่อน/ทะลุได้ (เห็นเฉพาะฝั่งเรา)","Tap any object to hide it and walk through it (only on your screen)")
Button(T,"↺ คืนวัตถุที่ลบทั้งหมด","↺ Restore Deleted Objects",undoDel)
bind(LP.CharacterAdded,function()
 task.wait(0.6)
 if TX.del then giveDel() end
 if TX.freeze then local r=root() if r then r.Anchored=true end end
end)

local function ToolsExtraOff()
 TX.fb,TX.day,TX.nofog,TX.fov,TX.nofall,TX.void=false,false,false,false,false,false
 Lighting.Ambient=LT0.Ambient Lighting.OutdoorAmbient=LT0.Outdoor Lighting.Brightness=LT0.Bright
 Lighting.ClockTime=LT0.Clock Lighting.FogEnd=LT0.Fog
 for a,d in pairs(atmo) do pcall(function() a.Density=d end) end
 atmo={}
 LP.CameraMaxZoomDistance=LT0.Zoom
 if TX.freeze then TX.freeze=false local r=root() if r then r.Anchored=false end end
 if TX.fps then TX.fps=false pcall(function() setfpscap(60) end) end
 if delTool then delTool:Destroy() delTool=nil end
 TX.del=false
 undoDel()
end

-- รายชื่อผู้เล่น: ค้นหา / วาร์ปไปหา / ส่อง
Header(T,"รายชื่อผู้เล่นในแมพ","Players In Map")
local box=new("Frame",{Size=UDim2.new(1,0,0,240),BackgroundColor3=C.panel,BackgroundTransparency=0.2},T) round(box,12)
local srch=new("TextBox",{Size=UDim2.new(1,-16,0,32),Position=UDim2.new(0,8,0,8),BackgroundColor3=C.off,TextColor3=C.txt,PlaceholderText="ค้นหา / Search",PlaceholderColor3=C.dim,Font=GM,TextSize=13,Text="",ClearTextOnFocus=false},box) round(srch,8)
local lst=new("ScrollingFrame",{Size=UDim2.new(1,-16,1,-52),Position=UDim2.new(0,8,0,44),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.cy,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},box)
new("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},lst)
local spec
local function unspec() spec=nil local c=workspace.CurrentCamera local h=hum() if c and h then c.CameraSubject=h end end
local function refresh()
 for _,c in ipairs(lst:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
 local q=srch.Text:lower()
 for _,p in ipairs(Players:GetPlayers()) do
  if p~=LP and (q=="" or p.Name:lower():find(q,1,true) or p.DisplayName:lower():find(q,1,true)) then
   local r=new("Frame",{Size=UDim2.new(1,-6,0,46),BackgroundColor3=C.off,BackgroundTransparency=0.4},lst) round(r,8)
   local im=new("ImageLabel",{Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,6,0,5),BackgroundColor3=C.bg,Image="rbxthumb://type=AvatarHeadShot&id="..p.UserId.."&w=48&h=48"},r) circle(im)
   new("TextLabel",{Size=UDim2.new(1,-150,0,22),Position=UDim2.new(0,48,0,3),BackgroundTransparency=1,Text=p.DisplayName,TextColor3=C.txt,Font=GB,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},r)
   new("TextLabel",{Size=UDim2.new(1,-150,0,16),Position=UDim2.new(0,48,0,25),BackgroundTransparency=1,Text="@"..p.Name,TextColor3=C.dim,Font=GM,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},r)
   local b1=new("TextButton",{Size=UDim2.new(0,44,0,30),Position=UDim2.new(1,-98,0.5,-15),BackgroundColor3=C.acc,Text="TP",TextColor3=C.txt,Font=GB,TextSize=12},r) round(b1,7)
   local b2=new("TextButton",{Size=UDim2.new(0,44,0,30),Position=UDim2.new(1,-50,0.5,-15),BackgroundColor3=(spec==p) and C.cy or C.off,Text=(spec==p) and "STOP" or "VIEW",TextColor3=C.txt,Font=GB,TextSize=11},r) round(b2,7)
   b1.MouseButton1Click:Connect(function()
    local mr=root() local pr=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if mr and pr then mr.CFrame=pr.CFrame*CFrame.new(0,0,3) end
   end)
   b2.MouseButton1Click:Connect(function()
    local ph=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    if spec==p then unspec() elseif ph then spec=p workspace.CurrentCamera.CameraSubject=ph end
    refresh()
   end)
  end
 end
end
srch:GetPropertyChangedSignal("Text"):Connect(refresh)
bind(Players.PlayerAdded,function() task.wait(0.5) refresh() end)
bind(Players.PlayerRemoving,function(p) if spec==p then unspec() end task.wait(0.1) refresh() end)
refresh()

-- ปิดทุกอย่างตอนยกเลิกสคริปต์
local function ToolsOff()
 S.fly,S.noclip,S.anti,S.car,S.inf,S.tp=false,false,false,false,false,false
 if S.speed then S.speed=false local h=hum() if h then h.WalkSpeed=16 end end
 if S.jump then S.jump=false local h=hum() if h then h.JumpPower=50 end end
 restoreSeats()
 if tpTool then tpTool:Destroy() tpTool=nil end
 unspec()
 ToolsExtraOff()
end

local TrollOffFn
local __ok1,__e1=pcall(function()
-- ===== แกล้ง (เกรียน) =====
local TR=pages.troll
local K={bighead=false,hs=3,face=false,rainbow=false,ghost=false,gh=60,dance=false,rag=false,slow=false,sw=6,spin=false,bhop=false,grav=false,gv=40,size=false,sz=100}
local origC,origT,headOrig,sizeOrig={}, {}, nil, {}
local g0=workspace.Gravity
local function parts() local c=LP.Character return c and c:GetDescendants() or {} end

-- หัวโต
local function applyHead()
 local h=hum() local c=LP.Character local hd=c and c:FindFirstChild("Head")
 if not hd then return end
 if not K.bighead and not headOrig then return end
 local hsv=h and h:FindFirstChild("HeadScale")
 if hsv then
  headOrig=headOrig or hsv.Value
  hsv.Value=K.bighead and K.hs or headOrig
 else
  local m=hd:FindFirstChildOfClass("SpecialMesh")
  if m then
   headOrig=headOrig or m.Scale
   m.Scale=K.bighead and (headOrig*K.hs) or headOrig
  end
 end
end

-- ใบหน้าตลก (อีโมจิเปลี่ยนหน้าไปมา)
local faceGui
local faces={"🤪","😝","😜","🥴","🤡","😵","😛"}
local function clearFace()
 if faceGui then faceGui:Destroy() faceGui=nil end
 local c=LP.Character local hd=c and c:FindFirstChild("Head")
 local d=hd and hd:FindFirstChildOfClass("Decal")
 if d then d.Transparency=0 end
end
local function mkFace()
 clearFace()
 local c=LP.Character local hd=c and c:FindFirstChild("Head")
 if not hd then return end
 local d=hd:FindFirstChildOfClass("Decal")
 if d then d.Transparency=1 end
 faceGui=new("SurfaceGui",{Face=Enum.NormalId.Front,CanvasSize=Vector2.new(120,120),LightInfluence=0},hd)
 new("TextLabel",{Name="E",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=faces[1],TextScaled=true,Font=GB},faceGui)
end
local ft,fi=0,1
bind(RS.Heartbeat,function(dt)
 if K.face and faceGui and faceGui.Parent then
  ft+=dt
  if ft>0.35 then ft=0 fi=fi%#faces+1 faceGui.E.Text=faces[fi] end
 end
end)

-- ตัวละครเปลี่ยนสี
local hue=0
local function restoreColors() for p,c in pairs(origC) do pcall(function() p.Color=c end) end origC={} end
bind(RS.Heartbeat,function(dt)
 if K.rainbow then
  hue=(hue+dt*0.4)%1
  local col=Color3.fromHSV(hue,1,1)
  for _,p in ipairs(parts()) do
   if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
    if not origC[p] then origC[p]=p.Color end
    p.Color=col
   end
  end
 end
end)

-- โหมดผี (โปร่งใส)
local function restoreGhost() for p,t in pairs(origT) do pcall(function() p.Transparency=t end) end origT={} end
bind(RS.Heartbeat,function()
 if K.ghost then
  for _,p in ipairs(parts()) do
   if (p:IsA("BasePart") and p.Name~="HumanoidRootPart") or p:IsA("Decal") then
    if origT[p]==nil then origT[p]=p.Transparency end
    p.Transparency=K.gh/100
   end
  end
 end
end)

-- เต้นตลก
local danceTrack,di=nil,0
local emotes={"dance","dance2","dance3"}
local r6={"rbxassetid://182435998","rbxassetid://182436842","rbxassetid://182491277"}
local function stopDance() if danceTrack then pcall(function() danceTrack:Stop() end) danceTrack=nil end end
local function doDance()
 local h=hum() if not h then return end
 di=di%3+1
 if h.RigType==Enum.HumanoidRigType.R15 then
  pcall(function() h:PlayEmote(emotes[di]) end)
 else
  stopDance()
  pcall(function()
   local a=new("Animation",{AnimationId=r6[di]})
   local an=h:FindFirstChildOfClass("Animator") or h
   danceTrack=an:LoadAnimation(a) danceTrack.Looped=true danceTrack:Play()
  end)
 end
end
task.spawn(function()
 while SG.Parent do
  if K.dance then doDance() end
  task.wait(6)
 end
end)

-- ล้มแบบตุ๊กตาผ้า
bind(RS.Heartbeat,function()
 if K.rag then
  local h=hum()
  if h then h.PlatformStand=true h:ChangeState(Enum.HumanoidStateType.Ragdoll) end
 end
end)

-- เดินช้า
bind(RS.Heartbeat,function()
 if K.slow then local h=hum() if h then h.WalkSpeed=K.sw end end
end)

-- หมุนตัว
local spinO
bind(RS.Heartbeat,function()
 local r=root()
 if K.spin and r then
  if not spinO or spinO.Parent~=r then
   if spinO then spinO:Destroy() end
   spinO=new("BodyAngularVelocity",{MaxTorque=Vector3.new(0,1e9,0),AngularVelocity=Vector3.new(0,25,0)},r)
  end
 elseif spinO then spinO:Destroy() spinO=nil end
end)

-- กระโดดอัตโนมัติ
bind(RS.Heartbeat,function()
 if K.bhop then
  local h=hum()
  if h and h.FloorMaterial~=Enum.Material.Air then h:ChangeState(Enum.HumanoidStateType.Jumping) end
 end
end)

-- ปรับขนาดตัว (R15)
local scaleNames={"BodyHeightScale","BodyWidthScale","BodyDepthScale"}
local function applySize()
 local h=hum() if not h then return end
 for _,n in ipairs(scaleNames) do
  local v=h:FindFirstChild(n)
  if v then
   if sizeOrig[n]==nil then sizeOrig[n]=v.Value end
   v.Value=K.size and sizeOrig[n]*K.sz/100 or sizeOrig[n]
  end
 end
end

-- เกิดใหม่แล้วใส่เอฟเฟกต์กลับ
bind(LP.CharacterAdded,function()
 headOrig,sizeOrig,origC,origT,danceTrack=nil,{}, {}, {}, nil
 task.wait(1)
 if K.bighead then applyHead() end
 if K.face then mkFace() end
 if K.size then applySize() end
end)

-- ===== เอฟเฟกต์เสริมหมวดแกล้ง =====
local K2={fire=false,spark=false,smoke=false,trail=false,disco=false,jit=false,bounce=false,bp=80,headless=false}
local fxObj={}
local function fxClear(n)
 local l=fxObj[n]
 if l then for _,x in ipairs(l) do pcall(function() x:Destroy() end) end fxObj[n]=nil end
end
local function fxMake(n,r)
 if n=="fire" then return {new("Fire",{Size=9,Heat=12,Color=C.acc,SecondaryColor=C.cy},r)}
 elseif n=="spark" then return {new("Sparkles",{SparkleColor=C.acc2},r)}
 elseif n=="smoke" then return {new("Smoke",{Size=10,Opacity=0.45,RiseVelocity=6,Color=C.acc},r)}
 else
  local a0=new("Attachment",{Position=Vector3.new(0,1.2,0)},r)
  local a1=new("Attachment",{Position=Vector3.new(0,-1.2,0)},r)
  local t=new("Trail",{Attachment0=a0,Attachment1=a1,Lifetime=0.7,LightEmission=1,Color=ColorSequence.new(C.acc,C.cy),Transparency=NumberSequence.new(0,1)},r)
  return {t,a0,a1}
 end
end
local function applyFx()
 local r=root()
 for _,n in ipairs({"fire","spark","smoke","trail"}) do
  local l=fxObj[n]
  if K2[n] and r then
   if not l or l[1].Parent~=r then fxClear(n) fxObj[n]=fxMake(n,r) end
  else fxClear(n) end
 end
end

local dh=0
bind(RS.Heartbeat,function(dt)
 if K2.disco then
  dh=(dh+dt*0.8)%1
  local c=Color3.fromHSV(dh,1,1)
  Lighting.Ambient=c Lighting.OutdoorAmbient=c
 end
 if K2.jit then
  local r=root()
  if r then r.CFrame=r.CFrame*CFrame.new((math.random()-0.5)*1.2,(math.random()-0.5)*0.6,(math.random()-0.5)*1.2) end
 end
end)

local wasAir=false
bind(RS.Heartbeat,function()
 if not K2.bounce then wasAir=false return end
 local h,r=hum(),root()
 if not h or not r then return end
 local air=(h.FloorMaterial==Enum.Material.Air)
 if wasAir and not air then
  local v=r.AssemblyLinearVelocity
  r.AssemblyLinearVelocity=Vector3.new(v.X,K2.bp,v.Z)
 end
 wasAir=air
end)

local function applyHeadless()
 local c=LP.Character local hd=c and c:FindFirstChild("Head")
 if not hd then return end
 local d=hd:FindFirstChildOfClass("Decal")
 hd.Transparency=K2.headless and 1 or 0
 if d then d.Transparency=K2.headless and 1 or 0 end
end
local function emote(n) local h=hum() if h then pcall(function() h:PlayEmote(n) end) end end

bind(LP.CharacterAdded,function() task.wait(1) applyFx() applyHeadless() end)

-- ===== แกล้งมุมมอง: เปลี่ยนหน้าตาผู้เล่นอื่น (เห็นเฉพาะจอเรา) =====
local V={big=false,bs=4,rain=false,face=false,ghost=false,gs=70}
local vo={}
local function setProp(o,prop,val)
 if vo[o]==nil then vo[o]={} end
 if vo[o][prop]==nil then vo[o][prop]=o[prop] end
 o[prop]=val
end
local function viewRestore()
 for o,t in pairs(vo) do for prop,val in pairs(t) do pcall(function() o[prop]=val end) end end
 vo={}
 for _,p in ipairs(Players:GetPlayers()) do
  local hd=p.Character and p.Character:FindFirstChild("Head")
  local g=hd and hd:FindFirstChild("NX_F")
  if g then g:Destroy() end
 end
end
local vh,vi=0,1
local vfaces={"🤪","😝","😜","🥴","🤡","😵","😛"}
task.spawn(function()
 while SG.Parent do
  task.wait(0.15)
  vh=(vh+0.03)%1 vi=vi%#vfaces+1
  if V.big or V.rain or V.ghost or V.face then
   for _,p in ipairs(Players:GetPlayers()) do
    local ch=(p~=LP) and p.Character
    if ch then
     local h=ch:FindFirstChildOfClass("Humanoid")
     local hd=ch:FindFirstChild("Head")
     if V.big and h then
      local hs=h:FindFirstChild("HeadScale")
      if hs then setProp(hs,"Value",V.bs)
      else
       local m=hd and hd:FindFirstChildOfClass("SpecialMesh")
       if m then setProp(m,"Scale",((vo[m] and vo[m].Scale) or m.Scale)*V.bs) end
      end
     end
     if V.rain or V.ghost then
      local col=Color3.fromHSV(vh,1,1)
      for _,d in ipairs(ch:GetDescendants()) do
       if d:IsA("BasePart") and d.Name~="HumanoidRootPart" then
        if V.rain then setProp(d,"Color",col) end
        if V.ghost then setProp(d,"Transparency",V.gs/100) end
       elseif d:IsA("Decal") and V.ghost then setProp(d,"Transparency",V.gs/100) end
      end
     end
     if V.face and hd then
      local g=hd:FindFirstChild("NX_F")
      if not g then
       local d=hd:FindFirstChildOfClass("Decal")
       if d then setProp(d,"Transparency",1) end
       g=new("SurfaceGui",{Name="NX_F",Face=Enum.NormalId.Front,CanvasSize=Vector2.new(120,120),LightInfluence=0},hd)
       new("TextLabel",{Name="E",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextScaled=true,Font=GB},g)
      end
      g.E.Text=vfaces[vi]
     end
    end
   end
  end
 end
end)
local function VOff()
 V.big,V.rain,V.face,V.ghost=false,false,false,false
 viewRestore()
end

local function TrollExtraOff()
 VOff()
 K2.fire,K2.spark,K2.smoke,K2.trail=false,false,false,false
 applyFx()
 if K2.disco then K2.disco=false Lighting.Ambient=LT0.Ambient Lighting.OutdoorAmbient=LT0.Outdoor end
 K2.jit=false K2.bounce=false
 K2.headless=false applyHeadless()
end

local function TrollOff()
 TrollExtraOff()
 K.bighead=false applyHead()
 K.face=false clearFace()
 K.rainbow=false restoreColors()
 K.ghost=false restoreGhost()
 K.dance=false stopDance()
 if K.rag then K.rag=false local h=hum() if h then h.PlatformStand=false end end
 if K.slow then K.slow=false local h=hum() if h then h.WalkSpeed=16 end end
 K.spin=false K.bhop=false
 if K.grav then K.grav=false workspace.Gravity=g0 end
 K.size=false applySize()
end

TrollOffFn=TrollOff
-- ===== หน้าจอ =====
local note=new("TextLabel",{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,TextColor3=C.dim,Font=GM,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},TR)
tr(note,"เอฟเฟกต์ในหมวดนี้เห็นเฉพาะฝั่งเรา ผู้เล่นอื่นอาจไม่เห็น","Effects here are client-side. Other players may not see them")

Header(TR,"ตัวละคร","Character")
ToggleSlider(TR,"🗿 หัวโต (Big Head)","🗿 Big Head","ขยายหัวให้ใหญ่ ลากแถบปรับขนาดได้","Enlarge your head, drag the bar to set the size",
 "ขนาดหัว (เท่า)","Head Size (x)",2,10,3,function(v) K.bighead=v applyHead() end,function(v) K.hs=v if K.bighead then applyHead() end end)
Toggle(TR,"👀 ใบหน้าตลก (Funny Face)","👀 Funny Face",false,function(v) K.face=v if v then mkFace() else clearFace() end end,"เปลี่ยนหน้าเป็นอีโมจิตลก ๆ สลับไปมา","Swaps your face for silly emojis")
Toggle(TR,"🌈 ตัวละครเปลี่ยนสี (Rainbow)","🌈 Rainbow Character",false,function(v) K.rainbow=v if not v then restoreColors() end end,"สีตัวละครไล่เฉดสีรุ้งตลอดเวลา","Your character cycles through rainbow colors")
ToggleSlider(TR,"👻 โหมดผี (Ghost Mode)","👻 Ghost Mode","ตัวละครโปร่งใส ลากแถบปรับความจางได้","See-through character, drag the bar to set it",
 "ความโปร่งใส (%)","Transparency (%)",10,90,60,function(v) K.ghost=v if not v then restoreGhost() end end,function(v) K.gh=v end)
Toggle(TR,"🤸 ล้มแบบตุ๊กตาผ้า (Ragdoll)","🤸 Ragdoll Mode",false,function(v)
 K.rag=v
 local h,r=hum(),root()
 if v then
  if r then r.AssemblyLinearVelocity=r.CFrame.LookVector*-18+Vector3.new(0,14,0) end
 elseif h then h.PlatformStand=false h:ChangeState(Enum.HumanoidStateType.GettingUp) end
end,"ตัวละครล้มลงตัวอ่อนเหมือนตุ๊กตาผ้า","Your character flops over like a rag doll")
ToggleSlider(TR,"📏 ปรับขนาดตัว","Body Size","ทำให้ตัวเล็กหรือตัวใหญ่ (ใช้ได้กับตัวละคร R15)","Make yourself tiny or giant (R15 characters only)",
 "ขนาด (%)","Size (%)",30,300,100,function(v) K.size=v applySize() end,function(v) K.sz=v if K.size then applySize() end end)

Header(TR,"ท่าทางและการเคลื่อนไหว","Motion")
Toggle(TR,"🕺 เต้นตลก (Funny Dance)","🕺 Funny Dance",false,function(v) K.dance=v if v then doDance() else stopDance() end end,"เต้นท่าต่าง ๆ สลับกัน ขยับตัวเพื่อหยุดเต้น","Cycles through dances. Move to stop")
ToggleSlider(TR,"🐌 เดินช้า (Slow Walk)","🐌 Slow Walk","เดินช้า ลากแถบปรับความเร็วได้","Walk slowly, drag the bar to set the speed",
 "ความเร็วเดิน","Walk Speed",1,15,6,function(v) K.slow=v if not v then local h=hum() if h and not S.speed then h.WalkSpeed=16 end end end,function(v) K.sw=v end)
Toggle(TR,"🌀 หมุนตัว","🌀 Spin",false,function(v) K.spin=v end,"หมุนตัวรอบแกนตลอดเวลา","Spins you around nonstop")
Toggle(TR,"🐰 กระโดดอัตโนมัติ","🐰 Auto Bunny Hop",false,function(v) K.bhop=v end,"กระโดดเด้งไปเรื่อย ๆ เมื่อแตะพื้น","Hops again every time you land")
Toggle(TR,"🪑 นั่งค้าง","🪑 Sit",false,function(v) local h=hum() if h then h.Sit=v end end,"สั่งให้ตัวละครนั่งลงกับที่","Makes your character sit down")
ToggleSlider(TR,"🌙 แรงโน้มถ่วงต่ำ","🌙 Low Gravity","ลอยตัวเหมือนอยู่บนดวงจันทร์","Float like you are on the moon",
 "แรงโน้มถ่วง","Gravity",0,196,40,function(v) K.grav=v workspace.Gravity=v and K.gv or g0 end,function(v) K.gv=v if K.grav then workspace.Gravity=v end end)

Header(TR,"ออร่ารอบตัว","Auras")
Toggle(TR,"🔥 ไฟลุกตัว","🔥 Fire Aura",false,function(v) K2.fire=v applyFx() end,"เปลวไฟสีม่วงรอบตัว","Purple flames around you")
Toggle(TR,"✨ ประกายแสง","✨ Sparkles",false,function(v) K2.spark=v applyFx() end,"ประกายระยิบรอบตัว","Sparkles around you")
Toggle(TR,"💨 ควันม่วง","💨 Smoke",false,function(v) K2.smoke=v applyFx() end,"ควันม่วงลอยขึ้นจากตัว","Purple smoke rising off you")
Toggle(TR,"🌠 เทรลนีออน","🌠 Neon Trail",false,function(v) K2.trail=v applyFx() end,"เส้นแสงตามหลังตอนเคลื่อนที่","A glowing trail behind you when you move")

Header(TR,"ปาร์ตี้และป่วน","Party & Chaos")
Toggle(TR,"🪩 ดิสโก้ไฟ","🪩 Disco Lights",false,function(v)
 K2.disco=v
 if not v then Lighting.Ambient=LT0.Ambient Lighting.OutdoorAmbient=LT0.Outdoor end
end,"แสงทั้งแมพเปลี่ยนสีรุ้งรัว ๆ (เห็นเฉพาะฝั่งเรา)","The whole map flashes rainbow light (only on your screen)")
Toggle(TR,"📳 กระตุกเหมือนแล็ก","📳 Glitch Jitter",false,function(v) K2.jit=v end,"ตัวสั่นกระตุกเหมือนเน็ตหลุด ๆ หาย ๆ","Your character twitches like bad lag")
Toggle(TR,"😎 ไร้หัว","😎 Headless",false,function(v) K2.headless=v applyHeadless() end,"ซ่อนหัวตัวละคร","Hides your head")
ToggleSlider(TR,"🏀 โหมดเด้งดึ๋ง","🏀 Bounce Mode","กระโดดครั้งแรกแล้วจะเด้งต่อเองทุกครั้งที่ลงพื้น ลากแถบปรับแรงเด้ง","Jump once and you keep bouncing on every landing. Drag the bar for power",
 "แรงเด้ง","Bounce Power",30,300,80,function(v) K2.bounce=v end,function(v) K2.bp=v end)

Header(TR,"แอคชัน","Actions")
Button(TR,"🤸 ตีลังกา","🤸 Backflip",function()
 local r=root()
 if r then r.AssemblyLinearVelocity=Vector3.new(0,55,0)+r.CFrame.LookVector*-8 r.AssemblyAngularVelocity=r.CFrame.RightVector*-14 end
end)
Button(TR,"🚀 ยิงตัวขึ้นฟ้า","🚀 Launch Up",function()
 local r=root()
 if r then r.AssemblyLinearVelocity=Vector3.new(0,350,0) end
end)
Button(TR,"👋 โบกมือ","👋 Wave",function() emote("wave") end)
Button(TR,"👉 ชี้นิ้ว","👉 Point",function() emote("point") end)
Button(TR,"🎉 ดีใจ","🎉 Cheer",function() emote("cheer") end)
Button(TR,"😂 หัวเราะ","😂 Laugh",function() emote("laugh") end)

Header(TR,"แกล้งมุมมอง: ผู้เล่นคนอื่น","Prank View: Other Players")
local vnote=new("TextLabel",{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,TextColor3=C.dim,Font=GM,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},TR)
tr(vnote,"เปลี่ยนหน้าตาทุกคนให้ตลกบนจอเรา คนอื่นไม่เห็นและไม่ถูกรบกวน","Makes everyone look silly on your screen only. They don't see it and aren't affected")
ToggleSlider(TR,"🗿 ทุกคนหัวโต","🗿 Everyone Big Head","ขยายหัวผู้เล่นทุกคนบนจอเรา ลากแถบปรับขนาด","Enlarges everyone's head on your screen",
 "ขนาดหัว (เท่า)","Head Size (x)",2,10,4,function(v) V.big=v if not v then viewRestore() end end,function(v) V.bs=v end)
Toggle(TR,"🌈 ทุกคนเปลี่ยนสีรุ้ง","🌈 Everyone Rainbow",false,function(v) V.rain=v if not v then viewRestore() end end,"ตัวผู้เล่นทุกคนไล่สีรุ้งบนจอเรา","Everyone cycles rainbow colors on your screen")
Toggle(TR,"🤪 ทุกคนหน้าตลก","🤪 Everyone Funny Face",false,function(v) V.face=v if not v then viewRestore() end end,"หน้าทุกคนเป็นอีโมจิตลกสลับไปมา","Everyone's face becomes a swapping silly emoji")
ToggleSlider(TR,"👻 ทุกคนโปร่งใส","👻 Everyone Ghost","ทำให้ผู้เล่นทุกคนจางลงบนจอเรา","Fades everyone out on your screen",
 "ความโปร่งใส (%)","Transparency (%)",10,90,70,function(v) V.ghost=v if not v then viewRestore() end end,function(v) V.gs=v end)



end)
if not __ok1 then warn("NEXORA troll: "..tostring(__e1)) end
local __ok2,__e2=pcall(function()
-- ===== ตั้งค่า (แบ่งหัวข้อ + คำอธิบาย) =====
local ST=pages.set
local AFK,AR=true,false
local hint=new("TextLabel",{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,TextColor3=C.dim,Font=GM,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},ST)
tr(hint,"แตะโลโก้ลอยเพื่อเปิด/ปิดหน้าต่าง (หรือกด RightShift บนคอม)","Tap the floating logo to show/hide the window (or press RightShift on PC)")

Header(ST,"ความปลอดภัย","Safety")
Toggle(ST,"กันหลุด (Anti-AFK)","Anti-AFK",true,function(v) AFK=v end,"ไม่โดนเตะเมื่อยืนนิ่งนาน ๆ","Stops you being kicked for idling")
bind(LP.Idled,function()
 if AFK then
  local VU=game:GetService("VirtualUser")
  VU:CaptureController() VU:ClickButton2(Vector2.new())
 end
end)
Toggle(ST,"รีจอยอัตโนมัติ","Auto Rejoin",false,function(v) AR=v end,"เข้าเกมใหม่เองถ้าเน็ตหลุดหรือถูกเตะ","Rejoins by itself if you disconnect")
bind(GS.ErrorMessageChanged,function()
 if AR then task.wait(2) TP:Teleport(game.PlaceId,LP) end
end)

Header(ST,"หน้าตา GUI","Appearance")
Toggle(ST,"เอฟเฟคอวกาศ","Space Effects",true,function(v)
 FX=v Stars.Visible=v MGrad.Enabled=v
end,"ดาว ดาวตก เนบิวลา และแสงเรือง ปิดแล้วเครื่องลื่นขึ้น","Stars, shooting stars, nebula and glow. Turn off for smoother play")
Toggle(ST,"ปุ่มโลโก้","Logo Button",true,function(v) LH.Visible=v end,"ปุ่มลอยสำหรับเปิด/ปิดหน้าต่าง","Floating button to show/hide the window")
Slider(ST,"ขนาดหน้าต่าง","Window Size",70,130,100,function(v) baseScale=v/100 MScale.Scale=baseScale end)
Slider(ST,"ความโปร่งใส","Transparency",0,60,0,function(v) Main.BackgroundTransparency=v/100 Space.BackgroundTransparency=v/100 end)

Header(ST,"ประสิทธิภาพ","Performance")
Toggle(ST,"ลดแล็ก (FPS Boost)","FPS Boost",false,function(v)
 pcall(function()
  settings().Rendering.QualityLevel=v and 1 or 10
  Lighting.GlobalShadows=not v
 end)
end,"ลดกราฟิกเพื่อเพิ่ม FPS","Lowers graphics to raise FPS")

Header(ST,"เซิร์ฟเวอร์","Server")
local srvL=new("TextLabel",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,TextColor3=C.dim,Font=GM,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Text=""},ST)
local function srvMsg(th,en) srvL.Text=(Lang=="th") and th or en end
local function httpGet(url)
 local ok,res=pcall(function() return game:HttpGet(url) end)
 if ok and res then return res end
 local rq=(typeof(request)=="function" and request) or (typeof(http_request)=="function" and http_request) or (syn and syn.request)
 if rq then
  local ok2,r=pcall(rq,{Url=url,Method="GET"})
  if ok2 and r and r.Body then return r.Body end
 end
end
local srvBusy=false
Button(ST,"เข้าเซิร์ฟคนน้อย (0–1 คน)","Join Low-Player Server",function()
 if srvBusy then return end
 srvBusy=true
 srvMsg("กำลังค้นหาเซิร์ฟ...","Searching servers...")
 task.spawn(function()
  local base="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
  local cur,pick="",nil
  for _=1,3 do
   local body=httpGet(base..(cur~="" and ("&cursor="..cur) or ""))
   if not body then srvMsg("ตัวรันสคริปต์นี้ดึงข้อมูลเซิร์ฟไม่ได้","Your executor can't fetch server data") srvBusy=false return end
   local ok,data=pcall(function() return game:GetService("HttpService"):JSONDecode(body) end)
   if not ok or type(data)~="table" or not data.data then srvMsg("อ่านข้อมูลเซิร์ฟไม่สำเร็จ ลองใหม่อีกครั้ง","Could not read server data, try again") srvBusy=false return end
   for _,s in ipairs(data.data) do
    local n=s.playing or 0
    if s.id~=game.JobId and n<=1 and n<(s.maxPlayers or 0) then pick=s break end
   end
   cur=data.nextPageCursor or ""
   if pick or cur=="" then break end
  end
  if not pick then srvMsg("ไม่พบเซิร์ฟที่มีคน 0–1 คน ลองใหม่อีกครั้ง","No server with 0–1 players found, try again") srvBusy=false return end
  local n=pick.playing or 0
  srvMsg("พบแล้ว ("..n.." คน) กำลังเข้า...","Found ("..n.." players), joining...")
  TP:TeleportToPlaceInstance(game.PlaceId,pick.id,LP)
  task.wait(8) srvBusy=false
 end)
end)

Header(ST,"อื่น ๆ","Other")
Button(ST,"รีจอยเซิร์ฟเดิม","Rejoin Server",function() TP:TeleportToPlaceInstance(game.PlaceId,game.JobId,LP) end)
Button(ST,"คัดลอก Game ID","Copy Game ID",function() pcall(function() setclipboard(tostring(game.PlaceId)) end) end)
Button(ST,"ปิดสคริปต์ทั้งหมด","Unload Script",function()
 ESP.on=false ESP.hb=false ESP.lock=false ToolsOff() TrollOffFn()
 task.wait(0.7)
 TG:Destroy()
 for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
 SG:Destroy()
end)

end)
if not __ok2 then warn("NEXORA settings: "..tostring(__e2)) end
bind(UIS.InputBegan,function(i,gp)
 if not gp and i.KeyCode==Enum.KeyCode.RightShift then Show(not shown) end
end)

local foot=new("TextLabel",{Size=UDim2.new(1,-16,0,12),Position=UDim2.new(0,8,1,-14),BackgroundTransparency=1,Text="made for roblox  ·  nxh",TextColor3=C.dim,Font=GM,TextSize=9,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3},Main)
Pick("home")
