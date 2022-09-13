-------------------------------------------------------------------
--File: fuliguan.lua
--Author: zhengyuhua
--Date: 2008-3-17 14:23
--Describe: 福利官npc脚本
-------------------------------------------------------------------
local tbFuLiGuan = Npc:GetClass("fuliguan");

tbFuLiGuan.nCreatPlayerLimit = 20120912;

function tbFuLiGuan:OnDialog()
	local tbOpt = {};
--		{
--			{"查看纳税详情", self.Demand, self},
--			--{"申请本周福利资格", self.ApplyWelfare, self},
--			--{"领取上周福利", self.TakeWelfare, self},
--			{"Kết thúc đối thoại"}
--		};
	
	tbOpt[#tbOpt + 1] = {"查看纳税详情", self.Demand, self};
	
	local nCreatTime = me.GetRoleCreateDate();
	if (me.nLevel >= 50 and nCreatTime < self.nCreatPlayerLimit) then
		tbOpt[#tbOpt + 1] = {"领取降装备等级需求状态", self.GetEquipBuff, self};
	end
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};
	Dialog:Say("你好，有什么事吗？", tbOpt);
end

function tbFuLiGuan:GetEquipBuff()
	local nLevel = me.GetSkillState(2859);
	if (nLevel > 0) then
		Dialog:Say("你的降装备等级需求状态还在，请状态消失后再来领取！");
		return 0;
	end

	me.AddSkillState(2859, 1, 1, 100 * 24 * 60 * 60 * 18, 1, 0, 1);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[活动]增加技能buff：%s",2859));
	EventManager:WriteLog(string.format("[活动]增加技能buff,%s",2859), me);
end

function tbFuLiGuan:ApplyWelfare()
	local nRet = TradeTax:ApplyWelfare(me);
	if nRet ~= 1 then
		if nRet == 0 then
			Dialog:Say("你的江湖威望不够"..TradeTax.MIN_WEIWANG.."，不能申请领取福利");
			return 0; 
		elseif nRet == 2 then
			Dialog:Say("你已经申请过了")
		elseif nRet == 3 then
			Dialog:Say("你上周的福利还没领取，不能申请本周福利资格，请先领取上周福利");
		end
		return 0;
	end
	Dialog:Say("你已获得领取本周福利的资格，请于下周一至下周日之间来领取，过期不候哟!");
end

function tbFuLiGuan:TakeWelfare(bConfirm)
	if bConfirm == 1 then
		TradeTax:TakeWelfare(me, 1);
		return 0;
	end
	local nWelfare = TradeTax:TakeWelfare(me);
	if nWelfare < 0 then
		if nWelfare == -1 then
			Dialog:Say("你上周未申请领取福利资格或者你已经领取，不能再领了");
		end
		return 0;
	end
	local szMsg = string.format("你上周的福利是%s两，请收好。如果想要领取本周福利，请先申请本周福利资格", nWelfare);
	Dialog:Say(szMsg,
		{
			{"Xác nhận", self.TakeWelfare, self, 1};
		});
end

function tbFuLiGuan:Demand()
	TradeTax:Check(me);
	
	TradeTax:CheckTaxReagion();
		
	local nRemain = 0;
	local nTaxCount = 0;
	local nAmount = me.GetTask(TradeTax.TAX_TASK_GROUP, TradeTax.TAX_AMOUNT_TASK_ID);	-- 本周交易额
	if nAmount > TradeTax.TAX_REGION[1][1] then
		nTaxCount = me.GetTask(TradeTax.TAX_TASK_GROUP, TradeTax.TAX_ACCOUNT_TASK_ID)
	else
		nRemain = TradeTax.TAX_REGION[1][1] - nAmount;
	end
	local nTaxRate = 0;
	for i = 1, #TradeTax.TAX_REGION do
		if nAmount >= TradeTax.TAX_REGION[i][1] then
			if TradeTax.TAX_REGION[i + 1] then
				nTaxRate = TradeTax.TAX_REGION[i + 1][2];
			else
				--nTaxRate = TradeTax.TAX_REGION[i][2];
				nTaxRate = TradeTax.TAX_REGION_MAXNUMBER; --最后的一个税率
			end
		end
	end
	local szMsg = string.format("你本周的免税额还有<color=red>%s<color>两，纳税额是<color=red>%s<color>两，目前的税率是<color=red>%s<color>", nRemain, nTaxCount, nTaxRate*100).."%";
	Dialog:Say(szMsg);
end

