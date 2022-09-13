-- 文件名　：help.lua
-- 创建者　：FanZai
-- 创建时间：2008-03-13 12:52:48

Require("\\script\\task\\help\\help_table.lua")
local tbHelp	= Task.tbHelp or {};	-- 支持重载
Task.tbHelp		= tbHelp;

tbHelp.TSKG_SNEWSTIME	= 2018;		--帮助锦囊-静态最新消息激活时间
tbHelp.TSKG_SNEWSREAD	= 2019;		--帮助锦囊-静态最新消息阅读标记,bit型
tbHelp.TSKG_DNEWSREAD	= 2035;		--帮助锦囊-动态最新消息阅读标记,记录时间

tbHelp.NEWSBUFID	= 1;

if (not tbHelp.tbMenPaiNew) then
	tbHelp.tbMenPaiNew = {};
end

if (not tbHelp.tbMenPaiDa) then
	tbHelp.tbMenPaiDa = {};
end

-- 静态消息的id
tbHelp.NEWSID_ONLEVELUP	= {
	[10]	= 1010,
	[12]	= 1012,
	[20]	= 1020,
	[25]	= 1025,
	[30]	= 1030,
	[50]	= 1050,
	[60]	= 1060,
	[69]	= 1069,
	[70]	= 1070,
	[90]	= 1090,
	[100]	= 1100,
	[120]	= 1120,
};

-- 当gameserver连接到gamecenter上时做的处理
function Task:OnNotifyHelp(nConnectId)
	Task.tbHelp:OnRecConnectMsg(nConnectId);
	SpecialEvent.CompensateGM:OnRecConnectMsg(nConnectId);	--在线补偿指令；
	Domain.tbStatuary:OnRecConnectEvent(nConnectId);
	GCEvent:OnRecConnectEvent(nConnectId);
end

-- 收到连接的消息，进行数据加载
function tbHelp:OnRecConnectMsg(nConnectId)
	-- 向gameserver发送数据
	if (self.tbNewsList) then
		for key, tbNewsInfo in pairs(self.tbNewsList) do
			if (tbNewsInfo) then
				self:WriteLog("OnRecConnectMsg", nConnectId, tbNewsInfo.nKey, tbNewsInfo.szTitle);
				GSExcute(nConnectId, {"Task.tbHelp:ReceiveNewsInfo", tbNewsInfo});
			end
		end
	end
end

-- 从数据库中加载动态消息
function tbHelp:LoadDynamicNewsGC()
	-- 如果gamecenter中消息的数据不存在先加载数据
	self.tbNewsList = {};
	local tbNewsList = GetGblIntBuf(self.NEWSBUFID, 0);
	if (tbNewsList and type(tbNewsList) == "table") then
		self.tbNewsList = tbNewsList;
	end
	self:_SetOrgLevelNews();
	self:_AddMoneyUseNews();
	self:WriteLog("LoadDynamicNewsGC", "Load success");
end

-- 增加金币获得途径消息
function tbHelp:_AddMoneyUseNews()
	local tbAddTime		= {
		year 	= 2008,
		month	= 7,
		day		= 8,
		hour	= 14,
		min		= 0,	
	};
	local nAddTime	= Lib:GetSecFromNowData(tbAddTime);

	local nAddFlag = 0;
	if (not self.tbNewsList[self.NEWSKEYID.NEWS_MONEYUSEWAY]) then
		nAddFlag = 1;
	else
		local tbNewsInfo	= self.tbNewsList[self.NEWSKEYID.NEWS_MONEYUSEWAY];
		if (tbNewsInfo.nAddTime and tbNewsInfo.nAddTime > 0) then
			if (tbNewsInfo.nAddTime < nAddTime) then
				nAddFlag = 1;
			end
		else
			nAddFlag = 1;
		end
	end
	if (nAddFlag == 1) then
		local szTitle	= "如何获得银两";
		local szMsg		= "剑侠世界里获得不绑定银两的主要途径：\n玩家可以通过完成<color=yellow>义军任务<color>和<color=yellow>挖藏宝图<color>获得不绑定的银两。\n\n" .. 
						"<color=yellow>义军任务<color>\n城市和新手村包万同处接义军任务，每完成10次任务大概可获得<color=yellow>10000<color>左右的不绑定银两。\n\n" .. 
						"<color=yellow>挖藏宝图<color>\n连续完成每天的前10轮义军任务后会获得1张藏宝图，按照藏宝图上的说明在指定地点进行挖宝，有机会获得不绑定银两，并有一定的几率挖出地下迷宫，完成迷宫任务后，更会获得<color=yellow>10万或12万不绑定银两<color>哦。\n";
		local nEndTime	= nAddTime + 3600 * 24 * 7;
		self:SetDynamicNews(self.NEWSKEYID.NEWS_MONEYUSEWAY, szTitle, szMsg, nEndTime, nAddTime);
	end
