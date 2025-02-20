ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('givecar', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local model = args[1]
    local targetPlayerId = tonumber(args[2])
    local plate = args[3]

    if not model or not targetPlayerId then
        print('Invalid arguments. Usage: /givecar (model) (playerid) [plate]')
        return
    end

    if plate and (string.len(plate) < 4 or string.len(plate) > 7) then
        print('Invalid plate. Plate must be 4-7 characters long.')
        return
    end

    if not plate then
        plate = string.upper(GetRandomString(7))
    end

    if Config.UseAdminIdentifier then
        local isAdmin = false
        for _, identifier in ipairs(Config.AdminIdentifiers) do
            print("Checking identifier: " .. identifier) -- Debug print
            for _, playerIdentifier in ipairs(GetPlayerIdentifiers(source)) do
                print("Player identifier: " .. playerIdentifier) -- Debug print
                if playerIdentifier == identifier then
                    isAdmin = true
                    break
                end
            end
            if isAdmin then break end
        end
        if not isAdmin then
            print('You do not have permission to use this command.')
            return
        end
    elseif Config.UseAdminGroup then
        local playerGroup = xPlayer.getGroup()
        print("Player group: " .. playerGroup) -- Debug print
        local isAdmin = false
        for _, group in ipairs(Config.AdminGroups) do
            print("Checking group: " .. group) -- Debug print
            if playerGroup == group then
                isAdmin = true
                break
            end
        end
        if not isAdmin then
            print('You do not have permission to use this command.')
            return
        end
    end

    local targetPlayer = ESX.GetPlayerFromId(targetPlayerId)
    if not targetPlayer then
        print('Player not found.')
        return
    end

    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, vehicle) VALUES (@owner, @vehicle)', {
        ['@owner'] = targetPlayer.identifier,
        ['@vehicle'] = json.encode({ model = model, plate = plate })
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print('Vehicle given successfully.')
            TriggerClientEvent('chat:addMessage', targetPlayerId, { args = { '^2SYSTEM', 'You have received a new vehicle with plate ' .. plate .. '.' } })
        else
            print('Failed to give vehicle.')
        end
    end)
end, false)

function GetRandomString(length)
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local randomString = ''
    for i = 1, length do
        local rand = math.random(#chars)
        randomString = randomString .. chars:sub(rand, rand)
    end
    return randomString
end
