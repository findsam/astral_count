-- Create the main frame for the display
local frame = CreateFrame("Frame", "AstralPowerFrame", UIParent)
frame:SetSize(46, 46) -- Ensure the frame matches the size of the icon
frame:SetPoint("CENTER", UIParent, "CENTER") 
frame:SetScale(1.125)

-- Add a border texture to the frame
local border = frame:CreateTexture(nil, "BACKGROUND")
border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
border:SetAllPoints(frame) -- Ensure the border fills the frame exactly 

-- Add the Starsurge spell icon as the background
local background = frame:CreateTexture(nil, "ARTWORK")
background:SetTexture("Interface\\Icons\\spell_arcane_arcane03")
background:SetAllPoints(frame) -- Ensure the icon fills the frame exactly 

-- Create a font string to display the number of Starsurges
local starsurgeCountText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
starsurgeCountText:SetPoint("CENTER", frame, "CENTER")
starsurgeCountText:SetTextColor(0, 0.75, 1)
starsurgeCountText:SetFont("Fonts\\FRIZQT__.TTF", 28, "OUTLINE") 

-- Function to calculate and display the number of Starsurges
local function UpdateStarsurgeCount()
    local currentPower = UnitPower("player", Enum.PowerType.LunarPower)
    local isIncarnationActive = AuraUtil.FindAuraByName("Incarnation: Chosen of Elune", "player")
    local hasTouchTheCosmos = AuraUtil.FindAuraByName("Touch the Cosmos", "player")
    local starsurgeCost = 36 

    if isIncarnationActive then
        starsurgeCost = 27
    elseif hasTouchTheCosmos then
        starsurgeCost = 30
    end 

    local starsurgesAvailable = math.floor(currentPower / starsurgeCost) 

    if starsurgesAvailable > 0 then
        starsurgeCountText:SetText(starsurgesAvailable)
        frame:Show() 

        -- Show glow only if more than 2 Starsurges are available
        if starsurgesAvailable > 2 then
            ActionButton_ShowOverlayGlow(frame) -- Apply the glow to the frame
        else
            ActionButton_HideOverlayGlow(frame) -- Hide the glow
        end
    else
        frame:Hide()
        ActionButton_HideOverlayGlow(frame)
    end
end 

-- Register events to update the Starsurge count
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_AURA") 

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
SLASH_ASTRALPOWER1 = "/aps"
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
