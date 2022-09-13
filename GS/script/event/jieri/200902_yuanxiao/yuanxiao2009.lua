--２００９元宵节
--邓志辉
--2009.02.03
--DOC：\Sword1Ex-Scheme\项目启动前期设计文档\h活动\y元宵活动\y元宵活动（2009）
--任务变量区间: group=2027	start=28	end=50


local tbYuanXiao09 = {};
SpecialEvent.YuanXiao2009 = tbYuanXiao09;

tbYuanXiao09.TIME_START = 200902060000;	--申请开启时间
tbYuanXiao09.TIME_END   = 200902200000;	--申请结束时间

tbYuanXiao09.DEF_DIS = 50;	--一屏范围之内

tbYuanXiao09.TASKGID 	= 2027
tbYuanXiao09.TASK_LIJIAORIQI_ID 	= 28
tbYuanXiao09.TASK_LIJIANGLI_LIHE 	= 29;	--礼盒
tbYuanXiao09.TASK_LIJIANGLI_HONGBAO	= 30;	--红包
tbYuanXiao09.TASK_LIJIANGLI_FUDAI	= 31;	--福袋

tbYuanXiao09.TASK_ZHUFU_TIME		= 38;
tbYuanXiao09.TASK_FRIEND_COUNT 		= 39;   --祝福次数
tbYuanXiao09.TASK_FRIEND_START 		= 40;
tbYuanXiao09.TASK_FRIEND_END 		= 49;

tbYuanXiao09.MAX_ZHUFU_COUNT		= 10;
function tbYuanXiao09:CheckState()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nNowDate >= self.TIME_START and nNowDate < self.TIME_END then
		return 1;
	end
	return 0;
end

--庆元宵玩家回馈活动
	--领取元宵好礼
	--送给好友祝福
	--了解元宵活动
	--随便看看（离开）
function tbYuanXiao09:OnDialog(entry)
	if SpecialEvent.YuanXiao2009:CheckState() == 0 then
		return
	end
	
	if (not entry) then
		entry = 1;
	end
	
	local tbOpt = {};
	tbOpt[1] = {
		{"领取元宵好礼", self.OnDialog, self, 2},
		{"获得好友的祝福 ", self.GetHaoYouZuFu, self},
		{"了解元宵活动", self.ReadMe, self},
		{"Ta chỉ xem qua Xóa bỏ"}
		};
	local nIndex = 1;
	tbOpt[2] = {};
	if (me.GetTask(self.TASKGID, self.TASK_LIJIANGLI_LIHE) == 0) then
		tbOpt[2][nIndex] = {"领取新春礼盒", self.GetYuanXiaoHaoLi, self, 1};
		nIndex = nIndex + 1;
	end
	
	if (me.GetTask(self.TASKGID, self.TASK_LIJIANGLI_HONGBAO) == 0) then
		tbOpt[2][nIndex] = {"领取新年红包", self.GetYuanXiaoHaoLi, self, 2};
		nIndex = nIndex + 1;
	end
	if (me.GetTask(self.TASKGID, self.TASK_LIJIANGLI_FUDAI) == 0) then
		tbOpt[2][nIndex] = {"领取新春大福袋", self.GetYuanXiaoHaoLi, self, 3};
		nIndex = nIndex + 1;
	end
	
	tbOpt[2][nIndex] = {"Ta chỉ xem qua (Trở lại)", self.OnDialog, self, 1};
	local szMsg = nil;
	
	if (entry == 1) then --第一层对话
		szMsg = "大家元宵快乐！今日正是辞旧迎新之际，老朽这里为大家准备了丰厚大礼以及新年的祝福，希望你们在新的一年更上一层楼！";
	elseif (entry == 2) then --第二层对话
		if (nIndex == 1) then --表示没有礼物可领了
			szMsg = "您的元宵礼物已经领完了，希望您来年更加努力奋斗。";
		else		
			szMsg = "元宵佳节，只要条件符合我就有礼物送给你。<color=yellow>下面的礼物你都可以领取一次<color>，你想领哪一个呢？";
		end
	end
	Dialog:Say(szMsg, tbOpt[entry]);
