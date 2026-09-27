local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local Stats        = game:GetService("Stats")
local Players      = game:GetService("Players")

local GOLD_BRIGHT  = Color3.fromRGB(255, 215, 100)
local GOLD_MID     = Color3.fromRGB(200, 160, 60)
local GOLD_HOVER   = Color3.fromRGB(130, 100, 40)
local ICON_IDLE    = Color3.fromRGB(230, 200, 130)
local ICON_HOVER   = Color3.fromRGB(255, 235, 170)

local FONT      = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
local FONT_BOLD = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

local ICON_SIZE     = 36
local EXPAND_WIDTH  = 120
local EXPAND_TIME   = 0.3
local BOUNCE_STYLE  = Enum.EasingStyle.Back
local BOUNCE_DIR    = Enum.EasingDirection.Out

local BAR_RESTING_Y = -16
local BAR_HIDDEN_Y  = 90
local CHEV_OPEN_Y   = -100
local CHEV_CLOSED_Y = -14

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Reiihub"

    local self = setmetatable({}, Library)
    self.Tabs = {}
    self.SettingsToggles = {}

    self.ScreenGui = new("ScreenGui", {
        Name = "Reiihub - UI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
    })

    self.SmartBar = new("Frame", {
        ZIndex = 150,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(17, 17, 17),
        AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.new(0, 319, 0, 70),
        Position = UDim2.new(0.5, 0, 1, BAR_HIDDEN_Y),
        Name = "SmartBar",
        BackgroundTransparency = 1,
        Parent = self.ScreenGui,
    })

    new("UIScale", { Scale = 0.96056 }, self.SmartBar)
    new("UICorner", { CornerRadius = UDim.new(0, 15) }, self.SmartBar)

    self.BarStroke = new("UIStroke", {
        Transparency = 0.4,
        Thickness = 1.2,
        Color = Color3.fromRGB(255, 255, 255),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, self.SmartBar)

    new("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 190, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 70, 25)),
        },
    }, self.BarStroke)

    local shadow = new("Frame", {
        ZIndex = 149,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(17, 17, 17),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Name = "ShadowCaster",
        BackgroundTransparency = 1,
        ClipsDescendants = false,
    }, self.SmartBar)
    new("UICorner", { CornerRadius = UDim.new(0, 15) }, shadow)
    new("UIShadow", {}, shadow)

    self.TabsFrame = new("Frame", {
        ZIndex = 150,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Name = "Tabs",
        BackgroundTransparency = 1,
    }, self.SmartBar)

    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, self.TabsFrame)

    new("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, self.TabsFrame)

    self.Chevron = new("ImageButton", {
        Name = "Chevron",
        ZIndex = 200,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(0.5, 0, 1, CHEV_CLOSED_Y),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(564, 284),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = Color3.fromRGB(230, 190, 80),
        Rotation = 180,
        Parent = self.ScreenGui,
    })

    self.Watermark = new("Frame", {
        Visible = true,
        ZIndex = 9000,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(21, 21, 23),
        AnchorPoint = Vector2.new(0, 1),
        Size = UDim2.new(0, 340, 0, 34),
        Position = UDim2.new(0, 20, 1, -20),
        Name = "Watermark",
        Parent = self.ScreenGui,
    })

    new("UICorner", { CornerRadius = UDim.new(0, 11) }, self.Watermark)
    new("UIShadow", {}, self.Watermark)
    new("UIStroke", {
        Transparency = 0.6,
        Color = Color3.fromRGB(230, 190, 80),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, self.Watermark)

    local wmContent = new("Frame", {
        ZIndex = 9001,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Name = "Content",
        BackgroundTransparency = 1,
    }, self.Watermark)

    new("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
    }, wmContent)

    local function makeDivider(order)
        new("Frame", {
            ZIndex = 9001,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(244, 242, 237),
            Size = UDim2.new(0, 1, 0, 12),
            Name = "divider" .. order,
            LayoutOrder = order,
            BackgroundTransparency = 0.75,
        }, wmContent)
    end

    local function makeText(text, order, font, color, gradient)
        local t = new("TextLabel", {
            ZIndex = 9001,
            BorderSizePixel = 0,
            TextSize = 13,
            FontFace = font,
            TextColor3 = color,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            Text = text,
            LayoutOrder = order,
            AutomaticSize = Enum.AutomaticSize.X,
            Name = "part" .. order,
        }, wmContent)
        if gradient then
            new("UIGradient", { Rotation = 12, Color = gradient }, t)
        end
        return t
    end

    makeText(title, 1, FONT_BOLD, Color3.fromRGB(255, 255, 255), ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 170)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 160, 60)),
    })
    makeDivider(2)
    self.WatermarkSubLabel = makeText("discord.gg/gay", 3, FONT, Color3.fromRGB(244, 242, 237))
    makeDivider(4)
    self.FpsLabel = makeText("FPS: --", 5, FONT, Color3.fromRGB(204, 183, 148))
    makeDivider(6)
    self.PingLabel = makeText("Ping: --", 7, FONT, Color3.fromRGB(204, 183, 148))

    new("TextButton", {
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 9002,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Name = "WatermarkButton",
    }, self.Watermark)

    local fpsFrameCount, fpsAccum = 0, 0
    RunService.RenderStepped:Connect(function(dt)
        fpsFrameCount += 1
        fpsAccum += dt
        if fpsAccum >= 1 then
            self.FpsLabel.Text = "FPS: " .. math.floor(fpsFrameCount / fpsAccum + 0.5)
            fpsFrameCount, fpsAccum = 0, 0
        end
    end)

    task.spawn(function()
        local pingItem = Stats.Network.ServerStatsItem["Data Ping"]
        while task.wait(1) do
            local ok, value = pcall(function() return pingItem:GetValue() end)
            self.PingLabel.Text = ok and string.format("Ping: %d ms", math.floor(value + 0.5)) or "Ping: --"
        end
    end)

    self.SettingsPanel = new("Frame", {
        Name = "SettingsPanel",
        ZIndex = 145,
        AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.new(0, 290, 0, 0),
        Position = UDim2.new(0.5, 0, 0, -6),
        BackgroundColor3 = Color3.fromRGB(21, 21, 23),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
    }, self.SmartBar)

    new("UICorner", { CornerRadius = UDim.new(0, 12) }, self.SettingsPanel)
    new("UIStroke", {
        Transparency = 0.55,
        Thickness = 1,
        Color = Color3.fromRGB(230, 190, 80),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, self.SettingsPanel)

    new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, self.SettingsPanel)

    new("UIPadding", {
        PaddingTop    = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft   = UDim.new(0, 8),
        PaddingRight  = UDim.new(0, 8),
    }, self.SettingsPanel)

    self.SettingsOpen = false
    self.MenuOpen = false

    self.Chevron.MouseButton1Click:Connect(function()
        self:SetMenuOpen(not self.MenuOpen)
    end)

    self.Chevron.MouseEnter:Connect(function()
        TweenService:Create(self.Chevron, TweenInfo.new(0.15),
            { ImageColor3 = Color3.fromRGB(255, 235, 170) }):Play()
    end)
    self.Chevron.MouseLeave:Connect(function()
        TweenService:Create(self.Chevron, TweenInfo.new(0.15),
            { ImageColor3 = Color3.fromRGB(230, 190, 80) }):Play()
    end)

    self:CreateTab("Settings", "rbxassetid://80758916183665", function()
        self:SetSettingsOpen(not self.SettingsOpen)
    end)

    return self
