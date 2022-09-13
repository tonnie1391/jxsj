--美丽的花束

local tbClass = EventManager:GetClass("item_flowers")

function tbClass:ExeStartFun()
	local szTaskMale 		= self:GetParam("task_male")[1];
	local nTaskFeMale		= tonumber(self:GetParam("task_female")[1]) or 0;
	local nDefFeMaleMax 	= tonumber(self:GetParam("def_female_max")[1]) or 0;
	local nDefFeMaleLevel 	= tonumber(self:GetParam("def_female_level")[1]) or 0;
	local nDefFavorLevel 	= tonumber(self:GetParam("def_favorlevel")[1]) or 0;
	local szDefMaleItem		= (self:GetParam("def_male_Item")[1]);
	local szDefFeMaleItem	= (self:GetParam("def_female_Item")[1]);	
	local szDefMaleBuff		= (self:GetParam("def_male_buff")[1]);
	local szDefFeMaleBuff	= (self:GetParam("def_female_buff")[1]);
	local szDefTitle		= (self:GetParam("def_title")[1]);
	
	tbClass.TASK_MALE 			= Lib:SplitStr(szTaskMale); --男性存祝福的女性哈希表
	tbClass.TASK_FEMALE			= nTaskFeMale;				--女性祝福多少次有奖励
	tbClass.DEF_FEMALE_MAX		= nDefFeMaleMax;			--女性最多受到祝福次数
	tbClass.DEF_FEMALE_LEVEL	= nDefFeMaleLevel;			--要求达到等级
	tbClass.DEF_FAVORLEVEL		= nDefFavorLevel;			--好友等级
	tbClass.DEF_MALE_ITEM		= szDefMaleItem;			--男方奖励物品
	tbClass.DEF_FEMALE_ITEM		= szDefFeMaleItem;			--女方奖励物品
	tbClass.DEF_MALE_BUFF		= szDefMaleBuff;			--男方奖励buff
	tbClass.DEF_FEMALE_BUFF		= szDefFeMaleBuff;			--女方奖励buff
	tbClass.DEF_TITLE			= szDefTitle;	--称号Id
	tbClass.ITEM_RATE = 
	{
		{nRate = 10, tbItem={1,13,15,1}, nBind=1 },	--10％概率面具
		{nRate = 10, tbItem={1,13,19,1}, nBind=1 },	--10％概率面具
	};
end

