-- 文件名　：jixiang.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-07 11:09:14
-- 功能描述：结婚npc，吉祥

local tbNpc = Npc:GetClass("marry_jixiang");

--===================================================

tbNpc.LEVEL_LAIBIN = 1;		-- 来宾
tbNpc.LEVEL_BANLN = 2;		-- 伴郎伴娘
tbNpc.LEVEL_SIYI = 3;		-- 司仪
tbNpc.LEVEL_COUPLE = 4;		-- 新郎新娘

tbNpc.WEDDINGLEVEL_PINGMIN	= 1;
tbNpc.WEDDINGLEVEL_GUIZU	= 2;
tbNpc.WEDDINGLEVEL_WANGHOU	= 3;
tbNpc.WEDDINGLEVEL_HUANGJIA	= 4;

tbNpc.CDTIME_SETHUATONG		= 60 * 10;	-- 摆放花童操作的cd时间，10分钟

tbNpc.COST_PER_PLAYERLIMIT	= 10000;	-- 每个人数上限需要花费的银两
tbNpc.COST_PER_CAIYAOLIMIT	= 50000;	-- 每个菜肴上限需要花费的银两

tbNpc.STATE_STARTWEDDING	= 1;	-- 开启婚礼
-- tbNpc.STATE_YANHUO			= 2;	-- 开启焰火（皇家模式）
tbNpc.STATE_VISITORNPC		= 2;	-- 开启来访npc
tbNpc.STATE_ZHUHUNNPC		= 3;	-- 开启主婚人npc
tbNpc.STATE_YANXI			= 4;	-- 开启婚礼宴席上菜
tbNpc.STATE_OVER			= 5;

tbNpc.tbZhuHunNpc = {
	[1] = {szName = "白秋琳", nNpcId = 6659, tbPos = {1764, 3148}},
	[2] = {szName = "白秋琳", nNpcId = 6658, tbPos = {1605, 3169}},
	[3] = {szName = "白秋琳", nNpcId = 6657, tbPos = {1696, 3082}},
	[4] = {szName = "白秋琳", nNpcId = 6656, tbPos = {1592, 3214}},
	};

-- 抽奖次数
tbNpc.tbCount_ChouJiang = {[1] = 0, [2] = 0, [3] = 5, [4] = 5,};
tbNpc.tbAward_ChouJiang = {
	[1] = {tbGDPL = {}, szAwardName = ""},
	[2] = {tbGDPL = {}, szAwardName = ""},
	[3] = {tbGDPL = {18, 1, 614, 1}, szAwardName = "典礼幸运轮盘"},
	[4] = {tbGDPL = {18, 1, 614, 1}, szAwardName = "典礼幸运轮盘"},
	};

-- 最多摆放花童数量
tbNpc.MAX_HUATONG_COUNT = 64;
tbNpc.tbHuaTongPos = {{1600, 3200}, {1600, 3200}};

--===================================================

function tbNpc:OnDialog()
	if (Marry:CheckState() == 0) then
		return 0;
	end

	local szMsg = "你好！这场典礼由我吉祥来主持。准备好的话，就请二位侠侣或他们的结义兄弟、闺中密友告诉我吧！";
	local tbOpt = {{"Kết thúc đối thoại"},};
		
	local nTimerId = Marry:GetSpecTimer(me.nMapId, "huatong");
	if (nTimerId and 0 ~= nTimerId) then
		table.insert(tbOpt, 1, {"<color=gray>花童燃放烟花<color>", self.OpenHuaTongYanHua, self});
		table.insert(tbOpt, 2, {"<color=yellow>花童停止燃放烟花<color>", self.CloseHuaTongYanHua, self});
	else
		table.insert(tbOpt, 1, {"<color=yellow>花童燃放烟花<color>", self.OpenHuaTongYanHua, self});
		table.insert(tbOpt, 2, {"<color=gray>花童停止燃放烟花<color>", self.CloseHuaTongYanHua, self});
	end
		
	local bHaveDynamicChoice, tbDynamicChoice = self:GetCurDynamicChoice();
	if (1 == bHaveDynamicChoice) then
		table.insert(tbOpt, 1, tbDynamicChoice);
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:CheckLevel(nNeedLevel)
	local nMyLevel = self:GetWeddingPlayerLevel(me.szName);
	if (nMyLevel >= nNeedLevel) then
		return 1;
	end
	return 0;
