-- 文件名　：kingame_room3_npc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-30 10:53:55
-- 描述：独孤&东郭

local tbDugu = Npc:GetClass("kingame_dugu");

-- 血量触发
function tbDugu:OnLifePercentReduceHere(nLifePercent)
	local pNpc = him;
	local pGame = KinGame2:GetGameObjByMapId(pNpc.nMapId);
	if not pGame then
		return 0;
	end
	if nLifePercent == KinGame2.CHANGE_LIFE_PERCENT and pGame.tbRoom[4].nIsChangedBoss ~= 1 then
		pGame.tbRoom[4]:ChangeBoss();
	elseif nLifePercent == KinGame2.WARNING_LIFE_PERCENT and pGame.tbRoom[4].nIsWaring ~= 1 then
		pGame.tbRoom[4].nIsWaring = 1;
		pGame:AllBlackBoard("必须同时击杀东郭逸尘和独孤若兰");
	end
end


local tbDongguo = Npc:GetClass("kingame_dongguo");
-- 血量触发
function tbDongguo:OnLifePercentReduceHere(nLifePercent)
	local pNpc = him;
	local pGame = KinGame2:GetGameObjByMapId(pNpc.nMapId);
	if not pGame then
		return 0;
	end
	if nLifePercent == KinGame2.CHANGE_LIFE_PERCENT and pGame.tbRoom[4].nIsChangedBoss ~= 1 then
		pGame.tbRoom[4]:ChangeBoss();
	elseif nLifePercent == KinGame2.WARNING_LIFE_PERCENT and pGame.tbRoom[4].nIsWaring ~= 1 then
		pGame.tbRoom[4].nIsWaring = 1;
		pGame:AllBlackBoard("必须同时击杀东郭逸尘和独孤若兰");
	end
end