-- [[ Nego Hub - Oficial Mobile Clean + Night Vision ]]

if game.CoreGui:FindFirstChild("NegoHubUI") then
    game.CoreGui.NegoHubUI:Destroy()
end

local NegoHubUI = Instance.new("ScreenGui")
NegoHubUI.Name = "NegoHubUI"
NegoHubUI.Parent = game.CoreGui
NegoHubUI.ResetOnSpawn = false

getgenv().CamlockEnabled = false
getgenv().NightVisionEnabled = false

-- Salva as configurações de iluminação originais do jogo para poder restaurar depois
local Lighting = game:GetService("Lighting")
local OriginalBrightness = Lighting.Brightness
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient

-- 📱 PAINEL PRINCIPAL (Tamanho reajustado para os 2 botões + radar)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = NegoHubUI
MainFrame.Position = UDim2.new(0.15, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 255) -- Ajustado para caber o novo botão
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 22)
MainFrame.Visible = true

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 200)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = MainFrame
UIPadding.PaddingTop = UDim.new(0, 15)

-- 🟢 BOTÃO DE ABRIR/FECHAR
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Parent = NegoHubUI
MenuButton.Position = UDim2.new(0.05, 0, 0.35, 0)
MenuButton.Size = UDim2.new(0, 90, 0, 40)
MenuButton.BackgroundColor3 = Color3.fromRGB(15, 35, 15)
MenuButton.Text = "Fechar"
MenuButton.TextColor3 = Color3.fromRGB(0, 230, 0)
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.TextSize = 22
MenuButton.Active = true
MenuButton.Draggable = true

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = MenuButton

MenuButton.MouseButton1Click:Connect(function()
    if MainFrame.Visible == true then
        MainFrame.Visible = false
        MenuButton.Text = "Abrir"
        MenuButton.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
    else
        MainFrame.Visible = true
        MenuButton.Text = "Fechar"
        MenuButton.BackgroundColor3 = Color3.fromRGB(15, 35, 15)
    end
end)

-- 🎨 CRIADOR DE BOTÕES INTERNOS
local function CriarBotao(Nome, Texto, CorTexto, Funcao)
    local Botao = Instance.new("TextButton")
    Botao.Name = Nome
    Botao.Parent = MainFrame
    Botao.Size = UDim2.new(0, 230, 0, 45)
    Botao.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
    Botao.Text = Texto
    Botao.TextColor3 = CorTexto
    Botao.Font = Enum.Font.SourceSansBold
    Botao.TextSize = 18
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Botao

    Botao.MouseButton1Click:Connect(function()
        Funcao(Botao)
    end)
    return Botao
end

-- 🛠️ CRIAÇÃO DOS COMANDOS

-- 1. Camlock
CriarBotao("CamlockBtn", "CentuDox Camlock: OFF", Color3.fromRGB(0, 180, 255), function(self)
    getgenv().CamlockEnabled = not getgenv().CamlockEnabled
    if getgenv().CamlockEnabled then
        self.Text = "CentuDox Camlock: ON"
        self.BackgroundColor3 = Color3.fromRGB(30, 50, 70)
    else
        self.Text = "CentuDox Camlock: OFF"
        self.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
    end
end)

-- 2. Night Vision (NOVO)
CriarBotao("NightVisionBtn", "Night Vision: OFF", Color3.fromRGB(0, 255, 100), function(self)
    getgenv().NightVisionEnabled = not getgenv().NightVisionEnabled
    if getgenv().NightVisionEnabled then
        self.Text = "Night Vision: ON"
        self.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
    else
        self.Text = "Night Vision: OFF"
        self.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
    end
end)

-- 📊 MONITOR DE PROXIMIDADE (Radar de Distância)
local RadarLabel = Instance.new("TextLabel")
RadarLabel.Name = "RadarLabel"
RadarLabel.Parent = MainFrame
RadarLabel.Size = UDim2.new(0, 230, 0, 45)
RadarLabel.BackgroundColor3 = Color3.fromRGB(15, 18, 22)
RadarLabel.Text = "Alvo: Nenhum"
RadarLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
RadarLabel.Font = Enum.Font.SourceSansPro
RadarLabel.TextSize = 16

local RadarCorner = Instance.new("UICorner")
RadarCorner.CornerRadius = UDim.new(0, 8)
RadarCorner.Parent = RadarLabel

-- 🎯 LÓGICA DO JOGO
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local function GetClosestPlayer()
    local ClosestTarget = nil
    local MaxDistance = 600
    local TargetName = "Nenhum"
    local RoundedDistance = 0

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local TargetPart = player.Character.HumanoidRootPart
                local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - TargetPart.Position).Magnitude

                if Distance < MaxDistance then
                    ClosestTarget = TargetPart
                    MaxDistance = Distance
                    TargetName = player.DisplayName
                    RoundedDistance = math.floor(Distance)
                end
            end
        end
    end
    return ClosestTarget, TargetName, RoundedDistance
end

RunService.RenderStepped:Connect(function()
    local Target, Name, Dist = GetClosestPlayer()
    
    -- Atualiza o texto do indicador de proximidade
    if Target then
        RadarLabel.Text = "Perto: " .. Name .. " [" .. Dist .. "m]"
        RadarLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    else
        RadarLabel.Text = "Alvo: Nenhum"
        RadarLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
    
    -- Camlock ativa
    if getgenv().CamlockEnabled and Target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
    end
    
    -- Controle do Night Vision (Atualiza dinamicamente para evitar que o jogo resete a luz)
    if getgenv().NightVisionEnabled then
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = OriginalBrightness
        Lighting.Ambient = OriginalAmbient
        Lighting.OutdoorAmbient = OriginalOutdoorAmbient
    end
end)