end

-- 更新等级上限消息
function tbHelp:UpdateLevelOpenTimeNews(nLevelOpenId, nLevel)
	local nId = self.NEWSKEYID.NEWS_LEVELOPENTIME;
	local nTime	= KGblTask.SCGetDbTaskInt(nLevelOpenId);
	-- 如果存在这条消息
	if (self.tbNewsList[nId]) then
		if (nTime > self.tbNewsList[nId].nAddTime) then -- 表示不是同一个消息
			self:SetLevelOpenTimeNews(nId, nTime, nLevel);
		end
	else -- 如果不存在这条消息
		self:SetLevelOpenTimeNews(nId, nTime, nLevel);
	end
end

-- 设置等级上限消息
function tbHelp:SetLevelOpenTimeNews(nKey, nTime, nLevel)
	local nAddTime	= nTime;
	local nEndTime	= GetTime() + 3600 * 24 * 7;
	local szTime	= os.date("<color=Yellow>%m月%d日<color>", nTime);
	local szTitle	= string.format("角色等级上限已开放至%d级", nLevel);
	local szMsg		= string.format("<color=yellow>本服务器<color>已于%s开放角色等级上限至<color=yellow>%d<color>级", szTime, nLevel);
	self:WriteLog("SetLevelOpenTimeNews", szTitle, szTime, GetTime());
	self:SetDynamicNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
end

-- 设置盛夏活动
function tbHelp:SetLuckCardNews(szCard, nAddTime, nEndTime, nTime)
	if szCard == nil then
		return 0;
	end
	local szTime	= os.date("%m月%d日", nTime);
	local szTitle	= string.format("%s国庆活动幸运项目", szTime);
	local szMsg		= string.format("<color=yellow>%s<color>国庆活动幸运项目：<color=yellow>%s<color>\n\n所有今天鉴定出的民族大团圆卡-<color=yellow>%s<color>，都可以使用换取幸运项目奖励\n\n奖励内容：\n<color=yellow>  50000绑定银两\n  500绑定金币<color>\n\n对于没有中奖的盛夏活动卡，直接使用换取鼓励奖，使用卡片将自动收藏在盛夏活动卡收藏册内。",szTime, szCard, szCard);
	self:WriteLog("SetLuckCardNews", szTitle, szTime, GetTime());
	self:SetDynamicNews(self.NEWSKEYID.NEWS_LUCKCARD, szTitle, szMsg, nEndTime, nAddTime);
end

-- 设置盛夏活动信息
function tbHelp:SetCollectCardNews(nAddTime, nEndTime, szTitle, szMsg, nKey)
	local tbTemp = 
	{
		[1] = self.NEWSKEYID.NEWS_COLLECTCARD_1,
		[2] = self.NEWSKEYID.NEWS_COLLECTCARD_2,
		[3] = self.NEWSKEYID.NEWS_COLLECTCARD_3,
		[4] = self.NEWSKEYID.NEWS_COLLECTCARD_4,
		[5] = self.NEWSKEYID.NEWS_COLLECTCARD_5,
		[6] = self.NEWSKEYID.NEWS_COLLECTCARD_6,
	}
	self:WriteLog("SetLuckCardNews", szTitle, szTime, GetTime());
	self:SetDynamicNews(tbTemp[nKey], szTitle, szMsg, nEndTime, nAddTime);
