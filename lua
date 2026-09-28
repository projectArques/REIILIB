local Library = {}
Library.__index = Library

local HttpService   = game:GetService("HttpService")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")
local Stats         = game:GetService("Stats")
local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")

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

local BAR_RESTING_Y = 16
local BAR_HIDDEN_Y  = -90
local CHEV_OPEN_Y   = 100
local CHEV_CLOSED_Y = 14

local PAGE_OPEN_HEIGHT = 320

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local Icons = nil
local function loadWithTimeout(url, timeout)
    timeout = timeout or 5
    local done = false
    local result = nil
    task.spawn(function()
        local ok, res = pcall(game.HttpGet, game, url)
        if ok and #res > 0 then
            local execOk, execRes = pcall(function() return loadstring(res)() end)
            if execOk then result = execRes end
        end
        done = true
    end)
    local start = tick()
    while not done and (tick() - start) < timeout do
        task.wait(0.05)
    end
    return result
end

Icons = loadWithTimeout("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua", 5)

local function getIcon(name)
    if not Icons then return nil end
    name = string.match(string.lower(name), "^%s*(.*)%s*$")
    local sizedicons = Icons["48px"]
    local r = sizedicons[name]
    if not r then return nil end
    local rirs, riro = r[2], r[3]
    return {
        id = r[1],
        imageRectSize = Vector2.new(rirs[1], rirs[2]),
        imageRectOffset = Vector2.new(riro[1], riro[2]),
    }
end

local function getAssetUri(id)
    if type(id) == "number" then
        return "rbxassetid://" .. id
    end
    return ""
end

local function resolveIcon(icon)
    if not icon or icon == 0 then return "", nil, nil end
    if type(icon) == "string" then
        local asset = getIcon(icon)
        if asset then
            return "rbxassetid://" .. asset.id, asset.imageRectOffset, asset.imageRectSize
        end
        return "", nil, nil
    end
    return getAssetUri(icon), nil, nil
end

function Library:Icon(name)
    return getIcon(name)
end

local TabMethods = {}
TabMethods.__index = TabMethods

function TabMethods:_row(name, height)
    return new("Frame", {
        Name = "row_" .. name,
        LayoutOrder = #(self.Rows or {}) + 1,
        Size = UDim2.new(1, 0, 0, height or 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = self.Content,
    })
end

function TabMethods:CreateButton(config)
    config = config or {}
    local name = config.Name or "Button"
    local callback = config.Callback

    local row = self:_row(name, 36)

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

    local stroke = new("UIStroke", {
        Color = GOLD_MID,
        Thickness = 1,
        Transparency = 0.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, button)

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(90, 70, 25) }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), { Transparency = 0.15 }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(35, 28, 12) }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), { Transparency = 0.4 }):Play()
    end)
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return {
        Set = function(text) button.Text = text end,
    }
end

