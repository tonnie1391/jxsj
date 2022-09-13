-------------------------------------------------------------------
--File: mappedgmcmd_gc.lua
--Author: zouying
--Date: 2009-07-06 21:08
--Describe: eyes发送过来的key执行gmcmd
-------------------------------------------------------------------

GmCmd.tbCompensateTaskId = {};	--存储已执行过的补偿任务结果，key为taskId,value为执行结果
GmCmd.tbEyesKey2GcFun = {
	["TEST"]					= {},										--测试
	["LoadScript"]				= {},										--指令
	["GetGCPlayerBaseInfo"]		= {"szName"},									--获得角色GC数据
	["GetGSPlayerInfo"]			= {"szName"},									--获得角色GS数据
	["GetKinInfo"]				= {},										--获得家族数据
	["GetTongInfo"]				= {},										--获得帮会数据
	["QueryTongInfo"]			= {"nMode", "szCmd", "szCompare", "szData"},--查找帮会（高级模式）
	["QueryKinTongOfRole"]		= {},										--获得角色家族和帮会
	["QueryServerInfo"]			= {},										--查询服务器信息(简)
	["QueryServerInfo2"]		= {},										--查询服务器信息(详)
--	["CompensateToRole"]		= {"szRoleName", "tbItem", "nTimeLimit",	
--		"nNum", "nBind", "nMoney", "nBindMoney", "nBindCoin", "szDesc", "taskId"},--角色补偿(关闭该功能，使用文件模式)
	["SendMail"]				= {"szName", "szTitle", "szContent"},										--发邮件
	["OpenIBReturn"]			= {"S", "E", "nType"},						--金币消费返还
	["LoadKingEyesEventFile"]	= {},										--加载在线运营活动
	--["GetWareSaleStatus"]		= {},										--奇珍阁查看哪些物品被强制下架了
	--["CancelWareSaleStatus"]	= {};										--奇珍阁强制下架
	--["AddWareSaleStatus"]		= {};										--奇珍阁恢复上架
	["CompensateToRoleFile"]	= {"szPath", "nTaskId"},					--通过文件给角色补偿
	["GetKingEyesEvent"]		= {},										--获得开启的存档活动
	["CloseKingEyesEvent"]		= {"nEventId", "nPartId"},					--关闭某个活动
	["LoadIllegalListFile"]		= {"szPath", "szIndex"},					--通过文件非法物品扣除
	["BatchArrest"]				= {"szDataPath", "bArrest"},				--批量关天牢
	["BatchMail"]				= {"szDataPath", "szTitle", "szContent"},	--批量发邮件
	["SetVipTransRate"]			= {"szPlayerName", "nRate", "szAccount", "szGateway"},
	["ActiveJbReturn"]			= {"szPlayerName", "nMonLimit", "nSpecial", "szCurName"},	--设置内部优惠
	["UnfreezePlayer"]			= {"szPlayerName"},
	["LoadQuestFile"]			= {"szPath", "szPlayerListPath"},			--加载调查问卷（通过名单）
	["Openbaihutang"]			= {"S", "E", "nCount"},						--白虎堂双倍
	["Openbattle"]				= {"S", "E", "nCount"},						--战场双倍
	["QueryKinPlayerInfo"]		= {"szName"},								--查询家族成员		
	["QueryMarryInfo"]			= {"nDate", "nEndDate"},					--查询结婚列表
	["QueryWllsLeagueForLName"]	= {"szLeagueName", "nDate"},				--查询联赛战队信息（通过战队名）
	["QueryWllsLeagueForMName"]	= {"szMemberName", "nDate"},				--查询联赛战队信息（通过成员名）
	["QueryIbshopBuffInfo"]		= {},										--查询奇珍阁在线指令的buff
	["SetAllIbWareDiscount"]	= {"nNeedCurrencyType", "nDiscount", "szStartTime", "szEndTime"},--设置所有奇珍阁商品打折
	["SetOneIbWareDisCount"]	= {"nWareId", "nDiscount", "szStartTime", "szEndTime"},			 --设置一个奇珍阁商品打折
	["UpGoods"]					= {"nWareId", "szSellStartDate", "szSellEndTime", "nTimeFrame"}, --对单个商品上架
	["DownGoods"]				= {},										--对单个商品下架
	["ClearIbshopBuff"]			= {},										--清除在线指令的buff
	["QueryCompensateByName"]	= {"szName"},								--查询补偿信息
	["ClearCompensateByName"]	= {"szName", "nLogId"},						--清除补偿
	["SetIbShopGoodsNewUp"]		= {},										--设置商品在新品上架中（维持一个月，未上架物品将直接上架，受时间轴影响商品仍然有效）
	["QueryJBExchangeRate"]		= {},										--查询金币交易所汇率	
	["SetOneIbWarePrice"]		= {"nWareId", "nPrice"},					--设置一个奇珍阁商品价格
	["LoadPresendCardFile"]		= {},										--定制礼包执行文件		
	["DelPresendCardBuf"]		= {},										--删除礼包
	["QueryPresendCardBuf"]		= {},										--定制礼包查询
	["AddNewBatchMail"]			= {"szTitle", "szContent", "nEndTime" },	--新增批量邮件	
	["QueryShowLadder"]			= {"nType1", "nType2", "nType3"},			--查询排行榜显示榜（经典模式）
	["QueryHonorLadder"]		= {"nType1", "nType2", "nType3", "szName"},	--查询排行榜荣誉榜（列表模式）										
	["ClearGCStartData"]		= {},										--清除GC启动数据（新服提前试开清档使用）
	["QueryGcStartDataBak"]		= {},										--查询执行清档指令前的备份数据列表
	["RepairGcStartData"]		= {},										--根据备份数据进行还原
	["ModifyWorldCupLevel"]		= {},										-- 修改世界杯各个球队的成绩	
	["GoldBarIpList"]			= {"szDataPath"},							--金牌网吧上传iplist表
	["AddGoldBarIp"]			= {"szIp"},									--金牌网吧增加ip段或者ip值
	["DelGoldBarIp"]			= {"szIp"},									--金牌网吧删除ip段或者ip值
	["QueryGoldBarIp"]			= {"szIp"},									--金牌网吧查询ip
	["ApplyChangeAccount"]		= {"szName", "oldszAccount", "szAccount", "szAccountRe"},	--申请角色转账号
	["ApplyChangeAccountFile"]		= {"szDataPath"},								--申请角色转账号
	--["OpenXLandBattle"]			= {},										--手动开启或者关闭铁浮城战。(旧版)
	--["SetXLandBattleState"]		= {},										--设置铁浮城战阶段(旧版)
	["OpenNewXLandBattle"]		= {},										--手动开启或者关闭铁浮城战。(新版)
	["ChenmiSwitch"]			= {},										--防沉迷开关
	["YouLongGeSwitch"]			= {},										--游龙阁10次次数限制开关	
	["SetWeiWangTimes"]			= {},										--设置江湖威望倍率
	["Openfactionbattle"]		= {"S", "E", "nCount"},						--设置门派竞技积分换奖励倍率
	["Openkingamecoin"]			= {"S", "E", "nCount"},						--设置家族关卡铜钱倍率
	["Opendomainbattle"]		= {"S", "E", "nCount"},						--设置领土征战奖励倍率
	["Opencangbaotu"]			= {"S", "E", "nCount"},						--设置藏宝图奖励倍率
	["Openxoyogamecard"]		= {"S", "E", "nCount"},						--设置逍遥谷开卡奖励倍率
	["OldPlayer2NewGate"]		= {"szDataPath"},							--老玩家回归  转新服
	["OldPlayerBack"]			= {"szDataPath"},							--老玩家回归  留在老服
	["TaobaoCooperate"]			= {"szDataPath"},							--淘宝合作活动
	["TaobaoSwitch"]			= {},										--淘宝合作活动开关
	["QueryTaobaoCode"]		= {},											--查询淘宝剩余码
	["LaXin2010ReadFile"]		= {"szDataPath"},							--拉新活动
	["TaskPlatformFabu"]		= {"nType", "nCount", "nGrade"},			--官方发布经验平台任务
	["QueryLaXin2010Card"]		= {},										--查询拉新卡密库存
	["DelLaXin2010Card"]		= {"nType", "nCount"},						--删除拉新卡密库存
	["ExecuteAutoDoCommand"]	= {"szName", "nEndDate", "szScript"},		--执行服务器自动重启的指令
	["QueryAutoDoCommand"]		= {},										--查询服务器自动重启的指令
	["ClearAutoDoCommand"]		= {},										--清除所有服务器自动重启的指令
	["DelAutoDoCommand"]		= {},										--删除一条服务器自动重启的指令
	["GMAddOnLine"]				= {"szName", "nStartDate", "nEndDate", "szScript", "szInfo"},--GM指令移植，玩家离线指令
	["GMAddOnNpc"]				= {"szName", "nStartDate", "nEndDate", "szItem",
								"nItemTime", "nCount", "nBind", "nNeedFreeBag",
								"nMoney", "nBindMoney", "nBindCoin", "szDesc", "szScript"},--GM指令移植，让玩家自行领取
	["Msg2WorldByChat"]			= {},										--GM指令移植，发公告(聊天栏)
	["Msg2WorldByNews"]			= {},										--GM指令移植，发公告(屏幕上方)
	["OpenJBExChange"]			= {"nOpen"},								--GM指令移植， 金币交易所操作
	["UpdateLadder"]			= {},										--GM指令移植，更新排行榜
	["SetStartServerTime"]		= {"nDate"},								--GM指令移植，设置开服时间
	["KickPlayerOnLine"]		= {"szName"},								--GM指令移植，在线踢人
	["ArrestPlayerOnLine"]		= {"szName"},								--GM指令移植，抓入天牢
	["SetFreePlayerOnLine"]		= {"szName"},								--GM指令移植，从天牢释放
	["OpenEventCompensate"]		= {"szTitle", "szDesc", "nStartDate", "nEndDate", "nLevel", "nExpMin", "nBindMoney", "nFuDaiCount"},										--GM模板，补偿通用设置
	["GetEventCompensate"]		= {},										--GM模板，补偿通用查询
	["CloseEventCompensate"]	= {},										--GM模板，补偿通用关闭
	["QueryKinMemberInfo"]		= {"szName", "nMode"},						--家族成员活动信息查询
	["QueryKinDailyInfo"]		= {"nDate", "nSRank", "nERank"},			--家族成员活动信息查询
	["KEAddNpc"] 				= {"nNpcId", "szName", "nMapId", "nPosX", "nPosY", "nLiveTime"},	--KE Addnpc
	["QueryAddNpc"]			= {},											--查询已经加的npc
	["KEDelNpc"]				= {"nKey"},									--删除加的npc				
	["DoGcCmd"]					= {"szCmd"},								--执行GC指令
	["DoGsCmd"]					= {"szCmd", "szGcCallBack"},				--执行GS指令
	["DoPlayerGsCmd"]			= {"szName", "szCmd"},						--执行针对玩家的GS脚本
	["DoPlayerClientCmd"]		= {"szName", "szCmd"},						--执行针对玩家的Client脚本
	["UpLoadServerListCfg"]		= {"szPath"},								--上传更新ServerList列表
	["ReloadPackServerListCfg"]	= {},										--重载包内服务器列表配置
	["OpenJBTransactions"]		= {"nOpen"},								--金币交易开关
	["OpenAuctionJBTransactions"]={"nOpen"},								--拍卖行金币交易开关
	["OpenKuaFuBaiHuTang"]		= {"nOpen"},								--跨服白虎堂开关
	["OpenGlbWlls"]				= {"nOpen"},								--增加跨服联赛开关
	["LoadPlayerActionKind"]	= {"szPath"},								--设置玩家行为类型（正常或工作室等类型）
	["QueryPlayerActionKind"]	= {"szName"},								--查询玩家行为类型
	["SetPlayerActionKind"]		= {"szName", "nKind"},						--设置玩家行为类型
	["AddNewHelpMsg"]		= {"szTitle", "szMsg", "nAddTime", "nEndTime"},	--添加帮助最新消息
	["DelNewHelpMsg"]			= {"nKey"},								--删除最新消息
	["QueryNewHelpMsg"]		= {},										--查询最新消息
	["SetJingHuoFuLi"]			= {"szPath"},								--删除最新消息
	["QueryJingHuoFuLi"]		= {},										--查询最新消息
	["OpenGoldenGbWlls"]		= {"nOpen"},								--金币交易开关
	["OpenTimeframe"]		= {"nOpen"},									--加速版时间轴开关
	["OpenEnhanceSixteen"]		= {"nOpen"},								--关闭强16开关
	["OpenIbShopLimit"]		= {"nOpen"},								--ibshop无时间轴限制开关
	["SetPartnerExpBookCountFile"]			= {"szPath"},						--设置每天使用同伴经验书的数量批量
	["SetPartnerExpBookCount"]			= {"nCount"},						--设置每天使用同伴经验书的数量
	["QueryPartnerExpBookCount"]		= {},									--查询每天使用同伴经验书的数量
	["SetArrestPartnerBookCountFile"]			= {"szPath"},					--设置每天使用镶边帛帖的数量批量
	["SetArrestPartnerBookCount"]			= {"nCount"},						--设置每天使用镶边帛帖的数量
	["QueryArrestPartnerBookCount"]		= {},								--查询每天使用镶边帛帖的数量
	["ClearXoYoGameRank"] = 	{"nLevel"},										--清空逍遥谷排名
	["QueryShiwuJiang"]		= {"nType", "nDate"},								--查询实物奖励
	["ClearShiwuJiang"]		= {"nType", "nDate"},								--清除实物奖励
	["CreatRoleAward"]		= {"nDate", "szAward"},								--创建角色奖励
	["QueryRoleAward"]		= {},												--查询创建角色奖励
	["CreatKinDiscount"]	= {"nDate", "nDiscount"},								--创建家族优惠折扣
	["QueryKinDiscount"]	= {},												--查询创建家族优惠折扣
	["OpenFuliJIngHuo"]	= {"S", "E"},										--开启福利精活额外购买
	["QueryNameServerModifyList"] = {},				-- 查询等纠正的网关名列表
	["ExcuteNameServerModify"] = {"szOldGate", "szNewGate", "szRole"},				-- 执行网关纠正操作
	["LoadGirlList"]		= {"szPath"},										-- load美女决赛名单
	["LoadGirlLogo"]		= {"szPath"},										-- load美女认证logo
	["OpenKinPlant"]				= {"S", "E", "nCount"},						--家族种植翻倍
	["SendKinMail"]				= {"szKin", "szTitle", "szContent"},				--家族发邮件
	["SendKinListMail"]				= {"szPath", "szTitle", "szContent"},				--批量家族发邮件
	["BatchMsg"]			= {"szPath"},
	["BatchPlayerMail"]			= {"szPath"},
	["SetOlympicGameInfo"]		= {"nDay", "nGold", "nSliver", "nBonze"},			--设定奥运活动奖牌信息
	["ClearGirlVoteTitle"]		= {"szPlayerName", "szMsg"},			--清楚掉美女特殊标志及永久取消美女资格
	["LoadGlobalAreaCityer"]	= {"szPath"},										-- 加载战区城主数据
	["OpenGumuZhuXiu"]			= {"nOpen"},								--古墓派主修开关
	["OpenGumuFuXiu"]			= {"nOpen"},								--古墓派辅修开关
	["OpenGumuFuXiuTask"]		= {"nOpen"},								--古墓派辅修任务开关
};

GmCmd.tbCallBack	= GmCmd.tbCallBack or {};

function GmCmd:RegGSCall(szGcCallBack)
	local tbCall	= self.tbCallBack[0];
	assert(tbCall);	-- 一个函数两次调用CallGS？
	
	assert(self[szGcCallBack]);
	
	self.tbCallBack[0]	= nil;
	
	tbCall.szGcCallBack	= szGcCallBack;
	tbCall.nGsDataCount	= 0;
	tbCall.tbGsData		= {};

	local nRegId		= (self.nCallBackId or 0) + 1;
	self.nCallBackId	= nRegId;
	self.tbCallBack[nRegId]	= tbCall;
	
	if (not self.nGsCount) then	-- 尚未读取GS个数
		local tbData = Lib:LoadIniFile("gc_config.ini");
		if not tbData or type(tbData.Init) ~= "table" or not tonumber(tbData.Init.ServerCount) then
			tbData = Lib:LoadIniFile("\\setting\\hostset.ini")
		end
		
		if tbData and type(tbData.Init) == "table" and tonumber(tbData.Init.ServerCount) then
			self.nGsCount	= tonumber(tbData.Init.ServerCount);
		end
	end
	
	tbCall.nTimerId	= Timer:Register(Env.GAME_FPS * 5, "GmCmd:OnTimeOut", nRegId);	-- 开启超时计算
	
	return nRegId;
end

function GmCmd:CallGS(szGcCallBack, ...)
	local nRegId = self:RegGSCall(szGcCallBack);
	GlobalExcute({"GmCmd:OnCallGS", nRegId, ...});
end

