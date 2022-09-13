-- 文件名　：qixi2012_gs.lua
-- 创建者　：huangxiaoming
-- 创建时间：2012-08-10 14:10:10
-- 描  述  ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201208_qixi\\qixi2012_def.lua");
SpecialEvent.QiXi2012 = SpecialEvent.QiXi2012 or {};
local tbQiXi2012 = SpecialEvent.QiXi2012 or {};

-- 是否在活动时间内
function tbQiXi2012:CheckActivityTime()
	local nNowTime = tonumber(GetLocalDate("%H%M%S"));
	if nNowTime >= self.DAY_OPEN_TIME1 and nNowTime <= self.DAY_CLOSE_TIME1 then
		return 1;
	end
	if nNowTime >= self.DAY_OPEN_TIME2 and nNowTime <= self.DAY_CLOSE_TIME2 then
		return 1;
	end
	return 0;
end

-- 能否领取活动道具
function tbQiXi2012:CheckCanAcceptSeed(pPlayer)
	if self:CheckActivityTime() ~= 1 then
		return 0, "活动时间未到，2012.8.21-2012.8.27的11:00~15:00、18:00~23：00期间才可领取前世之物。";
	end
	if pPlayer.nLevel < self.LIMIT_LEVEL or pPlayer.nFaction <= 0 then
		return 0, "只有50级以上并且加入门派的侠士才能才可领取前世之物。";
	end
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_LAST_ACCEPT_DAY) >= nDate then
		return 0, "每个玩家每天只能领取1次，你今天已经领取过了。";
	end
	local nFreeCount = pPlayer.CountFreeBagCell();
	local nNeedCount = self.NUM_SEED;
	if pPlayer.nSex == 1 then
		nNeedCount = self.NUM_GRAP
	end
	if nFreeCount < nNeedCount then
		return -2, string.format("Hành trang không đủ chỗ trống,需要<color=yellow>%s个<color>背包空间。", nNeedCount);
	end 
	return 1;
end


-- 随机四种图案
function tbQiXi2012:RandGrap()
	local tbRand = {};
	for i = 1, self.MAX_GRAP_LEVEL do
		tbRand[i] = i;
	end
	Lib:SmashTable(tbRand);
	local tbItem = {};
	for i = 1, self.NUM_GRAP do
		tbItem[i] = {};
		tbItem[i][1] = self.ITEMID_GRAP[1];
		tbItem[i][2] = self.ITEMID_GRAP[2];
		tbItem[i][3] = self.ITEMID_GRAP[3];
		tbItem[i][4] = tbRand[i];
	end
	return tbItem;
end

-- 获取组队的另一方,必须是男女两人队伍
function tbQiXi2012:GetPartner(pPlayer)
	if pPlayer.nTeamId <= 0 then
		return nil;
	end
	local _, nTeamCount = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	if nTeamCount ~= 2 then
		return ni;
	end
	local tbTeamMembers, nMemberCount = pPlayer.GetTeamMemberList();
	if nMemberCount ~= 2 then
		return nil;
	end
	
	if tbTeamMembers[1].nSex == tbTeamMembers[2].nSex then
		return nil;
	end
	if tbTeamMembers[1].nId == pPlayer.nId then
		return tbTeamMembers[2];
	end
	return tbTeamMembers[1];
end

-- 检查能否种下玫瑰种子
function tbQiXi2012:CheckCanPlant(pPlayer)
	if self:CheckActivityTime() ~= 1 then
		return 0, "现在不是活动时间";
	end
	local szMapTyp = GetMapType(pPlayer.nMapId);
	if szMapTyp ~= "fight" then
		return 0, "与纳兰吟心对话穿越时光之门后才可以种下玫瑰";
	end
	if pPlayer.nSex ~= 0 then -- 女性不可能有种子
		return 0;
	end
	if GetTime() - pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME) <= self.PLANT_INTERVAL then
		return 0, "你的上次种植还未完成或采摘，需要间隔20分钟才能再次种植。"
	end
	local pGirl = self:GetPartner(pPlayer);
	if not pGirl then
		return 0, "只有与你的有缘人双人组队且在周围，才能种下玫瑰";
	end
	if GetTime() - pGirl.GetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME) <= self.PLANT_INTERVAL then
		return 0, "你的前世有缘人还有未完成或采摘的种植，需要20分钟间隔。"
	end
	local nMapId1, nPosX1, nPosY1 = pPlayer.GetWorldPos();
	local nMapId2, nPosX2, nPosY2 = pGirl.GetWorldPos();
	if nMapId1 ~= nMapId2 then
		return 0, "你的前世有缘人离你太远了，无法种植";
	end
	if (nPosX1 - nPosX2) * (nPosX1 - nPosX2) + (nPosY1 - nPosY2) * (nPosY1 - nPosY2) > self.MAX_PLANT_RANGE * self.MAX_PLANT_RANGE then
		return 0, "你的前世有缘人离你太远了，无法种植";
	end
	-- 男玩家查找有没有种子
	local nSeedCount = pPlayer.GetItemCountInBags(unpack(self.ITEMID_SEED));
	if nSeedCount <= 0 then
		return 0;
	end
	-- 女玩家查找有没有图
	local tbGrapSet = pGirl.FindClassItemInBags("qixi2012_grap");
	if #tbGrapSet <= 0 then
		return 0, "你的前世有缘人没有携带玫瑰阵图，无法种植";
	end
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, self.MAX_FREE_RANGE);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or pNpc.nKind == 4 or pNpc.nKind == 8 then
			return 0, "这里太拥挤了，换个地方再种吧";
		end
	end
	return 1;
