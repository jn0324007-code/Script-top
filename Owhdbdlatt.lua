--[[
    Script: Sasiperere.lua (Versão com Aimbot, Silent Aim e ESP Integrados)
    [!] MÓDULO ESP: A lógica do ESP foi extraída de "árduo.lua" e integrada
    a este script, com novos botões na UI para controle total.
]]

--================================================================================
-- SERVIÇOS E VARIÁVEIS
--================================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    -- Aimbot e Silent Aim
    AimbotEnabled = false, SilentAimEnabled = false, Prediction = true,
    TeamCheck = true, WallCheck = true, ShowFov = false,
    FOV = 80, Smoothness = 0.3, MaxDistance = 500, HitPart = "Head",

    -- ESP (Extraído de árduo.lua)
    EspEnabled = false,
    EspName = false,
    EspHealth = false,
    EspDistance = false,
    EspDistanceMode = "Meters",
    EspBots = false,
    EspChams = false,
    EspDead = false,
    EspActiveGun = false,
    EspLoot = false,
    EspExtracts = false,
    EspTextOutline = true,
    EspRenderDistance = 1000,
    EspChamsFill = 0.5,
    EspChamsOutline = 0,
    EspTextSize = 14,
    EspTextColor = Color3.fromRGB(255,255,255),
    EspChamsFillColor = Color3.fromRGB(255,0,0),
    EspChamsOutlineColor = Color3.fromRGB(255,255,255)
}

-- Tabela para guardar os objetos do ESP
local espObjects = {}

--================================================================================
-- CRIAÇÃO DA INTERFACE GRÁFICA (GUI)
--================================================================================
local mainGui = Instance.new("ScreenGui", CoreGui); mainGui.Name = "DeleteMob_GUI_Final"; mainGui.ResetOnSpawn = false
local mainFrame = Instance.new("Frame", mainGui); mainFrame.Name = "DeleteMobF"; mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); mainFrame.Position = UDim2.new(0.5, -200, 0.5, -200); mainFrame.Size = UDim2.new(0, 400, 0, 550); mainFrame.Draggable = true; mainFrame.Active = true; mainFrame.Visible = true; mainFrame.ClipsDescendants = true
local frameCorner = Instance.new("UICorner", mainFrame); frameCorner.CornerRadius = UDim.new(0, 8); local frameStroke = Instance.new("UIStroke", mainFrame); frameStroke.Color = Color3.fromRGB(80, 80, 80); frameStroke.Thickness = 1
local header = Instance.new("Frame", mainFrame); header.BackgroundColor3 = Color3.fromRGB(35, 35, 35); header.Size = UDim2.new(1, 0, 0, 35); local headerStroke = Instance.new("UIStroke", header); headerStroke.Color = Color3.fromRGB(80, 80, 80); headerStroke.Thickness = 1
local titleLabel = Instance.new("TextLabel", header); titleLabel.BackgroundTransparency = 1; titleLabel.Position = UDim2.new(0.05, 0, 0, 0); titleLabel.Size = UDim2.new(0.9, 0, 1, 0); titleLabel.Font = Enum.Font.GothamBold; titleLabel.Text = "DeleteMob | Cheat Engine"; titleLabel.TextColor3 = Color3.fromRGB(17, 223, 255); titleLabel.TextSize = 20; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
local openCloseButton = Instance.new("TextButton", mainGui); openCloseButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25); openCloseButton.Size = UDim2.new(0, 150, 0, 30); openCloseButton.Position = UDim2.new(0.5, -75, 0.05, 0); openCloseButton.Font = Enum.Font.GothamBold; openCloseButton.Text = "Abrir / Fechar"; openCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255); openCloseButton.TextSize = 16; openCloseButton.ZIndex = 12
local ocCorner = Instance.new("UICorner", openCloseButton); ocCorner.CornerRadius = UDim.new(0, 6); local ocStroke = Instance.new("UIStroke", openCloseButton); ocStroke.Color = Color3.fromRGB(80, 80, 80); ocStroke.Thickness = 1
local buttonContainer = Instance.new("ScrollingFrame", mainFrame); buttonContainer.BackgroundTransparency = 1; buttonContainer.Position = UDim2.new(0.05, 0, 0, 45); buttonContainer.Size = UDim2.new(0.9, 0, 1, -55); buttonContainer.BorderSizePixel = 0; buttonContainer.ScrollBarThickness = 4
local listLayout = Instance.new("UIListLayout", buttonContainer); listLayout.SortOrder = Enum.SortOrder.LayoutOrder; listLayout.Padding = UDim.new(0, 8)
local COLOR_ACCENT, COLOR_OFF, COLOR_HOVER = Color3.fromRGB(17, 223, 255), Color3.fromRGB(52, 52, 52), Color3.fromRGB(70, 70, 70)
local function CreateButton(text) local button = Instance.new("TextButton"); button.Parent = buttonContainer; button.BackgroundColor3 = COLOR_OFF; button.Size = UDim2.new(1, 0, 0, 30); button.Font = Enum.Font.Gotham; button.Text = text; button.TextColor3 = Color3.fromRGB(255, 255, 255); button.TextSize = 16; local corner = Instance.new("UICorner", button); corner.CornerRadius = UDim.new(0, 6); local stroke = Instance.new("UIStroke", button); stroke.Color = Color3.fromRGB(80, 80, 80); stroke.Thickness = 1; button.MouseEnter:Connect(function() if not button:GetAttribute("IsActive") then TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_HOVER}):Play() end end); button.MouseLeave:Connect(function() if not button:GetAttribute("IsActive") then TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_OFF}):Play() end end); return button end

