-------------------------------------------------------------------
--File: c2scall.lua
--Author: lbh
--Date: 2007-7-31 10:05
--Describe: 客户端调用服务端脚本接口
-------------------------------------------------------------------
if not MODULE_GAMESERVER then
	--最好不要在客户端暴露此文件
	--error("Only For Gameserver")
	return
end

--召唤令牌回调
function c2s:ZhaoHuanLingPaiCmd(nMapId, nPosX, nPosY, nMemberPlayerId, nFightState, bAccept)
	--print("ZhaoHuanLingPaiCmd", nMapId, nPosX, nPosY, nMemberPlayerId, nFightState, bAccept)	
	Item.tbZhaoHuanLingPai:PlayerAccredit(nMapId, nPosX, nPosY, nMemberPlayerId, nFightState, bAccept);
end

function c2s:BuyOverCmd(nNum, nOffset)
	SpecialEvent.BuyOver:OnClientCall(nNum, nOffset);
end

function c2s:HelpManCmd(szName)
	--print("HelpMan", szName, "点开次数");
end

function c2s:NewPlayerUiCmd(...)
	local fun = Log.Ui_LogSetValue
	if not fun then
		print("c2s NewPlayerUi Command Error Called: Ui_LogSetValue")
		return
	end
	fun(Log, unpack(arg))
end

function c2s:PartnerCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return
	end
	local fun = Partner.c2sFun[szFun]
	if not fun then
		print("c2s Partner Command Error Called: "..szFun)
		return
	end
	fun(Partner, unpack(arg))
end

function c2s:PlayerCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return
	end
	local fun = Player.c2sFun[szFun]
	if not fun then
		print("c2s Player Command Error Called: "..szFun)
		return
	end
	fun(Player, unpack(arg))
end

function c2s:ZhenYuanCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return;
	end
	local fun = Item.tbZhenYuan.c2sFun[szFun];
	if not fun then
		print("c2s ZhenYuan Command Error Called: "..szFun)
		return
	end
	fun(Item.tbZhenYuan, unpack(arg))
end

function c2s:KinCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return
	end
	local fun = Kin.c2sFun[szFun]
	if not fun then
		print("c2s Kin Command Error Called: "..szFun)
		return
	end
	fun(Kin, unpack(arg))
end

function c2s:TongCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return
	end
	local fun = Tong.c2sFun[szFun]
	if not fun then
		print("c2s Tong Command Error Called: "..szFun)
		return
	end
	fun(Tong, unpack(arg))
end

function c2s:DlgCmd(szFun, varValue)
	if type(szFun) ~= "string" then
		return
	end
	if (szFun == "InputNum") then
		local nNum	= tonumber(varValue);
		if not nNum then
			return
		end
		nNum	= math.floor(nNum);
		if (nNum < 0 or nNum > 20*10000*10000) then	-- 暂不允许负数和20亿以上
			ServerEvent:WriteLog(Dbg.LOG_ERROR, "DlgCmd-InputNum Error!", me.szName, me.szAccount, nNum);
			return;
		end
		Dialog:OnOk("tbNumberCallBack", nNum);
	elseif (szFun == "InputTxt") then
		Dialog:OnOk("tbStringCallBack", tostring(varValue));
	end
end

function c2s:MailCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return;
	end
	local fun = Mail.tbc2sFun[szFun];	
	if not fun then
		print("c2s Mail Command Error Called: "..szFun);
		return;
	end
	fun(Mail, unpack(arg));
end

function c2s:HlpQue(nGroupId)
	if (type(nGroupId) ~= "number") then
		return;
	end
	HelpQuestion:StartGame(me, nGroupId)
end

function c2s:OfflineBuy(nType, nCount)
	if (not nType or not nCount or 0 == Lib:IsInteger(nType) or 0 == Lib:IsInteger(nCount)) then
		return;
	end
	nType	= math.floor(nType);
	nCount	= math.floor(nCount);
	-- assert(nType >= 1 and nType <= Item.IVER_nOpenBaiJuWanLevel); --改成return zounan
	if nType < 1 or nType > Item.IVER_nOpenBaiJuWanLevel then
		Player:ProcessIllegalProtocol("c2s:OfflineBuy","nType",nType);	
		return;
	end
	--assert(nCount > 0 and nCount < 10000); --改成return zounan
	if nCount <= 0 or nCount >= 10000 then
		Player:ProcessIllegalProtocol("c2s:OfflineBuy","nCount",nCount);	
		return;
	end
	Player.tbOffline:OnBuy(nType, nCount);
