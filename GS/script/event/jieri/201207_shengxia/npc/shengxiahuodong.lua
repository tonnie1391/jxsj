-- FileName: shengxiahuodong.lua
-- Author: lgy
-- Time: 2012/7/3 09:23
-- Comment:活动接引人
--


SpecialEvent.tbShengXia2012 = SpecialEvent.tbShengXia2012 or {};
local tbShengXia2012 = SpecialEvent.tbShengXia2012;

local tbNpc= Npc:GetClass("2012shengxiahuodong");

function tbNpc:OnDialog()
	if tbShengXia2012:IsInTime() == 0 then
		Dialog:Say("不在盛夏活动期间。")
		return 0;
	end
	
	local szMsg =[[	
	尊敬的各位侠客：
	
	《剑侠世界》2012年盛夏活动<color=red>即日起至8月12日晚23点59分<color>火热进行！
	
	“集套卡/猜奖牌/燃圣火”三大活动燃烧一夏，<color=yellow>大于等于50级且已入门派<color>的玩家即可参加，快邀请你的朋友们一起来劲享这<color=red>20天<color>的活动吧！
	 ]]
	local tbOpt =
	{
		{"<color=yellow>领取活跃度额外奖励<color>[15/30/45点]",self.LingQuHuoYueDu,self,0},
		{"盛夏典藏集套卡，声望令牌好运来",self.JiKaGuiZe,self,0},
		{"奥运奖牌天天猜，辉煌之星耀江湖",self.JingCaiGuiZe,self},
		{"喝彩奥运燃圣火，秘境修炼送祝福",self.ShengHuoGuiZe,self},
		{"我已了解活动详情"},
	}

	Dialog:Say(szMsg,tbOpt);
	return;
