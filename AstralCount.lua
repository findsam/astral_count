-- Create the main frame for the display
local frame = CreateFrame("Frame", "AstralPowerFrame", UIParent)
frame:SetSize(54, 54) -- Adjust the size as needed
frame:SetPoint("CENTER", UIParent, "CENTER") -- Default position in the center

-- Add a border texture to the frame (like an action button)
local border = frame:CreateTexture(nil, "BACKGROUND")
border:SetTexture("Interface\\Buttons\\UI-Quickslot2") -- Action button border texture
border:SetAllPoints(frame)

-- Add the Starsurge spell icon as the background
local background = frame:CreateTexture(nil, "ARTWORK")
background:SetTexture("Interface\\Icons\\spell_arcane_arcane03") -- Starsurge spell icon
background:SetAllPoints(frame) -- Make the icon fill the entire frame

-- Create a font string to display the number of Starsurges
local starsurgeCountText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
starsurgeCountText:SetPoint("CENTER", frame, "CENTER") -- Center the text inside the frame
starsurgeCountText:SetTextColor(0, 0.75, 1)
starsurgeCountText:SetFont("Fonts\\FRIZQT__.TTF", 32, "OUTLINE")  -- Font size and outline

-- Function to calculate and display the number of Starsurges
local function UpdateStarsurgeCount()
    local currentPower = UnitPower("player", Enum.PowerType.LunarPower) -- Astral Power enum
    local isIncarnationActive = AuraUtil.FindAuraByName("Incarnation: Chosen of Elune", "player") -- Check for Incarnation buff
    local hasTouchTheCosmos = AuraUtil.FindAuraByName("Touch the Cosmos", "player") -- Check for Touch the Cosmos buff
    local starsurgeCost = 36 -- Default Starsurge cost

    -- Adjust Starsurge cost based on active buffs
    if isIncarnationActive then
        starsurgeCost = 27 -- Reduced cost during Incarnation
    elseif hasTouchTheCosmos then
        starsurgeCost = 30 -- Adjust cost for Touch the Cosmos
    end

    -- Calculate the number of Starsurges available
    local starsurgesAvailable = math.floor(currentPower / starsurgeCost)

    -- Update the text and toggle frame visibility
    if starsurgesAvailable > 0 then
        starsurgeCountText:SetText(starsurgesAvailable)
        frame:Show() -- Show the frame if Starsurges are available
    else
        frame:Hide() -- Hide the frame if no Starsurges are available
    end
end

-- Register events to update the Starsurge count
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_AURA") -- Listen for changes in buffs/debuffs

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_POWER_UPDATE" then
        local unit, powerType = ...
        if unit == "player" and powerType == "LUNAR_POWER" then
            UpdateStarsurgeCount()
        end
    elseif event == "UNIT_AURA" then
        UpdateStarsurgeCount()
    else
        UpdateStarsurgeCount()
    end
end)

-- Enable dragging functionality for the frame
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Add a slash command to lock/unlock dragging
SLASH_ASTRALPOWER1 = "/aplock"
SlashCmdList["ASTRALPOWER"] = function()
    if frame:IsMovable() then
        frame:SetMovable(false)
        frame:EnableMouse(false)
        print("Astral Power Frame Locked.")
    else
        frame:SetMovable(true)
        frame:EnableMouse(true)
        print("Astral Power Frame Unlocked.")
    end
end

-- Run the update function once to initialize the display
UpdateStarsurgeCount()