end

function tbQiXi2012:IsRedRose(nLevel, nIndex)
	if not self.ROSE_COLORSET[nLevel] then
		return 0;
	end
	for i = 1, #self.ROSE_COLORSET[nLevel] do
		if self.ROSE_COLORSET[nLevel][i] == nIndex then
			return 1;
		end
	end
	return 0;
end

-- 种植玫瑰
function tbQiXi2012:PlantSeed(nPlayerId)
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nRet, szMsg = self:CheckCanPlant(pPlayer);
	if nRet ~= 1 then
		if szMsg then
			Dialog:SendInfoBoardMsg(pPlayer, szMsg);
			pPlayer.Msg(szMsg);
		end
		return 0;
	end
	local pGirl = self:GetPartner(pPlayer);
	if not pGirl then
		return 0;
	end
	local tbGrapSet = pGirl.FindClassItemInBags("qixi2012_grap");
	if #tbGrapSet <= 0 then
		return 0;
	end
	if self.tbRoseList[nPlayerId] and #self.tbRoseList[nPlayerId] > 0 then
		print("qixi2012", "err tbroselist is exist", nPlayerId, pPlayer.szName);
		return 0;
	end
	local nCount = pPlayer.ConsumeItemInBags(1, self.ITEMID_SEED[1], self.ITEMID_SEED[2], self.ITEMID_SEED[3], self.ITEMID_SEED[4], -1);
	if nCount ~= 0 then
		print("qixi2012", "consume seed fail", pPlayer.szName);
		return 0;
	end
	local nIndex = MathRandom(#tbGrapSet);
	local nLevel = tbGrapSet[nIndex].pItem.nLevel; -- 根据level摆图案
	pGirl.DelItem(tbGrapSet[nIndex].pItem);
	local pGrapUsed = pGirl.AddItem(self.ITEMID_GRAP_USED[1], self.ITEMID_GRAP_USED[2], self.ITEMID_GRAP_USED[3], nLevel);
	if pGrapUsed then
		pGrapUsed.Bind(1);
		pGirl.SetItemTimeout(pGrapUsed,os.date("%Y/%m/%d/%H/%M/%S", GetTime() + self.SEED_DURATION_TIME));
		pGrapUsed.Sync();
	else
		print("qixi2012", "add grapused fail", pGirl.szName);
	end
	self.tbRoseList[nPlayerId] = {};
	local nTimerId = Timer:Register(self.SEED_DURATION_TIME * 18, self.SeedOverdue, self, nPlayerId);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME, GetTime());
	pGirl.SetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME, GetTime());
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
	for i = 1, #self.ROSE_OFFSET do
		local pNpc = KNpc.Add2(self.NPCID_ROSE_SEED, 120, -1, nMapId, nPosX + self.ROSE_OFFSET[i][1], nPosY + self.ROSE_OFFSET[i][2]);
		if pNpc then
			pNpc.GetTempTable("Npc").tbSeedInfo = {};
			pNpc.GetTempTable("Npc").tbSeedInfo.nShapeId = nLevel;
			pNpc.GetTempTable("Npc").tbSeedInfo.nSeedColor = self.COLOR_TYPE_PINK; -- 记录种子颜色
			if self:IsRedRose(nLevel, i) == 1 then
				pNpc.GetTempTable("Npc").tbSeedInfo.nSeedColor = self.COLOR_TYPE_RED;
			end
			pNpc.GetTempTable("Npc").tbSeedInfo.nBoyId = nPlayerId;
			pNpc.GetTempTable("Npc").tbSeedInfo.nGirlId = pGirl.nId;
			pNpc.GetTempTable("Npc").tbSeedInfo.nTimerId = nTimerId;
			pNpc.GetTempTable("Npc").tbSeedInfo.nMapId = nMapId;
			pNpc.GetTempTable("Npc").tbSeedInfo.nPosX = nPosX;
			pNpc.GetTempTable("Npc").tbSeedInfo.nPosY = nPosY;
			pNpc.SetLiveTime(4* 3600 * 18);
			table.insert(self.tbRoseList[nPlayerId], pNpc.dwId);
		end
	end
	-- 检查一下是否所有npc都Call出来了，有可能边界call不出来
	if #self.tbRoseList[nPlayerId] < #self.ROSE_OFFSET then
		for _, nNpcId in pairs(self.tbRoseList[nPlayerId]) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
			end
		end
		self.tbRoseList[nPlayerId] = nil;
		Timer:Close(nTimerId);
		Dialog:SendBlackBoardMsg(pPlayer, "这里太拥挤了，换个地方种把");
		pPlayer.Msg("这里太拥挤了，换个地方种把");
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME, 0);
		pGirl.SetTask(Self.TASK_GROUP_ID, self.TASK_PLANT_TIME, 0);
		return 0;
	end
	local szBoyName = self:GetQianshiName(pPlayer);
	local szGirlName = self:GetQianshiName(pGirl);
	local szBoyMsg = string.format("你已为<color=pink>%s<color>种下玫瑰，点击种子可对其浇灌", szGirlName);
	local szGirlMsg = string.format("玫瑰阵图已打开，请按阵图帮助<color=pink>%s<color>浇灌红玫瑰", szBoyName);
	Dialog:SendBlackBoardMsg(pPlayer, szBoyMsg);
	pPlayer.Msg(szBoyMsg);
	Dialog:SendBlackBoardMsg(pGirl, szGirlMsg);
	pGirl.Msg(szGirlMsg);
	StatLog:WriteStatLog("stat_info", "qixi_2012", "plant", pPlayer.nId, pGirl.szName, 1);