function GmCmd:OnCallGC(nRegId, nServerId, ...)
	local tbCall	= self.tbCallBack[nRegId];
	assert(tbCall);
	assert(not tbCall.tbGsData[nServerId]);
	
	tbCall.tbGsData[nServerId]	= arg;
	tbCall.nGsDataCount			= tbCall.nGsDataCount + 1;
	
	if (tbCall.nGsDataCount	>= self.nGsCount) then
		local function fnCall()
			return self[tbCall.szGcCallBack](self, tbCall.tbGsData);
		end
		local nOk, szRet	= self:PCall(fnCall);
		
		ReportGmCmdResult(tbCall.nSession, 1, tbCall.nAsker, (nOk == 1 or 0) and 1, szRet);
		
		Timer:Close(tbCall.nTimerId);
		self.tbCallBack[nRegId]	= nil;
	end
end

function GmCmd:OnTimeOut(nRegId)
	local tbCall	= self.tbCallBack[nRegId];
	for nServerId = 1, self.nGsCount do
		if (not tbCall.tbGsData[nServerId]) then	-- 尚未收到此GS回调
			self:OnCallGC(nRegId, nServerId, false, "Time out!");	-- 模拟GS回调
			if (not self.tbCallBack[nRegId]) then	-- 已完成所有GS返回模拟
				break;
			end
		end
	end
	assert(not self.tbCallBack[nRegId]);	-- 应该已经完成了
end

function GmCmd:CGS_All(tbGsData)
	local szRet	= "";
	for nGsId, tb in pairs(tbGsData) do
		if (tb[1] and tb[3] > 0) then
			-- 因为table.concat不支持table中间存在“洞”，所以要自己写循环处理
			szRet	= szRet .. string.format("[GS_%d]: %s", nGsId, tostring(tb[2][1]));
			for i = 2, tb[3] do
				szRet	= szRet .. "\t" .. tostring(tb[2][i]);
			end
			szRet	= szRet .. "\n";
		end
	end
	return szRet .. "\n" .. self:CGSErrInfo(tbGsData);
end

function GmCmd:CGS_PLAYER(tbGsData)
	local szRet	= "";
	for nGsId, tb in pairs(tbGsData) do
		if (tb[2]) then	-- 有信息，无论是否成功
			local szData = "";
			if (tb[1]) then	-- 成功
				for i = 1, tb[3] do
					szData	= szData .. "\t" .. tostring(tb[2][i]);
				end
				if (szData == "") then
					szData = "(null)";
				else
					szData = string.sub(szData, 2);
				end
			else
				szData = string.format("Failed:\n%s\n", tostring(tb[2]));
			end
			szRet	= szRet .. string.format("[GS_%d]: %s\n", nGsId, szData);
		end
	end
	if (szRet == "") then
		szRet = "(player not found)";
	end
	return szRet;
end

function GmCmd:CGS_Sum(tbGsData)
	local nRet	= 0;
	for nGsId, tb in pairs(tbGsData) do
		if (tb[1]) then
			nRet	= nRet + (tonumber(tb[2][1]) or 0);
		end
	end
	return nRet .. "\n" .. self:CGSErrInfo(tbGsData);
end

function GmCmd:CGS_Cat(tbGsData)
	local szRet	= "";
	for nGsId, tb in pairs(tbGsData) do
		if (tb[1] and tb[3] > 0) then
			szRet	= szRet .. tostring(tb[2][1]);
		end
	end
	return szRet .. "\n" .. self:CGSErrInfo(tbGsData);
end

function GmCmd:CGSErrInfo(tbGsData)
	local szErrInfo	= "";
	local tbData	= {};
	for nGsId, tb in pairs(tbGsData) do
		if (not tb[1]) then	-- 此GS执行失败
			szErrInfo	= szErrInfo .. string.format("[GS_%d] Failed:\n%s\n", nGsId, tostring(tb[2]));
		end
	end
	return szErrInfo;
end

function GmCmd:DoMappedExeCmd(szCmdKey, szData, nSession, nAsker)
	if (type(szCmdKey) ~= "string") then
		return 0, "the cmdkey is not string";
	end
	
	local tbParamDef = self.tbEyesKey2GcFun[szCmdKey];
	if (not tbParamDef) then
		print("Wrong Key To Mapped Commod ", szCmdKey);
		return 0, "There is not the function of the key " .. szCmdKey;
	end
	
	local fnCmdFunc		= self[szCmdKey];
	if type(fnCmdFunc) ~= "function" then
		return 0, "it does not find function " .. szCmdKey;
	end
	
	local varData	= szData;
	if (tbParamDef[1]) then	-- 有参数定义
		-- TODO: 这里对平台发来的字符串直接loadstring！！！
		local fnGetTb, szErrorMsg	= loadstring("return "..szData);
		if (not fnGetTb) then
			return 0, szErrorMsg;
		end
		
		varData	= fnGetTb();	
		-- 参数检查
		if (type(varData) ~= "table") then
			return "Param format error! Table expected!";
		end
		for _, szParamDef in ipairs(tbParamDef) do
			if (not varData[szParamDef]) then
				return "Param ["..szParamDef.."] is missing!"
			end
		end
	end
	
	local function fnCall()
		return fnCmdFunc(self, varData);
	end
	
	self.tbCallBack[0]	= {
		nSession	= nSession,
		nAsker		= nAsker,
	};
	
	local nOk, szRet	= self:PCall(fnCall);
	
	if (not self.tbCallBack[0]) then	-- 中途已经调用CallGS
		return -1;
	end
	
	self.tbCallBack[0]	= nil;
	
	return nOk, szRet;
end

function GmCmd:TEST(szData)
	print('hello world!!!!')
	return "test OK"
end

function GmCmd:LoadScript(szFile)
	print('LoadScript:', szFile);
	
	local szFileData	= KFile.ReadTxtFile(szFile);
	if (not szFileData) then
		local szMsg	= string.format("cannot read file (%s)!", szFile);
		return 0, szMsg;
	end
	
	return assert(loadstring(szFileData, "@" .. szFile))();
end

-- 【查询玩家GC信息】
function GmCmd:GetGCPlayerBaseInfo(tbParam)
	local nPlayerId	= KGCPlayer.GetPlayerIdByName(tbParam.szName);
	if (not nPlayerId) then
		return "nil";
	end
	local tbInfo	= GetPlayerInfoForLadderGC(tbParam.szName);
	local tbText	= {
		{"角色名", tbParam.szName},
		{"账号", tbInfo.szAccount},
		{"等级", tbInfo.nLevel},
		{"性别", (tbInfo.nSex == 1 and "女") or "男"},
		{"门派路线", Player:GetFactionRouteName(tbInfo.nFaction, tbInfo.nRoute)},
		{"家族", tbInfo.szKinName},
		{"帮会", tbInfo.szTongName},
		{"江湖威望", KGCPlayer.GetPlayerPrestige(nPlayerId)},
		{"离开家族时间", os.date("%Y-%m-%d %H:%M:%S", KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_LEAVE_KIN_TIME))},
		{"在线GameserverID", KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_ONLINESERVER)},
		{"股份资产", KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_TONGSTOCK)},
		{"官衔等级", KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_OFFICIAL_LEVEL)},
	}
	local szMsg	= "";
	for _, tb in ipairs(tbText) do
		szMsg	= szMsg .. "\n" .. tb[1] .. "\t" .. tostring(tb[2]);
	end
	return szMsg;
end

-- 【查询玩家GS信息】
function GmCmd:GetGSPlayerInfo(tbParam)
	print("tbParam", type(tbParam), tbParam)
	Lib:ShowTB(tbParam);
	self:CallGS("CGS_All", "GmCmd:GetPlayerInfo_GS", tbParam.szName);
end

-- 【查询家族信息】
function GmCmd:GetKinInfo(szName)
	local pKin, nKinId	= KKin.FindKin(szName);
	if (not pKin) then
		return "nil";
	end
	local nAssId = pKin.GetAssistant() or 0;
	local szAssName = "nil";
	if nAssId > 0 then
		szAssName = pKin.GetMemberName(nAssId);
	end
	local tbWeeklyAction = { "白虎堂", "宋金战场", "通缉任务", "逍遥谷", "军营副本", };
	local nRegular, nSigned, nRetire, nCaptain, nAssistant	= pKin.GetMemberCount();
	local pTong = KTong.GetTong(pKin.GetBelongTong());
	local tbText	= {
		{"家族名", pKin.GetName()},
		{"所属帮会", (pTong and pTong.GetName()) or "nil"},
		{"族长", pKin.GetMemberName(pKin.GetCaptain())},
		{"副族长", szAssName},
		{"创建时间", os.date("%Y-%m-%d %H:%M:%S", pKin.GetCreateTime())},
		{"申请退出帮会的时间", os.date("%Y-%m-%d %H:%M:%S", pKin.GetApplyQuitTime())},
		{"正式成员数", nRegular},
		{"记名成员数", nSigned},
		{"荣誉成员数", nRetire},
		{"百家评选活动积分", pKin.GetHundredKinScore()},
		{"家族ID",	nKinId or 0},
		{"帮会ID",	pKin.GetBelongTong() or 0},
	};
	local szMsg	= "";
	for _, tb in ipairs(tbText) do
		szMsg	= szMsg .. "\n" .. tb[1] .. "\t" .. tostring(tb[2]);
	end
	return szMsg;
end

-- 【查询帮会信息】
function GmCmd:GetTongInfo(szName)
	local pTong, nTongId	= KTong.FindTong(szName);
	if (not pTong) then
		return "nil";
	end
	local tbKin	= {};
	local pKinIt	= pTong.GetKinItor();
	local nKinId 	= pKinIt.GetCurKinId();
	while nKinId > 0 do
		local pKin 	= KKin.GetKin(nKinId);
		tbKin[#tbKin + 1]	= pKin.GetName();
		nKinId 	= pKinIt.NextKinId();
	end
	local pMasterKin	= KKin.GetKin(pTong.GetMaster());
	local pPresidenKin	= KKin.GetKin(pTong.GetPresidentKin());
	local tbText	= {
		{"帮会名", pTong.GetName()},
		{"帮主", pMasterKin.GetMemberName(pMasterKin.GetCaptain())},
		{"首领", (pPresidenKin and pPresidenKin.GetMemberName(pTong.GetPresidentMember())) or "nil"},
		{"创建时间", os.date("%Y-%m-%d %H:%M:%S", pTong.GetCreateTime())},
		{"包含家族", table.concat(tbKin, " ")},
		{"资金", pTong.GetMoneyFund()},
		{"建设资金", pTong.GetBuildFund()},
		{"分红比例", pTong.GetTakeStock()},
		{"主城编号", pTong.GetCapital()},
		{"军饷的总额度", pTong.GetDomainAwardAmount()},
		{"家族ID",	nKinId or 0},
		{"帮会ID",	nTongId or 0},		
	_};
	local szMsg	= "";
	for _, tb in ipairs(tbText) do
		szMsg	= szMsg .. "\n" .. tb[1] .. "\t" .. tostring(tb[2]);
	end
	return szMsg;
end

local tbCompare = 
{
	["Greater"] = function (varSelfData, varTagData)
		if varSelfData > varTagData then
			return 1;
		end
		return 0;
	end,
	["Less"] = function (varSelfData, varTagData)
		if varSelfData < varTagData then
			return 1;
		end
		return 0;
	end,
	["Equal"] = function (varSelfData, varTagData)
		if varSelfData == varTagData then
			return 1, varSelfData;
		end
		return 0;
	end,
	["Unequal"] = function (varSelfData, varTagData)
		if varSelfData ~= varTagData then
			return 1, varSelfData;
		end
		return 0;
	end
}


-- 【查找帮会】 nMode 1 重新查找 nMode 2 在上次结果内查找 
function GmCmd:QueryTongInfo(tb)
	local nMode, szCmd, szCompare, szData = tb.nMode, tb.szCmd, tb.szCompare, tb.szData;
	szCmd = "Get"..szCmd;		-- 这里拼一次指令，防止外面调用了写权限的指令 	
	local szRetMsg = "";
	local varData = tonumber(szData) or szData;
	
	if not tbCompare[szCompare] then
		return "搜索失败,条件无效!";
	end
	local fnCompare = tbCompare[szCompare];
	if nMode == 1 then
		self._tbQueryTongInfo = {};
		local pTong, nTongId = KTong.GetFirstTong()
		while (pTong) do
			local bRet, szMsg = self:_QueryTongInfo(pTong, nTongId, szCmd, fnCompare, varData);
				if bRet == 1 then
					table.insert(self._tbQueryTongInfo, {nTongId, szMsg})
					szRetMsg = szRetMsg..string.format("%s\t%s\n", pTong.GetName(), szMsg);
				elseif bRet == -1 then
					return szMsg;
				end
			pTong, nTongId = KTong.GetNextTong(nTongId);
		end
	elseif nMode == 2 then
		local tbLast = self._tbQueryTongInfo;
		self._tbQueryTongInfo = {};
		for _, tbTongInfo in ipairs(tbLast) do
			local pTong = KTong.GetTong(tbTongInfo[1]);
			if pTong then
				local bRet, szMsg = self:_QueryTongInfo(pTong, tbTongInfo[1], szCmd, fnCompare, varData);
				if bRet == 1 then
					table.insert(self._tbQueryTongInfo, {tbTongInfo[1], tbTongInfo[2].."\t"..szMsg})
					szRetMsg = szRetMsg..string.format("%s\t%s\n", pTong.GetName(), tbTongInfo[2].."\t"..szMsg);
				elseif bRet == -1 then
					self._tbQueryTongInfo = tbLast; -- 搜索失败回复上次结果
					return szMsg;
				end
			end
		end
	end
	return "搜索结果:\n"..szRetMsg;
end

function GmCmd:_QueryTongInfo(pTong, nTongId, szInfo, fnCompare, varData)
	local varSelfData;
	if Tong.tbQueryCmd[szInfo] then		-- 存在脚本获取的函数
		varSelfData = Tong.tbQueryCmd[szInfo](pTong, nTongId);
	elseif _KLuaTong[szInfo] then	-- 帮会对象现有的函数
		varSelfData = pTong[szInfo]();
	else
		return -1, string.format("索搜失败! %s 不是可以搜索的帮会属性", szInfo);
	end
	if type(varSelfData) ~= type(varData) then
		return -1, "条件中帮会属性的类型与条件的类型不匹配，属性类型为"..type(varSelfData);
	end
	if fnCompare(varSelfData, varData) == 1 then
		return 1, tostring(varSelfData);
	end
	return 0;
end


--功能：查询角色的家族帮会信息
--参数格式：角色名
--返回值格式：角色名(角色ID),家族信息(家族ID),帮会信息(帮会ID)
function GmCmd:QueryKinTongOfRole(szRoleName)
	local szPlayerName	= szRoleName;
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	local szMsg	= string.format("%s(%s)", szPlayerName, tostring(nPlayerId));
	if (not nPlayerId) then
		return szMsg;
	end
	local nKinId = KGCPlayer.GetKinId(nPlayerId);
	local pKin = KKin.GetKin(nKinId);
	szMsg	= szMsg .. string.format(", %s(%s)", (pKin and pKin.GetName()) or "nil", tostring(nKinId));
	if (not pKin) then
		return szMsg;
	end
	local nTongId	= pKin.GetBelongTong();
	local pTong		= KTong.GetTong(nTongId);
	szMsg	= szMsg .. string.format(", %s(%s)", (pTong and pTong.GetName()) or "nil", tostring(nTongId));
	return szMsg;
end

--功能：查询服务器信息
--参数格式：无参数
--返回值格式：区服ID,角色数量,开服时间,开放150级时间,联赛届数,领土战场次数,铁浮城战届数,铁浮城战阶段
function GmCmd:QueryServerInfo()
	local nOpen150	= KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL150);
	if (nOpen150 == 0) then
		nOpen150	= TimeFrame:GetTime("OpenLevel150");
	end
	local tbXklandPreiod = {
		[0]="关闭中",
		[1]="竞拍期",
		[2]="选择阵营期",
		[3]="战争期",
		[4]="休战期",
	}
	local nXLandPreiod = Xkland:GetPeriod();
	if Xkland:CheckIsOpen() ~= 1 then
		nXLandPreiod = 0;
	end
	
	local szMsg = string.format("%s,%s,%s,%s,%s,%s,%s,%s",
		GetGatewayName(),
		GetMaxPlayerId(),
		os.date("%Y-%m-%d", KGblTask.SCGetDbTaskInt(16)),
		os.date("%Y-%m-%d", nOpen150),
		Wlls:GetMacthSession(),
		KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO),
		Xkland:GetSession(),
		(tbXklandPreiod[nXLandPreiod] or "未知")
		);
		
	return szMsg;
end

--功能：查询服务器信息
--参数格式：无参数
--返回值格式：区服ID,角色数量,开服时间,开放150级时间,联赛届数,领土战场次数,铁浮城战届数,铁浮城战阶段
function GmCmd:QueryServerInfo2()
	local nOpen150	= KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL150);
	if (nOpen150 == 0) then
		nOpen150	= TimeFrame:GetTime("OpenLevel150");
	end
	local tbXklandPreiod = {
		[0]="关闭中",
		[1]="竞拍期",
		[2]="选择阵营期",
		[3]="战争期",
		[4]="休战期",
	}
	local nXLandPreiod = Xkland:GetPeriod();
	if Xkland:CheckIsOpen() ~= 1 then
		nXLandPreiod = 0;
	end
	
	local szMsg = string.format([[
网关: %s
角色数量: %s
开服时间: %s
150级开放时间: %s
联赛届数: %s
领土战届数: %s
铁浮城战届数: %s
铁浮城战阶段: %s]],
		GetGatewayName(),
		GetMaxPlayerId(),
		os.date("%Y-%m-%d", KGblTask.SCGetDbTaskInt(16)),
		os.date("%Y-%m-%d", nOpen150),
		Wlls:GetMacthSession(),
		KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO),
		Xkland:GetSession(),
		(tbXklandPreiod[nXLandPreiod] or "未知")
		);
		
	return szMsg;
