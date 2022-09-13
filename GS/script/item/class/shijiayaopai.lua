 --武林世家腰牌
--zounan1@kingsoft.com
--2009-09-17 17:16

Require("\\script\\item\\class\\shijiayaopai_def.lua"); --定义的参数太多 故扔到另外一个文件
local tbItem = Item:GetClass("shijiayaopai");  

function tbItem:OnUse()	
	local tbOpt = {
		{"领取修炼时间", self.GetAwardXiulian,self},
		{"领取福袋",self.GetAwardFudai,self},
	};		
	if	me.GetTask(self.TASK_GROUP_ID, self.TASK_WEAPON) == 0 then	--领完不加
		table.insert(tbOpt, {"50级领取极品武器", self.OnGetAwardWeapon, self});
	end
	local nCount = me.GetTask(self.TASK_GROUP_ID, self.TASK_FANGJU_NUM) + me.GetTask(self.TASK_GROUP_ID, self.TASK_SHOUSHI_NUM);  
	if nCount < 4 then									--领完了就不加
		table.insert(tbOpt, {"69级领取极品防具和首饰", self.OnGetAwardEquip, self});
	end
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	local szMsg = "武林世家腰牌是各门派给新进弟子的特殊关怀，除了可以每天领取修炼时间和福袋，达到一定等级还可以领取极品装备。";
	Dialog:Say(szMsg, tbOpt); 

end

function tbItem:GetAwardXiulian()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nTaskDate = me.GetTask(self.TASK_GROUP_ID, self.TASK_DATE_XIULIAN);
	if nTaskDate >= nCurDate then
		Dialog:Say("您今天已经领取过修炼时间了。");
		return;
	end
	local tbXiuLianZhu = Item:GetClass("xiulianzhu");
	if tbXiuLianZhu:GetReTime() >= tbXiuLianZhu.MAX_REMAINTIME then
		Dialog:Say("您的修炼时间已满，不能增加修炼时间！");
		return;
	end
	tbXiuLianZhu:AddRemainTime(60);	
	me.Msg("您的修炼时间增加了<color=green>1小时<color>");
	me.SetTask(self.TASK_GROUP_ID, self.TASK_DATE_XIULIAN, nCurDate);
	Dialog:Say("您获得1小时的修炼时间，可以从修炼珠中开启获得4倍经验。");
end

function tbItem:GetAwardFudai()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nTaskDate = me.GetTask(self.TASK_GROUP_ID, self.TASK_DATE_FUDAI);
	if nTaskDate >= nCurDate then
		Dialog:Say("您今天已经领取过福袋的奖励了。");
		return;
	end 	
	if me.CountFreeBagCell()< self.FUDAI_COUNT then
		Dialog:Say("领取福袋需要2格背包空间，整理下再来。");
		return;
	end
	for i = 1, self.FUDAI_COUNT do
		local pItem = me.AddItem(18, 1, 80, 1);
		if pItem then
			self:WriteLog(pItem.szName);
		end
	end
	me.SetTask(self.TASK_GROUP_ID, self.TASK_DATE_FUDAI, nCurDate);	
	Dialog:Say("您获得了2个福袋，快打开看看有什么好东西。");
end

function tbItem:OnGetAwardWeapon()
	local tbOpt ={
		{"确定领取", self.GetAwardWeapon, self},
		{"Để ta suy nghĩ lại"},
		};
	local szMsg = "当您的级别达到50级时，可以领取门派5级橙色武器。";
	Dialog:Say(szMsg, tbOpt);	
end

function tbItem:GetAwardWeapon()
	if me.nLevel < 50 then
		Dialog:Say("您的级别尚未达到50级。");
		return;
	end
	if me.nRouteId == 0 or me.nFaction == 0 then
		Dialog:Say("您还没选择武功流派，不能领奖。");
		return;
	end
	if me.CountFreeBagCell()< 1 then
		Dialog:Say("领奖需要1格背包空间。");
		return;
	end
	local tbWeaponItem = self.tbWeapon[me.nFaction][me.nRouteId];
	if not tbWeaponItem then
		Dialog:Say("领取失败。");
		return;
	end		
	local nG, nD, nP, nL = unpack(tbWeaponItem);
	local pItem = me.AddItem(nG, nD, nP, nL, -1, self.QIANGHUALEVEL_WEAPON);
	if not pItem then
		Dialog:Say("领取失败。");
		return;
	end
	pItem.Bind(1);
	me.SetTask(self.TASK_GROUP_ID, self.TASK_WEAPON, 1);
	self:WriteLog(pItem.szName);
	Dialog:Say("您获得了一把极品武器，装备上看看吧。");
