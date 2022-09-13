-- 文件名  : treasuremap2_file.lua
-- 创建者  : zounan
-- 创建时间: 2010-08-09 11:36:47
-- 描述    : 读藏宝图文件
Require("\\script\\task\\treasuremap2\\treasuremap2_def.lua");

function TreasureMap2:LoadNpcFile(szNpcFile)
	local tbFile = Lib:LoadTabFile(szNpcFile);
	if not tbFile then
		print("[ERR] TreasureMap2:LoadNpcFile", szNpcFile);
		return {};
	end	
	
	local tbInstanceNpc = {};
	for _, tbData in ipairs(tbFile) do	
		local tbInstanceInfo = {};
		tbInstanceInfo.nTemplateId    = tonumber(tbData.TemplateId)    or 0;
		tbInstanceInfo.nNpcLevel      = tonumber(tbData.NpcLevel)      or 0;
		tbInstanceInfo.nNpcScore      = tonumber(tbData.NpcScore)      or 0;
		tbInstanceInfo.szName 		  = tbData.NpcName;
		local nNpcCount      = tonumber(tbData.NpcCount)  	  or 0;
		local nXPos		     = tonumber(tbData.XPos)   		  or 0;
		local nYPos		     = tonumber(tbData.YPos)  		  or 0;		
		tbInstanceInfo.tbNpcPos = {};
		if nXPos ~= 0 and nYPos ~= 0 then
			table.insert(tbInstanceInfo.tbNpcPos,{math.floor(nXPos/32),math.floor(nYPos/32)});			
		end
		local szNpcPosFile   = tbData.NpcPosFile;
	
		if szNpcPosFile ~= "" then
			local tbPosFile = Lib:LoadTabFile(szNpcPosFile);
			if not tbPosFile then
				print("[ERR] TreasureMap2:LoadNpcFile",szNpcPosFile);
				return {};
			end
			
			for _, tbPos in ipairs(tbPosFile) do
				table.insert(tbInstanceInfo.tbNpcPos,{math.floor((tonumber(tbPos.TRAPX))/32),math.floor((tonumber(tbPos.TRAPY))/32)});
			end
		end
		

		if nNpcCount == 0 then
			tbInstanceInfo.nNpcCount = #tbInstanceInfo.tbNpcPos;
		end
		
		table.insert(tbInstanceNpc, tbInstanceInfo);
	end
	return tbInstanceNpc;
end

function TreasureMap2:LoadTrapFile(szTrapFile)
	local tbFile = Lib:LoadTabFile(szTrapFile);
	if not tbFile then
		print("[ERR] TreasureMap2:LoadTrapFile", szTrapFile);
		return {};
	end	
	
	local tbInstanceTrap = {};
	for _, tbData in ipairs(tbFile) do	
		local szTrapName 	= tbData.TrapName;
		local szTrapPosFile = tbData.TrapPosFile;		
		local tbTrapInfo    = {};
		if szTrapPosFile ~= "" then
			local tbPosFile = Lib:LoadTabFile(szTrapPosFile);
			if not tbPosFile then
				print("ERR] TreasureMap2:LoadTrapFile", szTrapPosFile);
				return {};
			end
			
			for _, tbPos in ipairs(tbPosFile) do				 
				table.insert(tbTrapInfo,{math.floor((tonumber(tbPos.TRAPX))/32),math.floor((tonumber(tbPos.TRAPY))/32)});
	--			table.insert(tbTrapInfo,{tonumber(tbPos.TRAPX/32),tonumber(tbPos.TRAPY/32)});
			end
			if szTrapName == "" then
				print("ERR] TreasureMap2:LoadTrapFile TRAPNAME IS NIL");
			end
			tbInstanceTrap[szTrapName] = tbTrapInfo;
		end
	end
	
	return tbInstanceTrap;
end

function TreasureMap2:LoadAwardFile(szAwardFile)
	local tbFile = Lib:LoadTabFile(szAwardFile);
	if not tbFile then
		print("[ERR] TreasureMap2:LoadAwardFile", szAwardFile);
		return {};
	end
	local tbAward = {};
	for _, tbData in ipairs(tbFile) do
		local nAwardLevel    = tonumber(tbData.AwardLevel)    or 0;
		tbAward[nAwardLevel] = {};		
		local tbAwardInfo = tbAward[nAwardLevel];
		
		tbAwardInfo.nPlayerLevel  = tonumber(tbData.PlayerLevel)   or 0;
		tbAwardInfo.tbItem		  = {};
		tbAwardInfo.tbItem[1] 	  = tonumber(tbData.ItemG)      or 0;
		tbAwardInfo.tbItem[2]     = tonumber(tbData.ItemD)      or 0;
		tbAwardInfo.tbItem[3]     = tonumber(tbData.ItemP)      or 0;
		tbAwardInfo.tbItem[4]     = tonumber(tbData.ItemL)      or 0;
		tbAwardInfo.tbLevelAward  = {};	
		local tbLevelFile = Lib:LoadTabFile(tbData.LevelFile);
		if not tbLevelFile then
			print("[ERR] TreasureMap2:LoadAwardFile LevelFile",tbData.LevelFile);
			return {};
		end
			
		local nGrade = nil;
		local nCount = nil;
		for _, tbLevel in ipairs(tbLevelFile) do
			nGrade = tonumber(tbLevel.Grade) or 0;
			nCount = tonumber(tbLevel.Count) or 0;
			tbAwardInfo.tbLevelAward[nGrade] = nCount;
		end
		
	end
	return tbAward;
end

function TreasureMap2:LoadInfoFile(szInfoFile)
	local tbFile = Lib:LoadTabFile(szInfoFile);
	if not tbFile then
		print("[ERR] TreasureMap2:LoadInfoFile", szInfoFile);
		return {};
	end	
	
	local tbInstance = {};
	for _, tbData in ipairs(tbFile) do	
		local nInstanceLevel = tonumber(tbData.InstanceLevel) or 0; -- 0的话也可以？
		tbInstance[nInstanceLevel] = {};
		tbInstance[nInstanceLevel].nRequirePlayerLevel   = tonumber(tbData.RequirePlayerLevel) or 0;
		tbInstance[nInstanceLevel].szDesc	 = tbData.Desc;
		tbInstance[nInstanceLevel].nFavor	 = tonumber(tbData.Favor) or 0;
		tbInstance[nInstanceLevel].tbNpcInfo = self:LoadNpcFile(tbData.NpcFile);
		tbInstance[nInstanceLevel].tbAward = self:LoadAwardFile(tbData.AwardFile);
	end
	return tbInstance;
end

function TreasureMap2:Init()
	for nTreasureId, tbTreasureInfo in ipairs(self.TEMPLATE_LIST) do
		tbTreasureInfo.tbInstanceInfo = self:LoadInfoFile(tbTreasureInfo.szInstanceInfoFile);
		tbTreasureInfo.tbTrapInfo	  = self:LoadTrapFile(tbTreasureInfo.szTrapPosFile);
	end
end

TreasureMap2:Init();