end

function c2s:JingHuoBuy(nType, nCount)
	--if (not nType or not nCount or 0 == Lib:IsInteger(nType) or 0 == Lib:IsInteger(nCount)) then	购买精活的数目已经限定了 故不需要nCount
	if (not nType or 0 == Lib:IsInteger(nType)) then
		return;
	end	
	nType	= math.floor(nType);
	-- nCount	= math.floor(nCount);  -- nCount没有用到
	--assert(nType >= 1 and nType <= 2); --改成return zounan
	if(nType < 1 or nType > 2) then	
		Player:ProcessIllegalProtocol("c2s:JingHuoBuy","nType",nType);		
		return;
	end

	if nCount <= 0 or nCount >= 10000 then
		Player:ProcessIllegalProtocol("c2s:JingHuoBuy","nCount",nCount);	
		return;
	end

--	assert(nCount > 0 and nCount < 10000);
	Player.tbBuyJingHuo:BuyItem(nType, nCount);
end

function c2s:ApplyBuyJiuZhuan()
	Player:ApplyBuyAndUseJiuZhuan();
end

function c2s:ApplyBuyQianLiChuanYin()
	if (IsGlobalServer()) then
		me.Msg("跨服状态不能购买此道具。")
	else
		me.ApplyAutoBuyAndUse(216, 1);
	end
end
	
function c2s:JbExchangeCmd(szFun, ...)
	if (type(szFun) ~= "string") then
		return;
	end
	local fun = JbExchange.tbc2sFun[szFun];
	if not fun then
		print("c2s JbExchange Error Called:".. szFun);
		return;
	end
	fun(JbExchange, unpack(arg));
end

function c2s:LadderApplyCmd(nValue1, nValue2)
	if type(nValue1) ~= "number" or type(nValue2) ~= "number" then
		return;
	end
	Ladder:OnApplyLadder(nValue1, nValue2);
end

function c2s:LadderListApplyCmd(nValue1, nValue2)
	if (type(nValue1) ~= "number" or type(nValue2) ~= "number") then
		return;
	end
	Ladder:OnApplyList(nValue1, nValue2);
end

function c2s:LadderSearchListApplyCmd(nValue, szValue)
	if (type(nValue) ~= "number" or type(szValue) ~= "string") then
		return;
	end
	Ladder:OnApplySearchResult(nValue, szValue, 1);
end

function c2s:LadderApplyAdvSearchCmd(nValue1, nValue2, nValue3, szValue)
	if (type(nValue1) ~= "number" or type(nValue2) ~= "number" or type(nValue3) ~= "number" or type(szValue) ~= "string") then
		return;
	end
	Ladder:OnApplyAdvSearch(nValue1, nValue2, nValue3, szValue);	
end

function c2s:ApplyUpdateOnlineState(nValue)
	if (type(nValue) ~= "number") then
		return;
	end
	Player.tbOnlineExp:OnApplyUpdateState((nValue == 1 and 1) or 0);
end

function c2s:FightAfterRefresh(szInstanceId)
	FightAfter:OnPlayerRefresh(szInstanceId);
end

function c2s:FightAfterAward(szInstanceId)
	FightAfter:Award(me,szInstanceId);
end

function c2s:LadderGuidCmd(szFunc, ...)
	if Ladder.tbGuidLadder.tbC2SCall[szFunc] == 1 then
		Ladder.tbGuidLadder[szFunc](Ladder.tbGuidLadder, ...);
	end
end

function c2s:ApplyEscLooker()
	Looker:Leave(me);
end

function c2s:PlayerPrayCmd()
	Task.tbPlayerPray:OnApplyGetResult();
end

function c2s:ApplyGetPrayAward()
	if (Player:CheckForbidGetItem("playerpray") == 1) then
		return 0;
	end
	
	Task.tbPlayerPray:OnApplyGetAward();
end

-- 百宝箱
function c2s:ApplyBaibaoxiangGetResult(nCoin)
	Baibaoxiang:OnPlayerGetResult(nCoin);
end

function c2s:ApplyBaibaoxiangGetAward(nType)
	Baibaoxiang:OnPlayerGetAward(nType);
end
-- end

