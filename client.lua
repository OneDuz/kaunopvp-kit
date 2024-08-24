RegisterCommand("rinkinys", function()
    lib.callback('rinkinys:checkCooldown', source, function(data)
        if data.state then
            lib.registerContext({
                id = 'menukitai',
                title = 'Naujoko Ginklų rinkinys',
                options = {
                    {
                        title = 'Civilio Rinkinys',
                        description = 'Šiuo metu atvėsinamas',
                        icon = 'gun',
                        iconAnimation = 'spin',
                        metadata = {
                            { label = 'Hours',   value = data.hours },
                            { label = 'Minutes', value = data.minutes }
                        },
                    },
                }
            })
        else
            lib.registerContext({
                id = 'menukitai',
                title = 'Naujoko Ginklų rinkinys',
                options = {
                    {
                        title = 'Civilio Rinkinys',
                        description = 'Rinkinys paruoštas',
                        icon = 'gun',
                        iconAnimation = 'spin',
                        onSelect = function()
                            lib.callback('rinkinys:receiveKit', source, function(data)
                            end)
                        end,
                    },
                }
            })
        end
        lib.showContext('menukitai')
    end)
end)