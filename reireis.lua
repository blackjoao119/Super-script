--[[
    ╔════════════════════════════════════════════════════════════╗
    ║       PROJECT: SYSTEM: AWAKENING (V1.9.2 TOTAL)            ║
    ║       STUDIO: SHADOW PROTOCOL LABS                         ║
    ║------------------------------------------------------------║
    ║       LEAD DEVELOPER: ENZO CAVALCANTI                      ║
    ╚════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService") -- Para o efeito do botão

--// [CONFIGURAÇÃO GLOBAL]
getgenv().SystemConfig = {
    MiraAtiva = false,
    FovRadius = 500,
    Smoothness = 0.35,
    TeamCheck = true,
    HighlightEnabled = false,
    DotEnabled = false,
    FullBright = false,
    NoShadows = false,
    ClarezaMod = false,
    ShowFPS = false,
    ShowPlayers = false,
    InfAmmo = false,
    NoRecoil = false
}

local OriginalSettings = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows = Lighting.GlobalShadows,
    Exposure = Lighting.ExposureCompensation
}

--// [SISTEMA DE INTERFACE: TAGS E BOTÃO ELITE]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local TagContainer = Instance.new("Frame", ScreenGui)
TagContainer.Size = UDim2.new(0, 60, 0, 50) 
TagContainer.Position = UDim2.new(0, 5, 0, 45) 
TagContainer.BackgroundTransparency = 1
local UIList = Instance.new("UIListLayout", TagContainer)
UIList.Padding = UDim.new(0, 3)

local function CreateTag(color)
    local f = Instance.new("Frame", TagContainer)
    f.Size = UDim2.new(0, 70, 0, 16) 
    f.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    f.BackgroundTransparency = 0.5
    f.Visible = false
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = color
    l.TextSize = 10
    l.Font = Enum.Font.GothamBold
    return f, l
end

local fpsF, fpsL = CreateTag(Color3.fromRGB(0, 255, 120))
local countF, countL = CreateTag(Color3.fromRGB(255, 255, 0))

-- Botão Flutuante Elite (Novo)
local FloatingBtn = Instance.new("TextButton", ScreenGui)
FloatingBtn.Visible = false 
FloatingBtn.Size = UDim2.new(0, 65, 0, 35)
FloatingBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(15, 23, 35)
FloatingBtn.Text = "OFF"
FloatingBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 14
FloatingBtn.Draggable = true
FloatingBtn.Active = true
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", FloatingBtn)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(40, 50, 70)

local function UpdateBtnVisual(active)
    if active then
        TweenService:Create(FloatingBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 35, 60)}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(57, 172, 231)}):Play()
        FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        FloatingBtn.Text = "ON"
    else
        TweenService:Create(FloatingBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 23, 35)}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 50, 70)}):Play()
        FloatingBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        FloatingBtn.Text = "OFF"
    end
end

FloatingBtn.MouseButton1Click:Connect(function()
    getgenv().SystemConfig.MiraAtiva = not getgenv().SystemConfig.MiraAtiva
    UpdateBtnVisual(getgenv().SystemConfig.MiraAtiva)
end)

--// [FUNÇÃO: BUSCA DE ALVO (Aimbot)]
local function getTarget()
    local closest, shortest = nil, getgenv().SystemConfig.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local isTeam = (p.Team == Player.Team and Player.Team ~= nil)
                if not (isTeam and getgenv().SystemConfig.TeamCheck) then
                    local pos, vis = Camera:WorldToViewportPoint(head.Position)
                    if vis and pos.Z > 0 then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = head
                        end
                    end
                end
            end
        end
    end
    return closest
end

--// [FUNÇÃO: WALL CHECK]
local function IsBehindWall(targetPart)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Player.Character, targetPart.Parent}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
    return result ~= nil
end

--// [INTERFACE RAYFIELD]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👑 SYSTEM: AWAKENING | v1.9.2",
   LoadingTitle = "SHADOW PROTOCOL LABS",
   LoadingSubtitle = "By: Enzo Cavalcanti",
   ConfigurationSaving = { Enabled = false },
   Theme = "DarkBlue" 
})

local CombatTab = Window:CreateTab("🔫 Combate", 10734950020)
local WeaponTab = Window:CreateTab("🔥 Armamento", 10734951477)
local VisualTab = Window:CreateTab("👁️ Visual", 10734951477)
local LightTab = Window:CreateTab("💡 Iluminação", 10734951477)
local StatusTab = Window:CreateTab("📊 Monitor", 4483362458)

CombatTab:CreateToggle({ 
    Name = "Ativar Mira", 
    CurrentValue = false, 
    Callback = function(v) 
        getgenv().SystemConfig.MiraAtiva = v 
        FloatingBtn.Visible = v -- Sincronizado com o Menu
        UpdateBtnVisual(v)
    end 
})
CombatTab:CreateSlider({ Name = "Suavidade", Range = {0.1, 1}, Increment = 0.05, CurrentValue = 0.35, Callback = function(v) getgenv().SystemConfig.Smoothness = v end })

