local tbItem = Item:GetClass("qm_taqinghebao");

tbItem.TSK_GROUP 	= 2093;  
tbItem.TSK_ITEM		= 19;
tbItem.TSK_DAY		= 20;
tbItem.TIME_START	= 20100330;
tbItem.TIME_END		= 20100407;
tbItem.ITEM_TIME	= 12* 60; -- 实效
tbItem.DIALOGMSG	= "3月30日-4月7日，开放“饮酒狂欢福袋大赠送”活动，每日在线一定时长可获得时效为12小时的道具奖励";

tbItem.ITEM_AWARD   = {
	[1] = {nSec = 15*60, tbAward = {18,1,80,1},  nCount = 1, szName = "[在线15分钟]领取福袋一个",},
	[2] = {nSec = 30*60, tbAward = {18,1,189,1}, nCount = 1, szName = "[在线30分钟]领取酒箱一个",},
	[3] = {nSec = 45*60, tbAward = {18,1,80,1},  nCount = 2, szName = "[在线45分钟]领取福袋两个",},
	[4] = {nSec = 60*60, tbAward = {18,1,189,1}, nCount = 2, szName = "[在线60分钟]领取酒箱两个",},	
	};
	
function tbItem:OnUse()	
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.TIME_START then
		Dialog:Say("活动尚未开始呢。");
		return;
	end
	if nDate > self.TIME_END then
		Dialog:Say("活动已经结束啦。");
		return;
	end	
	local nTskItem = nil;
	if me.GetTask(self.TSK_GROUP,self.TSK_DAY) ~= nDate then
		me.SetTask(self.TSK_GROUP,self.TSK_DAY,nDate);
		me.SetTask(self.TSK_GROUP,self.TSK_ITEM,0);
		nTskItem = 0;
	else
		nTskItem = me.GetTask(self.TSK_GROUP,self.TSK_ITEM);	
	end	
		
	local nOnLineTime = GetTime() -  me.GetTask(2063,2);
	local tbOpt = {};
	for i , tbAward in ipairs(self.ITEM_AWARD) do
		if nOnLineTime < tbAward.nSec or Lib:LoadBits(nTskItem,i,i) == 1  then
			table.insert(tbOpt,{string.format("<color=gray>%s<color>",tbAward.szName),self.OnAward,self,i});
		else
			table.insert(tbOpt,{tbAward.szName,self.OnAward,self,i});
		end
	end		
	table.insert(tbOpt,{"Kết thúc đối thoại"});
	Dialog:Say(self.DIALOGMSG, tbOpt); 
end

function tbItem:OnAward(nPos)
	local nTskItem = nil;
	local nDate = tonumber(GetLocalDate("%Y%m%d"));	
	if me.GetTask(self.TSK_GROUP,self.TSK_DAY) ~= nDate then
		me.SetTask(self.TSK_GROUP,self.TSK_DAY,nDate);
		me.SetTask(self.TSK_GROUP,self.TSK_ITEM,0);
		nTskItem = 0;
	else
		nTskItem = me.GetTask(self.TSK_GROUP,self.TSK_ITEM);	
	end		
		
	local tbAward = self.ITEM_AWARD[nPos];
	
	if not tbAward then
		return;
	end
	
	if Lib:LoadBits(nTskItem,nPos,nPos) == 1 then
		Dialog:Say("您已经领取过该奖励了。");
		return;
	end			
	
	if 	(GetTime() -  me.GetTask(2063,2)) < tbAward.nSec then
		Dialog:Say("角色在线时间还不够长哦，不能领取该奖励。");
		return;
	end
			
	if 	me.CountFreeBagCell() < tbAward.nCount  then
		Dialog:Say("您的包裹空间不足。");
		return;
	end	
	nTskItem = Lib:SetBits(nTskItem, 1, nPos, nPos);
	me.SetTask(self.TSK_GROUP,self.TSK_ITEM,nTskItem);	
	for i = 1 , tbAward.nCount do
		local pItem = me.AddItem(unpack(tbAward.tbAward));
		if pItem then
			pItem.Bind(1);
			me.SetItemTimeout(pItem, self.ITEM_TIME, 0);
		end	
	end	
end
