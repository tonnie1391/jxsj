-------------------------------------------------------------------------
-- Author		:	LuoBaohang
-- CreateTime	:	2005-09-02
-- Desc			:  	地图切换触发脚本头文件--函数定义
-------------------------------------------------------------------------

local tbSwitchs	= Map.tbSwitchs; --开关函数定义，每个函数规定有且只有一个开关参数(进入为1，退出为0)

--状态开关(强制转换为练功模式,禁止改变模式,禁止仇杀,禁止改变阵营,禁止切磋)
function tbSwitchs:PKMODEL_OFF(bIn)
	if (bIn == 1) then
		me.nPkModel = Player.emKPK_STATE_PRACTISE;
		me.nForbidChangePK	= 1;
		me.ForbidEnmity(1);
		me.ForbidExercise(1);
		me.DisableChangeCurCamp(1);
	else
		me.nForbidChangePK	= 0;
		me.DisableChangeCurCamp(0);
		me.ForbidEnmity(0);
		me.ForbidExercise(0);
	end;
end;

--开启组队操作
function tbSwitchs:TEAM_ON(bIn)
	if (bIn == 1) then
		if me.IsDisabledTeam() == 1 then
			me.TeamDisable(0);
		end
	end
end

--队伍开关(离开队伍,禁止组队)
function tbSwitchs:TEAM_OFF(bIn)
	if (bIn == 1) then
		me.LeaveTeam();
		me.TeamDisable(1);
		--me.Msg("组队关闭！")
	else
		me.TeamDisable(0);
		--me.Msg("组队开启！")
	end;
end;

-- 祈福开关
function tbSwitchs:PRAY_OFF(bIn)
	if (bIn == 1) then
		Task.tbPlayerPray:DisablePray(me);
	else
		Task.tbPlayerPray:EnablePray(me);
	end;
end

--离线保存位置(1不保存,0常规保存)
function tbSwitchs:LOGINREVOUT_OFF(bIn)
	if (bIn == 1) then
		me.SetLogoutRV(1);
	else
		me.SetLogoutRV(0);
	end;
end;

--死亡惩罚(1无惩罚,0常规惩罚)
function tbSwitchs:PUNISH_OFF(bIn)
	if (bIn == 1) then
		me.SetNoDeathPunish(1);
	else
		me.SetNoDeathPunish(0);
	end;
end;

--战斗关闭状态(1进入非战斗状态)
function tbSwitchs:FIGHTSTATE_OFF(bIn)
	if (bIn == 1) then
		me.SetFightState(0)
	end;
end;

--战斗开启(1进入战斗状态)
function tbSwitchs:FIGHTSTATE_ON(bIn)
	if (bIn == 1) then
		me.SetFightState(1)
	end;
end;

--还原原始阵营(1,阵营不变,0还原原始阵营)
function tbSwitchs:RESTORECURCAMP(bIn)
	if (bIn == 1) then
	else
		me.SetCurCamp(GetCamp())
	end;
end;

--摆摊收购(1,禁止摆摊和收购,0还原摆摊收购)
function tbSwitchs:STALL_OFF(bIn)
	if(bIn == 1) then
		me.DisabledStall(1);
		me.DisableOffer(1);
	else
		me.DisabledStall(0);
		me.DisableOffer(0);
	end;
end;

--禁用公聊(1.禁用奇珍阁,禁用公聊,密聊,禁止获得托管时间) --注意:大牢自己维护,不能使用本接口禁用.,临时使用,以后整理
function tbSwitchs:CHAT_OFF(bIn)
	if bIn == 1 then
		me.SetForbidChat(1);
	else
		me.SetForbidChat(0);
	end
end

--禁止所有聊天频道使用（GM频道允许）
function tbSwitchs:CHAT_NEW_OFF(bIn)
	if bIn == 1 then
		me.SetChannelState(-1, 1);
	else
		me.SetChannelState(-1, 0);
	end
end

function tbSwitchs:TONG_PKMODEL_ON(bIn)
	if (bIn == 1) then
		me.SetFightState(1);
		me.nPkModel = Player.emKPK_STATE_TONG;
		me.nForbidChangePK	= 1;
		me.ForbidEnmity(1);
		me.ForbidExercise(1);
		me.DisableChangeCurCamp(1);
	else
		me.nForbidChangePK	= 0;
		me.DisableChangeCurCamp(0);
		me.ForbidEnmity(0);
		me.ForbidExercise(0);
	end;
end

--帮会地图状态(旧版本,无用可删除)
function tbSwitchs:TONG_MAP(bIn)
	self:PUNISH_OFF(bIn)
	self:RESTORECURCAMP(bIn)
	self:STALL_OFF(bIn)
	if (bIn == 1) then
		me.SetTmpDeathPos(SubWorldIdx2ID(SubWorld),aRevPos.x * 32,aRevPos.y * 32)
	else
		me.SetRevivePos(me.GetRevivePos())
	end;
	--地图禁制扔出
	if (bIn == 1 and GetMapType(SubWorld) == 1)then
		local nTongID = GetMapParam(SubWorld, 0)
		if (nTongID ~= 0)then
			local _,b = me.GetTongName()
			if (b ~= nTongID and TONG_GetTongMapBan(nTongID) == 1)then
				local pos = GetMapEnterPos(SubWorldIdx2MapCopy(SubWorld))
				me.SetFightState(0)
				SetPos(pos.x, pos.y)
			end;
		end;
	end;
end;

--变身状态
function tbSwitchs:CHANGE_ON(bIn)
	if (bIn == 1) then
		
		local nTime = me.GetTask(2192,34);
		local nType = me.GetTask(2192,44);
		if me.GetSkillState(2764) < 0 and nTime > 0 and nType > 0 and GetTime() - nTime <= 900 then
			local nMap, x, y = me.GetWorldPos();
			me.CastSkill(2764, nType, x, y);
		end
	else
		if me.GetSkillState(2764) > 0 then
			me.RemoveSkillState(2764);
		end
	end
end
