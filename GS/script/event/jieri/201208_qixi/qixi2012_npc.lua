-- 文件名　：qixi2012_npc.lua
-- 创建者　：huangxiaoming
-- 创建时间：2012-08-10 14:10:10
-- 描  述  ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201208_qixi\\qixi2012_def.lua");
SpecialEvent.QiXi2012 = SpecialEvent.QiXi2012 or {};
local tbQiXi2012 = SpecialEvent.QiXi2012 or {};

-- 活动大使
local tbNpcHuoDongDaShi = Npc:GetClass("qixi2012_huodongdashi");

function tbNpcHuoDongDaShi:OnDialog(nFlag)
	local szDesc = "    浮生乱世，谁许情深……<enter>    他说人如蜉蝣，许是回眸后半生不见，亦可相逢即相随。有已故掌门前车之鉴，我明知他话中的危险，却还是情不自禁违背门规，去寻他的踪迹。<enter>    离开古墓后，我不记得已经过了多少个七夕，直至心剑已老，素针湮灭。可只要我还有时间，总会找到他的，不是么？<enter>    你既已来，我必全力相助，让你们有情人终成眷属..";
	if tbQiXi2012:CheckIsOpen() ~= 1 then
		Dialog:Say(szDesc);
		return;
	end
	if nFlag ~= 1 then
		Dialog:Say(szDesc, {{"<color=yellow>七夕活动<color>", self.OnDialog, self, 1}, {"我只是随便看看"}});
		return;
	end
	if me.nLevel < tbQiXi2012.LIMIT_LEVEL or me.nFaction <= 0 then
		Dialog:Say("只有50级以上并且加入门派的侠士才能参加活动。");
		return;
	end
	local nNowTime = tonumber(GetLocalDate("%H%M%S"));
	
	local szMsg = "<color=pink>【活动一：寻找前世之旅】<color><enter>活动期间每天11:00~15:00、18:00~23：00,男女侠士可领取前世之物，组队后共同穿越<color=yellow>时光之门<color>，去往前世寻找<color=yellow>真爱红玫瑰<color>即有丰厚奖励。<enter><enter><color=pink>【活动二：浓情七夕解心玉】<color><enter>活动期间，参加逍遥谷、军营，击杀精英和首领可能获得<color=yellow>[解心玉]<color>，来开启宝物<color=yellow>[锁心玉]<color>。<enter><enter><color=pink>【活动三：相约七夕定情缘】<color><enter>活动期间，凡举行过<color=yellow>纳吉仪式<color>的侠客，都可领取一个七夕豪华情缘礼包。 <enter>";
	local tbOpt = {};
	if tbQiXi2012:CheckCanAcceptSeed(me) ~= 0 then
		if me.nSex == 1 then -- 女角色
			table.insert(tbOpt, {"领取玫瑰阵图", self.AcceptItem, self});
		else
			table.insert(tbOpt, {"领取玫瑰之种", self.AcceptItem, self});
		end
	end
	if tbQiXi2012:CheckActivityTime() == 1 then
		table.insert(tbOpt, {"寻找前世之旅", self.Transmit, self, him.dwId});
	end
	local tbFind = me.FindItemInBags(unpack(tbQiXi2012.ITEMID_AWARDROSE));
	if #tbFind > 0 then
		table.insert(tbOpt, {"上交真爱玫瑰", self.ChangeAward, self});
	else
		table.insert(tbOpt, {"<color=gray>上交真爱玫瑰<color>", self.ChangeAward, self});
	end
	if me.GetTask(tbQiXi2012.TASK_GROUP_ID, tbQiXi2012.TASK_QINGYUANLIBAO) == 0 then
		table.insert(tbOpt, {"领取七夕礼包", self.GetQingyuanlibao, self});
	end
	table.insert(tbOpt, "我只是随便看看");
	Dialog:Say(szMsg, tbOpt);
end

