-- 文件名  : TaobaoCooperate_gc.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-09-03 17:12:38
-- 描述    :  淘宝合作活动

if not MODULE_GC_SERVER then
	return;
end

SpecialEvent.tbTaobaoCooperate = SpecialEvent.tbTaobaoCooperate or {};
local tbTaobaoCooperate = SpecialEvent.tbTaobaoCooperate;

function tbTaobaoCooperate:SaveBuffer_GC()	
	SetGblIntBuf(GBLINTBUF_TAOBAOCOOPERATE, 0, 1, self.tbTaoBaoInfo);
	GlobalExcute({"SpecialEvent.tbTaobaoCooperate:LoadBuffer_GS"});
end

function tbTaobaoCooperate:SaveBuffer2_GC(nKey, szCode)
	if not self.tbTaoBaoInfo[nKey] then
		return;		
	end
	self.tbTaoBaoInfo[nKey][szCode] = 1;
	self:SaveBuffer_GC();
end

function tbTaobaoCooperate:LoadBuffer_GC()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_TAOBAOCOOPERATE, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbTaoBaoInfo = tbBuffer;
	end
end

function tbTaobaoCooperate:CanGetAward(dwId, nPlayerId, nKey)
	--红包代金券需要仲裁，绑银福袋不需要仲裁
	local szCode = self:GetCanUseCode(nKey);
	local nCountBox = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_TAOBAO_LIHE);
	if szCode ~= "" or nKey >= 8 then
		GlobalExcute({"SpecialEvent.tbTaobaoCooperate:OnUse", dwId, nPlayerId, 2, nKey, szCode});
		self:SaveBuffer2_GC(nKey, szCode);
		return;
	elseif nCountBox < self.nMaxTaoBox and nKey == 1 then
		KGblTask.SCSetDbTaskInt(DBTASD_EVENT_TAOBAO_LIHE, nCountBox + 1);
	end
	GlobalExcute({"SpecialEvent.tbTaobaoCooperate:OnUse", dwId, nPlayerId, 2, nKey});
end

function tbTaobaoCooperate:GetCanUseCode(nKey)
	if not self.tbTaoBaoInfo[nKey] then
		return "";
	end
	for szCode, nFlag in pairs(self.tbTaoBaoInfo[nKey]) do
		if nFlag == 0 then
			return szCode;
		end
	end
	return "";
end

function tbTaobaoCooperate:ReadTaobaoCooperate(szFileName)
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【在线领取】读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then	
			local nType = tonumber(tbParam.nType) or 0;
			local szCode  = tbParam.szCode or "";
			local szGateway = tbParam.szGateway or "";
			if GetGatewayName() == szGateway or szGateway == "" then
				if not self.tbTaoBaoInfo then
					self.tbTaoBaoInfo = {};
				end
				if nType ~= 0 and not self.tbTaoBaoInfo[nType] then
					self.tbTaoBaoInfo[nType] = {};
				end
				if szCode ~= "" and not self.tbTaoBaoInfo[nType][szCode] then
					self.tbTaoBaoInfo[nType][szCode] = 0;
					--table.insert(self.tbTaoBaoInfo[nType], szCode);
				end
			end
		end
	end
	self:SaveBuffer_GC();
	return 1;
end

GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbOldPlayerBack.LoadBuffer_GC, SpecialEvent.tbOldPlayerBack);