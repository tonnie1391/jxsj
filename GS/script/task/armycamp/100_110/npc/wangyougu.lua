-----------------------------------------------------------
-- 文件名　：wangyougu.lua
-- 文件描述：忘忧谷脚本
-- 创建者　：ZhangDeheng
-- 创建时间：2008-12-12 09:38:03
-----------------------------------------------------------

-- 火蓬春 对话
local tbHuoPengChen_Dialog = Npc:GetClass("huopengchen_dialog");

tbHuoPengChen_Dialog.tbNeedItemList = { {20, 1, 624, 1, 1}, {20, 1, 625, 1, 1}};

function tbHuoPengChen_Dialog:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.nHuoPengChenOut ~= 0) then
		return;
	end;
	
	local szMsg = "滚远点，老头子又让你们来送死吗？";
	Dialog:Say(szMsg,
		{
			{"给静心珠和书信", self.Give, self, tbInstancing, me.nId, him.dwId},
			{"Kết thúc đối thoại"}
		});
	
end;

function tbHuoPengChen_Dialog:Give(tbInstancing, nPlayerId, nNpcId)
	Task:OnGift("这些东西你仔细看看！", self.tbNeedItemList, {self.Pass, self, tbInstancing, nPlayerId, nNpcId}, nil, {self.CheckRepeat, self, tbInstancing}, true);
end;

function tbHuoPengChen_Dialog:CheckRepeat(tbInstancing)
	if (tbInstancing.nHuoPengChenOut == 1) then
		return 0;
	end	
	return 1; 
end

function tbHuoPengChen_Dialog:Pass(tbInstancing, nPlayerId, nNpcId)
	if (tbInstancing.nHuoPengChenOut ~= 0) then
		return;
	end;
	
	local szMsg = "这珠子好像是老头子交给殷童那个小丫头的，怎么会在你们手里？还有这封书信的笔记也很熟悉，好像也是殷童那个小丫头的，俺看看都写了些啥。<color=yellow>\
     《我蠢》    《卧春》\
    俺没有文化（暗梅幽闻花），\
    我智商很低（卧枝伤恨底），\
    要问我是谁（遥闻卧似水），\
    一头大蠢驴（易透达春绿）。\
    俺是驴    （岸似绿），\
    俺是头驴  （岸似透绿），\
    俺是头呆驴（岸似透黛绿）。<color>";
	
	Dialog:Say(szMsg,
	{
		{"Kết thúc đối thoại", self.ChangeFight, self, tbInstancing, nNpcId},
	});
	if (tbInstancing.nHuoPengChenOut == 0 and not tbInstancing.nHuoPengChenTimerId) then
		tbInstancing.nHuoPengChenTimerId = Timer:Register(Env.GAME_FPS * 5, self.OnClose, self, tbInstancing, nNpcId);
	end;
end;

function tbHuoPengChen_Dialog:OnClose(tbInstancing, nNpcId)
	self:ChangeFight(tbInstancing, nNpcId);
	if (tbInstancing.nHuoPengChenTimerId) then
		Timer:Close(tbInstancing.nHuoPengChenTimerId);
		tbInstancing.nHuoPengChenTimerId = nil;
	end;
	return 0;
end;

function tbHuoPengChen_Dialog:ChangeFight(tbInstancing, nNpcId)
	assert(tbInstancing, nPlayerId, nNpcId);
	if (tbInstancing.nHuoPengChenOut ~= 0) then
		return;
	end;
	
	local pNpc = KNpc.GetById(nNpcId);
	local nSubWorld, nPosX, nPosY	= him.GetWorldPos();
	pNpc.Delete();
	
	local pNpc = KNpc.Add2(4145, tbInstancing.nNpcLevel, -1, nSubWorld, nPosX, nPosY);
	tbInstancing.nHuoPengChenOut = 1;
	pNpc.AddLifePObserver(90);
	pNpc.AddLifePObserver(70);
	pNpc.AddLifePObserver(60);
	pNpc.AddLifePObserver(40);
	pNpc.AddLifePObserver(30);
	pNpc.AddLifePObserver(20);
	pNpc.AddLifePObserver(10);
	pNpc.AddLifePObserver(5);
	pNpc.AddLifePObserver(4);
	pNpc.AddLifePObserver(3);
	pNpc.AddLifePObserver(2);
	
	local tbNpc = Npc:GetClass("huopengchen_fight");

	if (tbNpc) then
		tbInstancing:NpcSay(pNpc.dwId, tbNpc.tbSayText[100]);
	end;
	
