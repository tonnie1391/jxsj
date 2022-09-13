
-- 
-- 领土争夺战 GC脚本
--  zhengyuhua
if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\domainbattle\\domainbattle_def.lua");

-- 初始化
function Domain:InitDomain_GC()
	self.tbPlayer 		= {};		-- 玩家功勋记录
	self.tbPlayerToUnion = {};
	self.tbDomainScore 	= {};		-- 区域积分
	self.nBattleState 	= self.NO_BATTLE;
	self.nTimerId 		= 0;
	self.nExpTimerId	= 0;		-- 经验时间ID
	
	-- 增加宕机保护
	self.tbDeclareDomainTong = {}; 	-- 地图ID对应的宣战帮会ID表
	self.tbTongDeclare = {};		-- 帮会ID对应宣战地图ID表
	self.tbReact = {}; 				-- 增加反扑表的存储
end

function Domain:GetBattleState_GC()
	return self.nBattleState;
end

-- 开启区域战流程
function Domain:StartDomainBattle()
	print("Domain:StartDomainBattle")
	local tbData = Domain:GetOpenStateTable()
	if not tbData then
		return 0;
	end
	local nWeekDay = tonumber(os.date("%w", GetTime()))

	if self.OPEN_DATE[nWeekDay] ~= 1 then
		return 0
	end
	--if self.nBattleState ~= self.NO_BATTLE then
	--	return 0;
	--end
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	KGblTask.SCSetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO, nCurNo + 1);
	Domain:InitDomain_GC();
	self.nBattleState = self.PRE_BATTLE_STATE;
	GlobalExcute{"Domain:StartDomainBattle_GS2", nCurNo + 1, Domain:UpdateDataVer()};		-- 根据次数判断要开的区域
end

-- 开启区域战
function Domain:StartAllGame_GC()
	print("Domain:StartAllGame_GC")
	if self.nBattleState ~= self.PRE_BATTLE_STATE then
		return 0;
	end
	self.nBattleState = self.BATTLE_STATE;
	if self.nTimerId > 0 then
		Timer:Close(self.nTimerId);
		self.nTimerId = 0;
	end
	self.nCurExpFlag = 0;
	self.nTimerId = Timer:Register(self.BATTLE_TIME * Env.GAME_FPS, self.StopAllGame_GC, self);
	self.nExpTimerId = Timer:Register(1, self.UpdateExpFlag, self);	-- 晚一帧执行
	self:CalculateReact();
	GlobalExcute{"Domain:BeginAllGame"};
end