end

function tbQiXi2012:GetQianshiName(pPlayer)
	local nType = pPlayer.GetSkillState(2764);
	return self.TYPE2NAME[nType] or pPlayer.szName;
end

-- 检查能否浇灌种子
function tbQiXi2012:CheckCandSeedPlant2Rose(dwNpcId, nPlayerId)
	local pSeed = KNpc.GetById(dwNpcId);
	if not pSeed then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbSeedInfo = pSeed.GetTempTable("Npc").tbSeedInfo;
	if not tbSeedInfo then
		return 0;
	end
	if tbSeedInfo.nBoyId ~= nPlayerId then
		return 0;
	end
	local pGirl = self:GetPartner(pPlayer);
	if not pGirl then
		return 0, "只有与你的有缘人双人组队且在周围，才能浇灌种子";
	end
	if tbSeedInfo.nGirlId ~= pGirl.nId then
		return 0, "对方不是你的有缘人，无法浇灌";
	end
	local nMapId1, nPosX1, nPosY1 = pPlayer.GetWorldPos();
	local nMapId2, nPosX2, nPosY2 = pGirl.GetWorldPos();
	if nMapId1 ~= nMapId2 then
		return 0, "对方离你太远，无法浇灌";
	end
	if (nPosX1 - nPosX2) * (nPosX1 - nPosX2) + (nPosY1 - nPosY2) * (nPosY1 - nPosY2) > self.MAX_PLANT_RANGE * self.MAX_PLANT_RANGE then
		return 0, "对方离你太远，无法浇灌";
	end
	local nGrapCount = pGirl.GetItemCountInBags(self.ITEMID_GRAP_USED[1], self.ITEMID_GRAP_USED[2], self.ITEMID_GRAP_USED[3], tbSeedInfo.nShapeId);
	if nGrapCount <= 0 then
		return 0, "对方没有携带阵图，无法浇灌";
	end
	return 1;
end