-- 游龙秘宝
function c2s:ApplyYoulongmibaoGetAward(nType)
	Youlongmibao:OnPlayerGetAward(nType);
end

function c2s:ApplyYoulongmibaoContinue()
	Youlongmibao:OnPlayerContinue();
end

function c2s:ApplyYoulongmibaoRestart()
	Youlongmibao:OnPlayerRestart();
end

function c2s:ApplyYoulongmibaoLeaveHere()
	Youlongmibao:OnPlayerLeave();
end

function c2s:ApplyYoulongmibaoShowAward()
	Youlongmibao:OnPlayerShowAward();
end


--战后系统
function c2s:ApplyAwardRefresh(szInstanceId)
	FightAfter:OnPlayerRefresh(szInstanceId);
end

--预更新 记录LOG
function c2s:PreUpdateLog(szLog)
	Log.__tbUpdateLogCount = Log.__tbUpdateLogCount or {};
	Log.__tbUpdateLogCount[szLog] = (Log.__tbUpdateLogCount[szLog] or 0) + 1;
	Dbg:WriteLog("PreUpdateLog", me.szName, szLog);
end

-- 客户端安装情况统计，每个客户端只会发一次
function c2s:InstallInfoLog(szKey)
	if (not szKey or type(szKey) ~= "string" or string.len(szKey) >= 1024) then
		return;
	end
	Dbg:WriteLog("InstallInfo", szKey);
end

-- end

function c2s:AccountCmd(nId, ...)
	Account:ProcessClientCmd(nId, arg);
end

function c2s:ProCmd(szFun,...)
	if type(szFun) ~= "string" then
		return
	end
	local fun = PProfile.c2sFun[szFun]
	if not fun then
		print("c2s PlayerProfile Command Error Called: "..szFun)
		return
	end
	fun(PProfile, unpack(arg))
end

function c2s:DomainCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return
	end
	local fun = Domain.c2sFun[szFun]
	if not fun then
		print("c2s Domain Command Error Called: "..szFun)
		return
	end
	fun(Domain, unpack(arg))
end

function c2s:HonorDataApplyCmd()
	PlayerHonor:SendHonorData();
end

function c2s:ApplyAccountInfo()
	me.ApplyAccountInfo();
end

function c2s:BankCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return;
	end
	local fun = Bank.tbc2sFun[szFun];
	if not fun then
		print("c2s Bank Error Called:".. szFun);
		return;
	end
	
	if (Bank.nBankState == 0) then
		me.Msg("钱庄暂时没有开放。");
		return ;
	end
	
	fun(Bank, unpack(arg));
end

function c2s:ClientProInfo(szFun, ...)
	if (type(szFun) ~= "string") then
		return 0;
	end
	local fun = Player.tbAntiBot.tbCProInfo.tbc2sFun[szFun];
	if (not fun) then
		return 0;
	end
	fun(Player.tbAntiBot.tbCProInfo, unpack(arg));
	return 1;
end

function c2s:RecvCData(szFun, ...)
	if (type(szFun) ~= "string") then
		return 0;
	end
	local szName, nFileIndex, nEndFlag, szMsg = unpack(arg);
	if (type(szName) ~= "string" or type(nFileIndex) ~= "number" or type(nEndFlag) ~= "number" or type(szMsg) ~= "string") then
		return 0;
	end
	local fun = Player.tbAntiBot.tbCProInfo.tbc2sFun[szFun];
	if (not fun) then
		return 0;
	end
	fun(Player.tbAntiBot.tbCProInfo, unpack(arg));
end

function c2s:AuctionCmd(szFun, ...)
	if (type(szFun) ~= "string") then
		return 0;
	end	
	local fun = Auction.tbc2sFun[szFun];
	if (not fun )then
		return 0;
	end
	fun(Auction, unpack(arg));
end

function c2s:RelationCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return;
	end
	local fun = Relation.tbc2sFun[szFun];
	if not fun then
		print("c2s Relation Error Called:".. szFun);
		return;
	end
	
	fun(Relation, unpack(arg));
end

function c2s:PlatformDataApplyCmd()
	EPlatForm:ApplyKinEventPlatformData();
end

function c2s:AchievementCmd_ST(szFun, ...)
	if (type(szFun) ~= "string") then
		return;
	end
	local fun = Achievement_ST.tbc2sFun[szFun];
	if (not fun) then
		print("c2s Achievement_ST Error Called:".. szFun);
		return;
	end
	
	fun(Achievement_ST, unpack(arg));
