-- FATALITY GUI for Matcha LuaVM
-- Converted from HTML/CSS/JS to Luau Drawing API

-- Configuration
local CONFIG = {
    MENU_WIDTH = 800,
    MENU_HEIGHT = 652,
    BAR_HEIGHT = 75,
    INSIDE_HEIGHT = 540,
    FIELDSET_WIDTH = 215,
    TOGGLE_KEY = 0x2E, -- DELETE key (VK_DELETE)
}

-- Color Palette
local COLORS = {
    PRIMARY = Color3.fromRGB(70, 50, 240),    -- #4632f0
    SECONDARY = Color3.fromRGB(235, 5, 90),   -- #eb055a
    BG_DARK = Color3.fromRGB(45, 48, 57),     -- #2d3039
    BG_DARKER = Color3.fromRGB(28, 20, 55),   -- #1c1437
    BG_FIELD = Color3.fromRGB(31, 25, 66),    -- #1f1942
    BORDER = Color3.fromRGB(70, 63, 106),     -- #463f6a
    TEXT_GRAY = Color3.fromRGB(104, 100, 140), -- #68648c
    TEXT_WHITE = Color3.fromRGB(255, 255, 255),
    BLACK_ALPHA = Color3.fromRGB(0, 0, 0),
}

-- GUI State
local GUI = {
    visible = true,
    dragging = false,
    dragOffset = Vector2.new(0, 0),
    position = Vector2.new(100, 100),
    currentTab = 1,
    elements = {},
    checkboxes = {},
    sliders = {},
}

-- Tab Data
local TABS = {
    {name = "RAGE", id = 1},
    {name = "VISUALS", id = 2},
    {name = "MISC", id = 3},
    {name = "INVENTORY", id = 4},
    {name = "LEGIT", id = 5},
}

-- Helper Functions
local function createDrawing(drawingType, properties)
    local drawing = Drawing.new(drawingType)
    for prop, value in pairs(properties) do
        drawing[prop] = value
    end
    table.insert(GUI.elements, drawing)
    return drawing
end

local function isMouseOver(pos, size)
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    return mousePos.X >= pos.X and mousePos.X <= pos.X + size.X and
           mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y
end

local function updateVisibility()
    for _, element in ipairs(GUI.elements) do
        if element.Visible ~= GUI.visible then
            element.Visible = GUI.visible
        end
    end
end

-- Create Background Fogging
local function createFogging()
    local fog = createDrawing("Square", {
        Size = Vector2.new(10000, 10000),
        Position = Vector2.new(0, 0),
        Color = COLORS.BLACK_ALPHA,
        Transparency = 0.35,
        Filled = true,
        Visible = true,
        ZIndex = 0,
    })
    return fog
end

-- Create Main Menu Container
local function createMenuBackground()
    local bg = createDrawing("Square", {
        Size = Vector2.new(CONFIG.MENU_WIDTH, CONFIG.MENU_HEIGHT),
        Position = GUI.position,
        Color = COLORS.BG_DARK,
        Transparency = 1,
        Filled = true,
        Visible = true,
        ZIndex = 1,
    })
    
    local border = createDrawing("Square", {
        Size = Vector2.new(CONFIG.MENU_WIDTH, CONFIG.MENU_HEIGHT),
        Position = GUI.position,
        Color = COLORS.BORDER,
        Transparency = 1,
        Filled = false,
        Visible = true,
        ZIndex = 2,
    })
    
    return bg, border
end

