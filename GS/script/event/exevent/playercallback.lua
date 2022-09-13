-- 文件名　：playercallback.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-03-06 15:01:02
-- 描述　  ：玩家召回活动

EventManager.ExEvent = EventManager.ExEvent or {};
EventManager.ExEvent.tbPlayerCallBack = EventManager.ExEvent.tbPlayerCallBack or {};
local tbPlayerCallBack = EventManager.ExEvent.tbPlayerCallBack;

tbPlayerCallBack.DEF_PATCH 					= 0;					--批次,从0批开始,重开改批次				

tbPlayerCallBack.TASK_GROUP_OLDPLAYER 		= 2082;
tbPlayerCallBack.TASK_OLDPLAYER_HASHID 		= {9, 10, 11, 12, 13};	-- 接受常在线玩家祝福的老玩家hashID
tbPlayerCallBack.TASK_ID_GETBLESSING_COUNT 	= 14;					-- 老玩家接受祝福的次数
tbPlayerCallBack.TASK_AWARD1 				= 19;					-- 领取礼包
tbPlayerCallBack.TASK_AWARD2 				= 20;					-- 领取礼包
tbPlayerCallBack.TASK_AWARD3 				= 21;					-- 领取礼包
tbPlayerCallBack.TASK_AWARD4 				= 22;					-- 领取礼包
tbPlayerCallBack.TASK_AWARD5 				= 23;					-- 领取礼包
tbPlayerCallBack.TASK_AWARD6 				= 24;					-- 领取礼包
tbPlayerCallBack.TASK_TITLE 				= 25;					-- 给与玩家江湖前辈称号标志
tbPlayerCallBack.TASK_PATCH 				= 26;					-- 记录批次,批次不同,清空变量

tbPlayerCallBack.MAX_SENDBLESSING_COUNT 	= 5;					-- 在线玩家可以最多可以送出祝福的次数
tbPlayerCallBack.MAX_GETBLESSING_COUNT 		= 10;					-- 老玩家最多可以接受的祝福次数
tbPlayerCallBack.DEF_OLDPLAYER_ITEM 		= {18,1,114,7};			-- 老玩家奖励物品（一个有效期1个月的绑定7玄）
tbPlayerCallBack.DEF_OLDPLAYER_TITLE 		= {5,3,1,0};			-- 江湖前辈称号
tbPlayerCallBack.MAX_LEAVE_DAY				= 90;					-- 最多计算离开90天

tbPlayerCallBack.nOpen						= tbPlayerCallBack.nOpen  or 0;					-- 活动开关
tbPlayerCallBack.tbLogTime  				= {year=2009,month=2,day=20,hour=0,min=0,sec=0};	--标记时间
tbPlayerCallBack.tbLogStartTime 			= {year=2009,month=3,day=17,hour=0,min=0,sec=0};	--活动开始时间
tbPlayerCallBack.tbLogEndTime 				= {year=2009,month=3,day=20,hour=0,min=0,sec=0};	--计算离开天数的截止日期
tbPlayerCallBack.LEAGUETYPE_CALLBACK		= 6;
tbPlayerCallBack.TSKGROUP_CALLBACK			= 2082;
tbPlayerCallBack.TSKID_OLDPLAYERFLAG		= 6;	-- 标记是否是老玩家
tbPlayerCallBack.TSKID_ISRELATION			= 17;	-- 是否已经有召回关系了
tbPlayerCallBack.TSKID_RELATIONCREATETIME	= 18;	-- 创建关系的时间
tbPlayerCallBack.ITEM_AWARD1				= {
	{tbItem = {18,1,286,7}, nCount = 1, nBind = 1, nTime = 30},--7级玄晶*10
	{tbItem = {18,1,303,1}, nCount = 1, nBind = 1, nTime = 30},--黄金福袋*50
	{tbItem = {18,1,251,1}, nCount = 2, nBind = 1, nTime = 30},--秘境地图*2
	{tbItem = {18,1,299,1}, nCount = 1, nBind = 1, nTime = 30},--门派竞技高级令牌*10
	{tbItem = {18,1,304,1}, nCount = 1, nBind = 1, nTime = 30},--白虎堂高级令牌*10
	{tbItem = {18,1,300,1}, nCount = 1, nBind = 1, nTime = 30},--家族令牌（高级）*10
	{tbItem = {18,1,301,1}, nCount = 1, nBind = 1, nTime = 30},--义军令牌*20
	{tbItem = {18,1,302,1}, nCount = 1, nBind = 1, nTime = 30},--战场令牌（凤翔）*20
};

tbPlayerCallBack.DEF_DIS					= 50;

--开启开关，返回值1为开启，其他为关闭；
--IsOpen()  是否开启
--IsOpen(1) 是否是老玩家
--IsOpen(2) 是否开启并且是老玩家且在老玩家第一次上线7天内
--IsOpen(3) 是否开启并且是老玩家
--IsOpen(4) 礼官处选项的存在时间