end

function Library:SetSettingsOpen(open)
    self.SettingsOpen = open
    if open then
        self.SettingsPanel.Visible = true
        self.SettingsPanel.Size = UDim2.new(0, 290, 0, 0)
        TweenService:Create(self.SettingsPanel,
            TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 290, 0, 132) }
        ):Play()
    else
        local t = TweenService:Create(self.SettingsPanel,
            TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 290, 0, 0) }
        )
        t.Completed:Connect(function()
            if not self.SettingsOpen then
                self.SettingsPanel.Visible = false
            end
        end)
        t:Play()
    end
end

function Library:SetMenuOpen(open)
    self.MenuOpen = open
    if not open then
        if self.SettingsOpen then
            self:SetSettingsOpen(false)
        end
        for _, tab in pairs(self.Tabs) do
            tab.Dot.Visible = false
        end
    end

    TweenService:Create(self.SmartBar,
        TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, 0, 1, open and BAR_RESTING_Y or BAR_HIDDEN_Y) }):Play()

    TweenService:Create(self.Chevron,
        TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, 0, 1, open and CHEV_OPEN_Y or CHEV_CLOSED_Y) }):Play()

    TweenService:Create(self.Chevron,
        TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Rotation = open and 0 or 180 }):Play()
end

function Library:CreateTab(name, imageId, onClick)
    local self_ = self

    local Wrapper = new("Frame", {
        Name = name .. "Wrapper",
        LayoutOrder = #self.Tabs + 1,
        Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = self.TabsFrame,
    })

    local Tab = new("Frame", {
        ZIndex = 150,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(35, 28, 12),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
        Name = name,
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
        Parent = Wrapper,
    })

    new("UICorner", { CornerRadius = UDim.new(0, 15) }, Tab)

    local TabStroke = new("UIStroke", {
        Transparency = 1,
        Thickness = 1.2,
        Color = GOLD_BRIGHT,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, Tab)

    new("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, GOLD_BRIGHT),
            ColorSequenceKeypoint.new(1, GOLD_MID),
        },
    }, TabStroke)

    new("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 48, 20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 28, 12)),
        },
    }, Tab)

    local Icon = new("ImageButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        ImageColor3 = ICON_IDLE,
        ZIndex = 151,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = imageId,
        Size = UDim2.new(0, 22, 0, 22),
        Name = "Icon",
        Position = UDim2.new(0, ICON_SIZE / 2, 0.5, 0),
    }, Tab)

    local Label = new("TextLabel", {
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 151,
        TextSize = 13,
        TextTransparency = 1,
        FontFace = FONT_BOLD,
        TextColor3 = GOLD_BRIGHT,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, EXPAND_WIDTH - ICON_SIZE - 10, 0, 19),
        Text = name,
        Name = "Label",
        Position = UDim2.new(0, ICON_SIZE + 2, 0.5, 0),
    }, Tab)

    local Dot = new("Frame", {
        Name = "SelectedDot",
        ZIndex = 156,
        AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.new(0, 4, 0, 4),
        Position = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = GOLD_BRIGHT,
        BorderSizePixel = 0,
        Visible = false,
        Parent = Wrapper,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, Dot)

    local Interact = new("TextButton", {
        TextTransparency = 1,
        AutoButtonColor = false,
        ZIndex = 155,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Name = "Interact",
        Position = UDim2.new(0.5, 0, 0.5, 0),
    }, Tab)

    local hovering = false

    local function onHover()
        if hovering then return end
        hovering = true

        TweenService:Create(Wrapper, TweenInfo.new(EXPAND_TIME, BOUNCE_STYLE, BOUNCE_DIR),
            { Size = UDim2.new(0, EXPAND_WIDTH, 0, ICON_SIZE) }):Play()

        TweenService:Create(Tab, TweenInfo.new(EXPAND_TIME, BOUNCE_STYLE, BOUNCE_DIR),
            { Size = UDim2.new(0, EXPAND_WIDTH, 0, ICON_SIZE), BackgroundColor3 = GOLD_HOVER }):Play()

        TweenService:Create(Label, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { TextTransparency = 0 }):Play()

        TweenService:Create(Icon, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 26, 0, 26), ImageColor3 = ICON_HOVER }):Play()

        TweenService:Create(TabStroke, TweenInfo.new(0.25), { Transparency = 0.1 }):Play()
        TweenService:Create(self_.BarStroke, TweenInfo.new(0.3), { Transparency = 0.1 }):Play()
    end

    local function onLeave()
        if not hovering then return end
        hovering = false

        TweenService:Create(Wrapper, TweenInfo.new(EXPAND_TIME, BOUNCE_STYLE, BOUNCE_DIR),
            { Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE) }):Play()

        TweenService:Create(Tab, TweenInfo.new(EXPAND_TIME, BOUNCE_STYLE, BOUNCE_DIR),
            { Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE), BackgroundColor3 = Color3.fromRGB(35, 28, 12) }):Play()

        TweenService:Create(Label, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()

        TweenService:Create(Icon, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 22, 0, 22), ImageColor3 = ICON_IDLE }):Play()

        TweenService:Create(TabStroke, TweenInfo.new(0.25), { Transparency = 1 }):Play()
        TweenService:Create(self_.BarStroke, TweenInfo.new(0.3), { Transparency = 0.4 }):Play()
    end

    Interact.MouseEnter:Connect(onHover)
    Interact.MouseLeave:Connect(onLeave)
    Interact.MouseButton1Click:Connect(function()
        for _, entry in pairs(self_.Tabs) do
            entry.Dot.Visible = false
        end
        Dot.Visible = true
        if onClick then onClick() end
    end)

    local tabObject = {
        Name = name,
        Frame = Tab,
        Wrapper = Wrapper,
        Dot = Dot,
        Buttons = {},
        Toggles = {},
        Labels = {},
    }

    self.Tabs[name] = tabObject

    return tabObject
