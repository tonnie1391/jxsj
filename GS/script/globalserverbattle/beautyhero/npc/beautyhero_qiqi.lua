-- 文件名  : qiqi.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-26 11:47:22
-- 描述    : 

local tbNpc = Npc:GetClass("beautyhero_qiqi");
tbNpc.NUM_PERPAGE = 9;

function tbNpc:OnDialog()
	local nMapId = him.GetWorldPos();
	local tbMissionInfo = BeautyHero:GetMissionInfo(nMapId);

	if not tbMissionInfo then	
		Dialog:Say("你好，我是七七，很高兴为您服务。");
		return;
	end

	local szMsg = "你好，我是七七，很高兴为您服务。";
	local tbOpt = {};
	table.insert(tbOpt,{"路上不小心捡了张卡", self.GetCard,self,nMapId, him.dwId});
--	if tbMissionInfo.nState == BeautyHero.MATCH_REST then
		table.insert(tbOpt,{"我是来支持美女的",self.SelectBeauty, self,nMapId});	
		table.insert(tbOpt,{"查看我的投票情况",self.ShowBeauty, self,nMapId});			

	--if tbMissionInfo.nState >= BeautyHero.CHAMPION_AWARD then
	if not GLOBAL_AGENT then
		table.insert(tbOpt,{"领取支持奖励",self.GetVoteAward, self,nMapId,0});
		table.insert(tbOpt,{"领取比赛奖励",self.GetMatchAward, self,nMapId,0});	
		
	else 
		table.insert(tbOpt,{"查看支持奖励",self.GetVoteAward, self,nMapId,0});
		table.insert(tbOpt,{"查看比赛奖励",self.GetMatchAward, self,nMapId,0});				
	end	
--	end

	if 	GLOBAL_AGENT then
		table.insert(tbOpt,{"购买红玫瑰", BeautyHero.BuyRose, BeautyHero});
	end	

	table.insert(tbOpt,{"老婆说了，路边的野花不要采"});	
	Dialog:Say(szMsg,tbOpt);
	return;
end


function tbNpc:SelectBeauty(nMapId,nCurPage)
	if me.nMapId ~= nMapId then
		return;
	end
	nCurPage = nCurPage or 1;
	local tbMissionInfo = BeautyHero:GetMissionInfo(nMapId);
	if not tbMissionInfo then	
		Dialog:Say("你好，我是七七，很高兴为您服务。");
		return;
	end	
	
	if tbMissionInfo.nState < BeautyHero.MATCH_REST then
		Dialog:Say("还没开始呢，不急。");
		return;
	end	
	
	if tbMissionInfo.nState > BeautyHero.MATCH_REST then
		Dialog:Say("时间不等人啊…下次吧。");
		return;
	end	
	
	local tbTmp = {};
	local tbOpt = {};
	for i = 1, 16 do
		if tbMissionInfo.tb16Player[i] then
			table.insert(tbTmp,tbMissionInfo.tb16Player[i].szName);			 
		end
	end	
	
	if #tbTmp == 0 then
		print("[ERR]，SelectBeauty nTotalCount == 0");
		return;
	end	
	
	local nCurBeginCount = self.NUM_PERPAGE *(nCurPage - 1) + 1;
	if not tbTmp[nCurBeginCount] then
		return 0;
	end
	local nCurEndCount = #tbTmp;
	if  #tbTmp - nCurBeginCount + 1 > self.NUM_PERPAGE then
		nCurEndCount = nCurBeginCount + self.NUM_PERPAGE - 1;
	end
	
	for i = nCurBeginCount , nCurEndCount do
		table.insert(tbOpt,{tbTmp[i],self.SelectBeautyTickets,self,nMapId,tbTmp[i]});
	end
	
	if nCurEndCount < #tbTmp then
		table.insert(tbOpt,{"Trang sau",self.SelectBeauty,self, nMapId,nCurPage + 1});
	end
	
	table.insert(tbOpt,{"Kết thúc đối thoại"});		
	Dialog:Say("你好，请选择要支持的美女", tbOpt);
end

function tbNpc:SelectBeautyTickets(nMapId,szName)
	if me.nMapId ~= nMapId then
		return;
	end
	local nCount = tonumber(me.GetItemCountInBags(unpack(BeautyHero.ITEM_VOTE))) or 0;
	if nCount == 0 then
		Dialog:Say("您还没有投票道具哦。");
		return;
	end	
	
	local szInput = string.format("输入票数");

	Dialog:AskNumber(szInput, nCount, self.SelectBeautyFinal, self, nMapId, szName);			
end