function tbPlayerCallBack:IsOpen(pPlayer, nType)
	if EventManager.IVER_bOpenPlayerCallBack  == 0 then
		do return 0 end	-- 马来关闭老玩家回归功能
	end
	
	Setting:SetGlobalObj(pPlayer);
	local nLogNowTime  = pPlayer.GetTask(Player.COMEBACK_TSKGROUPID, Player.COMEBACK_TSKID_NOWTIME);
	local nLogLastTime = pPlayer.GetTask(Player.COMEBACK_TSKGROUPID, Player.COMEBACK_TSKID_LASTTIME);
	local nLimitTime   = os.time(self.tbLogTime);	
	local nStartTime   = os.time(self.tbLogStartTime);
	local nReturn = 0;
	if not nType then
		nReturn = self.nOpen;
	elseif nType == 1 then
		--if self.nOpen == 1 then 
			nReturn = self:CheckPlayer();
		--end
	elseif nType == 2 then
		if self.nOpen == 1 and self:CheckPlayer() == 1 then
			local nCurStartTime = nLogNowTime;
			if nLogNowTime > 0 and nLogNowTime < nStartTime then
				nCurStartTime = nStartTime;
			end
			if nCurStartTime > 0 then
				if nCurStartTime + 7 * 24 * 3600 >= GetTime() then
					nReturn = 1;
				end
			end
		end
	elseif nType == 3 then
		if self.nOpen == 1 then 
			nReturn = self:CheckPlayer();
		end	
	elseif nType == 4 then
		local nDate = tonumber(GetLocalDate("%Y%m%d"));
		if nDate >= 20090317 and nDate < 20090801 then
			nReturn = 1;
		end
	end
	
	Setting:RestoreGlobalObj();
	return nReturn;
end

--检查可参加召回活动类型接口
function tbPlayerCallBack:CheckPlayer()
	if EventManager.IVER_bOpenPlayerCallBack  == 0 then
		do return -1 end
	end
	
	if self:IsCallBackPlayer(me) == 1 then
		return 1;
	end
	return 0;
end

--获得老玩家离开天数
function tbPlayerCallBack:GetLeaveDay(pPlayer)
	if self:IsOpen(pPlayer, 1) == 0 then
		return 0;
	end
	local nLogNowTime  = pPlayer.GetTask(Player.COMEBACK_TSKGROUPID, Player.COMEBACK_TSKID_NOWTIME);
	local nLogLastTime = pPlayer.GetTask(Player.COMEBACK_TSKGROUPID, Player.COMEBACK_TSKID_LASTTIME);
	local nLimitTime   = os.time(self.tbLogTime);	
	local nStartTime   = os.time(self.tbLogStartTime);
	local nEndTime	   = os.time(self.tbLogEndTime);
	
	local nCurStartTime = nLogNowTime;
	if nLogNowTime > nEndTime then
		nCurStartTime = nEndTime;
	end
	
	if nCurStartTime < nStartTime then
		nCurStartTime = nStartTime;
	end
	local nLeaveDay = math.floor((nCurStartTime - nLogLastTime)/ (24 * 3600));
	if nLeaveDay > self.MAX_LEAVE_DAY then
		nLeaveDay = self.MAX_LEAVE_DAY;
	end
	return nLeaveDay;
end

function tbPlayerCallBack:OnDialog()
	local szMsg = "老玩家召回活动开始啦，召回老朋友，可以获得丰厚奖励，老朋友更可获得诸多优惠。";
	local tbOpt = {
			{"领取老朋友召回关系绑定金币返还", self.OnDialog_BandCoinBack, self},
			{"Ta chỉ đến xem thôi"},
		};
	if self:IsOpen(me) == 1 then
		table.insert(tbOpt, 1, {"老朋友召回关系绑定", self.OnDialog_CallBackFriend, self});
		table.insert(tbOpt, 1, {"老朋友的欢迎祝福", self.OnDialog_ZhuFu, self});
		table.insert(tbOpt, 1, {"领取重出江湖礼包", self.OnDialog_Gift, self});
	end
		
	Dialog:Say(szMsg, tbOpt);
end

--六重大礼
function tbPlayerCallBack:OnDialog_Gift()
	if self:IsOpen(me, 1) ~= 1 then
		Dialog:Say("你不是离开一段时间的老玩家，没有资格领取礼包。");
		return 0;
	end
	local szMsg = "老玩家上线六重大礼，在活动期间可获得丰厚的大礼，你要领取哪个礼包？";
	local tbOpt = {
		{"领取重出江湖礼包", self.Gift_GetAward1, self},
		{"领取开黄金福袋的机会", self.Gift_GetAward2, self},
		{"领取使用小精活气散的机会", self.Gift_GetAward3, self},
		{"领取额外祈福机会", self.Gift_GetAward4, self},
		{"领取强化费用降低20%", self.Gift_GetAward5, self},
		{"领取奇珍阁金币消费返还优惠", self.Gift_GetAward6, self},
		{"Ta chỉ xem qua thôi"},
	};
	Dialog:Say(szMsg, tbOpt);