end

function tbNpc:GetCurDynamicChoice()
	local bRet = 0;
	local tbRet = {};
	local nCurState = self:GetCurState();

	if (self.STATE_STARTWEDDING == nCurState) then
		bRet = 1;
		tbRet = {"<color=yellow>可以开始典礼了！<color>", self.StartWedding, self};
	elseif (self.STATE_VISITORNPC == nCurState) then
		bRet = 1;
		tbRet = {"<color=yellow>可以请贵宾来道贺了！<color>", self.NpcVisitor, self};
	elseif (self.STATE_ZHUHUNNPC == nCurState) then
		bRet = 1;
		tbRet = {"<color=yellow>可以开始拜天地了！<color>", self.ZhuHunNpc, self};
	elseif (self.STATE_YANXI == nCurState) then
		bRet = 1;
		tbRet = {"<color=yellow>可以开始上菜了！<color>", self.OpenYanxi, self};
	end
	return bRet, tbRet;
end

-- 获取指定玩家的权限
function tbNpc:GetWeddingPlayerLevel(szPlayerName)
	return Marry:GetWeddingPlayerLevel(me.nMapId, szPlayerName);
end

function tbNpc:GetWeddingLevel(nMapId)
	return Marry:GetWeddingLevel(nMapId) or 0;
end

function tbNpc:SetLevel(szPlayerName, nLevel)
	Marry:SetWeddingPlayerLevel(me.nMapId, szPlayerName, nLevel)
end

function tbNpc:GetCurState()
	local nCurState = Marry:GetWeddingStep(me.nMapId);
	return nCurState;
end

function tbNpc:SetCurState(nState)
	Marry:SetWeddingStep(me.nMapId, nState);
end

function tbNpc:GetWeddingOwnerName()
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId) or {};
	return tbCoupleName;
end

--================================================================