end
--领取活跃度奖励
function tbNpc:LingQuHuoYueDu(nSel)
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime >= tbShengXia2012.nStartLingJiangTime then
		Dialog:Say("领取活跃度奖励已经结束。");
		return 0;
	end
	local bOk, szErrorMsg = tbShengXia2012:CommonCheck(me);
	if bOk == 0 then
		Dialog:Say(szErrorMsg);
		return;
	end
	local nActive = SpecialEvent.ActiveGift:GetActiveNum();
	local nTime1   = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGHUOYUEDU1);
	local nTime2   = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGHUOYUEDU2);
	local nTime3   = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGHUOYUEDU3);	
	if(nSel==0) then
		--判断活跃度
		local szMsg =[[	
		《剑侠世界》2012年盛夏活动<color=green>即日起至8月12日晚23点59分<color>火热进行！
		
		活动期间<color=green>大于等于50级且已入门派<color>的玩家在每日活跃度到达<color=green>15/30/45点<color>将额外获得2012盛夏活动宝物，“集套卡/猜奖牌/燃圣火”三大活动燃烧一夏，祝你活动愉快！]]
		local tbOpt =
		{
			{"<color=gray>领取15点活跃度奖励<color>",self.LingQuHuoYueDu,self,1},
			{"<color=gray>领取30点活跃度奖励<color>",self.LingQuHuoYueDu,self,2},
			{"<color=gray>领取45点活跃度奖励<color>",self.LingQuHuoYueDu,self,3},
			{"返回参加其他活动",self.OnDialog,self},
			{"我已了解活动详情"},
		}
		if	nActive >=15 and nTime1 == 0 then
			tbOpt[1][1] ="领取15点活跃度奖励";
		end
		if  nActive >=30 and nTime2 == 0 then
			tbOpt[2][1] ="领取30点活跃度奖励";
		end
		if  nActive >=45 and nTime3 == 0 then
			tbOpt[3][1] ="领取45点活跃度奖励";
		end
		Dialog:Say(szMsg,tbOpt);
	elseif nSel == 1 then
		if nActive < 15 then
			Dialog:Say("你的活跃度没有达到15点。");
			return;
		end
		if nTime1 == 1 then
			Dialog:Say("你已经领取过15点活跃度奖励");
			return;
		end		
		if me.CountFreeBagCell() < 2 then
			Dialog:Say("你的背包空间不足，请先整理出2个背包空间。");
			return;
		end
		me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGHUOYUEDU1,1);
		local tbAdd = tbShengXia2012.nShengXiaDianCangKa;
		me.AddStackItem(tbAdd[1], tbAdd[2], tbAdd[3], tbAdd[4], nil, 2);
		--记录log
		StatLog:WriteStatLog("stat_info", "olympic2012", "collation_card", me.nId, 2);
	elseif nSel == 2 then
		if nActive < 30 then
			Dialog:Say("你的活跃度没有达到30点。");
			return;
		end
		if nTime2 == 1 then
			Dialog:Say("你已经领取过30点活跃度奖励");
			return;
		end
		if me.CountFreeBagCell() < 3 then
			Dialog:Say("你的背包空间不足，请先整理出3个背包空间。");
			return;
		end
		me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGHUOYUEDU2,1);
		local tbAdd = tbShengXia2012.nShengXiaDianCangKa;
		me.AddStackItem(tbAdd[1], tbAdd[2], tbAdd[3], tbAdd[4], nil, 3);
		--记录log
		StatLog:WriteStatLog("stat_info", "olympic2012", "collation_card", me.nId, 3);
	elseif nSel == 3 then
		if nActive < 45 then
			Dialog:Say("你的活跃度没有达到45点。");
			return;
		end
		if nTime3 == 1 then
			Dialog:Say("你已经领取过45点活跃度奖励");
			return;
		end
		if me.CountFreeBagCell() < 6 then
			Dialog:Say("你的背包空间不足，请先整理出6个背包空间。");
			return;
		end
		me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGHUOYUEDU3,1);
		local tbAdd = tbShengXia2012.nShengXiaDianCangKa;
		me.AddStackItem(tbAdd[1], tbAdd[2], tbAdd[3], tbAdd[4], nil, 5);
		--记录log
		StatLog:WriteStatLog("stat_info", "olympic2012", "collation_card", me.nId, 5);
		me.AddItemEx(unpack(tbShengXia2012.nShenghuoId));
		local szCityname = GetMapNameFormId(me.nMapId);
		Player:SendMsgToKinOrTong(me,"在<color=green>"..szCityname.."<color>奥运火炬处成功领取了2012盛夏活动宝物。", 1);
	end
end