-- Botões do Aimbot/Silent
local aimbotEnableButton = CreateButton("Aimbot: OFF"); local silentAimEnableButton = CreateButton("Silent Aim: OFF"); local predictionButton = CreateButton("Prediction: ON"); local targetPartButton = CreateButton("Target Part: Head"); local aimbotWallCheckButton = CreateButton("WallCheck: ON"); local aimbotTeamCheckButton = CreateButton("TeamCheck: ON"); local aimbotShowFovButton = CreateButton("Show FOV: OFF"); local fovButton = CreateButton("FOV: 80"); local smoothnessButton = CreateButton("Suavidade: 0.3"); local distanceButton = CreateButton("Distância: 500")

-- Separador para ESP
local espSeparator = Instance.new("TextLabel", buttonContainer); espSeparator.BackgroundTransparency = 1; espSeparator.Size = UDim2.new(1,0,0,20); espSeparator.Font = Enum.Font.GothamBold; espSeparator.Text = "--- ESP ---"; espSeparator.TextColor3 = Color3.fromRGB(150, 150, 150); espSeparator.TextSize = 14;

-- Botões do ESP
local espEnableButton = CreateButton("ESP: OFF"); local espNameButton = CreateButton("ESP Name: OFF"); local espHealthButton = CreateButton("ESP Health: OFF"); local espDistanceButton = CreateButton("ESP Distance: OFF"); local espChamsButton = CreateButton("ESP Chams: OFF"); local espActiveGunButton = CreateButton("ESP Active Gun: OFF"); local espDeadButton = CreateButton("ESP Dead: OFF"); local espBotsButton = CreateButton("ESP Bots: OFF"); local espLootButton = CreateButton("ESP Loot: OFF"); local espExtractsButton = CreateButton("ESP Extracts: OFF");

