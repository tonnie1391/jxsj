-------------------------------------------------------------------
--File: tongquerycmd.lua
--Author: zhengyuhua
--Date: 2010-7-22 17:33
--Describe: 帮会查询用指令
-------------------------------------------------------------------

Tong.tbQueryCmd = {};
local tbCmd = Tong.tbQueryCmd

-- 总财富
function tbCmd.GetTotalWealth(pTong, nTongId)
	local pKinIt 		= pTong.GetKinItor();
	local nCurKinId		= pKinIt.GetCurKinId();
	local pCurKin		= KKin.GetKin(nCurKinId);
	local nTotalWealth	= 0;	
	
	while pCurKin do
		local pMemberItor = pCurKin.GetMemberItor();
		local pMember = pMemberItor.GetCurMember();
		while (pMember) do
			nTotalWealth = nTotalWealth + GetPlayerHonor(pMember.GetPlayerId(),8,0)
			pMember = pMemberItor.NextMember();
		end
		nCurKinId 	= pKinIt.NextKinId();
		pCurKin		= KKin.GetKin(nCurKinId);
	end
	return nTotalWealth;
end

function tbCmd.GetTotalMember(pTong, nTongId)
	return Tong:GetTotalMemberCount(pTong)
end

-- 正式成员数
function tbCmd.GetTotalNormalMember(pTong, nTongId)
	local tbResult = pTong.GetCrowdCount(0);
	return tbResult[4];
end

-- 股价
function tbCmd.GetStockPrice(pTong, nTongId)
	local nTotalStock = pTong.GetTotalStock();	-- 总股份数
	local nBuildFund = pTong.GetBuildFund();	-- 建设资金					-- 股价
	if nTotalStock > 0 and nBuildFund > 0 then
		return nBuildFund / nTotalStock;
	end
	return 0;
end

-- 首领股比
function tbCmd.GetPresidentStockPercent(pTong, nTongId)
	local nKinId = pTong.GetPresidentKin();
	local nMemberId = pTong.GetPresidentMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then 
		return 0;
	end
	if pKin.GetBelongTong() ~= nTongId then
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	local nTotalStock = pTong.GetTotalStock();	-- 总股份数
	if nTotalStock <= 0 then
		return 0;
	end
	return pMember.GetPersonalStock() / nTotalStock;
end

-- 首领名
function tbCmd.GetPresidentName(pTong, nTongId)
	return Tong:GetPresidentMemberName(nTongId);
end

-- 帮主名
function tbCmd.GetMasterName(pTong, nTongId)
	return KGCPlayer.GetPlayerName(Tong:GetMasterId(nTongId)) or "";
end

