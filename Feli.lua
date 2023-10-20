print("Aladin's Aimlock Client Loaded..")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MyCharacter = LocalPlayer.Character
local MyHumanoid = MyCharacter:WaitForChild("Humanoid")
local MyRootPart = MyCharacter:WaitForChild("HumanoidRootPart")
local MyView = game.Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local HoldingM2 = false
local Active = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(MyView.ViewportSize.X / 2, MyView.ViewportSize.Y / 2)
FOVCircle.Radius = Settings.CircleRadius
FOVCircle.Color = Settings.CircleColor
FOVCircle.Thickness = 2
FOVCircle.Transparency = 1
FOVCircle.NumSides = 64
FOVCircle.Visible = Settings.FOVVisible

local function CursorLock()
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

local function UnLockCursor()
    HoldingM2 = false
    Active = false
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

function FindNearestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.AimPart) then
            local targetPart = player.Character[Settings.AimPart]
            local screenPos, onScreen = MyView:WorldToScreenPoint(targetPart.Position)

            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(MyView.ViewportSize.X / 2, MyView.ViewportSize.Y / 2)).Magnitude

                if distance < Settings.CircleRadius and distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = targetPart
                end
            end
        end
    end

    return closestPlayer
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        HoldingM2 = true
        Active = true

        if Active then
            local target = FindNearestPlayer()

            while HoldingM2 and target do
                local predictedPosition = target.Position + target.Velocity * Settings.PredictionMultiplier
                MyView.CFrame = CFrame.lookAt(MyView.CFrame.Position, predictedPosition)
                FOVCircle.Position = Vector2.new(MyView.ViewportSize.X / 2, MyView.ViewportSize.Y / 2)

                task.wait()
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        UnLockCursor()
    end
end)
