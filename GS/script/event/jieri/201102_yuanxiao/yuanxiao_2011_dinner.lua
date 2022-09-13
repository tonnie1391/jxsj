-------------------------------------------------------
-- 文件名　：yuanxiao_2011_dinner.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-01-06 17:27:15
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201102_yuanxiao\\yuanxiao_2011_def.lua");

-- 汤圆盛宴
local tbItem = Item:GetClass("dinner2011");
local tbYuanxiao_2011 = SpecialEvent.Yuanxiao_2011;

function tbItem:OnUse()
	
	if tbYuanxiao_2011:CheckIsOpen() ~= 1 then
		Dialog:Say("对不起，活动已经结束。");
		return 0;
	end
	
	if me.nLevel < 60 then
		Dialog:Say("你还没有达到60级哟。");
		return 0;
	end
	
	if me.nFaction <= 0 then
		Dialog:Say("你还没加入门派哟。");
		return 0;
	end
	
	local nTotalUse = me.GetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_TOTAL_USE); 
	if nTotalUse >= tbYuanxiao_2011.MAX_TOTAL_USE then
		Dialog:Say("对不起，你已经摆放完30桌，无法继续摆放了。");
		return 0;
	end
	
	local nUseDinner = me.GetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_USE_DINNER); 
	if nUseDinner >= tbYuanxiao_2011.MAX_USE_DINNER then
		Dialog:Say("对不起，你今天已经摆放了三桌汤圆盛宴，请明日再来吧。");
		return 0;
	end
	
	local szMapClass = GetMapType(me.nMapId) or "";
	if szMapClass ~= "village" and szMapClass ~= "city" then
		Dialog:Say("汤圆盛宴只能在城市、新手村使用。");
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
	local pNpc = KNpc.Add2(tbYuanxiao_2011.NPC_TABLE_ID, 1, -1, nMapId, nMapX, nMapY);
	if pNpc then
		
		pNpc.GetTempTable("SpecialEvent").szOwner = me.szName;
		pNpc.GetTempTable("SpecialEvent").nLeft = tbYuanxiao_2011.MAX_DINNER_FOOD;
		pNpc.GetTempTable("SpecialEvent").tbQuest = {};
		pNpc.GetTempTable("SpecialEvent").nTimerId = Timer:Register(1800 * Env.GAME_FPS, self.DeleteNpc, self, pNpc.dwId);
		pNpc.szName = string.format("%s的汤圆盛宴", me.szName);
		
		me.SetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_USE_DINNER, nUseDinner + 1);
		me.SetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_TOTAL_USE, nTotalUse + 1);
		
		me.Msg("您摆放了一桌汤圆宴席，赶快邀请好友及家族帮会成员前来分享吧！");
		Dialog:SendBlackBoardMsg(me, "您摆放了一桌汤圆宴席，赶快邀请好友及家族帮会成员前来分享吧！");
		Player:SendMsgToKinOrTong(me, "摆放了一桌<汤圆宴席>，大家快去享用！", 0);
		
		Dbg:WriteLog("yuanxiao_2011", "2011元宵节", me.szAccount, me.szName, "摆放汤圆盛宴");
		StatLog:WriteStatLog("stat_info", "chunjie2011", "yuanxiao", me.nId, "使用汤圆盛宴");
		
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
