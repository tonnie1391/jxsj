--GM线上补偿
--孙多良
--2008.12.1
--接口1，在线补偿GC：SpecialEvent.CompensateGM:AddOnLine(szGate, szAccount, szName, nSDate, nEDate, szScript)
--接口2，礼官处领取GC：SpecialEvent.CompensateGM:AddOnNpc(szGate, szAccount, szName, nSDate, nEDate, tbAward)
--szGate: 	 区服号	(可选参数)
--szAccount: 帐号	(可选参数)
--szName:	 角色名	(*必须)
--nSDate:	 开始时间(格式YYYYmmddHHMM或YYYYmmdd),0为默认开启
--nEDate:	 结束时间(格式YYYYmmddHHMM或YYYYmmdd),0为默认一个月
--szScript:	 脚本执行指令,只能检测语法错误,不能检测函数错误,(需自检查);
--tbAward = {
--	tbItem = {0,0,0,0},	--物品Id,默认为空
--	nTimeLimit = 0,	--物品有效期，单位分钟,-1为永久。默认值0为30天
--	nMoney = 0,		--银两,默认为0
--	nBindMoney = 0,	--绑定银两,默认为0
--	nBindCoin = 0,		--绑定金币,默认为0
--	nBind = 0,			--物品是否绑定,默认为0不绑定
--	nNum = 0,		--物品数量,默认为1个
--	nNeedBag = 0,		--叠加物品填写此项则强制需要背包空间，没有该项，则根据物品自动计算（不包括叠加物品）
--	szScript = [[ ]]		--执行的指令,默认为空
--	szDesc = "",		--描述。记录log使用
--
--文件格式（新格式，旧格式还保留）
--	szGate = szGate,
--	szAccount = szAccount,
--	szName = szName,
--	nSDate = 0,
--	nEDate = 0,
--	tbAward ={
--		nMaxMoney 		= nMaxMoney,
--		nMaxBindMoney 	= nMaxBindMoney,
--		nNeedBag 		= nNeedBag,
--		szDesc 			= szDesc,
--		tbAwardEx		= tbAwardEx,
--	}
--
--接口3，删除在线补偿GC：SpecialEvent.CompensateGM:DelOnLine(szGate, szAccount, szName, nLogId, nGcManul, szResult)
--接口4，删除npc补偿GC：SpecialEvent.CompensateGM:DelOnNpc(szGate, szAccount, szName, nLogId, nGcManul, szResult)
--接口5，手动清除过期补偿GC：SpecialEvent.CompensateGM:ClearDateOut()
--nLogId: 补偿编号,每填加一项补偿时都会生成一个编号.可查看log或返回值.
--nGcManul: 是否GC手动删除, 1为手动删除.
--szResult: 原因,记log使用.

SpecialEvent.CompensateGM = SpecialEvent.CompensateGM or {};
local Compensate = SpecialEvent.CompensateGM;

--文件读取加载补偿
function Compensate:LoadFile(szPath,nTaskId)
	local tbbuf = self:ExLoadFile(szPath);
	if not tbbuf then
		return 0;
	end
	local szErrorLog;
	local szReturn = "";
	for i = 1,#tbbuf do 
		szReturn = self:AddOnNpc(tbbuf[i].szGate, tbbuf[i].szAccount, tbbuf[i].szName, tbbuf[i].nSDate, tbbuf[i].nEDate, tbbuf[i].tbAward, nTaskId, 1);
	end
	self:SaveGblBuf();
	
	--如果是单个补偿，马上返回错误信息
	if #tbbuf == 1 and not tonumber(szReturn) then
		szErrorLog = szReturn;
	end
	return szErrorLog or nTaskId;
end

--读文件
function Compensate:ExLoadFile(szPath)
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		print("文件加载错误~~~");
		return;
	end
	local tbBuf = {};
	for nId, tbParam in ipairs(tbFile) do
		local szGate = tbParam.Gatewayname or "";	
		local szAccount = tbParam.Account or "";
		local szName = tbParam.Rolename or "";
		local szDesc = tbParam.Desc or "";
		local nMaxMoney = 0;
		local nMaxBindMoney = 0;
		local nNum = 0;
		local tbAwardEx = {};
		local tbKingEyes = SpecialEvent.CompensateGM.KingEyes;
		for szKey, tbKey in pairs(tbKingEyes.ExeFunList) do
			if tbParam[szKey] and tbParam[szKey] ~= "" then
				local szParam = tbKingEyes:TransParam(szKey, tbParam[szKey]);
				local tbParamT = EventManager.tbFun:SplitStr(szParam);
				if tbKey[4] == 1 then
					nNum = nNum + (tonumber(tbParamT[2]) or 0);
				end
				if tbKey[4] == 2 then
					nMaxMoney = nMaxMoney + (tonumber(tbParamT[1]) or 0);
				end
				if tbKey[4] == 3 then
					nMaxBindMoney = nMaxBindMoney + (tonumber(tbParamT[1]) or 0);
				end
				local szFun = tbKey[2];
				tbAwardEx[szFun] = tbAwardEx[szFun] or {};
				if szParam and szParam ~= "" then
					tbAwardEx[szFun] = tbAwardEx[szFun] or {};
					table.insert(tbAwardEx[szFun], szParam);
				end
			end
		end
		tbBuf[nId] = {
			szGate = szGate,
			szAccount = szAccount,
			szName = szName,
			nSDate = 0,
			nEDate = 0,
			tbAward ={
				nMaxMoney 		= nMaxMoney,
				nMaxBindMoney 	= nMaxBindMoney,
				nNum 			= nNum,
				szDesc 			= szDesc,
				tbAwardEx		= tbAwardEx,
			}
		};
	end
	return tbBuf;
end

function Compensate:GetGblBuf()
	return self.tbGblBuf or {};
end

function Compensate:SetGblBuf(tbBuf)
	self.tbGblBuf = tbBuf;
	if (MODULE_GC_SERVER) then
		SetGblIntBuf(GBLINTBUF_COMPENSATE_GM, 0, 1, tbBuf);
	end
end

function Compensate:SetGblIntBufWithoutSave(tbBuf)
	self.tbGblBuf = tbBuf;
end

function Compensate:SaveGblBuf()
	if (MODULE_GC_SERVER and self.tbGblBuf) then
		SetGblIntBuf(GBLINTBUF_COMPENSATE_GM, 0, 1, self.tbGblBuf);
	end
end

--获得表中元素个数.
function Compensate:CountTableLeng(tbTable)
	local nLeng = 0;
	if type(tbTable) == 'table' then
		for Temp in pairs(tbTable) do
			nLeng = nLeng + 1;
		end
	end
	return nLeng;
end

--增加补偿存档
function Compensate:AddGblBufOnLine(szGate, szAccount, szName, nSDate, nEDate, szScript, bNoMsg)
	local tbBuf = self:GetGblBuf();
	if not tbBuf then
		tbBuf = {};
	end
	if not tbBuf.OnLine then
		tbBuf.OnLine = {};
	end
	if not tbBuf.OnLine[szName] then
		tbBuf.OnLine[szName] = {};
		tbBuf.OnLine[szName].nLogMax = 0;
		tbBuf.OnLine[szName].nCount = 0;
		tbBuf.OnLine[szName].tbScripts = {};
	end
	tbBuf.OnLine[szName].nLogMax = tbBuf.OnLine[szName].nLogMax + 1;
	tbBuf.OnLine[szName].nCount  = tbBuf.OnLine[szName].nCount + 1;
	if tbBuf.OnLine[szName].nLogMax > 10000 then
		tbBuf.OnLine[szName].nLogMax = 1;
	end
	local nLogId = tbBuf.OnLine[szName].nLogMax;
	tbBuf.OnLine[szName].tbScripts[nLogId] = {};
	tbBuf.OnLine[szName].tbScripts[nLogId].szAccount = szAccount;
	tbBuf.OnLine[szName].tbScripts[nLogId].nSDate = nSDate;
	tbBuf.OnLine[szName].tbScripts[nLogId].nEDate = nEDate;
	tbBuf.OnLine[szName].tbScripts[nLogId].szScript = szScript;
	tbBuf.OnLine[szName].tbScripts[nLogId].bNoMsg = bNoMsg;
	Dbg:WriteLog("CompensateGM", "AddOnLine", szGate, szAccount, szName, nSDate, nEDate, nLogId, szScript, bNoMsg);
	self:SetGblBuf(tbBuf);
	if (MODULE_GC_SERVER) then
		GlobalExcute({"SpecialEvent.CompensateGM:AddGblBufOnLine", szGate, szAccount, szName, nSDate, nEDate, szScript, bNoMsg});	
	end
	return nLogId;
end

--增加补偿存档,通过npc
function Compensate:AddGblBufOnNpc(szGate, szAccount, szName, nSDate, nEDate, tbAward, nTaskId, bNotSave)
	local tbBuf = self:GetGblBuf();
	if not tbBuf then
		tbBuf = {};
	end
	if not tbBuf.OnNpc then
		tbBuf.OnNpc = {};
	end
	if not tbBuf.OnNpc[szName] then
		tbBuf.OnNpc[szName] = {};
		tbBuf.OnNpc[szName].nLogMax = 0;
		tbBuf.OnNpc[szName].nCount = 0;
		tbBuf.OnNpc[szName].tbAwards = {};
	end
	tbBuf.OnNpc[szName].nLogMax = tbBuf.OnNpc[szName].nLogMax + 1;
	tbBuf.OnNpc[szName].nCount  = tbBuf.OnNpc[szName].nCount + 1;
	if tbBuf.OnNpc[szName].nLogMax > 10000 then
		tbBuf.OnNpc[szName].nLogMax = 1;
	end
	local nLogId = tbBuf.OnNpc[szName].nLogMax;
	tbBuf.OnNpc[szName].tbAwards[nLogId] = {};
	tbBuf.OnNpc[szName].tbAwards[nLogId].szAccount = szAccount;
	tbBuf.OnNpc[szName].tbAwards[nLogId].nSDate = nSDate;
	tbBuf.OnNpc[szName].tbAwards[nLogId].nEDate = nEDate;
	tbBuf.OnNpc[szName].tbAwards[nLogId].nNum   = 0;
	tbBuf.OnNpc[szName].tbAwards[nLogId].tbAward = tbAward;
	tbBuf.OnNpc[szName].tbAwards[nLogId].nTaskId = nTaskId or 0;
	
	if not tonumber(tbAward.nNeedBag) or tonumber(tbAward.nNeedBag) <= 0 then
		if type(tbAward.tbItem) == "table" and tbAward.tbItem[1]>0 and tbAward.tbItem[2]>0 and tbAward.tbItem[3]>0 then
			tbBuf.OnNpc[szName].tbAwards[nLogId].nNum = (tbAward.nNum or 1);
		end
	else
		tbBuf.OnNpc[szName].tbAwards[nLogId].nNum = tonumber(tbAward.nNeedBag);
	end
	Dbg:WriteLog("CompensateGM", "AddOnNpc", szGate, szAccount, szName, nSDate, nEDate, nLogId, (tbAward.szDesc or ""));
	
	if (bNotSave) then
		self:SetGblIntBufWithoutSave(tbBuf);
	else
		self:SetGblBuf(tbBuf);
	end
		
	if (MODULE_GC_SERVER) then
		local szDate = os.date("%Y年%m月%d日", Lib:GetDate2Time(nEDate));
		SendMailGC(szName, "物品领取提示", string.format("   你好，你有物品可到礼官处领取，你的物品项是：<color=yellow>%s<color>。请马上到礼官处领取你的物品，过期将会无效。\n\n<color=red>领取截止时间至%s<color>",tbAward.szDesc or "", szDate))
		GlobalExcute({"SpecialEvent.CompensateGM:AddGblBufOnNpc", szGate, szAccount, szName, nSDate, nEDate, tbAward, nTaskId});	
	end
	return nLogId;
end

--删除补偿名单
function Compensate:DelOnLine(szGate, szAccount, szName, nLogId, nGcManul, szResult)
	if not szResult then
		szResult = "正常领取删除";
	end	
	szGate = (szGate and string.upper(szGate));
	szAccount = (szAccount and string.upper(szAccount));
	local tbBuf = self:GetGblBuf();
	if not tbBuf.OnLine or not tbBuf.OnLine[szName] then
		return 0;
	end
	local tbScripts = tbBuf.OnLine[szName].tbScripts;
	if not tbScripts or not tbScripts[nLogId] then
		return 0;
	end
	tbBuf.OnLine[szName].nCount = tbBuf.OnLine[szName].nCount - 1;
	local nSDate = tbScripts[nLogId].nSDate;
	local nEDate = tbScripts[nLogId].nEDate;
	local szScript = tbScripts[nLogId].szScript;
	tbScripts[nLogId] = nil;
	if tbBuf.OnLine[szName].nCount <= 0 then
		tbBuf.OnLine[szName] = nil;
	end

	self:SetGblBuf(tbBuf);
	
	--指令首次GC执行删除，同步给GS
	if nGcManul == 1 and MODULE_GC_SERVER then
		GlobalExcute({"SpecialEvent.CompensateGM:DelOnLine", szGate, szAccount, szName, nLogId, 0 ,szResult});
	end
	Dbg:WriteLog("CompensateGM", "DelOnLine", tostring(szGate), tostring(szAccount), tostring(szName), tostring(nSDate), tostring(nEDate), tostring(szScript), tostring(szResult), tostring(nLogId));
	return nLogId;
end

--删除补偿名单通过npc
function Compensate:DelOnNpc(szGate, szAccount, szName, nLogId, nGcManul, szResult)
	if not szResult then
		szResult = "正常领取删除";
	end
	szGate = (szGate and string.upper(szGate)) or 0;
	szAccount = (szAccount and string.upper(szAccount)) or 0;
	local tbBuf = self:GetGblBuf();
	if not tbBuf.OnNpc or not tbBuf.OnNpc[szName] then
		return 0;
	end
	local tbAwards = tbBuf.OnNpc[szName].tbAwards;
	if not tbAwards or not tbAwards[nLogId] then
		return 0;
	end
	tbBuf.OnNpc[szName].nCount = tbBuf.OnNpc[szName].nCount - 1;
	local nSDate = tbAwards[nLogId].nSDate;
	local nEDate = tbAwards[nLogId].nEDate;
	local tbAward = tbAwards[nLogId].tbAward;
	tbAwards[nLogId] = nil;
	if tbBuf.OnNpc[szName].nCount <= 0 then
		tbBuf.OnNpc[szName] = nil;
	end
	
	self:SetGblBuf(tbBuf);
	--指令首次GC执行删除，同步给GS
	if nGcManul == 1 and MODULE_GC_SERVER then
		GlobalExcute({"SpecialEvent.CompensateGM:DelOnNpc", szGate, szAccount, szName, nLogId, 0, szResult});
	end
	Dbg:WriteLog("CompensateGM", "DelOnNpc",tostring(szGate), tostring(szAccount), tostring(szName), tostring(nSDate), tostring(nEDate), tostring(tbAward.szDesc), tostring(szResult), tostring(nLogId));
	return nLogId;
end

function Compensate:ClearBlank(szStr)
	local nSafe = 0; 	--安全。防止死循环，最多只执行50次。
	repeat
		nSafe = nSafe + 1;
		local ni = string.find(szStr, " ") or 0
		if ni and ni > 0 then
			szStr = string.sub(szStr,1, ni-1) .. string.sub(szStr,ni+1);
		end
	until(ni <= 0 or nSafe > 50)
	return szStr;
end

------------------------MODULE_GC_SERVER---------------------
if (MODULE_GC_SERVER) then
	
function Compensate:StartEvent()
	self.tbGblBuf = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_COMPENSATE_GM, 0);
	if tbBuf and type(tbBuf)=="table"  then
		self.tbGblBuf = tbBuf;
	end
