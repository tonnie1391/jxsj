
-- 领土争夺战 GS脚本
-- zhengyuhua
-------------------------------------------------------------------------------

Require("\\script\\domainbattle\\domainbattle_def.lua");

Domain.tbAdjacency = {}; -- 邻域表

function Domain:Init()
	self.tbGame			= {};
	self.tbRecorder		= {};
	self.nBattleState 	= self.NO_BATTLE;
	self.nTimerId 		= 0;
	self.tbReact		= {};		-- 反扑地图ID
	self.tbUnionState	= {}
end

function Domain:GetBattleState()
	return self.nBattleState;
end

if not Domain.nBattleState then
	Domain:Init()
end

Domain.c2sFun = {}
--注册能被客户端直接调用的函数
local function RegC2SFun(szName, fun)
	Domain.c2sFun[szName] = fun
end

function Domain:OnEnterMap(nMapId)
	if not nMapId or not self.tbGame[nMapId] then
		return 0;
	end
	self.tbGame[nMapId]:Join2Game(me);
end

function Domain:OnLeaveMap(nMapId)
	if not nMapId or not self.tbGame[nMapId] then
		return 0;
	end
	self.tbGame[nMapId]:LeaveGame(me);
end

-- 遍历所有战场，分帧执行
function Domain:ExcutePerGame(tbBuf, szExcute, ...)
	if not tbBuf.nIndex then			-- 开始遍历
		tbBuf.nIndex = 1;
		Timer:Register(1, self.ExcutePerGame, self, tbBuf, szExcute, ...);
	elseif self.tbGameIndex and tbBuf.nIndex <= #self.tbGameIndex then
		local nMapId = self.tbGameIndex[tbBuf.nIndex];
		if self.tbGame[nMapId] then
			self.tbGame[nMapId][szExcute](self.tbGame[nMapId], ...);
		end
		tbBuf.nIndex = tbBuf.nIndex + 1;
		return 1;
	else
		tbBuf.nIndex = nil;			-- 完成遍历
		return 0;
	end
end

-- 开启领土战流程,进入宣战期
function Domain:StartDomainBattle_GS2(nBattleNo, nDataVer)
	self.nDataVer = nDataVer;
	self.tbRecorder = {};			-- 各个帮会区域分值
	self.tbSort		= {};
	self.tbGameIndex = {};			-- 征战索引（分帧操作需要）
	self.tbDeclareDomainTong = {};
	self.tbTongDeclare = {};
	local nDomainVersion = self:GetDomainVersion(nBattleNo);
	self:InitAdjacencyTable(nDomainVersion);		-- 初始化临时表
	local tbData = self:GetOpenStateTable()
	if not tbData then
		return 0;
	end
	local nLevel = tbData.nNpcLevel;		-- 时间轴决定等级
	for nDomainId, nMapId in pairs(self.tbDomainFightMap) do
		if IsMapLoaded(nMapId) == 1 then
			self.tbGame[nMapId] = Lib:NewClass(self.Base);
			self.tbGame[nMapId]:InitGame(nMapId, nLevel);
			table.insert(self.tbGameIndex, nMapId);
		end
	end
	self.nBattleState = self.PRE_BATTLE_STATE;
	local szMsg = "Lãnh thổ chiến đang bước vào thời kỳ tuyên chiến, hãy đến Quan lãnh thổ các thành để xác định mục tiêu chinh chiến"
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
end

-- 本服所有领土战开始
function Domain:BeginAllGame()
	self:ExcutePerGame({}, "StartGame");
	self.nBattleState = self.BATTLE_STATE;
	self:InitUnionState();
	self.tbTempRight = {};
	self.nGameTimerId = Timer:Register(60 * Env.GAME_FPS, self.ExcuteAfterMoment, self, "ExcutePerMinute");		-- 每60秒计算一次积分
	self.nTimerId = Timer:Register(self.BATTLE_TIME * Env.GAME_FPS, self.EndTimer, self);
	self.nAddBossTimes = 0;
	self.nBossTimerId = Timer:Register(self.ADDBOSS_TIME * Env.GAME_FPS, self.AddDomainBoss, self);
	for nDomainId, nMapId in pairs(self.tbDomainFightMap) do
		if IsMapLoaded(nMapId) == 1 then
			self.tbGame[nMapId].bReact = self.tbReact[nDomainId] or 0;
		end
	end
	local szMsg = "Lãnh thổ chiến chưa mở!"
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
end

function Domain:GetDomainVersion(nBattleNo)
	
	-- by zhangjinpin@kingsoft
	local nStep = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_STEP);
	if nStep == 3 then
		return 2;
	end
	
	nBattleNo = nBattleNo or KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	local nReture = 1;
	for nDomainVersion, nOpenNo in ipairs(self.BATTLENO_TO_OPEN) do
		if nBattleNo >= nOpenNo then
			nReture = nDomainVersion;
		end
	end
	return nReture;
end

function Domain:GetRestTime()
	if self.nTimerId > 0 then
		return Timer:GetRestTime(self.nTimerId);
	end
	return 0;
end
function Domain:EndTimer()
	self.nTimerId = 0;
	return 0;
end

-- 刷领土BOSS
function Domain:AddDomainBoss()
	self.nAddBossTimes = (self.nAddBossTimes or 0) + 1;
	self:ExcutePerGame({}, "AddBoss")
	if self.nAddBossTimes >= self.ADDBOSS_TIMES then
		self.nBossTimerId = nil;
		return 0;
	end
end

function Domain:GetBossTimes()
	return self.nAddBossTimes;
end

-- 每相隔一段时间执行
function Domain:ExcuteAfterMoment(szFunName)
	if self.nBattleState == self.BATTLE_STATE then
		self:ExcutePerGame({}, szFunName)
	else
		return 0;
	end
end

-- 更换加经验标记
function Domain:UpdateExpFlag_GS2(nCurExpFlag)
	self.nCurExpFlag = nCurExpFlag;
	self:ExcutePerGame({}, "ChangeExpFlag")
end

function Domain:CheckAndAddExp(pPlayer)
	if not pPlayer or not self.nCurExpFlag then
		return 0;
	end
	if pPlayer.GetTask(self.TASK_GROUP_ID, self.ADDEXP_FLAG) == self.nCurExpFlag then
		return 0;		-- 本次的经验给过了
	end
	if pPlayer.IsDead() == 1 then
		return 0;		-- 死亡不给加经验
	end
	local nExp = self.EXP_PRE_FLAG * pPlayer.GetBaseAwardExp();	
	pPlayer.AddExp(nExp);		
	pPlayer.SetTask(self.TASK_GROUP_ID, self.ADDEXP_FLAG, self.nCurExpFlag);
	pPlayer.Msg(string.format("Bạn nhận được Lãnh thổ chiến cấp cho <color=yellow>%d lần<color> kinh nghiệm", self.nCurExpFlag));
end

-- 停止所有征战，进入休战期
function Domain:StopAllGame()
	self.nBattleState = self.STOP_STATE;
	self:ExcutePerGame({}, "StopGame");
	if self.nGameTimerId then
		Timer:Close(self.nGameTimerId);
		self.nGameTimerId = nil;
	end
	if self.nBossTimerId then
		Timer:Close(self.nBossTimerId);
		self.nBossTimerId = nil;
	end
	
	
	self.tbReact = {};		-- 反扑地图ID清空
	local nDataVer = self.nDataVer + 1;
	self.nDataVer = nDataVer;
	
	local szMsg = "Lãnh thổ chiến bước vào thời kỳ ngừng chiến!"
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
end

-- 结束所有征战
function Domain:EndAllGame()
	self:ExcutePerGame({}, "EndGame");
	self.nBattleState = self.NO_BATTLE;
	self.tbRecorder = {};		-- 各个帮会区域分值
	self.tbSort		= {};

	local szMsg = "Tranh đoạt lãnh thổ kết thúc!"
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
end

-- 检查（重置）任务变量
function Domain:CheckTask(pPlayer)
	if not pPlayer then
		return;
	end
	local nCurNo = pPlayer.GetTask(self.TASK_GROUP_ID, self.BATTLE_NO);
	local nBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	if nBattleNo ~= nCurNo then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.BATTLE_NO, nBattleNo);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.SCORE_ID, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.CHUANSONG_ID, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.KILL_TOWER, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.KILL_PLAYER, 0);
	end
