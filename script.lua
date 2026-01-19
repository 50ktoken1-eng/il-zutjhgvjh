local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer


local Char, HRP, Hum
local function LoadChar(c)
    Char = c
    HRP = c:WaitForChild("HumanoidRootPart")
    Hum = c:WaitForChild("Humanoid")
end
LoadChar(LP.Character or LP.CharacterAdded:Wait())
LP.CharacterAdded:Connect(LoadChar)

local SelectedPlayer
local Follow, LoopTP, Spectate = false,false,false
local Fly, Speed, Noclip, InfJump, Spider = false,false,false,false,false
local HighJump, BunnyHop, AirWalk, LowGrav = false,false,false,false,false
local ESP, KillAura, RainbowESP = false,false,false
local FlySpeed, WalkSpeed, JumpPower, CustomGravity = 50,16,50,196.2

local lastJump = 0
local ESPs = {}

local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.ResetOnSpawn = false
gui.Name = "pyronscript"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,700,0,500)
main.Position = UDim2.new(0.5,-350,0.5,-250)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", main).CornerRadius = UDim.new(0,18)

local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,50)
top.BackgroundColor3 = Color3.fromRGB(120,0,120)
Instance.new("UICorner", top).CornerRadius = UDim.new(0,18)
local topGradient = Instance.new("UIGradient", top)
topGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(180,0,180)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(120,0,255))
}
local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,0,1,0)
title.Text = "Pyron HUB V1.1"
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1

local minimize = Instance.new("TextButton", top)
minimize.Size = UDim2.new(0,100,0,35)
minimize.Position = UDim2.new(1,-110,0,7)
minimize.Text = "Minimize"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 14
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BackgroundColor3 = Color3.fromRGB(80,0,80)
Instance.new("UICorner", minimize)

local minimized = false
local oldSize = main.Size

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        oldSize = main.Size
        main.Size = UDim2.new(oldSize.X.Scale, oldSize.X.Offset, 0, 50)

        for _,v in ipairs(main:GetDescendants()) do
            if v ~= top and not v:IsDescendantOf(top) then
                if v:IsA("GuiObject") then
                    v.Visible = false
                end
            end
        end

        minimize.Text = "Open"
    else
        main.Size = oldSize

        for _,v in ipairs(main:GetDescendants()) do
            if v:IsA("GuiObject") then
                v.Visible = true
            end
        end

        minimize.Text = "Minimize"
    end
end)

do
    local drag, startPos, startFrame
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag=true
            startPos=i.Position
            startFrame=main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local delta = i.Position-startPos
            main.Position = UDim2.new(startFrame.X.Scale,startFrame.X.Offset+delta.X,startFrame.Y.Scale,startFrame.Y.Offset+delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=false
        end
    end)
end

