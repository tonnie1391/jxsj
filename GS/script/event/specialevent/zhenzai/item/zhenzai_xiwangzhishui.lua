-- 文件名　：zhenzai_xiwangzhishui.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-15 17:58:38
-- 描  述  ：希望之水(许愿的必需品)

local tbItem 	= Item:GetClass("zhenzai_wish");
SpecialEvent.ZhenZai = SpecialEvent.ZhenZai or {};
local ZhenZai = SpecialEvent.ZhenZai or {};
tbItem.nTransferTime =  Env.GAME_FPS * 5;		--传送时间

function tbItem:OnUse()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < ZhenZai.VowTreeOpenTime or nData > ZhenZai.VowTreeCloseTime then	--活动期间外
		Dialog:Say("现在还不能使用，还是把这希望之水留着为灾区送上一份自己的心意吧！", {"知道了"});
		return;
	end
	if me.nLevel < ZhenZai.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能使用这个道具！", ZhenZai.nLevel),{"知道了"});
		return;
	end	
	Dialog:Say("拿着这滴希望之水，可以到临安府的平安佛处为灾区人民祈愿，今天您为灾区的人民送上祝福了吗？",
			{"查询目前平安佛上的愿望数", self.View, self},
			{"传送到平安佛处", self.Transfer, self, 0},
			{"Để ta suy nghĩ thêm"}
			);
end

--查看许愿树上的愿望个数
function tbItem:View()
	local nCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_ZHENZAI_VOWNUM);
	Dialog:Say(string.format("当前平安佛上的愿望个数为：<color=yellow>%s<color>", nCount),{"知道了"});
end

--传送
function tbItem:Transfer(nFlag)
	--只让在(city、faction、village、fight)地图传送
	local nPlayerMapId, nPosX, nPosY = me.GetWorldPos();	
	local szMapType = GetMapType(nPlayerMapId);
	if not ZhenZai.tbTransferCondition[szMapType] then
		me.Msg("此处不能使用该物品传送！")
		return;
	end
	
	if nFlag == 1 then
		self:TransferEx();
		return;
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
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
		
	GeneralProcess:StartProcess("传送", self.nTransferTime, {self.Transfer, self, 1}, nil, tbEvent);
end

--读条成功newworld
function tbItem:TransferEx()
	me.NewWorld(unpack(ZhenZai.tbVowTreePosition));
end

function tbItem:InitGenInfo()
	-- 设定有效期限
	local nSec = Lib:GetDate2Time(ZhenZai.nOutTime)
	it.SetTimeOut(0, nSec);
	return	{ };
end
