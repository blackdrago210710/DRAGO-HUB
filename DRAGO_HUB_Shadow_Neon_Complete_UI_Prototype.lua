--[[
DRAGO HUB — AOT REVOLUTION | SHADOW NEON
Compact mobile-first Roblox Studio LocalScript UI prototype.

INSTALL:
1. Open Roblox Studio and create/open your own place.
2. In Explorer, go to StarterPlayer > StarterPlayerScripts.
3. Insert a LocalScript.
4. Replace its contents with this entire file.
5. Press Play to test the interface.

IMPORTANT:
- This is a UI / personal tracker prototype for Roblox Studio.
- It does NOT inject into Delta or other executors.
- Game-action controls (auto farm/attack/raid/dodge, etc.) are UI placeholders only.
  They do not automate a third-party game or bypass its rules.
- The family list is the list supplied by the user and is not independently verified.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then return end

local PLAYER_GUI = player:WaitForChild("PlayerGui")

-- Remove an older copy when testing repeatedly in Studio.
local old = PLAYER_GUI:FindFirstChild("DragoHubShadowNeon")
if old then old:Destroy() end

local C = {
    bg = Color3.fromRGB(9, 10, 16),
    panel = Color3.fromRGB(17, 19, 29),
    panel2 = Color3.fromRGB(23, 26, 39),
    panel3 = Color3.fromRGB(30, 34, 50),
    red = Color3.fromRGB(255, 48, 72),
    blue = Color3.fromRGB(0, 205, 255),
    violet = Color3.fromRGB(154, 91, 255),
    white = Color3.fromRGB(239, 243, 255),
    muted = Color3.fromRGB(143, 153, 177),
    green = Color3.fromRGB(66, 230, 153),
    gold = Color3.fromRGB(255, 198, 77),
    line = Color3.fromRGB(49, 55, 76),
}

local state = {
    selectedTab = "Home",
    minimized = false,
    hidden = false,
    uiScale = 1,
    accent = "Shadow Neon",
    targetFamily = "Ackerman",
    toggles = {},
    activity = {},
    soundNotifications = false,
    selectedEquipmentA = "ODM Gear A",
    selectedEquipmentB = "ODM Gear B",
}

local families = {
    {name="Reeves", rarity="Common"}, {name="Blouse", rarity="Common"},
    {name="Inocenio", rarity="Common"}, {name="Munsell", rarity="Common"},
    {name="Boyega", rarity="Common"}, {name="Ral", rarity="Common"},
    {name="Bozado", rarity="Common"}, {name="Pikale", rarity="Common"},
    {name="Hume", rarity="Common"}, {name="Iglehaut", rarity="Common"},
    {name="Smith", rarity="Rare"}, {name="Springer", rarity="Rare"},
    {name="Kirstein", rarity="Rare"}, {name="Grice", rarity="Rare"},
    {name="Azumabito", rarity="Rare"}, {name="Braus", rarity="Rare"},
    {name="Kruger", rarity="Rare"},
    {name="Zoe", rarity="Epic"}, {name="Tybur", rarity="Epic"},
    {name="Leonhart", rarity="Epic"}, {name="Galliard", rarity="Epic"},
    {name="Finger", rarity="Epic"}, {name="Braun", rarity="Epic"},
    {name="Arlert", rarity="Epic"}, {name="Ksaver", rarity="Epic"},
    {name="Ackerman", rarity="Legendary"}, {name="Yeager", rarity="Legendary"},
    {name="Reiss", rarity="Legendary"},
    {name="Fritz", rarity="Mythical"}, {name="Helos", rarity="Mythical"},
    {name="Shiki", rarity="Secret"},
}

local rarityColors = {
    Common = C.muted,
    Rare = C.blue,
    Epic = C.violet,
    Legendary = C.gold,
    Mythical = C.red,
    Secret = Color3.fromRGB(255, 95, 205),
}

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(parent, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end

local function stroke(parent, color, thickness, transparency)
    return make("UIStroke", {
        Color = color or C.line,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function pad(parent, left, right, top, bottom)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, left or 8),
        PaddingRight = UDim.new(0, right or 8),
        PaddingTop = UDim.new(0, top or 8),
        PaddingBottom = UDim.new(0, bottom or 8),
    }, parent)
end

local gui = make("ScreenGui", {
    Name = "DragoHubShadowNeon",
    ResetOnSpawn = false,
    IgnoreGuiInset = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 50,
}, PLAYER_GUI)

local scale = make("UIScale", {Scale = state.uiScale}, gui)

local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0, 610, 0, 440),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
corner(main, 15)
local mainStroke = stroke(main, C.red, 1.5, 0.08)

local header = make("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 62),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, main)
corner(header, 15)
make("Frame", {
    Position = UDim2.new(0, 0, 1, -14),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, header)

local logo = make("Frame", {
    Position = UDim2.new(0, 14, 0, 12),
    Size = UDim2.new(0, 38, 0, 38),
    BackgroundColor3 = C.panel3,
    BorderSizePixel = 0,
}, header)
corner(logo, 11)
stroke(logo, C.blue, 1.2, 0.1)
make("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBlack,
    Text = "D",
    TextSize = 25,
    TextColor3 = C.red,
}, logo)

make("TextLabel", {
    Position = UDim2.new(0, 62, 0, 9),
    Size = UDim2.new(0, 280, 0, 25),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack,
    Text = "DRAGO HUB",
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = C.white,
}, header)

make("TextLabel", {
    Position = UDim2.new(0, 63, 0, 33),
    Size = UDim2.new(0, 300, 0, 16),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "AOT REVOLUTION  •  SHADOW NEON",
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = C.blue,
}, header)

local statusDot = make("Frame", {
    Position = UDim2.new(1, -140, 0, 24),
    Size = UDim2.new(0, 8, 0, 8),
    BackgroundColor3 = C.green,
    BorderSizePixel = 0,
}, header)
corner(statusDot, 99)
make("TextLabel", {
    Position = UDim2.new(1, -127, 0, 18),
    Size = UDim2.new(0, 70, 0, 20),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "READY",
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = C.green,
}, header)

local minimizeBtn = make("TextButton", {
    Name = "Minimize",
    Position = UDim2.new(1, -48, 0, 15),
    Size = UDim2.new(0, 32, 0, 32),
    BackgroundColor3 = C.panel3,
    BorderSizePixel = 0,
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = C.white,
    AutoButtonColor = true,
}, header)
corner(minimizeBtn, 9)
stroke(minimizeBtn, C.line, 1)

local body = make("Frame", {
    Name = "Body",
    Position = UDim2.new(0, 0, 0, 62),
    Size = UDim2.new(1, 0, 1, -62),
    BackgroundTransparency = 1,
}, main)

local sidebar = make("Frame", {
    Name = "Sidebar",
    Position = UDim2.new(0, 10, 0, 10),
    Size = UDim2.new(0, 130, 1, -20),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, body)
corner(sidebar, 12)
pad(sidebar, 7, 7, 8, 8)

make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "NAVIGATION",
    TextSize = 9,
    TextColor3 = C.muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)

local navList = make("Frame", {
    Position = UDim2.new(0, 0, 0, 27),
    Size = UDim2.new(1, 0, 1, -27),
    BackgroundTransparency = 1,
}, sidebar)
make("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, navList)

local content = make("Frame", {
    Name = "Content",
    Position = UDim2.new(0, 150, 0, 10),
    Size = UDim2.new(1, -160, 1, -20),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, body)
corner(content, 12)
pad(content, 12, 12, 12, 12)

local pageTitle = make("TextLabel", {
    Name = "PageTitle",
    Size = UDim2.new(1, 0, 0, 27),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack,
    Text = "HOME / OVERVIEW",
    TextSize = 17,
    TextColor3 = C.white,
    TextXAlignment = Enum.TextXAlignment.Left,
}, content)

local pageSubtitle = make("TextLabel", {
    Position = UDim2.new(0, 0, 0, 27),
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Your shadow command center.",
    TextSize = 10,
    TextColor3 = C.muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, content)

local pageArea = make("ScrollingFrame", {
    Name = "PageArea",
    Position = UDim2.new(0, 0, 0, 52),
    Size = UDim2.new(1, 0, 1, -52),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = C.blue,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, content)
pad(pageArea, 1, 5, 1, 10)
make("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, pageArea)

local toastHolder = make("Frame", {
    Name = "ToastHolder",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -16, 0, 16),
    Size = UDim2.new(0, 250, 0, 150),
    BackgroundTransparency = 1,
    ZIndex = 20,
}, gui)
make("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
}, toastHolder)

local function logActivity(message)
    table.insert(state.activity, 1, os.date("%H:%M:%S") .. "  •  " .. message)
    while #state.activity > 40 do table.remove(state.activity) end
end

local function notify(message, color)
    logActivity(message)
    local toast = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = C.panel2,
        BorderSizePixel = 0,
        Text = "  " .. message,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = C.white,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 21,
    }, toastHolder)
    corner(toast, 9)
    stroke(toast, color or C.blue, 1)
    task.delay(3.5, function()
        if toast and toast.Parent then
            local tw = TweenService:Create(toast, TweenInfo.new(0.25), {BackgroundTransparency = 1, TextTransparency = 1})
            tw:Play()
            tw.Completed:Wait()
            if toast then toast:Destroy() end
        end
    end)
    if state.soundNotifications then
        -- No external audio asset is loaded by this prototype.
        statusDot.BackgroundColor3 = C.gold
        task.delay(0.25, function()
            if statusDot and statusDot.Parent then statusDot.BackgroundColor3 = C.green end
        end)
    end
end

local function clearPage()
    for _, child in ipairs(pageArea:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
end

local function section(title, description)
    local box = make("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = C.panel2,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, pageArea)
    corner(box, 10)
    stroke(box, C.line, 1, 0.25)
    pad(box, 10, 10, 9, 9)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextSize = 12,
        TextColor3 = C.white,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, box)
    make("TextLabel", {
        Position = UDim2.new(0, 0, 0, 23),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = description or "",
        TextSize = 10,
        TextWrapped = true,
        TextColor3 = C.muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, box)
    return box
end

local function actionButton(parent, text, callback, accent)
    local button = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = C.panel3,
        BorderSizePixel = 0,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = C.white,
        AutoButtonColor = true,
    }, parent)
    corner(button, 8)
    stroke(button, accent or C.blue, 1, 0.3)
    button.Activated:Connect(callback)
    return button
end

local function addToggle(parent, label, key, detail)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, detail and 58 or 38),
        BackgroundColor3 = C.panel2,
        BorderSizePixel = 0,
    }, parent)
    corner(row, 8)
    local text = make("TextLabel", {
        Position = UDim2.new(0, 10, 0, detail and 7 or 0),
        Size = UDim2.new(1, -72, 0, detail and 20 or 38),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = label,
        TextSize = 11,
        TextColor3 = C.white,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = detail and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
    }, row)
    if detail then
        make("TextLabel", {
            Position = UDim2.new(0, 10, 0, 28),
            Size = UDim2.new(1, -20, 0, 23),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = detail,
            TextSize = 9,
            TextWrapped = true,
            TextColor3 = C.muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        }, row)
    end
    local btn = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.new(0, 48, 0, 23),
        BackgroundColor3 = state.toggles[key] and C.blue or C.panel3,
        BorderSizePixel = 0,
        Text = state.toggles[key] and "ON" or "OFF",
        Font = Enum.Font.GothamBlack,
        TextSize = 9,
        TextColor3 = C.white,
    }, row)
    corner(btn, 7)
    btn.Activated:Connect(function()
        state.toggles[key] = not state.toggles[key]
        btn.Text = state.toggles[key] and "ON" or "OFF"
        btn.BackgroundColor3 = state.toggles[key] and C.blue or C.panel3
        notify(label .. ": " .. (state.toggles[key] and "enabled in UI" or "disabled in UI"), state.toggles[key] and C.blue or C.red)
    end)
    return row
