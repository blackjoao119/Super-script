--// =====================================================
--// 👑 REI REIS | SUPREMO - TOTAL CONTROL EDITION
--// STATUS: CÓDIGO FINAL COMPLETO ✅
--// DISPOSITIVO: OTIMIZADO MOBILE (MOTO G20/A03)
--// =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// VARIAVEIS DE CONTROLE
local MiraAtiva = false
local WallshotAtivo = false
local EspAtivo = false
local PuxadaMira = 0.16
local WalkSpeedValue = 100
local SpeedEnabled = false 
local InfiniteJumpEnabled = false
local AutoClickEnabled = false
local NoClipEnabled = false

--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👑 REI REIS | SUPREMO",
   LoadingTitle = "CARREGANDO TRONO SUPREMO...", 
   LoadingSubtitle = "MODO OFF: WI-FI",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
   Theme = "DarkBlue"
})

--// LÓGICA DE ALVO
local function getTarget()
    local closest = nil
    local shortest = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and (p.Team ~= Player.Team or Player.Team == nil) then
                local pos, visible = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if visible or WallshotAtivo then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < 400 and dist < shortest then
                        shortest = dist
                        closest = p.Character.HumanoidRootPart
                    end
                end
            end
        end
    end
    return closest
end

--// TABS
local CombatTab = Window:CreateTab("🔫 Combate", 10734950020)
local VisualTab = Window:CreateTab("👁 Visual", 10734951477)
local PlayerTab = Window:CreateTab("🏃 Player", 10734981350)
local ExtraTab = Window:CreateTab("✨ Extras", 10734954316)

-- SEÇÃO COMBATE
CombatTab:CreateToggle({Name = "Ativar Mira Suave", CurrentValue = false, Callback = function(V) MiraAtiva = V end})
CombatTab:CreateSlider({Name = "Força da Mira", Range = {0.01, 1}, Increment = 0.01, CurrentValue = 0.16, Callback = function(V) PuxadaMira = V end})
CombatTab:CreateToggle({Name = "Wallshot", CurrentValue = false, Callback = function(V) WallshotAtivo = V end})

-- SEÇÃO VISUAL
VisualTab:CreateSection("Iluminação e Rastreador")
VisualTab:CreateButton({
    Name = "Full Bright (Clarear Noite) ☀️",
    Callback = function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end,
})

VisualTab:CreateToggle({
   Name = "Ativar Raio-X + Pontos",
   CurrentValue = false,
   Callback = function(Value)
      EspAtivo = Value
      if not Value then
         for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                if p.Character:FindFirstChild("REI_ESP") then p.Character.REI_ESP:Destroy() end
                if p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart:FindFirstChild("REI_DOT") then
                    p.Character.HumanoidRootPart.REI_DOT:Destroy()
                end
            end
         end
      end
   end,
})

-- SEÇÃO PLAYER
PlayerTab:CreateToggle({Name = "Ativar Velocidade Rei", CurrentValue = false, Callback = function(V) SpeedEnabled = V if not V and Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.WalkSpeed = 16 end end})
PlayerTab:CreateSlider({Name = "Velocidade Rei", Range = {16, 250}, Increment = 1, CurrentValue = 100, Callback = function(V) WalkSpeedValue = V end})
PlayerTab:CreateToggle({Name = "Pulo Infinito", CurrentValue = false, Callback = function(V) InfiniteJumpEnabled = V end})
PlayerTab:CreateToggle({Name = "No-Clip", CurrentValue = false, Callback = function(V) NoClipEnabled = V end})

-- SEÇÃO EXTRAS
ExtraTab:CreateToggle({Name = "Auto Clicker", CurrentValue = false, Callback = function(V) AutoClickEnabled = V end})

--// LOOP DE EXECUÇÃO (ESP, PONTOS E MIRA)
RunService.RenderStepped:Connect(function()
    if MiraAtiva then
        local target = getTarget()
        if target then
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, PuxadaMira) 
        end
    end
    
    if EspAtivo then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local root = p.Character.HumanoidRootPart
                
                -- LÓGICA DO PONTO (DOT)
                local dotGui = root:FindFirstChild("REI_DOT")
                if not dotGui then
                    dotGui = Instance.new("BillboardGui")
                    dotGui.Name = "REI_DOT"
                    dotGui.Parent = root
                    dotGui.Size = UDim2.new(0, 10, 0, 10)
                    dotGui.AlwaysOnTop = true
                    dotGui.ExtentsOffset = Vector3.new(0, 3.5, 0)
                    local frame = Instance.new("Frame", dotGui)
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    local corner = Instance.new("UICorner", frame)
                    corner.CornerRadius = UDim.new(1, 0)
                end
                
                -- LÓGICA DO HIGHLIGHT (RAIO-X SUAVE)
                local h = p.Character:FindFirstChild("REI_ESP") or Instance.new("Highlight")
                h.Name = "REI_ESP"
                h.Parent = p.Character
                
                local isTeammate = (p.Team == Player.Team and Player.Team ~= nil)
                
                -- Check de Visibilidade (Raycast)
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {Player.Character, p.Character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                local ray = workspace:Raycast(Camera.CFrame.Position, (root.Position - Camera.CFrame.Position), rayParams)
                
                if isTeammate then
                    h.FillColor = Color3.fromRGB(0, 255, 0)
                    h.FillTransparency = 0.9 -- Bem suave
                    dotGui.Frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Ponto Verde
                elseif ray then
                    h.FillColor = Color3.fromRGB(170, 0, 255) -- Roxo (Parede)
                    h.FillTransparency = 0.8
                    dotGui.Frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Ponto Vermelho
                else
                    h.FillColor = Color3.fromRGB(255, 0, 0) -- Vermelho (Livre)
                    h.FillTransparency = 0.6 -- Mais visível
                    dotGui.Frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Ponto Vermelho
                end
                h.OutlineTransparency = 0.7
            end
        end
    end
end)

-- LOOP FÍSICO
RunService.Stepped:Connect(function()
    if SpeedEnabled and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = WalkSpeedValue
    end
    if NoClipEnabled and Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- CLIKS E AFK
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoClickEnabled then
            VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 1)
        end
    end
end)

Player.Idled:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end)

UIS.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

Rayfield:Notify({Title = "👑 REI REIS", Content = "CONTROLE TOTAL ATIVADO: WI-FI", Duration = 5})
