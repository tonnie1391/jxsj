--
-- FileName: diancangce.lua
-- Author: lgy
-- Time: 2012/7/3 11:02
-- Comment: 2012盛夏活动典藏册
--
SpecialEvent.tbShengXia2012 =  SpecialEvent.tbShengXia2012 or {};
local tbShengXia2012 = SpecialEvent.tbShengXia2012;

local tbItem = Item:GetClass("shengxia_diancangce_2012");

--获取提示
function tbItem:GetTip()
	local szTip = "";
	local nHighCount = 0;
	local nH	= 1;
	for n,szName in pairs(tbShengXia2012.AoYunName) do
		local nV = me.GetTask(tbShengXia2012.TASKGID, n) or 0;
		szName = string.format("%-10s", szName);
		if nV == 1 then			
			szTip = szTip.."<color=yellow>"..szName.."<color>";
			nHighCount = nHighCount + 1;
		else
			szTip = szTip.."<color=gray>"..szName.."<color>";
		end
		if nH == 5 then
			nH = 1;
		else
			nH = nH + 1;
		end

	end
	szTip = szTip.."\n<color=gold>("..nHighCount.."/26)<color>";
	if(nHighCount == 26) then
		szTip = szTip.."\n\n <color=red>(你已经点亮所有奥运项目。)<color>"
	else
		local left = 26 - nHighCount;
		szTip = szTip.."\n\n   (还差<color=red>"..left.."<color>个卡片,加油哦！)"
	end
	return szTip;
end

function tbItem:InitGenInfo()
	--local nNowSecond =GetTime();
	local nEndSecond =Lib:GetDate2Time(tbShengXia2012.nEndTime)
	it.SetTimeOut(0,nEndSecond);	--绝对时间
	return {};
end