-- 文件名　：bailiandan.lua
-- 创建者　：xiewen
-- 创建时间：2008-11-19 16:45:51

local tbBailiandan = Item:GetClass("bailiandan");
tbBailiandan.MAX_USE_COUNT = 200;

function tbBailiandan:OnUse()
	if me.GetBaiLianDanUseCount() >= self.MAX_USE_COUNT then
		me.Msg("该道具最多能用<color=yellow>"..self.MAX_USE_COUNT.."<color>个，您不能再用了。");
		return 0;
	end
	
	if me.nLevel < it.nReqLevel then
		me.Msg("您的等级不够"..it.nReqLevel.."级，无法使用百炼丹.");
		return 0;
	end
	
	local nAddExp = 130 * me.nLevel^2 + 2600 * me.nLevel + 9750;
	
	me.AddExp(nAddExp);
	me.AddBaiLianDanUseCount(1);
	me.Msg("您已经使用了<color=yellow>"..me.GetBaiLianDanUseCount()..
		"<color>个百炼丹，最多能用<color=yellow>"..self.MAX_USE_COUNT.."<color>个。");
	return 1;
end

function tbBailiandan:GetTip(nState)
	local nAddExp = 130 * me.nLevel^2 + 2600 * me.nLevel + 9750;
	local szTip = "使用该物品可以获得<color=yellow>"..nAddExp.."<color>经验。";
	return szTip;
end
