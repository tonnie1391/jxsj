-- 文件名　：aword_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-05-06 10:40:22
-- 描  述  ：

if  not MODULE_GAMESERVER then
	return;
end

SpecialEvent.tbAword = SpecialEvent.tbAword or {};
local tbAword = SpecialEvent.tbAword;

tbAword.tbAword		= tbAword.tbAword or {};
tbAword.tbAword_timer 	= tbAword.tbAword_timer or {};
tbAword.tbAword_Day	= tbAword.tbAword_Day or {};
tbAword.nOpenTime	= 0;
tbAword.nCloseTime	= 0;

tbAword.TSK_GROUP 				= 2122;		--任务组
tbAword.TSK_AWORD_DAILY		= 5;			--登录奖励 随机数
tbAword.TSK_DATA_DAILY			= 6;			--领奖的日期
tbAword.TSK_ISAWOERD_DAILY	= 7;			--是否领奖
tbAword.TSK_AWOERD_NUM		= 8;			--领取奖励的数
tbAword.TSK_AWOERD_ONLINE_NUM	= 9;		--在线领奖的数
tbAword.TSK_AWOERD_ONLINE_DAY	= 10;		--日期
tbAword.TSK_AWOERD_ONLINE_GETDAY	= 11;	--领取上一份的时间

