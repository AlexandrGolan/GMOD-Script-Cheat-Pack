-- [FILE NAME]: Autobhop.lua
-- [AUTOMATIC BUNNY HOP]
-- [AUTHOR]:AlexandrGolan
hook.Add("Think", "AutoBhop", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    -- [CHECK IF PLAYER IS ALIVE AND ON GROUND]
    if not ply:Alive() or not ply:OnGround() then return end
    
    -- [CHECK IF SPACE IS HELD FOR JUMPING]
    if input.IsKeyDown(KEY_SPACE) then
        -- [APPLY JUMP]
        ply:ConCommand("+jump")
        timer.Simple(0.1, function() 
            if IsValid(ply) then 
                ply:ConCommand("-jump") 
            end 
        end)
        
        -- [INCREASE SPEED DURING STRAFING]
        if input.IsKeyDown(KEY_A) then -- [STRAFE LEFT]
            local vel = ply:GetVelocity()
            ply:SetVelocity(Vector(-vel.y * 0.1, vel.x * 0.1, 0) * 2)
        elseif input.IsKeyDown(KEY_D) then -- [STRAFE RIGHT]
            local vel = ply:GetVelocity()
            ply:SetVelocity(Vector(vel.y * 0.1, -vel.x * 0.1, 0) * 2)
        end
    end
end)

-- [SPEED INCREASE WITH EACH JUMP]
local jumpCount = 0
local lastJumpTime = 0

hook.Add("OnPlayerHitGround", "SpeedBoost", function(ply, inWater, onFloater, speed)
    if not IsValid(ply) or ply ~= LocalPlayer() then return end
    
    local currentTime = CurTime()
    
    -- [RESET COUNTER IF MORE THAN 1 SECOND HAS PASSED SINCE LAST JUMP]
    if currentTime - lastJumpTime > 1 then
        jumpCount = 0
    end
    
    -- [INCREASE SPEED BASED ON JUMP COUNT]
    if jumpCount > 0 then
        local speedMultiplier = 1 + (jumpCount * 0.1) -- [10% INCREASE WITH EACH JUMP]
        local currentVel = ply:GetVelocity()
        ply:SetVelocity(currentVel * (speedMultiplier - 1))
    end
    
    jumpCount = jumpCount + 1
    lastJumpTime = currentTime
end)

-- [ALTERNATIVE VERSION WITH SIMPLER CONTROLS]
hook.Add("CreateMove", "SimpleAutoBhop", function(cmd)
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- [AUTO-JUMP WHEN SPACE IS HELD]
    if cmd:KeyDown(IN_JUMP) then
        if ply:OnGround() then
            cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_JUMP))
        else
            cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
        end
    end
    
    -- [SPEED BOOST DURING AIR STRAFING]
    if not ply:OnGround() and (cmd:KeyDown(IN_MOVELEFT) or cmd:KeyDown(IN_MOVERIGHT)) then
        local forward = cmd:GetForwardMove()
        local side = cmd:GetSideMove()
        
        -- [DOUBLE THE SPEED]
        cmd:SetForwardMove(forward * 2)
        cmd:SetSideMove(side * 2)
    end
end)