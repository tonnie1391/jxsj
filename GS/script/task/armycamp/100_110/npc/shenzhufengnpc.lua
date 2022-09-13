-----------------------------------------------------------
-- 文件名　：shenzhufengnpc.lua
-- 文件描述：神蛛峰NPC脚本
-- 创建者　：ZhangDeheng
-- 创建时间：2008-11-26 20:39:28
-----------------------------------------------------------

-- 锣
local tbLuo = Npc:GetClass("luo");
-- 传送玩家的位置
tbLuo.tbPlayerPos = {1952, 2896};

tbLuo.tbPlayText = {"是谁胆敢妄动我的禁物！", "神蛛使"};

-- 刷出的幼虫的位置
tbLuo.tbZhiZhuYouChongPos = { {1952, 2885}, {1946, 2907}, {1942, 2897}, {1945, 2888}, {1959, 2906}, {1953, 2910}, {1959, 2888}, {1962, 2897},}
-- 敲锣
function tbLuo:OnDialog()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 可以敲鼓就不能再敲锣
	if (tbInstancing.nPlayDrumCount == 1) then
		return;
	end;
	-- 时间是否到
	if (tbInstancing.nPlayDrumTime ~= 0) then
		me.Msg("你还需等" .. tbInstancing.nPlayDrumTime .. "秒才可以继续敲锣");
		return;
	end;
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
		-- 播放音乐
	local szMsg 	= "setting\\audio\\obj\\ss034.wav"; 
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.CallClientScript({"PlaySound", szMsg, 3});
	end;
	GeneralProcess:StartProcess("敲锣", 1 * Env.GAME_FPS, {self.OnPlay, self, me.nId, tbInstancing, nSubWorld}, {self.BreakPlay, self, me.nId, tbPlayList, szSound, "Mở gián đoạn!"}, tbEvent);
end;

function tbLuo:BreakPlay(nPlayerId, tbPlayList, szSound, szMsg)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	pPlayer.Msg(szMsg);
	for _, teammate in ipairs(tbPlayList) do
		teammate.CallClientScript({"StopSound", szSound});
	end;	
end;