end
--功能：对角色补偿
--参数格式：{ szRoleName=[[]], tbItem={g,d,p,l}, nTimeLimit=n, nBind=n, nNum=n, nMoney=n, nBindMoney=n, nBindCoin=n, szDesc=[==[]==], taskId=n }
--其中，szRoleName为string, tbItem为table, nTimeLimit为-1(不限时)或0(有效期30天), nNum为正整数, nBind为1(绑定)或0(不绑定)
--		nMoney,nBindMoney,nBindCoin均为>=0的整数, szDesc为string, taskId为整数,为eyes生成的补偿任务ID
--返回值格式：
function GmCmd:CompensateToRole(tb)
	local taskId = tb["taskId"];
	local szRoleName = tb.szRoleName;
	local tbValue = tb;
	tbValue.nNeedBag=0; --nNeedBag为0则自动判断背包
	--若以前已执行过则拒绝再次执行，并发送以前执行的结果
	local prevRet = GmCmd.tbCompensateTaskId[taskId];
	if prevRet then
		return "executed before: "..prevRet;
	end
	local ret = GM:AddOnNpc("", "", szRoleName, 0, 0, tbValue);
	if type(ret) == 'number' then
		GmCmd.tbCompensateTaskId[taskId] = ret;
	end
	return ret;
end


---- 强制下架 params=g,d,p,l, CurrencyType
--function GmCmd:CancelWareSaleStatus(params)
--	if not params then
--		return 0
--	end
--	return IbShop:SetWareStatus(params, 1)
--end
--
---- 恢复上架 params=g,d,p,l
--function GmCmd:AddWareSaleStatus(params)
--	if not params then
--		return 0;
--	end
--	return IbShop:SetWareStatus(params, 0)
--end
--
---- 查看哪些物品被强制下架了
--function GmCmd:GetWareSaleStatus()
--	local szMsg = IbShop:GetWareStatusList()
--	return szMsg
--end

--功能：给角色发邮件
--参数格式：角色名\t邮件标题\t邮件正文内容
--返回值格式：SendMailGC的返回值
function GmCmd:SendMail(tbData)
	local szName = tbData.szName;
	local szTitle = tbData.szTitle;
	local szContent = tbData.szContent;
	return SendMailGC(szName, szTitle, szContent);
end

--功能：开启"消费返还"促销活动
--参数格式：{S={0},E={1},nType={2}}
--S为开始时间，E为结束时间，格式为YYYYmmddHH。nType为1表示本月消费返还20%；为2表示本月前15000消费的金币返还15000金币,后消费的金币返还20%
function GmCmd:OpenIBReturn(tb)
	--检查返还类型
	if tb.nType ~= 1 and tb.nType ~= 2 then
		return "invalid IB Return type: "..tb.nType;
	end
	local tbEvent = {};
	local nEventId = 20;
	local nPartId = 1
	tbEvent[nEventId] = tbEvent[nEventId] or {};
	tbEvent[nEventId].tbPart = tbEvent[nEventId].tbPart or {};
	tbEvent[nEventId].tbPart[nPartId] = {};
	tbEvent[nEventId].tbPart[nPartId].szName = "消费返还";
	tbEvent[nEventId].tbPart[nPartId].szSubKind = "action_opentask";
	local nStartTime = Lib:GetDate2Time(tb.S);
	local nEndTime = Lib:GetDate2Time(tb.E);
	tbEvent[nEventId].tbPart[nPartId].nStartDate = tonumber(os.date("%Y%m%d%H%M", nStartTime));
	tbEvent[nEventId].tbPart[nPartId].nEndDate  = tonumber(os.date("%Y%m%d%H%M", nEndTime));
	tbEvent[nEventId].tbPart[nPartId].tbExParam = {string.format("OpenIBReturen:%s", tb.nType)};
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent);	
	return 1; 
end

function GmCmd:LoadKingEyesEventFile(params)
	local szPath = params;
	if EventManager.KingEyes:GCReloadEventByFile(szPath) == 0 then
		return "加载活动文件失败："..szPath;
	end
	return 1;
end

function GmCmd:CompensateToRoleFile(tbParam)
	local szPath	= tbParam.szPath;
	local nTaskId	= tonumber(tbParam.nTaskId) or 0;
	
	if nTaskId > 0 then
		--若以前已执行过则拒绝再次执行，并发送以前执行的结果
		local prevRet = GmCmd.tbCompensateTaskId[nTaskId];
		if prevRet then
			return "executed before: "..prevRet;
		end
	end
	local nLogId = SpecialEvent.CompensateGM:LoadFile(szPath,nTaskId);
	if nLogId == 0 then
		return "加载活动文件失败："..szPath;
	end
	
	GmCmd.tbCompensateTaskId[nTaskId] = nLogId;
	
	return nLogId;
end

function GmCmd:LoadIllegalListFile(tbParam)
	local nRet = SpecialEvent.HoleSolution:LoadBlackListToDataBase(tbParam.szPath, tbParam.szIndex);
	return nRet;
end

function GmCmd:GetKingEyesEvent(params)
	return EventManager.KingEyes:GetGblBufCurEffectString();
end

function GmCmd:CloseKingEyesEvent(tb)
	
	local nEId = tonumber(tb.nEventId) or 0;
	local nPId = tonumber(tb.nPartId) or 0;
	if EventManager.KingEyes:CloseEvent(nEId, nPId) == 0 then
		return "该活动不存在"; 
	end
	return 1;
end

function GmCmd:BatchArrest(tbParam)
	return GM.BatchArrest:ReadList(tbParam.szDataPath, tonumber(tbParam.bArrest));
end

function GmCmd:BatchMail(tbParam)
	return Mail.BatchMail:ReadList(tbParam.szDataPath, tbParam.szTitle, tbParam.szContent);
end

-- 设置转服资格
function GmCmd:SetVipTransRate(tbParam)
	local szPlayerName = tbParam.szPlayerName;
	local nRate = tonumber(tbParam.nRate) or 85;
	local szAccount = tbParam.szAccount or "";
	local szGateway = tbParam.szGateway or "";
	local szScript = string.format([[
		me.SetTask(2154, 1, %s);
		me.SetTaskStr(2154, 6, "%s");
		me.SetTaskStr(2154, 14, "%s");
	]], nRate, szAccount, szGateway);
	return GM:AddOnLine("", "", szPlayerName, 0, 0, szScript);
end

-- 设置内部优惠
function GmCmd:ActiveJbReturn(tbParam)
	local szPlayerName = tbParam.szPlayerName;
	local nMonLimit = tonumber(tbParam.nMonLimit);
	local nSpecial = tonumber(tbParam.nSpecial);
	local szCurName = tbParam.szCurName or "";
	local tbInfo = GetPlayerInfoForLadderGC(szPlayerName);
	if not tbInfo then
		return 0;
	end
	local szAccount = tbInfo.szAccount;
	local szScript = string.format("jbreturn:ActiveAccount(%s, %s, '%s');", nMonLimit, nSpecial, szCurName);
	if nMonLimit <= 0 then
		Account:SetAccountLimitIsUse(szAccount, 1);
	else
		Account:SetAccountLimitIsUse(szAccount, 0);
		if szCurName ~= "" and szCurName ~= "未设置" then
			Account:SetLimitAccountCurName(szAccount, szCurName)
		end
	end
	return GM:AddOnLine("", "", szPlayerName, 0, 0, szScript);
end

-- 解冻玩家
function GmCmd:UnfreezePlayer(tbParam)
	local szPlayerName = tbParam.szPlayerName;
	local szScript = [[me.SetTask(2063, 4, 0)]];
	return GM:AddOnLine("", "", szPlayerName, 0, 0, szScript);
end

function GmCmd:LoadQuestFile(tbParam)
	local szPath = tbParam.szPath;
	local szPlayerListPath = tbParam.szPlayerListPath;
	if EventManager.KingEyes:GCReloadEventByFile(szPath, szPlayerListPath) == 0 then
		return "加载活动文件失败："..szPath;
	end
end
--功能：开启白虎堂boss掉落翻倍
--参数格式：{S={0},E={1},nType={2}}
--S为开始时间，E为结束时间，格式为YYYYmmddHH。nCount为翻的倍数
function GmCmd:Openbaihutang(tbParam)
	local tbEvent = {};
	local nEventId = 20;
	local nPartId = 2
	tbEvent[nEventId] = tbEvent[nEventId] or {};
	tbEvent[nEventId].tbPart = tbEvent[nEventId].tbPart or {};
	tbEvent[nEventId].tbPart[nPartId] = {};
	tbEvent[nEventId].tbPart[nPartId].szName = string.format("开启白虎堂boss掉落%s倍",tbParam.nCount);
	tbEvent[nEventId].tbPart[nPartId].szSubKind = "default";
	local nStartTime = Lib:GetDate2Time(tbParam.S);
	local nEndTime = Lib:GetDate2Time(tbParam.E);
	tbEvent[nEventId].tbPart[nPartId].nStartDate = tonumber(os.date("%Y%m%d%H%M", nStartTime));
	tbEvent[nEventId].tbPart[nPartId].nEndDate  = tonumber(os.date("%Y%m%d%H%M", nEndTime));
	tbEvent[nEventId].tbPart[nPartId].tbExParam = {string.format("SetBaiHuAwardTimes:%s", tbParam.nCount)};
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent);
	return 1;
end

--功能：开启宋金奖励翻倍
--参数格式：{S={0},E={1},nType={2}}
--S为开始时间，E为结束时间，格式为YYYYmmddHH。nCount为翻的倍数
function GmCmd:Openbattle(tbParam)
	local tbEvent = {};
	local nEventId = 20;
	local nPartId = 3
	tbEvent[nEventId] = tbEvent[nEventId] or {};
	tbEvent[nEventId].tbPart = tbEvent[nEventId].tbPart or {};
	tbEvent[nEventId].tbPart[nPartId] = {};
	tbEvent[nEventId].tbPart[nPartId].szName = string.format("开启宋金奖励%s倍",tbParam.nCount);
	tbEvent[nEventId].tbPart[nPartId].szSubKind = "default";
	local nStartTime = Lib:GetDate2Time(tbParam.S);
	local nEndTime = Lib:GetDate2Time(tbParam.E);
	tbEvent[nEventId].tbPart[nPartId].nStartDate = tonumber(os.date("%Y%m%d%H%M", nStartTime));
	tbEvent[nEventId].tbPart[nPartId].nEndDate  = tonumber(os.date("%Y%m%d%H%M", nEndTime));
	tbEvent[nEventId].tbPart[nPartId].tbExParam = {string.format("SetSongJinAwardTimes:%s", tbParam.nCount)};	
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent);
	return 1;
end

--功能：开启门派竞技翻倍
--参数格式：{S={0},E={1},nType={2}}
--S为开始时间，E为结束时间，格式为YYYYmmddHH。nCount为翻的倍数
function GmCmd:Openfactionbattle(tbParam)
	local tbEvent = {};
	local nEventId = 20;
	local nPartId = 4
	tbEvent[nEventId] = tbEvent[nEventId] or {};
	tbEvent[nEventId].tbPart = tbEvent[nEventId].tbPart or {};
	tbEvent[nEventId].tbPart[nPartId] = {};
	tbEvent[nEventId].tbPart[nPartId].szName = string.format("开启门派竞技奖励%s倍",tbParam.nCount);
	tbEvent[nEventId].tbPart[nPartId].szSubKind = "default";
	local nStartTime = Lib:GetDate2Time(tbParam.S);
	local nEndTime = Lib:GetDate2Time(tbParam.E);
	tbEvent[nEventId].tbPart[nPartId].nStartDate = tonumber(os.date("%Y%m%d%H%M", nStartTime));
	tbEvent[nEventId].tbPart[nPartId].nEndDate  = tonumber(os.date("%Y%m%d%H%M", nEndTime));
	tbEvent[nEventId].tbPart[nPartId].tbExParam = {string.format("SetFactionBattleAwardTimes:%s", tbParam.nCount)};	
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent);
	return 1;
end

--功能：开启家族关卡铜钱翻倍
--参数格式：{S={0},E={1},nType={2}}
--S为开始时间，E为结束时间，格式为YYYYmmddHH。nCount为翻的倍数
function GmCmd:Openkingamecoin(tbParam)
	local tbEvent = {};
	local nEventId = 20;
	local nPartId = 5
	tbEvent[nEventId] = tbEvent[nEventId] or {};
	tbEvent[nEventId].tbPart = tbEvent[nEventId].tbPart or {};
	tbEvent[nEventId].tbPart[nPartId] = {};
	tbEvent[nEventId].tbPart[nPartId].szName = string.format("开启家族关卡铜钱奖励%s倍",tbParam.nCount);
	tbEvent[nEventId].tbPart[nPartId].szSubKind = "default";
	local nStartTime = Lib:GetDate2Time(tbParam.S);
	local nEndTime = Lib:GetDate2Time(tbParam.E);
	tbEvent[nEventId].tbPart[nPartId].nStartDate = tonumber(os.date("%Y%m%d%H%M", nStartTime));
	tbEvent[nEventId].tbPart[nPartId].nEndDate  = tonumber(os.date("%Y%m%d%H%M", nEndTime));
	tbEvent[nEventId].tbPart[nPartId].tbExParam = {string.format("SetKinGameCoinAwardTimes:%s", tbParam.nCount)};	
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent);
	return 1;
end

--功能：开启领土征战奖励翻倍
--参数格式：{S={0},E={1},nType={2}}
--S为开始时间，E为结束时间，格式为YYYYmmddHH。nCount为翻的倍数
function GmCmd:Opendomainbattle(tbParam)
	local tbEvent = {};
	local nEventId = 20;
	local nPartId = 6
	tbEvent[nEventId] = tbEvent[nEventId] or {};
	tbEvent[nEventId].tbPart = tbEvent[nEventId].tbPart or {};
	tbEvent[nEventId].tbPart[nPartId] = {};
	tbEvent[nEventId].tbPart[nPartId].szName = string.format("开启领土征战奖励奖励%s倍",tbParam.nCount);
	tbEvent[nEventId].tbPart[nPartId].szSubKind = "default";
	local nStartTime = Lib:GetDate2Time(tbParam.S);
	local nEndTime = Lib:GetDate2Time(tbParam.E);
	tbEvent[nEventId].tbPart[nPartId].nStartDate = tonumber(os.date("%Y%m%d%H%M", nStartTime));
	tbEvent[nEventId].tbPart[nPartId].nEndDate  = tonumber(os.date("%Y%m%d%H%M", nEndTime));
	tbEvent[nEventId].tbPart[nPartId].tbExParam = {string.format("SetDomainBattleAwardTimes:%s", tbParam.nCount)};	
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent);
	return 1;
end

--功能：开启藏宝图奖励翻倍
--参数格式：{S={0},E={1},nType={2}}
--S为开始时间，E为结束时间，格式为YYYYmmddHH。nCount为翻的倍数
function GmCmd:Opencangbaotu(tbParam)
	local tbEvent = {};
	local nEventId = 20;
	local nPartId = 10;
	tbEvent[nEventId] = tbEvent[nEventId] or {};
	tbEvent[nEventId].tbPart = tbEvent[nEventId].tbPart or {};
	tbEvent[nEventId].tbPart[nPartId] = {};
	tbEvent[nEventId].tbPart[nPartId].szName = string.format("开启藏宝图奖励%s倍",tbParam.nCount);
	tbEvent[nEventId].tbPart[nPartId].szSubKind = "default";
	local nStartTime = Lib:GetDate2Time(tbParam.S);
	local nEndTime = Lib:GetDate2Time(tbParam.E);
	tbEvent[nEventId].tbPart[nPartId].nStartDate = tonumber(os.date("%Y%m%d%H%M", nStartTime));
	tbEvent[nEventId].tbPart[nPartId].nEndDate  = tonumber(os.date("%Y%m%d%H%M", nEndTime));
	tbEvent[nEventId].tbPart[nPartId].tbExParam = {string.format("SetCangBaoTuAwardTimes:%s", tbParam.nCount)};	
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent);
	return 1;
end

--功能：开启逍遥谷开卡奖励翻倍
--参数格式：{S={0},E={1},nType={2}}
--S为开始时间，E为结束时间，格式为YYYYmmddHH。nCount为翻的倍数
function GmCmd:Openxoyogamecard(tbParam)
	local tbEvent = {};
	local nEventId = 20;
	local nPartId = 11;
	tbEvent[nEventId] = tbEvent[nEventId] or {};
	tbEvent[nEventId].tbPart = tbEvent[nEventId].tbPart or {};
	tbEvent[nEventId].tbPart[nPartId] = {};
	tbEvent[nEventId].tbPart[nPartId].szName = string.format("开启逍遥谷开卡奖励%s倍",tbParam.nCount);
	tbEvent[nEventId].tbPart[nPartId].szSubKind = "default";
	local nStartTime = Lib:GetDate2Time(tbParam.S);
	local nEndTime = Lib:GetDate2Time(tbParam.E);
	tbEvent[nEventId].tbPart[nPartId].nStartDate = tonumber(os.date("%Y%m%d%H%M", nStartTime));
	tbEvent[nEventId].tbPart[nPartId].nEndDate  = tonumber(os.date("%Y%m%d%H%M", nEndTime));
	tbEvent[nEventId].tbPart[nPartId].tbExParam = {string.format("SetXoyoCardTimes:%s", tbParam.nCount)};	
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent);
	return 1;
