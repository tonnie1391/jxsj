-- 文件名　：clientprocessinfo.lua
-- 创建者　：houxuan
-- 创建时间：2008-12-22 08:54:02

Require("\\script\\player\\antibot\\antibot.lua");

local tbCProInfo = Player.tbAntiBot.tbCProInfo or {};
Player.tbAntiBot.tbCProInfo = tbCProInfo;

tbCProInfo.tbc2sFun = {};

function tbCProInfo:CollectClientProInfo(szProName, szRoleName)
	local pPlayer = KPlayer.GetPlayerByName(szRoleName);
	if (not pPlayer) then
		return 0;
	end;
	
	if (not szProName) then
		szProName = "";
	end
	
	local szMsg = [[	
		local nRetCode, szRes = GetClientProInfo(_szProName_);
		if nRetCode == 1 then
			szRes = "初始化失败。";	
		elseif nRetCode == 2 then
			szRes = "获取详细信息失败。";	
		end
		
		local nMaxSendLen = 1024 * 6;	
		local nResLen = string.len(szRes);
		
		if (nResLen >= 100 * 1024) then
			nResLen = 100 * 1024;
		end

		local nStart = 0;
		while (nStart + nMaxSendLen < nResLen) do
			me.CallServerScript({"ClientProInfo", "SaveClientInfo", me.szName, string.sub(szRes, nStart, nStart + nMaxSendLen), 0});
			nStart = nStart + nMaxSendLen;                           
		end                           
		                           
		me.CallServerScript({"ClientProInfo", "SaveClientInfo", me.szName, string.sub(szRes, nStart, nResLen), 1});
	]];                           
	szMsg = string.gsub(szMsg, "_szProName_", "\""..szProName.."\"");                                
	
	--记录询问的时间和客户端的信息，写入文件中
	local szLog = string.format("IP：%s\t角色名：%s\t账号：%s\t请求获取客户端进程的时间：%s\n", pPlayer.GetPlayerIpAddress(), pPlayer.szName, pPlayer.szAccount, GetLocalDate("%Y\\%m\\%d  %H:%M:%S"));
	local tbData = Player:GetPlayerTempTable(pPlayer);
	tbData.szCP_FileName = "log\\AntiLog"..GetLocalDate("%Y%m%d")..".txt";
	KIo.AppendFile(tbData.szCP_FileName, szLog);
	
	pPlayer.CallClientScript({"GM:DoCommand", szMsg});
	return 0;
end

--把收集到的进程信息发送到服务端保存
function tbCProInfo:SaveClientInfo(szName, szMsg, nEndFlag)
	if (type(szName) ~= "string" or type(szMsg) ~= "string" or (not nEndFlag)) then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (not pPlayer) then
		return 0;
	end;
	local tbData = Player:GetPlayerTempTable(pPlayer);
	
	if (not tbData.tbCP_Msg) then
		tbData.tbCP_Msg = {};
	end
	table.insert(tbData.tbCP_Msg, szMsg);
	local szInfo = table.concat(tbData.tbCP_Msg);
	if (string.len(szInfo) >= 100 * 1024) then	--客户端进程信息最长不能超过100K
		local szText = string.format("IP：%s\t角色：%s\t账号：%s\t客户端进程信息收集到达时间：%s\t出现了异常(长度超过100K)，内容：\n%s\n", pPlayer.GetPlayerIpAddress(), pPlayer.szName, pPlayer.szAccount, GetLocalDate("%Y\\%m\\%d  %H:%M:%S"), szInfo);
		KIo.AppendFile(tbData.szCP_FileName, szText);
		tbData.tbCP_Msg = nil;
		local szLogMsg = string.format("[反外挂]：客户端进程信息过长\t账号：%s\t角色：%s\tIP地址：%s\t时间：%s", pPlayer.szAccount, pPlayer.szName, pPlayer.GetPlayerIpAddress(), GetLocalDate("%Y\\%m\\%d  %H:%M:%S"));
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_ANTIBOT_PROCESS, szLogMsg);
		pPlayer.KickOut();		--产生了异常，直接把该玩家踢下线
		return 0;
	end
	
	if (nEndFlag == 0) then			--等于0表示还有后继的信息
		return 0;
	end
	
	local szText = string.format("IP：%s\t角色名：%s\t账号：%s\t客户端进程信息收集到达时间：%s\n%s\n", pPlayer.GetPlayerIpAddress(), pPlayer.szName, pPlayer.szAccount, GetLocalDate("%Y\\%m\\%d  %H:%M:%S"), szInfo);
	KIo.AppendFile(tbData.szCP_FileName, szText);
	tbData.tbCP_Msg = nil;
	return 1;