end

function Domain:AddTongScore_GS1(nMapId, nTongId, nScore, tbSortResult)
	if not self.tbGame[nMapId] then  -- 该征战没在本服务器开~不予采纳
		return 0;
	end
	return GCExcute{"Domain:SetTongScore_GC", nMapId, nTongId, nScore, tbSortResult};
end

function Domain:SetTongScore_GS2(nMapId, nId, nScore, tbSortResult)
	if self.tbGame[nMapId] then		-- 活动在本服务器中，以本服的数据为准
		nScore = self.tbGame[nMapId].tbTongOrUnion[nId].nScore;
	end
	if not self.tbSort then
		--某台服务器宕机，导致数据未初始化和数据丢失。
		--GC数据准确
		print("\script\domainbattle\domainbattle_gs.lua 248", "Domain:SetTongScore_GS2", "Server Dump Data Error!");
		return 0;
	end
	if not self.tbRecorder[nId] then
		self.tbRecorder[nId] = {};
		self.tbSort[nId]	 = {};
	end
	self.tbRecorder[nId][nMapId] = nScore;
	for nCurId, nSort in pairs(tbSortResult) do
		if not self.tbSort then
			self.tbSort = {};
		end
		if not self.tbSort[nCurId] then
			self.tbSort[nCurId] = {};
		end
		self.tbSort[nCurId][nMapId] = nSort;
		if nCurId ~= 0 then
			if KTong.GetTong(nCurId) then
				KTongGs.TongClientExcute(nCurId, {"Domain:s2cBattleMinInfo", nil,
					{[nMapId] = self.tbSort[nCurId][nMapId]}});
			elseif KUnion.GetUnion(nCurId) then
				Union:UnionClientExcute(nCurId, {"Domain:s2cBattleMinInfo", nil,
					{[nMapId] = self.tbSort[nCurId][nMapId]}})
			end
		end
	end
	if nId ~= 0 then
		if KTong.GetTong(nId) then
			return KTongGs.TongClientExcute(nId, {"Domain:s2cBattleMinInfo", 
				{[nMapId] = nScore}, {[nMapId] = tbSortResult[nId]}});
		elseif KUnion.GetUnion(nId) then
			return Union:UnionClientExcute(nId, {"Domain:s2cBattleMinInfo", 
				{[nMapId] = nScore}, {[nMapId] = tbSortResult[nId]}});
		end
	end
end

-- 通知被反扑的帮会和地图
function Domain:NotifyNpcReact_GS2(nTongId, tbDomainId)
	for i = 1, #tbDomainId do
		local nDomainId = tbDomainId[i];
		self.tbReact[nDomainId] = 1;
		local szName = self.tbDomainName[nDomainId];
		if szName then
			local nDataVer = self.nDataVer + 1;
			self.nDataVer = nDataVer;
			KTong.Msg2Tong(nTongId, string.format("Lãnh thổ [%s] đã bị quân Lưu vong nơi đó phản công, hãy mau quay về canh giữ!", szName));
		end
	end
end

-- 获取全局信息
function Domain:GetTongGlobalInfo(nId)
	return self.tbRecorder[nId], self.tbSort[nId];
end

-- 设置奖励积分
function Domain:SetAwardScoreLimit(nTongId, tbAwardLimit, nAttendCount, nCurNo, szResult)
	local pTong = KTong.GetTong(nTongId);
	if pTong then
		for i = 1, #tbAwardLimit do
			pTong.SetDomainAwardLimit(i, tbAwardLimit[i])
		end
		pTong.SetDomainAttendNum(nAttendCount);
		pTong.SetDomainAttendNo(nCurNo);
		pTong.SetDomainResult(szResult);
	end
end

-- 设置区域新归属（删除原有归属，设置新归属，nNewOwnerId为0，则仅删除）
function Domain:SetDomainOwner_GS1(nDomainId, nNewOwnerId)
	return GCExcute{"Domain:SetDomainOwner_GC", nDomainId, nNewOwnerId};
end

function Domain:SetDomainOwner_GS2(nDomainId, nOrgOwnerId, nNewOwnerId, nTime, nDataVer, bIsDispense)
	local tbDomainName = self:GetDomains()
	local szName = tbDomainName[nDomainId];
	-- 删除原有
	if nOrgOwnerId ~= 0 then
		local pTong = KTong.GetTong(nOrgOwnerId);
		if pTong and szName then
			if (pTong.DelDomain(nDomainId) ~= 1) then
				print("[Error]", "Domain:SetDomainOwner_DelOrg", pTong, nDomainId, nOrgOwnerId, nNewOwnerId);
			end
			pTong.AddAffairLost(szName);
			if pTong.GetCapital() == nDomainId then
				pTong.SetCapital(0);
				KTong.Msg2Tong(nOrgOwnerId, "Thành chính bang hội ["..szName.."] bị đánh chiếm!");
			elseif self:GetDomainType(nDomainId) == "village" then
				KTong.Msg2Tong(nOrgOwnerId, "Tân thủ thôn ["..szName.."] quyền chiếm lĩnh bị thu hồi!");
			else
				KTong.Msg2Tong(nOrgOwnerId, "Lãnh thổ bang hội ["..szName.."] bị đánh chiếm!");
			end
			
			-- add log
			Dbg:WriteLog("DomainBattle", string.format("Bang hội %s bị mất lãnh thổ [%s]", pTong.GetName(), szName));
		end
		local pUnion = KUnion.GetUnion(nOrgOwnerId);
		if pUnion then
			if (pUnion.DelDomain(nDomainId) ~= 1) then
				print("[Error]", "Domain:SetDomainOwner_DelOrg", pUnion, nDomainId, nOrgOwnerId, nNewOwnerId);
			end
			if self:GetDomainType(nDomainId) == "village" then
				Union:Msg2UnionTong(nOrgOwnerId, "Tân thủ thôn ["..szName.."] quyền chiếm lĩnh bị thu hồi!");
			else
				if bIsDispense == 1 then
					local pTong = KTong.GetTong(nNewOwnerId);
					if pTong then
						Union:Msg2UnionTong(nOrgOwnerId, "Lãnh thổ của Liên minh ["..szName.."] giao cho bang hội ["..pTong.GetName().."]!");
					end
				else
					Union:Msg2UnionTong(nOrgOwnerId, "Lãnh thổ của Liên minh ["..szName.."] bị đánh chiếm!")
				end
			end
			
			-- add log
			Dbg:WriteLog("DomainBattle", string.format("Liên minh %s bị mất lãnh thổ [%s]", pUnion.GetName(), szName));
		end
	end
	-- 增加到新归属
	if (nNewOwnerId ~= 0) then
		local pTong = KTong.GetTong(nNewOwnerId);
		local pDomain;
		if pTong and szName then
			pTong.AddAffairOccupy(szName);
			pDomain = pTong.AddDomain(nDomainId);
			if pDomain then
				pDomain.SetOccupyTime(nTime);
				if bIsDispense == 1 then
--					KTong.Msg2Tong(nNewOwnerId, "Lãnh thổ của Liên minh ["..szName.."]分配给帮会成员["..pTong.GetName().."]了！");
				else
					KTong.Msg2Tong(nNewOwnerId, "Bang hội chiếm đóng lãnh thổ ["..szName.."]");
					-- add log
					Dbg:WriteLog("DomainBattle", string.format("Bang hội %s chiếm đóng lãnh thổ [%s]", pTong.GetName(), szName));
				end
			end
		end
		local pUnion = KUnion.GetUnion(nNewOwnerId);
		if pUnion and szName then
			if pUnion.AddDomain(nDomainId, nTime) == 1 then
				Union:Msg2UnionTong(nNewOwnerId, "Liên minh chiếm đóng lãnh thổ ["..szName.."]");
				-- add log
				Dbg:WriteLog("DomainBattle", string.format("Liên minh %s chiếm đóng lãnh thổ [%s]", pUnion.GetName(), szName));
			end
		end
	end
	if self.nBattleState == self.PRE_BATTLE_STATE then		-- 宣战期更新相邻居关系
		local nDomainVersion = self:GetDomainVersion();
		self:InitAdjacencyTable(nDomainVersion);
	end
	self.nDataVer = nDataVer;
	return 1;