end


--功能：开启宋金奖励翻倍
--参数格式：{szName=""}	szName为家族名字
function GmCmd:QueryKinPlayerInfo(tbParam)
	local nKinId = KKin.GetKinNameId(tbParam.szName);
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		return "【error】家族不存在！";
	end
	
	local tbFigName = {"族长","副族长","正式成员","记名成员","荣誉成员"};
	local itor = cKin.GetMemberItor();
	local cMember = itor.GetCurMember();
	local szMsg = "\n地位\t成员名\t等级\t门派\n";
	while cMember do
		local nFig = cMember.GetFigure() or 0;		
		local nPlayerId = cMember.GetPlayerId();
		local szName = KGCPlayer.GetPlayerName(nPlayerId);
		local tbInFor = GetPlayerInfoForLadderGC(szName) or {};
		local nFaction = tbInFor.nFaction or 0;
		local nRoute = tbInFor.nRoute or 0;
		local szFig = tbFigName[nFig] or nFig;
		szMsg = string.format("%s%s\t%s\t%s\t%s\n", szMsg, szFig, szName, (tbInFor.nLevel or 0), (Player:GetFactionRouteName(nFaction, nRoute) or ""));
		cMember = itor.NextMember();
	end
	return szMsg;
end

--功能：查询结婚排期列表
function GmCmd:QueryMarryInfo(tbParam)
	return Marry:GetMarryInfo(tonumber(tbParam.nDate), tonumber(tbParam.nEndDate));
end

--查询联赛战队信息（通过战队名）
function GmCmd:QueryWllsLeagueForLName(tbParam)
	local szLeagueName = tbParam.szLeagueName;
	local nDate		   = tonumber(tbParam.nDate) or 0;
	if nDate <= 0 then
		nDate = tonumber(GetLocalDate("%Y%m%d"));
	end
	return League:GetFileHistoryInforByLeague(Wlls.LGTYPE, nDate, szLeagueName)
end

--查询联赛战队信息（通过成员名）
function GmCmd:QueryWllsLeagueForMName(tbParam)
	local szMemberName = tbParam.szMemberName;
	local nDate		   = tonumber(tbParam.nDate) or 0;
	if nDate <= 0 then
		nDate = tonumber(GetLocalDate("%Y%m%d"));
	end
	return League:GetFileHistoryInforByMember(Wlls.LGTYPE, nDate, szMemberName)	
end

-- 查询奇珍阁在线指令buff
function GmCmd:QueryIbshopBuffInfo()
	local tbIbShopCmd = IbShop.tbIbshopCmdBuff;
	if (not tbIbShopCmd or Lib:CountTB(tbIbShopCmd) == 0) then
		return "不存在奇珍阁在线指令";
	end
	local strResult = "\n【状态】\t货币类型\t商品id\t折扣\t开始优惠时间\t结束优惠时间\t开始出售时间\t结束出售时间\t物品名\n"
	local nCurTime = GetTime();
	local szOutFile = "\\playerladder\\query_ibshop_goods.txt";
	KFile.WriteFile(szOutFile, strResult);
	for _, tbSubCmd in pairs(tbIbShopCmd) do
		local szState = "【上架中】";
		local szTimeSaleStart = tbSubCmd["timeSaleStart"];
		if (szTimeSaleStart) then
			local nTimeSaleStart = Lib:GetDate2Time(IbShop:ParseTime(szTimeSaleStart));
			if (nTimeSaleStart and nCurTime < nTimeSaleStart) then
				szState = "【下架中】";
			end
		end
		local szTimeSaleClose = tbSubCmd["timeSaleClose"];
		if (szTimeSaleClose) then
			local nTimeSaleClose = Lib:GetDate2Time(IbShop:ParseTime(szTimeSaleClose));
			if (nTimeSaleClose and nCurTime > nTimeSaleClose) then
				szState = "【下架中】";
			end
		end
		
		local szCurrencyType = "金币区";
		local nCurrencyType = tbSubCmd["nCurrencyType"];
		if (nCurrencyType and 2 == nCurrencyType) then
			szCurrencyType = "绑金区";
		end
		
		if (nCurrencyType and 3 == nCurrencyType) then
			szCurrencyType = "积分区";
		end
		
		local nWareId = tbSubCmd["WareId"] or 0;
		if (IbShop.tbPreloadWareInfo[nWareId]) then
			local nDiscount = tbSubCmd["nDiscount"] or "未打折";
			local nDiscountStart = tbSubCmd["DiscountStart"] or "不存在";
			local nDiscountClose = tbSubCmd["DiscountClose"] or "不存在";
			local szWareName = IbShop.tbPreloadWareInfo[nWareId]["WareName"] or "未获取到名字";
			local szOut = string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", szState, szCurrencyType,
				nWareId, nDiscount, nDiscountStart, nDiscountClose, szTimeSaleStart or "", szTimeSaleClose or "", szWareName);
			strResult = strResult .. szOut;
			KFile.AppendFile(szOutFile, szOut);	
		end
	end
	
	return strResult;
end

-- 为奇珍阁所有商品打折
-- 参数：货币类型（0金币 2绑金） 折扣（百分比，比如50就代表50%的折扣） 开始和结束销售时间（格式为："2010-1-17 0:00:00"）
function GmCmd:SetAllIbWareDiscount(tbParam)
	local nDiscount = tbParam.nDiscount;
	local nNeedCurrencyType = tbParam.nNeedCurrencyType;
	local szStartTime = tbParam.szStartTime;
	local szEndTime = tbParam.szEndTime;
	if (nDiscount < 1) then
		return "【Error】折扣百分比必须大于0";
	end
	
	local szPath = "\\setting\\ibshop\\";
	if (0 == nNeedCurrencyType) then
		szPath = szPath .. "coinshop.txt";
	elseif (2 == nNeedCurrencyType) then
		szPath=szPath .. "bindcoinshop.txt";
	else
		return "【Error】货币类型不正确";
	end
	
	local tbShop = KLib.LoadTabFile(szPath);
	local tbWareId = {};
	for nId, tbData in ipairs(tbShop) do
		if nId > 1 then
			local nId = tonumber(tbData[1]) or 0;
			tbWareId[nId] = 1;
		end
	end
	
	for _, tbData in pairs(IbShop.tbPreloadWareInfo) do
		local nCurrencyType = tonumber(tbData["nCurrencyType"]);
		if (nCurrencyType == nNeedCurrencyType) then
			local nId = tonumber(tbData["WareId"]);
			local nOrgPrice = tonumber(tbData["nOrgPrice"]) or 1;
			local nValue = nDiscount * nOrgPrice;
			local nCurRate=nDiscount;
			if nValue < 100 then
				nCurRate = math.ceil(100 / nOrgPrice);
			end
			local tbTemp = {};
			if (tbWareId[nId] and nCurRate > 0) then
				tbTemp.WareId = nId;
				tbTemp.nDiscount = nCurRate;
				tbTemp.DiscountStart = szStartTime;
				tbTemp.DiscountClose = szEndTime;
				GM:ModifyIBWare(tbTemp, 0);
			end
		end
	end
	IbShop:SaveBuf();
	print("GmCmd:SetAllIbWareDiscount", nDiscount, nNeedCurrencyType, szStartTime, szEndTime);
	return 1;
end

-- 为奇珍阁单个商品打折
-- 参数：商品id 折扣（百分比，比如50就代表50%的折扣） 开始和结束销售时间（格式为："2010-1-17 0:00:00"）
function GmCmd:SetOneIbWareDisCount(tbParam)
	local nWareId = tbParam.nWareId;
	local nDiscount = tbParam.nDiscount;
	local szStartTime = tbParam.szStartTime;
	local szEndTime = tbParam.szEndTime;
	if (nDiscount < 1 or not IbShop.tbPreloadWareInfo[nWareId]) then
		return "【Error】折扣百分比必须大于0并且商品必须存在。";
	end

	local tbData = IbShop.tbPreloadWareInfo[nWareId];
	local nOrgPrice = tonumber(tbData["nOrgPrice"]) or 1;
	local nValue = nDiscount * nOrgPrice;
	local nCurRate=nDiscount;
	if nValue < 100 then
		nCurRate = math.ceil(100 / nOrgPrice);
	end	
	
	if (nCurRate > 0) then
		local tbTemp = {};
		tbTemp.WareId = nWareId;
		tbTemp.nDiscount = nCurRate;
		--tbTemp.timeSaleStart = "2008-8-8 0:00:00";
		--tbTemp.timeSaleClose = "2018-8-8 0:00:00";
		tbTemp.DiscountStart = szStartTime;
		tbTemp.DiscountClose = szEndTime;
		GM:ModifyIBWare(tbTemp);
	end
	print("GmCmd:SetOneIbWareDisCount", nWareId, nDiscount, szStartTime, szEndTime);
	return 1;
end

-- 对单个商品上架
function GmCmd:UpGoods(tbParam)
	local nWareId = tonumber(tbParam.nWareId);
	local nTimeFrame = tonumber(tbParam.nTimeFrame) or 0;
	local szSellStartDate  = tbParam.szSellStartDate;
	local szSellEndTime  = tbParam.szSellEndTime;
	if (not IbShop.tbPreloadWareInfo[nWareId]) then
		return "【Error】商品必须存在。";
	end
	local tbTemp = {};
	tbTemp.WareId = nWareId;
	local szStartDate = GetLocalDate("%Y-%m-%d 0:00:00");
	tbTemp.timeSaleStart = szStartDate;
	tbTemp.timeSaleClose = "2018-8-8 0:00:00";
	if szSellStartDate and szSellStartDate ~= "" then
		tbTemp.timeSaleStart = szSellStartDate;
	end
	if szSellEndTime and szSellEndTime ~= "" then
		tbTemp.timeSaleClose = szSellEndTime;
	end	
	if (nTimeFrame > 0) then
		tbTemp.nTimeFrameStartSale = nTimeFrame;
		tbTemp.nTimeFrameEndSale = 100000;
	end
	GM:ModifyIBWare(tbTemp);
	print("GmCmd:UpGoods", nWareId, nTimeFrame, szSellStartDate, szSellEndTime);
	return 1;
end

-- 对单个商品下架
function GmCmd:DownGoods(nWareId)
	nWareId = tonumber(nWareId);
	if (not IbShop.tbPreloadWareInfo[nWareId]) then
		return "【Error】商品必须存在。";
	end
	local tbTemp = {};
	tbTemp.WareId = nWareId;
	tbTemp.timeSaleStart = "2018-8-8 0:00:00";
	tbTemp.timeSaleClose = "2018-8-8 0:00:00";
	GM:ModifyIBWare(tbTemp);
	print("GmCmd:DownGoods", nWareId);
	return 1;
end

--清除在线指令的buff
function GmCmd:ClearIbshopBuff()
	IbShop.tbIbshopCmdBuff = {};
	IbShop:SaveBuf();
	print("GmCmd:ClearIbshopBuff");
	return 1;
end

--查询补偿信息
function GmCmd:QueryCompensateByName(tbParam)
	local szName = tbParam.szName;
	if not szName or szName == "" then
		return "请输入玩家姓名";
	end
	return SpecialEvent.CompensateGM:GmGmdQueryAddOnNpc(szName);
end

--删除补偿信息
function GmCmd:ClearCompensateByName(tbParam)
	local szName = tbParam.szName;
	local nLogId = tonumber(tbParam.nLogId) or 0;
	if not szName or szName == "" then
		return "请输入玩家姓名";
	end
	if nLogId == 0 then
		return SpecialEvent.CompensateGM:GmGmdDelAllAddOnNpc(szName);
	end
	return SpecialEvent.CompensateGM:GmGmdDelSignleAddOnNpc(szName, nLogId);
end

function GmCmd:SetIbShopGoodsNewUp(nWareId)
	nWareId = tonumber(nWareId);
	if (not IbShop.tbPreloadWareInfo[nWareId]) then
		return "【Error】商品必须存在。";
	end
	local tbTemp = {};
	tbTemp.WareId = nWareId;
	local szStartDate = GetLocalDate("%Y-%m-%d 0:00:00");
	tbTemp.timeSaleStart = szStartDate;
	tbTemp.timeSaleClose = "2018-8-8 0:00:00";
	GM:ModifyIBWare(tbTemp);
	print("GmCmd:SetIbShopGoodsNewUp", nWareId);
	return 1;
end

--查询金币交易所汇率
function GmCmd:QueryJBExchangeRate()
	return "金币交易所汇率："..KJbExchange.GetPrvAvgPrice();
end

-- 修改制定商品的售价
function GmCmd:SetOneIbWarePrice(tbParam)
	local nWareId = tonumber(tbParam.nWareId);
	if (not IbShop.tbPreloadWareInfo[nWareId]) then
		return "【Error】商品必须存在。";
	end
	local nPrice = tonumber(tbParam.nPrice);
	if (not nPrice or nPrice <= 0) then
		return "【Error】请检查行的售价。";
	end
	local tbTemp = {};
	tbTemp.WareId = nWareId;
	tbTemp.nOrgPrice = nPrice;
	GM:ModifyIBWare(tbTemp);
	return 1;
end



function GmCmd:LoadPresendCardFile(szFile)
	return PresendCard:LoadGblBufFile(szFile);
end

function GmCmd:DelPresendCardBuf(szType)
	local nType = tonumber(szType);
	if not nType then
		return "nType is not number"..szType;
	end
	return PresendCard:DeleteOneBuf(nType);
end

function GmCmd:QueryPresendCardBuf()
	return PresendCard:QueryGlbBuf();
end

function GmCmd:AddNewBatchMail(tbParam)
	return  Mail.BatchMail:AddIntoGblBuf(tbParam.szTitle, tbParam.szContent, 
	tonumber(tbParam.nEndTime));
end

function GmCmd:QueryShowLadder(tbParam)
	local nType1 = tonumber(tbParam.nType1);
	local nType2 = tonumber(tbParam.nType2);
	local nType3 = tonumber(tbParam.nType3);
	local szMsg = "";
	local tbTitle = {};
	local nLoadTitle = 0;
	local nLadderType = Ladder:GetType(0, nType1, nType2, nType3);
	if nLadderType <= 0 then
		return "找不到该类型显示榜数据（经典模式）";
	end
	local tbData,szTitle =GetShowLadder(nLadderType)
	if not tbData then
		return "找不到该类型显示榜数据（经典模式）";
	end
  	szMsg = szMsg .."\n排行榜："..szTitle.."\n";
	for nRank, tbD in ipairs(tbData) do
	  
	  szMsg = szMsg.. "Rank";
	  if nLoadTitle == 0 then
		  for szKey, szValue in pairs(tbD) do
		  	tbTitle[szKey] = 1;
		  	szMsg = szMsg.. "\t" .. szKey;
		  end
		  nLoadTitle = 1;
		  szMsg = szMsg.. "\n";
	  end
	   szMsg = szMsg.. nRank;
	  for szKey in pairs(tbTitle) do
	  	if tbD[szKey] then
	  		szMsg = szMsg.. "\t" .. tbD[szKey];
	  	end
	  end
	  szMsg = szMsg.. "\n";
	end
	return szMsg;
end

function GmCmd:QueryHonorLadder(tbParam)
	local nType1 = tonumber(tbParam.nType1);
	local nType2 = tonumber(tbParam.nType2);
	local nType3 = tonumber(tbParam.nType3);
	local szName = tbParam.szName or "";
	local nLadderType = Ladder:GetType(0, nType1, nType2, nType3);
	local szLadderName = GetShowLadderName(nLadderType) or "";
	local szMsg = "\n排行榜："..szLadderName;
	szMsg = szMsg.. "\n排名\t玩家名\t荣誉点\n";
	if szName ~= "" then
		local nRank = GetTotalLadderRankByName(nLadderType, szName);
		if nRank <= 0 then
			return szMsg .."找不到该玩家排行榜信息:"..szName;
		end
		local tbInfor = GetPlayerLadderInfoByRank(nLadderType, nRank);
		if not tbInfor then
			return szMsg.. "找不到该玩家排行榜信息:"..szName;
		end
		return szMsg .. nRank .."\t" ..tbInfor.szPlayerName .. "\t" .. tbInfor.dwValue;
	end
	local tbTInfor = GetTotalLadder(nLadderType);
	if not tbTInfor then
		return szMsg .."找不到该玩家排行榜信息";
	end
	for nRank, tbInfor in ipairs(tbTInfor) do
		if nRank > 500 then
			break;
		end
		szMsg = szMsg .. nRank .. "\t" .. tbInfor.szPlayerName .. "\t" .. tbInfor.dwValue .. "\n";
	end
	return szMsg;
end

