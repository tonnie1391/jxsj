-- 文件名　：huadeng.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-28 18:00:18
-- 描  述  ：新年花灯

local tbNpc= Npc:GetClass("xinnian_huadeng");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};

function tbNpc:OnDialog()
	--local nData = tonumber(GetLocalDate("%Y%m%d"));
	--if nData < SpringFrestival.HuaDengOpenTime or nData > SpringFrestival.HuaDengCloseTime then	--活动期间外
	--	Dialog:Say("时机还不成熟！", {"知道了"});
	--	return;
	--end	
	local nDateEx = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_TIME) or 0;
	local nTimes = 0;
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDateEx ~= nNowDate then
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_TIME, nNowDate);
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_GUESSYCOUPLET_NCOUNT_DAILY, 0);
	else
		nTimes = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_GUESSYCOUPLET_NCOUNT_DAILY) or 0;
	end
	local nTimesEx = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_GUESSCOUPLET_NCOUNT) or 0;
	local szMsg = string.format("您今天猜对的春联数：<color=yellow>%s<color>\n您总共猜对的春联数：<color=yellow>%s<color>\n", nTimes,nTimesEx);
	
	local tbNpcTemp = him.GetTempTable("Npc");
	tbNpcTemp.tbPlayerList = tbNpcTemp.tbPlayerList or {};
	local nPart = tbNpcTemp.nPart;
	local nCount = tbNpcTemp.nCount;
	if nPart == 2 then
		szMsg = szMsg..string.format("这个花灯上写着：\n<color=yellow>下联：%s；\n横批：%s<color>\n您能对出这个花灯春联吗？前5位对出的玩家如下：", 
										SpringFrestival.tbCoupletList[nCount][nPart + 1], SpringFrestival.tbCoupletList[nCount][1]);
	else
		szMsg = szMsg..string.format("这个花灯上写着：\n<color=yellow>上联：%s；\n横批：%s<color>\n您能对出这个花灯春联吗？前5位对出的玩家如下：",
										SpringFrestival.tbCoupletList[nCount][nPart + 1], SpringFrestival.tbCoupletList[nCount][1]);		
	end
	--连接记录的前几个人的名字
	for i = 1, #tbNpcTemp.tbPlayerList do
		szMsg = szMsg.."\n<color=yellow>  "..tbNpcTemp.tbPlayerList[i].."<color>";		
	end
	Dialog:Say(szMsg,
		{
			{"贴上春联", self.PasteCouplet, self, nCount, nPart, him.dwId},
			{"Ta chỉ xem qua"}
		});
end

--贴春联
function tbNpc:PasteCouplet(nCount, nPart, nNpcId)	
	local szContent = "请放入您要贴到花灯上的春联1个";
	Dialog:OpenGift(szContent, nil, {self.OnOpenGiftOk, self, nCount, nPart, nNpcId});
end