function tbNpc:SelectBeautyFinal(nMapId,szName,nTickets)
	if me.nMapId ~= nMapId then
		return;
	end	
	
	local tbMissionInfo = BeautyHero:GetMissionInfo(nMapId);
	if not tbMissionInfo then	
		return;
	end	
	if tbMissionInfo.nState ~= BeautyHero.MATCH_REST then
		return;
	end	
	
	if nTickets <= 0 then
		return;
	end	
	--
	-- 扣除物品
	local nCount = me.GetItemCountInBags(unpack(BeautyHero.ITEM_VOTE));		
	if nCount < nTickets then
		Dialog:Say("道具不够");
		return;
	end
	
	local bRet = me.ConsumeItemInBags(nTickets, unpack(BeautyHero.ITEM_VOTE));
	Dialog:Say(string.format("你成功给%s投了%d票", szName,nTickets));
	Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroPK", "赌马投票",me.szName, szName,nTickets);
	-- 总数
	tbMissionInfo.tbGirlVote.nTotalTickets = tbMissionInfo.tbGirlVote.nTotalTickets + nTickets;
	
	tbMissionInfo.tbGirlVote.tbVote[szName] = tbMissionInfo.tbGirlVote.tbVote[szName] or {};
	local tbVote = tbMissionInfo.tbGirlVote.tbVote[szName];
	tbVote.nTickets = (tbVote.nTickets or 0) + nTickets;
	tbVote.tbFans   = tbVote.tbFans or {};
	tbVote.tbFans[me.szName] = (tbVote.tbFans[me.szName] or 0) + nTickets;
end

