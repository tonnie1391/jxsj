
SpecialEvent.ChongZhi = {};
local tbChongZhi = SpecialEvent.ChongZhi;

tbChongZhi.IS_AWARDED_EXT_POINT = 2;		-- 是否领取过送礼扩展点
tbChongZhi.AWARD_IN500 = 
{
	{tbItem = {1,12,6,3,{bForceBind = 1}}, nCount = 1, nTimeOut = 365 * 24 * 3600},
	{tbItem = {18,1,212,1,{bForceBind = 1}}, nCount = 7, nTimeOut = 10 * 24 * 3600},
}


function tbChongZhi:OnDialog()
	local nState = SpecialEvent.GameOpenTest:GetState(3)
	if nState == 1 then
		Dialog:Say("活动开始后，当月累计充值达到48元，可以领取一块<color=yellow>黄金庆贺令<color>；当月累计充值达到500元，可再获取<color=yellow>一匹90级马（一年）和7个祈福道具。<color>\n（注：1个帐号只能领取各种奖励一次）",
			{
				{"领取48元礼品", self.Get48Award, self},
				{"领取500元礼品", self.Get500Award, self},
			})
	else
		Dialog:Say("现在不是活动时间，不可以领取礼品");
	end
end

function tbChongZhi:Get48Award()
	local nState = SpecialEvent.GameOpenTest:GetState(3)
	if nState == 0 then
		Dialog:Say("现在不是活动时间，不可以领取礼品")
		return 0;
	end
	local nCurCharge = me.nMonCharge;
	local nExtPoint = me.GetExtPoint(self.IS_AWARDED_EXT_POINT)
	local bAwarded = nExtPoint % 10;
	if bAwarded > 0 then
		Dialog:Say("对不起，您已经领取过了，不可以贪心的。");
		return 0;
	end
	if nCurCharge < 48 then
		Dialog:Say("对不起，请您确认本月充值超过48元，再来领取礼品吧。");
		return 0;
	end
	if me.CountFreeBagCell() <= 0 then
		Dialog:Say("Hành trang không đủ 。");
		return 0;
	end
	local pItem = me.AddItemEx(18,1,211,1, {bForceBind = 1});
	if pItem then
		me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 3*24*3600), 0);
		me.AddExtPoint(self.IS_AWARDED_EXT_POINT, 1);
		Dbg:WriteLog("chongzhisongli", "Add48Successed",  "角色名:"..me.szName, "帐号:"..me.szAccount);
		Dialog:Say("请您拿好礼品并在使用期限之前使用它们。感谢您对《剑侠世界》的支持。")
		return 0;
	end
	Dbg:WriteLog("chongzhisongli", "Add48Failded",  "角色名:"..me.szName, "帐号:"..me.szAccount);
end

function tbChongZhi:Get500Award()
	local nState = SpecialEvent.GameOpenTest:GetState(3)
	if nState == 0 then
		Dialog:Say("现在不是活动时间，不可以领取礼品")
		return 0;
	end
	local nCurCharge = me.nMonCharge;
	local nExtPoint = me.GetExtPoint(self.IS_AWARDED_EXT_POINT)
	local bAwarded = math.floor(nExtPoint /10);
	if bAwarded > 0 then
		Dialog:Say("对不起，您已经领取过了，不可以贪心的。");
		return 0;
	end
	if nCurCharge < 500 then
		Dialog:Say("对不起，请您确认本月充值超过500元，再来领取礼品吧。");
		return 0;
	end
	if me.CountFreeBagCell() < 8 then
		Dialog:Say("Hành trang không đủ 。请腾出8格空间再来领取。");
		return 0;
	end
	for i=1, #self.AWARD_IN500 do
		if self.AWARD_IN500[i] then
			for j=1, self.AWARD_IN500[i].nCount do
				local pItem = me.AddItemEx(unpack(self.AWARD_IN500[i].tbItem));
				if pItem then
					me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + self.AWARD_IN500[i].nTimeOut), 0)
				else
					Dbg:WriteLog("chongzhisongli", "Add500Failded in "..i.." "..j,  "角色名:"..me.szName, "帐号:"..me.szAccount);
				end
			end
		end
	end
	me.AddExtPoint(self.IS_AWARDED_EXT_POINT, 10);		-- 标志领取过500的奖励
	Dbg:WriteLog("chongzhisongli", "Add500 over",  "角色名:"..me.szName, "帐号:"..me.szAccount);
end

