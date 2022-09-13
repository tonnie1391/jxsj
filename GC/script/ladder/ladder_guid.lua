-- 文件名　：
-- 创建者　：zhaoyu
-- 创建时间：2010/7/2 9:14:35

Require("\\script\\player\\playerhonor.lua");
Require("\\script\\ladder\\define.lua")

Ladder.tbGuidLadder = Ladder.tbGuidLadder or {};

local KEY_GUID	= 1;
local KEY_NAME	= 2;
local KEY_VALUE	= 3;
local ORDER_COUNT = 1000;

local tbGuidLadder = Ladder.tbGuidLadder;
tbGuidLadder.tbGuidData = {};
tbGuidLadder.tbOrderedData = {};

tbGuidLadder.nLadderCount = 10; -- guid榜的个数

tbGuidLadder.tbLadderMemberCount = {};

-- 客户端可以调用的接口
tbGuidLadder.tbC2SCall = 
{
	["ApplyData"] = 1,
};

-- 修改数据接口
function tbGuidLadder:ApplyChangeValue(nLadderId, szGuid, szName, nValue)
	GCExecute({"Ladder.tbGuidLadder:ValueChanged", nLadderId, szGuid, szName, nValue});
end

function tbGuidLadder:ValueChanged(nLadderId, szGuid, szName, nValue)
	GuidLadder_ValueChange(nLadderId, szGuid, szName, nValue);
	if (MODULE_GC_SERVER) then
		GSExecute(-1, {"Ladder.tbGuidLadder:ValueChanged", nLadderId, szGuid, szName, nValue});
	end
	if (MODULE_GAMESERVER) then
		local pPlayer = KPlayer.GetPlayerByName(szName);
		if (pPlayer) then
			Item.tbZhenYuan:UpdateLadderInfo(pPlayer, szGuid)
		end
	end
end

-- 客户端申请查询排行榜
function tbGuidLadder:ApplyData(nLadderId, nOrder1, nCount, szCallBack)
	local tbData = GuidLadder_ApplyData(nLadderId, nOrder1, nCount);
	local nParterId = Item.tbZhenYuanSetting.tbZhenYuanTempToPartnerId[nLadderId];
	local szName = Item.tbZhenYuanSetting.tbPartnerToZhenYuan[nParterId].szPartnerName;
	if (tbData) then
		local nMonth = tonumber(os.date("%m", GetTime() - 60 * 60 * 24));
		local nDay = tonumber(os.date("%d", GetTime() - 60 * 60 * 24));
		local szDate = string.format("%d月%d日", nMonth, nDay);
		tbData.szContext = string.format("%s【真元】%s 排行榜", szDate, szName);
		local nMemberCount = GuidLadder_GetMemberCount(nLadderId);
		if nMemberCount > ORDER_COUNT then
			tbData.nMaxLadder = ORDER_COUNT;
		else
			tbData.nMaxLadder = nMemberCount;
		end
		tbData.nType = nLadderId;
		tbData.nBeginId = nOrder1;
		me.CallClientScript({szCallBack, tbData});
	end
end

-- 客户端申请通过名字查询
function tbGuidLadder:FindByName(nLadderId, szName, nStart, szCallBack)
	local nRank, nValue = GuidLadder_FindByName(nLadderId, nStart, szName);
	if (nRank) then 
		me.CallClientScript({szCallBack, nRank, nValue});
	end
	--if (nRank > ORDER_COUNT) then
	--	nRank = 0;
	--end
	return nRank, nValue;
end

-- 客户端申请通过GUID查询
function tbGuidLadder:FindByGuid(nLadderId, szGuid, szCallBack)
	local nRank, nValue = GuidLadder_FindByGuid(szGuid);
	if not nRank then
		return -1;
	end
	if (nRank and szCallBack) then
		me.CallClientScript({szCallBack, nRank, nValue});
	end
	--if (nRank > ORDER_COUNT) then
	--	nRank = -1;
	--	nValue = 0;
	--end
	return nRank, nValue;
end

-- 排行
function tbGuidLadder:UpdateRank()
	GuidLadder_UpdateRank();
	if (MODULE_GC_SERVER) then
		GSExecute(-1, {"Ladder.tbGuidLadder:UpdateRank"});
	end
end

function tbGuidLadder:WriteLadderLog(nLadderId, szLog)
	Dbg:WriteLog("FightPower", "ZhenYuanLadder", nLadderId, szLog);
end
