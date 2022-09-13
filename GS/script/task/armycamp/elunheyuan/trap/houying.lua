local tbMap	= Map:GetClass(2152);
-- 后营障碍，禁止到狩猎场
local tbTrap1 = tbMap:GetTrapClass("houying_zhangai1");

function tbTrap1:OnPlayer()
	me.NewWorld(me.nMapId, 1791, 3482)	;
end

-- 后营障碍，禁止到祭祀场
local tbTrap2 = tbMap:GetTrapClass("houying_zhangai2");

function tbTrap2:OnPlayer()
	me.NewWorld(me.nMapId, 1780, 3455)	;
end