--================================================================================
-- FUNÇÕES DO SILENT AIM
--================================================================================
local SilentAimFunctions = {}
function SilentAimFunctions:IsAlive(Player) return Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 end
function SilentAimFunctions:IsVisible(Part) local RayParams = RaycastParams.new(); RayParams.FilterType = Enum.RaycastFilterType.Exclude; RayParams.FilterDescendantsInstances = (SilentAimFunctions:IsAlive(LocalPlayer) and {LocalPlayer.Character, Camera} or {Camera}); RayParams.IgnoreWater = true; local Direction = (Part.Position - Camera.CFrame.Position); local ray = workspace:Raycast(Camera.CFrame.Position, Direction.Unit * 9999, RayParams); return ray and ray.Instance and ray.Instance:IsDescendantOf(Part.Parent) end
function SilentAimFunctions:GetClosestToCenter() local Closest, Part = Settings.FOV, nil; local CenterScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2); for _,Player in pairs(Players:GetChildren()) do if Player ~= LocalPlayer and SilentAimFunctions:IsAlive(Player) and not (Settings.TeamCheck and Player.Team == LocalPlayer.Team) then local HitPart = Player.Character:FindFirstChild(Settings.HitPart); if HitPart then if not Settings.WallCheck or SilentAimFunctions:IsVisible(HitPart) then local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(HitPart.Position); if OnScreen then local Distance = (CenterScreen - Vector2.new(ScreenPosition.X, ScreenPosition.Y)).Magnitude; if Distance < Closest then Closest = Distance; Part = HitPart end end end end end end; return Part end
function SilentAimFunctions:Prediction(Part, Muzzlevelosity, Drag) local Distance = (Camera.CFrame.Position - Part.Position).Magnitude; local Time = Distance / Muzzlevelosity; local Speed = Muzzlevelosity - Drag * Muzzlevelosity^2 * Time^2; Time = Time + (Distance / Speed); return Part.CFrame.Position + (Part.Velocity * Time) end
function SilentAimFunctions:BulletDrop(From, To, MuzzleVelocity, Drag, Drop) local Distance = (From - To).Magnitude; local Time = Distance / MuzzleVelocity; local Speed = MuzzleVelocity - Drag * MuzzleVelocity^2 * Time^2; Time = Time + (Distance / Speed); local vector = Drop * Time^2; return vector end

--================================================================================
-- SISTEMA DE HOOK (CRIAR E DESTRUIR)
--================================================================================
local BulletModule = nil; local IsHooked = false
pcall(function() BulletModule = require(ReplicatedStorage.Modules.FPS.Bullet) end)
if not BulletModule then warn("Módulo de Bala do Project Delta não encontrado.") end

local function ActivateHook()
    if IsHooked or not BulletModule or not hookfunction or not newcclosure then return end
    IsHooked = true
    local OldBullet; OldBullet = hookfunction(BulletModule.CreateBullet, newcclosure(function(...)
        local Args = {...}
        if Settings.SilentAimEnabled and not checkcaller() then
            local Target = SilentAimFunctions:GetClosestToCenter()
            if Target then
                local originalAimPart = Args[5]
                local ammoTypeName = tostring(Args[7])
                local AmmoType = ReplicatedStorage.AmmoTypes:FindFirstChild(ammoTypeName)
                if AmmoType and typeof(originalAimPart) == "Instance" then
                    pcall(function()
                        local Prediction = SilentAimFunctions:Prediction(Target, AmmoType:GetAttribute("MuzzleVelocity"), AmmoType:GetAttribute("Drag"))
                        local PredictedDrop = SilentAimFunctions:BulletDrop(Camera.CFrame.Position, Prediction, AmmoType:GetAttribute("MuzzleVelocity"), AmmoType:GetAttribute("Drag"), AmmoType:GetAttribute("ProjectileDrop"))
                        local finalTargetPosition = Prediction + Vector3.new(0, PredictedDrop, 0)
                        local newAimArgument = { CFrame = CFrame.new(originalAimPart.CFrame.Position, finalTargetPosition) }
                        Args[5] = newAimArgument
                    end)
                end
            end
        end
        return OldBullet(unpack(Args))
    end))
    warn("Hook do Silent Aim ATIVADO.")
end

local function DeactivateHook()
    if not IsHooked or not BulletModule or not unhookfunction then return end
    unhookfunction(BulletModule.CreateBullet)
    IsHooked = false
    warn("Hook do Silent Aim DESTRUÍDO.")
end

