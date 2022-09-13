-- 文件名　：nianhua_unidentify.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-29 09:12:17
-- 描  述  ：未鉴定的年画

local tbItem 	= Item:GetClass("picture_newyear");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};
tbItem.IdentifyDuration = Env.GAME_FPS * 10;		--鉴定年画的读条时间

function tbItem:OnUse()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < SpringFrestival.VowTreeOpenTime or nData > SpringFrestival.VowTreeCloseTime then	--活动期间外
		Dialog:Say("没有在活动期间，您还不能使用该物品！", {"知道了"});
		return;
	end
	Dialog:Say(string.format("您想鉴定这个年画么？鉴定后就知道是十二生肖的哪个年画了，不过需要精活各%s点。", SpringFrestival.nGTPMkPMin_NianHua),
			{"确定鉴定", self.Identify, self, it.dwId, 0},
			{"那算了"}
			);
end

--鉴定年画
function tbItem:Identify(nItemId, nFlag)
	--等级判断
	if me.nLevel < SpringFrestival.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能鉴定这个玩意！",SpringFrestival.nLevel), {"知道了"});
		return;
	end
	--背包判断
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("需要2格背包空间，整理下再来！",{"知道了"});
		return;
	end
	--精活判断
	if me.dwCurGTP < SpringFrestival.nGTPMkPMin_NianHua or me.dwCurMKP < SpringFrestival.nGTPMkPMin_NianHua then
		Dialog:Say(string.format("您的精活不足，需要精活各%s点。", SpringFrestival.nGTPMkPMin_NianHua), {"知道了"});
		return;
	end
	--执行
	if nFlag == 1 then
		self:SuccessIdentify(nItemId);
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
		
	GeneralProcess:StartProcess("Đang giám định...", self.IdentifyDuration, {self.Identify, self,  nItemId, 1}, nil, tbEvent);
end

--读条成功
function tbItem:SuccessIdentify(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	local nNumber = MathRandom(12);
	local tbNianHua = SpringFrestival.tbNianHua_identify;
	local pItemEx = me.AddItem(tbNianHua[1], tbNianHua[2], tbNianHua[3], nNumber);
	if pItemEx then
		me.SetItemTimeout(pItemEx, 60*24*3, 0);	
		me.ChangeCurGatherPoint(-SpringFrestival.nGTPMkPMin_NianHua); 		--减500精力
		me.ChangeCurMakePoint(-SpringFrestival.nGTPMkPMin_NianHua);		--减500活力		
		local tbCouplet = SpringFrestival.tbNianHua_Unidentify;
		me.ConsumeItemInBags2(1, tbCouplet[1], tbCouplet[2], tbCouplet[3], tbCouplet[4], nil, -1);--删掉一个未鉴定的春联
	
		EventManager:WriteLog("[新年活动·鉴定年画]鉴定年画获得鉴定过的年画", me);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[新年活动·鉴定年画]鉴定年画获得鉴定过的年画");
		
		--一定几率获得三种奖励中的一种
		local nRant = MathRandom(100);
		for i = 1 ,#SpringFrestival.tbNianHua do
			if nRant > SpringFrestival.tbNianHua[i][2] and nRant <= SpringFrestival.tbNianHua[i][3]  then
				local pItem_EX = me.AddItem(unpack(SpringFrestival.tbNianHua[i][1]));
				EventManager:WriteLog(string.format("[新年活动·鉴定年画]获得随机物品:%s", pItem_EX.szName), me);
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[新年活动·鉴定年画]获得随机物品:%s", pItem_EX.szName));
			end
		end	
	end
end
