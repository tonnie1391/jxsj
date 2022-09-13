-- 文件名　：couplet_UnIdentify.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-28 16:03:45
-- 描  述  ：未鉴定的对联

local tbItem 	= Item:GetClass("distich");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};
tbItem.IdentifyDuration = Env.GAME_FPS * 10;		--鉴定时间

if MODULE_GAMESERVER then

function tbItem:OnUse()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < SpringFrestival.HuaDengOpenTime or nData > SpringFrestival.HuaDengCloseTime then	--活动期间外
		Dialog:Say("没有在活动期间，您还不能使用该物品！", {"知道了"});
		return;
	end	
	Dialog:Say(string.format("您要鉴定这个春联么？需要消耗精活各%s点，鉴定后您就可以知道它是属于哪个横批下了。", SpringFrestival.nGTPMkPMin_Couplet),
			{"确定鉴定", self.Identify, self, it.dwId, 0},
			{"那算了"}
			);
end

--鉴定
function tbItem:Identify(nItemId, nFlag)
	--等级判断
	if me.nLevel < SpringFrestival.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能鉴定这个玩意！",SpringFrestival.nLevel), {"知道了"});
		return;
	end
	--背包判断
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("需要1格背包空间，整理下再来！",{"知道了"});
		return;
	end
	--精活判断
	if me.dwCurGTP < SpringFrestival.nGTPMkPMin_Couplet or me.dwCurMKP < SpringFrestival.nGTPMkPMin_Couplet then
		Dialog:Say(string.format("您的精活不足，需要精活各%s点。", SpringFrestival.nGTPMkPMin_Couplet), {"知道了"});
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
	local pItem = KItem.GetObjById(nItemId)
	if pItem then		
		me.ChangeCurGatherPoint(-SpringFrestival.nGTPMkPMin_Couplet);	--减1000精力
		me.ChangeCurMakePoint(-SpringFrestival.nGTPMkPMin_Couplet);	--减1000活力
		local tbCouplet = SpringFrestival.tbCouplet_Unidentify;
		me.ConsumeItemInBags2(1, tbCouplet[1], tbCouplet[2], tbCouplet[3], tbCouplet[4], nil, -1);--删掉一个未鉴定的对联
		local  nTimes = me.GetTask(SpringFrestival.TASKID_GROUP,SpringFrestival.TASKID_IDENTIFYCOUPLET_NCOUNT) or 0;
		me.SetTask(SpringFrestival.TASKID_GROUP,SpringFrestival.TASKID_IDENTIFYCOUPLET_NCOUNT,nTimes + 1);
		local pItemEx = me.AddItem(unpack(SpringFrestival.tbCouplet_identify));--鉴定的对联
		if pItemEx then
			local nNumber = MathRandom(#SpringFrestival.tbCoupletList);
			local nPart = MathRandom(2);
			pItemEx.SetGenInfo(1, nNumber);		--甚至那副对联
			pItemEx.SetGenInfo(2, nPart);			--设置是上联还是下联
			pItemEx.Sync();
		end
		
		EventManager:WriteLog("[新年活动·鉴定对联]鉴定对联获得鉴定过的对联", me);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[新年活动·鉴定对联]鉴定对联获得鉴定过的对联");
	end
end

end

function tbItem:GetTip()
	local nTimes = me.GetTask(SpringFrestival.TASKID_GROUP,SpringFrestival.TASKID_IDENTIFYCOUPLET_NCOUNT) or 0;
	return string.format("您已经鉴定过的春联数：%s", nTimes);
end