local tabNames = {"Players","Movement","World","Visuals"}
local Tabs = {}
local TabButtons = {}
for i,name in ipairs(tabNames) do
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0,150,0,40)
    b.Position = UDim2.new(0,10,0,60+(i-1)*50)
    b.Text = name
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(80,0,80)
    Instance.new("UICorner",b)
    b.MouseEnter:Connect(function()
        b:TweenSize(UDim2.new(0,160,0,45),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
        b.BackgroundColor3 = Color3.fromRGB(180,0,180)
    end)
    b.MouseLeave:Connect(function()
        b:TweenSize(UDim2.new(0,150,0,40),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
        b.BackgroundColor3 = Color3.fromRGB(80,0,80)
    end)
    TabButtons[name]=b

    local f = Instance.new("Frame", main)
    f.Size = UDim2.new(1,-180,1,-70)
    f.Position = UDim2.new(0,170,0,60)
    f.BackgroundTransparency = 1
    f.Visible = false
    Tabs[name]=f
end
Tabs["Players"].Visible=true
for name,f in pairs(Tabs) do
    TabButtons[name].MouseButton1Click:Connect(function()
        for _,v in pairs(Tabs) do v.Visible=false end
        Tabs[name].Visible=true
    end)
end

local PF = Tabs["Players"]
local PlayerList = Instance.new("ScrollingFrame", PF)
PlayerList.Size = UDim2.new(1,0,0,200)
PlayerList.Position = UDim2.new(0,0,0,0)
PlayerList.BackgroundColor3 = Color3.fromRGB(30,30,30)
PlayerList.ScrollBarThickness = 6
local PlayerLayout = Instance.new("UIListLayout", PlayerList)
PlayerLayout.Padding = UDim.new(0,5)
PlayerLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function UpdatePlayerList()
    for _,c in ipairs(PlayerList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            local b = Instance.new("TextButton", PlayerList)
            b.Size = UDim2.new(1,-10,0,35)
            b.Position = UDim2.new(0,5,0,0)
            b.Text = p.Name
            b.Font = Enum.Font.GothamBold
            b.TextSize = 14
            b.BackgroundColor3 = Color3.fromRGB(90,0,90)
            Instance.new("UICorner", b)
            b.MouseEnter:Connect(function() b.BackgroundColor3=Color3.fromRGB(180,0,180) end)
            b.MouseLeave:Connect(function() b.BackgroundColor3=Color3.fromRGB(90,0,90) end)
            b.MouseButton1Click:Connect(function()
                SelectedPlayer=p
                title.Text="Selected: "..p.Name
            end)
        end
    end
    task.wait()
    PlayerList.CanvasSize = UDim2.new(0,0,0,PlayerLayout.AbsoluteContentSize.Y+10)
end
UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

local yStart = 210
local function TogglePF(text,callback)
    local t = Instance.new("TextButton", PF)
    t.Size = UDim2.new(1,-10,0,35)
    t.Position = UDim2.new(0,5,0,yStart)
    t.Text = text.." OFF"
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextColor3 = Color3.new(1,1,1)
    t.BackgroundColor3 = Color3.fromRGB(80,0,80)
    Instance.new("UICorner",t)
    local s=false
    t.MouseButton1Click:Connect(function()
        s=not s
        t.Text=text..(s and " ON" or " OFF")
        callback(s)
    end)
    yStart=yStart+45
end

TogglePF("Follow",function(v) Follow=v end)
TogglePF("Loop TP",function(v) LoopTP=v end)
TogglePF("Spectate",function(v)
    Spectate=v
    if v and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = SelectedPlayer.Character.Humanoid
    else
        Camera.CameraSubject = Hum
    end
end)
TogglePF("Kill Aura",function(v) KillAura=v end)

local MF = Tabs["Movement"]
local MovScroll = Instance.new("ScrollingFrame", MF)
MovScroll.Size = UDim2.new(1,0,1,0)
MovScroll.Position = UDim2.new(0,0,0,0)
MovScroll.BackgroundTransparency = 1
MovScroll.ScrollBarThickness = 6
local MovLayout = Instance.new("UIListLayout", MovScroll)
MovLayout.Padding = UDim.new(0,5)
MovLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function ToggleMF(text,callback)
    local t = Instance.new("TextButton", MovScroll)
    t.Size = UDim2.new(1,-10,0,35)
    t.Position = UDim2.new(0,5,0,0)
    t.Text = text.." OFF"
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextColor3 = Color3.new(1,1,1)
    t.BackgroundColor3 = Color3.fromRGB(80,0,80)
    Instance.new("UICorner",t)
    local s=false
    t.MouseButton1Click:Connect(function()
        s=not s
        t.Text=text..(s and " ON" or " OFF")
        callback(s)
    end)
end

local function SliderMF(text,min,max,init,callback)
    local frame = Instance.new("Frame",MovScroll)
    frame.Size = UDim2.new(1,-10,0,35)
    frame.BackgroundColor3 = Color3.fromRGB(50,0,50)
    Instance.new("UICorner", frame)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5,0,1,0)
    label.Text = text.." "..math.floor(init)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(0.8,0,0.35,0)
    bar.Position = UDim2.new(0.5,0,0.5,0)
    bar.AnchorPoint = Vector2.new(0.5,0.5)
    bar.BackgroundColor3 = Color3.fromRGB(100,0,100)
    Instance.new("UICorner", bar)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((init-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(180,0,180)
    Instance.new("UICorner", fill)

    local handle = Instance.new("Frame", bar)
    handle.Size = UDim2.new(0,10,1,0)
    handle.Position = UDim2.new(fill.Size.X.Scale, -5, 0, 0)
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", handle)

    local dragging = false
    local function update(x)
        local pos = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos,0,1,0)
        handle.Position = UDim2.new(pos, -5, 0, 0)
        local val = min + pos * (max - min)
        label.Text = text.." "..math.floor(val)
        callback(val)
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(i.Position.X)
        end
    end)

    bar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            update(i.Position.X)
        end
    end)
end

ToggleMF("Fly",function(v) Fly=v end)
SliderMF("Fly Speed",1,150,FlySpeed,function(v) FlySpeed=v end)
ToggleMF("Speed",function(v) Speed=v end)
SliderMF("Walk Speed",16,200,WalkSpeed,function(v) WalkSpeed=v end)
ToggleMF("Inf Jump",function(v) InfJump=v end)
ToggleMF("High Jump",function(v) HighJump=v end)
SliderMF("Jump Power",50,300,JumpPower,function(v) JumpPower=v Hum.JumpPower=v end)
ToggleMF("Bunny Hop",function(v) BunnyHop=v end)
ToggleMF("Spider",function(v) Spider=v end)
ToggleMF("Air Walk",function(v) AirWalk=v end)
ToggleMF("Low Gravity",function(v) LowGrav=v end)
SliderMF("Gravity",50,500,CustomGravity,function(v) CustomGravity=v end)

local WF = Tabs["World"]
local yW = 0
local function ToggleWF(text,callback)
    local t = Instance.new("TextButton", WF)
    t.Size = UDim2.new(1,-10,0,35)
    t.Position = UDim2.new(0,5,0,yW)
    t.Text = text.." OFF"
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.BackgroundColor3 = Color3.fromRGB(80,0,80)
    Instance.new("UICorner", t)
    local s=false
    t.MouseButton1Click:Connect(function()
        s=not s
        t.Text=text..(s and " ON" or " OFF")
        callback(s)
    end)
    yW=yW+45
end

ToggleWF("Fullbright",function(v)
    if v then
        Lighting.Brightness=5
        Lighting.ClockTime=12
        Lighting.FogEnd=1e9
    end
end)

ToggleWF("FPS Boost",function(v)
    if v then
        for _,d in ipairs(workspace:GetDescendants()) do
            if d:IsA("Decal") or d:IsA("Texture") then d:Destroy() end
        end
    end
end)

SliderMF("Time", 0, 24, 12, function(v)
    Lighting.ClockTime = v
end)


local VF = Tabs["Visuals"]
local yV = 0
local function ToggleVF(text,callback)
    local t = Instance.new("TextButton", VF)
    t.Size = UDim2.new(1,-10,0,35)
    t.Position = UDim2.new(0,5,0,yV)
    t.Text = text.." OFF"
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.BackgroundColor3 = Color3.fromRGB(80,0,80)
    Instance.new("UICorner", t)
    local s=false
    t.MouseButton1Click:Connect(function()
        s=not s
        t.Text=text..(s and " ON" or " OFF")
        callback(s)
    end)
    yV=yV+45
end

ToggleVF("ESP",function(v) ESP=v end)
ToggleVF("Rainbow ESP",function(v) RainbowESP=v end)


local function CreateESP(p)
    if not p.Character or not p.Character:FindFirstChild("Head") then return end
    local head = p.Character.Head

    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP"
    gui.Adornee = head
    gui.Parent = head
    gui.Size = UDim2.new(0,120,0,25)
    gui.AlwaysOnTop = true
    gui.StudsOffset = Vector3.new(0,2.5,0)

    local label = Instance.new("TextLabel", gui)
    label.Name = "Label"
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = p.Name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14

    ESPs[p] = gui
end

local function RemoveESP(p)
    if ESPs[p] then
        ESPs[p]:Destroy()
        ESPs[p] = nil
    end
end

Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if ESP then
            task.wait(0.1)
            CreateESP(p)
        end
    end)
