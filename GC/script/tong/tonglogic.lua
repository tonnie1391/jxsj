-------------------------------------------------------------------
--File: tonglogic.lua
--Author: lbh
--Date: 2007-9-6 11:24
--Describe: 基础帮会逻辑
-------------------------------------------------------------------
if not Tong then --调试需要
	Tong = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end


--定义临时变量，用于生成运行期的唯一流水ID号
if not Tong.nJourNum then
	Tong.nJourNum = 0;
end

--记录帮会脚本临时数据
if not Tong.aTongData then
	Tong.aTongData = {}
end

function Tong:GetExclusiveEvent(nTongId, nEventId)
	local tbTemp = (self:GetTongData(nTongId)).tbExclusiveEvent;
	if not tbTemp[nEventId] then
		tbTemp[nEventId] = {};
	end
	return tbTemp[nEventId];
end

function Tong:DelExclusiveEvent(nTongId, nEventId)
	local tbTemp = (self:GetTongData(nTongId)).tbExclusiveEvent;
	if not tbTemp[nEventId] then
		return 1;
	end
	tbTemp[nEventId].nApplyEvent = 0;	-- 申请事件标志清0
	tbTemp[nEventId].tbApplyRecord = nil 	-- 清空记录;（记录是如果执行的操作所需要的数据）
	tbTemp[nEventId].tbAccept	 = nil 	-- 清空表态表;
	tbTemp[nEventId].nCount 	 = 0;	-- 清记数器
end

function Tong:GetKickKinEvent(nTongId, nKinId)
	local tbTemp = (self:GetTongData(nTongId)).tbKickEvent;
	if not tbTemp[nKinId] then
		tbTemp[nKinId] = {};
	end
	return tbTemp[nKinId];
end

function Tong:DelKickKinEvent(nTong, nKinId)
	local tbTemp = (self:GetTongData(nTongId)).tbKickEvent;
	if not tbTemp[nEventId] then
		return 1;
	end
	tbTemp[nEventId].ApplyEvent	 = 0;	-- 申请事件标志清0
	tbTemp[nEventId].ApplyRecord = nil 	-- 清空记录;（记录是如果执行的操作所需要的数据）
	tbTemp[nEventId].tbAccept	 = nil 	-- 清空表态表;
	tbTemp[nEventId].nCount 	 = 0;	-- 清记数器
end

-- 获取帮会临时数据，因为不会返回空表，所以不能检测
function Tong:GetTongData(nTongId)
	local aTongData = self.aTongData[nTongId]
	if aTongData then
		return aTongData
	end
	aTongData = {}
	self.aTongData[nTongId] = aTongData
	
	-- 唯一申请事件(不可能同时有两个相同性质的申请)：发钱，发贡献，罢帮主，取钱
	aTongData.tbExclusiveEvent = {};
		
	
	if MODULE_GC_SERVER then
	else
		--邀请成员缓存
		aTongData.aInviteEvent = {}
		--帮会总威望价值量缓存
		aTongData.nTotalRepValue = 0
		--族长额外获得价值量缓存
		aTongData.nCaptainRepValue = 0
	end
	return aTongData
end

function Tong:DelTongData(nTongId)
	if self.aTongData[nTongId] then
		self.aTongData[nTongId] = nil
	end
end

--判断是否能创建帮会
function Tong:CanCreateTong(anKinId)
	--基础逻辑里只要有一个家族就可以建立帮会
	if not anKinId or #anKinId < 1 then
		return 0
	end
	--判断若有帮会已有帮会则不能创建
	for i, nKinId in ipairs(anKinId) do
		local cKin = KKin.GetKin(nKinId)
		if not cKin or cKin.GetBelongTong() ~= 0 then
			return 0
		end
	end
	return 1
end


--以列表的TongId创建帮会
function Tong:CreateTong(anKinId, szTongName, nCamp, nCreateTime)
	_DbgOut("Tong:CreateTong "..szTongName)
	-- 阵营是否合法范围
	if nCamp < 1 or nCamp > 3 then
		return nil
	end
	local cTong, nTongId = KTong.AddTong(szTongName)
	if not cTong then
		_DbgOut("Tong:CreateTong Add Failed")
		return nil
	end
	--不允许ID为0
	if nTongId == 0 then
		KTong.DelTong(nTongId)
		return nil
	end
	--KStatLog.ModifyField("Tong", szTongName, "帮会ID", tostring(nTongId));	
	local nTotalRepute = 0
-------------------------------------------------------------------------------------------------------------------------
-- 加上限判断
	local nTotalBuildFund = 0;
	for _, nId in ipairs(anKinId) do
		nTotalBuildFund = nTotalBuildFund + Kin:GetTotalKinStock(nId);
	end
	local nStockPercent = 1;

	if (nTotalBuildFund > self.MAX_BUILD_FUND) then
		nStockPercent = self.MAX_BUILD_FUND / nTotalBuildFund;
	end
