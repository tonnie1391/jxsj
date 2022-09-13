-------------------------------------------------------------------
--File: unionlogic.lua
--Author: zhangyuhua
--Date: 2009-6-6 15:17
--Describe: 基础联盟逻辑
-------------------------------------------------------------------
if not Union then --调试需要
	Union = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end

--定义临时变量，用于生成运行期的唯一流水ID号
if not Union.nJourNum then
	Union.nJourNum = 0;
end

-- 通过帮会ID获得联盟ID
function Union:GetUnionByTong(nTongId)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0;
	end
	return pTong.GetBelongUnion();
end

-- 检查创建联盟的帮会是否符合要求
function Union:CheckTong(tbPlayerInfo)
	if not tbPlayerInfo or type(tbPlayerInfo) ~= "table" or #tbPlayerInfo < 2 or #tbPlayerInfo > self.MAX_TONG_NUM then
		return 0, "队伍成员数量不符合创建联盟的条件， 联盟创建失败！";
	end
	local nTime = GetTime();
	for i, tbInfo in ipairs(tbPlayerInfo) do
		local pTong = KTong.GetTong(tbInfo.dwTongId)
		if not pTong then
			return 0, "队伍中所有成员必须有帮会并且是帮主，请让不符合条件的人离队然后找齐合适的人之后再过来找我。";
		end
		if not tbInfo.dwTongId or not tbInfo.nKinId or not tbInfo.nMemberId then 
			return 0, "队伍中所有成员必须有帮会，请让不符合条件的人离队然后找齐合适的人之后再过来找我。";
		end
		if Tong:CheckSelfRight(tbInfo.dwTongId,	tbInfo.nKinId, tbInfo.nMemberId, Tong.POW_MASTER)  ~= 1 then
			return 0, "队伍中所有成员必须都为帮主(并且权限不被冻结)，请让不符合条件的人离队然后找齐合适的人之后再过来找我。";
		end
		if pTong.GetBelongUnion() and pTong.GetBelongUnion() ~= 0 then
			return 0, "已加入联盟的帮主不能参与创建，请让不符合条件的人离队然后找齐合适的人之后再过来找我。";
		end
		if pTong.GetDomainCount() > self.MAX_TONG_DOMAIN_NUM then
			return 0, "队伍中有成员帮会领土数已经超过"..self.MAX_TONG_DOMAIN_NUM.."块，不能创建联盟。";
		end
		if nTime - pTong.GetLeaveUnionTime() < Tong.TONG_LEVE_UNION_LAST then
			return 0, "队伍中有成员刚退出联盟未满24小时，不能创建联盟。";
		end
	end
	return 1, "";
end

-- 以列表的UnionId创建联盟
function Union:CreateUnion(anTongId, szUnionName, nCreateTime)
	_DbgOut("Union:CreateUnion "..szUnionName);
	if not anTongId or type(anTongId) ~= "table" or #anTongId < 1 then
		return 0;
	end
	local pUnion, nUnionId = KUnion.AddUnion(szUnionName);
	if not pUnion then
		_DbgOut("Union:CreateUnion Add Failed");
		return nil;
	end
	--不允许ID为0
	if nUnionId == 0 then
		KUnion.DelUnion(nUnionId);
		return nil;
	end
	
	for i, nTongId in ipairs(anTongId) do
		pUnion.AddTong(nTongId, nCreateTime);
	end

	pUnion.SetCreateTime(nCreateTime);
	--第1个帮的帮主作为盟主
	pUnion.SetUnionMaster(anTongId[1]);
	--设置联盟名字
	pUnion.SetName(szUnionName);
	
	_DbgOut("Union:CreateUnion succeed")
	return pUnion, nUnionId;
end

-- 获得盟主的nPlayerId
function Union:GetUnionMasterId(nUnionId)
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end	
	local nMasterTongId = pUnion.GetUnionMaster()
	return Tong:GetMasterId(nMasterTongId);
end

