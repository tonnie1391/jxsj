-- 蒙古勇士对话npc
local tbNpcYongshi_Dialog = Npc:GetClass("elunheyuan_dlg_mengguyongshi");
tbNpcYongshi_Dialog.tbWoodPos = {};
tbNpcYongshi_Dialog.szWoodPosFile = "\\setting\\task\\armycamp\\elunheyuan\\menggujiguan.txt";
tbNpcYongshi_Dialog.nBossCastSkillWoodNum = 3;  -- 场地的木桩超过3个则释放抽蓝技能
tbNpcYongshi_Dialog.nBossCastSkillSpeTime = 1;	-- boss放技能间隔的描述
tbNpcYongshi_Dialog.nBossCallWoodSpeTime  = 10;	-- 每10秒boss会召唤一个木桩
tbNpcYongshi_Dialog.nBossCastGuangquanSpeTime = 30;	-- 每30秒放光圈
tbNpcYongshi_Dialog.nGuangquanType2Skill = {[1] = {2501, 2}, [2] = {2502, 2}};
tbNpcYongshi_Dialog.tbGuangquanType2Pos = {
	[1] = {55232/32, 113984/32},
	[2] = {55488/32, 113728/32},
	};
tbNpcYongshi_Dialog.tbQunzhongType2Pos = {
	[5] = {{1707, 3553}, {1742, 3562}, {1746, 3548}},
	[6] = {{1705, 3557}, {1722, 3576}, {1750, 3554}},
	[7] = {{1711, 3566}, {1717, 3573}, {1730, 3532}},
	};
tbNpcYongshi_Dialog.tbQunzhongType2Id ={[5] = 9983, [6] = 9984, [7] = 9985};
tbNpcYongshi_Dialog.tbCastGuangquanChat = {
	"燃烧吧，苍狼之炎！",
	"白鹿炎，焚！",
	};
tbNpcYongshi_Dialog.tbChatInfo = 
{
	[1] = {"干得好！", "击垮他们！", "吼吼吼吼吼吼吼吼吼！"},
	[2] = {"加油！", "再用力一点！", "好样的！"},
	[3] = {"加油"},
	[4] = {"加油"},	
	[5] = {"加油！！", "好样的！<pic=22>", "简直弱爆了！<pic=6>"},
	[6] = {"打倒他！！<pic=6>", "吼吼吼吼吼！！！！", "小心后面！！！"},
	[7] = {"这么快就气喘如牛了<pic=5>", "好久没看到这么精彩的比试了！<pic=1>", "真不愧是草原的勇士！！<pic=23>"},
};
function tbNpcYongshi_Dialog:OnDialog()
	local tbNpcData = him.GetTempTable("Task"); 
	if tbNpcData.nFailure == 1 then
		Dialog:Say(string.format("%s:%s, xin chào!", him.szName, me.szName));
		return;
	end
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[1] ~= 1 then -- 只有再关卡准备就绪的时候才可以对话
		return;
	end
	if (tbInstancing.tbBiwuchangInfo.nFightMengguyongshi1 ~= 0) then
		return;
	end
	local szMsg = string.format("%s: Ha ha...Khá khen cho ngươi! Hãy tiến lên võ đài, xem ai là người thắng cuộc!", him.szName);
	local tbOpt = {
		{"Tiến hành khiêu chiến!", self.StartFight, self, me.nId, him.dwId},
		{"Thôi, ta thấy sợ quá"},
	}
	Dialog:Say(szMsg, tbOpt);
end

