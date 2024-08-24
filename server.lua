local cooldown = 24 * 60 * 60 

function getPlayerIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in pairs(identifiers) do
        if string.match(identifier, "license:") then
            return identifier
        end
    end
    return nil
end

function checkCooldown(identifier, cb)
    local currentTime = os.time()
    MySQL.Async.fetchScalar("SELECT UNIX_TIMESTAMP(last_used) FROM command_cooldowns WHERE identifier = @identifier",
        { ['@identifier'] = identifier },
        function(lastUsed)
            if lastUsed then
                local timeDifference = currentTime - lastUsed
                if timeDifference >= cooldown then
                    cb(true)
                else
                    local remainingTime = cooldown - timeDifference
                    local hours = math.floor(remainingTime / 3600)
                    local minutes = math.floor((remainingTime % 3600) / 60)
                    cb(false, hours, minutes)
                end
            else
                cb(true)
            end
        end)
end

lib.callback.register('rinkinys:checkCooldown', function(source)
    local datasent = { state = false, hours = 0, minutes = 0 }
    local identifier = getPlayerIdentifier(source)
    if identifier then
        checkCooldown(identifier, function(isReady, hours, minutes)
            if isReady then
                datasent.state = false
            else
                datasent.state = true
                datasent.hours = hours
                datasent.minutes = minutes
            end
        end)
    else
        -- print("Failed to obtain player identifier.")
    end
    Wait(250)
    return datasent
end)

lib.callback.register('rinkinys:receiveKit', function(source)
    local identifier = getPlayerIdentifier(source)
    if identifier then
        print(source)
        checkCooldown(identifier, function(isReady)
            if isReady then
                exports.ox_inventory:AddItem(source, "WEAPON_SPECIALCARBINE", 1, "KIT", 5)
                exports.ox_inventory:AddItem(source, "WEAPON_MICROSMG", 1, "KIT", 2)
                exports.ox_inventory:AddItem(source, "WEAPON_COMBATPISTOL", 1, "KIT", 3)
                exports.ox_inventory:AddItem(source, "WEAPON_PISTOL50", 1, "KIT", 10)
                exports.ox_inventory:AddItem(source, "kevlar", 5, nil, 3)
                exports.ox_inventory:AddItem(source, "money", 1999909)

                exports.ox_inventory:AddItem(source, "ammo-9", 1000)

                exports.ox_inventory:AddItem(source, "at_suppressor_heavy", 1)
                exports.ox_inventory:AddItem(source, "at_clip_drum_rifle", 1)
                exports.ox_inventory:AddItem(source, "at_grip", 1)

                exports.ox_inventory:AddItem(source, "at_clip_extended_pistol", 1)
                exports.ox_inventory:AddItem(source, "at_suppressor_light", 1)

                local query = "INSERT INTO command_cooldowns (identifier, last_used) VALUES (@identifier, FROM_UNIXTIME(@currentTime)) ON DUPLICATE KEY UPDATE last_used = FROM_UNIXTIME(@currentTime)"
                MySQL.Async.execute(query, { ['@identifier'] = identifier, ['@currentTime'] = os.time() }, function(affectedRows)
                    if affectedRows then
                        -- print("Cooldown updated for identifier: " .. identifier)
                    else
                        -- print("Failed to update cooldown for identifier: " .. identifier)
                    end
                end)
            else
                -- print("Cooldown not yet passed")
            end
        end)
    else
        -- print("Failed to obtain player identifier.")
    end
    return true
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local _source = playerId
    local identifier = getPlayerIdentifier(_source)
    if identifier then
        checkCooldown(identifier, function(isReady, hours, minutes)
            if isReady then
                TriggerClientEvent('ox_lib:notify', _source, ({
                    title = "Rinkinys paruoštas",
                    description = '/rinkinys',
                    position = 'top',
                    type = 'success'
                }))
                -- print("Kit is ready.")
            else
                TriggerClientEvent('ox_lib:notify', _source, ({
                    title = "Atvėsinimas aktyvus. Liko laiko: " ..hours .. " valandos ir " ..minutes .. " minutės.",
                    description = '/rinkinys',
                    position = 'top',
                    type = 'warning'
                }))
                -- print("Cooldown is active. Time remaining: " ..hours .. " hours and " ..minutes .. " minutes.")
            end
        end)
    else
        TriggerClientEvent('ox_lib:notify', _source, ({
            title = "Failed to obtain player identifier.",
            description = 'top',
            type = 'warning'
        }))
        -- print("Failed to obtain player identifier.")
    end
end)