-- 计算反扑
function Domain:CalculateReact()
	local pTong, nTongId = KTong.GetFirstTong();
	while pTong do
		if pTong and pTong.GetDomainCount() > self.MIN_REACT_DOMAINCOUNT then
			local pDomainItor = pTong.GetDomainItor();
			local nDomainId = pDomainItor.GetCurDomainId();
			local tbOwnerDomain = {};
			local tbReactDomain = {};
			while (nDomainId and nDomainId ~= 0) do
				if pTong.GetCapital() ~= nDomainId and self:GetDomainType(nDomainId) ~= "village" then
				   	if self.tbReactRate[nDomainId] and self.tbReactRate[nDomainId] > MathRandom(1, 100) then
						table.insert(tbReactDomain, nDomainId);
						Dbg:WriteLog("Domain NotifyNpcReact", nDomainId);
					end
					table.insert(tbOwnerDomain, nDomainId);
				end
				nDomainId = pDomainItor.NextDomainId();
			end
			if #tbReactDomain == 0 and pTong.GetDomainCount() >= self.BE_REACT_DOMAINCOUNT  then
				local nIndex = MathRandom(1, #tbOwnerDomain);
				local nReactDomainId = tbOwnerDomain[nIndex];
				if nReactDomainId then
					table.insert(tbReactDomain, nReactDomainId);
					Dbg:WriteLog("Domain NotifyNpcReact", nReactDomainId);
				end
			end
			GlobalExcute{"Domain:NotifyNpcReact_GS2", nTongId, tbReactDomain};
			
			-- GC存储NPC反扑地图表，以便GS宕机重启后同步
			if #tbReactDomain ~= 0 then
				for i = 1, #tbReactDomain do
					local nReactDomainId = tbReactDomain[i];
					if not self.tbReact[nReactDomainId] then
						self.tbReact[nReactDomainId] = {};
					end
					self.tbReact[nReactDomainId] = 1;
				end			
			end
			
		end
		pTong, nTongId = KTong.GetNextTong(nTongId);
	end
end

-- 每5分钟更新一次加经验的标记
function Domain:UpdateExpFlag()
	if not self.nCurExpFlag then
		return 0;
	end
	self.nCurExpFlag = self.nCurExpFlag + 1;
	GlobalExcute{"Domain:UpdateExpFlag_GS2", self.nCurExpFlag};
	if self.nCurExpFlag <= self.MAX_FLAG then
		return self.CHANGE_FLAG_TIME * Env.GAME_FPS;		-- 后面每隔一段时间执行一次
	else
		return 0;
	end
end

-- 休战期
function Domain:StopAllGame_GC()
	print("Domain:StopAllGame_GC")
	if self.nBattleState ~= self.BATTLE_STATE then
		return 0;
	end
	self.nBattleState = self.STOP_STATE;
	
	GlobalExcute{"Domain:StopAllGame"};
	Timer:Register(10 * Env.GAME_FPS, self.SortMemberScore_GC, self);
	if self.nTimerId > 0 then
		Timer:Close(self.nTimerId);
		self.nTimerId = 0;
	end
	self.nTimerId = Timer:Register(self.STOP_TIME * Env.GAME_FPS, self.EndAllGame_GC, self);
	return 0;
end

-- 关闭
function Domain:EndAllGame_GC()
	print("Domain:EndAllGame_GC");
	if self.nBattleState ~= self.STOP_STATE then
		return 0;
	end
	if self.nTimerId > 0 then
		Timer:Close(self.nTimerId);
		self.nTimerId = 0;
	end
	self.nBattleState = self.NO_BATTLE;
	GlobalExcute{"Domain:EndAllGame"};
	return 0;
end

-- 设置帮会在某区域积分
function Domain:SetTongScore_GC(nMapId, nTongId, nScore, tbSortResult)
	if not self.tbDomainScore[nMapId] then
		self.tbDomainScore[nMapId] = {};
	end
	self.tbDomainScore[nMapId][nTongId] = nScore;
	return GlobalExcute{"Domain:SetTongScore_GS2", nMapId, nTongId, nScore, tbSortResult};
end


function Domain:FatchJunXu_GC(nTongId, nPlayerId, nType, nParticular, nLevel)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	
	local nSucceed = 0;
	local nJunXuMoney = 0;
	if nType == self.JUNXU_MEDICINE then
		nJunXuMoney = self.JUNXU_MEDICINE_PRICE[nLevel];
	elseif nType == self.JUNXU_HELPFUL then
		nJunXuMoney = self.JUNXU_HELPFUL_PRICE[nLevel];
	end
	if Tong:CanCostedBuildFund(nTongId, 0, 0, nJunXuMoney, 0) == 1 then	
		Tong:ConsumeBuildFund_GC(nTongId, nJunXuMoney);
		pTong.AddCostedBuildFund(nJunXuMoney);  -- 记录本周总共消耗的建设资金	
		nSucceed = 1;
	end	
	return GlobalExcute{"Domain:FatchJunXu_GS2", nTongId, nPlayerId, nType, nParticular, nLevel, nSucceed, pTong.GetCostedBuildFund()};
end

-- 记录所有有积分的玩家（临时存于内存，方便结束时候排序）
function Domain:SetTongPlayerScore_GC(nUnionId, nTongId, nPlayerId, nScore)
	if nTongId == 0 then
		return 0;
	end
	
	-- 按帮会记分
	if not self.tbPlayer[nTongId] then
		self.tbPlayer[nTongId] = {};
	end
	self.tbPlayer[nTongId][nPlayerId] = nScore;
	
	-- 统计联盟总人数
	if not self.tbPlayerToUnion[nUnionId] then
		self.tbPlayerToUnion[nUnionId] = {};
		self.tbPlayerToUnion[nUnionId].nTotalCount = 0;
	end
	if not self.tbPlayerToUnion[nUnionId][nPlayerId] then
		self.tbPlayerToUnion[nUnionId][nPlayerId] = nTongId;
		self.tbPlayerToUnion[nUnionId].nTotalCount = self.tbPlayerToUnion[nUnionId].nTotalCount + 1
	end
end

-- 排序并同步
function Domain:SortMemberScore_GC()
	print("Domain:SortMemberScore_GC");
	local tbSort =
	{
		__lt = function(tbA, tbB)
			return tbA.nKey > tbB.nKey;
		end
	};
	for nTongId, tbPlayerSet in pairs(self.tbPlayer) do	
		local pTong = KTong.GetTong(nTongId);
		if pTong then
			-- 领袖荣誉
			self:IncreasePlayerHonor(nTongId);	
	
			local tbSortScore = {}
			local nAttendCount = 0;
			for nPlayerId, nScore in pairs(tbPlayerSet) do
				local tbTemp = {nKey = nScore, nId = nPlayerId};
				nAttendCount = nAttendCount + 1;		-- 计算出席人数
				setmetatable(tbTemp, tbSort);
				table.insert(tbSortScore, tbTemp);
			end
			table.sort(tbSortScore);

			local tbAwardLimit = {};
			local nMemberNum = #tbSortScore;
			local nPercent = 0;
			for i, tbInfo in ipairs(self.DOMAINBATTLE_SCORE_RATE_TABLE) do
				nPercent = nPercent + tbInfo[1];
				local nIndex = math.floor(nPercent * nMemberNum)
				if nIndex < 1 then
					nIndex = 1;
				end
				tbAwardLimit[i] = tbSortScore[nIndex].nKey;
				if i == 2 and tbAwardLimit[1] == tbAwardLimit[2] then
					tbAwardLimit[1] = tbAwardLimit[1] + 1;	-- 第一档次与第二档次同积分则给提高第一档次的分数
					pTong.SetDomainAwardLimit(1, tbAwardLimit[1]);
				end
				pTong.SetDomainAwardLimit(i, tbAwardLimit[i]);
			end
			
			pTong.SetDomainAttendNum(nAttendCount);			-- 记录出席人数
			local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
			pTong.SetDomainAttendNo(nCurNo);
			local szResult = "";
			for i = 1, math.min(10,#tbSortScore) do
				local szName = KGCPlayer.GetPlayerName(tbSortScore[i].nId)
				szResult = szResult..Lib:StrFillL("Hạng "..i, 8)..Lib:StrFillL(szName, 18)..tbSortScore[i].nKey.."\n"
			end
			pTong.SetDomainResult(szResult);
			Tong:AdjustOfficialMaxLevel_GC(nTongId);
			print("SetSystemAward_GC");
			self:SetSystemAward_GC(nTongId);
			GlobalExcute{"Domain:SetAwardScoreLimit", nTongId, tbAwardLimit, nAttendCount, nCurNo, szResult};
		end
	end
	
	self:AddDomainNews();
	Domain:UpdateDataDomainColor();		-- 更新领土颜色
	return 0;
end

function Domain:IncreasePlayerHonor(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	-- 计算该帮会对应领袖荣誉
	local nHonor = 0;	--该帮会对应的领袖荣誉
	local nDomainNum = pTong.GetDomainCount();		-- 该帮会占领的领土数量
	for i = 1, #self.DOMAIN_RATE do
		if (nDomainNum >= self.DOMAIN_RATE[i]) then	
			nHonor = self.LINXIU_HONOR[i];
			break;
		end
	end
	-- 增加帮主的领袖荣誉
	local nMasterId = Tong:GetMasterId(nTongId);
	if nMasterId ~= 0 then	
		PlayerHonor:AddPlayerHonor(nMasterId, PlayerHonor.HONOR_CLASS_LINGXIU, 0, nHonor);
	end
	-- 增加非帮主族长的领袖荣誉			
	local pKinItor = pTong.GetKinItor()
	local nKinInTongId = pKinItor.GetCurKinId();
	while (nKinInTongId > 0) do
		local pKinInTong = KKin.GetKin(nKinInTongId);
		local nCaptainId = Kin:GetPlayerIdByMemberId(nKinInTongId, pKinInTong.GetCaptain());
		if nMasterId ~= nCaptainId then
			PlayerHonor:AddPlayerHonor(nCaptainId, PlayerHonor.HONOR_CLASS_LINGXIU, 0, nHonor/5);
		end
		nKinInTongId = pKinItor.NextKinId();
	end
end

-- 所有帮会联盟领土统计排名
function Domain:DomainCountSort()
	local tbSort =
	{
		__lt = function(tbA, tbB)
			return tbA.nKey > tbB.nKey;
		end
	};
	-- 所有帮会联盟领土统计排名
	local tbDomainCount = {}
	for nDomainId, _ in pairs(self.tbDomainName) do
		local nId = self:GetDomainOwner(nDomainId);
		if nId ~= 0 then
			-- 如果是领土拥有者是“帮会”
			local pTong = KTong.GetTong(nId);
			if pTong then
				local nUnionId = pTong.GetBelongUnion();
				-- 如果该帮会有联盟，则算联盟
				if nUnionId ~= 0 then
					local pUnion = KUnion.GetUnion(nId);
					if pUnion then
						tbDomainCount[nUnionId] = (tbDomainCount[nUnionId] or 0) + 1;
					end
				else
					tbDomainCount[nId] = (tbDomainCount[nId] or 0) + 1; 
				end
			end
			-- 如果是领土拥有者是“联盟”
			local pUnion = KUnion.GetUnion(nId);
			if pUnion then
				tbDomainCount[nId] = (tbDomainCount[nId] or 0) + 1;
			end
		end
	end
	local tbTempToSort = {};
	for nId, nCount in pairs(tbDomainCount) do
		local tbTemp = {nId = nId, nKey = nCount};
		setmetatable(tbTemp, tbSort);
		table.insert(tbTempToSort, tbTemp);
	end
	table.sort(tbTempToSort);
	return tbTempToSort;
end

-- 更新领土颜色
function Domain:UpdateDataDomainColor()	
	print("UpdateDataDomainColor");
	local tbTempToSort = self:DomainCountSort();
	local nNoColorCount = 0;
	if tbTempToSort[11] then	
		nNoColorCount = tbTempToSort[11].nKey;
	end
	local tbColor = {0,0,0,0,0,0,0,0,0,0}		-- 10种颜色标志位~占用置1
	local tbTongToColor = {};					-- 待分配的帮会颜色，线性操作，直接记对象
	local tbSyncInfo = {};						-- 同步信息
	-- 统计颜色占用情况
	for i = 1, #tbTempToSort do
		local pTong =KTong.GetTong(tbTempToSort[i].nId);
		local pUnion =KUnion.GetUnion(tbTempToSort[i].nId);
		local pDomainOwner = nil;
		if pTong then
			pDomainOwner = pTong;
		end
		if pUnion then
			pDomainOwner = pUnion;
		end
		if pDomainOwner then
			if tbTempToSort[i].nKey > nNoColorCount then	-- 不大于第11个排名的帮会没有特殊颜色
				local nColor = pDomainOwner.GetDomainColor();
				if tbColor[nColor] and tbColor[nColor] == 0 then
					tbColor[nColor] = 1;					-- 颜色占用
					tbSyncInfo[tbTempToSort[i].nId] = nColor;
				else
					table.insert(tbTongToColor, {nId = tbTempToSort[i].nId, pOwner = pDomainOwner});		-- 待分配
				end
			else
				pDomainOwner.SetDomainColor(0)
				tbSyncInfo[tbTempToSort[i].nId] = 0;
			end
		end
	end
	
	-- 分配颜色
	local nIndex = 1;
	for nColor, bOccupy in ipairs(tbColor) do
		if bOccupy == 0 and tbTongToColor[nIndex] then
			tbTongToColor[nIndex].pOwner.SetDomainColor(nColor);
			tbSyncInfo[tbTongToColor[nIndex].nId] = nColor;
			nIndex = nIndex + 1;
		end
	end
	local nDataVer = Domain:UpdateDataVer();
	GlobalExcute{"Domain:UpdateDataDomainColor_GS2", tbSyncInfo, nDataVer};
end

-- 领土争夺战 帮助锦囊战报
function Domain:AddDomainNews()
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 24 * 3600;
	local tbSort =
	{
		__lt = function(tbA, tbB)
			return tbA.nKey > tbB.nKey;
		end
	};
	local nTemp = {};
	local tbDomains = self:GetDomains()
	for nDomainId, _ in pairs(tbDomains) do
		local nTongId = self:GetDomainOwner(nDomainId)
		if nTongId ~= 0 then
			nTemp[nTongId] = (nTemp[nTongId] or 0) + 1;
		end
	end
	local tbResult = {}
	local tbVillageResult = {};
	for nTongId, nCount in pairs(nTemp) do
		local pTong = KTong.GetTong(nTongId);
		if pTong then
			local bInsert = 0;
			if nCount == 1 then
				local pItor = pTong.GetDomainItor()
				local nDomainId = pItor.GetCurDomainId();
				if Domain:GetDomainType(nDomainId) == "village" then
					table.insert(tbVillageResult, {szTongName = pTong.GetName(), szVillage = Domain:GetDomainName(nDomainId) or ""});
					bInsert = 1;
				end
			end
			if bInsert ~= 1 then
				local tbInfo = {szName = pTong.GetName(), nKey = nCount}
				setmetatable(tbInfo, tbSort);
				table.insert(tbResult, tbInfo);
			end
		end
	end
	table.sort(tbResult);
	
	local szMsg = "";
	local nCount = 1;
	local nSort = 1;
	local nBefore = 0;
	szMsg = os.date("%Y年%m月%d日 <color=yellow>领土争夺战战报<color>\n", GetTime());
	while (nCount <= 10 or nSort <= 10) and (#tbResult >= nCount) do
		szMsg = szMsg.."\n"..Lib:StrFillL("Hạng "..nSort, 8).."<color=yellow>"..Lib:StrFillL(tbResult[nCount].szName, 14).."<color>占领了<color=green>"..tbResult[nCount].nKey.."<color>块领土"
		nBefore = tbResult[nCount].nKey;
		nCount = nCount + 1
		if tbResult[nCount] and nBefore ~= tbResult[nCount].nKey then
			nSort = nCount;
		end
	end
	
	if #tbVillageResult > 0 then
		szMsg = szMsg.."\n\n<color=yellow>新手村战报<color>\n\n";
		for _, tbInfo in ipairs(tbVillageResult) do
			szMsg = szMsg..string.format("<color=yellow>%s<color>攻占了<color=green>%s<color>，获得领土攻打资格！\n", 
				tbInfo.szTongName, tbInfo.szVillage);
		end
	end
	
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_STARTDOMAIN, "领土争夺战战报", szMsg, nEndTime, nAddTime);
end


-- 设置区域新归属（删除原有归属，设置新归属，nNewOwnerId为0，则仅删除）
function Domain:SetDomainOwner_GC(nDomainId, nNewOwnerId, bIsDispense)
	local tbDomainName = self:GetDomains()
	local nOrgOwnerId = self:GetDomainOwner(nDomainId);
	if nOrgOwnerId == nNewOwnerId then
		return 1;
	end
	-- Owner可能是帮会也可能是联盟
	-- 删除原有
	if nOrgOwnerId ~= 0 then
		local pTong = KTong.GetTong(nOrgOwnerId);
		if pTong then
			if (pTong.DelDomain(nDomainId) ~= 1) then
				print("[Error]", "Domain:SetDomainOwner_DelOrg", pTong, nDomainId, nOrgOwnerId, nNewOwnerId);
			end
			local szName = tbDomainName[nDomainId]
			if szName then
				pTong.AddAffairLost(szName);
				_G.TongLog(pTong.GetName(), Log.emKTONG_LOG_TONGSTRUCTURE, string.format("帮会%s失去领土[%s]", pTong.GetName(), szName));
			end
			if pTong.GetCapital() == nDomainId then
				pTong.SetCapital(0);
			end
		end
		local pUnion = KUnion.GetUnion(nOrgOwnerId);
		if pUnion then
			if (pUnion.DelDomain(nDomainId) ~= 1) then
				print("[Error]", "Domain:SetDomainOwner_DelOrg", pUnion, nDomainId, nOrgOwnerId, nNewOwnerId);
			end
			local szName = tbDomainName[nDomainId];
			if szName then
				_G.TongLog(pUnion.GetName(), Log.emKTONG_LOG_TONGSTRUCTURE, string.format("联盟%s失去领土[%s]", pUnion.GetName(), szName));
			end
		end
	end
	local nTime = GetTime();
	-- 增加到新归属
	if (nNewOwnerId ~= 0) then
		local pTong = KTong.GetTong(nNewOwnerId);
		local pDomain;
		if pTong then
			local szName = tbDomainName[nDomainId]
			if szName then
				pTong.AddAffairOccupy(szName);
				_G.TongLog(pTong.GetName(), Log.emKTONG_LOG_TONGSTRUCTURE, string.format("帮会%s占领领土[%s]", pTong.GetName(), szName));
			end
			pDomain = pTong.AddDomain(nDomainId);
			if pDomain then
				pDomain.SetOccupyTime(nTime);
			end
			if (not pDomain) then
				print("[Error]", "Domain:SetDomainOwner_SetNew", pTong, pDomain, nDomainId, nOrgOwnerId, nNewOwnerId);
			end	
		end
		local pUnion = KUnion.GetUnion(nNewOwnerId);
		if pUnion then
			pUnion.AddDomain(nDomainId, nTime);
			local szName = tbDomainName[nDomainId]
			if szName then
				_G.TongLog(pUnion.GetName(), Log.emKTONG_LOG_TONGSTRUCTURE, string.format("联盟%s占领领土[%s]", pUnion.GetName(), szName));
			end
		end
	end
	self:SetDomainOwner(nDomainId, nNewOwnerId);
	local nDataVer = Domain:UpdateDataVer();
	return GlobalExcute{"Domain:SetDomainOwner_GS2", nDomainId, nOrgOwnerId, nNewOwnerId, nTime, nDataVer, bIsDispense};
end

-- 更新数据版本号
function Domain:UpdateDataVer()
	self.nDataVer = self.nDataVer + 1;
	return self.nDataVer;
end

-- 新领土宣战(gc执行)
function Domain:DeclareWar_GC(nDomainId, nTongId)
	local cTong = KTong.GetTong(nTongId);
	if cTong == nil then
		print("[Error]", "Domain:DeclareWar_GC", nDomainId, nTongId);
		return 0;
	end

	return GlobalExcute{"Domain:DeclareWar_GS2", nDomainId, nTongId};
end

-- 设置系统奖励
function Domain:SetSystemAward_GC(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	local nMemberCount = pTong.GetDomainAttendNum(); 	-- 帮会参战人数
	
	local nTotalValue = 0;
	local tbTong = {}
	local nUnionId = pTong.GetBelongUnion();
	local pUnion = KUnion.GetUnion(nUnionId);
	if pUnion then
		nTotalValue = self:GetUnionDomainScore(nUnionId); -- 该联盟的领土总分
		tbTong = Union:GetTongTable(nUnionId);
	 -- 帮会人数在联盟中的比例
	else
		local nTotalReputeParam = self:GetTotalReputeParam(nTongId);  -- 该帮的领土总星级
		nTotalValue = self:CalculateDomainScore(nTotalReputeParam); -- 该帮领土总分		
		tbTong = Union:GetTongTable(nTongId);
	end	

	-- 合服额外加成
	if GetTime() < KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME) + 7 * 24 * 60 * 60 and KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME) > 0 then -- 合服前两次领土战给予合服前奖励
		for i = 1, #tbTong do
			local nConzoneReputeParam = tbTong[i].GetConzoneReputeParam();
			nTotalValue = nTotalValue + self:CalculateDomainScore(nConzoneReputeParam);
		end
	end

	if pUnion and self.tbPlayerToUnion[nUnionId] and self.tbPlayerToUnion[nUnionId].nTotalCount ~= 0 then
		nTotalValue = nTotalValue * nMemberCount / self.tbPlayerToUnion[nUnionId].nTotalCount;
	end
	
	if nMemberCount < 50 then 
		nMemberCount = 50;
	end
	print("DomainAward", pTong.GetName(), "nTotalValue", nTotalValue)
	local tbPersonDomainScore = {};
	-- 计算和设置不同功勋档次的个人领土得分
	for i = 1, #self.DOMAINBATTLE_SCORE_RATE_TABLE do
		-- 该档次的人数
		local nLevelMemberCount = math.ceil(nMemberCount * self.DOMAINBATTLE_SCORE_RATE_TABLE[i][1]); 
		local nPersonVelue = nTotalValue * self.DOMAINBATTLE_SCORE_RATE_TABLE[i][4] / nLevelMemberCount;
		table.insert(tbPersonDomainScore, nPersonVelue);
		pTong.SetPersonDomainScore(i, nPersonVelue);
		print("DomainAward", pTong.GetName(), "nPersonVelue", nPersonVelue)
	end
	
	return GlobalExcute{"Domain:SetSystemAward_GS2", nTongId, tbPersonDomainScore};
end	

-- 设置帮会奖励额度GC
function Domain:SetTongAward_GC(nTongId, nSelfKinId, nSelfMemberId, nLevel, nPlayerId)
	if (Domain:GetBattleState_GC() == self.PRE_BATTLE_STATE or Domain:GetBattleState_GC() == self.BATTLE_STATE) then
		return 0;
	end
	
	if Tong:CheckPresidentRight(nTongId, nSelfKinId, nSelfMemberId) ~= 1 then
		return 0;
	end

	local cTong = KTong.GetTong(nTongId);
	local nGblBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	local nWastage = self.DOMAINBATTLE_AWARD_TABLE[nLevel];
	local nTongBuildFund = cTong.GetBuildFund() - nWastage;
	local nDomainAwardAmount = 0;
	if cTong.GetDomainAwardNo() == nGblBattleNo then
		nDomainAwardAmount = cTong.GetDomainAwardAmount() + nWastage;
	else
		nDomainAwardAmount = nWastage;
	end

	if (cTong and nLevel > 0 and nWastage > 0 and nTongBuildFund >= 0 and 
		cTong.GetDomainAttendNo() == nGblBattleNo and nDomainAwardAmount > 0 and nDomainAwardAmount <= self.MAX_DOMAINAWARD_AWARD) then 
			print("帮会: "..cTong.GetName().." 追加军饷到："..nDomainAwardAmount);
			cTong.SetDomainAwardAmount(nDomainAwardAmount);
			cTong.SetBuildFund(nTongBuildFund);
			cTong.SetDomainAwardNo(nGblBattleNo);
			cTong.AddAffairTongAward(KGCPlayer.GetPlayerName(nPlayerId), tostring(nWastage));
			return GlobalExcute{"Domain:SetTongAward_GS2", nTongId, nTongBuildFund, nDomainAwardAmount, nPlayerId};
	end
	return 0;
end

function Domain:SetJunXu_GC(nTongId, nType, nLevel, nNum)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local nJunXuNo = pTong.GetDomainJunXunNo();
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	local nJunXunType = pTong.GetDomainJunXunType()
	if nJunXuNo == nCurNo then		-- 本场额度已经设过
		if nType == self.JUNXU_MEDICINE and nNum then
			nJunXunType = nJunXunType + nLevel;
			pTong.SetDomainJunXunMedicineNum(nNum);
		else
			nJunXunType = nJunXunType + nLevel * self.JUNXU_HELPFUL;
		end
	else
		if nType == self.JUNXU_MEDICINE and nNum then
			nJunXunType = nLevel;
			pTong.SetDomainJunXunMedicineNum(nNum);
		else
			nJunXunType = nLevel * self.JUNXU_HELPFUL;
			pTong.SetDomainJunXunMedicineNum(0);
		end
	end
	pTong.SetDomainJunXunNo(nCurNo);
	pTong.SetDomainJunXunType(nJunXunType);	
	Tong.nJourNum = Tong.nJourNum + 1;
	pTong.SetTongDataVer(Tong.nJourNum);
	GlobalExcute{"Domain:SetJunXu_GS2", nTongId, nType, nJunXunType, nNum, nCurNo, Tong.nJourNum}
end

-- 清除所有领土拥有者
function Domain:ResetDomainState()
	local tbDomains = self:GetDomains()
	for nDomainId, _ in pairs(tbDomains) do
		self:SetDomainOwner_GC(nDomainId, 0);
	end
end

-- 合服处理（额外系统奖励，攻击目标数）
function Domain:CozoneDomain_Deal()
	local pTong, nTongId = KTong.GetFirstTong();
	while (pTong) do
		local nReputeParam = self:GetTotalReputeParam(nTongId);
		pTong.SetCozoneAttackNum(pTong.GetDomainCount());
		pTong.SetConzoneReputeParam(nReputeParam);
		pTong, nTongId = KTong.GetNextTong(nTongId)
	end
	self:ResetDomainState(); -- 清所有占领地图
end

-- 更新全区缴纳霸主之印最多的玩家
function Domain:UpdateBaZhuZhiYin_GC(szName, nTongId, nCurCount, nAddCount)
	if (not szName or "" == szName or not nCurCount or nCurCount < 0 or not nAddCount or nAddCount < 0 or
		not nTongId or nTongId <= 0) then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	
	local bIsFirst = 0;
	local nCurTongCount = cTong.GetDomainBaZhu() + nAddCount;
	cTong.SetDomainBaZhu(nCurTongCount);
	local nCurMaxCount = KGblTask.SCGetDbTaskInt(DBTASK_BAZHUZHIYIN_MAX);
	if ((nCurCount + nAddCount) > nCurMaxCount) then
		bIsFirst = 1;
		nCurMaxCount = nCurCount + nAddCount;
		KGblTask.SCSetDbTaskStr(DBTASK_BAZHUZHIYIN_MAX, szName);
		KGblTask.SCSetDbTaskInt(DBTASK_BAZHUZHIYIN_MAX, nCurCount + nAddCount);
	end
	return GlobalExcute{"Domain:UpdateBaZhuZhiYin_GS", szName, bIsFirst, nCurCount, nCurMaxCount, nAddCount};
end

function Domain:IsAward()
	local nOpenTime = KGblTask.SCGetDbTaskInt(DBTASK_DOMAINTASK_OPENTIME);
	if (0 == nOpenTime) then
		return 0;
	end
	local nState = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_STEP);
	if (3 == nState) then	-- 3表示活动结束状态
		local nOpenDay	= Lib:GetLocalDay(nOpenTime);
		local nStartAwardDay = nOpenDay + math.floor(Domain.DomainTask.VAILD_OPEN_TIME / (3600 * 24));
		-- by zhangjinpin@kingsoft
		local nCozoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);
		local nCozoneDay	= Lib:GetLocalDay(nCozoneTime);
		if nCozoneDay > nOpenDay and nCozoneDay < nStartAwardDay then
			nStartAwardDay	= nStartAwardDay + math.floor(Domain.DomainTask.EXTRA_COZONE_TIME / (3600 * 24));
		end
		-- end
		
		local nEndAwardDay = nStartAwardDay + 5;
		local nNowTime = GetTime();
		local nNowDay	= Lib:GetLocalDay(nNowTime);
		if (nNowDay >= nStartAwardDay and nNowDay <= nEndAwardDay) then
			return 1;
		end
	end
	return 0;
