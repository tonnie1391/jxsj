-------------------------------------------------------------------
--File: 	
--Author: 	sunduoliang
--Date: 	2008-4-14 9:00
--Describe:	乾坤符逻辑，也就是不需要请求，直接传送到指令玩家身边逻辑
-------------------------------------------------------------------

if (not Item.tbQianKunFu) then
	Item.tbQianKunFu = {};
end

local tb = Item.tbQianKunFu;

--乾坤符ID,对应使用次数.
tb.tbItemList = {
		[85] = 10;
		[91] = 100;
	}
tb.tbItemTemplet= {18,1,85,1};
-- GC询问各个Server指定的队友是否在线
function tb:SelectMemberPos(nMemberPlayerId, nPlayerId, nItemId)
	GlobalExcute({"Item.tbQianKunFu:SeachPlayer", nMemberPlayerId, nPlayerId, nItemId});
end


-- GS 搜索本服务器上是否有指定玩家
function tb:SeachPlayer(nMemberPlayerId, nPlayerId, nItemId)
	-- 如果找到的话返回这个玩家的坐标
	local pMember = KPlayer.GetPlayerObjById(nMemberPlayerId)
	if (pMember) then
		local nMapId, nPosX, nPosY = pMember.GetWorldPos();
		local nFightState = pMember.nFightState
		local nCanSendIn  = Item:IsCallInAtMap(nMapId, unpack(self.tbItemTemplet));
		if (nCanSendIn ~= 1) then
			nMapId = -1;
		end		
		GCExcute({"Item.tbQianKunFu:FindMember", nMemberPlayerId, nPlayerId, nItemId, nMapId, nPosX, nPosY, nFightState});		
	end
end


-- GC 得到指定徒弟信息，通知师傅
function tb:FindMember(nMemberPlayerId, nPlayerId, nItemId, nMapId, nPosX, nPosY, nFightState)
	GlobalExcute({"Item.tbQianKunFu:ObtainMemberPos", nMemberPlayerId, nPlayerId, nItemId, nMapId, nPosX, nPosY, nFightState})
end


-- GS 得知对友位置
function tb:ObtainMemberPos(nMemberPlayerId, nPlayerId, nItemId, nMapId, nPosX, nPosY, nFightState)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer == nil then
		return 0;
	end
	if nMapId == -1 then
		pPlayer.Msg("不可以传送到目标地图！");
		return 0;
	end
	
	local nCanSendOut = KItem.CheckLimitUse(pPlayer.nMapId, KItem.GetOtherForbidType(unpack(self.tbItemTemplet)));
	if (not nCanSendOut or nCanSendOut == 0) then
		pPlayer.Msg("当前地图不可以被传送！");
		return 0;
	end

	if self:CheckMember(nPlayerId,nMemberPlayerId) ~= 1 then
		pPlayer.Msg("你没有该队友，可能是该队友已经离开队伍！");
		return 0;		
	end
	-- 执行传送
	local pItem = KItem.GetObjById(nItemId);
	if pItem == nil then
		pPlayer.Msg("无法找到乾坤符，非法操作。请与GM联系。")
		return 0;
	end	
	if pItem.GetTempTable().nMapId and pItem.GetTempTable().nMapId ~= nMapId then
		pPlayer.Msg("队友好像已经不在那个地方了。")
		return 0;
	end
	local nRet, szMsg = Map:CheckTagServerPlayerCount(nMapId)
	if nRet ~= 1 then
		pPlayer.Msg(szMsg);
		return 0;
	end
	local nUseCount = pItem.GetGenInfo(1,0);
	if self.tbItemList[pItem.nParticular] - nUseCount == 1 then
		if (pPlayer.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
			pPlayer.Msg("删除乾坤符失败！");
			return 0;
		end
	else
		pItem.SetGenInfo(1,nUseCount + 1);
		pItem.Sync();
	end
	pPlayer.SetFightState(nFightState);
	pPlayer.NewWorld(nMapId, nPosX, nPosY);
	Npc.tbFollowPartner:FollowNewWorld(pPlayer, nMapId, nPosX, nPosY);
end

function tb:CheckMember(nPlayerId, nMemberPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer == nil then
		return 0;
	end
	local tbTeamMemberList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	if tbTeamMemberList == nil then
		return 0;
	else
		for _, nMemPlayerId in pairs(tbTeamMemberList) do
				if nMemPlayerId == nMemberPlayerId then
					return 1;
				end
		end	
	end
	return 0;
end

--记录队友的地图id，如果放生变化就不让玩家传过去
function tb:ReCordPlayerMapId_GS(nMemberPlayerId, nPlayerId, nItemId, nMapId)
	local pMember = KPlayer.GetPlayerObjById(nMemberPlayerId);
	local pItem = KItem.GetObjById(nItemId);
	if (pMember and not nMapId) then		
		local nMapId = pMember.GetWorldPos();
		GlobalExcute({"Item.tbQianKunFu:ReCordPlayerMapId_GS", nMemberPlayerId, nPlayerId, nItemId, nMapId});
	end
	if (pItem and nMapId) then
		pItem.GetTempTable().nMapId = nMapId;	
	end
end
