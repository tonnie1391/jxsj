------------------------------------------------------
-- 文件名　：fileuploader.lua
-- 创建者　：dengyong
-- 创建时间：2012-03-28 17:14:02
-- 描  述  ：文件上传控制端
------------------------------------------------------

-- 处理策略：1.在收到服务端请求之后，应当在30秒(这个时间不一定精确)内有回复包；否则认为超时；
-- 2.在申请队列中的角色在下线或者跨服时要打断当前请求
-- 3.收到客户端的回复包之后，根据回复包的状态信息做下一步处理

local tbFileUploader = Player.tbFileUploader or {};
Player.tbFileUploader = tbFileUploader;

tbFileUploader.tbRequestList = tbFileUploader.tbRequestList or {};
tbFileUploader.nTimerId 	= nil;
tbFileUploader.bLogPrint	= 0;

-- 客户端返包状态值
tbFileUploader.CLIENT_RET_SUCCESS_NOT_LAST	= 0;	-- 成功，但不是最后一个包
tbFileUploader.CLIENT_RET_SUCCESS_LAST		= 1;	-- 成功，最后一个包
tbFileUploader.CLIENT_RET_NO_FILE			= 2;	-- 客户端未能找到指定文件
tbFileUploader.CLIENT_RET_POS_OVERHEAD		= 3;	-- 申请读取的文件内容的位置超出大小
tbFileUploader.CLIENT_RET_READ_FAILED		= 4;	-- 客户端读取文件内容失败
tbFileUploader.CLIENT_RET_STATE_FILE_EMPTY  = 5;	-- 客户端文件内容为空

tbFileUploader.SERVER_STATE_WRITE_FAILED	= 64;	-- 客户端返回正确内容包，但服务端写入文件时失败
tbFileUploader.SERVER_WRITE_FAILED_TIMES	= 3;	-- 服务端写文件失败3次后，删除请求


tbFileUploader.TIMER_CHECK_INTERVAL			= 30 * 18;	-- 30秒，timer回调一次
tbFileUploader.REQUEST_TIMEOUT				= tbFileUploader.TIMER_CHECK_INTERVAL;	-- 请求超时时间

-- 请求上传指定文件 
function tbFileUploader:RequestUploadFile(varKey, nBeginPos, szFile, nFailTimes)
	local pPlayer = nil;
	if type(varKey) == "userdata" then		-- pPlayer
		pPlayer = varKey;
	elseif type(varKey) == "number" then	-- id
		pPlayer = KPlayer.GetPlayerObjById(varKey);
	elseif type(varKey) == "string" then	-- szName
		pPlayer = KPlayer.GetPlayerByName(varKey);
	end
	
	-- 要先判断这个玩家是否在线
	if not pPlayer then
		return 0;
	end
	
	if(self.tbRequestList[pPlayer.nId] ~= nil and self.tbRequestList[pPlayer.nId][2] ~= szFile) then
		print(string.format("Player[%s], File[%s] 客户端正在上传其他文件，请稍候再试...", pPlayer.szName, szFile));
		return 0;
	end
	
	local nRet = RequireClientDLLData(pPlayer.GetNetConnectId(), nBeginPos, szFile);
	if nRet == 1 then
		self.tbRequestList = self.tbRequestList or {};		
		self.tbRequestList[pPlayer.nId] = {nBeginPos, szFile, GetTime(), nFailTimes or 0};	-- 最后一个0表示失败次数
		
		if not self.nTimerId then
			self.nTimerId = Timer:Register(self.TIMER_CHECK_INTERVAL, self._OnTimer, self);
		end
	end	
	
	return nRet;
end

function tbFileUploader:ReceiveClientPackage(pPlayer, tbPackage)
	-- 不属于这儿管的
	if not self.tbRequestList or not self.tbRequestList[pPlayer.nId] then
		return;
	end
	
	if self.bLogPrint == 1 then
		print(string.format("Player[%s], File[%s] Receive Package: State[%d], BeginPos[%d], UploadSize[%d], ReqSize[%d]。",
			 pPlayer.szName, self.tbRequestList[pPlayer.nId][2], tbPackage.nState, tbPackage.nBeginPos,
			 tbPackage.nUploadSize, tbPackage.nReqSize));
	end
		
	if tbPackage.nState == self.CLIENT_RET_SUCCESS_NOT_LAST 
		or tbPackage.nState == self.CLIENT_RET_SUCCESS_LAST	then	-- 成功
		self:OnPackageSuccess(pPlayer, tbPackage);
	else
		self:OnPackageFail(tbPackage.nState, pPlayer);		-- 失败	
	end