end

-- 为和服操作提供是否发放完帮会奖励的接口
function Domain:IsGetTongAward()
	local cTong, nTongId = KTong.GetFirstTong();
	local tbTongAmount = {};
	while (cTong) do
		local tbTemp = {};
		local nAmount = cTong.GetDomainBaZhu();
		tbTemp.nTongId = nTongId;
		tbTemp.nAmount = nAmount;
		table.insert(tbTongAmount, tbTemp);
		cTong, nTongId = KTong.GetNextTong(nTongId)
	end
	if (Lib:CountTB(tbTongAmount) == 0) then
		return 0;
	end
	table.sort(tbTongAmount, function(a, b) return (a.nAmount > b.nAmount) end);
	if (tbTongAmount[1].nAmount == 0) then
		return 1;
	end
	return 0;
end

-- 合服的时候调用的发放霸主之印帮会奖励接口
function Domain:CozoneGetTongAward()
	local szReason = "cozone";
	self:GetTongAward_GC(szReason);
end

-- 为帮会发放霸主之印的奖励（增加建设资金）
function Domain:GetTongAward_GC(szReason)
	if (not szReason or "cozone" ~= szReason) then
		if (self:IsAward() == 0) then
			return;
		end
	end
	local cTong, nTongId = KTong.GetFirstTong();
	local tbTongAmount_All = {};
	while (cTong) do
		local tbTemp = {};
		local nAmount = cTong.GetDomainBaZhu();
		tbTemp.nTongId = nTongId;
		tbTemp.nAmount = nAmount;
		table.insert(tbTongAmount_All, tbTemp);
		cTong.SetDomainBaZhu(0);
		cTong, nTongId = KTong.GetNextTong(nTongId)
	end
	table.sort(tbTongAmount_All, function(a, b) return (a.nAmount > b.nAmount) end);
	if (not tbTongAmount_All[1] or tbTongAmount_All[1].nAmount == 0) then
		return;
	end
	
	local tbTongAmount = {};
	for i = 1, 10 do
		if (tbTongAmount_All[i] and tbTongAmount_All[i].nAmount > 0) then
			table.insert(tbTongAmount, tbTongAmount_All[i]);
		end
	end
	
	for i = 1, 10 do
		local v = tbTongAmount[i];
		if (not v) then
			break;
		end
		cTong = KTong.GetTong(v.nTongId);
		if (not cTong) then
			break;
		end
		if (not self.BAZHU_AWARD[i]) then
			break;
		end
		if (-1 ~= self.MIN_BAZHU_AMOUNT[i] and v.nAmount < self.MIN_BAZHU_AMOUNT[i]) then
			break;
		end
		cTong.AddBuildFund(self.BAZHU_AWARD[i]);
		Dbg:WriteLog("Domain", "tbChaoTingYuShi", string.format("霸主之印任务为帮会%s发放建设资金%s", cTong.GetName(), self.BAZHU_AWARD[i]));
		Dbg:Output("Domain", "tbChaoTingYuShi", string.format("霸主之印任务为帮会%s发放建设资金%s", cTong.GetName(), self.BAZHU_AWARD[i]));
	end
	GlobalExcute{"Domain:GetTongAward_GS", tbTongAmount};
	if (not szReason or "cozone" ~= szReason) then
		local szName	= KGblTask.SCGetDbTaskStr(DBTASK_BAZHUZHIYIN_MAX);
		self.tbStatuary:AddStatuaryCompetence(szName, Domain.tbStatuary.TYPE_EVENT_NORMAL);
		self:AddHelpNews_Result(tbTongAmount);
	end
