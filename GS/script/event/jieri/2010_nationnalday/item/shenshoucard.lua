--=================================================
-- 文件名　：shenshoucard.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-24 11:34:05
-- 功能描述：神州卡
--=================================================

local tbItem = Item:GetClass("shenshoucard");
SpecialEvent.tbNationnalDay = SpecialEvent.tbNationnalDay or {};
local tbEvent = SpecialEvent.tbNationnalDay or {};

function tbItem:CanUse()
	local szErrMsg = "";
	
	if (tbEvent:CheckOpenFlag() ~= tbEvent.STATE_OPEN) then
		szErrMsg = "现在不在活动期间，不能使用神州卡。";
		return 0, szErrMsg;
	end
	
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	local nLastUseDate = me.GetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_DATE);
	if (nCurDate ~= nLastUseDate) then
		me.SetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_DATE, nCurDate);
		me.SetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_COUNT_DAY, 0);
	end
	
--	if (me.CountFreeBagCell() < 1) then
--		szErrMsg = "需要1个包裹空间。"
--		return 0, szErrMsg;
--	end
	
	local bCollectAll = 1;
	for i = 1, tbEvent.COUNT_AREA do
		if (tbEvent:GetAchieveFlag(i) == 0) then
			bCollectAll = 0;
			break;
		end
	end
	if (1 == bCollectAll) then
		szErrMsg = "恭喜你，你已经收集了所有的卡片，不需要继续使用其他卡片了。";
		return 0, szErrMsg;
	end
	
	return 1;
end

function tbItem:GetRandomAreaIndex()
	local tbIndex_DonotHave = {};
	for i = 1, tbEvent.COUNT_AREA do
		if (tbEvent:GetAchieveFlag(i) == 0) then
			table.insert(tbIndex_DonotHave, i);
		end
	end
	if (#tbIndex_DonotHave == 0) then
		return 0;
	end
	local nIndex = MathRandom(1, #tbIndex_DonotHave);
	return tbIndex_DonotHave[nIndex];
end

function tbItem:OnUse()
	local bCanUse, szErrMsg = self:CanUse();
	if (not bCanUse or 0 == bCanUse) then
		if (szErrMsg and "" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	local nRand = self:GetRandomAreaIndex();
	tbEvent:OnGetAreaCard(nRand);
	return 1;
end