function GmCmd:ClearGCStartData()
	local DBTASD_MAX = 144;		--全局变量最大数据
	--local GBLINTBUF_MAX = 23;	--全局buff最大数据
	local szBakName = "\\playerladder\\gc_clsbak\\".."GC_CLSBAK"..GetLocalDate("%Y_%m_%d_%H_%M_%S")..".bak";
	KFile.WriteFile(szBakName, "GId\tValueInt\tValueStr\n");
	for i=0, DBTASD_MAX do
		local nGInt = KGblTask.SCGetDbTaskInt(i);
		local szGStr = KGblTask.SCGetDbTaskStr(i);
		if nGInt ~= 0 or szGStr ~= "" then
			local szOut = i.."\t"..nGInt.."\t"..szGStr.."\n";
			KFile.AppendFile(szBakName, szOut);
			KGblTask.SCSetDbTaskStr(i, "");
			KGblTask.SCSetDbTaskInt(i, 0);
		end
	end
	
	--清除帮助锦囊信息，不做备份。
	SetGblIntBuf(GBLINTBUF_HELPNEWS, 0, 0, {})	
	Task.tbHelp.tbNewsList = {};
	GlobalExcute({"GM:DoCommand", "Task.tbHelp.tbNewsList = {}"});
	--清除帮助锦囊信息，不做备份。end
	
	--清除排行榜（等级），不做备份。
	for i=0, 12 do
 		local nType = Ladder:GetType(0, 2, 1, i);
       	DelShowLadder(nType)
	end
	--清除排行榜（等级），不做备份。
	
	return 1;
end

function GmCmd:QueryGcStartDataBak()
	local tbFile = KFile.GetCurDirAllFile("\\playerladder\\gc_clsbak", ".bak");
	if not tbFile then
		return "不存在备份数据";
	end
	local szMsg = "\n序号\t备份文件\n";
	for i, szPath in ipairs(tbFile) do
		local nFind, nEndFind = string.find(szPath, "/playerladder/gc_clsbak/")
		if nEndFind then
			local szFileName = string.sub(szPath, nEndFind+1, -1);
			szMsg = szMsg .. i .."\t".. szFileName .. "\n";
		end
	end
	return szMsg;
end

function GmCmd:RepairGcStartData(szData)
	
	local tbFile = Lib:LoadTabFile("\\playerladder\\gc_clsbak\\"..szData);
	if not tbFile then
		return "不存在该备份数据";
	end
	self:ClearGCStartData();	--先清除备份再还原
	for _, tbData in ipairs(tbFile) do
		local nGInt  = tonumber(tbData.GId);
		local szGInt = tonumber(tbData.ValueInt);
		local szGstr = tbData.ValueStr;
		KGblTask.SCSetDbTaskStr(nGInt, szGstr);
		KGblTask.SCSetDbTaskInt(nGInt, szGInt);
	end
	return 1;
end

-- 修改世界杯各个球队的价值量
-- szWorldCupValue = "nTeam1Level,nTeam2Level,nTeam3Level,...,nTeam32Level"
function GmCmd:ModifyWorldCupLevel(szWorldCupLevel)
	local tbWorldCupValue = Lib:SplitStr(szWorldCupLevel);
	return SpecialEvent.tbWroldCup:SetCardValue_GC(tbWorldCupValue);
end

--金牌网吧 上传ip文件
function GmCmd:GoldBarIpList(tbParam)
	return SpecialEvent.tbGoldBar:ReadGateWayFile(tbParam.szDataPath);
end

--金牌网吧 增加ip或者ip段
function GmCmd:AddGoldBarIp(tbParam)
	return SpecialEvent.tbGoldBar:AddIp(tbParam.szIp);
end

--金牌网吧 没有参数时表示整个删除，删除ip或者ip段
function GmCmd:DelGoldBarIp(tbParam)
	return SpecialEvent.tbGoldBar:DelIp(tbParam.szIp);
end

--金牌网吧 查询ip  无参数表示整个打印出来，
function GmCmd:QueryGoldBarIp(tbParam)
	local szOutFile = "\\playerladder\\goldenbariplist.txt";	
	local strResult = "金牌网吧Ip:\n";
	local szOut = "";
	if not tbParam.szIp or tbParam.szIp == "" then
		KFile.WriteFile(szOutFile, strResult);
		for szKey, tbIp in pairs(SpecialEvent.tbGoldBar.GoldBarIpList) do
			if tbIp.nAll then
				szOut = szKey..".*\n";
				strResult = strResult..szOut;
				KFile.AppendFile(szOutFile, szOut);	
			else
				for szIp, _ in pairs(tbIp) do
					szOut = szIp.."\n";
					strResult = strResult..szOut;
					KFile.AppendFile(szOutFile, szOut);
				end
			end			
		end
		return strResult;
	end
	local szKey,nAll = SpecialEvent.tbGoldBar:GetIpKey(tbParam.szIp);
	if szKey then
		if SpecialEvent.tbGoldBar.GoldBarIpList[szKey] then
			if nAll then
				if SpecialEvent.tbGoldBar.GoldBarIpList[szKey].nAll then
					strResult = szKey..".*Ip段是金牌网吧ip";
				else
					strResult = szKey..".*Ip段不是金牌网吧ip";
				end
			else
				if SpecialEvent.tbGoldBar.GoldBarIpList[szKey].nAll or SpecialEvent.tbGoldBar.GoldBarIpList[szKey][tbParam.szIp] then
					strResult =tbParam.szIp.."是金牌网吧ip";
				end
			end
			return strResult
		else
			return "该ip不是金牌网吧ip"
		end
	else
		return "ip值不正确！"
	end
end

function GmCmd:ApplyChangeAccount(tbData)
	local szName 		= tbData.szName;
	local oldszAccount  = tbData.oldszAccount;
	local szAccount 	= Lib:ClearBlank(tbData.szAccount);
	local szAccountRe 	= Lib:ClearBlank(tbData.szAccountRe);
	if not KGCPlayer.GetPlayerIdByName(szName) then
		return "不存在该角色:"..szName;
	end
	if oldszAccount == "" then
		return "请输入原始账号";
	end
	if szAccount == "" then
		return "请输入更改后的账号";
	end
	if szAccount ~= szAccountRe then
		return "输入账号和确认账号不匹配。";
	end
	local szScript = string.format([[me.ApplyChangeAccount("%s")]], szAccount);
	return SpecialEvent.CompensateGM:AddOnLine("", oldszAccount, szName, 0, 0, szScript);	
end

function GmCmd:ApplyChangeAccountFile(tbParam)
	local szPath = tbParam.szDataPath or "";
	if szPath == "" then
		return "出错啦！";
	end
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return "出错啦！";
	end	
	local szMsg = "";
	for nId, tbParamEx in ipairs(tbFile) do
		if nId >= 1 then
			local szGateway = tbParamEx.GATEWAY or "";
			local szOldAccount = tbParamEx.ORG_ACCOUNT or "";
			local szNewAccount = Lib:ClearBlank(tbParamEx.NEW_ACCOUNT) or ""
			local szName = tbParamEx.ORG_ROLE or "";
			if GetGatewayName() == szGateway then		
				if not KGCPlayer.GetPlayerIdByName(szName) then
					szMsg = szMsg.. "不存在该角色:"..szName.."\n";
				end
				if szOldAccount ~= ""  and szNewAccount ~= "" and szRole ~= "" then
					local szScript = string.format([[me.ApplyChangeAccount("%s")]], szNewAccount);
					SpecialEvent.CompensateGM:AddOnLine("", szOldAccount, szName, 0, 0, szScript);
				end
			end
		end
	end	
	if szMsg ~= "" then
		return szMsg;
	end
	return 1;
end

function GmCmd:OpenSuperBattle(nIsOpen)
	if not GLOBAL_AGENT then
		return "Error,不是全局服";
	end
	nIsOpen = tonumber(nIsOpen) or 0;
	if nIsOpen ~= 0 then
		nIsOpen = 1;
	end
	SetGlobalSportTask(SuperBattle.GA_DBTASK_GID, SuperBattle.GA_DBTASK_OPEN, nIsOpen)
	return 1;
end

function GmCmd:OpenShengLongCheng(nIsOpen)
	if not GLOBAL_AGENT then
		return "Error,不是全局服";
	end
	nIsOpen = tonumber(nIsOpen) or 0;
	if nIsOpen ~= 0 then
		nIsOpen = 1;
	end
	SetGlobalSportTask(ShengLongCheng.GA_DBTASK_GID, ShengLongCheng.GA_DBTASK_OPEN, nIsOpen)
	return 1;
end

function GmCmd:OpenXLandBattle(nIsOpen)
	if not GLOBAL_AGENT then
		return "Error,不是全局服";
	end
	nIsOpen = tonumber(nIsOpen) or 0;
	if nIsOpen ~= 0 then
		nIsOpen = 1;
	end
	SetGlobalSportTask(Xkland.GA_DBTASK_GID, Xkland.GA_DBTASK_OPEN, nIsOpen)
	return 1;
end

function GmCmd:SetXLandBattleState(nState)
	if not GLOBAL_AGENT then
		return "Error,不是全局服";
	end	
	if Xkland:CheckIsOpen() ~= 1 or Xkland:CheckIsGlobal() ~= 1 then
		return "该大区铁浮城未开启";
	end
	local nPrePeriod = Xkland:GetPeriod();	
	
	--nState 1:竞投；2:选择军团
	nState = tonumber(nState) or 0;
	if nState == 1 then

		if nPrePeriod == Xkland.PERIOD_WAR_REST then
			Xkland:TaskCompetitive();
			return 1;
		end
		return "Error,该大区铁浮城不在休息阶段，无法进入竞投阶段";
	end
	
	if nState == 2 then
		if nPrePeriod == Xkland.PERIOD_COMPETITIVE then
			Xkland:TaskSelectGroup();
			return 1;
		end
		return "Error,该大区铁浮城不在竞投阶段，无法进入选择军团阶段";
	end
	return 0;
end

function GmCmd:ChenmiSwitch(szState)
	local nState =  tonumber(szState) or 0;
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_CHENMISWITCH, nState);
	return GlobalExcute({"SpecialEvent.tbChenMi:ChangeSwitch", nState});
end

function GmCmd:YouLongGeSwitch(szState)
	local nState =  tonumber(szState) or 0;
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_YOULONGGESWITCH, nState);
end

function GmCmd:SetWeiWangTimes(nTimes)
	local nTimes =  tonumber(nTimes) or 1;
	KGblTask.SCSetDbTaskInt(DBTASK_WEIWANG_TIMES, nTimes);
end

--老玩家回归  转新服
function GmCmd:OldPlayer2NewGate(tbParam)
	return SpecialEvent.tbOldPlayerBack:ReadOldPlayer2NewGate(tbParam.szDataPath);
end

--老玩家回归  留在老服
function GmCmd:OldPlayerBack(tbParam)
	return SpecialEvent.tbOldPlayerBack:ReadOldPlayerBack(tbParam.szDataPath);
end

--导入拉新卡密
function GmCmd:LaXin2010ReadFile(tbParam)
	return SpecialEvent.tbLaXin2010:ReadCard(tbParam.szDataPath);
end

--查询拉新卡密库存
function GmCmd:QueryLaXin2010Card(tbParam)
	return SpecialEvent.tbLaXin2010:PrintCardInfo();
end

--删除卡密
function GmCmd:DelLaXin2010Card(tbData)
	local szFile = "tempcard" .. os.date("%Y_%m_%d_%H_%M_%S", GetTime()) .. ".txt";
	local nType = tonumber(tbData.nType);
	local nCount = tonumber(tbData.nCount);
	local tbCardList, nDelCount = SpecialEvent.tbLaXin2010:DelCard(nType, nCount);
	local szInfo = "nType	szCardId	szCardPass\r\n";
	if nDelCount > 1000 then
		KFile.AppendFile(szFile, szInfo);
		for _, tbCard in pairs(tbCardList) do
			szInfo = nType .. "\t" .. tbCard.szCardId .. "\t" .. tbCard.szCardPass .. "\r\n";
			KFile.AppendFile(szFile, szInfo);
		end
		return "由于导出卡密过多，导出结果已经写入文件：" .. szFile;
	else
		for _, tbCard in pairs(tbCardList) do
			szInfo = szInfo .. nType .. "\t" .. tbCard.szCardId .. "\t" .. tbCard.szCardPass .. "\r\n";
		end
		return szInfo;
	end
end

--淘宝合作活动
function GmCmd:TaobaoCooperate(tbParam)
	return SpecialEvent.tbTaobaoCooperate:ReadTaobaoCooperate(tbParam.szDataPath);
end

function GmCmd:TaobaoSwitch(szState)
	local nState =  tonumber(szState) or 0;
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_TAOBAOSWITCH, nState);
	GlobalExcute({"SpecialEvent.tbTaobaoCooperate:AddNpc"});
	return 1;
end

--官方发布经验平台任务
function GmCmd:TaskPlatformFabu(tbData)
	local nType 		= tonumber(tbData.nType) or 0;
	local nCount 	 	= tonumber(tbData.nCount) or 0;
	local nGrade 		= tonumber(tbData.nGrade)or 0;
	if nType <= 0 or nCount <= 0 or nCount > 20 or nGrade <= 0 or nGrade > 20 or not Task.TaskExp.tbItem[nType] then
		print("官方发布经验平台有误！");
		return;
	end
	local tbTaskFaBu = {};
	tbTaskFaBu[1] = nCount;
	tbTaskFaBu[2] = nGrade;
	tbTaskFaBu.szBuf = "system";
	Task.TaskExp:FaBuTask(nType, tbTaskFaBu);
end

function GmCmd:QueryTaobaoCode()
	local szMsg = "";	
	local tbCodeCount = {0,0,0,0,0,0,0,};
	local tbNameCode = {"礼包", 	"100元【淘宝红包】","50元【淘宝红包】","10元【淘宝红包】","5元【淘宝红包】","100元【淘宝代金券】","20元【淘宝代金券】"}
	for i = 2 , 7 do
		if SpecialEvent.tbTaobaoCooperate.tbTaoBaoInfo[i] then
			for szCode, nFlag  in pairs(SpecialEvent.tbTaobaoCooperate.tbTaoBaoInfo[i]) do
				if nFlag == 0 then
					tbCodeCount[i]  = tbCodeCount[i] + 1; 
				end
			end
		end
		local szTotalCount = string.format("%s码字剩余总数：%s\n", tbNameCode[i], tbCodeCount[i]);
		szMsg = szMsg .. szTotalCount;		
	end
	return szMsg;
end

--执行服务器重启执行的指令
function GmCmd:ExecuteAutoDoCommand(tbData)
	local szName = tbData.szName;
	local nDate  = tonumber(tbData.nEndDate) or 0;
	local szScript = tbData.szScript;
	return GM:DoAndSaveBuf(szName, nDate, szScript);
end

--查询服务器重启执行的指令
function GmCmd:QueryAutoDoCommand()
	local szMsg = "\n名称\t截止日期\n";
	local szOutFile = "\\playerladder\\autodocommand.txt";	
	local strResult = "重启服务器自动执行指令:\n";
	local szOut = "";
	
	KFile.WriteFile(szOutFile, strResult..szMsg);
	for szName, tbCommandEx in pairs(GM.tbCommand) do
		szOut = szName.."\t".. tbCommandEx[1] .."\n";
		KFile.AppendFile(szOutFile, szOut);	
		szMsg = szMsg .. szOut;
	end
	return szMsg;
end

--清除所有服务器重启执行的指令
function GmCmd:ClearAutoDoCommand()
	GM.tbCommand = {};
	SetGblIntBuf(GBLINTBUF_GMCOMMAND, 0, 1, {});
end

----删除一条服务器重启执行的指令
function GmCmd:DelAutoDoCommand(szName)
	if GM.tbCommand and GM.tbCommand[szName] then
		GM.tbCommand[szName] = nil;
		SetGblIntBuf(GBLINTBUF_GMCOMMAND, 0, 1, GM.tbCommand);
		return 0;
	else
		return "没有找到您要删除的指令名字！";
	end
end

function GmCmd:GMAddOnLine(tbDate)
	local szName		= tbDate.szName;
	local nStartDate	= tonumber(tbDate.nStartDate) or 0;
	local nEndDate		= tonumber(tbDate.nEndDate) or 0;
	local szScript		= tbDate.szScript;
	local szInfo		= tbDate.szInfo;
	local bMsg = nil;
	if szInfo ~= "" then
		bMsg = 1;
		szScript = szScript..string.format([[me.Msg("%s")]], szInfo);
	end
	return GM:AddOnLine("", "", szName, nStartDate, nEndDate, szScript, bMsg);
end