function TabMethods:CreateToggle(config)
    config = config or {}
    local name = config.Name or "Toggle"
    local state = config.CurrentValue or config.Default or false
    local callback = config.Callback

    local row = self:_row(name, 36)

    local label = new("TextLabel", {
        Name = "RowLabel",
        BackgroundTransparency = 1,
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
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 22),
        BackgroundColor3 = Color3.fromRGB(35, 28, 12),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = row,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, switch)

    local stroke = new("UIStroke", {
        Color = GOLD_MID,
        Thickness = 1,
        Transparency = 0.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, switch)

    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 3, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(200, 190, 175),
        BorderSizePixel = 0,
        Parent = switch,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

    local hit = new("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 10,
        Parent = row,
    })

    local function apply(animate)
        local info = TweenInfo.new(animate and 0.18 or 0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(knob, info, {
            Position = UDim2.new(0, state and 21 or 3, 0.5, 0),
            BackgroundColor3 = state and Color3.fromRGB(255, 235, 170) or Color3.fromRGB(200, 190, 175),
        }):Play()
        TweenService:Create(switch, info, {
            BackgroundColor3 = state and Color3.fromRGB(90, 70, 25) or Color3.fromRGB(35, 28, 12),
        }):Play()
        TweenService:Create(stroke, info, { Transparency = state and 0.15 or 0.4 }):Play()
    end
    apply(false)

    hit.MouseButton1Click:Connect(function()
        state = not state
        apply(true)
        if callback then callback(state) end
    end)

    return {
        Set = function(v)
            state = v
            apply(true)
            if callback then callback(state) end
        end,
        Get = function() return state end,
    }
end

function TabMethods:CreateSlider(config)
    config = config or {}
    local name = config.Name or "Slider"
    local range = config.Range or {0, 100}
    local increment = config.Increment or 1
    local suffix = config.Suffix or ""
    local value = config.CurrentValue or range[1]
    local callback = config.Callback

    local row = self:_row(name, 48)

    new("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, -8),
        Size = UDim2.new(1, -70, 0, 18),
        FontFace = FONT,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(230, 220, 200),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = name,
        Parent = row,
    })

    local valueLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, -8),
        Size = UDim2.new(0, 60, 0, 18),
        FontFace = FONT,
        TextSize = 13,
        TextColor3 = GOLD_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(value) .. " " .. suffix,
        Parent = row,
    })

    local track = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -8),
        Size = UDim2.new(1, -16, 0, 6),
        BackgroundColor3 = Color3.fromRGB(35, 28, 12),
        BorderSizePixel = 0,
        Parent = row,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, track)

    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = GOLD_MID,
        BorderSizePixel = 0,
        Parent = track,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = GOLD_BRIGHT,
        BorderSizePixel = 0,
        Parent = track,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

    local dragging = false

    local function setVisual()
        local alpha = (value - range[1]) / (range[2] - range[1])
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(value) .. " " .. suffix
    end
    setVisual()

    local function fromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local raw = range[1] + rel * (range[2] - range[1])
        return math.floor(raw / increment + 0.5) * increment
    end

    local function update(x)
        local v = fromX(x)
        if v ~= value then
            value = v
            setVisual()
            if callback then callback(value) end
        end
    end

    local hit = new("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.new(1, 20, 0, 20),
        Position = UDim2.new(0, -10, 1, -18),
        ZIndex = 10,
        Parent = row,
    })

    hit.MouseButton1Down:Connect(function()
        dragging = true
        update(UIS:GetMouseLocation().X)
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(UIS:GetMouseLocation().X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return {
        Set = function(v)
            value = math.clamp(v, range[1], range[2])
            setVisual()
            if callback then callback(value) end
        end,
        Get = function() return value end,
    }
end

function TabMethods:CreateInput(config)
    config = config or {}
    local name = config.Name or "Input"
    local placeholder = config.PlaceholderText or ""
    local removeAfter = config.RemoveTextAfterFocusLost or false
    local callback = config.Callback

    local row = self:_row(name, 40)

    local box = new("TextBox", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -8, 0, 30),
        BackgroundColor3 = Color3.fromRGB(35, 28, 12),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        FontFace = FONT,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 235, 170),
        PlaceholderText = placeholder,
        PlaceholderColor3 = Color3.fromRGB(155, 148, 134),
        Text = config.CurrentValue or "",
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = row,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 8) }, box)
    new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, box)

    local stroke = new("UIStroke", {
        Color = GOLD_MID,
        Thickness = 1,
        Transparency = 0.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, box)

    box.Focused:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.15), { Transparency = 0.1 }):Play()
    end)
    box.FocusLost:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.15), { Transparency = 0.4 }):Play()
        if callback then callback(box.Text) end
        if removeAfter then box.Text = "" end
    end)

    return {
        Set = function(text) box.Text = text end,
        Get = function() return box.Text end,
    }
end