--登录事件
function tbAword:Open(bExchangeServerComing)
	if bExchangeServerComing ~= 0 then
		return;
	end
	--随机一个每日登录的奖励
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if self.tbAword[1] and nDate ~= me.GetTask(self.TSK_GROUP, self.TSK_DATA_DAILY) then
		local nNum = Random(#self.tbAword[1]) + 1;
		me.SetTask(self.TSK_GROUP, self.TSK_AWORD_DAILY, nNum);
		me.SetTask(self.TSK_GROUP, self.TSK_DATA_DAILY, nDate);
		me.SetTask(self.TSK_GROUP, self.TSK_ISAWOERD_DAILY, 0);
	end
	--上线更新持续在线的奖励
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	local nData = me.GetTask(self.TSK_GROUP, self.TSK_AWOERD_ONLINE_DAY);	
	if nData ~= nNowTime then
		me.SetTask(tbAword.TSK_GROUP, tbAword.TSK_AWOERD_ONLINE_DAY, nNowTime);		
		me.SetTask(tbAword.TSK_GROUP, tbAword.TSK_AWOERD_ONLINE_NUM, 0);
	end
	local tbOpenFlag = {};
	tbOpenFlag[1] = EventManager.IVER_bOpenZaiXian1;
	tbOpenFlag[2] = EventManager.IVER_bOpenZaiXian2;
	tbOpenFlag[3] = EventManager.IVER_bOpenZaiXian3;
	tbOpenFlag[4] = EventManager.IVER_bOpenZaiXian4;
	me.SetTask(tbAword.TSK_GROUP,tbAword.TSK_AWOERD_ONLINE_GETDAY, GetTime());
	me.CallClientScript({"SpecialEvent.tbAword:Init", self.tbAword, self.tbAword_timer, self.tbAword_Day, self.nOpenTime, self.nCloseTime, tbOpenFlag, EventManager.IVER_bOpenZaiXian});
	me.CallClientScript({"SpecialEvent.tbAword:OpenAwordOnlineTimer"});
end

--获取每日登录奖励
function tbAword:GetAwordDaily()
	local nFlag = me.GetTask(tbAword.TSK_GROUP, tbAword.TSK_ISAWOERD_DAILY);
	if nFlag == 1 then		
		me.Msg("您已经领取过了！");
		return;
	end
	local nNum = me.GetTask(tbAword.TSK_GROUP, tbAword.TSK_AWORD_DAILY);
	if tbAword:GetAword(1, nNum) == 0 then
		return;
	end
	me.SetTask(tbAword.TSK_GROUP, tbAword.TSK_ISAWOERD_DAILY,1);	
	me.Msg("每天登录都可获得令人心动的礼物哦！");	
	me.CallClientScript({"UiManager:OpenWindow", "UI_GETAWORD"});	
end

--获取累积登录奖励
function tbAword:GetAwordLogIn()
	local nNumLogin = me.GetTask(2063,20);
	local nNowAword = me.GetTask(tbAword.TSK_GROUP, tbAword.TSK_AWOERD_NUM);
	if not tbAword.tbAword_Day[nNowAword + 1] then
		return;
	end
	if tbAword.tbAword_Day[nNowAword + 1] > nNumLogin then
		me.Msg("您还不能领取！");
		return;
	end
	if tbAword:GetAword(2, nNowAword + 1) == 0 then
		return;
	end
	local nNowMonth = tonumber(GetLocalDate("%m"));
	local nMonth = me.GetTask(2063,18);
	if nMonth == nNowMonth then
		me.SetTask(tbAword.TSK_GROUP, tbAword.TSK_AWOERD_NUM,me.GetTask(tbAword.TSK_GROUP, tbAword.TSK_AWOERD_NUM) + 1);
		StatLog:WriteStatLog("stat_info", "dayaword", "accumulateday", me.nId, nNumLogin);
		if tbAword.tbAword_Day[nNowAword + 2] then
			me.Msg(string.format("当月累积登录%s天之后您还可以领取更丰富的奖励哦（当月领取，过期作废）！", tbAword.tbAword_Day[nNowAword + 2]));
		else
			me.Msg("您当月累积奖励已经领取完了（当月领取，过期作废）！")
		end
	else
		me.SetTask(2063,18,nNowMonth);
		me.SetTask(2063,20, 0);
		me.SetTask(tbAword.TSK_GROUP, tbAword.TSK_AWOERD_NUM, 0);
		me.Msg("新的一个月开始了，记得累积获取奖励哦（当月领取，过期作废）！");
	end
	
	me.CallClientScript({"UiManager:OpenWindow", "UI_GETAWORD"});	
end

--获取持续在线奖励
function tbAword:GetAwordOnline()	
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));	
	local nNum = me.GetTask(tbAword.TSK_GROUP, tbAword.TSK_AWOERD_ONLINE_NUM);	
	local nNowTimeEx = GetTime();
	local nStarTime = me.GetTask(2063, 2);
	local nLastTime = me.GetTask(tbAword.TSK_GROUP,tbAword.TSK_AWOERD_ONLINE_GETDAY);
	if (tbAword.nOpenTime ~= 0 and  nNowTime < tbAword.nOpenTime) or (tbAword.nCloseTime ~= 0 and  nNowTime > tbAword.nCloseTime) then
		me.Msg("目前没有派送礼物！");
		return;
	end
	if nNum + 1 > #SpecialEvent.tbAword.tbAword[3]  then
		me.Msg("今日的礼物已全部送出了！");
		return;
	end
	if nNowTimeEx - nStarTime < tbAword.tbAword_timer[nNum + 1] or nNowTimeEx - nLastTime < tbAword.tbAword_timer[nNum + 1] then
		me.Msg("您还不能领取！");
		return;
	end	
	if tbAword:GetAword(3, nNum + 1) == 0 then
		return;
	end
	me.SetTask(tbAword.TSK_GROUP, tbAword.TSK_AWOERD_ONLINE_NUM, nNum + 1);	
	me.SetTask(tbAword.TSK_GROUP,tbAword.TSK_AWOERD_ONLINE_GETDAY, nNowTimeEx);
	
	local nData = me.GetTask(tbAword.TSK_GROUP, tbAword.TSK_AWOERD_ONLINE_DAY);	
	if nData ~= nNowTime then		
		me.SetTask(tbAword.TSK_GROUP, tbAword.TSK_AWOERD_ONLINE_DAY, nNowTime);
		me.SetTask(tbAword.TSK_GROUP, tbAword.TSK_AWOERD_ONLINE_NUM, 0);
	end
	if nNum + 1 >= #SpecialEvent.tbAword.tbAword[3] then
		me.Msg("今日的礼物已全部送出，祝您早日名震江湖，后会有期！");
	end
	me.CallClientScript({"UiManager:OpenWindow", "UI_GETAWORD", 1});
