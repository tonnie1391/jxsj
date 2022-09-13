-- 文件名　：fuben.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-7
-- 描  述  ：

-- 副本道具脚本

local tbFuBen= Item:GetClass("fuben");

function tbFuBen:OnUse()					-- 点击申请fb
	--tbFuBen[it.dwId] = tbFuBen[it.dwId] or {};
	--tbFuBen[it.dwId].OnUsed = tbFuBen[it.dwId].OnUsed or 0;
	--tbFuBen[it.dwId].IsOpen = tbFuBen[it.dwId].IsOpen or 0;
	local nItemGDPL = string.format("%s,%s,%s,%s", it.nGenre, it.nDetail, it.nParticular,it.nLevel);	
	if not CFuben.FUBEN_EX[nItemGDPL] then
		me.Msg("物品已经过期了！");
		return;
	end
	local nType = CFuben.FUBEN_EX[nItemGDPL][1];
	local nId = CFuben.FUBEN_EX[nItemGDPL][2];
	local szInfo = string.format("神秘的<color=yellow>%s<color>，或许能解开这个物品的谜底。", CFuben.FUBEN[nType][nId].szName);
	local tbOpt = {};	
	--if it.GetGenInfo(1) == 0 then
	tbOpt ={
			{"申请前往这个神秘的地方",	self.Apply, self, it.dwId, me.nId, nType, nId},
			{"和队友一起进入", self.RequestFrend, self, me.nId, it.dwId},
			{"Đóng lại"},
		};	
	--end
	--elseif it.GetGenInfo(2) == 0 then
	--	tbOpt ={
	--				{"开启征程",	self.OnOpen, self, it.dwId},
	--				{"Đóng lại"},
	--			};
	--	szInfo = string.format("开启<color=yellow>  %s  <color>？", CFuben.FUBEN[nType][nId].szName);	
	--else
	--	tbOpt ={
	--			--{"进入副本",	self.OnEnter, self, me.nId},
	--			{"和队友一起进入", self.RequestFrend, self, me.nId, it.dwId},
	--			{"Đóng lại"},
	--		};
	--	szInfo = string.format("进入<color=yellow> %s <color>？", CFuben.FUBEN[nType][nId].szName);		
	--end	
	Dialog:Say(szInfo,tbOpt);
	return 0;
end

function tbFuBen:OnEnter(nId)
	CFuben:JoinGame(nId, nId);
end

function tbFuBen:Apply(nItemId, nPlayerId, nType, nId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pItem =  KItem.GetObjById(nItemId);
	if pItem then	
		if CFuben:ApplyFuBen(nItemId, pPlayer.nId) == 1 then	--初始化副本
			pItem.SetGenInfo(1, 1);			
			if CFuben.FUBEN[nType][nId].nFlagAuto == 1 then  --副本是否自动开启，设置一个物品属性
				--pItem.SetTimeOut(0, (GetTime() + self.FUBEN[nType][nId].nTotalTime ));				
				me.SetItemTimeout(pItem, CFuben.FUBEN[nType][nId].nTotalTime, 0);
				pItem.Sync();
		--		pItem.SetGenInfo(2, 1);
			end		
			return 0;
		end
	end
end

function tbFuBen:OnOpen(nId)
	local szMsg = "";
	local tbOpt ={{"取消"},};
	if not CFuben.FubenData[me.nId] then
		szMsg = "\n\n您没有申请副本！";
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local nTempMapId = CFuben.FubenData[me.nId][1];
	local nDyMapId = CFuben.FubenData[me.nId][2];
	if CFuben.tbMapList[nTempMapId][nDyMapId].IsOpen == 0 then
		CFuben.tbMapList[nTempMapId][nDyMapId].IsOpen = 1;
		CFuben:GameStart(me.nId, CFuben.FubenData[me.nId][2]);
		szMsg = "您成功开启副本！";
	else
		szMsg = "\n\n您的副本已经开启了！";
		Dialog:Say(szMsg, tbOpt);
	end
	--tbFuBen[nId].IsOpen = 1;
	local pItem = KItem.GetItemObj(nId);
	if pItem then
		pItem.Delete(me);
	end
	--todo考虑在这里做生成npc，然后从这里传出去
	return ;
end

function tbFuBen:RequestFrend(nPlayerId, nItemId)	
	local pItem =  KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local _ , nTime = pItem.GetTimeOut();
	if nTime == 0 then
		pPlayer.Msg("请用您申请的物品进入吧！");
		return 0;
	end
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
	if pPlayer.nTeamId == 0 then
		pPlayer.Msg("您没有队伍！");
		return 0;
	end
	local tbPlayerIdList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	if pPlayer.nId ~= tbPlayerIdList[1] then
		pPlayer.Msg("您不是队长不能带队友进入！");
		return 0;		
	end
	for _, nPlayerIdEx in ipairs(tbPlayerIdList) do
		local pPlayerEx = KPlayer.GetPlayerObjById(nPlayerIdEx);
		if not pPlayerEx then				
			Dialog:Say("你们队伍有人没来啊，我们还不能出发，等等他吧。");
			return 0;
		else
			local nMapId2, nPosX2, nPosY2 = pPlayerEx.GetWorldPos();
			local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
			if nMapId2 ~= nMapId or nDisSquare > 400 then
				Dialog:Say("您的所有队友必须在这附近。");
				return 0;				 
			end
		end
		if CFuben:IsSatisfy(nPlayerIdEx, nPlayerId) == 0 then			
			return 0;
		end
	end		
	for _, nPlayerIdEx in pairs(tbPlayerIdList) do
		CFuben:JoinGame(nPlayerIdEx, nPlayerId); 
	end			
	pItem.Delete(pPlayer);	
end