end

tbCProInfo.tbc2sFun["SaveClientInfo"] = tbCProInfo.SaveClientInfo;


--上传客户端的文件

tbCProInfo.tbClientFile = {}

function tbCProInfo:RequestUpload(szName, szClientPath, szLocalName)
	if (self:IsAllowUpload() == 1) then
		self:WriteLog("RequestUpload", "服务器端禁止上传客户端信息。");
		return 0;
	end
	
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (not pPlayer) then
		self:WriteLog("RequestUpload", "player "..szName.." is not online.");
		return 0;
	end
	if (not szClientPath) then
		return 0;
	end
	if ((not szLocalName) or (szLocalName == "")) then
		szLocalName = GetLocalDate("%Y%m%d");
	end
	if (string.len(szLocalName) <= 4) then
		szLocalName = szLocalName..".pak";
	elseif (string.sub(szLocalName, -4, -1) ~= ".pak") then
		szLocalName = szLocalName..".pak";
	end
	self.tbClientFile[szName] = nil;
	self.tbClientFile[szName] = {};
	
	local tbOne = self.tbClientFile[szName];
	
	tbOne.szFileName = "log\\"..szName..szLocalName;
	tbOne.szFileText = {};
	tbOne.nCount = 0;
	tbOne.szFileText[0] = {};
	tbOne.szFileText[1] = {};
	
	local szMsg = [[
		local nRet = UploadFile(__szClientPath__, __szLocalName__);
		if (nRet ~= 0)	then
			me.CallServerScript({"RecvCData", "RecvData", me.szName, -2, 0, ""});
		end
	]];
	
	szMsg = string.gsub(szMsg, "__szClientPath__", "\""..szClientPath.."\"");
	szMsg = string.gsub(szMsg, "__szLocalName__", "\""..szLocalName.."\"");
	
	pPlayer.CallClientScript({"GM:DoCommand", szMsg});
	return 0;
end

function tbCProInfo:RecvData(szName, nFileIndex, nPackCount, szMsg)
	if (self:IsAllowUpload() == 1) then
		self:WriteLog("RecvData", "服务器端禁止上传客户端信息, 信息接收失败");
		self:ClearPlayerData(szName);
		return 0;
	end
	
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (not pPlayer) then
		self:WriteLog("RequestUpload", "玩家"..szName.."与服务器的连接已经断开.");
		self:ClearPlayerData(szName);
		return 0;
	end
	
	local tbOne = self.tbClientFile[szName];
	if (not tbOne) then
		self:WriteLog("RecvData", "服务器并未要求"..szName.."上传客户端文件。");
		return 0;
	end
	
	if (nFileIndex == -1) then
		self:SaveClientData(szName);
		self:ClearPlayerData(szName);
	elseif (nFileIndex == -2) then
		self:WriteLog("RecvData", "请求上传"..szName.."的客户端文件失败，打包失败或者找不到要打包的文件");
		self:ClearPlayerData(szName);
	else
		if (nPackCount == -1) then	--新的文件
			tbOne.szFileText[nFileIndex][tbOne.nCount + 1] = szMsg;
			tbOne.nCount = 0;
			self:Response(szName);
		elseif (tbOne.nCount + 1 == nPackCount) then
			tbOne.nCount = nPackCount;
			tbOne.szFileText[nFileIndex][tbOne.nCount] = szMsg;
			self:Response(szName);
		else
			self:WriteLog("RecvData", "玩家"..szName.."上传客户端数据的过程中，出现数据包缺失。");
			self:ClearPlayerData(szName);	--数据包传送出错
		end
	end
	return 0;
end

tbCProInfo.tbc2sFun["RecvData"] = tbCProInfo.RecvData;