function GmCmd:GMAddOnNpc(tbDate)
	local szName		= tbDate.szName;   
	local nStartDate	= tonumber(tbDate.nStartDate) or 0;
	local nEndDate		= tonumber(tbDate.nEndDate) or 0;
	local szItem		= tbDate.szItem;
	local nItemTime		= tonumber(tbDate.nItemTime) or 0;
	local nCount		= tonumber(tbDate.nCount) or 0;
	local nBind			= tonumber(tbDate.nBind) or 0;
	local nNeedFreeBag	= tonumber(tbDate.nNeedFreeBag) or 0;
	local nMoney		= tonumber(tbDate.nMoney) or 0;
	local nBindMoney	= tonumber(tbDate.nBindMoney) or 0;
	local nBindCoin		= tonumber(tbDate.nBindCoin) or 0;
	local szDesc		= tbDate.szDesc;
	local szScript		= tbDate.szScript;
	local tbItem		= Lib:SplitStr(szItem, ",");
	tbItem[1] = tonumber(tbItem[1]) or 0;
	tbItem[2] = tonumber(tbItem[2]) or 0;
	tbItem[3] = tonumber(tbItem[3]) or 0;
	tbItem[4] = tonumber(tbItem[4]) or 0;
	local tbAward 		= {
			tbItem = tbItem,
			nTimeLimit = nItemTime,
			nNum=nCount,
			nBind=nBind,
			nNeedBag = nNeedFreeBag,
			nMoney = nMoney,
			nBindMoney = nBindMoney,
			nBindCoin = nBindCoin,
			szDesc = szDesc, 
			szScript = szScript,
		} 
	return GM:AddOnNpc("", "",szName, nStartDate, nEndDate, tbAward);
end	

function GmCmd:Msg2WorldByChat(szContent)
	local szContent = szContent;
	return GlobalExcute({"KDialog.Msg2SubWorld", szContent});
end

function GmCmd:Msg2WorldByNews(szContent)
	local szContent = szContent;
	return GlobalExcute({"KDialog.NewsMsg", 0, Env.NEWSMSG_NORMAL, szContent});
end

function GmCmd:OpenJBExChange(tbData)
	local nOpen = tonumber(tbData.nOpen) or -1;
	local tbState = {
		[0]=1,	--开
		[1]=0,	--关
		};
	if not tbState[nOpen] then
		return "开关参数错误";
	end
	KJbExchange.SetClose(tbState[nOpen]);
	local szOpen = "开启";
	if tbState[nOpen] == 1 then
		szOpen = "关闭";
	end
	return "设置开关成功："..szOpen;
end

function GmCmd:UpdateLadder()
	--更新武林荣誉、财富荣誉、领袖荣誉排行榜
	PlayerHonor:UpdateWuLinHonorLadder();
	PlayerHonor:UpdateLeaderHonorLadder();
	PlayerHonor:UpdateMoneyHonorLadder();
	KGblTask.SCSetDbTaskInt(DBTASD_HONOR_LADDER_TIME, GetTime());
	GlobalExcute({"PlayerHonor:OnLadderSorted"});
	return 1;
end

function GmCmd:SetStartServerTime(tbDate)
	local nDate = tonumber(tbDate.nDate) or -1;
	if nDate < 0 then
		return "参数错误";
	end
	TimeFrame: SetStartServerTime(nDate);
	return 1;
end

function GmCmd:KickPlayerOnLine(tbDate)
	local szName = tbDate.szName;
	return GM:KickOut(szName);
end

function GmCmd:ArrestPlayerOnLine(tbDate)
	local szName = tbDate.szName;
	return GM:AddOnLine("", "", szName, 0, 0, string.format([[Player:Arrest("%s")]], szName));
end

function GmCmd:SetFreePlayerOnLine(tbDate)
	local szName = tbDate.szName;
	return GM:AddOnLine("", "", szName, 0, 0, string.format([[Player:SetFree("%s")]], szName) );
end

function GmCmd:OpenEventCompensate(tbData)
	local nStartDate = tonumber(tbData.nStartDate) or 0;
	local nEndDate = tonumber(tbData.nEndDate) or 0;
	local nLevel = tonumber(tbData.nLevel) or 60;
	if string.len(nStartDate) ~= 12 then
		return "开始时间格式出错";
	end
	if string.len(nEndDate) ~= 12 then
		return "结束时间格式出错";
	end
	if Lib:GetDate2Time(nEndDate) < GetTime() then
		return "出错，结束时间格式出错，已过期";
	end
	if Lib:GetDate2Time(nStartDate) >= Lib:GetDate2Time(nEndDate) then
		return "出错，开始时间比结束时间大";
	end
	
	local szTitle = tbData.szTitle;
	local szDesc = tbData.szDesc;
	
	local szCheckLevel = string.format([[CheckLevel:"%s","对不起，您还没有达到%s级无法领取补偿。"]], nLevel, nLevel);--玩家等级条件判断
	local szExpParam = string.format([[AddBaseExp:"%s","0"]], tbData.nExpMin);	--分钟基准经验
	local szBindMoneyParam = string.format([[AddBindMoney:"%s"]], tbData.nBindMoney);	--绑定银两
	local szItemParam = string.format([[AddItem:"18,1,80,1","%s","1","0","0","0"]], tbData.nFuDaiCount);	--黄金福袋
	local tbEvent = {};
	tbEvent[24] = {};
	tbEvent[24].szName  = szTitle;
	tbEvent[24].szDesc  = szDesc;
	tbEvent[24].nStartDate  = nStartDate;
	tbEvent[24].nEndDate  	= nEndDate;
	tbEvent[24].nTaskBatch	= math.floor(nEndDate/100);
	tbEvent[24].tbPart = {};
	tbEvent[24].tbPart[1] = {nStartDate = 0, nEndDate = nEndDate, tbExParam = {[5] = szCheckLevel, [13] = szExpParam}};
	tbEvent[24].tbPart[2] = {nStartDate = 0, nEndDate = nEndDate, tbExParam = {[5] = szCheckLevel, [13] = szBindMoneyParam}};
	tbEvent[24].tbPart[3] = {nStartDate = 0, nEndDate = nEndDate, tbExParam = {[5] = szCheckLevel, [13] = szItemParam}};
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent); 
end

function GmCmd:GetEventCompensate()
	local tbBuf = EventManager.KingEyes:GetGblBuf();
	if not tbBuf or not tbBuf[24] then
		return "无开启信息";
	end
	local szMsg = string.format("\n已有活动:%s\n开始时间:%s\n结束时间:%s\n描述信息:%s",
		tbBuf[24].szName or "无", 
		tbBuf[24].nStartDate,
		tbBuf[24].nEndDate,
		tbBuf[24].szDesc or "无");
	return szMsg;
end

function GmCmd:CloseEventCompensate()
	local tbBuf = EventManager.KingEyes:GetGblBuf();
	if not tbBuf or not tbBuf[24] then
		return "无开启信息";
	end 
	local tbEvent = {};
	tbEvent[24] = {};
	tbEvent[24].nStartDate  = 200909010000;
	tbEvent[24].nEndDate  	= 200909020000;
	tbEvent[24].tbPart = {};
	tbEvent[24].tbPart[1] = {nEndDate = 200909020000};
	tbEvent[24].tbPart[2] = {nEndDate = 200909020000};
	tbEvent[24].tbPart[3] = {nEndDate = 200909020000};
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent);
	return 1;
end

function GmCmd:OpenNewXLandBattle(nIsOpen)
	if not GLOBAL_AGENT then
		return "不是全局服";
	end
	nIsOpen = tonumber(nIsOpen) or 0;
	if nIsOpen ~= 0 then
		nIsOpen = 1;
	end
	return Newland:_SetState(nIsOpen);
end

--查询家族相关信息
function GmCmd:QueryKinMemberInfo(tb)
	local szKinName, nMode = tb.szName, tb.nMode;
	local cKin, nKinId = KKin.FindKin(szKinName);
	if not cKin then
		return "nil";
	end
	local tbWeeklyAction = {
	[1] = "白虎堂",
	[2] = "宋金战场",
	[3] = "通缉任务",
	[4] = "逍遥谷",
	[5] = "军营副本",
	};
	local szMsg = "";
	if nMode == 2 then
		local nType = EPlatForm:GetMacthType();
		local tbPlatformInfo = EPlatForm:GetMacthTypeCfg(nType);
		if not tbPlatformInfo then
			return "本月无家族竞技";
		end
		szMsg = "排名\t姓名\t\t" .. tbPlatformInfo.szName;
	elseif nMode == 3 then
		szMsg = "排名\t姓名\t\t出勤次数";
	end
	local nCount = 0;
	local tbText = {};
	local cMemberIt = cKin.GetMemberItor();
	local cMember = cMemberIt.GetCurMember();
	local nMemberId = cMemberIt.GetCurMemberId();
	while cMember do
		local tbItem = {};
		local nPlayerId = cMember.GetPlayerId();
		local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
		tbItem.nMemberId = nMemberId;
		tbItem.szPlayerName = szPlayerName;
		if nMode == 2 then
			tbItem.nData = GetEventScoreForMonth(szPlayerName)
		elseif nMode ==  3 then
			tbItem.nData = cMember.GetAttendance();
		end
		cMember = cMemberIt.NextMember();
		nMemberId = cMemberIt.GetCurMemberId();
		table.insert(tbText, tbItem);
		nCount = nCount + 1;
		if nCount > 100 then
			break;
		end
	end
	table.sort(tbText, function(tbA, tbB)
			if (tbA.nData == tbB.nData) then
				return tbA.nMemberId < tbB.nMemberId;
			end
			return tbA.nData > tbB.nData;
			end);
	local nIndex = 1;
	for k, v in pairs(tbText) do
		local szFillPlayerName = Lib:StrFillL(v.szPlayerName, 20);
		local szId = tostring(nIndex);
		local szFillId = Lib:StrFillL(szId, 5);
		local szData = tostring(v.nData);
		local szFillData = Lib:StrFillL(szData, 8);
		nIndex = nIndex + 1;
		szMsg = szMsg .. "\n" .. szFillId .. szFillPlayerName .. szFillData;
	end
	return szMsg;
end

-- 查询家族每日信息
function GmCmd:QueryKinDailyInfo(tbParam)
	local nDate = tonumber(tbParam.nDate) or 0;
	local nSRank = tonumber(tbParam.nSRank) or 0;
	local nERank = tonumber(tbParam.nERank) or 50;
	if nDate <= 0 then
		nDate = tonumber(GetLocalDate("%Y%m%d"));
	end
	return Kin:GetFileHistoryInfoList(nDate, nSRank, nERank);
end

function GmCmd:KEAddNpc(tbDate)
	local nNpcId = tonumber(tbDate.nNpcId);
	local szName = tbDate.szName;
	local nMapId = tonumber(tbDate.nMapId);
	local nPosX = tonumber(tbDate.nPosX);
	local nPosY = tonumber(tbDate.nPosY);
	local nLiveTime = tonumber(tbDate.nLiveTime);
	return EventManager.tbOther:AddNpc(nNpcId, szName, nMapId, nPosX, nPosY, nLiveTime);
end

function GmCmd:QueryAddNpc()
	local szMsg = "\nKey\tNpcId\t名字\t地图id\tx坐标(32位)\ty坐标(32位)\t剩余时间(秒)\n";	
	for nServerId, tbNpc in ipairs(EventManager.tbOther.tbNpcId) do
		for nNpcId, nNum  in pairs(tbNpc) do
			local szInfor = "";
			local tbNpcInfo = EventManager.tbOther.tbNpc[nNum];
			if tbNpcInfo and #tbNpcInfo > 0 then
				if tbNpcInfo[6] and tbNpcInfo[6]  > 0 then
					local nTime = GetTime() - tbNpcInfo[7];
					if nTime > 0 and nTime < tbNpcInfo[6] then
						szInfor = (nNpcId * 10 + nServerId).."\t"..tbNpcInfo[1].."\t"..tbNpcInfo[2].."\t"..tbNpcInfo[3].."\t"..tbNpcInfo[4].."\t"..tbNpcInfo[5].."\t"..tbNpcInfo[6] - nTime.."\n";
					end
				elseif not tbNpcInfo[6]  then
					szInfor =(nNpcId * 10 + nServerId).."\t"..tbNpcInfo[1].."\t"..tbNpcInfo[2].."\t"..tbNpcInfo[3].."\t"..tbNpcInfo[4].."\t"..tbNpcInfo[5].."\t"..tbNpcInfo[6].."\n";
				end
			end
			szMsg = szMsg..szInfor;
		end
	end	
	return szMsg;
end

function GmCmd:KEDelNpc(tbDate)
	local nKey = tonumber(tbDate.nKey) or 0;
	if nKey <= 0 then
		return "你输入的key值不正确！";
	end
	local nServerId = math.fmod(nKey, 10);
	local nNpcId = math.floor(nKey/10);
	local tbNpcId = EventManager.tbOther.tbNpcId;
	local tbNpcInfo = EventManager.tbOther.tbNpc;
	if not tbNpcId or not tbNpcInfo then
		return "ke没有加载过npc！";
	end
	if nServerId <= 0 or nServerId > 7 or not tbNpcId[nServerId] or not tbNpcId[nServerId][nNpcId] then
		return "你输入的key值不正确！";
	end
	if not tbNpcInfo[tbNpcId[nServerId][nNpcId]] or #tbNpcInfo[tbNpcId[nServerId][nNpcId]] <= 0  then
		return "你输入的key值不正确！";
	end
	--过期检查
	local tbNpcInfoEx = tbNpcInfo[tbNpcId[nServerId][nNpcId]];
	if tbNpcInfoEx[6] and tbNpcInfoEx[6]  > 0 then
		local nTime = GetTime() - tbNpcInfoEx[7];
		if nTime > 0 and nTime >= tbNpcInfoEx[6] then
			return "你输入的key值不正确！";
		end
	end
	return EventManager.tbOther:DelNpc(nServerId, nNpcId);
end

-- 执行GC脚本
function GmCmd:DoGcCmd(tbParam)
	return GM:DoCommand(tbParam.szCmd);
end

-- 执行GS脚本
function GmCmd:DoGsCmd(tbParam)
	self:CallGS(tbParam.szGcCallBack, "GM:DoCommand", tbParam.szCmd);
end

-- 执行针对玩家的GS脚本
function GmCmd:DoPlayerGsCmd(tbParam)
	local nRegId = self:RegGSCall("CGS_PLAYER");
	GlobalExcute({"GmCmd:OnCallPlayer", nRegId, tbParam.szName, tbParam.szCmd});
end

-- 执行针对玩家的Client脚本
function GmCmd:DoPlayerClientCmd(tbParam)
	local nRegId = self:RegGSCall("CGS_PLAYER");
	GlobalExcute({"GmCmd:OnCallClient", nRegId, tbParam.szName, tbParam.szCmd});
end

function GmCmd:UpLoadServerListCfg(tbParam)
	local szPath = tbParam.szPath;
	if ServerEvent:LoadServerFile(szPath, 1, 1) == 1 then
		KGblTask.SCSetDbTaskInt(DBTASK_SERVER_LIST_LOADBUFF, GetTime());
		return 1;
	end
	return "配置文件不存在";
end

function GmCmd:ReloadPackServerListCfg()
	if KGblTask.SCGetDbTaskInt(DBTASK_SERVER_LIST_LOADBUFF) > 0 then
		KGblTask.SCSetDbTaskInt(DBTASK_SERVER_LIST_LOADBUFF, 0);
		ServerEvent:LoadServerFile(ServerEvent.szServerListCfgPath, 1, 1);
		return 1;
	end
	return "原本就是包内配置表，无需重置";
end

function GmCmd:OpenJBTransactions(tbParam)
	if (GLOBAL_AGENT) then
		return "不允许在全局服执行";
	end	
	local nOpen = tonumber(tbParam.nOpen) or 0;
	if nOpen == 1 then
		if KGblTask.SCGetDbTaskInt(DBTASK_OPEN_COIN_TRADE) == 0 then
			KJbExchange.DelAllBill();
			KGblTask.SCSetDbTaskInt(DBTASK_OPEN_COIN_TRADE, 1);
			return 1;
		end
		return "已是开启状态";
	end
	if nOpen == 0 then
		if KGblTask.SCGetDbTaskInt(DBTASK_OPEN_COIN_TRADE) == 1 then
			KGblTask.SCSetDbTaskInt(DBTASK_OPEN_COIN_TRADE, 0);
			return 1;
		end
		return "已是关闭状态";
	end
	return "参数错误";
end

function GmCmd:OpenAuctionJBTransactions(tbParam)
	if (GLOBAL_AGENT) then
		return "不允许在全局服执行";
	end
	local nOpen = tonumber(tbParam.nOpen) or 0;
	if nOpen == 1 then
		if KGblTask.SCGetDbTaskInt(DBTASK_OPEN_COIN_AUCTION) == 0 then
			Auction:OpenAuctionCoin()
			return 1;
		end
		return "已是开启状态";
	end
	if nOpen == 0 then
		if KGblTask.SCGetDbTaskInt(DBTASK_OPEN_COIN_AUCTION) == 1 then
			Auction:CloseAuctionCoin()
			return 1;
		end
		return "已是关闭状态";
	end
	return "参数错误";
end

function GmCmd:OpenKuaFuBaiHuTang(tbParam)
	if (not GLOBAL_AGENT) then
		return "只允许在全局服执行";
	end
	local nOpen = tonumber(tbParam.nOpen) or 0;
	if nOpen == 1 then
		if KGblTask.SCGetDbTaskInt(DBTASK_GC_KUAFUBAIHU_SWITCH) == 0 then
			KuaFuBaiHu:Switch(1);
			return 1;
		end
		return "已是开启状态";
	end
	if nOpen == 0 then
		if KGblTask.SCGetDbTaskInt(DBTASK_GC_KUAFUBAIHU_SWITCH) == 1 then
			KuaFuBaiHu:Switch(0);
			return 1;
		end
		return "已是关闭状态";
	end
	return "参数错误";
