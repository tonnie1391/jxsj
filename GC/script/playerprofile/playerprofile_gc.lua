-------------------------------------------------------------------
--File: playerprofile_gc.lua
--Author: Brianyao
--Date: 2008-9-24 14:57
--Describe: gamecenter 玩家信息
-------------------------------------------------------------------
if not PProfile then --调试需要
	PProfile = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
else
	if not MODULE_GC_SERVER then
		return
	end
end

--已经在服务器Check过逻辑了，这里只是做数据修改
function PProfile:ApplyEditStrInfoGS(nOper,szStr,szPlayerName)
         local pPProfile = nil
         local nRet      = 0
         
         pPProfile,nRet = KPProfile.GetPlayerProfileByName(szPlayerName)
         
         if (nRet==1) then
         
             if pPProfile == nil then 
                 KPProfile.CreateProfileByPlayerName(szPlayerName)
                 pPProfile = KPProfile.GetPlayerProfileByName(szPlayerName)
             end
             
             if (pPProfile ~= nil) then
                 local nTaskID = nOper
                 local nTaskValue = szStr
                 pPProfile.SetTaskBuff(nTaskID,nTaskValue)
             else
                 print("Profile Create Failed",szPlayerName)
             end
             
         end
         
	 return 1
end

--已经在服务器Check过逻辑了，这里只是做数据修改
function PProfile:ApplyEditIntInfoGS(nOper,szName,nParam)
         local pPProfile = nil
         local nRet = 0
         
         pPProfile,nRet = KPProfile.GetPlayerProfileByName(szName)
         if (nRet==1) then
         
             if pPProfile == nil then 
                 KPProfile.CreateProfileByPlayerName(szName)
                 pPProfile = KPProfile.GetPlayerProfileByName(szName)
             end
             
             if (pPProfile ~= nil) then
                 local nTaskID = nOper
                 local nTaskValue = nParam
                 pPProfile.SetTaskValue(nTaskID,nTaskValue)
             else 
                 print("Profile Create Failed",szName)
             end
             
         end
         
	 return 1
end

function PProfile:ApplyFirstTimeGift(szName)
	local pPProfile = nil;
	local nRet = 0;
   
	pPProfile, nRet = KPProfile.GetPlayerProfileByName(szName)
	if nRet == 1 then
		local nFirstTime = 0;
		--没有关联任何SNS，而且是第一次填写个人信息
		if pPProfile == nil then
			KPProfile.CreateProfileByPlayerName(szName)
			pPProfile = KPProfile.GetPlayerProfileByName(szName)
			if (pPProfile ~= nil) then
				nFirstTime = 1;
			end
		--有关联SNS导致Profile已创建，但是第一次填写个人信息
		else
			local nEdited = pPProfile.GetTaskValue(self.emPF_TASK_PROFILE_EDITED);
			if nEdited == 0 then
				nFirstTime = 1;
			end
		end
		if nFirstTime == 1 then
			GlobalExcute{"PProfile:ApplyFirstTimeGiftRet", szName};
			pPProfile.SetTaskValue(self.emPF_TASK_PROFILE_EDITED, 1);
		end
	end
end

function PProfile:GetSnsInfo(nServerId, nRequestId, tbPlayerName)
	local tbSnsInfo = {};
	local nBegin = PProfile.emPF_BUFTASK_TTENCENT;
	local nEnd = PProfile.emPF_BUFTASK_TSINA;
	for _, szPlayerName in ipairs(tbPlayerName) do
		if szPlayerName and type(szPlayerName) == "string" then
			local nHide = 0;
			local nSnsBind = 0;
			local nId = KGCPlayer.GetPlayerIdByName(szPlayerName);
			if nId then
				nSnsBind = KGCPlayer.OptGetTask(nId, KGCPlayer.SNS_BIND);
				nHide = Lib:LoadBits(nSnsBind, 4, 7);
			end
			local pPProfile = KPProfile.GetPlayerProfileByName(szPlayerName);
			if pPProfile and nHide == 0 then
				local tbInner = {};
				for i = nBegin, nEnd do
					tbInner[i] = pPProfile.GetTaskBuff(i);
				end
				tbSnsInfo[szPlayerName] = tbInner;
			end
		end
	end
	--目前缺少通过nServerId查找nConnectId的接口, 先用广播的方式, 将nServerId传回
	GlobalExcute({"PProfile:OnSnsInfoReceived", nServerId, nRequestId, tbSnsInfo});	
end
