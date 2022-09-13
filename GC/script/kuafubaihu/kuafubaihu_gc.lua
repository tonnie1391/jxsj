 -- 文件名　：kuafubaihu_gc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2010-12-14 17:32:59
-- 描述：


Require("\\script\\kuafubaihu\\kuafubaihu_def.lua")

if not MODULE_GC_SERVER then
	return;
end

KuaFuBaiHu.tbPKStopTimer = nil;	--PK停止计时器 , 准备场进入战斗场关闭后开启，15分钟
KuaFuBaiHu.tbKickOutTimer = nil; --传出所有玩家计时器，PK结束开启，5分钟
KuaFuBaiHu.tbPKStartTimer = nil; --PK开始计时器,apply调用开启， 5分钟
KuaFuBaiHu.tbTransferTimer = nil; --准备场进入战斗场计时器，PK开始时开启，5分钟

function KuaFuBaiHu:Switch(bOpen)
	if bOpen then
		KGblTask.SCSetDbTaskInt(DBTASK_GC_KUAFUBAIHU_SWITCH,bOpen);
	end
end


function KuaFuBaiHu:SendGB_GCState(nLevel)	--向所有的GC广播当前状态
	GlobalGCExcute(GCEvent.nGBGCExcuteFromId,{"BaiHuTang:ReceiveGB_GCState",self.nActionState_GC,nLevel});
end

function KuaFuBaiHu:OnTimerPKStart()
	self:PKStart();
	return 0;
end

function KuaFuBaiHu:OnTimerKickOut()
	self:TransferAllPlayer();
	return 0;
end

function KuaFuBaiHu:OnTimerTransfer()
	self.nActionState_GC = KuaFuBaiHu.FORBIDENTER;
	GlobalExcute{"KuaFuBaiHu:ApplyForbidSign_GS",self.nActionState_GC};	--广播状态
	self.tbPKStopTimer = Timer:Register(KuaFuBaiHu.nPKStopTimeOut  * 60 * Env.GAME_FPS, self.OnTimerPKStop, self);	--PK传送关闭后15分钟PK结束
	self.tbTransferTimer = nil;
	return 0;
end

function KuaFuBaiHu:OnTimerPKStop()
	self:PKStop();
	return 0;
end

function KuaFuBaiHu:PKStop()	--pk结束,50分开启
	if not GLOBAL_AGENT then
		return;
	end
	self.nActionState_GC = KuaFuBaiHu.RESTSTATE;
	GlobalExcute{"KuaFuBaiHu:PKStop_GS",self.nActionState_GC};
	self.tbKickOutTimer = Timer:Register(KuaFuBaiHu.nKickOutTimeOut * 60 * Env.GAME_FPS, self.OnTimerKickOut, self); -- PK结束后5分钟传送所有玩家
	self.tbPKStopTimer = nil;
	Dbg:WriteLogEx(2, "KuafuBaiHu","KuaFuBaiHu PKStop",self.nActionState_GC);
end

function KuaFuBaiHu:ApplyStart()	--开启报名,本服白虎堂到25分开启
	if not GLOBAL_AGENT then
		return;
	end
	if KGblTask.SCGetDbTaskInt(DBTASK_GC_KUAFUBAIHU_SWITCH) == 0 then	--开关控制
		return;
	end
	self.nActionState_GC = KuaFuBaiHu.APPLYSTATE;
	self.tbPlayerInfo_GC	= {};	--gc上存储的玩家信息
	self.tbGroupInfo_GC 	= {};	--gc上进行的分组信息
	self.tbCampInfo_GC	= {};	--gc上的阵营信息，用于分组使用
	GlobalExcute{"KuaFuBaiHu:ApplyStart_GS",self.nActionState_GC};	--广播状态
	self.tbPKStartTimer = Timer:Register(KuaFuBaiHu.nPKStartTimeOut  * 60 * Env.GAME_FPS, self.OnTimerPKStart, self);
	Dbg:WriteLogEx(2, "KuafuBaiHu","KuaFuBaiHu Begin",self.nActionState_GC);
