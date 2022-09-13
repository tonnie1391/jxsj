
function Player:SetMaxLevelGC()
	local tbData = Lib:LoadTabFile("\\setting\\player\\setmaxlevel.txt");
	if (not tbData) then
		print("Khong tim thay "..szClassList.." tab file!");
		return	0;
	end
	local tbContent = {};
	for _, tbRow in ipairs(tbData) do
		local nGetOpenDay = tonumber(tbRow.DATE) or 0;
		local nGetMaxLevel = tonumber(tbRow.MAX_LEVEL) or 0;
		tbContent[nGetOpenDay]	= nGetMaxLevel;
	end
	local nTimeOpenServer = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nOpenDay = math.floor((GetTime() - nTimeOpenServer) / (3600 * 24));
	local nOffset = 0;
	for i = 1, #tbContent do
		if nOpenDay == 0 then
			nOffset = 60;
			break;
		elseif nOpenDay == i then
			nOffset = tbContent[i]
			break;
		elseif i == #tbContent then
			nOffset = tbContent[#tbContent];
			break;
		end
	end 
	
	if nOffset >= 150 then
		if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL150) == 0 then
			KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL150, GetTime());
		end
		if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL99) == 0 then
			KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL99, GetTime());
		end
		if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL89) == 0 then
			KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL89, GetTime());
		end
		if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL79) == 0 then
			KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL79, GetTime());
		end				
		if KGblTask.SCGetDbTaskInt(DBTASK_STONE_FUNCTION_OPENDAY) == 0 then
			Item.tbStone:SetOpenDay(GetTime());
		end			
		-- 判断是否发送宝石系统邮件
		if (Item.tbStone.IsOpen == 1) then		-- 确定系统已经开启了
			if (KGblTask.SCGetDbTaskInt(DBTASK_STONE_MAIL_SENDFLAG) == 0) then	-- 确保只发送一次
				KGblTask.SCSetDbTaskInt(DBTASK_STONE_MAIL_SENDFLAG, 1);
				Item.tbStone:StoneSendMail();
			end
		end
		if SpecialEvent.tbModuleSwitch.tbSwitchState["fightpower"] and
			SpecialEvent.tbModuleSwitch.tbSwitchState["fightpower"].nState == 1 then
			Player.tbFightPower:OnOpenFightPower();
		end
		Dbg:WriteLog("Player","Cap do toi da: "..nOffset);
		GlobalExcute({"Player:SetMaxLevelGC2GS", nOffset});
		GlobalExcute({"Player.tbOffline:OnUpdateLevelInfo"});
		Task.tbHelp:UpdateLevelOpenTimeNews(DBTASD_SERVER_SETMAXLEVEL150, 150);
		Wlls:SetOpenNews();
		return 0;
	end
	
	if nOffset >= 99 then
		KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL150, 0);		
		if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL99) == 0 then
			KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL99, GetTime());
		end
		if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL89) == 0 then
			KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL89, GetTime());
		end
		if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL79) == 0 then
			KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL79, GetTime());
		end
		if KGblTask.SCGetDbTaskInt(DBTASK_STONE_FUNCTION_OPENDAY) == 0 then
			Item.tbStone:SetOpenDay(GetTime());
		end	
		-- 判断是否发送宝石系统邮件
		if (Item.tbStone.IsOpen == 1) then		-- 确定系统已经开启了
			if (KGblTask.SCGetDbTaskInt(DBTASK_STONE_MAIL_SENDFLAG) == 0) then	-- 确保只发送一次
				KGblTask.SCSetDbTaskInt(DBTASK_STONE_MAIL_SENDFLAG, 1);
				Item.tbStone:StoneSendMail();
			end
		end
		if SpecialEvent.tbModuleSwitch.tbSwitchState["fightpower"] and
			SpecialEvent.tbModuleSwitch.tbSwitchState["fightpower"].nState == 1 then
			Player.tbFightPower:OnOpenFightPower();
		end
		Dbg:WriteLog("Player","Cap do toi da: "..nOffset);
		GlobalExcute({"Player:SetMaxLevelGC2GS", nOffset});
		GlobalExcute({"Player.tbOffline:OnUpdateLevelInfo"});
		Task.tbHelp:UpdateLevelOpenTimeNews(DBTASD_SERVER_SETMAXLEVEL99, 99);
		return 0;
	end
	
	if nOffset >= 89 then
		KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL99, 0);
		KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL150, 0);
		if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL89) == 0 then
			KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL89, GetTime());
		end
		if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL79) == 0 then
			KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL79, GetTime());
		end
		if KGblTask.SCGetDbTaskInt(DBTASK_STONE_FUNCTION_OPENDAY) == 0 then
			Item.tbStone:SetOpenDay(GetTime());
		end	
		-- 判断是否发送宝石系统邮件
		if (Item.tbStone.IsOpen == 1) then		-- 确定系统已经开启了
			if (KGblTask.SCGetDbTaskInt(DBTASK_STONE_MAIL_SENDFLAG) == 0) then	-- 确保只发送一次
				KGblTask.SCSetDbTaskInt(DBTASK_STONE_MAIL_SENDFLAG, 1);
				Item.tbStone:StoneSendMail();
			end
		end
		Dbg:WriteLog("Player","Cap do toi da: "..nOffset);
		GlobalExcute({"Player:SetMaxLevelGC2GS", nOffset});
		GlobalExcute({"Player.tbOffline:OnUpdateLevelInfo"});
		Task.tbHelp:UpdateLevelOpenTimeNews(DBTASD_SERVER_SETMAXLEVEL89, 89);
		return 0;
	end
	
	if nOffset >= 79 then
		KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL89, 0);
		KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL99, 0);
		KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL150, 0);
		if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL79) == 0 then
			KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL79, GetTime());
		end
		if KGblTask.SCGetDbTaskInt(DBTASK_STONE_FUNCTION_OPENDAY) == 0 then
			Item.tbStone:SetOpenDay(GetTime());
		end	
		-- 判断是否发送宝石系统邮件
		if (Item.tbStone.IsOpen == 1) then		-- 确定系统已经开启了
			if (KGblTask.SCGetDbTaskInt(DBTASK_STONE_MAIL_SENDFLAG) == 0) then	-- 确保只发送一次
				KGblTask.SCSetDbTaskInt(DBTASK_STONE_MAIL_SENDFLAG, 1);
				Item.tbStone:StoneSendMail();
			end
		end
		Dbg:WriteLog("Player","Cap do toi da: "..nOffset);
		GlobalExcute({"Player:SetMaxLevelGC2GS", nOffset});
		GlobalExcute({"Player.tbOffline:OnUpdateLevelInfo"});
		Task.tbHelp:UpdateLevelOpenTimeNews(DBTASD_SERVER_SETMAXLEVEL79, 79);
		return 0;
	end
	
	KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL150, 0);
	KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL99, 0);
	KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL89, 0);
	KGblTask.SCSetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL79, 0);
	Dbg:WriteLog("Player","Cap do toi da: "..nOffset);
	GlobalExcute({"Player:SetMaxLevelGC2GS", nOffset});
	return 0;