-- 种子变玫瑰
function tbQiXi2012:SeedPlant2Rose(dwNpcId, nPlayerId, nFlag)
	local pOldSeed = KNpc.GetById(dwNpcId);
	if not pOldSeed then
		return;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local nRet, szPrompt = self:CheckCandSeedPlant2Rose(dwNpcId, nPlayerId);
	if nRet ~= 1 then
		if szPrompt then
			Dialog:SendInfoBoardMsg(pPlayer, szPrompt);
			pPlayer.Msg(szPrompt);
		end
		return;
	end
	local tbSeedInfo = pOldSeed.GetTempTable("Npc").tbSeedInfo;
	if not tbSeedInfo then
		return;
	end
	local pGirl = KPlayer.GetPlayerObjById(tbSeedInfo.nGirlId);
	if not pGirl then
		return;
	end
	if not self.tbRoseList[nPlayerId] then
		print("qixi2012", "找不到种子索引表");
		return;
	end
	local nIndex = 0;
	for i, nId in pairs(self.tbRoseList[nPlayerId]) do
		if nId == dwNpcId then
			nIndex = i;
			break;
		end
	end
	if nIndex <= 0 then
		print("qixi2012", "无效的种子");
		return;
	end
	if not nFlag then
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
		GeneralProcess:StartProcess("浇灌中", 5 * Env.GAME_FPS, 
			{self.SeedPlant2Rose, self, dwNpcId, nPlayerId, 1}, nil, tbEvent);
		return
	end
	local nRoseId = self.NPCID_ROSE_RED;
	if tbSeedInfo.nSeedColor == self.COLOR_TYPE_PINK then
		nRoseId = self.NPCID_ROSE_PINK;
	end
	-- 把有用的信息都保存下来
	local nMapId, nPosX, nPosY = pOldSeed.GetWorldPos();
	local nTimerId = tbSeedInfo.nTimerId;
	local nBoyId = tbSeedInfo.nBoyId;
	local nGirlId = tbSeedInfo.nGirlId;
	local nShapeId = tbSeedInfo.nShapeId;
	local nSeedColor = tbSeedInfo.nSeedColor;
	local nPlayerMapId = tbSeedInfo.nMapId; 
	local nPlayerPosX = tbSeedInfo.nPosX;
	local nPlayerPosY = tbSeedInfo.nPosY;
	local pRose = KNpc.Add2(nRoseId, 120, -1, nMapId, nPosX, nPosY);
	if not pRose then -- 先加npc，如果加不出来就失败不继续执行
		pPlayer.Msg("浇灌失败，请重新浇");
		Dialog:SendBlackBoardMsg(pPlayer, "浇灌失败，请重新浇灌");
		return;
	end
	pRose.SetLiveTime(10 * 3600 * 18);
	pOldSeed.Delete();
	self.tbRoseList[nPlayerId][nIndex] = pRose.dwId;
	
	local nPinkRoseNum = 0;
	local nRedRoseNum = 0;
	for i = 1, #self.tbRoseList[nPlayerId] do
		local pNpc = KNpc.GetById(self.tbRoseList[nPlayerId][i]);
		if not pNpc then
			return 0;
		end
		if pNpc.nTemplateId == self.NPCID_ROSE_RED then
			nRedRoseNum = nRedRoseNum + 1;
		elseif pNpc.nTemplateId == self.NPCID_ROSE_PINK then
			nPinkRoseNum = nPinkRoseNum + 1;
		end
	end
	local szBoyName = self:GetQianshiName(pPlayer);
	local szGirlName = self:GetQianshiName(pGirl);
	if nRedRoseNum >= self.SUCCEED_REDROSE_NUM then -- 成功采到9朵红玫瑰
		Timer:Close(nTimerId);
		for _, nNpcId in pairs(self.tbRoseList[nPlayerId]) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
			end
		end
		self.tbRoseList[nPlayerId] = nil;
		local nConsume = pGirl.ConsumeItemInBags(1, self.ITEMID_GRAP_USED[1], self.ITEMID_GRAP_USED[2], self.ITEMID_GRAP_USED[3], nShapeId, -1);
		if nConsume ~= 0 then
			print("tbQiXi2012", "consume grap fail", pGirl.szName);
			return;
		end
		self.tbAwardRoseList[nPlayerId] = {};
		pPlayer.NewWorld(nPlayerMapId, nPlayerPosX, nPlayerPosY);-- 男女飞回来一起享受鲜花盛开
		pGirl.NewWorld(nPlayerMapId, nPlayerPosX, nPlayerPosY);
		local szSuccessMsg = "你们完成了浇灌，真爱红玫瑰已盛开，快去采集吧";
		Dialog:SendBlackBoardMsg(pPlayer, szSuccessMsg);
		Dialog:SendBlackBoardMsg(pGirl, szSuccessMsg);
		pPlayer.Msg(szSuccessMsg);
		pGirl.Msg(szSuccessMsg);
		pPlayer.CallClientScript({"SpecialEvent.QiXi2012:OpenTimer", self.SKILLID_EFFECT, self.EFFECT_DURATION});
		pGirl.CallClientScript({"SpecialEvent.QiXi2012:OpenTimer", self.SKILLID_EFFECT, self.EFFECT_DURATION});
		-- 盛开鲜花,起12个定时器，
		for i = 1, #self.AWARDROSE_OFFSET do
			Timer:Register(self.AWARDROSE_OFFSET[i][3], self.AddAwardRose, self, nPlayerId, nGirlId, nPlayerMapId, nPlayerPosX + self.AWARDROSE_OFFSET[i][1], nPlayerPosY + self.AWARDROSE_OFFSET[i][2]);
		end
		return;
	elseif nPinkRoseNum >= self.FAILURE_PINKROSE_NUM then -- 采集到了3朵粉玫瑰
		-- 还在活动时间内继续刷，过了活动时间就不刷了
		if self:CheckActivityTime() == 1 then
			Timer:Close(nTimerId);
			nTimerId = Timer:Register(self.SEED_DURATION_TIME * 18, self.SeedOverdue, self, nPlayerId);
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME, GetTime());
			pGirl.SetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME, GetTime());
			local tbNpcIdSet = {};
			for _, nNpcId in pairs(self.tbRoseList[nPlayerId]) do
				local pNpc = KNpc.GetById(nNpcId);
				if pNpc then -- 把NPC重新变为种子
					if pNpc.nTemplateId == self.NPCID_ROSE_RED or pNpc.nTemplateId == self.NPCID_ROSE_PINK then
						local nColroType = self.COLOR_TYPE_RED;
						if pNpc.nTemplateId == self.NPCID_ROSE_PINK then
							nColroType = self.COLOR_TYPE_PINK;
						end
						local nRoseMapId, nRosePosX, nRosePosY = pNpc.GetWorldPos();
						pNpc.Delete();
						local pSeed = KNpc.Add2(self.NPCID_ROSE_SEED, 120, -1, nRoseMapId, nRosePosX, nRosePosY);
						if pSeed then
							pSeed.GetTempTable("Npc").tbSeedInfo = {};
							pSeed.GetTempTable("Npc").tbSeedInfo.nShapeId = nShapeId;
							pSeed.GetTempTable("Npc").tbSeedInfo.nSeedColor = nColroType;
							pSeed.GetTempTable("Npc").tbSeedInfo.nBoyId = nPlayerId;
							pSeed.GetTempTable("Npc").tbSeedInfo.nGirlId = pGirl.nId;
							pSeed.GetTempTable("Npc").tbSeedInfo.nTimerId = nTimerId;
							pSeed.GetTempTable("Npc").tbSeedInfo.nMapId = nPlayerMapId;
							pSeed.GetTempTable("Npc").tbSeedInfo.nPosX = nPlayerPosX;
							pSeed.GetTempTable("Npc").tbSeedInfo.nPosY = nPlayerPosY;
							pSeed.SetLiveTime(10 * 3600 * 18); -- 设置一个有效期防止NPC无限期存在
							table.insert(tbNpcIdSet, pSeed.dwId);
						end
					else
						pNpc.GetTempTable("Npc").tbSeedInfo.nTimerId = nTimerId;
						table.insert(tbNpcIdSet, pNpc.dwId);
					end
				end
			end
			self.tbRoseList[nPlayerId] = tbNpcIdSet;
			pPlayer.Msg("浇灌失败，请重新再来");
			Dialog:SendBlackBoardMsg(pPlayer, "浇灌失败，请重新再来");
			pGirl.Msg("浇灌失败，请重新再来");
			Dialog:SendBlackBoardMsg(pGirl, "浇灌失败，请重新再来");
			StatLog:WriteStatLog("stat_info", "qixi_2012", "fail", pPlayer.nId, pGirl.szName, 1);
		else
			Timer:Close(nTimerId);
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME, 0);
			pGirl.SetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME, 0);
			for _, nNpcId in pairs(self.tbRoseList[nPlayerId]) do
				local pNpc = KNpc.GetById(nNpcId);
				if pNpc then
					pNpc.Delete();
				end
			end
			self.tbRoseList[nPlayerId] = nil;
			pPlayer.Msg("浇灌失败，活动时间已过，下次努力吧");
			Dialog:SendBlackBoardMsg(pPlayer, "浇灌失败，活动时间已过，下次努力吧");
			pGirl.Msg("浇灌失败，活动时间已过，下次努力吧");
			Dialog:SendBlackBoardMsg(pGirl, "浇灌失败，活动时间已过，下次努力吧");
		end
		return;
	end
	local szResultMsg = "";
	if nSeedColor == self.COLOR_TYPE_RED then
		szResultMsg = string.format("恭喜<color=pink>%s<color>浇灌出一朵红玫瑰，继续努力吧！", szBoyName);
	else
		szResultMsg = string.format("很遗憾<color=pink>%s<color>浇灌出的是粉玫瑰，再接再厉！", szBoyName);
	end
	pPlayer.Msg(szResultMsg);
	Dialog:SendBlackBoardMsg(pPlayer, szResultMsg);
	pGirl.Msg(szResultMsg);
	Dialog:SendBlackBoardMsg(pGirl, szResultMsg);
