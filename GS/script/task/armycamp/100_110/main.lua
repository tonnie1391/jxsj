-----------------------------------------------------------
-- 文件名　：main.lua
-- 文件描述：军营副本-百蛮山
-- 创建者　：ZhangDeheng
-- 创建时间：2008-12-01 15:48:25
-----------------------------------------------------------

Require("\\script\\task\\armycamp\\campinstancing\\instancingmanager.lua");

local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancingBase(2); -- 2为此FB的Id

tbInstancing.szName = "Bách Man Sơn";
tbInstancing.szDesc = "备战，为了之后的胜利";

-- 山民 说的话
tbInstancing.tbShanMinText = {
	{"贵客要破了桃花瘴才可通过此处！", ""},
	{"此处尚不能通过！", "请前往碧蜈峰！"},
	{"此处尚不能通过！", "请由此前往神蛛峰！"},
	{"此处尚不能通过！", "请由此前往灵蝎峰！"},
	{"此处尚不能通过！", "请由此出前往天绝峰！"},
	{"尊客竟然能来到此地，真了不起！"},
	{"闯山的客人已经来了！"},
}

-- 桃花瘴瘴气位置
tbInstancing.tbZhangQiPos = {
	{1653, 3051},
	{1707, 3029},
	{1707, 3029},
}

-- 蛊王护法位置
tbInstancing.tbGuWangHuFaPos 	= {{1842, 2767}, {1883, 2862}, {1842, 2940}, {1761, 2900}, {1763, 2812}};
-- 心灯位置  传送
tbInstancing.tbXinDengInPos		= {{1822, 2818}, {1845, 2860}, {1824, 2882}, {1794, 2863}, {1798, 2837}, };
-- 心灯位置  出
tbInstancing.tbXinDengOutPos 	= {{1839, 2789}, {1866, 2869}, {1838, 2920}, {1777, 2891}, {1776, 2824}, };

