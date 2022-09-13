-- 文件名　：awordonline.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-26 16:45:21
-- 描  述  ：在线领取  sever脚本

if  not MODULE_GAMESERVER then
	return;
end

SpecialEvent.tbAwordOnline = SpecialEvent.tbAwordOnline or {};
local tbAwordOnline = SpecialEvent.tbAwordOnline;

tbAwordOnline.nSeverTime 	= 20;	--时间要求 开服多少天以内
tbAwordOnline.nGrade		= 0;	--等级要求 0表示新手
tbAwordOnline.bOpen			= EventManager.IVER_bOpenAwardOnLine;	--在线领取开关 1表示开，0表示关
tbAwordOnline.nCloseTime	= 14;	--关闭时间建立角色多少天以内
tbAwordOnline.tbAword		= tbAwordOnline.tbAword or {};
tbAwordOnline.tbAword_timer = tbAwordOnline.tbAword_timer or {};

tbAwordOnline.TSK_GROUP 			= 2122;		--任务组
tbAwordOnline.TSK_AWORD_NUMBER		= 1;			--已经领取的数目
tbAwordOnline.TSK_DATA				= 2;			--领奖的日期
tbAwordOnline.TSK_ISAWOERD_NUM		= 3;			--可以领取的奖励
tbAwordOnline.TSK_AWOERD_TIME		= 4;			--领取上一份奖励的时间

--登陆事件
function tbAwordOnline:Open(bExchangeServerComing)
	if GLOBAL_AGENT then
		return 0;
	end
	--条件
	if self:CheckOpen() == 0 then
		me.CallClientScript({"UiManager:CloseWindow", "UI_AWORDONLINE"});
		return;
	end
	--隔天
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	local nData = me.GetTask(self.TSK_GROUP, self.TSK_DATA);
	local nNum = me.GetTask(self.TSK_GROUP, self.TSK_AWORD_NUMBER);
	local nIsNum = me.GetTask(self.TSK_GROUP, self.TSK_ISAWOERD_NUM);
	--先前已经积累够时间的，继续领奖
	if nNum == nIsNum and nNum ~= 0 then
		me.CallClientScript({"UiManager:OpenWindow", "UI_AWORDONLINE", 3, nNum, bExchangeServerComing});
		return;
	end
	if nData ~= nNowTime then
		me.SetTask(self.TSK_GROUP, self.TSK_DATA, nNowTime);
		me.SetTask(self.TSK_GROUP, self.TSK_AWORD_NUMBER, 1);
	end
	--奖励已经领到没有值了
	nNum = me.GetTask(self.TSK_GROUP, self.TSK_AWORD_NUMBER);
	if nNum > #self.tbAword then
		me.CallClientScript({"UiManager:CloseWindow", "UI_AWORDONLINE"});
		return;
	end
	
	me.CallClientScript({"UiManager:OpenWindow", "UI_AWORDONLINE", 1, nNum, bExchangeServerComing});
end

