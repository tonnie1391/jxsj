-- 文件名　：dts_merchant.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-27 16:17:18
-- 描  述  ：大逃杀休息阶段刷出的商人

local tbNpc = Npc:GetClass("dataosha_merchant");
tbNpc.BuyRate = {3,3,3,3,1,1,3,3,3,30,10,10}; 	--购买比率，对应底下的道具，table里面的数字是多少个货币换一个道具
tbNpc.Item ={				--物品的gdpl			
	{18,	1,	505,	1},	--回天丹箱
	{18,	1,	497,	1},	--九转还魂丹箱
	{18,	1,	506,	1},	--大补散箱
	{18,	1,	498,	1},	--首乌还神丹箱
	{19,	3,	1,	4},	--蒜茸生菜
	{19,	3,	1,	5},	--玉笛谁家听落梅	
	{18,	1,	499,	1},	--短效护甲片
	{18,	1,	500,	1},	--短效磨刀石
	{18,	1,	501,	1},	--短效五行石
	{18, 	1,	518,	1},	--武器强化卷轴
	{18, 	1,	519,	1},	--防具强化卷轴
	{18, 	1,	520,	1},	--饰品强化卷轴	
	};
tbNpc.BuyLifeRate = 50;	--购买生命条数的价钱
function tbNpc:OnDialog()	
	me.OpenShop(184,3);
	do return end;
	local tbOpt = {
			--{"回天丹      <color=yellow>"..self.BuyRate[1].."<color>货币/个", self.OnOpenShop, self,1},			
			--{"九转还魂丹  <color=yellow>"..self.BuyRate[2].."<color>货币/个", self.OnOpenShop, self, 2},
			--{"大补散      <color=yellow>"..self.BuyRate[3].."<color>货币/个", self.OnOpenShop, self, 3},			
			--{"首乌还神丹  <color=yellow>"..self.BuyRate[4].."<color>货币/个", self.OnOpenShop, self, 4},
			--{"蒜茸生菜    <color=yellow>"..self.BuyRate[5].."<color>货币/个", self.OnOpenShop, self, 5},			
			{"短效护甲片  <color=yellow>"..self.BuyRate[7].."<color>货币/个", self.OnOpenShop, self, 7},
			{"短效磨刀石  <color=yellow>"..self.BuyRate[8].."<color>货币/个", self.OnOpenShop, self, 8},	
			{"短效五行石  <color=yellow>"..self.BuyRate[9].."<color>货币/个", self.OnOpenShop, self, 9},	
			{"武器强化卷轴  <color=yellow>"..self.BuyRate[10].."<color>货币/个", self.OnOpenShop, self, 10},	
			{"防具强化卷轴  <color=yellow>"..self.BuyRate[11].."<color>货币/个", self.OnOpenShop, self, 11},
			{"首饰强化卷轴  <color=yellow>"..self.BuyRate[12].."<color>货币/个", self.OnOpenShop, self, 12},
			{"死亡机会数  <color=yellow>50<color>货币/个", self.BuyLife, self},						
			{"Kết thúc đối thoại"},
		};	
	if DaTaoSha:GetPlayerMission(me).nLevel == 1 then   
		--低级场药菜
		table.insert(tbOpt, 1 ,{"回天丹·箱      <color=yellow>"..self.BuyRate[1].."<color>货币/个", self.OnOpenShop, self,1});
		table.insert(tbOpt, 2 ,{"大补散·箱      <color=yellow>"..self.BuyRate[3].."<color>货币/个", self.OnOpenShop, self, 3});
		table.insert(tbOpt, 3 ,{"蒜茸生菜    <color=yellow>"..self.BuyRate[5].."<color>货币/个", self.OnOpenShop, self, 5});
	else		
		--高级场药菜
		table.insert(tbOpt, 1 ,{"九转还魂丹·箱  <color=yellow>"..self.BuyRate[2].."<color>货币/个", self.OnOpenShop, self, 2} );
		table.insert(tbOpt, 2 ,{"首乌还神丹·箱  <color=yellow>"..self.BuyRate[4].."<color>货币/个", self.OnOpenShop, self, 4} );
		table.insert(tbOpt, 3 ,{"玉笛谁家听落梅    <color=yellow>"..self.BuyRate[6].."<color>货币/个", self.OnOpenShop, self, 6});
	end	
	local nMoneyNum = me.GetItemCountInBags(DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4],nil, -1);
	Dialog:Say("<color=red>"..me.szName.."<color>，您需要购买什么？\n您的货币数量是:<color=yellow>"..nMoneyNum.."<color>",tbOpt);
	return 0;