end

--7级玄晶*10；黄金福袋*50；秘境地图*2；门派竞技高级令牌*10；白虎堂高级令牌*10；家族令牌（高级）*10；义军令牌*20；战场令牌（凤翔）*20；
function tbPlayerCallBack:Gift_GetAward1(nFlag)
	
	
	if not nFlag then
		local szMsg = "秋姨托我带给重出江湖的各位侠士们的礼包，礼包包括： 7级玄晶*10；黄金福袋*50；秘境地图*2；门派竞技高级令牌*10；白虎堂高级令牌*10；家族令牌（高级）*10；义军令牌*20；战场令牌（凤翔）*20；是否要现在领取?";
		local tbOpt = {
			{"我要现在领取礼包", self.Gift_GetAward1, self, 1},
			{"Ta chỉ đến xem thôi"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	if me.GetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD1) >= 1 then
		Dialog:Say("你已领取过了重出江湖礼包");
		return 0;
	end
	
	local nCount = 0;
	for _, tbItem in pairs(self.ITEM_AWARD1) do
		nCount = nCount + tbItem.nCount;
	end
	if me.CountFreeBagCell() < nCount then
		Dialog:Say(string.format("你的背包空间不足，需要<color=yellow>%s<color>格背包空间。", nCount));
		return 0;
	end
	for _, tbItem in pairs(self.ITEM_AWARD1) do
		for i=1, tbItem.nCount do
			local pItem = me.AddItem(unpack(tbItem.tbItem));
			if pItem then
				if tbItem.nBind then
					pItem.Bind(tbItem.nBind);
				end
				if tbItem.nTime then
					me.SetItemTimeout(pItem, tbItem.nTime*24*60, 0)
					--pItem.SetTimeOut(0, GetTime()+ tbItem.nTime*24*3600 );
					--pItem.Sync();
				end
			end
		end
	end
	me.SetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD1, 1);
	Dbg:WriteLog("tbPlayerCallBack", me.szName.."领取老玩家召回礼包：", self.TASK_AWARD1);
	Dialog:Say(string.format("成功领取了重出江湖礼包。"));
end