end

function GmCmd:OpenGumuZhuXiu(tbParam)
	if (GLOBAL_AGENT) then
		return "只允许在普通服执行";
	end
	local nOpen = tonumber(tbParam.nOpen) or 0;
	local nNowOpenState = KGblTask.SCGetDbTaskInt(DBTASK_OPEN_GUMU_FACTION);
	if nOpen == 1 then
		if nNowOpenState == 0 then
			KGblTask.SCSetDbTaskInt(DBTASK_OPEN_GUMU_FACTION, 1);
			return 1;
		end
		return "已是开启状态";
	end
	if nOpen == 0 then
		if nNowOpenState == 1 then
			KGblTask.SCSetDbTaskInt(DBTASK_OPEN_GUMU_FACTION, 0);
			return 1;
		end
		return "已是关闭状态";
	end
	return "参数错误";
end

function GmCmd:OpenGumuFuXiu(tbParam)
	if (GLOBAL_AGENT) then
		return "只允许在普通服执行";
	end
	local nOpen = tonumber(tbParam.nOpen) or 0;
	local nNowOpenState = KGblTask.SCGetDbTaskInt(DBTASK_OPEN_GUMU_FUXIU);
	if nOpen == 1 then
		if nNowOpenState == 0 then
			KGblTask.SCSetDbTaskInt(DBTASK_OPEN_GUMU_FUXIU, 1);
			return 1;
		end
		return "已是开启状态";
	end
	if nOpen == 0 then
		if nNowOpenState == 1 then
			KGblTask.SCSetDbTaskInt(DBTASK_OPEN_GUMU_FUXIU, 0);
			return 1;
		end
		return "已是关闭状态";
	end
	return "参数错误";
end

function GmCmd:OpenGumuFuXiuTask(tbParam)
	if (GLOBAL_AGENT) then
		return "只允许在普通服执行";
	end
	local nOpen = tonumber(tbParam.nOpen) or 0;
	local nNowOpenState = KGblTask.SCGetDbTaskInt(DBTASK_OPEN_GUMU_FUXIU_TASK);
	if nOpen == 1 then
		if nNowOpenState == 0 then
			KGblTask.SCSetDbTaskInt(DBTASK_OPEN_GUMU_FUXIU_TASK, 1);
			return 1;
		end
		return "已是开启状态";
	end
	if nOpen == 0 then
		if nNowOpenState == 1 then
			KGblTask.SCSetDbTaskInt(DBTASK_OPEN_GUMU_FUXIU_TASK, 0);
			return 1;
		end
		return "已是关闭状态";
	end
	return "参数错误";
end

function GmCmd:OpenGlbWlls(tbParam)
	if (not GLOBAL_AGENT) then
		return "只允许在全局服执行";
	end
	local nOpen = tonumber(tbParam.nOpen) or 0;
	if nOpen >= 1 then
		if GbWlls:GetGblWllsOpenState() == 0 then
			KGblTask.SCSetDbTaskInt(GbWlls.GTASK_MACTH_SESSION, nOpen);	
			GbWlls:SetGblWllsOpenState(nOpen);
			return 1;
		end
		return "已是开启状态";
	end
	if nOpen == 0 then
		if GbWlls:GetGblWllsOpenState() > 0 then
			GbWlls:SetGblWllsOpenState(0);
			KGblTask.SCSetDbTaskInt(GbWlls.GTASK_MACTH_SESSION, 0);	
			return 1;
		end
		return "已是关闭状态";
	end
	return "参数错误";	
end


--类1:正常玩家
--类2:新手玩家或小号
--类3:小号或小型工作室
--类4:中小型工作室
--类5:一定规模的工作室
--类6:较大规模工作室
--类7:规模工作室
function GmCmd:LoadPlayerActionKind(tbParam)
	local szPath = tbParam.szPath;
	return Player:SetActionKindByFile(szPath);
end

--类1:正常玩家
--类2:新手玩家或小号
--类3:小号或小型工作室
--类4:中小型工作室
--类5:一定规模的工作室
--类6:较大规模工作室
--类7:规模工作室
function GmCmd:QueryPlayerActionKind(tbParam)
	local szName = tbParam.szName;
	local bRet = Player:GetActionKind(szName);
	if bRet < 0 then
		return "角色不存在";
	end
	return bRet;
end

function GmCmd:SetPlayerActionKind(tbParam)
	local szName = tbParam.szName;
	local nKind	 = tonumber(tbParam.nKind) or 0;
	local bRet = Player:GetActionKind(szName);
	if bRet < 0 then
		return "角色不存在";
	end
	local bSuccess = Player:SetActionKind(szName, nKind);
	if bSuccess == 0 then
		return "设置行为失败";
	end
	return string.format("[%s]原来行为类型%s;现设置为%s",szName, bRet, bSuccess);
end

function GmCmd:AddNewHelpMsg(tbParam)	
	local szTitle = tbParam.szTitle;
	local szMsg = tbParam.szMsg;
	local nEndTime = Lib:GetDate2Time(tonumber(tbParam.nEndTime) or 0);
	local nAddTime = Lib:GetDate2Time(tonumber(tbParam.nAddTime) or 0);
	local nTime = GetTime();
	if szTitle == "" or szMsg == "" or nEndTime <= 0 or nAddTime <= 0 then
		return "参数不对，出项异常";
	end
	if nEndTime < nTime then
		return "参数不对，出项异常";
	end	
	local tbHelpList = {Task.tbHelp.NEWSKEYID.NEWS_VIETNAM_1, Task.tbHelp.NEWSKEYID.NEWS_VIETNAM_2, Task.tbHelp.NEWSKEYID.NEWS_VIETNAM_3}
	for i, nKey in ipairs(tbHelpList) do	
		local nEndTimeEx = Task.tbHelp:GetENewsTime(nKey);
		if nEndTimeEx == 0 or (nEndTimeEx ~= 0 and nEndTimeEx <= nTime) then
			Task.tbHelp:SetDynamicNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
			return 1;
		end
	end
	return "同一时间段内最多只能发布三个最新消息。";
end

function GmCmd:DelNewHelpMsg(tbParam)
	local nKey = tonumber(tbParam.nKey) or 0;
	local nTime = GetTime();	
	local tbHelpList = {Task.tbHelp.NEWSKEYID.NEWS_VIETNAM_1, Task.tbHelp.NEWSKEYID.NEWS_VIETNAM_2, Task.tbHelp.NEWSKEYID.NEWS_VIETNAM_3}
	for i, nKeyEx in ipairs(tbHelpList) do		
		if nKey == nKeyEx and Task.tbHelp.tbNewsList and Task.tbHelp.tbNewsList[nKey] then
			local tbHelp = Task.tbHelp.tbNewsList[nKey];
			Task.tbHelp:SetDynamicNews(nKey, tbHelp.szTitle, tbHelp.szContent, GetTime() -1, tbHelp.nAddTime);
			return 1;
		end
	end
	return "输入的key值有误。";
end

function GmCmd:QueryNewHelpMsg()
	local nTime = GetTime();
	local szMsg = "key\t标题\t开始时间\t剩余时间(秒)\n";
	local tbHelpList = {Task.tbHelp.NEWSKEYID.NEWS_VIETNAM_1, Task.tbHelp.NEWSKEYID.NEWS_VIETNAM_2, Task.tbHelp.NEWSKEYID.NEWS_VIETNAM_3}
	for i, nKey in ipairs(tbHelpList) do
		local nEndTime = Task.tbHelp:GetENewsTime(nKey);		
		if nTime < nEndTime and Task.tbHelp.tbNewsList and Task.tbHelp.tbNewsList[nKey] then
			szMsg = szMsg..nKey.."\t"..Task.tbHelp.tbNewsList[nKey].szTitle.."\t"..os.date("%Y/%m/%d %H:%M:%S",Task.tbHelp.tbNewsList[nKey].nAddTime).."\t"..os.date("%Y/%m/%d %H:%M:%S",nEndTime).."\n";
		end
	end
	return szMsg;
end

--设置福利精活的值，领取购买福利精活的条件
--上次table文件，格式如下：
--GateWay	PrestigeKe
--Gate1000	100
function GmCmd:SetJingHuoFuLi(tbParam)
	local szPath = tbParam.szPath or "";
	if szPath == "" then
		return "出错啦！";
	end
	local tbFile = Lib:LoadTabFile(szPath);	
	if not tbFile then
		return "出错啦！";
	end	
	local tbPrestigeKe = {};
	for nId, tbParamEx in ipairs(tbFile) do
		if nId >= 1 then
			local szGateway = tbParamEx.GateWay or "";
			local nPrestigeKe = tonumber(tbParamEx.PrestigeKe) or 0;		
			if szGateway ~= "" and nPrestigeKe >= 0 then
				tbPrestigeKe[szGateway] = nPrestigeKe;
			end
		end
	end	
	local szGatewayMe = GetGatewayName();
	if tbPrestigeKe[szGatewayMe] then
		KGblTask.SCSetDbTaskInt(DBTASK_JINGHUOFULI_KE, tbPrestigeKe[szGatewayMe]);
		return 1;
	else
		return "没有设置该服务器的福利精活值！";
	end
end

--福利精活设置的值查询
function GmCmd:QueryJingHuoFuLi()
	local nPrestigeKe = KGblTask.SCGetDbTaskInt(DBTASK_JINGHUOFULI_KE);
	return string.format("设置的福利精活值为：\t%s", nPrestigeKe);
end

-- 设置黄金联赛开关，限全局服使用
function GmCmd:OpenGoldenGbWlls(tbParam)
	if (not GLOBAL_AGENT) then
		return "只允许在全局服执行";
	end	
	local nOpen = tonumber(tbParam.nOpen) or 0;
	if nOpen == 1 then
		if GbWlls:GetGoldenGbWllsOpenFlag() == 0 then
			GbWlls:SetGoldenGbWllsOpenFlag(1);
			return 1;
		end
		return "已是开启状态";
	end
	if nOpen == 0 then
		if GbWlls:GetGoldenGbWllsOpenFlag() == 1 then
			GbWlls:SetGoldenGbWllsOpenFlag(0);
			return 1;
		end
		return "已是关闭状态";
	end
	return "参数错误";
end

function GmCmd:OpenTimeframe(tbParam)
	local nOpen = tonumber(tbParam.nOpen) or 0;	
	KGblTask.SCSetDbTaskInt(DBTASK_TIMEFRAME_OPEN, nOpen);	
	Player:SetMaxLevelGC();
	return 1;
end

function GmCmd:OpenEnhanceSixteen(tbParam)
	local nOpen = tonumber(tbParam.nOpen) or 0;	
	KGblTask.SCSetDbTaskInt(DBTASK_ENHANCESIXTEEN_OPEN, nOpen);
	return 1;
end

function GmCmd:OpenIbShopLimit(tbParam)
	local nOpen = tonumber(tbParam.nOpen) or 0;	
	local nOldOpen = KGblTask.SCGetDbTaskInt(DBTASK_IBSHOPNOLIMIT_OPEN);
	if nOldOpen == nOpen then
		if nOpen == 1 then
			return "开关已经开启";
		else
			return "开关已经关闭";
		end
	end
	KGblTask.SCSetDbTaskInt(DBTASK_IBSHOPNOLIMIT_OPEN, nOpen);
	IbShop:OpenTimeFrameLimit();
	return 1;
end

--设置每天使用同伴经验书的数量，批量设置
--上次table文件，格式如下：
--Gate	nCount
--Gate1000	100
function GmCmd:SetPartnerExpBookCountFile(tbParam)
	local szPath = tbParam.szPath or "";
	if szPath == "" then
		return "出错啦！";
	end
	local tbFile = Lib:LoadTabFile(szPath);	
	if not tbFile then
		return "出错啦！";
	end	
	local tbCount = {};
	for nId, tbParamEx in ipairs(tbFile) do
		if nId >= 1 then
			local szGateway = tbParamEx.Gate or "";
			local nCount = tonumber(tbParamEx.nCount) or 0;		
			if szGateway ~= "" and nCount > 0 then
				tbCount[szGateway] = nCount;
			end
		end
	end	
	local szGatewayMe = GetGatewayName();
	if tbCount[szGatewayMe] then
		KGblTask.SCSetDbTaskInt(DBTASK_DAY_PARTNEREXPBOOK_COUNT, tbCount[szGatewayMe]);
		return 1;
	else
		return "没有设置该服务器的每天使用同伴经验书的数量！";
	end
end

--设置每天使用同伴经验书的数量
function GmCmd:SetPartnerExpBookCount(tbParam)
	local nCount = tonumber(tbParam.nCount) or 0;
	if nCount > 0 then
		KGblTask.SCSetDbTaskInt(DBTASK_DAY_PARTNEREXPBOOK_COUNT, nCount);
	end
end

--查询每天使用同伴经验书的数量
function GmCmd:QueryPartnerExpBookCount()
	local nCount = KGblTask.SCGetDbTaskInt(DBTASK_DAY_PARTNEREXPBOOK_COUNT);
	return string.format("设置每天使用同伴经验书的数量：\t%s", nCount);
end

--设置每天使用镶边帛帖的数量，批量设置
--上次table文件，格式如下：
--Gate	nCount
--Gate1000	100
function GmCmd:SetArrestPartnerBookCountFile(tbParam)
	local szPath = tbParam.szPath or "";
	if szPath == "" then
		return "出错啦！";
	end
	local tbFile = Lib:LoadTabFile(szPath);	
	if not tbFile then
		return "出错啦！";
	end	
	local tbCount = {};
	for nId, tbParamEx in ipairs(tbFile) do
		if nId >= 1 then
			local szGateway = tbParamEx.Gate or "";
			local nCount = tonumber(tbParamEx.nCount) or 0;		
			if szGateway ~= "" and nCount > 0 then
				tbCount[szGateway] = nCount;
			end
		end
	end	
	local szGatewayMe = GetGatewayName();
	if tbCount[szGatewayMe] then
		KGblTask.SCSetDbTaskInt(DBTASK_DAY_PARTNERARRESTBOOK_COUNT, tbCount[szGatewayMe]);
		return 1;
	else
		return "没有设置该服务器的每天使用镶边帛帖的数量！";
	end
end

--设置每天使用镶边帛帖的数量
function GmCmd:SetArrestPartnerBookCount(tbParam)
	local nCount = tonumber(tbParam.nCount) or 0;
	if nCount > 0 then
		KGblTask.SCSetDbTaskInt(DBTASK_DAY_PARTNERARRESTBOOK_COUNT, nCount);
	end
end

--查询每天使用镶边帛帖的数量
function GmCmd:QueryArrestPartnerBookCount()
	local nCount = KGblTask.SCGetDbTaskInt(DBTASK_DAY_PARTNERARRESTBOOK_COUNT);
	return string.format("设置每天使用镶边帛帖的数量：\t%s", nCount);
end

function GmCmd:ClearXoYoGameRank(tbParam)
	local nLevel = tonumber(tbParam.nLevel) or 0;	
	if nLevel ~= 0 then
		if not XoyoGame.tbXoyoRank[nLevel]  or #XoyoGame.tbXoyoRank[nLevel] == 0 then
			return "排行榜是空的，不需要清除。";
		end
		XoyoGame.tbXoyoRank[nLevel] = {};
	else
		if Lib:CountTB(XoyoGame.tbXoyoRank) == 0 then
			return "排行榜是空的，不需要清除。";
		end
		XoyoGame.tbXoyoRank = {};
	end
	SetGblIntBuf(GBLINTBUF_XOYO_RANK, 0, 1, XoyoGame.tbXoyoRank);
	XoyoGame:LoadRankData_GC();
	XoyoGame:ApplySyncData();
	return 1;
end

function GmCmd:QueryShiwuJiang(tbParam)
	local nType = tonumber(tbParam.nType) or 0;
	local nQueryDate = tonumber(tbParam.nDate) or 0;
	local tbDate = GetGblIntBuf(GBLINTBUF_SHIWUJIANGLI, 0) or {};
	local szMsg = "账号\t奖励物品类型\t玩家真实姓名\t联系电话\n"
	if nType == 0 then
		for nDate, tbInfor in pairs(tbDate) do
			for _, tbPlayerInfo in pairs(tbInfor) do
				szMsg = szMsg..string.format("%s\t%s\t%s\t%s\n", tbPlayerInfo[1], tbPlayerInfo[2], tbPlayerInfo[3], tbPlayerInfo[4]);
			end
		end
	elseif nType == 1 then
		for nDate, tbInfor in pairs(tbDate) do
			if nQueryDate >= nDate then
				for _, tbPlayerInfo in pairs(tbInfor) do
					szMsg = szMsg..string.format("%s\t%s\t%s\t%s\n", tbPlayerInfo[1], tbPlayerInfo[2], tbPlayerInfo[3], tbPlayerInfo[4]);
				end
			end
		end
	elseif nType == 2 then
		tbDate = tbDate[nQueryDate] or {};
		for _, tbPlayerInfo in pairs(tbDate) do
			szMsg = szMsg..string.format("%s\t%s\t%s\t%s\n", tbPlayerInfo[1], tbPlayerInfo[2], tbPlayerInfo[3], tbPlayerInfo[4]);			
		end
	end	
	return szMsg
