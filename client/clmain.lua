local PlayerData = {}
local variable = false

RegisterNetEvent('infoped:open')
AddEventHandler('infoped:open', function(title, filename)
  SendNUIMessage({
     open = "true",
     title = title,
     filename = filename
  })
  SetNuiFocus(true, true)
end)

function closeUI()
  SendNUIMessage({
    open = "false",
  })
  SetNuiFocus(false, false)
end

RegisterNUICallback('close', function(data)
  closeUI()
end)

Citizen.CreateThread(function()
  for k, v in pairs(Config.Infos) do
    local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
    if v.setblip then
      SetBlipSprite(blip, 407)
      SetBlipScale(blip, 0.7)
      SetBlipColour(blip, 30)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName('STRING')
      AddTextComponentSubstringPlayerName(v.name)
      EndTextCommandSetBlipName(blip)
    end
  end
end)

Citizen.CreateThread(function()
   for k, v in pairs(Config.Infos) do
     local hash = GetHashKey(v.ped)

     if not HasModelLoaded(hash) then
         RequestModel(hash)
         Citizen.Wait(100)
     end

     while not HasModelLoaded(hash) do
         Citizen.Wait(0)
     end

     if variable == false then
         local npc = CreatePed(6, hash,  v.coords.x, v.coords.y, v.coords.z-1, v.coords.h, false, false) -- PED Position
         SetEntityInvincible(npc, true)
         FreezeEntityPosition(npc, true)
         SetPedDiesWhenInjured(npc, false)
         SetPedCanRagdollFromPlayerImpact(npc, false)
         SetPedCanRagdoll(npc, false)
         SetEntityAsMissionEntity(npc, true, true)
         SetEntityDynamic(npc, true)
         SetBlockingOfNonTemporaryEvents(npc, true)
     end
   end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    local playerCoords = GetEntityCoords(PlayerPedId())
    for k, v in pairs (Config.Infos) do
      local distance = #(playerCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
      if distance <= 1.5 then
        showHelpNotification('[~y~E~s~] Information')
        if IsControlJustReleased(1, 51) then
          TriggerEvent('infoped:open', v.name, v.filename)
        end
      end
    end
  end
end)

function showHelpNotification(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end