end

-- 师徒传送
function c2s:ShiTuChaunSongCmd(szFun, ...)
	if (type(szFun) ~= "string") then
		return;
	end
	local fun = Item.tbShiTuChuanSongFu.tbc2sFun[szFun];
	if (not fun) then
		print("c2s ShiTuChaunSong Error Called:".. szFun);
		return;
	end
	
	fun(Item.tbShiTuChuanSongFu, unpack(arg));
end

-- 调查问卷
function c2s:Questionnaires(nStaus)
	SpecialEvent.Questionnaires:OnAnswer(tonumber(nStaus));
end

-- 夫妻传送
function c2s:tbFuQiChuanSongCmd(szFun, ...)
	if (type(szFun) ~= "string") then
		return;
	end
	local fun = Item.tbFuQiChuanSongFu.tbc2sFun[szFun];
	if (not fun) then
		print("c2s FuQiChaunSong Error Called:".. szFun);
		return;
	end
	
	fun(Item.tbFuQiChuanSongFu, unpack(arg));
end

-- 使用无限传送符
function c2s:UseUnlimitedTrans(nMapId)
	if tonumber(nMapId) == nil then
		return;
	end
	Item:GetClass("chuansongfu"):OnClientCall(math.floor(nMapId));
end

-- 使用乾坤符传送
function c2s:UseQiankunfuTrans(nPlayerId)
	if type(nPlayerId) ~= "number" then
		return;
	end
	Item:GetClass("qiankunfu"):OnClientCall(nPlayerId);
end

function c2s:RecordPluginUseState(szName, nPluginNum)
	if (not szName or nPluginNum >= 1) then
		local szLog = string.format("玩家\t%s\t使用了插件，插件数量\t%s", szName, nPluginNum);
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Player", "plugin_log", szLog);
	end
end

-- 在线充值页面申请区服名
function c2s:ApplyOpenOnlinePay()
	local szZoneName = GetZoneName();
	me.CallClientScript({"Ui:ServerCall", "UI_PAYONLINE", "OnRecvZoneOpen", szZoneName});	
end

-- 在线领取
function c2s:AwordOnline()
	if (Player:CheckForbidGetItem("onlineaward") == 1) then
		return 0;
	end
	SpecialEvent.tbAwordOnline:GetAword();
end

-- 在线领取
function c2s:AwordDaily()
	if (Player:CheckForbidGetItem("onlineaward") == 1) then
		return 0;
	end

	if EventManager.IVER_bOpenZaiXian1 == 1 and EventManager.IVER_bOpenZaiXian == 1 then
		SpecialEvent.tbAword:GetAwordDaily();
	end
end

function c2s:AwordLogIn()
	if (Player:CheckForbidGetItem("onlineaward") == 1) then
		return 0;
	end

	if EventManager.IVER_bOpenZaiXian2 == 1 and EventManager.IVER_bOpenZaiXian == 1 then
		SpecialEvent.tbAword:GetAwordLogIn();
	end
end

function c2s:AwordOnlineEx()
	if (Player:CheckForbidGetItem("onlineaward") == 1) then
		return 0;
	end

	if EventManager.IVER_bOpenZaiXian3 == 1 and EventManager.IVER_bOpenZaiXian == 1 then
		SpecialEvent.tbAword:GetAwordOnline();
	end
end

function c2s:AwordUpLevel()
	if (Player:CheckForbidGetItem("onlineaward") == 1) then
		return 0;
	end

	if EventManager.IVER_bOpenZaiXian4 == 1 and EventManager.IVER_bOpenZaiXian == 1 then
		SpecialEvent.tbAword:GetAwordUpLevel();
	end
end

function c2s:GlobalFriendsCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return
	end
	local fun = Player.tbGlobalFriends[szFun]
	if not fun then
		print("c2s GlobalFriends Command Error Called: "..szFun)
		return
	end
	fun(Player.tbGlobalFriends, unpack(arg))
end

-- 玩家退出挽留界面操作（购买白驹）
function c2s:Detain_BuyBaiju()
	Player.tbOffline:Detain_BuyBaijuDlg();
end

-- 世界杯获取自己的排名成绩
function c2s:GetMyRank_Num()
	SpecialEvent.tbWroldCup:GetMyRank_Num();
end

