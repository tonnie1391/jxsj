--中秋节
--2008.09.01
--孙多良

Require("\\script\\event\\zhongqiu_jieri\\200809\\zhongqiu2008_def.lua")

local tbEvent = {};
tbEvent = SpecialEvent.ZhongQiu2008;

function tbEvent:CheckTime()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate >= self.TIME_STATE[1] and nDate < self.TIME_STATE[2] then
		return 1;
	end
	return 0;
end

function tbEvent:GetProductSet(pPlayer)
	local tbProductSet = self.PRODUCTSET;
	local nSkillId = Item:GetClass("jiazulingpai").nSkillId;
	local szExtendInfo;

	if pPlayer.GetSkillState(nSkillId) > 0 then
		tbProductSet = self.PRODUCTSET_INKIN;
		szExtendInfo = "<color=yellow>因为您在家族旗帜周围使用该配方进行制造，运气大大提升。<color>"
	end
	return tbProductSet, szExtendInfo;
end

function tbEvent:GetRandomMerial(pPlayer, nNum)
	for i=1, nNum do
		local pItem = pPlayer.AddItem(unpack(self.ITEM_MERIAL[Random(2)+1]));
		if pItem then
			KStatLog.ModifyAdd("zhongqiu", "[产出]"..pItem.szName, "总量", 1);
		end
	end
end

function tbEvent:BossDropItem(pPlayer, nNum)
	for i=1, nNum do
		local nNpcMapId, nNpcPosX, nNpcPosY	= him.GetWorldPos();
		local nItemW = Random(2)+1;
		local pObj = KItem.AddItemInPos(nNpcMapId, nNpcPosX, nNpcPosY, unpack(self.ITEM_MERIAL[nItemW]));
		KStatLog.ModifyAdd("zhongqiu", "[产出]"..KItem.GetNameById(unpack(self.ITEM_MERIAL[nItemW])), "总量", 1);
	end	
end

--按江湖威望领取
function tbEvent:OnAward()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	
	if nData < self.TIME_STATE[1] then
		Dialog:Say([[从9月9日到9月18日24点，江湖威望达到一定值就可以来领取月桂花和莲子粉
			江湖威望30以上：每天可领取两样物品的随机1个
			江湖威望100以上：每天可领取两样物品的随机2个]]);
		return 1;
	end	
	
	if nData >= self.TIME_STATE[2] then
		Dialog:Say("中秋活动已经结束");
		return 1;
	end		
	local nKinId, nKinMemId = me.GetKinMember();
	local szFailDesc = "";
	if nKinId == nil or nKinId <= 0 then
		szFailDesc = "您没有加入家族，没有江湖威望，不能领取中秋月饼制作材料。";
		Dialog:Say(szFailDesc);
		return 1;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		szFailDesc = "您没有加入家族，没有江湖威望，不能领取中秋月饼制作材料。";
		Dialog:Say(szFailDesc);
		return 1;
	end
	local cMember = cKin.GetMember(nKinMemId);
	if not cMember then
		szFailDesc = "您没有加入家族，没有江湖威望，不能领取中秋月饼制作材料。";
		Dialog:Say(szFailDesc);
		return 1;
	end	
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_WEIWANG_AWARD) >= tonumber(GetLocalDate("%Y%m%d")) then
		szFailDesc = "您今天已经领取过了月饼制作材料，请明天再来吧";
		Dialog:Say(szFailDesc);
		return 1;
	end

	local nPlayerId = cMember.GetPlayerId();
	local nRepute = KGCPlayer.GetPlayerPrestige(nPlayerId);
	if nRepute < self.AWARD_WEIWANG[#self.AWARD_WEIWANG][1] then
		Dialog:Say("您的江湖威望不足30，不能在这里领取月饼制作材料");
		return 1;
	end
	
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("您背包空间不足。需要2格背包空间。")
		return 1;
	end	
	
	for _, tbParam in ipairs(self.AWARD_WEIWANG) do
		if nRepute >= tbParam[1] then
			self:GetRandomMerial(me, tbParam[2])
			me.SetTask(self.TASK_GROUP_ID, self.TASK_WEIWANG_AWARD, tonumber(GetLocalDate("%Y%m%d")));
			Dialog:Say(string.format("成功领取了%s个制作材料。", tbParam[2]));
			return 1;
		end
	end
	Dialog:Say("您的江湖威望不足，没有奖励可领取。");
end