end

-- 新领土宣战(gs申请)
function Domain:DeclareWar_GS1(nDomainId, nTongId)
	
	-- by zhangjinpin@kingsoft
	if self:GetBattleState() ~= self.PRE_BATTLE_STATE then
		Dialog:Say("Hiện giờ chưa cho phép tuyên chiến! Thòi gian tuyên chiến từ 20:00 - 20:30.");
		return 0;
	end
	-- end
	
	local cTong = KTong.GetTong(nTongId);
	if cTong == nil then
		return 0;
	end

	local nDomainCount = cTong.GetDomainCount();
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local nGeneralCheck, cMember = Tong:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, Tong.POW_WAR);

	if nGeneralCheck ~= 1 then
		Dialog:Say("Bạn không có quyền tuyên chiến.");
		return 0;
	end

	if cTong.GetBelongUnion() == 0 then
		local tbAdjacency = self:GetAdjacency(nTongId);
		if self:GetDomainType(nDomainId) == "village" then
			if nDomainCount ~= 0 then
				Dialog:Say("Bang hội của bạn đã có lãnh thổ, không thể khiêu chiến lãnh thổ Tân thủ thôn.");
				return 0;
			end
		else
			local nDeclareNum = self:GetConzoneDelareNum(nTongId)
			if nDomainCount == 0 and nDeclareNum == 0 then
				Dialog:Say("Bang hội của bạn chưa có lãnh thổ, chỉ có thể khiêu chiến lãnh thổ Tân thủ thôn.");
				return 0;
			elseif nDeclareNum == 0 then
				local cItor = cTong.GetDomainItor();
				local nIdTmp = cItor.GetCurDomainId();
				if nDomainCount == 1 and self:GetDomainType(nIdTmp) == "village" then
				elseif tbAdjacency[nDomainId] ~= 0 then
						return 0;
				end
			end
		end
	end
	
	return GCExcute{"Domain:DeclareWar_GC", nDomainId, nTongId};
end

-- 新领土宣战(gs同步)
function Domain:DeclareWar_GS2(nDomainId, nTongId)
	
	-- by zhangjinpin@kingsoft
	if self:GetBattleState() ~= self.PRE_BATTLE_STATE then
		-- Dialog:Say("Hiện giờ chưa cho phép tuyên chiến! Thòi gian tuyên chiến từ 20:00 - 20:30.");
		return 0;
	end
	-- end
	
	local cTong = KTong.GetTong(nTongId);
	if cTong == nil then
		return 0;
	end
	local szCapital = self:GetDomainName(nDomainId);
	local nFightMap = self:GetDomainFightMap(nDomainId) or 0;
	local szFightMap = GetMapNameFormId(nFightMap);
		
	-- 设置领土与对应的宣战帮会，会先清掉之前的该帮会之前选择宣战的领土
	self:SetDeclareDomainTong(nDomainId, nTongId);
	
	if szCapital and szFightMap then
		if cTong.GetBelongUnion() == 0 then
			KTong.Msg2Tong(nTongId,
				string.format("Bang hội của bạn đã tuyên chiến [<color=red>%s<color>], hãy đến [<color=red>%s<color>] tham gia chiến đấu.",
				szCapital, szFightMap));
		else
			Union:Msg2UnionTong(cTong.GetBelongUnion(), 
				string.format("Liên minh bang hội [%s] đã tuyên chiến [<color=red>%s<color>], các thành viên bang hội thuộc liên minh được phép chinh chiến, hãy đến [<color=red>%s<color>] tham gia chiến đấu.",
				cTong.GetName(), szCapital, szFightMap));
		end
	end
	
	-- GC端存储宣战表信息
	GCExcute{"Domain:SaveDeclareTable", self.tbDeclareDomainTong, self.tbTongDeclare};
	
	return 1;
end

function Domain:OwnerIdToUnionId(nOwnerId)
	local pTong = KTong.GetTong(nOwnerId);
	if pTong then
		return pTong.GetBelongUnion();
	end
	if KUnion.GetUnion(nOwnerId) then
		return nOwnerId;
	end
	return 0;
end

-- 构造帮会占领的领土及其邻接表
function Domain:InitAdjacencyTable(nDomainVersion)
	local tbDomain = self:GetDomains();
	self.tbAdjacency = {};
	self.tbUnionAdjacency = {};
	for nDomainId, szDomainName in pairs(tbDomain) do
		local tbAdj = self:GetBorderDomains(nDomainVersion, nDomainId);
		if tbAdj then
			for nDomainId2,_ in pairs(tbAdj) do
				local nDomainOwnerId = self:GetDomainOwner(nDomainId);
				if nDomainOwnerId ~= 0 then
					if self.tbAdjacency[nDomainOwnerId] == nil then
						self.tbAdjacency[nDomainOwnerId] = {};
					end
					local tbTemp = self.tbAdjacency[nDomainOwnerId];
					tbTemp[nDomainId] = nDomainOwnerId;
					tbTemp[nDomainId2] = self:GetDomainOwner(nDomainId2);
				end
				local nUnionId = self:OwnerIdToUnionId(nDomainOwnerId);
				if nUnionId ~= 0 then
					if not self.tbUnionAdjacency[nUnionId] then
						self.tbUnionAdjacency[nUnionId] = {};
					end
					local tbTemp = self.tbUnionAdjacency[nUnionId];
					tbTemp[nDomainId] = nDomainOwnerId;
					tbTemp[nDomainId2] = self:GetDomainOwner(nDomainId2);
				end
			end
		end
	end
end

-- 构造联盟宣战状态（目的是为了快速判断征战关系，必须在进入征战期的时候构造一次）
function Domain:InitUnionState()
	self.tbUnionState = {};
	self.tbTongState = {};
	self:MakeUpUnionDeclear()
	local pUnion, nUnionId = KUnion.GetFirstUnion()
	while pUnion do
		self.tbUnionState[nUnionId] = Union:GetUnionDomainDecleaarState(nUnionId);
		pUnion, nUnionId = KUnion.GetNextUnion(nUnionId)
	end
	local tbDomain = self:GetDomains();
	for nDomainId, szDomainName in pairs(tbDomain) do
		if self:GetDomainType(nDomainId) == "village" then
			local nOwner = self:GetDomainOwner(nDomainId)
			if nOwner ~= 0 and KTong.GetTong(nOwner) then
				self.tbTongState[nOwner] = 1;
			end
		end
	end
end

function Domain:GetState(nId)
	if self.tbUnionState and self.tbTongState then
		return self.tbUnionState[nId] or self.tbTongState[nId];
	end
end

-- 获得帮会占领的领土及其邻接表
-- example:
-- tbAdj[nTongId] = {
--	{[nDomainId1] = nOwnerTongId1,[nDomainId2] = nOwnerTongId1,.........},
--	{[nDomainId5] = nOwnerTongId3,............},........
-- }
function Domain:GetAdjacency(nTongId)
	return self.tbAdjacency[nTongId];
end

-- 是否有征战权(必须在该区域指定的FightMap上)
function Domain:HasBattleRight(nTongId, nMapId)
	if not self.tbTempRight[nTongId] then
		self.tbTempRight[nTongId] = {}
	end
	if not self.tbTempRight[nTongId][nMapId] then
		self.tbTempRight[nTongId][nMapId] = self:_HasBattleRight(nTongId, nMapId);		-- 缓存，不用每次都去算
	end
	return self.tbTempRight[nTongId][nMapId];
end

