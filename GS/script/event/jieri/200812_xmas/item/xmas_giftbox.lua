-------------------------------------------------------------------
--File: 	giftbox.lua
--Author: 	furuilei
--Date: 	2008-12-16 10:26:42
--Describe:	圣诞元旦庆祝礼盒
--InterFace1: 
-------------------------------------------------------------------
if  MODULE_GC_SERVER then
	return;
end
local tbClass = Item:GetClass("xmas_giftbox");

tbClass.TSK_GROUP = 2027;
tbClass.TSK_ID = 95;
tbClass.DEF_MAX = 10;
tbClass.DEF_DIS = 50;
tbClass.DEF_ITEM = {18, 1, 270, 1};
tbClass.AWARD_FILE = "\\setting\\event\\jieri\\200812_xmas\\giftbox.txt";

function tbClass:InitGenInfo()
	-- 设定有效期限
	local nSec = GetTime() + 30 * 24 * 3600;
	it.SetTimeOut(0, nSec);
	return	{ };
end

function tbClass:GetTip()
	local szTip = "";
	local szGiveName = it.szCustomString;
	local nType 	 = it.nCustomType;
	local nUse = me.GetTask(self.TSK_GROUP, self.TSK_ID);
	if nType == Item.CUSTOM_TYPE_MAKER and szGiveName ~= "" then
		szTip = szTip .. string.format("<color=yellow>%s赠送<color>\n\n",szGiveName);
	end
	
	szTip = szTip .. string.format("<color=green>已使用%s个该物品<color>", nUse);
	return szTip;
end

-- 使用礼盒
function tbClass:OnUse()
	local szMsg = "圣诞礼盒，只能赠送给亲密度2级以上的好友。";
	Dialog:Say(szMsg,
		{
			{"使用该礼盒", self.SureUse, self, it.dwId},
			{"转送给队友", self.ShowOnlineMember, self, it.dwId},
			{"以后再说"},
		});
end

function tbClass:SureUse(nItemId)
	-- 1. 获取GenInfo(1)，如果是0，不是别人赠送的，不能使用
	-- 2. 获取玩家身上任务变量，是否够10次，超过了，就不能使用了
	-- 3. 如果通过以上两条件，可以使用
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local szGiveName = pItem.szCustomString;
	local nType 	 = pItem.nCustomType
	if (szGiveName == "") then
		Dialog:Say("该物品不能自己使用，你可以赠送给你的好友。");
		return 0;
	end
	if (me.GetTask(self.TSK_GROUP, self.TSK_ID) >= self.DEF_MAX) then
		Dialog:Say("您已经使用了10个圣诞礼盒，不能再使用了，不过你可以把礼盒赠送给你的好友。");
		return 0;
	end
	if self:CheckItemFree(me, 1) == 0 then
		return 0;
	end
	if me.DelItem(pItem, Player.emKLOSEITEM_TYPE_EVENTUSED) ~= 1 then
		return 0;
	end
	me.SetTask(self.TSK_GROUP, self.TSK_ID, me.GetTask(self.TSK_GROUP, self.TSK_ID) + 1);
	local nMaxProbability = self.tbItemList.nMaxProp;
	local nRate = MathRandom(1, nMaxProbability);
	local nRateSum = 0;
	for _, tbItem in pairs(self.tbItemList.tbRandom) do
		nRateSum = nRateSum + tbItem.nProbability;
		if nRate <= nRateSum then
			self:GetItem(me, tbItem, szGiveName)
			return 1;
		end
	end	
end

