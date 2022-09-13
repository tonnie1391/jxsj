-- 对话相关处理

-- 取得当前玩家对话相关的临时Table
function Dialog:GetMyDialog()
	local tbPlayerData		= me.GetTempTable("Dialog");
	local tbPlayerDialog	= tbPlayerData.tbDialog;
	if (not tbPlayerDialog) then
		tbPlayerDialog	= {
			tbCallBacks	= {},
		};
		tbPlayerData.tbDialog	= tbPlayerDialog;
	end;
	return tbPlayerDialog;
end;

--[[
-- 需要选项的一段文字对话
function Dialog:Say(szMsg, ...)
	BlackSky:SimpleSay(me, szMsg, ...)
end;

function Dialog:NormalSay(szMsg, ...)

	local tbPlayerDialog	= self:GetMyDialog();
	local tbCallBacks		= {};
	tbPlayerDialog.tbCallBacks	= tbCallBacks;
	
	tbPlayerDialog.tbGRoleArgs = tbPlayerDialog.tbGRoleArgs or {};
	if (me) then
		tbPlayerDialog.tbGRoleArgs.playerId = me.nId;
	else
		tbPlayerDialog.tbGRoleArgs.playerId = 0;
	end;
	if (him) then
		tbPlayerDialog.tbGRoleArgs.npcId = him.dwId;
	else
		tbPlayerDialog.tbGRoleArgs.npcId = 0;
	end;
	
	local tbOpt;
	-- 选项参数分三大类方式
	if (not arg[1]) then	-- 1、无选项，默认空
		tbOpt	= {}
	elseif (type(arg[1][1]) == "table") then	-- 2、一组选项作为一个参数
		tbOpt	= arg[1];
	else	-- 3、每一个参数一个选项，一共N个参数
		tbOpt	= arg;
	end;
	
	local tbOptions	= {};
	for i, v in ipairs(tbOpt) do
		if (type(v) == "table") then
			tbOptions[i]	= v[1];
			if (v[2]) then
				tbCallBacks[i]	= {unpack(v,2)};
			end;
		else
			tbOptions[i]	= v;
		end;
	end;
	if (not tbOptions[1]) then
		tbOptions[1]	= "Kết thúc đối thoại";
	end;
	me.Select(szMsg, tbOptions);
end
]]--
-- 需要选项的一段文字对话
function Dialog:Say(szMsg, ...)
	local tbPlayerDialog	= self:GetMyDialog();
	local tbCallBacks		= {};
	tbPlayerDialog.tbCallBacks	= tbCallBacks;
	
	tbPlayerDialog.tbGRoleArgs = tbPlayerDialog.tbGRoleArgs or {};
	if (me) then
		tbPlayerDialog.tbGRoleArgs.playerId = me.nId;
	else
		tbPlayerDialog.tbGRoleArgs.playerId = 0;
	end;
	if (him) then
		tbPlayerDialog.tbGRoleArgs.npcId = him.dwId;
	else
		tbPlayerDialog.tbGRoleArgs.npcId = 0;
	end;

	local tbOpt;
	-- 选项参数分三大类方式
	if (not arg[1]) then	-- 1、无选项，默认空
		tbOpt	= {}
	elseif (type(arg[1][1]) == "table") then	-- 2、一组选项作为一个参数
		tbOpt	= arg[1];
	else	-- 3、每一个参数一个选项，一共N个参数
		tbOpt	= arg;
	end;
	
	local tbOptions	= {};
	for i, v in ipairs(tbOpt) do
		if (type(v) == "table") then
			tbOptions[i]	= v[1];
			if (v[2]) then
				tbCallBacks[i]	= {unpack(v,2)};
			end;
		else
			tbOptions[i]	= v;
		end;
	end;
	if (not tbOptions[1]) then
		tbOptions[1]	= "Kết thúc đối thoại";
	end;
	me.Select(szMsg, tbOptions);
end;

-- 没有选项的多段文字对话
function Dialog:Talk(tbMsg, ...)
	if (arg[1]) then	-- 允许没有回调
		self:GetMyDialog().tbCallBacks	= {arg} -- arg本身就是一个表，说明对于Talk来说就只有tbCallBacks[1]
		
		self:GetMyDialog().tbGRoleArgs = self:GetMyDialog().tbGRoleArgs or {};
		if (me) then
			self:GetMyDialog().tbGRoleArgs.playerId = me.nId;
		else
			self:GetMyDialog().tbGRoleArgs.playerId = 0;
		end;
		if (him) then
			self:GetMyDialog().tbGRoleArgs.npcId = him.dwId;
		else
			self:GetMyDialog().tbGRoleArgs.npcId = 0;
		end;

	end;
	me.Talk(tbMsg);
