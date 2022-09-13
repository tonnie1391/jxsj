-------------------------------------------------------------------
--File: kinlogic.lua
--Author: lbh
--Date: 2007-6-26 14:57
--Describe: 基础家族逻辑
-------------------------------------------------------------------
if not Kin then --调试需要
	Kin = {}
	print(GetLocalDate("%Y/%m/%d/%H/%M/%S").." build ok ..")
end

--定义临时变量，用于生成运行期的唯一流水ID号
if not Kin.nJourNum then
	Kin.nJourNum = 0
end

--记录家族脚本临时数据
if not Kin.aKinData then
	Kin.aKinData = {}
end

function Kin:GetKinData(nKinId)
	local aKinData = self.aKinData[nKinId]
	if aKinData then
		return aKinData
	end
	aKinData = {}
	self.aKinData[nKinId] = aKinData
	
	-- 唯一申请事件(不可能同时有两个相同性质的申请)：取钱
	aKinData.tbExclusiveEvent = {};
	
	--记录推荐入帮事件
	aKinData.aIntroduceEvent = {}	
	aKinData.aIntroduceCancel = {}
	--记录踢人响应事件
	aKinData.aKickEvent = {}
	if MODULE_GC_SERVER then
	else
		--邀请成员缓存
		aKinData.aInviteEvent = {}
		--家族总威望价值量缓存
		aKinData.nTotalRepValue = 0
		--族长额外获得价值量缓存
		aKinData.nCaptainRepValue = 0
	end
	return aKinData
end

function Kin:DelKinData(nKinId)
	if self.aKinData[nKinId] then
		self.aKinData[nKinId] = nil
	end
end

--判断执行者的权限
--nFigureLevel：哪个级别以上才能操作
function Kin:CheckSelfRight(nKinId, nExcutorId, nFigureLevel)
	if nKinId == 0 or nExcutorId == 0 then
		return 0
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	--执行者为-1默认系统执行
	if nExcutorId == -1 then
		return 1, cKin;
	end
	local cMemberExcutor = cKin.GetMember(nExcutorId)
	if not cMemberExcutor then
		return 0, cKin;
	end
	
	-- 是否拥有该职位的权限
	if self:HaveFigure(nKinId, nExcutorId, nFigureLevel) == 0 then
		return 0;
	end
	
	--族长冻结状态
	if nFigureLevel <= 2 and cMemberExcutor.GetFigure() == 1 and cKin.GetCaptainLockState() == 1 then
		if MODULE_GAMESERVER then
			local pPlayer = KPlayer.GetPlayerObjById(cMemberExcutor.GetPlayerId());
			if pPlayer then
				pPlayer.Msg("Đã bãi nhiệm chức vụ, quyền Tộc trưởng không còn!");
			end
		end
		return 0, cKin, cMemberExcutor;
	end
	
	-- 未解锁
	if nFigureLevel <= 2 then
		if MODULE_GAMESERVER then
			local pPlayer = KPlayer.GetPlayerObjById(cMemberExcutor.GetPlayerId());
			if pPlayer and pPlayer.IsAccountLock() ~= 0 then
				pPlayer.Msg("Chưa mở khóa, không thể sử dụng quyền Tộc trưởng!");
				return 0, cKin, cMemberExcutor;
			end
		end
	end
	
	return 1, cKin, cMemberExcutor;
end

-- 是不是拥有该职位
function Kin:HaveFigure(nKinId, nExcutorId, nFigureLevel)
	if nKinId == 0 or nExcutorId == 0 then
		return 0
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	--执行者为-1默认系统执行
	if nExcutorId == -1 then
		return 1, cKin;
	end
	local cMemberExcutor = cKin.GetMember(nExcutorId)
	if not cMemberExcutor then
		return 0, cKin;
	end
	if cMemberExcutor.GetFigure() > nFigureLevel then
		return 0, cKin, cMemberExcutor;
	end
	return 1, cKin, cMemberExcutor;
end

--判断是否能创建家族
function Kin:CanCreateKin(anPlayerId)
	--基础逻辑里只要有一个人就可以建立家族，真实人数限制在上层逻辑判定
	if not anPlayerId or #anPlayerId < 1 then
		return 0
	end
	--判断若有成员已有家族则不能创建
	for i, nPlayerId in ipairs(anPlayerId) do
		local nKin, nMember = KKin.GetPlayerKinMember(nPlayerId)
		if nKin ~= 0 or nMember ~= 0 then
			return 0
		end
	end
	return 1
end

