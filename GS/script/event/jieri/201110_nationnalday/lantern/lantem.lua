-- 文件名　：lantem.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-13 16:37:38
-- 功能    ：
SpecialEvent.tbLantem_2011 = SpecialEvent.tbLantem_2011 or {};
local tbLantem_2011 = SpecialEvent.tbLantem_2011;
tbLantem_2011.nMinTime = 3;		--使用道具最少1秒
tbLantem_2011.nNpcId = 9726;		--灯笼npcid
tbLantem_2011.nNpcId2 = 9727;		--灯笼npcid
tbLantem_2011.tbAwardItem = {18, 1, 1475, 1};
tbLantem_2011.tbInfo = tbLantem_2011.tbInfo or {};

--使用道具
function tbLantem_2011:UseItem(nUsePlayerId, nTeamPlayerId, nItemId, nTime)	
	if self.tbInfo[nTeamPlayerId] and self.tbInfo[nTeamPlayerId][1] == nUsePlayerId then
		if math.abs(nTime - self.tbInfo[nTeamPlayerId][3]) <= self.nMinTime then
			self:UseItemSucess(nUsePlayerId, nItemId, nTeamPlayerId, self.tbInfo[nTeamPlayerId][2]);			
		else
			self:UseItemFail(nUsePlayerId, nTeamPlayerId);
		end
		self.tbInfo[nTeamPlayerId] = nil;
	else 
		self.tbInfo[nUsePlayerId] = {nTeamPlayerId, nItemId, nTime};
	end	
	local pPlayer = KPlayer.GetPlayerObjById(nUsePlayerId);
	if pPlayer then
		pPlayer.Msg("当两个人同时使用时就可以燃放灯笼。");
	end
end

--使用成功
function tbLantem_2011:UseItemSucess(nPlayerId1, nItemId1, nPlayerId2, nItemId2)
	local pItem1 = KItem.GetObjById(nItemId1);	
	local pPlayer1 = KPlayer.GetPlayerObjById(nPlayerId1);
	local pItem2 = KItem.GetObjById(nItemId2);	
	local pPlayer2 = KPlayer.GetPlayerObjById(nPlayerId2);
	if not pItem1 or not pPlayer1 or not pItem2 or not pPlayer2 then
		self:UseItemFail(nPlayerId1, nPlayerId2);
		return 0;
	end
	pItem1.Delete(pPlayer1);
	pPlayer1.AddItemEx(unpack(self.tbAwardItem));
	local nMapId, nX, nY = pPlayer1.GetWorldPos();
	local pNpc = KNpc.Add2(self.nNpcId, 1, -1, nMapId, nX, nY);
	if pNpc then
		pNpc.szName = pPlayer1.szName.."的"..pNpc.szName;
		pNpc.SetLiveTime(30*60*18);
	end
	Dialog:SendBlackBoardMsg(pPlayer1, "恭喜你升起了佳节红灯并获得奖励。");
	pItem2.Delete(pPlayer2);
	pPlayer2.AddItemEx(unpack(self.tbAwardItem));
	local nMapIdEx, nXEx, nYEx = pPlayer2.GetWorldPos();
	local pNpcEx = KNpc.Add2(self.nNpcId2, 1, -1, nMapIdEx, nXEx, nYEx);
	if pNpcEx then
		pNpcEx.szName = pPlayer2.szName.."的"..pNpcEx.szName;
		pNpcEx.SetLiveTime(30*60*18);
	end
	Dialog:SendBlackBoardMsg(pPlayer2, "恭喜你升起了佳节红灯并获得奖励。");
end

--使用失败
function tbLantem_2011:UseItemFail(nPlayerId1, nPlayerId2)	
	local szMsg = "请和你的好友同时点燃国庆明灯。";
	local pPlayer1 = KPlayer.GetPlayerObjById(nPlayerId1);	
	if pPlayer1 then
		Dialog:SendBlackBoardMsg(pPlayer1, szMsg);
	end
	local pPlayer2 = KPlayer.GetPlayerObjById(nPlayerId2);
	if pPlayer2 then
		Dialog:SendBlackBoardMsg(pPlayer2, szMsg);
	end
	return;
end