function tbNpc:IsCoupleInTheMap()
	local tbCoupleName = self:GetWeddingOwnerName(me.nMapId);
	if (#tbCoupleName ~= 2) then
		return 0;
	end
	local bIsCoupleInTheMap = 1;
	for _, szName in pairs(tbCoupleName) do
		local pPlayer = KPlayer.GetPlayerByName(szName);
		if (not pPlayer or pPlayer.nMapId ~= me.nMapId) then
			bIsCoupleInTheMap = 0;
			break;
		end
	end
	return bIsCoupleInTheMap;
end

function tbNpc:CanOpt(bCheckRelation)
	local szErrMsg = "";
	local bIsWeddingMap = Marry:CheckWeddingMap(me.nMapId);
	if (0 == bIsWeddingMap) then
		szErrMsg = "当前地图不是典礼场地，不能进行该操作。";
		return 0, szErrMsg;
	end
	
	local bLevelOk = self:CheckLevel(self.LEVEL_BANLN);
	if (bLevelOk == 0) then
		szErrMsg = "操作失败，需要二位侠侣或他们的结义兄弟、闺中密友才能操作。";
		return 0, szErrMsg;
	end
	
	local bCoupleInTheMap = self:IsCoupleInTheMap();
	if (0 == bCoupleInTheMap) then
		szErrMsg = "二位侠侣没有都到场，不能进行该操作。";
		return 0, szErrMsg;
	end
	
	local bIsPerformance = Marry:GetPerformState(me.nMapId);
	if (1 == bIsPerformance) then
		szErrMsg = "表演正在进行当中，还是等表演结束后再来进行下一步操作吧。";
		return 0, szErrMsg;
	end
	
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId);
	if (#tbCoupleName ~= 2) then
		return 0, szErrMsg;
	end
	local pPlayer1 = KPlayer.GetPlayerByName(tbCoupleName[1]);
	local pPlayer2 = KPlayer.GetPlayerByName(tbCoupleName[2]);
	if (0 == pPlayer1.IsFriendRelation(tbCoupleName[2])) then
		szErrMsg = "两位侠侣还没有建立好友关系，还是等他们成为好友之后再来吧。";
		return 0, szErrMsg;
	end
	if (not bCheckRelation) then
		if (not pPlayer1 or not pPlayer2) then
			return 0, szErrMsg;
		end
		if (1 == pPlayer1.IsMarried()) then
			szErrMsg = string.format("<color=yellow>%s<color>已经有知己了，换个人吧。", pPlayer1.szName);
			return 0, szErrMsg;
		end
		if (1 == pPlayer2.IsMarried()) then
			szErrMsg = string.format("<color=yellow>%s<color>已经有知己了，换个人吧。", pPlayer2.szName);
			return 0, szErrMsg;
		end
	end

	return 1;
end

--================================================================

function tbNpc:GetHuaTongList()
	local tbNpcIdxList = KNpc.GetMapNpcWithName(me.nMapId, "花童");
	if (not tbNpcIdxList or #tbNpcIdxList == 0) then
		return;
	end
	local tbNpcList = {};
	for _, nNpcIdx in pairs(tbNpcIdxList) do
		local pNpc = KNpc.GetByIndex(nNpcIdx);
		if (pNpc) then
			table.insert(tbNpcList, pNpc);
		end
	end
	return tbNpcList;
end

-- 燃放花童烟花
function tbNpc:OpenHuaTongYanHua()
	local nTimerId = Marry:GetSpecTimer(me.nMapId, "huatong");
	if (nTimerId and 0 ~= nTimerId) then
		return;
	end
	Marry:SetFireState(me.nMapId, 1);
	local nTimerId = Timer:Register(1, self.OpenYanHua, self, self:GetHuaTongList());
	Marry:AddSpecTimer(me.nMapId, "huatong", nTimerId);
end

function tbNpc:OpenYanHua(tbNpcList)
	if not tbNpcList then
		return 0;
	end
	local nFireState = Marry:GetFireState(me.nMapId) or 0;
	if (nFireState ~= 1) then
		return 0;
	end
	for _, pNpc in pairs(tbNpcList) do
		pNpc.CastSkill(307, 1, -1, pNpc.nIndex);
	end
	return 5 * Env.GAME_FPS;
end

--================================================================

-- 花童停止燃放烟花
function tbNpc:CloseHuaTongYanHua()
	local nTimerId = Marry:GetSpecTimer(me.nMapId, "huatong");
	Marry:ClearSpecTimer(me.nMapId, "huatong")
	Marry:SetFireState(me.nMapId, 0);
end

--================================================================

-- 开始婚礼
function tbNpc:StartWedding()
	local nCurState = self:GetCurState();
	if (nCurState ~= self.STATE_STARTWEDDING) then
		return;
	end
	
	local bCanOpt, szErrMsg = self:CanOpt();
	if (bCanOpt == 0) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	local tbCoupleName = self:GetWeddingOwnerName(me.nMapId);
	if (#tbCoupleName ~= 2) then
		return 0;
	end
	local szMsg = string.format("良辰已到，<color=yellow>%s<color>与<color=yellow>%s<color>的典礼正式开始。",
		tbCoupleName[1], tbCoupleName[2]);
	him.SendChat(szMsg);
	
	self:SetCurState(self.STATE_VISITORNPC);
	
	Dbg:WriteLog("Marry", "结婚系统", 
		string.format("%s跟%s的典礼正式开始", tbCoupleName[1], tbCoupleName[2]),
		string.format("开启仪式时间：%s", os.date("%Y年%m月%d日%H分", GetTime()))
	);
end

--================================================================

-- 开启拜访npc
function tbNpc:NpcVisitor()
	local nCurState = self:GetCurState();
	if (nCurState ~= self.STATE_VISITORNPC) then
		return;
	end
	
	local bCanOpt, szErrMsg = self:CanOpt();
	if (bCanOpt == 0) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	local nWeddingLevel = self:GetWeddingLevel(me.nMapId);
	Marry.VisitorManager:Open(me.nMapId, nWeddingLevel);
	
	self:SetCurState(self.STATE_ZHUHUNNPC);
end

--================================================================

function tbNpc:IsCoupleOnStage(nMapId)
	local tbCoupleName = self:GetWeddingOwnerName(nMapId);
	local bIsCoupleOnStage = 0;
	if (1 == Marry:CheckPlayerOnStage(nMapId, tbCoupleName[1]) and
		1 == Marry:CheckPlayerOnStage(nMapId, tbCoupleName[2])) then
		bIsCoupleOnStage = 1;
	end
	return bIsCoupleOnStage;
end

-- 开启主婚npc
function tbNpc:ZhuHunNpc()

	local nCurState = self:GetCurState();
	if (nCurState ~= self.STATE_ZHUHUNNPC) then
		return;
	end
	
	local bCanOpt, szErrMsg = self:CanOpt(1);
	if (bCanOpt == 0) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	local bIsCoupleOnStage = self:IsCoupleOnStage(me.nMapId);
	if (0 == bIsCoupleOnStage) then
		Dialog:Say("需要两位侠侣站在中央台子上，才能举行典礼。");
		return 0;
	end
	
	local nWeddingLevel = self:GetWeddingLevel(me.nMapId);
	self:OpenZhuHunNpc(nWeddingLevel, me.nMapId);
	
	self:SetCurState(self.STATE_YANXI);
end

function tbNpc:Marry(tbCoupleName, nMapId)
	local pMale = KPlayer.GetPlayerByName(tbCoupleName[1]);
	local pFemale = KPlayer.GetPlayerByName(tbCoupleName[2]);
	if (not pMale or not pFemale) then
		return;
	end
	self:RemoveProposalTitle(pMale, pFemale);
	
	local nWeddingLevel = Marry:GetWeddingLevel(nMapId);
	
	-- 为新人添加称号
	Marry:SetTitle(pMale, pFemale);
	
	local szBroadcastMsg = string.format("【<color=turquoise>%s<color>】与【<color=turquoise>%s<color>】已经结为侠侣，大家祝福他们吧。",
		tbCoupleName[1], tbCoupleName[2]);
	KDialog.NewsMsg(1, Env.NEWSMSG_COUNT, szBroadcastMsg, 20);
end

-- 移除求婚称号（如果有的话）
function tbNpc:RemoveProposalTitle(pMale, pFemale)
	local szTitle = pFemale.GetTaskStr(Marry.TASK_GROUP_ID, Marry.TASK_QIUHUN_NAME) .. "的心上人";
	pMale.RemoveSpeTitle(szTitle);
	
	szTitle = pMale.GetTaskStr(Marry.TASK_GROUP_ID, Marry.TASK_QIUHUN_NAME) .. "的心上人";
	pFemale.RemoveSpeTitle(szTitle);
end

function tbNpc:OpenZhuHunNpc(nWeddingLevel, nMapId)
	local nMapLevel = Marry:GetWeddingMapLevel(nMapId, me.szName);
	local tbZhuHunNpcInfo = self.tbZhuHunNpc[nWeddingLevel];
	if (not tbZhuHunNpcInfo) then
		return 0;
	end
	
	
	local pNpc = KNpc.Add2(tbZhuHunNpcInfo.nNpcId, 120, -1, nMapId, unpack(Marry.MAP_STAGE_POS[nMapLevel]));
	local tbCoupleName = self:GetWeddingOwnerName(me.nMapId);
	if (pNpc and #tbCoupleName == 2) then
		-- 开始释放经验
		local tbGouhuoNpc = Npc:GetClass("gouhuonpc");
		tbGouhuoNpc:InitGouHuo(pNpc.dwId, 0, 900, 5, 60, 500, 0);
		tbGouhuoNpc:StartNpcTimer(pNpc.dwId);
	
		-- 证婚人开始表演
		Marry:SetWitnessesId(nMapId, pNpc.dwId);
		local tbNpcData = pNpc.GetTempTable("Marry") or {};
		tbNpcData.nCurZhenghunStep = 1;
		local tbZhenghunren = Npc:GetClass("marry_zhenghunren");
		tbZhenghunren:Start(nMapId, nMapLevel, tbCoupleName);
		pNpc.SetLiveTime(3600 * Env.GAME_FPS);
		Relation:AddRelation_GS(tbCoupleName[1], tbCoupleName[2], Player.emKPLAYERRELATION_TYPE_COUPLE, 1);
		
		local pMale = KPlayer.GetPlayerByName(tbCoupleName[1]);
		local pFemale = KPlayer.GetPlayerByName(tbCoupleName[2]);
		pMale.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("与 %s 结为夫妻", pFemale.szName));
		pFemale.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("与 %s 结为夫妻", pMale.szName));
		
		local szLog = string.format("%s 与 %s 结为侠侣关系", tbCoupleName[1], tbCoupleName[2]);
		Dbg:WriteLog("Marry", "结婚系统", szLog);
	end
	return 0;
end

--================================================================

-- 开启宴席
function tbNpc:OpenYanxi()
	
	local nCurState = self:GetCurState();
	if (nCurState ~= self.STATE_YANXI) then
		return;
	end
	
	local bCanOpt, szErrMsg = self:CanOpt(1);
	if (bCanOpt == 0) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	-- 开始小游戏环节
	Marry.MiniGame:CallMiniGameNpc(me.nMapId);
	
	-- 上菜
	local tbNpc = Npc:GetClass("marry_shangcaipuren");
	tbNpc:Init(me.nMapId);
	
	-- 抽奖
	local nWeddingLevel = self:GetWeddingLevel(me.nMapId);
	local nCount_ChouJiang = self.tbCount_ChouJiang[nWeddingLevel];
	if (nCount_ChouJiang > 0) then
		if (not Marry.tbCount_ChouJiang) then
			Marry.tbCount_ChouJiang = {};
		end
		Marry.tbCount_ChouJiang[me.nMapId] = nCount_ChouJiang;
		local nChouJiang_CurCount = Marry:GetTicket(me.nMapId);
		if (nChouJiang_CurCount >= self.tbCount_ChouJiang[nWeddingLevel]) then
			return 0;
		end
		local szRightMsg = string.format("即将进行第<color=yellow>%s<color>次抽奖", nChouJiang_CurCount + 1);
		Marry:UpdateRightUI(me.nMapId, szRightMsg);
		
		local nTimerId = Timer:Register(2.4 * 60 * Env.GAME_FPS, self.ChouJiang, self, me.nMapId, nWeddingLevel);
		Marry:AddSpecTimer(me.nMapId, "choujiang", nTimerId);
	end
	
	self:SetCurState(self.STATE_OVER);
end

-- 抽奖
function tbNpc:ChouJiang(nMapId, nWeddingLevel)
	-- 当前地图目前已经进行的抽奖次数
	local nChouJiang_CurCount = Marry:GetTicket(nMapId);
	if (nChouJiang_CurCount >= self.tbCount_ChouJiang[nWeddingLevel]) then
		return 0;
	end

	local szRightMsg = string.format("即将进行第<color=yellow>%s<color>次抽奖", nChouJiang_CurCount + 2);
	Marry:UpdateRightUI(nMapId, szRightMsg);
	
	local tbCoupleName = Marry:GetWeddingOwnerName(nMapId);
	if (not tbCoupleName or #tbCoupleName ~= 2) then
		return 0;
	end
	local tbAllPlayer = Marry:GetAllPlayers(nMapId) or {};
	local nPlayerCount = #tbAllPlayer;
	if (0 ~= nPlayerCount) then
		local nRand = MathRandom(nPlayerCount);
		local pPlayer = tbAllPlayer[nRand];
		if (pPlayer) then
			local tbAwardInfo = self:GetAwardInfo(nWeddingLevel);
			KPlayer.SendMail(pPlayer.szName, "典礼抽奖礼品", string.format("恭喜！<color=yellow>%s<color>与<color=yellow>%s<color>的<color=green>%s<color>举行了抽奖活动，您有幸中了大奖！请注意查收附件。", tbCoupleName[1], tbCoupleName[2], Marry.WEDDING_LEVEL_NAME[nWeddingLevel]),
							0, 0, 1, unpack(tbAwardInfo.tbGDPL));
			local szMsg = string.format("<color=yellow>%s<color>在抽奖活动中获得了一个%s，大家恭喜他吧。获奖者请在邮件中查收奖品。",
											pPlayer.szName, tbAwardInfo.szAwardName);
			for _, pTempPlayer in pairs(tbAllPlayer) do
				pTempPlayer.Msg(szMsg);
			end
		end
	end
	
	Marry:AddTicket(nMapId);
	nChouJiang_CurCount = nChouJiang_CurCount + 1;
	if (nChouJiang_CurCount >= self.tbCount_ChouJiang[nWeddingLevel]) then
		Marry:UpdateRightUI(nMapId, "");
		return 0;
	end
	
	return 2.4 * 60 * Env.GAME_FPS;
end

-- 获取抽奖的奖品信息
function tbNpc:GetAwardInfo(nWeddingLevel)
	local tbAwardInfo = self.tbAward_ChouJiang[nWeddingLevel];
	return tbAwardInfo;
end