function tbCProInfo:Response(szName)
	if (self:IsAllowUpload() == 1) then
		self:WriteLog("Response", "服务器端禁止上传客户端信息, 停止向客户端发送上传数据的请求。");
		self:ClearPlayerData(szName);
		return 0;
	end
	
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (not pPlayer) then
		self:WriteLog("Response", "玩家"..szName.."已经不在线，无法回应客户端继续发送数据。");
		self:ClearPlayerData(szName);
		return 0;
	end
	local nBytes = self:GetPacketSize();
	if (nBytes == 0) then
		self:WriteLog("Response", "当前服务器在线人数过多，停止上传客户端数据。");
		self:ClearPlayerData(szName);
		return 0;
	end
	local szMsg = [[
		local nFileIndex, nPackCount, szMsg = SendClientData(__nBytes__);
		me.CallServerScript({"RecvCData", "RecvData", me.szName, nFileIndex, nPackCount, szMsg});
	]];
	szMsg = string.gsub(szMsg, "__nBytes__", nBytes);
	pPlayer.CallClientScript({"GM:DoCommand", szMsg});
	return 0;
end

tbCProInfo.tbSizeCfg = {
		[1]		= 1024 * 3,
		[2]		= 1024 * 3,
		[3]		= 1024 * 3,
		[4]		= 1024 * 3,
		[5]		= 1024 * 2,
		[6]		= 1024,
		[7]		= 512,
		[8]		= 0,
	}

tbCProInfo.nForbidden = 0;	--为0表示允许上传，为1表示禁止上传

function tbCProInfo:SetForbiddenValue(nValue)
	self.nForbidden = nValue;
	return 0;
end

function tbCProInfo:IsAllowUpload()
	return self.nForbidden;
end

--由当前的服务器在线人数决定请求上传的数据包的大小
function tbCProInfo:GetPacketSize()
	local nCurPlayerNumber = KPlayer.GetPlayerCount();
	nCurPlayerNumber = nCurPlayerNumber / 100;
	if (nCurPlayerNumber < 1) then
		nCurPlayerNumber = 1;
	end
	local nNumber = 0;
	for i, nBytes in ipairs(self.tbSizeCfg) do
		if (nCurPlayerNumber >= i) then
			nNumber = nBytes;
		end
	end
	if (self:IsAllowUpload() == 1) then
		nNumber = 0;
	end
	return nNumber;
end

function tbCProInfo:SaveClientData(szName)
	local tbOne = self.tbClientFile[szName];
	if (not tbOne) then
		self:WriteLog("SaveClientData", "服务器并未要求该玩家上传客户端文件, 无法保存数据。");
		return 0;
	end
	local szTemp = "";
	local tbPak = tbOne.szFileText[0];
	for i, msg in ipairs(tbPak) do
		szTemp = szTemp..msg;
		if (string.len(szTemp) >= 20 * 1024) then
			KIo.AppendFile(tbOne.szFileName, szTemp);
			szTemp = "";
		end
	end
	KIo.AppendFile(tbOne.szFileName, szTemp);
	szTemp = "";
	
	local tbTxt = tbOne.szFileText[1];
	for i, msg in ipairs(tbTxt) do
		szTemp = szTemp..msg;
		if (string.len(szTemp) >= 20 * 1024) then
			KIo.AppendFile(tbOne.szFileName..".txt", szTemp);
			szTemp = "";
		end
	end
	KIo.AppendFile(tbOne.szFileName..".txt", szTemp);
	szTemp = "";
end

function tbCProInfo:ClearPlayerData(szName)
	if (self.tbClientFile[szName]) then
		self.tbClientFile[szName] = nil;
		self:WriteLog("ClearPlayerData", "清除玩家"..szName.."在当前服务器上已经上传上来的数据。");
	end
end

function tbCProInfo:WriteLog(...)
	Dbg:WriteLogEx(Dbg.LOG_ATTENTION, "Player.tbAntiBot.tbCProInfo", unpack(arg));
end

function tbCProInfo:OnLogout(szReason)
	if (self.tbClientFile[me.szName]) then
		self:WriteLog("OnLogout", "玩家下线，释放玩家在服务器端未上传完毕的资源。");
		self:ClearPlayerData(me.szName);
	end
end

PlayerEvent:RegisterGlobal("OnLogout", Player.tbAntiBot.tbCProInfo.OnLogout, Player.tbAntiBot.tbCProInfo);
