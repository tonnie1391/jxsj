
local tbItem = Item:GetClass("insightbook");
tbItem.MAXUSECOUNT = 100;
tbItem.MINUSERLEVEL = 20;
tbItem.FAVOR = 20;
tbItem.DISUSELEVEL = Item.IVER_nInsightbookLevel; --低于书多少级才能使用
function tbItem:OnUse()
	local nTodayUsedCount = me.GetTask(2006, 1);
	if (nTodayUsedCount >= self.MAXUSECOUNT) then
		me.Msg("你已经达到了本日使用心得书的上限，请明天再试。");
		return 0;
	end
	if (me.nLevel < self.MINUSERLEVEL) then
		me.Msg("只有20级以上玩家可以使用心得书。");
		return 0;
	end
	
	local nCreatLevel = it.GetGenInfo(1);
	local nCanUseLevel = nCreatLevel - self.DISUSELEVEL + 1 ;
	if (me.nLevel >= (nCanUseLevel)) then
		me.Msg(string.format("你的等级已经超过这本心得书的等级，书中内容已经不能带给你什么。", nCreatLevel));
		return 0;
	end

	me.SetTask(2006, 1, nTodayUsedCount + 1, 1);

	local nAddExp = self:GetAddExp(it.nParticular);

	-- 当玩家等级与心得书等级的奖励倍率
	local nDelta = nCreatLevel - me.nLevel;
	if (nDelta >= 50) then		-- 心得书等级-角色等级 >=30且<50，则获得2倍经验
		nAddExp = nAddExp * 3;
	elseif (nDelta >= 30) then	-- 心得书等级-角色等级 >=50，则获得3倍经验
		nAddExp = nAddExp * 2;
	end

	-- 如果是使用师傅修炼的心得书，那么增加亲密度并且获得的经验是原来的两倍
	local szCreaterName = it.szCustomString;
	local szTeacherName = me.GetTrainingTeacher();
	if (szCreaterName and szTeacherName and szCreaterName == szTeacherName) then
		Relation:AddFriendFavor(me.szName, szTeacherName, self.FAVOR);
		me.Msg("由于这本心得书是你的师傅制作，使用后你们之间亲密度增加<color=yellow>" .. self.FAVOR .. "点<color>。");
		nAddExp = nAddExp * 2;
	end
	
	me.AddExp(nAddExp);
	me.Msg(string.format("你通过参悟书中心得，功力大涨！你获得了（%d）点经验！", nAddExp));

	return 1;
end


--	显示使用等级以及使用后能获得的经验数，并提示玩家一天内最多能使用多少本心得书
function tbItem:GetTip()
	local nCreatLevel = it.GetGenInfo(1);
	local nAddExp = self:GetAddExp(it.nParticular);
	local nTodayUsedCount = me.GetTask(2006, 1);
	
	local szTip = "";
	if (me.nLevel < self.MINUSERLEVEL) then
		return "<color=0x8080ff>必须在"..self.MINUSERLEVEL.."级以上方可使用心得书<color>\n\n";
	end
	local nCanUseLevel = nCreatLevel - self.DISUSELEVEL + 1 ;
	if (nCanUseLevel > 0) then
		szTip = szTip.."<color=0x8080ff>使用等级：小于"..nCreatLevel.."级<color>\n\n";
	end
	
	szTip = szTip.."<color=0x8080ff>可获得经验："..nAddExp.."<color>\n\n";
	szTip = szTip.."<color=0x8080ff>今天已经使用了："..nTodayUsedCount.."/"..self.MAXUSECOUNT.."次<color>\n\n";
	
	local nLimitLevel	= 0;
	local nTimes		= 1;
	local szMsg			= "";
	nLimitLevel = nCreatLevel - 30;
	if (nLimitLevel >= self.MINUSERLEVEL) then		-- 心得书等级-角色等级 >=30且<50，则获得2倍经验	
		nTimes	= 2;
		szTip	= szTip .. "使用者等级不超过<color=yellow>" .. nLimitLevel .. "<color>级，可以获得<color=yellow>" .. nTimes .. "<color>倍效果\n\n";
	end
	
	nLimitLevel = nCreatLevel - 50;
	if (nLimitLevel > self.MINUSERLEVEL) then	-- 心得书等级-角色等级 >=50，则获得3倍经验
		nTimes	= 3;
		szTip	= szTip .. "使用者等级不超过<color=yellow>" .. nLimitLevel .. "<color>级，可以获得<color=yellow>" .. nTimes .. "<color>倍效果\n\n";		
	end


	szTip = szTip.."<color=orange>"..it.szCustomString.."<color> <color=green>制作<color>";
	return szTip;
end


function tbItem:GetAddExp(nParticular)
	local nAddExp = 0;
	
	if (nParticular == 43) then
		nAddExp = 130 * me.nLevel^2 + 2600 * me.nLevel + 9750;
	elseif(nParticular == 44) then
		nAddExp = 160 * me.nLevel^2 + 3200 * me.nLevel + 12000;
	elseif(nParticular == 45) then
		nAddExp = 200 * me.nLevel^2 + 4000 * me.nLevel + 15000;
	end
	
	return nAddExp;
end
