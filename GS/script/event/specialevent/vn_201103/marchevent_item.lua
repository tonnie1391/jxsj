-- 文件名　：marchevent_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-03-22 16:41:42
--越南3月活动道具

--粽子
local tbItem_BM	= Item:GetClass("zongzi201103_vn");

function tbItem_BM:OnUse()
	if me.nLevel < 65 then
		Dialog:Say("您等级不足65级！",{"知道了"});
		return 0;
	end	
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("Hành trang không đủ chỗ trống<color=yellow>2格<color>！");
		return 0;
	end	
	local nFlag = Item:GetClass("randomitem"):SureOnUse(164, 2147, 0, 0, 30, 29, 10, 31, 100, it);
	if nFlag == 1 then
		local nAllCount_BM = me.GetTask(2147, 28);
		local nAllCount_ZZ = me.GetTask(2147, 31);
		if nAllCount_BM >= SpecialEvent.tbMarchEvent_vn.nAllMiBing and nAllCount_ZZ >= SpecialEvent.tbMarchEvent_vn.nAllZongZi then
			me.AddSkillState(892, 1, 1, 24 *3600*18, 1, 0, 1);
			me.Msg("恭喜您活动食用的粽子和米饼都达到最大，获得强化优惠奖励。");
		end
		local nRate = MathRandom(1,100000);
		if nRate <= SpecialEvent.tbMarchEvent_vn.nRandom then
			me.AddWaitGetItemNum(1);
			GCExcute({"SpecialEvent.tbMarchEvent_vn:IsGetHorse", me.nId});
		end
	end
	return nFlag;
end

--米饼
local tbItem_ZZ	= Item:GetClass("mibing201103_vn");

function tbItem_ZZ:OnUse()
	if me.nLevel < 65 then
		Dialog:Say("您等级不足65级！",{"知道了"});
		return 0;
	end	
	local nFlag = Item:GetClass("randomitem"):SureOnUse(163, 2147, 0, 0, 27, 26, 5, 28, 50, it);
	if nFlag == 1 then
		local nAllCount_BM = me.GetTask(2147, 28);
		local nAllCount_ZZ = me.GetTask(2147, 31);
		if nAllCount_BM >= SpecialEvent.tbMarchEvent_vn.nAllMiBing and nAllCount_ZZ >= SpecialEvent.tbMarchEvent_vn.nAllZongZi then
			me.AddSkillState(892, 1, 1, 24 *3600*18, 1, 0, 1);
			me.Msg("恭喜您活动食用的粽子和米饼都达到最大，获得强化优惠奖励。");
		end
	end
	return nFlag;
end
