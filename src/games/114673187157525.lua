-- Escape with a lucky block

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer

    env.AutoRedeem = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.autoredeem = setdata.autoredeem or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Toggle("Auto Redeem Codes", section, setdata.autoredeem, function(v)
        env.AutoRedeem = v
        env.setconfig("autoredeem", v)
        if not v then return end

        while env.AutoRedeem do
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Network["Codes: Get Active Code State"]
                local Result = Event:InvokeServer()

                if Result and Result[2] then
                    local codeData = Result[2]
                    local currentCode = codeData.CurrentCode

                    if currentCode then
                        local redeemEvent = game:GetService("ReplicatedStorage").Network["Codes: Redeem Code"]
                        redeemEvent:InvokeServer(currentCode)
                        print("Redeemed code: " .. currentCode)
                    end
                end
            end)

            task.wait(1)
        end
    end)
end
