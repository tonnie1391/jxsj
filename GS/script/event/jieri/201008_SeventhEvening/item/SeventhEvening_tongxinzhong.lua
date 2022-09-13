-------------------------------------------------------
-- 文件名　：SeventhEvening_tongxinzhong.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-07-23 09:09:02
-- 文件描述：
-------------------------------------------------------

local tbItem = Item:GetClass("QX_tongxinzhong");
SpecialEvent.SeventhEvening = SpecialEvent.SeventhEvening or {};
local tbSeventhEvening = SpecialEvent.SeventhEvening;

function tbItem:CheckState()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate >= 20100901 then
		return 0;
	end
	return 1;
end

function tbItem:OnUse()
	
	if self:CheckState() ~= 1 then
		Dialog:Say("对不起，活动已经结束，无法再种树了。");
		return 0;
	end
	
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	if nMapId > 8 then
		Dialog:Say("只有在新手村才可以种树！");
		return 0;
	end
	
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			Dialog:Say(string.format("在这种会把<color=green>%s<color>给挡住了，还是挪个地方吧。", pNpc.szName));
			return 0;
		end
	end
	
--	if me.GetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_DAILY_TREE) == 1 then
--		Dialog:Say("对不起，今天你已经种过树了。");
--		return 0;
--	end
	
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	if not tbMemberList or nMemberCount ~= 2 then
		Dialog:Say("请男女组队前来种树");
		return 0;
	end
	
	local pTeamMate = nil;
	for _, pMember in pairs(tbMemberList) do
		if pMember.szName ~= me.szName then
			pTeamMate = pMember;
		end
	end
	
	if not pTeamMate or me.nSex == pTeamMate.nSex then
		Dialog:Say("请男女组队前来种树");
		return 0;
	end	
	
	local pNpc = KNpc.Add2(tbSeventhEvening.SHUZHONG_ID, 1, -1, nMapId, nMapX, nMapY);
	if not pNpc then
		return 0;
	end
	
	pNpc.GetTempTable("SpecialEvent").szMaleName = me.szName;
	pNpc.GetTempTable("SpecialEvent").szFemaleName = pTeamMate.szName;
	
	local szMsg = "同心种种下十分钟之内，需要同心水的浇灌，便可长成同心树苗。";
	Dialog:SendBlackBoardMsg(me, szMsg);
	Dialog:SendBlackBoardMsg(pTeamMate, szMsg);
	
--	me.SetTask(tbSeventhEvening.TASKID_GROUP, tbSeventhEvening.TASK_DAILY_TREE, 1);

	Dbg:WriteLog("SeventhEvening", "10年七夕", "种植同心树", string.format("男方角色名：%s, 女方角色名：%s", me.szName, pTeamMate.szName));
	
	Timer:Register(60 * 10 * Env.GAME_FPS, tbSeventhEvening.OnTimerDelNpc, tbSeventhEvening, pNpc.dwId);
	
	return 1;
end

function tbItem:InitGenInfo()
	-- 设定有效期限
	local nSec = Lib:GetDate2Time(20100901);
	it.SetTimeOut(0, nSec);
	return	{ };
end

-----------------------------------------------------------------------------------------------------------------------
--同心水
local tbItemEx = Item:GetClass("QX_tongxinshui");

function tbItemEx:InitGenInfo()
	-- 设定有效期限
	local nSec = Lib:GetDate2Time(20100901);
	it.SetTimeOut(0, nSec);
	return	{ };
end

