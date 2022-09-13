-- 文件名　：kinskill.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-06-07 10:28:08
--家族技能
--------------------------------MODULE_GC_SERVER--------------------------------------
if MODULE_GAMECLIENT then
	return;
end

Require("\\script\\kin\\kinskill_def.lua");

--获取技能等级
function Kin:GetSkillLevel(nKinId, nGenreId, nDetailId, nSkillId)
	if not self.tbKinSkill.tbSkillInfo[nGenreId] or not self.tbKinSkill.tbSkillInfo[nGenreId][nDetailId] or not self.tbKinSkill.tbSkillInfo[nGenreId][nDetailId][nSkillId] then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	
	local nTaskId = self.tbKinSkill.tbSkillInfo[nGenreId][nDetailId][nSkillId].nTaskId;
	if nTaskId <= 0 then
		return 0;
	end
	local nSkillLevel = cKin.GetTask(nTaskId);
	local nPassive = self.tbKinSkill.tbSkillInfo[nGenreId][nDetailId][nSkillId].nPassive;		--被动技能，这里根据经验决定等级
	local tbSkillLevel = loadstring(self.tbKinSkill.tbSkillInfo[nGenreId][nDetailId][nSkillId].szLevelTable)();
	if nPassive == 1 and tbSkillLevel and type(tbSkillLevel) == "table" then
		nSkillLevel = self:GetSkillLevelEx(nSkillLevel, tbSkillLevel);		--特殊的都统一这样处理，变量上记录的总经验值
	end
	return nSkillLevel;
end

function Kin:GetSkillLevelEx(nSkillLevel, tbSkillLevel)
	for nLevel, nExp in pairs(tbSkillLevel) do
		if nExp >= nSkillLevel then
			return nLevel;
		end
	end
	return 0;
end

function Kin:CheckSkillLevel(nKinId, tbSkillInfo)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local nLevel = cKin.GetSkillLevel();
	
	if not self.tbKinSkill.tbSkillInfo then
		return 0;
	end
	
	--加的对应的点技能符合要求
	local nMaxPoint = 0;
	for _, tbSkillInfoEx in pairs(tbSkillInfo) do
		if not self.tbKinSkill.tbSkillInfo[tbSkillInfoEx[1]] or not self.tbKinSkill.tbSkillInfo[tbSkillInfoEx[1]][tbSkillInfoEx[2]] or not self.tbKinSkill.tbSkillInfo[tbSkillInfoEx[1]][tbSkillInfoEx[2]][tbSkillInfoEx[3]] or not self.tbKinSkill.tbSkillInfo[tbSkillInfoEx[1]][tbSkillInfoEx[2]][tbSkillInfoEx[3]].tbCondition then
			return 0;
		end
		local tbCondition = self.tbKinSkill.tbSkillInfo[tbSkillInfoEx[1]][tbSkillInfoEx[2]][tbSkillInfoEx[3]].tbCondition;
		local nSkillTaskId = self.tbKinSkill.tbSkillInfo[tbSkillInfoEx[1]][tbSkillInfoEx[2]][tbSkillInfoEx[3]].nTaskId;
		local nSkillLevel = cKin.GetTask(nSkillTaskId);
		local nSkillLevelNow = nSkillLevel + tbSkillInfoEx[4];
		if not tbCondition[nSkillLevelNow] or tbCondition[nSkillLevelNow] == -1 or tbCondition[nSkillLevelNow] > nLevel then
			return 0;
		end
		nMaxPoint = nMaxPoint + tbSkillInfoEx[4];
	end
	--剩余的点够加
	local nUsePoint = cKin.GetUsePoint();
	local nRemainPoint = nLevel - nUsePoint;
	if nMaxPoint <= 0 or nRemainPoint < nMaxPoint then
		return 0;
	end
	return 1;
end

if  MODULE_GC_SERVER then