end

function Domain:AddHelpNews_Result(tbTongAmount)
	local tbResult = {};
	for i = 1, 10 do
		local v = tbTongAmount[i];
		if (v) then
			local tbTemp = {};
			local cTong = KTong.GetTong(v.nTongId);
			if (cTong) then
				tbTemp.szTongName = cTong.GetName();
				tbTemp.nValue = v.nAmount;
				if (0 == tbTemp.nValue) then
					break;
				end
				table.insert(tbResult, tbTemp);
			end
		end
	end
	self.tbStatuary:AddHelpNews_Result(tbResult);
end

if MODULE_GC_SERVER and not Domain.nBattleState then
	Domain:InitDomain_GC();
end

-- 增加GS宕机保护
function Domain:SaveDeclareTable(tbDeclareDomainTong, tbTongDeclare)
	print("Declare table of DomainBattle Saved!");
	self.tbDeclareDomainTong = tbDeclareDomainTong;
	self.tbTongDeclare = tbTongDeclare;
end
	
function Domain:OnRecConnectEvent(nConnectId)
	print("GS "..nConnectId.." Reconnect GC!");
	if self.nBattleState == self.PRE_BATTLE_STATE then
		GlobalExcute({"Domain:ResumePreBattle",   
			Domain:UpdateDataVer(), 
			self.tbDeclareDomainTong,
			self.tbTongDeclare
		});
	elseif self.nBattleState == self.BATTLE_STATE then
		GlobalExcute({"Domain:ResumeBattle", 
			Domain:UpdateDataVer(), 
			self.tbDeclareDomainTong,
			self.tbTongDeclare,
			self.tbPlayer,
			self.tbDomainScore,
			self.tbReact
		});
	elseif self.nBattleState == self.STOP_STATE then
		GlobalExcute({"Domain:ResumeStopBattle"});
	end
end
GCEvent:RegisterGS2GCServerStartedFunc(Domain.OnRecConnectEvent, Domain);
