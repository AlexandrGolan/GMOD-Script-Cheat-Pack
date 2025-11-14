-- [FILE NAME]: WallHack.lua
-- [WALLHACK FOR GARRY'S MOD]
-- [AUTHOR]:AlexandrGolan

if CLIENT then
    -- [VARIABLES FOR STORING STATE]
    local wallhackEnabled = true
    local highlightColor = Color(64, 224, 208) -- [TURQUOISE COLOR]
    local maxEntities = 1000 -- [MAXIMUM SUPPORTED ENTITIES]

    -- [FUNCTION TO GET ENTITY INFORMATION]
    local function GetEntityInfo(ent)
        local info = {}
        
        -- [DETERMINE TYPE]
        if ent:IsPlayer() then
            info.type = "Player"
            info.health = ent:Health()
            info.armor = ent:Armor()
        elseif ent:IsNPC() then
            info.type = "NPC"
            info.health = ent:Health()
            info.armor = 0
        elseif ent:GetClass():find("nextbot") then
            info.type = "NextBot"
            info.health = ent:Health() or 100
            info.armor = 0
        else
            return nil
        end
        
        -- [DISTANCE TO PLAYER]
        local localPlayer = LocalPlayer()
        if IsValid(localPlayer) then
            info.distance = math.Round(localPlayer:GetPos():Distance(ent:GetPos()) / 40)
        else
            info.distance = 0
        end
        
        return info
    end
    
    -- [HIGHLIGHT ENTITIES THROUGH WALLS WITH IMPROVED VISIBILITY]
    hook.Add("PreDrawHalos", "WallHackHighlight", function()
        if not wallhackEnabled then return end
        
        local entities = {}
        local localPlayer = LocalPlayer()
        
        if not IsValid(localPlayer) then return end
        
        -- [COLLECT ALL ENTITIES FOR HIGHLIGHTING WITH LIMIT]
        local entityCount = 0
        for _, ent in pairs(ents.GetAll()) do
            if entityCount >= maxEntities then break end
            
            if IsValid(ent) and ent ~= localPlayer then
                if ent:IsPlayer() or ent:IsNPC() or ent:GetClass():find("nextbot") then
                    table.insert(entities, ent)
                    entityCount = entityCount + 1
                end
            end
        end
        
        -- [APPLY HIGHLIGHTING WITH BRIGHTER SETTINGS]
        if #entities > 0 then
            halo.Add(entities, highlightColor, 5, 5, 3, true, true) -- [INCREASED HALO SIZE AND INTENSITY]
        end
    end)
    
    -- [DRAW LINES FROM PLAYER TO ENTITIES]
    hook.Add("PostDrawTranslucentRenderables", "WallHackDistanceLines", function()
        if not wallhackEnabled then return end
        
        local localPlayer = LocalPlayer()
        if not IsValid(localPlayer) then return end
        
        local playerPos = localPlayer:GetPos()
        
        -- [DRAW LINES TO ALL VALID ENTITIES]
        local entityCount = 0
        for _, ent in pairs(ents.GetAll()) do
            if entityCount >= maxEntities then break end
            
            if IsValid(ent) and ent ~= localPlayer then
                if ent:IsPlayer() or ent:IsNPC() or ent:GetClass():find("nextbot") then
                    local entPos = ent:GetPos()
                    
                    -- [DRAW LINE FROM PLAYER TO ENTITY]
                    render.SetColorMaterial()
                    render.DrawLine(playerPos, entPos, Color(64, 224, 208, 255), true)
                    
                    entityCount = entityCount + 1
                end
            end
        end
    end)
    
    -- [DRAW INFORMATION NEXT TO ENTITIES]
    hook.Add("PostDrawTranslucentRenderables", "WallHackEntityInfo", function()
        if not wallhackEnabled then return end
        
        local localPlayer = LocalPlayer()
        if not IsValid(localPlayer) then return end
        
        local entityCount = 0
        
        for _, ent in pairs(ents.GetAll()) do
            if entityCount >= maxEntities then break end
            
            if IsValid(ent) and ent ~= localPlayer then
                local info = GetEntityInfo(ent)
                if info then
                    local entPos = ent:GetPos() + Vector(0, 0, 80)
                    local screenPos = entPos:ToScreen()
                    
                    if screenPos.visible then
                        cam.Start2D()
                            local text = string.format("%s | HP: %d | DIST: %dm", 
                                info.type, info.health, info.distance)
                            
                            draw.SimpleText(text, "DermaDefault", screenPos.x + 20, screenPos.y, Color(64, 224, 208), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        cam.End2D()
                    end
                    
                    entityCount = entityCount + 1
                end
            end
        end
    end)
    
    -- [REMOVE DEFAULT HUD FOR PLAYERS, NPCS AND NEXTBOTS]
    hook.Add("HUDDrawTargetID", "HideTargetID", function()
        if wallhackEnabled then
            return false
        end
    end)
end