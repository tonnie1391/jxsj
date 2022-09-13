------------------------------------------------------
-- 文件名　：stonethrower.lua
-- 创建者　：dengyong
-- 创建时间：2012-05-24 14:52:20
-- 描  述  ：载具----投石车
------------------------------------------------------
-- 操作列表：0移动控制，1填弹，2投弹
-- 注意，操作主角是him不是me，而且在客户端可能没有me，服务端肯定有me！

Require("\\script\\npc\\carrier\\basecarrier.lua");

local tbCarrier = Npc.tbCarrier or {};
local tbStoneThrower = tbCarrier:GetClass("StoneThrower");

local tbCarrierShortCutSkill =  Npc.tbCarrierShortCutSkill or {}
Npc.tbCarrierShortCutSkill = tbCarrierShortCutSkill;

tbCarrierShortCutSkill.tbConfig = 			--载具快捷键配置，前两位是被动技能，从3开始
{
	["tower"] = 
	{
		[0] = 
		{
			["SKILLS"]	= {3, 4, 5, 6},			--该位置所有技能
			["LEFT"]	=	3,					--左键技能，第一个为默认			
			["RIGHT"]	=	4, 					--右键技能，除默认技能其他的放在快捷栏

		},
		[1]	= {},								--炮台没有1号位
	},
	["StoneThrower"] = 
	{
		[0] = 
		{
			["SKILLS"]	= {3, 6},			--该位置所有技能
			["LEFT"]	=	0,				--默认左键技能	
			["RIGHT"]	=	6,				--默认右键技能，其他的放在快捷栏
		},
		[1]	= 
		{
			["SKILLS"]	= {4, 5},			--该位置所有技能
			["LEFT"]	=	0,				--默认左键技能
			["RIGHT"]	=	0,				--默认右键技能，其他的放在快捷栏
		},
	},
	["Boat2"] =
	{
		[0] =
		{
			["SKILLS"] = {1},
			["LEFT"]   = 1,
			["RIGHT"]  = 1,
		},
	}	
};

local OPERATION_FILL		= 1;
local OPERATION_THROW		= 2;


function tbStoneThrower:Init()
	self.tbPlayerSkills = {};
	
	self.nFillCD			= 3 * Env.GAME_FPS;			-- 填弹的CD
	self.nFillProcessTime 	= 5 * Env.GAME_FPS;			-- 填弹读条时间
	self.nMaxBomb			= 1;						-- 最多可填充1个炮弹
	
	-- dataid 定义
	self.LEADER_ID_INT		= 1;		-- 队长ID
	self.BOMB_COUNT_ID_INT	= 2;		-- 当前炮弹数
	self.BOMB_FILL_TIME_INT	= 3;		-- 上次填弹时间
	
	self.tbCanOperationCallBacks = 
	{
		[OPERATION_FILL]	=	"CanFillBomb",
		[OPERATION_THROW]	= 	"CanThrowBomb",
	}
	
	self.tbOperateCallBacks = 
	{
		[OPERATION_FILL]	=	"OperateFillBomb",
		[OPERATION_THROW]	= 	"OperateThrowBomb",
	}
end

function tbStoneThrower:CanOperate(nOpeSeq)
	if not self.tbCanOperationCallBacks or not 
		self.tbCanOperationCallBacks[nOpeSeq] then
			return 1;
		end
		
	local szCallBack = self.tbCanOperationCallBacks[nOpeSeq];
	local nRet = self[szCallBack](self);

	return nRet;
end

function tbStoneThrower:CanFillBomb()
	local nCount = him.GetCarrierIntData(self.BOMB_COUNT_ID_INT);
	if nCount >= self.nMaxBomb then
		self:BroadCastMsg("炮弹数已达上限！");
		return 0;
	end
	
	local nLastTime = him.GetCarrierIntData(self.BOMB_FILL_TIME_INT);
	if nLastTime + self.nFillCD >= GetFrame() then
		self:BroadCastMsg("填弹尚在CD中，请稍等再试！");
		return 0;
	end

	return 1;	
end

function tbStoneThrower:CanThrowBomb()
	local nCount = him.GetCarrierIntData(self.BOMB_COUNT_ID_INT);
	if nCount <= 0 then
		self:BroadCastMsg("炮弹已射完，请先填充炮弹！");
		return 0;
	end
	
	return 1;
end

function tbStoneThrower:Operate(nOpeSeq)
	if not self.tbOperateCallBacks or not 
		self.tbOperateCallBacks[nOpeSeq] then
			return 1;
		end
		
	local szCallBack = self.tbOperateCallBacks[nOpeSeq];
	local nRet = self[szCallBack](self);
	
	return nRet;