end;

-- 播放插画 illustration【n. 说明；插图；例证；图解】
-- 客户端服务端通用接口
-- 参数说明	名字 -> 默认值，注意：时间单位都是毫秒
-- tbParam.nOpenTime	= 400;	-- 幕布开启时间,如果开幕时间<=0表示没有开幕
-- tbParam.nCloseTime	= 400;	-- 幕布关闭时间,如果闭幕幕时间<=0表示没有开幕
-- tbParam.nFadeinTime	= 1000;	-- 主题淡入时间
-- tbParam.nFadeoutTime	= 1000;	-- 主体淡出时间
-- tbParam.nLastTime	= 3000;	-- 持续时间，一切开始工作都做好了的持续时间
-- tbParam.szImage		= "";	-- 主体图片
-- tbParam.szTalk		= "";	-- 说话内容
-- tbParam.bPenetrate	= 0;	-- 是否可以穿透
-- tbParam.nLoops		= 1;	-- 循环次数
-- 总的播放时间：total = nOpenTime + nFadinTime + nTalkTime + nLastTime + nFadeoutTime + nCloseTime
function Dialog:PlayIlluastration(pPlayer, tbParam)
	assert(type(pPlayer) == "userdata");
	
	-- TODO:（临时，勿效仿）需要一个规范、简洁的与客户端UI的接口
	if MODULE_GAMESERVER then
		pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_CHAHUA", tbParam});
	else
		UiManager:OpenWindow(Ui.UI_CHAHUA, tbParam);
	end
end

--打开给予界面
--传入表格格式
--varParam = {
--tbAward = {{nGenre=, nDetail=,nParticular=,nLevel=,nCount=,nBind=,nTimeLimit=分钟, nTimeType=限时类型(默认0绝对时间，1为相对时间)},{...},...}, 获得物品
--tbMareial = {{nGenre=, nDetail=,nParticular=,nLevel=,nCount=},{...},...}, 必须物品
--tbMareialOne = {{nGenre=, nDetail=,nParticular=,nLevel=,nCount=1}},  --材料必须其中一种
--}
--接口1 Dialog:OpenGift(szContent, varParam) --标题，表格内容
--接口2 Dialog:OpenGift(szContent, {"szCheckFun"}, {szOkFun, self}) --标题, 检查放入物品函数(client端), 确定函数
--szCheckFun接口参数szCheckFun(tbGiftSelf, pPickItem, pDropItem, nX, nY); --client端;参数：giftself, 放入物品,拿出物品
--szOkFun接口参数szOkFun(tbBoxItem);	--物品对象表tbBoxItem={{pItem,nx,ny},...};

function Dialog:OpenGift(szContent, varParam, varFun)
	if not varParam and not varFun then
		return
	end
	Dialog.tbGift:OnOpen(szContent, varParam, varFun)
end