function tbNpc:OnOpenGiftOk(nCount, nPart, nNpcId, tbItemObj)
	--背包判断
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("需要2格背包空间，整理下再来！",{"知道了"});
		return;
	end
	local nTimesEx = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_GUESSCOUPLET_NCOUNT) or 0;
	if nTimesEx >= SpringFrestival.nGuessCounple_nCount then
		Dialog:Say("您活动期间已经对上了100个春联了，机会还是留给其他人吧！", {"知道了"});
		return 0;
	end	
	--玩家当天对春联次数
	local nDateEx = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_TIME) or 0;
	local nTimes = 0;
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDateEx ~= nNowDate then
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_TIME, nNowDate);
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_GUESSYCOUPLET_NCOUNT_DAILY, 0);
	else
		nTimes = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_GUESSYCOUPLET_NCOUNT_DAILY) or 0;
	end
	if nTimes >= SpringFrestival.nGuessCounple_nCount_daily then
		Dialog:Say("您今天的猜对联的次数已经用完了，还是明天再来吧！", {"知道了"});	
		return 0;		
	end
	--物品个数判定
	if #tbItemObj ~= 1 then
		Dialog:Say("每次只能放入1个花灯春联[已鉴定]", {"知道了"});	
		return 0;
	end
	local pItem = tbItemObj[1][1];
	--物品gdpl判定
	local szKey = string.format("%s,%s,%s,%s",pItem.nGenre,pItem.nDetail,pItem.nParticular,pItem.nLevel);
	local szCoupletKey = string.format("%s,%s,%s,%s", unpack(SpringFrestival.tbCouplet_identify));   
	if szKey ~= szCoupletKey then
		Dialog:Say("您放的物品不对，请放入1个花灯春联[已鉴定]",{"知道了"});
		return 0;			
	end
	--春联是否对应
	local nCountEx = pItem.GetGenInfo(1);
	local nPartEz = pItem.GetGenInfo(2);
	if nCountEx < 1 or nPartEz < 1 or nCountEx ~= nCount or nPartEz == nPart then
		Dialog:Say("您给的这个春联与花灯上的不对应啊，再想想吧！", {"知道了"});
		return 0;			
	end
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end	
	
	pItem.Delete(me);	--删除春联
	me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_GUESSCOUPLET_NCOUNT, nTimesEx + 1);
	me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_GUESSYCOUPLET_NCOUNT_DAILY, nTimes + 1);
	--一定几率获得三种奖励中的一种
	local nRant = MathRandom(100);
	for i = 1 ,#SpringFrestival.tbCouplet do
		if nRant > SpringFrestival.tbCouplet[i][2] and nRant <= SpringFrestival.tbCouplet[i][3]  then
			local pItemEx = me.AddItem(unpack(SpringFrestival.tbCouplet[i][1]));
			--me.SetItemTimeout(pItemEx, 60*24*30, 0);
			EventManager:WriteLog(string.format("[新年活动·巧对春联]获得随机物品%s", pItemEx.szName), me);
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[新年活动·巧对春联]获得随机物品%s", pItemEx.szName));	
		end
	end	

	local tbNpcTemp = pNpc.GetTempTable("Npc");
	tbNpcTemp.tbPlayerList = tbNpcTemp.tbPlayerList or {};
	--对上的前五个人记录名字，给的物品为：花灯宝箱·福，以后给的奖励是：花灯宝箱
	if #tbNpcTemp.tbPlayerList < SpringFrestival.nGetHuaDengMaxNum then
		table.insert(tbNpcTemp.tbPlayerList, me.szName);		
		me.AddKinReputeEntry(1);	--1点江湖威望
		me.AddExp(me.GetBaseAwardExp() * 15);	--15分钟基准经验
		--1小时7级磨刀，护甲，五行buff
		me.AddSkillState(385, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
		me.AddSkillState(386, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
		me.AddSkillState(387, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
		--幸运值880, 4级30点,，打怪经验879, 6级（70％）
		me.AddSkillState(880, 4, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
		me.AddSkillState(879, 6, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);	
		--local pItemEx = me.AddItem(unpack(SpringFrestival.tbHuaDengBox_FU));
		--me.SetItemTimeout(pItemEx, 60*24*30, 0);
		--EventManager:WriteLog("[新年活动·巧对春联]获得花灯宝箱·福", me);
		--me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[新年活动·巧对春联]获得花灯宝箱·福");
		if #tbNpcTemp.tbPlayerList == SpringFrestival.nGetHuaDengMaxNum then
			SpringFrestival.AddNewHuaDeng(nNpcId);
		end
	end	
	if TimeFrame:GetState("OpenLevel150") == 1 and SpecialEvent.SpringFrestival.bPartOpen == 1 then
		me.AddItem(unpack(SpringFrestival.tbHuaDengBox)); 
	else
		me.AddItem(unpack(SpringFrestival.tbHuaDengBox_N));
	end
	--me.SetItemTimeout(pItemEx, 60*24*30, 0);
	EventManager:WriteLog("[新年活动·巧对春联]获得花灯宝箱", me);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[新年活动·巧对春联]获得花灯宝箱");	
end