-- Create Top Bar
local function createTopBar()
    local bar = createDrawing("Square", {
        Size = Vector2.new(CONFIG.MENU_WIDTH, CONFIG.BAR_HEIGHT),
        Position = GUI.position,
        Color = Color3.fromRGB(27, 21, 57), -- #1b1539
        Transparency = 1,
        Filled = true,
        Visible = true,
        ZIndex = 3,
    })
    
    -- Gradient line
    local line = createDrawing("Square", {
        Size = Vector2.new(CONFIG.MENU_WIDTH, 2),
        Position = Vector2.new(GUI.position.X, GUI.position.Y + 15),
        Color = COLORS.SECONDARY,
        Transparency = 1,
        Filled = true,
        Visible = true,
        ZIndex = 4,
    })
    
    -- Logo text
    local logo = createDrawing("Text", {
        Text = "FATALITY",
        Size = 18,
        Font = Drawing.Fonts.SystemBold,
        Position = Vector2.new(GUI.position.X + 18, GUI.position.Y + 40),
        Color = COLORS.TEXT_WHITE,
        Transparency = 1,
        Visible = true,
        Center = false,
        Outline = true,
        ZIndex = 5,
    })
    
    return bar, line, logo
end

-- Create Tab System
local function createTabs()
    local tabElements = {}
    local startX = 160
    local tabWidth = 100
    
    for i, tab in ipairs(TABS) do
        local xPos = GUI.position.X + startX + ((i - 1) * tabWidth)
        local yPos = GUI.position.Y + 30
        
        -- Tab text
        local tabText = createDrawing("Text", {
            Text = tab.name,
            Size = 14,
            Font = Drawing.Fonts.System,
            Position = Vector2.new(xPos, yPos),
            Color = GUI.currentTab == i and COLORS.TEXT_WHITE or COLORS.TEXT_GRAY,
            Transparency = 1,
            Visible = true,
            Center = false,
            Outline = false,
            ZIndex = 6,
        })
        
        -- Underline for active tab
        local underline = createDrawing("Square", {
            Size = Vector2.new(tabWidth - 20, 2),
            Position = Vector2.new(xPos, yPos + 20),
            Color = COLORS.SECONDARY,
            Transparency = GUI.currentTab == i and 1 or 0,
            Filled = true,
            Visible = true,
            ZIndex = 6,
        })
        
        table.insert(tabElements, {
            text = tabText,
            underline = underline,
            index = i,
            bounds = {pos = Vector2.new(xPos, yPos), size = Vector2.new(tabWidth, 25)}
        })
    end
    
    return tabElements
end

-- Create Inside Container
local function createInsideContainer()
    local inside = createDrawing("Square", {
        Size = Vector2.new(CONFIG.MENU_WIDTH - 2, CONFIG.INSIDE_HEIGHT),
        Position = Vector2.new(GUI.position.X + 1, GUI.position.Y + CONFIG.BAR_HEIGHT + 37),
        Color = COLORS.BG_DARKER,
        Transparency = 1,
        Filled = true,
        Visible = true,
        ZIndex = 3,
    })
    
    local border = createDrawing("Square", {
        Size = Vector2.new(CONFIG.MENU_WIDTH - 2, CONFIG.INSIDE_HEIGHT),
        Position = Vector2.new(GUI.position.X + 1, GUI.position.Y + CONFIG.BAR_HEIGHT + 37),
        Color = COLORS.BORDER,
        Transparency = 1,
        Filled = false,
        Visible = true,
        ZIndex = 4,
    })
    
    return inside, border
end

-- Create Checkbox
local function createCheckbox(label, position, tabId, index)
    local checkboxData = {
        checked = false,
        label = label,
        tabId = tabId,
        index = index,
        elements = {}
    }
    
    -- Checkbox box
    local box = createDrawing("Square", {
        Size = Vector2.new(9, 9),
        Position = position,
        Color = COLORS.BG_DARKER,
        Transparency = 1,
        Filled = true,
        Visible = true,
        ZIndex = 10,
    })
    
    local boxBorder = createDrawing("Square", {
        Size = Vector2.new(9, 9),
        Position = position,
        Color = COLORS.BORDER,
        Transparency = 1,
        Filled = false,
        Visible = true,
        ZIndex = 11,
    })
    
    -- Checkbox label
    local labelText = createDrawing("Text", {
        Text = label,
        Size = 12,
        Font = Drawing.Fonts.System,
        Position = Vector2.new(position.X + 15, position.Y - 2),
        Color = COLORS.TEXT_WHITE,
        Transparency = 1,
        Visible = true,
        Center = false,
        Outline = false,
        ZIndex = 10,
    })
    
    checkboxData.elements = {box = box, border = boxBorder, label = labelText}
    checkboxData.bounds = {pos = position, size = Vector2.new(200, 15)}
    
    return checkboxData