end

--GC数据同步给GS
function Compensate:OnRecConnectMsg(nConnectId)
	if self.tbGblBuf then
		for szkey, tbInfo in pairs(self.tbGblBuf) do
			for szName, tbParam in pairs(tbInfo) do
				--Dbg:WriteLog("OnRecConnectMsg", nConnectId, szkey, szName);
				GSExcute(nConnectId, {"SpecialEvent.CompensateGM:OnRecConnectMsg", szkey, szName, tbParam});
			end
		end
	end
end

--手动清除过期补偿
function Compensate:ClearDateOut()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	local szGate = string.upper(GetGatewayName());
	local tbOnNpcDels = {};
	local tbOnLineDels = {};
	if self.tbGblBuf and self.tbGblBuf.OnNpc then
		for szName, tbParam in pairs(self.tbGblBuf.OnNpc) do
			if tbParam.tbAwards then
				for nLogId, tbAward in pairs(tbParam.tbAwards) do
					if nCurDate >= tbAward.nEDate and tbAward.nEDate > 0 then
						table.insert(tbOnNpcDels, {szAccount = szAccount, szName = szName, nLogId = nLogId});
					end
				end
			end
		end
	end
	if self.tbGblBuf and self.tbGblBuf.OnLine then
		for szName, tbParam in pairs(self.tbGblBuf.OnLine) do
			if tbParam.tbScripts then
				for nLogId, tbScript in pairs(tbParam.tbScripts) do
					if nCurDate >= tbScript.nEDate and tbScript.nEDate > 0 then
						table.insert(tbOnLineDels, {szAccount = szAccount, szName = szName, nLogId = nLogId});
					end
				end
			end
		end
	end
	for _, tbDel in pairs(tbOnLineDels) do
		--过期删除
		GlobalExcute({"SpecialEvent.CompensateGM:DelOnLine", szGate, tbDel.szAccount, tbDel.szName, tbDel.nLogId, 0, "过期没领取手动删除"});
		SpecialEvent.CompensateGM:DelOnLine(szGate, tbDel.szAccount, tbDel.szName, tbDel.nLogId, 0, "过期没领取手动删除");
	end	
	for _, tbDel in pairs(tbOnNpcDels) do
		--过期删除
		GlobalExcute({"SpecialEvent.CompensateGM:DelOnNpc", szGate, tbDel.szAccount, tbDel.szName, tbDel.nLogId, 0, "过期没领取手动删除"});
		SpecialEvent.CompensateGM:DelOnNpc(szGate, tbDel.szAccount, tbDel.szName, tbDel.nLogId, 0, "过期没领取手动删除");			
	end
	print("在线补偿过期清除","清除数量:", #tbOnLineDels + #tbOnNpcDels);
	return #tbOnLineDels + #tbOnNpcDels;
end

--清楚所有补偿记录
function Compensate:GmGmdDelAllAddOnNpc(szName)
	local tbBuf = self:GetGblBuf();
	if not tbBuf.OnNpc or not tbBuf.OnNpc[szName] then
		return "不存在该玩家补偿数据："..szName;
	end
	local tbAwards = tbBuf.OnNpc[szName].tbAwards;
	local szMsg = "\n删除结果：\n"
	for nLogId, tbs in pairs(tbAwards)do
		local szDesc = tbs.tbAward.szDesc;
		SpecialEvent.CompensateGM:DelOnNpc("", "", szName, nLogId, 1, "平台指令删除");
		szMsg = szMsg .."删除ID："..nLogId .."\t补偿："..szDesc.."\n";	
	end
	return szMsg;
end

--清楚单个补偿记录
function Compensate:GmGmdDelSignleAddOnNpc(szName, nLogId)
	local tbBuf = self:GetGblBuf();
	if not tbBuf.OnNpc or not tbBuf.OnNpc[szName] then
		return "不存在该玩家补偿数据："..szName;
	end
	local tbAwards = tbBuf.OnNpc[szName].tbAwards;
	if not tbAwards[nLogId] then
		return "不存在该玩家Id的补偿数据："..nLogId;
	end
	local szDesc = tbAwards[nLogId].tbAward.szDesc;
	SpecialEvent.CompensateGM:DelOnNpc("", "", szName, nLogId, 1, "平台指令删除");
	return "指令执行成功，玩家："..szName.."\tID号:"..nLogId.."\t补偿："..szDesc;
end

--查询补偿记录
function Compensate:GmGmdQueryAddOnNpc(szName)
	local tbBuf = self:GetGblBuf();
	if not tbBuf.OnNpc or not tbBuf.OnNpc[szName] then
		return "不存在该玩家补偿数据："..szName;
	end
	local tbAwards = tbBuf.OnNpc[szName].tbAwards;
	local szMsg = "\n玩家补偿数据：\n";
	for nLogId, tbs in pairs(tbAwards) do
			szMsg = szMsg .."ID号："..nLogId .."\t补偿："..tbs.tbAward.szDesc.."\n";	
	end

	return szMsg;
end

--在线补偿
function Compensate:AddOnLine(szGate, szAccount, szName, nSDate, nEDate, szScript, bNoMsg)
	if not szName or not tonumber(nSDate) or not tonumber(nEDate) or not szScript then
		return "error: param nil";
	end
	if not szAccount or (szAccount and self:ClearBlank(szAccount) == "") then
		szAccount = "";
	end
	if not szGate or (szGate and self:ClearBlank(szGate) == "") then
		szGate = "";
	end
	szAccount = string.upper(szAccount);
	szGate = string.upper(szGate);
	
	if szGate ~= "" and string.upper(GetGatewayName()) ~= szGate then
		return 0;
	end
	
	szName = self:ClearBlank(szName);
	local szFun = loadstring(szScript);
	if not szFun or type(szFun) ~= "function" then
		return "error: loadstring Syntax Error";
	end	
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	if not nPlayerId or nPlayerId <= 0 then
		return "role not exist:"..szName;
	end
	if tonumber(nEDate) > 0 then
		if string.len(nEDate) == 8 then
			nEDate = tonumber(nEDate) * 10000 + 2400;
		end
		if string.len(nEDate) ~= 12 then
			return "error: nEDate param Error";
		end
	elseif tonumber(nEDate) == 0 then
		nEDate = tonumber(os.date("%Y%m%d%H%M", GetTime() + 30 * 24 * 3600));
	end
	if tonumber(nSDate) > 0 then
		if string.len(nSDate) == 8 then
			nEDate = tonumber(nSDate) * 10000;
		end
		if string.len(nSDate) ~= 12 then
			return "error: nSDate param Error";
		end
	end
	local nLogId = self:AddGblBufOnLine(szGate, szAccount, szName, tonumber(nSDate), tonumber(nEDate), szScript, bNoMsg);
	GlobalExcute({"SpecialEvent.CompensateGM:AddOnLine", szGate, szAccount, szName});
	return nLogId;
end

--补偿通过npc
function Compensate:AddOnNpc(szGate, szAccount, szName, nSDate, nEDate, tbAward, nTaskId, bNotSave)
	if not szName or not tonumber(nSDate) or not tonumber(nEDate) or not tbAward then
		return "error: param nil";
	end
	nTaskId = nTaskId or 0;
	if type(tbAward.tbItem) == "table" then
		tbAward.tbItem[1] = tbAward.tbItem[1] or 0;
		tbAward.tbItem[2] = tbAward.tbItem[2] or 0;
		tbAward.tbItem[3] = tbAward.tbItem[3] or 0;
		tbAward.tbItem[4] = tbAward.tbItem[4] or 0;
	end
	
	if tbAward.szScript then
		local szFun = loadstring(tbAward.szScript);
		if not szFun or type(szFun) ~= "function" then
			return "error: loadstring Syntax Error";
		end
	end
	
	if not szAccount or (szAccount and self:ClearBlank(szAccount) == "") then
		szAccount = "";
	end
	if not szGate or (szGate and self:ClearBlank(szGate) == "") then
		szGate = "";
	end	
	szAccount = string.upper(szAccount);
	szGate = string.upper(szGate);
	if szGate ~= "" and string.upper(GetGatewayName()) ~= szGate then
		return 0;
	end
	szName = self:ClearBlank(szName);
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	if not nPlayerId or nPlayerId <= 0 then
		Dbg:WriteLog("CompensateGM", "AddOnNpcMsg", "role not exist:"..szName);
		return "role not exist:"..szName;
	end
	if tonumber(nEDate) > 0 then
		if string.len(nEDate) == 8 then
			nEDate = tonumber(nEDate) * 10000 + 2400;
		end
		if string.len(nEDate) ~= 12 then
			return "error: nEDate param Error";
		end
	elseif tonumber(nEDate) == 0 then
		nEDate = tonumber(os.date("%Y%m%d%H%M", GetTime() + 30 * 24 * 3600));
	end
	
	if tonumber(nSDate) > 0 then
		if string.len(nSDate) == 8 then
			nEDate = tonumber(nSDate) * 10000;
		end
		if string.len(nSDate) ~= 12 then
			return "error: nSDate param Error";
		end
	end
	local nLogId = self:AddGblBufOnNpc(szGate, szAccount, szName, tonumber(nSDate), tonumber(nEDate), tbAward, nTaskId, bNotSave);
	return nLogId;
end


GCEvent:RegisterGCServerStartFunc(SpecialEvent.CompensateGM.StartEvent, SpecialEvent.CompensateGM);
GCEvent:RegisterGCServerStartFunc(SpecialEvent.CompensateGM.ClearDateOut, SpecialEvent.CompensateGM);

end



------------------------MODULE_GAMESERVER---------------------
if (MODULE_GAMESERVER) then

--GC数据同步给GS
function Compensate:OnRecConnectMsg(szkey, szName, tbParam)
	if not self.tbGblBuf then
		self.tbGblBuf = {};
	end
	if not self.tbGblBuf[szkey] then
		self.tbGblBuf[szkey] = {};
	end
	self.tbGblBuf[szkey][szName] = tbParam;
end

function Compensate:AddOnLine(szGate, szAccount, szName)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	local tbBuf = self:GetGblBuf();
	if not tbBuf or not tbBuf.OnLine or not tbBuf.OnLine[szName] then
		return
	end
	local tbScripts = tbBuf.OnLine[szName].tbScripts;
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	if not nPlayerId or nPlayerId <= 0 then
		print("role not exist:"..szName);
		Dbg:WriteLog("CompensateGM", "AddOnLineMsg", "role not exist:"..szName);
		return "role not exist:"..szName;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	for nLogId, tbScript in pairs(tbScripts) do
		--过期删除
		if nCurDate >= tbScript.nEDate and tbScript.nEDate > 0 then
			GlobalExcute({"SpecialEvent.CompensateGM:DelOnLine", szGate, szAccount, szName, nLogId, 0, "过期没领取自动删除"});
			GCExcute({"SpecialEvent.CompensateGM:DelOnLine", szGate, szAccount, szName, nLogId, 0, "过期没领取自动删除"});			
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_COMPENSATE, string.format("AddOnLine:过期删除\t%s\tLogId：%s",(tbScript.szScript or ""), nLogId));
		end

		if nCurDate >= tbScript.nSDate and nCurDate < tbScript.nEDate then
			if (not tbScript.szAccount or tbScript.szAccount == "" or szAccount == tbScript.szAccount) then
				Setting:SetGlobalObj(pPlayer);
				local szFun = loadstring(tbScript.szScript);
				if szFun and type(szFun) == "function" then
					Lib:CallBack{szFun};
					if not tbScript.bNoMsg then
						pPlayer.Msg("<color=yellow>成功进行了在线给予奖励，补偿，修复或GM操作。想了解更详细事项请与客服进行联系。<color>");
					end
				end
				Setting:RestoreGlobalObj();
				SpecialEvent.CompensateGM:DelOnLine(szGate, szAccount, szName, nLogId);
				GlobalExcute({"SpecialEvent.CompensateGM:DelOnLine", szGate, szAccount, szName, nLogId});
				GCExcute({"SpecialEvent.CompensateGM:DelOnLine", szGate, szAccount, szName, nLogId});
				Dbg:WriteLog("CompensateGM", "SuccessOnLine", szGate, szAccount, szName, tbScript.nSDate, tbScript.nEDate, tbScript.szScript, nLogId);
				pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_COMPENSATE, string.format("AddOnLine:成功领取\t%s\tLogId：%s",(tbScript.szScript or ""), nLogId));
			end
		end
	end
