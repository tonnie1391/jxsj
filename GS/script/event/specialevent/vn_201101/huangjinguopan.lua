-- 文件名  : huangjinguopan.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-12-28 17:15:04
-- 描述    : 黄金果盘

local tbItem = Item:GetClass("huangjinguopan_vn");

function tbItem:OnUse()	
	if me.CountFreeBagCell() < 2 then
	  	me.Msg("包裹空间不足2格，请整理下！");
	  	return 0;
	end
	
	if me.nLevel < 65 then
		me.Msg("您的等级不足65级！");
		return 0;
	end
	
	local nFlag = Item:GetClass("randomitem"):SureOnUse(151, 2143, 0, 0, 27, 28, 20, 29, 100, it);
	if nFlag == 1 then
		local nRate = MathRandom(1,100000);
		if nRate <= SpecialEvent.JanuaryEvent_vn.nRandom_GP then
			me.AddWaitGetItemNum(1);
			GCExcute({"SpecialEvent.JanuaryEvent_vn:IsGetHorse_GP", me.nId});
		end
	end
	return nFlag;
end
