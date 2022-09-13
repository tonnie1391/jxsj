-- 文件名  : SeventhEvening_def.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-08 10:28:54
-- 描述    : 

local SeventhEvening = SpecialEvent.SeventhEvening or {};
SpecialEvent.SeventhEvening = SeventhEvening;

SeventhEvening.tbXiangSiShi 			= {18,1,974,1};		--相思石
SeventhEvening.tbXiangSiShi 			= {18,1,975,1};		--金鹊羽
SeventhEvening.tbSiXian 				= {18,1,976,1};   	--七夕丝线
SeventhEvening.tbLiBao 					= {18,1,977,1};		--金鹊礼包
SeventhEvening.tbLiBaoKuiZeng 			= {18,1,978,1};		--金鹊礼包[馈赠]
SeventhEvening.tbXiYu 					= {18,1,966,1};		--鹊羽
SeventhEvening.tbLiuLiShi 				= {18,1,967,1};   	--琉璃石
SeventhEvening.tbChai					= {18,1,968,1};		--金鹊琉璃钗
SeventhEvening.tbAwordFinal				= {18,1,991,1};		--幸福大礼包
SeventhEvening.tbMaskAword				= {{1,13,78,1},{1,13,79,1}}	--幸福榜第一名面具奖励
SeventhEvening.tbTitleAword				= {{6,34,1,9},{6,35,1,9}}	--幸福榜称号奖励
SeventhEvening.nLevel 					= 60;				--活动等级限制
SeventhEvening.nGTPMkPMin_Couplet 		= 500;				--合成需要的精活
SeventhEvening.nCount_XiYu				= 3;				--合成需要的鹊羽数
SeventhEvening.nCount_LiuLiShi			= 3;				--合成需要的琉璃石数
SeventhEvening.nFavorNum				= 500;				--送礼包加的亲密度
SeventhEvening.OpenTime 				= 20100810;			--王母&&鹊桥活动开始日期
SeventhEvening.CloseTime 				= 20100821;			--王母&&鹊桥活动结束日期
SeventhEvening.nAcceptCount				= 10;				--接受金鹊礼包数目
SeventhEvening.nWangMuId				= 6869;				--王母模板Id
SeventhEvening.nWangMuAIId				= 6870;				--王母AI模板Id
SeventhEvening.nQueShen					= 6873;				--鹊神模板id
SeventhEvening.tbWangMuPoint			= {{5,1617,3090}, {6,1565,3110}};	--王母出生坐标
SeventhEvening.tbQueShen				= {29, 47040/32, 120992/32};		--鹊神坐标

SeventhEvening.TASKID_GROUP				= 2131;		--任务组
SeventhEvening.TASKID_ACCEPTNUM			= 1;		--总共接受礼物的数目
SeventhEvening.TASKID_USELIBAO			= 2;		--使用金鹊礼包[馈赠] 次数
SeventhEvening.TASKID_USELIBAO_DAY		= 3;		--使用金鹊礼包[馈赠] 日期
SeventhEvening.TASKID_ISGETAWORD		= 71;		--使用金鹊礼包[馈赠] 日期

SeventhEvening.tbQueQiaoAward = {		--送金鹊礼包奖励
		[1] = {18,1,987,1},
		[2] = {18,1,988,2},
	};

SeventhEvening.tbWangMuChat = {
	"人们所谓的爱情，都是过眼云烟，华而不实。",
	"人间一年等于仙界一天，时间对我来说没有意义。",
	"三千年结一次的蟠桃啊，诸位诚心祈求吧。",
	"我划出银河阻隔了牛郎织女，但我并非无情。",
	"人人以情为尊，天上人间岂不乱了章法。",
	"孤家寡人，请勿觉得凄冷，迎接清风，先得明月。",
	"人要认清自己不过是个凡人，而不是神。",
	"得不到你所爱的，就爱你所得的。"
	};

--数据
SeventhEvening.nNpc	= 0;			--Add王母,鹊神的标志
SeventhEvening.nNpcXiGuNiang	= 0;			--喜姑娘
SeventhEvening.nNpcKuiXing		= 0;			--魁星