function tbClass:GetItem(pPlayer, tbitem, szGiveName)
	if tbitem.nMoney ~= 0 then
		local nAddMoney = pPlayer.Earn(tbitem.nMoney, Player.emKEARN_RANDOM_ITEM);
		local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>两", tbitem.nMoney);
		pPlayer.Msg(szAnnouce);
		if nAddMoney == 1 then
			Dbg:WriteLog("随机获得物品",  pPlayer.szName,  string.format("随机获得了%s银两", tbitem.nMoney));
		else
			Dbg:WriteLog("随机获得物品",  pPlayer.szName,  string.format("银两达到上限,随机获得了%s银两失败", tbitem.nMoney));
		end
	end
	
	if tbitem.nBindMoney ~= 0 then
		pPlayer.AddBindMoney(tbitem.nBindMoney, Player.emKBINDMONEY_ADD_EVENT);
	end	
	
	if tbitem.nGenre ~= 0 and tbitem.nDetailType ~= 0 and tbitem.nParticularType ~= 0 then
		local pItem = pPlayer.AddItem(tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType, tbitem.nLevel, tbitem.nSeries, tbitem.nEnhTimes);
		if pItem == nil then
			local szMsg = string.format("随机获得物品失败，物品ID：%s,%s,%s",tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType);
			Dbg:WriteLog("随机获得物品",  pPlayer.szName, szMsg);
			return 0;
		else
			if tbitem.nBind ~= 0 then
				pItem.Bind(1);
			end
		end
		pPlayer.SetItemTimeout(pItem, 30*24*60, 0);
		local szAnnouce = string.format("Chúc mừng nhận được một <color=yellow>%s<color>", pItem.szName);
		pPlayer.Msg(szAnnouce);
		Dbg:WriteLog("随机获得物品",  pPlayer.szName, string.format("随机获得物品一个%s", pItem.szName));
	end
	
	if tbitem.nAnnounce == 1 then
		local szMsg = string.format("%s打开%s赠送的%s获得%s,真是好运啊！", pPlayer.szName, szGiveName, tbitem.szDesc, tbitem.szName);
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
	end
	
	if tbitem.nFriendMsg == 1 then
		pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>]打开"..szGiveName.."赠送的"..tbitem.szDesc..
			"获得了<color=yellow>"..tbitem.szName.."<color>。");
	end

	return 1;
end

function tbClass:CheckItemFree(pPlayer, nCount)
	if pPlayer.CountFreeBagCell() < nCount then
		local szAnnouce = "Hành trang không đủ ，请留出"..nCount.."格空间再试。";
		pPlayer.Msg(szAnnouce);
		return 0;
	end
	return 1;
end