end

--领取元宵好礼
--return 1 or 0, {}
function tbYuanXiao09:CheckHaoLi(nIndex)
	--[[
	逻辑条件：
		账号充值够15元或角色江湖威望200以上；
		角色等级达69；
		背包空间足够；
	--]]
	if (me.nPrestige < 200) and (me.GetExtMonthPay() < 15) then	--江湖威望不低于200或者当月充值不低于15元 
		return 0
		, "您不满足获得礼物的条件，<color=red>需要本月充值达到15元，或者江湖威望达到200<color>就可以来领奖了。"
		,{ {"Ta hiểu rồi Rời khỏi"} }
	end
	
	if me.nLevel < 69 then
		return 0
		, "您的等级不够，<color=yellow>69级<color>以后再来您礼物吧。"
		,{ {"Ta hiểu rồi Rời khỏi"} }
	end

	--nIndex 1, 2, 3 礼盒 6、红包 0、福袋 10
	local tbRequireRoom = {6, 0, 10}
	local nRequire = tbRequireRoom[nIndex] or 10	
	if me.CountFreeBagCell() < nRequire then
		return 0
		, "领取礼物需要<color=red> "..tostring(nRequire).." <color>格背包空间，整理一下包包再来吧。"
		,{ {"Ta hiểu rồi Rời khỏi"} }		
	end
	
	return 1
	,"这是我送给您的礼物，是过去一年您作出努力的奖励，同时希望您来年更加努力奋斗。"
	,{ {"谢谢您！（离开）"} }		
end

function tbYuanXiao09:SetItemTimeOut(pItem, nTime)
	if (not pItem or not nTime or nTime < 0) then
		return
	end
	pItem.SetTimeOut(0, nTime);
	local tbTimeOut = me.GetItemAbsTimeout(pItem);		--设置绝对过期时间
	if (tbTimeOut and pItem) then
		local szTime = string.format("%02d/%02d/%02d/%02d/%02d/10", 			
				tbTimeOut[1],
				tbTimeOut[2],
				tbTimeOut[3],
				tbTimeOut[4],
				tbTimeOut[5]);
		me.SetItemTimeout(pItem, szTime);
		pItem.Sync()
	end
end

function tbYuanXiao09:GiveLiHe()
	local pItem = me.AddItem(18, 1, 251, 1);
	if pItem then
		pItem.Bind(1);
		--DONE:秘境地图的时间限制无法显示
		self:SetItemTimeOut(pItem, GetTime() + 30 * 24 * 60 * 60);		--设置绝对过期时间
		me.Msg("您获得了一个进入特殊打怪地图的道具!");
	end
	for i = 1, 5 do
		local pItem = me.AddItem(18,1,114,7);	--给予7级玄晶
		if (pItem) then
			pItem.Bind(1)
			self:SetItemTimeOut(pItem, GetTime() + 30 * 24 * 60 * 60);	--设置绝对过期时间
		end
	end
	me.SetTask(tbYuanXiao09.TASKGID, tbYuanXiao09.TASK_LIJIANGLI_LIHE, tonumber(GetLocalDate("%Y%m%d")));
	--记录log
	local szLog = "2009元宵活动:获得元宵好礼：新春礼盒--5个7级玄晶和一张秘境地图！";
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
	me.Msg("您领取了新春礼盒的奖励，获得了５个７级玄晶和一张秘境地图！");
end

