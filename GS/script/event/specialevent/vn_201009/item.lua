-- 文件名  : item.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-08-25 09:48:32
-- 描述    :  vn中秋国庆活动相关物品

--VN--
if (MODULE_GAMESERVER) then
---------------------------------------------------------------
--绿豆饼

local tbLvDou	= Item:GetClass("lvdoubing");
tbLvDou.tbShiPinBag = {18,1,684,1};

function tbLvDou:OnUse()
	if me.CountFreeBagCell() < 1 then
	  	me.Msg("包裹空间不足1格，请整理下！");
	  	return 0;
	end
	local nFlag = Item:GetClass("randomitem"):SureOnUse(96, 2069, 0, 0, 78, 79, 10, 80, 100);
	if nFlag == 1 then
		local nRate = MathRandom(100);
		if nRate <= 10 then
			me.AddItem(unpack(self.tbShiPinBag));
			Dbg:WriteLog("vnMAFestival", "使用绿豆饼", me.szAccount, me.szName, "获得随机道具食品袋子");
		end
	end
	return nFlag;
end

---------------------------------------------------------------
--什锦饼

local tbShiJin	= Item:GetClass("ShiJinbing");
tbShiJin.tbShiPinBag = {18,1,684,1};

function tbShiJin:OnUse()
	 if me.CountFreeBagCell() < 2 then
	  	me.Msg("包裹空间不足2格，请整理下！");
	  	return 0;
	end
	local nCount = me.GetTask(2069,81);
	if nCount >= 50 then
		me.Msg("您已经食用了50个什锦饼了，不能在吃了！")
		return 0;
	end
	local nFlag = Item:GetClass("randomitem"):SureOnUse(97, 2069, 0, 0, 78, 79, 10, 80, 100);
	if nFlag == 1 then
		local nRate = MathRandom(100);
		if nRate <= 3 then
			me.AddItem(unpack(self.tbShiPinBag));
			Dbg:WriteLog("vnMAFestival", "使用什锦饼", me.szAccount, me.szName, "获得随机道具食品袋子");
		end
		me.SetTask(2069,81, nCount + 1);
	end
	return nFlag;
end

-------------------------------------------------------------------------
--查询食用的饼的数量

SpecialEvent.tbVnZhongQiu = SpecialEvent.tbVnZhongQiu or {};
local tbVnZhongQiu = SpecialEvent.tbVnZhongQiu;
tbVnZhongQiu.nNpcId = 0;			--是否加载过npc标志
tbVnZhongQiu.nTempNpcId = 6723;	--模板id
tbVnZhongQiu.nStartTime = 20100815;	--开始时间
tbVnZhongQiu.nCloseTime = 20100814;	--结束时间
tbVnZhongQiu.tbNpcPos = {			--事件使者位置
	{23,1583,3088},
	{24,1808,3488},
	{25,1634,3119},	
	{26,1600,3182},
	{27,1625,3184},
	{28,1512,3262},
	{29,1648,3920},
	}
tbVnZhongQiu.tbNpcPos_CaiYuan  = {7222, 5, 1590, 3109};
tbVnZhongQiu.nNpcId_CaiYuan = 0;

function tbVnZhongQiu:OnDialog()
	local nTotalCount = me.GetTask(2069,80);
	local nJinShiCount = me.GetTask(2069,81);
	local nTodayCount = me.GetTask(2069,79);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate ~= me.GetTask(2069,78) then
		nTodayCount = 0;
	end
	
	local szMsg = string.format("你已经食用了%s什锦饼、%s绿豆饼、今天你已经食用了%s个饼，活动期间你总共食用%s个饼",nJinShiCount, nTotalCount - nJinShiCount, nTodayCount, nTotalCount);
	local tbOpt = {
		{"Ta hiểu rồi"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function SpecialEvent:SeverStartVn09()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate < tbVnZhongQiu.nStartTime or nNowDate > tbVnZhongQiu.nCloseTime then
		return;
	end
	for _, tbNpc in ipairs(tbVnZhongQiu.tbNpcPos) do
		if SubWorldID2Idx(tbNpc[1]) >= 0 then
			 if tbVnZhongQiu.nNpcId == 0 then			--没有加载过，add NPC
		 		local pNpc = KNpc.Add2(tbVnZhongQiu.nTempNpcId, 100, -1, tbNpc[1], tbNpc[2], tbNpc[3]);
			end
		end
	end
	tbVnZhongQiu.nNpcId = 1;
end

ServerEvent:RegisterServerStartFunc(SpecialEvent.SeverStartVn09, SpecialEvent);

end

----------------------------------------------------------------------------
--gc

if (MODULE_GC_SERVER) then

SpecialEvent.tbVnZhongQiu = SpecialEvent.tbVnZhongQiu or {};
local tbVnZhongQiu = SpecialEvent.tbVnZhongQiu;

function SpecialEvent:SeverStartVn09()
	GlobalExcute{"SpecialEvent:SeverStartVn09"};
end

-- 动态注册到时间任务系统
function tbVnZhongQiu:RegisterScheduleTask()	
	local nTaskId = KScheduleTask.AddTask("SpecialEvent", "SpecialEvent", "SeverStartVn09");
	assert(nTaskId > 0);
	-- 时间执行点注册
	KScheduleTask.RegisterTimeTask(nTaskId, 0000, 1);
end

--GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbVnZhongQiu.RegisterScheduleTask, SpecialEvent.tbVnZhongQiu);

end
