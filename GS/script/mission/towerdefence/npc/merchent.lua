-- 文件名　：merchent.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-10 16:41:20
-- 描  述  ：蘑菇商店

local tbNpc = Npc:GetClass("td_merchent");

function tbNpc:OnDialog()
	me.OpenShop(169, 10);
end