end

-- Create Slider
local function createSlider(label, position, tabId, index)
    local sliderData = {
        value = 0,
        min = 0,
        max = 100,
        dragging = false,
        label = label,
        tabId = tabId,
        index = index,
        elements = {}
    }
    
    -- Slider label
    local labelText = createDrawing("Text", {
        Text = label,
        Size = 12,
        Font = Drawing.Fonts.System,
        Position = Vector2.new(position.X, position.Y - 15),
        Color = COLORS.TEXT_WHITE,
        Transparency = 1,
        Visible = true,
        Center = false,
        Outline = false,
        ZIndex = 10,
    })
    
    -- Slider background
    local sliderBg = createDrawing("Square", {
        Size = Vector2.new(180, 10),
        Position = position,
        Color = COLORS.BLACK_ALPHA,
        Transparency = 0.2,
        Filled = true,
        Visible = true,
        ZIndex = 10,
    })
    
    local sliderBorder = createDrawing("Square", {
        Size = Vector2.new(180, 10),
        Position = position,
        Color = COLORS.BORDER,
        Transparency = 1,
        Filled = false,
        Visible = true,
        ZIndex = 11,
    })
    
    -- Slider fill
    local sliderFill = createDrawing("Square", {
        Size = Vector2.new(0, 10),
        Position = position,
        Color = COLORS.SECONDARY,
        Transparency = 1,
        Filled = true,
        Visible = true,
        ZIndex = 12,
    })
    
    -- Value display
    local valueText = createDrawing("Text", {
        Text = "0",
        Size = 11,
        Font = Drawing.Fonts.System,
        Position = Vector2.new(position.X + 90, position.Y - 1),
        Color = COLORS.TEXT_WHITE,
        Transparency = 1,
        Visible = true,
        Center = true,
        Outline = false,
        ZIndex = 13,
    })
    
    sliderData.elements = {
        label = labelText,
        background = sliderBg,
        border = sliderBorder,
        fill = sliderFill,
        valueText = valueText
    }
    sliderData.bounds = {pos = position, size = Vector2.new(180, 10)}
    
    return sliderData
end

