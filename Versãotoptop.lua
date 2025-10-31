--[[
    Script: Sasiperere.lua (Versão Final com Silent Aim)
    [!] INTEGRAÇÃO: O Silent Aim do Project Delta foi adicionado à UI.
    - Adicionados botões "Silent Aim" e "Prediction".
    - Aimbot e Silent Aim são mutuamente exclusivos (ativar um desativa o outro).
    - AVISO: A função Silent Aim SÓ FUNCIONARÁ no jogo "Project Delta".
]]

--================================================================================
-- SERVIÇOS E VARIÁVEIS
--================================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AimbotEnabled = false,
    SilentAimEnabled = false, -- Nova opção
    Prediction = true,        -- Nova opção
    TeamCheck = true,
    WallCheck = true,
    ShowFov = false,
    FOV = 80,
    Smoothness = 0.3,
    MaxDistance = 500,
    HitPart = "Head" -- Usado pelo Silent Aim
}

--================================================================================
-- CRIAÇÃO DA INTERFACE GRÁFICA (GUI)
--================================================================================
local mainGui = Instance.new("ScreenGui", CoreGui)
mainGui.Name = "DeleteMob_GUI_Final"
mainGui.ResetOnSpawn = false

-- Interface Principal
local mainFrame = Instance.new("Frame", mainGui)
mainFrame.Name = "DeleteMobF"
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -185) -- Aumentei um pouco a altura
mainFrame.Size = UDim2.new(0, 400, 0, 370)          -- Aumentei um pouco a altura
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Visible = true
mainFrame.ClipsDescendants = true
local frameCorner = Instance.new("UICorner", mainFrame); frameCorner.CornerRadius = UDim.new(0, 8)
local frameStroke = Instance.new("UIStroke", mainFrame); frameStroke.Color = Color3.fromRGB(80, 80, 80); frameStroke.Thickness = 1

-- Header
local header = Instance.new("Frame", mainFrame); header.BackgroundColor3 = Color3.fromRGB(35, 35, 35); header.Size = UDim2.new(1, 0, 0, 35)
local headerStroke = Instance.new("UIStroke", header); headerStroke.Color = Color3.fromRGB(80, 80, 80); headerStroke.Thickness = 1
local titleLabel = Instance.new("TextLabel", header); titleLabel.BackgroundTransparency = 1; titleLabel.Position = UDim2.new(0.05, 0, 0, 0); titleLabel.Size = UDim2.new(0.9, 0, 1, 0); titleLabel.Font = Enum.Font.GothamBold; titleLabel.Text = "DeleteMob | Cheat Engine"; titleLabel.TextColor3 = Color3.fromRGB(17, 223, 255); titleLabel.TextSize = 20; titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Botão de Abrir/Fechar
local openCloseButton = Instance.new("TextButton", mainGui); openCloseButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25); openCloseButton.Size = UDim2.new(0, 150, 0, 30); openCloseButton.Position = UDim2.new(0.5, -75, 0.05, 0); openCloseButton.Font = Enum.Font.GothamBold; openCloseButton.Text = "Abrir / Fechar"; openCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255); openCloseButton.TextSize = 16; openCloseButton.ZIndex = 12
local ocCorner = Instance.new("UICorner", openCloseButton); ocCorner.CornerRadius = UDim.new(0, 6)
local ocStroke = Instance.new("UIStroke", openCloseButton); ocStroke.Color = Color3.fromRGB(80, 80, 80); ocStroke.Thickness = 1

-- Container para os botões
local buttonContainer = Instance.new("ScrollingFrame", mainFrame); buttonContainer.BackgroundTransparency = 1; buttonContainer.Position = UDim2.new(0.05, 0, 0, 45); buttonContainer.Size = UDim2.new(0.9, 0, 1, -55); buttonContainer.BorderSizePixel = 0; buttonContainer.ScrollBarThickness = 4
local listLayout = Instance.new("UIListLayout", buttonContainer); listLayout.SortOrder = Enum.SortOrder.LayoutOrder; listLayout.Padding = UDim.new(0, 8)