-- 获得联盟的领土数（包括已分配的领土）
function Union:GetUnionDomainCount(nUnionId)
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end
	
	local nUnionDomainCount = pUnion.GetDomainCount();
	local pTongItor = pUnion.GetTongItor();
	local nTongId = pTongItor.GetCurTongId();
	while nTongId ~= 0 do
		local pTong = KTong.GetTong(nTongId);
		if pTong then
			nUnionDomainCount = nUnionDomainCount + pTong.GetDomainCount();
		end
		nTongId = pTongItor.NextTongId();
	end
	return nUnionDomainCount;
end

-- 遍历帮会并执行
function Union:ExcutePerTong(nUnionId, fnExcute, ...)
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end
	local tbRet = {};
	local pTongItor = pUnion.GetTongItor();
	if not pTongItor then
		return 0;
	end
	local nTongId = pTongItor.GetCurTongId()
	while nTongId ~= 0 do
		
		fnExcute(nTongId, ...);
		nTongId = pTongItor.NextTongId();
	end
end

-- 广播联盟信息
function Union:Msg2UnionTong(nUnionId, szMsg, bDirect)
	local fnExcute = function (nTongId)
		KTong.Msg2Tong(nTongId, szMsg, bDirect or 1);
	end
	self:ExcutePerTong(nUnionId, fnExcute);
end

function Union:UnionClientExcute(nUnionId, tbArg)
	local fnExcute = function (nTongId, tbArg)
		KTongGs.TongClientExcute(nTongId, tbArg);
	end
	self:ExcutePerTong(nUnionId, fnExcute, tbArg);
end

-- 遍历联盟的领土并执行
function Union:ExcutePerUnionDomain(nUnionId, fnExcute)
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end
	local tbRet = {};
	local pUDomainItor = pUnion.GetDomainItor()
	local nUDomainId = pUDomainItor.GetCurDomainId();
	while nUDomainId ~= 0 do
		fnExcute(nUDomainId);		-- 未分配领土
		nUDomainId = pUDomainItor.NextDomainId();
	end
	
	local pTongItor = pUnion.GetTongItor();
	local nTongId = pTongItor.GetCurTongId();
	while nTongId ~= 0 do
		local pTong = KTong.GetTong(nTongId);
		if pTong then
			local pDomainItor = pTong.GetDomainItor()
			local nDomainId = pDomainItor.GetCurDomainId()
			while nDomainId ~= 0 do
				fnExcute(nUDomainId);		-- 已分配属于某帮会的领土
				nDomainId = pDomainItor.NextDomainId()
			end
		end
		nTongId = pTongItor.NextTongId();
	end
	return nUnionDomainCount;
end

-- 通过ID获得对应的Tong或者Union
function Union:GetTongTable(nId)
	if not nId or nId == 0 then
		return 0;
	end
	local tbTong = {}
	local pTong = KTong.GetTong(nId);
	if pTong then
		table.insert(tbTong, pTong);
		return tbTong;
	end
	local pUnion = KUnion.GetUnion(nId);
	if pUnion then
		local pTongItor = pUnion.GetTongItor();
		local nTongId = pTongItor.GetCurTongId();
		while nTongId ~= 0 do
			local pTong = KTong.GetTong(nTongId);
			if pTong then
				table.insert(tbTong, pTong);
			end
			nTongId = pTongItor.NextTongId();
		end
		return tbTong;
	end
	return 0;
end

-- 返回联盟的宣战状态 -1:无法宣战 0:只能宣战新手村 1:可宣战任意白城 2:只能宣战周边白城
function Union:GetUnionDomainDecleaarState(nUnionId)
	local pUnion = KUnion.GetUnion(nUnionId);
	if pUnion and self:GetUnionDomainCount(nUnionId) > pUnion.GetTongCount() then
		return -1;
	end
	local nState = 0;
	local fnExcute = function (nDomainId)
		if Domain:GetDomainType(nDomainId) == "village" and nState ~= 2 then
			nState = 1;
		else
			nState = 2;
		end
	end
	self:ExcutePerUnionDomain(nUnionId, fnExcute);
	return nState;
end

	
