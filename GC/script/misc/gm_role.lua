-- GM角色相关

local tbGMRole	= {};
GM.tbGMRole		= tbGMRole;

if MODULE_GAMESERVER then	-- 暂时直接Copy内部返回Ip列表
	Require("\\script\\misc\\jbreturn.lua");
	tbGMRole.tbPermitIp	= Lib:CopyTB1(jbreturn.tbPermitIp);
end

tbGMRole.SKILLID_GMHIDE	= 1462;

-- 产生GM角色
function tbGMRole:MakeGmRole()
	me.AddLevel(5-me.nLevel);	-- 初始5级
	
	me.SetCamp(6);				-- GM阵营
	me.SetCurCamp(6);
	
	me.AddFightSkill(163,60);	-- 60级梯云纵
	me.AddFightSkill(91,60);	-- 60级银丝飞蛛
	me.AddFightSkill(1417,1);	-- 1级移形换影
	
	me.SetExtRepState(1);		--	扩展箱令牌x1（已使用）

	me.AddItemEx(21, 8, 1, 1, {bForceBind=1}, 0);	-- 20格背包x3（绑定）
	me.AddItemEx(21, 8, 1, 1, {bForceBind=1}, 0);
	me.AddItemEx(21, 8, 1, 1, {bForceBind=1}, 0);
	me.AddItemEx(18, 1, 195, 1, {bForceBind=1}, 0);	-- 无限传送符（无限期，绑定）
	me.AddItemEx(18, 1, 400, 1, {bForceBind=1}, 0);	-- GM专用卡（无限期，绑定）
	local pItem	= me.AddItemEx(1, 13, 17, 1, {bForceBind=1}, 0);	-- 二丫面具（无限期，绑定）
	me.DelItemTimeout(pItem);
	pItem	= me.AddItemEx(1, 13, 15, 1, {bForceBind=1}, 0);		-- 圣诞少女面具（无限期，绑定）
	me.DelItemTimeout(pItem);
	
	me.AddBindMoney(100000, 100);
end

-- 召唤某人到这里
function tbGMRole:CallHimHere(nPlayerId)
	self:_CallSomeoneHere(me.nId, nPlayerId, string.format("拉玩家(%s)到当前位置", KGCPlayer.GetPlayerName(nPlayerId)));
end

-- 传送自己到某人处
function tbGMRole:SendMeThere(nPlayerId)
	local szOperation	= string.format("传送至玩家(%s)处", KGCPlayer.GetPlayerName(nPlayerId));
	GM.tbGMRole:_ApplyPlayerCall(me.nId, szOperation, nPlayerId, "GM.tbGMRole:_CallSomeoneHere", me.nId, me.nId, szOperation);
end

-- 关某人入天牢
function tbGMRole:ArrestHim(nPlayerId)
	local pPlayer	= KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "GM Arrest to TianLao");
	end
	self:_OnLineCmd(me.nId, string.format("关玩家(%s)入天牢", KGCPlayer.GetPlayerName(nPlayerId)), nPlayerId, "Player:Arrest(me.szName)");
end

-- 解除某人天牢
function tbGMRole:FreeHim(nPlayerId)
	self:_OnLineCmd(me.nId, string.format("解除玩家(%s)天牢", KGCPlayer.GetPlayerName(nPlayerId)), nPlayerId, "Player:SetFree(me.szName)");
end

-- 踢某人下线
function tbGMRole:KickHim(nPlayerId)
	local szOperation	= string.format("踢玩家(%s)下线", KGCPlayer.GetPlayerName(nPlayerId));
	GM.tbGMRole:_ApplyPlayerCall(me.nId, szOperation, nPlayerId, "GM.tbGMRole:_KickMe", me.nId, szOperation);
end

-- 尝试执行玩家指令，出错会有日志
function tbGMRole:_ApplyPlayerCall(nGMPlayerId, szOperation, nPlayerId, ...)
	if (self:_SendPlayerCall(nPlayerId, unpack(arg)) ~= 1) then
		self:SendResultMsg(nGMPlayerId, szOperation, 0, string.format("玩家(%s)不在线", KGCPlayer.GetPlayerName(nPlayerId)));
	end
end

-- 执行玩家离线指令，并产生执行结果
function tbGMRole:_OnLineCmd(nGMPlayerId, szOperation, nPlayerId, szScriptCmd)
	GCExcute({"GM.tbGMRole:_OnLineCmd_GC", nGMPlayerId, szOperation, nPlayerId, szScriptCmd});