-- 给予界面
function Dialog:Gift(szTable, ...)
	local tbGift = KLib.GetValByStr(szTable);
	if (not tbGift) or (type(tbGift) ~= "table") then
		print("无效的给予界面对象："..tostring(szTable));
		return;
	end
	if (not Lib:IsDerived(tbGift, Gift)) then
		print("给予界面对象必须Gift派生："..tostring(szTable));
		return;
	end
	local tbPlayerDialog = self:GetMyDialog();
	local tbCallBacks =
	{
		{ tbGift.OnOK,	   tbGift },
		{ tbGift.OnCancel, tbGift },
	};
	if #arg > 0 then 
		for _, tbgift in pairs(tbCallBacks) do
			for _, tbParam in pairs(arg) do
				table.insert(tbgift, tbParam);
			end
		end
	end
	tbPlayerDialog.tbCallBacks = tbCallBacks;
	
	tbPlayerDialog.tbGRoleArgs = tbPlayerDialog.tbGRoleArgs or {};
	if (me) then
		tbPlayerDialog.tbGRoleArgs.playerId = me.nId;
	else
		tbPlayerDialog.tbGRoleArgs.playerId = 0;
	end;
	if (him) then
		tbPlayerDialog.tbGRoleArgs.npcId = him.dwId;
	else
		tbPlayerDialog.tbGRoleArgs.npcId = 0;
	end;

	me.Gift(szTable, #tbCallBacks);
end

-- 请求客户端输入字符串
function Dialog:AskString(szTitle, nMax, ...)
	local tbPlayerDialog	= self:GetMyDialog();
	tbPlayerDialog.tbStringCallBack	= arg;
	
	tbPlayerDialog.tbGRoleArgs = tbPlayerDialog.tbGRoleArgs or {};
	if (me) then
		tbPlayerDialog.tbGRoleArgs.playerId = me.nId;
	else
		tbPlayerDialog.tbGRoleArgs.playerId = 0;
	end;
	if (him) then
		tbPlayerDialog.tbGRoleArgs.npcId = him.dwId;
	else
		tbPlayerDialog.tbGRoleArgs.npcId = 0;
	end;

	KDialog.AskString(me, szTitle, nMax);
end;

-- 请求客户端输入数字
function Dialog:AskNumber(szTitle, nMax, ...)
	local tbPlayerDialog	= self:GetMyDialog();
	tbPlayerDialog.tbNumberCallBack	= arg;
	
	tbPlayerDialog.tbGRoleArgs = tbPlayerDialog.tbGRoleArgs or {};
	if (me) then
		tbPlayerDialog.tbGRoleArgs.playerId = me.nId;
	else
		tbPlayerDialog.tbGRoleArgs.playerId = 0;
	end;
	if (him) then
		tbPlayerDialog.tbGRoleArgs.npcId = him.dwId;
	else
		tbPlayerDialog.tbGRoleArgs.npcId = 0;
	end;

	KDialog.AskNumber(me, szTitle, nMax);
end;

-- 打开对话
function Dialog:OpenShop(nShopId, nCurreycyType, nScale)
	me.OpenShop(nShopId, nCurreycyType or 1, nScale or 100);
end

-- 系统调用的选项被选中
function Dialog:OnSelect(nSelect)
	local tbPlayerDialog	= self:GetMyDialog();
	local tbCallBack		= tbPlayerDialog.tbCallBacks[nSelect];
	
	tbPlayerDialog.tbCallBacks	= {};
	if (not tbCallBack) then
		return;
	end;
	
	if MODULE_GAMESERVER then
		local tbGRoleArgs = tbPlayerDialog.tbGRoleArgs;
		local pNpc = KNpc.GetById(tbGRoleArgs.npcId);
		Setting:SetGlobalObj(nil, pNpc)
		Lib:CallBack(tbCallBack);
		Setting:RestoreGlobalObj();
	else
		Lib:CallBack(tbCallBack);
	end
end;

-- 系统调用的客户端确认
function Dialog:OnOk(szType, ...)
	local tbPlayerDialog	= self:GetMyDialog();
	local tbCallBack		= tbPlayerDialog[szType];
	tbPlayerDialog[szType]	= nil;
	if (not tbCallBack) then
		return;
	end;
	local n	= #tbCallBack;
	for i, v in ipairs(arg) do	-- 不用ipairs，允许参数中含有nil
		tbCallBack[n + i]	= v;
	end;
	
	local tbGRoleArgs = tbPlayerDialog.tbGRoleArgs;
	local pNpc = KNpc.GetById(tbGRoleArgs.npcId);
	Setting:SetGlobalObj(nil, pNpc);
	Lib:CallBack(tbCallBack);
	Setting:RestoreGlobalObj();
end;

-- 显示战场即时消息	（nWaitFrame默认不等待）
function Dialog:ShowBattleMsg(pPlayer, nInBattle, nWaitFrame)
	assert(type(pPlayer) == "userdata");
	
	-- TODO:（临时，勿效仿）需要一个规范、简洁的与客户端UI的接口
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_TASKTRACK", "ChangeInBattle", nInBattle, nWaitFrame});
end

-- 发送战场即时消息
-- nRefreshMsgOnly: 只刷新消息，不刷新时间，避免时间间隔显示不规则
function Dialog:SendBattleMsg(pPlayer, szMsg, nRefreshMsgOnly)
	assert(type(pPlayer) == "userdata");
	
	-- TODO:（临时，勿效仿）需要一个规范、简洁的与客户端UI的接口
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_TASKTRACK", "OnReceiveBattleMsg", szMsg, nRefreshMsgOnly});
end

-- 打开倒计时面板 设定计时
function Dialog:SetTimerPanel(pPlayer, szName, nSec)
	assert(type(pPlayer) == "userdata");
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_TASKLEAVETIME", "OpenWindow", szName, nSec});
end;

-- 关闭倒计时面板
function Dialog:CloseTimerPanel(pPlayer)
	assert(type(pPlayer) == "userdata");
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_TASKLEAVETIME", "CloseWindow"});
end

-- 设定战场计时器
function Dialog:SetBattleTimer(pPlayer, szTimerFmt, ...)
	assert(type(pPlayer) == "userdata");
	
	-- TODO:（临时，勿效仿）需要一个规范、简洁的与客户端UI的接口
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_TASKTRACK", "OnReceiveBattleTimer", szTimerFmt, arg});
end

-- 设置任务跟踪
function Dialog:SetTrackTask(pPlayer, bTrack)
	assert(type(pPlayer) == "userdata");
	
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_TASKTRACK", "SetTrack", bTrack});
end

function Dialog:SetActiveAuraId(pPlayer, nAuraId)
	pPlayer.CallClientScript({"Player:SetActiveAura", nAuraId});
end
-- 屏幕中央黄色大字消息
function Dialog:SendInfoBoardMsg(pPlayer, szMsg)
	assert(type(pPlayer) == "userdata");
	
	-- TODO:（临时，勿效仿）需要一个规范、简洁的与客户端UI的接口
	pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", szMsg});
end

-- 屏幕中央黑底大字
function Dialog:SendBlackBoardMsg(pPlayer, szMsg)
	assert(type(pPlayer) == "userdata");
	
	-- TODO:（临时，勿效仿）需要一个规范、简洁的与客户端UI的接口
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_TASKTIPS", "Begin", szMsg});
end

-- 屏幕中央黑底大字(队伍内所有成员提示，nInSide==1为在附近的队员才提示)
function Dialog:SendBlackBoardMsgTeam(pPlayer, szMsg, nInSide)
	local DEF_DIS = 50;
	local tbMemberList = pPlayer.GetTeamMemberList();
	if not tbMemberList or pPlayer.nTeamId <= 0 then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		return 0;
	end
	local nMapId, nX, nY	= pPlayer.GetWorldPos();
	local tbCurMemberList = {};
	for _, pMemPlayer in pairs(tbMemberList) do
		if nInSide ==  1 then
			local nPlayerMapId, nPlayerX, nPlayerY	= pMemPlayer.GetWorldPos();
			if (nPlayerMapId == nMapId) then
				local nDisSquare = (nX - nPlayerX)^2 + (nY - nPlayerY)^2;
				if (nDisSquare < ((DEF_DIS/2) * (DEF_DIS/2))) then
					table.insert(tbCurMemberList, pMemPlayer);
				end
			end
		else
			table.insert(tbCurMemberList, pMemPlayer);
		end
	end
	
	for _, pMemPlayer in pairs(tbCurMemberList) do
		Dialog:SendBlackBoardMsg(pMemPlayer, szMsg)
	end
end

-- 宋金即时战报
function Dialog:SendBattleReportMsg(pPlayer, tbPlayerInfoList, tbPlayerInfo)
	assert(type(pPlayer) == "userdata");
	
	-- TODO:（临时，勿效仿）需要一个规范、简洁的与客户端UI的接口
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_BATTLEREPORT", "OnData", tbPlayerInfoList, tbPlayerInfo});
end

-- 同步活动数据
function Dialog:SyncCampaignDate(pPlayer, szType, tbDate, nUsefulTime)
	assert(type(pPlayer) == "userdata");

	-- TODO:（临时，勿效仿）需要一个规范、简洁的与客户端UI的接口
	pPlayer.CallClientScript{"Player:SyncCampaignDate", szType, tbDate, nUsefulTime};
end

-- 大区头顶公告
function Dialog:GlobalNewsMsg(szMsg)
	if MODULE_GAMESERVER then
		GCExcute({"Dialog:GlobalNewsMsg", szMsg});
	elseif MODULE_GC_SERVER then
		GC_AllExcute({"Dialog:GlobalNewsMsg_Center", szMsg});
	end
end

function Dialog:GlobalNewsMsg_Center(szMsg)
	if GLOBAL_AGENT then
		GC_AllExcute({"Dialog:GlobalNewsMsg_GC", szMsg});
	end
end

function Dialog:GlobalNewsMsg_GC(szMsg)
	if MODULE_GC_SERVER then
		GlobalExcute({"Dialog:GlobalNewsMsg_GS", szMsg});
	end
end

function Dialog:GlobalNewsMsg_GS(szMsg)
	if MODULE_GAMESERVER then
		KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	end
end

-- 大区系统公告
function Dialog:GlobalMsg2SubWorld(szMsg)
	if MODULE_GAMESERVER then
		GCExcute({"Dialog:GlobalMsg2SubWorld", szMsg});
	elseif MODULE_GC_SERVER then
		GC_AllExcute({"Dialog:GlobalMsg2SubWorld_Center", szMsg});
	end
end

function Dialog:GlobalMsg2SubWorld_Center(szMsg)
	if GLOBAL_AGENT then
		GC_AllExcute({"Dialog:GlobalMsg2SubWorld_GC", szMsg});
	end
end

function Dialog:GlobalMsg2SubWorld_GC(szMsg)
	if MODULE_GC_SERVER then
		GlobalExcute({"Dialog:GlobalMsg2SubWorld_GS", szMsg});
	end
end

function Dialog:GlobalMsg2SubWorld_GS(szMsg)
	if MODULE_GAMESERVER then
		KDialog.Msg2SubWorld(szMsg);
	end
end
