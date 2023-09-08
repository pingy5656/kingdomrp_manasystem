if SERVER then
    AddCSLuaFile("kingdomrp/cl_init.lua")
    include("kingdomrp/sv_init.lua")
else
    include("kingdomrp/cl_init.lua")
end