end

function tbNpc:OnOpenShop(nType)
	local nRate = self.BuyRate[nType];
	local nMoneyNum = me.GetItemCountInBags(DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4],nil, -1);
	--local nMoneyNum = me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_MONEY);
	local nMax = math.floor(nMoneyNum/nRate);
	if nMax > 0 then
		Dialog:AskNumber("请输入购买的数量", nMax, self.OnBuy, self, nType, nRate);
	else
		me.Msg("您的货币不够！");
	end
end

function tbNpc:OnBuy(nType, nRate, nCount)	
	if nCount <= 0 then
		return 0;
	end
	
	local nMoneyNum = me.GetItemCountInBags(DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4],nil, -1);
	if nMoneyNum < nRate * nCount then
		me.Msg("您的货币不够！");
		return;
	end	
	
	if me.CountFreeBagCell() < nCount then
		me.Msg("您的包裹不足。");
		return 0 ;
	end
	local tbItem = self.Item[nType];	
	me.AddStackItem(tbItem[1],tbItem[2],tbItem[3],tbItem[4],nil,nCount);
	--local nMoneyNum = me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_MONEY);
	--nMoneyNum = nMoneyNum - nRate * nCount;
	--me.SetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_MONEY, nMoneyNum);				
	me.ConsumeItemInBags2(nCount * nRate, DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4], nil, -1);
	local tbItemInformation = KItem.GetItemBaseProp(tbItem[1],tbItem[2],tbItem[3],tbItem[4],0);
	if tbItemInformation then 
		local szMsg = string.format("队友<color=yellow>%s<color>在商人处花费 <color=yellow>%s<color> 银币购买了%s个<color=yellow>%s<color>。",
		                                me.szName, nRate * nCount, nCount, tbItemInformation.szName);
		KTeam.Msg2Team(me.nTeamId, szMsg);
	end
end

function tbNpc:BuyLife()
	local nGroupId = DaTaoSha:GetPlayerMission(me):GetPlayerGroupId(me);
	local nLifeCount = DaTaoSha:GetPlayerMission(me).tbGroups[nGroupId].nLifeCount;
	if nLifeCount < DaTaoSha.MIS_LIFE_COUNT then
		Dialog:AskNumber("请输入购买的数量", DaTaoSha.MIS_LIFE_COUNT - nLifeCount , self.BuyLifeEx, self);
	else
		me.Msg("你们队的生命数已经是最高了，不能买了！")
	end
end
function tbNpc:BuyLifeEx(nCount)
	if nCount <= 0 then
		return 0;
	end	
	local nMoneyNum = me.GetItemCountInBags(DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4],nil, -1);
	if nMoneyNum < self.BuyLifeRate * nCount then
		me.Msg("您的货币不够！");
		return;
	end	
	
	local nGroupId = DaTaoSha:GetPlayerMission(me):GetPlayerGroupId(me);
	local nLifeCount = DaTaoSha:GetPlayerMission(me).tbGroups[nGroupId].nLifeCount;
	nLifeCount = nLifeCount + nCount;
	if nLifeCount >  DaTaoSha.MIS_LIFE_COUNT then
		return 0;
	end	
	local szMsg = string.format("队友<color=yellow>%s<color>在商人处花费 <color=yellow>%s<color> 银币购买了%s条命。",
		                                me.szName, self.BuyLifeRate * nCount, nCount);
	KTeam.Msg2Team(me.nTeamId, szMsg);
	me.ConsumeItemInBags2(nCount * self.BuyLifeRate, DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4], nil, -1);
	DaTaoSha:GetPlayerMission(me).tbGroups[nGroupId].nLifeCount = nLifeCount;
	DaTaoSha:GetPlayerMission(me):UpdateBattleMsg(me);	
end
		