end

function tbHelp:_SetOrgLevelNews()
	local nEndTime	= KGblTask.SCGetDbTaskInt(DBTASK_HELPNEWS_TIME); 
	local nAddTime	= nEndTime - 3600 * 24 * 3;
	local szTitle	= KGblTask.SCGetDbTaskStr(DBTASK_HELPNEWS_TITLE);
	local szMsg		= KGblTask.SCGetDbTaskStr(DBTASK_HELPNEWS_MSG1) .. KGblTask.SCGetDbTaskStr(DBTASK_HELPNEWS_MSG2)
			.. KGblTask.SCGetDbTaskStr(DBTASK_HELPNEWS_MSG3);
	if (szTitle ~= "" and szMsg ~= "") then
		self:SetDynamicNews(self.NEWSBUFID, szTitle, szMsg, nEndTime, nAddTime);
		KGblTask.SCSetDbTaskStr(DBTASK_HELPNEWS_TITLE, "");
		KGblTask.SCSetDbTaskStr(DBTASK_HELPNEWS_MSG1, "");
		KGblTask.SCSetDbTaskStr(DBTASK_HELPNEWS_MSG2, "");
		KGblTask.SCSetDbTaskStr(DBTASK_HELPNEWS_MSG3, "");
		KGblTask.SCSetDbTaskInt(DBTASK_HELPNEWS_TIME, 0);
	end
end

-- 获得静态消息阅读标记
function tbHelp:GetSNewsReaded(nNewsId)
	local bReaded	= me.GetTaskBit(self.TSKG_SNEWSREAD, nNewsId);
	return bReaded;
end

-- 设置静态消息的阅读标记
function tbHelp:SetSNewsReaded(nNewsId)
	local nTime	= me.SetTaskBit(self.TSKG_SNEWSREAD, nNewsId, 1);
	return nTime;
end

-- 获得动态消息的阅读标记
function tbHelp:GetDNewsReaded(nNewsId)
	local nTime	= me.GetTask(self.TSKG_DNEWSREAD, nNewsId);
	if (self.tbNewsList and self.tbNewsList[nNewsId]) then
		local nNewsTime = self.tbNewsList[nNewsId].nAddTime;
		if (nTime >= nNewsTime) then
			return 1;
		end
	end
	return 0;
end

-- 设置动态消息的阅读标记
function tbHelp:SetDNewsReaded(nNewsId)
	local nNewsTime = self.tbNewsList[nNewsId].nAddTime;
	me.SetTask(self.TSKG_DNEWSREAD, nNewsId, nNewsTime);
end

-- 清除阅读标记(测试用的)
function tbHelp:ClearNewsReaded()
	me.ClearTaskGroup(self.TSKG_SNEWSREAD, 1);
	me.ClearTaskGroup(self.TSKG_DNEWSREAD, 1);
end

-- 获取静态消息阅读时间
function tbHelp:GetSNewsTime(nNewsId)
	local nTime	= me.GetTask(self.TSKG_SNEWSTIME, nNewsId);
	return nTime;
end

-- 激活静态消息的时间
function tbHelp:ActiveSNews(nNewsId)
	local nNowTime	= GetTime();
	me.SetTask(self.TSKG_SNEWSTIME, nNewsId, nNowTime);
end

--== 服务端 ==--
-- 增加动态消息，增加前必须确定消息的id是否正确，每个消息的id是唯一的
function tbHelp:AddDNews(nKey, szTitle, szMsg, nEndTime, nAddTime)
	self:SetDynamicNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
end

-- 保存动态消息 这个是不同步的保存
function tbHelp:SaveDynamicNews(tbNewsList)
	SetGblIntBuf(self.NEWSBUFID, 0, 0, tbNewsList);
end

