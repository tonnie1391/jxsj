-- 文件名  : xiwangzhizhong.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2011-02-24 09:58:23
-- 描述    : 希望之种

--陈年树种
local tbSeed = Item:GetClass("wish_seed");
SpecialEvent.tbZhiShu2011 = SpecialEvent.tbZhiShu2011 or {};
local tbZhiShu2011 = SpecialEvent.tbZhiShu2011;

function tbSeed:OnUse()	
	--time
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < tbZhiShu2011.nStartTime or nData > tbZhiShu2011.nEndTime then	--活动期间外
		Dialog:Say("不在活动期！", {"知道了"});
		return 0;
	end
	--level
	if me.nLevel < tbZhiShu2011.nAttendMinLevel then
		Dialog:Say("您等级不足60级，是不能种树的！",{"知道了"});
		return 0;
	end
	if me.nFaction == 0 then
		Dialog:Say("您还是先入门派吧。",{"知道了"});
		return 0;
	end
	--task
	local nFlag = Player:CheckTask(tbZhiShu2011.TASKGID, tbZhiShu2011.TASK_DATE, "%Y%m%d", tbZhiShu2011.TASK_COUNT_PLANT, tbZhiShu2011.nMaxPlant);
	if nFlag == 0 then
		Dialog:Say("今天你已经种了足够多了，休息下吧！",{"知道了"});
		return 0;
	end
	local nCount = me.GetTask(tbZhiShu2011.TASKGID, tbZhiShu2011.TASK_COUNT_PLANT);
	local szMsg = string.format([[
		    在这充满希望的春天里，手着拉手，我们植树去！
   希望之种需要悉心呵护才能长成大树，每成功进入到下一阶段都可以选择<color=gold>摘取果实<color>或者<color=gold>继续培育<color>，选择<color=green>摘取果实则获得本阶段奖励<color>，树木将消失；成功培育出的树木越高级，获得奖励越丰厚。
   <color=red>您今天的已经播种：%s/%s<color>]], nCount, tbZhiShu2011.nMaxPlant);
	local tbOpt = {
		{"就在这种", self.PlantTree, self, me, it.dwId},
	    		{"我再考虑下"},
	    };
	Dialog:Say(szMsg, tbOpt);
	return 0;
end


function tbSeed:PlantTree(pPlayer, dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		Dialog:Say("你的种子过期了。");
		return;
	end
	
	local nRes, szMsg = tbZhiShu2011:CanPlantTree(pPlayer);
	if nRes == 1 then
		local tbEvent = 
			{
				Player.ProcessBreakEvent.emEVENT_MOVE,
				Player.ProcessBreakEvent.emEVENT_ATTACK,
				Player.ProcessBreakEvent.emEVENT_SITE,
				Player.ProcessBreakEvent.emEVENT_USEITEM,
				Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
				Player.ProcessBreakEvent.emEVENT_DROPITEM,
				Player.ProcessBreakEvent.emEVENT_SENDMAIL,
				Player.ProcessBreakEvent.emEVENT_TRADE,
				Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
				Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
				Player.ProcessBreakEvent.emEVENT_LOGOUT,
				Player.ProcessBreakEvent.emEVENT_DEATH,
			};
			
		GeneralProcess:StartProcess("植树中", 3 * Env.GAME_FPS, {SpecialEvent.tbZhiShu2011.Plant1stTree, SpecialEvent.tbZhiShu2011, pPlayer, dwItemId}, nil, tbEvent);
	 elseif szMsg then
		Dialog:Say(szMsg);
	end
end
