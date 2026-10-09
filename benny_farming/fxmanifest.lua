fx_version 'cerulean'
game 'gta5'

author 'BennySama'
description 'Beispiel, um Metallteile zu sammeln und zu verarbeiten'
version '1.0.0'

shared_scripts { '@ox_lib/init.lua', 'config.lua' }
client_scripts { '@benny_utils/client.lua', 'client.lua' }
server_script 'server.lua'

data_file 'OX_INVENTORY_ITEM' 'data/items.lua'
data_file 'OX_INVENTORY_CRAFTING' 'data/crafting.lua'

dependencies { 'ox_inventory', 'ox_lib', 'benny_utils' }
lua54 'yes'