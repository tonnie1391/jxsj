--Player全局
--GC，GS，Client共用
--sunduoliang

Require("\\script\\player\\define.lua");

function Player:_Init()
	local tbFactions = Player:LoadFactionXmlFile();
	self.tbFactions	= {};
	for nFactionId = self.FACTION_NONE, self.FACTION_NUM do
		self.tbFactions[nFactionId]	= tbFactions[nFactionId];
	end
	
	if MODULE_GAMESERVER then
		local tbSkillAuto, tbShortcutAuto = Player:LoadSkillAutoFile();
		self.tbSkillAuto = tbSkillAuto;
		self.tbShortcutAuto = tbShortcutAuto;
		Player:ReStoreSkillPointAdd();
	end
end

--技能点多加修复
function Player:ReStoreSkillPointAdd()
	local nMaxPoint	  = 0;
	local tbSkillAuto = self.tbSkillAuto;
	for nKind, tb1 in pairs(tbSkillAuto) do
 		for nFactionId , tb2 in pairs(tb1) do
 	 		if type(nFactionId) == "number" then
 				local nAddSkillPoint = 0;
 				for nRouteId, tb3 in pairs(tb2) do
 					for nLevel, nSkillPoint in pairs(tb3) do
 						nAddSkillPoint = nAddSkillPoint + nSkillPoint;
 					end
 				end
 				if nMaxPoint < nAddSkillPoint then
 					nMaxPoint = nAddSkillPoint;
 				end		
 			end		
 		end
 		
		nMaxPoint = nMaxPoint - nKind + 1;
		if nMaxPoint < 0 then 
			nMaxPoint = 0;
		end
		
		tbSkillAuto[nKind]["AddSkillPoint"] = nMaxPoint;
	end
end

-- 获得门派路线名
--	如果nRouteId为0或省略，则返回门派名，否则返回路线名
function Player:GetFactionRouteName(nFactionId, nRouteId)
	local tbFaction	= self.tbFactions[nFactionId];
	local tbRoute	= tbFaction.tbRoutes[nRouteId or 0];
	return (tbRoute or tbFaction).szName;
end

-- 获得技能Id
-- nFactionId 门派
-- nRouteId	  路线
-- nLevel 	  技能等级,10为10级技能,20为20级技能;
function Player:GetFactionRouteSkillId(nFactionId, nRouteId, nLevel)
	local tbFaction	= self.tbFactions[nFactionId];
	local tbRoute	= tbFaction.tbRoutes[nRouteId];
	if not tbRoute then
		print("【GetFactionRouteSkillId】没有该路线数据:"..nRouteId)
		return 0;
	end
	local tbSkill = tbRoute.tbSkills[math.floor(nLevel/10)];
	if not tbSkill then
		print("【GetFactionRouteSkillId】没有该等级数据:"..nLevel)
		return 0;
	end
	return tbSkill.nId;
end

-- 获得技能自动加点数
-- nKind类型(69级, 89级, 99级)
-- nFactionId 门派
-- nRouteId	  路线
-- nLevel 	  技能等级,10为10级技能,20为20级技能;
function Player:GetSkillAutoPoint(nKind, nFactionId, nRouteId, nLevel)
	if not self.tbSkillAuto[nKind] then
		print("【GetSkillAutoPoint】等级段错误，没有该等级段数据："..nKind);
		return 0;
	end
	if not self.tbSkillAuto[nKind][nFactionId] then
		print("【GetSkillAutoPoint】门派Id错误，没有该门派数据："..nFactionId);
		return 0;
	end
	
	if not self.tbSkillAuto[nKind][nFactionId][nRouteId] then
		print("【GetSkillAutoPoint】路线Id错误，没有该路线数据："..nRouteId);
		return 0;
	end
	
	if not self.tbSkillAuto[nKind][nFactionId][nRouteId][nLevel] then
		print("【GetSkillAutoPoint】等级错误，没有该等级数据："..nLevel);
		return 0;
	end	
	return self.tbSkillAuto[nKind][nFactionId][nRouteId][nLevel];
end

-- 获得需要增加的点数 (有可能增加的技能点比玩家自身的技能点多)
-- nKind类型(69级, 89级, 99级)
function Player:GetAddSkillPoint(nKind)
	if not self.tbSkillAuto[nKind] then
		print("【GetAddSkillPoint】等级段错误，没有该等级段数据："..nKind);
		return 0;
	end
	return self.tbSkillAuto[nKind]["AddSkillPoint"];
end

