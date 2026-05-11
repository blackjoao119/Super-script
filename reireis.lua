--// =====================================================
--// 👑 REI REIS | SUPREMO - TOTAL CONTROL EDITION
--// Mobile Optimized (Moto G20)
--// STATUS: ONLINE 👑
--// =====================================================

local Color3_fromRGB = Color3.fromRGB
local taskwait = task.wait
local taskspawn = task.spawn

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// VARIAVEIS DE CONTROLE
local MiraAtiva = false
local WallshotAtivo = false
local EspAtivo = false
local PuxadaMira = 0.16 -- Valor padrão
local WalkSpeedValue = 100
local InfiniteJumpEnabled = false

--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👑 REI REIS | SUPREMO",
   LoadingTitle = "Calibrando Sensibilidade Rei Reis...",
   LoadingSubtitle = "STATUS: ONLINE 👑",
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
        if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and (p.Team ~= Player.Team or Player.Team == nil) then
                local pos, visible = Camera:WorldToViewportPoint(p.Character.Head.Position)
                
                if WallshotAtivo or visible then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < 400 and dist < shortest then
                        shortest = dist
                        closest = p.Character.Head
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

-- COMBATE
CombatTab:CreateSection("Aimbot Customizado")

CombatTab:CreateToggle({
   Name = "Ativar Mira Suave",
   CurrentValue = false,
   Callback = function(Value) MiraAtiva = Value end,
})

CombatTab:CreateSlider({
   Name = "Velocidade da Puxada",
   Range = {0.01, 1},
   Increment = 0.01,
   Suffix = "Força",
   CurrentValue = 0.16,
   Callback = function(Value)
      PuxadaMira = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Wallshot (Atravessar Bala)",
   CurrentValue = false,
   Callback = function(Value) WallshotAtivo = Value end,
})

-- VISUAL
VisualTab:CreateSection("ESP Inteligente")
VisualTab:CreateToggle({
   Name = "Raio-X (Verde/Vermelho)",
   CurrentValue = false,
   Callback = function(Value)
      EspAtivo = Value
      if not Value then
         for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("REI_ESP") then p.Character.REI_ESP:Destroy() end
         end
      end
   end,
})

-- PLAYER
PlayerTab:CreateSection("Movimentação")
PlayerTab:CreateSlider({
   Name = "Velocidade Rei",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 100,
   Callback = function(Value)
      WalkSpeedValue = Value
      if Player.Character and Player.Character:FindFirstChild("Humanoid") then
         Player.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

PlayerTab:CreateToggle({
   Name = "Pulo Infinito",
   CurrentValue = false,
   Callback = function(Value) InfiniteJumpEnabled = Value end,
})

--// LOOPS
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
            if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
                local h = p.Character:FindFirstChild("REI_ESP") or Instance.new("Highlight")
                h.Name = "REI_ESP"
                h.Parent = p.Character
                
                local _, visible = Camera:WorldToViewportPoint(p.Character.Head.Position)
                h.FillColor = visible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                h.FillTransparency = 0.5
                h.OutlineTransparency = 0
            end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid:ChangeState("Jumping")
    end
end)

Rayfield:Notify({
   Title = "👑 REI REIS",
   Content = "wi-fi",
   Duration = 5
})