--集卡规则
function tbNpc:JiKaGuiZe(nSel, nFlag)
	if(nSel==0) then
		local szMsg =[[	
		欢迎参加<color=yellow>盛夏典藏集套卡，声望令牌好运来<color>活动！
		每人每天可最多打开10张典藏卡，打开典藏卡的同时将有机会获得<color=green>六种小游龙阁声望令牌<color>[帽子/衣服/腰带/鞋子/戒指/护身符]中的一种。
		
		活动期间成功收集<color=green>18<color>个项目以上就可领取<color=green>收集奖励<color>如下：		
		    收集满26个项目：9玄1个、经验跟宠（15天）1个
		    收集达25个项目：9玄1个、经验跟宠（7天）1个
		    收集达24个项目：9玄1个、经验跟宠（3天）1个
		    收集21-23个项目：8玄2个
		    收集18-20个项目：8玄1个
		祝你活动愉快！
		]]
		local tbOpt =
		{
			{"兑换典藏册收集奖励\n<color=yellow>（8月13日-8月15日领取）<color>",self.JiKaGuiZe,self,1},
			{"返回参加其他活动",self.OnDialog,self},
			{"我已了解活动详情"},
		}
		Dialog:Say(szMsg,tbOpt);
		return;
	elseif(nSel==1) then
		if me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGJIANG) == 1 then
			Dialog:Say("您已经领过奖了。");
			return;
		end
		
		local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
		if nNowTime < tbShengXia2012.nStartLingJiangTime then
			Dialog:Say("现在还没到领奖日期。");
			return 0;
		end
		
		if nNowTime > tbShengXia2012.nEndLingJiangTime then
			Dialog:Say("现在已过了领奖日期");
			return 0;
		end
	
		local bOk, szErrorMsg = tbShengXia2012:CommonCheck(me);
		if bOk == 0 then
			Dialog:Say(szErrorMsg);
			return;
		end
		
		local tbFind = me.FindItemInBags(unpack(tbShengXia2012.nShengXiaDianCangCe));		
		if (#tbFind == 0) then
			Dialog:Say("您身上没有盛夏典藏册。");
			return;
		end
		local nCardCount = me.GetTask(tbShengXia2012.TASKGID,tbShengXia2012.TASK_DIANLIANG);
		if nCardCount < 18 then
			Dialog:Say("您没有集齐18张卡片，最少集齐18张卡才可以领奖。");
			return;
		end
		
		local tbFinalAward = nil;
		local nFinalIndex = 0;
		for i, tb in ipairs(tbShengXia2012.tbFinalAward) do
			if nCardCount <= tb[1] then
				tbFinalAward = tb;
				nFinalIndex = i;
				break;
			end
		end
		if not tbFinalAward then
			return;
		end
		if me.CountFreeBagCell() < tbFinalAward[3] then
			Dialog:Say(string.format("Hành trang không đủ ，请先整理出%s个背包空间。", tbFinalAward[3]));
			return;
		end
		if not nFlag then
			if nCardCount < 26 then
				local szMsg =[[您没有集齐26张卡片，集齐奖励会更高哦，您确定领取？]]
				local tbOpt =
				{
					{"确定领奖",self.JiKaGuiZe,self,1,1},
					{"返回"},
				}
				Dialog:Say(szMsg,tbOpt);
				return;
			end
		end
		 --删除道具
		local nRet = me.ConsumeItemInBags2(1, unpack(tbShengXia2012.nShengXiaDianCangCe));	
		if nRet ~= 0 then
			Dbg:WriteLog("2012盛夏活动删除典藏册失败", me.szAccount, me.szName);
			return;
		end
		
		for i, tbAward in ipairs(tbFinalAward[2]) do
			me.AddStackItem(tbAward[1], tbAward[2], tbAward[3], tbAward[4], nil, tbAward[5]);
		end
		
	   	me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGJIANG, 1);
	 	  --记录log
		StatLog:WriteStatLog("stat_info", "olympic2012", "collation_book", me.nId, nCardCount, nFinalIndex);
		return;
	end
end