WeaponTab:CreateToggle({ Name = "Bala Infinita", CurrentValue = false, Callback = function(v) getgenv().SystemConfig.InfAmmo = v end })
WeaponTab:CreateToggle({ Name = "Sem Recuo", CurrentValue = false, Callback = function(v) getgenv().SystemConfig.NoRecoil = v end })

VisualTab:CreateToggle({ Name = "Ativar Raio-X", CurrentValue = false, Callback = function(v) getgenv().SystemConfig.HighlightEnabled = v end })
VisualTab:CreateToggle({ Name = "Ponto na Cabeça", CurrentValue = false, Callback = function(v) getgenv().SystemConfig.DotEnabled = v end })

LightTab:CreateToggle({ 
    Name = "FullBright", 
    CurrentValue = false, 
    Callback = function(v) 
        getgenv().SystemConfig.FullBright = v 
        if not v then
            Lighting.Ambient = OriginalSettings.Ambient
            Lighting.Brightness = OriginalSettings.Brightness
            Lighting.ClockTime = OriginalSettings.ClockTime
            Lighting.FogEnd = OriginalSettings.FogEnd
            Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
        end
    end 
})
LightTab:CreateToggle({ Name = "Clareza Técnica", CurrentValue = false, Callback = function(v) getgenv().SystemConfig.ClarezaMod = v end })
LightTab:CreateToggle({ Name = "Remover Sombras", CurrentValue = false, Callback = function(v) Lighting.GlobalShadows = not v end })

StatusTab:CreateToggle({ Name = "Mostrar FPS", CurrentValue = false, Callback = function(v) getgenv().SystemConfig.ShowFPS = v fpsF.Visible = v end })
StatusTab:CreateToggle({ Name = "Contador Players", CurrentValue = false, Callback = function(v) getgenv().SystemConfig.ShowPlayers = v countF.Visible = v end })

--// [LOOP CORE]
RunService.RenderStepped:Connect(function(dt)
    if getgenv().SystemConfig.ShowFPS then fpsL.Text = "FPS: " .. math.floor(1/dt) end
    if getgenv().SystemConfig.ShowPlayers then countL.Text = "P: " .. #Players:GetPlayers() end

    if getgenv().SystemConfig.MiraAtiva then
        local target = getTarget()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, getgenv().SystemConfig.Smoothness * math.clamp(60 * dt, 0, 1))
        end
    end

    if getgenv().SystemConfig.FullBright then
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        Lighting.ClockTime = 14
    end
    if getgenv().SystemConfig.ClarezaMod then
        Lighting.Brightness = 3
        Lighting.ExposureCompensation = 0.5
    else
        if not getgenv().SystemConfig.FullBright then
            Lighting.Brightness = OriginalSettings.Brightness
            Lighting.ExposureCompensation = OriginalSettings.Exposure
        end
    end

    if getgenv().SystemConfig.InfAmmo or getgenv().SystemConfig.NoRecoil then
        local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                for _, obj in ipairs(tool:GetDescendants()) do
                    if getgenv().SystemConfig.InfAmmo and (obj:IsA("IntValue") or obj:IsA("NumberValue")) then
                        if obj.Name:lower():find("ammo") or obj.Name:lower():find("clip") then
                            obj.Value = 999
                        end
                    end
                end
            end)
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            if head then
                local isTeam = (p.Team == Player.Team and Player.Team ~= nil)
                local statusColor = isTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                
                local hl = char:FindFirstChild("System_HL") or Instance.new("Highlight", char)
                hl.Name = "System_HL"
                hl.Enabled = getgenv().SystemConfig.HighlightEnabled
                hl.FillColor = statusColor
                hl.OutlineColor = statusColor
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                
                local behind = IsBehindWall(head)
                local dotColor = isTeam and Color3.fromRGB(0, 255, 0) or (behind and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(255, 0, 0))

                local dot = head:FindFirstChild("System_Dot")
                if not dot then
                    local bill = Instance.new("BillboardGui", head)
                    bill.Name = "System_Dot"
                    bill.Size = UDim2.new(0, 10, 0, 10)
                    bill.AlwaysOnTop = true
                    bill.ExtentsOffset = Vector3.new(0, 1.5, 0)
                    local f = Instance.new("Frame", bill)
                    f.Size = UDim2.new(1,0,1,0)
                    Instance.new("UICorner", f).CornerRadius = UDim.new(1,0)
                    dot = bill
                end
                dot.Enabled = getgenv().SystemConfig.DotEnabled
                dot.Frame.BackgroundColor3 = dotColor
            end
        end
    end
end)

Rayfield:Notify({Title = "SHADOW PROTOCOL LABS", Content = "Sistema Original Restaurado com Botão Elite!", Duration = 5})
