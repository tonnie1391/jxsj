-------------------------------------------------------
-- 文件名　：fuqichuansonglogic.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-29 18:02:18
-- 文件描述：
-------------------------------------------------------


if (not Marry.tbFuQiChuanSongFu) then
	Marry.tbFuQiChuanSongFu = {};
end

local tb = Marry.tbFuQiChuanSongFu;

-- GC询问各个Server对方是否在线
function tb:SelectMemberPos(nCoupleId, nPlayerId)
	GlobalExcute({"Marry.tbFuQiChuanSongFu:SeachPlayer", nCoupleId, nPlayerId});
end

-- GS 搜索本服务器上是否有指定玩家
function tb:SeachPlayer(nCoupleId, nPlayerId)
	
	-- 如果找到的话返回这个玩家的坐标
	local pMember = KPlayer.GetPlayerObjById(nCoupleId)
	if (pMember) then
		local nMapId, nPosX, nPosY = pMember.GetWorldPos();
		local nFightState = pMember.nFightState
		local nCanSendIn  = Item:IsCallInAtMap(nMapId, "chuansong");
		if (nCanSendIn ~= 1) then
			nMapId = -1;
		end	
		GCExcute({"Marry.tbFuQiChuanSongFu:FindMember", nCoupleId, nPlayerId, nMapId, nPosX, nPosY, nFightState});		
	end
end

-- GC 得到对方信息，通知传送者
function tb:FindMember(nCoupleId, nPlayerId, nMapId, nPosX, nPosY, nFightState)
	GlobalExcute({"Marry.tbFuQiChuanSongFu:ObtainMemberPos", nCoupleId, nPlayerId, nMapId, nPosX, nPosY, nFightState})
end

-- GS 得知对方位置
function tb:ObtainMemberPos(nCoupleId, nPlayerId, nMapId, nPosX, nPosY, nFightState)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer == nil then
		return 0;
	end
	if nMapId == -1 then
		pPlayer.Msg("不可以传送到目标地图！");
		return 0;
	end
	
	local nCanSendOut = KItem.CheckLimitUse(pPlayer.nMapId, "chuansong");
	if (not nCanSendOut or nCanSendOut == 0) then
		pPlayer.Msg("当前地图不可以被传送！");
		return 0;
	end
	
	local nRet, szMsg = Map:CheckTagServerPlayerCount(nMapId)
	if nRet ~= 1 then
		pPlayer.Msg(szMsg);
		return 0;
	end
	pPlayer.SetFightState(nFightState);
	pPlayer.NewWorld(nMapId, nPosX, nPosY);
end
