-- TaskAct为行为，在编辑器的任务完成处填写

TaskAct.tbTalkForbitHead	= {
-- string.byte返回字符的整数形式，比如"a"返回的就是97
	[string.byte("\r")]	= 1, 
	[string.byte("\n")]	= 1, 
	[string.byte(" ")]	= 1,
};



-- 询问接收任务
function TaskAct:AskAccept(nReferId)
	-- 获得这个引用任务所关联的任务
	local tbReferData = Task.tbReferDatas[nReferId];
	if (not tbReferData) then
		print("玩家"..me.szName.."准备接的任务："..nReferId.."不存在！");
		print(debug.traceback())
		return;
	end
	
	local nTaskId = tbReferData.nTaskId;
	
	local tbSubData	= Task.tbSubDatas[tbReferData.nSubTaskId];
	local szMsg = "";
	if (tbSubData.tbAttribute.tbDialog.Start.szMsg) then -- 未分步骤
			szMsg = tbSubData.tbAttribute.tbDialog.Start.szMsg;
	else
			szMsg = tbSubData.tbAttribute.tbDialog.Start.tbSetpMsg[1];
	end
	
	TaskAct:TalkInDark(szMsg,Task.AskAccept, Task, nTaskId, nReferId);		
				
end;

-- 增加经验
function TaskAct:AddExp(nExp, nTaskId)
	me.AddExp2(nExp,"task");   -- mod zounan 修改经验接口
end;

-- 增加金钱
function TaskAct:AddMoney(nMoney, nTaskId)
	me.AddBindMoney2(nMoney,"task",Player.emKBINDMONEY_ADD_TASK_ACT);
	
	Task:TskProduceLog(nTaskId, Task.TSKPRO_LOG_TYPE_BINDMONEY, nMoney);
end;

function TaskAct:GiveActiveMoney(nMoney, szExtParam1, szExtParam2, szExtParam3, nTaskId)
	local nTaskId = tonumber(nTaskId);
	local tbPlayerTask	= Task:GetPlayerTask(me);
	local tbTask		= tbPlayerTask.tbTasks[nTaskId];
	if (tbTask) then
		me.Earn(nMoney, Player.emKEARN_TASK_ACT);
		KStatLog.ModifyAdd("jxb", "[产出]"..Task:GetTaskTypeName(nTaskId), "总量", nMoney);
	end
	
	Task:TskProduceLog(nTaskId, Task.TSKPRO_LOG_TYPE_MONEY, nMoney);
end

function TaskAct:AddItem(tbItem)
	Task:AddItem(me, tbItem);
end

function TaskAct:AddItems(tbItem, nCount)
	if (nCount < 1) then
		return;
	end
	
	for nCount = 1, nCount do
		Task:AddItem(me, tbItem);
	end
end


-- 对话行为
--玩家和Npc对话
--<playername>npc你好<end>
--<npc=2>玩家你好<end>
--KNpc.GetNameByTemplateId(nDiglogNpcTempId);
function TaskAct:Talk(AllMsg, ...)
	local szAllMsg = "";
	local nCallBackInfo = 0;
	if (type(AllMsg) == "table") then
		nCallBackInfo , szAllMsg = Lib:CallBack(AllMsg);
	elseif(type(AllMsg) == "string") then
		szAllMsg = AllMsg;
	end
	
	szAllMsg = szAllMsg or "";

	BlackSky:SimpleTalk(me, szAllMsg, ...)
end

-- 对话完不会结束黑屏
function TaskAct:TalkInDark(szAllMsg, ...)
	BlackSky:SendDarkCommand(me, {TaskAct.NormalTalk, TaskAct, szAllMsg, unpack(arg)})
end

