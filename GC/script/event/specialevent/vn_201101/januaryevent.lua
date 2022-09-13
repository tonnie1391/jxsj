-- 文件名  : januaryevent.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-12-28 09:27:52
-- 描述    : 一月vn活动

SpecialEvent.JanuaryEvent_vn = SpecialEvent.JanuaryEvent_vn or {};
local tbJanuaryEvent_vn = SpecialEvent.JanuaryEvent_vn;
tbJanuaryEvent_vn.nOpenDate = 20100120		--开始日期
tbJanuaryEvent_vn.nCloseDate = 20100220		--结束日期

tbJanuaryEvent_vn.nAllCount_YH = 10;			--烟花活动的马总的
tbJanuaryEvent_vn.tbHorse_YH = {1, 12, 35, 4};	--烟花活动的马GDPL
tbJanuaryEvent_vn.nRandom_YH = 1;			--烟花活动获得马的概率(1-10000)

tbJanuaryEvent_vn.nAllCount_GP = 5;			--五果盘活动的马总的
tbJanuaryEvent_vn.tbHorse_GP = {1, 12, 33, 4};	--五果盘活动的马GDPL
tbJanuaryEvent_vn.nRandom_GP = 1;			--五果盘活动获得马的概率(1-100000)

if MODULE_GC_SERVER then

function tbJanuaryEvent_vn:IsGetHorse_YH(nPlayerId)
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDate = KGblTask.SCGetDbTaskInt(DBTASK_VN_BENXIAO_LAST_DAY_YH);
	local nAllCount = KGblTask.SCGetDbTaskInt(DBTASK_VN_BENXIAO_ALL_COUNT_YH) + 1;
	if nNowDate ~= nDate and nAllCount <= self.nAllCount_YH then
		GlobalExcute{"SpecialEvent.JanuaryEvent_vn:OnSpecialAward_YH",nPlayerId, 1};
		KGblTask.SCSetDbTaskInt(DBTASK_VN_BENXIAO_LAST_DAY_YH, nNowDate);
		KGblTask.SCSetDbTaskInt(DBTASK_VN_BENXIAO_ALL_COUNT_YH, nAllCount);
	else
		GlobalExcute{"SpecialEvent.JanuaryEvent_vn:OnSpecialAward_YH",nPlayerId};
	end	
end

function tbJanuaryEvent_vn:IsGetHorse_GP(nPlayerId)
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDate = KGblTask.SCGetDbTaskInt(DBTASK_VN_BENXIAO_LAST_DAY_GP);
	local nAllCount = KGblTask.SCGetDbTaskInt(DBTASK_VN_BENXIAO_ALL_COUNT_GP) + 1;
	if nDate ~= nNowDate and nAllCount <= self.nAllCount_GP then
		GlobalExcute{"SpecialEvent.JanuaryEvent_vn:OnSpecialAward_GP",nPlayerId, 1};
		KGblTask.SCSetDbTaskInt(DBTASK_VN_BENXIAO_LAST_DAY_GP, nNowDate);
		KGblTask.SCSetDbTaskInt(DBTASK_VN_BENXIAO_ALL_COUNT_GP, nAllCount);
	else
		GlobalExcute{"SpecialEvent.JanuaryEvent_vn:OnSpecialAward_GP",nPlayerId};
	end	
end

end

if MODULE_GAMESERVER then
function tbJanuaryEvent_vn:OnSpecialAward_YH(nPlayerId, nFlag)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	pPlayer.AddWaitGetItemNum(-1);
	if nFlag then
		local pItem = pPlayer.AddItem(unpack(self.tbHorse_YH));
		if pItem then
			pItem.SetTimeOut(0, GetTime()  + 90*24*3600);
			pItem.Sync();
			KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, string.format("%s点燃烟花获得一个%s，真是鸿运当头呀！", pPlayer.szName, pItem.szName));
			Dbg:WriteLog("[越南1月烟花活动]使用火柴烟花获得奔宵马");
		end
	end	
end

function tbJanuaryEvent_vn:OnSpecialAward_GP(nPlayerId, nFlag)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	pPlayer.AddWaitGetItemNum(-1);
	if nFlag then
		local pItem = pPlayer.AddItem(unpack(self.tbHorse_GP));
		if pItem then
			KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, string.format("%s打开五果黄金盘获得一个%s，真是鸿运当头呀！", pPlayer.szName, pItem.szName));
			Dbg:WriteLog("[越南1月五果盘活动]使用五果黄金盘获得翻羽马");
		end
	end	
end

function tbJanuaryEvent_vn:OnDialog_YH()
	local nTotalCount = me.GetTask(2143,26);	
	local nTodayCount = me.GetTask(2143,25);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate ~= me.GetTask(2143,24) then
		nTodayCount = 0;
	end
	
	local szMsg = string.format("你今天已经点燃了%s个烟花，活动期间你总共点燃了%s个烟花",nTodayCount, nTotalCount);
	local tbOpt = {
		{"我知道了"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbJanuaryEvent_vn:OnDialog_GP()
	local nTotalCount_G = me.GetTask(2143,29);
	local nTotalCount = me.GetTask(2143,30);
	local nTodayCount = me.GetTask(2143,28);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate ~= me.GetTask(2143,27) then
		nTodayCount = 0;
	end
	
	local szMsg = string.format("你今天已经使用了%s个五果盘，活动期间你总共使用%s个五果黄金盘、%s个五果白银盘",nTodayCount, nTotalCount_G, nTotalCount);
	local tbOpt = {
		{"我知道了"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbJanuaryEvent_vn:OnDialog_ZZ()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCount = me.GetTask(2143,22);
	if nNowDate ~= me.GetTask(2143,21) then
		nCount = 0;
	end
	
	local szMsg = string.format("你今天已经煮了%s个粽子",nCount);
	local tbOpt = {
		{"我知道了"}
		};
	Dialog:Say(szMsg, tbOpt);
end
end
