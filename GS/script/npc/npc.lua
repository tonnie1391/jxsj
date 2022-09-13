-- Npc脚本类

Require("\\script\\npc\\define.lua");

if (not Npc.tbClassBase) then	-- 防止文件重载时破坏已有数据
	-- Npc基础模板，详细的在default.lua中定义
	Npc.tbClassBase	= {};

	-- Npc模板库
	Npc.tbClass	= {
		-- 默认模板，可以提供直接使用
		default	= Npc.tbClassBase,
		[""]	= Npc.tbClassBase,
	};
end;

-- 取得特定类名的Npc模板
function Npc:GetClass(szClassName, bNotCreate)
	local tbClass	= self.tbClass[szClassName];
	-- 如果没有bNotCreate，当找不到指定模板时会自动建立新模板
	if (not tbClass and bNotCreate ~= 1) then
		-- 新模板从基础模板派生
		tbClass	= Lib:NewClass(self.tbClassBase);
		-- 加入到模板库里面
		self.tbClass[szClassName]	= tbClass;
	end;
	return tbClass;
end;

-- 任何Npc对话，系统都会调用这里
function Npc:OnDialog(szClassName, szParam)
	-- 这里可以加入一些通用的Npc对话事件
	--观战模式不允许对话；
	if Looker:IsLooker(me) > 0 then
		Dialog:Say("Ai đó? Sao nghe tiếng mà không thấy người vậy?");
		return 0;
	end
	--防沉迷, 不允许和任何npc对话
	if (me.GetTiredDegree() == 2) then
		Dialog:Say("Bạn đã online quá 5h, không nhận được bất cứ hiệu quả nào.");
		return 0;
	end;
	
	if szClassName == "yijunshouling" then
		SpecialEvent.ActiveGift:AddCounts(me, 9);		--对话活跃度
	elseif szClassName == "longwutaiye" then
		SpecialEvent.ActiveGift:AddCounts(me, 44);		--对话活跃度
	end
	
	local tbOpt	= {};
	local nEventFlag = 0;
	local nTaskFlag = 0;
	
	if (Task:AppendNpcMenu(tbOpt) == 1) then
		nTaskFlag = 1;
	end;
	
	local tbNpc = EventManager:GetNpcClass(him.nTemplateId);
	local tbNpcType = EventManager:GetNpcClass(szClassName);
	
	if tbNpc and EventManager.tbFun:MergeDialog(tbOpt, tbNpc) == 1 then
		nEventFlag = 1;
	end
	
	if tbNpcType and EventManager.tbFun:MergeDialog(tbOpt, tbNpcType) == 1 then
		nEventFlag = 1;
	end
	
	if (EventManager.IVER_bOpenTiFu == 1) then
		if him.nTemplateId == 3570 then
			local tbTiFu = Npc:GetClass("tmpnpc_tifu")
			nTaskFlag = 1;
			table.insert(tbOpt, 1, {"<color=yellow>Nhân vật server thử nghiệm nhận<color>", tbTiFu.OnDialog, tbTiFu});
		end
	end
	local nSpecFlag = 0;
	if self.tbSpecDialog[him.nTemplateId] then
		for szMsg, tbSpec in pairs(self.tbSpecDialog[him.nTemplateId]) do
			if tbSpec.check() == 1 then
				nSpecFlag = 1;
				table.insert(tbOpt, 1, {szMsg, tbSpec.fun, tbSpec.obj, him});
			end
		end
	end
	local nCeilFlag = 0;
	-- 根据 szClassName 找到特定模板
	local tbClass	= self.tbClass[szClassName];
	if tbClass and tbClass.GenTopDialogOpt then
		local tbCeilOpt = tbClass:GenTopDialogOpt(); -- 该对话必须是有条件出现的，不允许放入永久性对话
		if tbCeilOpt and #tbCeilOpt > 0 then
			nCeilFlag = 1;
			for _, tbTempOpt in ipairs(tbCeilOpt) do
				table.insert(tbOpt, 1, tbTempOpt);
			end
		end
	end
	
	if nEventFlag == 1 or nTaskFlag == 1 or nSpecFlag == 1 or nCeilFlag == 1 then
		local szMsg = "";
		local szMsg2 = "";
		if nEventFlag == 1 and nTaskFlag == 1 and nSpecFlag == 1 then
			szMsg = string.format("%s: Đến thật đúng lúc, ta có nhiệm vụ và hoạt động cho ngươi.", him.szName)
			szMsg2 = "Không muốn tham gia";
		elseif nEventFlag == 1 then
			szMsg = string.format("%s: Đến thật đúng lúc, ta có hoạt động cho ngươi.", him.szName)
			szMsg2 = "Ta muốn hỏi chuyện khác";
		elseif nTaskFlag == 1 then
			szMsg = string.format("%s: Đến thật đúng lúc, ta có nhiệm vụ cho ngươi.", him.szName)			
			szMsg2 = "Không muốn làm";
		elseif nSpecFlag == 1 or nCeilFlag == 1 then
			szMsg = string.format("%s: Đến thật đúng lúc, ta có nhiệm vụ đặc biệt cho ngươi.", him.szName)
			szMsg2 = "Ta muốn hỏi chuyện khác";
		end
		tbOpt[#tbOpt+1]	= {szMsg2, self.OriginalDialog, self, szClassName, him};	
		--if nTaskFlag == 1 then
		--	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
		--end
		Dialog:Say(szMsg, tbOpt);
		return;
	end
	
	
	Dbg:Output("Npc", "OnDialog", szClassName, tbClass);
	if (tbClass) then
		-- 调用模板指定的对话函数
		tbClass:OnDialog(szParam);
	end;	
end;

-- 注册一组npc拦截对话
function Npc:RegisterSpecDialog(tbNpcGroup, fnSpec, fnCheck, tbSpec, szMsg)
	for _, nNpcId in pairs(tbNpcGroup or {}) do
		if not self.tbSpecDialog[nNpcId] then
			self.tbSpecDialog[nNpcId] = {};
		end
		self.tbSpecDialog[nNpcId][szMsg] = {fun = fnSpec, check = fnCheck, obj = tbSpec};
	end
end

function Npc:OnBubble(szClassName)
	local tbClass = self.tbClass[szClassName];
	if (tbClass) then
		tbClass:OnTriggerBubble();
	end
end

function Npc:AddBubble(szClassName, nIndex, szMsg)
end
-- 原有Npc对话，提供“我不想做任务”使用，不会进行对话拦截
function Npc:OriginalDialog(szClassName, pNpc)
	-- TODO: FanZai	要对Npc指针进行检查
	him	= pNpc;
	self.tbClass[szClassName]:OnDialog();
	him	= nil;
end;

-- 任何Npc死亡，系统都会调用这里
function Npc:OnDeath(szClassName, szParam, ...)
	local pOldHim = him;
	-- 根据 szClassName 找到特定模板
	local tbClass	= self.tbClass[szClassName];
	-- TODO:写在这里不好,将来要改!!!
	-- 如果该NPC死的时候正在被说服，删掉被说服状态
	if him.GetTempTable("Partner").nPersuadeRefCount then
		him.RemoveTaskState(Partner.nBePersuadeSkillId);
		him.GetTempTable("Partner").nPersuadeRefCount = 0;
	end
	
	-- 这里可以加入一些通用的Npc死亡事件
	local tbOnDeath	= him.GetTempTable("Npc").tbOnDeath;
	Dbg:Output("Npc", "OnDeath", szClassName, tbClass, tbOnDeath);
	if (tbOnDeath) then
		local tbCall	= {unpack(tbOnDeath)};
		Lib:MergeTable(tbCall, arg);
		local bOK, nRet	= Lib:CallBack(tbCall);	-- 调用回调
		if (not bOK or nRet ~= 1) then
			him.GetTempTable("Npc").tbOnDeath	= nil;
		end
	end

	-- 插入载具死亡回调
	if him.IsCarrier() == 1 then
		Npc.tbCarrier:OnDeath(him.GetCarrierTemplate());
	end
	
	if (tbClass) then
		-- 调用模板指定的死亡函数
		tbClass:OnDeath(unpack(arg));
		-- 死亡插入额外掉落处理函数
		if (tbClass.ExternDropOnDeath) then
			tbClass:ExternDropOnDeath(unpack(arg));
		end
	end;
	
	--npc死亡额外触发事件
	Lib:CallBack({"SpecialEvent.ExtendEvent:DoExecute","Npc_Death", him, arg[1]});
		
	if (not arg[1]) then
		return;
	end
	
	local pNpc 		= arg[1];
	local nNpcType 	= him.GetNpcType();
	local pPlayer  	= pNpc.GetPlayer();
	if (not pPlayer) then
		return;
	end

	if (1 == nNpcType) then
		self:AwardXinDe(pPlayer, 100000);
		self:AwardTeamXinDe(pPlayer, 100000);	
		self:AddActive(pPlayer, 5);	--击杀精英活跃度
	elseif (2 == nNpcType) then
		self:AwardXinDe(pPlayer, 200000);
		self:AwardTeamXinDe(pPlayer, 200000)
		self:AddActive(pPlayer, 5);	--击杀首领活跃度
	end
	
	--活动系统调用
	EventManager:NpcDeathApi(szClassName, him, pPlayer, unpack(arg))
	
	--击杀世界boss活跃度
	if szClassName == "uniqueboss" then		
		self:AddActive(pPlayer, 24);
		SpecialEvent.BuyOver:AddCounts(pPlayer, SpecialEvent.BuyOver.TASK_VOLAMCAOTHU);
	end
	
	-- 成就系统调用
--	local nMapIndex = SubWorldID2Idx(him.nMapId);
--	local nMapTemplateId = SubWorldIdx2MapCopy(nMapIndex);
	Achievement:OnKillNpc(pPlayer, pOldHim.nTemplateId);
	--每天杀怪标志
	SpecialEvent.tbPJoinEventTimes:OnKillNpc(pPlayer, szClassName)
	--击杀npc时调用宠物奖励
	Npc.tbFollowPartner:AddAward(pPlayer, "killnpc");
end;

function Npc:AddActive(pPlayer, nIndex)
	if not pPlayer or not nIndex then
		return;
	end
	if pPlayer.nTeamId > 0 then
		local tbMember = KTeam.GetTeamMemberList(pPlayer.nTeamId);
		if tbMember then
			for i = 1, #tbMember do
				local pPlayer = KPlayer.GetPlayerObjById(tbMember[i]);	
				if pPlayer then
					SpecialEvent.ActiveGift:AddCounts(pPlayer, nIndex);
				end
			end
		end
	else
		SpecialEvent.ActiveGift:AddCounts(pPlayer, nIndex);
	end
end

function Npc:AwardTeamXinDe(pPlayer, nXinDe)
	if (nXinDe <= 0) then
		return;
	end

	local nTeamId	= pPlayer.nTeamId;
	local tbPlayerId, nMemberCount	= KTeam.GetTeamMemberList(nTeamId);
	if not tbPlayerId then
		return
	end	
	local nNpcMapId, nNpcX, nNpcY	= pPlayer.GetWorldPos();	
	for i, nPlayerId in pairs(tbPlayerId) do
		local pTPlayer	= KPlayer.GetPlayerObjById(nPlayerId);
		if pTPlayer and pTPlayer.nId ~= pPlayer.nId then
			local nPlayerMapId, nPlayerX, nPlayerY	= pTPlayer.GetWorldPos();
			if (nPlayerMapId == nNpcMapId) then
				local nDisSquare = (nNpcX - nPlayerX)^2 + (nNpcY - nPlayerY)^2;
				if (nDisSquare < 16 * 16) then -- 九屏内玩家
					self:AwardXinDe(pTPlayer, nXinDe);
				end
			end
		end
	end
	
end

function Npc:AwardXinDe(pPlayer, nXinDe)
	if (nXinDe <= 0) then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	Task:AddInsight(nXinDe);
	Setting:RestoreGlobalObj();
end

function Npc:OnArrive(szClassName, pNpc)
	--print ("Npc:OnArrive", szClassName, pNpc);
	local tbOnArrive = pNpc.GetTempTable("Npc").tbOnArrive;
	Setting:SetGlobalObj(me, pNpc, it)
	if (tbOnArrive) then
		Lib:CallBack(tbOnArrive);
	end
	Setting:RestoreGlobalObj()
end

-- 当Npc血量减少到此处触发
function Npc:OnLifePercentReduceHere(szClassName, pNpc, nPercent)
	Setting:SetGlobalObj(me, pNpc, it);
	local tbOnLifePercentReduce	= him.GetTempTable("Npc").tbOnLifePercentReduce;
	if (tbOnLifePercentReduce) and (tbOnLifePercentReduce[nPercent]) then
		local tbCall	= {unpack(tbOnLifePercentReduce[nPercent])};
		Lib:MergeTable(tbCall, {nPercent});
		local bOK, nRet	= Lib:CallBack(tbCall);	-- 调用回调
		if (not bOK or nRet ~= 1) then
			him.GetTempTable("Npc").tbOnLifePercentReduce[nPercent]	= nil;
		end
	end
	Setting:RestoreGlobalObj();
	local tbClass	= self.tbClass[szClassName];
	if (not tbClass) then
		Dbg:WriteLogEx(Dbg.LOG_ERROR, "Npc", string.format("Npc[%s] not found！", szClassName));
		return 0;
	end;
	
	Setting:SetGlobalObj(me, pNpc, it);
	if (tbClass.OnLifePercentReduceHere) then
		tbClass:OnLifePercentReduceHere(nPercent);
	end
	--特殊：逍遥谷npc血量注册回调,by Egg
	local tbXoyoPercent = him.GetTempTable("XoyoGame").tbPercentInfo;
	local szXoyoGroup = him.GetTempTable("XoyoGame").szGroup;
	local tbRoom = him.GetTempTable("XoyoGame").tbRoom;
	if szXoyoGroup and tbXoyoPercent and tbRoom then
		for _,tbInfo in pairs(tbXoyoPercent) do
			if tbInfo[1] == nPercent then
				tbRoom:OnNpcBloodPercent(szXoyoGroup,nPercent,tbInfo[2],unpack(tbInfo,3));
			end
		end		
	end 
	Setting:RestoreGlobalObj();
end

--设置npc随机走动AI
--nMapId		:地图Id
--nX			:X坐标32位
--nY			:Y坐标32位
--nAINpcId	:随意走动npcId(具有AI的战斗npc)
--nChatSec		:多少秒循环一次，（0或nil为5）(由nChatSec*nChatCount决定了AInpc的一次存在时间)
--nChatCount	:共循环多少次，（0或nil为1）
--nMaxSec		:存在总时间(包括了AInpc和对话npc在内的总的时间(秒), 0为无限时)
--nRange		:npc每次随机范围(32位,范围随机,（0或nil为1000）)
--nDialogNpcId	:转变成对话npc的Id(0为无对话npc转换,将始终是AInpc)
--nDialogSec	:对话npc存在时间(秒)（0或nil为10秒）
--tbChat		:npc说话内容(AInpc走到过程中的说话内容,表内随机)
--example		:local nMapId,nX,nY = me.GetWorldPos(); Npc:OnSetFreeAI(nMapId, nX*32, nY*32, 598, 0, 0, 0, 0, 2964, 0, {"唉～～～"});	
function Npc:OnSetFreeAI(nMapId, nX, nY, nAINpcId, nChatSec, nChatCount, nMaxSec, nRange, nDialogNpcId, nDialogSec, tbChat)
	
	--默认值；
	nChatSec 	= ((nChatSec==0 	or not nChatSec) 	and 5) 		or nChatSec;
	nChatCount 	= ((nChatCount==0 	or not nChatCount) 	and 1) 		or nChatCount;
	nRange 		= ((nRange==0 		or not nRange) 		and 1000) 	or nRange;
	nDialogSec 	= ((nDialogSec==0 	or not nDialogSec) 	and 10) 	or nDialogSec;
	
	local pNpc = KNpc.Add(nAINpcId, 100, -1, SubWorldID2Idx(nMapId), nX, nY);
	if pNpc then
		local tbRX =  {math.floor(MathRandom(-nRange, -math.floor(nRange*0.6))), math.floor(MathRandom(math.floor(nRange*0.6), nRange))};
		local tbRY =  {math.floor(MathRandom(-nRange, -math.floor(nRange*0.6))), math.floor(MathRandom(math.floor(nRange*0.6), nRange))};
		local nTrX =  tbRX[math.floor(MathRandom(1, 2))] or 0;
		local nTrY =  tbRY[math.floor(MathRandom(1, 2))] or 0;
		local nMovX = nX + nTrX;
		local nMovY = nY + nTrY;
		pNpc.AI_AddMovePos(nMovX, nMovY);
		pNpc.SetNpcAI(9, 0, 1,-1, 0, 0, 0, 0, 0, 0, 0);
		pNpc.GetTempTable("Npc").tbNpcFreeAI				= {};
		pNpc.GetTempTable("Npc").tbNpcFreeAI.nCalcChatCount = 0;
		pNpc.GetTempTable("Npc").tbNpcFreeAI.nChatCount 	= nChatCount;
		pNpc.GetTempTable("Npc").tbNpcFreeAI.nMaxSec 		= nMaxSec;
		pNpc.GetTempTable("Npc").tbNpcFreeAI.nAINpcId 		= nAINpcId;
		pNpc.GetTempTable("Npc").tbNpcFreeAI.nChatSec 		= nChatSec;
		pNpc.GetTempTable("Npc").tbNpcFreeAI.nRange 		= nRange;
		pNpc.GetTempTable("Npc").tbNpcFreeAI.nDialogNpcId 	= nDialogNpcId;
		pNpc.GetTempTable("Npc").tbNpcFreeAI.nDialogSec 	= nDialogSec;
		pNpc.GetTempTable("Npc").tbNpcFreeAI.tbChat 		= tbChat;
		local nTimerId = Timer:Register(nChatSec * Env.GAME_FPS, self.OnTimerFreeAI, self, pNpc.dwId, 1);
		self._tbDebugFreeAITimer 	= self._tbDebugFreeAITimer or {};
		self._tbDebugFreeAITimer2 	= self._tbDebugFreeAITimer2 or {};
		self._tbDebugFreeAITimer[nTimerId] 	 = pNpc.dwId;
		self._tbDebugFreeAITimer2[pNpc.dwId] = nTimerId;
		Npc.tbFreeAINpcList = Npc.tbFreeAINpcList or {};
		Npc.tbFreeAINpcList[pNpc.dwId] = 1;
	end
	return 0;
end

function Npc:OnTimerFreeAI(nNpcId, nNpcType)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		local nTimerId = self._tbDebugFreeAITimer2[nNpcId];
		if nTimerId then 
			self._tbDebugFreeAITimer[nTimerId]	= nil; 
		end
		self._tbDebugFreeAITimer2[nNpcId] = nil;
		return 0;
	end
	
	local nCalcChatCount=	pNpc.GetTempTable("Npc").tbNpcFreeAI.nCalcChatCount;
	local nChatCount 	=	pNpc.GetTempTable("Npc").tbNpcFreeAI.nChatCount;
	local nMaxSec 		= 	pNpc.GetTempTable("Npc").tbNpcFreeAI.nMaxSec;
	local nAINpcId 		= 	pNpc.GetTempTable("Npc").tbNpcFreeAI.nAINpcId;
	local nChatSec 		= 	pNpc.GetTempTable("Npc").tbNpcFreeAI.nChatSec;
	local nRange 		= 	pNpc.GetTempTable("Npc").tbNpcFreeAI.nRange;
	local nDialogNpcId 	= 	pNpc.GetTempTable("Npc").tbNpcFreeAI.nDialogNpcId;
	local nDialogSec 	= 	pNpc.GetTempTable("Npc").tbNpcFreeAI.nDialogSec;
	local tbChat 		= 	pNpc.GetTempTable("Npc").tbNpcFreeAI.tbChat;
	local nMapId 		= 	pNpc.nMapId;
	local nX, nY 		= 	pNpc.GetMpsPos();
	local tbSec 		= 	{[1] = nChatSec, [2] = nDialogSec,};
	
	if nMaxSec > 0 then
		nMaxSec = nMaxSec - tbSec[nNpcType];
		if nMaxSec == 0 then
			nMaxSec = -1;
		end
	end
	
	if nMaxSec < 0 then
		Npc.tbFreeAINpcList[pNpc.dwId] = nil;
		
		---Debug
		local nTimerId = self._tbDebugFreeAITimer2[pNpc.dwId];
		self._tbDebugFreeAITimer[nTimerId]	= nil;
		self._tbDebugFreeAITimer2[pNpc.dwId] = nil;	
		---	
		
		pNpc.Delete();		
		return 0;
	end
	
	if nNpcType == 2 then
		Npc.tbFreeAINpcList[pNpc.dwId] = nil;
		
		---Debug
		local nTimerId = self._tbDebugFreeAITimer2[pNpc.dwId];
		self._tbDebugFreeAITimer[nTimerId]	= nil;
		self._tbDebugFreeAITimer2[pNpc.dwId] = nil;	
		---
		
		pNpc.Delete();
		self:OnSetFreeAI(nMapId, nX, nY, nAINpcId, nChatSec, nChatCount, nMaxSec, nRange, nDialogNpcId, nDialogSec, tbChat)
		return 0;
	end
	
	pNpc.GetTempTable("Npc").tbNpcFreeAI.nMaxSec = nMaxSec;
	if not nDialogNpcId or nDialogNpcId ==0 or nCalcChatCount < nChatCount then
		if nDialogNpcId > 0 then
			pNpc.GetTempTable("Npc").tbNpcFreeAI.nCalcChatCount = pNpc.GetTempTable("Npc").tbNpcFreeAI.nCalcChatCount + 1;
		end
		if type(tbChat) == "table" and #tbChat > 0 then
			local szChar = tbChat[math.floor(MathRandom(1, #tbChat))] or "";
			pNpc.SendChat(szChar);
		end
		return
	end
	
	Npc.tbFreeAINpcList[pNpc.dwId] = nil;
	---Debug
	local nTimerId = self._tbDebugFreeAITimer2[pNpc.dwId];
	self._tbDebugFreeAITimer[nTimerId]	= nil;
	self._tbDebugFreeAITimer2[pNpc.dwId] = nil;	
	---	
	
	pNpc.Delete();
	
	local pNpcDialog = KNpc.Add(nDialogNpcId, 100, -1, SubWorldID2Idx(nMapId), nX, nY);
	if  pNpcDialog then
		pNpcDialog.GetTempTable("Npc").tbNpcFreeAI 				= {};
		pNpcDialog.GetTempTable("Npc").tbNpcFreeAI.nChatCount 	= nChatCount;
		pNpcDialog.GetTempTable("Npc").tbNpcFreeAI.nMaxSec 		= nMaxSec;
		pNpcDialog.GetTempTable("Npc").tbNpcFreeAI.nAINpcId 	= nAINpcId;
		pNpcDialog.GetTempTable("Npc").tbNpcFreeAI.nChatSec 	= nChatSec;
		pNpcDialog.GetTempTable("Npc").tbNpcFreeAI.nRange 		= nRange;
		pNpcDialog.GetTempTable("Npc").tbNpcFreeAI.nDialogNpcId = nDialogNpcId;
		pNpcDialog.GetTempTable("Npc").tbNpcFreeAI.nDialogSec 	= nDialogSec;
		pNpcDialog.GetTempTable("Npc").tbNpcFreeAI.tbChat 		= tbChat;
		local nTimerId = Timer:Register(nDialogSec * Env.GAME_FPS, self.OnTimerFreeAI, self, pNpcDialog.dwId, 2);
		
		--Debug
		self._tbDebugFreeAITimer[nTimerId] 	 = pNpcDialog.dwId;
		self._tbDebugFreeAITimer2[pNpcDialog.dwId] = nTimerId;
		--Debug
		
		Npc.tbFreeAINpcList[pNpcDialog.dwId] = 1;
	end
	return 0;
end

--清空随机AINpc或DialogNpc;
--nNpcId：	清空npc的模版Id，如有对话npc，需AINpc和对话Npc都要清楚，没有填写npc模版Id默认为清空所有AINpc和对话Npc；
function Npc:OnClearFreeAINpc(nNpcId)
	if Npc.tbFreeAINpcList then
		for dwId in pairs(Npc.tbFreeAINpcList) do
			local pNpc = KNpc.GetById(dwId);
			if pNpc then
				if not nNpcId then
					pNpc.Delete();
				end
				
				if nNpcId and pNpc.nTemplateId == nNpcId then
					pNpc.Delete();
				end
			end
		end
	end
	return 0;
end

-- 获取等级数据
--	tbParam:{szAIParam, szSkillParam, szPropParam, szScriptParam}
function Npc:GetLevelData(szClassName, szKey, nSeries, nLevel, tbParam)
	-- 根据 szClassName 找到特定模板
	local tbClass	= self.tbClass[szClassName];
	if (not tbClass) then
		Dbg:WriteLogEx(Dbg.LOG_ERROR, "Npc", string.format("Npc[%s] not found！", szClassName));
		return 0;
	end;
	
	-- 尝试直接找到该类中的属性定义
	local tbData	= nil;
	
	if (szClassName == "") then
		tbClass	= {_tbBase=tbClass};
	end
	
	local tbBaseClasses	= {
		rawget(tbClass, "tbLevelData"),
		self.tbAIBase[tbParam[1]],
		self.tbSkillBase[tbParam[2]],
		self.tbPropBase[tbParam[3]],
		tbClass._tbBase and tbClass._tbBase.tbLevelData,
	};
	for i = 1, 5 do
		local tbBase	= tbBaseClasses[i];
		tbData	= tbBase and tbBase[szKey];
		if (tbData) then
			break;
		end;
	end;
	if (not tbData) then
		Dbg:WriteLogEx(Dbg.LOG_ERROR, "Npc", string.format("Npc[%s]:[%s] not found！", szClassName, szKey));
		return 0;
	end;
	if (type(tbData) == "function") then
		return tbData(nSeries, nLevel, tbParam[4]);
	else
		return Lib.Calc:Link(nLevel, tbData);
	end;
end;

-- 注册特定血量百分比回调
function Npc:RegPNpcLifePercentReduce(pNpc, nPercent, ...)
	local tbPNpcData		= pNpc.GetTempTable("Npc");
	tbPNpcData.tbOnLifePercentReduce = tbPNpcData.tbOnLifePercentReduce or {};
	assert(not tbPNpcData.tbOnLifePercentReduce[nPercent], "too many OnLifePercentReduce registrer on npc:"..pNpc.szName);
	pNpc.AddLifePObserver(nPercent);
	tbPNpcData.tbOnLifePercentReduce[nPercent] = arg;
end

-- 取消特定血量百分比回调
function Npc:UnRegPNpcLifePercentReduce(pNpc, nPercent)
	if pNpc.GetTempTable("Npc").tbOnLifePercentReduce and pNpc.GetTempTable("Npc").tbOnLifePercentReduce[nPercent] then
		pNpc.GetTempTable("Npc").tbOnLifePercentReduce[nPercent] = nil;
	end
end

-- 注册特定Npc死亡回调
function Npc:RegPNpcOnDeath(pNpc, ...)
	local tbPNpcData		= pNpc.GetTempTable("Npc");
	assert(not tbPNpcData.tbOnDeath, "too many OnDeath registrer on npc:"..pNpc.szName);
	tbPNpcData.tbOnDeath	= arg;
end;

-- 取消特定Npc死亡回调
function Npc:UnRegPNpcOnDeath(pNpc)
	pNpc.GetTempTable("Npc").tbOnDeath	= nil;
end;


-- 当Npc死亡掉落物品时回调
function Npc:DeathLoseItem(szDropFile, szClassName, pNpc, tbLoseItem)
	if szDropFile and szDropFile ~= "" then
		self:LoseItem_XuanJingLog(szDropFile, pNpc, tbLoseItem);
	end
	
	local tbDeathLoseItem = pNpc.GetTempTable("Npc").tbDeathLoseItem;
	if (tbDeathLoseItem) then
		local tbCall	= {unpack(tbDeathLoseItem)};
		Lib:MergeTable(tbCall, {pNpc, tbLoseItem});
		local bOK, nRet	= Lib:CallBack(tbCall);	-- 调用回调
		if (not bOK or nRet ~= 1) then
			pNpc.GetTempTable("Npc").tbDeathLoseItem	= nil;
		end
	end
--	if (not tbClass) then
--		Dbg:WriteLogEx(Dbg.LOG_ERROR, "Npc", string.format("Npc[%s] not found！", szClassName));
--		return 0;
--	end;
	local tbClass	= self.tbClass[szClassName];
	if tbClass then
		Setting:SetGlobalObj(me, pNpc, it);
		if (tbClass.DeathLoseItem) then
			tbClass:DeathLoseItem(tbLoseItem);
		end
		Setting:RestoreGlobalObj();
	end
end

function Npc:RegDeathLoseItem(pNpc,...)
	local tbPNpcData = pNpc.GetTempTable("Npc");
	assert(not tbPNpcData.tbDeathLoseItem, "too many DeathLoseItem registrer on npc:"..pNpc.szName);
	tbPNpcData.tbDeathLoseItem = arg;
end

function Npc:UnRegDeathLoseItem(pNpc)
	pNpc.GetTempTable("Npc").tbDeathLoseItem = nil;
end

function Npc:LoseItem_XuanJingLog(szDropFile, pNpc, tbLoseItem)
	if not szDropFile or szDropFile == "" then
		return;
	end
	local tbSystemMsgItem = {		
		["18,1,1276,1"]=1,		--奔宵马牌·箱
		["1,12,33,4"]=1,			--翻羽
		["18,1,1282,1"]=1,		--虎魄天晶符（金）
		["18,1,1282,2"]=1,		--虎魄天晶符（木）
		["18,1,1282,3"]=1,		--虎魄天晶符（水）
		["18,1,1282,4"]=1,		--虎魄天晶符（火）
		["18,1,1282,5"]=1,		--虎魄天晶符（土）
		["2,7,503,10"]=1,		--霸王破阵靴（金）
		["2,7,504,10"]=1,		--玄女舞影鞋（金）
		["2,7,505,10"]=1,		--霸王破阵靴（木）
		["2,7,506,10"]=1,		--玄女舞影鞋（木）
		["2,7,507,10"]=1,		--霸王破阵靴（水）
		["2,7,508,10"]=1,		--玄女舞影鞋（水）
		["2,7,509,10"]=1,		--霸王破阵靴（火）
		["2,7,510,10"]=1,		--玄女舞影鞋（火）
		["2,7,511,10"]=1,		--霸王破阵靴（土）
		["2,7,512,10"]=1,		--玄女舞影鞋（土）
		["18,1,541,4"]=1,		--穿珠银帖（2级）
		["18,1,1,10"]=1,			--10级玄晶
		}
		
	local szStoneLogInfo;
	for _, nItemId in pairs(tbLoseItem.Item or {}) do
		local pItem = KItem.GetObjById(nItemId);
		if pItem and pItem.szClass == "xuanjing" then
			local nBind, nUnBind = 0, 0;
			if (pItem.IsBind() == 1 or KItem.IsItemBindByBindType(pItem.nBindType) == 1) then
			  	nBind = nBind + pItem.nCount;
			else
				nUnBind = nUnBind + pItem.nCount;
			end
			
			Item:InsertXJRecordMemory(Item.emITEM_XJRECORD_DROPRATE, szDropFile, pItem.nLevel, nBind, nUnBind);
		end
		
		--掉落系统提示（vn暂时加到这里，考虑有需求加到掉落表中作为一项）
		if pItem then
			local szItem = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
			if tbSystemMsgItem[szItem] then
				KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, string.format("[%s] bị tiêu diệt, trước khi chết để lại [%s]",pNpc.szName, pItem.szName));
			end
		end
		
--		if pItem and Item.tbStone.tbStoneLogItem[pItem.SzGDPL()] then
--			szStoneLogInfo = szStoneLogInfo or "";
--			szStoneLogInfo = szStoneLogInfo..string.format("%d_%d_%d_%d,", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel)
--		end
	end
	
--	if szStoneLogInfo then
--		szStoneLogInfo =szStoneLogInfo..string.format("%d,%d", pNpc.nMapId, pNpc.nTemplateId);
--		-- 数据埋点 todo zjq 这里的日志可以去掉
--		StatLog:WriteStatLog("stat_info", "baoshixiangqian", "drop", 0, szStoneLogInfo);
--	end
end

function Npc:OnFollowPartnerTalk(nNpcId)
	Npc.tbFollowPartner:OnFollowPartnerTalk(nNpcId)
end

function Npc:OnFollowPartnerSkill(nNpcId)
	Npc.tbFollowPartner:OnFollowPartnerSkill(nNpcId)
end

if MODULE_GAMESERVER then

function Npc:LoadDropFileRecordList()
	local tbFile = Lib:LoadTabFile(self.DROPFILE_RECORD_LIST);
	if not tbFile then
		print("load "..self.DROPFILE_RECORD_LIST.."failed!");
		return;
	end
	
	local tb = {};
	for _, tbData in pairs(tbFile) do
		local tbTemp = {};
		tbTemp.szDropFile = tbData.DropFile;
		tbTemp.ID = assert(tonumber(tbData.ID));		
		
		table.insert(tb, tbTemp);
	end
	
	KNpc.InitDropFileRecordList(tb);
end

Npc:LoadDropFileRecordList();
Npc.tbSpecDialog = Npc.tbSpecDialog or {};
end