--================================================================================
-- LÓGICA E FUNÇÕES DO ESP (Extraído de árduo.lua)
--================================================================================
local function setupEsp(obj, dtype, otype1)
    if not obj then return end

    local dobj
    local tableinfo
    if dtype == "Name" then
        dobj = Drawing.new("Text")
        dobj.Visible = Settings.EspEnabled
        dobj.Center = true
        dobj.Outline = Settings.EspTextOutline
        dobj.Size = Settings.EspTextSize
        dobj.Color = Settings.EspTextColor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = { primary = obj, type = "Name", otype = otype1 }
    elseif dtype == "HP" then
        dobj = Drawing.new("Text")
        dobj.Visible = Settings.EspEnabled
        dobj.Center = true
        dobj.Outline = Settings.EspTextOutline
        dobj.Size = Settings.EspTextSize
        dobj.Color = Settings.EspTextColor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = { primary = obj, type = "HP", otype = otype1 }
    elseif dtype == "Distance" then
        dobj = Drawing.new("Text")
        dobj.Visible = Settings.EspEnabled
        dobj.Center = true
        dobj.Outline = Settings.EspTextOutline
        dobj.Size = Settings.EspTextSize
        dobj.Color = Settings.EspTextColor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = { primary = obj, type = "Distance", otype = otype1 }
    elseif dtype == "Hotbar" then
        dobj = Drawing.new("Text")
        dobj.Visible = Settings.EspEnabled
        dobj.Center = true
        dobj.Outline = Settings.EspTextOutline
        dobj.Size = Settings.EspTextSize
        dobj.Color = Settings.EspTextColor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = { primary = obj, type = "Hotbar", otype = otype1 }
    elseif dtype == "Highlight" then
        dobj = Instance.new("Highlight")
        dobj.Name = "Sasiperere_ESP_Highlight"
        dobj.FillColor = Settings.EspChamsFillColor
        dobj.OutlineColor = Settings.EspChamsOutlineColor
        dobj.FillTransparency = Settings.EspChamsFill
        dobj.OutlineTransparency = Settings.EspChamsOutline
        if obj.Parent and obj.Parent:IsA("Model") then
            dobj.Parent = obj.Parent
        else
            dobj:Destroy()
            return
        end
        dobj.Enabled = Settings.EspChams
        tableinfo = { primary = obj, type = "Highlight", otype = otype1 }
    end

    if dobj == nil or tableinfo == nil then return end

    local removing
    local function selfDestruct()
        if dtype == "Highlight" then
            dobj.Enabled = false
            dobj:Destroy()
        else
            dobj.Visible = false
            dobj:Remove()
        end
        if removing then
            removing:Disconnect()
            removing = nil
        end
    end

    if espObjects[dobj] then
        selfDestruct()
        return
    else
        espObjects[dobj] = tableinfo
    end

    removing = obj:GetAncestryChanged():Connect(function()
        if not obj or not obj.Parent then
            espObjects[dobj] = nil
            selfDestruct()
        end
    end)
end

local function startEsp(v, otype)
    if not v then return end

    task.spawn(function()
        if otype == "Extract" then
            setupEsp(v, "Name", otype)
            setupEsp(v, "Distance", otype)
        elseif otype == "Loot" then
            local valcache = { ["6B45"] = 16, ["AS Val"] = 16, ["ATC Key"] = 6, ["Airfield Key"] = 6, ["Altyn"] = 16, ["Altyn Visor"] = 8, ["Maska Visor"] = 8, ["Attak-5 60L"] = 16, ["Bolts"] = 1, ["Crane Key"] = 6, ["DAGR"] = 12, ["Duct Tape"] = 1, ["Fast MT"] = 10, ["Flare Gun"] = 20, ["Fueling Station Key"] = 2, ["Garage Key"] = 4, ["Hammer"] = 1, ["JPC"] = 10, ["Lighthouse Key"] = 6, ["M4A1"] = 12, ["Nails"] = 1, ["Nuts"] = 1, ["Saiga 12"] = 8, ["Super Glue"] = 1, ["Village Key"] = 2, ["Wrench"] = 1, ["SPSh-44"] = 12, ["R700"] = 16, ["AKMN"] = 12, ["Mosin"] = 12, ["SVD"] = 12, ["7.62x39AP"] = 0.15, ["7.62x54AP"] = 0.15 }
            local Value = 0
            if v.Parent and v.Parent:FindFirstChild("Inventory") then
                for _, i in ipairs(v.Parent.Inventory:GetChildren()) do
                    local Amount = i.ItemProperties:GetAttribute("Amount") or 1
                    Value = Value + (valcache[i.ItemProperties:GetAttribute("CallSign")] or 0) * Amount
                end
                if Value >= 4 then
                    setupEsp(v, "Name", otype)
                    setupEsp(v, "Hotbar", otype)
                    setupEsp(v, "Distance", otype)
                end
            end
        elseif otype == "Dead" then
            local hd = v:WaitForChild("Head", 1)
            if hd == nil then return end
            setupEsp(hd, "Name", otype)
            setupEsp(hd, "Distance", otype)
        else
            local hd = v:WaitForChild("Head", 1)
            if hd == nil then return end
            setupEsp(hd, "Name", otype)
            setupEsp(hd, "HP", otype)
            setupEsp(hd, "Distance", otype)
            setupEsp(hd, "Hotbar", otype)
            setupEsp(hd, "Highlight", otype) 
        end
    end)