function TabMethods:CreateDropdown(config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local options = config.Options or {}
    local multiple = config.MultipleOptions or false
    local selected = config.CurrentOption or (multiple and {} or {options[1]})
    local callback = config.Callback
    local screenGui = self.Content:FindFirstAncestorWhichIsA("ScreenGui")

    local row = self:_row(name, 40)
    row.ClipsDescendants = false
    row.ZIndex = 5

    local button = new("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -8, 0, 30),
        BackgroundColor3 = Color3.fromRGB(35, 28, 12),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
        Parent = row,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 8) }, button)

    new("UIStroke", {
        Color = GOLD_MID,
        Thickness = 1,
        Transparency = 0.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, button)

    local display = new("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(1, -30, 1, 0),
        FontFace = FONT,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 235, 170),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = table.concat(selected, ", "),
        ZIndex = 7,
        Parent = button,
    })

    new("ImageLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 10, 0, 10),
        Image = "rbxassetid://138715549597115",
        ImageColor3 = GOLD_MID,
        ZIndex = 7,
        Parent = button,
    })

    local list = new("ScrollingFrame", {
        Visible = false,
        ZIndex = 10000,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 250, 0, 0),
        BackgroundColor3 = Color3.fromRGB(21, 21, 23),
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(121, 121, 121),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 8) }, list)
    new("UIStroke", { Color = GOLD_MID, Thickness = 1, Transparency = 0.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, list)
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, list)
    new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, list)

    local open = false

    local function updateListPosition()
        list.Position = UDim2.new(0, button.AbsolutePosition.X, 0, button.AbsolutePosition.Y + button.AbsoluteSize.Y + 4)
        list.Size = UDim2.new(0, button.AbsoluteSize.X, 0, list.Size.Y.Offset)
    end

    local function setListOpen(v)
        open = v
        if v then
            updateListPosition()
            list.Visible = true
            list.Size = UDim2.new(0, button.AbsoluteSize.X, 0, 0)
            TweenService:Create(list,
                TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, button.AbsoluteSize.X, 0, 120) }
            ):Play()
        else
            local t = TweenService:Create(list,
                TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, button.AbsoluteSize.X, 0, 0) }
            )
            t.Completed:Connect(function()
                if not open then
                    list.Visible = false
                end
            end)
            t:Play()
        end
    end

    local function rebuild()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end

        for i, opt in ipairs(options) do
            local optBtn = new("TextButton", {
                Name = "opt_" .. tostring(i),
                LayoutOrder = i,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = opt,
                FontFace = FONT,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(230, 220, 200),
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = 10001,
                Parent = list,
            })
            new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, optBtn)

            optBtn.MouseEnter:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.12), { TextColor3 = GOLD_BRIGHT }):Play()
            end)
            optBtn.MouseLeave:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(230, 220, 200) }):Play()
            end)
            optBtn.MouseButton1Click:Connect(function()
                if multiple then
                    local found = false
                    for idx, s in ipairs(selected) do
                        if s == opt then
                            table.remove(selected, idx)
                            found = true
                            break
                        end
                    end
                    if not found then table.insert(selected, opt) end
                else
                    selected = { opt }
                    setListOpen(false)
                end
                display.Text = table.concat(selected, ", ")
                if callback then callback(selected) end
            end)
        end
    end
    rebuild()

    button.MouseButton1Click:Connect(function()
        setListOpen(not open)
    end)

    row.AncestryChanged:Connect(function()
        if not row:IsDescendantOf(game) then
            list:Destroy()
        end
    end)

    return {
        Refresh = function(newOptions)
            options = newOptions
            rebuild()
        end,
        Set = function(newSelected)
            selected = newSelected
            display.Text = table.concat(selected, ", ")
            if callback then callback(selected) end
        end,
        Get = function() return selected end,
    }
end

