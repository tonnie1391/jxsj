-- 对话白鹿使
local tbNpcBailu_Dialog = Npc:GetClass("xiake_bailu_dlg");

function tbNpcBailu_Dialog:OnDialog()

end

-- 开始挑战，关卡初始化
function tbNpcBailu_Dialog:StarChallenge(nSubWorld, nPosX, nPosY)
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[7] ~= 1 then
		return;
	end
	if tbInstancing.tbTollgateReset[6] ~= 2 then
		print("error open elunheyuan xiakeboss");
		return;
	end
	tbInstancing.tbXiakeBoss.nNpcStone = nil;
	-- 出现特效
	local pEffectNpc = KNpc.Add2(2976, 10, -1, nSubWorld, 55232/32, 103040/32);
	assert(pEffectNpc);
	tbInstancing:ChangeTollgateState(7,0);	
	Timer:Register(5 * Env.GAME_FPS, self.CallBoss, self, pEffectNpc.dwId);
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		teammate.NewWorld(nSubWorld, nPosX, nPosY);
		tbInstancing.tbAttendPlayerList[teammate.nId] = 1;
		teammate.SetFightState(1);
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=10147>：“凡间之人，唯有心灵纯净者，方能踏足于腾格里之下的土地。你们准备接受考验么？”");
		Setting:RestoreGlobalObj();
	end
end