function tbYuanXiao09:GiveHongBao()
	me.AddBindMoney(288000, Player.emKBINDMONEY_ADD_EVENT);
	me.AddBindCoin(2880, Player.emKBINDCOIN_ADD_EVENT);
	me.SetTask(tbYuanXiao09.TASKGID, tbYuanXiao09.TASK_LIJIANGLI_HONGBAO, tonumber(GetLocalDate("%Y%m%d")));
	me.Msg("您打开新年红包，获得了 288000 绑定银两和 2880 绑定金币！");
	--记录log
	local szLog = "2009元宵活动:获得元宵好礼：新春红包--288000绑定银两和2880绑定金币！";
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
end

function tbYuanXiao09:GiveFuDai()
	for i = 1, 10 do
		local pItem = me.AddItem(18,1,80,1);	--给予黄金福袋
		if (pItem) then
			pItem.Bind(1)
		end
	end
	--给予基准经验
	local exp = me.GetBaseAwardExp() * 588;
	me.AddExp(exp);
	me.SetTask(tbYuanXiao09.TASKGID, tbYuanXiao09.TASK_LIJIANGLI_FUDAI, tonumber(GetLocalDate("%Y%m%d")));
	me.Msg("您打开新春大福袋，获得了 10 个黄金福袋和 "..exp.." 经验值！");
	--记录log
	local szLog = "2009元宵活动:获得元宵好礼：新春大福袋--10个黄金福袋和"..exp.."经验值！";
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
end

function tbYuanXiao09:GetYuanXiaoHaoLi(nIndex)
	local ok, msg, tbOpt = self:CheckHaoLi(nIndex)	
	
	Dialog:Say(msg, tbOpt);
	
	if (ok == 1) then --条件满足，可以领取奖励，因为没有客户端点击确认后才领取奖励的过程，不需要额外的防刷判断
		--设置为今天已经领取过
		--me.SetTask(tbYuanXiao09.TASKGID, tbYuanXiao09.TASK_LIJIAORIQI_ID, tonumber(GetLocalDate("%Y%m%d")))
		if (nIndex == 1) then self:GiveLiHe() end
		if (nIndex == 2) then self:GiveHongBao() end
		if (nIndex == 3) then self:GiveFuDai() end
		--
	end
end

------------------------------------------------------------------------------------------------------------------------------------
--玩家点选“了解元宵活动”项
function tbYuanXiao09:ReadMe(entry)
	if not entry then
		entry = 1
	end

	local tbReadMeOpt = {};
	local tbOpt = tbReadMeOpt;
	tbOpt[1] = 
	{
		msg = "您想了解哪个活动呢？",
		tb =
		{ 
			{"了解“礼官元宵送好礼”活动", self.ReadMe, self, 101},
			{"了解“新春的祝福”活动", self.ReadMe, self, 102},
			{"了解“晏若雪的礼物”活动", self.ReadMe, self, 103},
			{"Ta hiểu rồi Rời khỏi"},
		}
	};
	tbOpt[101] = 
	{
		msg ="2月6日更新维护后~~2月20日0点，凡是<color=red>当月充值达到15元或者江湖威望达到200，且等级69级以上的角色<color>都可以去礼官处领取礼物。在活动期间，每个角色都可以去礼官处领取奖励——<color=yellow>新春礼盒，新年红包，新春大福袋<color>，每种可领1次。奖励丰厚不可错过。",
		tb = 
		{
			{"Ta hiểu rồi（返回上层）", self.ReadMe, self, 1},
		}
	};
	tbOpt[102] = 
	{
		msg ="2月6日更新维护后~~2月20日0点，凡是<color=red>当月充值达到15元或者江湖威望达到200，且等级69级以上的角色<color>都可以去礼官处和好友组队，获得其送出的祝福，并能获得奖励。在活动期间，<color=yellow>每个角色有10次获得亲密度3级以上的好友送出的祝福的机会，同一好友只能送出1次祝福，每天只能获得1次祝福。<color>玩家需要与送出祝福方单独组队去和礼官对话以传达祝福。",
		tb = 
		{
			{"Ta hiểu rồi（返回上层）", self.ReadMe, self, 1},
		}
	};
	tbOpt[103] = 
	{
		msg ="2月6日更新维护后~~2月20日0点，新年活动结束后，<color=red>在活动时间内飞絮崖荣誉排行榜前20名的玩家能在晏若雪处获得她送出的礼物，领奖机会仅一次。<color>到时晏若雪离开就不能拿到礼物了。",
		tb = 
		{
			{"Ta hiểu rồi（返回上层）", self.ReadMe, self, 1},
		}
	};

	Dialog:Say(tbReadMeOpt[entry].msg, tbReadMeOpt[entry].tb);
