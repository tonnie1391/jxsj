local tbNpc = Npc:GetClass("tulengzhu_switch")

tbNpc.tbCommonRoomMsg =
{
--房间号 {x,y}
	[4]  = {"以彼人之道，还治彼人之身。若想打开前路必须通过考验，欲通过者将手按于碑面。","把手按在石碑上面"},
	[6]  = {"欲速则不达。若想打开前路必须通过考验，欲通过者将手按于碑面。","把手按在石碑上面"},
	[23] = {"无法看见的危险。若想打开前路必须通过考验，欲通过者将手按于碑面。","把手按在石碑上面"},
	[24] = {"你将能遇到你的影子。若想打开前路必须通过考验，欲通过者将手按于碑面。","把手按在石碑上面"},
	[25] = {"行若风，奔如雷。若想打开前路必须通过考验，欲通过者将手按于碑面。","把手按在石碑上面"},
}
tbNpc.tbCoreRoomMsg =
{
	szCoreRoom = {"通往前路的关键在%s，欲通过者将手按于碑面。","把手按在石碑上面", "石碑上清楚的刻着：%s， 机关已被人按下了。"},
	szRunRoom = {"%s，欲通过者将手按于碑面。","把手按在石碑上面", "石碑上清楚的刻数字：%s， 机关已被人按下了。"},
}

function tbNpc:OnDialog()
	self:OnSwitch(him.dwId, 0);
end

function tbNpc:OnSwitch(nNpcId, nSure)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end	
	local tbTmp = pNpc.GetTempTable("KinGame");
	local pRoom = tbTmp.tbLockTable.tbRoom;
	local nRoomId = pRoom.nRoomId;
	if nRoomId >= 7 and nRoomId <= 22 then
		--密码间
		
		local tbLock = pRoom:GetNextLock();
		local nNextRoomId = tbLock[1].tbLock.nRoomId
		if nNextRoomId > 22 then
			if tbTmp.tbLockTable:IsLock() == 1 then
				Dialog:SendBlackBoardMsg(me, "这个石碑的机关已经被人开动过了。");
				return 0;
			end
			Dialog:Say("你听到了“咔！”的一声脆响。");
			KinGame:NpcUnLockMulti(pNpc);
			return 0;
		end

		
		local szRoomName = KinGame.ROOM_NAME[nNextRoomId];		
		local szParam = "szCoreRoom";
		if nRoomId >=7 and nRoomId <= 14 then
			--天地日月，青龙，白虎，朱雀，玄武
			szParam = "szRunRoom"
		end
		if tbTmp.tbLockTable:IsLock() == 1 then
			Dialog:SendBlackBoardMsg(me, string.format(self.tbCoreRoomMsg[szParam][3],szRoomName));
			
			return 0;
		end
		if nSure == 1 then
			Dialog:SendBlackBoardMsg(me, string.format("你触动了机关，%s开启了。",szRoomName));
			KinGame:NpcUnLockMulti(pNpc);
			return 0;
		end		
		
		local szMsg = string.format(self.tbCoreRoomMsg[szParam][1],szRoomName);
		local tbOpt =
		{
			{self.tbCoreRoomMsg[szParam][2], self.OnSwitch, self, him.dwId, 1},
			{"Kết thúc đối thoại"}
		}
		Dialog:Say(szMsg, tbOpt);		
	else
		if tbTmp.tbLockTable:IsLock() == 1 then
			Dialog:SendBlackBoardMsg(me, "这个石碑的机关已经被人开动过了。");
			return 0;
		end
		if self.tbCommonRoomMsg[nRoomId] == nil then
			return 0;
		end
		if nSure == 1 then
			KinGame:NpcUnLockMulti(pNpc);
			Dialog:SendBlackBoardMsg(me,"你触动了机关，房间里出现了一些守卫！");
			return 0;
		end
		local tbOpt =
		{
			{self.tbCommonRoomMsg[nRoomId][2], self.OnSwitch, self, him.dwId, 1},
			{"Kết thúc đối thoại"}
		}
		Dialog:Say(self.tbCommonRoomMsg[nRoomId][1], tbOpt);
	end
end