end

function tbQiXi2012:AddAwardRose(nBoyId, nGirlId, nMapId, nPosX, nPosY)
	if not self.tbAwardRoseList[nBoyId] then -- 奖励npc表不存在了说明已经领奖了
		return 0;
	end
	local pNpc = KNpc.Add2(self.NPCID_ROSE_AWARD, 120, -1, nMapId, nPosX, nPosY);
	if pNpc then
		pNpc.GetTempTable("Npc").tbAwardInfo = {};
		pNpc.GetTempTable("Npc").tbAwardInfo.nBoyId = nBoyId;
		pNpc.GetTempTable("Npc").tbAwardInfo.nGirlId = nGirlId;
		local nTimerId = Timer:Register(self.AWARD_DURATION_TIME * 18, self.DeleteAwardNpcTimer, self, pNpc.dwId, nBoyId);
		pNpc.GetTempTable("Npc").tbAwardInfo.nTimerId = nTimerId;
		pNpc.GetTempTable("Npc").tbAwardInfo.nAwardFlag = 0;
		pNpc.SetLiveTime(20 * 60 * 18); --- 设一个生存时间，防止计时器错误没有删除
		table.insert(self.tbAwardRoseList[nBoyId], pNpc.dwId);
	end
	return 0;
end

function tbQiXi2012:DeleteAwardNpcTimer(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then 
		return 0;
	end
	local tbInfo = pNpc.GetTempTable("Npc").tbAwardInfo;
	local nFlag = 1;
	if tbInfo and tbInfo.nAwardFlag then
		nFlag = tbInfo.nAwardFlag;
	end
	pNpc.Delete();
	if nFlag == 1 then
		return 0;
	end
	if self.tbAwardRoseList[nPlayerId] then
		-- 从奖励npc表中移除
		local nIndex = 0;
		for i, nNpcId in pairs(self.tbAwardRoseList[nPlayerId]) do
			if nNpcId == dwNpcId then
				nIndex = i;
			end
		end
		if nIndex > 0 then
			table.remove(self.tbAwardRoseList[nPlayerId], nIndex);
		end
		if #self.tbAwardRoseList[nPlayerId] == 0 then
			self.tbAwardRoseList[nPlayerId] = nil;
		end
	end
	return 0;
end

-- 检查是否收起种子
function tbQiXi2012:CheckCancelPlant(dwNpcId, nPlayerId)
	local pSeed = KNpc.GetById(dwNpcId);
	if not pSeed then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbSeedInfo = pSeed.GetTempTable("Npc").tbSeedInfo;
	if not tbSeedInfo then
		return 0;
	end
	if tbSeedInfo.nBoyId ~= nPlayerId then
		return 0;
	end
	local pGirl = self:GetPartner(pPlayer);
	if not pGirl then
		return 0, "只有与你的有缘人双人组队且在周围，才能回收种子";
	end
	if tbSeedInfo.nGirlId ~= pGirl.nId then
		return 0, "对方不是你的有缘人，无法回收种子";
	end
	local nMapId1, nPosX1, nPosY1 = pPlayer.GetWorldPos();
	local nMapId2, nPosX2, nPosY2 = pGirl.GetWorldPos();
	if nMapId1 ~= nMapId2 then
		return 0, "队伍成员必须在附近才可以回收种子";
	end
	if (nPosX1 - nPosX2) * (nPosX1 - nPosX2) + (nPosY1 - nPosY2) * (nPosY1 - nPosY2) > self.MAX_PLANT_RANGE * self.MAX_PLANT_RANGE then
		return 0, "队伍成员必须在附近才可以回收种子";
	end
	local nGrapCount = pGirl.GetItemCountInBags(self.ITEMID_GRAP_USED[1], self.ITEMID_GRAP_USED[2], self.ITEMID_GRAP_USED[3], tbSeedInfo.nShapeId);
	if nGrapCount <= 0 then
		return 0, "对方没有玫瑰阵图，无法回收种子";
	end
	if pPlayer.CountFreeBagCell() < 1  then
		return 0, "你的背包空间不足，无法收起";
	end
	if pGirl.CountFreeBagCell() < 1 then
		return 0, "对方背包空间不足，无法收起"
	end
	return 1;
end

-- 收起种子
function tbQiXi2012:CancelPlant(dwNpcId, nPlayerId)
	local pSeed = KNpc.GetById(dwNpcId);
	if not pSeed then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nRet, szPrompt = self:CheckCancelPlant(dwNpcId, nPlayerId);
	if nRet ~= 1 then
		if szPrompt then
			Dialog:SendInfoBoardMsg(pPlayer, szPrompt);
			pPlayer.Msg(szPrompt);
			return 0;
		end
	end
	local tbSeedInfo = pSeed.GetTempTable("Npc").tbSeedInfo;
	if not tbSeedInfo then
		return;
	end
	local nTimerId = tbSeedInfo.nTimerId;
	local pGirl = self:GetPartner(pPlayer);
	if not pGirl then
		return 0;
	end
	if not tbQiXi2012.tbRoseList[nPlayerId] then
		return;
	end
	-- 删除所有npc并给玩家加种子
	for _, nNpcId in pairs(tbQiXi2012.tbRoseList[nPlayerId]) do
		local pTemp = KNpc.GetById(nNpcId);
		if pTemp then
			pTemp.Delete();
		end
	end
	self.tbRoseList[nPlayerId] = nil;
	Timer:Close(nTimerId);
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	local nValidTime = Lib:GetDate2Time(nDate) + 24 * 3600 - 1;
	local pItem1 = pPlayer.AddItem(unpack(tbQiXi2012.ITEMID_SEED));
	if pItem1 then
		pItem1.Bind(1);
		pPlayer.SetItemTimeout(pItem1, os.date("%Y/%m/%d/%H/%M/%S", nValidTime));
		pItem1.Sync();
	else
		print("qixi2012", "fanhuan seed fail", pPlayer.szName);
	end
	pGirl.ConsumeItemInBags(1, self.ITEMID_GRAP_USED[1], self.ITEMID_GRAP_USED[2], self.ITEMID_GRAP_USED[3], tbSeedInfo.nShapeId, -1);
	local pItem2 = pGirl.AddItem(self.ITEMID_GRAP[1], self.ITEMID_GRAP[2], self.ITEMID_GRAP[3], tbSeedInfo.nShapeId);
	if pItem2 then
		pItem2.Bind(1);
		pGirl.SetItemTimeout(pItem2, os.date("%Y/%m/%d/%H/%M/%S", nValidTime));
		pItem2.Sync();
	else
		print("qixi2012", "fanhuan grap fail", pGirl.szName);
	end
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME, 0);
	pGirl.SetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME, 0);
	local szBoyName = self:GetQianshiName(pPlayer);
	local szMsg = string.format("<color=pink>%s<color>回收了种子，请重新种植。", szBoyName);
	Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	Dialog:SendBlackBoardMsg(pGirl, szMsg);
	pPlayer.Msg(szMsg);
	pGirl.Msg(szMsg);
