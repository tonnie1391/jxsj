--圣诞活动
--sunduoliang
--2008.12.16

SpecialEvent.Xmas2008 = SpecialEvent.Xmas2008 or {};

local tbEvent = SpecialEvent.Xmas2008;

tbEvent.tbState = {
	20091222,
	20100105,
	20100124,
}

tbEvent.szDropYanHua = "\\setting\\event\\jieri\\200812_xmas\\yanhua_dropitem.txt"; 
tbEvent.tbCallNpcId 	= {[1] = 3469, [2] = 3470, [3] = 3471};	--npcId 
tbEvent.tbCallNpcRate	= 
{
	--圣诞老人出现概率	圣诞树出现概率	雪堆出现概率
	[1] = {tbRate={0.1, 0.3, 0.6}, tbPos = {[1]={1607, 3125}, [2]={1617, 3125}, [3]={1604, 3124}} , nLiveTime=10 * 60 *  Env.GAME_FPS, },	--白虎堂一层
	[2] = {tbRate={0.1, 0.3, 0.6}, tbPos = {[1]={1607, 3125}, [2]={1617, 3125}, [3]={1604, 3124}} , nLiveTime=10 * 60 *  Env.GAME_FPS, },	--白虎堂二层
	[3] = {tbRate={0.1, 0.3, 0.6}, tbPos = {[1]={1607, 3125}, [2]={1617, 3125}, [3]={1604, 3124}} , nLiveTime=10 * 60 *  Env.GAME_FPS, },	--白虎堂三层
	[4] = {tbRate={	 0,	  1,   0}, tbPos = {[1]={1470, 3464}, [2]={1470, 3464}, [3]={1470, 3464}} , nLiveTime=90 * 60 *  Env.GAME_FPS, },	--门派竞技
	[5] = {tbRate={0.1, 0.3, 0.6}, tbPos = {[1]={1622, 3274}, [2]={1694, 3469}, [3]={1776, 3284}} , nLiveTime=60 * 60 *  Env.GAME_FPS, },	--宋金战场 九曲
	[6] = {tbRate={0.1, 0.3, 0.6}, tbPos = {[1]={1605, 3159}, [2]={1746, 3332}, [3]={1705, 3289}} , nLiveTime=60 * 60 *  Env.GAME_FPS, },	--宋金战场 五丈
	[7] = {tbRate={0.1, 0.3, 0.6}, tbPos = {[1]={2156, 3625}, [2]={2046, 3730}, [3]={2216, 3705}} , nLiveTime=60 * 60 *  Env.GAME_FPS, },	--宋金战场 蟠龙
	[8] = {tbRate={0.1, 0.3, 0.6}, tbPos = {[1]={1690, 2985}, [2]={1826, 3043}, [3]={1953, 2943}} , nLiveTime=60 * 60 *  Env.GAME_FPS, },	--宋金战场 嘉峪关
};
function tbEvent:Check()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate < self.tbState[1] then 
		return -1;
	end
	if nCurDate >= self.tbState[2] then
		return 0;
	end
	return 1;	
end


function tbEvent:CallNpc(nType, nMapId)
	local nCheck = self:Check();
	if  nCheck ~= 1  then
		return 0;
	end
	if not self.tbCallNpcRate[nType] then
		return 0;
	end
	local nCurRate = MathRandom(1, 100);
	local nSumRate = 0;
	for nId, nRate in pairs(self.tbCallNpcRate[nType].tbRate) do
		nSumRate = nSumRate + nRate * 100;
		if nSumRate >= nCurRate then
			local nX = self.tbCallNpcRate[nType].tbPos[nId][1];
			local nY = self.tbCallNpcRate[nType].tbPos[nId][2];
			local nLiveTime = self.tbCallNpcRate[nType].nLiveTime;
			local pNpc = KNpc.Add2(self.tbCallNpcId[nId], 99, -1, nMapId, nX, nY);
			if pNpc then
				pNpc.SetLiveTime(nLiveTime);
			end
			return 1;
		end
	end
end
