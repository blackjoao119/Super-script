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

--// [CONFIGURAÇÃO GLOBAL]
getgenv().SystemConfig = {
    MiraAtiva = false,
    FovRadius = 500,
    Smoothness = 0.35,
    TeamCheck = true,
    HighlightEnabled = false,
    DotEnabled = false,
    FullBright = false,
    InfAmmo = false,
    NoRecoil = false
}

local OriginalSettings = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

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

CombatTab:CreateToggle({ Name = "Ativar Mira", CurrentValue = false, Callback = function(v) getgenv().SystemConfig.MiraAtiva = v end })
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

--// [LOOP CORE]
RunService.RenderStepped:Connect(function(dt)
    -- Lógica da Mira (RESTURADA)
    if getgenv().SystemConfig.MiraAtiva then
        local target = getTarget()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, getgenv().SystemConfig.Smoothness * math.clamp(60 * dt, 0, 1))
        end
    end

    -- Balas Infinitas
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

    -- Visuais Calibrados (Baseado na 2567.jpg)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            
            if head then
                local isTeam = (p.Team == Player.Team and Player.Team ~= nil)
                local statusColor = isTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                
                -- Highlight Otimizado: Outline Colorido e Fill Suave
                local hl = char:FindFirstChild("System_HL") or Instance.new("Highlight", char)
                hl.Name = "System_HL"
                hl.Enabled = getgenv().SystemConfig.HighlightEnabled
                hl.FillColor = statusColor
                hl.OutlineColor = statusColor
                hl.FillTransparency = 0.5 -- Aumentado para não ficar muito forte como na foto
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                
                -- Ponto Inteligente
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

Rayfield:Notify({Title = "SHADOW PROTOCOL LABS", Content = "Mira e Visão 100% Calibradas, meu rei!", Duration = 5})