-- 设置动态消息内容
function tbHelp:SetDynamicNews(nKey, szTitle, szMsg, nEndTime, nAddTime)
	self:WriteLog("tbHelp:SetDynamicNews", nKey, szTitle, szMsg, nEndTime, nAddTime);
	if (MODULE_GAMESERVER) then -- 如果是gameserver就向gamecenter发送数据
		GCExcute({"Task.tbHelp:SetDynamicNews", nKey, szTitle, szMsg, nEndTime, nAddTime});
	end
	if (MODULE_GC_SERVER) then -- 如果是gamecenter就直接处理 
		local tbNewsInfo = {
				nKey 			= nKey,
				szTitle 		= szTitle,
				nAddTime		= nAddTime,
				nEndTime		= nEndTime,
				szMsg			= szMsg, 
			};
			
		self.tbNewsList[nKey] = tbNewsInfo;
		self:SaveDynamicNews(self.tbNewsList);
		GlobalExcute({"Task.tbHelp:ReceiveNewsInfo", tbNewsInfo});
	end
end

function tbHelp:ReceiveNewsInfo(tbNewsInfo)
	self:WriteLog("Get The Dynamic new nKey: , szTitle:  ", tbNewsInfo.nKey, tbNewsInfo.szTitle);
	if (not self.tbNewsList) then
		self.tbNewsList = {};
	end
	self.tbNewsList[tbNewsInfo.nKey] = tbNewsInfo;
	local tbPlayerList	= KPlayer.GetAllPlayer();
	for _, pPlayer in ipairs(tbPlayerList) do
		pPlayer.CallClientScript({"Task.tbHelp:OnUpdateNews", tbNewsInfo});
	end
end

function tbHelp:GetDNewsTime(nNewsId)
	if (self.tbNewsList and self.tbNewsList[nNewsId]) then
		return self.tbNewsList[nNewsId].nAddTime; 
	end
	return 0;
end

function tbHelp:GetENewsTime(nNewsId)
	if (self.tbNewsList and self.tbNewsList[nNewsId]) then
		return self.tbNewsList[nNewsId].nEndTime; 
	end
	return 0;
end

function tbHelp:ClearDNews()
	KGblTask.SCSetDbTaskInt(DBTASK_HELPNEWS_TIME, 0); 
	
	GlobalExcute({"Task.tbHelp:UpdateAll"});
end

function tbHelp:OnLevelUp(nLevel)
	local nNewsId	= self.NEWSID_ONLEVELUP[nLevel];
	if (nNewsId) then
		self:ActiveSNews(nNewsId);
	end

	if (nLevel == 69 and self:GetDNewsTime(self.NEWSKEYID.NEWS_LEVELUP) == 0)  then
		local szTitle	= string.format("%s率先冲上69级！", me.szName);
		local szMsg		= string.format("最先达到69级的武林高手诞生了！\n姓名：<color=gold>%s<color>\n性别：<color=gold>%s<color>\n门派路线：<color=gold>%s<color>\n累计在线：<color=gold>%.1f<color>小时",
			me.szName, Player.SEX[me.nSex], Player:GetFactionRouteName(me.nFaction, me.nRouteId), me.nOnlineTime / 3600);
		local nNowTime 	= GetTime(); 
		local nEndTime	= nNowTime + 3600 * 24 * 3;
		self:AddDNews(self.NEWSKEYID.NEWS_LEVELUP, szTitle, szMsg, nEndTime, nNowTime);
	end
end

-- 玩家登陆的时候处理
function tbHelp:OnLogin()
	if (not self.tbNewsList) then
		return;
	end
	for key, tbValue in pairs(self.tbNewsList) do
		if (tbValue) then
			me.CallClientScript({"Task.tbHelp:OnUpdateNews", tbValue});
		end
	end
end


function tbHelp:WriteLog(...)
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Task", "Help", unpack(arg));
	end
	if (MODULE_GC_SERVER) then
		Dbg:Output("Task", "Help", unpack(arg));
	end
end

--1.首页，2.活动推荐，3.最新活动，4.详细活动，5.搜索选项
--Task.tbHelp:OpenNews(nType, szTitle)
function tbHelp:OpenNews(nType, szTitle)
	me.CallClientScript({"Task.tbHelp:OpenNews_C",nType, szTitle});
