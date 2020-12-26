LoadModuleTranslations("Data/Locales/".. GlobalConfig.Lang ..".lua")
local Config = LoadModuleConfig("Data/Config.lua")


SetArtificialLightsState(true)
SetScenarioGroupEnabled("LSA_Planes", false)
StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
SetDistantCarsEnabled(true)
SetMaxWantedLevel(0)

SetInterval(10, function()
    for i, Player in pairs(GetActivePlayers()) do

        local PlayerId = GetPlayerFromServerId(Player)
        local PlayerPed = GetPlayerPed(PlayerId)
        local VehicleHandler = -1
        local Success
        local Handler, VehicleHandler = FindFirstVehicle()

        repeat
            Wait(10)
            local VehicleCoords = GetEntityCoords(VehicleHandler)

            if (IsPedInVehicle(PlayerPed, VehicleHandler, true)) or (GetLastPedInVehicleSeat(VehicleHandler, -1) == PlayerPed) then
                SetVehRadioStation(VehicleHandler, "OFF")
                --SetVehicleForwardSpeed(VehicleHandler, 0.0)
            else

                if (Utils.Random(1, 100) <= Config.PercentageVehiclesUndriveable) and GetVehicleEngineHealth(VehicleHandler) > 999.0 then
                    SetVehicleIsConsideredByPlayer(VehicleHandler, false)
                    SetEntityRenderScorched(VehicleHandler, true)
                    SetVehicleEngineHealth(VehicleHandler, -4000.0)
                else
                    SetVehicleEngineHealth(VehicleHandler, 999.0)
                end

                if not (IsVehicleSeatFree(VehicleHandler, -1)) then
                    local PedHandler = GetPedInVehicleSeat(VehicleHandler, -1)
                    DeleteEntity(PedHandler)
                end

                --SetVehicleDoorOpen
                SetVehicleEngineOn(VehicleHandler, false, true, true)
                --SetVehicleForwardSpeed(VehicleHandler, 0.0)
                BringVehicleToHalt(VehicleHandler, 0, 1, false)
            end
             
            if (Config.Debug) then
                DrawMarker(1, VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 4.0, 4.0, 2.0, 255, 255, 255, 255, false, true, 2, nil, nil, false)
            end

            Success, VehicleHandler = FindNextVehicle(Handler)
        until not (Success)

        EndFindPed(Handler)
    end
end)

SetInterval(0, function()
    for i, Interior in pairs(Config.InteriorLights) do
        DrawLightWithRange(Interior.X, Interior.Y, Interior.Z, Interior.R, Interior.G, Interior.B, Interior.Range, Interior.Intensity)
    end
end)

SetInterval(0, function()
    DisablePlayerVehicleRewards(PlayerId())
    for i=0,15 do
        EnableDispatchService(i, false)
    end
end)

SetInterval(500, function()
    for i, Safe in pairs(Config.SafeZones) do
        local PedHandler = -1
        local Success = false
        local Handler, PedHandler = FindFirstPed()

        repeat
            Wait(10)
            if IsPedHuman(PedHandler) and not IsPedAPlayer(PedHandler) and not IsPedDeadOrDying(PedHandler, true) then
                local PedCoords = GetEntityCoords(PedHandler)

                if (Safe.X < (PedCoords.x + (Safe.Width / 2)) and Safe.X > (PedCoords.x - (Safe.Width / 2)) and Safe.Y < (PedCoords.y + (Safe.Height / 2)) and Safe.Y > (PedCoords.y - (Safe.Height / 2))) then
                    DeleteEntity(PedHandler)
                end
            end

            Success, PedHandler = FindNextPed(Handler)
        until not (Success)

        EndFindPed(Handler)
    end
end)