function tbLuo:OnPlay(nPlayerId, tbInstancing, nSubWorld)
	tbInstancing.nPlayDrumTime = 10;
	
	-- 传送
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(self.tbPlayText[1], self.tbPlayText[2]);
		teammate.NewWorld(tbInstancing.nMapId, self.tbPlayerPos[1], self.tbPlayerPos[2]);
		teammate.SetFightState(1);
	end;
	-- 删除幼虫
	for i = 1, #tbInstancing.tbWenZhu do
		if (tbInstancing.tbWenZhu[i]) then
			local pNpc = KNpc.GetById(tbInstancing.tbWenZhu[i]);
			if (pNpc) then
				pNpc.Delete();
			end;
		end;
	end;
	tbInstancing.tbWenZhu = {};
	-- 重新刷出幼虫
	for i = 1, 5 do
		for i = 1, #self.tbZhiZhuYouChongPos do
			local pYouChong = KNpc.Add2(4131, tbInstancing.nNpcLevel, -1 , nSubWorld, self.tbZhiZhuYouChongPos[i][1], self.tbZhiZhuYouChongPos[i][2]);
			assert(pYouChong);
			tbInstancing.tbWenZhu[#tbInstancing.tbWenZhu + 1] = pYouChong.dwId;
		end;
	end;
end;


-- 文珠
local tbWenZhu = Npc:GetClass("wenzhu");

tbWenZhu.tbDeathText = {"你们这些家伙，我会让你们死的很难看。", "神蛛使"};

function tbWenZhu:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then	-- 
		return;
	end;
	
	tbInstancing.nWenZhu = tbInstancing.nWenZhu + 1;
	
	if (tbInstancing.nWenZhu % 10 == 0) then
		local tbPlayList, nCount = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			teammate.Msg(self.tbDeathText[1], self.tbDeathText[2])
		end;
	end;
	
	if (tbInstancing.nWenZhu >= 10 and tbInstancing.nPlayDrumCount == 0) then
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Task.tbArmyCampInstancingManager:ShowTip(teammate, "Đã có thể đánh Trống rồi!");
			tbInstancing.nPlayDrumCount = 1;
			for i = 1, #tbInstancing.tbWenZhu do
				if (tbInstancing.tbWenZhu[i]) then
					local pNpc = KNpc.GetById(tbInstancing.tbWenZhu[i]);
					if (pNpc) then
						pNpc.Delete();
					end;
				end;
			end;
			tbInstancing.tbWenZhu = {};
		end;
	end; 
end;


-- 鼓
local tbGu = Npc:GetClass("gu");
-- 蛛母出现的位置
tbGu.tbZhuMuPos = {1976, 2851};

tbGu.tbPlayText = {"你们这是自投罗网！", "神蛛使"}
-- 敲鼓
function tbGu:OnDialog()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 是否可以打鼓
	-- if (tbInstancing.nWenZhu < 200) then
		-- me.Msg("情网大阵未破不可敲鼓！");
		-- return;
	-- end;
	-- 是否已经敲过鼓
	if (tbInstancing.nPlayGongCount ~= 0) then
		return;
	end;
		
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
	
	-- 播放音乐
	local szMsg 	= "setting\\audio\\obj\\ss033s.wav"; 
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.CallClientScript({"PlaySound", szMsg, 3});
	end;
	
	GeneralProcess:StartProcess("Đang đánh trống...", 5 * 18, {self.OnPlay, self, me.nId, tbInstancing, nSubWorld}, {self.BreakPlay, self, me.nId, tbPlayList, szSound, "Mở gián đoạn!"}, tbEvent);	
end;

function tbGu:BreakPlay(nPlayerId, tbPlayList, szSound, szMsg)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	pPlayer.Msg(szMsg);
	for _, teammate in ipairs(tbPlayList) do
		teammate.CallClientScript({"StopSound", szSound});
	end;	
end;

function tbGu:OnPlay(nPlayerId, tbInstancing, nSubWorld)
	-- 是否已经敲过鼓
	if (tbInstancing.nPlayGongCount ~= 0) then
		return;
	end;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(self.tbPlayText[1], self.tbPlayText[2])
	end;
	
	tbInstancing.nPlayGongCount = 1;
	local pZhuMu = KNpc.Add2(4132, tbInstancing.nNpcLevel, -1 , nSubWorld, self.tbZhuMuPos[1], self.tbZhuMuPos[2]);
	assert(pZhuMu);
	
	pZhuMu.AddLifePObserver(99);
	pZhuMu.AddLifePObserver(90);
	pZhuMu.AddLifePObserver(70);
	pZhuMu.AddLifePObserver(50);
	pZhuMu.AddLifePObserver(30);
	pZhuMu.AddLifePObserver(10);
	
	if (tbInstancing.nLiuYiBanOutCount ~= 0) then
		local pNpc = KNpc.Add2(4155, tbInstancing.nNpcLevel, -1, nSubWorld, 1979, 2855);
		pNpc.AddLifePObserver(40);
	end;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Task.tbArmyCampInstancingManager:ShowTip(teammate, "Thần Chu Sứ đã xuất hiện.");
	end;
end;

-- 蛛母
local tbZhuMu = Npc:GetClass("shenzhushi");

tbZhuMu.tbText = {
	[99] = {"看样子老二他们都已经惨败了是吧？", "看不出来你们小小年纪竟然会有这么深厚的功力！"},
	[90] = {"人往高处走，水往低处流！", "不如你加入我们蛊教！", "我会传授你练蛊的法门！"},
	[70] = {"再不撒手老娘可是要发飙了！", "小坏蛋当真不知好歹吗？"},
	[50] = {"我们往日无怨，近日无仇！", "你们这又是何必呢？", "何苦跟我一个女人过不去呢？"},
	[30] = {"看情形有点不妙！", "我还是看清逃路的方向吧！"},
	[10] = {"老娘我不陪你们玩了！", "这，这不可能！"},
	[0]  = {"我太高估自己了！", "神蛛使"},

}
function tbZhuMu:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();

	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing.nShenZhuFengPass = 1;
	
	him.SendChat(self.tbText[0][1]);
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(self.tbText[0][1], self.tbText[0][2]);
	end;
	
	if (tbInstancing.nJinZhiShenZhuFeng) then
		local pNpc = KNpc.GetById(tbInstancing.nJinZhiShenZhuFeng);
		pNpc.Delete();
	end;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Task.tbArmyCampInstancingManager:ShowTip(teammate, "Đã có thể đến Linh Hạt Phong rồi!");
	end;
end;

function tbZhuMu:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	tbInstancing:NpcSay(him.dwId, self.tbText[nLifePercent], 1);
	
	if (nLifePercent == 10) then
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			teammate.NewWorld(tbInstancing.nMapId, 1952, 2896);
			teammate.SetFightState(1);
			Task.tbArmyCampInstancingManager:ShowTip(teammate, "Thần Chu Sứ dùng hết nội lực đẩy bạn ra xa.");
		end;
	end;
end;

-- 神蛛峰指引
local tbBiWuFengZhiYin = Npc:GetClass("shenzhufengzhiyin");

tbBiWuFengZhiYin.szText = "    前面神蛛使依然闻风设下了情网大阵，等着你们自投罗网。还在此阵奥妙我已悉知，不足为惧。\n\n    破阵的关键是神蛛峰的那面锣，<color=red>只要敲响锣，神蛛便会误以为是要其攻击蜂拥而出，只要神蛛不敌而退便可敲鼓迎战神蛛使。<color>需要注意的是，一旦锣被敲响，所有人都会被吸入到阵法中心，此时文蛛必定蜂拥而出，一定要小心！切记！切记！\n\n    情网大阵一破，可速速<color=red>敲响神蛛使殿前的那面鼓<color>，此是神蛛使放出本命蛊害人的讯号，只要本命蛊飞出，神蛛使并不足为惧了。";

function tbBiWuFengZhiYin:OnDialog()
	local tbOpt = {{"Kết thúc đối thoại"}, };
	Dialog:Say(self.szText, tbOpt);
end;