end

function tbItem:OnGetAwardEquip()
	local tbOpt ={
			{"领取防具", self.OnselectFangju, self},
			{"领取首饰", self.OnselectShoushi, self},
			{"Để ta suy nghĩ lại"},
		}
	local szMsg = "当您的级别达到69级时，您可以领取2件防具和2件首饰。";
	Dialog:Say(szMsg, tbOpt);	
end

function tbItem:OnselectFangju()
	if me.nLevel < 69 then
		Dialog:Say("您的级别尚未达到69级。");
		return;
	end
	if me.nRouteId == 0 or me.nFaction == 0 then
		Dialog:Say("您还没选择武功流派，不能领奖。");
		return;
	end
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_FANGJU_NUM)>= 2 then
		Dialog:Say("防具已经领取完毕。");
		return;
	end	
	local tbOpt  = {};
	local szMsg = "";
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_FANGJU_SEL) == 0 then 
		szMsg = "您可以从以下防具中选择两件，请分两次领取。";
	else
		szMsg = "您还可以从以下防具中选择一件。";
	end
	local tbTemp = {
		{"领取衣服", self.GetAwardEquip, self,1, 1},
		{"领取帽子", self.GetAwardEquip, self,1, 2},
		{"领取腰带", self.GetAwardEquip, self,1, 3},
		{"领取鞋子", self.GetAwardEquip, self,1, 4},
		{"领取护腕", self.GetAwardEquip, self,1, 5},
		};
	for i , tbP  in ipairs(tbTemp) do                         --把已经领取过了的装备剔除
		if i ~= me.GetTask(self.TASK_GROUP_ID, self.TASK_FANGJU_SEL) then
	    	table.insert(tbOpt , tbP);
		end
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg , tbOpt);
end

function tbItem:OnselectShoushi()
	if me.nLevel <69 then
		Dialog:Say("您的级别尚未达到69级。");
		return;
	end
	if me.nRouteId == 0 or me.nFaction == 0 then
		Dialog:Say("请选择修行路线，以便赠送您合适的装备。");
		return;
	end
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_SHOUSHI_NUM)>= 2 then
		Dialog:Say("首饰已经领取完毕。");
		return;
	end
	local tbOpt  = {};
	local szMsg = "";
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_SHOUSHI_SEL) == 0 then 
		szMsg = "您可以从以下首饰中选择两件，请分两次领取。";
	else
		szMsg = "您还可以从以下首饰中选择一件。";
	end
	local tbTemp = {
		{"领取护身符", self.GetAwardEquip, self,2, 1},
		{"领取戒指", self.GetAwardEquip, self,2, 2},
		{"领取腰坠", self.GetAwardEquip, self,2, 3},
		{"领取项链", self.GetAwardEquip, self,2, 4},
		};
	for i , tbP  in ipairs(tbTemp) do                         --把已经领取过了的装备剔除
		if i ~= me.GetTask(self.TASK_GROUP_ID, self.TASK_SHOUSHI_SEL) then
	    	table.insert(tbOpt , tbP);
		end
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg , tbOpt);
end

function tbItem:GetAwardEquip(nType, nSelId)
	if me.CountFreeBagCell()< 1 then
		Dialog:Say("领奖需要1格背包空间。");
		return;
	end
	local pItem = nil;
	if nType == 1 and nSelId <= 2 then  --用衣服和帽子是用门派分类的
		local nG, nD, nP, nL = unpack(self.tbEquip[1][nSelId][me.nFaction][me.nSex][me.nRouteId]);
		pItem = me.AddItem(nG, nD, nP, nL, -1,  self.QIANGHUALEVEL_EQUIP);
	else                               --用五行分类
		local nG, nD, nP, nL = unpack(self.tbEquip[nType][nSelId][me.nSeries][me.nSex]);
		pItem = me.AddItem(nG, nD, nP, nL, -1 , self.QIANGHUALEVEL_EQUIP);
	end	
	if not pItem then
		Dialog:Say("领取失败。");
		return;
	end
	pItem.Bind(1);
	local nCount = me.GetTask(self.TASK_GROUP_ID, self.tbTask[nType][1]); 
	me.SetTask(self.TASK_GROUP_ID, self.tbTask[nType][1], nCount + 1);
	me.SetTask(self.TASK_GROUP_ID, self.tbTask[nType][2], nSelId); 
	tbItem:WriteLog(pItem.szName);
	Dialog:Say("领取成功。");		
end

function tbItem:WriteLog(szName)
	local szMsg = "[活动]增加物品:"..szName;
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szMsg);		
	Dbg:WriteLog(szMsg, me.szName);	
end