function c2s:ApplySureMatchRoundCmd(tbRound)
	if (type(tbRound) ~= "table") then
		return;
	end
	Wlls:OnGivePkChoosePlayerResult(tbRound);
end

--启动进度条
function c2s:StartProcess(szText, nTime, tbEvent)
	GeneralProcess:StartProcessByClient(szText, nTime, tbEvent);
end


function c2s:AchievementCmd(szFun, ...)
	if (type(szFun) ~= "string") then
		return;
	end
	local fun = Achievement.tbc2sFun[szFun];
	if (not fun) then
		print("c2s Achievement Error Called:".. szFun);
		return;
	end
	
	fun(Achievement, unpack(arg));
end

--确定是否重铸，原在item里
function c2s:ConfirmRecast(nRequest,nEquipId,nIndex)
	if not nEquipId then
		--提示重铸失败,记录log
		me.GetTempTable("Item").tbEquip = nil
		Dbg:WriteLog("Recast", "角色名:"..me.szName, "帐号:"..me.szAccount, "传入装备id异常");
		return 0;
	end
	if not me.GetTempTable("Item").tbEquip 
		or me.GetTempTable("Item").tbEquip.dwEquipId ~= nEquipId then
		Dbg:WriteLog("Recast", "角色名:"..me.szName, "帐号:"..me.szAccount, "重复确认或者传入装备id异常");
		return 0;
	end
	if nRequest == 0 then	--选择重铸界面上的取消和esc
		local tbEquip = me.GetTempTable("Item").tbEquip;
		if tbEquip and tbEquip.dwEquipId == nEquipId then
			local bBind = tbEquip.nItemBindType;
			local pEquip = KItem.GetObjById(tbEquip.dwEquipId);
			if bBind == 1 and pEquip then				
				pEquip.Bind(1);					-- 强制绑定装备
				Spreader:OnItemBound(pEquip);
			end
			
			--客服log------------
			if pEquip then
				local szPlayerLog = string.format("玩家: %s ,重铸装备{%s_%d} ,放弃重铸的新装备",me.szName, pEquip.szName, pEquip.nEnhTimes);
				me.PlayerLog(Log.emKITEMLOG_TYPE_USE, szPlayerLog);
			end
		end
		me.GetTempTable("Item").tbEquip = nil;
		Dbg:WriteLog("Recast", "角色名:"..me.szName, "帐号:"..me.szAccount, "放弃重铸的新装备");
		
		return 1;
	elseif nRequest == 1 then
		if nIndex == 1 then
			local tbEquip = me.GetTempTable("Item").tbEquip;
			if tbEquip and tbEquip.dwEquipId == nEquipId then
				local bBind = tbEquip.nItemBindType;
				local pEquip = KItem.GetObjById(tbEquip.dwEquipId);
				if bBind == 1 and pEquip then
					pEquip.Bind(1);					-- 强制绑定装备
					Spreader:OnItemBound(pEquip);
				end
				
				--客服log------------
				if pEquip then
					local szPlayerLog = string.format("玩家: %s ,重铸装备{%s_%d} ,放弃重铸的新装备",me.szName, pEquip.szName, pEquip.nEnhTimes);
					me.PlayerLog(Log.emKITEMLOG_TYPE_USE, szPlayerLog);
				end
			end
			me.GetTempTable("Item").tbEquip = nil;	--清空临时table
			Dbg:WriteLog("Recast", "角色名:"..me.szName, "帐号:"..me.szAccount, "选择旧装备");
					
			return 1;
		elseif nIndex == 2 then
			local pEquip = KItem.GetObjById(nEquipId);
			local nNewRandSeed = me.GetTempTable("Item").tbEquip.nNewRandSeed;
			local tbRandMa	   = me.GetTempTable("Item").tbEquip.tbRandMa;
			local bBind		   = me.GetTempTable("Item").tbEquip.nItemBindType;
			--Lib:ShowTB(tbRandMa)
			if not nNewRandSeed then
				Dbg:WriteLog("Recast", "角色名:"..me.szName, "帐号:"..me.szAccount, "传入随机种子异常");
				me.GetTempTable("Item").tbEquip = nil;--清空临时table
				return 0;
			end
			if not tbRandMa then
				Dbg:WriteLog("Recast", "角色名:"..me.szName, "帐号:"..me.szAccount, "传入随机种子table异常");
				me.GetTempTable("Item").tbEquip = nil;--清空临时table
				return 0;
			end
			if not pEquip then
				Dbg:WriteLog("Recast", "角色名:"..me.szName, "帐号:"..me.szAccount, "重铸的装备异常");
				me.GetTempTable("Item").tbEquip = nil;--清空临时table
				return 0;
			end
			
			local nRet = pEquip.Regenerate(
			pEquip.nGenre,
			pEquip.nDetail,
			pEquip.nParticular,
			pEquip.nLevel,
			pEquip.nSeries,
			pEquip.nEnhTimes,
			pEquip.nLucky,
			pEquip.GetGenInfo(),
			0,
			nNewRandSeed,
			pEquip.nStrengthen,
			tbRandMa
			);
			if nRet ~= 1 then
				Dbg:WriteLog("Recast", "角色名:"..me.szName, "帐号:"..me.szAccount, "Regenerate道具失败");
				me.GetTempTable("Item").tbEquip = nil;--清空临时table
				return 0;
			end
			if bBind == 1 then
				pEquip.Bind(1);  	-- 强制绑定
				Spreader:OnItemBound(pEquip);
			end
			me.GetTempTable("Item").tbEquip = nil;	--清空临时table
			me.Msg("您获得了<color=gold>"..pEquip.szName.."<color>");
			
			--客服log------------
			local szPlayerLog = string.format("玩家: %s ,重铸装备{%s_%d} ,选择新装备",me.szName, pEquip.szName, pEquip.nEnhTimes);
			me.PlayerLog(Log.emKITEMLOG_TYPE_USE, szPlayerLog);
			
			return 1;
		else
			Dbg:WriteLog("Recast", "角色名:"..me.szName, "帐号:"..me.szAccount, "传入index异常");
			me.GetTempTable("Item").tbEquip = nil;	--清空临时table
			return 0;
		end
	else
		Dbg:WriteLog("Recast", "角色名:"..me.szName, "帐号:"..me.szAccount, "传入request异常");
		me.GetTempTable("Item").tbEquip = nil;	--清空临时table
		return 0;
	end
