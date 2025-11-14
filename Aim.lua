-- [FILE NAME]: Aim.lua
-- [SMART AIM BOT WITH HOTKEYS]
-- [AUTHOR]:AlexandrGolan
local wasMouseDown = false
local isAiming = false
local currentTarget = nil
local fixedAimAngle = nil
local aimBotEnabled = true -- [ENABLED BY DEFAULT]
local spawnMenuOpen = false

-- [WEAPONS TO IGNORE]
local ignoredWeapons = {
    ["weapon_physgun"] = true,
    ["weapon_physcannon"] = true,
    ["gmod_tool"] = true,
    ["weapon_gravitygun"] = true,
    ["weapon_crowbar"] = true
}

-- [FIRST DECLARE ALL FUNCTIONS]
local ResetAim
local FindNearestTarget
local GetHeadPosition
local SetFixedAim
local IsTargetAlive
local UpdateAim
local KillTarget
local ProcessShot
local IsWeaponIgnored

-- [FUNCTION TO CHECK IF WEAPON IS IGNORED]
IsWeaponIgnored = function(weapon)
    if not IsValid(weapon) then return true end
    local weaponClass = weapon:GetClass()
    return ignoredWeapons[weaponClass] or false
end

-- [FUNCTION TO RESET AIM WITH ALT]
ResetAim = function()
    isAiming = false
    fixedAimAngle = nil
    currentTarget = nil
    LocalPlayer():ConCommand("-attack")
end

-- [FUNCTION TO FIND NEAREST TARGET]
FindNearestTarget = function()
    local localPlayer = LocalPlayer()
    local localPos = localPlayer:GetShootPos()
    local closestTarget = nil
    local closestDistance = math.huge
    
    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and ent ~= localPlayer then
            local isAlive = false
            
            if ent:IsPlayer() and IsValid(ent) then
                isAlive = ent:Alive()
            elseif ent:IsNPC() and IsValid(ent) then
                isAlive = ent:Health() > 0
            elseif string.StartWith(ent:GetClass(), "nextbot") and IsValid(ent) then
                isAlive = ent:Health() > 0
            end
            
            if isAlive then
                local distance = localPos:Distance(ent:GetPos())
                if distance < closestDistance then
                    closestTarget = ent
                    closestDistance = distance
                end
            end
        end
    end
    
    return closestTarget
end

-- [FUNCTION TO GET HEAD POSITION]
GetHeadPosition = function(target)
    if not IsValid(target) then return Vector(0,0,0) end
    
    local headPos = nil
    local boneId = target:LookupBone("ValveBiped.Bip01_Head1")
    if boneId then
        headPos = target:GetBonePosition(boneId)
    end
    
    if not headPos then
        local alternativeBones = {"head", "Head", "bip_head", "Bip01 Head"}
        for _, boneName in ipairs(alternativeBones) do
            boneId = target:LookupBone(boneName)
            if boneId then
                headPos = target:GetBonePosition(boneId)
                if headPos then break end
            end
        end
    end
    
    if not headPos then
        if target:IsPlayer() then
            headPos = target:EyePos() + Vector(0, 0, 8)
        else
            local targetPos = target:GetPos()
            local targetMins, targetMaxs = target:GetCollisionBounds()
            
            local class = target:GetClass()
            if string.find(class, "cscanner") or string.find(class, "manhack") then
                headPos = targetPos + Vector(0, 0, 10)
            elseif string.find(class, "zombie") or string.find(class, "antlion") or string.find(class, "headcrab") then
                if targetMins and targetMaxs then
                    headPos = targetPos + Vector(0, 0, targetMaxs.z * 0.7)
                else
                    headPos = targetPos + Vector(0, 0, 50)
                end
            elseif string.find(class, "combine") or string.find(class, "soldier") then
                if targetMins and targetMaxs then
                    headPos = targetPos + Vector(0, 0, targetMaxs.z * 0.85)
                else
                    headPos = targetPos + Vector(0, 0, 70)
                end
            else
                if targetMins and targetMaxs then
                    headPos = targetPos + Vector(0, 0, targetMaxs.z * 0.8)
                else
                    headPos = targetPos + Vector(0, 0, 60)
                end
            end
        end
    end
    
    return headPos or target:GetPos() + Vector(0, 0, 60)
end

-- [FUNCTION TO SET FIXED AIM ANGLE]
SetFixedAim = function(target)
    if not IsValid(target) then return Vector(0,0,0) end
    
    local localPlayer = LocalPlayer()
    local localPos = localPlayer:GetShootPos()
    local headPos = GetHeadPosition(target)
    
    fixedAimAngle = (headPos - localPos):Angle()
    currentTarget = target
    isAiming = true
    
    return headPos
end

-- [FUNCTION TO CHECK IF TARGET IS ALIVE]
IsTargetAlive = function(target)
    if not IsValid(target) then return false end
    
    if target:IsPlayer() then
        return target:Alive()
    elseif target:IsNPC() then
        return target:Health() > 0
    elseif string.StartWith(target:GetClass(), "nextbot") then
        return target:Health() > 0
    end
    
    return false