end

--================================================================================
-- CONEXÕES DOS BOTÕES
--================================================================================
local function UpdateButtonState(button, isActive, textPrefix) button.Text = textPrefix .. (isActive and "ON" or "OFF"); button:SetAttribute("IsActive", isActive); local targetColor = isActive and COLOR_ACCENT or COLOR_OFF; TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play() end
-- Aimbot/Silent
UpdateButtonState(aimbotEnableButton, Settings.AimbotEnabled, "Aimbot: "); UpdateButtonState(silentAimEnableButton, Settings.SilentAimEnabled, "Silent Aim: "); UpdateButtonState(predictionButton, Settings.Prediction, "Prediction: "); UpdateButtonState(aimbotWallCheckButton, Settings.WallCheck, "WallCheck: "); UpdateButtonState(aimbotTeamCheckButton, Settings.TeamCheck, "TeamCheck: "); UpdateButtonState(aimbotShowFovButton, Settings.ShowFov, "Show FOV: ")
-- ESP
UpdateButtonState(espEnableButton, Settings.EspEnabled, "ESP: "); UpdateButtonState(espNameButton, Settings.EspName, "ESP Name: "); UpdateButtonState(espHealthButton, Settings.EspHealth, "ESP Health: "); UpdateButtonState(espDistanceButton, Settings.EspDistance, "ESP Distance: "); UpdateButtonState(espChamsButton, Settings.EspChams, "ESP Chams: "); UpdateButtonState(espActiveGunButton, Settings.EspActiveGun, "ESP Active Gun: "); UpdateButtonState(espDeadButton, Settings.EspDead, "ESP Dead: "); UpdateButtonState(espBotsButton, Settings.EspBots, "ESP Bots: "); UpdateButtonState(espLootButton, Settings.EspLoot, "ESP Loot: "); UpdateButtonState(espExtractsButton, Settings.EspExtracts, "ESP Extracts: ");

