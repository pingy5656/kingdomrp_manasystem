util.AddNetworkString("Mana_Update")
util.AddNetworkString("Mana_SetMax")

local jobManaConfig = {
    ["Druid"] = 100,
    ["Mage"] = 150,
}

local weaponManaCost = {
    ["swep_dex_plasmid_explosion"] = 10,
}

local function getMaxManaForJob(jobName)
    return jobManaConfig[jobName] or 0
end

hook.Add("EntityFireBullets", "ManaWeaponFire", function(ent, data)
    if not ent:IsPlayer() then return end  -- Ensure the entity is a player
    local weapon = ent:GetActiveWeapon()   -- Get the weapon the player is using

    if not IsValid(weapon) then return end -- Ensure the weapon is valid

    -- Check if the weapon is the one we're interested in
    if weapon:GetClass() == "swep_dex_plasmid_explosion" then
        -- Deduct mana and check if the player has enough
        if not DeductManaForWeapon(ent, weapon:GetClass()) then
            return false  -- Prevent the bullet from being fired
        end
    end
end)

local PLAYER = FindMetaTable("Player")

util.AddNetworkString("KRMP_UpdateEffectStatus")

function PLAYER:DeductManaForWeapon(weaponClass)
    local manaCost = weaponManaCost[weaponClass] or 0

    if self:GetNWInt("Mana") >= manaCost then
        self:SetNWInt("Mana", self:GetNWInt("Mana") - manaCost)
        self:SetNWBool("CanPlayEffect", true)
        
        net.Start("KRMP_UpdateEffectStatus")
        net.WriteBool(true)
        net.Send(self)
        
        return true
    else
        self:ChatPrint("You don't have enough mana!")
        self:SetNWBool("CanPlayEffect", false)
        
        net.Start("KRMP_UpdateEffectStatus")
        net.WriteBool(false)
        net.Send(self)
        
        return false
    end
end



hook.Add("PlayerInitialSpawn", "InitializeMana", function(ply)
    local maxMana = getMaxManaForJob(ply:Team())
    ply:SetNWInt("Mana", maxMana)
    ply:SetNWInt("MaxMana", maxMana)
end)

hook.Add("OnPlayerChangedTeam", "UpdateManaOnJobChange", function(ply, oldTeam, newTeam)
    local maxMana = getMaxManaForJob(team.GetName(newTeam))
    ply:SetNWInt("Mana", maxMana)
    ply:SetNWInt("MaxMana", maxMana)
end)

timer.Create("ManaRegen", 5, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        local maxMana = ply:GetNWInt("MaxMana", 0)
        local currentMana = ply:GetNWInt("Mana", 0)
        if currentMana < maxMana then
            ply:SetNWInt("Mana", math.min(currentMana + 5, maxMana))
            net.Start("Mana_Update")
            net.WriteInt(math.min(currentMana + 5, maxMana), 16)
            net.Send(ply)
        end
    end
end)