--加技能经验
function Kin:AddSkillExp_GC(nKinId, nNum)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then		
		return 0
	end
	local nLevel = cKin.GetSkillLevel() + 1;
	local nNowExp = cKin.GetSkillExp();	
	if not self.tbKinSkill.tbLevelExp[nLevel] then		
		return 0;
	end
	local nExp = nNum;	
	while nExp > 0 do
		if self.tbKinSkill.tbLevelExp[nLevel] and self.tbKinSkill.tbLevelExp[nLevel] > 0  then
			if  nExp + nNowExp >= self.tbKinSkill.tbLevelExp[nLevel] then
				nExp = nExp - (self.tbKinSkill.tbLevelExp[nLevel] - nNowExp);
				nNowExp = 0;
				nLevel = nLevel + 1;				
			else
				nNowExp =nNowExp + nExp;
				nExp = 0;				
			end
		elseif self.tbKinSkill.tbLevelExp[nLevel] == 0 then			
			nExp = 0;
			nLevel = #self.tbKinSkill.tbLevelExp;
		end
	end	
	cKin.SetSkillLevel(nLevel - 1);
	cKin.SetSkillExp(nNowExp);	
	GlobalExcute{"Kin:SetSkillInfo_GS", nKinId, nLevel - 1, nNowExp};
	return 1;
end

--设置家族技能点
function Kin:AddSkillLevel_GC(szPlayerName, nKinId, tbSkillInfo)
	local nRet = Kin:CheckSkillLevel(nKinId, tbSkillInfo);	
	if nRet == 0 then		
		GlobalExcute{"Kin:AddSkillLevelError_GS", szPlayerName};
		return 0;
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local nLevel = cKin.GetSkillLevel();
	local nMaxPoint = 0;
	for _, tbSkillInfoEx in pairs(tbSkillInfo) do
		local nTaskId = self.tbKinSkill.tbSkillInfo[tbSkillInfoEx[1]][tbSkillInfoEx[2]][tbSkillInfoEx[3]].nTaskId;
		cKin.SetTask(nTaskId, tbSkillInfoEx[4]);
		nMaxPoint = nMaxPoint + tbSkillInfoEx[4];
	end
	cKin.SetUsePoint(cKin.GetUsePoint()  + nMaxPoint);	
	GlobalExcute{"Kin:AddSkillLevel_GS", szPlayerName, nKinId, tbSkillInfo};
end