-- Conexões Aimbot/Silent
aimbotEnableButton.MouseButton1Click:Connect(function() Settings.AimbotEnabled = not Settings.AimbotEnabled; if Settings.AimbotEnabled then Settings.SilentAimEnabled = false; DeactivateHook() end; UpdateButtonState(aimbotEnableButton, Settings.AimbotEnabled, "Aimbot: "); UpdateButtonState(silentAimEnableButton, Settings.SilentAimEnabled, "Silent Aim: ") end)
silentAimEnableButton.MouseButton1Click:Connect(function() Settings.SilentAimEnabled = not Settings.SilentAimEnabled; if Settings.SilentAimEnabled then Settings.AimbotEnabled = false; ActivateHook() else DeactivateHook() end; UpdateButtonState(silentAimEnableButton, Settings.SilentAimEnabled, "Silent Aim: "); UpdateButtonState(aimbotEnableButton, Settings.AimbotEnabled, "Aimbot: ") end)
predictionButton.MouseButton1Click:Connect(function() Settings.Prediction = not Settings.Prediction; UpdateButtonState(predictionButton, Settings.Prediction, "Prediction: ") end)
targetPartButton.MouseButton1Click:Connect(function() if Settings.HitPart == "Head" then Settings.HitPart = "HumanoidRootPart"; targetPartButton.Text = "Target Part: Torso" else Settings.HitPart = "Head"; targetPartButton.Text = "Target Part: Head" end end)
aimbotWallCheckButton.MouseButton1Click:Connect(function() Settings.WallCheck = not Settings.WallCheck; UpdateButtonState(aimbotWallCheckButton, Settings.WallCheck, "WallCheck: ") end)
aimbotTeamCheckButton.MouseButton1Click:Connect(function() Settings.TeamCheck = not Settings.TeamCheck; UpdateButtonState(aimbotTeamCheckButton, Settings.TeamCheck, "TeamCheck: ") end)
aimbotShowFovButton.MouseButton1Click:Connect(function() Settings.ShowFov = not Settings.ShowFov; UpdateButtonState(aimbotShowFovButton, Settings.ShowFov, "Show FOV: ") end)
local function createInputForButton(button, settingName, min, max, format) button.MouseButton1Click:Connect(function() button.Visible = false; local input = Instance.new("TextBox"); input.Parent = button.Parent; input.Size, input.Position, input.ZIndex = button.Size, button.Position, button.ZIndex + 1; input.Font, input.TextSize, input.TextColor3 = button.Font, button.TextSize, button.TextColor3; input.BackgroundColor3 = COLOR_HOVER; input.ClearTextOnFocus, input.PlaceholderText = true, tostring(min).."-"..tostring(max); local c = Instance.new("UICorner", input); c.CornerRadius = UDim.new(0, 6); local s = Instance.new("UIStroke", input); s.Color = Color3.fromRGB(80, 80, 80); s.Thickness = 1; input:CaptureFocus(); input.FocusLost:Connect(function(enter) if enter then local v = tonumber(input.Text); if v and v >= min and v <= max then Settings[settingName] = v; button.Text = string.format(format, v) end end; input:Destroy(); button.Visible = true end) end) end
createInputForButton(fovButton, "FOV", 1, 999, "FOV: %d"); createInputForButton(smoothnessButton, "Smoothness", 0.1, 1.0, "Suavidade: %.1f"); createInputForButton(distanceButton, "MaxDistance", 1, 1000, "Distância: %d")

-- Conexões ESP
espEnableButton.MouseButton1Click:Connect(function() Settings.EspEnabled = not Settings.EspEnabled; UpdateButtonState(espEnableButton, Settings.EspEnabled, "ESP: ") end)
espNameButton.MouseButton1Click:Connect(function() Settings.EspName = not Settings.EspName; UpdateButtonState(espNameButton, Settings.EspName, "ESP Name: ") end)
espHealthButton.MouseButton1Click:Connect(function() Settings.EspHealth = not Settings.EspHealth; UpdateButtonState(espHealthButton, Settings.EspHealth, "ESP Health: ") end)
espDistanceButton.MouseButton1Click:Connect(function() Settings.EspDistance = not Settings.EspDistance; UpdateButtonState(espDistanceButton, Settings.EspDistance, "ESP Distance: ") end)
espChamsButton.MouseButton1Click:Connect(function() Settings.EspChams = not Settings.EspChams; UpdateButtonState(espChamsButton, Settings.EspChams, "ESP Chams: ") end)
espActiveGunButton.MouseButton1Click:Connect(function() Settings.EspActiveGun = not Settings.EspActiveGun; UpdateButtonState(espActiveGunButton, Settings.EspActiveGun, "ESP Active Gun: ") end)
espDeadButton.MouseButton1Click:Connect(function() Settings.EspDead = not Settings.EspDead; UpdateButtonState(espDeadButton, Settings.EspDead, "ESP Dead: ") end)
espBotsButton.MouseButton1Click:Connect(function() Settings.EspBots = not Settings.EspBots; UpdateButtonState(espBotsButton, Settings.EspBots, "ESP Bots: ") end)
espLootButton.MouseButton1Click:Connect(function() Settings.EspLoot = not Settings.EspLoot; UpdateButtonState(espLootButton, Settings.EspLoot, "ESP Loot: ") end)
espExtractsButton.MouseButton1Click:Connect(function() Settings.EspExtracts = not Settings.EspExtracts; UpdateButtonState(espExtractsButton, Settings.EspExtracts, "ESP Extracts: ") end)

