local QBCore = exports['qb-core']:GetCoreObject()
local isProtected = false
local protectionTimeLeft = 0

function EnableProtection()
    isProtected = true
    protectionTimeLeft = Config.ProtectionTime * 60
    
    SetEntityAlpha(PlayerPedId(), 200, false)
    SetEntityCollision(PlayerPedId(), true, false)
    NetworkSetEntityInvisibleToNetwork(PlayerPedId(), true)
    
    SendNUIMessage({
        action = "show",
        logo = Config.Logo,
        title = Config.UITitle,
        timerText = Config.UITimerText,
        rewardText = Config.UIRewardText,
        protectionText = Config.UIProtectionText,
        rewardAmount = Config.RewardAmount,
        minutes = math.ceil(protectionTimeLeft / 60)
    })
    
    Citizen.CreateThread(function()
        while isProtected and protectionTimeLeft > 0 do
            Citizen.Wait(1000)
            protectionTimeLeft = protectionTimeLeft - 1
            
            SendNUIMessage({
                action = "updateTimer",
                minutes = math.ceil(protectionTimeLeft / 60)
            })
            
            if protectionTimeLeft <= 0 then
                EndProtection()
                break
            end
        end
    end)

    Citizen.CreateThread(function()
        while isProtected do
            Citizen.Wait(0)
            local ped = PlayerPedId()
            
            SetPedCanRagdoll(ped, false)
            SetEntityProofs(ped, true, true, true, true, true, true, true, true)
            SetPedCanBeTargetted(ped, false)
            SetPlayerCanDoDriveBy(PlayerId(), false)
            DisablePlayerFiring(PlayerId(), true)
            
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                SetEntityAlpha(vehicle, 200, false)
                SetEntityCollision(vehicle, true, false)
                NetworkSetEntityInvisibleToNetwork(vehicle, true)
                SetEntityProofs(vehicle, true, true, true, true, true, true, true, true)
                
                local vehicles = GetGamePool('CVehicle')
                for _, otherVehicle in ipairs(vehicles) do
                    if otherVehicle ~= vehicle then
                        SetEntityNoCollisionEntity(vehicle, otherVehicle, true)
                        SetEntityNoCollisionEntity(otherVehicle, vehicle, true)
                    end
                end
                
                local peds = GetGamePool('CPed')
                for _, nearbyPed in ipairs(peds) do
                    if nearbyPed ~= ped then
                        SetEntityNoCollisionEntity(vehicle, nearbyPed, true)
                        SetEntityNoCollisionEntity(nearbyPed, vehicle, true)
                    end
                end
            end
            
            for _, player in ipairs(GetActivePlayers()) do
                local playerPed = GetPlayerPed(player)
                if playerPed ~= ped then
                    SetEntityNoCollisionEntity(ped, playerPed, true)
                end
            end
        end
    end)
end

function EndProtection()
    if not isProtected then return end
    
    isProtected = false
    protectionTimeLeft = 0
    local ped = PlayerPedId()
    
    SendNUIMessage({
        action = "hide"
    })
    
    ResetEntityAlpha(ped)
    SetEntityCollision(ped, true, true)
    NetworkSetEntityInvisibleToNetwork(ped, false)
    SetPedCanRagdoll(ped, true)
    SetEntityProofs(ped, false, false, false, false, false, false, false, false)
    SetPedCanBeTargetted(ped, true)
    SetPlayerCanDoDriveBy(PlayerId(), true)
    
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        ResetEntityAlpha(vehicle)
        SetEntityCollision(vehicle, true, true)
        NetworkSetEntityInvisibleToNetwork(vehicle, false)
        SetEntityProofs(vehicle, false, false, false, false, false, false, false, false)
        
        local vehicles = GetGamePool('CVehicle')
        for _, otherVehicle in ipairs(vehicles) do
            if otherVehicle ~= vehicle then
                SetEntityNoCollisionEntity(vehicle, otherVehicle, false)
                SetEntityNoCollisionEntity(otherVehicle, vehicle, false)
            end
        end
        
        local peds = GetGamePool('CPed')
        for _, nearbyPed in ipairs(peds) do
            if nearbyPed ~= ped then
                SetEntityNoCollisionEntity(vehicle, nearbyPed, false)
                SetEntityNoCollisionEntity(nearbyPed, vehicle, false)
            end
        end
    end
    
    TriggerServerEvent('protection:rewardPlayer')
    QBCore.Functions.Notify('Koruma süresi sona erdi. $' .. Config.RewardAmount .. ' ödülünüz banka hesabınıza yatırıldı.', 'success')
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Citizen.Wait(2000)
    EnableProtection()
end)

RegisterCommand('testkoruma', function(source, args)
    local action = args[1]
    
    if action == "baslat" then
        QBCore.Functions.Notify('Koruma sistemi test için başlatıldı.', 'success')
        EnableProtection()
    elseif action == "bitir" then
        QBCore.Functions.Notify('Koruma sistemi test için sonlandırıldı.', 'info')
        EndProtection()
    elseif action == "sure" and args[2] then
        local minutes = tonumber(args[2])
        if minutes and minutes > 0 then
            Config.ProtectionTime = minutes
            QBCore.Functions.Notify('Koruma süresi ' .. minutes .. ' dakika olarak ayarlandı.', 'success')
        else
            QBCore.Functions.Notify('Geçerli bir süre giriniz.', 'error')
        end
    else
        QBCore.Functions.Notify('Kullanım: /testkoruma [baslat/bitir/sure] [dakika]', 'primary')
    end
end, false)