end

function Compensate:OnLogin()
	local szGate = string.upper(GetGatewayName());
	local szAccount = string.upper(me.szAccount);
	local szName = me.szName;
	self:AddOnLine(szGate, szAccount, szName);
end

--领取补偿通过npc
function Compensate:AddOnNpc(szGate, szAccount, szName)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	local tbBuf = self:GetGblBuf();
	if not tbBuf or not tbBuf.OnNpc or not tbBuf.OnNpc[szName] then
		return
	end
	local tbAwards = tbBuf.OnNpc[szName].tbAwards;
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	if not nPlayerId or nPlayerId <= 0 then
		print("role not exist:"..szName);
		return "role not exist:"..szName;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	for nLogId, tbAward in pairs(tbAwards) do
		--过期删除
		if nCurDate >= tbAward.nEDate and tbAward.nEDate > 0 then
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_COMPENSATE, string.format("AddOnNpc:过期删除\t%s\tLogId：%s",(tbAward.szDesc or ""), nLogId));
			GlobalExcute({"SpecialEvent.CompensateGM:DelOnNpc", szGate, szAccount, szName, nLogId, 0, "过期没领取自动删除"});
			GCExcute({"SpecialEvent.CompensateGM:DelOnNpc", szGate, szAccount, szName, nLogId, 0, "过期没领取自动删除"});			
		end

		if nCurDate >= tbAward.nSDate and nCurDate < tbAward.nEDate then
			if (not tbAward.szAccount or tbAward.szAccount == "" or szAccount == tbAward.szAccount) then
				local szDesc			= tbAward.tbAward.szDesc or "";				
				local nMoney 			= tonumber(tbAward.tbAward.nMoney) or 0;
				local nBindMoney 		= tonumber(tbAward.tbAward.nBindMoney) or 0;
				local nBindCoin			= tonumber(tbAward.tbAward.nBindCoin) or 0;
				local nBind 			= tonumber(tbAward.tbAward.nBind) or 0;
				local nTimeLimit 		= tonumber(tbAward.tbAward.nTimeLimit) or 0;
				local nNum 				= tonumber(tbAward.tbAward.nNum) or 1;
				local tbAwardItem 		= tbAward.tbAward.tbItem;
				--local nNeedBag 			= tonumber(tbAward.nNum) or 0;	//使用自检
				local tbAwardEx			= tbAward.tbAward.tbAwardEx;
				local nMaxMoney 		= tonumber(tbAward.tbAward.nMaxMoney) or 0;
				local nMaxBindMoney 	= tonumber(tbAward.tbAward.nMaxBindMoney) or 0;
				local nLogTaskId		= tonumber(tbAward.nTaskId) or 0;
				local nNeedBag 		= tonumber(tbAward.tbAward.nNeedBag) or 0;
				nMaxMoney 		= nMaxMoney + nMoney;
				nMaxBindMoney 	= nMaxBindMoney + nBindMoney;
				
				--local nNeedBag = 0;
				if type(tbAwardItem) == "table" then
					nNeedBag = nNeedBag + KItem.GetNeedFreeBag(tbAwardItem[1], tbAwardItem[2], tbAwardItem[3], tbAwardItem[4], {bTimeOut=nTimeLimit}, nNum);
				end
				
				if tbAwardEx then
					for szFun, tbParam in pairs(tbAwardEx) do
						for _, szParam in pairs(tbParam) do
							local nCheck, szMsg = SpecialEvent.CompensateGM.KingEyes:CheckFun(szFun, szParam)
							if nCheck == 1 then
								Dialog:Say(szMsg);
								return 0;
							end
						end
					end
				end
				
				if pPlayer.CountFreeBagCell() < nNeedBag then
					Dialog:Say(string.format("对不起，您的背包空间不够，请整理一下背包再来领取。您需要<color=red>%s格<color>背包空间。", nNeedBag));
					return 0;
				end

				if nBindMoney + pPlayer.GetBindMoney() > pPlayer.GetMaxCarryMoney() then
					Dialog:Say(string.format("对不起，您现在要领取<color=yellow>%s绑定银两<color>，您身上的绑定银两将会达到上限，请整理后再来领取。", nBindMoney));
					return 0;		
				end
				if nMoney + pPlayer.nCashMoney > pPlayer.GetMaxCarryMoney() then
					Dialog:Say(string.format("对不起，您现在要领取<color=yellow>%s银两<color>，您身上的银两将会达到上限，请整理后再来领取。", nMoney));
					return 0;
				end
				
				--先删除再给奖励
				SpecialEvent.CompensateGM:DelOnNpc(szGate, szAccount, szName, nLogId);
				GlobalExcute({"SpecialEvent.CompensateGM:DelOnNpc", szGate, szAccount, szName, nLogId});
				GCExcute({"SpecialEvent.CompensateGM:DelOnNpc", szGate, szAccount, szName, nLogId});
				Dbg:WriteLog("CompensateGM", "SuccessOnNpcFirst", szGate, szAccount, szName, tbAward.nSDate, tbAward.nEDate, szDesc, nLogId);
				--先删除再给奖励
	
				if nMoney > 0 then
					pPlayer.Earn(nMoney, Player.emKEARN_ERROR_REAWARD)
					Compensate:WriteLog(pPlayer,"在线补偿OnNpc：领取银两："..nMoney);
				end
				
				if nBindMoney > 0 then
					pPlayer.AddBindMoney(nBindMoney, Player.emKBINDMONEY_ADD_ERROR_REAWARD);
					Compensate:WriteLog(pPlayer,"领取绑定银两："..nBindMoney);
				end
				
				if nBindCoin > 0 then
					pPlayer.AddBindCoin(nBindCoin, Player.emKBINDCOIN_ADD_ERROR_REAWARD);
					Compensate:WriteLog(pPlayer,string.format("领取绑定%s：%s",IVER_g_szCoinName, nBindCoin));			
				end

				if type(tbAwardItem) == "table" and tbAwardItem[1] > 0 and tbAwardItem[2] > 0 and tbAwardItem[3] > 0 then
					for i=1, nNum do
						local nG, nD, nP, nL = unpack(tbAwardItem)
						local pItem = pPlayer.AddItemEx(nG, nD, nP, nL, {bForceBind=nBind});
						if pItem then
							if nTimeLimit ~= -1 then
								if nTimeLimit > 0 then
									pPlayer.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 60 * nTimeLimit));
								else
									--默认有效期30天
									pPlayer.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 60 * 43200));
								end
								pItem.Sync();
							end
							local szItem = string.format("%s,%s,%s,%s",unpack(tbAwardItem));
							self:WriteLog(pPlayer,"在线补偿OnNpc领取物品成功 物品ID："..szItem);
						end
					end
				end
				
				if tbAward.tbAward.szScript then
					Setting:SetGlobalObj(pPlayer);
					local szFun = loadstring(tbAward.tbAward.szScript);
					if szFun and type(szFun) == "function" then
						Lib:CallBack{szFun};
					end
					Setting:RestoreGlobalObj();
				end	
				--新的一套
				Setting:SetGlobalObj(pPlayer);
				if tbAwardEx then
					for szFun, tbParam in pairs(tbAwardEx) do
						for _, szParam in pairs(tbParam) do
							EventManager:ExeszFun(szFun, szParam);
						end
					end
				end
				Setting:RestoreGlobalObj();
				--end 新的一套
				
				Dbg:WriteLog("CompensateGM", "SuccessOnNpc", szGate, szAccount, szName, tbAward.nSDate, tbAward.nEDate, szDesc, nLogId);
				Setting:SetGlobalObj(pPlayer);
				Dialog:Say("成功领取了物品。");
				Setting:RestoreGlobalObj();
				pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_COMPENSATE, string.format("AddOnNpc:成功领取\t%s\tLogId：%s\tTaskId:%s",szDesc, nLogId, nLogTaskId));
				return 0;
			end
		end
	end
	Dialog:Say("对不起，您没有物品可领取。");
