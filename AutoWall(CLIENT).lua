-- [FILE NAME]: AutoWall(CLIENT).lua
-- [ULTIMATE WALLBREAKER - CLIENT]
-- [AUTHOR]:AlexandrGolan
local UltimateWallBreaker = {}
local shotCooldown = 0

function UltimateWallBreaker.Enable()
    hook.Remove("Think", "UltimateWallBreaker")
    
    hook.Add("Think", "UltimateWallBreaker", function()
        if CurTime() < shotCooldown then return end
        
        local localPlayer = LocalPlayer()
        if not IsValid(localPlayer) then return end
        if not localPlayer:Alive() then return end
        
        local weapon = localPlayer:GetActiveWeapon()
        if not IsValid(weapon) then return end
        if weapon:GetClass() == "weapon_physgun" then return end
        
        -- [CHECK IF PLAYER IS RELOADING]
        if weapon:GetNetworkedBool("reloading", false) then return end
        
        -- [CHECK IF WEAPON HAS AMMO]
        local clip1 = weapon:Clip1()
        local primaryAmmoType = weapon:GetPrimaryAmmoType()
        local ammoCount = localPlayer:GetAmmoCount(primaryAmmoType)
        
        if clip1 <= 0 and ammoCount <= 0 then return end
        
        if input.IsMouseDown(MOUSE_LEFT) then
            local shootPos = localPlayer:GetShootPos()
            local aimVec = localPlayer:GetAimVector()
            
            local target, hitPos = UltimateWallBreaker.FindTargetIgnoreWalls(shootPos, aimVec)
            
            if target then
                UltimateWallBreaker.DealDamage(target, localPlayer, 50, hitPos)
                shotCooldown = CurTime() + 0.1
            end
        end
    end)
end

function UltimateWallBreaker.FindTargetIgnoreWalls(shootPos, aimVec)
    local bestTarget = nil
    local bestDot = -1
    
    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and UltimateWallBreaker.IsValidTarget(ent) then
            local entPos = ent:EyePos()
            local toEnt = entPos - shootPos
            local directionToEnt = toEnt:GetNormalized()
            local dot = directionToEnt:Dot(aimVec)
            
            if dot > 0.999 then
                if dot > bestDot then
                    bestTarget = ent
                    bestDot = dot
                end
            end
        end
    end
    
    if bestTarget then
        local hitPos = bestTarget:EyePos()
        return bestTarget, hitPos
    end
    
    return nil, nil
end

function UltimateWallBreaker.IsValidTarget(ent)
    if not IsValid(ent) then return false end
    if ent == LocalPlayer() then return false end
    
    if ent:IsNPC() then return true end
    if ent:IsPlayer() then 
        local myTeam = LocalPlayer():Team()
        local targetTeam = ent:Team()
        return targetTeam ~= myTeam
    end
    
    local class = ent:GetClass() or ""
    return class:find("nextbot") or class:find("zombie") or class:find("combine") or class:find("headcrab")
end

function UltimateWallBreaker.DealDamage(target, attacker, damage, hitPos)
    net.Start("UltimateWallBreakerDamage")
        net.WriteEntity(target)
        net.WriteEntity(attacker)
        net.WriteUInt(damage, 32)
        net.WriteVector(hitPos)
    net.SendToServer()
end

function UltimateWallBreaker.Disable()
    hook.Remove("Think", "UltimateWallBreaker")
end

-- [HOOK TO DETECT RELOADING]
hook.Add("Think", "DetectReloading", function()
    local localPlayer = LocalPlayer()
    if not IsValid(localPlayer) then return end
    
    local weapon = localPlayer:GetActiveWeapon()
    if not IsValid(weapon) then return end
    
    local reloading = weapon:GetNetworkedBool("reloading", false)
    
    if not reloading then
        local nextPrimaryFire = weapon:GetNextPrimaryFire()
        if nextPrimaryFire > CurTime() then
            weapon:SetNetworkedBool("reloading", true)
        end
    else
        local nextPrimaryFire = weapon:GetNextPrimaryFire()
        if nextPrimaryFire <= CurTime() then
            weapon:SetNetworkedBool("reloading", false)
        end
    end
end)

hook.Add("InitPostEntity", "AutoEnableWallBreaker", function()
    timer.Simple(5, function()
        if LocalPlayer() and IsValid(LocalPlayer()) then
            UltimateWallBreaker.Enable()
        end
    end)
end)

concommand.Add("ultimate_wallbreaker", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    if args[1] == "1" then
        UltimateWallBreaker.Enable()
    else
        UltimateWallBreaker.Disable()
    end
end)