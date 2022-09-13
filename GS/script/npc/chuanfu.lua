local tbNpc = Npc:GetClass("chuanfu");

function tbNpc:Init()
	self.LOCK_INTERVAL	= 2 * 18;		-- 2秒
	self.nBoatNpcId 	= 11002;
	
	
	-- 新手村三条航线
	self.tbTemplate = {};
	local tbData = Lib:LoadTabFile("\\setting\\map\\chuanfu.txt");
	for _, tbRow in pairs(tbData) do
		local nTemplate = tonumber(tbRow.TemplateId);
		if nTemplate then
			local tb = self.tbTemplate[nTemplate] or {};
			
			local szTransPos = tbRow.TransPos;
			local tbTransPos = Lib:SplitStr(szTransPos, ":");
			if tbTransPos[1] and tbTransPos[2] then
				tb.tbTransPos = {tonumber(tbTransPos[1]), tonumber(tbTransPos[2])};
			end
			
			local tbBoatPos = Lib:SplitStr(tbRow.BoatPos, ":");
			if tbBoatPos[1] and tbBoatPos[2] then
				tb.tbBoatPos = {tonumber(tbBoatPos[1]), tonumber(tbBoatPos[2])};
			end
			
			tb.nBoatLine = tonumber(tbRow.Line);			
			tb.szCfmMsg = tbRow.ConfirmMsg;
			
			tb.tbTaskInfo = {tbRow.MaiTaskId, tbRow.SubTaskId, tonumber(tbRow.TaskStep)};
			
			self.tbTemplate[nTemplate] = tb;
		end
	end
end

function tbNpc:OnDialog()
	if self:CheckCanDialog() == 0 then
		return;
	end

	self:_OnDialog();
end

function tbNpc:_OnDialog(bSure, dwHimId, nMeId)
	local bSure = bSure or 0;
	if bSure == 0 then
		local szMsg = self.tbTemplate[him.nTemplateId].szCfmMsg;
		local tbOpt = 
		{
			{"Xác nhận", self._OnDialog, self, 1, him.dwId, me.nId},
			{"Kết thúc đối thoại"},
		}
		Dialog:Say(szMsg, tbOpt);
	else
		local pNpc = KNpc.GetById(dwHimId);
		local pPlayer = KPlayer.GetPlayerObjById(nMeId);
		if not pNpc or not pPlayer then
			return;
		end
		
		Setting:SetGlobalObj(pPlayer);
		self:ClimbBoat(pNpc.nTemplateId, pNpc.nMapId);
		Setting:RestoreGlobalObj();
	end
end

function tbNpc:CheckCanDialog()
	local nTemplateId = him.nTemplateId;
	if not self.tbTemplate or not self.tbTemplate[nTemplateId] then
		return 0;
	end
	
	local tbTemplate = self.tbTemplate[nTemplateId];
	-- 判断任务步骤，不到指定任务步骤返回
	if self:CheckTaskStep(tbTemplate) == 0 then
		Dialog:Say("Xin chào!");
		return 0;
	end
	
	if (self:CheckLockTime(tbTemplate) == 0 ) then
		return 0;
	end
	
	return 1;
end

function tbNpc:CheckTaskStep(tbTemplate)
	local tbTaskInfo = tbTemplate.tbTaskInfo;
	if not tbTaskInfo then
		return 0;
	end
	
	local nMainTaskId = tonumber(tbTaskInfo[1], 16);
	local nSubTaskId = tonumber(tbTaskInfo[2], 16);
	local nCheckStep = tbTaskInfo[3];
	
	-- 只要这里面有一个为空，就认为是不需要检查任务
	if not nMainTaskId or not nSubTaskId or not nCheckStep then
		return 1;
	end
	
	local tbPlayerTasks	= Task:GetPlayerTask(me).tbTasks;
	local tbTask = tbPlayerTasks[nMainTaskId];	-- 主任务ID
	
	if tbTask and tbTask.nReferId == nSubTaskId then
		if (tbTask.nCurStep == nCheckStep) then
			return 1;
		end
	end
	
	return 0;
end

function tbNpc:CheckLockTime()
	local nTemplateId = him.nTemplateId;
	if not self.tbTemplate or not self.tbTemplate[nTemplateId] then
		return 0;
	end
	
	local tbTemplate = self.tbTemplate[nTemplateId];
	if not tbTemplate.LOCK_BOAT or tbTemplate.LOCK_BOAT == 0 then
		return 1;
	end
	
	if tbTemplate.LOCK_BOAT == 1 then
		if (GetFrame() - tbTemplate.LOCK_TIME >= self.LOCK_INTERVAL) then
			tbTemplate.LOCK_BOAT = 0;
			tbTemplate.LOCK_TIME = 0;
			local nMapId = him.GetWorldPos();
			tbTemplate.pBoat 	 = KNpc.Add2(self.nBoatNpcId, 1, -1, nMapId, unpack(tbTemplate.tbBoatPos));
			tbTemplate.pBoat.SetCarrierIntData(1, tbTemplate.nBoatLine);	-- 设置航线
			self.tbTemplate[nTemplateId] = tbTemplate;
			return 1;
		end
	end
	
	return 0;
end

-- 我擦勒，为什么用climb
function tbNpc:ClimbBoat(nTemplateId, nMapId, nFlag)
	if not self.tbTemplate or not self.tbTemplate[nTemplateId] or not nMapId then
		return 0;
	end
	
	--乘船保护变量
	me.SetTask(1025,83, nTemplateId); 
	if nTemplateId == 10163 then
		me.SetRevivePos(me.nMapId, 2);
	elseif nTemplateId == 10248 then
		me.SetRevivePos(me.nMapId, 1);
	end
	me.RideHorse(0);
	local pBoat = nil;
	local tbTransPos = self.tbTemplate[nTemplateId].tbTransPos;
	local tbBoatPos = self.tbTemplate[nTemplateId].tbBoatPos;
	if nFlag then
		if not self.tbTemplate[nTemplateId].pBoat then
			self.tbTemplate[nTemplateId].pBoat = KNpc.Add2(self.nBoatNpcId, 1, -1, nMapId, unpack(tbBoatPos));
			if not self.tbTemplate[nTemplateId].pBoat then
				return 0;
			end
			self.tbTemplate[nTemplateId].pBoat.SetCarrierIntData(1, self.tbTemplate[nTemplateId].nBoatLine);	-- 设置航线
		end
	
		pBoat = self.tbTemplate[nTemplateId].pBoat;
		
		-- 注意，登船的动作是个持续的过程，所以过程中需要锁定登陆状态
		self.tbTemplate[nTemplateId].LOCK_BOAT = 1;
		self.tbTemplate[nTemplateId].LOCK_TIME = GetFrame();
	else
		pBoat = KNpc.Add2(self.nBoatNpcId, 1, -1, nMapId, unpack(tbBoatPos));
		if not pBoat then
			return;
		end
		pBoat.SetCarrierIntData(1, self.tbTemplate[nTemplateId].nBoatLine);
	end
	me.NewWorld(nMapId, unpack(tbTransPos));	
	Npc.tbCarrier:LandInCarrier(pBoat, me);
end

tbNpc:Init();


---------------------------------------------------------------------
local tbNpc2 = Npc:GetClass("qingjianchuan")
function tbNpc2:OnDialog()
	local bRet = Task:_Specil_SelectCountry();
	if bRet == 0 then
		Dialog:Say("Xin chào!");
	end
end