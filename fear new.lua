-- Load library
local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ShaddowScripts/Main/main/Library"))()

-- Create UI window
local Main = library:CreateWindow("Fear.lua", "Crimson")
local tab = Main:CreateTab("Main")
local tab2 = Main:CreateTab("Player")

-- Function to update aimbot settings
local function updateAimbotSettings()
    if aimbotEnabled then
        getgenv().settings = {
            key = "Q",
            part = "HumanoidRootPart",
            smoothness = 1,
            prediction = Vector3.new(0.11945, 0.11, 0.11934)
        }
        
        -- Integrate the additional aimbot settings here
        getgenv().OldAimPart = "Head"
        getgenv().AimPart = "HumanoidRootPart"
        getgenv().AimlockKey = "q"
        getgenv().AimRadius = 50
        getgenv().ThirdPerson = true
        getgenv().FirstPerson = true
        getgenv().TeamCheck = false
        getgenv().PredictMovement = true
        getgenv().PredictionVelocity = 14.6
        getgenv().CheckIfJumped = true
        getgenv().Smoothness = true
        getgenv().SmoothnessAmount = 0.24
        
        local Players, Uis, RService, SGui = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("StarterGui")
        local Client, Mouse, Camera, CF, RNew, Vec3, Vec2 = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera, CFrame.new, Ray.new, Vector3.new, Vector2.new
        local Aimlock, MousePressed, CanNotify = true, false, false
        local AimlockTarget
        
        getgenv().WorldToViewportPoint = function(P)
            return Camera:WorldToViewportPoint(P)
        end
        
        getgenv().WorldToScreenPoint = function(P)
            return Camera.WorldToScreenPoint(Camera, P)
        end
        
        getgenv().GetObscuringObjects = function(T)
            if T and T:FindFirstChild(getgenv().AimPart) and Client and Client.Character:FindFirstChild("Head") then
                local RayPos = workspace:FindPartOnRay(RNew(
                    T[getgenv().AimPart].Position, Client.Character.Head.Position)
                )
                if RayPos then return RayPos:IsDescendantOf(T) end
            end
        end
        
        getgenv().GetNearestTarget = function()
            local players = {}
            local PLAYER_HOLD = {}
            local DISTANCES = {}
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= Client then
                    table.insert(players, v)
                end
            end
            for i, v in pairs(players) do
                if v.Character ~= nil then
                    local AIM = v.Character:FindFirstChild("Head")
                    if getgenv().TeamCheck == true and v.Team ~= Client.Team then
                        local DISTANCE = (v.Character:FindFirstChild("Head").Position - game.Workspace.CurrentCamera.CFrame.p).magnitude
                        local RAY = Ray.new(game.Workspace.CurrentCamera.CFrame.p, (Mouse.Hit.p - game.Workspace.CurrentCamera.CFrame.p).unit * DISTANCE)
                        local HIT, POS = game.Workspace:FindPartOnRay(RAY, game.Workspace)
                        local DIFF = math.floor((POS - AIM.Position).magnitude)
                        PLAYER_HOLD[v.Name .. i] = {}
                        PLAYER_HOLD[v.Name .. i].dist = DISTANCE
                        PLAYER_HOLD[v.Name .. i].plr = v
                        PLAYER_HOLD[v.Name .. i].diff = DIFF
                        table.insert(DISTANCES, DIFF)
                    elseif getgenv().TeamCheck == false and v.Team == Client.Team then
                        local DISTANCE = (v.Character:FindFirstChild("Head").Position - game.Workspace.CurrentCamera.CFrame.p).magnitude
                        local RAY = Ray.new(game.Workspace.CurrentCamera.CFrame.p, (Mouse.Hit.p - game.Workspace.CurrentCamera.CFrame.p).unit * DISTANCE)
                        local HIT, POS = game.Workspace:FindPartOnRay(RAY, game.Workspace)
                        local DIFF = math.floor((POS - AIM.Position).magnitude)
                        PLAYER_HOLD[v.Name .. i] = {}
                        PLAYER_HOLD[v.Name .. i].dist = DISTANCE
                        PLAYER_HOLD[v.Name .. i].plr = v
                        PLAYER_HOLD[v.Name .. i].diff = DIFF
                        table.insert(DISTANCES, DIFF)
                    end
                end
            end
            
            if unpack(DISTANCES) == nil then
                return nil
            end
            
            local L_DISTANCE = math.floor(math.min(unpack(DISTANCES)))
            if L_DISTANCE > getgenv().AimRadius then
                return nil
            end
            
            for i, v in pairs(PLAYER_HOLD) do
                if v.diff == L_DISTANCE then
                    return v.plr
                end
            end
            return nil
        end
        
        Mouse.KeyDown:Connect(function(a)
            if not (Uis:GetFocusedTextBox()) then
                if a == AimlockKey and AimlockTarget == nil then
                    pcall(function()
                        if MousePressed ~= true then MousePressed = true end
                        local Target; Target = GetNearestTarget()
                        if Target ~= nil then
                            AimlockTarget = Target
                        end
                    end)
                elseif a == AimlockKey and AimlockTarget ~= nil then
                    if AimlockTarget ~= nil then AimlockTarget = nil end
                    if MousePressed ~= false then
                        MousePressed = false
                    end
                end
            end
        end)
        
        RService.RenderStepped:Connect(function()
            if getgenv().ThirdPerson == true and getgenv().FirstPerson == true then
                if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 or (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then
                    CanNotify = true
                else
                    CanNotify = false
                end
            elseif getgenv().ThirdPerson == true and getgenv().FirstPerson == false then
                if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 then
                    CanNotify = true
                else
                    CanNotify = false
                end
            elseif getgenv().ThirdPerson == false and getgenv().FirstPerson == true then
                if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then
                    CanNotify = true
                else
                    CanNotify = false
                end
            end
            if Aimlock == true and MousePressed == true then
                if AimlockTarget and AimlockTarget.Character and AimlockTarget.Character:FindFirstChild(getgenv().AimPart) then
                    if getgenv().FirstPerson == true then
                        if CanNotify == true then
                            if getgenv().PredictMovement == true then
                                if getgenv().Smoothness == true then
                                    local Main = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position + AimlockTarget.Character[getgenv().AimPart].Velocity / PredictionVelocity)
                                    Camera.CFrame = Camera.CFrame:Lerp(Main, getgenv().SmoothnessAmount, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut)
                                else
                                    Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position + AimlockTarget.Character[getgenv().AimPart].Velocity / PredictionVelocity)
                                end
                            elseif getgenv().PredictMovement == false then
                                if getgenv().Smoothness == true then
                                    local Main = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position)
                                    Camera.CFrame = Camera.CFrame:Lerp(Main, getgenv().SmoothnessAmount, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut)
                                else
                                    Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position)
                                end
                            end
                        end
                    end
                end
            end
            if CheckIfJumped == true then
                if AimlockTarget.Character.Humanoid.FloorMaterial == Enum.Material.Air then
                    getgenv().AimPart = "UpperTorso"
                else
                    getgenv().AimPart = getgenv().OldAimPart
                end
            end
        end)
    else
        -- Clear aimbot settings if not enabled
        getgenv().settings = nil
    end
end

-- Create UI elements
tab:CreateButton("glock.lua", function()
    print("glock.lua on discord")
end)

tab:CreateCheckbox("Aimbot", function(value)
    aimbotEnabled = value
    if not value then
        -- Reset aimbot settings or perform any necessary cleanup
        getgenv().settings = nil
    else
        updateAimbotSettings()
    end
end)

tab:CreateDropdown("ESP", {"Box", "Name", "Both"}, function(selection)
    print(selection)
end)

-- Keybinds (unchanged)

-- Run initial aimbot setup if enabled by default
if tab:GetCheckboxState("Aimbot") then
    updateAimbotSettings()
end

-- Final part of the script
return Main