-- Cores e Função de Criação de Botão
local COLOR_ACCENT = Color3.fromRGB(17, 223, 255)
local COLOR_OFF = Color3.fromRGB(52, 52, 52)
local COLOR_HOVER = Color3.fromRGB(70, 70, 70)

local function CreateButton(text)
    local button = Instance.new("TextButton"); button.Parent = buttonContainer; button.BackgroundColor3 = COLOR_OFF; button.Size = UDim2.new(1, 0, 0, 30); button.Font = Enum.Font.Gotham; button.Text = text; button.TextColor3 = Color3.fromRGB(255, 255, 255); button.TextSize = 16
    local corner = Instance.new("UICorner", button); corner.CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", button); stroke.Color = Color3.fromRGB(80, 80, 80); stroke.Thickness = 1
    button.MouseEnter:Connect(function() if not button:GetAttribute("IsActive") then TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_HOVER}):Play() end end)
    button.MouseLeave:Connect(function() if not button:GetAttribute("IsActive") then TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_OFF}):Play() end end)
    return button
end

-- Botões
local aimbotEnableButton = CreateButton("Aimbot: OFF")
local silentAimEnableButton = CreateButton("Silent Aim: OFF") -- Novo
local predictionButton = CreateButton("Prediction: ON")      -- Novo
local aimbotWallCheckButton = CreateButton("WallCheck: ON")
local aimbotTeamCheckButton = CreateButton("TeamCheck: ON")
local aimbotShowFovButton = CreateButton("Show FOV: OFF")
local fovButton = CreateButton("FOV: 80")
local smoothnessButton = CreateButton("Suavidade: 0.3")
local distanceButton = CreateButton("Distância: 500")

--================================================================================
-- CONEXÕES E LÓGICA DOS BOTÕES
--================================================================================
local function UpdateButtonState(button, isActive, textPrefix)
    button.Text = textPrefix .. (isActive and "ON" or "OFF")
    button:SetAttribute("IsActive", isActive)
    local targetColor = isActive and COLOR_ACCENT or COLOR_OFF
    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
end

-- Configurar estado inicial dos botões
UpdateButtonState(aimbotEnableButton, Settings.AimbotEnabled, "Aimbot: ")
UpdateButtonState(silentAimEnableButton, Settings.SilentAimEnabled, "Silent Aim: ")
UpdateButtonState(predictionButton, Settings.Prediction, "Prediction: ")
UpdateButtonState(aimbotWallCheckButton, Settings.WallCheck, "WallCheck: ")
UpdateButtonState(aimbotTeamCheckButton, Settings.TeamCheck, "TeamCheck: ")
UpdateButtonState(aimbotShowFovButton, Settings.ShowFov, "Show FOV: ")

-- Lógica de Exclusividade
aimbotEnableButton.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    if Settings.AimbotEnabled then Settings.SilentAimEnabled = false end
    UpdateButtonState(aimbotEnableButton, Settings.AimbotEnabled, "Aimbot: ")
    UpdateButtonState(silentAimEnableButton, Settings.SilentAimEnabled, "Silent Aim: ")
end)

silentAimEnableButton.MouseButton1Click:Connect(function()
    Settings.SilentAimEnabled = not Settings.SilentAimEnabled
    if Settings.SilentAimEnabled then Settings.AimbotEnabled = false end
    UpdateButtonState(silentAimEnableButton, Settings.SilentAimEnabled, "Silent Aim: ")
    UpdateButtonState(aimbotEnableButton, Settings.AimbotEnabled, "Aimbot: ")
end)