end

function tbStoneThrower:OperateFillBomb(dwHimId)
	if not MODULE_GAMESERVER then
		dwHimId = him.dwId;
	end
	
	if not dwHimId then
		local tbEvent = 
		{
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
		}
		
		-- 失败donothing
		GeneralProcess:StartProcess("填充炮弹中", self.nFillProcessTime, {self.OperateFillBomb, self, him.dwId}, nil, tbEvent);
		return 0;		-- 造成了异步，一定要返回0
	else
		local pCarrier = KNpc.GetById(dwHimId);
		if not pCarrier or pCarrier.IsCarrier() == 0 then
			return 0;
		end
	
		local nCount = pCarrier.GetCarrierIntData(self.BOMB_COUNT_ID_INT);
		pCarrier.SetCarrierIntData(self.BOMB_COUNT_ID_INT, nCount + 1);		-- 当前炸弹数加1		
		pCarrier.SetCarrierIntData(self.BOMB_FILL_TIME_INT, GetFrame());		-- 记录上次释放时间
		
		if MODULE_GAMESERVER then
			pCarrier.SyncOnCarrierOperSucc(me.nPlayerIndex, OPERATION_FILL);
		end
		
		return 1;
	end
end

function tbStoneThrower:OperateThrowBomb()
	local nCount = him.GetCarrierIntData(self.BOMB_COUNT_ID_INT);
	nCount = nCount - 1 > 0 and nCount - 1 or 0;
	him.SetCarrierIntData(self.BOMB_COUNT_ID_INT, nCount);	-- 炮弹少了一个
	
	if MODULE_GAMESERVER then
		-- TODO:用castskill好，还是用doskill好？？？
		local _, x, y = him.GetWorldPos();
		him.DoSkill(604, x, y);
	end
	
	--TODO:可能会有问题！！！
	return 1;
end

-- just for fun~
function tbStoneThrower:OnAttachNpc()
	if MODULE_GAMESERVER then
		--him.AddFightSkill(475, 20, 0);		-- 测试用必杀技
		--him.AddFightSkill(604, 20, 0);		-- some skill
		
		him.SetFightState(1);
		
		-- 注册血量回调处理函数
		Npc:RegPNpcLifePercentReduce(him, 30, self.LifeReduced, self);
	else
	--	him.nLeftSkill = 475;
	--	him.nRightSkill = 604;
	end
end

-- 服务端：队伍处理；客户端：刷新界面
function tbStoneThrower:OnPlayerLandIn(pPlayer, nSeat)
	if MODULE_GAMESERVER then
		NewBattle:SendMsg2Player(pPlayer, "Chiến Xa có thể phá hủy Tiễn Tháp, Pháo Tháp và Long Mạch.",NewBattle.SYSTEMBLACK_MSG);
		pPlayer.SetFightState(0);
		local pLeader = self:GetLeader(him);	-- 获取队长所属队伍ID
		if not pLeader and nSeat ~= 0 then
			-- 逻辑上不应该出现这种情况的，因此给个报错
			assert(false, "there is no leader!");
		end
		if nSeat == 0 or not pLeader then
			-- 这个玩家是leader!
			self:SetLeader(him, pPlayer);
			
			if not pPlayer.nTeamId or pPlayer.nTeamId == 0 then
				KTeam.CreateTeam(pPlayer.nId);
			elseif (pPlayer.IsCaptain() == 0) then	-- leader要变成队伍队长
				pPlayer.LeaveTeam();
				KTeam.CreateTeam(pPlayer.nId);
				--KTeam.TeamChangeCaptain(pPlayer.nTeamId, pPlayer.nId);	
			end			
		else
			-- 其他乘客应当与leader在同一队伍！
			if pLeader.nTeamId ~= pPlayer.nTeamId then
				pPlayer.LeaveTeam();
				KTeam.AddTeamMember(pLeader.nTeamId, pPlayer.nId);
			end		
		end
		-- 安装快捷键
		tbCarrierShortCutSkill:Setup("StoneThrower", him, pPlayer, nSeat);
		
	else
		UiManager:OpenWindow(Ui.UI_CARRIEROFF);
		-- 客户端只有自己才会进入到这里
		-- 需要应用载具操作界面
	end
end

