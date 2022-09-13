-- 文件名  : base_obj.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-05 09:19:14
-- 描述    : 简单的格子基类 用处不大

-- TODO 其实可以做些扩展

CastleFight.tbBaseObj = CastleFight.tbBaseObj or {};
local tbBaseObj = CastleFight.tbBaseObj
function tbBaseObj:Init(tbTable)
	self.TEMP_OBJ = tbTable;
end


function tbBaseObj:GetObjList()
	self.tbObjList = self.tbObjList or {};
	return self.tbObjList;
end

function tbBaseObj:GetObjPosInfo(nPos)
	return self.TEMP_OBJ[nPos];
end

function tbBaseObj:DelObj(nPos)
	local tbObjList = self:GetObjList();
	tbObjList[nPos] = nil;
end

function tbBaseObj:CheckObj(nPos)
	local tbObjList = self:GetObjList();
	if tbObjList[nPos] then
		return 1;
	end
	return 0;
end

function tbBaseObj:CheckPos(pPlayer)
	local _, nX, nY = pPlayer.GetWorldPos();
	for nPos, tbPosition in ipairs(self.TEMP_OBJ) do
		if math.abs(nX - tbPosition.nX) < tbPosition.nRange  and math.abs(nY - tbPosition.nY) < tbPosition.nRange then		
			return nPos;
		end
	end
	return 0;
end

function tbBaseObj:CheckObjByPlayer(pPlayer)
	local nPos = self:CheckPos(pPlayer);
	if nPos == 0 then
		return 0;
	end

	if self:CheckObj(nPos) == 1 then
		return 0;
	end
	return nPos;
end


function tbBaseObj:AddObj(nPos)
	local tbObjList = self:GetObjList();
	tbObjList[nPos] = 1;
end


function tbBaseObj:AddObjWithCheck(pPlayer)
	local nPos = self:CheckObjByPlayer(pPlayer);
	if nPos == 0 then
		return 0 ;
	end
	-- tbMission:OnCheckObj(nPos);
	self:_AddObj(nPos);
--	self:OnAddObj(nPos);
	return 1;
end
