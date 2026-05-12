--// =====================================================
--// 👑 PROJECT: SYSTEM: AWAKENING | FPS EDITION v1.9.1
--// STATUS: INTERFACE CORRIGIDA + ANTI-SNAP ✅
--// OTIMIZAÇÃO: PERFORMANCE TOTAL (DELTA EXECUTOR)
--// =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer

--// [CONFIGURAÇÃO GLOBAL]
getgenv().SystemConfig = {
    MiraAtiva = false,
    FovRadius = 500,
    Smoothness = 0.35,
    ShowFov = false,
    TeamCheck = true,
    HighlightEnabled = false,
    DotEnabled = false
}

--// [FOV CIRCLE]
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 1.5
FovCircle.Color = Color3.fromRGB(0, 200, 255)
FovCircle.Transparency = 0.5

--// [FUNÇÃO: BUSCAR ALVO ESTÁVEL]
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
                    
                    -- ANTI-SNAP: Só aceita se o alvo estiver na frente da câmera (pos.Z > 0)
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
   LoadingTitle = "INICIALIZANDO...",
   LoadingSubtitle = "Estabilidade Total, Meu Rei",
   ConfigurationSaving = { Enabled = false },
   Theme = "DarkBlue" 
})

--// [TABS]
local CombatTab = Window:CreateTab("🔫 Combate", 10734950020)
local VisualTab = Window:CreateTab("👁️ Visual", 10734951477)

CombatTab:CreateToggle({
    Name = "Ativar Mira (Estabilizada)", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SystemConfig.MiraAtiva = v end
})

CombatTab:CreateSlider({
    Name = "Puxada (Suavidade)", 
    Range = {0.1, 1}, 
    Increment = 0.05, 
    CurrentValue = 0.35, 
    Callback = function(v) getgenv().SystemConfig.Smoothness = v end
})

CombatTab:CreateSlider({
    Name = "Raio da Mira", 
    Range = {50, 800}, 
    Increment = 10, 
    CurrentValue = 500, 
    Callback = function(v) getgenv().SystemConfig.FovRadius = v end
})

VisualTab:CreateSection("Efeitos Visuais")
VisualTab:CreateToggle({
    Name = "Ativar Brilho (Raio-X)", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SystemConfig.HighlightEnabled = v end
})
VisualTab:CreateToggle({
    Name = "Ativar Ponto na Cabeça", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SystemConfig.DotEnabled = v end
})

--// [FUNÇÃO: WALL CHECK]
local function IsBehindWall(targetPart)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Player.Character, targetPart.Parent}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
    return result ~= nil
end

--// [LOOP PRINCIPAL]
RunService.RenderStepped:Connect(function(dt)
    -- Atualiza FOV
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Radius = getgenv().SystemConfig.FovRadius
    FovCircle.Visible = getgenv().SystemConfig.ShowFov

    -- Lógica de Mira
    if getgenv().SystemConfig.MiraAtiva then
        local target = getTarget()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            -- math.clamp impede que a mira pule violentamente em lags
            Camera.CFrame = Camera.CFrame:Lerp(goal, getgenv().SystemConfig.Smoothness * math.clamp(60 * dt, 0, 1))
        end
    end

    -- Lógica Visual (Highlights e Dots)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local char = p.Character
            local hl = char:FindFirstChild("System_HL") or Instance.new("Highlight", char)
            hl.Name = "System_HL"
            
            local head = char:FindFirstChild("Head")
            if head then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local dotGui = head:FindFirstChild("System_Dot")
                
                -- Se não tiver o dot, cria
                if not dotGui then
                    local bill = Instance.new("BillboardGui", head)
                    bill.Name = "System_Dot"
                    bill.Size, bill.AlwaysOnTop = UDim2.new(0, 8, 0, 8), true
                    bill.ExtentsOffset = Vector3.new(0, 1.5, 0)
                    local frame = Instance.new("Frame", bill)
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
                    dotGui = bill
                end

                if hum and hum.Health > 0 then
                    local isTeam = (p.Team == Player.Team and Player.Team ~= nil)
                    local behind = IsBehindWall(head)
                    local color = isTeam and Color3.new(0,1,0) or (behind and Color3.new(1,0.6,0) or Color3.new(1,0,0))
                    
                    hl.Enabled = getgenv().SystemConfig.HighlightEnabled
                    hl.FillColor = color
                    
                    dotGui.Enabled = getgenv().SystemConfig.DotEnabled
                    dotGui.Frame.BackgroundColor3 = color
                else
                    hl.Enabled = false
                    dotGui.Enabled = false
                end
            end
        end
    end
end)

Rayfield:Notify({Title = "SISTEMA PRONTO", Content = "Menu carregado, Meu Rei!", Duration = 5})