end

function Player:SetMaxLevelGC2GS(nMaxLevel)
	-- if KPlayer.GetMaxLevel() < nMaxLevel then
		KPlayer.SetMaxLevel(nMaxLevel);
		Dbg:WriteLog("Player","Cap do toi da: "..nMaxLevel);
	-- end
end

function Player:SetMaxLevelGS()
	local tbData = Lib:LoadTabFile("\\setting\\player\\setmaxlevel.txt");
	if (not tbData) then
		print("Khong tim thay "..szClassList.." tab file!");
		return	0;
	end
	local tbContent = {};
	for _, tbRow in ipairs(tbData) do
		local nGetOpenDay = tonumber(tbRow.DATE) or 0;
		local nGetMaxLevel = tonumber(tbRow.MAX_LEVEL) or 0;
		tbContent[nGetOpenDay]	= nGetMaxLevel;
	end
	local nTimeOpenServer = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nOpenDay = math.floor((GetTime() - nTimeOpenServer) / (3600 * 24));
	local nOffset = 0;
	for i = 1, #tbContent do
		if nOpenDay == i then
			nOffset = tbContent[i]
			break;
		else
			nOffset = tbContent[#tbContent]
		end
	end
	
	-- if KPlayer.GetMaxLevel() < nOffset then
		KPlayer.SetMaxLevel(nOffset)
		Dbg:WriteLog("Player","Cap do toi da: "..nOffset); 
	-- end
	
	return 0;
end
