-- 文件名　：lantern_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-13 16:06:58
-- 功能    ：花灯

local tbItem = Item:GetClass("huadeng2011");

function tbItem:OnUse()
	local nRet, szErrorMsg = self:CheckCanUse();
	if nRet == 0 then
		Dialog:Say(szErrorMsg);
		return 0;
	end
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);
	local nPlayerId = nil;
	for i = 1, #tbPlayerList do
		local pPlayer = KPlayer.GetPlayerObjById(tbPlayerList[i]);
		if me.nId ~= tbPlayerList[i] then
			nPlayerId = tbPlayerList[i];	
			break;
		end
	end
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	}
	
	GeneralProcess:StartProcess("点燃灯笼...", 1 * Env.GAME_FPS, {self.OnClick, self, me.nId, nPlayerId, it.dwId}, nil, tbEvent);
	return 0;
end

function tbItem:OnClick(nPlayerId, nTeamPlayerId, nItemId)
	SpecialEvent.tbLantem_2011:UseItem(nPlayerId, nTeamPlayerId,  nItemId, GetTime());
end

--是否可以使用
function tbItem:CheckCanUse()	
	if me.nLevel < 60 then
		return 0, "等级不足60级。";
	end
	if me.nFaction <= 0 then
		return 0, "需要加入门派。";
	end
	if me.CountFreeBagCell() < 1 then
		return 0, "Hành trang không đủ chỗ trống1格，请清理下再来吧。";
	end
	if me.nTeamId <= 0 then
		return 0, "需要2个人组队才能使用。";
	end
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);
	if #tbPlayerList ~=  2 then
		return 0, "需要2个人组队才能使用。";
	end
	local pPlayer = nil;
	for i = 1, #tbPlayerList do
		pPlayer = KPlayer.GetPlayerObjById(tbPlayerList[i]);
		if me.nId ~= tbPlayerList[i] then
			if not pPlayer then
				return 0, "您的队友没在跟前。";
			end
			break;
		end
	end
	if me.IsFriendRelation(pPlayer.szName) ~= 1 then
		return 0, "只有好友才能一起放灯。";
	end
	local nMapId1, nX1,nY1 = me.GetWorldPos();
	local nMapId2, nX2,nY2 = pPlayer.GetWorldPos();
	if nMapId1 ~= nMapId2 or (nX1 - nX2) * (nX1 - nX2) + (nY1 - nY2) * (nY1 - nY2) > 100  then
		return 0, "您的队友没在跟前。";
	end	
	if nMapId1 ~= nMapId2 or (nX1 - nX2) * (nX1 - nX2) + (nY1 - nY2) * (nY1 - nY2) < 10  then
		return 0, "您跟队友站的太近了，分开点站。";
	end
	local szMapClass = GetMapType(me.nMapId) or "";
	if szMapClass ~= "village" and szMapClass ~= "city" then		
		return 0,"只能在城市、新手村使用。";
	end
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or pNpc.nKind == 4 then
			return 0, "在这会把<color=green>".. pNpc.szName.."<color>给挡住了，还是挪个地方吧。";
		end
	end
	return 1;
end

-- 烟花
-- 作用：右键点击使用，可放出美丽的烟花
local tbYanhua 		= Item:GetClass("2011_yanhua");
tbYanhua.nCastSkillId 	=  {1636, 1635};

function tbYanhua:OnUse()
	me.CastSkill(self.nCastSkillId[it.nLevel], 1, -1, me.GetNpc().nIndex);
	me.AddExp(math.floor(me.GetBaseAwardExp() * 60));
	return 1;
end