function tbPlayerCallBack:Gift_GetAward2(nFlag)
	if me.GetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD2) > 0 then
		Dialog:Say("你已经领取过开启福袋赠送机会了。");
		return 0;
	end
	local nCount = self:GetLeaveDay(me) * 10;
	if not nFlag then
		local szMsg = string.format("你可以获得<color=yellow>%s<color>次开启福袋的赠送机会。", nCount);
		local tbOpt = {
			{"我要现在领取", self.Gift_GetAward2, self, 1},
			{"Ta chỉ đến xem thôi"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	me.SetTask(2013,4, me.GetTask(2013,4) + nCount);
	me.SetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD2, 1)
	Dbg:WriteLog("tbPlayerCallBack", me.szName.."领取老玩家召回礼包：", self.TASK_AWARD2);	
	Dialog:Say("成功领取开启福袋赠送机会。");
end

function tbPlayerCallBack:Gift_GetAward3(nFlag)
	if me.GetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD3) > 0 then
		Dialog:Say("你已经领取过使用小精活气散的额外机会了。");
		return 0;
	end
	local nCount = self:GetLeaveDay(me) * 5;
	if not nFlag then
		local szMsg = string.format("你可以获得<color=yellow>%s<color>次使用精气散（小）和<color=yellow>%s<color>次使用活气散（小）的机会。", nCount, nCount);
		local tbOpt = {
			{"我要现在领取", self.Gift_GetAward3, self, 1},
			{"Ta chỉ đến xem thôi"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	me.SetTask(2024,20, me.GetTask(2024,20) + nCount);
	me.SetTask(2024,21, me.GetTask(2024,21) + nCount);
	me.SetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD3, 1);
	Dbg:WriteLog("tbPlayerCallBack", me.szName.."领取老玩家召回礼包：", self.TASK_AWARD3);	
	Dialog:Say("成功领取使用小精活气散的额外机会。");	
end

function tbPlayerCallBack:Gift_GetAward4(nFlag)
	if me.GetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD4) > 0 then
		Dialog:Say("你已经领取过祈福额外机会了。");
		return 0;
	end
	local nCount = self:GetLeaveDay(me) * 1;
	if not nFlag then
		local szMsg = string.format("你可以获得<color=yellow>%s<color>次祈福额外机会。", nCount);
		local tbOpt = {
			{"我要现在领取", self.Gift_GetAward4, self, 1},
			{"Ta chỉ đến xem thôi"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	Task.tbPlayerPray:AddCountByLingPai(me, nCount);
	me.SetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD4, 1);
	Dbg:WriteLog("tbPlayerCallBack", me.szName.."领取老玩家召回礼包：", self.TASK_AWARD4);		
	Dialog:Say("成功领取祈福额外机会。");		
end

function tbPlayerCallBack:Gift_GetAward5(nFlag)
	if me.GetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD5) > 0 then
		Dialog:Say("你已经领取过强化费用减少20％的祝福了。");
		return 0;
	end
	if me.GetSkillState(892) > 0 then
		Dialog:Say("你已经拥有强化费用减少20%的祝福了，不能重复领取。");	
		return 0;
	end
	if not nFlag then
		local szMsg = string.format("你可以获得强化费用减少20％的祝福。");
		local tbOpt = {
			{"我要现在领取", self.Gift_GetAward5, self, 1},
			{"Ta chỉ đến xem thôi"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local nTime = 7 * 24 * 3600;
	me.AddSkillState(892, 1, 1, nTime*18, 1, 0, 1);
	me.SetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD5, 1);
	Dbg:WriteLog("tbPlayerCallBack", me.szName.."领取老玩家召回礼包：", self.TASK_AWARD5);	
	Dialog:Say("成功领强化费用减少20%的祝福。");	
end

function tbPlayerCallBack:Gift_GetAward6(nFlag)
	if me.GetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD6) > 0 then
		Dialog:Say("你已经领取过奇珍阁金币消费满500金币送100绑金的优惠。");
		return 0;
	end
	if me.GetSkillState(1336) > 0 then
		Dialog:Say("你已经拥有奇珍阁金币消费满500金币送100绑金的优惠祝福了，不能重复领取。");	
		return 0;
	end	
	local nCount = self:GetLeaveDay(me) * 1;
	if not nFlag then
		local szMsg = string.format("你可以获得奇珍阁金币消费满500金币送100绑金的优惠祝福。", nCount);
		local tbOpt = {
			{"我要现在领取", self.Gift_GetAward6, self, 1},
			{"Ta chỉ đến xem thôi"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local nTime = 7 * 24 * 3600;
	me.AddSkillState(1336, 1, 1, nTime*18, 1, 0, 1);
	me.SetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_AWARD6, 1);
	Dbg:WriteLog("tbPlayerCallBack", me.szName.."领取老玩家召回礼包：", self.TASK_AWARD6);	
	Dialog:Say("成功领取奇珍阁金币消费满500金币送100绑金的优惠祝福。");	
end

-- 老玩家召回活动，礼官对话祝福
function tbPlayerCallBack:OnDialog_ZhuFu()
	local pPlayer = me;
	local bIsOldPlayer = self:IsOpen(pPlayer, 1);
	if (1 == bIsOldPlayer) then
		Dialog:Say("您是老玩家，不能进行祝福。在老玩家召回活动期间，只能由常在线玩家对老玩家进行祝福。");
		return 0;
	end
	local tbPlayerInfo, nCount = pPlayer.GetTeamMemberList();
	if (not tbPlayerInfo or 2 ~= nCount) then
		Dialog:Say("您不在队伍当中或者您的队伍不是两个人，请确认队伍是两个人之后再来吧。");
		return 0;
	end
	local nPlayerId = tbPlayerInfo[1].nId;
	if (nPlayerId == pPlayer.nId) then
		nPlayerId = tbPlayerInfo[2].nId;
	end
	local pOldPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	

	local bIsTeamMemOldPlayer = self:IsOpen(pOldPlayer, 1);
	if (0 == bIsTeamMemOldPlayer) then
		Dialog:Say("您的队友不是老玩家，不能领取祝福。在老玩家召回活动期间，只有老玩家才能接受常在线玩家的祝福。");
		return 0;
	end
	local nFavorLevel = pPlayer.GetFriendFavorLevel(pOldPlayer.szName);
	if (nFavorLevel < 2) then
		Dialog:Say("你们之间的亲密度不到2级，不能祝福。");
		return 0;
	end
	local nHashNameId_OldPlayer = KLib.Number2UInt(tonumber(KLib.String2Id(pOldPlayer.szName)));
	local nRUseTaskCount_OldPlayer= 0;
	local nUseTaskId_OldPlayer = 0;
	for nId, nTaskId in ipairs(self.TASK_OLDPLAYER_HASHID) do
		if tonumber(nTaskId) > 0 then
			if KLib.Number2UInt(pPlayer.GetTask(self.TASK_GROUP_OLDPLAYER, tonumber(nTaskId))) == nHashNameId_OldPlayer then
				Dialog:Say("您已经祝福过对方，请不要重复祝福一个玩家。");
				return 0;
			end
			
			if nUseTaskId_OldPlayer == 0 and KLib.Number2UInt(pPlayer.GetTask(self.TASK_GROUP_OLDPLAYER, tonumber(nTaskId))) == 0 then
				nUseTaskId_OldPlayer = tonumber(nTaskId);
				nRUseTaskCount_OldPlayer = nId;
			end
		end
	end
	
	if (nRUseTaskCount_OldPlayer == 0) then
		Dialog:Say("您已经送出<color=yellow>" .. self.MAX_SENDBLESSING_COUNT .. "<color>次祝福，不能再祝福更多的老玩家了。");
		return 0;
	end
	
	
	local nGetBlessingCount = pOldPlayer.GetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_ID_GETBLESSING_COUNT);
	if (nGetBlessingCount >= self.MAX_GETBLESSING_COUNT) then
		Dialog:Say("该老玩家已经领取过<color=yellow>" .. self.MAX_GETBLESSING_COUNT .. "<color>次祝福，不能继续接受更多的祝福了。");
		return 0;
	end
	
	
	--判断背包空间
	local nFreeCount = 1;
	if pPlayer.CountFreeBagCell() < nFreeCount then
		pPlayer.Msg(string.format("对不起，您身上的背包空间不足，需要<color=yellow>%s<color>格背包空间。", nFreeCount));
		return 0;
	end
	
	-- 常在线的玩家
	--Setting:SetGlobalObj(pPlayer);
	local pItem = pPlayer.AddItem(unpack(self.DEF_OLDPLAYER_ITEM));
	if (pItem) then
		pItem.Bind(1);
		pPlayer.SetItemTimeout(pItem, 30*24*60, 0)
		--pItem.SetTimeOut(0, (GetTime() + 3600 * 24 * 30));
		--pItem.Sync();
		EventManager:WriteLog(string.format("获得物品%s", pItem.szName), pPlayer);
	end
	pPlayer.Msg("您已经成功向玩家<color=yellow>" .. pOldPlayer.szName .. "<color>送出祝福。");
	--Setting:RestoreGlobalObj();
	
	-- 被召回老玩家
	--Setting:SetGlobalObj(pOldPlayer);
	pOldPlayer.AddSkillState(385, 7, 1, 2 * 60 * 60 * Env.GAME_FPS, 1, 0, 1);	--增加技能状态
	pOldPlayer.AddSkillState(386, 7, 1, 2 * 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	pOldPlayer.AddSkillState(387, 7, 1, 2 * 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	pOldPlayer.AddSkillState(880, 4, 1, 2 * 60 * 60 * Env.GAME_FPS, 1, 0, 1);	--幸运值880, 4级30点,，打怪经验879, 8级（110％）
	pOldPlayer.AddSkillState(879, 8, 1, 2 * 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	pOldPlayer.Msg("你收到玩家<color=yellow>" .. pPlayer.szName .. "<color>的祝福。");
	EventManager:WriteLog("获得祝福buff", pOldPlayer);
	--Setting:RestoreGlobalObj();
	
	pPlayer.SetTask(self.TASK_GROUP_OLDPLAYER, nUseTaskId_OldPlayer, nHashNameId_OldPlayer);
	pOldPlayer.SetTask(tbPlayerCallBack.TASK_GROUP_OLDPLAYER, tbPlayerCallBack.TASK_ID_GETBLESSING_COUNT, nGetBlessingCount + 1);
end

function tbPlayerCallBack:OnDialog_CallBackFriend()
	local pMe = me;
	-- 活动结束或者没开始
	if (self:IsOpen(pMe) == 0) then
		return;
	end
	
	local ok, msg, tbOpt, pFriend = self:OldPlayer_CheckOldPlayerFriend(pMe);
	if (ok == 1 and pFriend == nil) then
		return
	end

	Setting:SetGlobalObj(pMe);
	if (0 == ok) then
		Dialog:Say(msg, tbOpt);	
	elseif (ok == 1) then
		Dialog:Say("你确定和你的好友<color=green>" .. pFriend.szName .. "<color>成为召回关系吗？",
			{ 
				{"是的，我确定", self.OnDialog_SureCallBack, self, msg, tbOpt, pMe.nId, pFriend.nId},
				{"Để ta suy nghĩ lại"},
			});
	end
	Setting:RestoreGlobalObj();
end

function tbPlayerCallBack:OnDialog_SureCallBack(msg, tbOpt, nMeId, nFriendId)
	local pFriend = KPlayer.GetPlayerObjById(nFriendId);
	local pMe	= KPlayer.GetPlayerObjById(nMeId);

	if (not pFriend) then
		if (pMe) then
			pMe.Msg("对不起，与您建立召回关系的老侠客可能不在线了！");
		end
		return;
	end
	
	if (not pMe) then
		return;
	end
	
	Setting:SetGlobalObj(pFriend);
	Dialog:Say(pMe.szName .. "将要和你建立召回关系，一旦建立召回关系就不能解除，你确定吗？",
		{
			{"我确定", self.MakeCallBackRelation, self, msg, tbOpt, nMeId, nFriendId},
			{"Để ta suy nghĩ lại", self.NotMakeCallBackRelation, self, nMeId, nFriendId},	
		});
	Setting:RestoreGlobalObj();

	Setting:SetGlobalObj(pMe);
	Dialog:Say("请等待好友确定！")
	Setting:RestoreGlobalObj();
end

function tbPlayerCallBack:NotMakeCallBackRelation(nMeId, nFriendId)
	local pFriend = KPlayer.GetPlayerObjById(nFriendId);
	local pMe	= KPlayer.GetPlayerObjById(nMeId);
	if (pMe) then
		Setting:SetGlobalObj(pMe);
		Dialog:Say("您的队友不同意和你建立召回关系！");
		Setting:RestoreGlobalObj();
		return;
	end
end

function tbPlayerCallBack:MakeCallBackRelation(szMsg, tbMsgOpt, nMeId, nFriendId)
	local pFriend = KPlayer.GetPlayerObjById(nFriendId);
	local pMe	= KPlayer.GetPlayerObjById(nMeId);
	if (not pFriend) then
		if (pMe) then
			pMe.Msg("对不起，与您建立召回关系的老侠客可能不在线了！");
		end
		return;
	end
	
	if (not pMe) then
		if (pFriend) then
			pFriend.Msg("对不起，与您建立召回关系的侠客可能不在线了！");
		end
		return;
	end
	
	local ok, msg, tbOpt, pPlayer = self:OldPlayer_CheckOldPlayerFriend(pMe);
	Setting:SetGlobalObj(pMe);
	if (ok == 1 and pPlayer == nil) then
		self:WriteLog("MakeCallBackRelation", pMe.szName .. "没有找队友，不可能吧有问题");
		Setting:RestoreGlobalObj();
		return 0;
	end
	
	if (ok == 0) then
		Dialog:Say(msg, tbOpt);
		self:WriteLog("MakeCallBackRelation", pMe.szName .. "判断是否能成为召回关系失败：" .. msg);
		Setting:RestoreGlobalObj();
		return 0;
	end
	
	if (pPlayer.szName ~= pFriend.szName) then
		self:WriteLog("MakeCallBackRelation", "再次判断的时候两个召回玩家名字前后不一致 ", pPlayer.szName, pFriend.szName);
		Setting:RestoreGlobalObj();
		return 0;
	end
	local szLeagueName		= pMe.szName;
	local szLeagueMember	= pFriend.szName;
	local pLeague			= League:FindLeague(self.LEAGUETYPE_CALLBACK, szLeagueName);
	if (pLeague) then
		if (1 == League:AddMember(self.LEAGUETYPE_CALLBACK, szLeagueName, szLeagueMember)) then
			self:SetCallBackRelationFlag(pFriend, 1);
			self:SetCallBackRelationTime(pFriend, GetTime());
			Dialog:Say(szMsg, tbMsgOpt);
			pFriend.Msg("你和队友建立了召回关系");
			self:WriteLog("MakeCallBackRelation", "将玩家[" .. szLeagueMember .. "]加入玩家[" .. szLeagueName .. "]成功！！");
		else
			self:WriteLog("MakeCallBackRelation", "1", "将玩家[" .. szLeagueMember .. "]加入玩家[" .. szLeagueName .. "]不成功！！");
		end
	else
		local tbMemberList = {
				{ 
					szName = szLeagueMember,
				},
			};
		GCExcute{"League:CreateLeagueWithMember", self.LEAGUETYPE_CALLBACK, szLeagueName, tbMemberList};
		self:SetCallBackRelationFlag(pFriend, 1);
		self:SetCallBackRelationTime(pFriend, GetTime());
		Dialog:Say(szMsg, tbMsgOpt);
		pFriend.Msg("您和<color=green>" .. pMe.szName .. "<color>建立了召回关系");
		self:WriteLog("MakeCallBackRelation", "创建回归玩家战队成功 ", szLeagueName, szLeagueMember);
	end
	Setting:RestoreGlobalObj();
end

function tbPlayerCallBack:OldPlayer_CheckOldPlayerFriend(pMe)
	if pMe.nLevel < 80 then
		return 0
		, "您的等级不够，必须达到<color=red>80级<color>才可以和老侠客建立召回关系。"
		,{ {"Ta hiểu rồi Rời khỏi"} }
	end
	
	if (self:IsOpen(pMe, 1) == 1) then
		return 0
		,"你是重出江湖的侠客，不能召回其他侠客！"
		,{{"Ta hiểu rồi Rời khỏi"}}	
	end
	
	-- 这个是不正常的关系，因为可能是之前的老玩家标记变更导致这里可能会出现这样的情况
	if (self:GetCallBackRelationFlag(pMe) == 1) then
		self:WriteLog("OldPlayer_CheckOldPlayerFriend", pMe.szName .. "可能之前是老玩家并且已经有老玩家召回关系，但出于某些原因不是老玩家了，但战队标记还在");
		return 1;
	end

	local tbTeamMemberList = KTeam.GetTeamMemberList(pMe.nTeamId);                        
	local tbPlayerId = pMe.GetTeamMemberList();                                           
	if ((not tbPlayerId) or (not tbTeamMemberList) or #tbTeamMemberList ~= 2 or Lib:CountTB(tbPlayerId) ~= 2) then
		return 0
		,"哪位是要召回的侠客呢？只有与<color=red>他单独组队并在附近<color>，才能召回他。"
		,{{"Ta hiểu rồi Rời khỏi"}} 
	end
	
	--判断队友是否在附近
	local nFlag = 0;
	local pFriend = nil;
	local nMapId, nX, nY	= pMe.GetWorldPos();
	for _, pPlayer in pairs(tbPlayerId) do
		if pPlayer.nId ~= pMe.nId then
			local nPlayerMapId, nPlayerX, nPlayerY	= pPlayer.GetWorldPos();
			if (nPlayerMapId == nMapId) then
				local nDisSquare = (nX - nPlayerX)^2 + (nY - nPlayerY)^2;
				if (nDisSquare < ((self.DEF_DIS/2) * (self.DEF_DIS/2))) then
					pFriend = pPlayer;
					nFlag = 1;
				end
			end
		end
	end
	
	if (nFlag ~= 1) then
		return 0
		,"哪位是要召回的玩家呢？你的附近没有队友，不能建立召回关系。"
		,{{"Ta hiểu rồi Rời khỏi"}} 
	end

	if (self:IsOpen(pFriend, 1) == 0) then
		return 0
		,"你的好友不是重出江湖的老侠客！"
		,{{"Ta hiểu rồi Rời khỏi"}}		
	end
	
	if (pFriend.nLevel < 79) then
		return 0
		,"你的好友未到79级！"
		,{{"Ta hiểu rồi Rời khỏi"}}			
	end

	-- 表示无法召回
	if (self:CheckRelation(pFriend) ~= 0) then
		return 0
		,"你的好友已经和其他人建立关系，不能重复建立！"
		,{{"Ta hiểu rồi Rời khỏi"}}
	end
	
	--所有的条件满足，送出祝福
	return 1
	,"你的好友<color=red>"..pFriend.szName.."<color>和你建立了召回关系！"
	,{{"谢谢您（离开）"}}
	,pFriend	

end

-- 判断是否是老玩家，目前的判断的条件是看玩家变量是否是老玩家,出怀疑的老玩家外
function tbPlayerCallBack:IsCallBackPlayer(pPlayer)
	local nFlag = self:GetCallBackPlayerFlag(pPlayer);
	if (nFlag == Player.COMEBACK_YES_OLD or nFlag == Player.COMEBACK_DOUBT_OLD) then
		return 1;
	end
--	if (nFlag == Player.COMEBACK_DOUBT_OLD) then
--		if (pPlayer.GetTask(2027,19) > 0 or 
--			pPlayer.GetTask(2064,10) > 0 or 
--			pPlayer.GetTask(2064,10) > 0) then
--			return 1;
--		end	
--	end
	return 0;
end

-- 判断是否已经存在召回关系了
-- 1 返回表示被召回人已经召回过了，0表示没有召回
function tbPlayerCallBack:CheckRelation(pFriend)
	local szLeagueName	= self:GetRelationTeamName(pFriend);

	if (not szLeagueName) then
		return 0;
	end

	return 1;
end

-- 获取召回关系的战队名
function tbPlayerCallBack:GetRelationTeamName(pPlayer)
	if (self:GetCallBackRelationFlag(pPlayer) == 0) then
		return nil;
	end
	local szLeagueName	= League:GetMemberLeague(self.LEAGUETYPE_CALLBACK, pPlayer.szName);
	return szLeagueName;	
end

-- 判断一个玩家是否可以参加老友回归消费返还
function tbPlayerCallBack:CheckIsConsumeRelation(pPlayer)
	local nFlag = self:IsOpen(pPlayer, 1);
	-- 是否是老玩家
	if (0 == nFlag) then
		return 0;
	end
	
	nFlag = self:GetCallBackRelationFlag(pPlayer);
	-- 是否已经建立了老玩家关系
	if (0 == nFlag) then
		return 0;
	end

	local nNowTime		= GetTime();
	local nCreateTime	= self:GetCallBackRelationTime(pPlayer);
	local nCreateDay	= Lib:GetLocalDay(nCreateTime);
	local nNowDay		= Lib:GetLocalDay(nNowTime);
	local nDetDay		= nNowDay - nCreateDay;

	if (nDetDay < 0 or nDetDay > 90) then
		return 0;
	end
	return 1;
end

function tbPlayerCallBack:GetCallBackRelationFlag(pPlayer)
	return pPlayer.GetTask(self.TSKGROUP_CALLBACK, self.TSKID_ISRELATION);
end

function tbPlayerCallBack:GetCallBackRelationTime(pPlayer)
	return pPlayer.GetTask(self.TSKGROUP_CALLBACK, self.TSKID_RELATIONCREATETIME);
end

function tbPlayerCallBack:SetCallBackRelationTime(pPlayer, nTime)
	pPlayer.SetTask(self.TSKGROUP_CALLBACK, self.TSKID_RELATIONCREATETIME, nTime);
end

function tbPlayerCallBack:SetCallBackRelationFlag(pPlayer, nFlag)
	pPlayer.SetTask(self.TSKGROUP_CALLBACK, self.TSKID_ISRELATION, nFlag);
end

function tbPlayerCallBack:GetCallBackPlayerFlag(pPlayer)
	return pPlayer.GetTask(self.TSKGROUP_CALLBACK, self.TSKID_OLDPLAYERFLAG);
end

function tbPlayerCallBack:GetConsumeRate(pPlayer)
	if (self:CheckIsConsumeRelation(pPlayer) == 0) then
		return 0;
	end
	local nNowTime		= GetTime();
	local nCreateTime	= self:GetCallBackRelationTime(pPlayer);
	local nCreateDay	= Lib:GetLocalDay(nCreateTime);
	local nNowDay		= Lib:GetLocalDay(nNowTime);
	local nDetDay		= nNowDay - nCreateDay;
	
	if (nDetDay < 0) then
		return 0;
	elseif (nDetDay <= 30) then
		return 0.3;
	elseif (nDetDay <= 60) then
		return 0.2;
	elseif (nDetDay <= 90) then
		return 0.1;
	end
	return 0;
end


function tbPlayerCallBack:OnDialog_BandCoinBack()
	local pMe	= me;
	Setting:SetGlobalObj(pMe);
	-- 被怀疑的算吗？
	if (pMe.nLevel < 80) then
		Dialog:Say("你等级还不够80级无法领取绑金返还！");
		Setting:RestoreGlobalObj();
		return;				
	end

	local nFlag = self:IsOpen(pMe, 1);
	if (nFlag == 1) then
		Dialog:Say("你没有和重出江湖的老侠客建立召回关系！");
		Setting:RestoreGlobalObj();
		return;
	end
	
	local nConsume	= GetCallBackPlayerConsume(pMe.szName);
	if (nConsume <= 0) then
		Dialog:Say("你现在没有可以领取的绑金（你的老战友奇珍阁消费后重新登陆游戏，你才能获得返还的绑定金币）！");
		Setting:RestoreGlobalObj();
		return;		
	end
	local szMsg		= "你现在有<color=yellow>" .. nConsume .. "<color>绑定金币，你确定全部领取吗？（你的老战友奇珍阁消费后重新登陆游戏，你才能获得返还的绑定金币）";
	Dialog:Say(szMsg,
		{
			{"确定领取", self.GiveCallBackBindCoin, self, pMe},
			{"Để ta suy nghĩ lại"},	
		});
	Setting:RestoreGlobalObj();
end

function tbPlayerCallBack:GiveCallBackBindCoin(pMe)
	local nConsume	= GetCallBackPlayerConsume(pMe.szName);
	-- 这里要写log
	if (SetCallBackPlayerConsume(pMe.szName, 0) == 0) then
		self:WriteLog("扣除返还绑定金币失败");
	end
	self:WriteLog("GiveCallBackBindCoin", "玩家" .. pMe.szName .. "获得了老玩家召回绑金返还 " .. nConsume .. " 绑金");
	pMe.AddBindCoin(nConsume, Player.emKBINDCOIN_ADD_CALLBACK);
end

function tbPlayerCallBack:WriteLog(...)
	Dbg:WriteLogEx(Dbg.LOG_INFO, "tbPlayerCallBack", unpack(arg));
end

function tbPlayerCallBack:AddOldPlayerTitle()
	if self:IsOpen(me, 3) == 1 then
		if me.GetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_TITLE) == 0 then
			me.AddTitle(unpack(self.DEF_OLDPLAYER_TITLE));
			me.SetCurTitle(unpack(self.DEF_OLDPLAYER_TITLE));			
			me.SetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_TITLE, 1)
			self:CheckPatch();
		end
	end
end

function tbPlayerCallBack:CheckPatch()
	if me.GetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_PATCH) < self.DEF_PATCH then
		me.SetTask(self.TASK_GROUP_OLDPLAYER, self.TASK_PATCH, self.DEF_PATCH);
		--
		--清空需要重置的变量
		--待做,需要重开再开发.
		
	end
end

if (MODULE_GAMESERVER) then
PlayerEvent:RegisterOnLoginEvent(EventManager.ExEvent.tbPlayerCallBack.AddOldPlayerTitle, EventManager.ExEvent.tbPlayerCallBack)
end