end

function tbYuanXiao09:CheckHaoYouZhuFu()
	--[[
		账号充值够15元或角色江湖威望200以上；
		角色等级达69；
		已组队且人数为2人；
		队友在队伍范围内；
		与队友亲密度达3级；
		未向队友送出过祝福；
		当天未祝福；
		祝福总次数未达10次；
		背包空间足够；
	--]]
	if (me.nPrestige < 200) and (me.GetExtMonthPay() < 15) then	--江湖威望不低于200或者当月充值不低于15元
		return 0
		, "您不满足送出祝福的条件，<color=red>需要本月充值达到15元，或者江湖威望达到200<color>就可以来送出祝福了。"
		,{ {"Ta hiểu rồi Rời khỏi"} }
	end
	
	if me.nLevel < 69 then
		return 0
		, "您的等级不够，<color=red>69级<color>以后再来祝福吧。"
		,{ {"Ta hiểu rồi Rời khỏi"} }
	end
	
	local tbTeamMemberList = KTeam.GetTeamMemberList(me.nTeamId);                        
	local tbPlayerId = me.GetTeamMemberList();                                           
	if ((not tbPlayerId) or (not tbTeamMemberList) or #tbTeamMemberList ~= 2 or Lib:CountTB(tbPlayerId) ~= 2) then
		return 0
		,"哪位是要祝福你的好友呢？只有与<color=red>要送出祝福方单独组队并让他在附近<color>，才能获得他给你的祝福。"
		,{{"Ta hiểu rồi Rời khỏi"}} 
	end
	
	--判断队友是否在附近
	local nFlag = 0;
	local pFriend = nil;
	local nMapId, nX, nY	= me.GetWorldPos();
	for _, pPlayer in pairs(tbPlayerId) do
		if pPlayer.nId ~= me.nId then
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
		,"哪位是要祝福你的好友呢？只有与<color=red>要送出祝福方单独组队并让他在附近<color>，才能获得他给你的祝福。"
		,{{"Ta hiểu rồi Rời khỏi"}} 
	end
	
	--好友，亲密度
	if (1 ~= me.IsFriendRelation(pFriend.szName) or me.GetFriendFavorLevel(pFriend.szName) < 3) then --DONE:亲密度修改为３
		return 0
		,"您与队友<color=red>不是好友或亲密度未达3级<color> "
		,{{"Ta hiểu rồi Rời khỏi"}}
	end
	
	--当天是否已经送出过祝福
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if (me.GetTask(self.TASKGID, self.TASK_ZHUFU_TIME) >= nDate) then
		return 0
		,"今天你<color=red>已经获得过祝福了<color>，明天再来吧。"
		,{{"Ta hiểu rồi Rời khỏi"}}
	end
	
	--祝福的次数是否超出self.MAX_ZHUFU_COUNT(10)次
	local nCount = me.GetTask(self.TASKGID, self.TASK_FRIEND_COUNT);
	if (nCount >= self.MAX_ZHUFU_COUNT) then
		return 0
		,"您已经<color=red>总共获得了10次祝福<color>，没有机会再获得祝福了。"
		,{{"Ta hiểu rồi Rời khỏi"}}
	end
	
	--是否对该好友送出过的祝福
	local nFriendHashId = KLib.Number2UInt(tonumber(KLib.String2Id(pFriend.szName)));
	nFlag = 0;
	for nId = self.TASK_FRIEND_START, self.TASK_FRIEND_END do 
		local nHashId = KLib.Number2UInt(me.GetTask(self.TASKGID, nId));
		if (nHashId == nFriendHashId) then
			nFlag = 1;
			break;
		end
	end
	if (nFlag == 1) then
		return 0
		,"你已经<color=red>获得过这位好友的祝福了<color>，重复祝福是没有意义的。"
		,{{"Ta hiểu rồi Rời khỏi"}}
	end
	
	if me.CountFreeBagCell() < 1 then
		return 0
		, "获得祝福需要背包空间<color=red>1格<color>背包空间，整理一下包包再来吧。"
		,{ {"Ta hiểu rồi Rời khỏi"} }		
	end
	
	--所有的条件满足，送出祝福
	return 1
	,"你获得你的好友<color=red>"..pFriend.szName.."<color>送出的新春祝福，在新的一年里，他的祝福会常伴你左右。这是你获得的祝福奖励"
	,{{"谢谢您（离开）"}}
	,pFriend
end

function tbYuanXiao09:GetHaoYouZuFu()
	local ok, msg, tbOpt, pFriend = self:CheckHaoYouZhuFu();
	if (ok == 1 and pFriend == nil) then
		return
	end
	
	Dialog:Say(msg, tbOpt);
	if (ok == 1) then
		local pItem = me.AddItem(18,1,114,7);	--给予7级玄晶
		if (pItem) then
			pItem.Bind(1);
			self:SetItemTimeOut(pItem, GetTime() + 30 * 24 * 60 * 60);	--设置绝对过期时间
			
			--增加技能状态
			me.AddSkillState(385, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
			me.AddSkillState(386, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
			me.AddSkillState(387, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
			--幸运值880, 4,，打怪经验879, 5
			me.AddSkillState(880, 4, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
			me.AddSkillState(879, 8, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);

			me.SetTask(tbYuanXiao09.TASKGID, tbYuanXiao09.TASK_ZHUFU_TIME, tonumber(GetLocalDate("%Y%m%d"))) --当天已经祝福过
			local zhufucishu = me.GetTask(tbYuanXiao09.TASKGID, tbYuanXiao09.TASK_FRIEND_COUNT);
			me.SetTask(tbYuanXiao09.TASKGID, tbYuanXiao09.TASK_FRIEND_COUNT, zhufucishu + 1);  --祝福次数加1

			--将队友标记为已祝福过			
			local nFriendHashId = tonumber(KLib.String2Id(pFriend.szName));
			for nId = self.TASK_FRIEND_START, self.TASK_FRIEND_END do 
				local nHashId = KLib.Number2UInt(me.GetTask(self.TASKGID, nId));
				if (nHashId <= 0) then
					me.SetTask(self.TASKGID, nId, nFriendHashId); --4位的无符号数字
					break;
				end
			end
			--在好友，家族及帮会频道给予提示信息
			local szMsg = string.format("<color=red>%s<color> 得到来自其好友 <color=red>%s<color> 的新春祝福，在新的一年里一定会事事顺心如意的。", me.szName, pFriend.szName);
			me.SendMsgToFriend(szMsg);
			--DONE:怎样向家族或者帮会发送消息
			szMsg = string.format("得到来自其好友 <color=red>%s<color> 的新春祝福，在新的一年里一定会事事顺心如意的。", pFriend.szName);
			Player:SendMsgToKinOrTong(me, szMsg, 1);
			--记录log
			local szLog = "2009元宵活动:获得好友"..pFriend.szName.."的新春祝福：1个7级玄晶，7级磨刀石7级护甲片7级五行石的(1个小时)，30分钟的30点幸运和1个小时的110%的打怪经验！";
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
		end
		--
	end
end