end;

-- 火蓬春 战斗
local tbHuoPengChen_Fight = Npc:GetClass("huopengchen_fight");

tbHuoPengChen_Fight.tbSayText = {
	[100] = {"殷童这个小丫头片子！", "人都走了还不忘记捉弄人！"},
	[90] = {"老头子已经不行了吧？", "俺在上面都听说了！"},
	[70] = {"老头子不行了，吖吼！", "那俺岂不是就是这里的头头了？"},
	[60] = {"等俺把这里的人都收拾齐喽！", "看俺怎么收拾你们！"},
	[40] = {"俺一定不会跟俺师傅一样窝囊！"},
	[30] = {"俺一定要让他们瞧瞧！", "俺地厉害！"},
	[20] = {"对了，还有殷童那小丫头！", "俺一定要抓住她！", "让她给俺当媳妇！"},
	[10] = {"你们就不能轻点啊！", "啊！俺的蛊怎么招不出来了？", "你们对俺做了啥？"},
	[5]  = "难道老头子给殷童的就是……",
	[4]  = "天杀的老头子啊！",
	[3]  = "你死都死的不利索啊！",
	[2]  = "俺……俺……",
	[0]  = "俺恨你们……",
}

function tbHuoPengChen_Fight:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;

	if (nLifePercent < 10 and him) then
		him.SendChat(self.tbSayText[nLifePercent]);
		
		local tbPlayList, nCount = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			teammate.Msg(self.tbSayText[nLifePercent], him.szName);
		end;
		return;
	end;
	
	tbInstancing:NpcSay(him.dwId, self.tbSayText[nLifePercent]);
end;

function tbHuoPengChen_Fight:OnDeath(pNpc)
	-- 掉一个宝箱
	local nSubWorld, nNpcPosX, nNpcPosY = him.GetWorldPos();
	local pBaoXiang = KNpc.Add2(4113, 1, -1, nSubWorld, nNpcPosX, nNpcPosY);
	if not pBaoXiang then
		return 0;
	end
	--assert(pBaoXiang)
	local pPlayer  	= pNpc.GetPlayer();
	pBaoXiang.GetTempTable("Task").nOwnerPlayerId = (pPlayer and pPlayer.nId) or 0;
	pBaoXiang.GetTempTable("Task").CUR_LOCK_COUNT = 0;
	
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Task.tbArmyCampInstancingManager:ShowTip(teammate, "Một bảo rương lấp lánh xuất hiện!");
	end;
end;

-- 雪羽鸿飞
local tbXueYuHongFei = Npc:GetClass("xueyuhongfei");

tbXueYuHongFei.tbText = {
	[99] = "你们是什么人敢闯入到禁地中来。",
	[90] = "这里什么都没有，你们到底想要什么？",
	[70] = {"难道，难道是他？", "是火蓬春这家伙让你们来的？"},
	[50] = {"你们？你们都知道些什么？", "你们知道你们都在干些什么？"},
	[30] = "看样子你们知道些什么？",
	[0]  = "你们会后悔的！",
}

function tbXueYuHongFei:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (nLifePercent == 50 or nLifePercent == 70) then
		tbInstancing:NpcSay(him.dwId, self.tbText[nLifePercent]);
		return;
	end;
		
	local tbPlayList, nCount = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(self.tbText[nLifePercent], him.szName);
	end;
	him.SendChat(self.tbText[nLifePercent]);
end;