--以列表的PlayerId创建家族
function Kin:CreateKin(anPlayerId, anStoredRepute, szKinName, nCamp, nCreateTime, tbStock)
	-- 阵营是否合法范围
	if nCamp < 1 or nCamp > 3 then
		return nil
	end
	local cKin, nKinId = KKin.AddKin(szKinName)
	if not cKin then
		return nil
	end
	if not tbStock then
		return 0;
	end
	--不允许ID为0
	if nKinId == 0 then
		KKin.DelKin(nKinId)
		return nil
	end
	--KStatLog.ModifyField("Kin", szKinName, "家族ID", tostring(nKinId));
	local nMemberId = 0
	--将列表的Player加入家族中
	for i, nPlayerId in ipairs(anPlayerId) do
		nMemberId = nMemberId + 1
		local cMember = cKin.AddMember(nMemberId)
		if not cMember then
			return nil
		end
		if MODULE_GC_SERVER then
			KKin.SetPlayerKinMember(nPlayerId, nKinId, nMemberId)
			local szMsg = string.format("%s tham gia Gia tộc", KGCPlayer.GetPlayerName(nPlayerId));
			_G.KinLog(szKinName,  Log.emKKIN_LOG_TYPE_KINSTRUCTURE, szMsg);
		end
		cMember.SetPlayerId(nPlayerId)
		cMember.SetJoinTime(nCreateTime)
		--cMember.SetRepute(anStoredRepute[i])	--加本身缓存的江湖威望
		if MODULE_GC_SERVER then
			tbStock[i] = KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_TONGSTOCK);
		end
		cMember.SetPersonalStock(tbStock[i]);
		if i == 1 then
			cMember.SetFigure(self.FIGURE_CAPTAIN)
			if MODULE_GC_SERVER then
				KGCPlayer.SetPlayerPrestige(nPlayerId, KGCPlayer.GetPlayerPrestige(nPlayerId) + 20);
			end
			if (MODULE_GAMESERVER) then
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if (pPlayer) then
					-- 成就，创建家族并成为族长
					Achievement:FinishAchievement(pPlayer, 33);
				end
			end
		else
			cMember.SetFigure(self.FIGURE_REGULAR)
			if MODULE_GC_SERVER then
					KGCPlayer.SetPlayerPrestige(nPlayerId, KGCPlayer.GetPlayerPrestige(nPlayerId) + 5);
			end
		end
	end
	cKin.SetCamp(nCamp)
	cKin.SetCreateTime(nCreateTime)
	cKin.SetLastLoginTime(nCreateTime); 
	--设置家族名字
	cKin.SetName(szKinName)
	--设置称号
	cKin.SetTitleCaptain("Tộc trưởng")
	cKin.SetTitleAssistant("Tộc phó")
	cKin.SetTitleMan("Thành viên Nam")
	cKin.SetTitleWoman("Thành viên Nữ")
	cKin.SetTitleRetire("Thành viên Danh Dự")
	--组队队长作为族长
	cKin.SetCaptain(1)
	--设置ID生成器
	cKin.SetMemberIdGentor(nMemberId)
	local tbHistory = {};
	for i=1,6 do	-- 5个成员，不足记录空串
		local szMsg = ""
		if anPlayerId[i] then
			szMsg = KGCPlayer.GetPlayerName(anPlayerId[i]);
			if not szMsg then
				szMsg = "";
			end
		end
		tbHistory[i] = szMsg;
	end
	cKin.AddHistoryEstablish(szKinName, unpack(tbHistory));
	_DbgOut("Kin:CreateKin succeed")
	return cKin, nKinId
end

function Kin:CheckMemberCanAdd(nKinId, nPlayerId)
	--已有家族
	local nPreKin, nPreMember = KKin.GetPlayerKinMember(nPlayerId);
	if nPreKin ~= 0 then
		local cPreKin = KKin.GetKin(nPreKin);
		if (cPreKin) then
			local cPreMember = cPreKin.GetMember(nPreMember);
			if cPreMember and cPreMember.GetPlayerId() == nPlayerId then
				return 0			
			end
		end
		-- 数据有问题，清除
		KKin.DelPlayerKinMember(nPlayerId);
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local nRegular, nSigned, nRetire = cKin.GetMemberCount()
	local nMemberLimit, nRetireLimit = self:GetKinMemberLimit(nKinId);
	if (nRegular + nSigned + nRetire) >= (nMemberLimit + nRetireLimit) then
		return 0;
	end
	if nRegular + nSigned >= nMemberLimit then
		return 0
	end
	return 1
end

function Kin:CheckQuitTong(cKin)
	if not cKin then
		return 0;
	end
	local nMemberCount = cKin.nMemberCount;
	local nQuitDisagrre;		
	if nMemberCount > 0 then
		nQuitDisagrre = math.floor(nMemberCount / 3);	-- 反对退出帮会的人数需要达到的总人数1/3
		if nQuitDisagrre < 1 then		--  防止家族人数少于3永不能成功退帮
			nQuitDisagrre = 1;
		end
		local cMemberItor = cKin.GetMemberItor()
		local cCurMember = cMemberItor.GetCurMember()
		while cCurMember do
			if cCurMember.GetQuitVoteState() == 2 then	--投反对票的成员
				nQuitDisagrre = nQuitDisagrre - 1;
			end
			cCurMember = cMemberItor.NextMember();
		end
	end
	if nQuitDisagrre < 1 then		-- 反对人数超过总人数的1/3
		return 0;
	end
	return 1;
