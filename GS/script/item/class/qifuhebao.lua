-- 文件名　：qifuhebao.lua
-- 创建者　：jiazhenwei

local tbItem = Item:GetClass("qifuhebao");

tbItem.TSK_GROUP 	= 2121;  
tbItem.TSK_ITEM		= 4;
tbItem.TSK_DAY		= 5;
tbItem.TSK_ISGETBUFF = 6;
tbItem.TIME_START	= 20100420;
tbItem.TIME_END		= 20100511;
tbItem.TIME_START_QIANG = 20100501;
tbItem.TIME_END_QIANG = 20100505;
tbItem.ITEM_TIME	= 12* 60; -- 实效
tbItem.DIALOGMSG	= "    千里传心愿任务后，您携带着这个香可以每时每刻为灾区人民敬上自己的一份心意，您也可以得到一定的奖励！";

tbItem.ITEM_AWARD   = {
	[1] = {nSec = 15*60, tbAward = {18,1,80,1},  nCount = 1, szName = "[在线15分钟]领取福袋一个",},
	[2] = {nSec = 60*60, tbAward = {18,1,80,1},  nCount = 3, szName = "[在线60分钟]领取福袋三个",},
	[3] = {nSec = 90*60, tbAward = {18,1,189,1}, nCount = 1, szName = "[在线90分钟]领取酒箱一个",},	
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
	if nDate >= self.TIME_START_QIANG and nDate <= self.TIME_END_QIANG then
		if me.GetTask(self.TSK_GROUP,self.TSK_ISGETBUFF) == 1 then
			table.insert(tbOpt,{"<color=gray>强化优惠奖励<color>",self.GetBuffEquit,self});
		else
			table.insert(tbOpt,{"强化优惠奖励",self.GetBuffEquit,self});
		end
	end
	table.insert(tbOpt,{"Kết thúc đối thoại"});
	Dialog:Say(self.DIALOGMSG, tbOpt); 
end

function tbItem:GetBuffEquit()	
	Dialog:Say("你确定要领取强化优惠吗？", {
		{"确定领取",self.GetBuffEquitEx,self},
		{"Kết thúc đối thoại"}}); 	
end

function tbItem:GetBuffEquitEx()
	if me.GetTask(self.TSK_GROUP,self.TSK_ISGETBUFF) == 1 then
		Dialog:Say("您已经领取过该奖励了。");
		return;
	end	
	me.AddSkillState(892, 1, 1, 5 * 24 * 3600 * Env.GAME_FPS, 1, 0, 1);
	me.SetTask(self.TSK_GROUP,self.TSK_ISGETBUFF,1);	
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
