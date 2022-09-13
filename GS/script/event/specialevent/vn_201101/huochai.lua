-- 文件名  : huochai.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-12-27 16:46:53
-- 描述    : 火柴脚本

local tbItem = Item:GetClass("huochai_vn");
tbItem.tbYanHua = {18,1,1126,1};

function tbItem:OnUse()
	local nFlag = self:CheckPlayer();	
	if nFlag == 1 then
		nFlag = Item:GetClass("randomitem"):SureOnUse(148, 2143, 0, 0, 24, 25, 5, 26, 100, it);
		if nFlag == 1 then
			local nRate = MathRandom(1,10000);
			if nRate <= SpecialEvent.JanuaryEvent_vn.nRandom_YH then
				me.AddWaitGetItemNum(1);
				GCExcute({"SpecialEvent.JanuaryEvent_vn:IsGetHorse_YH", me.nId});
			end
			me.CastSkill(307, 1, -1, me.GetNpc().nIndex);
			me.ConsumeItemInBags2(1, self.tbYanHua[1], self.tbYanHua[2], self.tbYanHua[3], self.tbYanHua[4], nil, -1);
		end
	end
	return nFlag;
end

function tbItem:CheckPlayer()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate < SpecialEvent.JanuaryEvent_vn.nOpenDate or nNowDate >= SpecialEvent.JanuaryEvent_vn.nCloseDate then
		me.Msg("不在活动期，不能使用该物品。");
		return 0;
	end
	if me.nLevel < 60 then
		me.Msg("您的等级不足60级！");
		return 0;
	end
	if me.CountFreeBagCell() < 2 then
	  	me.Msg("包裹空间不足2格，请整理下！");
	  	return 0;
	end
	if Lib:CountTB(me.FindItemInBags(unpack(self.tbYanHua))) <= 0 then
		me.Msg("你包包里面没有烟花。");
		return 0;
	end 
	local nMapId = me.GetWorldPos();
	if nMapId < 22 or nMapId > 29 then
		me.Msg("只能在城市中鸣放烟花。");
		return 0;
	end
	return 1;
end