-------------------------------------------------------------------------------------------------------------------------
	--将列表的Kin加入帮会中
	for i, nKinId in ipairs(anKinId) do
		nTotalRepute = nTotalRepute +  self:_AddKin2Tong(nTongId, cTong, nKinId, nCreateTime, i, nStockPercent)
	end
	cTong.SetTotalRepute(nTotalRepute + 100)
	-- cTong.SetBuildFund(self.CREATE_TONG_MONEY)
	cTong.SetCamp(nCamp)
	cTong.SetCreateTime(nCreateTime);
	--组队队长作为帮主
	cTong.SetMaster(anKinId[1])
	--进入考验期
	cTong.SetTestState(1)
	--设置帮会名字
	cTong.SetName(szTongName)
	--设置普通称号
	cTong.SetTitleMan("Thành viên_nam")
	cTong.SetTitleWoman("Thành viên_nữ")
	cTong.SetTitleRetire("Thành viên vinh dự")
	cTong.SetTitleExcellent("Tinh anh")
	--长老称号
	cTong.SetCaptainTitle(self.CAPTAIN_NORMAL, "Trưởng lão")
	cTong.SetCaptainTitle(self.CAPTAIN_MASTER, "Bang chủ")
	cTong.SetCaptainTitle(self.CAPTAIN_VICEMASTER, "Phó bang chủ")
	cTong.SetCaptainTitle(self.CAPTAIN_ASSISTANT2, "Trưởng lão chiến tranh")
	cTong.SetCaptainTitle(self.CAPTAIN_ASSISTANT3, "Trưởng lão chiến tranh")
	cTong.SetCaptainTitle(self.CAPTAIN_ASSISTANT4, "Trưởng lão nội chính")
	cTong.SetCaptainTitle(self.CAPTAIN_ASSISTANT5, "Trưởng lão ngoại giao")
	cTong.SetCaptainTitle(self.CAPTAIN_ASSISTANT6, "Trưởng lão nghi trượng")
	--设定帮主长老的权限（所有）
	cTong.AssignCaptainPower(self.CAPTAIN_MASTER, self.POWCB_ALL)
	cTong.AssignCaptainPower(self.CAPTAIN_VICEMASTER, self.POWCB_VICEMASTER)
	cTong.AssignCaptainPower(self.CAPTAIN_ASSISTANT2, self.POWCB_WAR)
	cTong.AssignCaptainPower(self.CAPTAIN_ASSISTANT3, self.POWCB_WAR)
	cTong.AssignCaptainPower(self.CAPTAIN_ASSISTANT4, self.POWCB_INTERIOR)
	cTong.AssignCaptainPower(self.CAPTAIN_ASSISTANT5, self.POWCB_DIPLOMAT)
	cTong.AssignCaptainPower(self.CAPTAIN_ASSISTANT6, self.POWCB_SECRETARY)
	for i = 1,8 do
		cTong.SetCaptainTitle(self.CAPTAIN_CUSTOM_BEGIN + i, "常务长老")
		cTong.AssignCaptainPower(self.CAPTAIN_CUSTOM_BEGIN + i, self.POWCB_CUSTOM)
	end
	-- 组成家族名
	local tbKinName = {};
	for i = 1, 6 do
		local szName = ""
		if anKinId[i] then
			local cKin = KKin.GetKin(anKinId[i]);
			if cKin then
				szName = cKin.GetName();
			end
		end
		tbKinName[i] = szName;
	end
	-- 帮主名
	local szMasterName = "";
	local cKin = KKin.GetKin(anKinId[1]);
	if cKin then
		local nCaptainId = cKin.GetCaptain();
		local cCaptain = cKin.GetMember(nCaptainId);
		if cCaptain then 
			szMasterName = KGCPlayer.GetPlayerName(cCaptain.GetPlayerId());
		end
	end
	cTong.AddHistoryEstablish(szTongName, szMasterName, unpack(tbKinName));
	_DbgOut("Tong:CreateTong succeed")
	return cTong, nTongId
end

