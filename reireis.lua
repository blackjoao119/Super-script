--// =====================================================
--// 👑 REI REIS | SUPREMO - THE FINAL VERSION
--// STATUS: MIRA 0.35 + PONTOS FULL + DISTÂNCIA INIMIGO ✅
--// DISPOSITIVO: OTIMIZADO MOBILE (WI-FI)
--// =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// VARIÁVEIS DE CONTROLE
local MiraAtiva = false
local FovVisivel = false
local WallshotAtivo = false
local EspRaioXAtivo = false
local ESPDistanceEnabled = false
local FovRadius = 25
local DistanceCache = {}

--// VARIÁVEIS PLAYER
local WalkSpeedValue = 100
local SpeedEnabled = false 
local InfiniteJumpEnabled = false

--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👑 REI REIS | SUPREMO",
   LoadingTitle = "CONSOLIDANDO CÓDIGO FINAL...", 
   LoadingSubtitle = "MODO OFF: WI-FI",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
   Theme = "DarkBlue"
})

--// =====================================================
--// GUI DO FOV (CÍRCULO)
--// =====================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "REI_FOV_SYSTEM"
Gui.IgnoreGuiInset = true 
pcall(function() Gui.Parent = game.CoreGui end)

local Circle = Instance.new("Frame", Gui)
Circle.Visible = false
Circle.BackgroundTransparency = 1
Circle.AnchorPoint = Vector2.new(0.5,0.5)
Circle.Position = UDim2.new(0.5,0,0.5,0)
Circle.Size = UDim2.new(0, FovRadius*2, 0, FovRadius*2)

local Stroke = Instance.new("UIStroke", Circle)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0,170,255)

local Corner = Instance.new("UICorner", Circle)
Corner.CornerRadius = UDim.new(1,0)

--// =====================================================
--// FUNÇÕES TÉCNICAS (RAYCAST & TARGET)
--// =====================================================
local function IsBehindWall(targetPart)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Player.Character, targetPart.Parent}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
    return result ~= nil
end

local function getTarget()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local closest, shortest = nil, FovRadius

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
            local isTeam = (p.Team == Player.Team and Player.Team ~= nil)
            if not isTeam then
                local head = p.Character.Head
                local hum = p.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local pos, vis = Camera:WorldToViewportPoint(head.Position)
                    local behind = IsBehindWall(head)
                    if vis and (not behind or WallshotAtivo) then
                        local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
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

--// =====================================================
--// INTERFACE (ABAS)
--// =====================================================
local CombatTab = Window:CreateTab("🔫 Combate", 10734950020)
local VisualTab = Window:CreateTab("👁 Visual", 10734951477)
local PlayerTab = Window:CreateTab("🏃 Player", 10734981350)

-- COMBATE
CombatTab:CreateToggle({Name = "Ativar Mira Suave (0.35)", CurrentValue = false, Callback = function(v) MiraAtiva = v end})
CombatTab:CreateToggle({Name = "Exibir Círculo do FOV", CurrentValue = false, Callback = function(v) FovVisivel = v Circle.Visible = v end})
CombatTab:CreateToggle({Name = "Wallshot", CurrentValue = false, Callback = function(v) WallshotAtivo = v end})
CombatTab:CreateSlider({Name = "Ajustar FOV", Range = {5, 25}, Increment = 1, CurrentValue = 5, Callback = function(v)
    FovRadius = v * 5
    Circle.Size = UDim2.new(0, FovRadius*2, 0, FovRadius*2)
end})

-- VISUAL
VisualTab:CreateToggle({Name = "Ativar Pontos (Dist. Inimigo)", CurrentValue = false, Callback = function(v)
    ESPDistanceEnabled = v
    if not v then for _, d in pairs(DistanceCache) do if d.bill then d.bill:Destroy() end end table.clear(DistanceCache) end
end})
VisualTab:CreateToggle({Name = "Raio-X (Highlight)", CurrentValue = false, Callback = function(v) EspRaioXAtivo = v end})
VisualTab:CreateButton({Name = "Iluminar Mapa (Full Bright) ☀️", Callback = function() 
    Lighting.Brightness = 2 
    Lighting.ClockTime = 14 
    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.GlobalShadows = false
end})

-- PLAYER
PlayerTab:CreateToggle({Name = "Velocidade Rei", CurrentValue = false, Callback = function(v) SpeedEnabled = v end})
PlayerTab:CreateSlider({Name = "Velocidade", Range = {16, 250}, Increment = 1, CurrentValue = 100, Callback = function(v) WalkSpeedValue = v end})
PlayerTab:CreateToggle({Name = "Pulo Infinito", CurrentValue = false, Callback = function(v) InfiniteJumpEnabled = v end})

--// =====================================================
--// SISTEMA ESP DINÂMICO
--// =====================================================
local function createESP(plr)
    if DistanceCache[plr] then return end
    local head = plr.Character and plr.Character:FindFirstChild("Head")
    if not head then return end
    
    local bill = Instance.new("BillboardGui", head)
    bill.Name = "REI_ESP_SYSTEM"
    bill.Size, bill.AlwaysOnTop, bill.ExtentsOffset = UDim2.new(0,50,0,50), true, Vector3.new(0, 2, 0)

    local dot = Instance.new("Frame", bill)
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0.5, -4, 0.5, -4)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local text = Instance.new("TextLabel", bill)
    text.Size, text.BackgroundTransparency, text.TextScaled, text.Font = UDim2.new(1, 0, 0.4, 0), 1, true, Enum.Font.GothamBold
    text.Position = UDim2.new(0, 0, 0.7, 0)
    text.Visible = false

    DistanceCache[plr] = {bill = bill, dot = dot, text = text, head = head}
end

--// =====================================================
--// LOOPS DE RENDERIZAÇÃO
--// =====================================================
RunService.RenderStepped:Connect(function()
    -- Mira
    if MiraAtiva then
        local target = getTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 0.35)
        end
    end
    
    -- ESP Inteligente
    if ESPDistanceEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
                createESP(p)
                local data = DistanceCache[p]
                if data then
                    local head = p.Character.Head
                    local dist = (Player.Character.Head.Position - head.Position).Magnitude
                    local behind = IsBehindWall(head)
                    local isTeam = (p.Team == Player.Team and Player.Team ~= nil)
                    
                    if isTeam then
                        data.dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Verde (Aliado)
                        data.text.Visible = false -- Sem distância para time
                    else
                        local color = behind and Color3.fromRGB(130, 0, 0) or Color3.fromRGB(255, 0, 0)
                        data.dot.BackgroundColor3 = color
                        data.text.TextColor3 = color
                        data.text.Text = math.floor(dist).."m"
                        data.text.Visible = true -- Distância só para inimigo
                    end
                end
            end
        end
    end

    -- Raio-X
    if EspRaioXAtivo then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local h = p.Character:FindFirstChild("REI_HL") or Instance.new("Highlight", p.Character)
                h.Name = "REI_HL"
                local isTeam = (p.Team == Player.Team and Player.Team ~= nil)
                local head = p.Character:FindFirstChild("Head")
                local behind = head and IsBehindWall(head) or false
                
                h.FillColor = isTeam and Color3.new(0,1,0) or (behind and Color3.fromRGB(130, 0, 0) or Color3.fromRGB(255, 0, 0))
            end
        end
    end
end)

-- Movimentação
RunService.Stepped:Connect(function()
    if SpeedEnabled and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = WalkSpeedValue
    end
end)

-- Salto
UIS.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

Rayfield:Notify({Title = "👑 REI REIS", Content = "SCRIP TOTALMENTE UNIFICADO! ✅", Duration = 5})