-- 对话转战斗,初级蒙古勇士
function tbNpcYongshi_Dialog:StartFight(nPlayerId,	nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(nNpcId);
	if (not pPlayer or not pNpc) then
		return;
	end
	local nSubWorld = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.tbBiwuchangInfo.nFightMengguyongshi1 ~= 0) then
		return;
	end
	--tbInstancing.tbTollgateReset[1] = 0;
	-- 出现特效
	local pEffectNpc = KNpc.Add2(2976, 10, -1, nSubWorld, 55232/32, 113728/32);
	assert(pEffectNpc);
	tbInstancing:ChangeTollgateState(1, 0);
	pNpc.Delete();-- 删除对话npc
	tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi1= 0;
	Timer:Register(5 * Env.GAME_FPS, self.CallBoss, self, 1, pEffectNpc.dwId);
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		teammate.NewWorld(nSubWorld, 55200/32, 113536/32);
		tbInstancing.tbAttendPlayerList[teammate.nId] = 1;
		teammate.SetFightState(1);
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=9934>：“哈哈哈哈哈哈哈！很好，有胆量上台的都是真正的勇士。虽说是比武，不过在草原上，每一次比试都是要赌上性命的，做好觉悟了么。记住我的名字——赫赤勒！哈哈哈哈哈哈！”");
		Setting:RestoreGlobalObj();
	end
	-- 添加围观的群众
	for nType, tbTemp in pairs(self.tbQunzhongType2Pos) do
		for _, tbPos in ipairs(tbTemp) do
			local pNpcQunzhong = KNpc.Add2(self.tbQunzhongType2Id[nType], 110, -1, nSubWorld, tbPos[1], tbPos[2]);
			if pNpcQunzhong then
				tbInstancing.tbBiwuchangInfo.tbNpcQuanzhongId[pNpcQunzhong.dwId] = nType;
				Timer:Register(3 * Env.GAME_FPS, self.SaySomething, self, pNpcQunzhong.dwId, nType);
			end
		end
	end
end