function tbNpc:GetCard(nMapId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end	
	
	if me.nMapId ~= nMapId then
		return;
	end
	
	local szContent = "请放入卡片";
	Dialog:OpenGift(szContent, nil, {self.GetCardEx, self, nMapId,nNpcId});
end
	
function tbNpc:GetCardEx(nMapId, nNpcId, tbItemObj)
	--背包判断
	--if me.CountFreeBagCell() < 2 then
	--	Dialog:Say("需要2格背包空间，整理下再来！",{"知道了"});
	--	return;
	--end
	if me.nMapId ~= nMapId then
		return;
	end
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	
	if #tbItemObj == 0 then
		Dialog:Say("原来你没有卡啊…哎…美女总被调戏…");	
		return 0;
	end		
	
	--物品个数判定
	if #tbItemObj ~= 1 then
		Dialog:Say("每次只能放入1张卡片。");	
		return 0;
	end	
	
	local pItem = tbItemObj[1][1];

	--物品gdpl判定
	local szKey = string.format("%s,%s,%s,%s",pItem.nGenre,pItem.nDetail,pItem.nParticular,pItem.nLevel);
	local szCoupletKey = string.format("%s,%s,%s,%s", unpack(BeautyHero.ITEM_CARD));   
	if szKey ~= szCoupletKey then
		Dialog:Say("您放的物品不对，请放入1张卡片。");
		return 0;			
	end	
	local szMsg = "";

	local szItemString =  pItem.szCustomString;
	pItem.Delete(me);	

	if pNpc.GetTempTable("BeautyHero").szName ~= "" and pNpc.GetTempTable("BeautyHero").szName == szItemString then
		szMsg = string.format("这么巧，我也支持<color=yellow>%s<color>。这个盒子您拿去吧",pNpc.GetTempTable("BeautyHero").szName);
		if GLOBAL_AGENT then
			szMsg = string.format("这么巧，我也支持<color=yellow>%s<color>。奖励已放在本服丁丁处，比赛结束记得回本服领取哦。",pNpc.GetTempTable("BeautyHero").szName);
			BeautyHero:AddGlobalRestAward(me.nId,BeautyHero.COIN_BOX, me);
		else	
			szMsg = string.format("这么巧，我也支持<color=yellow>%s<color>。这个盒子您拿去吧",pNpc.GetTempTable("BeautyHero").szName);	
			local pItem2 = me.AddItem(unpack(BeautyHero.ITEM_BAOXIANG));
			if pItem2 then
				pItem2.Bind(1);
			end
		end
	else
		if GLOBAL_AGENT then
			szMsg = "您走错了吧。这点绑金拿去，做你回乡的路费。";
			BeautyHero:AddGlobalRestAward(me.nId, 100, me);
		else
			szMsg = "您走错了吧。这5w银子拿去，做你回乡的路费。";
			me.AddBindMoney(50000);
		end
		if pNpc.GetTempTable("BeautyHero").szName ~= "" then
			local szTmp = string.format("这里是<color=yellow>%s<color>粉丝团，",pNpc.GetTempTable("BeautyHero").szName);
			szMsg = szTmp..szMsg;
		end
	end
	
	Dialog:Say(szMsg);	
end


function tbNpc:ShowBeauty(nMapId)
	if me.nMapId ~= nMapId then
		return;
	end
	local tbMissionInfo = BeautyHero:GetMissionInfo(nMapId);
	if not tbMissionInfo then	
		Dialog:Say("你好，我是七七，很高兴为您服务。");
		return;
	end
	local nCount = 0;
	local szMsg = "您的投票如下：\n";
	local szTmp = "";
	for szBeautyName, tbInfo  in pairs(tbMissionInfo.tbGirlVote.tbVote) do
		 if tbInfo.tbFans[me.szName] then
		 	nCount = nCount + 1;
		 	szTmp = string.format("<color=yellow>%s<color>   <color=yellow>%d票<color>\n",  Lib:StrFillL(szBeautyName,16), tbInfo.tbFans[me.szName]);
		 	szMsg = szMsg..szTmp;
		 end		
	end
	
	if nCount > 0 then
		Dialog:Say(szMsg);
		return;
	end
	
	Dialog:Say("您还没投票呢。");
end

function tbNpc:GetVoteAward(nMapId, bSure)
	if me.nMapId ~= nMapId then
		return;
	end
		
	local tbMissionInfo = BeautyHero:GetMissionInfo(nMapId);
	if not tbMissionInfo then	
		return;
	end
	
	if tbMissionInfo.bChampionAward ~= 1 then
		Dialog:Say("奖励还没出来呢，等等吧。");
		return;
	end
	
	if not tbMissionInfo.tbVoteAward[me.szName] then
		Dialog:Say("这里没有您的奖励记录。");
		return;
	end
	
	if tbMissionInfo.tbVoteAward[me.szName].bHaveGet == 1 then
		Dialog:Say("您已经领取过这份奖励了，不能重复领哦。");
		return;
	end	
	
	local nBindCoin = 0;
	local szMsg = "您的支持奖励如下:\n支持美女           排名   奖励绑金\n";
	local szTmp = "";
	local szFmt = "";
	for _, tbInfo in ipairs(tbMissionInfo.tbVoteAward[me.szName]) do
	--	szFmt = string.format("<color=yellow>%s  %s<color>",tbInfo.szPlayerName,tbInfo.szWinName);
	--	szTmp = string.format("%s  <color=yellow>%s<color>绑金\n", Lib:StrFillL(szFmt,24), tbInfo.nBindCoin);
		szTmp = string.format("<color=yellow>%s  %s<color>  <color=yellow>%s<color>\n", Lib:StrFillL(tbInfo.szPlayerName,16), Lib:StrFillL(tbInfo.szWinName,6),tbInfo.nBindCoin);
		szMsg = szMsg..szTmp;
		nBindCoin = nBindCoin + tbInfo.nBindCoin;
	end
	szTmp = string.format("总计  <color=yellow>%d<color>绑金",nBindCoin);
	szMsg = szMsg..szTmp;
	if not bSure or bSure ~= 1 then
		if not GLOBAL_AGENT then
			Dialog:Say(szMsg,{{"我要领取",self.GetVoteAward,self,nMapId,1},{"Để ta suy nghĩ thêm"}});
		else
			--szMsg = szMsg.."您可以回本服丁丁处领取这份奖励。";
			Dialog:Say(szMsg);
		end
		return;
	end
	
	tbMissionInfo.tbVoteAward[me.szName].bHaveGet = 1;
	me.AddBindCoin(nBindCoin);
	Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroPK", "赌马奖励领取",me.szName, nBindCoin);
	StatLog:WriteStatLog("statlog", "beautyleague", "winmoney", me.nId, nBindCoin);		
end

function tbNpc:GetMatchAward(nMapId,bSure)
	if me.nMapId ~= nMapId then
		return;
	end
		
	local tbMissionInfo = BeautyHero:GetMissionInfo(nMapId);
	if not tbMissionInfo then	
		return;
	end
	
	if tbMissionInfo.bChampionAward ~= 1 then
		Dialog:Say("奖励还没出来呢，等等吧。");
		return;
	end
	
	if not tbMissionInfo.tbMatchAward[me.szName] then
		Dialog:Say("这里没有您的奖励记录。");
		return;
	end
	
	if tbMissionInfo.tbMatchAward[me.szName].bHaveGet == 1 then
		Dialog:Say("您已经领取过这份奖励了，不能重复领哦。");
		return;
	end	
	local nWinCount = tbMissionInfo.tbMatchAward[me.szName].nWinCount;
	local szMsg = string.format("恭喜您在这次比赛中获得<color=yellow>%s<color>。",BeautyHero.AWARD_VOTER[nWinCount].szName);
	if not bSure or bSure ~= 1 then
		if not GLOBAL_AGENT then
			--szMsg = szMsg.."确定领取奖励吗？";
			Dialog:Say(szMsg,{{"我要领取",self.GetMatchAward,self,nMapId,1},{"Để ta suy nghĩ thêm"}});
		else
			--szMsg = szMsg.."您可以回本服丁丁处领取这份奖励。";
			Dialog:Say(szMsg);
		end

		return;
	end	
	
	local nBoxNum = BeautyHero.AWARD_VOTER[nWinCount].nBoxNum;
		
	if me.CountFreeBagCell() < nBoxNum then
		Dialog:Say(string.format("至少需要%d格背包空间，才能领奖哦。",nBoxNum));
		return 0;
	end

	tbMissionInfo.tbMatchAward[me.szName].bHaveGet = 1;
	local pItem = nil;
	for i = 1, nBoxNum do
		pItem = me.AddItem(unpack(BeautyHero.AWARD_VOTER[nWinCount].tbBox));
		if pItem then
			pItem.Bind(1);
		end
	end

	Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroPK", "比赛奖励领取",me.szName,nWinCount);	
end