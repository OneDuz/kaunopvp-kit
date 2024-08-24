fx_version 'cerulean'
game 'gta5'

lua54 "yes"
author "onecodes"
version "1.0.5"
description 'Simple /kit script to provide for players every 24hrs'



server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}

shared_script '@ox_lib/init.lua'
