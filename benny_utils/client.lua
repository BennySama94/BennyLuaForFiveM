---Creates a short-range local map blip.
---@param coords vector3 | {x: number, y: number, z: number}
---@param data { sprite: number, colour: number, name: string, display?: number, scale?: number, shortRange?: boolean }
---@return number blip
function CreateBlip(coords, data)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipDisplay(blip, data.display or 4)
    SetBlipScale(blip, data.scale or 1.0)
    SetBlipColour(blip, data.colour or 0)
    SetBlipAsShortRange(blip, data.shortRange ~= false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(data.name)
    EndTextCommandSetBlipName(blip)
    return blip
end