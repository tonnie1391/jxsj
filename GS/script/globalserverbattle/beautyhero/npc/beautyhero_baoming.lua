-- 文件名  : beautyhero_baoming.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-30 09:22:14
-- 描述    : 

local tbNpc = Npc:GetClass("beautyhero_baoming");

function tbNpc:OnDialog()
	local nMapId  = him.GetWorldPos();
	local tbMissionInfo = BeautyHero:GetMissionInfo(nMapId);
	if not tbMissionInfo then
		Dialog:Say("欢迎来到巾帼英雄赛比赛场。",
			{
				{"我要离开赛场", BeautyHero.LeaveMap, BeautyHero,nMapId},
				{"Để ta suy nghĩ lại"}
			}
		);
		return 0;
	end
	
	local nCount = tbMissionInfo:GetAttendPlayerCount();
	local tbOpt = 
	{
			{"我要报名参加巾帼英雄赛", BeautyHero.SignUp, BeautyHero,nMapId},
			{"我要离开比赛场", BeautyHero.LeaveMap, BeautyHero,nMapId},
			{"Để ta suy nghĩ lại"}
	}

	local szMsg = "欢迎来到巾帼英雄赛比赛场。";

	if tbMissionInfo.nState == BeautyHero.SIGN_UP then
		table.insert(tbOpt, 2, {"我要取消报名", BeautyHero.CancelSignUp, BeautyHero, nMapId});
		szMsg = szMsg..(string.format("当前已报名参赛人数为%d人。",nCount));
	end
	
	if not GLOBAL_AGENT then
		szMsg = szMsg..(string.format("本周参加次数：<color=yellow>%d<color>/2）",BeautyHero:GetAttendTimes(me)));
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function BeautyHero:SignUp(nMapId)
	if me.nMapId ~= nMapId then
		return 0;
	end
	
	local tbMissionInfo = self:GetMissionInfo(nMapId);
	if not tbMissionInfo then
		Dialog:Say("现在没有巾帼英雄赛！");
		return 0;
	end
	
	if tbMissionInfo.nState > self.SIGN_UP then
		Dialog:Say("巾帼英雄赛已在20：00开始了，现在不再接受报名，请在场内参加其他活动吧。");
--	if tbMissionInfo.nState >= self.CHAMPION_AWARD then
--		Dialog:Say("巾帼英雄赛已经结束了，不能接受报名。");
		return 0;
	end
	
	if me.nSex ~= 1 then
		Dialog:Say("只有女玩家才可以参加，如果您执意参加我可以送你一本最新版的葵花宝典。");
		return 0;
	end

	if tbMissionInfo.nType == self.emMATCHTYPE_SERIES and  me.nSeries ~= tbMissionInfo.nSeries then
		Dialog:Say("您的五行弄错了，请去与您五行相符的赛场参加比赛吧！");
		return 0;
	end
	
	if me.nLevel < self.MIN_LEVEL then
		Dialog:Say("你学艺不精，等级不足"..self.MIN_LEVEL.."级，不能参加比赛，但可参加场内组织的其他活动");
		return 0;
	end

	if tbMissionInfo:GetAttendPlayerCount() >= self.MAX_ATTEND_PLAYER then
		Dialog:Say("报名人数已达到400人上限，不能再报名了，请在场内参加其他活动吧");
		return;
	end
	
	-- 全局服和本地服不一样的条件
	if not GLOBAL_AGENT then
		local tbGirl = SpecialEvent.Girl_Vote_New;	
		if tbGirl:IsHaveGirl(me.szName) ~= 1 then
			Dialog:Say("需要参加过美女海选的才能报名巾帼英雄PK赛");
			return;
		end
		local nAttendTimes = BeautyHero:GetAttendTimes(me);
		if nAttendTimes >= self.MAX_MATCHTIMES then				
			Dialog:Say(string.format("一周只能参加%d次巾帼英雄赛！",self.MAX_MATCHTIMES));
			return;
		end	
		
	else	
		
		if me.GetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_GLOBAL_MATCHTYPE) ~= 1 then
			Dialog:Say("只有各服前10的巾帼英雄才能报名参加本次跨服比赛!");
			return;
		end		
	end

	if tbMissionInfo:FindAttendPlayer(me.nId) == 1 then
		Dialog:Say("你已经报过名了 不能重复报名");
		return;
	end		
		

	local nRet = tbMissionInfo:JoinPlayer(me,1);

	Dialog:Say("您已成功报名，祝您好运。请在外场等待比赛开始，切勿离开，否则会失去比赛资格！<color=yellow>巾帼英雄赛将在20：00正式开始");
end


-- 离开门派竞技场对话
function BeautyHero:LeaveMap(nMapId,bConfirm)	
	if me.nMapId ~= nMapId then
		return 0;
	end

	if bConfirm == 1 then
		Dbg:WriteLog("BeautyHeroPK", "LeaveMap",me.szName); -- 加LOG
		me.SetLogoutRV(0);	
		if GLOBAL_AGENT then
			Transfer:NewWorld2GlobalMap(me);
		else
			FightAfter:Fly2City(me);
		end
		return 0;
	end
	
	local szMsg = "你确定要离开比赛场吗？离开的话将失去比赛资 ô.";
	--if GLOBAL_AGENT then
	--	szMsg = szMsg.."如果确定的话，您将回到英雄岛";
	Dialog:Say("你确定要离开比赛场吗？离开的话将失去比赛资 ô.",
		{
			{"Xác nhận", BeautyHero.LeaveMap, BeautyHero, nMapId, 1},
			{"Để ta suy nghĩ lại"}
		}
	);
end

function BeautyHero:CancelSignUp(nMapId, bConfirm)
	if me.nMapId ~= nMapId then
		return 0;
	end
	
	local tbMissionInfo = BeautyHero:GetMissionInfo(nMapId);
	if not tbMissionInfo then
		Dialog:Say("目前没有巾帼英雄赛");
		return 0;
	end	
	
	if bConfirm == 1 then
		if tbMissionInfo.nState ~= self.SIGN_UP then
			Dialog:Say("比赛已经开始,不能取消比赛资 ô.");
			return 0;
		end
		if tbMissionInfo:FindAttendPlayer(me.nId) ~= 1 then
			Dialog:Say("你还没有报名呢。");
			return 0;
		end		
		
		Dbg:WriteLog("BeautyHeroPK", "CancelSignUp",me.szName); -- 加LOG
		tbMissionInfo:DelAttendPlayer(me.nId);
		Dialog:Say("您取消了参加竞技赛的资 ô.");
		return 0;
	end
	Dialog:Say("你确定要取消报名？",
		{
			{"Xác nhận", BeautyHero.CancelSignUp, BeautyHero, nMapId, 1},
			{"Để ta suy nghĩ lại"}
		}
	);	
end


--function FactionBattle:ChampionFlagNpc(pPlayer, pNpc)
--	self:ExcuteAwardChampion(pPlayer, pNpc);
--end
