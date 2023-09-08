net.Receive("Mana_Update", function()
    local newMana = net.ReadInt(16)
    LocalPlayer():SetNWInt("Mana", newMana)
end)

net.Receive("Mana_SetMax", function()
    local maxMana = net.ReadInt(16)
    LocalPlayer():SetNWInt("MaxMana", maxMana)
end)

net.Receive("KRMP_UpdateEffectStatus", function()
    local canPlay = net.ReadBool()
    LocalPlayer():SetNWBool("CanPlayEffect", canPlay)
end)

hook.Add("HUDPaint", "DrawManaBar", function()
    local ply = LocalPlayer()
    local maxMana = ply:GetNWInt("MaxMana", 0)
    if maxMana <= 0 then return end

    local mana = ply:GetNWInt("Mana", 0)
    local barWidth = 200
    local barHeight = 20
    local posX = ScrW() * 0.05
    local posY = ScrH() * 0.95 - barHeight

    draw.RoundedBox(4, posX, posY, barWidth, barHeight, Color(50, 50, 50, 200))
    local manaWidth = (mana / maxMana) * barWidth
    draw.RoundedBox(4, posX, posY, manaWidth, barHeight, Color(0, 0, 255, 255))
    draw.SimpleText("Mana: " .. mana .. "/" .. maxMana, "Default", posX + barWidth / 2, posY + barHeight / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

