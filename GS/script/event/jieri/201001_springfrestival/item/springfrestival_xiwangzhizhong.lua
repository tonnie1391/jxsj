-- 文件名　：xiwangzhizhong.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-29 10:37:37
-- 描  述  ：希望之种(许愿的必需品)

local tbItem 	= Item:GetClass("gift_wish");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};
tbItem.nTransferTime =  Env.GAME_FPS * 2;		--传送时间

function tbItem:OnUse()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < SpringFrestival.VowTreeOpenTime or nData > SpringFrestival.VowTreeCloseTime then	--活动期间外
		Dialog:Say("没有在活动期间，您还不能使用该物品！", {"知道了"});
		return;
	end
	if me.nLevel < SpringFrestival.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能使用这个道具！", SpringFrestival.nLevel),{"知道了"});
		return;
	end	
	Dialog:Say("拿着这颗希望的种子，可以到永乐镇的许愿树上许下新年的愿望，今天您许愿了吗？",
			{"查询目前许愿树上的愿望数", self.View, self},
			{"传送到许愿树处", self.Transfer, self, 0},
			{"Để ta suy nghĩ thêm"}
			);
end

--查看许愿树上的愿望个数
function tbItem:View()
	local nCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_SPRINGFRESTIVAL_VOWNUM);
	Dialog:Say(string.format("当前许愿树上的愿望个数为：<color=yellow>%s<color>", nCount),{"知道了"});
end

--传送
function tbItem:Transfer(nFlag)
	--只让在(city、faction、village、fight)地图传送
	local nPlayerMapId, nPosX, nPosY = me.GetWorldPos();	
	local szMapType = GetMapType(nPlayerMapId);
	if not SpringFrestival.tbTransferCondition[szMapType] then
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
	me.NewWorld(unpack(SpringFrestival.tbVowTreePosition));
end

function tbItem:InitGenInfo()
	-- 设定有效期限
	local nSec = Lib:GetDate2Time(SpringFrestival.nOutTime)
	it.SetTimeOut(0, nSec);
	return	{ };
end
