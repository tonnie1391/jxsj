-- 文件名　：aprilevent_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-04-06 14:24:06
--越南4月活动道具

--水袋子
local tbShuiDai	= Item:GetClass("shuidaizi_vn");

function tbShuiDai:OnUse()
	if me.nLevel < 65 then
		Dialog:Say("您等级不足65级！",{"知道了"});
		return 0;
	end	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống<color=yellow>1格<color>！");
		return 0;
	end	
	local nFlag = Item:GetClass("randomitem"):SureOnUse(188, 2147, 0, 0, 41, 40, 15, 39, 100, it);
	if nFlag == 1 then
		local nAllCount_s = me.GetTask(2147, 39);
		local nAllCount_g = me.GetTask(2147, 42);
		if nAllCount_s >= SpecialEvent.tbAprilEvent_vn.nMaxAllCount and nAllCount_g >= SpecialEvent.tbAprilEvent_vn.nMaxAllCount then
			me.AddSkillState(892, 1, 1, 24 *3600*18, 1, 0, 1);
			me.Msg("恭喜您使用水袋子和干粮袋子都达到上限，获得强化优惠奖励。");
		end
	end
	return nFlag;
end

--干粮袋子
local tbGanliang = Item:GetClass("ganliangdaizi_vn");
tbGanliang.tbShanZhenHaiWei = {18,1,1268,1};		--山珍海味

function tbGanliang:OnUse()
	if me.nLevel < 65 then
		Dialog:Say("您等级不足65级！",{"知道了"});
		return 0;
	end
	if me.CountFreeBagCell() < 3 then
		Dialog:Say("Hành trang không đủ chỗ trống<color=yellow>3格<color>！");
		return 0;
	end
	local nFlag = Item:GetClass("randomitem"):SureOnUse(189, 2147, 0, 0, 41, 40, 15, 42, 100, it);
	if nFlag == 1 then
		local nAllCount_s = me.GetTask(2147, 39);
		local nAllCount_g = me.GetTask(2147, 42);
		if nAllCount_s >= SpecialEvent.tbAprilEvent_vn.nMaxAllCount and nAllCount_g >= SpecialEvent.tbAprilEvent_vn.nMaxAllCount then
			me.AddSkillState(892, 1, 1, 24 *3600*18, 1, 0, 1);
			me.Msg("恭喜您使用水袋子和干粮袋子都达到上限，获得强化优惠奖励。");
		end
		me.AddItem(unpack(self.tbShanZhenHaiWei));
		local nRate = MathRandom(1,10000);
		if nRate <= SpecialEvent.tbAprilEvent_vn.nRandom_BX then
			me.AddWaitGetItemNum(1);
			GCExcute({"SpecialEvent.tbEventFun_vn:IsGetHorse", me.nId, 1});
		end
	end
	return nFlag;
end

--功勋箱
local tbGongXun = Item:GetClass("GongXunXiang_vn");
tbGongXun.tbYanHua = {18,1,1275,1};		--烟花

function tbGongXun:OnUse()
	if me.nLevel < 65 then
		Dialog:Say("您等级不足65级！",{"知道了"});
		return 0;
	end
	if me.CountFreeBagCell() < 3 then
		Dialog:Say("Hành trang không đủ chỗ trống<color=yellow>3格<color>！");
		return 0;
	end
	local nFlag = Item:GetClass("randomitem"):SureOnUse(190, 0, 0, 0, 0, 0, 0, 0, 0, it);
	if nFlag == 1 then
		me.AddItem(unpack(self.tbYanHua));
		local nRate = MathRandom(1,100000);
		if nRate <= SpecialEvent.tbAprilEvent_vn.nRandom_FY then
			me.AddWaitGetItemNum(1);
			GCExcute({"SpecialEvent.tbEventFun_vn:IsGetHorse", me.nId, 2});
		end
	end
	return nFlag;
end

--凯旋酒
local tbKaiXuan	= Item:GetClass("kaixuan_vn");
tbKaiXuan.tbShanZhenHaiWei	= {18, 1, 1268, 1};	--山珍海味
tbKaiXuan.tbYanHua			= {18, 1, 1275, 1};	--烟花
tbKaiXuan.tbZhengDuoLing		= {18, 1, 1273, 1};	--争夺令

function tbKaiXuan:OnUse()
	if me.nLevel < 65 then
		Dialog:Say("您等级不足65级！",{"知道了"});
		return 0;
	end
	if me.CountFreeBagCell() < 3 then
		Dialog:Say("Hành trang không đủ chỗ trống<color=yellow>3格<color>！");
		return 0;
	end
	local tbFindS = me.FindItemInBags(unpack(self.tbShanZhenHaiWei));
	if not tbFindS[1] then
		Dialog:Say("你没有山珍海味。！");
		return 0;
	end
	local tbFindY = me.FindItemInBags(unpack(self.tbYanHua));
	if not tbFindY[1] then
		Dialog:Say("你没有烟花");
		return 0;
	end
	--检查周围是不是有白秋林
	if self:CheckArroundHaveBai() == 0 then
		Dialog:Say("你没在白秋林旁边。");
		return 0;
	end
	local nFlag = Item:GetClass("randomitem"):SureOnUse(191, 2147, 0, 0, 44, 43, 20, 45, 100, it);
	if nFlag == 1 then
		me.ConsumeItemInBags2(1, self.tbShanZhenHaiWei[1], self.tbShanZhenHaiWei[2], self.tbShanZhenHaiWei[3],self.tbShanZhenHaiWei[4]);
		me.ConsumeItemInBags2(1, self.tbYanHua[1], self.tbYanHua[2], self.tbYanHua[3],self.tbYanHua[4]);
		me.CastSkill(307, 1, -1, me.GetNpc().nIndex);
		local pItem = me.AddItem(unpack(self.tbZhengDuoLing));
		if pItem then
			pItem.SetTimeOut(0, GetTime() + 30 *24 *3600);
			pItem.Sync();
		end
		local nRate = MathRandom(1,100000);
		if nRate <= SpecialEvent.tbAprilEvent_vn.nRandom_QhYt then
			me.AddWaitGetItemNum(1);
			GCExcute({"SpecialEvent.tbAprilEvent_vn:IsGetHorse_QhYt", me.nId, 2});
		end
	end
	return nFlag;
end

function tbKaiXuan:CheckArroundHaveBai() 
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == 3570 then
			return 1;
		end
	end
	return 0;
end