-- 判断是否有征战权
function Domain:_HasBattleRight(nTongId,nMapId)
	local nDomainId = self:GetMapDomain(nMapId); -- mapId到DomainId
	local nOwnerId = self:GetDomainOwner(nDomainId);
	local nOwnerUnion = self:OwnerIdToUnionId(nOwnerId);
	local pTong = KTong.GetTong(nTongId);
	if pTong == nil or nDomainId == nil or nDomainId == 0 then
		return 0;
	end
	local nUnionId = pTong.GetBelongUnion();
	if nUnionId ~= 0 and nUnionId ~= nOwnerUnion then	-- 非本联盟领土
		local pUnion = KUnion.GetUnion(nUnionId);
		if pUnion then
			local nUnionDomainCount = Union:GetUnionDomainCount(nUnionId);
			if nUnionDomainCount > pUnion.GetTongCount() then		-- 帮会数大于领土数 无法进攻
				return 0;
			end
		end
	elseif nUnionId ~= 0 then			-- 本联盟领土
		if not KTong.GetTong(nOwnerId) then		-- 未分配领土 不许防守
			return 0;
		end
	end
	
	-- 1.已经宣战的区域
	if (self:IsTongDeclareDomain(nTongId, nDomainId) == 1 or self:IsUnionDeclareDomain(nUnionId, nDomainId) == 1) and -- 本帮或联盟已宣
		(not self.tbUnionState[nUnionId] or self.tbUnionState[nUnionId] >= 0) then		-- 无联盟或联盟可攻打
		return 1;
	end
	if self:GetDomainType(nDomainId) == "village" then
		return 0; 		-- 只有宣战才能攻打新手村
	end
	
	-- 如果占有新手村可供打任意有归属的领土
	if Union:GetUnionDomainDecleaarState(nUnionId) == 1 or Tong:GetTongDomainState(nTongId) == 1 then
		if nOwnerId ~= 0 then
			return 1;
		end
	end
	
	local tbAdj = self:GetAdjacency(nTongId);
	local tbUnionAbj = self.tbUnionAdjacency[nUnionId];
	if ((tbAdj and tbAdj[nDomainId] and tbAdj[nDomainId] ~= 0) or						-- 帮会邻接
		(tbUnionAbj and tbUnionAbj[nDomainId] and tbUnionAbj[nDomainId] ~= 0)) then		-- 联盟邻接
			return 1;
	end
	
	return 0;
end

function Domain:UpdateDataDomainColor_GS2(tbSyncInfo, nDataVer)
	for nId, nColor in pairs(tbSyncInfo) do
		local pTong = KTong.GetTong(nId)
		if pTong then
			pTong.SetDomainColor(nColor);
		end
		local pUnion = KUnion.GetUnion(nId)
		if pUnion then
			pUnion.SetDomainColor(nColor);
		end
	end
	self.nDataVer = nDataVer;
end

-- 同步客户端数据
function Domain:ApplyData_GS1(nDataVer)
	if nDataVer == self.nDataVer then
		return 0;
	end
	local nDomainVersion = self:GetDomainVersion();
	local tbDomain = self:GetDomains();
	local tbDomainInfo = {};
	for nDomainId, szDomainName in pairs(tbDomain) do
		local szTongName = "";
		local szUnionName = "";
		local nColor = 0;
		if self:GetBorderDomains(nDomainVersion, nDomainId) then
			local nOwnerId = self:GetDomainOwner(nDomainId);			
			local pTong = KTong.GetTong(nOwnerId);
			local pUnion = KUnion.GetUnion(nOwnerId);
			if pTong then
				local nUnionId = pTong.GetBelongUnion();
				if nUnionId ~= 0 then
					local pUnion = KUnion.GetUnion(nUnionId);
					if pUnion then
						nColor = pUnion.GetDomainColor();
						szUnionName = pUnion.GetName();
						szTongName = pTong.GetName();
					end
				else
					nColor = pTong.GetDomainColor();
					szTongName = pTong.GetName();
					szUnionName = 0;
				end
				tbDomainInfo[nOwnerId] = {};
				if nDomainId == pTong.GetCapital() then
					tbDomainInfo[nDomainId] = {szTongName, nColor, 1, self.tbReact[nDomainId] or 0, szUnionName or 0};
				else
					tbDomainInfo[nDomainId] = {szTongName, nColor, 0, self.tbReact[nDomainId] or 0, szUnionName or 0};
				end
			elseif pUnion then
				nColor = pUnion.GetDomainColor();
				szUnionName = pUnion.GetName();	
				szTongName = 0;
				tbDomainInfo[nDomainId] = {szTongName or 0, nColor, 0, self.tbReact[nDomainId] or 0, szUnionName or 0};
			end
		end
	end
	me.CallClientScript({"Domain:RecvData", tbDomainInfo, self.nDataVer, nDomainVersion});
end
RegC2SFun("ApplyData", Domain.ApplyData_GS1);

function Domain:CheckAwardCondition(cPlayer, nTongId, nAwardType)
	-- 如果没有帮会
	local cTong = KTong.GetTong(cPlayer.dwTongId);
	if not cTong then
		return 0;
	end
	
	-- 检测对应奖励类型是否领满了
	local nScoreLevel = 0;
	local nMinScore = 0;
	if (nAwardType == self.SYSTEMAWARD) then
		nScoreLevel, nMinScore = self:GetScoreLevel(cPlayer, self.SYSTEMAWARDLIMIT); 	-- 个人功勋到达的声望奖励等级
		-- 是否已经领取过系统奖励了
		if self:HasReciveSystemAward() == 1 then
			Dialog:Say("Bạn đã nhận được phần thưởng.");
			return 0;
		end
	elseif (nAwardType == self.TONGAWARD) then
		nScoreLevel, nMinScore = self:GetScoreLevel(cPlayer, 0); 	-- 个人功勋到达的声望奖励等级
		local nAwardAmount = cTong.GetDomainAwardAmount();  -- 帮主设定的帮会奖励总量
		if self:CanReciveTongAward(nAwardAmount) ~= 1 then -- 是否已经领满了帮会奖励了
			Dialog:Say("Bạn đã nhận được phần thưởng.");
			return 0;
		end
	else
		return 0;
	end
	
	-- 不符合基本条件
	local nGlobalBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	local nMyBattleNo = cPlayer.GetTask(self.TASK_GROUP_ID, self.BATTLE_NO); -- 个人征战流水号
	local nCurTongId = KLib.Number2UInt(nTongId);	-- 当前公会的ID
	local nPreTongId = KLib.Number2UInt(cPlayer.GetTask(self.TASK_GROUP_ID, self.SCORE_TONG)); -- 领土争夺战时的公会ID
	local szMsg = "";
	-- 宣战期和征战期无法领奖
	if (self:GetBattleState() == self.PRE_BATTLE_STATE or self:GetBattleState() == self.BATTLE_STATE) then
		szMsg = "Đang trong thời kỳ tuyên chiến không thể nhận thưởng.";
		Dialog:Say(szMsg);
		return 0;
	elseif (nGlobalBattleNo ~= nMyBattleNo) then
		szMsg = "Bạn không tham gia Lãnh thổ chiến, không thể nhận thưởng.";
		Dialog:Say(szMsg);
		return 0;
	elseif (nCurTongId ~= nPreTongId) then
		szMsg = "Bạn đã rời khỏi bang hội, không thể nhận phần thưởng Lãnh thổ chiến.";
		Dialog:Say(szMsg);
		return 0;
	elseif (nScoreLevel <= 0) then
		szMsg = string.format("Tích lũy của bạn <color=green>%d điểm<color> không đủ, cần ít nhất <color=green>%d điểm<color> tích lũy mới có thể nhận thưởng.", 
							   cPlayer.GetTask(self.TASK_GROUP_ID, self.SCORE_ID), nMinScore);
		Dialog:Say(szMsg);
		return 0;
	end
	return 1;
end

-- 设置系统奖励
function Domain:SetSystemAward_GS2(nTongId, tbPersonDomainScore)
	local pTong = KTong.GetTong(nTongId);
	if pTong and tbPersonDomainScore then
		-- 设置不同功勋档次的个人领土得分
		for i = 1, #self.DOMAINBATTLE_SCORE_RATE_TABLE do
			pTong.SetPersonDomainScore(i, tbPersonDomainScore[i]);
		end
	end
	return 0;
end

-- 获得系统奖励
function Domain:ReciveSystemAward(bConfirme)
-- 检测是否符合条件
	if self:CheckAwardCondition(me, me.dwTongId, self.SYSTEMAWARD) ~= 1 then
		return 0;
	end
	