-- 特效结束后添加战斗boss
function tbNpcYongshi_Dialog:CallBoss(nLevel, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local nSubWorld, nX, nY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		pNpc.Delete();
		return 0;
	end
	if nLevel == 1 then -- 初级勇士
		if (tbInstancing.tbBiwuchangInfo.nFightMengguyongshi1 ~= 0) then
			pNpc.Delete();
			return 0;
		end
		local pMengguyongshi = KNpc.Add2(9934, tbInstancing.nNpcLevel, -1, nSubWorld, nX, nY);
		if pMengguyongshi then
			pNpc.Delete();
			tbInstancing.tbBiwuchangInfo.nFightMengguyongshi1 = pMengguyongshi.dwId;
			local tbNpc = Npc:GetClass("elunheyuan_fight_mengguyongshi1");
			for nLifePercent, szTxt in pairs(tbNpc.tbText) do
				pMengguyongshi.AddLifePObserver(nLifePercent);
			end
			return 0;
		else
			return Env.GAME_FPS; -- 若添加npc失败隔一秒再尝试一次
		end
	elseif nLevel == 2 then -- 中级勇士
		if (tbInstancing.tbBiwuchangInfo.nFightMengguyongshi2 ~= 0) then
			pNpc.Delete();
			return 0;
		end
		local pMengguyongshi = KNpc.Add2(9935, tbInstancing.nNpcLevel, -1, nSubWorld, nX, nY);
		if pMengguyongshi then
			pNpc.Delete();
			tbInstancing.tbBiwuchangInfo.nFightMengguyongshi2 = pMengguyongshi.dwId;
			-- 每10秒添加一个机关
			Timer:Register(self.nBossCallWoodSpeTime * Env.GAME_FPS, self.CallWoodNpc, self, pMengguyongshi.dwId);
			local tbNpc = Npc:GetClass("elunheyuan_fight_mengguyongshi2");
			for nLifePercent, szTxt in pairs(tbNpc.tbText) do
				pMengguyongshi.AddLifePObserver(nLifePercent);
			end
			return 0;
		else
			return Env.GAME_FPS; -- 若添加npc失败隔一秒再尝试一次
		end
	elseif nLevel == 3 then	-- 高级勇士1
		if (tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_1 ~= 0) then
			pNpc.Delete();
			return 0;
		end
		local pMengguyongshi = KNpc.Add2(9936, tbInstancing.nNpcLevel, -1, nSubWorld, nX, nY);
		if pMengguyongshi then
			tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_1 = pMengguyongshi.dwId;
			-- 每30秒施放一个定点制单
			Timer:Register(10 * Env.GAME_FPS, self.CastGuangquan, self, pMengguyongshi.dwId, 1, 0);
			Timer:Register((self.nBossCastGuangquanSpeTime + 10) * Env.GAME_FPS, self.CastGuangquan, self, pMengguyongshi.dwId, 1, self.nBossCastGuangquanSpeTime);
			if (tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_2 ~= 0) then
				-- 每10秒添加一个机关
				Timer:Register(self.nBossCallWoodSpeTime * Env.GAME_FPS, self.CallWoodNpc, self, tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_2, pMengguyongshi.dwId);
			end
			tbInstancing:SendPrompt("Mở cơ quan trên mặt đất để loại bỏ trạng thái xấu!", 0, 1, 1, 0);
			local tbNpc = Npc:GetClass("elunheyuan_fight_mengguyongshi3_1");
			for nLifePercent, szTxt in pairs(tbNpc.tbText) do
				pMengguyongshi.AddLifePObserver(nLifePercent);
			end
		end
		pNpc.Delete();
		return 0; -- 第三关两个npc，如果加失败就不再尝试加了
	elseif nLevel == 4 then -- 高级勇士2
		if (tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_2 ~= 0) then
			pNpc.Delete();
			return 0;
		end
		local pMengguyongshi = KNpc.Add2(9937, tbInstancing.nNpcLevel, -1, nSubWorld, nX, nY);
		if pMengguyongshi then
			tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_2 = pMengguyongshi.dwId;
			-- 每30秒施放一个定点子弹
			Timer:Register(10 * Env.GAME_FPS, self.CastGuangquan, self, pMengguyongshi.dwId, 2, 0);
			Timer:Register((self.nBossCastGuangquanSpeTime + 10)* Env.GAME_FPS, self.CastGuangquan, self, pMengguyongshi.dwId, 2, self.nBossCastGuangquanSpeTime);
			if (tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_1 ~= 0) then
				-- 每10秒添加一个机关
				Timer:Register(self.nBossCallWoodSpeTime * Env.GAME_FPS, self.CallWoodNpc, self, tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_1, pMengguyongshi.dwId);
			end
			local tbNpc = Npc:GetClass("elunheyuan_fight_mengguyongshi3_2");
			for nLifePercent, szTxt in pairs(tbNpc.tbText) do
				pMengguyongshi.AddLifePObserver(nLifePercent);
			end
		end
		pNpc.Delete();
		return 0; -- 第三关两个npc，如果加失败就不再尝试加了
	end
	pNpc.Delete();
	return 0;
end

-- 每10秒召唤一次木桩,第二关是一个boss，第三关是两个boss
function tbNpcYongshi_Dialog:CallWoodNpc(nBossId1, nBossId2)
	local pBoss1, pBoss2 = nil, nil;
	if nBossId1 then
		pBoss1 = KNpc.GetById(nBossId1);
	end
	if nBossId2 then
		pBoss2 = KNpc.GetById(nBossId2);
	end
	if not pBoss1 and not pBoss2 then
		return 0;
	end
	local pBoss = pBoss1 or pBoss2;
	local nSubWorld = pBoss.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	if tbInstancing.tbTollgateReset[1] ~= 0 then
		return 0;
	end
	-- 如果场上超过八个机关就先不加了，再加也没有意义
	if #tbInstancing.tbBiwuchangInfo.tbNpcWoodId >= 8 then
		tbInstancing:SendPrompt("Nhanh chóng mở các cơ quan!", 0, 1, 1, 0);
		return;
	end
	if not self.tbWoodPos or #self.tbWoodPos <= 0 then
		self.tbWoodPos = {};
		local tbFile = Lib:LoadTabFile(self.szWoodPosFile);
		if not tbFile then
			print("elunheyuan","load mengguyongshiwood failure");
			return 0;
		end
		for nIndex, tbTemp in ipairs(tbFile) do
			table.insert(self.tbWoodPos, {tonumber(tbTemp["POSX"])/32, tonumber(tbTemp["POSY"])/32});
		end
	end
	local nRand = MathRandom(#self.tbWoodPos);
	if tbInstancing.tbBiwuchangInfo.tbWoodUseInfo[nRand] == 1 then
		for i = 1, #self.tbWoodPos do
			if tbInstancing.tbBiwuchangInfo.tbWoodUseInfo[i] ~= 1 then
				nRand = i;
				break;
			end
		end
	end
	local pNpc = KNpc.Add2(9982, 110, -1, nSubWorld, self.tbWoodPos[nRand][1], self.tbWoodPos[nRand][2]);
	if not pNpc then
		return;
	end
	-- 挑一个boss喊话
	pBoss.SendChat("机关出现了，你们如果无视机关就死定了");
	table.insert(tbInstancing.tbBiwuchangInfo.tbNpcWoodId, pNpc.dwId);
	tbInstancing.tbBiwuchangInfo.tbWoodUseInfo[nRand] = 1;	
	pNpc.GetTempTable("Task").nWoodPosIndex = nRand;
	local tbNpcData = pNpc.GetTempTable("Task"); 
	tbNpcData.nBelongBossId1 = nBossId1;
	tbNpcData.nBelongBossId2 = nBossId2;
	if #tbInstancing.tbBiwuchangInfo.tbNpcWoodId > 0 then
		-- 给boss加相应层数的buff
		-- pBoss.AddSkillState(1111,1,1, 1800);
		if pBoss1 then
			pBoss1.RemoveSkillState(2555);
			pBoss1.AddSkillState(2555, #tbInstancing.tbBiwuchangInfo.tbNpcWoodId, 1, 18000);
		end
		if pBoss2 then
			pBoss2.RemoveSkillState(2555);
			pBoss2.AddSkillState(2555, #tbInstancing.tbBiwuchangInfo.tbNpcWoodId, 1, 18000);
		end
	end
	if #tbInstancing.tbBiwuchangInfo.tbNpcWoodId >= self.nBossCastSkillWoodNum then
		if pBoss1 then
			local tbNpcData = pBoss1.GetTempTable("Task"); 
			if not tbNpcData.nCastChoulanTimerId then
				tbNpcData.nCastChoulanTimerId = Timer:Register(self.nBossCastSkillSpeTime * Env.GAME_FPS, self.CastChoulanSkill, self, nBossId1);
			end
		end
		if pBoss2 then
			local tbNpcData = pBoss2.GetTempTable("Task"); 
			if not tbNpcData.nCastChoulanTimerId then
				tbNpcData.nCastChoulanTimerId = Timer:Register(self.nBossCastSkillSpeTime * Env.GAME_FPS, self.CastChoulanSkill, self, nBossId2);
			end
		end
		pBoss.SendChat("你们竟然无视我的机关，该给你们点颜色看看了");
		tbInstancing:SendPrompt("Nhanh chóng mở các cơ quan!", 0, 1, 1, 0);
	end
end

-- boss每隔一段时间释放抽蓝技能
function tbNpcYongshi_Dialog:CastChoulanSkill(nBossId)
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	local tbNpcData = pBoss.GetTempTable("Task"); 
	local nSubWorld, nX, nY = pBoss.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		tbNpcData.nCastChoulanTimerId = nil;
		return 0;
	end
	if tbInstancing.tbTollgateReset[1] ~= 0 then
		tbNpcData.nCastChoulanTimerId = nil;
		return 0;
	end
	-- 不存在超过指定数量的木桩则不再释放技能
	if not tbInstancing.tbBiwuchangInfo.tbNpcWoodId or #tbInstancing.tbBiwuchangInfo.tbNpcWoodId < self.nBossCastSkillWoodNum then
		tbNpcData.nCastChoulanTimerId = nil;
		return 0;
	end
	pBoss.CastSkill(2662, 20, nX * 32, nY * 32);
end

-- 每30秒放一个定点子弹
function tbNpcYongshi_Dialog:CastGuangquan(nNpcId, nType, nNextTime)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.SendChat(self.tbCastGuangquanChat[nType]);
	pNpc.CastSkill(self.nGuangquanType2Skill[nType][1], self.nGuangquanType2Skill[nType][2], self.tbGuangquanType2Pos[nType][1] * 32, self.tbGuangquanType2Pos[nType][2] * 32);
	return nNextTime * Env.GAME_FPS;
end

-- boss无聊的时候喊点啥
function tbNpcYongshi_Dialog:SaySomething(nNpcId, nIndex)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nSubWorld = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	-- 战斗过程中喊话，结束了不喊了
	if tbInstancing.tbTollgateReset[1] ~= 0 then
		return 0;
	end
	local tbNpcInfo = pNpc.GetTempTable("Task");
	tbNpcInfo.nChatTimes = tbNpcInfo.nChatTimes or 0;
	tbNpcInfo.nChatTimes = tbNpcInfo.nChatTimes + 1;
	local nChatIndex = math.mod(tbNpcInfo.nChatTimes, #self.tbChatInfo[nIndex]) + 1;
	pNpc.SendChat(self.tbChatInfo[nIndex][nChatIndex]);
	return MathRandom(2,5) * Env.GAME_FPS; -- 随机下次喊话的时间，防止喊话时间都同时喊太难看
end

-- 初级蒙古勇士
local tbNpcYongshi_Fight_1 = Npc:GetClass("elunheyuan_fight_mengguyongshi1");
tbNpcYongshi_Fight_1.tbText = {
	[80] = "草原之熊的咆哮足以震撼整个草原！",
	[50] = "只有击败我，我才会认可你的勇气。",
	[30] = "草原上没有熊？我以前迷路到天山获得了熊的力量你以为我会告诉你吗<pic=8>",
};

function tbNpcYongshi_Fight_1:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing:NpcSay(him.dwId, self.tbText[nLifePercent]);
end

-- 死亡时执行
function tbNpcYongshi_Fight_1:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbBiwuchangInfo.nFightMengguyongshi1 ~= him.dwId then
		return;
	end
	tbInstancing.tbBiwuchangInfo.nFightMengguyongshi1 = 0; -- 清楚初级蒙古勇士
	-- 出现特效
	local pEffectNpc = KNpc.Add2(2976, 10, -1, nSubWorld, 55232/32, 113728/32);
	assert(pEffectNpc);
	Timer:Register(5 * Env.GAME_FPS, tbNpcYongshi_Dialog.CallBoss, tbNpcYongshi_Dialog, 2, pEffectNpc.dwId);
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=9935>：“你们，身手不错。但是，空有蛮力是没有用的。放马过来，让你们见识一下草原上不只有狼，还有洞悉人心的蛇！”");
		Setting:RestoreGlobalObj();
		teammate.Msg("Tiếp tục thu phục Triết Côn.");
	end
	-- 删除接下来出场的观战npc
	if tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi2 ~= 0 then
		local pNpc = KNpc.GetById(tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi2);
		if pNpc then
			pNpc.Delete();
		end
		tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi2 = 0;
	end
	-- 如果旧的npc还存在先删掉
	if tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi1 ~= 0 then
		local pNpc = KNpc.GetById(tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi1);
		if pNpc then
			pNpc.Delete();
		end
		tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi1 = 0;
	end
	-- 添加观战npc
	local pNpc = KNpc.Add2(9938, 110, -1, nSubWorld, 54624/32, 113792/32);
	if pNpc then
		tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi1 = pNpc.dwId;
		local tbNpcData = pNpc.GetTempTable("Task"); 
		tbNpcData.nFailure = 1;	-- 战败的标志
		Timer:Register(5 * Env.GAME_FPS, tbNpcYongshi_Dialog.SaySomething, tbNpcYongshi_Dialog, pNpc.dwId, 1);
	end
end

-- 中级蒙古勇士
local tbNpcYongshi_Fight_2 = Npc:GetClass("elunheyuan_fight_mengguyongshi2");

tbNpcYongshi_Fight_2.tbText = {
	[80] = "所有的草原勇者都擅长摔跤的技巧，所谓摔跤的技巧就是我把你摔倒。"	,
	[50] = "嗯，你的资质不错，来我来教你摔跤。<pic=25>",
	[30] = "因为你们的下一个对手太过强悍，所以你们最好的选择就是输给我。",
};

function tbNpcYongshi_Fight_2:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing:NpcSay(him.dwId, self.tbText[nLifePercent]);
end

-- 死亡时执行
function tbNpcYongshi_Fight_2:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbBiwuchangInfo.nFightMengguyongshi2 ~= him.dwId then
		return;
	end
	tbInstancing.tbBiwuchangInfo.nFightMengguyongshi2 = 0; -- 清除中级蒙古勇士
	local pEffectNpc1 = KNpc.Add2(2976, 10, -1, nSubWorld, 55200/32, 113536/32);
	assert(pEffectNpc1);
	pEffectNpc1.SetLiveTime(6 * Env.GAME_FPS); -- 防止bug没删除
	Timer:Register(5 * Env.GAME_FPS, tbNpcYongshi_Dialog.CallBoss, tbNpcYongshi_Dialog, 3, pEffectNpc1.dwId);
	local pEffectNpc2 = KNpc.Add2(2976, 10, -1, nSubWorld, 55040/32, 113696/32);
	assert(pEffectNpc2);
	pEffectNpc2.SetLiveTime(6 * Env.GAME_FPS);
	Timer:Register(5 * Env.GAME_FPS, tbNpcYongshi_Dialog.CallBoss, tbNpcYongshi_Dialog, 4, pEffectNpc2.dwId);
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=9936>：“好强的身手！能够击败赫赤勒和哲昆，你们在草原上也都是有数的勇士了。来吧，放开你们的手脚，像雄鹰一样全力以赴，让我们兄弟感受一下你们真正的实力！”");
		Setting:RestoreGlobalObj();
		teammate.Msg("Tiếp tục thu phục anh em nhà Mộc Nhi.");
	end
	-- 删除机关
	for _, nWoodId in ipairs(tbInstancing.tbBiwuchangInfo.tbNpcWoodId) do
		tbInstancing:DeleteNpc(nWoodId);
	end
	tbInstancing.tbBiwuchangInfo.tbNpcWoodId = {};
	tbInstancing.tbBiwuchangInfo.tbWoodUseInfo = {};
	-- 删除接下来出战的npc，第三关有两个boss
	if tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_1 ~= 0 then
		local pNpc = KNpc.GetById(tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_1);
		if pNpc then
			pNpc.Delete();
		end
		tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_1 = 0;
	end
	if tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_2 ~= 0 then
		local pNpc = KNpc.GetById(tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_2);
		if pNpc then
			pNpc.Delete();
		end
		tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_2 = 0;
	end
	-- 重新添加挑战失败的npc
	if tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi2 ~= 0 then
		local pNpc = KNpc.GetById(tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi2);
		if pNpc then
			pNpc.Delete();
		end
		tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi2 = 0;
	end
	-- 添加观战npc
	local pNpc = KNpc.Add2(9939, 110, -1, nSubWorld, 1727, 3536);
	if pNpc then
		tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi2 = pNpc.dwId;
		local tbNpcData = pNpc.GetTempTable("Task"); 
		tbNpcData.nFailure = 1;	-- 战败的标志
		Timer:Register(5 * Env.GAME_FPS, tbNpcYongshi_Dialog.SaySomething, tbNpcYongshi_Dialog, pNpc.dwId, 2);
	end
end

-- 高级蒙古勇士1
local tbNpcYongshi_Fight_3_1 = Npc:GetClass("elunheyuan_fight_mengguyongshi3_1");
-- 过关需要清楚的负面状态
tbNpcYongshi_Fight_3_1.tbDebuffList = {2499, 2504, 2506};

tbNpcYongshi_Fight_3_1.tbText = {
	[80] = "蒙古人都是苍狼与白鹿的后代。",
	[60] = "我继承的便是苍狼的力量，狼牙撕扯你的肉体和灵魂。",
	[40] = "在我面前你最好的选择就是放弃胜利或者生命。",
	[20] = "你下手太重了混蛋！<pic=6>",	
};

function tbNpcYongshi_Fight_3_1:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing:NpcSay(him.dwId, self.tbText[nLifePercent]);
end

-- 死亡时执行
function tbNpcYongshi_Fight_3_1:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_1 ~= him.dwId then
		return;
	end
	tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_1 = 0;
	-- 重新添加挑战成功的观战npc
	if tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_1 ~= 0 then
		local pNpc = KNpc.GetById(tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_1);
		if pNpc then
			pNpc.Delete();
		end
		tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_1 = 0;
	end
	-- 添加观战npc
	local pNpc = KNpc.Add2(9940, 110, -1, nSubWorld, 1745, 3553);
	if pNpc then
		tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_1 = pNpc.dwId;
		local tbNpcData = pNpc.GetTempTable("Task"); 
		tbNpcData.nFailure = 1;	-- 战败的标志
		Timer:Register(5 * Env.GAME_FPS, tbNpcYongshi_Dialog.SaySomething, tbNpcYongshi_Dialog, pNpc.dwId, 3);
	end
	-- 另一个已经挂了则已经通关了
	if tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_2 == 0 then
		self:ChallengeSuccess(tbInstancing);
		local pKillerPlayer = pKiller.GetPlayer();
		if not pKillerPlayer then
			return 0;
		end
		Achievement:FinishAchievement(pKillerPlayer, 483);
	end
end

function tbNpcYongshi_Fight_3_1:ChallengeSuccess(tbInstancing)
	tbInstancing:ChangeTollgateState(1,2);
	tbInstancing.tbAttendPlayerList = {};
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.SetTask(1025, 57, 1);
		if (teammate.IsDead() == 1) then
			teammate.ReviveImmediately(1);
		end
		-- 清负面状态
		for _, nStateId in ipairs(self.tbDebuffList) do
			teammate.RemoveSkillState(nStateId);
		end
		teammate.SetFightState(0);
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("在草原上，勇者为尊。击败了赫赤勒，哲昆，查木儿兄弟，我们的勇气和实力赢得了蒙人的尊敬！向下一关前进吧！");
		Setting:RestoreGlobalObj();
		teammate.Msg("Khiêu chiến thành công, đến Khu Bắt Ngựa nhanh!");
	end
	-- 删除机关
	for _, nWoodId in ipairs(tbInstancing.tbBiwuchangInfo.tbNpcWoodId) do
		tbInstancing:DeleteNpc(nWoodId);
	end
	tbInstancing.tbBiwuchangInfo.tbNpcWoodId = {};
	tbInstancing.tbBiwuchangInfo.tbWoodUseInfo = {};
	for nQunzhongId, _ in pairs(tbInstancing.tbBiwuchangInfo.tbNpcQuanzhongId) do
		tbInstancing:DeleteNpc(nQunzhongId);
	end
	tbInstancing.tbBiwuchangInfo.tbNpcQuanzhongId = {};
end

-- 高级蒙古勇士2
local tbNpcYongshi_Fight_3_2 = Npc:GetClass("elunheyuan_fight_mengguyongshi3_2");

tbNpcYongshi_Fight_3_2.tbText = {
	[80] = "狼之火可以吞噬鹿角，同样的鹿之火也可以吞噬狼牙",
	[60] = "无视狼牙和鹿角的人，我也不知道会怎样，因为他们都已经死了。<pic=25>",
	[40] = "狼之火可以吞噬鹿角，同样的鹿之火也可以吞噬狼牙",
	[20] = "无视狼牙和鹿角的人，我也不知道会怎样，因为他们都已经死了。<pic=25>",	
};

function tbNpcYongshi_Fight_3_2:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	tbInstancing:NpcSay(him.dwId, self.tbText[nLifePercent]);
end

-- 死亡时执行
function tbNpcYongshi_Fight_3_2:OnDeath(pKiller)
	local nSubWorld = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_2 ~= him.dwId then
		return;
	end
	tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_2 = 0;
	-- 重新添加挑战成功的观战npc
	if tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_2 ~= 0 then
		local pNpc = KNpc.GetById(tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_2);
		if pNpc then
			pNpc.Delete();
		end
		tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_2 = 0;
	end
	-- 添加观战npc
	local pNpc = KNpc.Add2(9941, 110, -1, nSubWorld, 55072/32, 114400/32);
	if pNpc then
		tbInstancing.tbBiwuchangInfo.nDlgMengguyongshi3_2 = pNpc.dwId;
		local tbNpcData = pNpc.GetTempTable("Task"); 
		tbNpcData.nFailure = 1;	-- 战败的标志
		Timer:Register(5 * Env.GAME_FPS, tbNpcYongshi_Dialog.SaySomething, tbNpcYongshi_Dialog, pNpc.dwId, 4);
	end
	-- 另一个已经挂了则已经通关了
	if tbInstancing.tbBiwuchangInfo.nFightMengguyongshi3_1 == 0 then
		tbNpcYongshi_Fight_3_1:ChallengeSuccess(tbInstancing);
		local pKillerPlayer = pKiller.GetPlayer();
		if not pKillerPlayer then
			return 0;
		end
		Achievement:FinishAchievement(pKillerPlayer, 483);
	end
end

-- 蒙古机关
local pNpcJiguan = Npc:GetClass("elunheyuan_menggujiguan");
pNpcJiguan.nMaxOpenTimes = 15;	-- 每个玩家每一轮最多开启次数
pNpcJiguan.nOpenSpeTime = 20;	-- 每个玩家每次开启机关的间隔
function pNpcJiguan:OnDialog()
	local tbNpcData = him.GetTempTable("Task");
	if not tbNpcData.nBelongBossId1 and not tbNpcData.nBelongBossId2 then
		him.Delete();
		return 0;
	end
	local pBoss1, pBoss2 = nil, nil;
	if tbNpcData.nBelongBossId1 then
		pBoss1 = KNpc.GetById(tbNpcData.nBelongBossId1);
	end
	if tbNpcData.nBelongBossId2 then
		pBoss2 = KNpc.GetById(tbNpcData.nBelongBossId2);
	end
	local pBoss = pBoss1 or pBoss2;
	if not pBoss then
		him.Delete();
		return 0;
	end
	local nSubWorld = pBoss.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		him.Delete();
		return 0;
	end
	tbInstancing.tbBiwuchangInfo.tbPlayerOpenInfo[me.nId] = tbInstancing.tbBiwuchangInfo.tbPlayerOpenInfo[me.nId] or {};
	-- 开启次数
	tbInstancing.tbBiwuchangInfo.tbPlayerOpenInfo[me.nId].nOpenTimes = tbInstancing.tbBiwuchangInfo.tbPlayerOpenInfo[me.nId].nOpenTimes or 0;
	-- 开始时间
	tbInstancing.tbBiwuchangInfo.tbPlayerOpenInfo[me.nId].nLastTime = tbInstancing.tbBiwuchangInfo.tbPlayerOpenInfo[me.nId].nLastTime or 0;
	if tbInstancing.tbBiwuchangInfo.tbPlayerOpenInfo[me.nId].nOpenTimes > self.nMaxOpenTimes then
		Dialog:SendBlackBoardMsg(me, "Mỗi người chỉ có thể mở 5 cơ quan!");
		return 0;
	end
	if GetTime() - tbInstancing.tbBiwuchangInfo.tbPlayerOpenInfo[me.nId].nLastTime < self.nOpenSpeTime then
		Dialog:SendBlackBoardMsg(me, "Bạn vừa mở cơ quan rồi, hãy để người khác mở!");
		return 0;
	end
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
	}
	GeneralProcess:StartProcess("Đang mở...", 1 * Env.GAME_FPS, 
			{self.CloseJiguan, self, him.dwId, tbNpcData.nBelongBossId1, tbNpcData.nBelongBossId2}, 
			nil, 
			tbEvent);
end

function pNpcJiguan:CloseJiguan(nNpcId, nBossId1, nBossId2)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local nPosIndex = pNpc.GetTempTable("Task").nWoodPosIndex or 0;
	pNpc.Delete();
	local pBoss1, pBoss2 = nil, nil;
	if nBossId1 then
		pBoss1 = KNpc.GetById(nBossId1);
	end
	if nBossId2 then
		pBoss2 = KNpc.GetById(nBossId2);
	end
	if not pBoss1 and not pBoss2 then
		return 0;
	end
	local pBoss = pBoss1 or pBoss2;
	local nSubWorld = pBoss.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 从npc列表中删除
	local nIndex = 0;
	for i, nWoodId in ipairs(tbInstancing.tbBiwuchangInfo.tbNpcWoodId) do
		if nWoodId == nNpcId then
			nIndex = i;
			break;
		end
	end
	if nIndex <= 0 then
		return;
	end
	table.remove(tbInstancing.tbBiwuchangInfo.tbNpcWoodId, nIndex);
	tbInstancing.tbBiwuchangInfo.tbWoodUseInfo[nPosIndex] = nil;
	if #tbInstancing.tbBiwuchangInfo.tbNpcWoodId > 0 then
		-- 重新给boss上响应层数的buff
		if pBoss1 then
			pBoss1.RemoveSkillState(2555);
			pBoss1.AddSkillState(2555, #tbInstancing.tbBiwuchangInfo.tbNpcWoodId, 1, 18000);
		end
		if pBoss2 then
			pBoss2.RemoveSkillState(2555);
			pBoss2.AddSkillState(2555, #tbInstancing.tbBiwuchangInfo.tbNpcWoodId, 1, 18000);
		end
	else
		-- 删除boss的buff
		if pBoss1 then
			pBoss1.RemoveSkillState(2555);
		end
		if pBoss2 then
			pBoss2.RemoveSkillState(2555);
		end
	end
	tbInstancing.tbBiwuchangInfo.tbPlayerOpenInfo[me.nId].nOpenTimes = tbInstancing.tbBiwuchangInfo.tbPlayerOpenInfo[me.nId].nOpenTimes + 1;
	tbInstancing.tbBiwuchangInfo.tbPlayerOpenInfo[me.nId].nLastTime = GetTime();
end