-- 服务端：队伍处理；客户端：刷新界面
function tbStoneThrower:OnPlayerLandOff(pPlayer, nSeat)
	tbCarrierShortCutSkill:Uninstall(pPlayer);
	if MODULE_GAMESERVER then
		pPlayer.SetFightState(1);
		Player:AddProtectedState(pPlayer, NewBattle.PLAYERPROTECTEDTIME);
		local pLeader = self:GetLeader(him);
		if not pLeader then
			-- 逻辑上不应该出现这种情况的，因此给个报错
			assert(false, "there is no leader!");
		end
		if nSeat == 0 then
			-- 找到下一个乘客，并让他成为leader
			local pPassenger = self:GetCandidate(him);
			if not pPassenger then
				self:SetLeader(him);		-- 载具上没有乘客了，自然也没有leader
				pPlayer.LeaveTeam();
				return;
			end
			self:SetLeader(him, pPassenger);
			--换了Leader，重新安装快捷键
			tbCarrierShortCutSkill:ReSetup("StoneThrower", him, pPassenger, 0);	
						
			him.ResetPassengerSeat(pPassenger.nPlayerIndex, nSeat);
			KTeam.TeamChangeCaptain(pPlayer.nTeamId, pPassenger.nId);	
		end
		pPlayer.LeaveTeam();
	else
		UiManager:CloseWindow(Ui.UI_CARRIEROFF);
		-- 客户端只有自己才会进入到这里
		-- 需要恢复操作界面
	end
end

function tbStoneThrower:CanUseSkill(pPlayer, nSkillId)
	if MODULE_GAMESERVER then
		--print("蝶儿蝶儿满天飞~~~");
		return tbCarrierShortCutSkill:CanUseSkill("StoneThrower", him, pPlayer, nSkillId);
	else
		--客户端取不到玩家的座位号，直接返回1吧
		return 1;
	end

end

if MODULE_GAMESERVER then
	
-- 战车以队伍为单位管理乘客，登入操作需要判断队伍相关逻辑
-- 载具登入申请操作（应当执行在me.LandInCarrier()之前）
function tbStoneThrower:LandInCarrier(pPlayer, nSeat)
	if (him.IsCarrier() == 0) then
		return;
	end
	
	-- 前逻辑判断，队伍人数不能满，战车位置不能满
	if self:IsFullyLoad() == 1 then
		pPlayer.Msg("载具位置已满！");
		return;
	end
	
	local pLeader = self:GetLeader(him);
	if pLeader then
		local _, nMemCount = pLeader.GetTeamMemberList();
		if (not pPlayer.nTeamId or pPlayer.nTeamId ~= pLeader.nTeamId)
			 and nMemCount >= 6 then
				pPlayer.Msg("载具队伍人数已满！");
				return;
		end
	end
	
	-- 距离判断	
	nSeat = nSeat or -1;	-- -1表示系统指定座位号
	pPlayer.LeaveTeam();
	-- 表现操作，执行服务端CMD，玩家在期间失去控制，由服务端控制完成某些操作，操作完成交回控制权
	-- 两秒保护时间，防止半空中被打死。
	Player:AddProtectedState(pPlayer, 2);
	local tbCmd = {};
--	local szAction = string.format([[local pPlayer = ...; 
--		local _, x, y = %d, %d, %d; 
--		pPlayer.SetFightState(1);
--		pPlayer.GetNpc().DoSkill(10,x*32,y*32);]],
--		him.GetWorldPos());
	local szAction = string.format([[local pPlayer = ...;
		local _, x, y = %d, %d, %d;
		pPlayer.DoCommand(4, x * 32, y * 32, 600);]],
		him.GetWorldPos());
	table.insert(tbCmd, {nil, szAction, 20});	-- 用轻功跳到载具处
	szAction = string.format("local pPlayer = ...;pPlayer.LandInCarrier(%d, %d);", him.nIndex, nSeat);
	table.insert(tbCmd, {nil, szAction, 0});	-- 逻辑登入
	
	Player:DoServerCmd(pPlayer, tbCmd);
	
end

function tbStoneThrower:LandOffCarrier(pPlayer)
	pPlayer.LandOffCarrier();
	Player:AddProtectedState(pPlayer, NewBattle.PLAYERPROTECTEDTIME);
end

function tbStoneThrower:OnPlayerLeaveTeam(pPlayer)
	self:LandOffCarrier(pPlayer);
end

-- 该类载具独有逻辑，获取候选者
function tbStoneThrower:GetCandidate(pCarrier)
	local tbPassengers = pCarrier.GetCarrierPassengers();
	if not tbPassengers or Lib:CountTB(tbPassengers) == 0 then
		return;
	end
	
	return tbPassengers[1];
end

