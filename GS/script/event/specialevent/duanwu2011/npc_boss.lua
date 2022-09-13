-- 文件名　：npc_boss.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-05-23 19:46:10
-- 描  述  ：

Require("\\script\\event\\specialevent\\duanwu2011\\duanwu2011_def.lua");
SpecialEvent.DuanWu2011 = SpecialEvent.DuanWu2011 or {};
local tbDuanWu2011 = SpecialEvent.DuanWu2011 or {};

local tbDuanWuNpc = Npc:GetClass("duanwu2011_boss");

function tbDuanWuNpc:OnDeath(pNpc)
	local tbNpcBoss = him.GetTempTable("Npc").tbNpcBoss;
	if not tbNpcBoss then
		return 0;
	end
	local nKinId = tbNpcBoss.nKinId;
	local nOverTime = tbNpcBoss.nOverTime;
	local cKin = KKin.GetKin(nKinId);
	local nDate = tbNpcBoss.nDate;
	if not cKin then 
		return 0;
	end
	if nOverTime - GetTime() <= 0 then
		return 0;
	end
	if not nDate or nDate ~= tonumber(GetLocalDate("%Y%m%d")) then	-- 服务器卡过天了
		return 0;
	end
	local pNpcQuYuan = KNpc.Add2(tbDuanWu2011.NPC_QUYUAN_ID, 100, -1, tbNpcBoss.nMapId, tbNpcBoss.nPosX, tbNpcBoss.nPosY);
	if not pNpcQuYuan then
		Dbg:WriteLog("duanwu2011", "add_quyuan_failure", cKin.GetName());
		return 0;
	end
	pNpcQuYuan.SetLiveTime((nOverTime - GetTime()) * Env.GAME_FPS);
	pNpcQuYuan.GetTempTable("Npc").tbNpcInfo = {};
	local tbNpcInfo = pNpcQuYuan.GetTempTable("Npc").tbNpcInfo;
	tbNpcInfo.nKinId = nKinId;
	tbNpcInfo.nDate = nDate;
	pNpcQuYuan.szName = string.format("%s的%s", cKin.GetName(), pNpcQuYuan.szName);
end

local tbNpcQuYuan = Npc:GetClass("duanwu2011_quyuanzhonghun");

-- 跟屈原忠魂对话领取奖励
function tbNpcQuYuan:OnDialog()
	local tbNpcInfo = him.GetTempTable("Npc").tbNpcInfo;
	if not tbNpcInfo then
		him.Delete();
		return 0;
	end
	if tbNpcInfo.nDate ~= tonumber(GetLocalDate("%Y%m%d")) then
		him.Delete();
		return 0;
	end
	local nOwnerKinId = tbNpcInfo.nKinId or 0;
	if nOwnerKinId == 0 then
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	if nKinId ~= nOwnerKinId then
		Dialog:Say("你是不是找错人了，我可不为你们的家族服务哦！");
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	tbDuanWu2011:CheckTodayFishRemainNum(me);
	tbNpcInfo.tbAwardList = tbNpcInfo.tbAwardList or {};
	if tbNpcInfo.tbAwardList[me.nId] or me.GetTask(tbDuanWu2011.TASK_GROUP_ID, tbDuanWu2011.TASK_GET_AWARD) ~= 0 then
		Dialog:Say("你已经领过奖。");
		return 0;
	end
	if me.GetTask(tbDuanWu2011.TASK_GROUP_ID, tbDuanWu2011.TASK_YESTODAY_FISH_NUM) < tbDuanWu2011.MIN_AWARD_FEED_TIMES then
		Dialog:Say(string.format("只有昨日喂食<color=yellow>%s次<color>的家族成员才可以领取奖励。", tbDuanWu2011.MIN_AWARD_FEED_TIMES));
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống，需要<color=yellow>1格<color>空 ô.");
		return 0;
	end
	me.SetTask(tbDuanWu2011.TASK_GROUP_ID, tbDuanWu2011.TASK_GET_AWARD, 1);
	tbNpcInfo.tbAwardList[me.nId] = 1;
	local pItem = me.AddItem(unpack(tbDuanWu2011.ITEM_ZHONGHUN_BAG_ID));
	if pItem then
		pItem.Bind(1);
		local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + tbDuanWu2011.ITEM_VALIDITY_ZHONGHUNDAI);
	    me.SetItemTimeout(pItem, szDate);
		Dialog:SendBlackBoardMsg(me, "成功获得一个端午忠魂袋");
		Dialog:Say(" 长太息以掩气兮,哀民生之多艰，亦余心之所善兮,虽九死其犹未悔。年轻人，感谢你在这特殊的节日记得我，在这特殊的节日里，感谢你的家族，感谢你，愿你和你的朋友们永远平安。");
	else
		Dbg:WriteLog("duanwu2011", "add_zhonghun_failure", me.szName);
	end
	StatLog:WriteStatLog("stat_info", "duanwujie_2011", "boss", me.nId, cKin.GetName());
end