function TabMethods:CreateColorPicker(config)
    config = config or {}
    local name = config.Name or "Color"
    local color = config.Color or Color3.fromRGB(255, 255, 255)
    local callback = config.Callback

    local row = self:_row(name, 40)

    local button = new("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -8, 0, 30),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 8) }, button)
    new("UIStroke", { Color = GOLD_MID, Thickness = 1, Transparency = 0.3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, button)

    new("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(1, -20, 1, 0),
        FontFace = FONT,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextStrokeTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = name,
        Parent = button,
    })

    local function openPicker()
        local picker = new("Frame", {
            ZIndex = 10000,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 240, 0, 200),
            BackgroundColor3 = Color3.fromRGB(21, 21, 23),
            BorderSizePixel = 0,
            Parent = self.Page,
        })
        new("UICorner", { CornerRadius = UDim.new(0, 10) }, picker)
        new("UIStroke", { Color = GOLD_MID, Thickness = 1, Transparency = 0.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, picker)

        local preview = new("Frame", {
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 40),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = picker,
        })
        new("UICorner", { CornerRadius = UDim.new(0, 6) }, preview)

        for i, ch in ipairs({"R", "G", "B"}) do
            local sRow = new("Frame", {
                Position = UDim2.new(0, 10, 0, 60 + (i - 1) * 32),
                Size = UDim2.new(1, -20, 0, 24),
                BackgroundTransparency = 1,
                Parent = picker,
            })
            new("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 20, 1, 0),
                FontFace = FONT_BOLD,
                TextSize = 13,
                TextColor3 = GOLD_BRIGHT,
                Text = ch,
                Parent = sRow,
            })
            local sTrack = new("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 24, 0.5, 0),
                Size = UDim2.new(1, -24, 0, 6),
                BackgroundColor3 = Color3.fromRGB(35, 28, 12),
                BorderSizePixel = 0,
                Parent = sRow,
            })
            new("UICorner", { CornerRadius = UDim.new(1, 0) }, sTrack)
            local sFill = new("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = (ch == "R" and Color3.fromRGB(220,80,80)) or (ch == "G" and Color3.fromRGB(80,220,80)) or Color3.fromRGB(80,80,220),
                BorderSizePixel = 0,
                Parent = sTrack,
            })
            new("UICorner", { CornerRadius = UDim.new(1, 0) }, sFill)

            local hit = new("TextButton", {
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                Size = UDim2.new(1, 10, 0, 24),
                Position = UDim2.new(0, -5, 0.5, -12),
                ZIndex = 10001,
                Parent = sRow,
            })

            hit.MouseButton1Down:Connect(function()
                local rel = math.clamp((UIS:GetMouseLocation().X - sTrack.AbsolutePosition.X) / sTrack.AbsoluteSize.X, 0, 1)
                local v = math.floor(rel * 255 + 0.5)
                local r, g, b = color.R * 255, color.G * 255, color.B * 255
                if ch == "R" then r = v elseif ch == "G" then g = v else b = v end
                color = Color3.fromRGB(r, g, b)
                preview.BackgroundColor3 = color
                button.BackgroundColor3 = color
                if callback then callback(color) end
            end)
        end

        local close = new("TextButton", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -10, 1, -10),
            Size = UDim2.new(0, 60, 0, 24),
            BackgroundColor3 = GOLD_MID,
            BorderSizePixel = 0,
            Text = "Close",
            FontFace = FONT_BOLD,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(21, 19, 17),
            AutoButtonColor = false,
            ZIndex = 10001,
            Parent = picker,
        })
        new("UICorner", { CornerRadius = UDim.new(0, 6) }, close)
        close.MouseButton1Click:Connect(function() picker:Destroy() end)
    end

    button.MouseButton1Click:Connect(openPicker)

    return {
        Set = function(c)
            color = c
            button.BackgroundColor3 = c
            if callback then callback(color) end
        end,
        Get = function() return color end,
    }
end

function TabMethods:CreateKeybind(config)
    config = config or {}
    local name = config.Name or "Keybind"
    local key = config.CurrentKeybind or "Q"
    local hold = config.HoldToInteract or false
    local callback = config.Callback

    local row = self:_row(name, 40)

    new("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.new(1, -100, 1, 0),
        FontFace = FONT,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(230, 220, 200),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = name,
        Parent = row,
    })

    local button = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 80, 0, 26),
        BackgroundColor3 = Color3.fromRGB(35, 28, 12),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = key,
        FontFace = FONT_BOLD,
        TextSize = 12,
        TextColor3 = GOLD_BRIGHT,
        AutoButtonColor = false,
        Parent = row,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 6) }, button)
    new("UIStroke", { Color = GOLD_MID, Thickness = 1, Transparency = 0.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, button)

    local listening = false

    button.MouseButton1Click:Connect(function()
        listening = true
        button.Text = "..."
    end)

    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            key = input.KeyCode.Name
            listening = false
            button.Text = key
            if callback and not hold then callback(false) end
        elseif not listening and not hold and input.KeyCode.Name == key then
            if callback then callback(false) end
        elseif not listening and hold and input.KeyCode.Name == key then
            if callback then callback(true) end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if hold and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then
            if callback then callback(false) end
        end
    end)

    return {
        Set = function(newKey)
            key = newKey
            button.Text = newKey
        end,
        Get = function() return key end,
    }