-- 该类载具独有逻辑，踢除载具
function tbStoneThrower:Kick(pSrc, pDes)
	local pLeader = self:GetLeader(him);
	if not pLeader then
		return;
	end
	
	if pSrc.nId ~= pLeader.nId then
		pSrc.Msg("队长才能踢除队友！");
		return;
	end
	self:LandOffCarrier(pPlayer);
end

-- 该类载具独有逻辑, 获取队长
function tbStoneThrower:GetLeader(pCarrier)
	local nId = pCarrier.GetCarrierIntData(self.LEADER_ID_INT);
	local pLeader = KPlayer.GetPlayerObjById(nId);
	return pLeader;
end

-- 该类载具独有逻辑，设置队长
function tbStoneThrower:SetLeader(pCarrier, pPlayer)
	local nId = pPlayer and pPlayer.nId or 0;
	pCarrier.SetCarrierIntData(self.LEADER_ID_INT, nId);
	
	if not pPlayer then
		-- 设置不显示名字、血条
		pCarrier.szName = pCarrier.GetTempTable("Npc").szOldName;
		pCarrier.Sync();
	else
		-- 设置显示名字、血条
		pCarrier.GetTempTable("Npc").szOldName = pCarrier.szName;
		local szName = string.format("Chiến Xa của %s", pPlayer.szName);
		pCarrier.szName = szName;
		pCarrier.Sync();
	end
end

function tbStoneThrower:LifeReduced(nPercent)
	if nPercent == 30 then
		-- 残血，散发出浓烟烈火
		-- him.AddSkillState(xxxxxxx);
	end
end

end	  -- if MODULE_GAMESERVER then

local tbTower = tbCarrier:GetClass("tower");

function tbTower:OnPlayerLandIn(pPlayer, nSeat)
	if MODULE_GAMESERVER then
		pPlayer.SetFightState(0);		
		tbCarrierShortCutSkill:Setup("tower", him, pPlayer, nSeat);
	else
		UiManager:OpenWindow(Ui.UI_CARRIEROFF);
	end

end

function tbTower:LandInCarrier(pPlayer, nSeat)
	-- 两秒保护时间，防止半空中被打死。
	Player:AddProtectedState(pPlayer, 2);
	local tbCmd = {};
	local szAction = string.format([[local pPlayer = ...;
		local _, x, y = %d, %d, %d;
		pPlayer.DoCommand(4, x * 32, y * 32, 600);]],
		him.GetWorldPos());
	table.insert(tbCmd, {nil, szAction, 20});	-- 用轻功跳到载具处
	szAction = string.format("local pPlayer = ...;pPlayer.LandInCarrier(%d, %d);", him.nIndex, nSeat);
	table.insert(tbCmd, {nil, szAction, 0});	-- 逻辑登入
	Player:DoServerCmd(pPlayer, tbCmd);
	
end

-- 服务端：队伍处理；客户端：刷新界面
function tbTower:OnPlayerLandOff(pPlayer, nSeat)
	if MODULE_GAMESERVER then
		pPlayer.SetFightState(1);	
		Player:AddProtectedState(pPlayer, NewBattle.PLAYERPROTECTEDTIME);
	else
		UiManager:CloseWindow(Ui.UI_CARRIEROFF);
	end
	tbCarrierShortCutSkill:Uninstall(pPlayer);
end


-- 能否使用技能
function tbCarrierShortCutSkill:CanUseSkill(szClassName, pCarrier, pPlayer, nSkillId)
	local nSeat = -1;
	local tbCPS = pCarrier.GetCarrierPassengers();
	if not tbCPS then
		return 0;
	end
	-- 先取到座位编号
	for n,pPlayerT in pairs(tbCPS) do
		if pPlayer.szName == pPlayerT.szName then
			nSeat = n;
			break;	
		end
	end
	if nSeat == -1 then
		return 0;
	end
	-- 检查是否能施放
	local tbToweSkill = pCarrier.GetCarrierSkill();	
	for _, nNum in ipairs(self.tbConfig[szClassName][nSeat].SKILLS) do
		if nSkillId == tbToweSkill[nNum].nSkillId then
			return 1;
		end
	end
	return 0;

end