-- 开始计算奖励
	local pTong = KTong.GetTong(me.dwTongId);
	local nScoreLevel = self:GetScoreLevel(me, self.SYSTEMAWARDLIMIT); 	-- 个人功勋到达的声望奖励等级	
	local nMemberCount = pTong.GetDomainAttendNum(); -- 帮会人数
	if nMemberCount < 50 then 
		nMemberCount = 50;
	end
	local nLevelMemberCount = math.ceil(nMemberCount * self.DOMAINBATTLE_SCORE_RATE_TABLE[nScoreLevel][1]); -- 到达的该声望奖励等级的人数
	local nPersonDomainScore = pTong.GetPersonDomainScore(nScoreLevel); -- 个人领土总分（荣誉总值）
	-- 计算个人声望
	local nPersonalRepute = 0; -- 分给帮众的总声望
	if self.TONG_MAX_REPUTE_LEVEL[nScoreLevel] and nPersonDomainScore > self.TONG_MAX_REPUTE_LEVEL[nScoreLevel] then
		nPersonalRepute =  self.TONG_MAX_REPUTE_LEVEL[nScoreLevel];
	else
		nPersonalRepute = nPersonDomainScore;	
	end
	-- 取整
	nPersonalRepute = math.floor(nPersonalRepute);
	
	-- 计算个人经验
	local nExpFactor = 0;
	if self.TONG_MAX_EXP_LEVEL[nScoreLevel] and (nPersonDomainScore * 2) > self.TONG_MAX_EXP_LEVEL[nScoreLevel] then
		nExpFactor = self.TONG_MAX_EXP_LEVEL[nScoreLevel]	-- 分给帮众的总经验
	else
		nExpFactor = nPersonDomainScore * 2;
	end
	
	local nPersonalExp = nExpFactor * self.DOMAINBATTLE_SCORE_RATE_TABLE[nScoreLevel][4] * me.GetBaseAwardExp() * self.AWARD_TIMES;
	-- 取整
	nPersonalExp = math.floor(nPersonalExp);
	
	local nDirectRepute = math.floor(nPersonalRepute * self.REPUTE_PERCENT) * self.AWARD_TIMES;
	local nRemain = me.GetTask(self.TASK_GROUP_ID, self.BOX_REMAIN);
	local nBoxRepute = math.floor(nPersonalRepute * (1 - self.REPUTE_PERCENT) + nRemain );
	local nBoxAward = math.floor(nBoxRepute / self.BOX_REPUTE_PARAM) * self.AWARD_TIMES;
	nRemain = nBoxRepute % self.BOX_REPUTE_PARAM;
	local nScore = me.GetTask(self.TASK_GROUP_ID, self.SCORE_ID);
-- 确认认领
	if (bConfirme == 0) then		
		Dialog:Say("1. Bang của bạn chiếm <color=green>"..pTong.GetDomainCount().."<color> vùng lãnh thổ;\n"..
		           "2. Trong giai đoạn chinh chiến nhận được <color=green>"..nScore.." điểm<color> công trạng cá nhân, đạt được <color=green>"..self.DOMAINBATTLE_SCORE_RATE_TABLE[nScoreLevel][3].."<color>, công trạng cấp <color=green>"..nScoreLevel.."<color>);\n"..
	             "    Xét thấy 2 điểm trên, đặc biệt khen thưởng cho ngươi <color=green>"..nDirectRepute.."<color> điểm danh vọng lãnh thổ, <color=green>"..nBoxAward.."<color> rương tranh đoạt lãnh thổ.",
			{
				{"Ta muốn nhận", self.ReciveSystemAward, self, 1},
			 	{"Để ta suy nghĩ thêm"},
			});
		return 0;
	end	
	local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("DomainbattleTask", me, nScore, nBoxAward);
	if me.CountFreeBagCell() < (1+nFreeCount) then
		Dialog:Say("Hành trang không đủ ô trống!");
		return 0;
	end
	
-- 给予奖励
	local nStockBaseCount = 0; 	-- 玩家对应的股份基数
	local nDomainNum = pTong.GetDomainCount();		-- 玩家的帮会占领的领土数量
	-- 计算玩家对应的股份基数
	for i = 1, #self.DOMAIN_RATE do
		if (nDomainNum >= self.DOMAIN_RATE[i]) then	
			nStockBaseCount = self.STOCK_BASE_COUNT[i] * self.DOMAINBATTLE_SCORE_RATE_TABLE[nScoreLevel][2] / nLevelMemberCount;
			break;
		end
	end
	-- 增加帮会建设资金和帮主、族长、副族长、个人的股份
	Tong:AddStockBaseCount_GS1(me.nId, nStockBaseCount, 0.6, 0.15, 0.1, 0.05, 0.1)

	local nGblBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO)
	local nReputeExt = Item:GetClass("reputeaccelerate"):GetAndUseExtRepute(me, self.CAMP_DOMAINBATTLE, self.CLASS_DOMAIN, nDirectRepute, 1);
	me.AddRepute(self.CAMP_DOMAINBATTLE, self.CLASS_DOMAIN, nDirectRepute + nReputeExt);
	me.AddExp(nPersonalExp);
	local nReputCount = 0;
	-- by zhangjinpin@kingsoft
	
	if nScore >= 800 and nDomainNum >= 1 then
		nReputCount = 30;
		me.AddKinReputeEntry(30);
	end
	-- end
	
	local nGiven = me.AddStackItem(self.DOMAIN_BOX[1], self.DOMAIN_BOX[2], self.DOMAIN_BOX[3], self.DOMAIN_BOX[4], {}, nBoxAward)
	-- TODO
	local nDet = nBoxAward - nGiven;
	
	if (self.AWARD_TIMES > 0) then
		nDet = math.floor(nDet / self.AWARD_TIMES);
	end
	local nRemain = nRemain + self.BOX_REPUTE_PARAM * nDet;
	me.SetTask(self.TASK_GROUP_ID, self.BOX_REMAIN, nRemain);
	me.SetTask(self.TASK_GROUP_ID, self.SYSTEMAWARD_NO, nGblBattleNo);
	Dbg:WriteLog("DomainBattle", "玩家获得声望"..nDirectRepute, "箱子："..nGiven.."/"..nBoxAward, 
		"剩余："..nRemain, me.szName, me.szAccount);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("帮会领土数量:%s\t功勋:%s\t获得领土声望:%s\t获得江湖威望:%s\t获得箱子:%s/%s\t剩余价值:%s",nDomainNum,nScore,nDirectRepute,nReputCount,nGiven,nBoxAward,nRemain));	
	--by jiazhenwei   活动系统领土战奖励
	
	SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
end