-- Create Fieldset
local function createFieldset(title, position, tabId, contentCallback)
    local fieldsetElements = {}
    
    -- Fieldset background
    local bg = createDrawing("Square", {
        Size = Vector2.new(CONFIG.FIELDSET_WIDTH, 150),
        Position = position,
        Color = COLORS.BG_FIELD,
        Transparency = 1,
        Filled = true,
        Visible = true,
        ZIndex = 8,
    })
    
    local border = createDrawing("Square", {
        Size = Vector2.new(CONFIG.FIELDSET_WIDTH, 150),
        Position = position,
        Color = COLORS.BORDER,
        Transparency = 1,
        Filled = false,
        Visible = true,
        ZIndex = 9,
    })
    
    -- Fieldset title
    local titleText = createDrawing("Text", {
        Text = title,
        Size = 12,
        Font = Drawing.Fonts.System,
        Position = Vector2.new(position.X + 10, position.Y - 8),
        Color = COLORS.TEXT_WHITE,
        Transparency = 1,
        Visible = true,
        Center = false,
        Outline = false,
        ZIndex = 10,
    })
    
    -- Title background (to create legend effect)
    local titleBg = createDrawing("Square", {
        Size = Vector2.new(#title * 7, 3),
        Position = Vector2.new(position.X + 8, position.Y - 1),
        Color = COLORS.BG_FIELD,
        Transparency = 1,
        Filled = true,
        Visible = true,
        ZIndex = 9,
    })
    
    table.insert(fieldsetElements, bg)
    table.insert(fieldsetElements, border)
    table.insert(fieldsetElements, titleText)
    table.insert(fieldsetElements, titleBg)
    
    -- Call content callback to add elements
    if contentCallback then
        contentCallback(position, tabId)
    end
    
    return fieldsetElements
end

-- Create Tab 1 Content (RAGE)
local function createTab1Content()
    local startX = GUI.position.X + 30
    local startY = GUI.position.Y + CONFIG.BAR_HEIGHT + 52
    
    -- Fieldset 1: Box1
    createFieldset("Box1", Vector2.new(startX, startY), 1, function(pos, tabId)
        local checkbox1 = createCheckbox("Checkbox1", Vector2.new(pos.X + 10, pos.Y + 15), tabId, 1)
        local checkbox2 = createCheckbox("Checkbox2", Vector2.new(pos.X + 10, pos.Y + 35), tabId, 2)
        local slider1 = createSlider("Range slider1", Vector2.new(pos.X + 17, pos.Y + 75), tabId, 1)
        
        table.insert(GUI.checkboxes, checkbox1)
        table.insert(GUI.checkboxes, checkbox2)
        table.insert(GUI.sliders, slider1)
    end)
    
    -- Fieldset 2: Box2
    createFieldset("Box2", Vector2.new(startX + CONFIG.FIELDSET_WIDTH + 30, startY), 1, function(pos, tabId)
        local checkbox3 = createCheckbox("Checkbox3", Vector2.new(pos.X + 10, pos.Y + 15), tabId, 3)
        local checkbox4 = createCheckbox("Checkbox4", Vector2.new(pos.X + 10, pos.Y + 35), tabId, 4)
        local slider2 = createSlider("Range slider2", Vector2.new(pos.X + 17, pos.Y + 75), tabId, 2)
        
        table.insert(GUI.checkboxes, checkbox3)
        table.insert(GUI.checkboxes, checkbox4)
        table.insert(GUI.sliders, slider2)
    end)
end

-- Update all element positions based on menu position
local function updateElementPositions()
    -- Update all drawings with relative positions
    -- This is a simplified version - you'd need to track original offsets
    for _, element in ipairs(GUI.elements) do
        if element.Position then
            -- Recalculate position based on new menu position
            -- This requires storing original offsets, which is simplified here
        end
    end
end

-- Handle Tab Switching
local function switchTab(newTabIndex)
    if GUI.currentTab == newTabIndex then return end
    
    GUI.currentTab = newTabIndex
    
    -- Update tab colors and underlines
    for i, tab in ipairs(TABS) do
        -- Find and update tab elements (simplified)
    end
    
    -- Show/hide content based on active tab
    for _, checkbox in ipairs(GUI.checkboxes) do
        local visible = checkbox.tabId == newTabIndex
        for _, elem in pairs(checkbox.elements) do
            elem.Visible = visible and GUI.visible
        end
    end
    
    for _, slider in ipairs(GUI.sliders) do
        local visible = slider.tabId == newTabIndex
        for _, elem in pairs(slider.elements) do
            elem.Visible = visible and GUI.visible
        end
    end
end

-- Handle Checkbox Click
local function handleCheckboxClick(checkbox)
    checkbox.checked = not checkbox.checked
    
    if checkbox.checked then
        checkbox.elements.box.Color = COLORS.SECONDARY
        checkbox.elements.border.Color = COLORS.SECONDARY
    else
        checkbox.elements.box.Color = COLORS.BG_DARKER
        checkbox.elements.border.Color = COLORS.BORDER
    end
    
    print(checkbox.label .. " is now " .. (checkbox.checked and "ON" or "OFF"))
end

-- Handle Slider Drag
local function handleSliderDrag(slider, mouseX)
    local sliderPos = slider.bounds.pos
    local sliderWidth = slider.bounds.size.X
    
    local relativeX = mouseX - sliderPos.X
    relativeX = math.clamp(relativeX, 0, sliderWidth)
    
    local percentage = relativeX / sliderWidth
    slider.value = math.floor(slider.min + (slider.max - slider.min) * percentage)
    
    -- Update slider fill
    slider.elements.fill.Size = Vector2.new(relativeX, 10)
    slider.elements.valueText.Text = tostring(slider.value)
    
    -- Optional: Add border highlight on hover
    if relativeX > 0 then
        slider.elements.border.Color = COLORS.SECONDARY
    else
        slider.elements.border.Color = COLORS.BORDER
    end
end

-- Initialize GUI
local function initializeGUI()
    print("Initializing FATALITY GUI...")
    
    -- Create all GUI elements
    createFogging()
    createMenuBackground()
    createTopBar()
    local tabs = createTabs()
    createInsideContainer()
    createTab1Content()
    
    -- Set initial tab visibility
    switchTab(1)
    
    print("GUI Initialized! Press DELETE to toggle visibility.")
end

-- Input Handling
local UserInputService = game:GetService("UserInputService")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle GUI visibility with DELETE key
    if input.KeyCode.Value == CONFIG.TOGGLE_KEY then
        GUI.visible = not GUI.visible
        updateVisibility()
        return
    end
    
    -- Handle mouse clicks
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        
        -- Check if clicking on menu bar for dragging
        if isMouseOver(GUI.position, Vector2.new(CONFIG.MENU_WIDTH, CONFIG.BAR_HEIGHT)) then
            GUI.dragging = true
            GUI.dragOffset = Vector2.new(mousePos.X - GUI.position.X, mousePos.Y - GUI.position.Y)
        end
        
        -- Check checkbox clicks
        for _, checkbox in ipairs(GUI.checkboxes) do
            if checkbox.tabId == GUI.currentTab and isMouseOver(checkbox.bounds.pos, checkbox.bounds.size) then
                handleCheckboxClick(checkbox)
            end
        end
        
        -- Check slider clicks
        for _, slider in ipairs(GUI.sliders) do
            if slider.tabId == GUI.currentTab and isMouseOver(slider.bounds.pos, slider.bounds.size) then
                slider.dragging = true
                handleSliderDrag(slider, mouse.X)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        GUI.dragging = false
        for _, slider in ipairs(GUI.sliders) do
            slider.dragging = false
            slider.elements.border.Color = COLORS.BORDER
        end
    end
end)

