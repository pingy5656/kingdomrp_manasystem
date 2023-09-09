util.AddNetworkString("Mana_Update")
util.AddNetworkString("Mana_SetMax")

local jobManaConfig = {
    ["Druid"] = 100,
    ["Mage"] = 150,
}

local weaponManaCost = {
    ["swep_dex_plasmid_bleed"] = 10,
    ["swep_dex_plasmid_bubbles"] = 5,
    ["swep_dex_plasmid_electricity"] = 45,
    ["swep_dex_plasmid_explosion"] = 50,
    ["swep_dex_plasmid_fire"] = 35,
    ["swep_dex_plasmid_heal"] = 15,
    ["swep_dex_plasmid_ice"] = 80,
    ["swep_dex_plasmid_seagull"] = 5,
    ["swep_dex_plasmid_sickness"] = 65,
    ["swep_dex_plasmid_telekinesis"] = 70,
    ["swep_dex_plasmid_teleport"] = 35,
    ["swep_dex_plasmid_water"] = 15,
}

local function getMaxManaForJob(jobName)
    return jobManaConfig[jobName] or 0
end

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
