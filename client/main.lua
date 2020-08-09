ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local Vehicle = {
	Coords = nil,
	Vehicle = nil,
	Dimension = nil,
	IsInFront = false,
	Distance = nil
}


Citizen.CreateThread(function()
	Citizen.Wait(200)

	local ped = PlayerPedId()

	while true do 
		local closestVehicle, Distance = ESX.Game.GetClosestVehicle()
		local vehicleCoords = GetEntityCoords(closestVehicle)
        local dimension = GetModelDimensions(GetEntityModel(closestVehicle), vector3(0.0, 0.0, 0.0), vector3(5.0, 5.0, 5.0))

        if Distance < 6.0 and not IsPedInAnyVehicle(ped, false) then
        	Vehicle.Coords = vehicleCoords
            Vehicle.Dimensions = dimension
            Vehicle.Vehicle = closestVehicle
            Vehicle.Distance = Distance
            
            if GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle), GetEntityCoords(ped), true) > GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle) * -1, GetEntityCoords(ped), true) then
                Vehicle.IsInFront = false
            else
                Vehicle.IsInFront = true
            end
        else
        	Vehicle = {
        		Coords 		= nil, 
        		Vehicle 	= nil, 
        		Dimensions 	= nil, 
        		IsInFront 	= false, 
        		Distance 	= nil
        	}
        end

        Citizen.Wait(500)
	end
end)

Citizen.CreateThread(function()
	local ped = PlayerPedId()
	
	while true do 
		Citizen.Wait(5)

		if Vehicle.Vehicle ~= nil then
            local currentVehicle = Vehicle.Vehicle

            if IsVehicleSeatFree(currentVehicle, -1) and GetVehicleEngineHealth(currentVehicle) <= Config.DamageNeeded then
                ESX.Game.Utils.DrawText3D(vector3(Vehicle.Coords.x, Vehicle.Coords.y, Vehicle.Coords.z), _U('push_vehicle'), 0.4)
            end
 

            if IsControlPressed(0, 21) and IsVehicleSeatFree(currentVehicle, -1) and not IsEntityAttachedToEntity(ped, currentVehicle) and IsControlJustPressed(0, 38) and GetVehicleEngineHealth(currentVehicle) <= Config.DamageNeeded then
               
                NetworkRequestControlOfEntity(currentVehicle)

                local coords = GetEntityCoords(ped)

                if Vehicle.IsInFront then    
                    AttachEntityToEntity(PlayerPedId(), currentVehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y * -1 + 0.1 , Vehicle.Dimensions.z + 1.0, 0.0, 0.0, 180.0, 0.0, false, false, true, false, true)
                else
                    AttachEntityToEntity(PlayerPedId(), currentVehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y - 0.3, Vehicle.Dimensions.z  + 1.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, true)
                end

                ESX.Streaming.RequestAnimDict('missfinale_c2ig_11')
                TaskPlayAnim(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0, -8.0, -1, 35, 0, 0, 0, 0)

                Citizen.Wait(200)

                while true do
                    Citizen.Wait(5)

                    if IsDisabledControlPressed(0, 34) then
                        TaskVehicleTempAction(PlayerPedId(), currentVehicle, 11, 1000)
                    end

                    if IsDisabledControlPressed(0, 9) then
                        TaskVehicleTempAction(PlayerPedId(), currentVehicle, 10, 1000)
                    end

                    if Vehicle.IsInFront then
                        SetVehicleForwardSpeed(currentVehicle, -1.0)
                    else
                        SetVehicleForwardSpeed(currentVehicle, 1.0)
                    end

                    if HasEntityCollidedWithAnything(currentVehicle) then
                        SetVehicleOnGroundProperly(currentVehicle)
                    end

                    if not IsDisabledControlPressed(0, 38) then
                        DetachEntity(ped, false, false)
                        StopAnimTask(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
                        FreezeEntityPosition(ped, false)
                        break
                    end
                end
            end
        end
	end
end)

