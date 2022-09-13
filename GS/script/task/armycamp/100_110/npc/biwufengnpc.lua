-----------------------------------------------------------
-- 文件名　：biwufengnpc.lua
-- 文件描述：蛊翁，毒蝎幼虫，蝎王
-- 创建者　：ZhangDeheng
-- 创建时间：2008-11-26 18:11:25
-----------------------------------------------------------

-- 蛊翁
local tbGuWeng = Npc:GetClass("guweng");

-- 幼虫ID
tbGuWeng.nYouChongId = 4126;

-- 幼虫出现的位置
tbGuWeng.tbYouChongPos = {
	{1777, 3069}, {1784, 3069}, {1787, 3081}, {1779, 3091}, {1773, 3079},
};

-- 
tbGuWeng.tbLifePresent = {99, 90, 80, 70, 30, 10,};

tbGuWeng.tbLifePresentText = {
	[99] = {{"二哥，他们在砸你的醋坛子","天绝使"}, {"闭嘴，我又不是没有长眼睛", "碧蜈使"}},
	[90] = {{"二哥，还在砸！", "天绝使"}, {"看看再说，我的蛊可不是养来看的！", "碧蜈使"}},
	[80] = {{"二哥，你的蛊好像不怎么厉害！", "天绝使"}, {"胡说，你懂啥，现在出来都是没什么用的，厉害的在后头呢！", "碧蜈使"}},
	[70] = {{"二哥……", "天绝使"}, {"闭嘴！", "碧蜈使"}},
	[30] = {{"二哥，我看你的蛊是真的不行了！怕不是臭了吧？", "天绝使"}, {"又不是在腌咸菜，什么臭不臭的，怕什么？出了事有我顶着，这都是些小屁孩，我怎么跟他们计较，传出去我还怎么见人？", "碧蜈使"}},
	[10] = {{"二哥，我觉得你这里也不是很安全！", "天绝使"}, {"好戏还在后头呢！", "碧蜈使"}},
	[0]  = {{"小瘪三，你们折腾够了吧？", "碧蜈使"}, {"现在让你们数数马王爷有几只眼！", "碧蜈使"}},
}

function tbGuWeng:OnLifePercentReduceHere(nLifePercent)
	
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return;
	end
	--assert(tbInstancing);

	-- 添加幼虫
	if (nLifePercent % 7 == 0) then
		for i = 1, #self.tbYouChongPos do
			for j = 1, 2 do
				KNpc.Add2(self.nYouChongId, tbInstancing.nNpcLevel, -1 , nSubWorld, self.tbYouChongPos[i][1], self.tbYouChongPos[i][2]);
			end;
		end;
	end;
	
	-- 说话
	for i = 1, #self.tbLifePresent do 
		if (nLifePercent == self.tbLifePresent[i]) then
			local tbPlayList, nCount = KPlayer.GetMapPlayer(tbInstancing.nMapId);
			for _, teammate in ipairs(tbPlayList) do
				teammate.Msg(self.tbLifePresentText[nLifePercent][1][1],self.tbLifePresentText[nLifePercent][1][2]);
				teammate.Msg(self.tbLifePresentText[nLifePercent][2][1],self.tbLifePresentText[nLifePercent][2][2]);
			end;
		end;
	end;
end;

function tbGuWeng:OnDeath(pNpc)
	local nSubWorld, _, _ = him.GetWorldPos();	
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
		
	local tbPlayList, nCount = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(self.tbLifePresentText[0][1][1],self.tbLifePresentText[0][1][2]);
		teammate.Msg(self.tbLifePresentText[0][2][1],self.tbLifePresentText[0][2][2]);
	end;
end;

-- 毒蝎幼虫
local tbDuXieYouChong = Npc:GetClass("youchong");
-- 需要杀的数量
tbDuXieYouChong.NEED_COUNT		= 10;

-- 死亡时执行
function tbDuXieYouChong:OnDeath(pNpc)
	local nSubWorld, nNpcPosX, nNpcPosY = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;
	
	tbInstancing.nDuXieYouChong = tbInstancing.nDuXieYouChong + 1;
	if (tbInstancing.nDuXieYouChong >= self.NEED_COUNT and tbInstancing.nXieWangOut == 0) then
		local pXieWang = KNpc.Add2(4127, tbInstancing.nNpcLevel, -1 , nSubWorld, 1800, 3035);
		assert(pXieWang);
		Task.ArmyCamp:StartTrigger(pXieWang.dwId, 7);
		pXieWang.AddLifePObserver(90);
		pXieWang.AddLifePObserver(70);
		pXieWang.AddLifePObserver(50);
		pXieWang.AddLifePObserver(30);
		pXieWang.AddLifePObserver(10);
		tbInstancing.nXieWangOut = 1;
		-- 留一半
		if (tbInstancing.nLiuYiBanOutCount ~= 0) then
			local pNpc = KNpc.Add2(4155, tbInstancing.nNpcLevel, -1, nSubWorld, 1804, 3036);
			pNpc.AddLifePObserver(60);
		end;
		
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Task.tbArmyCampInstancingManager:ShowTip(teammate, "Bích Ngô Sứ đã xuất hiện.");
		end;
	end;
