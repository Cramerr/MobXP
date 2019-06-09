do
    GameTooltip:HookScript('OnTooltipSetUnit', function(self)
        MobXPTooltip(self)
    end)
end

local function CalcXp()
    t = UnitLevel("mouseover");
    p = UnitLevel("player");
    if ( t == -1 ) then
        return 0;
    end
    if ( t == p ) then
        xp = ((p * 5) + 45);
    end
    if ( t > p ) then
        xp = ((p * 5) + 45) * (1 + 0.05 * (t - p));
    end
    if ( t < p ) then
        -- need gray level "g"
        if (p < 6) then g = 0; end
        if (p > 5 and p < 40) then
            g = p - 5 - floor(p/10);
        end
        if (p > 39) then
            g = p - 1 - floor(p/5);
        end
        if (t > g) then
            -- need zero difference "z"
            if (p < 8) then z = 5; end
            if (p > 7 and p < 10) then z = 6; end
            if (p > 9 and p < 12 ) then z = 7; end
            if (p > 11 and p < 16 ) then z = 8; end
            if (p > 15 and p < 20 ) then z = 9; end
            if (p > 19 and p < 40 ) then z = 9 + floor(p/10); end
            if (p > 39) then z = 5 + floor(p/5); end
            xp = (p * 5 + 45) * (1 - (p - t) / z);
        else
            -- t <= g, mob is Gray
            xp = 0;
        end
    end
    xp = floor(xp+0.5);    -- result is rounded before calculating rest bonus
    if ( GetRestState() == 1) then
        xp = xp * 2;
    end
    if ( UnitClassification("target") == "elite" ) then
        xp = xp * 2;
        -- what about "worldboss", "rareelite"... not sure how the XP scales
    end
    if (xp > 0) then
        return xp;
    else
        return 0;
    end
end

local function DetermineUnitType(guid)
    local parts = {strsplit('-', guid)}
    local type = parts[1]
    if type == 'Creature' then
        local id = tonumber(parts[6])
        return type, id
    end

    return type
end

function MobXPTooltip(tooltip)
    local name, unit = tooltip:GetUnit()
    if unit then
        local guid = UnitGUID(unit)
        if (guid) then
            local type, id = DetermineUnitType(guid)
            if type == 'Creature' and UnitCanAttack("player","mouseover") then
                if IsXPUserDisabled() then
                    tooltip:AddDoubleLine('XP turned off')
                else
                    local xpPerMob = CalcXp()
                    xpNeeded = (UnitXPMax("player") - UnitXP("player")) / xpPerMob
                    tooltip:AddDoubleLine(xpPerMob, 'xp per mob')
                    tooltip:AddDoubleLine(math.ceil(xpNeeded), 'mobs to level')
                end
            end
        end
    end