function tbNpcBailu_Dialog:CallBoss(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local nSubWorld, nX, nY = pNpc.GetWorldPos();
	pNpc.Delete();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local pBaiLu_Fight = KNpc.Add2(10147, tbInstancing.nNpcLevel, -1, nSubWorld, nX, nY);
	if pBaiLu_Fight then
		tbInstancing.tbXiakeBoss.nNpcBaiLu_Fight = pBaiLu_Fight.dwId;
		pBaiLu_Fight.AddLifePObserver(50);
	end
	local pCangLang_Dialog = KNpc.Add2(10150, tbInstancing.nNpcLevel, -1, nSubWorld, 55488/32, 102752/32);
	if pCangLang_Dialog then
		tbInstancing.tbXiakeBoss.nNpcCangLang_Dialog = pCangLang_Dialog.dwId;
	end
end

-- 战斗白鹿使
local tbNpcBailu_Fight = Npc:GetClass("xiake_bailu_fgt");

function tbNpcBailu_Fight:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local pPlayer = pKiller.GetPlayer();
	local nTeamId = 0;
	if pPlayer then
		nTeamId = pPlayer.nTeamId;
	end
	tbInstancing.tbXiakeBoss.nNpcBaiLu_Fight = nil;
	if not tbInstancing.tbXiakeBoss.nNpcCangLang_Fight then
		self:AchieveTask(nTeamId, tbInstancing);
	end
end

function tbNpcBailu_Fight:AchieveTask(nTeamId, tbInstancing)
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	tbInstancing:ChangeTollgateState(7, 2);
	tbInstancing.tbAttendPlayerList = {};
	for _, teammate in ipairs(tbPlayList) do
		if (teammate.IsDead() == 1) then
			teammate.ReviveImmediately(1);
		end
		teammate.SetFightState(0);
		XiakeDaily:AchieveTask(teammate, 1, 4);
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=10147>:“你们成功通过了腾格里的试炼。须谨记，沉浮于世，凡事应淡看，亦应不弃执念，方能保持本心又不至沉沦。”");
		Setting:RestoreGlobalObj();
		StatLog:WriteStatLog("stat_info", "junying", "killboss", teammate.nId, teammate.GetHonorLevel(), nTeamId, 10148, tbInstancing.szOpenTime);
	end
	-- 清除狼兵
	if tbInstancing.tbXiakeBoss.tbNpcLangWei and  #tbInstancing.tbXiakeBoss.tbNpcLangWei > 0 then
		for _, nNpcId in pairs(tbInstancing.tbXiakeBoss.tbNpcLangWei) do
			tbInstancing:DeleteNpc(nNpcId);
		end
	end
	tbInstancing.tbXiakeBoss.tbNpcLangWei = {};
end

function tbNpcBailu_Fight:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	if nLifePercent == 50 then -- 变非战斗状态
		him.Delete();
		tbInstancing.tbXiakeBoss.nNpcBaiLu_Fight = nil;
		local pBaiLu_Dialog = KNpc.Add2(10148, tbInstancing.nNpcLevel, -1, nSubWorld, 55680/32, 102944/32);
		if pBaiLu_Dialog then
			tbInstancing.tbXiakeBoss.nNpcBaiLu_Dialog = pBaiLu_Dialog.dwId;
		end
		if tbInstancing.tbXiakeBoss.nNpcCangLang_Dialog then
			tbInstancing:DeleteNpc(tbInstancing.tbXiakeBoss.nNpcCangLang_Dialog);
			tbInstancing.tbXiakeBoss.nNpcCangLang_Dialog = nil;
		end
		if tbInstancing.tbXiakeBoss.nNpcCangLang_Fight then -- 应该是不会出现
			tbInstancing:DeleteNpc(tbInstancing.tbXiakeBoss.nNpcCangLang_Fight);
			tbInstancing.tbXiakeBoss.nNpcCangLang_Fight = nil;
		end
		local pCangLang_Fight = KNpc.Add2(10149, tbInstancing.nNpcLevel, -1, nSubWorld, 55424/32, 103168/32);
		if pCangLang_Fight then
			tbInstancing.tbXiakeBoss.nNpcCangLang_Fight = pCangLang_Fight.dwId;
			pCangLang_Fight.AddLifePObserver(70);
			pCangLang_Fight.AddLifePObserver(50);
		end
		tbInstancing:SendPrompt("Bạch Lộc Thần Sứ: Hãy kiểm tra họ.", 0, 1, 0, 0);
		tbInstancing:SendPrompt("Bạch Lộc Thần Sứ: Hãy kiểm tra họ lần nữa.", 0, 0, 1, 0);
	end
end
-----------第二个boss--------------------
-- 对话苍狼使
local tbNpcCangLang_Dialog = Npc:GetClass("xiake_canglang_dlg");

function tbNpcCangLang_Dialog:OnDialog()
end

-- 战斗苍狼使
local tbNpcCangLang_Fight = Npc:GetClass("xiake_canglang_fgt");

tbNpcCangLang_Fight.tbLangWeiPos = 
{
	{55104/32,103008/32}, {55296/32,102816/32}, {55360/32,103328/32}, {55552/32,103136/32},	
};

function tbNpcCangLang_Fight:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local pPlayer = pKiller.GetPlayer();
	local nTeamId = 0;
	if pPlayer then
		nTeamId = pPlayer.nTeamId;
	end
	tbInstancing.tbXiakeBoss.nNpcCangLang_Fight = nil;
	if not tbInstancing.tbXiakeBoss.nNpcBaiLu_Fight then
		tbNpcBailu_Fight:AchieveTask(nTeamId, tbInstancing);
	end
end

function tbNpcCangLang_Fight:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	if nLifePercent == 70 and not him.GetTempTable("Task").nHaveCallLangWei then
		him.GetTempTable("Task").nHaveCallLangWei = 1;
		if tbInstancing.tbXiakeBoss.tbNpcLangWei and #tbInstancing.tbXiakeBoss.tbNpcLangWei > 0 then
			for nNpcId, _ in pairs(tbInstancing.tbXiakeBoss.tbNpcLangWei) do
				self:DeleteNpc(nNpcId);
			end
		end
		tbInstancing.tbXiakeBoss.tbNpcLangWei = {};
		for _, tbPos in pairs(self.tbLangWeiPos) do
			local pNpc = KNpc.Add2(10151, tbInstancing.nNpcLevel, -1, nSubWorld, tbPos[1], tbPos[2]);
			if pNpc then
				table.insert(tbInstancing.tbXiakeBoss.tbNpcLangWei, pNpc.dwId);
			end
		end
		--npc啥的经常call不出来，还是处理一下保险
		if #tbInstancing.tbXiakeBoss.tbNpcLangWei == #self.tbLangWeiPos then
			him.AddSkillState(1332, 20, 1, 180000);
			him.SendChat("你们以为我就没有帮手吗？？");
			tbInstancing:SendPrompt("Hạ gục Lang Vệ!", 0, 1, 1, 0);
		end
	end
	if nLifePercent == 50 and not him.GetTempTable("Task").HaveChange then
		him.GetTempTable("Task").HaveChange = 1; -- 防止多次触发
		if tbInstancing.tbXiakeBoss.nNpcBaiLu_Dialog then
			tbInstancing:DeleteNpc(tbInstancing.tbXiakeBoss.nNpcBaiLu_Dialog);
			tbInstancing.tbXiakeBoss.nNpcBaiLu_Dialog = nil;
		end
		if tbInstancing.tbXiakeBoss.nNpcBaiLu_Fight then -- 应该是不会出现
			tbInstancing:DeleteNpc(tbInstancing.tbXiakeBoss.nNpcBaiLu_Fight);
			tbInstancing.tbXiakeBoss.nNpcBaiLu_Fight = nil;
		end
		local pBaiLu_Fight = KNpc.Add2(10147, tbInstancing.nNpcLevel, -1, nSubWorld, 1725, 3223);
		if pBaiLu_Fight then
			tbInstancing.tbXiakeBoss.nNpcBaiLu_Fight = pBaiLu_Fight.dwId;
			pBaiLu_Fight.ReduceLife(pBaiLu_Fight.nMaxLife/2);
		end
		tbInstancing:SendPrompt("Thương Lang Thần Sứ: Bạch Lộc không cần ở lại nữa", 0, 1, 1, 0);
	end
end

-- 狼卫
local tbNpcLangWei = Npc:GetClass("xiake_langwei");

function tbNpcLangWei:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	tbInstancing.tbXiakeBoss.tbNpcLangWei = tbInstancing.tbXiakeBoss.tbNpcLangWei or {};
	for nIndex, nNpcId in ipairs(tbInstancing.tbXiakeBoss.tbNpcLangWei) do
		if nNpcId == him.dwId then
			table.remove(tbInstancing.tbXiakeBoss.tbNpcLangWei, nIndex);
			break;
		end
	end
	if #tbInstancing.tbXiakeBoss.tbNpcLangWei == 0 then
		if tbInstancing.tbXiakeBoss.nNpcCangLang_Fight then
			local pBoss = KNpc.GetById(tbInstancing.tbXiakeBoss.nNpcCangLang_Fight);
			if pBoss then
				pBoss.RemoveSkillState(1332);
				pBoss.SendChat("看来还是得亲自会会你们");
			end
		end
	end
end