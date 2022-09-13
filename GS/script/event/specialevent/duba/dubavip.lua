-- 文件名　：dubavip.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-17 11:33:18
-- 描  述  ：

SpecialEvent.DuBaVip = SpecialEvent.DuBaVip or {};
local tbClass = SpecialEvent.DuBaVip or {};

tbClass.TIME_STARTSERVER= 20080101;	-- 开服时间限制
tbClass.TIME_START 		= 201101;	-- 活动开始时间
tbClass.TIME_END		= 201101;	-- 活动结束时间
tbClass.TASK_GROUP_ID	= 2093;
tbClass.TASK_AUTHORITY	= 26;
tbClass.TASK_TIME		= 27;

tbClass.tbAwardItem = 
{-- 物品ID，数量, 绑定类型
	[1] = {{18, 1, 236, 1}, 5, 1},
	[2] = {{18, 1, 251, 1}, 1, 1},
	[3] = {{18, 1, 258, 1}, 2, 1}, 	
};
tbClass.nAwardBindMoney = 200000;	--绑银

function tbClass:CheckState()
	local nTime = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local szStartServerTime = os.date("%Y%m%d", nTime);
	local nStartServerTime = tonumber(szStartServerTime);
	local nNowDate = tonumber(GetLocalDate("%Y%m"));
	if nStartServerTime > self.TIME_STARTSERVER and nNowDate >= self.TIME_START and nNowDate <= self.TIME_END then
		return 1
	end 
	return 0;
end

-- 检查玩家是否有资格领取和本月是否领取
function tbClass:CheckTakeAuthority()
	local nAuthority = me.GetTask(tbClass.TASK_GROUP_ID, tbClass.TASK_AUTHORITY);
	local nChangeTime = me.GetTask(tbClass.TASK_GROUP_ID, tbClass.TASK_TIME);
	local nNowDate = tonumber(GetLocalDate("%Y%m"));
	if nAuthority == 1 and nNowDate > nChangeTime  then
		return 1;
	end
	return 0;
end

function tbClass:OnDialog(nConfirm)
	if self:CheckState() == 0 then
		return 0;
	end
	local nAuthority = me.GetTask(tbClass.TASK_GROUP_ID, tbClass.TASK_AUTHORITY);
	if nAuthority ~= 1 then
		Dialog:Say("对不起，您没有资格领取毒霸特权月度礼包。");
		return 0;
	end
	local nChangeTime = me.GetTask(tbClass.TASK_GROUP_ID, tbClass.TASK_TIME);
	local nNowDate = tonumber(GetLocalDate("%Y%m"));
	if nNowDate <= nChangeTime then
		Dialog:Say("您本月已经领取过毒霸特权月度礼包。");
		return 0;
	end
	if not nConfirm or nConfirm ~= 1 then
		local tbOpt = 
		{
			{"确认", self.OnDialog, self, 1},
			{"下次再领吧"},		
		};
		Dialog:Say("   感谢您对金山毒霸的支持！我这里为您准备了一些礼物，请确认背包有足够的空间。\n\n<color=yellow>1、20万绑银\n2、5个江湖威望令牌（绑定）\n3、1个密境地图\n4、2个修炼丹（绑定）\n<color>\n确定领取？", tbOpt);
		return 0;
	end 
	if me.GetMaxCarryMoney() < me.GetBindMoney() + self.nAwardBindMoney then
		Dialog:Say("您领取的绑银会使绑银携带量超出上限！");
		return 0;
	end
	local nBagNeed = 0;
	for _, tbParam in pairs(self.tbAwardItem) do
		nBagNeed = nBagNeed + tbParam[2] or 1;
	end
	if me.CountFreeBagCell() < nBagNeed then
		Dialog:Say(string.format("Hành trang không đủ chỗ trống，请清理出<colro=yellow>%s格<color>背包空间。", nBagNeed));
		return 0;
	end
	me.SetTask(tbClass.TASK_GROUP_ID, tbClass.TASK_TIME, nNowDate);
	me.AddBindMoney(self.nAwardBindMoney);
	for _, tbParam in pairs(self.tbAwardItem) do
		local tbItemId = tbParam[1];
		local nCount = tbParam[2] or 1;
		local nBind = tbParam[3] or 1;
		local tbItemInfo = {};
		if nBind > 0 then
			tbItemInfo.bForceBind = nBind;
		end
		local nAddCount = me.AddStackItem(tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4], tbItemInfo, nCount);
	end
	Dbg:WriteLog("毒霸特权礼包", "Nhận", me.szAccount, me.szName);
	Dialog:Say("您已成功领取本月毒霸特权礼包。");
end