end

function TabMethods:CreateLabel(text, imageId, color)
    local label = new("TextLabel", {
        LayoutOrder = #(self.Rows or {}) + 1,
        Size = UDim2.new(1, -16, 0, 22),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        FontFace = FONT,
        TextSize = 13,
        TextColor3 = color or Color3.fromRGB(230, 220, 200),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text or "Label",
        Parent = self.Content,
    })
    return { Frame = label, Set = function(t) label.Text = t end }
end

function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Reiihub"

    local self = setmetatable({}, Library)
    self.Tabs = {}
    self.MenuOpen = false
    self.PageOpen = false
    self.ActiveTab = nil

    self.ScreenGui = new("ScreenGui", {
        Name = "Reiihub - UI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
    })

    Library._ScreenGui = self.ScreenGui

    self.SmartBar = new("Frame", {
        ZIndex = 150,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(17, 17, 17),
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 319, 0, 70),
        Position = UDim2.new(0.5, 0, 0, BAR_HIDDEN_Y),
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
    new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, self.TabsFrame)

    self.Chevron = new("ImageButton", {
        Name = "Chevron",
        ZIndex = 200,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(0.5, 0, 0, CHEV_CLOSED_Y),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(564, 284),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = Color3.fromRGB(230, 190, 80),
        Rotation = 0,
        Parent = self.ScreenGui,
    })

    self.Watermark = new("Frame", {
        Visible = true,
        ZIndex = 9000,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(21, 21, 23),
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.new(0, 340, 0, 34),
        Position = UDim2.new(1, -20, 0, 20),
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
        BackgroundTransparency = 1,
    }, self.Watermark)
    new("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
    }, wmContent)

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
        }, wmContent)
        if gradient then
            new("UIGradient", { Rotation = 12, Color = gradient }, t)
        end
        return t
    end
    local function makeDivider(order)
        new("Frame", {
            ZIndex = 9001,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(244, 242, 237),
            Size = UDim2.new(0, 1, 0, 12),
            LayoutOrder = order,
            BackgroundTransparency = 0.75,
        }, wmContent)
    end

    makeText(title, 1, FONT_BOLD, Color3.fromRGB(255, 255, 255), ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 170)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 160, 60)),
    })
    makeDivider(2)
    makeText("discord.gg/gay", 3, FONT, Color3.fromRGB(244, 242, 237))
    makeDivider(4)
    self.FpsLabel = makeText("FPS: --", 5, FONT, Color3.fromRGB(204, 183, 148))
    makeDivider(6)
    self.PingLabel = makeText("Ping: --", 7, FONT, Color3.fromRGB(204, 183, 148))

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

    self.Page = new("Frame", {
        Name = "Page",
        ZIndex = 145,
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 290, 0, 0),
        Position = UDim2.new(0.5, 0, 1, 6),
        BackgroundColor3 = Color3.fromRGB(21, 21, 23),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
    }, self.SmartBar)
    new("UICorner", { CornerRadius = UDim.new(0, 12) }, self.Page)
    new("UIStroke", {
        Transparency = 0.55,
        Thickness = 1,
        Color = Color3.fromRGB(230, 190, 80),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, self.Page)

    self.PageContainer = new("Frame", {
        Name = "PageContainer",
        ZIndex = 146,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        ClipsDescendants = false,
    }, self.Page)

    self.Chevron.MouseButton1Click:Connect(function()
        self:SetMenuOpen(not self.MenuOpen)
    end)
    self.Chevron.MouseEnter:Connect(function()
        TweenService:Create(self.Chevron, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(255, 235, 170) }):Play()
    end)
    self.Chevron.MouseLeave:Connect(function()
        TweenService:Create(self.Chevron, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(230, 190, 80) }):Play()
    end)

    return self
end

function Library:SetPageOpen(open)
    self.PageOpen = open
    if open then
        self.Page.Visible = true
        TweenService:Create(self.Page,
            TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 290, 0, PAGE_OPEN_HEIGHT) }
        ):Play()
    else
        local t = TweenService:Create(self.Page,
            TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 290, 0, 0) }
        )
        t.Completed:Connect(function()
            if not self.PageOpen then self.Page.Visible = false end
        end)
        t:Play()
    end