end

-- 检查是否能够领奖
function tbQiXi2012:CheckCanGetAward(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbAwardInfo = pNpc.GetTempTable("Npc").tbAwardInfo;
	if not tbAwardInfo then
		return 0;
	end
	if tbAwardInfo.nBoyId ~= nPlayerId and tbAwardInfo.nGirlId ~= nPlayerId then
		return 0, "这不是你们的真爱玫瑰";
	end
	local pPartner = self:GetPartner(pPlayer);
	if not pPartner then
		return 0, "只有与你的有缘人双人组队且在周围，才能采摘真爱之花";
	end
	if tbAwardInfo.nBoyId ~= pPartner.nId and tbAwardInfo.nGirlId ~= pPartner.nId then
		return 0, "请与你的前世有缘人组队后再来采摘真爱之花";
	end
	local nMapId1, nPosX1, nPosY1 = pPlayer.GetWorldPos();
	local nMapId2, nPosX2, nPosY2 = pPartner.GetWorldPos();
	if nMapId1 ~= nMapId2 then
		return 0, "你的前世有缘人必须在附近才可以采摘真爱玫瑰";
	end
	if (nPosX1 - nPosX2) * (nPosX1 - nPosX2) + (nPosY1 - nPosY2) * (nPosY1 - nPosY2) > self.MAX_PLANT_RANGE * self.MAX_PLANT_RANGE then
		return 0, "你的前世有缘人必须在附近才可以采摘真爱玫瑰";
	end
	if pPlayer.CountFreeBagCell() < 1 or pPartner.CountFreeBagCell() < 1 then
		return 0, "你或队友的背包空间不足";
	end
	return 1;
end

-- 领取奖励
function tbQiXi2012:GetAward(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local nRet, szPrompt = self:CheckCanGetAward(dwNpcId, nPlayerId);
	if nRet ~= 1 then
		if szPrompt then
			Dialog:SendBlackBoardMsg(pPlayer, szPrompt);
			pPlayer.Msg(szPrompt);
		end
		return;
	end
	local tbAwardInfo = pNpc.GetTempTable("Npc").tbAwardInfo;
	if not tbAwardInfo then
		return;
	end
	local pPartner = self:GetPartner(pPlayer);
	if not pPartner then
		return;
	end
	local nRoseListIndex = nPlayerId;
	if pPlayer.nSex == 1 then
		nRoseListIndex = pPartner.nId;
	end
	if not self.tbAwardRoseList[nRoseListIndex] then
		print("tbQiXi2012", "找不到奖励玫瑰表");
		return;
	end
	for _, nAwardId in pairs(self.tbAwardRoseList[nRoseListIndex]) do
		local pAwardedNpc = KNpc.GetById(nAwardId);
		if pAwardedNpc then
			pAwardedNpc.GetTempTable("Npc").tbAwardInfo.nAwardFlag = 1; -- 设置已领奖标记
		end
	end
	self.tbAwardRoseList[nRoseListIndex] = nil; -- 那一批玫瑰等着时间到自动消失
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME, 0);
	pPartner.SetTask(self.TASK_GROUP_ID, self.TASK_PLANT_TIME, 0);
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	local nValidTime = Lib:GetDate2Time(nDate) + 24 * 3600 - 1;
	local pItem1 = pPlayer.AddItem(unpack(self.ITEMID_AWARDROSE));
	if pItem1 then
		pItem1.Bind(1);
		pPlayer.SetItemTimeout(pItem1, os.date("%Y/%m/%d/%H/%M/%S", nValidTime));
		pItem1.Sync();
		Dialog:SendBlackBoardMsg(pPlayer, "成功采集到1朵真爱玫瑰");
		pPlayer.Msg("成功采集到1朵真爱玫瑰");
	else
		print("qixi2012", "add awardrose fail", pPlayer.szName);
	end
	local pItem2 = pPartner.AddItem(unpack(self.ITEMID_AWARDROSE));
	if pItem2 then
		pItem2.Bind(1);
		pPartner.SetItemTimeout(pItem2, os.date("%Y/%m/%d/%H/%M/%S", nValidTime));
		pItem2.Sync();
		Dialog:SendBlackBoardMsg(pPartner, "成功采集到1朵真爱玫瑰");
		pPartner.Msg("成功采集到1朵真爱玫瑰");
	else
		print("qixi2012", "add awardrose fail", pPartner.szName);
	end
	StatLog:WriteStatLog("stat_info", "qixi_2012", "finish", pPlayer.nId, pPartner.szName, 1);
end

-- 过期处理
function tbQiXi2012:SeedOverdue(nPlayerId)
	if self.tbRoseList[nPlayerId] and #self.tbRoseList[nPlayerId] > 0 then
		for _, nNpcId in pairs(self.tbRoseList[nPlayerId]) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
			end
		end
		self.tbRoseList[nPlayerId] = nil;
	end
	return 0;
end

-- 随机奖励
function tbQiXi2012:RandomAward(pPlayer, tbAward)
	local nRate = MathRandom(1000000);
	local nAdd = 0;
	local nFind = 0;
	for i, tbInfo in ipairs(tbAward) do
		nAdd = nAdd + tbInfo[3];
		if nRate <= nAdd then
			nFind = i;
			break;
		end
	end
	if nFind > 0 then
		local tbFind = tbAward[nFind];
		if tbFind[1] == "玄晶" then
			pPlayer.AddItemEx(18, 1, 114, tbFind[2]);
			StatLog:WriteStatLog("stat_info", "qixi_2012", "award_qixi", pPlayer.nId, string.format("%s_%s_%s_%s", 18, 1, 114, tbFind[2]), 1);
		elseif tbFind[1] == "绑金" then
			pPlayer.AddBindCoin(tbFind[2]);
			StatLog:WriteStatLog("stat_info", "qixi_2012", "award_qixi", pPlayer.nId, "BindCoin", tbFind[2]);
		elseif tbFind[1] == "绑银" then
			pPlayer.AddBindMoney(tbFind[2]);
			StatLog:WriteStatLog("stat_info", "qixi_2012", "award_qixi", pPlayer.nId, "BindMoney", tbFind[2]);
		end
	end
end

-- 判断奖励最大银两
function tbQiXi2012:GetMaxMoney(tbAward)
	local nMaxValue = 0;
	for _, tbInfo in ipairs(tbAward) do
		if tbInfo[1] == "绑银" and nMaxValue < tbInfo[2] then
			nMaxValue = tbInfo[2];
		end
	end
	return nMaxValue;
end

-- 随机跟宠
function tbQiXi2012:RandPet(pPlayer, nLevel)
	if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_AWARD_PET) == 1 then
		return;
	end
	if self.OPENSUOXINYU_RANDPET[nLevel] and self.OPENSUOXINYU_RANDPET[nLevel] > 0 then
		local nRand = MathRandom(100);
		if nRand <= self.OPENSUOXINYU_RANDPET[nLevel] then
			local pItem = pPlayer.AddItem(unpack(self.ITEMID_PET))
			if pItem then
				pItem.Bind(1);
				pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_AWARD_PET, 1);
				pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>]打开情缘宝物锁心玉获得了【葫小芦·跟宠】。");
				Player:SendMsgToKinOrTong(pPlayer, "打开情缘宝物锁心玉获得了【葫小芦·跟宠】。", 1);
			end
		end
	end
