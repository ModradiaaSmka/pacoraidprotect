local QBCore = exports['qb-core']:GetCoreObject()

local protectionData = {}

RegisterNetEvent('protection:rewardPlayer')
AddEventHandler('protection:rewardPlayer', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        local citizenid = Player.PlayerData.citizenid
        if not protectionData[citizenid] or not protectionData[citizenid].completed then
            Player.Functions.AddMoney('bank', Config.RewardAmount, "protection-reward")
            protectionData[citizenid] = {completed = true}
            
            MySQL.Async.execute('INSERT INTO player_protection (citizenid, completed, remaining_time) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE completed = ?, remaining_time = ?',
                {citizenid, true, 0, true, 0})
        end
    end
end)

RegisterNetEvent('protection:saveRemainingTime')
AddEventHandler('protection:saveRemainingTime', function(remainingTime)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        local citizenid = Player.PlayerData.citizenid
        MySQL.Async.execute('INSERT INTO player_protection (citizenid, completed, remaining_time) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE remaining_time = ?',
            {citizenid, false, remainingTime, remainingTime})
    end
end)

QBCore.Functions.CreateCallback('protection:getProtectionStatus', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if Player then
        local citizenid = Player.PlayerData.citizenid
        MySQL.Async.fetchAll('SELECT * FROM player_protection WHERE citizenid = ?', {citizenid}, function(result)
            if result[1] then
                cb(result[1])
            else
                cb({completed = false, remaining_time = Config.ProtectionTime * 60})
            end
        end)
    else
        cb({completed = false, remaining_time = Config.ProtectionTime * 60})
    end
end)

-- Reset protection status command for admins
QBCore.Commands.Add('resetkoruma', 'Oyuncunun koruma durumunu sıfırla (Sadece Admin)', {{name = 'id', help = 'Oyuncu ID'}}, true, function(source, args)
    local src = source
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('QBCore:Notify', src, 'Geçerli bir oyuncu ID\'si girin!', 'error')
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(targetId)
    if Player then
        local citizenid = Player.PlayerData.citizenid
        MySQL.Async.execute('DELETE FROM player_protection WHERE citizenid = ?', {citizenid})
        protectionData[citizenid] = nil
        TriggerClientEvent('QBCore:Notify', src, 'Oyuncunun koruma durumu sıfırlandı!', 'success')
        TriggerClientEvent('QBCore:Notify', targetId, 'Koruma durumunuz sıfırlandı!', 'info')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Oyuncu bulunamadı!', 'error')
    end
end, 'admin')

