-- 文件名  : item.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-09-25 11:58:56
-- 描述    :  vn 11月教师节

--VN--
if not MODULE_GAMESERVER then
	return;
end

SpecialEvent.tbVnTeacher = SpecialEvent.tbVnTeacher or {};
local tbVnTeacher = SpecialEvent.tbVnTeacher;

function tbVnTeacher:OnDialog()
	local nDate = me.GetTask(2143,2);
	local nHisCount = me.GetTask(2143,3);
	local nHisTotalCount = me.GetTask(2143,4);
	local nGeoTotalCount = me.GetTask(2143,1);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate ~= nDate then
		nHisCount = 0;
	end
	local szMsg = string.format("  你总共已经阅读了<color=yellow>%s<color>本历史书，<color=yellow>%s<color>本地理书，今天你已经阅读了<color=yellow>%s<color>本历史书。",nHisTotalCount, nGeoTotalCount, nHisCount);
	local tbOpt = {
		{"Ta hiểu rồi"}
		};
	Dialog:Say(szMsg, tbOpt);
end

---------------------------------------------------------------
--历史书

local tbItem	= Item:GetClass("lishishu_vn");
tbItem.tbZhengDuoLing = {18, 1, 1059, 1};
tbItem.nZDLStartTime = 20101108;		--争夺战开始时间
tbItem.nZDLEndTime = 20101122;		--争夺战结束时间

function tbItem:OnUse()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.nLevel < 60 then
		me.Msg("您的等级不足60级！");
		return 0;
	end
	 if me.CountFreeBagCell() < 2 then
	  	me.Msg("包裹空间不足2格，请整理下！");
	  	return 0;
	end
	local nFlag = Item:GetClass("randomitem"):SureOnUse(124, 2143, 0, 0, 2, 3, 20, 4, 100, it);
	if nFlag == 1 and nNowDate >= self.nZDLStartTime and nNowDate < self.nZDLEndTime then
		me.AddItem(unpack(self.tbZhengDuoLing));
	end
	return nFlag;
end

--帮会争夺令

local tbTongItem	= Item:GetClass("banghuizhengduoling");

function tbTongItem:OnUse()
	if me.GetTask(2143,17) == 1 then
		me.Msg("你已经有资格了，还是不要浪费了！");
		return 0;
	end
	me.Msg("你已经成功登记参加帮会争夺战第二届!");
	me.SetTask(2143,17,1);
	return 1;
end