--洗技能点
function Kin:RefreshSkillPoint_GC(nKinId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local nPoint = 0;
	for _, tbSkillG in pairs(self.tbKinSkill.tbSkillInfo) do
		for _, tbSkillD in pairs(tbSkillG) do
			for _, tbSkillS in pairs(tbSkillD) do
				nPoint = nPoint + cKin.GetTask(tbSkillS.nTaskId);
				cKin.SetTask(tbSkillS.nTaskId, 0);
			end
		end
	end
	cKin.SetUsePoint(0);
	GlobalExcute{"Kin:RefreshSkillPoint_GS2", nKinId};
end

function Kin:SetSkillInfo_GC(nKinId, nLevel, nNowExp)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end	
	cKin.SetSkillLevel(nLevel);
	cKin.SetSkillExp(nNowExp);
	--Msg to kin	
	GlobalExcute{"Kin:SetSkillInfo_GS", nKinId, nLevel, nNowExp};
end

-------------------------------------------test-------------------------------------
function Kin:ShowKinSkill(nKinId)	
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local tbSkillInfo = {};
	print("--------------------------华丽的分割线--------------------------------")
	local nLevel = cKin.GetSkillLevel();
	print("家族技能："..nLevel);
	local nUsePoint = cKin.GetUsePoint();
	print("家族技能使用的点数："..nUsePoint);
	local nExp = cKin.GetSkillExp();
	print("家族技能当前经验值："..nExp);
	for i, tbSkillG in pairs(self.tbKinSkill.tbSkillInfo) do
		for j, tbSkillD in pairs(tbSkillG) do
			for k, tbSkillS in pairs(tbSkillD) do
				print("家族技能 "..i.."-"..j.."-"..k..":"..cKin.GetTask(tbSkillS.nTaskId));
			end
		end
	end	
end


end

--------------------------------MODULE_GAMESERVER--------------------------------------

if MODULE_GAMESERVER then

Require("\\script\\kin\\kinlogic_gs.lua");


--设置家族技能等级和当前经验
function Kin:SetSkillInfo(nKinId, nLevel, nNowExp)
	if self.tbKinSkill.Open ~= 1 then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end	
	--Msg to kin	
	GCExcute{"Kin:SetSkillInfo_GC", nKinId, nLevel, nNowExp};
end

--设置家族技能等级和当前经验
function Kin:SetSkillInfo_GS(nKinId, nLevel, nNowExp)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	local nLastLevel = cKin.GetSkillLevel();
	cKin.SetSkillLevel(nLevel);
	cKin.SetSkillExp(nNowExp);
	--Msg to kin
	if nLastLevel ~= nLevel then
		KKin.Msg2Kin(nKinId, string.format("家族技能等级升级，当前等级为%s", nLevel));
	end
	return KKinGs.KinClientExcute(nKinId, {"Kin:AddSkillExp_C2", nLevel, nNowExp});
end

--设置具体技能
function Kin:AddSkillLevel_GS(szPlayerName, nKinId, tbSkillInfo)
	local nRet = Kin:CheckSkillLevel(nKinId, tbSkillInfo);
	if nRet == 0 then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local nLevel = cKin.GetSkillLevel();
	local nMaxPoint = 0;
	for _, tbSkillInfoEx in pairs(tbSkillInfo) do
		local nTaskId = self.tbKinSkill.tbSkillInfo[tbSkillInfoEx[1]][tbSkillInfoEx[2]][tbSkillInfoEx[3]].nTaskId;
		cKin.SetTask(nTaskId, cKin.GetTask(nTaskId) + tbSkillInfoEx[4]);
		nMaxPoint = nMaxPoint + tbSkillInfoEx[4];
	end
	cKin.SetUsePoint(cKin.GetUsePoint()  + nMaxPoint);
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		for _, tb in pairs(tbSkillInfo) do
			local nTaskId = self.tbKinSkill.tbSkillInfo[tb[1]][tb[2]][tb[3]].nTaskId;
			local nSkillId = tb[1] *1000000 + tb[2]*10000+ tb[3]*100+cKin.GetTask(nTaskId);	--八位记录，G,D,S,L
			local szSkillId = "";
			if tb[1] < 10 then
				szSkillId = "0"..tostring(nSkillId);
			else
				szSkillId = tostring(nSkillId);
			end
			StatLog:WriteStatLog("stat_info", "jiazujineng", "add", pPlayer.nId, cKin.GetName(), szSkillId, nLevel - cKin.GetUsePoint(),  nLevel, cKin.GetSkillExp());
		end
	end
	KKin.Msg2Kin(nKinId, string.format("[%s]对家族技能进行了升级，增加了新的可用技能，快去查看。", szPlayerName));
	return KKinGs.KinClientExcute(nKinId, {"Kin:AddSkillLevel_C2", tbSkillInfo});
end

--检点错误提示
function Kin:AddSkillLevelError_GS(szPlayerName)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	pPlayer.Msg("您的加点有误，请重新加点。");
	return 0;
end

--洗技能点
function Kin:RefreshSkillPoint_GS1(nKinId)
	if self.tbKinSkill.Open ~= 1 then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	GCExcute{"Kin:RefreshSkillPoint_GC", nKinId};
end

--洗技能点
function Kin:RefreshSkillPoint_GS2(nKinId)	
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local nPoint = 0;
	for _, tbSkillG in pairs(self.tbKinSkill.tbSkillInfo) do
		for _, tbSkillD in pairs(tbSkillG) do
			for _, tbSkillS in pairs(tbSkillD) do
				nPoint = nPoint + cKin.GetTask(tbSkillS.nTaskId);
				cKin.SetTask(tbSkillS.nTaskId, 0);
			end
		end
	end
	cKin.SetUsePoint(0);
	KKin.Msg2Kin(nKinId, "家族技能洗成功，可以重新加点了。");
	return KKinGs.KinClientExcute(nKinId, {"Kin:RefreshSkillPoint_C2"});
end

--玩家登陆时同步家族技能给客户端
PlayerEvent:RegisterGlobal("OnLogin",  Kin.RefreshSkillInfo,  Kin);

--------------------------------c2s--------------------------------------
--注册能被客户端直接调用的函数
local function RegC2SFun(szName, fun)
	Kin.c2sFun[szName] = fun
end

--家族技能加点
function Kin:AddSkillLevel(tbSkillInfo)
	if self.tbKinSkill.Open ~= 1 then
		return 0;
	end
	local nKinId, nExcutorId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		me.Msg("你没有家族是不能进行家族技能相关操作的。");
		return 0
	end
	local cMember = cKin.GetMember(nExcutorId);
	if not cMember then
		me.Msg("你没有家族是不能进行家族技能相关操作的。");
		return 0;
	end	
	if cMember.GetFigure()   > self.FIGURE_ASSISTANT then
		me.Msg("只有族长和副族长才有加点的权限。")
		return 0
	end
	local bRet = self:CheckSkillLevel(nKinId, tbSkillInfo);
	if bRet == 0 then
		me.Msg("您的加点有误，请重新加点。");
		return 0;
	end	
	GCExcute{"Kin:AddSkillLevel_GC", me.szName, nKinId, tbSkillInfo};	
end
RegC2SFun("AddSkillLevel", Kin.AddSkillLevel);


--同步技能相关
function Kin:RefreshSkillInfo(nKinId)	
	if self.tbKinSkill.Open ~= 1 then
		return 0;
	end	
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local tbSkillInfo = {};
	local nLevel = cKin.GetSkillLevel();
	local nUsePoint = cKin.GetUsePoint();
	local nExp = cKin.GetSkillExp();
	for _, tbSkillG in pairs(self.tbKinSkill.tbSkillInfo) do
		for _, tbSkillD in pairs(tbSkillG) do
			for _, tbSkillS in pairs(tbSkillD) do
				tbSkillInfo[tbSkillS.nTaskId] = cKin.GetTask(tbSkillS.nTaskId);
			end
		end
	end
	tbSkillInfo[49] = nLevel;
	tbSkillInfo[50] = nExp;
	tbSkillInfo[51] = nUsePoint;
	return KKinGs.KinClientExcute(nKinId, {"Kin:RefreshSkillInfo_C2", tbSkillInfo});	
end

RegC2SFun("RefreshSkillInfo", Kin.RefreshSkillInfo, nKinId);
---------------------------------test-------------------------------------

function Kin:ShowKinSkill(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end	
	local nKinId, nExcutorId = pPlayer.GetKinMember();	
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local tbSkillInfo = {};
	pPlayer.Msg("--------------------------华丽的分割线--------------------------------")
	local nLevel = cKin.GetSkillLevel();
	pPlayer.Msg("家族技能："..nLevel);
	local nUsePoint = cKin.GetUsePoint();
	pPlayer.Msg("家族技能使用的点数："..nUsePoint);
	local nExp = cKin.GetSkillExp();
	pPlayer.Msg("家族技能当前经验值："..nExp);
	for i, tbSkillG in pairs(self.tbKinSkill.tbSkillInfo) do
		for j, tbSkillD in pairs(tbSkillG) do
			for k, tbSkillS in pairs(tbSkillD) do				
				pPlayer.Msg("家族技能 "..i.."-"..j.."-"..k..":"..cKin.GetTask(tbSkillS.nTaskId));
			end
		end
	end	
end
end
