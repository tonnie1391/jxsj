
if (not Item.tbShiTuChuanSongFu) then
	Item.tbShiTuChuanSongFu = {};
end

local tb = Item.tbShiTuChuanSongFu;
tb.ITEM_ID = {18,1,65,1};
tb.tbc2sFun = {};

-- GC询问各个Server指定的徒弟是否在线
function tb:SelectDstPlayerPos(szDstPlayerName, szAppPlayerName)
	GlobalExcute({"Item.tbShiTuChuanSongFu:SeachPlayer", szDstPlayerName, szAppPlayerName});
end


-- GS 搜索本服务器上是否有指定玩家
function tb:SeachPlayer(szDstPlayerName, szAppPlayerName)
	-- 如果找到的话返回这个玩家的坐标
	local pDstPlayer = GetPlayerObjFormRoleName(szDstPlayerName);
	if (pDstPlayer) then
		local nMapId, nPosX, nPosY = pDstPlayer.GetWorldPos();
		local nCanSendIn  = Item:IsCallOutAtMap(nMapId, unpack(self.ITEM_ID));
		if (nCanSendIn ~= 1) then
			nMapId = -1;
		end	
		GCExcute({"Item.tbShiTuChuanSongFu:FindDstPlayer", szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY});		
	end
end


-- GC 得到指定徒弟信息，通知师傅
function tb:FindDstPlayer(szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY)
	GlobalExcute({"Item.tbShiTuChuanSongFu:ObtainDstPlayerPos", szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY})
end


-- GS 师傅得知徒弟位置
function tb:ObtainDstPlayerPos(szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY)

	local pAppPlayer = GetPlayerObjFormRoleName(szAppPlayerName);
	if (not pAppPlayer) then
		return 0;
	end
	if nMapId == -1 then
		pAppPlayer.Msg("不可以传送到目标地图！");
		return 0;
	end
	local nCanSendOut = Item:IsCallInAtMap(nMapId, unpack(self.ITEM_ID));
	if (nCanSendOut ~= 1) then
		pAppPlayer.Msg("当前地图不可以被传送！");
		return 0;
	end
	
	-- 通知徒弟确认
	GCExcute({"Item.tbShiTuChuanSongFu:Msg2DstPlayer4Confirm_GC", szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY});
end


-- GC 通知徒弟确认
function tb:Msg2DstPlayer4Confirm_GC(szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY)
	GlobalExcute({"Item.tbShiTuChuanSongFu:Msg2DstPlayer4Confirm_GS", szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY});
end

-- GS 通知徒弟确认
function tb:Msg2DstPlayer4Confirm_GS(szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY)
	local pDstPlayer = GetPlayerObjFormRoleName(szDstPlayerName);
	if (not pDstPlayer) then
		return;
	end
	
	pDstPlayer.CallClientScript({"Item.tbShiTuChuanSongFu:Msg2DstPlayer4Confirm_C", szDstPlayerName, szAppPlayerName});
end

-- C
function tb:Msg2DstPlayer4Confirm_C(szDstPlayerName, szAppPlayerName)
	CoreEventNotify(UiNotify.emCOREEVENT_CONFIRMATION, UiNotify.CONFIRMATION_TEACHER_CONVECTION, szDstPlayerName, szAppPlayerName);
end

-- GS徒弟确认后,bAccept为(0.拒绝，1.同意)
function tb:DstPlayerAccredit(szDstPlayerName, szAppPlayerName, bAccept)	
	local pStudent = GetPlayerObjFormRoleName(szDstPlayerName);
	if (not pStudent) then
		return;
	end
	if (bAccept ~= 1) then
		Item.tbShiTuChuanSongFu:Msg2Player_GS(szAppPlayerName, "你的徒弟现在不需要你过来！");
		return;
	end
	
	local nMapId, nPosX, nPosY = pStudent.GetWorldPos();
	local nStudentFightState = pStudent.nFightState;
	local nCanSendIn  = Item:IsCallOutAtMap(nMapId, unpack(Item.tbShiTuChuanSongFu.ITEM_ID));
	if (nCanSendIn ~= 1) then
		nMapId = -1;
	end	
	
	-- 让师傅传过来
	GCExcute({"Item.tbShiTuChuanSongFu:AgreeTeacherComeHere_GC", szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY,nStudentFightState});		