function tbClass:OnUse()
	local szMsg = "今天是江湖女儿的节日，选择一个女子送出你真心的祝福吧！";
	
	if me.nTeamId <= 0 then
		Dialog:Say("必须和你的女性朋友组队并且在附近才能送出祝福。");
		return 0;
	end
	local tbTeamMemberList = me.GetTeamMemberList();
	if not tbTeamMemberList or #tbTeamMemberList <= 1 then
		Dialog:Say("必须和你的女性朋友组队并且在附近才能送出祝福。");
		return 0;		
	end
	local tbOpt = {};
	for _, pPlayer in ipairs(tbTeamMemberList) do
		if pPlayer.nId ~= me.nId then
			table.insert(tbOpt, {pPlayer.szName, self.SelectFriend, self, it.dwId, pPlayer.nId});
		end
	end
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbClass:SelectFriend(nItemId, nPlayerId)
	local pMePlayer = me;
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if not pPlayer or pPlayer.nMapId ~= pMePlayer.nMapId then
		Dialog:Say("对方不在附近不能送出祝贺");
		return 0;
	end
	
	if pPlayer.nSex ~= Env.SEX_FEMALE then
		Dialog:Say("美女节不能祝贺男性哦");
		return 0;
	end
	
	if pPlayer.nLevel < self.DEF_FEMALE_LEVEL then
		Dialog:Say("对方没到60级，不能获得祝贺。");
		return 0;		
	end
	
	if pMePlayer.GetFriendFavorLevel(pPlayer.szName) < self.DEF_FAVORLEVEL then
		Dialog:Say(string.format("您与对方不是好友关系或亲密度不到%s级", self.DEF_FAVORLEVEL));
		return 0;
	end
	
	local nHashNameId = KLib.Number2UInt(tonumber(KLib.String2Id(pPlayer.szName)));
	local nUseTaskId  	= 0;
	local nRUseTaskCount= 0;
	for nId, nTaskId in ipairs(self.TASK_MALE) do
		if tonumber(nTaskId) > 0 then
			if KLib.Number2UInt(EventManager:GetTask(tonumber(nTaskId))) == nHashNameId then
				Dialog:Say("你已经祝贺过对方，多次祝贺是没有意义的");
				return 0;
			end
			
			if nUseTaskId == 0 and KLib.Number2UInt(EventManager:GetTask(tonumber(nTaskId))) == 0 then
				nUseTaskId = tonumber(nTaskId);
				nRUseTaskCount = nId;
			end
			
		end
	end
	
	if nUseTaskId == 0 then
		Dialog:Say(string.format("你已经祝贺了%s次了，不能再进行祝福。", #self.TASK_MALE));
		return 0;
	end
	
	--判断背包空间
	local nFreeCount = 1;
	if pMePlayer.CountFreeBagCell() < nFreeCount then
		pMePlayer.Msg(string.format("对不起，您身上的背包空间不足，需要%s格背包空间。", nFreeCount));
		return 0;
	end
	
	local nFreeCount2 = 2;
	if pPlayer.CountFreeBagCell() < nFreeCount2 then
		pMePlayer.Msg(string.format("对不起，对方身上的背包空间不足，无法进行祝福，需要%s格背包空间。", nFreeCount2));
		return 0;
	end	
	
	--双方给予奖励
	if (pMePlayer.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
		return 0;
	end
	
	--男方玩家
	Setting:SetGlobalObj(pMePlayer);
	
	if self.DEF_MALE_ITEM then
		EventManager.tbFun:ExeAddItem(self.DEF_MALE_ITEM);
	end
	if self.DEF_MALE_BUFF then
		EventManager.tbFun:ExeAddBuffType(self.DEF_MALE_BUFF);
	end
	if nUseTaskId == tonumber(self.TASK_MALE[#self.TASK_MALE]) then
		pMePlayer.AddTitle(6, 4, 2, 0);
		pMePlayer.SetCurTitle(6, 4, 2, 0);			
	end
	Setting:RestoreGlobalObj();
	
	--女性玩家
	Setting:SetGlobalObj(pPlayer);
	
	
	EventManager:SetTask(self.TASK_FEMALE, EventManager:GetTask(self.TASK_FEMALE) + 1);
	local nFeMaleCanGetAward = EventManager:GetTask(self.TASK_FEMALE);
	if self.DEF_TITLE then
		EventManager.tbFun:ExeAddTitle(self.DEF_TITLE);
	end	
	
	if EventManager:GetTask(self.TASK_FEMALE) <= self.DEF_FEMALE_MAX then
		if self.DEF_FEMALE_ITEM then
			EventManager.tbFun:ExeAddItem(self.DEF_FEMALE_ITEM);
		end
		if self.DEF_FEMALE_BUFF then
			EventManager.tbFun:ExeAddBuffType(self.DEF_FEMALE_BUFF);
		end
	end
	
	if EventManager:GetTask(self.TASK_FEMALE) == self.DEF_FEMALE_MAX then
		local nRate = MathRandom(1,100);
		local nSum  = 0;
		for _, tbItem in pairs(self.ITEM_RATE) do
			nSum = nSum + tbItem.nRate;
			if nRate <= nSum then
				local pItem = me.AddItem(unpack(tbItem.tbItem));
				if pItem then
					if tbItem.nBind then
						pItem.Bind(tbItem.nBind)
					end
				end
				break;
			end
		end
		pPlayer.AddTitle(6, 5, 1, 0);
		pPlayer.SetCurTitle(6, 5, 1, 0);	
	end
	
	Setting:RestoreGlobalObj();

	EventManager:SetTask(nUseTaskId, nHashNameId);
	local szMeMsg = string.format("在美女节对<color=yellow>%s<color>送出了祝贺，真是个体贴的好男子呀！(已祝福%s次)", pPlayer.szName, nRUseTaskCount);
	pMePlayer.Msg(string.format("<color=yellow>%s<color>%s", pMePlayer.szName, szMeMsg));
	pMePlayer.SendMsgToFriend(string.format("<color=yellow>%s<color>%s", pMePlayer.szName, szMeMsg));
	Player:SendMsgToKinOrTong(pMePlayer, szMeMsg, 1);
	
	local szFeMsg = string.format("在美女节获得<color=yellow>%s<color>的祝贺，虽因已被祝贺10次而奖励变少，但幸福依然瞬间降临到她的头上！(已受到%s次祝福)", pMePlayer.szName, nFeMaleCanGetAward);
	if nFeMaleCanGetAward <= 10 then
		szFeMsg = string.format("在美女节获得<color=yellow>%s<color>的祝贺，幸福瞬间降临到她的头上(已受到%s次祝福)", pMePlayer.szName, nFeMaleCanGetAward);
	end
	
	pPlayer.Msg(string.format("<color=yellow>%s<color>%s", pPlayer.szName, szFeMsg));
	pPlayer.SendMsgToFriend(string.format("<color=yellow>%s<color>%s", pPlayer.szName, szFeMsg));
	Player:SendMsgToKinOrTong(pPlayer, szFeMsg, 1);	
end