end

function KuaFuBaiHu:PKStart() --pk开始，30分开启
	if not GLOBAL_AGENT then
		return;
	end
	self:GenFinalGroup();
	self.nActionState_GC = KuaFuBaiHu.FIGHTSTATE;
	self.tbTransferTimer = Timer:Register(KuaFuBaiHu.nTransTimeOut * 60 * Env.GAME_FPS, self.OnTimerTransfer, self);	--PK开启后5分钟无法进入
	GlobalExcute{"KuaFuBaiHu:PKStart_GS",self.tbGroupInfo_GC,self.nActionState_GC};	--广播给每个gc分组信息,把状态广播给每个gs
	self.tbPKStartTimer = nil;
	Dbg:WriteLogEx(2, "KuafuBaiHu","KuaFuBaiHu PKStart",self.nActionState_GC);
end


function KuaFuBaiHu:GenFinalGroup()	--生成最终的分组信息,30分钟时候开启
	self:SataCampInfo();
	self:SortCampByRich();
	local tbGroup = self:GroupingCampsBySort();
	for i = 1, #KuaFuBaiHu.tbFightMapIdList do
		self.tbGroupInfo_GC[i] = {};
	end
	for nIndex,tbRoom in pairs(tbGroup) do
		local tbTemp = {};
		for _,nCampIndex in pairs(tbRoom) do
			table.insert(tbTemp,self:GetCampIdByIndex(nCampIndex));	
		end
		local iPos = (nIndex % #KuaFuBaiHu.tbFightMapIdList) ~= 0 and (nIndex % #KuaFuBaiHu.tbFightMapIdList) or #KuaFuBaiHu.tbFightMapIdList;
		table.insert(self.tbGroupInfo_GC[iPos],tbTemp);
	end
end

function KuaFuBaiHu:TransferAllPlayer()	--mission关闭了，将所有玩家传回本服,55分开启
	if not GLOBAL_AGENT then
		return;
	end
	GlobalExcute{"KuaFuBaiHu:TransferAllPlayer"};
	self.tbKickOutTimer = nil;
	Dbg:WriteLogEx(2, "KuafuBaiHu","KuaFuBaiHu TransferAll",self.nActionState_GC);
end


function KuaFuBaiHu:ReceivePlayerInfo(tbPlayerInfo)	--玩家进入准备场，给gc同步玩家的基本信息,通过信息进行分组
	if tbPlayerInfo then
		local tbTemp = {};	
		tbTemp.nPlayerId = tbPlayerInfo.nId;
		tbTemp.nPlayerCampId = tbPlayerInfo.nCampId;
		tbTemp.nRiches = tbPlayerInfo.nRiches;
		tbTemp.nPlayerLevel = tbPlayerInfo.nLevel;
		table.insert(self.tbPlayerInfo_GC,tbTemp);
		Dbg:WriteLogEx(2, "KuafuBaiHu","KuaFuBaiHu ReceiveInfo",tbTemp.nPlayerId,tbTemp.nPlayerCampId,tbTemp.nRiches,tbTemp.nPlayerLevel);
	end
end

function KuaFuBaiHu:RemovePlayerInfo(nId)	--若在准备场PK未开始时间段离开，则将玩家信息从表中移除
	if nId then
		for nIndex,tbPlayer in pairs(self.tbPlayerInfo_GC) do
			if tbPlayer.nPlayerId == nId then
				table.remove(self.tbPlayerInfo_GC,nIndex);
			end
		end
	end
end

function KuaFuBaiHu:SataCampInfo()	--统计阵营信息
	for _,tbPlayer in pairs(self.tbPlayerInfo_GC) do
		local bCampExist,nIndex = self:IsCampExist(tbPlayer.nPlayerCampId);
		if  bCampExist == 1 then
			self.tbCampInfo_GC[nIndex].nRiches = self.tbCampInfo_GC[nIndex].nRiches + tbPlayer.nRiches*tbPlayer.nPlayerLevel/100;
		else
			local tbTemp = {};
			tbTemp.nId = tbPlayer.nPlayerCampId;
			tbTemp.nRiches = tbPlayer.nRiches;
			table.insert(self.tbCampInfo_GC,tbTemp);
		end
	end
end

function KuaFuBaiHu:IsCampExist(nCampId)	--玩家阵营是否存在
	for nIndex , tbCamp in pairs(self.tbCampInfo_GC) do
		if tbCamp.nId == nCampId then 
			return 1,nIndex;
		end
	end
	return 0;
end

function KuaFuBaiHu:SortCampByRich()	--按阵营的财富总和进行排序
	local sortFunc = function(tb1,tb2) return tb2.nRiches < tb1.nRiches end
	table.sort(self.tbCampInfo_GC,sortFunc);	--按财富将阵营进行降序排列
end

function KuaFuBaiHu:GroupingCampsBySort()	--按照财富排序进行分组
	local tbCampRoom = {};		-- 用来存放各个mission的阵营ID表
	local nCampRoomIndex = 1;
	local nCampInfoIndex = 1;
	while(self.tbCampInfo_GC[nCampInfoIndex]) do
		tbCampRoom[nCampRoomIndex] = tbCampRoom[nCampRoomIndex] or {};
		local tbRoom = tbCampRoom[nCampRoomIndex];
		local tbCampInfo1 = self.tbCampInfo_GC[nCampInfoIndex];
		local tbCampInfo2 = self.tbCampInfo_GC[nCampInfoIndex + 1] or nil;
		if #tbRoom <= 1 or not tbCampInfo2 then
			table.insert(tbRoom, nCampInfoIndex);
			nCampInfoIndex = nCampInfoIndex + 1;
		elseif #tbRoom >= 3 then
			nCampRoomIndex = nCampRoomIndex + 1;
		elseif #tbRoom == 2 then
			if not tbCampInfo2 then
				table.insert(tbRoom, nCampInfoIndex);
				nCampInfoIndex = nCampInfoIndex + 1;
			else
				local _tbCampInfo2 = self.tbCampInfo_GC[tbRoom[2]];
				if _tbCampInfo2.nRiches - tbCampInfo1.nRiches < tbCampInfo1.nRiches - tbCampInfo2.nRiches then
					table.insert(tbRoom, nCampInfoIndex);
					nCampInfoIndex = nCampInfoIndex + 1;
				else
					nCampRoomIndex = nCampRoomIndex + 1;				
				end
			end		
		end
	end
	return tbCampRoom;
end 

function KuaFuBaiHu:GetCampIdByIndex(nIndex)
	return self.tbCampInfo_GC[nIndex].nId;
end

----测试指令-----------------------------------
function KuaFuBaiHu:ChangeBossTime(tbTime)
	if tbTime then
		GlobalExcute{"KuaFuBaiHu:ChangeTime_GS",tbTime};
	end
end

function KuaFuBaiHu:ClearAllState()
	if self.tbPKStopTimer and self.tbPKStopTimer ~= 0 then
		Timer:Close(self.tbPKStopTimer);
		self.tbPKStopTimer = nil;
	end
	if self.tbKickOutTimer and self.tbKickOutTimer ~= 0  then
		Timer:Close(self.tbKickOutTimer);
		self.tbKickOutTimer = nil;
	end
	if self.tbPKStartTimer and self.tbPKStartTimer ~= 0  then
		Timer:Close(self.tbPKStartTimer)
		self.tbPKStartTimer = nil;
	end
	if self.tbTransferTimer and self.tbTransferTimer ~= 0 then
		Timer:Close(self.tbTransferTimer)
		self.tbTransferTimer = nil;
	end
	self.nActionState_GC = KuaFuBaiHu.RESTSTATE;
	GlobalExcute{"KuaFuBaiHu:PKStop_GS",self.nActionState_GC};
	self:TransferAllPlayer();
end