function Tong:_AddKin2Tong(nTongId, cTong, nKinId, nCreateTime, i, nStockPercent)
	nStockPercent = nStockPercent or 1;
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	--返回该家族威望
	local nAddRepute = cKin.GetTotalRepute()
	if cTong.AddKin(nKinId, nCreateTime) ~= 1 then
		return 0;
	end
	cKin.SetBelongTong(nTongId)
	cKin.SetLastTong(nTongId)
	-- 族长威望处理
	local nCaptain = cKin.GetCaptain()
	local cKinMember = cKin.GetMember(nCaptain)
	if cKinMember then
		local nPlayerId = cKinMember.GetPlayerId();
		if i == 1 then
			cKin.SetTongFigure(self.CAPTAIN_MASTER);
			cKinMember.AddPersonalStock(self.CREATE_TONG_MONEY);		-- 建帮费用的所有资产都进帮主的口袋了
			if MODULE_GC_SERVER then
				KGCPlayer.SetPlayerPrestige(nPlayerId, KGCPlayer.GetPlayerPrestige(nPlayerId) + 100)
			end
		elseif i > 1 then
			cKin.SetTongFigure(self.CAPTAIN_NORMAL)
			if MODULE_GC_SERVER then
				KGCPlayer.SetPlayerPrestige(nPlayerId, KGCPlayer.GetPlayerPrestige(nPlayerId) + 20)
			end
		else		--非创建帮会时加入帮会，族长江湖威望不涨？
			cKin.SetTongFigure(self.CAPTAIN_NORMAL)
		end
	end
	Dbg:WriteLog("TongBuildFund", "kinadd_beg", nTongId, cTong.GetBuildFund(), cTong.GetTotalStock(), nKinId, Kin:GetTotalKinStock(nKinId));
	-- 处理成员股份数
	local nTotalFund = cTong.GetBuildFund();
	local nTotalStock = cTong.GetTotalStock();
	if (nTotalFund > self.MAX_BUILD_FUND) then
		nTotalFund = self.MAX_BUILD_FUND;
	end
	local nStockPrice = 0;
	if nTotalFund == 0 or nTotalStock == 0 then
		nStockPrice = self.DEFAULT_STOCKPRICE;
	else
		nStockPrice = nTotalFund / nTotalStock;		-- 股份价格
	end
	
-------------------------------------------------------------------------------------------------
	local nKinFund = Kin:GetTotalKinStock(nKinId);	-- 家族总的建设资金
	local nKinAddFund = 0;
	local nPercent = 1;
	if (nKinFund > 0) then
		nKinAddFund = math.floor(nKinFund * nStockPercent); -- 计算应该给帮会增加的建设资金
		if (nKinAddFund > self.MAX_BUILD_FUND - nTotalFund) then
			nKinAddFund = self.MAX_BUILD_FUND - nTotalFund;	-- 超过上限时，则截取
		end
		nPercent = nKinAddFund / nKinFund;	-- 个人建设资金的(百分比)获取帮会股份	
		-- log
		if nStockPercent and nStockPercent ~= 1 then
			local szLog = string.format("家族[%s]在创建过程中家族成员所持有的帮会股份是正常情况下的[%d]百分比,(帮会建设资金上限问题)",
				cKin.GetName(), math.floor(nStockPercent * 100));
			Dbg:WriteLog("Tong", szLog);
		end
	end
-------------------------------------------------------------------------------------------------
	if nStockPrice < 1 then
		nStockPrice = 1;	-- 股价比1低的时候按1的股价加入帮会，防止溢出，此时该家族会亏
	end
	local pMemberItor = cKin.GetMemberItor()
	local pMember = pMemberItor.GetCurMember();

	while pMember do
		local nPersonalStock = pMember.GetPersonalStock();				-- 成员资产,没帮会的成员股份价格恒定为1JXB
		local nNewStock = math.floor(nPercent * self.JOIN_TONG_STOCK * nPersonalStock / nStockPrice);		-- 成员新股份数
		if nTotalStock + nNewStock > self.MAX_TONG_FUND then  -- 股权数量不能超过建设资金的最大值即股价为1时最大的股权数，防止溢出
			nNewStock = self.MAX_TONG_FUND - nTotalStock;
			nTotalStock = self.MAX_TONG_FUND;
		else
			nTotalStock = nTotalStock + nNewStock;
		end
		if nNewStock < 0 then	-- 已有的资金溢出的帮会可能会导致该值小于0
			nNewStock = 0;
		end
		pMember.SetPersonalStock(nNewStock);
		-- log
		if nPercent and nPercent ~= 1 then
			local szLog = string.format("家族[%s]玩家[%s]加入帮会个人股份获取量是正常情况下的[%d]百分比,以前股份为[%d],(帮会建设资金上限问题)",
				cKin.GetName(), KGCPlayer.GetPlayerName(pMember.GetPlayerId()), math.floor(nPercent * 100), nPersonalStock);
			Dbg:WriteLog("Tong", szLog);
		end
		
		pMember = pMemberItor.NextMember();
	end
	cTong.AddBuildFund(nKinAddFund);		-- 增加资金
	cTong.SetTotalStock(nTotalStock);	-- 增加股份
	Dbg:WriteLog("TongBuildFund", "kinadd_end", nTongId, cTong.GetBuildFund(), cTong.GetTotalStock(), nKinId, Kin:GetTotalKinStock(nKinId));
	return nAddRepute, nKinAddFund;
end

