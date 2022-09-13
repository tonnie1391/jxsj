-------------------------------------------------------
-- 文件名　：kinbattle_look.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-7 10:15:46
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\mission\\kinbattle\\kinbattle_def.lua");

function KinBattle:OnLookDialog()
	if me.nLevel < KinBattle.LOOKER_LEVEL then
		me.Msg("只有达到<color=yellow>50级<color>的玩家才能进入比赛场地");
		Dialog:Say("只有达到<color=yellow>50级<color>的玩家才能进入比赛场地");
		return 0;
	end
	local tbKinBattleInfoList = KinBattle:GetBattleInfoList();
	if #tbKinBattleInfoList <= 0 then
		Dialog:Say("暂时没有家族战可观看");
		return 0;
	end
	local szMsg = string.format("下列每场家族战最多允许<color=yellow>%s人<color>同时观看。灰色选项表示预定成功即将开始家族战。\n<color=yellow>您想观看哪两个家族间的较量？<color>", KinBattle.MAX_LOOKER_COUNT);
	local tbOpt = {};
	for _, tbTemp in ipairs(tbKinBattleInfoList) do
		local szTitle = string.format("%s <color=yellow>VS<color> %s", tbTemp.szKinName, tbTemp.szKinNameMate);
		if tbTemp.nMissionState ~= 2 then
			szTitle = "<color=gray>" .. szTitle .. "<color>";
		end
		table.insert(tbOpt, {szTitle, self.LookMatch, self, tbTemp.nId, tbTemp.nKinId, tbTemp.nKinIdMate});
	end
	table.insert(tbOpt, "Kết thúc đối thoại");
	Dialog:Say(szMsg, tbOpt);
end

function KinBattle:LookMatch(nIndex, nKinId, nKinIdMate)
	if self.tbMissionList[nIndex].nState ~= 1 or self.tbMissionList[nIndex].nKinId ~= nKinId and self.tbMissionList[nIndex].nKinIdMate ~= nKinIdMate then
		Dialog:Say("本场家族战未开战或者已关闭！");
		return 0;
	end
	local nSelfKinId = me.GetKinMember();
	if nSelfKinId == nKinId or nSelfKinId == nKinIdMate then
		Dialog:Say("您无法观看自己家族的家族战");
		return 0;
	end
	-- 还没进入战斗不允许进入观看
	if self.tbMissionList[nIndex].nMissionState < 2 then
		local nResFrame = math.floor((KinBattle.TIMER_SIGNUP / 18) - (GetTime() - self.tbMissionList[nIndex].nStartTime)) * 18;
		local szTime = Lib:FrameTimeDesc(nResFrame);
		if nResFrame <= 0 then
			szTime = "0分1秒";
		end
		Dialog:Say("该家族战还有<color=yellow>" .. szTime .. "<color>开战，等他们开打了再来吧");
		return 0;
	end
	if self.tbMissionList[nIndex].nLookerCount >= KinBattle.MAX_LOOKER_COUNT then
		Dialog:Say("观战人数已达到上限，下次请早吧。");
		return 0;
	end
	local nMapType = self:GetMapType(nIndex);
	local nCityId = KinBattle.MAP_LIST[nIndex][4]; 
	local tbLeavePos = {nCityId, unpack(KinBattle.LEAVE_POS[nCityId])};
	Looker:Join(me, 3, KinBattle.MAP_LIST[nIndex][1], KinBattle.MAP_LOOKER_POS[nMapType][1], KinBattle.MAP_LOOKER_POS[nMapType][2], 1, tbLeavePos);
end

function KinBattle:LookOnEnterPk()
	me.SetFightState(0);
	local nMissionId = self:GetMissionIdByMapId(me.nMapId);
	if nMissionId == -1 then
		Looker:Leave(me);
		return 0;
	end
	local tbMission = KinBattle.tbMissionList[nMissionId].tbMission;
	if not tbMission or tbMission:IsOpen() == 0 then
		Looker:Leave(me);
		return 0;
	end
	self:OpenSingleUi(me, "<color=green>Thời gian còn lại: <color> <color=white>%s<color>", tbMission:GetStateLastTime());
	tbMission:JoinLooker(me);
	me.Msg("已进入家族战场，若要退出观战，可点击右下角按钮。");
	Dialog:SendBlackBoardMsg(me, "已进入家族战场，若要退出观战，可点击右下角按钮。");
	GCExcute({"KinBattle:AddLooker", nMissionId, me.nId});
	GlobalExcute({"KinBattle:AddLooker", nMissionId, me.nId});
end

function KinBattle:LookOnLeavePk()
	local nMissionId = self:GetMissionIdByMapId(me.nMapId);
	if nMissionId ~= -1 then
		local tbMission = KinBattle.tbMissionList[nMissionId].tbMission;
		if tbMission and tbMission:IsOpen() == 1 then
			tbMission:LeaveLooker(me);
		end
	end
	self:CloseSingleUi(me);
	me.Msg("您已离开家族战场");
	Dialog:SendBlackBoardMsg(me, "您已离开家族战场");
	GCExcute({"KinBattle:ReduceLooker", nMissionId, me.nId});
	GlobalExcute({"KinBattle:ReduceLooker", nMissionId, me.nId});
end

function KinBattle:OpenSingleUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer, szMsg, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

function KinBattle:CloseSingleUi(pPlayer)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面信息
function KinBattle:UpdateMsgUi(pPlayer, szMsg)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
end