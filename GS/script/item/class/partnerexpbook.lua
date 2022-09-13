------------------------------------------------------
-- 文件名　：partnerexpbook.lua
-- 创建者　：zhaoyu
-- 创建时间：2009-12-15 17:02:08
-- 描  述  ：同伴经验书
------------------------------------------------------
local tbItem = Item:GetClass("partnerexpbook");

-- 获得的经验比率
tbItem.tbRate =
{-- 已吃道具个数，  对应比例
	{10, 3*0.5},
	{40, 0.5},
}

-- 记录玩家吃了多少本经验书的任务变量索引
tbItem.nTask	 = 2112;
tbItem.nSubTask  = 1;
tbItem.nDateTask  = 2;
tbItem.nLastTime = 7 * 24 * 3600;	-- 同伴经验书最多可以持续一周
tbItem.nCount = 40;		--每天吃的上限
tbItem.nCountOtherExp = 10;		--每天前多少本给额外经验

function tbItem:OnUse()
	if (Partner.bOpenPartner ~= 1) then
		Dialog:Say("现在同伴活动已经关闭，无法使用物品");
		return 0;
	end
	
	if me.nPartnerCount == 0 then
		Dialog:Say("您当前并没有同伴需要同伴经验书。");
		return 0;
	end
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()))
	local nDate = me.GetTask(self.nTask, self.nDateTask);	   -- 日期
	if nCurDate ~= nDate then
		me.SetTask(self.nTask, self.nSubTask, 0)
		me.SetTask(self.nTask, self.nDateTask, nCurDate);
	end
	
	local nTimes = me.GetTask(self.nTask, self.nSubTask);	   -- 已经吃过的个数 
		
	local nCount = self.nCount;
	local nSetCount = KGblTask.SCGetDbTaskInt(DBTASK_DAY_PARTNEREXPBOOK_COUNT);
	if nSetCount ~= 0 then
		nCount = nSetCount;
	end	
	if nTimes >= nCount then
		me.Msg(string.format("您今天已经给同伴使用了%s个同伴经验书，无法再使用了。", nCount));
		return;
	end
	
	local tbOpt = {};
	for i = 0, me.nPartnerCount - 1 do
		local pPartner = me.GetPartner(i);
		if pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL) < Partner.MAXLEVEL and
			pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_EXP) < Partner:GetMaxStoreExp(pPartner) then
				
			local szMsg = pPartner.szName;
			local nExp = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_EXP);
			local nExpAfterBook = self:GetExpFromBook(pPartner);
			
			szMsg = szMsg..string.format("（%d → <color=yellow>%d<color>）", nExp, nExpAfterBook);
			table.insert(tbOpt, {szMsg, self.OnSelectPartner, self, it.dwId, i});
		end
	end
	if #tbOpt == 0 then
		Dialog:Say("您当前并没有同伴需要同伴经验书。");
		return;
	end
	
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	Dialog:Say("请选择给以下哪位同伴增加经验。<color=yellow>每个同伴最多只能积累10级的经验<color>", tbOpt);		
end

-- 返回吃经验书后得得到的经验。
function tbItem:GetExpFromBook(pPartner)
	local nRate = 0;
	for _, tbData in pairs(self.tbRate) do
		if me.GetTask(self.nTask, self.nSubTask) < tbData[1] then
			nRate = tbData[2];
			break;
		end
	end
	
	local nLevel = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL);
	local nBookExp = nRate * self:GetBaseExp(nLevel);	-- 经验书提供的经验
	
	local nMaxStoreExp = Partner:GetMaxStoreExp(pPartner);
	local nCurExp = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_EXP);
	
	return (nCurExp + nBookExp) > nMaxStoreExp and nMaxStoreExp or (nCurExp + nBookExp);
end

function tbItem:OnSelectPartner(nItemId, nPartnerIndex)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	local pOwner = pItem.GetOwner();  -- pItem.GetOwner() 可能为nil; zounan
	if not pOwner or pOwner.nId ~= me.nId then 
		return;
	end
	
	local pPartner = me.GetPartner(nPartnerIndex);
	if not pPartner then
		return;
	end
	
	local nBookExp = self:GetExpFromBook(pPartner);
	local nRet, varMsg = Partner:AddExp(pPartner, nBookExp - pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_EXP));
	if nRet ~= 1 then
		me.Msg(varMsg);
		return;
	end
	
	local nCount = self.nCount;
	local nSetCount = KGblTask.SCGetDbTaskInt(DBTASK_DAY_PARTNEREXPBOOK_COUNT);
	if nSetCount ~= 0 then
		nCount = nSetCount;
	end	
	
	local nAddedExp = varMsg;	-- 返回的是实际增加的经验
	local nTimes = me.GetTask(self.nTask, self.nSubTask);
	local szMsg = string.format("您的同伴%s增加了%d点经验。您今天共计给同伴使用了<color=yellow>%d<color>本同伴经验书。您每天能给同伴使用<color=yellow>%s<color>本，前<color=yellow>%s<color>本可获得额外经验。",
		pPartner.szName, nAddedExp,  nTimes + 1, nCount, self.nCountOtherExp);	
	me.Msg(szMsg);
	
	-- 设置任务变量记录吃了多少本经验书
	me.SetTask(self.nTask, self.nSubTask, nTimes + 1);
	Dbg:WriteLog("同伴Log:", me.szName, "使用", pItem.szName, "增加同伴经验：", nAddedExp);

	-- 扣除物品
	me.DelItem(pItem);
end

-- 获取经验书的基准经验
function tbItem:GetBaseExp(nPartnerLevel)
	local nKey = math.floor(nPartnerLevel / 10) * 10 + 9;
	local nExp = 0;
	if not Partner.tbPartnerExpBook[nKey] then
		Dbg:WriteLog("同伴经验书", string.format("角色[%s]传入了同伴等级[%d]，不合法！", me.szName, nPartnerLevel));
		nKey = 9;
	end
	
	return Partner.tbPartnerExpBook[nKey];		
end

function tbItem:InitGenInfo()
	-- 设定同伴经验书的有效期限, 绝对时间
	it.SetTimeOut(0, GetTime() + self.nLastTime);
	return	{ };
end