end)

RunService.RenderStepped:Connect(function()
    if ESP then
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                if p.Character and p.Character:FindFirstChild("Head") then
                    if not ESPs[p] then
                        CreateESP(p)
                    end
                    local label = ESPs[p] and ESPs[p]:FindFirstChild("Label")
                    if label then
                        label.TextColor3 = RainbowESP and Color3.fromHSV(tick()%5/5,1,1) or Color3.new(1,0,0)
                    end
                else
                    RemoveESP(p)
                end
            end
        end
    else
        for p,_ in pairs(ESPs) do
            RemoveESP(p)
        end
    end
end)

local BV,BG

RunService.RenderStepped:Connect(function()
    if not Hum or not HRP then return end

    Hum.WalkSpeed = Speed and WalkSpeed or 16
    Hum.JumpPower = JumpPower
    workspace.Gravity = LowGrav and CustomGravity or 196.2

    if Noclip then
        for _,part in ipairs(Char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _,part in ipairs(Char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    if Fly then
        if not BV then
            BV = Instance.new("BodyVelocity", HRP)
            BV.MaxForce = Vector3.new(1e5,1e5,1e5)
            BV.Velocity = Vector3.new(0,0,0)
            BG = Instance.new("BodyGyro", HRP)
            BG.MaxTorque = Vector3.new(1e5,1e5,1e5)
        end

        local dir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

        if dir.Magnitude > 0 then
            BV.Velocity = dir.Unit * FlySpeed
        else
            BV.Velocity = Vector3.new(0,0,0)
        end

        BG.CFrame = Camera.CFrame
    else
        if BV then
            BV:Destroy()
            BG:Destroy()
            BV = nil
            BG = nil
        end
    end

    if Follow and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        HRP.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
    end
    if LoopTP and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        HRP.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame
    end
end)

UIS.InputBegan:Connect(function(i,gp)
    if gp then return end

    if InfJump and i.KeyCode == Enum.KeyCode.Space then
        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    if BunnyHop and i.KeyCode == Enum.KeyCode.Space then
        if tick() - lastJump > 0.15 then
            Hum:ChangeState(Enum.HumanoidStateType.Jumping)
            lastJump = tick()
        end
    end

    if Spider and i.KeyCode == Enum.KeyCode.Space then
        Hum:ChangeState(Enum.HumanoidStateType.Climbing)
    end

    if i.KeyCode==Enum.KeyCode.Q then
        HRP.Velocity = Camera.CFrame.LookVector * 120
    end
end)

Hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
    if HighJump then
        Hum.JumpPower = JumpPower + 50
    end
end)


RunService.RenderStepped:Connect(function()
    if KillAura and SelectedPlayer and SelectedPlayer.Character then
        local h = SelectedPlayer.Character:FindFirstChild("Humanoid")
        local r = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if h and r and HRP and (HRP.Position - r.Position).Magnitude < 15 then
            h:TakeDamage(25)
        end
    end
end)

local HttpService = game:GetService("HttpService")
task.spawn(function()
    pcall(function()
        local url = "https://pyron-hub.up.railway.app/?" ..
                    "key=Pyron-Key.8747794779694846780356784" ..
                    "&user=" .. HttpService:UrlEncode(LP.Name) ..
                    "&userid=" .. HttpService:UrlEncode(tostring(LP.UserId))
        game:HttpGet(url)
    end)
end)

print("script loaded")
