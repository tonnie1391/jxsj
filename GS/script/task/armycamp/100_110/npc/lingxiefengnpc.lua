-----------------------------------------------------------
-- 文件名　：lingxiefengnpc.lua
-- 文件描述：碧蜈峰NPC脚本
-- 创建者　：ZhangDeheng
-- 创建时间：2008-11-27 09:19:00
-----------------------------------------------------------

-- 铁公鸡牢门
local tbLaoMen = Npc:GetClass("laomen");

function tbLaoMen:OnDialog()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nLaoMenDurationTime ~= 0) then
		me.Msg("Từ từ, đừng nóng vội!")
		return;
	end;
	
		local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
	-- 
	GeneralProcess:StartProcess("Đang mở...", 1 * Env.GAME_FPS, {self.Open, self, me.nId, him.dwId, tbInstancing}, {me.Msg, "Mở thất bại!"}, tbEvent);
end;

-- 打开牢门 成功率30%
function tbLaoMen:Open(nPlayerId, nNpcId, tbInstancing)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(nNpcId);
	assert(pPlayer);
	if (not pNpc) then
		return;
	end;
	
	-- 成功率30%
	local nSuccess = MathRandom(100);
	if (nSuccess < 85) then
		Task.tbArmyCampInstancingManager:ShowTip(pPlayer, "Thiết Môn đã mở!");
		tbInstancing.nTieGongJiLaoMen = 1;
		pNpc.Delete();
	else
		pPlayer.Msg("Mở thất bại!");
		tbInstancing.nLaoMenDurationTime = 5;
	end;
end;

-- 铁公鸡 对话
local tbTieGongJi = Npc:GetClass("tiegongji_dialog");
-- 需要的物品
tbTieGongJi.tbNeedItemList 	= { {20, 1, 626, 1, 10}, };
-- 铁公鸡的行走路线
tbTieGongJi.tbTrack			= { 
	{1870, 2694}, {1881, 2693}, {1890, 2681}, 
	{1900, 2675}, {1889, 2650}, {1871, 2650}, 
	{1866, 2638}, {1874, 2619}, {1882, 2606} 
};

tbTieGongJi.tbText = {"啊！天哪！天哪！这是谁？", "是谁带来这么可恶的家伙？"};

function tbTieGongJi:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.nTieGongJiOut == 1) then
		return;
	end;
	
	Dialog:Say("Đưa ta 10 Đuôi Bò Cạp, ta sẽ giúp ngươi diệt trừ Linh Hạt Sứ",
		{
			{"Ta có đây", self.Give, self, tbInstancing, me.nId, him.dwId},
			{"Kết thúc đối thoại"}
		});
end;

function tbTieGongJi:Give(tbInstancing, nPlayerId, nNpcId)
	Task:OnGift("Hãy đặt vào 10 Đuôi Bò Cạp", self.tbNeedItemList, {self.Pass, self, tbInstancing, nPlayerId, nNpcId}, nil, {self.CheckRepeat, self, tbInstancing}, true);
end;

function tbTieGongJi:CheckRepeat(tbInstancing)
	if (tbInstancing.nTieGongJiOut == 1) then
		return 0;
	end	
	return 1; 
end

function tbTieGongJi:Pass(tbInstancing, nPlayerId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end;
	local nSubWorld, nPosX, nPosY	= him.GetWorldPos();
	pNpc.Delete();
	
	if (tbInstancing.nTieGongJiLaoOut == 1) then
		return;
	end;
	local pFightNpc = KNpc.Add2(4170, 100, -1, nSubWorld, nPosX, nPosY);
	tbInstancing.nTieGongJiOut = 1;
	tbInstancing.dwFightGongJiId = pFightNpc.dwId;
	
	tbInstancing:Escort(pFightNpc.dwId, nPlayerId, self.tbTrack, 50, 1);
	pFightNpc.GetTempTable("Npc").tbOnArrive = {self.OnArrive, self, pFightNpc.dwId, me.nId};
	
	tbInstancing.bLXSCastSkill = false;
	
	if (tbInstancing.nLingXieShiId) then
		local pNpc = KNpc.GetById(tbInstancing.nLingXieShiId);
		if (not pNpc) then
			return;
		end;
		pNpc.RemoveSkillState(999);
	end;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg("喔喔喔！！！", pFightNpc.szName);
		Task.tbArmyCampInstancingManager:ShowTip(teammate, "Tiếng kêu của Thiết Trảo Kê phá tan hộ thuẫn của Linh Hạt Sứ");
	end;
end;

function tbTieGongJi:OnArrive(dwNpcId, nPlayerId)

	assert(dwNpcId and nPlayerId);
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then  --加上保护 zounan
		return;
	end
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);

	local tbNpc = Npc:GetClass("lingxieshi");
	tbInstancing:NpcSay(tbInstancing.nLingXieShiId, self.tbText);
end;

-- 灵蝎使
local tbLingXieShi = Npc:GetClass("lingxieshi");

