--竞技赛npc
--孙多良
--2008.12.25

--报名
function Esport:OnDialog_SignUp(nSure)
	
	if self:CheckState() == 0 then
		Dialog:Say("我休息一下吧，新年打雪仗已经结束了。")
		return 0;
	end
	
	
	if self.nReadyTimerId <= 0 or Timer:GetRestTime(self.nReadyTimerId) <= Esport.DEF_READY_TIME_ENTER  then
		Dialog:Say("比赛时间为<color=yellow>上午10点——午夜1点<color>；每半个小时进行一次，整点和半点开始报名。报名时间10分钟。\n\n<color=red>现在不在报名阶段<color>");
		return 0;
	end
	
	if me.nTeamId <= 0 then
		if nSure == 1 then
			self:OnDialogApplySignUp();
			return 0;
		end
		if me.nLevel < self.DEF_PLAYER_LEVEL or me.nFaction <= 0 then
			Dialog:Say("你的修为不足哦，50级并加入门派以后我一定带你去哦。");
			return 0;
		end
		if self:IsSignUpByAward(me) == 1 then
			Dialog:Say("你上次比赛的奖励还没领呢，不准不要我的礼物哦，我会生气不带你去玩的。");
			return 0;
		end		
		if self:IsSignUpByTask(me) == 0 then
			Dialog:Say("你今天已经去了这么多次飞絮崖了，回去休息下明天再来吧。");
			return 0;
		end
		local tbOpt = {
			{"我要前往", self.OnDialog_SignUp, self, 1},
			{"Để ta suy nghĩ lại"},
			};
		Dialog:Say("你想自己进入晏若雪家院子，参加飞絮崖的雪仗吗？", tbOpt);
		return 0;
	end
	

	if me.IsCaptain() == 0 then
		Dialog:Say("你不是队长哦，去叫你们队长来报名吧。");
		return 0;
	end
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);
	
	if nSure == 1 then
		self:OnDialogApplySignUp(tbPlayerList);
		return 0;
	end
	
	local tbOpt = {
		{"我们要前往", self.OnDialog_SignUp, self, 1},
		{"我们再考虑考虑"},
		};
	Dialog:Say(string.format("你们队伍想进入晏若雪家院子，参加飞絮崖的雪仗吗？队伍有<color=yellow>%s人<color>，请确定队员在这里。", #tbPlayerList), tbOpt);
	return 0;
end

function Esport:OnDialogApplySignUp(tbPlayerList)
	if not tbPlayerList then
		GCExcute{"Esport:ApplySignUp",{me.nId}};
		return 0;
	end
	local nMapId, nPosX, nPosY	= me.GetWorldPos();	
	for _, nPlayerId in pairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			Dialog:Say("你们队伍有人没来啊，我们还不能出发，等等他吧。");
			return 0;
		end
		if pPlayer.nLevel < self.DEF_PLAYER_LEVEL or pPlayer.nFaction <= 0 then
			
		end
		if pPlayer.nLevel < self.DEF_PLAYER_LEVEL or pPlayer.nFaction <= 0 then
			Dialog:Say(string.format("啊，那个<color=yellow>%s<color>太弱小了吧，如果遇到怪物就危险了，50级并加入门派以后再来吧。", pPlayer.szName));
			return 0;
		end
		if self:IsSignUpByAward(pPlayer) == 1 then
			Dialog:Say(string.format("<color=yellow>%s<color>上次比赛的奖励还没领呢，不准不要我的礼物哦，我会生气不带你们去玩的。", pPlayer.szName));
			return 0;
		end				
		
		if self:IsSignUpByTask(pPlayer) == 0 then
			Dialog:Say(string.format("啊，<color=yellow>%s<color>你今天去飞絮崖好多次了，明天再来吧。", pPlayer.szName));
			return 0;
		end
		local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
		local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
		if nMapId2 ~= nMapId or nDisSquare > 400 then
			Dialog:Say("您的所有队友必须在这附近。");
			return 0;
		end
		if not pPlayer or pPlayer.nMapId ~= nMapId then
			Dialog:Say("您的所有队友必须在这附近。");
			return 0;
		end
	end
	GCExcute{"Esport:ApplySignUp", tbPlayerList};
	return 0;
end

function Esport:IsSignUpByTask(pPlayer)
	Esport:TaskDayEvent();
	local nCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT);
	local nExCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_EXCOUNT)
	if nCount <= 0 and nExCount <= 0 then
		return 0, 0 ,0;
	end
	return nCount + nExCount, nCount, nExCount;
end

function Esport:IsSignUpByAward(pPlayer)
	return pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_AWARD);
end

function Esport:GetItemJinZhouBaoZu()
	local szMsg = "孩子，你回来了？新年快乐啊。你来找我有什么事呢？";
	local tbNpc =  Npc:GetClass("esport_yanruoxue");
	local tbOpt = {
		{"领取禁咒爆竹", self.GetItemJinZhouBaoZuItem, self},
		{"关于消灭年兽", tbNpc.OnAboutNianShou, tbNpc},
		{"了解新年活动", tbNpc.OnAboutNewYears, tbNpc},
		{"向您老人家问个好就走"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function Esport:GetItemJinZhouBaoZuItem()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你包包里塞满了东西，还能装得下吗？");
		return 0;
	end
	if me.nLevel < 50 then
		Dialog:Say("孩子你修为不足，拿这玩意反而容易引火自焚，恐怕要50级以后我才可放心给你。");
		return 0;
	end
	
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nTaskDate = me.GetTask(self.TSK_GROUP, self.TSK_NEWYEAR_JINZHOUBAOZHU);
	
	if nCurDate <= nTaskDate then
		Dialog:Say("我已经把鞭炮给你了，不再有多的。孩子，你记住，其他的要自己努力去争取。");
		return 0;
	end
	
	local pItem = me.AddItem(unpack(self.SNOWFIGHT_ITEM_JINZHOUBAOZHU));
	if pItem then
		pItem.Bind(1);
		me.SetTask(self.TSK_GROUP, self.TSK_NEWYEAR_JINZHOUBAOZHU, nCurDate);
		self:WriteLog("得到物品"..pItem.szName, me.nId);
	end
	Dialog:Say("这鞭炮拿好了，很是神奇，如果你遇到年兽这蛮物，点燃的话，可破其护体戾气，轻松打败他。");
end