--竞猜规则
function tbNpc:JingCaiGuiZe(nSel, nType)
	if not nSel then
		--判断之前是否有竞猜，如果有的话是否中奖,没中奖的话清除数据
		local nMyBeiShu, nMyDay, bToday = tbShengXia2012:GetJingCaiInfo(me);
		if not nMyDay then
			Dialog:Say("您的竞猜信息异常，请稍后再试。");
			return 0;
		end
		if (bToday == 1) then
			me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAI,0);
		elseif (nMyBeiShu >=1) then
			if not tbShengXia2012.tbGlobalBuffer[nMyDay] then
				Dialog:Say("您的竞猜信息异常，请稍后再试。");
				return 0;
			end
			for i=1, nMyBeiShu do
				local nMyAnswer = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAIID[i]);
				local nRightAnswer = tbShengXia2012.tbGlobalBuffer[nMyDay][4];			
				if nMyAnswer == nRightAnswer then
					me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAI,1)
					break;
				end
			end
			--如果不是当天数据并且没中奖。设置为2
			if me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAI) == 0 then
				me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAI,2);
			end
		end
		local szMsg =[[	
		欢迎参加<color=green>奥运奖牌天天猜，辉煌之星耀江湖<color>活动！
		
		在16个比赛日中，每一次成功猜中中国队下个比赛日的<color=green>金银铜牌总数<color>，即可尊享<color=green>辉煌之星<color>的荣耀！
		
		在每个竞猜日，每个人可提交<color=yellow>一次竞猜数<color>，你还可以使用<color=yellow>2012盛夏活动·纪念卡<color>进行<color=yellow>第二次竞猜<color>。
		
		<color=red>竞猜时间：8月12日前每天10:00-16:30<color>
	 		]]
		local tbOpt =
		{
			{"<color=green>领取我的竞猜奖励<color>",self.JingCaiGuiZe,self,1},
			{"提交我的<color=yellow>第一个<color>竞猜数",self.JingCaiGuiZe,self,2,0},
			{"提交我的<color=yellow>第二个<color>竞猜数<color>",self.JingCaiGuiZe,self,2,0},
			{"查询我已提交的竞猜数",self.JingCaiGuiZe,self,4},
			{"了解<color=yellow>辉煌之星<color>",self.JingCaiGuiZe,self,3},
			{"返回参加其他活动",self.OnDialog,self},
			{"我已了解活动详情"},
		}
		local nMyBeiShu, nMyDay, bToday = tbShengXia2012:GetJingCaiInfo(me);
		local nRightorWrong = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAI);
		if nRightorWrong == 1 then
			for i=2,3 do
				tbOpt[i][1] = "<color=gray>"..tbOpt[i][1].."<color>";
				tbOpt[i][5] = 1;
			end
		elseif nRightorWrong == 0 and nMyBeiShu==1 then
				tbOpt[2][1] = "<color=gray>"..tbOpt[2][1].."<color>";
				tbOpt[2][5] = 2;
		elseif nRightorWrong == 0 and nMyBeiShu==2 then
			for i=2,3 do
				tbOpt[i][1] = "<color=gray>"..tbOpt[i][1].."<color>";
				tbOpt[i][5] = 3;
			end
		elseif (nRightorWrong == 0 and nMyBeiShu == 0) or (nRightorWrong == 2) then
				tbOpt[3][1] = "<color=gray>"..tbOpt[3][1].."<color>";
				tbOpt[3][5] = 4;
		end
		
		Dialog:Say(szMsg,tbOpt);
		return;
	elseif(nSel==1) then
		local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
		local nTimeDate = tonumber(GetLocalDate("%H%M%S"));
		if nNowTime <= tbShengXia2012.nStartJingCaiTime and nTimeDate<100000 then
			Dialog:Say("现在还没到竞猜领奖时间，请耐心等待吧");
			return 0;
		end
		local nG,nS,nB,nC = tbShengXia2012:GetJiangPai(1);
		local nYesterday = KGblTask.SCGetDbTaskInt(DBTASK_SHENGXIA_DAY);
		local szMsg ="截止目前，奥运会已经进行到了<color=red>"..nYesterday.."个比赛日<color>。中国队总共获得<color=yellow>总奖牌数为"..nC.."个，其中金牌"..nG.."个、银牌"..nS.."个、铜牌"..nB.."个<color>。\n"
		local nG,nS,nB,nC = tbShengXia2012:GetJiangPai(2);
		szMsg = szMsg.."在上一个比赛日中中国队获得的总奖牌数为<color=yellow>"..nC.."个，其中金牌"..nG.."个、银牌"..nS.."个、铜牌"..nB.."个<color>。\n\n"
		if me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAI) == 0 then
			Dialog:Say(szMsg.."您没有未领取的奖励。");
			return;
		elseif me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAI) == 2 then
			Dialog:Say(szMsg.."很遗憾，您猜错了之前的竞猜。");
			return;
		end
		--查看条件，背包信息等等
		local bOk, szErrorMsg = tbShengXia2012:CommonCheck(me);
		if bOk == 0 then
			Dialog:Say(szErrorMsg);
			return;
		end
		--标记领奖，清除数据
		if tbShengXia2012:ClearJingCai(me) == 0 then
			Dialog:Say("您的竞猜信息异常，请稍后再试。");
			return 0;
		end
		--给奖励
		
		--给特效持续时间
		local nTimeDate = Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d")));
		local nSecond = nTimeDate+ 24*3600 - GetTime();
		me.AddSkillState(2928,1,1,nSecond * Env.GAME_FPS,1,0,1);
		me.AddTitle(6,98,1,0);
		me.SetCurTitle(6,98,1,0);
		--标记特效
		me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_HUIHUANG,1);
		me.Msg("恭喜您获得<color=yellow>辉煌之星<color>荣耀。");
		Dialog:Say(szMsg.."恭喜您获得<color=yellow>辉煌之星<color>荣耀。");
		StatLog:WriteStatLog("stat_info", "olympic2012", "guess_buff", me.nId, 1);
		Player:SendMsgToKinOrTong(me,"成为今日的<color=red>辉煌之星<color>，快快邀请这位幸运儿一起<color=red>组队活动<color>分享幸福的喜悦吧！", 1);
		return;
	elseif(nSel==2) then
		local bOk, szErrorMsg = tbShengXia2012:CommonCheck(me);
		if bOk == 0 then
			Dialog:Say(szErrorMsg);
			return;
		end
		if nType == 1 then
			Dialog:Say("你已经中奖，请先领取奖励后再竞猜");
			return;
		elseif nType == 2 then
			Dialog:Say("你已经提交了第一次竞猜");
			return;
		elseif nType == 3 then
			Dialog:Say("你已经提交完两次竞猜");
			return;
		elseif nType == 4 then
			Dialog:Say("请先提交第一次竞猜。");
			return;
		end
		--是否为竞猜提交时间（10:00 -- 16:30）以及8月13日之前
		local nNowTime = tonumber(GetLocalDate("%Y%m%d%H%M"));
		if nNowTime >= tbShengXia2012.nEndJingCaiTime  then
			Dialog:Say("盛夏竞猜奖牌活动已经结束");
			return 0;
		end
		local nTimeDate = tonumber(GetLocalDate("%H%M%S"));
		if nTimeDate < 100000 or nTimeDate > 163000  then
			local szMsg ="现在不是竞猜时间。请在10点到16点30分之间竞猜。";
			Dialog:Say(szMsg)
		else 
			Dialog:AskNumber("提交您的竞猜数：", 100, self.TiJiaoJingCai, self, me.nId);
		end
		return;
	elseif(nSel==3) then
		local szMsg =[[	
		 <color=yellow>了解【辉煌之星】<color>
		
		 1、当你对某个比赛日的中国队奖牌总数竞猜成功后，可领取<color=green>辉煌之星<color>的荣耀奖励，包括特殊称号和超炫特效，持续时间截止当晚23点59分。
		 
		 2、在<color=green>辉煌之星<color>状态下组队参加活动，可让全队伍成员有额外的绑金奖励。每人每天可获得辉煌之星额外奖励的活动包括：<color=green>逍遥谷一次<color>、<color=green>军营副本一次<color>。
		 
		 3、多个<color=green>辉煌之星<color>组队在一起，奖励不会再有额外加成。
		 ]]
		Dialog:Say(szMsg);
		return;
	elseif(nSel==4) then
		local bOk, szErrorMsg = tbShengXia2012:CommonCheck(me);
		if bOk == 0 then
			Dialog:Say(szErrorMsg);
			return;
		end
		local nMyBeiShu, nMyDay, bToday, nToday = tbShengXia2012:GetJingCaiInfo(me);
		if nMyBeiShu == 0 then
			Dialog:Say("您没有提交任何竞猜数");
			return
		end
		local nRightorWrong = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAI);
		local szMsg = "";
		if nRightorWrong == 0 then
			szMsg = "您当前提交了"..nMyBeiShu.."个竞猜数。\n";
		else
			szMsg = "您之前提交了"..nMyBeiShu.."个竞猜数。\n";
		end
		for i=1, nMyBeiShu do
			local nMyAnswer = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAIID[i]);
			szMsg = szMsg.."第"..i.."次竞猜数为：<color=yellow>"..nMyAnswer.."<color>。\n";
		end
		Dialog:Say(szMsg);
		return;
	end