tbLingXieShi.tbText = {
	[99] = "这一关可没那么好过！",
	[50] = {"快把它带走，快点带走！", "我求求你们啦！快带走它！"},
	[30] = "可恶的家伙，我不放过你们！",
	[10] = "看我的蛊影分身大法！",
	[0]  = "你们不得好死！",
}
-- 毒蝎ID
tbLingXieShi.tbDuWeiXieId = 4128;
-- 毒蝎位置
tbLingXieShi.tbPos = {
	{1880, 2601}, {1883, 2601}, {1885, 2602}, {1886, 2604},
	{1886, 2607}, {1884, 2609}, {1881, 2609}, {1879, 2605},
}
tbLingXieShi.nActiveRunCD = 8;
tbLingXieShi.tbDropItem = {"setting\\npc\\droprate\\droprate010_shouling.txt", 6};

function tbLingXieShi:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nJinZhiLingXieFeng) then
		local pNpc_x = KNpc.GetById(tbInstancing.nJinZhiLingXieFeng);
		if (pNpc_x) then
			pNpc_x.Delete();
		end;
	end;
	
	
	
	tbInstancing.nLingXieFengPass = 1;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	
	-- 掉落
	local nId = 0;
	if (pNpc and pNpc.GetPlayer()) then
		nId = pNpc.GetPlayer().nId;
	else
		nId = tbPlayList[1].nId;
	end;
	him.DropRateItem(self.tbDropItem[1], self.tbDropItem[2], -1, -1, nId);
	
	for _, teammate in ipairs(tbPlayList) do
		Task.tbArmyCampInstancingManager:ShowTip(teammate, "Đã có thể đến Thiên Tuyệt Phong rồi!");
		teammate.RemoveSkillState(1936);
	end;
	if him.GetTempTable("Task").nActiveRunTimer then
		Timer:Close(him.GetTempTable("Task").nActiveRunTimer);
		him.GetTempTable("Task").nActiveRunTimer = nil;
	end
end;

function tbLingXieShi:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (nLifePercent == 50) then
		tbInstancing:NpcSay(him.dwId, self.tbText[nLifePercent]);
		him.GetTempTable("Task").tbSayOver = nil;
		if him.GetTempTable("Task").nDianMingTrigger ~= 0 then
			return;
		end
		him.GetTempTable("Task").nDianMingTrigger = 1;
		him.GetTempTable("Task").nActiveRunTimer = Timer:Register(1, self.ActiveRun, self, him.dwId);
		return;
	end;
	
	him.SendChat(self.tbText[nLifePercent]);
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(self.tbText[nLifePercent], him.szName);
	end;	
	
	if (nLifePercent == 10) then
		-- 毒蝎幼虫
		for i = 1, 8 do
			local pNpc = KNpc.Add2(self.tbDuWeiXieId, 100, -1, nSubWorld, self.tbPos[i][1], self.tbPos[i][2]);
			assert(pNpc);
			pNpc.GetTempTable("Task").nLingXieFengLifePresent = him.nCurLife;
		end;
		-- 删除公鸡
		if (tbInstancing.dwFightGongJiId) then
			local pGongJi = KNpc.GetById(tbInstancing.dwFightGongJiId);
			if (pGongJi) then
				pGongJi.Delete();
				tbInstancing.dwFightGongJiId = nil;
			end;
		end;
		-- 删除灵蝎使
		him.Delete();
	end;
end;

function tbLingXieShi:ActiveRun(nNpcId)	-- 积极奔跑
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbPlayerList = KNpc.GetAroundPlayerList(nNpcId, 30);
	if tbPlayerList then
		for _, pPlayer in pairs(tbPlayerList) do
			pPlayer.AddSkillState(1936,10,0,360,0,0,1);
		end
	end
	return self.nActiveRunCD * 18; -- 8秒钟之后再调
end

-- 毒尾蝎
local tbDuWeiXie = Npc:GetClass("duweixie");

function tbDuWeiXie:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	--assert(tbInstancing); 改成保护 zounan
	if not tbInstancing then
		Dbg:WriteLog("军营","毒尾蝎 死亡时 无副本",nSubWorld);
		return;
	end
			
	local tbNpcData = him.GetTempTable("Task");
	if (not tbNpcData or not tbNpcData.nLingXieFengLifePresent) then
		return; -- 
	end;
	
	tbInstancing.nDuWeiXieCount = tbInstancing.nDuWeiXieCount + 1;
	if (tbInstancing.nDuWeiXieCount > 8) then
		return;
	end;
	
	if (tbInstancing.nDuWeiXieCount == 8) then
		local pNpc = KNpc.Add2(4136, tbInstancing.nNpcLevel, -1 , tbInstancing.nMapId, 1883, 2605);
		assert(pNpc);
		
		local nReduct = pNpc.nMaxLife - tbNpcData.nLingXieFengLifePresent;
		pNpc.ReduceLife(nReduct);
	end;
end;

-- 灵蝎峰指引
local tbLingXieFengZhiYin = Npc:GetClass("lingxiefengzhiyin");

tbLingXieFengZhiYin.szText = "    能闯到此地，诸位果然是高手。不过前方灵蝎使所修与其他三使不同，请留神听我说。\n\n    灵蝎使所修蛊术可令其有如金钟，刀剑难伤。可惜再强的绝技也有罩门，破她蛊术的恰恰是最不起眼的雄鸡。\n\n    诸位可先暗中<color=red>从灵蝎峰的蝎子身上获得蝎尾20只，将其喂给我暗中喂养的铁嘴金鸡<color>，它自会带着你们大闹灵蝎峰。";

function tbLingXieFengZhiYin:OnDialog()
	local tbOpt = {{"Kết thúc đối thoại"}, };
	Dialog:Say(self.szText, tbOpt);
end;