end
function tbGMRole:_OnLineCmd_GC(nGMPlayerId, szOperation, nPlayerId, szScriptCmd)
	local szName	= KGCPlayer.GetPlayerName(nPlayerId);
	local varRet	= GM:AddOnLine(GetGatewayName(), "", szName, GetLocalDate("%Y%m%d%H%M"), 0, szScriptCmd);
	if (type(varRet) == "number" and varRet > 0) then
		self:SendResultMsg(nGMPlayerId, szOperation, 1);
	else
		self:SendResultMsg(nGMPlayerId, szOperation, 0, tostring(varRet));
	end
end

-- 发出玩家执行操作
function tbGMRole:_SendPlayerCall(nPlayerId, ...)
	local nState	= KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_ONLINESERVER);
	if (nState <= 0) then
		return 0;
	end
	
	GlobalExcute({"GM.tbGMRole:_OnPlayerCall", nPlayerId, arg})

	return 1;
end

-- 收到玩家执行操作
function tbGMRole:_OnPlayerCall(nPlayerId, tbCallBack)
	local pPlayer	= KPlayer.GetPlayerObjById(nPlayerId);
	if (pPlayer) then
		pPlayer.Call(unpack(tbCallBack));
		self:DbgOut("_OnPlayerCall", pPlayer.szName, tostring(tbCallBack[1]));
	end
end

-- 写脚本日志
function tbGMRole:ScriptLogF(pPlayer, ...)
	local szMsg	= string.format(unpack(arg));
	Dbg:WriteLogEx(Dbg.LOG_INFO, "GM", "GM_Operation", pPlayer.szName, szMsg);
end

-- 发送GM操作结果消息并写客服日志
function tbGMRole:SendResultMsg(nGMPlayerId, szOperation, bSuccess, szDetail)
	GM.tbGMRole:_SendPlayerCall(nGMPlayerId, "GM.tbGMRole:_OnResultMsg", szOperation, bSuccess, szDetail);
end
function tbGMRole:_OnResultMsg(szOperation, bSuccess, szDetail)
	local szMsg	= "";
	if (szOperation) then
		szMsg	= szMsg.."【操作】"..szOperation.."；";
	end
	if (bSuccess) then
		szMsg	= szMsg.."【结果】"..((bSuccess == 1 and "成功") or "失败").."；";
	end
	if (szDetail) then
		szMsg	= szMsg.."【详细】"..szDetail.."；";
	end
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_GM_OPERATION, szMsg);
	self:ScriptLogF(me, szMsg);
	me.Msg(szMsg);
end

-- 是否隐身中
function tbGMRole:IsHide()
	return me.IsHaveSkill(self.SKILLID_GMHIDE);
end

-- 设置隐身
function tbGMRole:SetHide(nHide)
	if (nHide == 1) then
		me.AddFightSkill(self.SKILLID_GMHIDE, 1);
	else
		me.DelFightSkill(self.SKILLID_GMHIDE);
	end
	self:SendResultMsg(me.nId, (nHide == 1 and "开始隐身") or "取消隐身", 1);
end

-- 获取允许最大设置为多少级
function tbGMRole:GetMaxAdjustLevel()
	local nLadderLevel	= 0;
	local tbInfo		= GetLadderPlayerInfoByRank(0x00020100, 10);	-- 排行榜第10名
	if (tbInfo) then
		local _,_,Level = string.find(tbInfo.szContext, "(-?%d+)(.*)");
		nLadderLevel	= tonumber(Level) or 0;
	end
	return math.max(nLadderLevel, 10);	-- 至少可以到达10级
end

