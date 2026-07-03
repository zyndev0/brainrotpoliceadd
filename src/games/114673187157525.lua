-- Escape with a lucky block

return function(section)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    elements:Label("This is a Label", section)

    elements:Toggle("This is a Toggle", section, false, function(bool)
        if bool then
            print("Enabled!")
        else
            print("Disabled.")
        end
    end)

    elements:Button("This is a Button", section, function()
        print("Clicked!")
    end)

    elements:Textbox("This is a TextBox", section, "", function(str)
        print("Typed: "..str)
    end)

    elements:Toggle("Auto Redeem Codes", section, false, function(bool)
        if bool then
            print("Auto Redeem On")
            local autoRedeemConnection
            autoRedeemConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not bool then
                    autoRedeemConnection:Disconnect()
                    return
                end

                local Event = game:GetService("ReplicatedStorage").Network["Codes: Get Active Code State"]
                local Result = Event:InvokeServer()

                if Result and Result[2] then
                    local codeData = Result[2]
                    local currentCode = codeData.CurrentCode

                    if currentCode then
                        -- Redeem the current code
                        local redeemEvent = game:GetService("ReplicatedStorage").Network["Codes: Redeem Code"]
                        redeemEvent:InvokeServer(currentCode)
                        print("Redeemed code: " .. currentCode)
                    end
                end

                wait(1) -- Wait 1 second before checking again
            end)
        else
            print("Auto Redeem Off")
        end
    end)
end