end

function Library:CreateToggle(tab, config)
    config = config or {}
    local name = config.Name or "Toggle"
    local default = config.Default or false
    local callback = config.Callback

    local row = new("Frame", {
        Name = "row_" .. name,
        LayoutOrder = #tab.Toggles + 1,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = tab.Frame,
    })

    local label = new("TextLabel", {
        Name = "RowLabel",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.new(1, -70, 1, 0),
        FontFace = FONT,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(230, 220, 200),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = name,
        Parent = row,
    })

    local switch = new("Frame", {
        Name = "Switch",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 22),
        BackgroundColor3 = Color3.fromRGB(35, 28, 12),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = row,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, switch)

    local switchStroke = new("UIStroke", {
        Color = GOLD_MID,
        Thickness = 1,
        Transparency = 0.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, switch)

    local knob = new("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 3, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(200, 190, 175),
        BorderSizePixel = 0,
        Parent = switch,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

    local hit = new("TextButton", {
        Name = "Hit",
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 10,
        Parent = row,
    })

    local state = default
    local function applyState(animate)
        local info = TweenInfo.new(animate and 0.18 or 0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(knob, info, {
            Position = UDim2.new(0, state and 21 or 3, 0.5, 0),
            BackgroundColor3 = state and Color3.fromRGB(255, 235, 170) or Color3.fromRGB(200, 190, 175),
        }):Play()
        TweenService:Create(switch, info, {
            BackgroundColor3 = state and Color3.fromRGB(90, 70, 25) or Color3.fromRGB(35, 28, 12),
        }):Play()
        TweenService:Create(switchStroke, info, {
            Transparency = state and 0.15 or 0.4,
        }):Play()
    end

    applyState(false)

    hit.MouseButton1Click:Connect(function()
        state = not state
        applyState(true)
        if callback then callback(state) end
    end)

    hit.MouseEnter:Connect(function()
        TweenService:Create(label, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(255, 235, 170) }):Play()
    end)
    hit.MouseLeave:Connect(function()
        TweenService:Create(label, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(230, 220, 200) }):Play()
    end)

    local toggleObj = {
        Name = name,
        Set = function(v) state = v; applyState(true); if callback then callback(state) end end,
        Get = function() return state end,
    }

    table.insert(tab.Toggles, toggleObj)
    return toggleObj
end

function Library:CreateButton(tab, config)
    config = config or {}
    local name = config.Name or "Button"
    local callback = config.Callback

    local row = new("Frame", {
        Name = "row_" .. name,
        LayoutOrder = #tab.Buttons + 1,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = tab.Frame,
    })

    local button = new("TextButton", {
        Name = "Button",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -8, 0, 28),
        BackgroundColor3 = Color3.fromRGB(35, 28, 12),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = name,
        FontFace = FONT_BOLD,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 235, 170),
        AutoButtonColor = false,
        Parent = row,
    })

    new("UICorner", { CornerRadius = UDim.new(0, 8) }, button)

    local buttonStroke = new("UIStroke", {
        Color = GOLD_MID,
        Thickness = 1,
        Transparency = 0.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, button)

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(90, 70, 25),
        }):Play()
        TweenService:Create(buttonStroke, TweenInfo.new(0.15), { Transparency = 0.15 }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(35, 28, 12),
        }):Play()
        TweenService:Create(buttonStroke, TweenInfo.new(0.15), { Transparency = 0.4 }):Play()
    end)

    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    local buttonObj = { Name = name }
    table.insert(tab.Buttons, buttonObj)
    return buttonObj
end

function Library:CreateLabel(tab, config)
    config = config or {}
    local text = config.Name or "Label"

    local label = new("TextLabel", {
        Name = "Label_" .. text,
        LayoutOrder = #tab.Labels + 1,
        Size = UDim2.new(1, -16, 0, 22),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        FontFace = FONT,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(230, 220, 200),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
        Parent = tab.Frame,
    })

    local labelObj = { Name = text, Frame = label }
    table.insert(tab.Labels, labelObj)
    return labelObj
end

return Library