-- 开启FB的时候调用
function tbInstancing:OnOpen()
	-- 开启FB计时器
	self.nNoPlayerDuration = 0; 
	self.nBreathTimerId = Timer:Register(Env.GAME_FPS, self.OnBreath, self);
	self.nCloseTimerId 	= Timer:Register(self.tbSetting.nInstancingExistTime*Env.GAME_FPS, self.OnClose, self);
	
	self.tbPlayerList = {}; -- 当前Player列表
	self.tbEnteredPlayerList = {}; -- 曾经进过的Player列表
	
	-- 用于NPC说话计数
	self.nCount	= nil;
	
	-- 留一半 出现的次数
	self.nLiuYiBanOutCount = 0;
	
	-- 桃花瘴
	local pNpc = KNpc.Add2(4163, 110, -1, self.nMapId, 1709, 3122);
	self.nTaoHuaLinZhiYin = pNpc.dwId; -- 桃花林指引
	-- 桃花瘴 禁制
	local pNpc = KNpc.Add2(4135, 110, -1, self.nMapId, 1655, 3023);
	self.nJinZhiTaoHuaLin = pNpc.dwId
	
	-- 山民
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1656, 3029);
	self.nTaoHuaZhengShanMin1 = pNpc.dwId;
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1661, 3023);
	self.nTaoHuaZhengShanMin2 = pNpc.dwId;
	
	-- 桃花瘴瘴气
	self.tbZhangQiId = {};
	local pNpc = KNpc.Add2(4141, 150, -1, self.nMapId, self.tbZhangQiPos[1][1], self.tbZhangQiPos[1][2]);
	self.tbZhangQiId[1] = pNpc.dwId;
	local pNpc = KNpc.Add2(4141, 150, -1, self.nMapId, self.tbZhangQiPos[2][1], self.tbZhangQiPos[2][2]);
	self.tbZhangQiId[2] = pNpc.dwId;
	local pNpc = KNpc.Add2(4141, 150, -1, self.nMapId, self.tbZhangQiPos[3][1], self.tbZhangQiPos[3][2]);
	self.tbZhangQiId[3] = pNpc.dwId;
	
	self.nTaoHuaZhangPass 	= 0; -- 桃花瘴是否可以通过
	
	-- 桃花使
	KNpc.Add2(4124, self.nNpcLevel, -1 , self.nMapId, 1671, 2910);	-- 对话桃花使
	
	local pNpc = KNpc.Add2(4135, 110, -1, self.nMapId, 1686, 2944); -- 禁制
	self.nJinZhiTaoHuaShi = pNpc.dwId;
	
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1676, 2931);
	self.nTaoHuaShiShanMin1 = pNpc.dwId;
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1681, 2926);
	self.nTaoHuaShiShanMin2 = pNpc.dwId;
	
	local nProb = MathRandom(100);  -- 10%的概率出现留一半

	if (nProb < 50) then  
		local pNpc = KNpc.Add2(4155, self.nNpcLevel, -1 , self.nMapId, 1667, 2907); -- 留一半
		pNpc.AddLifePObserver(99);
		pNpc.AddLifePObserver(80);
		self.nLiuYiBanOutCount = 1;
	end;

	self.nTaoHuaShiOut		= 0; 						-- 桃花使是否已经出现
	self.nTaoHuaShiPass 	= 0; 						-- 桃花使处是否可以通过
	
	-- 碧蜈峰
	local pNpc = KNpc.Add2(4125, 150, -1 , self.nMapId, 1781, 3073, 1); -- 蛊翁
	
	pNpc.AddLifePObserver(99);
	pNpc.AddLifePObserver(80);
	pNpc.AddLifePObserver(30);
	pNpc.AddLifePObserver(10);
	
	for i = 1, 14 do 
		pNpc.AddLifePObserver(i * 7);
	end;
	
	
	local pNpc = KNpc.Add2(4135, 110, -1, self.nMapId, 1828, 3044); -- 碧蜈峰 禁制
	self.nJinZhiBiWuFeng = pNpc.dwId;
	
	-- 山民
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1825, 3043);
	self.nBiWuFengShanMin1 = pNpc.dwId;
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1829, 3047);
	self.nBiWuFengShanMin2 = pNpc.dwId;
	
	local pNpc = KNpc.Add2(4164, 110, -1, self.nMapId, 1720, 2977); --碧蜈峰指引
	self.nBiWuFengZhiYin = pNpc.dwId;

	self.nDuXieYouChong		= 0; -- 杀死毒蝎幼虫的个数	
	self.nXieWangOut		= 0;  -- 碧蜈使是否出现
	self.nBiWuFengPass		= 0;  -- 碧蜈峰是否可以通过	
	
	-- 神蛛峰
	local pNpc = KNpc.Add2(4165, 110, -1, self.nMapId, 1877, 2981); -- 神蛛峰指引
	self.nShenZhuFengZhiYin = pNpc.dwId;
	-- 神蛛峰 禁制
	local pNpc = KNpc.Add2(4135, 110, -1, self.nMapId, 1951, 2847);
	self.nJinZhiShenZhuFeng = pNpc.dwId;

	-- 山民
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1949, 2852);
	self.nShenZhuFengShanMin1 = pNpc.dwId;
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1954, 2849);
	self.nShenZhuFengShanMin2 = pNpc.dwId;
	
	self.tbWenZhu			= {}; -- 用于记录每次刷出的毒蝎幼虫
	self.nPlayDrumTime 		= 0;  -- 记录可以敲鼓的时间是否到
	self.nPlayDrumCount		= 0; -- 敲鼓的次数
	self.nPlayGongCount		= 0; -- 敲锣的次数
	self.nWenZhu			= 0; -- 杀死毒蝎幼虫的个数	 

	self.nShenZhuFengPass 	= 0; -- 神蛛峰是否可以通过
	 
	-- 灵蝎峰
	KNpc.Add2(4134, self.nNpcLevel, -1 , self.nMapId, 1865, 2692); 	-- 铁公鸡
	local pNpc = KNpc.Add2(4136, self.nNpcLevel, -1 , self.nMapId, 1883, 2605);		-- 灵蝎使
	self.nLingXieShiId = pNpc.dwId;
	self.bLXSCastSkill = true; -- 记录灵蝎使是否继续释放技能
	
	pNpc.AddLifePObserver(99);
	pNpc.AddLifePObserver(50);
	pNpc.GetTempTable("Task").nDianMingTrigger = 0;
	pNpc.AddLifePObserver(30);
	pNpc.AddLifePObserver(10);
	-- 灵蝎峰 禁制
	local pNpc = KNpc.Add2(4135, 110, -1, self.nMapId, 1826, 2685);
	self.nJinZhiLingXieFeng = pNpc.dwId;
	
	-- 山民
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1831, 2684);
	self.nLingXieFengShanMin1 = pNpc.dwId;
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1825, 2678);
	self.nLingXieFengShanMin2 = pNpc.dwId;	

	if (self.nLiuYiBanOutCount ~= 0) then 
		local pNpc = KNpc.Add2(4155, self.nNpcLevel, -1, self.nMapId, 1886, 2608);
		pNpc.AddLifePObserver(20);
	end;
	
	local pNpc = KNpc.Add2(4166, 110, -1, self.nMapId, 1939, 2715); -- 灵蝎峰指引
	self.nLingXieFengZhiYin = pNpc.dwId;
	
	self.nLaoMenDurationTime 		= 0; 	-- 据下次可以开牢门的时间
	self.nLingXieFengPass			= 0; 	-- 碧蜈峰是否可以通过
	self.nTieGongJiLaoMen			= 0; 	-- 铁公鸡牢门是否打开
	self.nTieGongJiOut				= 0;	-- 战斗铁公鸡是否出现
	self.nDuWeiXieCount				= 0;	-- 杀死毒尾蝎的个数
	-- 天绝峰
	
	local pNpc = KNpc.Add2(4167, 110, -1, self.nMapId, 1772, 2742); -- 天绝峰指引
	self.nTianJueGongZhiYin = pNpc.dwId;

	-- 山民
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1646, 2955);
	self.nTianJueGongShanMin1 = pNpc.dwId;

	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1810, 2828);
	self.nTianJueGongShanMin2 = pNpc.dwId;
	local pNpc = KNpc.Add2(4154, 110, -1, self.nMapId, 1807, 2833);
	self.nTianJueGongShanMin3 = pNpc.dwId;
	
	-- 蛊王护法
	for i = 1, #self.tbGuWangHuFaPos do
		local pNpc = KNpc.Add2(4142, 110, -1 , self.nMapId, self.tbGuWangHuFaPos[i][1], self.tbGuWangHuFaPos[i][2]);
		pNpc.GetTempTable("Task").nId = i;
		pNpc.AddLifePObserver(99);
	end;

	-- 心灯 传送
	for i = 1, #self.tbXinDengInPos do
		local pNpc6 = KNpc.Add2(4137, 110, -1 , self.nMapId, self.tbXinDengInPos[i][1], self.tbXinDengInPos[i][2]);
		pNpc6.GetTempTable("Task").nId = i;
	end;
	-- 心灯 出
	for i = 1, #self.tbXinDengOutPos do
		local pNpc6 = KNpc.Add2(4138, 110, -1 , self.nMapId, self.tbXinDengOutPos[i][1], self.tbXinDengOutPos[i][2]);
		pNpc6.GetTempTable("Task").nId = i;
	end;
	
	-- 长生灯出现的顺序
	self.tbChangShengDeng = {1, 2, 3, 4, 5,};
	Lib:SmashTable(self.tbChangShengDeng);	-- 长生灯的顺序	
	
	self.nGuWangLife99				= 0; -- 记录开始的时候话是否说过
	self.nGuWangChange75			= 0; -- 蛊王转变成别的NPC 75%
	self.nGuWangChange50			= 0; -- 蛊王转变成别的NPC 50%	
	self.nGuShenOut					= 0; -- 蛊神是否出现
	self.nChangShengDengCount		= 0; -- 长生灯已经出现的个数
	self.nOpenChangShengDeng		= 0; -- 已经开启的个数
	
	-- 忘忧谷
	KNpc.Add2(4144, self.nNpcLevel, -1, self.nMapId, 1841, 2990);
	self.nHuoPengChenOut			= 0; -- 火蓬春是否出现
	
	-- 风雪鸿飞
	local pNpc = KNpc.Add2(4148, self.nNpcLevel, -1, self.nMapId, 1894, 2924, 1);
	pNpc.AddLifePObserver(99);
	pNpc.AddLifePObserver(90);
	pNpc.AddLifePObserver(70);
	pNpc.AddLifePObserver(50);
	pNpc.AddLifePObserver(30);
	
	local pNpc = KNpc.Add2(4146, self.nNpcLevel, -1, self.nMapId, 1910, 2838, 1); -- 火眼猊
	
	self.szOpenTime = GetLocalDate("%Y-%m-%d %H:%M:%S");
