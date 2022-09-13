----------------------------------------
-- 伏牛山庄宝箱
-- ZhangDeheng
-- 2008/10/28  10:41
----------------------------------------

local tbFnsTreasureBox = Npc:GetClass("fnsbaoxiang");

tbFnsTreasureBox.ALL_LOCK_COUNT 	= 5; 	--箱子的总层数
tbFnsTreasureBox.COST_TIME			= 100	--开箱需要的时间
tbFnsTreasureBox.TIRED_DURATION		= 10 * Env.GAME_FPS;	-- 劳累持续时间
tbFnsTreasureBox.TIRED_SKILLID		= 389;	--技能 用于控制时间间隔

-- 在开启每层宝箱时 掉落的物品及物品的数量
tbFnsTreasureBox.tbDrapItem = 
{
	{szDropItemFilePath = "setting\\npc\\droprate\\renwudiaoluo\\baoxiang_lv1.txt", nDrapItemCount = 8,},
	{szDropItemFilePath = "setting\\npc\\droprate\\renwudiaoluo\\baoxiang_lv2.txt", nDrapItemCount = 8,},
	{szDropItemFilePath = "setting\\npc\\droprate\\renwudiaoluo\\baoxiang_lv3.txt", nDrapItemCount = 8,},
	{szDropItemFilePath = "setting\\npc\\droprate\\renwudiaoluo\\baoxiang_lv4.txt", nDrapItemCount = 8,},
	{szDropItemFilePath = "setting\\npc\\droprate\\renwudiaoluo\\baoxiang_lv5.txt", nDrapItemCount = 8,},
}

-- 打开一层
function tbFnsTreasureBox:DecreaseLockLayer(pPlayer, pNpc)
	if not pPlayer or not pNpc then
		return;	
	end
	
	local tbNpcData = pNpc.GetTempTable("Task"); 
	assert(tbNpcData);
	
	if (5 <= tbNpcData.CUR_LOCK_COUNT) then
		return;
	end
	
	tbNpcData.CUR_LOCK_COUNT = tbNpcData.CUR_LOCK_COUNT + 1;
	KTeam.Msg2Team(pPlayer.nTeamId, pPlayer.szName.."打开了宝箱的第<color=yellow>" .. tbNpcData.CUR_LOCK_COUNT .. "<color>层锁！");
	
	if (tbNpcData.CUR_LOCK_COUNT <= 5) then
		local tbLayerInfo = self.tbDrapItem[tbNpcData.CUR_LOCK_COUNT];
		pPlayer.DropRateItem(tbLayerInfo.szDropItemFilePath, tbLayerInfo.nDrapItemCount, -1, -1, pNpc);
	end
	--最后一层
	if(tbNpcData.CUR_LOCK_COUNT == 5) then 
		KTeam.Msg2Team(pPlayer.nTeamId, "<color=yellow>宝箱已经被打开<color>！");
		tbNpcData.CUR_LOCK_COUNT = 0;
		pNpc.Delete();
	end
end

--开启宝箱
function tbFnsTreasureBox:OnCheckOpen(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc or pNpc.nIndex == 0) then
		return;
	end
	
	local tbNpcData = pNpc.GetTempTable("Task"); 
	assert(tbNpcData);
	
	local nCurLockLayer = tbNpcData.CUR_LOCK_COUNT;
	if (5 <= nCurLockLayer) then
		-- 已经全部打开
		return;
	end
	
	pPlayer.AddSkillState(self.TIRED_SKILLID, 1, 1, self.TIRED_DURATION);
	self:DecreaseLockLayer(pPlayer, pNpc);
end

--点击宝箱时对话
function tbFnsTreasureBox:OnDialog()
	
	local pNpc = KNpc.GetById(him.dwId);
	if (not pNpc or pNpc.nIndex == 0) then
		return;
	end

	local tbNpcData = him.GetTempTable("Task"); 
	--assert(tbNpcData.nOwnerPlayerId); 改为return zounan
	if not tbNpcData.nOwnerPlayerId then
		return;
	end
	
	local pOpener = KPlayer.GetPlayerObjById(tbNpcData.nOwnerPlayerId);
	--不存在
	if not pOpener then
		local szMsg = "你不能开启别人的宝箱！"
		Dialog:SendInfoBoardMsg(me, szMsg);		
		return;
	end;
	
	local nTeamId = pOpener.nTeamId;
	--是否组队
	if (me.nTeamId == 0) then
		local szMsg = "只有组队才能开启宝箱！"
		Dialog:SendInfoBoardMsg(me, szMsg);
		return;
	end
	--宝箱是否是所在队伍的宝箱
	if (me.nTeamId ~= nTeamId) then
		local szMsg = "只有<color=yellow>"..pOpener.szName.."<color>所在的队伍才能进开启此宝箱！"
		Dialog:SendInfoBoardMsg(me, szMsg);
		return;
	end
	--间隔时间是否到	
	local nRet = me.GetSkillState(self.TIRED_SKILLID);
	if (nRet ~=  -1) then
		Dialog:SendInfoBoardMsg(me, "<color=red>你太累了需要休息一会才能继续开启宝箱！<color>");
		return;
	end
	--打断开启事件
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
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
	--开启宝箱
	GeneralProcess:StartProcess("Đang mở rương", tbFnsTreasureBox.COST_TIME, {self.OnCheckOpen, self, me.nId, him.dwId}, {me.Msg, "Mở thất bại!"}, tbEvent);
end