-- 设置帮会奖励额度
function Domain:SetTongAward(nLevel, bConfirme)
	-- 如果没有帮会 
	if (me.dwTongId == 0) then 
		Dialog:Say("Bạn không gia nhập bang hội.");
		return 0;
	end
	
	-- 如果在宣战期和征战期
	if (self:GetBattleState() == self.PRE_BATTLE_STATE or self:GetBattleState() == self.BATTLE_STATE) then
		Dialog:Say("Thời kỳ tuyên chiến và chinh chiến không thể thiết lập quân thưởng bang hội.");
		return 0;
	end
	
	-- 如果不是合法时间
	local nTime = GetTime();
	local nWeekDay = tonumber(os.date("%w", nTime))
	local nCurTime = tonumber(os.date("%H%M", nTime))

	local nRet = 0;
	for i = 1, #self.TONG_AWARD_DAY do
		if nWeekDay == self.TONG_AWARD_DAY[i] then
			nRet = 1;
			break;
		end
	end

	if nRet ~= 1 or nCurTime < self.TONG_AWARD_START_TIME or nCurTime > self.TONG_AWARD_END_TIME then 
		Dialog:Say(string.format("Thứ %s, Chủ nhật vào lúc 21:30 đến 22:00 trong lúc đó đến để thiết lập ngạch quân thưởng.", UiManager.IVER_szDomainBattleTime));
		return 0;
	end

	-- 如果不是首领
	local cTong = KTong.GetTong(me.dwTongId);
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	
	if Tong:CheckPresidentRight(me.dwTongId, nSelfKinId, nSelfMemberId) ~= 1 then
		Dialog:Say("Chỉ có bang chủ mới có thể thiết lập ngạch quân thưởng.");
		return 0;
	end

	-- 如果还没参加战斗
	local nGblBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	if (cTong.GetDomainAttendNo() ~= nGblBattleNo or cTong.GetDomainAttendNum() == 0) then
		Dialog:Say("Bang hội của bạn không tham gia Lãnh thổ chiến, không thể thiết lập ngạch quân thưởng.");
		return 0;
	end
	
	-- 如果是帮主和该帮没设置帮会奖励
	if (bConfirme == 0) then	
		-- 设置帮会奖励
		local tbOpt = {};
		local szSay = "";
		
		for Index = 5, 1, -1 do
			local nMoney = self.DOMAINBATTLE_AWARD_TABLE[Index]
			szSay = "<color=green>"..nMoney.."<color>（"..Item:FormatMoney(nMoney).."）";
			table.insert(tbOpt, {szSay, self.SetTongAwardComfirme, self, Index});
		end
		table.insert(tbOpt, {"Kết thúc đối thoại"});
		
		Dialog:Say("    Thủ lĩnh có thể thông qua thiết lập ngạch quân hưởng, tiêu hao quỹ xây dựng bang hội để thưởng cho thành viên bang hội thành lập công huân xuất sắc trong chiến tranh lãnh thổ. Ngạch quân hưởng khác nhau, thành viên bang hội có thể nhận được phần thưởng cũng khác nhau, ngạch quân hưởng càng lớn thành viên nhận được phần thưởng cũng sẽ càng nhiều.\n    <color=yellow>Bang hội của bạn hiện chưa đặt ngạch quân hưởng. <color>\n\n Ta muốn thiết lập.", 
			tbOpt); 

		return 0;		
	end
	
	-- 如果选择了帮会奖励方式而帮会建设资金不足
	if (cTong.GetBuildFund() < self.DOMAINBATTLE_AWARD_TABLE[nLevel]) then
		Dialog:Say("Quỹ xây dựng bang hội không đủ");
		return 0;
	end
	
	-- 军饷上限20亿
	local nWastage = self.DOMAINBATTLE_AWARD_TABLE[nLevel];
	local nDomainAwardAmount = 0;
	if cTong.GetDomainAwardNo() == nGblBattleNo then
		nDomainAwardAmount = cTong.GetDomainAwardAmount() + nWastage;
	else
		nDomainAwardAmount = nWastage;
	end
	if nDomainAwardAmount > self.MAX_DOMAINAWARD_AWARD then
		Dialog:Say("Giới hạn tối đa là "..self.MAX_DOMAINAWARD_AWARD);
		return 0;
	end
	return GCExcute{"Domain:SetTongAward_GC", me.dwTongId, nSelfKinId, nSelfMemberId, nLevel, me.nId};
end

-- 确认设置帮会奖励额度
function Domain:SetTongAwardComfirme(nLevel)
	Dialog:Say("    Xác định chọn <color=green>"..self.DOMAINBATTLE_AWARD_TABLE[nLevel].."<color> ngạch quân thưởng, sẽ khấu trừ vào quỹ xây bang hội?",
				{"Ta chắc chắn", self.SetTongAward, self, nLevel, 1},
				{"Để ta suy nghĩ thêm"}
			   );
end

-- 设置帮会奖励额度GS2
function Domain:SetTongAward_GS2(nTongId, nTongBuildFund, nDomainAwardAmount, nPlayerId)
	if (nTongId ~= 0 and nTongBuildFund >= 0 and nDomainAwardAmount > 0 and nPlayerId > 0) then 
		-- 设置帮会奖励额度
		local cTong = KTong.GetTong(nTongId);
		local nGblBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
		local nWastage = cTong.GetBuildFund() - nTongBuildFund;
		if nWastage < 0 then
			nWastage = 0;
		end
		cTong.SetBuildFund(nTongBuildFund);  --扣除建设基金
		cTong.SetDomainAwardAmount(nDomainAwardAmount);	 --设置帮会奖励额度
		cTong.SetDomainAwardNo(nGblBattleNo);	 --设置帮会奖励流水号，标记为已经设置帮会奖励额度
		cTong.AddAffairTongAward(KGCPlayer.GetPlayerName(nPlayerId), tostring(nWastage));
		local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not cPlayer then
			return 0;
		end
		cPlayer.Msg("Đặt ngạch quân thưởng thành công");
	end	
end

-- 拿取帮会奖励
function Domain:ReciveTongAward(bConfirme, nChoose)
-- 检测是否符合条件
	if Domain:CheckAwardCondition(me, me.dwTongId, self.TONGAWARD) ~= 1 then
		return 0;
	end
	
	-- 如果帮主还没设置帮会奖励额度
	local cTong = KTong.GetTong(me.dwTongId);
	local nAwardAmount = cTong.GetDomainAwardAmount();  -- 帮主设定的帮会奖励总量
	local nGblBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);

	if nAwardAmount < self.DOMAINBATTLE_AWARD_TABLE[1] or cTong.GetDomainAwardNo() ~= nGblBattleNo then
		Dialog:Say("Chưa thiết lập ngạch quân thưởng");
		return 0;
	end	

	-- 计算个人奖励值
	local nMemberCount = cTong.GetDomainAttendNum(); -- 帮会总人数
	if nMemberCount < 50 then 
		nMemberCount = 50;
	end
	local nScoreLevel = self:GetScoreLevel(me, 0); -- 个人功勋到达的帮会奖励等级
	local nLevelMemberCount = math.ceil(nMemberCount * self.DOMAINBATTLE_SCORE_RATE_TABLE[nScoreLevel][1]); -- 到达的该声望奖励等级的人数
	
	local nTongAwardNo = me.GetTask(self.TASK_GROUP_ID, self.TONGAWARD_NO); 
	local nMyBattleNo = me.GetTask(self.TASK_GROUP_ID, self.BATTLE_NO);
	local nGotValue = me.GetTask(self.TASK_GROUP_ID, self.TONGAWARD_AMOUNT)
	if nTongAwardNo ~= nMyBattleNo then
		 nGotValue = 0;
	end
	local nRestValue = nAwardAmount - nGotValue ; -- 个人还能领的奖励价值
	if nRestValue == 0 then
		Dialog:Say("Ngươi đã nhận hết quân thưởng rồi.");
		return 0;
	end
	local nPersonalAwardValue = nRestValue * self.DOMAINBATTLE_SCORE_RATE_TABLE[nScoreLevel][2] / nLevelMemberCount;	
	
	-- 选择&领取奖励
	local tbAwardMode = {0, 20, 40, 60, 80, 100} -- 奖励模式百分比表（以银两占的百分比为基准）
	if(bConfirme == 0) then		
		--选择奖励方式
		local tbOpt = {};
		local szSay = "";
		for nIdex = 1, #tbAwardMode do		
			local nItemLevel, nItemNum, nMoney = self:CalculateTongAward(nPersonalAwardValue, tbAwardMode[nIdex]);			
			--取整
			nMoney = math.floor(nMoney);
			
			if (nItemNum == nil or nItemLevel == nil) then 
				szSay = string.format("Hình thức thưởng %d:<color=green>%d bạc khóa<color>", nIdex, nMoney);	
			elseif (nMoney == nil) then 
				szSay = string.format("Hình thức thưởng %d:<color=green>%d Huyền tinh cấp %d<color>", nIdex, nItemNum, nItemLevel);
			else
				szSay = string.format("Hình thức thưởng %d:<color=green>%d Huyền tinh cấp %d, %d bạc khóa<color>", nIdex, nItemNum, nItemLevel, nMoney);
			end
		
			table.insert(tbOpt, { szSay, self.ReciveTongAwardConfirme, self, nIdex, szSay })
		end
		table.insert(tbOpt, {"Chuyển vào quỹ thưởng bang hội", self.TongAwardToGreatBonus, self, me.dwTongId, me.nId, nPersonalAwardValue});
		table.insert(tbOpt, {"Kết thúc đối thoại"});
		
		Dialog:Say("1. Bang hội thiết lập phần thưởng Lãnh thổ chiến số tiền <color=green>"..nAwardAmount.."<color> ngươi còn có <color=green>"..nRestValue.."<color> ngạch chưa lĩnh;\n"..
		           "2. Trong Lãnh thổ chiến ngươi đạt được <color=green>“"..self.DOMAINBATTLE_SCORE_RATE_TABLE[nScoreLevel][3].."”<color> điểm, công trạng cấp <color=green>"..nScoreLevel.."<color>;\n"..
		           "    Xét thất 2 điểm trên, ngươi có thể nhận 1 trong các phần thưởng sau:", tbOpt);
	else
		-- 领取奖励
		self:ReceiveTongAward(nPersonalAwardValue, me.nId, tbAwardMode[nChoose]);
	end
