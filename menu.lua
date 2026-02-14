-- FATALITY GUI - PROPERLY STYLED VERSION
-- Matches the original HTML/CSS design

print("[FATALITY] Initializing GUI...")

-- Configuration
local CONFIG = {
    MENU_WIDTH = 800,
    MENU_HEIGHT = 652,
    BAR_HEIGHT = 75,
    INSIDE_HEIGHT = 540,
    FIELDSET_WIDTH = 215,
    FIELDSET_HEIGHT = 180,
    TOGGLE_KEY = 0x2E, -- DELETE key
}

-- Color Palette (from original CSS)
local COLORS = {
    PRIMARY = Color3.fromRGB(70, 50, 240),
    SECONDARY = Color3.fromRGB(235, 5, 90),
    BG_DARK = Color3.fromRGB(45, 48, 57),
    BG_DARKER = Color3.fromRGB(28, 20, 55),
    BG_FIELD = Color3.fromRGB(31, 25, 66),
    BORDER = Color3.fromRGB(70, 63, 106),
    TEXT_GRAY = Color3.fromRGB(104, 100, 140),
    TEXT_WHITE = Color3.fromRGB(255, 255, 255),
    BLACK = Color3.fromRGB(0, 0, 0),
}

-- GUI State
local GUI = {
    visible = true,
    dragging = false,
    dragOffset = Vector2.new(0, 0),
    position = Vector2.new(200, 100),
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

-- Helper: Create drawing with auto-tracking
local function createDrawing(drawingType, properties)
    local drawing = Drawing.new(drawingType)
    for prop, value in pairs(properties) do
        drawing[prop] = value
    end
    table.insert(GUI.elements, drawing)
    return drawing
end

-- Helper: Check mouse over
local function isMouseOver(pos, size)
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    return mousePos.X >= pos.X and mousePos.X <= pos.X + size.X and
           mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y
end

-- Create fogging background
local fogging = createDrawing("Square", {
    Size = Vector2.new(10000, 10000),
    Position = Vector2.new(0, 0),
    Color = COLORS.BLACK,
    Transparency = 0.35,
    Filled = true,
    Visible = true,
    ZIndex = 0,
})

-- Create main menu background
local menuBg = createDrawing("Square", {
    Size = Vector2.new(CONFIG.MENU_WIDTH, CONFIG.MENU_HEIGHT),
    Position = GUI.position,
    Color = COLORS.BG_DARK,
    Transparency = 1,
    Filled = true,
    Visible = true,
    ZIndex = 1,
})

local menuBorder = createDrawing("Square", {
    Size = Vector2.new(CONFIG.MENU_WIDTH, CONFIG.MENU_HEIGHT),
    Position = GUI.position,
    Color = COLORS.BORDER,
    Transparency = 1,
    Filled = false,
    Visible = true,
    ZIndex = 2,
})

-- Create top bar
local topBar = createDrawing("Square", {
    Size = Vector2.new(CONFIG.MENU_WIDTH, CONFIG.BAR_HEIGHT),
    Position = GUI.position,
    Color = Color3.fromRGB(27, 21, 57),
    Transparency = 1,
    Filled = true,
    Visible = true,
    ZIndex = 3,
})

-- Gradient line under title
local gradientLine = createDrawing("Square", {
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
    Position = Vector2.new(GUI.position.X + 18, GUI.position.Y + 35),
    Color = COLORS.TEXT_WHITE,
    Transparency = 1,
    Visible = true,
    Center = false,
    Outline = true,
    ZIndex = 5,
})

-- Create tabs
local tabElements = {}
local tabStartX = 245  -- Centered position for tabs
local tabSpacing = 95

for i, tab in ipairs(TABS) do
    local xPos = GUI.position.X + tabStartX + ((i - 1) * tabSpacing)
    local yPos = GUI.position.Y + 30
    
    local tabText = createDrawing("Text", {
        Text = tab.name,
        Size = 13,
        Font = Drawing.Fonts.System,
        Position = Vector2.new(xPos, yPos),
        Color = i == GUI.currentTab and COLORS.TEXT_WHITE or COLORS.TEXT_GRAY,
        Transparency = 1,
        Visible = true,
        Center = false,
        Outline = false,
        ZIndex = 6,
    })
    
    local underline = createDrawing("Square", {
        Size = Vector2.new(string.len(tab.name) * 8, 2),
        Position = Vector2.new(xPos, yPos + 18),
        Color = COLORS.SECONDARY,
        Transparency = i == GUI.currentTab and 1 or 0,
        Filled = true,
        Visible = true,
        ZIndex = 6,
    })
    
    table.insert(tabElements, {
        text = tabText,
        underline = underline,
        index = i,
        bounds = {pos = Vector2.new(xPos, yPos), size = Vector2.new(tabSpacing - 10, 25)}
    })
end

-- Create inside container
local insideContainer = createDrawing("Square", {
    Size = Vector2.new(CONFIG.MENU_WIDTH - 4, CONFIG.INSIDE_HEIGHT),
    Position = Vector2.new(GUI.position.X + 2, GUI.position.Y + CONFIG.BAR_HEIGHT + 35),
    Color = COLORS.BG_DARKER,
    Transparency = 1,
    Filled = true,
    Visible = true,
    ZIndex = 3,
})

local insideBorder = createDrawing("Square", {
    Size = Vector2.new(CONFIG.MENU_WIDTH - 4, CONFIG.INSIDE_HEIGHT),
    Position = Vector2.new(GUI.position.X + 2, GUI.position.Y + CONFIG.BAR_HEIGHT + 35),
    Color = COLORS.BORDER,
    Transparency = 1,
    Filled = false,
    Visible = true,
    ZIndex = 4,
})

-- Create Checkbox
local function createCheckbox(label, position, tabId, index)
    local checkboxData = {
        checked = false,
        label = label,
        tabId = tabId,
        index = index,
        elements = {},
        position = position,
    }
    
    local box = createDrawing("Square", {
        Size = Vector2.new(9, 9),
        Position = position,
        Color = Color3.fromRGB(25, 21, 63),
        Transparency = 1,
        Filled = true,
        Visible = tabId == GUI.currentTab,
        ZIndex = 10,
    })
    
    local boxBorder = createDrawing("Square", {
        Size = Vector2.new(9, 9),
        Position = position,
        Color = COLORS.BORDER,
        Transparency = 1,
        Filled = false,
        Visible = tabId == GUI.currentTab,
        ZIndex = 11,
    })
    
    local labelText = createDrawing("Text", {
        Text = label,
        Size = 11,
        Font = Drawing.Fonts.System,
        Position = Vector2.new(position.X + 20, position.Y - 2),
        Color = COLORS.TEXT_WHITE,
        Transparency = 1,
        Visible = tabId == GUI.currentTab,
        Center = false,
        Outline = false,
        ZIndex = 10,
    })
    
    checkboxData.elements = {box = box, border = boxBorder, label = labelText}
    checkboxData.bounds = {pos = position, size = Vector2.new(150, 15)}
    
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
        elements = {},
        position = position,
    }
    
    local labelText = createDrawing("Text", {
        Text = label,
        Size = 11,
        Font = Drawing.Fonts.System,
        Position = Vector2.new(position.X, position.Y - 20),
        Color = COLORS.TEXT_WHITE,
        Transparency = 1,
        Visible = tabId == GUI.currentTab,
        Center = false,
        Outline = false,
        ZIndex = 10,
    })
    
    local sliderBg = createDrawing("Square", {
        Size = Vector2.new(180, 10),
        Position = position,
        Color = Color3.fromRGB(0, 0, 0),
        Transparency = 0.2,
        Filled = true,
        Visible = tabId == GUI.currentTab,
        ZIndex = 10,
    })
    
    local sliderBorder = createDrawing("Square", {
        Size = Vector2.new(180, 10),
        Position = position,
        Color = COLORS.BORDER,
        Transparency = 1,
        Filled = false,
        Visible = tabId == GUI.currentTab,
        ZIndex = 11,
    })
    
    local sliderFill = createDrawing("Square", {
        Size = Vector2.new(0, 10),
        Position = position,
        Color = COLORS.SECONDARY,
        Transparency = 1,
        Filled = true,
        Visible = tabId == GUI.currentTab,
        ZIndex = 12,
    })
    
    local valueText = createDrawing("Text", {
        Text = "0",
        Size = 10,
        Font = Drawing.Fonts.System,
        Position = Vector2.new(position.X + 90, position.Y - 1),
        Color = COLORS.TEXT_WHITE,
        Transparency = 1,
        Visible = tabId == GUI.currentTab,
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
local function createFieldset(title, position, tabId)
    local fieldsetData = {
        title = title,
        position = position,
        tabId = tabId,
        elements = {}
    }
    
    local bg = createDrawing("Square", {
        Size = Vector2.new(CONFIG.FIELDSET_WIDTH, CONFIG.FIELDSET_HEIGHT),
        Position = position,
        Color = COLORS.BG_FIELD,
        Transparency = 1,
        Filled = true,
        Visible = tabId == GUI.currentTab,
        ZIndex = 8,
    })
    
    local border = createDrawing("Square", {
        Size = Vector2.new(CONFIG.FIELDSET_WIDTH, CONFIG.FIELDSET_HEIGHT),
        Position = position,
        Color = COLORS.BORDER,
        Transparency = 1,
        Filled = false,
        Visible = tabId == GUI.currentTab,
        ZIndex = 9,
    })
    
    local titleText = createDrawing("Text", {
        Text = title,
        Size = 11,
        Font = Drawing.Fonts.System,
        Position = Vector2.new(position.X + 10, position.Y - 8),
        Color = COLORS.TEXT_WHITE,
        Transparency = 1,
        Visible = tabId == GUI.currentTab,
        Center = false,
        Outline = false,
        ZIndex = 10,
    })
    
    local titleBg = createDrawing("Square", {
        Size = Vector2.new(string.len(title) * 7 + 4, 3),
        Position = Vector2.new(position.X + 8, position.Y - 1),
        Color = COLORS.BG_FIELD,
        Transparency = 1,
        Filled = true,
        Visible = tabId == GUI.currentTab,
        ZIndex = 9,
    })
    
    fieldsetData.elements = {bg, border, titleText, titleBg}
    return fieldsetData
end

-- Create Tab 1 Content (RAGE)
local contentStartX = GUI.position.X + 40
local contentStartY = GUI.position.Y + CONFIG.BAR_HEIGHT + 52

-- Box1
local box1 = createFieldset("Box1", Vector2.new(contentStartX, contentStartY), 1)
local checkbox1 = createCheckbox("Checkbox1", Vector2.new(contentStartX + 15, contentStartY + 20), 1, 1)
local checkbox2 = createCheckbox("Checkbox2", Vector2.new(contentStartX + 15, contentStartY + 45), 1, 2)
local slider1 = createSlider("Range slider1", Vector2.new(contentStartX + 18, contentStartY + 95), 1, 1)

table.insert(GUI.checkboxes, checkbox1)
table.insert(GUI.checkboxes, checkbox2)
table.insert(GUI.sliders, slider1)

-- Box2
local box2 = createFieldset("Box2", Vector2.new(contentStartX + CONFIG.FIELDSET_WIDTH + 40, contentStartY), 1)
local checkbox3 = createCheckbox("Checkbox3", Vector2.new(contentStartX + CONFIG.FIELDSET_WIDTH + 55, contentStartY + 20), 1, 3)
local checkbox4 = createCheckbox("Checkbox4", Vector2.new(contentStartX + CONFIG.FIELDSET_WIDTH + 55, contentStartY + 45), 1, 4)
local slider2 = createSlider("Range slider2", Vector2.new(contentStartX + CONFIG.FIELDSET_WIDTH + 58, contentStartY + 95), 1, 2)

table.insert(GUI.checkboxes, checkbox3)
table.insert(GUI.checkboxes, checkbox4)
table.insert(GUI.sliders, slider2)

print("[FATALITY] Content created")

-- Update all element positions
local function updateAllPositions()
    -- Update main containers
    menuBg.Position = GUI.position
    menuBorder.Position = GUI.position
    topBar.Position = GUI.position
    gradientLine.Position = Vector2.new(GUI.position.X, GUI.position.Y + 15)
    logo.Position = Vector2.new(GUI.position.X + 18, GUI.position.Y + 35)
    insideContainer.Position = Vector2.new(GUI.position.X + 2, GUI.position.Y + CONFIG.BAR_HEIGHT + 35)
    insideBorder.Position = Vector2.new(GUI.position.X + 2, GUI.position.Y + CONFIG.BAR_HEIGHT + 35)
    
    -- Update tabs
    for i, tab in ipairs(tabElements) do
        local xPos = GUI.position.X + tabStartX + ((i - 1) * tabSpacing)
        local yPos = GUI.position.Y + 30
        tab.text.Position = Vector2.new(xPos, yPos)
        tab.underline.Position = Vector2.new(xPos, yPos + 18)
        tab.bounds.pos = Vector2.new(xPos, yPos)
    end
    
    -- Update content positions
    local newContentStartX = GUI.position.X + 40
    local newContentStartY = GUI.position.Y + CONFIG.BAR_HEIGHT + 52
    
    -- Update Box1 fieldset
    for _, elem in ipairs(box1.elements) do
        local offsetX = elem.Position.X - contentStartX
        local offsetY = elem.Position.Y - contentStartY
        elem.Position = Vector2.new(newContentStartX + offsetX, newContentStartY + offsetY)
    end
    
    -- Update Box2 fieldset
    for _, elem in ipairs(box2.elements) do
        local offsetX = elem.Position.X - (contentStartX + CONFIG.FIELDSET_WIDTH + 40)
        local offsetY = elem.Position.Y - contentStartY
        elem.Position = Vector2.new(newContentStartX + CONFIG.FIELDSET_WIDTH + 40 + offsetX, newContentStartY + offsetY)
    end
    
    -- Update checkboxes and sliders
    for _, checkbox in ipairs(GUI.checkboxes) do
        local offsetX = checkbox.position.X - contentStartX
        local offsetY = checkbox.position.Y - contentStartY
        local newPos = Vector2.new(newContentStartX + offsetX, newContentStartY + offsetY)
        
        checkbox.position = newPos
        checkbox.bounds.pos = newPos
        checkbox.elements.box.Position = newPos
        checkbox.elements.border.Position = newPos
        checkbox.elements.label.Position = Vector2.new(newPos.X + 20, newPos.Y - 2)
    end
    
    for _, slider in ipairs(GUI.sliders) do
        local offsetX = slider.position.X - contentStartX
        local offsetY = slider.position.Y - contentStartY
        local newPos = Vector2.new(newContentStartX + offsetX, newContentStartY + offsetY)
        
        slider.position = newPos
        slider.bounds.pos = newPos
        slider.elements.background.Position = newPos
        slider.elements.border.Position = newPos
        slider.elements.fill.Position = newPos
        slider.elements.label.Position = Vector2.new(newPos.X, newPos.Y - 20)
        slider.elements.valueText.Position = Vector2.new(newPos.X + 90, newPos.Y - 1)
    end
    
    contentStartX = newContentStartX
    contentStartY = newContentStartY
end

-- Switch tabs
local function switchTab(newTab)
    if GUI.currentTab == newTab then return end
    GUI.currentTab = newTab
    
    for i, tab in ipairs(tabElements) do
        tab.text.Color = i == newTab and COLORS.TEXT_WHITE or COLORS.TEXT_GRAY
        tab.underline.Transparency = i == newTab and 1 or 0
    end
    
    for _, checkbox in ipairs(GUI.checkboxes) do
        local visible = checkbox.tabId == newTab and GUI.visible
        for _, elem in pairs(checkbox.elements) do
            elem.Visible = visible
        end
    end
    
    for _, slider in ipairs(GUI.sliders) do
        local visible = slider.tabId == newTab and GUI.visible
        for _, elem in pairs(slider.elements) do
            elem.Visible = visible
        end
    end
    
    -- Update fieldsets
    for _, elem in ipairs(box1.elements) do
        elem.Visible = 1 == newTab and GUI.visible
    end
    for _, elem in ipairs(box2.elements) do
        elem.Visible = 1 == newTab and GUI.visible
    end
end

-- Handle checkbox click
local function handleCheckboxClick(checkbox)
    checkbox.checked = not checkbox.checked
    checkbox.elements.box.Color = checkbox.checked and COLORS.SECONDARY or Color3.fromRGB(25, 21, 63)
    checkbox.elements.border.Color = checkbox.checked and COLORS.SECONDARY or COLORS.BORDER
    print("[FATALITY]", checkbox.label, "is now", checkbox.checked and "ON" or "OFF")
end

-- Handle slider drag
local function handleSliderDrag(slider, mouseX)
    local relativeX = mouseX - slider.bounds.pos.X
    relativeX = math.clamp(relativeX, 0, slider.bounds.size.X)
    local percentage = relativeX / slider.bounds.size.X
    slider.value = math.floor(slider.min + (slider.max - slider.min) * percentage)
    slider.elements.fill.Size = Vector2.new(relativeX, 10)
    slider.elements.valueText.Text = tostring(slider.value)
end

-- Input handling
local UserInputService = game:GetService("UserInputService")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode.Value == CONFIG.TOGGLE_KEY then
        GUI.visible = not GUI.visible
        for _, elem in ipairs(GUI.elements) do
            elem.Visible = GUI.visible
        end
        print("[FATALITY] Visibility:", GUI.visible)
        return
    end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        
        -- Check title bar drag
        if isMouseOver(GUI.position, Vector2.new(CONFIG.MENU_WIDTH, CONFIG.BAR_HEIGHT)) then
            GUI.dragging = true
            GUI.dragOffset = Vector2.new(mousePos.X - GUI.position.X, mousePos.Y - GUI.position.Y)
            return
        end
        
        -- Check tab clicks
        for _, tab in ipairs(tabElements) do
            if isMouseOver(tab.bounds.pos, tab.bounds.size) then
                switchTab(tab.index)
                return
            end
        end
        
        -- Check checkbox clicks
        for _, checkbox in ipairs(GUI.checkboxes) do
            if checkbox.tabId == GUI.currentTab and isMouseOver(checkbox.bounds.pos, checkbox.bounds.size) then
                handleCheckboxClick(checkbox)
                return
            end
        end
        
        -- Check slider clicks
        for _, slider in ipairs(GUI.sliders) do
            if slider.tabId == GUI.currentTab and isMouseOver(slider.bounds.pos, slider.bounds.size) then
                slider.dragging = true
                handleSliderDrag(slider, mouse.X)
                return
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        GUI.dragging = false
        for _, slider in ipairs(GUI.sliders) do
            slider.dragging = false
        end
    end
end)

-- Main update loop
spawn(function()
    while true do
        wait(0.016)
        
        if GUI.visible then
            if GUI.dragging then
                local mousePos = Vector2.new(mouse.X, mouse.Y)
                GUI.position = Vector2.new(mousePos.X - GUI.dragOffset.X, mousePos.Y - GUI.dragOffset.Y)
                updateAllPositions()
            end
            
            for _, slider in ipairs(GUI.sliders) do
                if slider.dragging and slider.tabId == GUI.currentTab then
                    handleSliderDrag(slider, mouse.X)
                end
            end
        end
    end
end)

print("[FATALITY] GUI loaded successfully!")
print("[FATALITY] Press DELETE to toggle")

-- API
local API = {
    toggle = function()
        GUI.visible = not GUI.visible
        for _, elem in ipairs(GUI.elements) do
            elem.Visible = GUI.visible
        end
    end,
    setCheckbox = function(tabId, index, value)
        for _, cb in ipairs(GUI.checkboxes) do
            if cb.tabId == tabId and cb.index == index then
                cb.checked = value
                cb.elements.box.Color = value and COLORS.SECONDARY or Color3.fromRGB(25, 21, 63)
                cb.elements.border.Color = value and COLORS.SECONDARY or COLORS.BORDER
                break
            end
        end
    end,
    getCheckbox = function(tabId, index)
        for _, cb in ipairs(GUI.checkboxes) do
            if cb.tabId == tabId and cb.index == index then
                return cb.checked
            end
        end
        return false
    end,
    setSlider = function(tabId, index, value)
        for _, sl in ipairs(GUI.sliders) do
            if sl.tabId == tabId and sl.index == index then
                sl.value = math.clamp(value, sl.min, sl.max)
                local percentage = (sl.value - sl.min) / (sl.max - sl.min)
                sl.elements.fill.Size = Vector2.new(sl.bounds.size.X * percentage, 10)
                sl.elements.valueText.Text = tostring(sl.value)
                break
            end
        end
    end,
    getSlider = function(tabId, index)
        for _, sl in ipairs(GUI.sliders) do
            if sl.tabId == tabId and sl.index == index then
                return sl.value
            end
        end
        return 0
    end,
}

_G.FatalityGUI = API
return API