end


function tbInstancing:OnBreath()
	if (self.nPlayerCount == 0) then
		self.nNoPlayerDuration = self.nNoPlayerDuration + 1;
	elseif (nNoPlayerDuration ~= 0) then
		self.nNoPlayerDuration = 0;
	end
	
	if (self.nNoPlayerDuration >= self.tbSetting.nNoPlayerDuration) then
		self:OnClose();
		return 0;
	end
	
	if (not self.nCurSec) then
		self.nCurSec = 1;
	else
		self.nCurSec = self.nCurSec + 1;
	end
	
	if (self.nCurSec % 600 == 0) then
		Task.tbArmyCampInstancingManager:Tip2MapPlayer(self.nMapId, "Thời gian đóng "..self.tbSetting.szName.." còn lại "..math.floor((self.tbSetting.nInstancingExistTime-self.nCurSec)/60).." phút");
	end
	-- 指引的人每10秒说一次话
	if ((self.nCurSec - 1) % 5 == 0) then
		self:NpcTimerSay(self.nTaoHuaLinZhiYin, "前路危险，请跟我来！");
		self:NpcTimerSay(self.nBiWuFengZhiYin, "侠士请留步！");
		self:NpcTimerSay(self.nShenZhuFengZhiYin, "莫前行，前面有埋伏！");
		self:NpcTimerSay(self.nLingXieFengZhiYin, "请暂缓尊步！");
		self:NpcTimerSay(self.nTianJueGongZhiYin, "请移驾一谈！");
	end;
	
	-- 山名说话 每5秒一次
	if (self.nCurSec % 5 == 0) then
		-- 桃花瘴 山民
		self:NpcTimerSayWithCondition(self.nTaoHuaZhengShanMin1, self.nTaoHuaZhangPass, self.tbShanMinText[1][1], self.tbShanMinText[1][2]);
		self:NpcTimerSayWithCondition(self.nTaoHuaZhengShanMin2, self.nTaoHuaZhangPass, self.tbShanMinText[1][1], self.tbShanMinText[1][2]);
		-- 桃花使 山民
		self:NpcTimerSayWithCondition(self.nTaoHuaShiShanMin1, self.nTaoHuaShiPass, self.tbShanMinText[2][1], self.tbShanMinText[2][2]);
		self:NpcTimerSayWithCondition(self.nTaoHuaShiShanMin2, self.nTaoHuaShiPass, self.tbShanMinText[2][1], self.tbShanMinText[2][2]);
		-- 碧蜈峰 山民
		self:NpcTimerSayWithCondition(self.nBiWuFengShanMin1, self.nBiWuFengPass, self.tbShanMinText[3][1], self.tbShanMinText[3][2]);
		self:NpcTimerSayWithCondition(self.nBiWuFengShanMin2, self.nBiWuFengPass, self.tbShanMinText[3][1], self.tbShanMinText[3][2]);
		-- 神蛛峰 山民
		self:NpcTimerSayWithCondition(self.nShenZhuFengShanMin1, self.nShenZhuFengPass, self.tbShanMinText[4][1], self.tbShanMinText[4][2]);
		self:NpcTimerSayWithCondition(self.nShenZhuFengShanMin2, self.nShenZhuFengPass, self.tbShanMinText[4][1], self.tbShanMinText[4][2]);
		-- 灵蝎峰 山民
		self:NpcTimerSayWithCondition(self.nLingXieFengShanMin1, self.nLingXieFengPass, self.tbShanMinText[5][1], self.tbShanMinText[5][2]);
		self:NpcTimerSayWithCondition(self.nLingXieFengShanMin2, self.nLingXieFengPass, self.tbShanMinText[5][1], self.tbShanMinText[5][2]);
		-- 天绝峰 山民
		self:NpcTimerSay(self.nTianJueGongShanMin1, self.tbShanMinText[6][1]);
		
		self:NpcTimerSay(self.nTianJueGongShanMin2, self.tbShanMinText[7][1]);
		self:NpcTimerSay(self.nTianJueGongShanMin3, self.tbShanMinText[7][1]);

	end;	
	-- 牢门计时
	if (self.nLaoMenDurationTime ~= 0) then
		self.nLaoMenDurationTime = self.nLaoMenDurationTime - 1;
	end;
	-- 敲锣计时
	if (self.nPlayDrumTime > 0) then
		self.nPlayDrumTime = self.nPlayDrumTime - 1;
	end;
	 
	-- 灵蝎使每三分钟释放一次金钟罩
	if (self.nLingXieShiId and self.bLXSCastSkill and (self.nCurSec - 1) % 300 == 0) then
		local pNpc = KNpc.GetById(self.nLingXieShiId);
		if (not pNpc) then
			return;
		end;
		pNpc.CastSkill(999, 10, -1, pNpc.nIndex);
	end;
