--春节拜年礼官
--孙多良
--2009.01.06

local tbNpc = Npc:GetClass("spring_liguan")
tbNpc.tbYanHua = {18, 1, 279, 1};

function tbNpc:OnDialog()
	if Esport:CheckState() == 0 then
		Dialog:Say("我只是出来闲逛闲逛。。");		
		return 0;
	end
	
	local szMsg = "新年到来，老人家我到处去拜年，你我有缘此处偶遇，老朽送你个礼物吧。";
	local tbOpt = {
		{"获得新年烟花", self.GetYanHua, self, him.dwId},
		{"获得随机礼物", self.GetGift, self, him.dwId},
		{"Ta chỉ xem qua"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetYanHua(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	
	if me.nLevel < 50 then
		Dialog:Say("我这烟花，阅历不足之人用了几乎没有任何效果，岂不，浪费，待你50级以后再来找我吧。");
		return 0;
	end
	
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nTaskDate = me.GetTask(Esport.TSK_GROUP, Esport.TSK_NEWYEAR_YANHUA);
	if nCurDate <= nTaskDate then
		Dialog:Say("你今天不是已经领取过烟花了，还来骗老朽。");
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你包包里塞满了东西，还能装得下吗？");
		return 0;
	end	
	
	--获得物品奖励；
	local pItem = me.AddItem(unpack(self.tbYanHua));
	if pItem then
		me.SetTask(Esport.TSK_GROUP, Esport.TSK_NEWYEAR_YANHUA, nCurDate);
		pItem.Bind(1);
	end
	Dialog:Say("新年快乐，这是我送给你的礼物，祝您好运连连！");
end

function tbNpc:GetGift(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if me.nLevel < 50 then
		Dialog:Say("这些东西，以你的修为几乎没任何用，暴殄天物，50级后再来吧。");
		return 0;
	end	
	
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nTaskDate = me.GetTask(Esport.TSK_GROUP, Esport.TSK_NEWYEAR_LIGUAN_DAY);
	if nCurDate <= nTaskDate then
		Dialog:Say("领了还想领，老朽并非老眼昏花哦，出来混诚实最重要了，每天只能在我这里领取一次礼物。");
		return 0;
	end	
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你包包里塞满了东西，还能装得下吗？");
		return 0;
	end
	
	--获得物品奖励；
	if Item:GetClass("randomitem"):SureOnUse(14, 0, 0, 0) == 1 then
		me.SetTask(Esport.TSK_GROUP, Esport.TSK_NEWYEAR_LIGUAN_DAY, nCurDate);
		Dialog:Say("新年快乐，这是我送给你的礼物，祝好运连连！");
	end
end