end
tb.tbc2sFun["DstPlayerAccredit"] = tb.DstPlayerAccredit;


-- GC让师傅传送到指定地图
function tb:AgreeTeacherComeHere_GC(szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY, nStudentFightState)
	GlobalExcute({"Item.tbShiTuChuanSongFu:AgreeTeacherComeHere_GS", szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY, nStudentFightState});
end


-- GS 收到徒弟确认传，师傅可以传了
function tb:AgreeTeacherComeHere_GS(szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY, nStudentFightState, nSure)
	local pPlayer = GetPlayerObjFormRoleName(szAppPlayerName);
	if (not pPlayer) then
		return;
	end
	local szDestStudent = pPlayer.GetTempTable("Item").szBeComeToSutdentName;
	if (not szDestStudent or szDestStudent ~= szDstPlayerName) then
		self:Msg2Player_GS(szDstPlayerName, "师徒传送申请已经过期，如需要重新传送，必须重新申请。")
		pPlayer.Msg("师徒传送申请已经过期，如需要重新传送，必须重新申请。");
		return;
	end
	if nMapId == -1 then
		pPlayer.Msg("不可以传送到目标地图！");
		return 0;
	end
	local nRet, szMsg = Map:CheckTagServerPlayerCount(nMapId)
	if nRet ~= 1 then
		pPlayer.Msg(szMsg);
		return 0;
	end
	local nCanSendOut = Item:IsCallInAtMap(nMapId,unpack(self.ITEM_ID));
	if (nCanSendOut ~= 1) then
		pPlayer.Msg("当前地图不可以被传送！");
		return 0;
	end
	if (nSure ~= 1 and pPlayer.nFightState == 1) then				-- 玩家在非战斗状态下传送无延时正常传送
		local tbEvent	= {-- 会中断延时的事件
			Player.ProcessBreakEvent.emEVENT_MOVE,
			Player.ProcessBreakEvent.emEVENT_ATTACK,
			Player.ProcessBreakEvent.emEVENT_SITE,
			Player.ProcessBreakEvent.emEVENT_USEITEM,
			Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
			Player.ProcessBreakEvent.emEVENT_DROPITEM,
			Player.ProcessBreakEvent.emEVENT_SENDMAIL,
			Player.ProcessBreakEvent.emEVENT_TRADE,
			Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
			Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
			Player.ProcessBreakEvent.emEVENT_LOGOUT,
			Player.ProcessBreakEvent.emEVENT_DEATH,
			Player.ProcessBreakEvent.emEVENT_ATTACKED,
			};
		Setting:SetGlobalObj(pPlayer)
		GeneralProcess:StartProcess("正在传送中...", 10 * Env.GAME_FPS, {self.AgreeTeacherComeHere_GS, self, szDstPlayerName, szAppPlayerName, nMapId, nPosX, nPosY, nStudentFightState, 1}, nil, tbEvent);
		Setting:RestoreGlobalObj()
		return 0;
	end
	pPlayer.GetTempTable("Item").szBeComeToSutdentName = nil;
	pPlayer.SetFightState(nStudentFightState);
	pPlayer.NewWorld(nMapId, nPosX, nPosY);
end

-- GS发送消息给指定玩家
function tb:Msg2Player_GS(szPlayerName, szMsg)
	GCExcute({"Item.tbShiTuChuanSongFu:Msg2Player_GC", szPlayerName, szMsg});	
end

-- GC发送消息给指定玩家
function tb:Msg2Player_GC(szPlayerName, szMsg)
	GlobalExcute({"Item.tbShiTuChuanSongFu:ReceiveMsg", szPlayerName,szMsg});
end

-- GS收到发送给某个玩家的消息
function tb:ReceiveMsg(szPlayerName, szMsg)
	local pPlayer = GetPlayerObjFormRoleName(szPlayerName);
	if (not pPlayer) then
		return;
	end
	
	pPlayer.Msg(szMsg);
end

