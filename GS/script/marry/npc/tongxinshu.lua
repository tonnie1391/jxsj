-- FileName	: tongxinshu.lua
-- Author	: furuilei
-- Time		: 2010/1/23 23:03
-- Comment	: 结婚小游戏（同心树）

local tbNpc = Npc:GetClass("marry_tongxinshu");

--=============================================================

tbNpc.MAX_TIME_DIFFERENCE = 1;	-- 最大时间差1秒

-- 四个不同档次婚礼地图当中的npc模板
tbNpc.TB_NPCID = {6566, 6566, 6566, 6566};

-- 四个不同档次婚礼地图当中的npc刷出坐标
tbNpc.TB_POS = {
	[1] = {1743, 3171},
	[2] = {1591, 3185},
	[3] = {1675, 3103},
	[4] = {1563, 3251},
	};
	
-- 对应4个不同档次婚礼的奖励物品
tbNpc.TB_AWARD_ITEM = {
	[1] = {18, 1, 612, 1},
	[2] = {18, 1, 612, 1},
	[3] = {18, 1, 611, 1},
	[4] = {18, 1, 611, 1},
	};

tbNpc.MAX_RANGE = 50;
tbNpc.nSkillId = 307;
tbNpc.nExpRate = 20;

--=============================================================

function tbNpc:GameStart(nMapId)
	local nWeddingMapLevel = Marry:GetWeddingMapLevel(nMapId);
	local nNpcTemplateId = self.TB_NPCID[nWeddingMapLevel];
	local tbPos = self.TB_POS[nWeddingMapLevel];
	if (not nNpcTemplateId or not tbPos) then
		return 0;
	end
	
	KNpc.Add2(nNpcTemplateId, 120, -1, nMapId, unpack(tbPos));
end

function tbNpc:OnDialog()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId);
	if (not tbCoupleName or 2 ~= #tbCoupleName) then
		return 0;
	end
	
	if (me.szName ~= tbCoupleName[1] and me.szName ~= tbCoupleName[2]) then
		Dialog:Say("只有二位侠侣才可以执行此操作，你不是，叫他们来。");
		return 0;
	end
	
	self:PlayerClick(him.dwId, me.szName, me.nMapId);
end

-- 玩家点击事件（触发一个读条过程，读条完毕记录并判断时间差）
function tbNpc:PlayerClick(nNpcId, szPlayerName, nMapId)
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
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if (not pPlayer) then
		return 0;
	end
	Setting:SetGlobalObj(pPlayer);
	GeneralProcess:StartProcess("游戏中...", 5 * Env.GAME_FPS,
		{self.RecordClickTime, self, nNpcId, szPlayerName, nMapId}, nil, tbEvent);
	Setting:RestoreGlobalObj();
end

-- 记录下新人读条结束的时间
function tbNpc:RecordClickTime(nNpcId, szPlayerName, nMapId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local tbNpcData = pNpc.GetTempTable("Marry") or {};
	tbNpcData.tbClickTime = tbNpcData.tbClickTime or {};
	
	-- 如果记录的玩家数量超过2个，就出问题了，因为一场婚礼当中只能有一对新人
	if (Lib:CountTB(tbNpcData.tbClickTime) >= 2) then
		tbNpcData.tbClickTime = {};
	end
	local nCurTime = GetTime();
	tbNpcData.tbClickTime[szPlayerName] = nCurTime;
	
	if (Lib:CountTB(tbNpcData.tbClickTime) < 2) then
		return;
	end
	
	if (1 == self:JudgeTime(tbNpcData.tbClickTime)) then
		self:GameOver(nNpcId, nMapId);
		pNpc.Delete();
	else
		local szMsg = "同心果需要二位侠侣在同一秒之内摘取才算成功！";
		local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId) or {};
		for _, szName in pairs(tbCoupleName) do
			local pPlayer = KPlayer.GetPlayerByName(szName);
			if pPlayer then
				Dialog:SendBlackBoardMsg(pPlayer, szMsg);
			end
		end
	end
end

-- 检查时间，如果时间差小于一秒，就成功了，返回1
function tbNpc:JudgeTime(tbClickTime)
	if (Lib:CountTB(tbClickTime) ~= 2) then
		return 0;
	end
	
	local tbCoupleName = {};
	for szName, _ in pairs(tbClickTime) do
		table.insert(tbCoupleName, szName);
	end
	
	if (math.abs(tbClickTime[tbCoupleName[1]] - tbClickTime[tbCoupleName[2]]) > self.MAX_TIME_DIFFERENCE) then
		return 0;
	end
	
	tbClickTime = nil;
	
	return 1;
end

-- 游戏结束
function tbNpc:GameOver(nNpcId, nMapId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	
	local tbPlayer, nPlayerNum = KNpc.GetAroundPlayerList(nNpcId, self.MAX_RANGE);
	if (nPlayerNum > 0) then
		for _, pPlayer in pairs(tbPlayer) do
			pPlayer.AddExp(pPlayer.GetBaseAwardExp() * self.nExpRate);
		end
	end
	
	self:GetAward(nMapId);
	
	Marry.MiniGame:NextStep(nMapId);
end

-- 获得奖励物品
function tbNpc:GetAward(nMapId)
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId);
	local tbCouplePlayer = {};
	for i = 1, 2 do
		local pPlayer = KPlayer.GetPlayerByName(tbCoupleName[i]);
		table.insert(tbCouplePlayer, pPlayer);
	end
	
	local nWeddingLevel = Marry:GetWeddingLevel(nMapId);
	local tbAwardItemGDPL = self.TB_AWARD_ITEM[nWeddingLevel];
	if (not tbAwardItemGDPL) then
		return 0;
	end
	
	for _, pPlayer in pairs(tbCouplePlayer) do
		local pItem = pPlayer.AddItem(unpack(tbAwardItemGDPL));
		if (not pItem) then
			local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
			pItem =KItem.AddItemInPos(nMapId, nPosX, nPosY, tbAwardItemGDPL[1], tbAwardItemGDPL[2],
				tbAwardItemGDPL[3], tbAwardItemGDPL[4],0, 0, 0, nil, nil, 0, 0, pPlayer);
			pItem.SetOnlyBelongPick(1);
		end
	end
end