end

function GmCmd:ClearShiwuJiang(tbParam)
	local nType = tonumber(tbParam.nType) or 0;
	local nClearDate = tonumber(tbParam.nDate) or 0;
	local tbDate = GetGblIntBuf(GBLINTBUF_SHIWUJIANGLI, 0);
	if nType == 0 then
		tbDate = {};
	elseif nType == 1 then
		for nDate, tbInfor in pairs(tbDate) do
			if nClearDate >= nDate then
				tbDate[nDate] = {};
			end
		end
	elseif nType == 2 then
		tbDate[nClearDate] = {};
	end
	SetGblIntBuf(GBLINTBUF_SHIWUJIANGLI, 0, 1, tbDate);
	SpecialEvent.tbShiwuJIang:LoadBuffer_GC();
	return 1;
end

function GmCmd:CreatRoleAward(tbParam)
	local nDate = tonumber(tbParam.nDate) or 0;
	local szAward = tbParam.szAward or "";
	--关闭指令	
	if (nDate >0 and Lib:GetDate2Time(nDate) <= GetTime()) or szAward == "" then
		return "指令有问题！";
	end
	local tbBuffer = GetGblIntBuf(GBLINTBUF_LOGIN_AWARD, 0);
	if not tbBuffer or type(tbBuffer) ~= "table" then
		tbBuffer = {};		
	end
	tbBuffer[1] = tbBuffer[1] or {};
	if nDate <= 0 then
		tbBuffer[1] = nil;
		SetGblIntBuf(GBLINTBUF_LOGIN_AWARD, 0, 1, tbBuffer);
		return 1;
	end
	local tbContent = {};	
	table.insert(tbContent, nDate);
	local tbAward = Lib:SplitStr(szAward, ";");
	for _, tb in pairs(tbAward) do
		local tbEx = Lib:SplitStr(tb);
		if #tbEx ~= 6 then
			return "指令有问题！";
		end
		for i, tb1 in pairs(tbEx) do
			tbEx[i] = tonumber(tb1);
		end
		table.insert(tbContent, tbEx);
	end
	tbBuffer[1] = tbContent;
	SetGblIntBuf(GBLINTBUF_LOGIN_AWARD, 0, 1, tbBuffer);
	return 1;
end

function GmCmd:QueryRoleAward(tbParam)
	local tbBuffer = GetGblIntBuf(GBLINTBUF_LOGIN_AWARD, 0);
	if not tbBuffer or type(tbBuffer) ~= "table" or not tbBuffer[1] then
		return "没有开启建立角色奖励。";
	end	
	local szMsg = "建立日期要求：";
	local nFlag = 0;
	for i, tb in pairs(tbBuffer[1]) do
		if i == 1 then			
			szMsg = szMsg..tb;
		else
			szMsg = szMsg..string.format("第%s个奖励项：", i - 1);
			for _, nId in pairs(tb) do
				szMsg = szMsg..nId..","
			end
		end
		nFlag = 1;	
	end
	if nFlag == 0 then
		return "没有开启建立角色奖励。";
	end
	return szMsg;
end

function GmCmd:CreatKinDiscount(tbParam)
	local nDate = tonumber(tbParam.nDate) or 0;
	local nDiscount = tonumber(tbParam.nDiscount) or 0;
	--关闭指令	
	if (nDate >0 and Lib:GetDate2Time(nDate) <= GetTime()) or nDiscount <= 0 or nDiscount > 10000 then
		return "指令有问题！";
	end
	local tbBuffer = GetGblIntBuf(GBLINTBUF_LOGIN_AWARD, 0);
	if not tbBuffer or type(tbBuffer) ~= "table" then
		tbBuffer = {};
	end
	tbBuffer[2] = tbBuffer[2] or {};
	if nDate <= 0 then
		tbBuffer[2] = nil;
		SetGblIntBuf(GBLINTBUF_LOGIN_AWARD, 0, 1, tbBuffer);
		return 1;
	end	
	tbBuffer[2][1] =  nDate;
	tbBuffer[2][2] =  nDiscount;	
	SetGblIntBuf(GBLINTBUF_LOGIN_AWARD, 0, 1, tbBuffer);
	return 1;
end

function GmCmd:QueryKinDiscount(tbParam)
	local tbBuffer = GetGblIntBuf(GBLINTBUF_LOGIN_AWARD, 0);
	if not tbBuffer or type(tbBuffer) ~= "table" or not tbBuffer[2] then
		return "没有开启奖励家族优惠奖励。";
	end
	local nFlag = 0;
	local szMsg = "建立日期要求：";
	for i, n in pairs(tbBuffer[2]) do
		if i == 1 then
			szMsg = szMsg..n;
		else
			szMsg = szMsg..string.format("折扣率：%s/10000", n)
		end
		nFlag = 1;	
	end	
	if nFlag == 0 then
		return "没有开启奖励家族优惠奖励。";
	end
	return szMsg;
end

--功能：开启福利精活优惠
--参数格式：{S={0},E={1}}
--S为开始时间，E为结束时间，格式为YYYYmmddHH
function GmCmd:OpenFuliJIngHuo(tbParam)
	local tbEvent = {};
	local nEventId = 20;
	local nPartId = 7;
	local nPartIdEx = 8;
	tbEvent[nEventId] = tbEvent[nEventId] or {};
	tbEvent[nEventId].tbPart = tbEvent[nEventId].tbPart or {};
	tbEvent[nEventId].tbPart[nPartId] = tbEvent[nEventId].tbPart[nPartId] or {};
	tbEvent[nEventId].tbPart[nPartIdEx] = tbEvent[nEventId].tbPart[nPartIdEx] or {};
	local nStartTime = Lib:GetDate2Time(tbParam.S);
	local nEndTime = Lib:GetDate2Time(tbParam.E);
	tbEvent[nEventId].tbPart[nPartId].nStartDate = tonumber(os.date("%Y%m%d%H%M", nStartTime));
	tbEvent[nEventId].tbPart[nPartId].nEndDate  = tonumber(os.date("%Y%m%d%H%M", nEndTime));
	tbEvent[nEventId].tbPart[nPartIdEx].nStartDate = tonumber(os.date("%Y%m%d%H%M", nStartTime));
	tbEvent[nEventId].tbPart[nPartIdEx].nEndDate  = tonumber(os.date("%Y%m%d%H%M", nEndTime));
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent);
	return 1;
end

-- 功能：查询待纠正的网关名列表
function GmCmd:QueryNameServerModifyList(tbParam)
	local tbBuff = GetGblIntBuf(GBLINTBUF_NAMESERER_MODIFY, 0);
	if not tbBuff or Lib:CountTB(tbBuff) == 0 then
		return "null";
	end
	
	local szMsg = "";
	for szNewGate, tbInfo in pairs(tbBuff) do
		szMsg = szMsg .. "---------------------------------------\n";
		szMsg = szMsg .. "NewGate:\t" .. szNewGate .. "\n";
		local nOldCount = 1;
		for szOldGate, _ in pairs(tbInfo) do
			szMsg = szMsg .. "OldGate" ..nOldCount..":\t" .. szOldGate .. "\n";
			nOldCount = nOldCount + 1;
		end		
	end
	
	return szMsg;	
end

-- 功能：执行网关名纠正操作
-- {"szOldGate, szNewGate, szRole"}
function GmCmd:ExcuteNameServerModify(tbParam)
	local szOldGate = tbParam.szOldGate;
	local szNewGate = tbParam.szNewGate;
	local szRole = tbParam.szRole or "";
	
	local bFromBuff = 2;	-- 默认操作环境2
	local tbBuff = {};
	if not szOldGate or not szNewGate or szOldGate == "" or szNewGate == "" then
		szRole = "";
		tbBuff = GetGblIntBuf(GBLINTBUF_NAMESERER_MODIFY, 0);
		bFromBuff = 1;		-- 这样是操作环境1
	else
		tbBuff[szNewGate] = {[szOldGate] = 1}; 
	end
			
	if not tbBuff or Lib:CountTB(tbBuff) == 0 then
		return 0, bFromBuff;
	end

	for _szNewGate, tbInfo in pairs(tbBuff) do
		for _szOldGate, _ in pairs(tbInfo) do
		ApplyModifyNameServerGate(_szOldGate, _szNewGate, szRole);
		end
	end
	
	if (bFromBuff == 1) then
		SetGblIntBuf(GBLINTBUF_NAMESERER_MODIFY, 0, 1, {});
	end
	
	return 1, bFromBuff;	
end

--load美女决赛名单
function GmCmd:LoadGirlList(tbParam)
	local szPath = tbParam.szPath or "";
	SpecialEvent.Girl_Vote:LoadPassGirlFile(szPath);
end

--load美女认证标志
function GmCmd:LoadGirlLogo(tbParam)
	local szPath = tbParam.szPath or "";
	SpecialEvent.Girl_Vote:LoadGirlLogoFile(szPath);
end

--加载战区城主数据，进行展示
function GmCmd:LoadGlobalAreaCityer(tbParam)
	local szPath = tbParam.szPath or "";
	Newland:LoadCityCaptainFile(szPath)
end

--功能：开启宋金奖励翻倍
--参数格式：{S="YYYYmmddHH",E="YYYYmmddHH",nCount="2"}
--S为开始时间，E为结束时间，格式为YYYYmmddHH。nCount为翻的倍数
function GmCmd:OpenKinPlant(tbParam)
	local tbEvent = {};
	local nEventId = 20;
	local nPartId = 9
	tbEvent[nEventId] = tbEvent[nEventId] or {};
	tbEvent[nEventId].tbPart = tbEvent[nEventId].tbPart or {};
	tbEvent[nEventId].tbPart[nPartId] = {};
	tbEvent[nEventId].tbPart[nPartId].szName = string.format("开启家族种植%s倍",tbParam.nCount);
	tbEvent[nEventId].tbPart[nPartId].szSubKind = "default";
	local nStartTime = Lib:GetDate2Time(tbParam.S);
	local nEndTime = Lib:GetDate2Time(tbParam.E);
	tbEvent[nEventId].tbPart[nPartId].nStartDate = tonumber(os.date("%Y%m%d%H%M", nStartTime));
	tbEvent[nEventId].tbPart[nPartId].nEndDate  = tonumber(os.date("%Y%m%d%H%M", nEndTime));
	tbEvent[nEventId].tbPart[nPartId].tbExParam = {string.format("SetKinPlantTimes:%s", tbParam.nCount)};	
	EventManager.KingEyes:SaveBuf(tbEvent);
	EventManager.KingEyes:UpdateEvent(tbEvent);
	return 1;
end

--功能：给家族角色发邮件
--参数格式：家族名\t邮件标题\t邮件正文内容
function GmCmd:SendKinMail(tbData)
	local szKin = tbData.szKin;
	local szTitle = tbData.szTitle;
	local szContent = tbData.szContent;
	local pKin = KKin.FindKin(szKin);
	local nRet = 0;
	if (pKin) then
		local itor = pKin.GetMemberItor();
		local cMember = itor.GetCurMember();
		while cMember do
			local nPlayerId = cMember.GetPlayerId();
			if SendMailGC(nPlayerId, szTitle, szContent) == 1 and nRet == 0 then
				nRet = 1;
			end
			cMember = itor.NextMember();
		end
	end
	return nRet;
end

--功能：批量给家族角色发邮件
--参数格式：家族名\t邮件标题\t邮件正文内容
function GmCmd:SendKinListMail(tbData)
	local szPath = tbData.szPath or "";
	local szTitle = tbData.szTitle;
	local szContent = tbData.szContent;
	local tbFile = Lib:LoadTabFile(szPath)
	if not tbFile then
		print("【LoadPassGirlFile】找不到该路径文件", szPath);
		return 0;
	end
	self.tbKinSendMail_List = tbFile;
	self.nKinSendMail_Id = 1;
	Timer:Register(1, self.PerKinSendMail_Timer, self, szTitle, szContent);
end

function GmCmd:PerKinSendMail_Timer(szTitle, szContent)
	if self.nKinSendMail_Id > #self.tbKinSendMail_List or not self.tbKinSendMail_List[self.nKinSendMail_Id] then
		return 0;
	end
	local szKin = self.tbKinSendMail_List[self.nKinSendMail_Id].KinName or "";
	local szGateway = self.tbKinSendMail_List[self.nKinSendMail_Id].GatewayId or "";
	if GetGatewayName() == szGateway then
		local pKin = KKin.FindKin(szKin);
		if (pKin) then
			local itor = pKin.GetMemberItor();
			local cMember = itor.GetCurMember();
			while cMember do
				local nPlayerId = cMember.GetPlayerId();
				SendMailGC(nPlayerId, szTitle, szContent);
				cMember = itor.NextMember();
			end
		end
	end
	self.nKinSendMail_Id = self.nKinSendMail_Id + 1;
	return;
end

-- 功能：批量发送公告
-- 参数格式：szPath:文件路径
function GmCmd:BatchMsg(tbParam)
	local tbData = Lib:LoadTabFile(tbParam.szPath);
	if not tbData then
		return "szDataPath Error:" .. (tbParam.szPath or "");
	end
	local tbMsg = {};
	local nIndex = 1;
	for _, tbRow in ipairs(tbData) do
		if tbRow.GatewayID == GetGatewayName() then
			if tbRow.HelpTitle and tbRow.HelpTitle ~= "" then
				local tbHelp = {};
				tbHelp.szTitle = tbRow.HelpTitle;
				tbHelp.szMsg = tbRow.HelpMsg;
				tbHelp.nAddTime = tbRow.HelpAddTime;
				tbHelp.nEndTime = tbRow.HelpEndTime;
				self:AddNewHelpMsg(tbHelp);
			end
			if tbRow.Chat and tbRow.Chat ~= "" then
	 			GlobalExcute({"KDialog.Msg2SubWorld", tbRow.Chat});
			end
			if tbRow.News and tbRow.News ~= "" then
				GlobalExcute({"KDialog.NewsMsg", 0, Env.NEWSMSG_NORMAL, tbRow.News});
			end
		end
	end
	return 1;
end

-- 功能：批量发送邮件，每个玩家的内容各不相同
-- 参数格式：szPath:文件路径
function GmCmd:BatchPlayerMail(tbParam)
	local tbData = Lib:LoadTabFile(tbParam.szPath);
	if not tbData then
		return "szDataPath Error:" .. (tbParam.szPath or "");
	end
	local tbMailList = {};
	local tbCount = {};
	for i, tbRow in ipairs(tbData) do
		if not tbRow.GatewayID or not tbRow.RoleName or not tbRow.Title or not tbRow.Content then
			return "Data Error, Index:" .. (i+1);
		end
		tbCount[tbRow.GatewayID] = tbCount[tbRow.GatewayID] or 0;
		tbCount[tbRow.GatewayID] = tbCount[tbRow.GatewayID] + 1;
		local nIndex = tbCount[tbRow.GatewayID];
		if nIndex > 20 then
			return tbRow.GatewayID .. "名单个数超过20个";
		end
		if tbRow.GatewayID == GetGatewayName() then
			tbMailList[nIndex] = {};
			tbMailList[nIndex].szRoleName = tbRow.RoleName;
			tbMailList[nIndex].szTitle = tbRow.Title;
			tbMailList[nIndex].szContent = tbRow.Content;
			-- 检查角色名字和gateway是否有错
			local nPlayerId = KGCPlayer.GetPlayerIdByName(tbRow.RoleName);
			if not nPlayerId or nPlayerId == 0 then
				return string.format("行：%s,角色名字[%s]与gateway[%s]不对应", i+1, tbRow.RoleName, tbRow.GatewayID);
			end
		end
	end
	for _, tbTemp in ipairs(tbMailList) do
		SendMailGC(tbTemp.szRoleName, tbTemp.szTitle, tbTemp.szContent)
	end
	return 1;
end

function GmCmd:SetOlympicGameInfo(tbParam)
	local nDay = tonumber(tbParam.nDay)  or 0;
	local nGold = tonumber(tbParam.nGold)  or 0;
	local nSliver = tonumber(tbParam.nSliver)  or 0;
	local nBonze = tonumber(tbParam.nBonze)  or 0;
	if nDay <= 20120727 then
		return "日期设置不正确，奥运活动比赛日从2012年07月28日开始。";
	end
	nDay = math.floor((Lib:GetDate2Time(nDay) - Lib:GetDate2Time(20120727)) / 24 / 3600);
	return SpecialEvent.tbShengXia2012:SetBuffer(nDay, nGold, nSliver, nBonze);
end

function GmCmd:ClearGirlVoteTitle(tbParam)
	local szPlayerName = tbParam.szPlayerName;
	local szMsg = tbParam.szMsg;
	if not KGCPlayer.GetPlayerIdByName(szPlayerName) then
		return "不存在该角色:"..szPlayerName;
	end
	
	local szScript = "";
	if szMsg ~= "" then
		szScript = string.format([[
			me.SetTask(2189,522,-1)
			me.SetTask(2189,523,0)
			me.SetTask(2189,524,0)
			me.Msg("%s");
		]], szMsg)
	else
		szScript = [[
			me.SetTask(2189,522,-1)
			me.SetTask(2189,523,0)
			me.SetTask(2189,524,0)
		]];
	end
	GM:AddOnLine("", "", szPlayerName, 0, 0, szScript,1);
	return 1;
end
