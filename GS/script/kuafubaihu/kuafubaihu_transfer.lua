-------------------------------------------------------
-- 文件名　：kuafubaihu_map.lua
-- 创建者　：zhangjunjie
-- 创建时间：2010-12-17 15:24
-- 文件描述：
-------------------------------------------------------


Require("\\script\\kuafubaihu\\kuafubaihu_def.lua")

--传送到跨服准备场
function KuaFuBaiHu:NewWorld2GlobalMap(pPlayer)
	local tbPos = self.tbWaitMapPos[MathRandom(#self.tbWaitMapPos)];
	local nWaitMapCount = #self.tbWaitMapIdList;	--有几个准备场
	--如果是全区服，调用返回至跨服白虎准备场
	if GLOBAL_AGENT then	
		local nTransferId = Transfer:GetMyTransferId(pPlayer);
		local nServerId = nTransferId % nWaitMapCount + 1;
		local nMapId = self.tbWaitMapIdList[nServerId][1];
		if not nMapId then
			return 0;
		end
		pPlayer.NewWorld(nMapId, tbPos.nX/32, tbPos.nY/32);	
		return 0;
	end
	-----如果是本服，进行跨服操作-------
	pPlayer.SetLogoutRV(0);
	local nTransferId = Transfer:GetMyTransferId(pPlayer);
	local nServerId = nTransferId % nWaitMapCount + 1;
	local nMapId = self.tbWaitMapIdList[nServerId][1];	-- 单号transerid进2号准备场,双号的进1号准备场
	if not nMapId then
		return 0;
	end
	-- 跨过去的人数超过上限
	if BaiHuTang.nEnteredGBMapPlayer >= BaiHuTang.MAX_COUNT_TRANSFER then
		local szMsg = "你所在帮会或联盟人手已够，请下次再来！";
		pPlayer.Msg(szMsg,"系统提示");
		Dialog:SendBlackBoardMsg(pPlayer,szMsg);
		return 0;
	end
	local nCanSure = Map:CheckGlobalPlayerCount(nMapId);
	if nCanSure == 0 or nCanSure < 0 then	--人满或者地图未加载,则找到空闲地图给玩家分配
		local bFindFreeMap = 0;	--是否找到空闲地图
		local nOtherCanSure = 0;
		for i = 1 , nWaitMapCount do
			if i ~= nServerId then
				nMapId = self.tbWaitMapIdList[i][1];
				nOtherCanSure = Map:CheckGlobalPlayerCount(nMapId);
				if nOtherCanSure == 1 then
					bFindFreeMap = 1;
					break;
				end
			end
		end
		if bFindFreeMap == 0 then
			if nOtherCanSure < 0 then
				pPlayer.Msg("Đường phía trước bị chặn.","系统提示");
				Dialog:SendBlackBoardMsg(pPlayer,"Đường phía trước bị chặn.");
				return 0;
			end
			if nOtherCanSure == 0 then
				local szMsg = "前方人满为患,请稍后再试!";
				pPlayer.Msg(szMsg,"系统提示");
				Dialog:SendBlackBoardMsg(pPlayer,szMsg);
				return 0;
			end	
		end
	end
	--通过任务变量同步数据
	local szGate = Transfer:GetMyGateway(pPlayer);	--网关名， gatexxx
	--local szGateName = ServerEvent:GetServerNameByGateway(szGate);
	local pTong = KTong.GetTong(pPlayer.dwTongId);
	local nRiches = GetPlayerHonor(pPlayer.nId,PlayerHonor.HONOR_CLASS_MONEY,0);
	if pTong then
		pPlayer.SetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_SERVER_NAME,szGate);	--同步网关名
		pPlayer.SetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_NAME,pTong.GetName()); --同步帮会名
		pPlayer.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_ID,pPlayer.dwTongId);	--同步帮会id
		pPlayer.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_UNION_ID,pPlayer.dwUnionId);	--同步联盟id
		pPlayer.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_RICHES,nRiches or 0);
		pPlayer.GlobalTransfer(nMapId, tbPos.nX / 32, tbPos.nY /32);
		BaiHuTang.nEnteredGBMapPlayer = BaiHuTang.nEnteredGBMapPlayer + 1;	--每次过去的时候，增加一个	
	end
	Dbg:WriteLogEx(2, "KuafuBaiHu","Transfer:",nMapId,pPlayer.nId,pPlayer.szName);
end

--跨回本服
function KuaFuBaiHu:NewWorld2MyServer(pPlayer)
	if GLOBAL_AGENT then
		local tbReturnMap = self.tbReturnMapIdList;
		local tbPos = self.tbReturnMapPos[MathRandom(#self.tbReturnMapPos)];
		local nMapIdEx	= tbReturnMap[1];
		local nPosX		= tbPos.nX;
		local nPosY		= tbPos.nY;
		pPlayer.GlobalTransfer(nMapIdEx, nPosX/32, nPosY/32);	
		Dbg:WriteLogEx(2, "KuafuBaiHu","TransferToMyserver:",nMapIdEx,pPlayer.nId,pPlayer.szName,GetLocalDate("%H:%M-%S"));
	end
end