end	

-- 计算个人功勋在帮会奖励中的等级
function Domain:GetScoreLevel(cPlayer, nMinLimit)
	local cTong = KTong.GetTong(cPlayer.dwTongId);
	local nScore = cPlayer.GetTask(self.TASK_GROUP_ID, self.SCORE_ID); -- 个人功勋值
	local nScoreLevel = 0; -- 个人功勋到达的帮会奖励等级

	local nGblBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO); -- 全局征战流水号
	local nMyBattleNo = cPlayer.GetTask(self.TASK_GROUP_ID, self.BATTLE_NO); -- 个人征战流水号
	if nGblBattleNo ~= nMyBattleNo then	
		return 0;
	end

	for nIndex = 1, 5 do
		if (nScore >= cTong.GetDomainAwardLimit(nIndex) and nScore >= nMinLimit) then
			nScoreLevel = nIndex;
			break;
		end;
	end

	local nMinScore = math.max(cTong.GetDomainAwardLimit(5), nMinLimit);
	if nMinScore > self.SYSTEMAWARDLIMIT then
		nMinScore = self.SYSTEMAWARDLIMIT;
	end
	
	if nScoreLevel == 0 and nScore >= self.SYSTEMAWARDLIMIT then
		nScoreLevel = 5;
	end
	
	return nScoreLevel, nMinScore;
end

-- 计算不同奖励
function Domain:CalculateTongAward(nPersonalAwardValue, nMoneyPercent)
	local nMoney = nPersonalAwardValue * nMoneyPercent / 100;
	local nValue = nPersonalAwardValue * (100 - nMoneyPercent) / 100;
	local tbItem = {}; 
	local nLevel = 0; 
	local nResValue = 0;
	
	if (nValue > 0) then
		tbItem, nLevel, nResValue = Item:ValueToItemAndMoney(nValue);
		if nLevel == 0 then
			return nil, nil, nPersonalAwardValue; 
		end
	end
	
	nMoney = nResValue + nMoney;
	return nLevel, tbItem[nLevel], nMoney; 
end

-- 确认认领帮会奖励	
function Domain:ReciveTongAwardConfirme(nChoose, szSay)
	if (self:GetBattleState() == self.PRE_BATTLE_STATE or self:GetBattleState() == self.BATTLE_STATE) then
		Dialog:Say("Trong thời gian tuyên chiến và chinh chiến không thể nhận thưởng");
		return 0;
	end

	Dialog:Say("Ngươi lựa chọn "..szSay.."?",
		{
			{"Vâng", self.ReciveTongAward, self, 1, nChoose},
			{"Ta muốn chọn lại"}
		}
	)
end

-- 帮会奖励转优秀成员奖励基金
function Domain:TongAwardToGreatBonus(nTongId, nPlayerId, nPersonalAwardValue)
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0;
	end
	local pTong = KTong.GetTong(cPlayer.dwTongId);
	if not pTong then
		return 0;
	end
	if nPersonalAwardValue + pTong.GetGreatBonus() > 2000000000 or nPersonalAwardValue < 0 then
		cPlayer.Msg("Quỹ thưởng của bang hội đã đạt đến giới hạn");
		return 0;
	end
	Tong:AddGreatBonus_GS(nTongId, nPersonalAwardValue);
	local nMyBattleNo = cPlayer.GetTask(self.TASK_GROUP_ID, self.BATTLE_NO); -- 个人征战流水号
	cPlayer.SetTask(self.TASK_GROUP_ID, self.TONGAWARD_AMOUNT, pTong.GetDomainAwardAmount());
	cPlayer.SetTask(self.TASK_GROUP_ID, self.TONGAWARD_NO, nMyBattleNo);
	KTong.Msg2Tong(nTongId, cPlayer.szName.." sử dụng "..math.floor(nPersonalAwardValue).." điểm thưởng, chuyển vào quỹ thưởng bang hội.");
	return 1;
end
	
-- 接受帮会奖励
function Domain:ReceiveTongAward(nPersonalAwardValue, nPlayerId, nMoneyPercent)
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0;
	end
	local cTong = KTong.GetTong(cPlayer.dwTongId);
	if not cTong then
		return 0;
	end

	if Tong:ReceiveAward(nPersonalAwardValue, nPlayerId, nMoneyPercent, "Domain") == 0 then
		return 0;
	end
	
	local nMyBattleNo = cPlayer.GetTask(self.TASK_GROUP_ID, self.BATTLE_NO); -- 个人征战流水号
	cPlayer.SetTask(self.TASK_GROUP_ID, self.TONGAWARD_AMOUNT, cTong.GetDomainAwardAmount());
	cPlayer.SetTask(self.TASK_GROUP_ID, self.TONGAWARD_NO, nMyBattleNo);
	
	Dbg:WriteLog("DomainBattle", "玩家获得帮会奖励价值", cPlayer.szAccount, cPlayer.szName, nPersonalAwardValue);
	return 1;
end

-- 没有功勋
function Domain:NoScore()
	local nGblBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO); -- 全局征战流水号
	local nMyBattleNo = me.GetTask(self.TASK_GROUP_ID, self.BATTLE_NO); -- 个人征战流水号
	local nSystemAwardNo = me.GetTask(self.TASK_GROUP_ID, self.SYSTEMAWARD_NO);  -- 个人系统奖励流水号
	local nScore = me.GetTask(self.TASK_GROUP_ID, self.SCORE_ID); -- 个人功勋值

	if (nGblBattleNo ~= nMyBattleNo or nScore == 0) then	
		return 1;
	else
		return 0;
	end	
end

-- 领过了系统奖励
function Domain:HasReciveSystemAward()
	local nGblBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO); -- 全局征战流水号
	local nMyBattleNo = me.GetTask(self.TASK_GROUP_ID, self.BATTLE_NO); -- 个人征战流水号
	local nSystemAwardNo = me.GetTask(self.TASK_GROUP_ID, self.SYSTEMAWARD_NO);  -- 个人系统奖励流水号
	if (nGblBattleNo == nMyBattleNo and nMyBattleNo == nSystemAwardNo) then		
		return 1;
	else
		return 0;
	end	
end

-- 领过了帮会奖励 (nAwardAmount:设定的帮会奖励总量)
function Domain:CanReciveTongAward(nAwardAmount)
	local nGblBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO); -- 全局征战流水号
	local nMyBattleNo =  me.GetTask(self.TASK_GROUP_ID, self.BATTLE_NO);  -- 个人征战流水号
	local nTongAwardNo = me.GetTask(self.TASK_GROUP_ID, self.TONGAWARD_NO);  -- 个人帮会奖励流水号
	local nGotValue = me.GetTask(self.TASK_GROUP_ID, self.TONGAWARD_AMOUNT)
	if nTongAwardNo ~= nMyBattleNo then
		 nGotValue = 0;
	end
	local nRestValue = nAwardAmount - nGotValue ; -- 个人还能领的奖励价值
	
	if nGblBattleNo == nMyBattleNo then
		if nMyBattleNo == nTongAwardNo and nRestValue <= 0 then
			return 0;
		else 
			return 1;
		end
	else
		return 0;
	end	
end

function Domain:SetJunXu_GS2(nTongId, nType, nJunXunType, nNum, nCurNo, nDataVer)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local szMsg = "";
	local nMedicineLevel = self:GetMedicineLevel(nJunXunType);
	local nHelpfulLevel = self:GetHelpfulLevel(nJunXunType);
	if nType == self.JUNXU_MEDICINE then
		szMsg = "Bang hội đã thiết lập quân nhu Lãnh thổ chiến, các thành viên trong bang hội có thể đến nhận <color=red>"..self.JUNXU_NAME[self.JUNXU_MEDICINE][nMedicineLevel].." "..nNum.." rương<color>."
		pTong.SetDomainJunXunMedicineNum(nNum);
	end
	if nType == self.JUNXU_HELPFUL then
		szMsg = "Bang hội đã thiết lập vũ khí Lãnh thổ chiến,, các thành viên trong bang hội có thể đến nhận <color=red>"..self.JUNXU_NAME[self.JUNXU_HELPFUL][nHelpfulLevel].." "..nNum.."<color>."
		local nJunXuNo = pTong.GetDomainJunXunNo();
		if nJunXuNo ~= nCurNo then
			pTong.SetDomainJunXunMedicineNum(0);
		end
	end
	pTong.SetDomainJunXunType(nJunXunType);
	pTong.SetDomainJunXunNo(nCurNo);
	pTong.SetTongDataVer(nDataVer);
	KTong.Msg2Tong(nTongId, szMsg);