function tbClass:ShowOnlineMember(nItemId)
	
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end

	local szGiveName = pItem.szCustomString;
	local nType 	 = pItem.nCustomType
	if (nType == Item.CUSTOM_TYPE_MAKER and me.GetTask(self.TSK_GROUP, self.TSK_ID) < self.DEF_MAX) then
		
		Dialog:Say("您的礼盒是别人赠送的，必须使用了10个圣诞礼盒，才能把礼盒转送给你的好友。");
		return 0;
	end
	
	local tbPlayerId = me.GetTeamMemberList();
	if tbPlayerId == nil then
		me.Msg("你没有在队伍的当中，不能赠送圣诞礼盒。");
		return 0;
	end
	local tbOnlineMember = {};
	local nMapId, nX, nY	= me.GetWorldPos();
	for _, pPlayer in pairs(tbPlayerId) do
		if pPlayer.nId ~= me.nId then
			local nPlayerMapId, nPlayerX, nPlayerY	= pPlayer.GetWorldPos();
			if (nPlayerMapId == nMapId) then
				local nDisSquare = (nX - nPlayerX)^2 + (nY - nPlayerY)^2;
				if (nDisSquare < ((self.DEF_DIS/2) * (self.DEF_DIS/2))) then
					tbOnlineMember[#tbOnlineMember + 1]= {string.format("%s", pPlayer.szName), self.SelectMember, self, pPlayer.nId, me.nId, nItemId};
				end
			end
		end
	end	
	if (#tbOnlineMember <= 0) then
		Dialog:Say("附近没有队友，不能赠送圣诞礼盒。");
		return 0;
	end
	tbOnlineMember[#tbOnlineMember + 1] = {"取消"};
	Dialog:Say("您要把圣诞礼盒赠送给哪位队友？", tbOnlineMember);
end

function tbClass:SelectMember(nMemberPlayerId, nPlayerId, nItemId)
	local pItem = KItem.GetObjById(nItemId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	local pPlayer1 = KPlayer.GetPlayerObjById(nMemberPlayerId);
	if not pItem or not pPlayer or not pPlayer1 then
		return 0;
	end
	
	local nMapId, nX, nY	= pPlayer.GetWorldPos();
	local nPlayerMapId, nPlayerX, nPlayerY	= pPlayer1.GetWorldPos();
	if nPlayerMapId ~= nMapId then
		Dialog:Say("队友不在附近，不能赠送圣诞礼盒。");
		return 0;
	end
	
	local nDisSquare = (nX - nPlayerX)^2 + (nY - nPlayerY)^2;
	if (nDisSquare > ((self.DEF_DIS/2) * (self.DEF_DIS/2))) then
		Dialog:Say("队友不在附近，不能赠送圣诞礼盒。");
		return 0;
	end
	
	if (1 ~= pPlayer.IsFriendRelation(pPlayer1.szName)) then
		Dialog:Say("该队友与您不是好友关系，不能赠送圣诞礼盒。");
		return 0;
	end
	
	if pPlayer.GetFriendFavorLevel(pPlayer1.szName) < 2 then
		Dialog:Say("该好友与您的亲密度等级不到2级，不能赠送圣诞礼盒给他。");
		return 0;
	end

	if pPlayer1.CountFreeBagCell() < 1 then
		me.Msg("对方没有足够的空间。");
		return 0;
	end
	
	if me.DelItem(pItem, Player.emKLOSEITEM_TYPE_EVENTUSED) ~= 1 then
		me.Msg("赠送失败。");
		return 0;
	end
	
	local pItem = pPlayer1.AddItem(unpack(self.DEF_ITEM));
	if pItem then
		pItem.SetCustom(Item.CUSTOM_TYPE_MAKER, pPlayer.szName);
		pItem.Sync();
	end
	pPlayer.Msg(string.format("你成功赠送圣诞礼盒给<color=yellow>%s<color>。", pPlayer1.szName));
	pPlayer1.Msg(string.format("你接受到了<color=yellow>%s<color>赠送的圣诞礼盒。", pPlayer.szName));
end

function tbClass:LoadItemList()
	self.tbItemList = self:LoadList(self.AWARD_FILE);
end

function tbClass:LoadList(szFile)
	local tbsortpos = Lib:LoadTabFile(szFile);
	local nLineCount = #tbsortpos;
	local tbClassItemList = {nMaxProp = 0, tbRandom = {}};
	for nLine=2, nLineCount do
		local nProbability = tonumber(tbsortpos[nLine].Probability) or 0;
		local szName = tbsortpos[nLine].Name;
		local szDesc = tbsortpos[nLine].Desc;
		local nMoney = tonumber(tbsortpos[nLine].Money) or 0;
		local nBindMoney = tonumber(tbsortpos[nLine].BindMoney) or 0;
		local nGenre = tonumber(tbsortpos[nLine].Genre) or 0;
		local nDetailType = tonumber(tbsortpos[nLine].DetailType)or 0;
		local nParticularType = tonumber(tbsortpos[nLine].ParticularType) or 0;
		local nLevel = tonumber(tbsortpos[nLine].Level)or 0;
		local nSeries = tonumber(tbsortpos[nLine].Series) or 0;
		local nEnhTimes = tonumber(tbsortpos[nLine].EnhTimes) or 0;
		local nBind = tonumber(tbsortpos[nLine].Bind) or 0;
		local nAnnounce = tonumber(tbsortpos[nLine].Announce) or 0;
		local nFriendMsg = tonumber(tbsortpos[nLine].FriendMsg) or 0;
		
		local tbRandom = {};
		tbRandom.nProbability = nProbability;
		tbRandom.szName = szName;
		tbRandom.nMoney = nMoney;
		tbRandom.nBindMoney = nBindMoney;
		tbRandom.nGenre = nGenre;
		tbRandom.nDetailType = nDetailType;
		tbRandom.nParticularType = nParticularType;
		tbRandom.nLevel = nLevel;
		tbRandom.nSeries = nSeries;
		tbRandom.nEnhTimes = nEnhTimes;
		tbRandom.nBind = nBind;
		tbRandom.nAnnounce = nAnnounce;
		tbRandom.nFriendMsg = nFriendMsg;
		tbRandom.szDesc = szDesc;
		table.insert(tbClassItemList.tbRandom, tbRandom);
		if nProbability >= 0 then
			tbClassItemList.nMaxProp = tbClassItemList.nMaxProp + nProbability;
		end
	end
	return tbClassItemList;
end

if MODULE_GAMESERVER then
	
tbClass:LoadItemList();

end