-------------------------------------------------------
-- by zhangjinpin@kingsoft
-------------------------------------------------------
SeventhEvening.TASK_DAILY_QUESTION 		= 4;		--当日是否答题
SeventhEvening.TASK_DAILY_TREE 			= 5;		--当日是否种树
SeventhEvening.TASK_GET_SHIJI 			= 6;		--是否获得诗集
SeventhEvening.TASK_XIALV_POINT 		= 7;		--侠侣幸福积分
SeventhEvening.TASK_SHIJI_AWARD			= 8;		--是否领取诗集奖励

SeventhEvening.TASK_SHIJI =
{
	[1] = {{11, "纤"}, {12, "云"}, {13, "弄"}, {14, "巧"}},
	[2] = {{15, "飞"}, {16, "星"}, {17, "传"}, {18, "恨"}},
	[3] = {{19, "银"}, {20, "汉"}, {21, "迢"}, {22, "迢"}, {23, "暗"}, {24, "渡"}},
	[4] = {{25, "金"}, {26, "风"}, {27, "玉"}, {28, "露"}, {29, "一"}, {30, "相"}, {31, "逢"}}, 
	[5] = {{32, "便"}, {33, "胜"}, {34, "却"}, {35, "人"}, {36, "间"}, {37, "无"}, {38, "数"}}, 
	[6] = {{39, "柔"}, {40, "情"}, {41, "似"}, {42, "水"}}, 
	[7] = {{43, "佳"}, {44, "期"}, {45, "如"}, {46, "梦"}}, 
	[8] = {{47, "忍"}, {48, "顾"}, {49, "鹊"}, {50, "桥"}, {51, "归"}, {52, "路"}}, 
	[9] = {{53, "两"}, {54, "情"}, {55, "若"}, {56, "是"}, {57, "久"}, {58, "长"}, {59, "时"}}, 
	[10] = {{60, "又"}, {61, "岂"}, {62, "在"}, {63, "朝"}, {64, "朝"}, {65, "暮"}, {66, "暮"}}, 
};
SeventhEvening.szArticle = "纤云弄巧，飞星传恨，银汉迢迢暗渡。金风玉露一相逢，便胜却人间无数。柔情似水，佳期如梦，忍顾鹊桥归路。两情若是久长时，又岂在朝朝暮暮！";

SeventhEvening.tbShijiAward =
{
	[1] = {56, 10},
	[2] = {50, 5},
	[3] = {35, 3};
};

SeventhEvening.tbKuixingTitleId 	= {6, 36, 1, 0};
SeventhEvening.tbSpecailMaleId		= {1, 13, 78, 1};
SeventhEvening.tbSpecailFemaleId	= {1, 13, 79, 1};

SeventhEvening.tbShijiId 			= {18, 1, 979, 1};
SeventhEvening.tbShijiBoxId 		= {18, 1, 990, 1};
SeventhEvening.tbTongxinshuiId 		= {18, 1, 970, 1};
SeventhEvening.tbYanhuaBoxId 		= {18, 1, 989, 1};
SeventhEvening.tbTongxinguoId		= {18, 1, 972, 1};
SeventhEvening.tbXialvguoId			= {18, 1, 973, 1};


SeventhEvening.SHUZHONG_ID	 		= 6879;
SeventhEvening.SHUMIAO_ID			= 6880;
SeventhEvening.TONGXINSHU_ID		= 6874;
SeventhEvening.XIALVSHU_ID			= 6875;

SeventhEvening.MAX_BUFFER_LEN		= 20;
SeventhEvening.tbXialvBuffer 		= SeventhEvening.tbXialvBuffer or {};
SeventhEvening.tbXialvBuffer1 		= SeventhEvening.tbXialvBuffer1  or {};	--合服buff

-- 获取诗集奖励箱子数量
function SeventhEvening:GetShijiAward(pPlayer)
	local nCount = self:GetShijiCount(pPlayer);
	if nCount <= 0 then
		return 0;
	end
	for _, tbInfo in ipairs(self.tbShijiAward) do
		if nCount >= tbInfo[1] then
			return tbInfo[2];
		end
	end
	return 0;
end

-- 获取诗集文字数量
function SeventhEvening:GetShijiCount(pPlayer)
	local nRet = 0;
	for i = 11, 66 do
		if me.GetTask(self.TASKID_GROUP, i) == 1 then
			nRet = nRet + 1;
		end
	end
	return nRet;
end

-- 计时器清除npc
function SeventhEvening:OnTimerDelNpc(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.Delete();
	return 0;
end