end;

-- 蝎王
local tbBiWuShi = Npc:GetClass("biwushi");

tbBiWuShi.tbText = {
	[90] = {"难怪老四这么害怕！还挺扎手！", "大理国内没有这样的好手！", "你们是哪路高手，报上名来！"},
	[70] = {{"怎么的？看不起人？知道我是谁不？", "我可是百蛮山的老大！"}, {"二哥，大姐知道会不高兴的！", "天绝使"}, {"不高兴？她什么时候高兴过？", "她要是高兴的话早就是你二嫂了！"}},
	[50] = {"点子扎手！", "有点吃不消了！"},
	[30] = {{"我看我们还是去找大姐吧！", "天绝使"}, {"你诚心看我出丑吗？", "碧蜈使"}, {"出丑总比没命强吧？", "天绝使"}},
	[10] = {{"二哥！留着青山在还怕没柴烧？", "天绝使"}, {"唉！风紧扯呼！", "碧蜈使"}},
	[0]  = {"看样子有点晚了！", "你自己逃命去吧！"}
}

function tbBiWuShi:OnDeath(pNpc)
	local nSubWorld, nNpcPosX, nNpcPosY = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;
	
	local tbPlayList, nCount = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(self.tbText[0][1], him.szName);
		teammate.Msg(self.tbText[0][2], him.szName);
	end;
	
	tbInstancing.nBiWuFengPass = 1;
	
	if (not tbInstancing.nJinZhiBiWuFeng) then
		return;
	end;
	
	local pNpc = KNpc.GetById(tbInstancing.nJinZhiBiWuFeng);
	if (pNpc) then
		pNpc.Delete();
	end;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Task.tbArmyCampInstancingManager:ShowTip(teammate, "Đã có thể đến Thần Thù Phong rồi!");
	end;
	Task.ArmyCamp:ClearData(him.dwId);
end;

function tbBiWuShi:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;
	if (nLifePercent == 90 or nLifePercent == 50) then
			tbInstancing:NpcSay(him.dwId, self.tbText[nLifePercent]);
			him.GetTempTable("Task").tbSayOver = nil;
	end;
	if (nLifePercent == 70) then
		tbInstancing:NpcSay(him.dwId, self.tbText[nLifePercent][1]);
		him.GetTempTable("Task").tbSayOver = {self.SayOver, self, him.dwId, self.tbText[nLifePercent]};
	end;
	if (nLifePercent == 30 or nLifePercent == 10) then
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			for i = 1, #self.tbText[nLifePercent] do
				teammate.Msg(self.tbText[nLifePercent][i][1], self.tbText[nLifePercent][i][2]);
			end;
		end;
	end;
end;

function tbBiWuShi:SayOver(nNpcId, tbText)
	if (not nNpcId or not tbText) then
		return;
	end;
	
	local pNpc = KNpc.GetById(nNpcId);
	local nSubWorld, _, _ = pNpc.GetWorldPos();	
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	assert(tbInstancing);
		
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(tbText[2][1], tbText[2][2]);
	end;
	
	tbInstancing:NpcSay(nNpcId, tbText[3]);
	him.GetTempTable("Task").tbSayOver = nil;
end;

-- 碧蜈峰指引
local tbBiWuFengZhiYin = Npc:GetClass("biwufengzhiyin");

tbBiWuFengZhiYin.szText = "    过桥处便是碧蜈峰，此处由碧蜈使把守。碧蜈使以前辈自居，对后辈从不主动出手。若想和他交手，必须将其激怒。\n\n   等下你们经过碧蜈峰会看到一个巨大的蛊瓮，此是碧蜈使炼蛊所用。<color=red>只要攻击此瓮，瓮内的蛊物必会按奈不住出来伤人，蛊物伤的多了，碧蜈使自然会按奈不住。<color>";

function tbBiWuFengZhiYin:OnDialog()
	local tbOpt = {{"Kết thúc đối thoại"}, };
	Dialog:Say(self.szText, tbOpt);
end;