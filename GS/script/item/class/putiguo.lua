------------------------------------------------------
-- 文件名　：putiguo.lua
-- 创建者　：dengyong
-- 创建时间：2010-01-05 15:40:46
-- 描  述  ：一个菩提果
------------------------------------------------------

local tbItem = Item:GetClass("putiguo");

tbItem.nLimitLevel 		= 120;	-- 120级以下的同伴不能洗等级
tbItem.nLimitStarLevel  = 6.5;	-- 6.5星以上包括6.5星的同伴洗等级需要去龙五太爷那里申请

function tbItem:OnUse()
	if me.IsAccountLock() == 1 then
		local szMsg = "您的账号处于锁定状态，不可以重生同伴！请先解除锁定。";
		me.Msg(szMsg);
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", szMsg});
		Account:OpenLockWindow(me);
		return 0;
	end
	if Account:Account2CheckIsUse(me, 6) == 0 then
		Dialog:Say("你正在使用副密码登陆游戏，设置了权限控制，无法进行该操作！");
		return 0;
	end
	local szMsg = "使用菩提果会将您的某位120级以上的同伴的重生，使其等级与技能等级恢复到1，<color=yellow>同伴的领悟度和亲密度会恢复成默认值<color>，同时返还可以增加领悟度的同伴精华液（只有两个技能的同伴将不能得到返还）。您要让哪位同伴重生？";
	local tbOpt = {};
	for i = 1, me.nPartnerCount do
		local pPartner = me.GetPartner(i - 1);
		if pPartner and pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL) >= self.nLimitLevel then		-- 80级以下的同伴不能洗等级
			table.insert(tbOpt, {pPartner.szName, self.OnSelectPartner, self, i - 1, it.dwId});
		end
	end
	
	if #tbOpt == 0 then
		Dialog:Say("没有可以重生的120级同伴！");
		return 0;
	end

	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	Dialog:Say(szMsg, tbOpt);
	
	return 0;
end

function tbItem:OnSelectPartner(nIndex, dwId)
	local pPartner = me.GetPartner(nIndex);
	local pItem = KItem.GetObjById(dwId);
	
	if not pPartner or not pItem then
		return;
	end
	
	if Partner:GetSelfStartCount(pPartner) >= self.nLimitStarLevel * 2 then  -- 配置表中的星级是实际星级的2倍
		local nApplyTime = me.GetTask(Partner.TASK_PEEL_PARTNER_GROUPID, Partner.TASK_PEEL_PARTNER_SUBID);
		if nApplyTime == 0 then
			local szMsg = string.format("6.5星级以上的同伴必须在龙五太爷处申请才能重生！", Partner.PEELLIMITSTARLEVEL);
			me.Msg(szMsg);
			me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", szMsg});
			return;
		end
		
		local nDiffTime = GetTime() - nApplyTime;
		if nDiffTime < Partner.PEEL_USABLE_MINTIME then
			local szMsg = string.format("您的同伴正在重生申请中，还有%0.1f小时才可以重生%0.1f星以上的同伴", 
				(Partner.PEEL_USABLE_MINTIME - nDiffTime)/3600, Partner.PEELLIMITSTARLEVEL);
			me.Msg(szMsg);
			me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", szMsg});
			return;
		elseif nDiffTime > Partner.PEEL_USABLE_MAXTIME then
			local szMsg = "您提交的重生申请已经过期，请重新申请";
			me.Msg(szMsg);
			me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", szMsg});
			return;
		end	
	end
	
	local tbRetItem = Partner:CalPeelRetItem(pPartner);
	
	local szMsg = string.format("重生之后，同伴%s保留技能，等级和技能等级都将恢复到1。您将得到以下返还：\n", pPartner.szName);
	for nLevel = 1, 4 do 
		local szItemName = KItem.GetNameById(Partner.tbPartnerJinghua.nGenre, Partner.tbPartnerJinghua.nDetail,
			Partner.tbPartnerJinghua.nParticular, nLevel);
		szMsg = szMsg..string.format("<color=yellow>%d个%s<color>\n", tbRetItem[nLevel] or 0, szItemName);
	end
	
	local tbOpt = 
	{
		{"Xác nhận", self.OnConfirmPeel, self, nIndex, dwId},
		{"Ta chỉ xem qua thôi"},
	}
	
	Dialog:Say(szMsg, tbOpt);
end
	
function tbItem:OnConfirmPeel(nIndex, dwId)
	local pPartner = me.GetPartner(nIndex);
	local pItem = KItem.GetObjById(dwId);
	
	if not pPartner or not pItem then
		return;
	end
	
	if pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL) < self.nLimitLevel then
		return;
	end
	
	-- 在剥离同伴之前，保存这个同伴的相关信息，操作成功后写入到LOG
	local nPartnerId = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_TEMPID);
	local nLevel = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL);
	local nPotentialId = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_PotentialTemp);
	local nPotentialRemained = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_PotentialPoint);
	local nPartnerValue = Partner:GetPartnerValue(pPartner);
	
	local szMsg = string.format("%s使用%s将同伴%s洗成了1级。", me.szName, pItem.szName, pPartner.szName)
	szMsg = szMsg..string.format("%d, %d, %d, %d, %d, %d, %d, %d, %d",
		nPartnerId, nLevel, nPotentialId, nPotentialRemained, pPartner.GetAttrib(0),
		pPartner.GetAttrib(1), pPartner.GetAttrib(2), pPartner.GetAttrib(3),nPartnerValue
		);
		
	for i = 1, pPartner.nSkillCount do
		local tbSkill = pPartner.GetSkill(i - 1);
		szMsg = szMsg..string.format(", {%d, %d}", tbSkill.nId, tbSkill.nLevel);
	end
		
	local nRes, szLog = Partner:PeelPartner(pPartner);
	if nRes ~= 0 then
		szMsg = szMsg.."。"..szLog;
		Dbg:WriteLog("同伴Log:", szMsg);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_REALTION, szMsg);
		
		me.DelItem(pItem);
	end
end