local menuVisible = true; openCloseButton.MouseButton1Click:Connect(function() menuVisible = not menuVisible; local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out); local goal = {Position = menuVisible and UDim2.new(0.5, -200, 0.5, -275) or UDim2.new(0.5, -200, -1, 0)}; TweenService:Create(mainFrame, tweenInfo, goal):Play() end)

--================================================================================
-- LÓGICA DE DESCOBERTA DO ESP
--================================================================================
local function scanWorkspaceForEsp()
    for i, v in ipairs(workspace:GetDescendants()) do
        if v and v:FindFirstChild("Humanoid") and v ~= LocalPlayer.Character then
            if Players:FindFirstChild(v.Name) and not v:FindFirstAncestor("DroppedItems") then
                startEsp(v, "Player")
            elseif v:FindFirstAncestor("AiZones") then
                startEsp(v, "Bot")
            elseif v:FindFirstAncestor("DroppedItems") then
                startEsp(v, "Dead")
            end
        elseif v.Parent == workspace:FindFirstChild("NoCollision"):FindFirstChild("ExitLocations") then
            startEsp(v, "Extract")
        elseif v:FindFirstAncestor("Containers") and v:IsA("MeshPart") then
            if v.Parent and v.Parent:IsA("Model") then
                startEsp(v, "Loot")
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(v)
    if v and v.Parent and v:IsA("BasePart") and v.Name == "Head" then
        local hum = v.Parent:WaitForChild("Humanoid", 1)
        if hum and v.Parent ~= LocalPlayer.Character then
            if Players:FindFirstChild(v.Parent.Name) and not v:FindFirstAncestor("DroppedItems") then
                startEsp(v.Parent, "Player")
            elseif v:FindFirstAncestor("AiZones") then
                startEsp(v.Parent, "Bot")
            elseif v:FindFirstAncestor("DroppedItems") then
                startEsp(v.Parent, "Dead")
            end
        end
    elseif v.Parent and v.Parent == workspace:FindFirstChild("NoCollision"):FindFirstChild("ExitLocations") then
        startEsp(v, "Extract")
    elseif v:FindFirstAncestor("Containers") and v:IsA("MeshPart") then
        if v.Parent and v.Parent:IsA("Model") then
            startEsp(v, "Loot")
        end
    end
end)

scanWorkspaceForEsp() -- Scan inicial

