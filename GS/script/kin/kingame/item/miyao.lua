
local tbItem = Item:GetClass("kingame_miyao")

function tbItem:OnUse()
	--持续120秒，有技能配置表决定
	local nMapIndex 		= SubWorldID2Idx(me.nMapId);
	local nMapTemplateId	= SubWorldIdx2MapCopy(nMapIndex);
	if KinGame.MAP_TEMPLATE_ID ~= nMapTemplateId then
		me.Msg("本地图禁止使用该物品。")
		return 0;
	end
	me.AddSkillState(764,1,0,1);
	Dialog:SendBlackBoardMsg(me, "喝下秘药后，你感觉到身体里有一股热气在串动。")
	return 1;
end
