-- 文件名  : girl_vote_new_def.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-30 17:00:29
-- 描述    : 

SpecialEvent.Girl_Vote_New = SpecialEvent.Girl_Vote_New or {};
local tbGirl = SpecialEvent.Girl_Vote_New;

tbGirl.emVOTE_STATE_NONE  = 0;
tbGirl.emVOTE_STATE_SIGN  = 1;
tbGirl.emVOTE_STATE_AWARD = 2;
tbGirl.emVOTE_STATE_FREE  = 3;

tbGirl.IS_OPEN			  = 1;

tbGirl.TIME_SIGN_START = 20101012;
tbGirl.TIME_SIGN_END   = 20101026;

tbGirl.TIME_AWARD_START = 20101028;
tbGirl.TIME_AWARD_END	= 20101102;

tbGirl.ITEM_AWARD	= {18,1,1024,1}; -- 投票奖励
tbGirl.ITEM_VOTE	= {18,1,1023,1}; -- 投票道具


tbGirl.ITEM_WAIZHUANG = {1,26,37,1};   --外帽
tbGirl.ITEM_WAIZHUANG_2 = {1,25,37,1}; -- 外衣
tbGirl.TITLE_JOIN  = {6,44,3,8};    -- 参加的奖励
tbGirl.TITLE_TOP_10 = {6,44,5,9};  -- 前10的称号
tbGirl.TITLE_TOP_1  = {6,44,6,10};
tbGirl.TITLE_VOTER_VOTES = {6,44,4,8};   -- 投票超过499的玩家
tbGirl.TITLE_VOTER_FANS = {6,45,7,8};    -- 投票最多的玩家

tbGirl.LEVEL_LIMIT	= 60;
tbGirl.AWARD_VOTE_LIMIT	= 499;   -- 至少得票超过499

tbGirl.TSK_GROUP 		= 2141;
tbGirl.TSKSTR_FANS_NAME = {1, 250};	--存储美女名和票数,最多50个美女，共250个任务变量(变量不能更换,用了偏移处理)
tbGirl.TSK_FANS_GATEWAYID = {260, 510};	--存储决赛投票的玩家区服(变量不能更换,用了偏移处理)
tbGirl.TSK_Vote_Girl 	= 256;	--记录美女报名后的标志，预防出问题后可以查询到哪些美女报名了；
tbGirl.TSK_Award_State1 = 257;	--领奖
tbGirl.TSK_Award_StateEx1= 258; --粉丝领奖
tbGirl.TSK_FANS_CLEAR	 = 259; --第二轮记录任务变量清0标志;
tbGirl.TSK_Award_State2	 = 511; --决赛领奖
tbGirl.TSK_Award_StateEx2= 512; --决赛粉丝领奖
tbGirl.TSK_Award_Buff	 = 513; --技能buff任务变量（记录时间）
tbGirl.TSK_Award_Buff_Level	= 514; --技能buff任务变量（记录等级）
tbGirl.TSK_TOTAL_TICKETS  = 515;		--总共的投票数

tbGirl.DEF_TASK_OFFSET 	 = 259; 	--粉丝存储美女和区服变量偏移值
tbGirl.DEF_TASK_SAVE_FANS= 10; 		--多少个任务变量记录一个投票玩家和票数(影响TSKSTR_FANS_NAME存储的美女数量)
tbGirl.DEF_AWARD_TICKETS 	= 499; 	--499票
tbGirl.DEF_FANS_MAX_NUM 	= 5; 	--一个美女5个FANS
tbGirl.DEF_SORT_MAX_NUM 	= 10; 	--只排序前10

function tbGirl:GetState()
	if self.IS_OPEN	== 0 then
		return self.emVOTE_STATE_NONE;
	end		
	
	local nDate = tonumber(GetLocalDate("%Y%m%d"));	
	if nDate >= self.TIME_SIGN_START and nDate <= self.TIME_SIGN_END then
		return self.emVOTE_STATE_SIGN;
	end
	
	if nDate > self.TIME_SIGN_END and nDate < self.TIME_AWARD_START then
		return self.emVOTE_STATE_FREE;
	end

	if nDate >= self.TIME_AWARD_START and nDate <= self.TIME_AWARD_END then
		return self.emVOTE_STATE_AWARD;
	end	

	return self.emVOTE_STATE_NONE;
end