-- Outros botões
predictionButton.MouseButton1Click:Connect(function() Settings.Prediction = not Settings.Prediction; UpdateButtonState(predictionButton, Settings.Prediction, "Prediction: ") end)
aimbotWallCheckButton.MouseButton1Click:Connect(function() Settings.WallCheck = not Settings.WallCheck; UpdateButtonState(aimbotWallCheckButton, Settings.WallCheck, "WallCheck: ") end)
aimbotTeamCheckButton.MouseButton1Click:Connect(function() Settings.TeamCheck = not Settings.TeamCheck; UpdateButtonState(aimbotTeamCheckButton, Settings.TeamCheck, "TeamCheck: ") end)
aimbotShowFovButton.MouseButton1Click:Connect(function() Settings.ShowFov = not Settings.ShowFov; UpdateButtonState(aimbotShowFovButton, Settings.ShowFov, "Show FOV: ") end)

local function createInputForButton(button, settingName, min, max, format)
    button.MouseButton1Click:Connect(function()
        button.Visible = false
        local input = Instance.new("TextBox"); input.Parent = button.Parent; input.Size, input.Position, input.ZIndex = button.Size, button.Position, button.ZIndex + 1; input.Font, input.TextSize, input.TextColor3 = button.Font, button.TextSize, button.TextColor3; input.BackgroundColor3 = COLOR_HOVER; input.ClearTextOnFocus, input.PlaceholderText = true, tostring(min).."-"..tostring(max)
        local c = Instance.new("UICorner", input); c.CornerRadius = UDim.new(0, 6); local s = Instance.new("UIStroke", input); s.Color = Color3.fromRGB(80, 80, 80); s.Thickness = 1
        input:CaptureFocus()
        input.FocusLost:Connect(function(enter)
            if enter then
                local v = tonumber(input.Text)
                if v and v >= min and v <= max then Settings[settingName] = v; button.Text = string.format(format, v) end
            end
            input:Destroy(); button.Visible = true
        end)
    end)
end

createInputForButton(fovButton, "FOV", 1, 999, "FOV: %d")
createInputForButton(smoothnessButton, "Smoothness", 0.1, 1.0, "Suavidade: %.1f")
createInputForButton(distanceButton, "MaxDistance", 1, 1000, "Distância: %d")

local menuVisible = true
openCloseButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible; local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out); local goal = {Position = menuVisible and UDim2.new(0.5, -200, 0.5, -185) or UDim2.new(0.5, -200, -1, 0)}; TweenService:Create(mainFrame, tweenInfo, goal):Play()
end)

--================================================================================
-- FUNÇÕES DO SILENT AIM (do script Project Delta)
--================================================================================
local function isAlive(player) return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 end
local function isVisible(origin, target, ...) local ignore = { Camera, ... }; if isAlive(LocalPlayer) then table.insert(ignore, LocalPlayer.Character) end; local hit = workspace:FindPartOnRayWithIgnoreList(Ray.new(origin, target.Position - origin), ignore, false, true); return hit and hit:IsDescendantOf(target.Parent) end
local function getAi() local ai = {}; for _,v in workspace.AiZones:GetChildren() do for _, character in v:GetChildren() do table.insert(ai, character) end end; return ai end
local function getTarget(...)
    local cloestTarget, closestDistance = nil, Settings.FOV
    for _, character in getAi() do if character:FindFirstChild("HumanoidRootPart") then local hitPart = character:FindFirstChild(Settings.HitPart); if hitPart then if not (Settings.WallCheck and not isVisible(Camera.CFrame.Position, hitPart, ...)) then local screenPosition, onScreen = Camera:WorldToViewportPoint(hitPart.Position); if onScreen then local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - Camera.ViewportSize/2).Magnitude; if distance < closestDistance then closestDistance = distance; cloestTarget = hitPart end end end end end end
    for _, player in Players:GetPlayers() do if player ~= LocalPlayer and isAlive(player) then local hitPart = player.Character:FindFirstChild(Settings.HitPart); if hitPart then if not (Settings.TeamCheck and player.Team == LocalPlayer.Team) then if not (Settings.WallCheck and not isVisible(Camera.CFrame.Position, hitPart, ...)) then local screenPosition, onScreen = Camera:WorldToViewportPoint(hitPart.Position); if onScreen then local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - Camera.ViewportSize/2).Magnitude; if distance < closestDistance then closestDistance = distance; cloestTarget = hitPart end end end end end end end
    return cloestTarget