end

function tbHelp:OpenNews_C(nType, szName)
	UiManager:OpenWindow(Ui.UI_HELPSPRITE);
    local uiHelpSprite = Ui(Ui.UI_HELPSPRITE);
    uiHelpSprite:OnButtonClick("BtnHelpPage"..nType);
    if nType == 1 then
	    for key, tbNews in pairs(uiHelpSprite.tbNewsInfo) do
	        if (tbNews.szName == szName) then
	            uiHelpSprite:Link_news_OnClick("", key);
	            break;
	        end
	    end	
	end
    if nType == 2 then
	   for nId, tbMInfo in pairs(uiHelpSprite.tbRecInfo) do
	        if (tbMInfo.szName == szName) then
	            uiHelpSprite:Link_tuijian_OnClick("", nId);
	            break;
	        end
	    end	
	end
	if nType == 3 then
	   for nId, tbMInfo in pairs(uiHelpSprite.tbNewsActFileData) do
	        if (tbMInfo[1] == szName) then
	            uiHelpSprite:Link_newaction_OnClick("", nId);
	            break;
	        end
	    end
	end
	if nType == 4 then
	   for key, tbMInfo in pairs(uiHelpSprite.tbHelpContent) do
	        if (string.find(key,szName) and string.find(key,szName) > 0) then
	            uiHelpSprite:Link_helps_OnClick("", key);
	            break;
	        end
	    end
	end
	if nType == 5 then
		uiHelpSprite.szSearchKey = szName;
		uiHelpSprite:SearchHelpList(szName);
		uiHelpSprite:UpdatePage(1);
		for key, tbMInfo in pairs(uiHelpSprite.tbHelpContent) do
	        if (string.find(key,szName) and string.find(key,szName) > 0) then
	            uiHelpSprite:Link_helps_OnClick("", key)
	            break;
	        end
	    end
	end
end

-- TODO: REOMVE zhengyuhua 临时消息 一周后删掉
if MODULE_GC_SERVER then
	function tbHelp:SetLinShiNews()
		local szHelp = [[
  <color=yellow>门派竞技参赛等级限制调整<color>
  
  从即日起，当本服务器开启联赛后的每个月<color=yellow>1号~7号<color>内召开的门派竞技比赛，100级以上的角色也可以参加
  
  同时，门派竞技比赛的开启最低人数从16人降至<color=yellow> 8 <color>人


		]]
		if not self.tbNewsList[self.NEWSKEYID.NEWS_STARTDOMAIN] then
			local nAddTime = GetTime();
			local nEndTime = nAddTime + 3600 * 24 * 7;
			-- 暂时使用领土战消息的ID~用完记得删掉
			self:SetDynamicNews(self.NEWSKEYID.NEWS_STARTDOMAIN, "门派竞技参赛等级限制调整", szHelp, nEndTime, nAddTime);
		end
	end
	GCEvent:RegisterGCServerStartFunc(Task.tbHelp.SetLinShiNews, Task.tbHelp);
end


--== 客户端 ==--

if (MODULE_GAMECLIENT) then
	if (not tbHelp.tbNewsList) then
		tbHelp.tbNewsList = {};
	end
	
	if (not tbHelp.tbLottoryData) then
		tbHelp.tbLottoryData = {};
	end
end

function tbHelp:OnUpdateNews(tbNewsInfo)
	if (not self.tbNewsList) then
		self.tbNewsList = {};
	end
	self.tbNewsList[tbNewsInfo.nKey] = tbNewsInfo;
end

function tbHelp:OnUpdateLottroyData(tbData)
	if (not self.tbLottoryData) then
		self.tbLottoryData = {};
	end
	self.tbLottoryData = tbData;
end

if (MODULE_GAMESERVER) then	-- GS专用
	-- 注册事件回调
	PlayerEvent:RegisterGlobal("OnLevelUp", tbHelp.OnLevelUp, tbHelp);
	PlayerEvent:RegisterGlobal("OnLogin", tbHelp.OnLogin, tbHelp);
end
