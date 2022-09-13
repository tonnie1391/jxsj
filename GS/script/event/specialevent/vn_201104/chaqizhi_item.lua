-- 文件名　：chaqizhi_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-04-06 17:12:06
--

--旗杆
local tbQiGan = Item:GetClass("QiGan2011_vn");
SpecialEvent.tbChaQi2011 = SpecialEvent.tbChaQi2011 or {};
local tbChaQi2011 = SpecialEvent.tbChaQi2011;

function tbQiGan:OnUse()
	--time
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nData < tbChaQi2011.nStartTime or nData > tbChaQi2011.nEndTime then	--活动期间外
		Dialog:Say("不在活动期！", {"知道了"});
		return 0;
	end
	
	--level
	if me.nLevel < tbChaQi2011.nAttendMinLevel then
		Dialog:Say("您等级不足65级，是不能插旗帜的！",{"知道了"});
		return 0;
	end
	
	if me.nFaction == 0 then
		Dialog:Say("您还是先入门派吧。",{"知道了"});
		return 0;
	end
	
	local nCount = me.GetTask(tbChaQi2011.TASKGID, tbChaQi2011.TASK_COUNT_PLANT);
	local nCountAll = me.GetTask(tbChaQi2011.TASKGID, tbChaQi2011.TASK_COUNT_PLANT_ALL);
	local szMsg = string.format("你确定在此处插旗帜?\n<color=red>您今天已经插的旗帜：%s/%s\n您总共插的旗帜：%s/%s<color>", nCount, tbChaQi2011.nMaxPlant, nCountAll, tbChaQi2011.nMaxPlantAll);
	local tbOpt = {
		{"插旗", self.PlantTree, self, me, it.dwId},
	    	{"我再考虑下"},
	    };
	Dialog:Say(szMsg, tbOpt);
	return 0;
end


function tbQiGan:PlantTree(pPlayer, dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		Dialog:Say("你的旗杆有问题。");
		return;
	end
	
	local nRes, szMsg = tbChaQi2011:CanPlantTree(pPlayer);
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
			
		GeneralProcess:StartProcess("插旗中", 3 * Env.GAME_FPS, {SpecialEvent.tbChaQi2011.Plant1stTree, SpecialEvent.tbChaQi2011, pPlayer, dwItemId}, nil, tbEvent);
	 elseif szMsg then
		Dialog:Say(szMsg);
	end
end
