-- 文件名　：kinplant_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-10-12 17:23:39
-- 功能    ：道具相关

SpecialEvent.tbKinPlant_2011 = SpecialEvent.tbKinPlant_2011 or {};
local tbKinPlant_2011 = SpecialEvent.tbKinPlant_2011;
local tbSeed = Item:GetClass("xingyunzhizhong");

function tbSeed:OnUse()
	--time
	if tbKinPlant_2011:GetState() == 0 then
		Dialog:Say("不在活动期。",{"知道了"});
		return 0;
	end
	--level
	if me.nLevel < 60 then
		Dialog:Say("您等级不足60级，是不能种树的！",{"知道了"});
		return 0;
	end
	if me.nFaction == 0 then
		Dialog:Say("您还是先入门派吧。",{"知道了"});
		return 0;
	end	
	local tbOpt = {
		{"就在这种", self.PlantTree, self, me, it.dwId},
	    	{"我再考虑下"},
	    };
	Dialog:Say("喜迎国庆，欢乐家园植树节。这是粒幸运的种子，您是不是要种植呢？", tbOpt);
	return 0;
end

function tbSeed:PlantTree(pPlayer, dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		Dialog:Say("你的种子过期了。");
		return;
	end
	
	local nRes, szMsg = tbKinPlant_2011:CanPlantTree(pPlayer);
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
			
		GeneralProcess:StartProcess("植树中", 3 * Env.GAME_FPS, {SpecialEvent.tbKinPlant_2011.Plant1stTree, SpecialEvent.tbKinPlant_2011, pPlayer, dwItemId}, nil, tbEvent);
	 elseif szMsg then
		Dialog:Say(szMsg);
	end
end

local tbWater = Item:GetClass("xingyunzhishui");

function tbWater:GetTip()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCount = me.GetTask(2176, 102);
	local nDate = me.GetTask(2176, 101);
	if nNowDate ~= nDate then
		nCount = 0;
	end
	local szColor = "green";
	if nCount >= 20 then
		szColor = "gray";
	end
	return string.format("可浇水次数：<color=%s>%s/20<color>", szColor, nCount);
end
