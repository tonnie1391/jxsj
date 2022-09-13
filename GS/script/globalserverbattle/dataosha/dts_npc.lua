-- 文件名　：dts_npc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-13
-- 描  述  ：大逃杀高低场公用

DaTaoSha.tbNpc = DaTaoSha.tbNpc or {};
local tbNpc = DaTaoSha.tbNpc;
function tbNpc:JoinOne(nLevel)
	local tbPlayerList = {};	
	if me.nTeamId == 0 then			
		local nFlag, szReMsg = self:CheckCanAttend(me);
		if nFlag == 1 then
			Dialog:Say("您参与本次活动次数已达上限，无法继续参加。");
			return 0;		
		elseif nFlag == 2 then
			Dialog:Say("您今天已无挑战机会，还是明天再来吧！");
			return 0;
		elseif nFlag == 3 then
			Dialog:Say("您已无挑战资格，可使用月影之石在龙五太爷处购买寒武魂珠增加挑战资格！");
			return 0;
		end
		table.insert(tbPlayerList, me.nId);
	else
		Dialog:Say("单人报名需要退出队伍才可成功报名。");
		return;
	end
	GCExcute{"DaTaoSha:EnterReadyMap", tbPlayerList, nLevel};
end

function tbNpc:JoinTeam(nLevel)
	local tbPlayerList = {};	
	local nTimes = 0;
	local szMsg = "";	
	if me.nTeamId ~= 0 then
		if me.IsCaptain() == 0 then
			Dialog:Say("组队报名只有队长与我对话才行，你叫他来吧。");
			return 0;
		end
		local tbPlayerIdList = KTeam.GetTeamMemberList(me.nTeamId);		
		local nTeamMemberNum = #tbPlayerIdList;
		if nTeamMemberNum ~= DaTaoSha.PLAYER_TEAM_NUMBER then
			local szMsg = string.format("组队报名队伍中只能有<color=yellow>%s<color>名队员，调整下队伍再来吧。", DaTaoSha.PLAYER_TEAM_NUMBER);
			Dialog:Say(szMsg);
			return 0;
		end	
	       	local nMapId, nPosX, nPosY = me.GetWorldPos();
		for _, nPlayerId in pairs(tbPlayerIdList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if not pPlayer then
				Dialog:Say("你们队伍有人没来啊，我们还不能出发，等等他吧。");
				return 0;
			else
				local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
				local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
				if nMapId2 ~= nMapId or nDisSquare > 400 then
					Dialog:Say("您的所有队友必须在这附近。");
					return 0;
				end
				local nFlag, szReMsg = self:CheckCanAttend(pPlayer);
				if nFlag == 1 then
					Dialog:Say(string.format("你们队伍的<color=red>%s<color>参与本次活动次数已达上限，无法继续参加。", pPlayer.szName));
					return 0;
				elseif nFlag == 2 then
					Dialog:Say(string.format("你们队伍的<color=red>%s<color>今天已经没有挑战机会，还是明天再来吧！",  pPlayer.szName));
					return 0;
				elseif nFlag == 3 then
					Dialog:Say(string.format("你们队伍的<color=red>%s<color>已无挑战资格，可使用月影之石在龙五太爷处购买“寒武魂珠”增加挑战资 ô.",  pPlayer.szName));
					return 0;	
				end
			end	
			table.insert(tbPlayerList, pPlayer.nId);
		end
	else		
		Dialog:Say("组队报名需要加入队伍才可报名。");
		return 0;
	end	
	GCExcute{"DaTaoSha:EnterReadyMap", tbPlayerList, nLevel};
end

function tbNpc:CheckCanAttend(pPlayer)
	local nLimitTime = pPlayer.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_LIMIT_TIMES);	
	local nAllTimes = GetPlayerSportTask(pPlayer.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_ATTEND_ALLNUM) or 0;
	local nTickets = pPlayer.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_TICKETS);	
	local nGlobalBatch = GetPlayerSportTask(pPlayer.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_BATCH) or 0;
	if nGlobalBatch ~= DaTaoSha.nBatch then
		for i = 1, 9 do
			SetPlayerSportTask(pPlayer.nId,DaTaoSha.GBTSKG_DATAOSHA, i, 0);
		end
		SetPlayerSportTask(pPlayer.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_BATCH, DaTaoSha.nBatch);
		nAllTimes = 0;
	end
	if nAllTimes >= DaTaoSha.nMaxTime then
		return 1;
	end
	if nAllTimes >= nLimitTime then			
		return 2;
	end	
	if nAllTimes >= nTickets then
		return 3;
	end
	return 0;
end