function tbNpcHuoDongDaShi:AcceptItem()
	local nRet, szMsg = tbQiXi2012:CheckCanAcceptSeed(me);
	if nRet ~= 1 then
		Dialog:Say(szMsg);
		return;
	end
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	local nValidTime = Lib:GetDate2Time(nDate) + 24 * 3600 - 1;
	me.SetTask(tbQiXi2012.TASK_GROUP_ID, tbQiXi2012.TASK_LAST_ACCEPT_DAY, nDate);
	me.SetTask(tbQiXi2012.TASK_GROUP_ID, tbQiXi2012.TASK_DAY_AWARD_TIMES, 0);
	if me.nSex == 1 then
		local tbRandItem = tbQiXi2012:RandGrap();
		assert(#tbRandItem == tbQiXi2012.NUM_GRAP);
		for i = 1, #tbRandItem do
			local pItem = me.AddItem(unpack(tbRandItem[i]));
			if pItem then
				pItem.Bind(1);
				me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", nValidTime));
				pItem.Sync();
			else
				print("qixi2012", "add grap fail", me.szName);
			end
		end
	else
		for i = 1, tbQiXi2012.NUM_SEED do
			local pItem = me.AddItem(unpack(tbQiXi2012.ITEMID_SEED));
			if pItem then
				pItem.Bind(1);
				me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", nValidTime));
				pItem.Sync();
			else
				print("qixi2012", "add seed fail", me.szName);
			end
		end
	end
	StatLog:WriteStatLog("stat_info", "qixi_2012", "join", me.nId, 1);
end

-- 变身，传送到野外
function tbNpcHuoDongDaShi:Transmit(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then 
		return;
	end
	if tbQiXi2012:CheckActivityTime() ~= 1 then
		Dialog:Say("活动时间未到，2012.8.21-2012.8.27的11:00~15:00、18:00~23：00期间才可穿越时光之门。");
		return 0;
	end
	local nNpcMapId, nNpcPosX, nNpcPosY = pNpc.GetWorldPos();
	local pPartner = tbQiXi2012:GetPartner(me);
	if not pPartner then
		Dialog:Say("请与1名异性有缘人组队并且站到我身边才可以穿越时光之门。");
		return 0;
	end
	if me.nSex == 1 then
		Dialog:Say("时光隧道异常凶险，请让男性来选择开始穿越时光之门。");
		return 0;
	end
	local nMapId1, nPosX1, nPosY1 = me.GetWorldPos();
	local nMapId2, nPosX2, nPosY2 = pPartner.GetWorldPos();
	if nMapId1 ~= nNpcMapId or nMapId2 ~= nNpcMapId then
		Dialog:Say("她离你太远了，无法一同穿越时光之门。");
		return 0;
	end
	if (nPosX1 - nNpcPosX) * (nPosX1 - nNpcPosX) + (nPosY1 - nNpcPosY) * (nPosY1 - nNpcPosY) > tbQiXi2012.MAX_TRANSMIT_RANGE * tbQiXi2012.MAX_TRANSMIT_RANGE or
		(nPosX2 - nNpcPosX) * (nPosX2 - nNpcPosX) + (nPosY2 - nNpcPosY) * (nPosY2 - nNpcPosY) > tbQiXi2012.MAX_TRANSMIT_RANGE * tbQiXi2012.MAX_TRANSMIT_RANGE then
		Dialog:Say("需要两个人都站在我身边，才能到达你们的前世。");
		return 0;
	end
	local nSeedCount = me.GetItemCountInBags(unpack(tbQiXi2012.ITEMID_SEED));
	if nSeedCount <= 0 then
		Dialog:Say("你没有前世信物玫瑰之种（七夕使者处领取),无法穿越时光之门。");
		return 0;
	end
	-- 女玩家查找有没有图
	local tbGrapSet = pPartner.FindClassItemInBags("qixi2012_grap");
	if #tbGrapSet <= 0 then
		Dialog:Say("她没有携带玫瑰阵图（七夕使者处领取），无法穿越时光之门。");
		return 0;
	end
	-- 变身,设置任务变量，在跨地图的时候会变,必须跨服才会生效
	local nRand = MathRandom(#tbQiXi2012.SKILLLEVEL_GROP);
	local szMsg = "<color=cyan>你到达前世，看到了那似曾相识的身影，原来这一切早已是命中注定。<color>";
	me.Msg(szMsg);
	pPartner.Msg(szMsg);
	me.SetTask(2192, 34, GetTime());
	me.SetTask(2192, 44, tbQiXi2012.SKILLLEVEL_GROP[nRand][0]);
	pPartner.SetTask(2192, 34, GetTime());
	pPartner.SetTask(2192, 44, tbQiXi2012.SKILLLEVEL_GROP[nRand][1]);
	-- 随机点传送
	local tbValidPos = {};
	for i = 1, #tbQiXi2012.tbTransmitPos do
		if SubWorldID2Idx(tbQiXi2012.tbTransmitPos[i][1]) < 0 then
			tbValidPos[#tbValidPos + 1] = i;
		end
	end
	local nMapIndex = 1;
	if #tbValidPos >= 1 then
		local nRand = MathRandom(#tbValidPos);
		nMapIndex = tbValidPos[nRand];
	end
	me.NewWorld(unpack(tbQiXi2012.tbTransmitPos[nMapIndex]));
	pPartner.NewWorld(unpack(tbQiXi2012.tbTransmitPos[nMapIndex]));
end

function tbNpcHuoDongDaShi:ChangeAward()
	local tbFind = me.FindItemInBags(unpack(tbQiXi2012.ITEMID_AWARDROSE));
	local nCount = #tbFind;
	if nCount <= 0 then
		Dialog:Say("你的背包里没有真爱红玫瑰，无法兑换奖励");
		return 0;
	end
	local nAwardedTimes = me.GetTask(tbQiXi2012.TASK_GROUP_ID, tbQiXi2012.TASK_DAY_AWARD_TIMES);
	local nMaxTims = tbQiXi2012.MAX_AWARD_TIMES_BOY;
	if me.nSex == 1 then
		nMaxTims = tbQiXi2012.MAX_AWARD_TIMES_GIRL;
	end
	local nChangeCount = nMaxTims - nAwardedTimes;
	if nChangeCount < nCount then
		nCount = nChangeCount;
	end
	if nCount <= 0 then
		Dialog:Say(string.format("你今天已经兑换了%s次奖励，无法再兑换", nMaxTims));
		return 0;
	end
	local nConsume = me.ConsumeItemInBags(nCount, tbQiXi2012.ITEMID_AWARDROSE[1], tbQiXi2012.ITEMID_AWARDROSE[2], tbQiXi2012.ITEMID_AWARDROSE[3], tbQiXi2012.ITEMID_AWARDROSE[4], -1);
	if nCount - nConsume <= 0 then
		print("qixi2012", "consume rose fail", me.szName, nCount, nConsume);
		return 0;
	end
	for i = 1, nCount do 
		local tbItem = tbQiXi2012.ITEMID_AWARD_BOYBOX;
		if me.nSex == 1 then
			tbItem = tbQiXi2012.ITEMID_AWARD_GIRLBOX;
		end
		local pItem = me.AddItem(unpack(tbItem));
		if pItem then
			pItem.Bind(1);
			local nDate = tonumber(GetLocalDate("%Y%m%d"));
			local nValidTime = Lib:GetDate2Time(nDate) + 24 * 3600 - 1;
			me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", nValidTime));
			pItem.Sync();
		else
			print("qixi2012", "add box fail", me.szName, me.nSex);
		end
	end
	me.SetTask(tbQiXi2012.TASK_GROUP_ID, tbQiXi2012.TASK_DAY_AWARD_TIMES, nAwardedTimes + nCount);
	Dialog:SendBlackBoardMsg(me, "你用真爱之花兑换了一个许愿灯，快点燃看看吧");
end

function tbNpcHuoDongDaShi:GetQingyuanlibao()
	if tbQiXi2012:CheckIsOpen() ~= 1 then
		Dialog:Say("该活动已结束");
		return;
	end
	local pPartner = tbQiXi2012:GetPartner(me);
	if not pPartner then
		Dialog:Say("请跟你的情侣双人组队过来领取");
		return;
	end
	if me.GetTask(tbQiXi2012.TASK_GROUP_ID, tbQiXi2012.TASK_QINGYUANLIBAO) ~= 0 then
		Dialog:Say("你已经领过礼包了");
		return;
	end
	if pPartner.GetTask(tbQiXi2012.TASK_GROUP_ID, tbQiXi2012.TASK_QINGYUANLIBAO) ~= 0 then
		Dialog:Say("你的情侣已经领过礼包了");
		return;
	end
	local nHasMarry = Marry:CheckQiuhun(me, pPartner);
	if nHasMarry ~= 1 then
		if me.nSex == 0 then
			nHasMarry = KPlayer.CheckRelation(me.szName, pPartner.szName, Player.emKPLAYERRELATION_TYPE_COUPLE);
		else
			nHasMarry = KPlayer.CheckRelation(pPartner.szName, me.szName, Player.emKPLAYERRELATION_TYPE_COUPLE);
		end
	end
	if nHasMarry ~= 1 then
		Dialog:Say("你们两人没有纳吉或以上关系，请纳吉之后再来找我吧");
		return;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你的背包空间不足。");
		return;
	end
	if pPartner.CountFreeBagCell() < 1 then
		Dialog:Say("你的情侣背包空间不足。");
		Dialog:SendBlackBoardMsg(pPartner, "你的背包空间不足");
		return;
	end
	local nNpcMapId, nNpcPosX, nNpcPosY = him.GetWorldPos();
	local nMapId1, nPosX1, nPosY1 = me.GetWorldPos();
	local nMapId2, nPosX2, nPosY2 = pPartner.GetWorldPos();
	if nMapId1 ~= nNpcMapId or nMapId2 ~= nNpcMapId then
		Dialog:Say("你和你的情侣一起过来我才能给你们奖励。");
		return 0;
	end
	if (nPosX1 - nNpcPosX) * (nPosX1 - nNpcPosX) + (nPosY1 - nNpcPosY) * (nPosY1 - nNpcPosY) > tbQiXi2012.MAX_TRANSMIT_RANGE * tbQiXi2012.MAX_TRANSMIT_RANGE or
		(nPosX2 - nNpcPosX) * (nPosX2 - nNpcPosX) + (nPosY2 - nNpcPosY) * (nPosY2 - nNpcPosY) > tbQiXi2012.MAX_TRANSMIT_RANGE * tbQiXi2012.MAX_TRANSMIT_RANGE then
		Dialog:Say("需要两个人都站在我身边我才能给你们奖励。");
		return 0;
	end
	me.SetTask(tbQiXi2012.TASK_GROUP_ID, tbQiXi2012.TASK_QINGYUANLIBAO, 1);
	pPartner.SetTask(tbQiXi2012.TASK_GROUP_ID, tbQiXi2012.TASK_QINGYUANLIBAO, 1);
	local pItem1 = me.AddItem(unpack(tbQiXi2012.ITEMID_QINGYUANLIBAO[me.nSex]));
	if pItem1 then
		pItem1.Bind(1);
		me.SetItemTimeout(pItem1, 30*24*60, 0);
		pItem1.Sync();
	else
		print("qixi2012", "add qingyuanlibao fail", me.szName);
	end
	local pItem2 = pPartner.AddItem(unpack(tbQiXi2012.ITEMID_QINGYUANLIBAO[pPartner.nSex]));
	if pItem2 then
		pItem2.Bind(1);
		pPartner.SetItemTimeout(pItem2, 30*24*60, 0);
		pItem2.Sync();
	else
		print("qixi2012", "add qingyuanlibao fail", pPartner.szName);
	end
	me.SendMsgToFriend(string.format("你的好友[%s]在七夕之际喜结良缘，得到了一个豪华情缘礼包。", me.szName));
	Player:SendMsgToKinOrTong(me, "在七夕之际喜结良缘，得到了一个豪华情缘礼包。", 0);
	pPartner.SendMsgToFriend(string.format("你的好友[%s]在七夕之际喜结良缘，得到了一个豪华情缘礼包。", pPartner.szName));
	Player:SendMsgToKinOrTong(pPartner, "在七夕之际喜结良缘，得到了一个豪华情缘礼包。", 0);
	StatLog:WriteStatLog("stat_info", "qixi_2012", "naji_qixi", me.nId, pPartner.szName, 1);
end

-- 玫瑰种子
local tbNpcSeed = Npc:GetClass("qixi2012_seed");

function tbNpcSeed:OnDialog()
	if tbQiXi2012:CheckIsOpen() ~= 1 then
		Dialog:Say("该活动已结束");
		return;
	end
	local tbSeedInfo = him.GetTempTable("Npc").tbSeedInfo;
	if not tbSeedInfo then
		return;
	end
	if tbSeedInfo.nBoyId ~= me.nId and tbSeedInfo.nGirlId ~= me.nId then
		Dialog:Say("这不是你的玫瑰。");
		return;
	end
	local pPartner = tbQiXi2012:GetPartner(me);
	if not pPartner then
		Dialog:Say("需要与你一起种下玫瑰的情侣组队才能浇灌。");
		return;
	end
	if tbSeedInfo.nBoyId ~= pPartner.nId and tbSeedInfo.nGirlId ~= pPartner.nId then
		Dialog:Say("需要与你一起种下玫瑰的情侣组队才能浇灌。");
		return;
	end
	if tbSeedInfo.nBoyId == me.nId then -- 男的对话
		local szGirlName = tbQiXi2012:GetQianshiName(pPartner);
		local szMsg = string.format("你已为<color=pink>%s<color>种下玫瑰之种。你需要她的帮助去<color=yellow>浇灌出9朵红玫瑰<color>。<enter><enter>提示：<enter><color=red>1.若不小心浇错3次粉玫瑰，将会失败重来。<enter>2.若有种子无法采集，可以收回种子重新种下。<enter>3.15分钟内未完成种子将自动消失。<color>  ", szGirlName);
		local tbOpt = 
		{
			{"浇灌种子", tbQiXi2012.SeedPlant2Rose, tbQiXi2012, him.dwId, me.nId},
			{"回收种子", tbQiXi2012.CancelPlant, tbQiXi2012, him.dwId, me.nId},
			{"Để ta suy nghĩ lại"},	
		};
		Dialog:Say(szMsg ,tbOpt);
	else -- 女的对话
		local szBoyName = tbQiXi2012:GetQianshiName(pPartner);
		local szMsg = string.format("<color=pink>%s<color>已为你种下玫瑰之种，请点击背包内道具“前世·玫瑰阵图（已开启）”，<color=yellow>观察红色玫瑰及粉色玫瑰分布<color>，帮助他浇灌出<color=yellow>9朵红玫瑰。<color><enter><enter><color=red>若不小心浇错出3簇粉玫瑰，将会失败重来<color><enter><color=red>15分钟内未完成种子将自动消失。<color>", szBoyName);
		local tbOpt = 
		{
			{"Ta hiểu rồi"},	
		};
		Dialog:Say(szMsg ,tbOpt);
	end
end

-- 奖励玫瑰
local tbNpcAwardRose = Npc:GetClass("qixi2012_awardrose");

function tbNpcAwardRose:OnDialog()
	if tbQiXi2012:CheckIsOpen() ~= 1 then
		Dialog:Say("该活动已结束");
		return;
	end
	local tbAwardInfo = him.GetTempTable("Npc").tbAwardInfo;
	if not tbAwardInfo then
		return;
	end
	if tbAwardInfo.nBoyId ~= me.nId and tbAwardInfo.nGirlId ~= me.nId then
		Dialog:Say("这不是你的真爱红玫瑰，不能采摘");
		return;
	end
	if tbAwardInfo.nAwardFlag ~= 0 then
		Dialog:Say("你们已经找到了1束真爱之花，快去找纳兰吟心兑换奖励吧。");
		return;
	end
	local pPartner = tbQiXi2012:GetPartner(me);
	if not pPartner then
		Dialog:Say("只有与你的有缘人双人组队且在周围，才能采摘真爱红玫瑰。");
		return 0;
	end
	local szMsg = "你们找到了真爱红玫瑰，采集后可交给纳兰吟心换取奖励。";
	local tbOpt = 
	{
		{"采摘真爱红玫瑰", tbQiXi2012.GetAward, tbQiXi2012, him.dwId, me.nId},
		{"我只是路过"}	
	};
	Dialog:Say(szMsg, tbOpt); 
end
