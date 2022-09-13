-- 文件名  : xiwangitem.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2011-03-01 09:35:24
-- 描述    : 希望之风，希望之水，希望之土

SpecialEvent.tbZhiShu2011 = SpecialEvent.tbZhiShu2011 or {};
local tbZhiShu2011 = SpecialEvent.tbZhiShu2011;
local tbItem = Item:GetClass("xiwangitem_2011")

function tbItem:InitGenInfo()
	-- 设定有效期限
	local nSec = Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d")) + 1);
	it.SetTimeOut(0, nSec);
	return	{ };
end

local tbXiWangItem = Item:GetClass("xiwangzhitu_2011")

function tbXiWangItem:OnUse()
	local szMsg = "这是能孕育出希望的种子的土壤，请放下土壤后不要离队，并确保两名队员就在附近哦。";
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < tbZhiShu2011.nStartTime or nData > tbZhiShu2011.nEndTime then	--活动期间外
		Dialog:Say("不在活动活动期！", {"知道了"});
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
	local tbOpt = {
		{"开辟希望之土", self.PlantTreeTeam, self, it.dwId},
        		{"我再考虑下"},
        };
         Dialog:Say(szMsg, tbOpt);
    	return 0;	
end

function tbXiWangItem:PlantTreeTeam(dwItemId)	
	local nFlag, szMsg =  tbZhiShu2011:CanPlantTreeTeam(me.nId);	
	if nFlag == 0 then
		Dialog:Say(szMsg);
		return 0;
	end
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
	GeneralProcess:StartProcess("培育希望种子...", 3 * Env.GAME_FPS, {tbZhiShu2011.Plant1stTreeTeam, tbZhiShu2011, me.nId, dwItemId}, nil, tbEvent);
end

function tbXiWangItem:InitGenInfo()
	-- 设定有效期限
	local nSec = Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d")) + 1);
	it.SetTimeOut(0, nSec);
	return	{ };
end
