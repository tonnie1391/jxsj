--动态消息统一管理
--(如不需要，尽量少用动态消息，效率问题。如消息是静态的，用静态消息处理。)
--sunduoliang
--2008.11.11

if (MODULE_GC_SERVER) then
Require("\\script\\misc\\gcevent.lua");
end

local tbHelp	= Task.tbHelp or {};
Task.tbHelp		= tbHelp;

-- 动态消息的id: 上限最多32个，超过将会有可能无法存储和宕机，请节约使用
tbHelp.NEWSKEYID = {
	NEWS_LEVELUP 			= 1, 	--等级上限信息[常规]
	NEWS_MENPAIJINGJI_NEW 	= 2,	--门派新人王[常规]现在联赛在用，现在还没时间改
	NEWS_MENPAIJINGJI_DASHIXING = 3,--门派大师兄[常规]
	NEWS_MONEYUSEWAY	= 4, 	-- 剑侠币获得途径的消息id[常规]
	NEWS_LEVELOPENTIME	= 5, 	-- 开放等级上限的消息id[常规]
	NEWS_LUCKCARD 		= 6,	-- 国庆活动 09-10-11过期
	NEWS_WLDH_PROSSESSION 	= 7,	-- 武林大会资格认定
	NEWS_LOTTERY_0909	= 8,   	--9月促销抽奖
	NEWS_YOULONGMIBAO	= 9,	-- 游龙秘宝
	NEWS_MARRY_SUPER	= 10,	-- 皇家婚礼
	NEWS_MARRY_DAILY	= 11,	-- 每日婚礼
	--NEWS_XKLAND_RESULT	= 12,	-- 侠客岛
	NEWS_NEWLAND_RESULT	= 12,	-- 铁浮城
	NEWS_BEAUTYHERO		= 13,	-- 巾帼英雄赛 10-12-01过期
	--NEWS_COLLECTCARD_1	= 7,	--公测活动 11.18过期
	--NEWS_COLLECTCARD_2	= 8,	--公测活动 11.18过期
	--NEWS_COLLECTCARD_3	= 9,	--公测活动 11.18过期
	--NEWS_COLLECTCARD_4	= 10,	--公测活动 11.18过期
	--NEWS_COLLECTCARD_5	= 11,	--金山20周年 11.25过期
	--NEWS_COLLECTCARD_6	= 12,	--金山20周年 11.25过期
	--NEWS_WANGLAOJI_1 	= 13,	--金山20周年 11.25过期
	--NEWS_WANGLAOJI_2 	= 14,	--王老吉防上火行动11.25
	--NEWS_ZHONGQIU 		= 15,	--王老吉延长三周11.25
	NEWS_VIETNAM_1		= 14,	--越南ke
	NEWS_VIETNAM_2		= 15,	--越南ke
	NEWS_LEAGUE 		= 16,	--武林联赛[常规]
	NEWS_LEAGUE_ADV		= 17,	--联赛八强赛动态战报[常规]
	NEWS_JINBIFANHUAN	= 18,	--金山20周年 11.25过期 
	NEWS_STARTDOMAIN	= 19,	--领土战开启
	NEWS_MENPAI_NEW		= 20,	--门派新人王
	NEWS_BAIBAOXIANG	= 21,	--百宝箱爆机
	NEWS_STATUARY		= 22,	--树立雕像
	NEWS_DOMAINTASK		= 23,	--霸主任务活动结果揭晓
	NEWS_LOTTERY_0908	= 24,   --8月促销抽奖
	NEWS_WLDH_1			= 25,	--武林大会单人
	NEWS_WLDH_2			= 26,	--武林大会双人
	NEWS_WLDH_3			= 27,	--武林大会三人
	NEWS_WLDH_4			= 28,	--武林大会五行五人
	NEWS_WLDH_5			= 29,	--武林大会大型团体赛
	NEWS_GBWLLS_DAILY	= 30,	-- 跨服联赛每日公告
	NEWS_VIETNAM_3		= 31,	--越南ke
};

tbHelp.tbDyNews = 
{
	--默认格式
	{
		nKey 		= 0,	--key值，默认为0
		nStartTime 	= 0,	--开启时间 -年月日时分200810101200，默认为0
		nEndTime 	= 0,	--结束时间 -年月日时分200810101224，默认为0
		nGlobalKey 	= 16,	--默认为开服时间的全局变量
		nStartDay 	= 0,	--开服几天后开启（和nLastDay搭配使用），默认为0
		nLastDay 	= 0,	--开启后持续时间（和nStartDay搭配使用），默认为0
		szTitle		= "",	--标题
		szContent 	= [[	--内容
		]],
	},
	
}

function tbHelp:RegisterDyNews(tbNews)
	if not self.tbDyNews then
		self.tbDyNews = {};
	end
	table.insert(self.tbDyNews, tbNews);
end

function tbHelp:UpdateDyNews()
	for _, tbNews in pairs(self.tbDyNews) do
		local nKey = tonumber(tbNews.nKey) or 0;
		local nStartTime = tonumber(tbNews.nStartTime) or 0;
		local nEndTime = tonumber(tbNews.nEndTime) or 0;
		local nGlobalKey = tonumber(tbNews.nGlobalKey) or DBTASD_SERVER_STARTTIME;
		local nStartDay = tonumber(tbNews.nStartDay) or 0;
		local nLastDay = tonumber(tbNews.nLastDay) or 0;
		local szTitle = tbNews.szTitle;
		local szContent = tbNews.szContent;
		local nAddSec = 0;
		local nEndSec = 0;
		if nStartDay > 0 and nLastDay > 0 then
			nAddSec = KGblTask.SCGetDbTaskInt(nGlobalKey) + nStartDay*24*3600;
			nEndSec = nAddSec + nLastDay * 24 * 3600;
		end
		if nStartTime > 0 then
			nAddSec = Lib:GetDate2Time(nStartTime);
		end
		if nEndTime > 0 then
			nEndSec = Lib:GetDate2Time(nEndTime);
		end
		if nKey > 0 then
			self:SetDynamicNews(nKey, szTitle, szContent, nEndSec, nAddSec);
		end
	end
end

if (MODULE_GC_SERVER) then
	GCEvent:RegisterGCServerStartFunc(Task.tbHelp.UpdateDyNews, Task.tbHelp);
end
