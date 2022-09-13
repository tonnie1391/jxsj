--
-- FileName: shenghuo.lua
-- Author: lgy
-- Time: 2012/7/3 11:30
-- Comment: 2012盛夏圣火
--
SpecialEvent.tbShengXia2012 =  SpecialEvent.tbShengXia2012 or {};
local tbShengXia2012 = SpecialEvent.tbShengXia2012;

local tbItem = Item:GetClass("shengxia_shenghuo_2012");

-- 使用
function tbItem:OnUse()
	local szMsg = "2012年盛夏活动圣火，使用可获得一小时的秘境修炼时间，更有机会可以获得秘境地图一张。";
	local tbOpt = {
			{"使用",self.UseThis, self, it.dwId},
			{"Để ta suy nghĩ lại"}
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 使用圣火
function tbItem:UseThis(nItemId, nSel)
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return;
	end
	
	if me.CountFreeBagCell() < 2 then
			Dialog:Say("你的背包空间不足，请先整理出2个背包空间。");
		return;
	end
	
	local szMsg = "";
	
	if not nSel then
		local nRestTime = me.GetTask(Task.FourfoldMap.TSK_GROUP, Task.FourfoldMap.TSK_REMAIN_TIME)
		if nRestTime >= 3600 * 14 then
			szMsg = "您当前的修炼时间已满，继续使用将不会增加修炼时间，但有机会得到秘境地图，确定使用吗？";
			local tbOpt = {
				{"Xác nhận",self.UseThis, self, nItemId ,1},
				{"Để ta suy nghĩ lại"}
			};
			Dialog:Say(szMsg, tbOpt);
			return;
		end
	end
	-- 删道具
	local nRet = pItem.Delete(me);
	if nRet ~= 1 then
		Dbg:WriteLog("2012盛夏活动圣火删除失败", me.szAccount, me.szName);
		return;
	end
	--给秘境地图
	local nRand = MathRandom(1, 6);
	if nRand == 1 then
		local pItem = me.AddItemEx(18, 1, 251, 1);
		if pItem then
			pItem.Bind(1);
		end
		StatLog:WriteStatLog("stat_info", "olympic2012", "flame_get", me.nId, 1);
		me.Msg("恭喜您获得一张秘境地图!");
	else
		StatLog:WriteStatLog("stat_info", "olympic2012", "flame_get", me.nId, 0);
	end
	
	--给秘境时间
	local nRestTime = me.GetTask(Task.FourfoldMap.TSK_GROUP, Task.FourfoldMap.TSK_REMAIN_TIME)
	nRestTime = nRestTime + 3600;
	if nRestTime > 14 * 3600 then
		nRestTime = 14 * 3600;
		szMsg = "恭喜您的秘境时间已达到<color=red>14<color>小时。";
	else
		local szTime = string.format("%s小时%s分钟%s秒",Lib:TransferSecond2NormalTime(nRestTime));
		szMsg = "恭喜您获得<color=red>1<color>小时的秘境时间，您当前的修炼时间为<color=red>"..szTime.."<color>。";
	end
	me.SetTask(Task.FourfoldMap.TSK_GROUP, Task.FourfoldMap.TSK_REMAIN_TIME,nRestTime)
	me.Msg(szMsg);
end

function tbItem:InitGenInfo()
	local nTime = tonumber(os.date("%Y%m%d", GetTime() + 3600*24));
	nTime = Lib:GetDate2Time(nTime) - 1;
	it.SetTimeOut(0,nTime);	--当天有效
	return {};
end