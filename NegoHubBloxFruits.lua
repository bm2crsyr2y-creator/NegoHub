-- [[ Nego Hub - Oficial Mobile Atualizado ]]

if game.CoreGui:FindFirstChild("NegoHubUI") then
    game.CoreGui.NegoHubUI:Destroy()
end

local NegoHubUI = Instance.new("ScreenGui")
NegoHubUI.Name = "NegoHubUI"
NegoHubUI.Parent = game.CoreGui
NegoHubUI.ResetOnSpawn = false

getgenv().CamlockEnabled = false
getgenv().AimbotSkills = false
getgenv().AutoV4 = false

-- 🟢 BOTÃO DE ABRIR/FECHAR
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Parent = NegoHubUI
MenuButton.Position = UDim2.new(0.05, 0, 0.35, 0)
MenuButton.Size = UDim2.new(0, 90, 0, 40)
MenuButton.BackgroundColor3 = Color3.fromRGB(15, 35, 15)
MenuButton.Text = "Menu"
MenuButton.TextColor3 = Color3.fromRGB(0, 230, 0)
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.TextSize = 24
MenuButton.Active = true
MenuButton.Draggable = true

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = MenuButton

-- 📱 PAINEL PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = NegoHubUI
MainFrame.Position = UDim2.new(0.15, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 320)
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

-- 🎨 CRIADOR DE BOTÕES EMPILHADOS
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

CriarBotao("AimbotSkillsBtn", "Aimbot Skills: OFF", Color3.fromRGB(255, 50, 150), function(self)
    getgenv().AimbotSkills = not getgenv().AimbotSkills
    if getgenv().AimbotSkills then
        self.Text = "Aimbot Skills: ON"
        self.BackgroundColor3 = Color3.fromRGB(70, 30, 50)
    else
        self.Text = "Aimbot Skills: OFF"
        self.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
    end
end)

CriarBotao("AutoV4Btn", "Auto V4: OFF", Color3.fromRGB(255, 200, 0), function(self)
    getgenv().AutoV4 = not getgenv().AutoV4
    if getgenv().AutoV4 then
        self.Text = "Auto V4: ON"
        self.BackgroundColor3 = Color3.fromRGB(60, 50, 20)
    else
        self.Text = "Auto V4: OFF"
        self.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
    end
end)

MenuButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 🎯 SISTEMA PVP INTERNO (MIRA, SKILLS E AUTO V4)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local function GetClosestPlayer()
    local ClosestTarget = nil
    local MaxDistance = 600

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local TargetPart = player.Character.HumanoidRootPart
                local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - TargetPart.Position).Magnitude

                if Distance < MaxDistance then
                    ClosestTarget = TargetPart
                    MaxDistance = Distance
                end
            end
        end
    end
    return ClosestTarget
end

-- Modifica o comportamento do Mouse/Toque para direcionar Skills
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if getgenv().AimbotSkills and (Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRay") then
        local Target = GetClosestPlayer()
        if Target then
            return Target, Target.Position, Vector3.new(0,1,0), Target.Material
        end
    end
    return OldNamecall(Self, ...)
end)

RunService.RenderStepped:Connect(function()
    local Target = GetClosestPlayer()
    
    -- 1. Camlock de CFrame
    if getgenv().CamlockEnabled and Target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
    end
    
    -- 2. Direcionamento Forçado das Skills
    if getgenv().AimbotSkills and Target then
        pcall(function()
            LocalPlayer:GetMouse().Hit = Target.CFrame
        end)
    end
    
    -- 3. Auto Raça V4
    if getgenv().AutoV4 then
        local Character = LocalPlayer.Character
        if Character and Character:FindFirstChild("AwakeningBar") and Character.AwakeningBar.Value >= 100 then
            VirtualUser:TypeKey("t")
        end
    end
end)
