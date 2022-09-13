if not MODULE_GAMESERVER then
	return;
end


Require("\\script\\event\\jieri\\201201_springfestival\\201201_springfestival_def.lua");

SpecialEvent.SpringFestival2012 = SpecialEvent.SpringFestival2012 or {};
local SpringFestival = SpecialEvent.SpringFestival2012;

-- 汤圆盛宴
local tbItem = Item:GetClass("dinner2012");

function tbItem:OnUse()
	if SpringFestival:IsYuanxiaoOpen() ~= 1 then
		Dialog:Say("对不起，活动已经结束。");
		return 0;
	end
	if me.nLevel < 50 then
		Dialog:Say("你还没有达到50级,不能参加此活动。");
		return 0;
	end
	local nTotalUse = me.GetTask(SpringFestival.nTaskGroupId, SpringFestival.nUseYuanxiaoTotalCountTaskId); 
	if nTotalUse >= SpringFestival.nCanUseYuanxiaoMaxTotal then
		Dialog:Say(string.format("对不起，你已经摆放完%s桌汤圆宴席，无法继续摆放了。"),SpringFestival.nCanUseYuanxiaoMaxTotal);
		return 0;
	end
	--隔天清零
	local nLastUseTime = me.GetTask(SpringFestival.nTaskGroupId, SpringFestival.nLastUseYuanxiaoTimeTaskId);
	if os.date("%Y%m%d",GetTime()) ~= os.date("%Y%m%d",nLastUseTime) then
		me.SetTask(SpringFestival.nTaskGroupId, SpringFestival.nLastUseYuanxiaoTimeTaskId,GetTime());
		me.SetTask(SpringFestival.nTaskGroupId, SpringFestival.nUseYuanxiaoCountTaskId,0);
	end
	local nUseDinner = me.GetTask(SpringFestival.nTaskGroupId, SpringFestival.nUseYuanxiaoCountTaskId); 
	if nUseDinner >= SpringFestival.nCanUseYuanxiaoMaxPerDay then
		Dialog:Say(string.format("对不起，你今天已经摆放了%s桌汤圆宴席，请明日再来吧。",SpringFestival.nCanUseYuanxiaoMaxPerDay));
		return 0;
	end
	local szMapClass = GetMapType(me.nMapId) or "";
	if szMapClass ~= "village" and szMapClass ~= "city" then
		Dialog:Say("汤圆宴席只能在城市、新手村使用。");
		return 0;
	end
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			Dialog:Say(string.format("这里会把<color=green>%s<color>给挡住了，还是挪个地方吧。", pNpc.szName));
			return 0;
		end
	end
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	local pNpc = KNpc.Add2(SpringFestival.nYuanxiaoTableId, 1, -1, nMapId, nMapX, nMapY);
	if pNpc then
		pNpc.GetTempTable("SpecialEvent").szOwner = me.szName;
		pNpc.GetTempTable("SpecialEvent").nLeft = SpringFestival.nCanEatMaxCountPerTable;
		pNpc.GetTempTable("SpecialEvent").tbQuest = {};
		pNpc.GetTempTable("SpecialEvent").nTimerId = Timer:Register(1800 * Env.GAME_FPS, self.DeleteNpc, self, pNpc.dwId);
		pNpc.szName = string.format("%s的汤圆宴席", me.szName);
		me.SetTask(SpringFestival.nTaskGroupId, SpringFestival.nUseYuanxiaoCountTaskId, nUseDinner + 1);
		me.SetTask(SpringFestival.nTaskGroupId, SpringFestival.nUseYuanxiaoTotalCountTaskId, nTotalUse + 1);
		me.Msg("您摆放了一桌汤圆宴席，赶快邀请好友及家族帮会成员前来分享吧！");
		Dialog:SendBlackBoardMsg(me,"您摆放了一桌热气腾腾的汤圆宴席，赶快邀请好友及家族帮会成员前来分享吧！");
		Player:SendMsgToKinOrTong(me,"在元宵佳节之际，亲手制作了一桌汤圆盛宴，大家快去享用吧！", 0);
		me.SendMsgToFriend(string.format("在元宵佳节之际，Hảo hữu [<color=yellow>%s<color>]亲手制作了一桌汤圆盛宴，大家快去享用吧！",me.szName));
		StatLog:WriteStatLog("stat_info","spring_2012","put_desk",me.nId,1);
		return 1;
	end
	return 0;
end

function tbItem:DeleteNpc(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
	return 0;
end
