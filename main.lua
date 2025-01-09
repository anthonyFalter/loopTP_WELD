local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local userInput = game:GetService("UserInputService")

-- Function to initialize the script for the player
local function setupScriptForPlayer(player)
    -- Creating the UI and teleportation logic for each player
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0.3, 0, 0.5, 0)
    frame.Position = UDim2.new(0.35, 0, 0.25, 0)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local isDragging = false
    local dragStart, startPos

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = userInput:GetMouseLocation()
            local guiPos = frame.AbsolutePosition
            local guiSize = frame.AbsoluteSize
            if mousePos.X >= guiPos.X and mousePos.X <= guiPos.X + guiSize.X and 
                mousePos.Y >= guiPos.Y and mousePos.Y <= guiPos.Y + guiSize.Y then
                isDragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end
    end

    local function onInputChanged(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end

    frame.InputBegan:Connect(onInputBegan)
    frame.InputChanged:Connect(onInputChanged)
    frame.InputEnded:Connect(onInputEnded)

    local teleportButton = Instance.new("TextButton")
    teleportButton.Name = "TeleportButton"
    teleportButton.Size = UDim2.new(1, 0, 0, 50)
    teleportButton.Position = UDim2.new(0, 0, 0, 0)
    teleportButton.Text = "Loop Teleport to Players in Teams"
    teleportButton.Font = Enum.Font.SourceSans
    teleportButton.TextSize = 20
    teleportButton.TextColor3 = Color3.new(1, 1, 1)
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    teleportButton.BorderSizePixel = 0
    teleportButton.Parent = frame

    local checklistFrame = Instance.new("Frame")
    checklistFrame.Name = "Checklist"
    checklistFrame.Size = UDim2.new(1, 0, 1, -50)
    checklistFrame.Position = UDim2.new(0, 0, 0, 50)
    checklistFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    checklistFrame.BorderSizePixel = 0
    checklistFrame.Parent = frame

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = checklistFrame

    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingTop = UDim.new(0, 5)
    uiPadding.PaddingBottom = UDim.new(0, 5)
    uiPadding.Parent = checklistFrame

    local function getCheckedTeams()
        local checkedTeams = {}
        for _, teamCheckbox in ipairs(checklistFrame:GetChildren()) do
            if teamCheckbox:IsA("TextButton") and teamCheckbox:FindFirstChild("Checked") then
                local isChecked = teamCheckbox.Checked.Value
                if isChecked then
                    table.insert(checkedTeams, teamCheckbox.Name)
                end
            end
        end
        return checkedTeams
    end

    local teleportEnabled = true

    --TARGET
    local function loopTeleportToPlayersInTeams()
        local localPlayer = Players.LocalPlayer
        if not localPlayer.Character or not localPlayer.Character.PrimaryPart then return end

        local checkedTeams = getCheckedTeams()
        local primaryPart = localPlayer.Character.PrimaryPart
        local currentWeld = nil

        while teleportEnabled == true do
            local teleported = false

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Team and table.find(checkedTeams, player.Team.Name) then
                    if player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") then
                        local humanoid = player.Character.Humanoid
                        -- Check if the player's health is greater than 0
                        if humanoid.Health > 0 then
                            if currentWeld then
                                currentWeld:Destroy()
                                currentWeld = nil
                            end

                            local targetPart = player.Character.PrimaryPart
                            -- Adjust the offset to place the player a bit to the left (e.g., -3 on the X axis)
                            local offset = CFrame.new(-3, -1, 2)  -- Change -3 to a value that suits your needs

                            primaryPart.CFrame = targetPart.CFrame * offset

                            currentWeld = Instance.new("WeldConstraint")
                            currentWeld.Part0 = primaryPart
                            currentWeld.Part1 = targetPart
                            currentWeld.Parent = primaryPart

                            wait(3)
                            teleported = true
                        end
                    end
                end
            end

            if not teleported then break end
        end

        if currentWeld then
            currentWeld:Destroy()
        end
    end

    --END LOOP


    teleportButton.MouseButton1Click:Connect(function()
        if teleportEnabled then
            loopTeleportToPlayersInTeams()
        else
            print("Teleportation is currently disabled.")
        end
    end)

    function enableTeleport()
        teleportEnabled = true
        print("Teleportation enabled.")
    end

    function disableTeleport()
        teleportEnabled = false
        print("Teleportation disabled.")
    end

    local function populateChecklist()
        for _, team in ipairs(Teams:GetTeams()) do
            local teamButton = Instance.new("TextButton")
            teamButton.Name = team.Name
            teamButton.Text = team.Name
            teamButton.Size = UDim2.new(1, 0, 0, 30)
            teamButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            teamButton.Font = Enum.Font.SourceSans
            teamButton.TextSize = 18
            teamButton.TextColor3 = Color3.new(1, 1, 1)
            teamButton.BorderSizePixel = 0
            teamButton.Parent = checklistFrame

            local checkedValue = Instance.new("BoolValue")
            checkedValue.Name = "Checked"
            checkedValue.Value = false
            checkedValue.Parent = teamButton

            teamButton.MouseButton1Click:Connect(function()
                checkedValue.Value = not checkedValue.Value
                teamButton.BackgroundColor3 = checkedValue.Value and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end)
        end
    end

    populateChecklist()
end

-- Reparent the script whenever the player respawns
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local scriptClone = script:Clone()
        scriptClone.Parent = player:WaitForChild("Backpack")  -- Or StarterCharacterScripts
        setupScriptForPlayer(player)
    end)
end)