--获取奖励
function tbAwordOnline:GetAword()
	if GLOBAL_AGENT then
		return 0;
	end	
	--开启状态
	if self.bOpen ~= 1 then
		return 0;
	end
	local nNum = me.GetTask(tbAwordOnline.TSK_GROUP, tbAwordOnline.TSK_AWORD_NUMBER);
	local nIsNum = me.GetTask(tbAwordOnline.TSK_GROUP, tbAwordOnline.TSK_ISAWOERD_NUM);
	local nLastTime = me.GetTask(tbAwordOnline.TSK_GROUP, tbAwordOnline.TSK_AWOERD_TIME);
	local nNowTime = GetTime();
	local nStarTime = me.GetTask(2063, 2);
	if nNum ~= nIsNum then
		if not tbAwordOnline.tbAword_timer[nNum] or not tbAwordOnline.tbAword_timer[nNum][1] or nNowTime - nLastTime < tbAwordOnline.tbAword_timer[nNum][1] or nNowTime - nStarTime < tbAwordOnline.tbAword_timer[nNum][1]  then
			me.Msg("您还不能领取！");
			return;
		end
	end
	if not tbAwordOnline.tbAword[nNum] then
		return;
	end
	local nNeedBag = 0;
	for _, tbAword in pairs(tbAwordOnline.tbAword[nNum]) do
		nNeedBag = nNeedBag + tbAword[2];
	end
	if me.CountFreeBagCell() < nNeedBag then
		Dialog:Say(string.format("请预留%s格背包空间再来领取！", nNeedBag),{"知道了"});
		return 0;
	end
	--给奖励
	for szType, tbAword in pairs(tbAwordOnline.tbAword[nNum]) do
		if tbAword[2] ~= 0 then	
			for i = 1, tbAword[2] do	
				local pItem = me.AddItemEx(tbAword[1][1], tbAword[1][2], tbAword[1][3], tbAword[1][4], {bForceBind=1});
				if pItem then
					pItem.SetTimeOut(0, (GetTime() + 30*24*3600)); -- 加过期时间
					pItem.Sync();  	
				end
			end
		end
		Item:CheckXJRecord(Item.emITEM_XJRECORD_EVENT, "在线领奖", {tbAword[1][1], tbAword[1][2], tbAword[1][3], tbAword[1][4], 1, tbAword[2]});
		
		if tbAword[3] ~= 0 then
			me.Earn(tbAword[3], 1);
		end
		if tbAword[4] ~= 0 then
			me.AddBindMoney(tbAword[4]);
		end
		if tbAword[5] ~= 0 then
			me.AddBindCoin(tbAword[5], Player.emKBINDCOIN_ADD_ONLINE_AWARD);
		end
		tbAwordOnline:WriteLog(tbAword[6]);
	end	
	me.SetTask(tbAwordOnline.TSK_GROUP, tbAwordOnline.TSK_AWOERD_TIME, nNowTime);		--领奖时间
	me.SetTask(tbAwordOnline.TSK_GROUP, tbAwordOnline.TSK_AWORD_NUMBER, nNum + 1);		--下一份奖励
	me.SetTask(tbAwordOnline.TSK_GROUP, tbAwordOnline.TSK_ISAWOERD_NUM, 0);
	local szEndTime = os.date("%Y年%m月%d日",Lib:GetDate2Time(me.GetRoleCreateDate()) + tbAwordOnline.nCloseTime * 24 * 3600)
	me.Msg(string.format("您闯荡江湖已有些时日，特赠送您<color=yellow>第%s份礼物<color>（共%s份），不成敬意，您在<color=yellow>%s<color>之前，每天只要持续在线，均可获得奖励。", nNum, #tbAwordOnline.tbAword, szEndTime));
	
	tbAwordOnline:Open();
	local nCreateTime = me.GetRoleCreateDate();
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime == me.GetTask(tbAwordOnline.TSK_GROUP, tbAwordOnline.TSK_DATA) then
		if nNum >= #tbAwordOnline.tbAword then
			me.Msg("今日的礼物已全部送出，祝您早日名震江湖，后会有期！");
			if Lib:GetDate2Time(nNowTime) - Lib:GetDate2Time(nCreateTime) < (tbAwordOnline.nCloseTime -1) *24 * 3600 then
				me.Msg("明天您还可以继续领取奖励，记得上线领奖的哦！");
			end
		end
	end
end

--log
function tbAwordOnline:WriteLog(szMsg)
	EventManager:WriteLog("【在线领奖】获得"..szMsg, me);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "【在线领奖】获得"..szMsg);
end

--检测玩家是否是新手，开启在线奖励
function tbAwordOnline:CheckOpen()
	--开启状态
	if self.bOpen ~= 1 then		
		return 0;
	end
	--时间要求
	local nOpenSeverTime = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME)))));
	local nCreateTime = Lib:GetDate2Time(me.GetRoleCreateDate());
	local nNowTime = Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d")));	
	if (self.nSeverTime ~= 0 and nCreateTime - nOpenSeverTime >= self.nSeverTime * 24 * 3600) or (self.nCloseTime ~= 0 and nNowTime - nCreateTime >= self.nCloseTime * 24 * 3600) then
		return 0;
	end
	--等级要求
	if self.nGrade ~= 0 and me.nLevel > self.nGrade then		
		return 0;
	end	
	return 1;
end

--下线
function tbAwordOnline:OnLogout()
	local nNum = me.GetTask(tbAwordOnline.TSK_GROUP, tbAwordOnline.TSK_AWORD_NUMBER);
	local nLastTime = me.GetTask(tbAwordOnline.TSK_GROUP, tbAwordOnline.TSK_AWOERD_TIME);
	local nNowTime = GetTime();
	local nStarTime = me.GetTask(2063, 2);
	if tbAwordOnline.tbAword_timer[nNum] and tbAwordOnline.tbAword_timer[nNum][1] and nNowTime - nLastTime >= tbAwordOnline.tbAword_timer[nNum][1] and nNowTime - nStarTime >= tbAwordOnline.tbAword_timer[nNum][1]  then		
		me.SetTask(self.TSK_GROUP, self.TSK_ISAWOERD_NUM, nNum);
	end
	me.CallClientScript({"UiManager:CloseWindow", "UI_AWORDONLINE"});	
end

PlayerEvent:RegisterGlobal("OnLogin", SpecialEvent.tbAwordOnline.Open, SpecialEvent.tbAwordOnline);
PlayerEvent:RegisterGlobal("OnLogout", SpecialEvent.tbAwordOnline.OnLogout, SpecialEvent.tbAwordOnline);