end

--接受客户端失败消息,Reason为1表示修改客户端引起的道具异常
function c2s:ReceiveRecastError(nReason)
	if nReason == 1 then	
		Dbg:WriteLog("Recast", me.szName,me.szAccount,"修改客户端引起道具异常");
		me.GetTempTable("Item").tbEquip = nil;
	end
end

--SNS功能
function c2s:SnsCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return
	end
	local fun = Sns.tbc2sFun[szFun];
	if not fun then
		print("c2s Sns Error Called:" .. szFun);
		return;
	end
	fun(Sns, ...);
end


--Add by zhangzhixiong in 2011.3.24
function c2s:WriteClientInfoToLog(...)
	local fGamePlayTime,fGameActiveTime,nMouseClickNum,nKeyboardClickNum,nClientInstanceCurrentNum = unpack(arg);
	if (type(fGamePlayTime) ~= "number" or type(fGameActiveTime) ~= "number" or
		 type(nMouseClickNum) ~= "number" or type(nKeyboardClickNum) ~= "number") then
		return 0;
	end
	StatLog:WriteStatLog("stat_info","game_client","client_status",me.nId,nMouseClickNum,nKeyboardClickNum,string.format("%d",fGamePlayTime),string.format("%d",fGameActiveTime),nClientInstanceCurrentNum);
end

function c2s:WriteLoginClientInfoLog(...)
	local nClientType = unpack(arg);
		
	StatLog:WriteStatLog("stat_info","client_login","login", me.nId, nClientType);
end

function c2s:MiniDownloadInfoCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return;
	end
	local fun = MiniResource.tbDownloadInfo.tbc2sFun[szFun];
	if not fun then
		print("c2s miniDownloadInfo Erro Called:" .. szFun);
		return;
	end
	fun(MiniResource.tbDownloadInfo, ...);
end

function c2s:ClientSendMiniDowloadInfo(...)
	local nSpeed = unpack(arg);
	MiniResource.tbDownloadInfo:OnClientSync(nSpeed);
end

function c2s:ProcessVicePasswordSetting(szPasswordDifference)
	if(type(szPasswordDifference) ~= "string" or #szPasswordDifference ~= 64) then
	    return 0;
	end
	
	local nClientIndex = me.nPlayerIndex;
	local szAccount = me.szAccount;
	
	if(IsLoginUseVicePassword(nClientIndex) == 1) then
		return 0;
	end
	
	Account:ApplySetBinValue(szAccount, "Account.szPasswordD", szPasswordDifference);
	
	Dialog:Say("副密码设置成功！");
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "副密码设置成功！");
end

