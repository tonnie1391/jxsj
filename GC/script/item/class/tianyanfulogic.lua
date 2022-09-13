-------------------------------------------------------------------
--File: 	
--Author: 	sunduoliang
--Date: 	2008-4-14 9:00
--Describe:	乾坤符逻辑，也就是不需要请求，直接传送到指令玩家身边逻辑
-------------------------------------------------------------------
if (not Item.tbTianYanFu) then
	Item.tbTianYanFu = {};
end

local tb = Item.tbTianYanFu;

--乾坤符ID,对应使用次数.
tb.tbItemList = {
	[206] = 10
}

-- GC询问各个Server指定的队友是否在线
function tb:SelectEnemyPos(nEnemyId, nPlayerId, nItemId)
	GlobalExcute({"Item.tbTianYanFu:SeachPlayer", nEnemyId, nPlayerId, nItemId});
end


-- GS 搜索本服务器上是否有指定玩家
function tb:SeachPlayer(nEnemyId, nPlayerId, nItemId)
	-- 如果找到的话返回这个玩家的坐标
	local pMember = KPlayer.GetPlayerObjById(nEnemyId)
	if (pMember) then
		local nMapId, nPosX, nPosY 	= pMember.GetWorldPos();
		local nMapIndex 			= SubWorldID2Idx(nMapId);
		local nMapTemplateId		= SubWorldIdx2MapCopy(nMapIndex);
		local nFightState 			= pMember.nFightState;
		GCExcute({"Item.tbTianYanFu:FindMember", pMember.szName, nPlayerId, nItemId, nMapTemplateId, nPosX, nPosY, nFightState});		
	end
end


-- GC 得到指定徒弟信息，通知师傅
function tb:FindMember(szEnemyName, nPlayerId, nItemId, nMapId, nPosX, nPosY, nFightState)
	GlobalExcute({"Item.tbTianYanFu:ObtainMemberPos", szEnemyName, nPlayerId, nItemId, nMapId, nPosX, nPosY, nFightState})
end


-- GS 得知对友位置
function tb:ObtainMemberPos(szEnemyName, nPlayerId, nItemId, nMapId, nPosX, nPosY, nFightState)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return 0;
	end
	
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		pPlayer.Msg("无法找到物品，非法操作。请与GM联系。")
		return 0;
	end
	local nNTime = GetTime();
	local nYearDate = tonumber(os.date("%Y%m%d",nNTime));
	local nTimeDate = tonumber(os.date("%H%M%S",nNTime));
	pItem.SetGenInfo(2,nYearDate);
	pItem.SetGenInfo(3,nTimeDate);
	
--	if nFightState == 0 or Item:IsCallInAtMap(nMapId, 18,1,85,1) == 0 then
--		Setting:SetGlobalObj(pPlayer, him, pItem);
--		Dialog:Say(string.format("您找的仇人<color=red>%s<color>现在不在野外，请稍后再查询。", szEnemyName));
--		Setting:RestoreGlobalObj();
--		return 0;
--	end
	
	local nUseCount = pItem.GetGenInfo(1,0);
	if self.tbItemList[pItem.nParticular] - nUseCount == 1 then
		if (pPlayer.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
			pPlayer.Msg("删除物品失败！");
			return 0;
		end
	else
		pItem.SetGenInfo(1,nUseCount + 1);
		pItem.Sync();
	end
	local szMsg = string.format("您找的仇人<color=red>%s<color>现在的位置是:\n\n所在地图：<color=yellow>%s<color>\n坐    标：<color=yellow>%s/%s<color>", szEnemyName, GetMapNameFormId(nMapId), math.floor(nPosX/8), math.floor(nPosY/16));
	if Item:IsCallInAtMap(nMapId, 18,1,85,1) == 0 then
		szMsg = string.format("您找的仇人<color=red>%s<color>现在的位置是:\n\n所在地图：<color=yellow>%s<color>\n坐    标：<color=yellow>不可查询区域<color>\n\n该地图禁止传送", szEnemyName, GetMapNameFormId(nMapId))
	end
	Setting:SetGlobalObj(pPlayer, him, pItem);
	Dialog:Say(szMsg)
	Setting:RestoreGlobalObj();
end