--玩家载具快捷键安装
function tbCarrierShortCutSkill:Setup(szClassName, pCarrier, pPlayer, nSeat, bReSetup)
	if not self.tbConfig[szClassName] then
		return;
	end	
	
	local tbToweSkill = pCarrier.GetCarrierSkill();
	local tbSkills = self.tbConfig[szClassName][nSeat];
	if not tbSkills then
		return;
	end	
	pPlayer.SetTask(Item.TSKGID_LEFTRIGHT_CARRIER, Item.TSKID_LEFT_FLAG_CARRIER, 0);
	pPlayer.SetTask(Item.TSKGID_LEFTRIGHT_CARRIER, Item.TSKID_RIGHT_FLAG_CARRIER, 0);
	self:ClearShortcut(pPlayer, 1);
	--放置技能
	for n, nSkillNum in ipairs(tbSkills.SKILLS) do
		if tbToweSkill[nSkillNum] then
			if nSkillNum ==  tbSkills.LEFT then
				pPlayer.SetTask(Item.TSKGID_LEFTRIGHT_CARRIER, Item.TSKID_LEFT_FLAG_CARRIER, tbToweSkill[nSkillNum].nSkillId);
			end
			
			if nSkillNum ==  tbSkills.RIGHT then
				pPlayer.SetTask(Item.TSKGID_LEFTRIGHT_CARRIER, Item.TSKID_RIGHT_FLAG_CARRIER, tbToweSkill[nSkillNum].nSkillId);
			end
			
			if nSkillNum ~= tbSkills.LEFT and nSkillNum ~=  tbSkills.RIGHT then
				self:SetShortcutSkill(pPlayer, n, tbToweSkill[nSkillNum].nSkillId, 1);
			end 
		end
	end
	FightSkill:RefreshShortcutWindow(pPlayer)
	pPlayer.CallClientScript({"UiManager:SetupCarrierRightLeftSkill"});
	
end

--玩家载具快捷键卸载
function tbCarrierShortCutSkill:Uninstall(pPlayer)
	if MODULE_GAMESERVER then
		pPlayer.SetTask(Item.TSKGID_LEFTRIGHT_CARRIER, Item.TSKID_LEFT_FLAG_CARRIER, 0);
		pPlayer.SetTask(Item.TSKGID_LEFTRIGHT_CARRIER, Item.TSKID_RIGHT_FLAG_CARRIER, 0);
  		FightSkill:RefreshShortcutWindow(pPlayer);
  	else
  		--在客户端执行快捷栏刷新
  		UiManager:CloseWindow(Ui.UI_SHORTCUTBAR);
    	UiManager:OpenWindow (Ui.UI_SHORTCUTBAR);  
    	me.SetTask(Item.TSKGID_LEFTRIGHT_CARRIER, Item.TSKID_LEFT_FLAG_CARRIER, 0);
		me.SetTask(Item.TSKGID_LEFTRIGHT_CARRIER, Item.TSKID_RIGHT_FLAG_CARRIER, 0);
    	--刷新一下左右键技能
    	UiNotify:OnNotify(UiNotify.emCOREEVENT_FIGHT_SKILL_CHANGED)
    end
end

-- 重新安装快捷键，用于玩家中途变换位置
function tbCarrierShortCutSkill:ReSetup(szClassName, pCarrier, pPlayer, nToSeat)
	self:Setup(szClassName, pCarrier, pPlayer, nToSeat)
	FightSkill:RefreshShortcutWindow(pPlayer)
end

--	添加载具快捷栏技能
function tbCarrierShortCutSkill:SetShortcutSkill(pPlayer, nPosition, nSkillId, nIsRefreshWindow)
	if nPosition < 0 or nPosition > Item.SHORTCUTBAR_OBJ_MAX_SIZE then
		return;
	end	
	local nFlags = pPlayer.GetTask(Item.TSKGID_SHORTCUTBAR_CARRIER, Item.TSKID_SHORTCUTBAR_FLAG_CARRIER);
	nFlags = Lib:SetBits(nFlags, Item.SHORTCUTBAR_TYPE_SKILL, nPosition * 3 - 3, nPosition * 3 - 1); 	
	pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR_CARRIER, Item.TSKID_SHORTCUTBAR_FLAG_CARRIER, nFlags);
	pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR_CARRIER, nPosition * 2 - 1, nSkillId);
	pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR_CARRIER, nPosition * 2 , 0);
	if nIsRefreshWindow == 1 then 
		FightSkill:RefreshShortcutWindow(pPlayer);
	end
end


-- 清载具快捷栏
function tbCarrierShortCutSkill:ClearShortcut(pPlayer, nIsRefreshWindow)
	pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR_CARRIER, Item.TSKID_SHORTCUTBAR_FLAG_CARRIER, 0); -- 只清标记位
	if nIsRefreshWindow == 1 then 
		FightSkill:RefreshShortcutWindow(pPlayer);
	end
end	