function c2s:QueryIfClientLoginUseVicePassword(...)
    local bLoginUseVicePassword = IsLoginUseVicePassword(me.nPlayerIndex);
    me.CallClientScript("SetLoginUsePassword", bLoginUseVicePassword);
end
--end	

-- 充值用户福利
function c2s:Tequan(szType)
	if (GLOBAL_AGENT) then
		Dialog:Say("该地图不允许这个操作！");
		return;
	end
	SpecialEvent.tbTequan:Do(szType);
end

-- 获得与特权相关的一些条件数值
-- 月充值数额(单位元)，月消耗数额(单位金币)
function c2s:GetTequanValue()
	--if (GLOBAL_AGENT) then
		--return;
	--end;
	SpecialEvent.tbTequan:GetValue();
end

function c2s:ApplyProcessPayAward(nProtocal, ...)
	if (type(nProtocal) ~= "number" or nProtocal >= EventManager.tbChongZhiEvent.PROT_MAX) then
		return 0;
	end
	EventManager.tbChongZhiEvent:ApplyProcessPayAward(nProtocal, unpack(arg));
end


function c2s:ItemSwitchEquipCmd(szFun, ...)
	if (type(szFun) ~= "string") then
		return;
	end
	local fun = Item.c2sFun[szFun];
	if (not fun) then
		print("c2s SwitchEquipSeries Error Called:".. szFun);
		return;
	end
	
	fun(Item, unpack(arg));
end
-- 道具操作
function c2s:ItemCmd(szFun, ...)
	if (type(szFun) ~= "string") then
		return;
	end
	local fun = Item.c2sFun[szFun];
	if (not fun) then
		print("c2s ItemCmd Error Called:".. szFun);
		return;
	end
	
	fun(Item, unpack(arg));
end

--自动匹配组队
function c2s:AutoTeamCmd(szFun, ...)
	if type(szFun) ~= "string" then
		return
	end
	local fun = AutoTeam.tbc2sFun[szFun];
	if not fun then
		print("c2s AutoTeam Error Called:" .. szFun);
		return;
	end
	fun(AutoTeam, ...);
end

function c2s:ApplyAddNewTeamLink(nTeamId, nPlayerId, nKinId, nTongId)
	if (type(nTeamId) ~= "number" or type(nPlayerId) ~= "number" 
		or type(nKinId) ~= "number" or type(nTongId) ~= "number") then
		return;
	end
	
	if (KGblTask.SCGetDbTaskInt(DBTASK_CLOASE_TEAMLINK) == 1) then
		return 0;
	end
	
	local nNowTime = GetTime();
	if (Player.nTeamLinkSyncTime) then
		if (nNowTime - Player.nTeamLinkSyncTime <= 5) then
			return 0;
		end
		Player.nTeamLinkSyncTime = nNowTime;
	end
	GCExcute({"KTeam.ModifyTeamLinkInfo", nTeamId, nPlayerId, -1, nKinId, nTongId});
end

--客户端通用信息日志
function c2s:LogMsg(szType, ...)
	if type(szType) ~= "string" then
		return
	end
	local szMsg = Lib:ConcatStr(arg, "\t");
	Dbg:Output("ClientLogMsg", me.szName, szType, szMsg);
	Dbg:WriteLogEx(Dbg.LOG_INFO, "ClientLogMsg", me.szName, szType, szMsg);
end

function c2s:ClientCallBack(...)
	GmCmd:OnClientCallBack(...);
end

function c2s:ApplyJoinFaction(nFaction, nRoute)
	if (type(nFaction) ~= "number") or nFaction <= 0 or nFaction > Env.FACTION_NUM then
		return;
	end
	Player:ApplyJoinFaction(nFaction, nRoute);
end