end

function Domain:FatchJunXu_GS2(nTongId, nPlayerId, nType, nParticular, nLevel, nSucceed, nCostedBuildFund)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	if nCostedBuildFund then
		pTong.SetCostedBuildFund(nCostedBuildFund);  -- 记录本周总共消耗的建设资金	
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if nSucceed == 1 then
		if nType == self.JUNXU_MEDICINE then  
			nLevel = nLevel + 3;
		end
		local pItem = pPlayer.AddItem(18, 1, nParticular, nLevel);
		if not pItem then
			Dbg:WriteLog("DomainBattle", "玩家获取军需是物品不存在", pPlayer.szAccount, pPlayer.szName);
			return 0;
		end
		local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
		pPlayer.SetItemTimeout(pItem,os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 3600 * 24)); -- 领取当天有效
		pItem.Sync();
		pPlayer.Msg("Nhận thành công!");	
		return 1;
	else
		if nType == self.JUNXU_MEDICINE then  
			local nSelfNum = pPlayer.GetTask(self.TASK_GROUP_ID, self.JUNXU_NUM);
			if nSelfNum - 1 < 0 then
				pPlayer.SetTask(self.TASK_GROUP_ID, self.JUNXU_NUM, 0);
				Dbg:WriteLog("DomainBattle", "玩家获取军需有异常", pPlayer.szAccount, pPlayer.szName);
				return 0;
			end
			pPlayer.SetTask(self.TASK_GROUP_ID, self.JUNXU_NUM, nSelfNum - 1);
			pPlayer.Msg("Nhận thất bại!");
		elseif nType == self.JUNXU_HELPFUL then
			local nSelfHelpfulNo = me.GetTask(self.TASK_GROUP_ID, self.JUNXU_HELPFUL_NO);
			pPlayer.SetTask(self.TASK_GROUP_ID, self.JUNXU_HELPFUL_NO, nSelfHelpfulNo - 1);
			pPlayer.Msg("Nhận thất bại!");
		end
		return 0;
	end
end

function Domain:GetMedicineLevel(nJunXunType)
	return nJunXunType % self.JUNXU_HELPFUL;
end

function Domain:GetHelpfulLevel(nJunXunType)
	return  math.floor(nJunXunType / self.JUNXU_HELPFUL);
end

-- 更新缴纳的霸王之印数量
function Domain:UpdateBaZhuZhiYin_GS(szName, bFirst, nCurCount, nMaxCount, nAddCount)
	if (not szName or not bFirst or not nCurCount or not nMaxCount or nCurCount < 0 or
		nMaxCount < 0 or not nAddCount or nAddCount < 0) then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (not pPlayer) then
		return 0;
	end
	
	local nTongId = pPlayer.dwTongId;
	if (nTongId <= 0) then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	
	local tbNpc = Npc:GetClass("chaotingyushi");
	local nCurTongCount = cTong.GetDomainBaZhu() + nAddCount;
	cTong.SetDomainBaZhu(nCurTongCount);
	local nCurPlayerCount = pPlayer.GetTask(tbNpc.TASK_GROUP, tbNpc.TASK_ID_COUNT) + nAddCount;
	pPlayer.SetTask(tbNpc.TASK_GROUP, tbNpc.TASK_ID_COUNT, nCurPlayerCount);
	PlayerHonor:SetPlayerHonorByName(pPlayer.szName, PlayerHonor.HONOR_CLASS_KAIMENTASK, 0, nCurPlayerCount);
	
	local szMsg = "";
	if (0 == bFirst) then
		szMsg = string.format("Hiện tại, ngươi chưa giao nộp <color=yellow>%s<color> Quan ấn, trước tiên phải giao nộp <color=yellow>%s<color>.", 
			nCurPlayerCount, nMaxCount);
	elseif (1 == bFirst) then
		szMsg = string.format("Chúc mừng! Ngươi đã giao nộp <color=yellow>%s<color> Quan ấn, để đạt tối đa, ngươi phải cố gắng nỗ lực thêm!", nCurPlayerCount);
	end
	Setting:SetGlobalObj(pPlayer)
	Dialog:Say(szMsg);
	Setting:RestoreGlobalObj()
	return 1;
end

function Domain:GetTongAward_GS(tbTongAmount)
	local cTong, nTongId = KTong.GetFirstTong();
	local tbTemp = {nTongId = 0, nAmount = 0};
	while (cTong) do
		cTong.SetDomainBaZhu(0);
		cTong, nTongId = KTong.GetNextTong(nTongId)
	end
	local szMsg = "Do ngươi thuộc bang hội giao nộp Quan ấn hoạt động hiệu suất cao, tăng %s quỹ xây, mục đích khích lệ.";
	for i = 1, 10 do
		local v = tbTongAmount[i];
		if (v) then
			cTong = KTong.GetTong(v.nTongId);
			if (cTong and self.BAZHU_AWARD[i]) then
				if (-1 == self.MIN_BAZHU_AMOUNT[i] or v.nAmount >= self.MIN_BAZHU_AMOUNT[i]) then
					cTong.AddBuildFund(self.BAZHU_AWARD[i]);
					KTong.Msg2Tong(v.nTongId, string.format(szMsg, self.BAZHU_AWARD[i]));
				end
			end
		end
	end
end

function Domain:ResumePreBattle(nDataVer, tbDeclareDomainTong, tbTongDeclare)
	local nCurBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	print("领土战准备阶段GS宕机保护--开始执行！");
	self:StartDomainBattle_GS2(nCurBattleNo, nDataVer);
	self.tbDeclareDomainTong = tbDeclareDomainTong;
	self.tbTongDeclare = tbTongDeclare;
end

function Domain:ResumeBattle(nDataVer, tbDeclareDomainTong, tbTongDeclare, tbPlayer, tbDomainScore, tbReact)
	local nCurBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	print("领土战征战阶段GS宕机保护--开始执行！");
	self:StartDomainBattle_GS2(nCurBattleNo, nDataVer);
	self.tbDeclareDomainTong = tbDeclareDomainTong;
	self.tbTongDeclare = tbTongDeclare;
	self.tbReact = tbReact;
	self:BeginAllGame();
	
	-- 恢复积分
	for nMapId, tbScore in pairs(tbDomainScore) do
		for nId, nScore in pairs(tbScore) do
			print("MapId:", nMapId, "TongId", nId, "Score:", nScore);
			local tbBase = self.tbGame[nMapId];
			local tbSortResult = {};
			
			if tbBase then			
				if not tbBase.tbTongOrUnion[nId] then
					tbBase.tbTongOrUnion[nId] = {};				
					local pTong = KTong.GetTong(nId) or KUnion.GetUnion(nId);
					if nId == 0 then
						tbBase.tbTongOrUnion[nId].szName = Domain.NPC_TONG_NAME[tbBase.nCountryId];
					elseif pTong then
						tbBase.tbTongOrUnion[nId].szName = pTong.GetName();
					else
						return;
					end
					tbBase.tbTongOrUnion[nId].nScore = 0;
					tbBase.tbTongOrUnion[nId].nSort = #self.tbSort + 1;	-- 设置排名为2使更新排名函数有效执行
					table.insert(tbBase.tbSort, nId);	
					tbSortResult[nId] = tbBase.tbTongOrUnion[nId].nSort;			
				end
				
				tbBase.tbTongOrUnion[nId].nScore = tbBase.tbTongOrUnion[nId].nScore + nScore;
				tbSortResult = tbBase:UpdateSort(nId, tbSortResult);
				self:AddTongScore_GS1(nMapId, nId, tbBase.tbTongOrUnion[nId].nScore, tbSortResult);
			end		
		end	
	end
end

function Domain:ResumeStopBattle()
	print("领土战休战阶段GS宕机保护--开始执行！");
	self:StopAllGame();
end