-- 调整自身等级
function tbGMRole:AdjustLevel(nLevel)
	local szOperation	= string.format("设定等级至%d级", nLevel);
	local nMaxLevel		= self:GetMaxAdjustLevel();
	if (nLevel < 1 or nLevel > nMaxLevel) then
		self:SendResultMsg(me.nId, szOperation, 0, string.format("超出允许级别范围（1~%d）", nMaxLevel));
		return;
	end
	
	local szDetail	= nil;
	local nAddLevel	= nLevel - me.nLevel;
	if (nAddLevel < 0) then
		if (me.IsHaveSkill(91)) then
			me.DelFightSkill(91);	-- 银丝飞蛛
		end
		if (me.IsHaveSkill(163)) then
			me.DelFightSkill(163);	-- 梯云纵
		end
		if (me.IsHaveSkill(1417)) then
			me.DelFightSkill(1417);	-- 1级移形换影
		end
		me.ResetFightSkillPoint();	-- 重置技能点
		me.UnAssignPotential();		-- 重置潜能点
		me.Msg("<color=green>您进行了降级操作，需要退出重登。否则客户端显示会有异常。");
		szDetail	= "降级操作，引起技能点、潜能点重置";
	end
	me.AddLevel(nAddLevel);
	
	me.AddFightSkill(163, 60);	-- 60级梯云纵
	me.AddFightSkill(91, 60);	-- 60级银丝飞蛛
	me.AddFightSkill(1417, 1);	-- 1级移形换影
	
	self:SendResultMsg(me.nId, szOperation, 1, szDetail);
end

-- 当GM进入地图
function tbGMRole:OnEnterMap(nMapId)
	local szMsg	= string.format("到达地图：%s(%d)，隐身状态：%d", GetMapNameFormId(nMapId), nMapId, self:IsHide());
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_GM_OPERATION, szMsg);
	self:DbgOut(szMsg);
end

-- 当GM登入
function tbGMRole:OnLogin(nMapId)
	if (me.GetCamp() ~= 6) then
		return;
	end
	
	local szIp	= me.GetPlayerIpAddress();
	local nPos	= string.find(szIp, ":");
	szIp		= string.sub(szIp, 1, nPos - 1);
	if (not self.tbPermitIp[szIp]) then
		local szMsg	= string.format("！！！拒绝登陆IP：%s", szIp);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_GM_OPERATION, szMsg);
		self:DbgOut(szMsg);
		me.KickOut();
	end
end

-- 发送系统邮件
function tbGMRole:SendMail(nPlayerId, szContext)
	print(nPlayerId, szContext)
	local szName	= KGCPlayer.GetPlayerName(nPlayerId);
	local szTitle	= string.format("[%s]", me.szName);
	KPlayer.SendMail(szName, szTitle, szContext);
	
	self:SendResultMsg(me.nId, string.format("发邮件至玩家(%s)", szName), 1);
end

function tbGMRole:_CallSomeoneHere(nGMPlayerId, nPlayerId, szOperation)
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local szMapClass	= GetMapType(nMapId) or "";
	if (Map.tbMapItemState[szMapClass].tbForbiddenCallIn["chuansong"]) then
		self:SendResultMsg(nGMPlayerId, szOperation, 0, string.format("(%s)所在地图(%s)禁止传入", me.szName, GetMapNameFormId(nMapId)));
		return;
	end
	GM.tbGMRole:_ApplyPlayerCall(nGMPlayerId, szOperation, nPlayerId, "GM.tbGMRole:_CallMePos", nGMPlayerId, nMapId, nMapX, nMapY, szOperation);
end

function tbGMRole:_CallMePos(nGMPlayerId, nMapId, nMapX, nMapY, szOperation)
	local szMapClass	= GetMapType(me.nMapId) or "";
	if Item:IsCallOutAtMap(me.nMapId, "chuansong") ~= 1 then
		self:SendResultMsg(nGMPlayerId, szOperation, 0, string.format("(%s)所在地图(%s)禁止传出", me.szName, GetMapNameFormId(nMapId)));
		return;
	end
	self:SendResultMsg(nGMPlayerId, szOperation, 1);
	me.NewWorld(nMapId, nMapX, nMapY);
end

function tbGMRole:_KickMe(nGMPlayerId, szOperation)
	self:SendResultMsg(nGMPlayerId, szOperation, 1);
	me.KickOut();
end



-- 调试输出
function tbGMRole:DbgOut(...)
	Dbg:Output("GM", unpack(arg));
end

-- 注册Login
if (MODULE_GAMESERVER and not GM.tbGMRole.bReged) then
	local function fnOnLogin()
		GM.tbGMRole:OnLogin();
	end
	PlayerEvent:RegisterOnLoginEvent(fnOnLogin);
	GM.tbGMRole.bReged	= 1;
end

----------测试-------------
function tbGMRole:AddPermitIp(szIp)
	if MODULE_GC_SERVER then
		GlobalExcute{"GM.tbGMRole:AddPermitIp",szIp};	--广播状态	
		return;
	end
	if szIp and #szIp ~= 0 then
		self.tbPermitIp[szIp] = 1;
	end
end