-- 消耗积分查询
function c2s:ApplyConsumeScores()
	local szTips = [[
	<color=green>奇珍阁消耗类型：<color>例如下:	
	
	    1、金币区购买玄晶，玄晶强化或合成被消耗掉即可算入消耗。
	    2、金币区购买精气散，直接使用精气散后即可算入消耗。
	    3、金币区购买魂石箱，取出所有魂石，箱子消失后即可算入消耗。
	    4、金币区购买乾坤符，乾坤符10次使用完消失后，即可算入消耗。
	<color=red>注：a、每年1月1日消耗积分清空。
	    b、必须从奇珍阁金币区购买的商品，并且该商品被消耗掉，即算入消耗额。<color>
	]]
	local tbOpt = {
		{"打开商城官方网页", Player.OpenConsumeUrl, Player},
		{"奇珍阁消耗查询", Player.ViewConsume, Player},
		{"Để ta suy nghĩ thêm"}}
	Dialog:Say(szTips, tbOpt);
end

--卡牌奖励回调
function c2s:GetRoundAward(nIndex)
	CardAward:GetRoundAward(nIndex);
end

--付费显示一个奖励项
function c2s:OpenOneCard(nIndex)
	CardAward:OpenOneCard(nIndex);
end

function c2s:OnCardAwardStart()
	CardAward:OnStart();
end

function c2s:OnCardAwardContinue()
	CardAward:OnContinue();
end

function c2s:OnCardAwardEnd()
	CardAward:OnBackEnd();
end

function c2s:ApplyBindBankOperate(...)
	local nOperate, nMoneyType, nCount = unpack(arg);
	jbreturn:BindCurrencyOperate(nOperate, nMoneyType, nCount);
end

function c2s:ApplyOpenOnlineBankPay()
	SpecialEvent.tbOnlineBankPay:OnDialog();
end

function c2s:ApplyDayBackAward()
	SpecialEvent.tbDayPlayerBack:OnDialog();
end

function c2s:ApplyPlayerSnsImgAddress(nSnsId, szPlayerName)
	if (type(nSnsId) ~= "number" or type(szPlayerName) ~= "string") then
		return;
	end
	GCExcute({"Player:ApplySnsImgAddress", me.szName, nSnsId, szPlayerName});
end

function c2s:ApplyUpdateMySnsImg(nSnsId, szHttpAddress)
	if (type(nSnsId) ~= "number" or type(szHttpAddress) ~= "string") then
		return;
	end
	GCExcute({"Player:ApplyUpdateSnsImgAddress_GC", me.szName, nSnsId, szHttpAddress});
end

function c2s:AccountViceSaveLimit(tbLimit)
	if IsLoginUseVicePassword(me.nPlayerIndex) == 1 then
		me.Msg("只有主密码登陆情况下才允许设置副密码权限！");
		return 0;
	end
	for nType, nState in ipairs(tbLimit) do
		local bUse = 0;
		if nState == 1 then
			bUse = 1;
		end
		Account:Account2SetUseState(me, nType, bUse)
	end
	me.Msg("已成功设置了副密码权限！");
end

function c2s:LandInClientSelCarrier(...)
--	print("c2s:LandInClientSelCarrier");
--	local dwCarrierId, nSeat = ...;
--	if not nSeat then
--		nSeat = -1;
--	end
--	
--	local pNpc = KNpc.GetById(dwCarrierId);
--	if not pNpc or pNpc.IsCarrier() == 0 then
--		return;
--	end
--	
--	Npc.tbCarrier:LandInCarrier(pNpc, me, nSeat);
end

function c2s:LandOffCarrier(...)
	local pCarrier = me.GetCarrierNpc();
	if not pCarrier then
		return;
	end
	Npc.tbCarrier:LandOffCarrier();
end

function c2s:ApplyOpenShop(nShopId)	--@错误返回0	@正确返回1
	if type(nShopId) ~= "number" then
		return 0;
	end
	
	Shop:ApplyOpenShop(nShopId);
	return 1;	
end

function c2s:ApplySwitchFaction(nFaction)
	if (type(nFaction) ~= "number") then
		return 0;
	end
	
	local nResult, szMsg = Faction:SwitchFaction(me, nFaction);
	if (szMsg) then
		me.Msg(szMsg)
	end
	if (1 == nResult) then
		me.CallClientScript({"Ui:ServerCall", "UI_FIGHTSKILL", "Refresh"});
	end
end

if (IsGlobalServer()) then
	ServerEvent:RegisterClientCallFunForbit("AwordOnlineEx");	-- 在线奖励
	ServerEvent:RegisterClientCallFunForbit("PlayerPrayCmd");	-- 祈福
	ServerEvent:RegisterClientCallFunForbit("ApplyUpdateOnlineState");		-- 在线托管
end
