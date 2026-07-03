local elements = import("rbxassetid://113037265185555")
local stuff = {}
local gameList = game:GetService("HttpService"):JSONDecode(game:HttpGet(getgitpath("src").. "gameslist.json"))

local function styleRecursive(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj.TextColor3 = Color3.fromRGB(255, 255, 255)
        if obj.BackgroundTransparency < 1 then
            obj.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        end
    elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") or obj:IsA("ViewportFrame") then
        if obj.BackgroundTransparency < 1 then
            obj.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        end
    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        obj.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end

    local stroke = obj:FindFirstChildOfClass("UIStroke")
    if not stroke and (obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
        stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 0.8
        stroke.Transparency = 0.65
        stroke.Parent = obj
    elseif stroke then
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 0.8
        stroke.Transparency = 0.65
    end

    if (obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and not obj:FindFirstChild("Glow") then
        local glow = Instance.new("UIGradient")
        glow.Name = "Glow"
        glow.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 220, 220)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        })
        glow.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.8),
            NumberSequenceKeypoint.new(0.5, 0.3),
            NumberSequenceKeypoint.new(1, 0.8)
        })
        glow.Rotation = 90
        glow.Parent = obj
    end

    for _, child in ipairs(obj:GetChildren()) do
        styleRecursive(child)
    end
end

local function themeElement(element)
    styleRecursive(element)
    return element
end

function stuff:Label(str, king)
    local newLabel = themeElement(elements.LabelElement:Clone())
    newLabel.Text = str
    newLabel.Parent = king
end

function stuff:Button(str, king, cb)
    local newBtn = themeElement(elements.ButtonElement:Clone())
    newBtn.TextLabel.Text = str
    newBtn.Parent = king

    newBtn.MouseButton1Click:Connect(cb)
end

function stuff:Toggle(str, king, def, cb)
    local newTog = themeElement(elements.ToggleElement:Clone())
    newTog.TextLabel.Text = str
    newTog.Parent = king

    local isTog = def
    if isTog then
        newTog.togglebg.BackgroundColor3 = Color3.fromRGB(59, 164, 57)
        newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(1, 0.5)
        newTog.togglebg.leftrightlol.Position = UDim2.new(1, 0, 0.5, 0)
    else
        newTog.togglebg.BackgroundColor3 = Color3.fromRGB(164, 58, 58)
        newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(0, 0.5)
        newTog.togglebg.leftrightlol.Position = UDim2.new(0, 0, 0.5, 0)
    end
    task.defer(function() cb(isTog) end)

    newTog.MouseButton1Click:Connect(function()
        isTog = not isTog
        if isTog then
            newTog.togglebg.BackgroundColor3 = Color3.fromRGB(59, 164, 57)
            newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(1, 0.5)
            newTog.togglebg.leftrightlol.Position = UDim2.new(1, 0, 0.5, 0)
        else
            newTog.togglebg.BackgroundColor3 = Color3.fromRGB(164, 58, 58)
            newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(0, 0.5)
            newTog.togglebg.leftrightlol.Position = UDim2.new(0, 0, 0.5, 0)
        end
        cb(isTog)
    end)
end

function stuff:Textbox(str, king, def, cb)
    local newTb = themeElement(elements.TextboxElement:Clone())
    newTb.TextLabel.Text = str
    newTb.Parent = king

    newTb.tbbg.Inp.FocusLost:Connect(function(ep)
        cb(newTb.tbbg.Inp.Text)
    end)
end

function stuff:Unsupported(king, cb)
    local newUs = themeElement(elements.unsupportElement:Clone())
    newUs.Parent = king

    newUs.suggestbtn.MouseButton1Click:Connect(function()
        setclipboard("https://github.com/zyndev0/zyndevbrainrotscripts/issues")
        newUs.suggestbtn.Text = "Copied Link!"
        wait(1)
        newUs.suggestbtn.Text = "Suggest Game"
    end)

    newUs.glbtn.MouseButton1Click:Connect(cb)
end

function stuff:addGame(king, gname, gstate, cb)
    local newGame = themeElement(elements.GameElement:Clone())
    newGame.ButtonElement.header.Text = gname
    if gstate == "🟢" then
        newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(0, 255, 0)
    elseif gstate == "🟡" then
        newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(255, 255, 0)
    elseif gstate == "🔴" then
        newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(255, 0, 0)
    end
    newGame.Parent = king

    newGame.ButtonElement.MouseButton1Click:Connect(cb)
end

-- to finish
function stuff:Searchbar(king)
    local newSearch = themeElement(elements.searchBar:Clone())
    newSearch.Parent = king
    newSearch.searchbar.Inp:GetPropertyChangedSignal("Text"):Connect(function()
        for i, v in pairs(king:GetChildren()) do
            if v.Name == "GameElement" then
                v:Destroy()
            end
        end

        for i, v in pairs(gameList) do
            if v["game"]:lower():find(newSearch.searchbar.Inp.Text:lower()) then
                stuff:addGame(king, v["game"], v["status"], function()
                    game:GetService("ExperienceService"):LaunchExperience({placeId = v["id"]})
                end)
            end
        end
    end)
end

function stuff:CredHead(king, txt)
    local newHead = themeElement(elements.CreditHeader:Clone())
    newHead.Text = "> " .. txt
    newHead.Parent = king
end

function stuff:CredPerson(king, txt)
    local newCred = themeElement(elements.CreditPerson:Clone())
    newCred.Text = "      + " .. txt
    newCred.Parent = king
end

return stuff