end

function Compensate:OnAwardNpc(nFlag)
	local szGate = string.upper(GetGatewayName());
	local szAccount = string.upper(me.szAccount);
	local szName = me.szName;
	local nCount, tbAward = self:CheckOnNpc();
	if nCount <= 0 then
		Dialog:Say("您没有物品可领。");
		return 0;
	end
	if not nFlag then
		local szMsg = string.format("您一共有<color=yellow>%s项<color>物品可以领取。", nCount);
		local nAwardDesc = 0;
		for nId, tbTemp in ipairs(tbAward) do
			if tbTemp.szDesc ~= "" then
				if nAwardDesc == 0 then
					szMsg = szMsg .. "物品内容如下：\n";
					nAwardDesc = 1;
				end
				szMsg = szMsg .. string.format("<color=yellow>%s  .%s<color>\n", nId, tbTemp.szDesc);
			end
		end
		szMsg = szMsg .."\n你确定要领取第一项物品吗？";
		local tbOpt = {
			{"领取第一项物品", self.OnAwardNpc, self, 1},
			{"结束对话"},
			};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	self:AddOnNpc(szGate, szAccount, szName);	
end

function Compensate:CheckOnNpc()
	local szGate = string.upper(GetGatewayName());
	local szAccount = string.upper(me.szAccount);
	local szName = me.szName;
	local nCurDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	local tbBuf = self:GetGblBuf();
	if not tbBuf or not tbBuf.OnNpc or not tbBuf.OnNpc[szName] then
		return 0;
	end
	local tbAwards = tbBuf.OnNpc[szName].tbAwards;
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	if not nPlayerId or nPlayerId <= 0 then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbMyAward = {};
	for nLogId, tbAward in pairs(tbAwards) do
		--过期删除
		if nCurDate >= tbAward.nEDate then
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_COMPENSATE, string.format("AddOnNpc:过期删除\t%s\tLogId：%s",(tbAward.szDesc or ""), nLogId));
			GlobalExcute({"SpecialEvent.CompensateGM:DelOnNpc", szGate, szAccount, szName, nLogId,  0, "过期没领取自动删除"});
			GCExcute({"SpecialEvent.CompensateGM:DelOnNpc", szGate, szAccount, szName, nLogId,  0, "过期没领取自动删除"});			
		end
		
		if nCurDate >= tbAward.nSDate and nCurDate < tbAward.nEDate then
			if (not tbAward.szAccount or tbAward.szAccount == "" or szAccount == tbAward.szAccount) then
				table.insert(tbMyAward, {nLogId = nLogId, szDesc = tbAward.tbAward.szDesc});
			end
		end
	end
	return #tbMyAward, tbMyAward;
end

function Compensate:WriteLog(pPlayer, szMsg)
	Dbg:WriteLog("SpecialEvent.CompensateCommon", "补偿", pPlayer.szAccount, pPlayer.szName, szMsg);
end

PlayerEvent:RegisterOnLoginEvent(SpecialEvent.CompensateGM.OnLogin, SpecialEvent.CompensateGM);

end