--行动力刷新
function Tong:RefleshTongEnergy(nTongId)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0
	end
	local nRepute = cTong.GetTotalRepute()
	local nEnergy = 800 + math.ceil(nRepute / 4000) * 100
	nEnergy = math.min(nEnergy, self.MAX_ENERGY);
	return KTong.ApplySetTongTask(nTongId, self.aTongTaskDesc2Id["Energy"], nEnergy)
end

--精英层决定
function Tong:ExcellentConfirm(nTongId)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0
	end
	local cKinItor = cTong.GetKinItor()
	local nKinId = cKinItor.GetCurKinId()
	local tbKinMember = {}
	while nKinId ~= 0 do
		local cKin = KKin.GetKin(nKinId)
		if cKin then
			local cKinMemberItor = cKin.GetMemberItor()
			local cMember = cKinMemberItor.GetCurMember()
			while cMember do
				--先去掉原先精英职位
				cMember.SetBitExcellent(0)
				table.insert(tbKinMember, cMember)
				cMember = cKinMemberItor.NextMember()
			end
		end
		nKinId = cKinItor.NextKinId()
	end
	--从大到小排列
	--table.sort(tbKinMember, function(c1, c2) return c1.GetRepute() > c2.GetRepute() end)
	table.sort(tbKinMember, function(c1, c2) 
			local nC1PlayerId, nC2PlayerId = c1.GetPlayerId(), c2.GetPlayerId();
			return KGCPlayer.GetPlayerPrestige(nC1PlayerId) > KGCPlayer.GetPlayerPrestige(nC2PlayerId);
		end)
		
	local nSize = #tbKinMember
	--取30%的人为精英
	if nSize < 4 then
		nSize = 1
	else
		nSize = math.floor(nSize * 0.3)
	end
	for i = 1, nSize do
		tbKinMember[i].SetBitExcellent(1)
	end
	return 1
end

-- 是不是拥有该职位
function Tong:HaveFigure(nTongId, nKinId, nMemberId, nPow)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	local nRetCode, _, cMember = Kin:HaveFigure(nKinId, nMemberId, 1);
	if nRetCode ~= 1 then -- 检查是不是长老
		return 2;
	end
	if (nPow == 0) then -- 没要求权限，则表示凡是长老都有权
		return 1, cMember;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 3;
	end
	local nFigure = cKin.GetTongFigure();
	if cTong.GetCaptainPower(nFigure, nPow) == 0 then 
		return 0;
	end
	return 1, cMember;
end
	
-- 检查权力，返回1才表示有权，返回其他表示无权的原因标志（暂时没用到）
-- 只有返回1时才同时返回Member对象
function Tong:CheckSelfRight(nTongId, nKinId, nMemberId, nPow)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	
	local nFigure = cKin.GetTongFigure();
	local nRetCode, _, cMember = Kin:CheckSelfRight(nKinId, nMemberId, 1);

	if nRetCode ~= 1 then -- 检查长老是否有效（是否为长老或者有否被冻结）
		return 2;
	end
	if (nPow == 0) then -- 没要求权限，则表示凡是长老都有权
		return 1, cMember;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 3;
	end
	if cTong.GetCaptainPower(nFigure, nPow) == 0 then 
		return 0;
	end
	
	if MODULE_GAMESERVER then
		local nPlayerId = cMember.GetPlayerId();
		if nPlayerId == self:GetMasterId(nTongId) and cTong.GetMasterLockState() == 1 then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
			if pPlayer then
				pPlayer.Msg("Bạn đã bị cách chức, không còn quyền bang chủ!");	
			end
			return 0;
		end
	end
	return 1, cMember;
end

function Tong:ParseHistory(tbRecord)
	if not Tong.HistoryFormat then
		return "";
	end
	if not tbRecord or not Tong.HistoryFormat[tbRecord.nType] then
		return "";
	end
	local tbParse = Tong.HistoryFormat[tbRecord.nType];
	if tbParse.nContentNum > #tbRecord.tbContent then
		return "";
	end 
	
	return tbRecord.nTime, string.format(tbParse.szFormat, unpack(tbRecord.tbContent));
end


-- 获取主城区域战编号
function Tong:GetDomainBattleNo(nTongId)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end
	return cTong.GetDomainBattleNo();	
end

-- 获得主城的区域编号(DomainId)
function Tong:GetCapital(nTongId)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end
	
	return cTong.GetCapital();
end

-- 计算迁都费用
function Tong:CalcChangeCapital(nTongId)
	local cTong = KTong.GetTong(nTongId);
	if cTong == nil then
		return;
	end
	local nChanges = cTong.GetCapitalChangeCount();

	if cTong.GetCapital() == 0 or nChanges == 0 then
		return 1000000, 0; -- 没有主城
	end

	if nChanges > 0 and nChanges < 3 then
		return (nChanges + 1) * 1000000, nChanges;
	else
		return 5000000, nChanges;
	end
