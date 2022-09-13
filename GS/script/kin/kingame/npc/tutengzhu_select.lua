local tbNpc = Npc:GetClass("tulengzhu_select")

function tbNpc:OnDialog()
	self:EnterRoom(him.dwId, 0);
end

local tbInfo =
{
	[26] = "小心……妖怪…诅咒……旁边的房间有解药……但是………";
	[27] = "神草能医百病，但只有你战胜自己的恶念方能拿到。";
}

function tbNpc:EnterRoom(nNpcId, nSure)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end	
	local tbTmp = pNpc.GetTempTable("KinGame");
	local pRoom = tbTmp.tbLockTable.tbRoom;
	local nRoomId = pRoom.nRoomId;
	
	if nRoomId == 26 or nRoomId == 27 then
		Dialog:Say(tbInfo[nRoomId])
		return 0;
	end
	
	local pGame =  KinGame:GetGameObjByMapId(pNpc.nMapId) --获得对象
	local pRoom24 = pGame.tbRoom[26];	--休息间
	if pRoom24:IsLock() == 1 then
		--已开锁，直接行走
		return 0;
	end
	local nCountMax = pGame:GetPlayerCount(0);
	local nCanPass = math.ceil(nCountMax / 3);
	local szMsg = "";
	local nCount = 0;
	if nRoomId == 4 then
		nCount = pGame:GetLeftPlayerCount();
	elseif nRoomId == 5 then
		nCount = pGame:GetMidPlayerCount();
	elseif nRoomId == 6 then
		nCount = pGame:GetRightPlayerCount();
	end
	if nCanPass - nCount <= 0 then
		szMsg = "你左右查看，发现石碑上的所有格子已凹陷，已不能前行，前方的好队不知如何。";
		Dialog:Say(szMsg)
	else
		szMsg = string.format("石碑上隐约的见到<color=red>%s个<color>格子凸起，碑文上刻着：前路只有被吾主认同者以及真的猛士能够通过。", nCanPass - nCount);
		Dialog:Say(szMsg)
	end
end
