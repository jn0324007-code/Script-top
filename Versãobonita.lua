--[[
    Script: Sasiperere.lua (Versão Beautified CORRIGIDA)
    [!] CORREÇÃO: A lógica para editar os valores de FOV, Suavidade e Distância
    foi restaurada. Agora é possível clicar nos botões para alterar os valores.
]]

--================================================================================
-- SERVIÇOS E VARIÁVEIS
--================================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AimbotEnabled = false, TeamCheck = true, WallCheck = true,
    ShowFov = false, FOV = 80, Smoothness = 0.3, MaxDistance = 500
}

--================================================================================
-- CRIAÇÃO DA INTERFACE GRÁFICA (GUI)
--================================================================================
local mainGui = Instance.new("ScreenGui", CoreGui)
mainGui.Name = "DeleteMob_GUI_Modern"
mainGui.ResetOnSpawn = false

-- Interface Principal
local mainFrame = Instance.new("Frame", mainGui)
mainFrame.Name = "DeleteMobF"
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -160)
mainFrame.Size = UDim2.new(0, 400, 0, 320)
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Visible = true
mainFrame.ClipsDescendants = true
local frameCorner = Instance.new("UICorner", mainFrame)
frameCorner.CornerRadius = UDim.new(0, 8)
local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Color = Color3.fromRGB(80, 80, 80)
frameStroke.Thickness = 1

-- Header
local header = Instance.new("Frame", mainFrame)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
header.Size = UDim2.new(1, 0, 0, 35)
local headerStroke = Instance.new("UIStroke", header)
headerStroke.Color = Color3.fromRGB(80, 80, 80)
headerStroke.Thickness = 1

local titleLabel = Instance.new("TextLabel", header)
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
titleLabel.Size = UDim2.new(0.9, 0, 1, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "DeleteMob | Cheat Engine"
titleLabel.TextColor3 = Color3.fromRGB(17, 223, 255)
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Botão de Abrir/Fechar
local openCloseButton = Instance.new("TextButton", mainGui)
openCloseButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
openCloseButton.Size = UDim2.new(0, 150, 0, 30)
openCloseButton.Position = UDim2.new(0.5, -75, 0.05, 0)
openCloseButton.Font = Enum.Font.GothamBold
openCloseButton.Text = "Abrir / Fechar"
openCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openCloseButton.TextSize = 16
openCloseButton.ZIndex = 12
local ocCorner = Instance.new("UICorner", openCloseButton)
ocCorner.CornerRadius = UDim.new(0, 6)
local ocStroke = Instance.new("UIStroke", openCloseButton)
ocStroke.Color = Color3.fromRGB(80, 80, 80)
ocStroke.Thickness = 1

-- Container para os botões
local buttonContainer = Instance.new("ScrollingFrame", mainFrame)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Position = UDim2.new(0.05, 0, 0, 45)
buttonContainer.Size = UDim2.new(0.9, 0, 1, -55)
buttonContainer.BorderSizePixel = 0
buttonContainer.ScrollBarThickness = 4

local listLayout = Instance.new("UIListLayout", buttonContainer)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)

-- Cores
local COLOR_ACCENT = Color3.fromRGB(17, 223, 255)
local COLOR_OFF = Color3.fromRGB(52, 52, 52)
local COLOR_HOVER = Color3.fromRGB(70, 70, 70)

-- Função para criar botões com o novo estilo
local function CreateButton(text)
    local button = Instance.new("TextButton")
    button.Parent = buttonContainer
    button.BackgroundColor3 = COLOR_OFF
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16

    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", button)
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
    
    button.MouseEnter:Connect(function() if not button:GetAttribute("IsActive") then TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_HOVER}):Play() end end)
    button.MouseLeave:Connect(function() if not button:GetAttribute("IsActive") then TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_OFF}):Play() end end)

    return button
end

local aimbotEnableButton = CreateButton("Aimbot: OFF")
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

-- Configurar estado inicial
UpdateButtonState(aimbotEnableButton, Settings.AimbotEnabled, "Aimbot: ")
UpdateButtonState(aimbotWallCheckButton, Settings.WallCheck, "WallCheck: ")
UpdateButtonState(aimbotTeamCheckButton, Settings.TeamCheck, "TeamCheck: ")
UpdateButtonState(aimbotShowFovButton, Settings.ShowFov, "Show FOV: ")

-- Conexões de clique para botões de toggle
aimbotEnableButton.MouseButton1Click:Connect(function() Settings.AimbotEnabled = not Settings.AimbotEnabled; UpdateButtonState(aimbotEnableButton, Settings.AimbotEnabled, "Aimbot: ") end)
aimbotWallCheckButton.MouseButton1Click:Connect(function() Settings.WallCheck = not Settings.WallCheck; UpdateButtonState(aimbotWallCheckButton, Settings.WallCheck, "WallCheck: ") end)
aimbotTeamCheckButton.MouseButton1Click:Connect(function() Settings.TeamCheck = not Settings.TeamCheck; UpdateButtonState(aimbotTeamCheckButton, Settings.TeamCheck, "TeamCheck: ") end)
aimbotShowFovButton.MouseButton1Click:Connect(function() Settings.ShowFov = not Settings.ShowFov; UpdateButtonState(aimbotShowFovButton, Settings.ShowFov, "Show FOV: ") end)

-- [!] LÓGICA DE INPUT RESTAURADA E ESTILIZADA
local function createInputForButton(button, settingName, min, max, format)
    button.MouseButton1Click:Connect(function()
        button.Visible = false
        local input = Instance.new("TextBox")
        input.Parent = button.Parent
        input.Size, input.Position, input.ZIndex = button.Size, button.Position, button.ZIndex + 1
        input.Font, input.TextSize, input.TextColor3 = button.Font, button.TextSize, button.TextColor3
        input.BackgroundColor3 = COLOR_HOVER
        input.ClearTextOnFocus, input.PlaceholderText = true, tostring(min).."-"..tostring(max)
        
        local c = Instance.new("UICorner", input); c.CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", input); s.Color = Color3.fromRGB(80, 80, 80); s.Thickness = 1
        input:CaptureFocus()
        
        input.FocusLost:Connect(function(enter)
            if enter then
                local v = tonumber(input.Text)
                if v and v >= min and v <= max then
                    Settings[settingName] = v
                    button.Text = string.format(format, v)
                end
            end
            input:Destroy()
            button.Visible = true
        end)
    end)
end

createInputForButton(fovButton, "FOV", 1, 999, "FOV: %d")
createInputForButton(smoothnessButton, "Smoothness", 0.1, 1.0, "Suavidade: %.1f")
createInputForButton(distanceButton, "MaxDistance", 1, 1000, "Distância: %d")

-- Animação de Abrir/Fechar
local menuVisible = true
openCloseButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local goal = {Position = menuVisible and UDim2.new(0.5, -200, 0.5, -160) or UDim2.new(0.5, -200, -1, 0)}
    TweenService:Create(mainFrame, tweenInfo, goal):Play()
end)

--================================================================================
-- LÓGICA PRINCIPAL (RenderStepped)
--================================================================================
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = true
FovCircle.Thickness = 2
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false
FovCircle.NumSides = 64
FovCircle.Radius = 0

RunService.RenderStepped:Connect(function()
    FovCircle.Radius = Settings.ShowFov and Settings.FOV or 0
    if Settings.ShowFov then FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) end
    if Settings.AimbotEnabled then
        local closest, shortest = nil, Settings.FOV
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