end

-- NPC说一句话
function tbInstancing:NpcTimerSay(nNpcId, szMsg)

	if (nNpcId) then
		local pNpc = KNpc.GetById(nNpcId);
		assert(pNpc);
		
		pNpc.SendChat(szMsg);
	end;
end;

-- NPC按条件说话
function tbInstancing:NpcTimerSayWithCondition(nNpcId, nCondition, szMsg1, szMsg2)
	if (nNpcId) then
		local pNpc = KNpc.GetById(nNpcId);
		assert(pNpc);
		if (nCondition == 0) then
			pNpc.SendChat(szMsg1);
		else
			pNpc.SendChat(szMsg2);
		end;
	end;
end;
-- NPC说话
function tbInstancing:NpcSay(nNpcId, tbText, nForbidChat)
	-- 某个NPC正在说话         -- 不能同时说话
	if (self.nCount) then
		return;
	end;

	if (not nNpcId or not tbText) then
		return;
	end;

	self.nNpcSayTimerId 	= Timer:Register(Env.GAME_FPS * 2, self.OnBreathDialog, self, nNpcId, tbText, nForbidChat);
	self.nCount				= 0;
end;

-- 
function tbInstancing:OnBreathDialog(nNpcId, tbText, nForbidChat)
	assert(nNpcId and tbText);
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		self.nNpcSayTimerId = nil;
		--Timer:Close(self.nNpcSayTimerId);
		self.nCount = nil;
		return 0;
	end;
	
	self.nCount = self.nCount + 1;
	-- 说完话，关闭计时器	
	if (self.nCount  > #tbText) then
		--Timer:Close(self.nNpcSayTimerId);
		self.nCount = nil;
		self.nNpcSayTimerId = nil;
		local tbSayOver = pNpc.GetTempTable("Task").tbSayOver;
		if (tbSayOver) then
			Lib:CallBack(tbSayOver);
			tbSayOver = nil;
		end;
		return 0;
	end;
	if not nForbidChat or nForbidChat ~= 1 then
		pNpc.SendChat(tbText[self.nCount]);
	end

	local tbPlayList, nCount = KPlayer.GetMapPlayer(self.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(tbText[self.nCount], pNpc.szName);
	end;		
end;

-- 护送NPC
function tbInstancing:Escort(nNpcId, nPlayerId, tbTrack, nActiveFight, bPassiveFight)
	assert(nNpcId and nPlayerId);
	local pNpc = KNpc.GetById(nNpcId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pNpc or not pPlayer then
		return 0;
	end
	--assert(pNpc and pPlayer);
	
	if (not nActiveFight) then
		nActiveFight = 0;
	end;
	if (not bPassiveFight) then
		bPassiveFight = 0;
	end;
	
	pNpc.SetCurCamp(0);
	pNpc.RestoreLife();
	pNpc.AI_ClearPath();
	for _,Pos in ipairs(tbTrack) do
		if (Pos[1] and Pos[2]) then
			pNpc.AI_AddMovePos(tonumber(Pos[1])*32, tonumber(Pos[2])*32)
		end
	end;
	pNpc.SetNpcAI(9, nActiveFight, bPassiveFight, -1, 25, 25, 25, 0, 0, 0, pPlayer.GetNpc().nIndex);	
end; 

-- FB关闭时调用
function tbInstancing:OnClose()
	for nPlayerId, tbPlayerData in pairs(self.tbPlayerList) do
		self:KickPlayer(nPlayerId, 1, "副本时间结束，您被传出了副本【百蛮山】");
	end
	
	Task.tbArmyCampInstancingManager:CloseMap(self.nMapId);
	Timer:Close(self.nBreathTimerId);
	Timer:Close(self.nCloseTimerId);
	ClearMapNpc(self.nMapId, 0);
	return 0;
end


-- 当一个玩家申请进入
function tbInstancing:OnPlayerAskEnter(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (self.nPlayerCount >= self.tbSetting.nMaxPlayer) then
		Dialog:SendInfoBoardMsg(pPlayer, "副本人数已满，您暂时无法进入。");
		return;
	end
	--加载任务
	local nHaveTask = 0;
	for _, nTaskId in ipairs(self.tbSetting.tbHaveTask) do
		if (Task:HaveTask(pPlayer, nTaskId) == 1) then
			nHaveTask = 1;
			break;
		end
	end
	if nHaveTask == 0 then
		if (pPlayer.GetTask(self.tbSetting.nJuQingTaskLimit_W.nTaskGroup, self.tbSetting.nJuQingTaskLimit_W.nTaskId) < self.tbSetting.nJuQingTaskLimit_W.nLimitValue) then
			local tbResult = Task:DoAccept(self.tbSetting.tbJuqingTask.nTaskId, self.tbSetting.tbJuqingTask.nReferId);
			if not tbResult then
				Dbg:WriteLog("armycamp", "accept haiwang juqing failure");
			end
		elseif (pPlayer.GetTask(self.tbSetting.nDailyTaskLimit_W.nTaskGroup, self.tbSetting.nDailyTaskLimit_W.nTaskId) < self.tbSetting.nDailyTaskLimit_W.nLimitValue) then
			local tbResult = Task:DoAccept(self.tbSetting.tbRichangTask.nTaskId, self.tbSetting.tbRichangTask.nReferId);
			if not tbResult then
				Dbg:WriteLog("armycamp", "accept haiwang richang failure");
			end
		else
			Dbg:WriteLog("armycamp", "accept haiwang failure");
		end
	end
	pPlayer.NewWorld(self.nMapId, unpack(self.tbSetting.tbRevivePos));
	pPlayer.SetFightState(0);
	self:OnPlayerEnter(pPlayer.nId);
	
	-- 成就，参加百蛮山
	Achievement:FinishAchievement(pPlayer, 237);
end

-- 当一个玩家进入后
function tbInstancing:OnPlayerEnter(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	self.nPlayerCount = self.nPlayerCount + 1;
	assert(self.nPlayerCount <= self.tbSetting.nMaxPlayer);
	-- 第一次进入当前副本
	if (not self.tbEnteredPlayerList[nPlayerId]) then
		--local nTimes = pPlayer.GetTask(self.tbSetting.nInstancingEnterLimit_D.nTaskGroup, self.tbSetting.nInstancingEnterLimit_D.nTaskId);
		--pPlayer.SetTask(self.tbSetting.nInstancingEnterLimit_D.nTaskGroup, self.tbSetting.nInstancingEnterLimit_D.nTaskId, nTimes + 1, 1);
		local nTimes = pPlayer.GetTask(self.tbSetting.nInstancingRemainEnterTimes.nTaskGroup, self.tbSetting.nInstancingRemainEnterTimes.nTaskId);
		pPlayer.SetTask(self.tbSetting.nInstancingRemainEnterTimes.nTaskGroup, self.tbSetting.nInstancingRemainEnterTimes.nTaskId, nTimes - 1, 1);
		self.tbEnteredPlayerList[nPlayerId] = 1;
		pPlayer.SetTask(1024, 61, 0); -- 重置任务变量
		
		--参加军营累积次数
		local nTimes = pPlayer.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_ARMY);
		pPlayer.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_ARMY, nTimes + 1);
				
		-- 记录玩家参加军营副本的次数
		Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_ARMYCAMP, 1);
	end
	
	self.tbPlayerList[nPlayerId] = {};
	
	-- 对此玩家注册一些事件
	Setting:SetGlobalObj(pPlayer, him, it);
	local nDeathEventId = PlayerEvent:Register("OnDeath", self.OnPlayerDeath, self);
	self.tbPlayerList[nPlayerId].nDeathEventId = nDeathEventId;
	local nLogoutEventId = PlayerEvent:Register("OnLogout", self.OnPlayerLogout, self);
	self.tbPlayerList[nPlayerId].nLogoutEventId = nLogoutEventId;
	local nLeaveMapEventId = PlayerEvent:Register("OnLeaveMap", self.OnPlayerLeaveMap, self);
	self.tbPlayerList[nPlayerId].nLeaveMapEventId = nLeaveMapEventId;
	Setting:RestoreGlobalObj();
	local nRevMapId, nRevPointId = pPlayer.GetRevivePos();
	self.tbPlayerList[nPlayerId].tbOldRev = {nRevMapId, nRevPointId};
	pPlayer.SetTmpDeathPos(self.nMapId, unpack(self.tbSetting.tbRevivePos));
	pPlayer.SetLogoutRV(1);
	Task.tbArmyCampInstancingManager:ShowTip(pPlayer, "Đội của "..self.szOpenerName.." tại "..self.szRegisterMapName.." đã mở "..self.tbSetting.szName .. ".", 20);
	
	-- 计时面板
	if (not self.nCurSec) then -- 在报名的一秒钟以内进入副本，self.nCurSec还没经过OnBreath生成，为nil 则在此处生成
		self.nCurSec = 0;
	end;
	Dialog:SetTimerPanel(pPlayer, "<color=Gold>Phó bản Quân Doanh<color>\n<color=White>Thời gian kết thúc phó bản: <color>", (self.tbSetting.nInstancingExistTime-self.nCurSec));
	Task.tbArmyCampInstancingManager.StatLog:WriteLog(1, 1, pPlayer);
	
end

-- 踢出一个玩家
function tbInstancing:KickPlayer(nPlayerId, bPassive, szDesc)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	if (not self.tbPlayerList[nPlayerId]) then
		return;
	end
	
	Dialog:CloseTimerPanel(pPlayer);
	
	self.nPlayerCount = self.nPlayerCount -1;
	assert(self.nPlayerCount >= 0);
	assert(self.tbPlayerList[nPlayerId] and self.tbPlayerList[nPlayerId].nDeathEventId and self.tbPlayerList[nPlayerId].nLogoutEventId and self.tbPlayerList[nPlayerId].nLeaveMapEventId);
	Setting:SetGlobalObj(pPlayer, him, it);
	PlayerEvent:UnRegister("OnDeath", self.tbPlayerList[nPlayerId].nDeathEventId);
	PlayerEvent:UnRegister("OnLogout", self.tbPlayerList[nPlayerId].nLogoutEventId);
	PlayerEvent:UnRegister("OnLeaveMap", self.tbPlayerList[nPlayerId].nLeaveMapEventId);
	Setting:RestoreGlobalObj();
	pPlayer.SetRevivePos(unpack(self.tbPlayerList[nPlayerId].tbOldRev));
	self.tbPlayerList[nPlayerId] = nil;
	if (pPlayer.IsDead() == 1) then
		pPlayer.ReviveImmediately(0);
	end
	
	-- 删除指定道具
	self:RemoveTaskItem(pPlayer, {20, 1, 623, 1, 0, 0});
	self:RemoveTaskItem(pPlayer, {20, 1, 624, 1, 0, 0});
	self:RemoveTaskItem(pPlayer, {20, 1, 625, 1, 0, 0});
	self:RemoveTaskItem(pPlayer, {20, 1, 626, 1, 0, 0});

	if (bPassive) then
		local nMapId, nReviveId, nMapX, nMapY = pPlayer.GetLoginRevivePos();
		pPlayer.NewWorld(nMapId, nMapX/32, nMapY/32);
	end
	
	pPlayer.SetLogoutRV(0);
	
	if (szDesc) then
		Task.tbArmyCampInstancingManager:Warring(pPlayer, szDesc);
	end
end

function tbInstancing:RemoveTaskItem(pPlayer, tbItemId)	
	local nDelCount = Task:GetItemCount(me, tbItemId);
	
	Task:DelItem(me, tbItemId, nDelCount);
end

-- 当玩家下线时候调用
function tbInstancing:OnPlayerLogout()
	self:KickPlayer(me.nId, 1);
end

-- 玩家死亡
function tbInstancing:OnPlayerDeath()
	me.ReviveImmediately(0);
	me.SetFightState(0);
end

-- 玩家离开地图
function tbInstancing:OnPlayerLeaveMap()
	self:KickPlayer(me.nId);
end