function TaskAct:NormalTalk(szAllMsg, ...)
	local tbMsg	= Lib:SplitStr(szAllMsg or "", "<end>"); -- 为以<end>为分割点把szAllMsg分割为n段对话
	for i, szMsg in ipairs(tbMsg) do
		--print("分割的第"..i.."个为："..szMsg)
		while (self.tbTalkForbitHead[string.byte(szMsg)]) do -- 去除非法首字符
			szMsg	= string.sub(szMsg, 2);
		end;
		local nStart	= string.find(szMsg, "：");
		if (not nStart) then
			nStart	= string.find(szMsg, ":");
		end;
		if (nStart) then
			local szName	= string.sub(szMsg, 1, nStart-1);
			if (szName == "<playername>" or szName == "<Playername>" or szName == "<PlayerName>") then -- 若是玩家
				if (me.nSex == 1) then
					--szMsg	= ""..szMsg;
				else
					--szMsg	= ""..szMsg;
				end;
			else -- 若是NPC
				local _, nNpcIdStart	= string.find(szMsg, "<npc=");
				local nNpcIdEnd			= string.find(szMsg, ">");
				local nNpcTempId		= -1;
				if (nNpcIdStart and nNpcIdEnd) then
					nNpcTempId 		= tonumber(string.sub(szMsg, nNpcIdStart+1, nNpcIdEnd-1));
				end
				if (nNpcTempId and nNpcTempId >0) then
					local szHeadPic = GetNpcHeadPic(nNpcTempId);
					if (szHeadPic) then
						szHeadPic = "<Pic:"..szHeadPic..">";
					end
					-- 根据模板获取和设置Npc肖像
					szMsg	= szHeadPic..szMsg;
				end
			end;
		end;
		-- 找到<Npc=xx>的位置
		local nCurIdx = 1;

		while true do
			local nNpcTagStart, nNpcIdStart	= string.find(szMsg, "<npc=");
			local nNpcTagEnd, nNpcIdEnd			= string.find(szMsg, ">", nNpcIdStart);
			local nNpcTempId = -1;
			if (not nNpcIdStart or not nNpcIdEnd) then
				break;
			end
			local nNpcTempId 		= tonumber(string.sub(szMsg, nNpcIdStart+1, nNpcIdEnd-1));
			
			if (nNpcTempId and nNpcTempId > 0) then
				local szNpcName = KNpc.GetNameByTemplateId(nNpcTempId);
				local nTagIndex = string.find(szNpcName,"_")
				if (nTagIndex) then
					szNpcName = string.sub(szNpcName, 1, nTagIndex-1);
				end
				szMsg = Lib:ReplaceStrFormIndex(szMsg, nNpcTagStart, nNpcTagEnd, "<color=Red>"..szNpcName.."<color>");
			else
				print("edit error：", szMsg);
				break;
			end
		end
		--print("tbMsg[i]",tbMsg[i])
		tbMsg[i]	= Lib:ReplaceStr(szMsg, "<playername>", "<color=Gold>"..me.szName.."<color>");
		tbMsg[i]	= Lib:ReplaceStr(tbMsg[i], "<Playername>", "<color=Gold>"..me.szName.."<color>");
		tbMsg[i]	= Lib:ReplaceStr(tbMsg[i],"<PlayerName>", "<color=Gold>"..me.szName.."<color>");
	end;

	if (tbMsg[#tbMsg] == "") then
		tbMsg[#tbMsg]	= nil;
	end;
	
	for i = 1, #tbMsg do
		tbMsg[i] = Lib:ParseExpression(tbMsg[i]);
	end
	
	if (tbMsg[1]) then
		Dialog:Talk(tbMsg, unpack(arg));
	elseif (arg[1]) then
		arg[1](unpack(arg,2));
	end;
end;

-- 增加Obj
function TaskAct:AddObj(nNpcTempId, szNewName)
	local nMapId, nPosX, nPosY	= me.GetWorldPos();
	local him	= KNpc.Add2(nNpcTempId, 1, -1, nMapId, nPosX, nPosY);
	if (szNewName) then
		him.szName	= szNewName;
	end
	
	return him;
end;

-- 瞬移,改为强制执行
function TaskAct:NewWorld(nMapId, nPosX, nPosY)
	-- 传送玩家
	me.NewWorld(nMapId, nPosX, nPosY, 1);
end;

-- TODO: liuchang 不安全，以后战斗状态转换应该写在地图OnEnter里面。
function TaskAct:NewWorldWithState(nMapId, nPosX, nPosY, nFightState)
	if nMapId == 0 then	-- 青螺岛船舱三层传送
		if me.nMapId == 2288 then
			nMapId = 2286;
		elseif me.nMapId == 402 then
			nMapId = 55;
		else
			nMapId = me.nMapId;
		end				
	end
	me.NewWorld(nMapId, nPosX, nPosY, 1);
	me.SetFightState(tonumber(nFightState));
end;

TaskAct.tbMapType2MapId = {
	["waiyingxiongzhong"] = {
			[74] = 405,
			[2340] = 2341,	
		},
	["wenxingem"] = {
			[74] = 418,
			[2340] = 2353,
		},
	["wenxingef"] = {
			[74] = 419,
			[2340] = 2354,
		},
	["gexialingendm"] = {
			[74] = 426,
			[2340] = 2361,
		},
	["gexialingendf"] = {
			[74] = 427,
			[2340] = 2362,
		},
};

function TaskAct:NewWorldWithStateByMapType(szMapType, nPosX, nPosY, nFightState)
	local tbMapInfo = self.tbMapType2MapId[szMapType];
	if (not tbMapInfo) then
		Dialog:Say("Không thể tìm được bản đồ!");
		return;
	end
	
	local nMapId = tbMapInfo[me.nMapId];
	if (not nMapId) then
		Dialog:Say("Không thể tìm được bản đồ!");
		return;
	end
	
	me.NewWorld(nMapId, nPosX, nPosY, 1);
	me.SetFightState(tonumber(nFightState));
end;
function TaskAct:DoSkill(nSkillId)
	CastSkill(nSkillId);
end;

function TaskAct:AddSkillState(nSkillId, nSkillLevel, nSkillType, nSkillTime, nIsDeathSave, nIsReplace)
	me.AddSkillState(nSkillId, nSkillLevel, nSkillType, nSkillTime * Env.GAME_FPS, nIsDeathSave, nIsReplace);
end

function TaskAct:RemoveSkillState(nSkillId)
	me.RemoveSkillState(nSkillId);
end

-- 设置任务变量
function TaskAct:SetTaskValue(nGroupId, nTaskId, nValue)
	me.SetTask(nGroupId, nTaskId, nValue, 1);
end

function TaskAct:AddATaskValue(nGroupId, nTaskId, nValue)
	local nOldValue = me.GetTask(nGroupId, nTaskId);
	me.SetTask(nGroupId, nTaskId, (nOldValue + nValue));
end

function TaskAct:AddTaskValue(nGroupId, nTaskId, nValue)
	local nOldValue = me.GetTask(nGroupId, nTaskId);
	me.SetTask(nGroupId, nTaskId, (nOldValue + nValue));
end

function TaskAct:SetPlayerLife(nLifeValue)
	me.ReduceLife2Value(nLifeValue);
end

function TaskAct:DelItem(tbTaskItemId, nDelCount)
	local tbItemId	= {20,1,tbTaskItemId[1],1,0,0};
	
	if (nDelCount <= 0) then
		nDelCount = Task:GetItemCount(me, tbItemId);
	end
	
	Task:DelItem(me, tbItemId, nDelCount);
end

function TaskAct:AddMakePoint(nAddPoint)
	me.ChangeCurMakePoint(nAddPoint);
end


function TaskAct:AddGatherPoint(nAddPoint)
	me.ChangeCurGatherPoint(nAddPoint);
end

function TaskAct:AddCustomizeItem(nGenre,nDetailType,nParticularType, nLevel, nSeries, nLuck, nCount)
	if (nCount < 1) then
		return;
	end
	
	for nCount = 1, nCount do
		Task:AddItem(me, {nGenre, nDetailType, nParticularType, nLevel, nSeries, nLuck});
	end
end

function TaskAct:AddRecip(nRecipId)
	if (nRecipId <= 0) then
		return;
	end
	
	LifeSkill:AddRecipe(me, nRecipId)
end

function TaskAct:AddLifeSkill(nSkillId, nSkillLevel)
	if (nSkillId <= 0 or nSkillLevel <= 0) then
		return;
	end
	
	LifeSkill:AddLifeSkill(me, nSkillId, nSkillLevel);
end

function TaskAct:StepOverEvent(szAllMsg)
	if (MODULE_GAMESERVER) then
		me.CallClientScript({"Ui:ServerCall", "UI_TASKTIPS", "Begin", szAllMsg})
	end
end


function TaskAct:StepOverWithTalk(szMsg1, szMsg2)
	TaskAct:Talk(szMsg1, self.StepOverEvent, self, szMsg2);
end

function TaskAct:AddAnger(nAnger)
	local nCurAnger = me.GetTask(2014,1);
	nCurAnger = nCurAnger + nAnger;
	if (nCurAnger > 9999) then
		nCurAnger = 9999;
	elseif (nCurAnger < 0) then
		nCurAnger = 0;
	end
	
	me.SetTask(2014, 1, nCurAnger, 1);
end


function TaskAct:SetTaskValueOnStart(nTaskGroup, nTaskId, nTaskValue)
	me.SetTask(nTaskGroup, nTaskId, nTaskValue, 1);
end

function TaskAct:AddTaskValueOnStart(nGroupId, nTaskId, nValue)
	local nOldValue = me.GetTask(nGroupId, nTaskId);
	me.SetTask(nGroupId, nTaskId, (nOldValue + nValue));
end

function TaskAct:SetTaskValueOnFailed(nTaskGroup, nTaskId, nTaskValue)
	me.SetTask(nTaskGroup, nTaskId, nTaskValue, 1);
end

function TaskAct:SetTaskValueOnFinish(nTaskGroup, nTaskId, nTaskValue)
	me.SetTask(nTaskGroup, nTaskId, nTaskValue, 1);
end

function TaskAct:AddTaskValueOnFinish(nTaskGroup, nTaskId, nTaskValue)
	local nOldValue = me.GetTask(nTaskGroup, nTaskId);
	me.SetTask(nTaskGroup, nTaskId, (nOldValue + nTaskValue), 1);
end

function TaskAct:DelItemOnFailed(tbTaskItemId, nDelCount)
	local tbItemId	= {20,1,tbTaskItemId[1],1,0,0};
	
	if (nDelCount <= 0) then
		nDelCount = Task:GetItemCount(me, tbItemId);
	end
	
	Task:DelItem(me, tbItemId, nDelCount);
end

function TaskAct:DelTitleOnFailed(nTitleGenre, nTitleDetailType, nTitleLevel)
	assert(nTitleGenre > 0);
	assert(nTitleDetailType > 0);
	assert(nTitleLevel > 0);
	
	me.RemoveTitle(nTitleGenre, nTitleDetailType, nTitleLevel);
end


function TaskAct:LearnFightSkill(nSkillId, nSkillLevel)
	if (me.GetSkillLevel(nSkillId) > nSkillLevel) then
		return;
	end
	
	me.AddFightSkill(nSkillId, nSkillLevel);
end


function TaskAct:SelBindMoney(nMoney, nBind, szExtParam1, szExtParam2, szExtParam3, nTaskId)
--	me.AddBindMoney(nMoney, Player.emKBINDMONEY_ADD_TASK_ACT);
	me.AddBindMoney2(nMoney,"task",Player.emKBINDMONEY_ADD_TASK_ACT);
	KStatLog.ModifyAdd("bindjxb", "[产出]"..Task:GetTaskTypeName(nTaskId), "总量", nMoney);
	
	Task:TskProduceLog(nTaskId, Task.TSKPRO_LOG_TYPE_BINDMONEY, nMoney);
end

function TaskAct:DelItemOnAccept(tbTaskItemId, nDelCount, szExtParam1, szExtParam2, szExtParam3)
	local tbItemId	= {20,1,tbTaskItemId[1],1,0,0};
	
	if (nDelCount <= 0) then
		nDelCount = Task:GetItemCount(me, tbItemId);
	end
	
	Task:DelItem(me, tbItemId, nDelCount);
end

function TaskAct:SetTaskValueBitOnStart(nTaskGroup, nTaskId, nBitNum, bBitValue, szExtParam1, szExtParam2, szExtParam3)
	local nTaskValue = me.GetTask(nTaskGroup, nTaskId);
	assert(nBitNum >= 1 and nBitNum <= 16);
	local nBitValue = 0;
	if (bBitValue) then
		nBitValue = 1;
	end
	nTaskValue = KLib.SetBit(nTaskValue, nBitNum, nBitValue);
	me.SetTask(nTaskGroup, nTaskId, nTaskValue);
end

--某个步骤完成后执行的额外脚本
function TaskAct:DoExecute(szFun)
	if not MODULE_GAMESERVER then
		return 0;
	end
	if szFun then
		loadstring(szFun)();
	end
end

--一个任务完成后执行的额外脚本
function TaskAct:DoExecuteOnFinish(szFun)
	if not MODULE_GAMESERVER then
		return 0;
	end
	if szFun then
		loadstring(szFun)();
	end
end
