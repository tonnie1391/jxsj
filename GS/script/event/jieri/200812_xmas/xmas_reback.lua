--圣诞充值返还
--孙多良
--2008.12.22

SpecialEvent.Xmas2008 = SpecialEvent.Xmas2008 or {};

local tbEvent = SpecialEvent.Xmas2008;

tbEvent.tbRebackState = 
{
	20081223,
	20090101,
}

function tbEvent:CheckReback()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate < self.tbRebackState[1] or nCurDate >= self.tbRebackState[2] then
		return 0;
	end
	return 1;		
end

function tbEvent:GetReback(nFlag)
	if self:CheckReback() == 0 then
		Dialog:Say("活动已经结束。");
		return 0;
	end
	local nGetFlag, nPayCoin = self:GetRebackExtPoint();
	local nRebackCoin = math.floor(nPayCoin / 50) * 1000;
	if nGetFlag == 0 and nPayCoin >= 50 then
		nRebackCoin = 15000 + (math.floor(nPayCoin / 50) - 1) * 1000;
	end
	
	if not nFlag then
		local szMsg = string.format([[
			
			您目前未领取返还的充值为：<color=yellow>%s元<color>
			可领取的绑金返还为：<color=yellow>%s绑定金币<color>
			
			活动时间：<color=yellow>2008年12月23日维护后
					  ——2009年1月1日0点<color>
			
			<color=red>注意，充值未满50元的话不能领取返还，领取返还部分的充值数额会清空，未满50元的部分会累计，活动结束后就不能领取返还了，切记。<color>
			]], nPayCoin, nRebackCoin);
		local tbOpt = {
			{"领取圣诞充值有礼活动返还", self.GetReback, self, 1},
			{"了解圣诞充值有礼活动",self.RebackAbout, self},
			{"Để ta suy nghĩ thêm吧"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	if nRebackCoin <= 0 or nPayCoin < 50 then
		Dialog:Say("您目前剩余未领取返还的<color=yellow>充值不足50元<color>，请充值后再来吧。")
		return 0;
	end
	
	if nGetFlag == 0 then
		me.AddExtPoint(2, 100000000);
	end
	me.PayExtPoint(2, math.floor(nPayCoin / 50) * 50);
	me.AddBindCoin(nRebackCoin, Player.emKBINDCOIN_ADD_XMAS_REBACK);
	Dialog:Say(string.format("成功领取了<color=yellow>%s绑定金币<color>。", nRebackCoin));
	Dbg:WriteLog("PlayerEvent.Xmas2008", "圣诞充值返还", "绑定金币", nRebackCoin);
end

--返回充值情况（第一次领取标志，剩余未领取充值）
function tbEvent:GetRebackExtPoint()
	local nPoint = me.GetExtPoint(2);
	local nGetFlag = math.floor(nPoint / 100000000);
	local nPayCoin = math.mod(nPoint , 100000000);
	return nGetFlag, nPayCoin;
end

function tbEvent:RebackAbout()
	Dialog:Say("在<color=yellow>2008年12月23日维护后——2009年1月1日0点<color>的活动期间，玩家充值<color=yellow>每达到50元<color>能在各新手村活动推广员处获得<color=yellow>20%的绑金返还<color>，在第一次充值满50元时更能获得<color=yellow>相当于150元的绑金返还<color>。\n\n<color=red>注意，充值未满50元的话不能领取返还，领取返还部分的充值数额会清空，未满50元的部分会累计，活动结束后就不能领取返还了，切记。<color>")
end
