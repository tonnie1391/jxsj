-- 文件名　：wldh_file_api.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-08-17 11:52:21
-- 描  述  ：

--赛制名
function Wldh:GetName(nType)
	return self.MACTH_TYPE[nType].szName;
end

--赛制描述
function Wldh:GetDesc(nType)
	return self.MACTH_TYPE[nType].szDesc;
end

--赛制场地分配类型
function Wldh:GetMapLinkType(nType)
	return self.MACTH_TYPE[nType].nMapLinkType;
end

--赛制配置
function Wldh:GetCfg(nType)
	return self.MACTH_TYPE[nType].tbMacthCfg;
end

--赛制场地:会场地图table
function Wldh:GetMapWaitTable(nType)
	return self.MACTH_TYPE[nType].tbWaitMap;
end

--赛制场地:准备场地图table
function Wldh:GetMapReadyTable(nType)
	return self.MACTH_TYPE[nType].tbReadyMap;
end

--赛制场地:比赛场地图table
function Wldh:GetMapMacthTable(nType)
	return self.MACTH_TYPE[nType].tbMacthMap;
end

--赛制场地:替补比赛场地图table
function Wldh:GetMapMacthPatchTable(nType)
	return self.MACTH_TYPE[nType].tbMacthMapPatch;
end

--赛制场地:获得战队类型
function Wldh:GetLGType(nType)
	return self.MACTH_TYPE[nType].nLGType;
end

--获得比赛场擂台点
function Wldh:GetMapPKPosTable(nType)
	return self.MACTH_TYPE[nType].tbPkPos;
end

--获得一张比赛地图最大容纳多少队伍(包括替补场)
function Wldh:GetOneMapPlayerMax(nType)
	for nId in ipairs(self:GetMapMacthTable(nType)) do
		if not self:GetMapMacthPatchTable(nType)[nId] then
			return 200;
		end
	end
	return 400;
end