-- 获得技能对应的快捷栏
-- nKind类型(69级, 89级, 99级)
-- nFactionId 门派
-- nRouteId	  路线
-- varLevel 	  技能等级,10为10级技能,20为20级技能; 或"LeftSkill" "RightSkill" 分别为左右快捷键对应的门派技能等级
function Player:GetShortcutAuto(nKind, nFactionId, nRouteId, valLevel)
	if not self.tbShortcutAuto[nKind] then
		print("【GetShortcutAuto】等级段错误，没有该等级段数据："..nKind);
		return 0;
	end
	if not self.tbShortcutAuto[nKind][nFactionId] then
		print("【GetShortcutAuto】门派Id错误，没有该门派数据："..nFactionId);
		return 0;
	end
	
	if not self.tbShortcutAuto[nKind][nFactionId][nRouteId] then
		print("【GetShortcutAuto】路线Id错误，没有该路线数据："..nRouteId);
		return 0;
	end
	
	if not self.tbShortcutAuto[nKind][nFactionId][nRouteId][valLevel] then
		return 0;
	end
	
	return self.tbShortcutAuto[nKind][nFactionId][nRouteId][valLevel];
end

function Player:LoadFactionXmlFile()
	local tbCamp = {
		["新手"] = 0,
		["正派"] = 1,
		["邪派"] = 2,
		["中立"] = 3,
	}
	local tbFactionsXml = KFile.LoadXmlFile("\\setting\\faction\\faction.xml").children;
	local tbFactions = {};
	for _, tbFaction in pairs(tbFactionsXml) do
		local nFactionId = tonumber(tbFaction.attrib.id) or 0;
		tbFactions[nFactionId] = {};
		tbFactions[nFactionId].nId = nFactionId;
		
		tbFactions[nFactionId].szName = tbFaction.attrib.name or "";					--门派名
		tbFactions[nFactionId].nSeries = tonumber(tbFaction.attrib.series) or 0; 	--门派五行Id
		tbFactions[nFactionId].szCamp = tbFaction.attrib.camp or "";		 			--门派阵营描述
		tbFactions[nFactionId].nSexLimit = tonumber(tbFaction.attrib.sexlimit) or 0;	--门派性别属性
		tbFactions[nFactionId].nCamp = 0;
		if tbCamp[tbFactions[nFactionId].szCamp] then
			tbFactions[nFactionId].nCamp = tbCamp[tbFactions[nFactionId].szCamp];
		end
		tbFactions[nFactionId].tbRoutes = {};
		tbFactions[nFactionId].tbRoutes.n = 0;
		if tbFaction.children and type(tbFaction.children) == "table" then
			for  _, tbRoute in pairs(tbFaction.children) do
				local nRouteId = tonumber(tbRoute.attrib.id) or 0;
				if nRouteId > 0 then
					tbFactions[nFactionId].tbRoutes.n = tbFactions[nFactionId].tbRoutes.n + 1;
				end
				local tbRouteTmp = {};
				tbFactions[nFactionId].tbRoutes[nRouteId] = tbRouteTmp;
				tbRouteTmp.nId = nRouteId;
				tbRouteTmp.szName = tbRoute.attrib.name or "";					--门派名
				tbRouteTmp.szDesc = tbRoute.attrib.desc or "";					--门派名
				tbRouteTmp.tbSkills = {};
				if tbRoute.children and type(tbRoute.children) == "table" then
					for  _, tbSkill in pairs(tbRoute.children) do
						local nSkillId = tonumber(tbSkill.attrib.id) or 0;
						local szName = tbSkill.attrib.name or "";
						table.insert(tbRouteTmp.tbSkills, {nId = nSkillId, szName = szName});
					end
				end
			end
		end
	end
	return tbFactions;
end

