
-- animal 模板

-- 从Npc模板库中找到此模板，如不存在会自动建立新模板并返回
local tbAnimal	= Npc:GetClass("animal");

-- 定义对话事件
function tbAnimal:OnDialog()
	me.Msg("Unbelievable!!!");	-- 战斗Npc，不会发生对话吧？
end;

-- 定义死亡事件
function tbAnimal:OnDeath(pNpcKiller)
	--local szMsg	= string.format("%s：%s，手下留情！", him.szName, pNpcKiller.szName);
	--Msg2SubWorld(szMsg);
end;

