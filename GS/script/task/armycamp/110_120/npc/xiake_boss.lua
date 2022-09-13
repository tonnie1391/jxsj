-- 文件名　：xiake_boss.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-03-15 12:10:10
-- 描  述  ：海王新增boss

local tbNpcDaLiShen	= Npc:GetClass("xiake_dalishen"); -- 大力神 7317
function tbNpcDaLiShen:OnDeath(pKillNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	tbInstancing.nHunTianHuOut = 0;
	local szSendText =  "<npc=7317>：“绝不气馁，绝不求饶，你们终究会后悔的！”<end>";
	szSendText = szSendText .. "<npc=7318>:“祈祷我的慈悲吧，你的灵魂，现在属于我啦！”<end>";
	local pPlayer = pKillNpc.GetPlayer();
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk(szSendText, self.TalkEnd, self, tbInstancing, nSubWorld);
		Setting:RestoreGlobalObj();
		StatLog:WriteStatLog("stat_info", "junying", "killboss", teammate.nId, teammate.GetHonorLevel(), pPlayer.nTeamId, him.nTemplateId, tbInstancing.szOpenTime);
	end
end

function tbNpcDaLiShen:TalkEnd(tbInstancing, nSubWorld)
	if tbInstancing.nHunTianHuOut ~= 0 then
		return 0;
	end
	tbInstancing.nHunTianHuOut = 1;
	local pTempNpc = KNpc.Add2(2976, 10, -1, nSubWorld, 1845, 3623);
	if pTempNpc then
		Timer:Register(5 * Env.GAME_FPS, self.CallHunTianHu, self, pTempNpc.dwId);
	end
end

function tbNpcDaLiShen:CallHunTianHu(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end;
	local nMapId, nPosX, nPosY	= pNpc.GetWorldPos();
	pNpc.Delete();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if not tbInstancing then
		return 0;
	end
	local pNpcHunTianHu = KNpc.Add2(7318, tbInstancing.nNpcLevel, -1, nMapId, nPosX, nPosY);
	if pNpcHunTianHu then
		Task.ArmyCamp:StartTrigger(pNpcHunTianHu.dwId, 8);
	end
	return 0;
end

local tbNpcHunTianHu	= Npc:GetClass("xiake_huntianhu"); -- 混天虎 7318
local tbNpcYouMingShenShou	= Npc:GetClass("xiake_youmingshenshou"); -- 幽冥神兽 7319

function tbNpcHunTianHu:OnDeath(pKillNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	tbInstancing.nYouMingShenShou = 0;
	local szSendText =  "<npc=7318>：“我……自由了……希望还不是太迟，请再多给我一些……时间……”<end>";
	szSendText = szSendText .. "<npc=7319>:“我看得到世间无尽的苦难，我看得到世间无穷的折磨，我看见了滔天的愤怒和怨仇——我，看到了一切……”<end>";
	local pPlayer = pKillNpc.GetPlayer();
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk(szSendText, self.TalkEnd, self, tbInstancing, nSubWorld);
		Setting:RestoreGlobalObj();
		StatLog:WriteStatLog("stat_info", "junying", "killboss", teammate.nId, teammate.GetHonorLevel(), pPlayer.nTeamId, him.nTemplateId, tbInstancing.szOpenTime);
	end
	Task.ArmyCamp:ClearData(him.dwId);
end

tbNpcHunTianHu.nCheckCD = 20;

function tbNpcHunTianHu:TalkEnd(tbInstancing, nSubWorld)
	if tbInstancing.nYouMingShenShou ~= 0 then
		return 0;
	end
	tbInstancing.nYouMingShenShou = 1;
	local pTempNpc = KNpc.Add2(2976, 10, -1, nSubWorld, 1843, 3625);
	if pTempNpc then
		Timer:Register(5 * Env.GAME_FPS, self.CallYouMingShenShou, self, pTempNpc.dwId);
	end
end

function tbNpcHunTianHu:CallYouMingShenShou(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end;
	local nMapId, nPosX, nPosY	= pNpc.GetWorldPos();
	pNpc.Delete();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if not tbInstancing then
		return 0;
	end
	local pNpcYouMingShenShou = KNpc.Add2(7319, tbInstancing.nNpcLevel, -1, nMapId, nPosX, nPosY);
	if pNpcYouMingShenShou then
		pNpcYouMingShenShou.AddLifePObserver(30);
		local tbNpcData = pNpcYouMingShenShou.GetTempTable("Task");
		tbNpcData.nTriggerTimes_30per = 0;
	end
	return 0;
end


tbNpcYouMingShenShou.nCheckCD = tbNpcHunTianHu.nCheckCD;
tbNpcYouMingShenShou.nFengShenTime = 30 * 18;
tbNpcYouMingShenShou.nActiveRunCD = 8;
tbNpcYouMingShenShou.FenShenPos = 
{
	{58848,115520},
	{58592,115424},
	{58368,115648},
	{58560,115808},
	{58688,116256},
	{58400,116128},
	{58784,115904},
	{59008,116544},
	{59360,116480},
	{59104,116256},
	{59296,116768},
	{59520,116096},
};

function tbNpcYouMingShenShou:OnLifePercentReduceHere(nPercent)
	if nPercent == 30 then
		if him.GetTempTable("Task").nTriggerTimes_30per ~= 0 then
			return 0;
		end
		local nSubWorld, _, _	= him.GetWorldPos();
		local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
		if not tbInstancing then
			return 0;
		end
		him.GetTempTable("Task").nTriggerTimes_30per = 1;
		Timer:Register(self.nCheckCD * 18, tbNpcYouMingShenShou.Splitting, tbNpcYouMingShenShou, him.dwId);
		tbInstancing.nYouMingShenShouId = him.dwId;
	end
end


function tbNpcYouMingShenShou:Splitting(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local nRand = MathRandom(#self.FenShenPos);
	local pNpc = KNpc.Add2(7328, tbInstancing.nNpcLevel, -1, nSubWorld, self.FenShenPos[nRand][1] / 32, self.FenShenPos[nRand][2] / 32);
	if pNpc then
		pNpc.SetLiveTime(self.nFengShenTime);
	end
end

function tbNpcYouMingShenShou:OnDeath(pKillNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local pPlayer = pKillNpc.GetPlayer();
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		XiakeDaily:AchieveTask(teammate, 1, 3);
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=7319>:“什么江湖，什么恩怨，一切都是过眼云烟。有一天你也会明白！");
		Setting:RestoreGlobalObj();
		StatLog:WriteStatLog("stat_info", "junying", "killboss", teammate.nId, teammate.GetHonorLevel(), pPlayer.nTeamId, him.nTemplateId, tbInstancing.szOpenTime);
	end
end

local tbNpcYouMingShou = Npc:GetClass("xiake_youmingshou");	-- 幽冥神

function tbNpcYouMingShou:OnDeath(pKillNpc)
	local nSubWorld, nPosX, nPosY	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local nYouMingShenShouId = tbInstancing.nYouMingShenShouId;
	local pNpc = KNpc.GetById(nYouMingShenShouId);
	if not pNpc then	-- 检查的npc不见了，不需要做什么了
		return 0;
	end
	pNpc.CastSkill(1953, 5, nPosX * 32, nPosY * 32);
end