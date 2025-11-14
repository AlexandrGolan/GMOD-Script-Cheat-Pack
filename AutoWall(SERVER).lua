-- [FILE NAME]: AutoWall(SERVER).lua
-- [ULTIMATE WALLBREAKER - SERVER]
-- [AUTHOR]:AlexandrGolan
util.AddNetworkString("UltimateWallBreakerDamage")

net.Receive("UltimateWallBreakerDamage", function(len, ply)
    local target = net.ReadEntity()
    local attacker = net.ReadEntity()
    local damage = net.ReadUInt(32)
    local hitPos = net.ReadVector()
    
    if not IsValid(target) then return end
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if attacker ~= ply then return end
    
    local dmgInfo = DamageInfo()
    dmgInfo:SetAttacker(attacker)
    dmgInfo:SetInflictor(attacker)
    dmgInfo:SetDamage(damage)
    dmgInfo:SetDamageType(DMG_BULLET)
    dmgInfo:SetDamagePosition(hitPos)
    
    target:TakeDamageInfo(dmgInfo)
end)