end

function tbAword:GetAwordUpLevel()
	if GLOBAL_AGENT then
		return 0;
	end
	local nItemLevel = SpecialEvent.NewPlayerGift:GetCurrData(me);
	if (not nItemLevel) then
		me.Msg("已经没有礼物可以领取！");
		return 0;
	end
	local nRes, szMsg =SpecialEvent.NewPlayerGift:GetAward(me);
	if nRes == 0 then
		me.Msg(szMsg);
		return 0;
	end
	me.CallClientScript({"UiManager:OpenWindow", "UI_GETAWORD"});	
end

function tbAword:GetAword(nGroup, nNum)	
	if GLOBAL_AGENT then
		return 0;
	end
	if not SpecialEvent.tbAword.tbAword[nGroup] or not SpecialEvent.tbAword.tbAword[nGroup][nNum] then
		return 0;
	end
	local nNeedBag = 0;
	for _, tbAword in pairs(SpecialEvent.tbAword.tbAword[nGroup][nNum]) do
		nNeedBag = nNeedBag + tbAword[3];
	end
	if me.CountFreeBagCell() < nNeedBag then
		me.Msg(string.format("请预留%s格背包空间再来领取！", nNeedBag));
		return 0;
	end
	--给奖励
	for szType, tbAwordEx in pairs(SpecialEvent.tbAword.tbAword[nGroup][nNum]) do
		if tbAwordEx[3] ~= 0 then	
			local szName = nil;
			for i = 1, tbAwordEx[3] do	
				local pItem = me.AddItemEx(tbAwordEx[2][1], tbAwordEx[2][2], tbAwordEx[2][3], tbAwordEx[2][4], {bForceBind=1});
				if pItem then
					szName = szName or pItem.szName;
					if tbAwordEx[7] and tbAwordEx[7] > 0 then
						pItem.SetTimeOut(0, (GetTime() + tbAwordEx[7] * 60)); -- 加过期时间
					elseif tbAwordEx[7] and tbAwordEx[7] == 0 then
						pItem.SetTimeOut(0, (GetTime() + 30*24*3600)); -- 加过期时间				
					end
					pItem.Sync();					
				end				
			end
			tbAword:WriteLog(tbAwordEx[3].."个"..szName);
			
			Item:CheckXJRecord(Item.emITEM_XJRECORD_EVENT, "在线领奖", {tbAwordEx[2][1], tbAwordEx[2][2], tbAwordEx[2][3], tbAwordEx[2][4], 1, tbAwordEx[3]});
		end
		if tbAwordEx[4] ~= 0 then
			me.Earn(tbAwordEx[4], 1);
			tbAword:WriteLog("银两"..tbAwordEx[4]);
		end
		if tbAwordEx[5] ~= 0 then
			me.AddBindMoney(tbAwordEx[5]);
			tbAword:WriteLog("绑定银两"..tbAwordEx[5]);
		end
		if tbAwordEx[6] ~= 0 then
			me.AddBindCoin(tbAwordEx[6], Player.emKBINDCOIN_ADD_ONLINE_AWARD);
			tbAword:WriteLog("绑定金币"..tbAwordEx[6]);
		end
	end
	return 1;
end

--log
function tbAword:WriteLog(szMsg)
	EventManager:WriteLog("【在线领奖】获得"..szMsg, me);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "【在线领奖】获得"..szMsg);
end

PlayerEvent:RegisterGlobal("OnLogin", SpecialEvent.tbAword.Open, SpecialEvent.tbAword);

