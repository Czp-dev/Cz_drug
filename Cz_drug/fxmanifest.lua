fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'VotreNom' -- Remplacez par votre nom
description 'CZP GoFast Script'
version '1.0.0'

-- Scripts côté client
client_scripts {
    'client/client.lua',
}

-- Scripts côté serveur
server_scripts {
    'server/server.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}