end

-- 没有检查逻辑
function tbFileUploader:RemoveRequest(varKey)
	local nPlayerId = nil;
	if type(varKey) == "userdata" then			-- pPlayer
		nPlayerId = varKey.nId;
	elseif type(varKey) == "number" then		-- id，remove不用判断这个玩家是否在线
		nPlayerId = varKey;		
	end
	
	if not nPlayerId then
		return;
	end
	
	if not self.tbRequestList or not self.tbRequestList[nPlayerId] then
		return;
	end
	
	local tbRequest = self.tbRequestList[nPlayerId];
	
	-- 删除下载临时文件
	-- 其实不删除文件也可以的吧，因为支持续传的。。。
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	if (RemoveClientUpLoadFile(szPlayerName, tbRequest[2]) == 0 ) then
		assert(false, string.format("Player[%s], File[%s] delete Failed!", szPlayerName, tbRequest[2]));
	end
	
	-- 从队列中删除
	self.tbRequestList[nPlayerId] = nil;
end

-- 返回包正确
function tbFileUploader:OnPackageSuccess(pPlayer, tbPackage)
	local tbRequest = self.tbRequestList[pPlayer.nId];
	
	if tbPackage.nState == self.CLIENT_RET_SUCCESS_LAST then
		-- 传完了
		self.tbRequestList[pPlayer.nId] = nil;
		return;
	end
	
	local nBeginPos = tbRequest[1] + tbPackage.nUploadSize;
	local szFile = tbRequest[2];
	
	self:RequestUploadFile(pPlayer, nBeginPos, szFile);
end

-- 返回包报错
function tbFileUploader:OnPackageFail(nReason, pPlayer)
	if (nReason == self.SERVER_STATE_WRITE_FAILED) then
		-- 是服务端写失败
		local tbRequest = self.tbRequestList[pPlayer.nId];	-- 不用再校验了吧？？？
		if (tbRequest[4] >= self.SERVER_WRITE_FAILED_TIMES) then
			self:RemoveRequest(pPlayer);	-- 失败太多次，删除请求，不然是个死循环
		else
			tbRequest[4] = tbRequest[4] + 1;
			self:RequestUploadFile(pPlayer, tbRequest[1], tbRequest[2], tbRequest[4]);	-- 重新请求一次吧
		end		
	else
		-- 其他原因，删除操作
		self:RemoveRequest(pPlayer);
	end	
end

-- 检查每个请求是否超时了
function tbFileUploader:_OnTimer()
	-- 队列中已经没有请求了，关掉计时器
	if not self.tbRequestList or 
		Lib:CountTB(self.tbRequestList) == 0 then
		
		self.nTimerId = nil;
		return 0;		-- 会关掉
	end
	
	local tbTimeOutRequest = {};
	local nNowTime = GetTime();
	for nId, tbRequest in pairs(self.tbRequestList) do	
		local nLastTime = tbRequest[3];
		if nNowTime < nLastTime or nNowTime - nLastTime >= self.REQUEST_TIMEOUT then
			--self:OnRequestTimeOut();	-- 超时了
			table.insert(tbTimeOutRequest, nId);
		end
	end
	
	for nId in pairs(tbTimeOutRequest) do
		self:RemoveRequest(nId);
	end	
end

function tbFileUploader:OnLogout()
	self:RemoveRequest(me);
end

-- 支持重载
if tbFileUploader.nLogoutEventId then
	PlayerEvent:UnRegisterGlobal("OnLogout", tbFileUploader.nLogoutEventId);
	tbFileUploader.nLogoutEventId = nil;
end
tbFileUploader.nLogoutEventId = PlayerEvent:RegisterGlobal("OnLogout", Player.tbFileUploader.OnLogout, Player.tbFileUploader);