end

local function addLabel(parent, text, color, height)
    local lbl = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, height or 24),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextSize = 10,
        TextColor3 = color or C.muted,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
    return lbl
end

local function addInput(parent, placeholder, initialText)
    local box = make("TextBox", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = C.panel3,
        BorderSizePixel = 0,
        PlaceholderText = placeholder,
        Text = initialText or "",
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.white,
        PlaceholderColor3 = C.muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
    corner(box, 8)
    stroke(box, C.line, 1)
    pad(box, 9, 9, 0, 0)
    return box
end

local tabs = {
    {"Home", "⌂"}, {"Family", "✦"}, {"Combat", "⚔"}, {"Farming", "↗"},
    {"Raids", "◆"}, {"Maps", "◎"}, {"Equipment", "◇"}, {"Settings", "⚙"},
    {"Activity Log", "≡"},
}
local navButtons = {}

local function setPage(name)
    state.selectedTab = name
    for tabName, btn in pairs(navButtons) do
        btn.BackgroundColor3 = tabName == name and C.panel3 or C.panel
        btn.TextColor3 = tabName == name and C.blue or C.muted
    end
    clearPage()
    pageTitle.Text = string.upper(name) .. " / " .. (name == "Home" and "OVERVIEW" or "CONTROL")
    local subtitles = {
        Home = "Your shadow command center.",
        Family = "Browse the supplied family list and set a personal target.",
        Combat = "Configuration preview — no gameplay automation is connected.",
        Farming = "Track goals and progress without automating gameplay.",
        Raids = "Raid planning, history, and status dashboard.",
        Maps = "Map notes and legitimate route planning.",
        Equipment = "Compare equipment notes side by side.",
        Settings = "Personalize the Shadow Neon interface.",
        ["Activity Log"] = "Recent actions taken inside this UI prototype.",
    }
    pageSubtitle.Text = subtitles[name] or ""

    if name == "Home" then
        section("WELCOME TO DRAGO HUB", "A compact, mobile-first Shadow Neon dashboard. Use the tabs to browse your tools.")
        section("SESSION STATUS", "Interface: running  •  Mode: UI prototype  •  Family entries: " .. tostring(#families))
        section("QUICK ACTIONS", "These open the relevant interface pages. Game-action automation is not connected.")
        local box = make("Frame", {Size=UDim2.new(1,0,0,78), BackgroundTransparency=1}, pageArea)
        make("UIGridLayout", {CellSize=UDim2.new(0.48,0,0,34), CellPadding=UDim2.new(0,6,0,7), SortOrder=Enum.SortOrder.LayoutOrder}, box)
        actionButton(box, "OPEN FAMILY", function() setPage("Family") end, C.violet)
        actionButton(box, "EQUIPMENT COMPARE", function() setPage("Equipment") end, C.blue)
        actionButton(box, "VIEW ACTIVITY", function() setPage("Activity Log") end, C.red)
        actionButton(box, "UI SETTINGS", function() setPage("Settings") end, C.violet)
        section("SAFETY NOTE", "Buttons for Auto Farm, Auto Attack, Auto Raid, Auto Dodge, and similar features are interface placeholders. They do not control the game.")
    elseif name == "Family" then
        section("FAMILY TARGET", "Choose a name for your personal target list. This does not change reroll odds or roll a family.")
        local search = addInput(pageArea, "Search family name...")
        local rarityFilter = addInput(pageArea, "Rarity filter: All / Common / Rare / Epic / Legendary / Mythical / Secret", "All")
        local chosen = make("TextLabel", {
            Size=UDim2.new(1,0,0,32), BackgroundColor3=C.panel3, BorderSizePixel=0,
            Text="  TARGET: "..state.targetFamily, Font=Enum.Font.GothamBold, TextSize=11,
            TextColor3=C.gold, TextXAlignment=Enum.TextXAlignment.Left,
        }, pageArea)
        corner(chosen, 8)
        local list = make("Frame", {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1}, pageArea)
        local listLayout = make("UIListLayout", {Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder}, list)
        local function refreshFamilies()
            for _, child in ipairs(list:GetChildren()) do
                if child:IsA("GuiObject") then child:Destroy() end
            end
            local query = string.lower(search.Text or "")
            local rarity = string.lower((rarityFilter.Text ~= "" and rarityFilter.Text or "All"))
            for _, item in ipairs(families) do
                local matchesName = string.find(string.lower(item.name), query, 1, true) ~= nil
                local matchesRarity = rarity == "all" or rarity == "" or string.lower(item.rarity) == rarity
                if matchesName and matchesRarity then
                    local b = make("TextButton", {
                        Size=UDim2.new(1,0,0,31), BackgroundColor3=C.panel2, BorderSizePixel=0,
                        Text="  "..item.name.."     •     "..item.rarity,
                        Font=Enum.Font.GothamBold, TextSize=10, TextColor3=rarityColors[item.rarity],
                        TextXAlignment=Enum.TextXAlignment.Left,
                    }, list)
                    corner(b, 7)
                    stroke(b, item.name == state.targetFamily and C.gold or C.line, 1, 0.35)
                    b.Activated:Connect(function()
                        state.targetFamily = item.name
                        chosen.Text = "  TARGET: "..state.targetFamily
                        notify("Target family set to "..item.name, rarityColors[item.rarity])
                        refreshFamilies()
                    end)
                end
            end
        end
        search:GetPropertyChangedSignal("Text"):Connect(refreshFamilies)
        rarityFilter:GetPropertyChangedSignal("Text"):Connect(refreshFamilies)
        refreshFamilies()
        section("LUCK / REROLL INFORMATION", "Only use luck boosts and rerolls provided by the actual game. This UI cannot increase RNG odds, force a family, or reroll automatically.")
    elseif name == "Combat" then
        section("COMBAT CONFIGURATION", "The controls below are saved as UI preferences only; they do not issue attacks or modify the game.")
        addToggle(pageArea, "Auto Attack (UI placeholder)", "autoAttack", "Display toggle only; no attack automation is connected.")
        addToggle(pageArea, "Titan Targeting Preference", "titanTarget", "Preference marker for your notes; does not lock onto in-game targets.")
        addToggle(pageArea, "Multi-Hit Preference", "multiHit", "UI-only setting; no hitbox or damage modification.")
        addToggle(pageArea, "Auto Dodge Preference", "autoDodge", "UI-only setting; no automatic dodging.")
        addToggle(pageArea, "Structure Unstuck Reminder", "unstuckReminder", "Reminder only. No noclip, wall penetration, or ground bypass.")
        addToggle(pageArea, "Performance-Friendly Display", "performance", "Keeps this dashboard lightweight; does not alter game graphics.")
    elseif name == "Farming" then
        section("FARMING DASHBOARD", "Track your own goals while playing normally. Automation is not connected.")
        addToggle(pageArea, "Auto Farm (UI placeholder)", "autoFarm", "Visual toggle only — does not farm or move your character.")
        addToggle(pageArea, "Auto Quest (UI placeholder)", "autoQuest", "Visual toggle only — does not accept or complete quests.")
        addToggle(pageArea, "Progress Reminders", "progressReminders", "A local UI preference for tracking your goals.")
        addLabel(pageArea, "PERSONAL GOAL", C.blue)
        local goal = addInput(pageArea, "e.g. Finish 3 missions today")
        actionButton(pageArea, "SAVE GOAL", function()
            state.personalGoal = goal.Text
            notify("Personal goal saved in this session")
        end, C.blue)
        section("PROGRESS DASHBOARD", "Use the goal field to track your own progress. This prototype does not read private game stats.")
    elseif name == "Raids" then
        section("RAID CONTROL CENTER", "Plan and track raids manually. No raid queueing or automated gameplay is connected.")
        addToggle(pageArea, "Auto Raid (UI placeholder)", "autoRaid", "Visual toggle only — does not enter or run raids.")
        addToggle(pageArea, "Auto Rejoin Reminder", "autoRejoin", "Preference only; this script does not rejoin servers.")
        addLabel(pageArea, "RAID NOTES", C.blue)
        local notes = addInput(pageArea, "Write raid plan / team notes...")
        actionButton(pageArea, "SAVE RAID NOTE", function()
            state.raidNotes = notes.Text
            notify("Raid note saved in this session")
        end, C.violet)
        section("RAID HISTORY", "Recent raid results can be added to Activity Log manually.")
    elseif name == "Maps" then
        section("MAP INTEL", "A planning area for your own map notes and route reminders.")
        local mapName = addInput(pageArea, "Map or mission name...")
        local mapNotes = addInput(pageArea, "Route / landmark notes...")
        actionButton(pageArea, "SAVE MAP NOTE", function()
            state.mapNote = (mapName.Text or "Unknown map") .. " — " .. (mapNotes.Text or "")
            notify("Map note saved in this session")
        end, C.blue)
        addToggle(pageArea, "Luck Boost Map Reminder", "luckMapReminder", "Reminder preference only; it does not detect hidden boosts or change luck.")
        addToggle(pageArea, "Structure Unstuck Reminder", "mapUnstuck", "Reminder only; no noclip or collision bypass.")
        section("MAP FINDER LIMIT", "The prototype cannot scan a live game world or identify secret drops. Use only map information available through legitimate game features.")
    elseif name == "Equipment" then
        section("EQUIPMENT COMPARISON", "Compare your own notes for two equipment items.")
        local a = addInput(pageArea, "Equipment A name...", state.selectedEquipmentA)
        local aStats = addInput(pageArea, "A stats / notes...")
        local b = addInput(pageArea, "Equipment B name...", state.selectedEquipmentB)
        local bStats = addInput(pageArea, "B stats / notes...")
        local result = make("TextLabel", {
            Size=UDim2.new(1,0,0,75), BackgroundColor3=C.panel3, BorderSizePixel=0,
            Text="Comparison will appear here.", Font=Enum.Font.Gotham, TextSize=10,
            TextColor3=C.white, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left,
            TextYAlignment=Enum.TextYAlignment.Top,
        }, pageArea)
        corner(result, 8)
        pad(result, 9, 9, 8, 8)
        actionButton(pageArea, "COMPARE EQUIPMENT NOTES", function()
            state.selectedEquipmentA = a.Text
            state.selectedEquipmentB = b.Text
            result.Text = (a.Text ~= "" and a.Text or "Equipment A") .. "\nA: " .. (aStats.Text ~= "" and aStats.Text or "No notes") ..
                "\n\n" .. (b.Text ~= "" and b.Text or "Equipment B") .. "\nB: " .. (bStats.Text ~= "" and bStats.Text or "No notes")
            notify("Equipment comparison updated")
        end, C.blue)
        section("EQUIPMENT VIEWER", "This is a notes-based comparison. It does not inspect or change your live inventory.")
    elseif name == "Settings" then
        section("INTERFACE SETTINGS", "Adjust the look and behavior of this prototype.")
        addLabel(pageArea, "UI SCALE", C.blue)
        local scaleBox = addInput(pageArea, "Enter scale from 0.70 to 1.20", tostring(state.uiScale))
        actionButton(pageArea, "APPLY UI SCALE", function()
            local n = tonumber(scaleBox.Text)
            if n and n >= 0.7 and n <= 1.2 then
                state.uiScale = n
                scale.Scale = n
                notify("UI scale set to "..tostring(n))
            else
                notify("Scale must be between 0.70 and 1.20", C.red)
            end
        end, C.blue)
        actionButton(pageArea, "SHADOW NEON THEME", function()
            C.red = Color3.fromRGB(255,48,72); C.blue = Color3.fromRGB(0,205,255); C.violet = Color3.fromRGB(154,91,255)
            mainStroke.Color = C.red
            notify("Shadow Neon theme selected")
        end, C.red)
        actionButton(pageArea, "CRIMSON THEME", function()
            C.red = Color3.fromRGB(255,65,65); C.blue = Color3.fromRGB(255,100,100); C.violet = Color3.fromRGB(180,65,100)
            mainStroke.Color = C.red
            notify("Crimson theme selected")
        end, C.red)
        addToggle(pageArea, "Sound Notifications (visual cue)", "soundNotify", "Uses a brief status light cue; no audio asset is loaded.")
        actionButton(pageArea, "EMERGENCY HIDE / SHOW", function()
            state.hidden = not state.hidden
            main.Visible = not state.hidden
            notify(state.hidden and "Hub hidden. Use the floating restore control." or "Hub shown again")
        end, C.violet)
        section("PROFILES", "Settings are session-only in this prototype. A real profile save system needs a server-side data design in your own experience.")
        actionButton(pageArea, "RESET UI PREFERENCES", function()
            state.toggles = {}
            state.uiScale = 1
            scale.Scale = 1
            notify("UI preferences reset")
            setPage("Settings")
        end, C.red)
    elseif name == "Activity Log" then
        section("ACTIVITY LOG", "This records actions performed inside this UI during the current session.")
        actionButton(pageArea, "REFRESH LOG", function() setPage("Activity Log") end, C.blue)
        if #state.activity == 0 then
            addLabel(pageArea, "No activity yet. Click a UI control to create a log entry.", C.muted, 35)
        else
            for _, entry in ipairs(state.activity) do
                local item = make("TextLabel", {
                    Size=UDim2.new(1,0,0,30), BackgroundColor3=C.panel2, BorderSizePixel=0,
                    Text="  "..entry, Font=Enum.Font.Gotham, TextSize=9, TextColor3=C.white,
                    TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
                }, pageArea)
                corner(item, 7)
            end
        end
        actionButton(pageArea, "CLEAR ACTIVITY LOG", function()
            state.activity = {}
            notify("Activity log cleared")
            setPage("Activity Log")
        end, C.red)
    end
end

for i, info in ipairs(tabs) do
    local name, icon = info[1], info[2]
    local btn = make("TextButton", {
        Name = name:gsub("%s+", ""),
        Size = UDim2.new(1, 0, 0, 31),
        BackgroundColor3 = name == "Home" and C.panel3 or C.panel,
        BorderSizePixel = 0,
        Text = icon .. "   " .. name,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = name == "Home" and C.blue or C.muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = i,
    }, navList)
    corner(btn, 8)
    navButtons[name] = btn
    btn.Activated:Connect(function() setPage(name) end)
end

-- Minimize to a compact header; tap the button again to restore.
minimizeBtn.Activated:Connect(function()
    state.minimized = not state.minimized
    body.Visible = not state.minimized
    main.Size = state.minimized and UDim2.new(0, 330, 0, 62) or UDim2.new(0, 610, 0, 440)
    minimizeBtn.Text = state.minimized and "+" or "—"
end)

-- Draggable header (mouse and touch).
local dragging = false
local dragStart, startPosition
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)

-- Emergency restore chip remains available when the hub is hidden.
local restore = make("TextButton", {
    Name = "RestoreDragoHub",
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -14, 1, -18),
    Size = UDim2.new(0, 95, 0, 34),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    Text = "DRAGO  ◈",
    Font = Enum.Font.GothamBlack,
    TextSize = 11,
    TextColor3 = C.blue,
    Visible = false,
}, gui)
corner(restore, 10)
stroke(restore, C.red, 1.2)
restore.Activated:Connect(function()
    state.hidden = false
    main.Visible = true
    restore.Visible = false
    notify("Hub restored")
end)

-- Replace emergency hide action with a safe restore-chip behavior.
-- The settings button's callback toggles the hub; this watcher makes the chip appear.
RunService.Heartbeat:Connect(function()
    if state.hidden then
        main.Visible = false
        restore.Visible = true
    else
        restore.Visible = false
    end
end)

-- If the player respawns, keep the ScreenGui alive and the interface available.
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if gui and gui.Parent then
        gui.Enabled = true
    end
end)

setPage("Home")
notify("DRAGO HUB UI loaded — Studio prototype", C.blue)