--================================================================================
-- LÓGICA DE RENDERIZAÇÃO
--================================================================================
local FovCircle = Drawing.new("Circle"); FovCircle.Visible = true; FovCircle.Thickness = 2; FovCircle.Color = Color3.fromRGB(255, 255, 255); FovCircle.Filled = false; FovCircle.NumSides = 64; FovCircle.Radius = 0
local currentTarget = nil
RunService.RenderStepped:Connect(function()
    -- Lógica do FOV Circle e Aimbot
    if Settings.ShowFov then
        FovCircle.Radius = Settings.FOV; FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        if Settings.SilentAimEnabled then currentTarget = SilentAimFunctions:GetClosestToCenter(); FovCircle.Color = currentTarget and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255) else FovCircle.Color = Color3.fromRGB(255, 255, 255) end
    else FovCircle.Radius = 0 end
    if Settings.AimbotEnabled then
        local closest, shortest = nil, Settings.FOV; local CenterScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position); if onScreen then local dist2D = (Vector2.new(pos.X, pos.Y) - CenterScreen).Magnitude; local dist3D = (Camera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude; if dist2D < shortest and dist3D <= Settings.MaxDistance then if Settings.WallCheck and not SilentAimFunctions:IsVisible(player.Character.HumanoidRootPart) then continue end; shortest = dist2D; closest = player end end
            end
        end
        if closest then local pos = closest.Character.HumanoidRootPart.Position; Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), Settings.Smoothness) end
    end

    -- Lógica de Renderização do ESP
    for dobj, info in pairs(espObjects) do
        if not info or not info.primary or not info.primary.Parent then
            espObjects[dobj] = nil
            if info.type == "Highlight" then dobj:Destroy() else dobj:Remove() end
            continue
        end

        local obj, isHumanoid
        if info.otype == "Extract" or info.otype == "Loot" then
            obj = info.primary
            isHumanoid = true 
        else
            obj = info.primary.Parent:FindFirstChild("UpperTorso")
            if not obj then espObjects[dobj] = nil; if info.type == "Highlight" then dobj:Destroy() else dobj:Remove() end; continue end
            isHumanoid = obj.Parent:FindFirstChild("Humanoid")
        end
        
        local metersdist = (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart) and math.floor((LocalPlayer.Character.PrimaryPart.Position - obj.Position).Magnitude * 0.3336) or 0
        local onScreen, screenPos = Camera:WorldToScreenPoint(obj.Position)

        local isVisible = Settings.EspEnabled and onScreen and isHumanoid and metersdist < Settings.EspRenderDistance
        
        if info.otype == "Bot" and not Settings.EspBots then isVisible = false end
        if info.otype == "Dead" and not Settings.EspDead then isVisible = false end
        if info.otype == "Extract" and not Settings.EspExtracts then isVisible = false end
        if info.otype == "Loot" and not Settings.EspLoot then isVisible = false end

        if info.type == "Highlight" then
            dobj.Enabled = isVisible and Settings.EspChams
            if dobj.Enabled then
                 dobj.FillColor = Settings.EspChamsFillColor
                 dobj.OutlineColor = Settings.EspChamsOutlineColor
                 dobj.FillTransparency = Settings.EspChamsFill
                 dobj.OutlineTransparency = Settings.EspChamsOutline
            end
        else
            dobj.Visible = isVisible
            if isVisible then
                local resultpos = Vector2.new(screenPos.X, screenPos.Y)
                dobj.Size = Settings.EspTextSize
                dobj.Color = Settings.EspTextColor
                dobj.Outline = Settings.EspTextOutline

                if info.type == "Name" and Settings.EspName then
                    dobj.Position = resultpos - Vector2.new(0, 15)
                    if info.otype == "Extract" then dobj.Text = obj.Name
                    elseif info.otype == "Dead" then dobj.Text = obj.Parent.Name .. " [DEAD]"
                    else dobj.Text = obj.Parent.Name end
                elseif info.type == "HP" and Settings.EspHealth and info.otype ~= "Dead" then
                    dobj.Position = resultpos - Vector2.new(0, 30)
                    dobj.Text = math.floor(obj.Parent.Humanoid.Health) .. "HP"
                elseif info.type == "Distance" and Settings.EspDistance then
                    dobj.Position = resultpos - Vector2.new(0, 45)
                    local distText = Settings.EspDistanceMode == "Meters" and metersdist .. "m" or math.floor(metersdist / 0.3336) .. "s"
                    dobj.Text = distText
                elseif info.type == "Hotbar" and Settings.EspActiveGun and info.otype ~= "Dead" then
                     dobj.Position = resultpos + Vector2.new(0, 15)
                     local hotgun = "None"
                     if info.otype == "Loot" then
                         -- Para loot, mostrar valor
                         hotgun = "" -- Implementar se necessário
                     else
                         for _, v in ipairs(obj.Parent:GetChildren()) do
                             if v:FindFirstChild("ItemRoot") then
                                 hotgun = v.Name
                                 break
                             end
                         end
                     end
                     dobj.Text = hotgun
                else
                    dobj.Visible = false
                end
            end
        end
    end
end)