end

function Library:SetMenuOpen(open)
    self.MenuOpen = open
    if not open then
        if self.PageOpen then self:SetPageOpen(false) end
        for _, tab in pairs(self.Tabs) do tab.Dot.Visible = false end
    end

    TweenService:Create(self.SmartBar,
        TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, 0, 0, open and BAR_RESTING_Y or BAR_HIDDEN_Y) }):Play()
    TweenService:Create(self.Chevron,
        TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, 0, 0, open and CHEV_OPEN_Y or CHEV_CLOSED_Y) }):Play()
    TweenService:Create(self.Chevron,
        TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Rotation = open and 180 or 0 }):Play()
end

function Library:CreateTab(name, imageId)
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

    local img, rectOffset, rectSize = resolveIcon(imageId)
    local Icon = new("ImageButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        ImageColor3 = ICON_IDLE,
        ZIndex = 151,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = img,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, ICON_SIZE / 2, 0.5, 0),
    }, Tab)
    if rectOffset then Icon.ImageRectOffset = rectOffset end
    if rectSize then Icon.ImageRectSize = rectSize end

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
        Position = UDim2.new(0, ICON_SIZE + 2, 0.5, 0),
    }, Tab)

    local Dot = new("Frame", {
        Name = "SelectedDot",
        ZIndex = 156,
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 4, 0, 4),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = GOLD_BRIGHT,
        BorderSizePixel = 0,
        Visible = false,
        Parent = Wrapper,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, Dot)

    local Content = new("ScrollingFrame", {
        Name = name .. "Content",
        ZIndex = 146,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(121, 121, 121),
        Visible = false,
        ClipsDescendants = false,
        Parent = self.PageContainer,
    })
    new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, Content)

    local Interact = new("TextButton", {
        TextTransparency = 1,
        AutoButtonColor = false,
        ZIndex = 155,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
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

    local tabObject = setmetatable({
        Name = name,
        Frame = Tab,
        Wrapper = Wrapper,
        Dot = Dot,
        Rows = {},
        Content = Content,
    }, TabMethods)

    Interact.MouseButton1Click:Connect(function()
        for _, entry in pairs(self_.Tabs) do
            entry.Dot.Visible = false
            entry.Content.Visible = false
        end
        Dot.Visible = true
        Content.Visible = true
        self_:SetPageOpen(true)
        self_.ActiveTab = name
    end)

    self.Tabs[name] = tabObject
    return tabObject
end

function Library:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 5

    local notif = new("Frame", {
        ZIndex = 9500,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 300, 0, 20),
        Size = UDim2.new(0, 300, 0, 0),
        BackgroundColor3 = Color3.fromRGB(16, 16, 18),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, notif)

    local accent = new("Frame", {
        Name = "Accent",
        ZIndex = 9501,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = GOLD_BRIGHT,
        BorderSizePixel = 0,
        Parent = notif,
    })

    local titleLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 10),
        Size = UDim2.new(1, -30, 0, 16),
        FontFace = FONT_BOLD,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title,
        Parent = notif,
    })

    local contentLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 28),
        Size = UDim2.new(1, -30, 0, 16),
        FontFace = FONT,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(150, 150, 155),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = content,
        Parent = notif,
    })

    task.wait()

    local titleH = math.max(titleLbl.TextBounds.Y, 16)
    local contentH = math.max(contentLbl.TextBounds.Y, 16)
    local totalH = titleH + contentH + 26

    TweenService:Create(notif,
        TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, 300, 0, totalH), Position = UDim2.new(1, -20, 0, 20) }
    ):Play()

    task.delay(duration, function()
        local t = TweenService:Create(notif,
            TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            { Position = UDim2.new(1, 320, 0, 20), BackgroundTransparency = 1 }
        )
        TweenService:Create(accent, TweenInfo.new(0.28), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(titleLbl, TweenInfo.new(0.28), { TextTransparency = 1 }):Play()
        TweenService:Create(contentLbl, TweenInfo.new(0.28), { TextTransparency = 1 }):Play()
        t.Completed:Connect(function() notif:Destroy() end)
        t:Play()
    end)
end

return Library
