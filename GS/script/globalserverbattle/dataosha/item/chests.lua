-- 文件名　：chests.lua
-- 创建者　：jiazhenwei/zounan
-- 创建时间：2009-10-23
-- 描  述  ：
local tbNpc = Npc:GetClass("dataosha_box");
tbNpc.DELAY_TIME = 1;
function tbNpc:OnDialog()
	local tbGroup =  him.GetTempTable("Npc").tbGroup;
	if not tbGroup then
		return;
	end	
	local nCanOpen = 0;
	for _, nId in ipairs(tbGroup) do
		if me.nId == nId then
			nCanOpen = 1;
			break;
		end
	 end
	 if nCanOpen == 0 then
	 	me.Msg("Không thể mở rương này!");
	 	return;
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
	GeneralProcess:StartProcess("Đang mở..." , self.DELAY_TIME* Env.GAME_FPS ,  {self.OnOpen , self,him.dwId} , nil , tbEvent);	
end

function tbNpc:OnOpen(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local tbPlayerIdList = KTeam.GetTeamMemberList(me.nTeamId);
	if not tbPlayerIdList then
		return;
	end
	for _, nPlayerId in pairs(tbPlayerIdList) do			
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if  pPlayer then		
			if  pPlayer.CountFreeBagCell() < 3 then
				local szMsg = string.format("Hành trang không đủ %s ô!", pPlayer.szName);
				KTeam.Msg2Team(pPlayer.nTeamId, szMsg);
				return;
			end
		end
	end
	pNpc.Delete();
	local tbItemInfo ={};	
	tbItemInfo.bForceBind = 1;
	--玩家包裹格子数目够不够的判定

	for _, nPlayerId in pairs(tbPlayerIdList) do			
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if  pPlayer  then			
			local nRandomNum = MathRandom(1,3);
			local nMoneyRandom = MathRandom(1,5);
			local tbItem = DaTaoSha.RANDOM_ITEM[nRandomNum][1];
			pPlayer.AddStackItem(tbItem[1],tbItem[2],tbItem[3],tbItem[4], tbItemInfo, DaTaoSha.RANDOM_ITEM[nRandomNum][2]);
			if nMoneyRandom == 1 then
				--local nNum = me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_MONEY);
				--nNum = nNum + 5;
				--me.SetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_MONEY, nNum);				
				local nAddCount = pPlayer.AddStackItem(DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4], nil, 5);
				if nAddCount == 0 then
					pPlayer.Msg("Hành trang đã đầy, không thể nhận thên Hàn Vũ Thạch Phù.");
				end
			end
		end
	end
end
