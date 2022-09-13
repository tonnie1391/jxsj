------------------------------------------------------
-- 文件名　：partnerxisuijing.lua
-- 创建者　：dengyong
-- 创建时间：2009-12-30 14:45:11
-- 描  述  ：重新分配同伴潜能模板的道具
------------------------------------------------------

local tbItem = Item:GetClass("partnerxisuijing");

function tbItem:OnUse()
	if (Partner.bOpenPartner ~= 1) then
		Dialog:Say("Tính năng đồng hành chưa mở.vui lòng thử lại sau");
		return 0;
	end	
	
	self:OnSelectUse(it.dwId);
end

-- 当从OnUse接口调过来的时候，nParam应该是默认参数，bSure为nil
-- 当是自己调用自己时，nParam为同伴索引
function tbItem:OnSelectUse(dwId, nParam, bSure)
	bSure = bSure or 0;
	
	if me.nPartnerCount <= 0 then
		me.Msg("Hiện tại bạn chưa có đồng hành!");
		return 0;
	end
	
	if bSure == 0 then
		local szMsg = "Bạn muốn tẩy điểm tiềm năng cho đồng hành nào:";
		local tbOpt = {};
		for i = 1, me.nPartnerCount do
			local pPartner = me.GetPartner(i - 1);
			if pPartner then
				table.insert(tbOpt, {pPartner.szName, self.OnSelectUse, self, dwId, i - 1, 1});
			end
		end
		
		table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
		Dialog:Say(szMsg, tbOpt);
		
		return 0;
	else
		local pPartner = me.GetPartner(nParam);
		local pItem = KItem.GetObjById(dwId);
		if not pPartner or not pItem then
			return 0;
		end
	
		-- 根据洗髓经的不同而决定不同的提示信息
		local szType = (pItem.GetExtParam(1) == 0) and "tăng ngẫu nhiên" or "tự thiết lập";	
		local szMsg = string.format("Bạn có chắc muốn đồng hành %s %s tiềm năng?", pPartner.szName, szType);
		local tbOpt = 
		{
			{"Xác nhận", self.OnConfirmReset, self, nParam, dwId},
			{"Để ta suy nghĩ thêm"},
		}
	
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	return 1;
end

function tbItem:OnConfirmReset(nPartnerIndex, dwId)
	local pPartner = me.GetPartner(nPartnerIndex);
	local pItem = KItem.GetObjById(dwId);
		
	if not pPartner or not pItem then
		return 0;
	end
				
	if pItem.GetExtParam(1) == 0 then	-- 重新随机潜能模板
		local nPotentialTemp = Partner:RandomPotentialTemp(me);
		self:ResetPotential(pPartner.nPartnerIndex, dwId, nPotentialTemp);
	else	-- 让玩家选择指定的潜能模板
		local szMsg = "请选择潜能模板：";
		local tbOpt = 
		{
			{"Thân Pháp 50%, Ngoại Công 50%", self.ResetPotential, self, pPartner.nPartnerIndex, dwId, 1},
			{"Ngoại Công 50%,Nội Công 50%", self.ResetPotential, self, pPartner.nPartnerIndex, dwId, 2},
			{"Sức mạnh 30%, Thân Pháp 30%, Ngoại Công 40%", self.ResetPotential, self, pPartner.nPartnerIndex, dwId, 3},
			{"Sức mạnh 30%, Thân Pháp 20%, Ngoại Công 50%", self.ResetPotential, self, pPartner.nPartnerIndex, dwId, 4},
			{"Sức mạnh 40%, Thân Pháp 20%, Ngoại Công 40%", self.ResetPotential, self, pPartner.nPartnerIndex, dwId, 5},
			{"Sức mạnh 40%, Thân Pháp 30%, Ngoại Công 30%", self.ResetPotential, self, pPartner.nPartnerIndex, dwId, 6},
			{"Sức mạnh 40%, Thân Pháp 10%, Ngoại Công 50%", self.ResetPotential, self, pPartner.nPartnerIndex, dwId, 7},
			{"Sức mạnh 40%, Thân Pháp 10%, Ngoại Công 10%, Nội Công 40%", self.ResetPotential, self, pPartner.nPartnerIndex, dwId, 8},
			{"Sức mạnh 50%, Thân Pháp 20%, Ngoại Công 30%", self.ResetPotential, self, pPartner.nPartnerIndex, dwId, 9},
			{"Để ta suy nghĩ thêm"},
		};
	
		Dialog:Say(szMsg, tbOpt);
		
		return 0;
	end	
end

function tbItem:ResetPotential(nPartnerIndex, dwId, nPotentialTemp)
	local pPartner = me.GetPartner(nPartnerIndex);
	local pItem = KItem.GetObjById(dwId);
	
	if not pPartner or not pItem then
		return;
	end
	
	local nPotentialTempOrg = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_PotentialTemp); -- 之前的潜能模板ID
	local tbPotentialOrg = {};
	for nAttribIndex = 0, 3 do
		tbPotentialOrg[nAttribIndex] = pPartner.GetAttrib(nAttribIndex);		
	end
	local nPotentialBalanceOrg = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_PotentialPoint);
	
	local nRet = 0;
	nRet = Partner:ResetPartnerPotential(pPartner, nPotentialTemp);
	
	-- 扣除道具
	if nRet ~= 0 then		
		local szItemName = pItem.szName;  --先记录道具的名字，写LOG用
		Partner:ConsumePartnerItem(pItem, me);
		
		local tbPotentialNow = {};
		for nAttribIndex = 0, 3 do
			tbPotentialNow[nAttribIndex] = pPartner.GetAttrib(nAttribIndex);
		end
		-- 洗过之后，剩余未分配的潜能点数
		local nPotentialBalanceNow = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_PotentialPoint);
		
		local szMsg = string.format("%s sử dụng %s, đồng hành %s tiềm năng {%d_%d_%d_%d_%d_%d} trở thành {%d_%d_%d_%d_%d_%d}", 
			me.szName, szItemName, pPartner.szName,
			nPotentialTempOrg, tbPotentialOrg[0], tbPotentialOrg[1], tbPotentialOrg[2], tbPotentialOrg[3],
			nPotentialBalanceOrg,
			nRet, tbPotentialNow[0], tbPotentialNow[1], tbPotentialNow[2], tbPotentialNow[3],
			nPotentialBalanceNow);
			
		Dbg:WriteLog("同伴Log:", szMsg);
		
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_REALTION, szMsg);
		me.Msg(string.format("Đông hành của bạn %s sử dụng %s", pPartner.szName, szItemName));
	end
end