end

function Kin:ParseHistory(tbRecord)
	if not Kin.HistoryFormat then
		return "";
	end
	if not tbRecord or not Kin.HistoryFormat[tbRecord.nType] then
		return "";
	end
	local tbParse = Kin.HistoryFormat[tbRecord.nType];
	if tbParse.nContentNum > #tbRecord.tbContent then
		return "";
	end
	return string.format("%s："..tbParse.szFormat, os.date("%Y年%m月%d日", tbRecord.nTime), unpack(tbRecord.tbContent));
end


function Kin:ClearAllStock(nKinId)
	local pKin = KKin.GetKin(nKinId)
	if not pKin then
		return 0;
	end
	local pMemberItor = pKin.GetMemberItor()
	local pMember = pMemberItor.GetCurMember();
	while pMember do
		pMember.SetPersonalStock(0);		-- 清除个人股份数
		pMember = pMemberItor.NextMember()
	end
end

-- 通过MemberId获得玩家的PlayerId
function Kin:GetPlayerIdByMemberId(nKinId, nMemberId)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then 
		return 0;
	end
	
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then 
		return 0;
	end
	
	return pMember.GetPlayerId();
end

-- 获取家族的帮会总共的帮会建设资金
function Kin:GetTotalKinStock(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	
	local nKinFund = 0;
	local pMemberItor = cKin.GetMemberItor();
	local pMember = pMemberItor.GetCurMember();
	if not pMemberItor then
		return 0;
	end
	
	while pMember do
		local nPersonalFund = pMember.GetPersonalStock();
		nKinFund = nKinFund + nPersonalFund;
		pMember = pMemberItor.NextMember();
	end
	
	return nKinFund;
end

function Kin:GetExclusiveEvent(nKinId, nEventId)
	local tbTemp = (self:GetKinData(nKinId)).tbExclusiveEvent;
	if not tbTemp[nEventId] then
		tbTemp[nEventId] = {};
	end
	return tbTemp[nEventId];
end

function Kin:DelExclusiveEvent(nKinId, nEventId)
	local tbTemp = (self:GetKinData(nKinId)).tbExclusiveEvent;
	if not tbTemp[nEventId] then
		return 1;
	end
	tbTemp[nEventId].nApplyEvent = 0;	-- 申请事件标志清0
	tbTemp[nEventId].tbApplyRecord = nil 	-- 清空记录;（记录是如果执行的操作所需要的数据）
	tbTemp[nEventId].tbAccept	 = nil 	-- 清空表态表;
	tbTemp[nEventId].nCount 	 = 0;	-- 清记数器
end


function Kin:CheckNewKin()
	local nSec = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nServerStar = tonumber(os.date("%Y%m%d", nSec));
	if nServerStar >= self.NEW_KIN_LIMITDAY then
		return 1;
	end
	return 0;
end

-- 获得家族正式和荣誉成员上限
function Kin:GetKinMemberLimit(nKinId)
	--根据帮会进行判断
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local nMember = self.MEMBER_LIMITED;
	local nRetire = self.RETIRE_LIMITED;
	local nTongId = cKin.GetBelongTong();
	local cTong = KTong.GetTong(nTongId);
	if (cTong) then
		if cTong.GetKinCount() > Tong.MAX_KIN_NUM then
			nMember = self.MEMBER_LIMITED_OLD;
			nRetire = self.RETIRE_LIMITED_OLD;			
		end
	end

	return nMember, nRetire;
end
-- 更新家族成员最近登录时间
function Kin:UpdateLastLoginTime(nKinId, nTime, nGCReturn, nDataVer)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	nTime = nTime or GetTime();
	if MODULE_GC_SERVER then
		self.nJourNum = self.nJourNum + 1
		cKin.SetKinDataVer(self.nJourNum)
		cKin.SetLastLoginTime(nTime);
		GlobalExcute{"Kin:UpdateLastLoginTime", nKinId, nTime, 1, self.nJourNum}
	else
		if nGCReturn ~= 1 then
			GCExcute{"Kin:UpdateLastLoginTime", nKinId, nTime}
		else
			cKin.SetLastLoginTime(nTime);
			cKin.SetKinDataVer(nDataVer);
		end
	end
end

-- 是否有足够的家族资金
function Kin:CheckHaveEnoughMoney(nKinId, nNeedMoney)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	-- 检查家族资金是否被锁定
	local tbTakeFundData = Kin:GetExclusiveEvent(nKinId, Kin.KIN_EVENT_TAKE_FUND);
	if tbTakeFundData.nApplyEvent and tbTakeFundData.nApplyEvent == 1 then
		return -1;
	end
	local tbSalaryData = Kin:GetExclusiveEvent(nKinId, Kin.KIN_EVENT_SALARY);
	if tbSalaryData.nApplyEvent and tbSalaryData.nApplyEvent == 1 then
		return -1;
	end
	local nMoney = cKin.GetMoneyFund();
	if nMoney >= nNeedMoney then
		return 1;
	end
	return -2;
end