-- Main update loop
spawn(function()
    while true do
        wait(0.016) -- ~60 FPS
        
        if GUI.visible then
            -- Handle dragging
            if GUI.dragging then
                local mousePos = Vector2.new(mouse.X, mouse.Y)
                GUI.position = Vector2.new(mousePos.X - GUI.dragOffset.X, mousePos.Y - GUI.dragOffset.Y)
                updateElementPositions()
            end
            
            -- Handle slider dragging
            for _, slider in ipairs(GUI.sliders) do
                if slider.dragging and slider.tabId == GUI.currentTab then
                    handleSliderDrag(slider, mouse.X)
                end
            end
        end
    end
end)

-- Start the GUI
initializeGUI()

-- Export GUI API for external control
return {
    toggle = function()
        GUI.visible = not GUI.visible
        updateVisibility()
    end,
    
    setCheckbox = function(tabId, index, value)
        for _, checkbox in ipairs(GUI.checkboxes) do
            if checkbox.tabId == tabId and checkbox.index == index then
                checkbox.checked = value
                handleCheckboxClick(checkbox)
                break
            end
        end
    end,
    
    getCheckbox = function(tabId, index)
        for _, checkbox in ipairs(GUI.checkboxes) do
            if checkbox.tabId == tabId and checkbox.index == index then
                return checkbox.checked
            end
        end
        return false
    end,
    
    setSlider = function(tabId, index, value)
        for _, slider in ipairs(GUI.sliders) do
            if slider.tabId == tabId and slider.index == index then
                slider.value = math.clamp(value, slider.min, slider.max)
                local percentage = (slider.value - slider.min) / (slider.max - slider.min)
                slider.elements.fill.Size = Vector2.new(slider.bounds.size.X * percentage, 10)
                slider.elements.valueText.Text = tostring(slider.value)
                break
            end
        end
    end,
    
    getSlider = function(tabId, index)
        for _, slider in ipairs(GUI.sliders) do
            if slider.tabId == tabId and slider.index == index then
                return slider.value
            end
        end
        return 0
    end,
}
