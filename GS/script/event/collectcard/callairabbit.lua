-------------------------------------------------------
-- 文件名　：rabbit.lua
-- 文件描述：抓兔npc
-- 创建者　：jiazhenwei@kingsoft.com
--创建时间 ：2009年8月25日
-------------------------------------------------------
if not SpecialEvent.CollectCard then
	SpecialEvent.CollectCard = {};
end
SpecialEvent.CollectCard.CallAiRabbit =  {};
local tbRabbit = SpecialEvent.CollectCard.CallAiRabbit;

tbRabbit.szChar ="肚子好饿，回不了家了啦~~~";
	
tbRabbit.NCHATSEC = 3; 		--timer延迟时间
tbRabbit.NRANGE = 1000; 		--npc跑动随机范围	
tbRabbit.NSEARCHAREA = 20 	--npc搜索玩家的范围

--生成兔子npc
--example		local nMapId,nX,nY = me.GetWorldPos(); 
--example         SpecialEvent.CollectCard:CallRabbit(nMapId, nX*32, nY*32, 598);
function tbRabbit:CallRabbit(nMapId, nX, nY, nAINpcId)		
	local pNpc = KNpc.Add(nAINpcId, 150, 0, SubWorldID2Idx(nMapId), nX, nY);	
	if (pNpc) then
		local nMovX, nMovY = self:RandomPos(nX, nY);
		pNpc.AI_AddMovePos(nMovX, nMovY);
		pNpc.SetNpcAI(9, 0, 1, -1, 0, 0, 0, 0, 0, 0, 0);
		pNpc.GetTempTable("Npc").tbRabbitAbout				= {};
		pNpc.GetTempTable("Npc").tbRabbitAbout.bIsCatch 		= 0;   --兔子是否被捕捉
		pNpc.SetLiveTime(900 * Env.GAME_FPS);
		pNpc.AddFightSkill(1475, 1, 1);
		local nTimerId = Timer:Register(self.NCHATSEC * Env.GAME_FPS, self.Sendchat, self, pNpc.dwId, 1);	
        return pNpc.dwId;	
	end
	return 0;
end

--跑路说话
function tbRabbit:Sendchat(nNpcId)	
	local pNpc = KNpc.GetById(nNpcId);	
	local nMovX,nMovY = self:GetMovePos(nNpcId);
	if ( not pNpc) then	
		return 0;	
	end		
	if(2 == pNpc.GetTempTable("Npc").tbRabbitAbout.bIsCatch) then
		pNpc.Delete();
		return 0;
	end
	if (1 == pNpc.GetTempTable("Npc").tbRabbitAbout.bIsCatch) then
		 pNpc.GetTempTable("Npc").tbRabbitAbout.bIsCatch = 2;		
		 return;
	end
	
	pNpc.SendChat(self.szChar);
	pNpc.AI_ClearPath();	
	pNpc.AI_AddMovePos(nMovX, nMovY);
	pNpc.SetNpcAI(9, 0, 1, -1, 0, 0, 0, 0, 0, 0, 0);		
	return ;
end

--返回最近玩家和兔子之间的反方向的一段距离的x，y
function tbRabbit:GetMovePos(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);	
	local tbRoundLis = KNpc.GetAroundPlayerList(nNpcId, self.NSEARCHAREA);
	
	local nMapId, nPlayerX, nPlayerY;			--玩家坐标点
	local nNearPlayerX ,nNearPlayerY;			--最近玩家坐标点
	local nNpcX = 0;
	local nNpcY = 0;					--npc坐标点
	local nMinPos = 0; 						--npc和最近玩家(没有时为0)的距离的平方值
	
	if (pNpc) then		 					--找离npc最近的玩家的坐标点
		nMapId, nNpcX, nNpcY = pNpc.GetWorldPos();					
		for _ , nPlayer in pairs(tbRoundLis) do
			nMapId, nPlayerX, nPlayerY = nPlayer.GetWorldPos();				
			local nDistance = self:TowPosDistance(nPlayerX, nPlayerY, nNpcX, nNpcY);			
			if (nMinPos <= nDistance ) then
				nMinPos = nDistance;				
				nNearPlayerX = nPlayerX;
				nNearPlayerY = nPlayerY;
			end
		end				
	end
	if( 0 == nMinPos ) then			--附近没有玩家返回npc坐标		
		return self:RandomPos(nNpcX, nNpcY);
	end		
	return  (nNpcX + nNpcX - nNearPlayerX)*32, (nNpcY + nNpcY - nNearPlayerY)*32;		--返回最近玩家和npc反方向的一段距离的x,y
end

--检查附近是否有玩家
function tbRabbit:IsPlayer(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (pNpc) then		
		local tbRoundLis = KNpc.GetAroundPlayerList(nNpcId, self.NSEARCHAREA);
		if(not tbRoundLis[1]) then
			return nil;
		end
	end
	return 1;
end

--两点之间的距离的平方值
function tbRabbit:TowPosDistance(nPosX1,nPosY1,nPosX2,nPosY2)
	return (nPosX1 - nPosX2) *  (nPosX1 - nPosX2) + (nPosY1 - nPosY2) *  (nPosY1 - nPosY2); 	
end

--nX，nY点NRANGE范围内的随机点
function tbRabbit:RandomPos(nX,nY)		
	local tbRX =  {math.floor(MathRandom(-self.NRANGE, -math.floor(self.NRANGE*0.6))), math.floor(MathRandom(math.floor(self.NRANGE*0.6), self.NRANGE))};
	local tbRY =  {math.floor(MathRandom(-self.NRANGE, -math.floor(self.NRANGE*0.6))), math.floor(MathRandom(math.floor(self.NRANGE*0.6), self.NRANGE))};
	local nTrX =  tbRX[math.floor(MathRandom(1, 2))] or 0;
	local nTrY =  tbRY[math.floor(MathRandom(1, 2))] or 0;
	local nMovX = nX + nTrX;
	local nMovY = nY + nTrY;
	return nMovX,nMovY;		
end