end

-- [FUNCTION TO UPDATE AIM]
UpdateAim = function()
    if not isAiming then return false end
    
    if not IsValid(currentTarget) then
        isAiming = false
        fixedAimAngle = nil
        currentTarget = nil
        return false
    end
    
    if not IsTargetAlive(currentTarget) then
        isAiming = false
        fixedAimAngle = nil
        currentTarget = nil
        return false
    end
    
    local localPos = LocalPlayer():GetShootPos()
    local headPos = GetHeadPosition(currentTarget)
    fixedAimAngle = (headPos - localPos):Angle()
    
    return true
end

-- [FUNCTION TO KILL TARGET]
KillTarget = function(target, headPos)
    if not IsValid(target) then return end
    
    RunString([[
        if CLIENT then return end
        local target = Entity(]] .. target:EntIndex() .. [[)
        local attacker = Entity(]] .. LocalPlayer():EntIndex() .. [[)
        if IsValid(target) and target:Health() > 0 then
            local dmg = DamageInfo()
            dmg:SetDamage(99999)
            dmg:SetAttacker(attacker)
            dmg:SetInflictor(attacker)
            dmg:SetDamageType(DMG_BULLET)
            dmg:SetDamagePosition(Vector(]] .. headPos.x .. [[, ]] .. headPos.y .. [[, ]] .. headPos.z .. [[))
            target:TakeDamageInfo(dmg)
        end
    ]])
end

-- [FUNCTION TO PROCESS SHOT]
ProcessShot = function()
    if not aimBotEnabled then return end
    
    local localPlayer = LocalPlayer()
    if not IsValid(localPlayer) or not localPlayer:Alive() then return end
    
    -- [CHECK IF SPAWN MENU IS OPEN]
    if spawnMenuOpen then return end
    
    local weapon = localPlayer:GetActiveWeapon()
    if IsValid(weapon) and IsWeaponIgnored(weapon) then
        return
    end
    
    if isAiming then
        local targetAlive = UpdateAim()
        if targetAlive then
            local headPos = GetHeadPosition(currentTarget)
            KillTarget(currentTarget, headPos)
        else
            local newTarget = FindNearestTarget()
            if IsValid(newTarget) then
                local headPos = SetFixedAim(newTarget)
                KillTarget(newTarget, headPos)
            else
                isAiming = false
                fixedAimAngle = nil
                currentTarget = nil
            end
        end
    else
        local target = FindNearestTarget()
        if IsValid(target) then
            local headPos = SetFixedAim(target)
            KillTarget(target, headPos)
        end
    end
    
    localPlayer:ConCommand("+attack")
    timer.Simple(0.05, function()
        if IsValid(localPlayer) then
            localPlayer:ConCommand("-attack")
        end
    end)
end

-- [HOOKS]
hook.Add("Tick", "MaintainAim", function()
    if not aimBotEnabled then return end
    if isAiming and fixedAimAngle then
        if not UpdateAim() then return end
        LocalPlayer():SetEyeAngles(fixedAimAngle)
        
        if input.IsMouseDown(MOUSE_LEFT) and IsValid(currentTarget) and IsTargetAlive(currentTarget) then
            local headPos = GetHeadPosition(currentTarget)
            KillTarget(currentTarget, headPos)
        end
    end
end)

hook.Add("Tick", "AimBotShoot", function()
    if not aimBotEnabled then return end
    
    -- [CHECK IF SPAWN MENU IS OPEN]
    if spawnMenuOpen then return end
    
    local isMouseDown = input.IsMouseDown(MOUSE_LEFT)
    
    if isMouseDown and not wasMouseDown then
        ProcessShot()
    end
    
    if not isMouseDown and wasMouseDown then
        LocalPlayer():ConCommand("-attack")
    end
    
    wasMouseDown = isMouseDown
end)

hook.Add("Think", "AutoTargetSwitch", function()
    if not aimBotEnabled then return end
    if isAiming and currentTarget then
        if not IsValid(currentTarget) or not IsTargetAlive(currentTarget) then
            isAiming = false
            fixedAimAngle = nil
            currentTarget = nil
        end
    end
end)

-- [HOTKEY PROCESSING]
local altPressed = false

hook.Add("Think", "AimBotHotkeys", function()
    -- [ALT TO RESET AIM]
    if input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT) then
        if not altPressed then
            ResetAim()
            altPressed = true
        end
    else
        altPressed = false
    end
end)

-- [DETECT SPAWN MENU OPEN/CLOSE]
hook.Add("OnSpawnMenuOpen", "AimBotDisableOnSpawnMenu", function()
    spawnMenuOpen = true
end)

hook.Add("OnSpawnMenuClose", "AimBotEnableOnSpawnMenuClose", function()
    spawnMenuOpen = false
end)

-- [ALSO CHECK CONTEXT MENU]
hook.Add("OnContextMenuOpen", "AimBotDisableOnContextMenu", function()
    spawnMenuOpen = true
end)

hook.Add("OnContextMenuClose", "AimBotEnableOnContextMenuClose", function()
    spawnMenuOpen = false
end)
