Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isProtected then
            SetPedCanBeTargetted(PlayerPedId(), false)
            
            if Config.DisableMeleeDamage then
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 143, true)
            end
        else
            SetPedCanBeTargetted(PlayerPedId(), true)
        end
    end
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local attacker = args[2]
        local isDead = args[4] == 1
        
        if victim == PlayerPedId() and isDead and isProtected then
            Citizen.Wait(2000)
            NetworkResurrectLocalPlayer(GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, false)
            QBCore.Functions.Notify('Koruma aktif olduğu için yeniden canlandırıldınız.', 'info')
        end
    end
end)

