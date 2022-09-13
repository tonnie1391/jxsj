-- 文件名　：xiake_boss.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-03-15 12:10:10
-- 描  述  ：伏牛山新增boss

local tbNpcBaiWuWei	= Npc:GetClass("xiake_baiwuwei"); -- 白无为

function tbNpcBaiWuWei:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	tbInstancing.nBaiSuSuOut = 0;
	local pPlayer = pNpc.GetPlayer();
	local szSendText =  "<npc=7312>：“美丽的伏牛山，我最可爱的姐姐，我最亲密的伙伴，再见了！”<end>";
	szSendText = szSendText .. "<npc=7314>:“你们不该来这里……你们更不该杀了我最亲爱的弟弟！”<end>";
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk(szSendText, self.TalkEnd, self, tbInstancing, nSubWorld);
		Setting:RestoreGlobalObj();
		StatLog:WriteStatLog("stat_info", "junying", "killboss", teammate.nId, teammate.GetHonorLevel(), pPlayer.nTeamId, him.nTemplateId, tbInstancing.szOpenTime);
	end
	Task.ArmyCamp:ClearData(him.dwId);
end

function tbNpcBaiWuWei:TalkEnd(tbInstancing, nSubWorld)
	if tbInstancing.nBaiSuSuOut ~= 0 then
		return 0;
	end
	tbInstancing.nBaiSuSuOut = 1;
	local pTempNpc = KNpc.Add2(2976, 10, -1, nSubWorld, 1678, 3819);
	if pTempNpc then
		Timer:Register(5 * Env.GAME_FPS, self.CallBaiSuSu, self, pTempNpc.dwId);
	end
end

function tbNpcBaiWuWei:CallBaiSuSu(nNpcId)
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
	KNpc.Add2(7314, tbInstancing.nNpcLevel, -1, nMapId, nPosX, nPosY);
	return 0;
end

local tbNpcBaiSuSu	= Npc:GetClass("xiake_baisusu"); -- 白素素

function tbNpcBaiSuSu:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local pPlayer = pNpc.GetPlayer();
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		XiakeDaily:AchieveTask(teammate, 1, 1);
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=7314>:“愤怒的死者永不安息，别了伏牛山”");
		Setting:RestoreGlobalObj();
		StatLog:WriteStatLog("stat_info", "junying", "killboss", teammate.nId, teammate.GetHonorLevel(), pPlayer.nTeamId, him.nTemplateId, tbInstancing.szOpenTime);
	end
end