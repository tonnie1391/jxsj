-- 文件名　：item_bianpao.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-28 14:10:10
-- 描  述  ：

Require("\\script\\event\\specialevent\\nianshouseige\\nianshousiege_def.lua");
SpecialEvent.NianShouSiege = SpecialEvent.NianShouSiege or {};
local tbNianShouSiege = SpecialEvent.NianShouSiege or {};

local tbItem	= Item:GetClass("chunjiebianpao");
function tbItem:OnUse()
	if tbNianShouSiege:CheckIsOpen() == 0 then
		return 0;
	end
	if me.nLevel < tbNianShouSiege.PLAYER_LEVEL_LIMIT or me.nFaction <= 0 then
		Dialog:SendInfoBoardMsg(me, "只有大于80级的非白名玩家才能使用！");
		me.Msg("只有大于80级的非白名玩家才能使用！");
		return 0;
	end
	if not tbNianShouSiege.nNianShouId then
		Dialog:SendInfoBoardMsg(me, "使用失败！请靠近年兽再使用！");
		me.Msg("使用失败！请靠近年兽再使用！");
		return 0;
	end
	local pNpc = KNpc.GetById(tbNianShouSiege.nNianShouId);
	if not pNpc then
		Dialog:SendInfoBoardMsg(me, "使用失败！请靠近年兽再使用！");
		me.Msg("使用失败！请靠近年兽再使用！");
		return 0;
	end
	local nIsNearBy = tbNianShouSiege:CheckIsNearby(me, pNpc, tbNianShouSiege.MAX_BIANPAO_USE_RANGE);
	if nIsNearBy == 0 then
		Dialog:SendInfoBoardMsg(me, "使用失败！请靠近年兽再使用！");
		me.Msg("使用失败！请靠近年兽再使用！");
		return 0;
	end
	local nRand = MathRandom(1,10);
	local nTimes = 0;
	for i = 1, nRand do
		if Npc:GetClass("nianshou_2011"):OnHit(me.nId, pNpc.dwId) == 0 then
			break;
		end
		nTimes = nTimes + 1;
	end
	if nTimes == 0 then
		Dialog:SendInfoBoardMsg(me, "使用失败！年兽暂时是无敌的");
		me.Msg("使用失败，年兽暂时是无敌的");
		return 0;
	end
	me.AddExp(math.floor(me.GetBaseAwardExp() / 5 * nTimes));
	local nBlood = nTimes * 100;
	local szMsg = "";
	if nTimes > 1 then
		szMsg = string.format("连响了<color=yellow>%s声<color>", nTimes);
	end
	me.Msg(string.format("鞭炮忽然噼里啪啦响起来，%s将年兽吓得掉了<color=yellow>%s<color>点血。",szMsg, nBlood));
	return 0;
end
