
if (not SpecialEvent.tbQQShow) then
	SpecialEvent.tbQQShow = {};
end
local tbQQShow = SpecialEvent.tbQQShow;


tbQQShow.QQSHOWNUMBER_PERSERVER = 2500; -- 每组服务器发放的数目

--------------------------------------------------------------------
-- GS
if MODULE_GAMESERVER then
	-- 需要发放QQShow激活码的服务器组
	tbQQShow.tbServerList = 
	{
		["gate0601"]=1,["gate0602"]=1,["gate0603"]=1,["gate0604"]=1,["gate0605"]=1,["gate0606"]=1,["gate0607"]=1,["gate0608"]=1,["gate0609"]=1,["gate0610"]=1,
		["gate0611"]=1,["gate0612"]=1,["gate0613"]=1,["gate0614"]=1,["gate0615"]=1,["gate0616"]=1,["gate0617"]=1,["gate0618"]=1,["gate0619"]=1,["gate0620"]=1,
		["gate0502"]=1,["gate0503"]=1,["gate0504"]=1,["gate0505"]=1,["gate0506"]=1,["gate0507"]=1,["gate0508"]=1,["gate0509"]=1,["gate0510"]=1,
	}
	
	
	-- 持续时间
	tbQQShow.TIME_START 	= 200810152400;	 	--开始时间
	tbQQShow.TIME_END   	= 200811142400;		--结束时间

	-- 需要获得激活码的最低等级
	tbQQShow.nLevelMinLimit = 30;
	
	-- 此任务变量保存玩家占用的QQShowId(Num)
	tbQQShow.tbQQShowTaskValue = {2038, 5};
	
	function tbQQShow:GetQQShowSNList()
		-- 只有指定区服才去读文件
		
		if (not self.tbQQShowSNList) then
			local szGatewayName = GetGatewayName();
			self.szQQShowSNFile = string.format("\\setting\\event\\qqshow\\qqshow_%s.txt", szGatewayName);
			if (self.tbServerList[szGatewayName]) then
				self.tbQQShowSNList = Lib:LoadTabFile(self.szQQShowSNFile);
			else
				self.tbQQShowSNList = {};
			end
		end
				
		return self.tbQQShowSNList;
	end
	
	-- 本服务器此时是否开启QQShow活动
	function tbQQShow:CheckOpen()
		local szGatewayName = GetGatewayName();
		local nDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
		if (nDate >= self.TIME_START and nDate < self.TIME_END and self.tbServerList[szGatewayName]) then
			return 1;
		end
	end
	
	
	-- 向GC申请一个QQShowSN
	function tbQQShow:QQShowApplySN(nPlayerId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if (not pPlayer) then
			return;
		end
		
		local szGatewayName = GetGatewayName();
		
		-- 本服务器是否有激活码发放
		if (not self.tbServerList[szGatewayName]) then
			self:Msg2Player(pPlayer, "只有新开服务器才能领取QQ秀激活码。");
			return;
		end
		
		-- 等级是否达到
		if (pPlayer.nLevel < self.nLevelMinLimit) then
			self:Msg2Player(pPlayer, "您的等级不足"..self.nLevelMinLimit.."级");
			return;
		end
		
		-- 是否已经领过		
		local nQQShowSNNum = pPlayer.GetTask(unpack(self.tbQQShowTaskValue));
		if (nQQShowSNNum ~= 0) then
			local szQQShowSN = self:GetQQShowSN(nQQShowSNNum);
			assert(szQQShowSN);
			self:Msg2Player(pPlayer, "您已经领取过QQ秀激活码，您的QQ秀激活码是：\n"..szQQShowSN);
			return;
		end
		
		-- 激活码是否已经发放完
		local nCurrSNCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_QQSHOW);
		if (nCurrSNCount >= self.QQSHOWNUMBER_PERSERVER) then
			self:Msg2Player(pPlayer, "本服务器QQ秀激活码已经发放完毕，感谢您的参与。");
			return;
		end
		
		-- 锁定此玩家，为了在接收到GC传来的消息前不会下线
		pPlayer.AddWaitGetItemNum(1);
		
		-- 通知GC分配一个激活码
		GCExcute({"SpecialEvent.tbQQShow:QQShowAllocateSN", pPlayer.szName});		
	end
	
	
	function tbQQShow:QQShowAllocateResult(szPlayerName, nQQShowSNNum)
		local pPlayer = GetPlayerObjFormRoleName(szPlayerName);
		if (not pPlayer) then
			return;
		end
		
		-- 解锁此玩家
		pPlayer.AddWaitGetItemNum(-1);
		
		-- 本组服务器QQShow激活码已经发放完毕
		if (not nQQShowSNNum) then
			return;	
		end
		
		local szQQShowSN = self:GetQQShowSN(nQQShowSNNum);
		assert(szQQShowSN);
		self:Msg2Player(pPlayer, "您好，恭喜您获得了剑侠世界公测活动的QQ秀赠品，以下是您的QQ秀激活码：\n"..szQQShowSN);
		pPlayer.SetTask(self.tbQQShowTaskValue[1], self.tbQQShowTaskValue[2], nQQShowSNNum);
		
		-- 烟花特效
		pPlayer.CastSkill(307, 1, -1, pPlayer.GetNpc().nIndex);
	end

	-- 返回QQShow激活码
	function tbQQShow:GetQQShowSN(nQQShowSNNum)
		local szQQShowSN = nil;	
		local tbQQShowSNList = self:GetQQShowSNList();
		if (not tbQQShowSNList or not tbQQShowSNList[nQQShowSNNum]) then
			print(nQQShowSNNum);
			assert(false);
		end
		
		szQQShowSN = tbQQShowSNList[nQQShowSNNum].QQShowSN;
		if (not szQQShowSN) then
			print(nQQShowSNNum);
			assert(false);
		end
		
		return szQQShowSN;
	end
	
	
	function tbQQShow:Msg2Player(pPlayer, szMsg)
		Setting:SetGlobalObj(pPlayer, him, it);
		Dialog:Say(szMsg);
		Setting:RestoreGlobalObj();
	end
	
end



--------------------------------------------------------------------
-- GC
if MODULE_GC_SERVER then
	-- GC分配一个QQShow激活码
	function tbQQShow:QQShowAllocateSN(szPlayerName)
		local nCurrSNCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_QQSHOW);
		if (nCurrSNCount >= self.QQSHOWNUMBER_PERSERVER) then
			-- 通知GS不能分配了
			GlobalExcute({"SpecialEvent.tbQQShow:QQShowAllocateResult", szPlayerName});
		else
			KGblTask.SCSetDbTaskInt(DBTASD_EVENT_QQSHOW, nCurrSNCount + 1);
			-- 通知GS分配了一个
			GlobalExcute({"SpecialEvent.tbQQShow:QQShowAllocateResult", szPlayerName, nCurrSNCount + 1});
		end
	end
end