end
local function solveQuadratic(A, B, C) local d = B^2 - 4*A*C; if d < 0 then return nil, nil end; local r = math.sqrt(d); return (-B - r) / (2*A), (-B + r) / (2*A) end
local function getBallisticFlightTime(direction, gravity, projectileSpeed) local r1, r2 = solveQuadratic(gravity:Dot(gravity) / 4, gravity:Dot(direction) - projectileSpeed^2, direction:Dot(direction)); if r1 and r2 then if r1 > 0 and r1 < r2 then return math.sqrt(r1) elseif r2 > 0 and r2 < r1 then return math.sqrt(r2) end end; return 0 end
local function projectileDrop(origin, target, projectileSpeed, acceleration) local g = Vector3.new() + Vector3.yAxis * (acceleration * 2); local t = getBallisticFlightTime(target - origin, g, projectileSpeed); return 0.5 * g * t^2 end
local function predict(target, origin, projectileSpeed, acceleration) local g = Vector3.new() + Vector3.yAxis * (acceleration * 2); local t = getBallisticFlightTime(target.Position - origin, g, projectileSpeed); return target.Position + (target.Velocity * t) end

--================================================================================
-- HOOK E LÓGICA PRINCIPAL (RenderStepped)
--================================================================================
local FovCircle = Drawing.new("Circle"); FovCircle.Visible = true; FovCircle.Thickness = 2; FovCircle.Color = Color3.fromRGB(255, 255, 255); FovCircle.Filled = false; FovCircle.NumSides = 64; FovCircle.Radius = 0

pcall(function()
    if not hookfunction then warn("Silent Aim: hookfunction não encontrado.") return end
    local success, bulletModule = pcall(require, ReplicatedStorage.Modules.FPS.Bullet)
    if not success then warn("Silent Aim: Módulo de bala não encontrado. (Não está no Project Delta?)") return end
    
    local oldBullet; oldBullet = hookfunction(bulletModule.CreateBullet, function(...)
        local args = {...}
        local aimPart = args[5]
        local target = getTarget(args[2], args[3], args[4], aimPart)
        
        if Settings.SilentAimEnabled and target then
            local ammoType = args[7]
            local bullet = ReplicatedStorage.AmmoTypes:FindFirstChild(ammoType)
            if bullet then
                local acceleration = bullet:GetAttribute("ProjectileDrop")
                local projectileSpeed = bullet:GetAttribute("MuzzleVelocity")
                bullet:SetAttribute("Drag", 0)
                
                local targetPosition = Settings.Prediction and predict(target, aimPart.Position, projectileSpeed, acceleration) or target.Position
                local vertical = projectileDrop(aimPart.Position, targetPosition, projectileSpeed, acceleration)
                args[5] = { CFrame = CFrame.new(aimPart.Position, targetPosition + vertical) }
            end
        end
        return oldBullet(unpack(args))
    end)
    warn("Silent Aim do Project Delta carregado com sucesso!")
end)


RunService.RenderStepped:Connect(function()
    FovCircle.Radius = Settings.ShowFov and Settings.FOV or 0
    if Settings.ShowFov then FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) end
    if Settings.AimbotEnabled then
        local closest, shortest = nil, Settings.FOV
        -- Sua lógica de Aimbot (sem alterações)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
                    local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    local dist2D = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    local dist3D = (Camera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if onScreen and dist2D < shortest and dist3D <= Settings.MaxDistance then
                        if Settings.WallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (player.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Unit * 500)
                            local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
                            if hit and not hit:IsDescendantOf(player.Character) then continue end
                        end
                        shortest = dist2D; closest = player
                    end
                end
            end
        end
        if closest then
            local pos = closest.Character.HumanoidRootPart.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), Settings.Smoothness)
        end
    end
end)
