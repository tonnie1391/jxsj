-- 文件名  : beautyhero_qizi.lua
-- 创建者  : zounan
-- 创建时间: 2010-10-19 09:37:30
-- 描述    : 
local tbGuanJunQiZhi = Npc:GetClass("beautyhero_qizhi");

function tbGuanJunQiZhi:OnDialog()
	BeautyHero:ChampionFlagNpc(me, him);
end
