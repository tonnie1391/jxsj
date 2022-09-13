-- 文件名　：dts_maptype.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-13
-- 描  述  ：大逃杀gc分地图gs分配点

Require("\\script\\globalserverbattle\\dataosha\\dts_def.lua");

--获得会场的点
function DaTaoSha:GetPKMapPos(nLevel)
	--随机pk出生点(先直接返回顺序的出生点)
	return self.MACTH_BIRTH[nLevel];
end

if (not MODULE_GC_SERVER) then
	return 0;
end

--获得准备场
function DaTaoSha:GetReadyMapId(tbPlayerList, nLevel)	
	local nNum = #tbPlayerList;
	local nEnterReadyId = 0;
	local nGroupId = nil;
	self.tbAllPlayerList = self.tbAllPlayerList or {};
	--一个人找队友地图
	if 1 == nNum then
		for _, nMapId in ipairs(self.MACTH_TYPE[nLevel].tbReadyMap) do	
			self.tbAllPlayerList[nMapId] = self.tbAllPlayerList[nMapId] or {};	
			self.tbAllPlayerList[nMapId].tbGroupId =  self.tbAllPlayerList[nMapId].tbGroupId or {}			
			local nGroupId = self.tbAllPlayerList[nMapId].tbGroupId[tbPlayerList[1]];		
			if nGroupId and self.tbAllPlayerList[nMapId].tbGroupList and #self.tbAllPlayerList[nMapId].tbGroupList[nGroupId] >= 1 then				
				return nMapId, 1;
			end
		end
	end
	local nMaxNum = 0; 
	local nMinNum = self.READYMAP_PLAYER_NUM;
	local nReadMap = 0;
	--找人数离72最接近的场扔
	for _, nMapId in ipairs(self.MACTH_TYPE[nLevel].tbReadyMap) do	
		self.tbAllPlayerList[nMapId] = self.tbAllPlayerList[nMapId] or {};
		self.tbAllPlayerList[nMapId].nCount = self.tbAllPlayerList[nMapId].nCount or 0;
		if  math.fmod(self.tbAllPlayerList[nMapId].nCount, self.PLAYER_NUMBER) > nMaxNum and self.tbAllPlayerList[nMapId].nCount < self.PLAYER_NUMBER
							and self.tbAllPlayerList[nMapId].nCount + nNum <= self.READYMAP_PLAYER_NUM then
			nMaxNum = math.fmod(self.tbAllPlayerList[nMapId].nCount, self.PLAYER_NUMBER);
			nReadMap = nMapId;
		end 
	end			
	if nReadMap ~= 0 then
		nEnterReadyId = nReadMap;
	else
		for _, nMapId in ipairs(self.MACTH_TYPE[nLevel].tbReadyMap) do
			if self.tbAllPlayerList[nMapId].nCount < nMinNum  then 		
				nMinNum = self.tbAllPlayerList[nMapId].nCount;
				nReadMap = nMapId;
			end	
		end		
	end	
	nEnterReadyId = nReadMap;
	return nEnterReadyId, 0;
end
