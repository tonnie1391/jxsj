-- 文件名  : base_trap.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-04 10:01:33
-- 描述    : 简单的双TRAP线基类 可以用于其它地方
-- 对动态地图还需要外围做些额外的操作 搓了

CastleFight.tbBaseTrap = CastleFight.tbBaseTrap or {};
local tbBaseTrap = CastleFight.tbBaseTrap;

tbBaseTrap.emTRAPSTATUS_NONE  = 0;
tbBaseTrap.emTRAPSTATUS_INIT  = 1;
tbBaseTrap.emTRAPSTATUS_LEFT  = 2;
tbBaseTrap.emTRAPSTATUS_RIGHT = 3;
tbBaseTrap.emTRAPSTATUS_END	  = 4;

tbBaseTrap.tbBaseLeftTrap = tbBaseTrap.tbBaseLeftTrap or {};
local tbBaseLeftTrap  = tbBaseTrap.tbBaseLeftTrap;

tbBaseTrap.tbBaseRightTrap = tbBaseTrap.tbBaseRightTrap or {};
local tbBaseRightTrap = tbBaseTrap.tbBaseRightTrap;

tbBaseTrap.TEMP_TABLE = "CastleFight";


-- 如果没有CLASS NAME 会不会好些呢？应该会简单一些
-- 确实有点失败
function tbBaseTrap:LoadTrapFile(szFilePath)
	local tbFile = Lib:LoadTabFile(szFilePath);
	if not tbFile then
		print("【ERR】tbBaseTrap:LoadTabFile", szFilePath);
		return;
	end
	
	self.tbTrapList = {};
	for nId, tbParam in ipairs(tbFile) do
		self.tbTrapList[tbParam.ClassName] = {};

		self.tbTrapList[tbParam.ClassName].tbLeftTrap  = {};
		self.tbTrapList[tbParam.ClassName].tbLeftTrap.szName = tbParam.LeftTrapName;
		self.tbTrapList[tbParam.ClassName].tbLeftTrap.tbTrap = {};
		local tbLeftTrap = self.tbTrapList[tbParam.ClassName].tbLeftTrap.tbTrap;
		local tbLeftFile = Lib:LoadTabFile(tbParam.LeftTrapFile);
		if not tbLeftFile then
			print("【ERR】tbBaseTrap:LoadLeftTabFile", tbLeftFile);
			return;
		end
		
		for _, tbInfo in ipairs(tbLeftFile) do
			tbLeftTrap[#tbLeftTrap+1] = {};
			tbLeftTrap[#tbLeftTrap][1] = math.floor((tonumber(tbInfo.TRAPX)));
			tbLeftTrap[#tbLeftTrap][2] = math.floor((tonumber(tbInfo.TRAPY)));
		end
		
		
		self.tbTrapList[tbParam.ClassName].tbRightTrap  = {};
		self.tbTrapList[tbParam.ClassName].tbRightTrap.szName = tbParam.RightTrapName;
		self.tbTrapList[tbParam.ClassName].tbRightTrap.tbTrap = {};
		local tbRightTrap = self.tbTrapList[tbParam.ClassName].tbRightTrap.tbTrap;
		local tbRightFile = Lib:LoadTabFile(tbParam.RightTrapFile);
		if not tbRightFile then
			print("【ERR】tbBaseTrap:LoadLeftTabFile", tbRightFile);
			return;
		end
		
		for _, tbInfo in ipairs(tbRightFile) do
			tbRightTrap[#tbRightTrap+1] = {};
			tbRightTrap[#tbRightTrap][1] = math.floor((tonumber(tbInfo.TRAPX)));
			tbRightTrap[#tbRightTrap][2] = math.floor((tonumber(tbInfo.TRAPY)));
		end
	end
end

-- 一般是作为基类  所以 提供传表的方式进行初始化
function tbBaseTrap:InitTrapTable(tbTrapList)
	self.tbTrapList = tbTrapList;
end


-- 也可以通过传表来做
function tbBaseTrap:AddTrapTable(szClassName, tbTrapInfo)
	self.tbTrapList = self.tbTrapList or {};
	if self.tbTrapList[szClassName] then
		print("【WRN】AddTrapTable ClassName exist",szClassName);
	end
	self.tbTrapList[szClassName] = tbTrapInfo;
end

--  szClassName 为nil 表示所有
--function tbBaseTrap:AttachCharacterToTrap(pCharacter, nStatus, szClassName)
function tbBaseTrap:AttachCharacterToTrap(pCharacter, szClassName)
	local nStatus = nil;
	nStatus = nStatus or self.emTRAPSTATUS_INIT;
	if not self.tbTrapList then
		print("【ERR】tbBaseTrap: AttachCharacterToTrap : traplist is nil", szClassName);
		return;
	end	
	
	if szClassName then
		if not self.tbTrapList[szClassName] then
			print("【ERR】tbBaseTrap: AttachCharacterToTrap : traplist is nil", szClassName);
			return;
		end
		self:SetCharacterTrapStatus(pCharacter, szClassName, nStatus);	
	else
		for szClass in pairs(self.tbTrapList) do
			self:SetCharacterTrapStatus(pCharacter, szClass, nStatus);
		end
	end
	
	self:_BindCharacter2Self(pCharacter);
end

function tbBaseTrap:DettachCharacterToTrap(pCharacter, szClassName)
	if szClassName then
		self:SetCharacterTrapStatus(pCharacter, szClassName, self.emTRAPSTATUS_NONE);
	else
		for szClass in pairs(self.tbTrapList) do
			self:SetCharacterTrapStatus(pCharacter, szClass, self.emTRAPSTATUS_NONE);
		end		
	end
	self:_UnBindCharacter2Self(pCharacter);
end

function tbBaseTrap:AttachMissionToTrap(tbMission)
	self.tbMission = tbMission;
end

function tbBaseTrap:DettachMissionToTrap()
	self.tbMission = nil;
end

function tbBaseTrap:GetCharacterTrapStatus(pCharacter, szClassName)
	if not pCharacter.GetTempTable(self.TEMP_TABLE).tbTrapList then
	 	pCharacter.GetTempTable(self.TEMP_TABLE).tbTrapList = {};
	end
	if not pCharacter.GetTempTable(self.TEMP_TABLE).tbTrapList[szClassName] then
		return self.emTRAPSTATUS_NONE;
	end	
	return pCharacter.GetTempTable(self.TEMP_TABLE).tbTrapList[szClassName];
end

function tbBaseTrap:SetCharacterTrapStatus(pCharacter, szClassName, nStatus)
	if not pCharacter.GetTempTable(self.TEMP_TABLE).tbTrapList then
	 	pCharacter.GetTempTable(self.TEMP_TABLE).tbTrapList = {};
	end
	if nStatus >= self.emTRAPSTATUS_END or nStatus < self.emTRAPSTATUS_NONE then
		print("【ERR】tbBaseTrap:SetCharacterTrapStatus nStatus", nStatus);
		return;
	end
	
	pCharacter.GetTempTable(self.TEMP_TABLE).tbTrapList[szClassName] = nStatus;
end

function tbBaseTrap:_BindCharacter2Self(pCharacter)
	pCharacter.GetTempTable(self.TEMP_TABLE).tbSelfTrap = self;
end

function tbBaseTrap:_GetCharacterBind(pCharacter)
	return pCharacter.GetTempTable(self.TEMP_TABLE).tbSelfTrap or 0;
end

function tbBaseTrap:_UnBindCharacter2Self(pCharacter)
	pCharacter.GetTempTable(self.TEMP_TABLE).tbSelfTrap = 0;
end


function tbBaseTrap:__OnCharacterLeftTrap(pCharacter, szClassName)
	local nBind = self:_GetCharacterBind(pCharacter);
	if nBind == 0 or nBind ~= self then -- self是个table 地址比较 应该也没啥问题
		return;
	end
	
	
	local nStatus = self:GetCharacterTrapStatus(pCharacter, szClassName);
	if nStatus == self.emTRAPSTATUS_NONE then
		return;
	end
	
	self:SetCharacterTrapStatus(pCharacter,szClassName,self.emTRAPSTATUS_LEFT);
	if nStatus == self.emTRAPSTATUS_RIGHT then
	--	if self.tbMission and self.tbMission.OnCharacterLeftTrap then
	--		self.tbMission:OnCharacterLeftTrap(pCharacter,szClassName);
	--	end
		self:OnCharacterLeftTrap(pCharacter,szClassName);
	end	
end

function tbBaseTrap:__OnCharacterRightTrap(pCharacter, szClassName)
	local nBind = self:_GetCharacterBind(pCharacter);
	if nBind == 0 or nBind ~= self then -- self是个table 地址比较 应该也没啥问题
		return;
	end	
	
	
	local nStatus = self:GetCharacterTrapStatus(pCharacter, szClassName);
	if nStatus == self.emTRAPSTATUS_NONE then
		return;
	end
	
	self:SetCharacterTrapStatus(pCharacter,szClassName,self.emTRAPSTATUS_RIGHT);
	if nStatus == self.emTRAPSTATUS_LEFT then
	--	if self.tbMission and self.tbMission.OnCharacterRightTrap then
	--		self.tbMission:OnCharacterRightTrap(pCharacter,szClassName);
	--	end
		self:OnCharacterRightTrap(pCharacter,szClassName);
	end	
end


-- 两个需要重载的函数。
function tbBaseTrap:OnCharacterLeftTrap(pCharacter,szClassName)
	
end

function tbBaseTrap:OnCharacterRightTrap(pCharacter,szClassName)
end


-- TRAP 与 地图关联
-- 是否是动态地图 动态地图相关的函数必须由模板函数来搞定
function tbBaseTrap:AttachMapToTrap(nMapId , bDyn)
	bDyn = bDyn or 0;
--	self.nMapId = nMapId;
	if not self.tbTrapList then
		print("【ERR】 tbBaseTrap: AttachMapToTrap: tbTrapList is nil", nMapId);
		assert(false);
		return;
	end


	for szClassName, tbTrapInfo in pairs(self.tbTrapList) do		
		local i = 1;
		for _, tbPoint in ipairs(tbTrapInfo.tbLeftTrap.tbTrap) do
		--	if bAddMapTrap == 1 then
				AddMapTrap(nMapId, tbPoint[1] , tbPoint[2], tbTrapInfo.tbLeftTrap.szName);
		--	end
		end
		
		for _, tbPoint in ipairs(tbTrapInfo.tbRightTrap.tbTrap) do
		--	if bAddMapTrap == 1 then
				AddMapTrap(nMapId, tbPoint[1] , tbPoint[2], tbTrapInfo.tbRightTrap.szName);
		--	end
		end
		
		--动态地图只加载TRAP点 不加载函数
		--所以要确保模板地图的函数加载（因为动态地图调用的是模板地图的函数，本身没有函数调用）
		if bDyn == 0 then
			local tbMap = Map:GetClass(nMapId);			
			local tbMapTrap = tbMap:GetTrapClass(tbTrapInfo.tbLeftTrap.szName);
			local tbLeftTrap 	= Lib:NewClass(self.tbBaseLeftTrap);
			tbLeftTrap.szTrapName  = tbTrapInfo.tbLeftTrap.szName;
			tbLeftTrap.szClassName = szClassName;
			tbLeftTrap.tbClass 	   = self;		
			for szFnc in pairs(tbLeftTrap) do			-- 复制函数
				tbMapTrap[szFnc] = tbLeftTrap[szFnc];
			end			
			
			tbMapTrap = tbMap:GetTrapClass(tbTrapInfo.tbRightTrap.szName);
			local tbRightTrap 	= Lib:NewClass(self.tbBaseRightTrap);
			tbRightTrap.szTrapName  = tbTrapInfo.tbRightTrap.szName;
			tbRightTrap.szClassName = szClassName;
			tbRightTrap.tbClass 	= self;
			for szFnc in pairs(tbLeftTrap) do			-- 复制函数
				tbMapTrap[szFnc] = tbRightTrap[szFnc];
			end
			
		end
	end								 
end

--- 左右 TRAP 线 基类
function tbBaseLeftTrap:OnPlayer()
--	print("base OnPlayer>>>>>>>");
	self.tbClass:__OnCharacterLeftTrap(me, self.szClassName);
end

function tbBaseLeftTrap:OnNpc()
	self.tbClass:__OnCharacterLeftTrap(him, self.szClassName);
end

function tbBaseRightTrap:OnPlayer()
--	print("base OnPlayer<<<<<<<<<<");	
	self.tbClass:__OnCharacterRightTrap(me, self.szClassName);
end

function tbBaseRightTrap:OnNpc()
	self.tbClass:__OnCharacterRightTrap(him, self.szClassName);
end