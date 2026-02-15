local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local bypassKey = "G"
local lastKeyState = false
local bypassEnabled = false

local function bypassShields()
    bypassEnabled = not bypassEnabled
    print(bypassEnabled and "enabled" or "disabled")
end

local originalShieldData = {}

local function processShields()
    if not bypassEnabled then
        for key, data in pairs(originalShieldData) do
            if data.part and data.part.Parent then
                data.part.CanCollide = data.canCollide
                data.part.Transparency = data.transparency
                data.part.Size = data.size
                data.part.CFrame = data.cframe
            end
        end
        originalShieldData = {}
        return
    end
    
    for _, player in pairs(Players:GetChildren()) do
        local character = Workspace:FindFirstChild(player.Name)
        if character then
            local shields = {}
            
            local torso = character:FindFirstChild("Torso")
            if torso then
                local shieldFolder = torso:FindFirstChild("ShieldFolder")
                if shieldFolder then
                    for _, part in pairs(shieldFolder:GetChildren()) do
                        if part:IsA("BasePart") then
                            table.insert(shields, part)
                        end
                    end
                end
            end
            
            local riotShield = character:FindFirstChild("Riot Shield")
            if riotShield then
                if riotShield:IsA("BasePart") then
                    table.insert(shields, riotShield)
                elseif riotShield:IsA("Model") then
                    for _, part in pairs(riotShield:GetDescendants()) do
                        if part:IsA("BasePart") then
                            table.insert(shields, part)
                        end
                    end
                end
            end
            
            for _, part in pairs(shields) do
                local key = tostring(part)
                
                if not originalShieldData[key] then
                    originalShieldData[key] = {
                        part = part,
                        canCollide = part.CanCollide,
                        transparency = part.Transparency,
                        size = part.Size,
                        cframe = part.CFrame
                    }
                end
                
                part.CanCollide = false
                part.Transparency = 0.95
                part.Size = Vector3.new(0.1, 0.1, 0.1)
                part.CFrame = part.CFrame * CFrame.new(0, -1000, 0)
            end
        end
    end
end

RunService.Render:Connect(function()
    local success, keys = pcall(getpressedkeys)
    if success and type(keys) == "table" then
        local keyPressed = false
        
        for i = 1, #keys do
            local keyStr = keys[i]
            
            if type(keyStr) == "string" and keyStr == bypassKey then
                keyPressed = true
                break
            end
        end
        
        if keyPressed and not lastKeyState then
            bypassShields()
        end
        
        lastKeyState = keyPressed
    end
    
    processShields()
end)
