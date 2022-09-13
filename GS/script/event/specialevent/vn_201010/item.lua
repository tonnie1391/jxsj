-- 文件名  : item.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-09-25 11:58:56
-- 描述    :  vn 10月黄金白银龙

--VN--
if (MODULE_GAMESERVER) then
SpecialEvent.tbVnBaiYinLong = SpecialEvent.tbVnBaiYinLong or {};
local tbVnBaiYinLong = SpecialEvent.tbVnBaiYinLong;
tbVnBaiYinLong.tbHorse = {1, 12, 35, 4};
tbVnBaiYinLong.nRateHorse =   1;

function tbVnBaiYinLong:AddAward(szPlayerName)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return;
	end
	local pItem = pPlayer.AddItem(unpack(self.tbHorse));
	if pItem then
		pItem.Bind(1);
		Dbg:WriteLog("Vn_HuangJinBaiYin", "使用黄金龙", pPlayer.szAccount, pPlayer.szName, "获得马牌（奔霄）");
	end
	Dialog:GlobalNewsMsg_GS(string.format("恭喜玩家[%s]真是鸿运当头获得马牌（奔霄）！", pPlayer.szName));
end

function tbVnBaiYinLong:OnDialog()
	local nDate = me.GetTask(2140,1);
	local nJinCount = me.GetTask(2140,2);
	local nJinTotalCount = me.GetTask(2140,3);
	local nYinTotalCount = me.GetTask(2140,4);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate ~= nDate then
		nJinCount = 0;
	end
	local szMsg = string.format("你已经使用了%s个黄金龙，%s个白银龙，今天你已经使用了%s黄金龙。",nJinTotalCount, nYinTotalCount, nJinCount);
	local tbOpt = {
		{"Ta hiểu rồi"}
		};
	Dialog:Say(szMsg, tbOpt);
end
---------------------------------------------------------------
--黄金龙

local tbHuangJinLong	= Item:GetClass("huangjinlong_vn");

function tbHuangJinLong:OnUse()
	if me.nLevel < 60 then
		me.Msg("您的等级不足60级！");
		return 0;
	end
	 if me.CountFreeBagCell() < 2 then
	  	me.Msg("包裹空间不足2格，请整理下！");
	  	return 0;
	end
	local nDayFlag = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_VN_HUANGJINBAIYIN_DAY);
	local nAllCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_VN_HUANGJINBAIYIN_ALL);
	local nFlag = Item:GetClass("randomitem"):SureOnUse(113, 2140, 0, 0, 1, 2, 20, 3, 100, it);
	if nFlag == 1 then
		local nRate = MathRandom(10000);
		if nRate <= SpecialEvent.tbVnBaiYinLong.nRateHorse and nDayFlag == 0 and nAllCount < 10 then
			GCExcute({"SpecialEvent.tbVnBaiYinLong:CanGetHorse", me.szName});
		end
	end
	return nFlag;
end
end
----------------------------------------------------------------------------
--gc

if (MODULE_GC_SERVER) then

SpecialEvent.tbVnBaiYinLong = SpecialEvent.tbVnBaiYinLong or {};
local tbVnBaiYinLong = SpecialEvent.tbVnBaiYinLong;

function tbVnBaiYinLong:CanGetHorse(szPlayerName)
	local nDayFlag = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_VN_HUANGJINBAIYIN_DAY);
	local nAllCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_VN_HUANGJINBAIYIN_ALL);
	if nDayFlag == 1 or nAllCount >= 10 then
		return;
	end
	GlobalExcute({"SpecialEvent.tbVnBaiYinLong:AddAward", szPlayerName});
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_VN_HUANGJINBAIYIN_DAY, 1);
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_VN_HUANGJINBAIYIN_ALL, nAllCount + 1);
end

-- 动态注册到时间任务系统;
function tbVnBaiYinLong:RegisterScheduleTask()	
	local nTaskId = KScheduleTask.AddTask("SpecialEvent", "SpecialEvent", "ReSetTaskId_Vn_HuangJin");
	assert(nTaskId > 0);	
	KScheduleTask.RegisterTimeTask(nTaskId, 0000, 1);
end

function SpecialEvent:ReSetTaskId_Vn_HuangJin()
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_VN_HUANGJINBAIYIN_DAY, 0);
end

--GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbVnBaiYinLong.RegisterScheduleTask, SpecialEvent.tbVnBaiYinLong);
end
