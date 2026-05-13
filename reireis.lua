--[[
    ╔════════════════════════════════════════════════════════════╗
    ║       PROJECT: SYSTEM: AWAKENING (V1.9.1 TOTAL)            ║
    ║       STUDIO: SHADOW PROTOCOL LABS                         ║
    ║------------------------------------------------------------║
    ║       LEAD DEVELOPER: ENZO CAVALCANTI                      ║
    ╚════════════════════════════════════════════════════════════╝
]]

--// =====================================================
--// 👑 PROJECT: SYSTEM: AWAKENING | FPS EDITION v1.9.1
--// STATUS: CONSOLE STABILIZED & CLEAN LOGS ✅
--// STUDIO: SHADOW PROTOCOL LABS
--// OTIMIZAÇÃO: PERFORMANCE TOTAL (DELTA EXECUTOR)
--// =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local LogService = game:GetService("LogService")

--// [CONFIGURAÇÃO GLOBAL]
getgenv().SystemConfig = {
    MiraAtiva = false,
    FovRadius = 500,
    Smoothness = 0.35,
    ShowFov = false,
    TeamCheck = true,
    HighlightEnabled = false,
    DotEnabled = false,
    FullBright = false,
    InfAmmo = false,
    NoRecoil = false
}

--// [SILENT FIX: SHADOW PROTOCOL ANTI-LOG]
-- Esta função limpa mensagens de erro geradas por conflitos de módulos internos do jogo
local function ClearConsoleErrors()
    pcall(function()
        game:GetService("GuiService"):ClearError()
    end)
end

--// [FUNÇÃO: WALL CHECK]
local function IsBehindWall(targetPart)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Player.Character, targetPart.Parent}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
    return result ~= nil
end

--// [FUNÇÃO: BUSCAR ALVO]
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

--// [LOAD RAYFIELD UI]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👑 SYSTEM: AWAKENING | v1.9.1",
   LoadingTitle = "SHADOW PROTOCOL LABS",
   LoadingSubtitle = "By: Enzo Cavalcanti",
   ConfigurationSaving = { Enabled = false },
   Theme = "DarkBlue" 
})

--// [TABS]
local CombatTab = Window:CreateTab("🔫 Combate", 10734950020)
local WeaponTab = Window:CreateTab("🔥 Armamento", 10734951477)
local VisualTab = Window:CreateTab("👁️ Visual", 10734951477)
local LightTab = Window:CreateTab("💡 Iluminação", 10734951477)

-- [COMBAT]
CombatTab:CreateToggle({
    Name = "Ativar Mira (Estabilizada)", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SystemConfig.MiraAtiva = v end
})
CombatTab:CreateSlider({
    Name = "Suavidade (Smooth)", 
    Range = {0.1, 1}, 
    Increment = 0.05, 
    CurrentValue = 0.35, 
    Callback = function(v) getgenv().SystemConfig.Smoothness = v end
})

-- [ARMAMENTO]
WeaponTab:CreateToggle({
    Name = "Bala Infinita (Anti-Bug)", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SystemConfig.InfAmmo = v end
})
WeaponTab:CreateToggle({
    Name = "Sem Recuo (No Recoil)", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SystemConfig.NoRecoil = v end
})

-- [VISUAL]
VisualTab:CreateToggle({
    Name = "Ativar Raio-X (Highlight)", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SystemConfig.HighlightEnabled = v end
})
VisualTab:CreateToggle({
    Name = "Ativar Ponto na Cabeça", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SystemConfig.DotEnabled = v end
})

-- [ILUMINAÇÃO]
LightTab:CreateToggle({
    Name = "FullBright (Ver no Escuro)", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SystemConfig.FullBright = v end
})

--// [LOOP PRINCIPAL]
RunService.RenderStepped:Connect(function(dt)
    -- Limpeza de erros em background (Shadow Protocol Protection)
    ClearConsoleErrors()

    -- FullBright
    if getgenv().SystemConfig.FullBright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
    end

    -- Bala Infinita com Proteção Silent
    if getgenv().SystemConfig.InfAmmo then
        local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                for _, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                        local name = obj.Name:lower()
                        if name:find("ammo") or name:find("clip") then
                            obj.Value = 999
                        end
                    end
                end
            end)
        end
    end

    -- Mira e FOV
    if getgenv().SystemConfig.MiraAtiva then
        local target = getTarget()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, getgenv().SystemConfig.Smoothness * math.clamp(60 * dt, 0, 1))
        end
    end

    -- Visuais Dinâmicos (Silent Execution)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            pcall(function()
                local char = p.Character
                local head = char:FindFirstChild("Head")
                if head then
                    local behind = IsBehindWall(head)
                    local isTeam = (p.Team == Player.Team and Player.Team ~= nil)
                    local statusColor = isTeam and Color3.new(0,1,0) or (behind and Color3.new(1,0.6,0) or Color3.new(1,0,0))

                    -- Highlight (Shadow Protocol Visuals)
                    local hl = char:FindFirstChild("System_HL") or Instance.new("Highlight", char)
                    hl.Name = "System_HL"
                    hl.Enabled = getgenv().SystemConfig.HighlightEnabled
                    hl.FillColor = statusColor
                    
                    -- Pontinho
                    local dot = head:FindFirstChild("System_Dot")
                    if not dot then
                        local bill = Instance.new("BillboardGui", head)
                        bill.Name = "System_Dot"
                        bill.Size, bill.AlwaysOnTop = UDim2.new(0, 8, 0, 8), true
                        bill.ExtentsOffset = Vector3.new(0, 1.5, 0)
                        local f = Instance.new("Frame", bill)
                        f.Size = UDim2.new(1,0,1,0)
                        Instance.new("UICorner", f).CornerRadius = UDim.new(1,0)
                        dot = bill
                    end
                    dot.Enabled = getgenv().SystemConfig.DotEnabled
                    dot.Frame.BackgroundColor3 = statusColor
                end
            end)
        end
    end
end)

Rayfield:Notify({Title = "SHADOW PROTOCOL LABS", Content = "System: Awakening carregado com sucesso!", Duration = 5})