function Player:LoadSkillAutoFile()
	local tbFile = Lib:LoadTabFile("\\setting\\player\\skillauto.txt");
	if not tbFile then
		print("【读取文件错误】skillauto.txt");
		return {},{};
	end
	local tbSkillAuto = {};  --自动分配技能
	local tbShortcutAuto = {}; -- 自动分配快捷键栏
	for nId, tbSkills in ipairs(tbFile) do
		if nId >= 2 then
			local nSkillCount = 0;
			local nKind = tonumber(tbSkills.Kind);
			local nFactionId = tonumber(tbSkills.FactionId);
			local nRouteId 	 = tonumber(tbSkills.RouteId);
			tbSkillAuto[nKind] = tbSkillAuto[nKind] or {};
			tbSkillAuto[nKind][nFactionId] = tbSkillAuto[nKind][nFactionId] or {};
			tbSkillAuto[nKind][nFactionId][nRouteId] = tbSkillAuto[nKind][nFactionId][nRouteId] or {};

			tbShortcutAuto[nKind] = tbShortcutAuto[nKind] or {};
			tbShortcutAuto[nKind][nFactionId] = tbShortcutAuto[nKind][nFactionId] or {};
			tbShortcutAuto[nKind][nFactionId][nRouteId] = tbShortcutAuto[nKind][nFactionId][nRouteId] or {};
			
			--已做了到150级技能判断
			for i=1, 15 do
				local tbData = Lib:SplitStr(tbSkills["Skill"..(i*10)] or "", "|");
				local nSkill = tonumber(tbData[1]) or 0;
				local nPosition = tonumber(tbData[2]) or 0;		
				tbSkillAuto[nKind][nFactionId][nRouteId][i*10] = nSkill;
				nSkillCount = nSkillCount + nSkill;
				if nPosition > 0 and nPosition <= Item.SHORTCUTBAR_OBJ_MAX_SIZE then
					tbShortcutAuto[nKind][nFactionId][nRouteId][i*10] = nPosition;
				end
			end
			local nAddSkillPoint = nSkillCount - nKind;  --不足的点数，
			if nAddSkillPoint >= 0 then
				tbSkillAuto[nKind]["AddSkillPoint"] = nAddSkillPoint + 1;
			end
			local nLeft = tonumber(tbSkills.LeftSkill) or 0;
			tbShortcutAuto[nKind][nFactionId][nRouteId]["LeftSkill"] = nLeft; 
			local nRight = tonumber(tbSkills.RightSkill) or 0;
			tbShortcutAuto[nKind][nFactionId][nRouteId]["RightSkill"] = nRight; 			
		end
	end
	return tbSkillAuto, tbShortcutAuto;
end

Player:_Init();

--获得玩家行为类型
--类0:默认玩家
--类1:正常玩家
--类2:新手玩家或小号
--类3:小号或小型工作室
--类4:中小型工作室
--类5:一定规模的工作室
--类6:较大规模工作室
--类7:规模工作室
--角色名，类型，GCGS自动同步（不填或填nil,0则自动同步，1则不同步）
function Player:SetActionKind(szName, nKind, nSync)
	if nKind < 0 or nKind > 128 then
		return 0;
	end
	if MODULE_GAMESERVER then
		if KGCPlayer.SetActionKind(szName, nKind) == 1 then
			if nSync ~= 1 then
				GCExcute({"Player:SetActionKind", szName, nKind});
			end
			return 1;
		end
	end
	if MODULE_GC_SERVER then
		if KGCPlayer.SetActionKind(szName, nKind) == 1 then
			if nSync ~= 1 then
				GlobalExcute({"KGCPlayer.SetActionKind", szName, nKind});
			end
			return 1;
		end
	end
	return 0;
end

--设置
function Player:SetActionKind_G(szName, nKind)
	return KGCPlayer.SetActionKind(szName, nKind);
end


--获得玩家行为类型
--类0:默认玩家
--类1:正常玩家
--类2:新手玩家或小号
--类3:小号或小型工作室
--类4:中小型工作室
--类5:一定规模的工作室
--类6:较大规模工作室
--类7:规模工作室
function Player:GetActionKind(szName)
	local nId = KGCPlayer.GetPlayerIdByName(szName)
	if nId then
		local tbInfo = KGCPlayer.GCPlayerGetInfo(nId);
		if tbInfo then
			return tbInfo.nActionKind or -1;
		end
		return -1;
	end
	return -1;
end

function Player:SetActionKindByFile(szFilePath)
	local tbFile = Lib:LoadTabFile(szFilePath);
	if not tbFile then
		return "文件不存在";
	end
	local nSCount = 0;
	local nFCount = 0;
	for _, tb in ipairs(tbFile) do
		if tb.szGateway == GetGatewayName() then
			local nId = KGCPlayer.GetPlayerIdByName(tb.szName);
			if nId and Player:SetActionKind(tb.szName, tonumber(tb.nKind) or 0, 1) == 1 then
				nSCount = nSCount + 1;
			else
				nFCount = nFCount + 1;
			end
		end
	end
	if MODULE_GC_SERVER then
		--这种写法不好，服务器名或架构变了导致无法使用同步，临时写法。todo
		local szGStoGCPath = "\\..\\gamecenter"; --GS转入GC目录索引
		GlobalExcute({"Player:SetActionKindByFile", szGStoGCPath..szFilePath});
	end
	return string.format("Succss(%s);Fail(%s)",nSCount, nFCount);
end
