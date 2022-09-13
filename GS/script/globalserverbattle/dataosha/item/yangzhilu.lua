-- 文件名　：yangzhilu.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-28 15:38:42
-- 描  述  ：

local tbItem 			= Item:GetClass("yangzhilu");

tbItem.tbValue = {1000,18,0};		--每半秒1000，回复一秒

function tbItem:OnUse()
	local nMapId, nPosX, nPosY = me.GetWorldPos();	  
	local tbPlayerIdList = KTeam.GetTeamMemberList(me.nTeamId);
	if tbPlayerIdList then
		for _, nPlayerId in pairs(tbPlayerIdList) do			
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if  pPlayer  then
				local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
				local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
				if nDisSquare < 400 then				
					pPlayer.GetNpc().ApplyMagicAttrib("lifepotion_v", self.tbValue);
				end
			end
		end
	else
		me.GetNpc().ApplyMagicAttrib("lifepotion_v", self.tbValue);
	end
	return 1;
end
