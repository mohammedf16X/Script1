-- Roblox Speed Modifier GUI using splib v2
-- Made for character speed modification with textbox and slider controls

-- Load splib v2 library from GitHub
local splib = loadstring(game:HttpGet("https://raw.githubusercontent.com/as6cd0/SP_Hub/refs/heads/main/splibv2"))()

-- Get required Roblox services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Get local player and character
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Speed configuration
local MIN_SPEED = 16
local MAX_SPEED = 100
local DEFAULT_SPEED = 16

-- Current speed value (shared between textbox and slider)
local currentSpeed = DEFAULT_SPEED

-- Create main window
local Window = splib:MakeWindow({
    Name = "Speed Modifier",
    SubTitle = "تعديل سرعة اللاعب",
    Setting = true,
    Toggle = true,
    RainbowMainFrame = false,
    RainbowTitle = false,
    RainbowSubTitle = false,
    ToggleIcon = "rbxassetid://83114982417764",
    CloseCallback = true
})

-- Create character tab with appropriate icon
local CharacterTab = Window:MakeTab({
    IsMobile = false,
    IsPC = false,
    Name = "Character",
    Icon = "rbxassetid://4483345998" -- Character/player icon
})

-- Add section for speed controls
CharacterTab:AddSection("إعدادات السرعة")

-- Function to apply speed to character
local function applySpeed(speed)
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = speed
        currentSpeed = speed
        
        -- Show notification when speed is applied
        splib:MakeNotification({
            Name = "تم تطبيق السرعة",
            Content = "السرعة الجديدة: " .. tostring(speed),
            Image = "rbxassetid://6026568198",
            Time = 2
        })
    end
end

-- Function to validate speed input
local function validateSpeed(input)
    local speed = tonumber(input)
    if speed == nil then
        return false, "يجب إدخال رقم صحيح"
    end
    
    if speed < MIN_SPEED then
        return false, "السرعة لا يمكن أن تكون أقل من " .. MIN_SPEED
    end
    
    if speed > MAX_SPEED then
        return false, "السرعة لا يمكن أن تكون أكثر من " .. MAX_SPEED
    end
    
    return true, speed
end

-- Create speed slider
local SpeedSlider = CharacterTab:AddSlider({
    IsMobile = false,
    IsPC = false,
    Name = "سرعة اللاعب",
    Min = MIN_SPEED,
    Max = MAX_SPEED,
    Increment = 1,
    Default = DEFAULT_SPEED,
    ValueName = "وحدة",
    Flag = "PlayerSpeedSlider",
    Callback = function(Value)
        currentSpeed = Value
        applySpeed(Value)
        
        -- Update textbox to match slider value
        if SpeedTextbox then
            SpeedTextbox:Set(tostring(Value))
        end
    end
})

-- Create speed textbox
local SpeedTextbox = CharacterTab:AddTextbox({
    IsMobile = false,
    IsPC = false,
    Name = "إدخال السرعة مباشرة",
    Desc = "أدخل قيمة السرعة من " .. MIN_SPEED .. " إلى " .. MAX_SPEED,
    Default = tostring(DEFAULT_SPEED),
    TextDisappear = false,
    Flag = "PlayerSpeedTextbox",
    Callback = function(Value)
        local isValid, result = validateSpeed(Value)
        
        if isValid then
            currentSpeed = result
            applySpeed(result)
            
            -- Update slider to match textbox value
            SpeedSlider:Set(result)
        else
            -- Show error notification
            splib:MakeNotification({
                Name = "خطأ في الإدخال",
                Content = result,
                Image = "rbxassetid://6026568198",
                Time = 3
            })
            
            -- Reset textbox to current valid value
            SpeedTextbox:Set(tostring(currentSpeed))
        end
    end
})

-- Add reset button
CharacterTab:AddButton({
    IsMobile = false,
    IsPC = false,
    Name = "إعادة تعيين السرعة",
    Desc = "إعادة السرعة إلى القيمة الافتراضية",
    Callback = function()
        currentSpeed = DEFAULT_SPEED
        applySpeed(DEFAULT_SPEED)
        
        -- Update both controls
        SpeedSlider:Set(DEFAULT_SPEED)
        SpeedTextbox:Set(tostring(DEFAULT_SPEED))
        
        splib:MakeNotification({
            Name = "تم إعادة التعيين",
            Content = "تم إعادة السرعة إلى " .. DEFAULT_SPEED,
            Image = "rbxassetid://6026568198",
            Time = 2
        })
    end
})

-- Add current speed display label
local SpeedLabel = CharacterTab:AddLabel("السرعة الحالية: " .. tostring(currentSpeed))

-- Function to update speed label
local function updateSpeedLabel()
    if Character and Character:FindFirstChild("Humanoid") then
        local actualSpeed = math.floor(Character.Humanoid.WalkSpeed)
        SpeedLabel:Set("السرعة الحالية: " .. tostring(actualSpeed))
    end
end

-- Monitor character changes and respawning
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    
    -- Apply saved speed to new character
    wait(1) -- Wait for character to fully load
    applySpeed(currentSpeed)
    
    splib:MakeNotification({
        Name = "تم إعادة الإحياء",
        Content = "تم تطبيق السرعة المحفوظة: " .. tostring(currentSpeed),
        Image = "rbxassetid://6026568198",
        Time = 3
    })
end)

-- Update speed label periodically
RunService.Heartbeat:Connect(function()
    updateSpeedLabel()
end)

-- Add information section
CharacterTab:AddSection("معلومات")

CharacterTab:AddParagraph("كيفية الاستخدام", 
    "• استخدم الشريط المنزلق للتحكم البصري في السرعة\n" ..
    "• استخدم صندوق النص للإدخال المباشر\n" ..
    "• السرعة محدودة بين " .. MIN_SPEED .. " و " .. MAX_SPEED .. "\n" ..
    "• يتم حفظ الإعدادات تلقائياً"
)

-- Add keybind for quick speed boost
CharacterTab:AddBind({
    IsMobile = false,
    IsPC = false,
    Name = "تسريع سريع",
    Desc = "اضغط للحصول على دفعة سرعة مؤقتة",
    Default = Enum.KeyCode.LeftShift,
    Hold = true,
    Flag = "SpeedBoostBind",
    Callback = function(isPressed)
        if Character and Character:FindFirstChild("Humanoid") then
            if isPressed then
                -- Apply speed boost
                Character.Humanoid.WalkSpeed = currentSpeed * 1.5
            else
                -- Return to normal speed
                Character.Humanoid.WalkSpeed = currentSpeed
            end
        end
    end
})

-- Initialize with default speed
applySpeed(DEFAULT_SPEED)

-- Welcome notification
splib:MakeNotification({
    Name = "مرحباً بك",
    Content = "تم تحميل واجهة تعديل السرعة بنجاح",
    Image = "rbxassetid://6026568198",
    Time = 4
})

print("Speed Modifier GUI loaded successfully!")
