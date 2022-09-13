-- 文件名　：dts_vote_def.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-07 20:25:26
-- 功能    ：

SpecialEvent.Dts_Vote = SpecialEvent.Dts_Vote or {};
local tbDtsVote = SpecialEvent.Dts_Vote;

tbDtsVote.IS_OPEN			  		= 1;		--活动开关

tbDtsVote.emVOTE_STATE_NONE  	= 0;			--关闭
tbDtsVote.emVOTE_STATE_SIGN 		= 1;			--开启
tbDtsVote.emVOTE_STATE_AWARD 	= 2;			--领奖
tbDtsVote.TIME_SIGN_START 		= 20110928;	--投票时间
tbDtsVote.TIME_SIGN_END   		= 20110930;	--投票时间
tbDtsVote.TIME_AWARD_START 		= 20111012;	--领奖时间
tbDtsVote.TIME_AWARD_END		= 20111018;	--领奖时间

tbDtsVote.ITEM_AWARD			= {18, 1, 1476, 1}; 	--原石宝箱
tbDtsVote.ITEM_VOTE				= {18, 1, 1469, 1}; 	--祝福卡

tbDtsVote.LEVEL_LIMIT				= 60;		--玩家要求等级

tbDtsVote.tbRate 		= {2, 4, 8, 16, 32, 63, 128, 256, 512, 1024};	--权重
tbDtsVote.nMinValue 	= 590000;	--最低奖池
tbDtsVote.tbBoxRate	= 0.18;		--宝箱占的概率
tbDtsVote.tbCoinRate 	= 1 - tbDtsVote.tbBoxRate;	--绑金占的概率
tbDtsVote.tbBaseCoin1 	= 200;		--投票基础奖励
tbDtsVote.tbBaseCoin2	= 500;		--领奖保底绑金奖励
tbDtsVote.tbBaseMoney	= 30000;		--领奖保底绑银奖励
tbDtsVote.tbBoxValue	= 6600;		--每个箱子价值量
tbDtsVote.nCoinMin	= 480000;	--奖池最低绑金奖励
tbDtsVote.nBoxMin		= 15;			--奖池最低宝箱个数
tbDtsVote.nPerValue	= 5 * 100;		--每张票得价值量

tbDtsVote.TSK_GROUP 			= 2176;
tbDtsVote.TSKSTR_FANS_NAME 	= {18, 98};	--存储美女名和票数,最多50个美女，共250个任务变量(变量不能更换,用了偏移处理)
tbDtsVote.TSK_Award_StateEx1	= 99; 		--粉丝领奖
tbDtsVote.TSK_Award_StateEx2	= 100; 		--基础奖励
tbDtsVote.DEF_TASK_SAVE_FANS	= 8; 			--多少个任务变量记录一个投票玩家和票数(影响TSKSTR_FANS_NAME存储的美女数量)
tbDtsVote.DEF_SORT_MAX_NUM 	= 10; 		--只排序前10

tbDtsVote.tbAwardList = tbDtsVote.tbAwardList or {};		--竞猜最终奖励list

tbDtsVote.TIME_SCHTASK= {0,20,40}	--每个小时的20分钟间隔发世界消息

--获得当前状态
function tbDtsVote:GetState()
	if self.IS_OPEN == 0 then
		return self.emVOTE_STATE_NONE;
	end
	
	local nDate = tonumber(GetLocalDate("%Y%m%d"));	
	if nDate >= self.TIME_SIGN_START and nDate <= self.TIME_SIGN_END then
		return self.emVOTE_STATE_SIGN;
	end
	if nDate >= self.TIME_AWARD_START and nDate <= self.TIME_AWARD_END then
		return self.emVOTE_STATE_AWARD;
	end
end

--奖池信息
function tbDtsVote:GenAwardInfo()
	local tbBuf = self:GetGblBuf();
	local nTotleTicketsInSys = 0;	--奖池
	for szName, tb in pairs(tbBuf) do		
		nTotleTicketsInSys = nTotleTicketsInSys + tb.nTickets;
	end
	if nTotleTicketsInSys <= 0 then
		return self.nCoinMin, self.nBoxMin;
	end
	nTotleTicketsInSys = nTotleTicketsInSys * self.nPerValue + self.nMinValue;			--奖池重新换算
	local nCoinCount = math.floor(nTotleTicketsInSys * self.tbCoinRate);				--奖池绑金数量
	local nBoxCount = math.floor(nTotleTicketsInSys * self.tbBoxRate / self.tbBoxValue);	--箱子的个数
	return nCoinCount, nBoxCount;
end