end

-- 添加许愿灯
function tbQiXi2012:AddXuyuandeng(pPlayer, nType)
	if not self.NPCID_XUYUANDENG[nType] then -- 没有类型则不加许愿灯
		return 1;
	end
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			return 0, "这里会把<color=green>".. pNpc.szName.."<color>给挡住了，换个地方吧。";
		elseif pNpc.nKind == 4 or pNpc.nKind == 8 then
			return 0, "这里太拥挤了，换个地方摆吧";
		end
	end
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
	local pDeng = KNpc.Add2(self.NPCID_XUYUANDENG[nType], 120, -1, nMapId, nPosX, nPosY);
	if pDeng then
		pDeng.SetTitle(string.format("<color=pink>%s<color>", pPlayer.szName));
		pDeng.SetLiveTime(self.YINGYUANDENG_DURATION_TIME * 18)
	end
	pPlayer.SendMsgToFriend(string.format("你的好友[%s]点燃了七夕许愿灯，默默许下了一个神秘的愿望。", pPlayer.szName));
	Player:SendMsgToKinOrTong(pPlayer, "点燃了七夕许愿灯，默默许下了一个神秘的愿望。", 0);
	return 1;
end

-- 获取开锁心玉的次数
function tbQiXi2012:GetTodayOpenSuoxinyuTimes(pPlayer)
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	local nTaskDate = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_OPENSUOXINYU_DAY);
	if nDate > nTaskDate then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_OPENSUOXINYU_DAY, nDate);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_OPENSUOXINYU_TIMES, 0);
	end
	return pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_OPENSUOXINYU_TIMES);
end

function tbQiXi2012:StartEvent_GS()
	-- 活动期间刷npc
	if self:CheckIsOpen() == 1 then
		for nMapId, tbPos in pairs(self.NPCPOS_HUODONGDASHI) do
			if SubWorldID2Idx(nMapId) >= 0 then
				local pNpc = KNpc.Add2(self.NPCID_HUODONGDASHI, 120, -1, nMapId, tbPos[1], tbPos[2]);
				if not pNpc then
					print("七夕活动npc添加失败");
				end
			end
		end
		-- 加载随机传送点
		local tbPos = Lib:LoadTabFile(self.PATH_RANDPOS);
		if not tbPos or #tbPos == 0 then
			print("qixi2012", "load pos file fail");
			return;
		end
		self.tbTransmitPos = {};
		for _, tbTemp in ipairs(tbPos) do
			table.insert(self.tbTransmitPos, {tonumber(tbTemp.MAPID), math.floor(tonumber(tbTemp.POSX) / 32), math.floor(tonumber(tbTemp.POSY) / 32)});
		end
	end
end

-- 注册启动事件
ServerEvent:RegisterServerStartFunc(tbQiXi2012.StartEvent_GS, tbQiXi2012);