end
--圣火规则
function tbNpc:ShengHuoGuiZe()
		local szMsg =[[	
		欢迎参加<color=green>喝彩奥运燃圣火，秘境修炼送祝福<color>活动！		
		
		活动期间每日活动度到达<color=green>45点<color>即可领取获得<color=green>2012盛夏活动·圣火火种<color>一个，使用火种可获得<color=green>额外1小时<color>秘籍修炼时间，并有机会获得一张<color=green>秘境地图<color>。		
		
		快快邀约你的伙伴们前往秘境送出你们的圣火祝福吧！
			]]
		local tbOpt =
		{
			{"<color=yellow>开启秘境送祝福<color>", Task.FourfoldMap.OnDialog, Task.FourfoldMap},
			{"返回参加其他活动",self.OnDialog,self},
			{"我已了解活动详情"},
		}
		Dialog:Say(szMsg,tbOpt);
		return;

end
--提交竞猜数的回调
function tbNpc:TiJiaoJingCai(nPlayerId, nCount)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if (not pPlayer) then
		return;
	end	
	Setting:SetGlobalObj(pPlayer);
	--如果竞猜错误，清楚竞猜信息
	local nRightorWrong = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAI);
	if nRightorWrong == 2 then
		tbShengXia2012:ClearJingCai(me);
		me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAI,0);
	end
	--资格认定
	local nMyBeiShu, nMyDay, bToday, nToday = tbShengXia2012:GetJingCaiInfo(pPlayer);
	if not nMyDay then
			Dialog:Say("找不到玩家信息，请稍后再试。");
			Setting:RestoreGlobalObj();
			return 0;
	end
	if nMyBeiShu ==2 then
		Dialog:Say("你已经提交两次竞猜，请明天再来。");
		Setting:RestoreGlobalObj();
		return 0;
	end
	if nMyBeiShu ~=0 then
		local nMyAnswer = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAIID[1]);
		if nMyAnswer == nCount then
			Dialog:Say("您提交的"..nCount.."竞猜数，之前已经提交过了，请选择不同的竞猜数提交。");
			Setting:RestoreGlobalObj();
			return 0;
		end
	end
	if nMyBeiShu ==1 then
		-- 检查纪念卡
		local nCountJiNian = me.GetItemCountInBags(unpack(tbShengXia2012.nShengXiaJiNianKa ));
		if nCountJiNian ==0 then
			Dialog:Say("你身上没有纪念卡，不能进行第二次竞猜。");
			Setting:RestoreGlobalObj();
			return 0;
		else 
			local nRet = me.ConsumeItemInBags2(1, unpack(tbShengXia2012.nShengXiaJiNianKa));	
			if nRet ~= 0 then
				Dbg:WriteLog("2012盛夏活动删除典藏册失败", me.szAccount, me.szName);
				Setting:RestoreGlobalObj();
				return 0;
			end
		end
	end
	nMyBeiShu = nMyBeiShu + 1;
	--保存此次竞猜倍数，竞猜数，此次流水号
	if tbShengXia2012:SetJingCaiInfo(pPlayer, nMyBeiShu, nToday, nCount) == 1 then		
		Dialog:Say("您提交了第"..nMyBeiShu.."次竞猜。");
		--发公告	
		Player:SendMsgToKinOrTong(me,"在<color=green>奥运奖牌天天猜<color>活动中预测下个比赛日中国队共获得<color=red>金/银/铜奖牌总数<color>为<color=green>"..nCount.."枚<color>", 1);
		--记录log
		StatLog:WriteStatLog("stat_info", "olympic2012", "guess_join", me.nId, nMyBeiShu);
	else
		Dialog:Say("您的竞猜信息异常，请稍后再试。");
	end
	Setting:RestoreGlobalObj();
end