end


-- 清除帮会所有股份
function Tong:ClearAllStock(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	pTong.SetTotalStock(0);					-- 清除帮会股份数
	local pKinItor = pTong.GetKinItor();
	local nKinId = pKinItor.GetCurKinId();
	while (nKinId > 0) do
		Kin:ClearAllStock(nKinId);			-- 清除家族股份数
		nKinId = pKinItor.NextKinId();
	end
end

-- 董事层决定
function Tong:PresidentConfirm(nTongId, tbResult, bSetPosition)		-- tbResult默认nil
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return;
	end
	local tbSort =
	{
		__lt = function(tbA, tbB)
			return tbA.nKey > tbB.nKey;
		end
	};
	local pItor = pTong.GetKinItor()
	local nKinId = pItor.GetCurKinId()
	local pKin = KKin.GetKin(nKinId);
	local nCandidateKin = 0;
	local nCandidateMember = 0;
	local tbRet = {};
	while (pKin) do
		local pMemberItor = pKin.GetMemberItor();
		local pMember = pMemberItor.GetCurMember();
		while pMember do
			if not tbResult then		-- 没传结果进来则计算
				local tbTemp = {}
				tbTemp.nKey = pMember.GetPersonalStock();
				tbTemp.nKinId = nKinId;
				tbTemp.nMemberId = pMemberItor.GetCurMemberId()
				setmetatable(tbTemp, tbSort);
				table.insert(tbRet, tbTemp);
				if pMember.GetStockFigure() == self.PRESIDENT_CANDIDATE then
					nCandidateKin = nKinId;
					nCandidateMember = tbTemp.nMemberId;
				end
			end
			if bSetPosition ~= 0 then
				pMember.SetStockFigure(self.NONE_STOCK_RIGHT)		-- 清空原有职位
			end
			pMember = pMemberItor.NextMember()
		end
		nKinId = pItor.NextKinId();
		pKin = KKin.GetKin(nKinId);
	end
	local nPresidenKin = 0; 
	local nPresidenMember = 0; 
	if not tbResult then
		table.sort(tbRet);
		tbResult = tbRet;
		if not tbResult[1] then
			Dbg:WriteLog("Official", "Tong is Empty!!!!!!", pTong.GetName())
			return;
		end
		if bSetPosition ~= 0 then
			-- 没有候选人或者候选人不是当前第一名，首领维持不变
			if (tbResult[1].nKinId ~= nCandidateKin or tbResult[1].nMemberId ~= nCandidateMember or 
				tbResult[1].nKinId == 0 or tbResult[1].nMemberId == 0) and self:CheckPresidentInTong(nTongId) == 1 then
					nPresidenKin = pTong.GetPresidentKin();
					nPresidenMember = pTong.GetPresidentMember()
					tbResult = Lib:MergeTable({{nKinId = nPresidenKin, nMemberId = nPresidenMember}}, tbResult)
			end
		end
	end
	tbRet = {};		-- 清空，只记录前10位排名
	
	local nCount = 1;
	-- self.DIRECTORATE_MEMBERS + 1 原因是可能首领成员在非第一位的地方出现第2次
	for i = 1, math.min(self.DIRECTORATE_MEMBERS + 1, #tbResult) do
		local pKin = KKin.GetKin(tbResult[i].nKinId);
		local bRecord = 0;
		if pKin then
			local pMember = pKin.GetMember(tbResult[i].nMemberId);
			if i == 1 then 	-- 第一个是首领
				if bSetPosition ~= 0 then
					pMember.SetStockFigure(self.PRESIDENT)
					pTong.SetPresidentKin(tbResult[i].nKinId);
					pTong.SetPresidentMember(tbResult[i].nMemberId);
					-- Add TongLog 成为首领
					local szLogMsg = string.format("[%s] 成为首领",  KGCPlayer.GetPlayerName(pMember.GetPlayerId()));
					 _G.TongLog(pTong.GetName(), Log.emKTONG_LOG_TONGSTRUCTURE, szLogMsg);
				end
				bRecord = 1
			elseif (nPresidenKin ~= tbResult[i].nKinId or nPresidenMember ~= tbResult[i].nMemberId) and 
				 (nCount < self.DIRECTORATE_MEMBERS) then	 -- 其他是股东会成员
				if bSetPosition ~= 0 then
					pMember.SetStockFigure(self.DIRECTORATE)
				end
				nCount = nCount + 1;
				bRecord = 1;
			end
		end
		if bRecord == 1 then
			tbRet[nCount] = tbResult[i];
			tbRet[nCount].nKey = nil;
		end
	end
	return tbRet;
end

function Tong:GetTotalMemberCount(pTong)
	local pKinItor = pTong.GetKinItor()
	local nKinId = pKinItor.GetCurKinId()
	local pKin = KKin.GetKin(nKinId);
	local nCount = 0;
	while pKin do
		nCount = nCount + pKin.nMemberCount;
		nKinId = pKinItor.NextKinId();
		pKin = KKin.GetKin(nKinId);
	end
	return nCount;
end

function Tong:CheckPresidentRight(nTongId, nKinId, nMemberId)
	if self:IsPresident(nTongId, nKinId, nMemberId) == 0 then
		return 0
	end
	local pKin = KKin.GetKin(nKinId)
	if not pKin then
		return 0
	end
	local pMember = pKin.GetMember(nMemberId)
	if not pMember then
		return 0;
	end
	
	if MODULE_GAMESERVER then
		local pPlayer = KPlayer.GetPlayerObjById(pMember.GetPlayerId());
		-- 未解锁
		if pPlayer and pPlayer.IsAccountLock() ~= 0 then
			pPlayer.Msg("Bạn chưa mở khóa, quyền thủ lĩnh bị khóa!");				
			return 0;
		end
	end
	return 1;
end

-- 服务器端判断玩家是不是首领
function Tong:IsPresident(nTongId, nKinId, nMemberId)
	if not nTongId then
		return 0;
	end
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	if nKinId == pTong.GetPresidentKin() and nMemberId == pTong.GetPresidentMember() then
		return 1;
	else
		return 0;
	end;
end


-- 服务器端判断玩家是不是能不能被任命帮会官衔
function Tong:CanAppointOfficial(nTongId, nKinId, nMemberId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	if pMember.GetStockFigure() == Tong.DIRECTORATE or 
	   pMember.GetStockFigure() == Tong.PRESIDENT_CANDIDATE or
	   pMember.GetStockFigure() == Tong.PRESIDENT then
		return 1;
	end
	return 0;
end


-- 检查首领是否在帮会
function Tong:CheckPresidentInTong(nTongId)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0;
	end
	local nKinId = pTong.GetPresidentKin();
	local nMemberId = pTong.GetPresidentMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin or pKin.GetBelongTong() ~= nTongId then
		return 0;
	elseif pKin then
		local pMember = pKin.GetMember(nMemberId);
		if not pMember then
			return 0;
		end
	end
	return 1;
end

function Tong:GetPresidentMemberName(nTongId)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return "Chưa biết";
	end
	local nKinId = pTong.GetPresidentKin();
	local nMemberId = pTong.GetPresidentMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin or pKin.GetBelongTong() ~= nTongId then
		return "Chưa biết";
	elseif pKin then
		local pMember = pKin.GetMember(nMemberId);
		if not pMember then
			return "Chưa biết";
		end
		return KGCPlayer.GetPlayerName(pMember.GetPlayerId());
	end
	return "Chưa biết";
end
-- 计算已经本周累积使用的建设资金总数
function Tong:CanCostedBuildFund(nTongId, nKinId, nMemberId, nMoney, nCheckPow)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	
	-- 检测使用权限,默认nil为检测,设置0为不检测
	if nCheckPow ~= 0 then 
		-- 判断权限
		if Tong:CheckSelfRight(nTongId, nKinId, nMemberId, Tong.POW_FUN) ~= 1 and 
		   Tong:CheckPresidentRight(nTongId, nKinId, nMemberId) ~= 1 then
				return 0;
		end
	end
	
	-- 如果不是本周的累积，则重新累积
	local nWeekNow = tonumber(os.date("%W", GetTime()));
	local nCostedBuildFund = 0; 
	local nBuildFundLimit = pTong.GetBuildFundLimit();
	if nWeekNow ~= pTong.GetCostedBFundWeek() then
		pTong.SetCostedBuildFund(0);
		nCostedBuildFund = nMoney;
		pTong.SetCostedBFundWeek(nWeekNow);
	else
		nCostedBuildFund =  pTong.GetCostedBuildFund();
		nCostedBuildFund = nCostedBuildFund + nMoney;
	end
	
	-- 判断有没超过使用建设资金上限	
	if nBuildFundLimit < nCostedBuildFund or pTong.GetBuildFund() - nMoney < self.MIN_CAN_COST  then
		return 0;	
	end

	return 1;
end

-- 获得首领的PlayerId
function Tong:GetPresidentId(nTongId)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0
	end
	local nPresidentKinId = pTong.GetPresidentKin()
	
	local pKin = KKin.GetKin(nPresidentKinId)
	if not pKin then
		return 0
	end
	
	local pMember = pKin.GetMember(pTong.GetPresidentMember())
	if not pMember then
		return 0
	end
	
	return pMember.GetPlayerId();
end

-- 获得帮主的PlayerId
function Tong:GetMasterId(nTongId)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0
	end
	local nMasterKinId = pTong.GetMaster()
	
	local pKin = KKin.GetKin(nMasterKinId)
	if not pKin then
		return 0
	end
	
	local pMember = pKin.GetMember(pKin.GetCaptain())
	if not pMember then
		return 0
	end
	
	return pMember.GetPlayerId();
end

-- 判断帮主竞选是否到限定时间
function Tong:MasterVoteDeadLine(nTongId)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0;
	end
	
	if pTong.GetVoteStartTime() == 0 then
		return 1;
	end
	
	local nNowTime = GetTime();
	local nVoteEndTime = pTong.GetVoteStartTime() + 48 * 3600;
	
	if nNowTime > nVoteEndTime then
		return 1;
	end
	return 0;
end

function Tong:GetStockFigure(nKinId, nMemberId)
	local pKin = KKin.GetKin(nKinId);
	if not pKin or pKin.GetBelongTong() == 0 then
		return;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return;
	end
	return pMember.GetStockFigure();
end

-- 在帮会官衔表中搜有自己的帮会官衔职位
function Tong:GetOfficialRank(nTongId, nKinId, nMemberId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong or not nKinId or not nMemberId then
		return 0;
	end
	local nTongOfficialLevel = pTong.GetPreOfficialLevel();
	local nOfficialRank = 0;
	for i = 1, self.MAX_TONG_OFFICIAL_NUM do
		local nOfficialKinId = pTong.GetOfficialKin(i);
		local nOfficialMemberId = pTong.GetOfficialMember(i);
		if nOfficialKinId and nOfficialMemberId and nKinId == nOfficialKinId and nMemberId == nOfficialMemberId then	
			nOfficialRank = i;
			break;
		end
	end
	
	return nOfficialRank;
end


-- 该帮会领土数量对应的最大帮会官衔水平
function Tong:GetMaxLevelByDomain(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local nDomainNum = pTong.GetDomainCount();		-- 该帮会占领的领土数量
	
	if not nDomainNum or nDomainNum == 0 then
		return 0;
	end
	
	-- 如果领土是新手村
	if nDomainNum == 1 then
		local pDomainItor = pTong.GetDomainItor();
		local nDomainId = pDomainItor.GetCurDomainId();
		if Domain:GetDomainType(nDomainId) == "village" then
			return 0;
		end
	end
	local nMaxTongLevel = 0;
	for i = 1, #Tong.OFFICIAL_LEVEL_CONDITION do
		if nDomainNum >= Tong.OFFICIAL_LEVEL_CONDITION[i] then
			nMaxTongLevel = nMaxTongLevel + 1;
		else
			break;
		end
	end
	return nMaxTongLevel;
end	

-- 获得个人官衔等级
function Tong:GetPlayerOfficialLevel(nPlayerId)
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_OFFICIAL_MAINTAIN_NO);
	local nOfficiallNo = KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_MAINTAIN_OFFICIAL_NO);  --维护流水号
	local nOfficialLevel = KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_OFFICIAL_LEVEL) or 0;
	
	if nCurNo == nOfficiallNo then
		return nOfficialLevel;
	else
		--- 合服处理
		local nGbCoZoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);
		local nZoneDay = Lib:GetLocalDay(nGbCoZoneTime);
		local nNowDay = Lib:GetLocalDay(GetTime());
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		-- 合服七天内
		if (pPlayer and pPlayer.IsSubPlayer() == 1 and nNowDay - nZoneDay <= 7) then
			local nSubOfficialNo = KGblTask.SCGetDbTaskInt(DBTASK_OFFICIAL_MAINTAIN_NO_SUB);
			if (nSubOfficialNo == nOfficiallNo) then
				return nOfficialLevel;
			end
		end
		return  0;
	end
end


-- 获得个人官衔Detail
function Tong:GetPlayerOfficialDetail(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nOfficialDetail = Tong.OFFICIAL_TITLE_DETAIL;
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if Tong:IsPresident(pPlayer.dwTongId, nKinId, nMemberId) == 1 then
		local nCapitalId = Tong:GetCapital(pPlayer.dwTongId);
		nOfficialDetail = Domain.tbTitleDetail[nCapitalId] or Tong.OFFICIAL_TITLE_DETAIL;
	end
	return nOfficialDetail;
end

-- 计算要消耗的个人股份数量
function Tong:CalculateStockCost(nTongId, nKinId, nMemberId, nCost)
	local pTong = KTong.GetTong(nTongId);
	if not pTong or not nCost then
		return;
	end
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return;
	end
	if not pTong.GetTotalStock() or pTong.GetTotalStock() == 0 or not pTong.GetBuildFund() then
		return;
	end

	local nStockPrice = pTong.GetBuildFund() / pTong.GetTotalStock();
	local nPersonalStock = pMember.GetPersonalStock();
	local nFund = nPersonalStock * nStockPrice;
	if nFund < nCost or nFund == 0 then 
		return;
	end

	local nStockAmount = math.ceil(nCost / nStockPrice);
	return nStockAmount;
end

-- 统计帮会总股份数
function Tong:CaculateTotalStock(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return;
	end
	local pKinItor = pTong.GetKinItor();
	local nKinId = pKinItor.GetCurKinId();
	local pKin = KKin.GetKin(nKinId);
	local nTotalStock = 0;
	while pKin do
		local pMemberItor = pKin.GetMemberItor();
		local pMember = pMemberItor.GetCurMember();
		while pMember do
			nTotalStock = nTotalStock + pMember.GetPersonalStock();
			pMember = pMemberItor.NextMember();
		end
		nKinId = pKinItor.NextKinId();
		pKin = KKin.GetKin(nKinId);
	end
	return nTotalStock;
end


-- 首领个人官衔名称对应表
Tong.OFFICIAL_TITLE = {}
-- 非首领个人官衔名称对应表
Tong.OFFICIAL_TITLE_NP = {}
-- 个人官衔维护费用
Tong.OFFICIAL_CHARGE = {}


-- 加载配置
function Tong:LoadOfficialInfo()
	local OFFICIAL_FILE = "\\setting\\domainbattle\\official.txt";
	local tbFile = Lib:LoadTabFile(OFFICIAL_FILE);
	if tbFile then
		local nLevel = 1;
		for _, tbRowData in pairs(tbFile) do
			nLevel = tonumber(tbRowData.Level);
			Tong.OFFICIAL_TITLE[nLevel] = tbRowData.Title;
			Tong.OFFICIAL_TITLE_NP[nLevel] = tbRowData.TitleNP;
			Tong.OFFICIAL_CHARGE[nLevel] = tbRowData.Charge;
		end
	end
end
Tong:LoadOfficialInfo();

-- 检测投票资格
function Tong:CanElectGreatMember(nTongId, nSelfKinId, nSelfMemberId, nTagetKinId, nTagetMemberId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0, 1;
	end	
	local pSelfKin = KKin.GetKin(nSelfKinId);
	local pTagetKin = KKin.GetKin(nTagetKinId);
	if not pSelfKin or not pTagetKin then
		return 0, 1;
	end	
	local pSelfMember = pSelfKin.GetMember(nSelfMemberId);
	local pTagetMember = pTagetKin.GetMember(nTagetMemberId);
	if not pSelfMember or not pTagetMember then 
		return 0, 1;
	end
		
	local pTong = KTong.GetTong(nTongId);
	if pTong.GetGreatMemberVoteState() == 0 then
		return 0, 2;
	end
	
	if Tong:IsPresident(nTongId, nTagetKinId, nTagetMemberId) == 1 then
		return 0, 3;
	end

	local nSelfFigure = pSelfMember.GetFigure();
	if nSelfFigure == Kin.FIGURE_SIGNED then 
		return 0, 4;
	end
	
	local nTagetFigure = pTagetMember.GetFigure();
	if nTagetFigure == Kin.FIGURE_SIGNED then 
		return 0, 6;
	end

	local nGreatMemberNo = KGblTask.SCGetDbTaskInt(DBTASK_GREAT_MEMBER_VOTE_NO);
	if pSelfMember.GetMemberVoteNo() == nGreatMemberNo then 
		return 0, 5;
	end
	return 1, 0;
end

-- 清空优秀成员列表
function Tong:ClearGreatMemberVote(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	for i = 1, self.GREAT_MEMBER_COUNT do
		pTong.SetGreatMemberId(i, 0);
		pTong.SetGreatKinId(i, 0);
	end	
	
	local pItor = pTong.GetKinItor();
	local nKinId = pItor.GetCurKinId();
	local pKin = KKin.GetKin(nKinId);
	-- 按成员的评优票数排序
	while (pKin) do
		local pMemberItor = pKin.GetMemberItor();
		local pMember = pMemberItor.GetCurMember();
		while pMember do
			pMember.SetGreatMemberVote(0);
			pMember = pMemberItor.NextMember();
		end
		nKinId = pItor.NextKinId();
		pKin = KKin.GetKin(nKinId);
	end	
	return 1;
end

-- 返回帮会的领土状态 -1:帮会不存在 1:可征战战任意有归属的领土
function Tong:GetTongDomainState(nTongId)
	local pTong = KTong.GetTong(nTongId);
	local nDomainCount = pTong.GetDomainCount();
	if not pTong or nDomainCount < 0 then
		return -1;
	end
	local nState = 0;
	local pItor = pTong.GetDomainItor();
	local nIdTmp = pItor.GetCurDomainId();
	if nDomainCount == 1 and Domain:GetDomainType(nIdTmp) == "village" then
		nState = 1;
	end
	return nState;
end
