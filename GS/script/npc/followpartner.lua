-- 文件名　：followpartner.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-05-10 12:58:02
-- 功能    ：

if not MODULE_GAMESERVER then
	return;
end

Npc.tbFollowPartner = Npc.tbFollowPartner or {};
local tbFollowPartner = Npc.tbFollowPartner;
tbFollowPartner.TSK_GROUP = 2112;
tbFollowPartner.TSK_TYPE					= 5;		--召唤的类型	
tbFollowPartner.TSK_NPC_TEMPID			= 6;		--召唤的npc tempid
tbFollowPartner.TSK_CALL_TIME				= 7;		--召唤时间
tbFollowPartner.TSK_AWARD_TYPE			= 8;		--召唤的宠物奖励类型
tbFollowPartner.TSK_AWARD_ADD			= 9;		--累计的奖励
tbFollowPartner.TSK_CALL_TIME_R			= 10;		--召唤剩余时间
tbFollowPartner.TSK_CHANGECOLOR			= 11;		--特殊操作（1-7表示变身（0-6））
tbFollowPartner.TSK_SKILLID				= 12;		--宠物携带的技能
tbFollowPartner.TSK_SKILLLEVEL				= 13;		--宠物携带的技能等级

tbFollowPartner.tbFollowPartner 		= tbFollowPartner.tbFollowPartner or {};		--跟宠基础总表
tbFollowPartner.tbFollowChat 			= tbFollowPartner.tbFollowChat or {};		--跟宠随即说话
tbFollowPartner.tbFollowAwardChat 	= tbFollowPartner.tbFollowAwardChat or {};	--跟宠奖励说话
tbFollowPartner.tbItemChat 			= tbFollowPartner.tbItemChat or {};		--跟宠道具tip
tbFollowPartner.tbFollowSkill 			=tbFollowPartner.tbFollowSkill or {};		--跟宠释放技能

function tbFollowPartner:InitSelf()
	for i = self.TSK_TYPE, self.TSK_CALL_TIME_R do
		me.SetTask(self.TSK_GROUP, i, 0);
	end
	local tbPlayerTemp =  me.GetTempTable("Player");
	tbPlayerTemp.tbFollowPartner = nil;
end

--反召唤npc
function tbFollowPartner:CallBackPartner(pNpc)
	self:InitSelf();
	if pNpc then
		pNpc.Delete();
	end
end

--召唤跟随同伴，同伴id，走动说话放技能类型
function tbFollowPartner:CallFollowPartner(nNpcId, nType, nTime, pItem)
	if not nNpcId or not nType or not nTime or nTime <= 0 then
		return;
	end
	local tbType = self.tbFollowPartner[nType];
	if not tbType then
		return;
	end
	local nMapId,nX,nY = me.GetWorldPos();
	local pFollow = KNpc.Add2(nNpcId,1,-1,nMapId, nX, nY,0,0);
	if pFollow then
		pFollow.SetNpcAI(10, me.GetNpc().nIndex, tbType[1], tbType[2], tbType[3], tbType[4], tbType[14], tbType[15], 0, 0, 0);
		if pItem then
			me.SetTask(self.TSK_GROUP, self.TSK_TYPE, nType);
			me.SetTask(self.TSK_GROUP, self.TSK_NPC_TEMPID, nNpcId);
			me.SetTask(self.TSK_GROUP, self.TSK_AWARD_TYPE, tbType[5]);
			me.SetTask(self.TSK_GROUP, self.TSK_AWARD_ADD, pItem.GetGenInfo(1));
			--变色传递变量
			local nOther = tonumber(pItem.GetExtParam(3));
			if nOther > 0 then
				me.SetTask(self.TSK_GROUP, self.TSK_CHANGECOLOR, nOther + 1); --变色从0开始，跟没有参数区别开
			else
				me.SetTask(self.TSK_GROUP, self.TSK_CHANGECOLOR, 0);
			end
			--技能传递变量
			local nSkillId = tonumber(pItem.GetExtParam(4));
			local nSkillLevel = tonumber(pItem.GetExtParam(5));
			if nSkillId > 0 and nSkillLevel > 0 then
				me.SetTask(self.TSK_GROUP, self.TSK_SKILLID, nSkillId);
				me.SetTask(self.TSK_GROUP, self.TSK_SKILLLEVEL, nSkillLevel);
			else
				me.SetTask(self.TSK_GROUP, self.TSK_SKILLID, 0);
				me.SetTask(self.TSK_GROUP, self.TSK_SKILLLEVEL, 0);
			end
		end
		pFollow.AddTaskState(1475);	--npc被动无敌
		pFollow.SetLiveTime(nTime * Env.GAME_FPS);
		me.SetTask(self.TSK_GROUP, self.TSK_CALL_TIME_R, nTime);
		me.SetTask(self.TSK_GROUP, self.TSK_CALL_TIME, GetTime());
		
		local tbPlayerTemp =  me.GetTempTable("Player");
		tbPlayerTemp.tbFollowPartner = {};
		tbPlayerTemp.tbFollowPartner.nParnerId = pFollow.dwId;
		tbPlayerTemp.tbFollowPartner.nTemplateId = nNpcId;
		
		local tbNpcTemp =  pFollow.GetTempTable("Npc");
		tbNpcTemp.tbFollowPartner = {};
		tbNpcTemp.tbFollowPartner.nPlayerId = me.nId;
		tbNpcTemp.tbFollowPartner.nTemplateId = nNpcId;
		tbNpcTemp.tbFollowPartner.nType = nType;
		return pFollow;
	end
	return;
end

--宠物随即说话
function tbFollowPartner:OnFollowPartnerTalk(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local tbNpcTemp = pNpc.GetTempTable("Npc").tbFollowPartner;
	if not tbNpcTemp then
		return;
	end
	if not tbNpcTemp.nType or not tbNpcTemp.nPlayerId then
		return;
	end
	--如果跟随的玩家找不到，删掉npc
	local pPlayer = KPlayer.GetPlayerObjById(tbNpcTemp.nPlayerId);
	if not pPlayer then
		pNpc.Delete();
		return;
	end
	--如果跟随的玩家记录的npcid和当前npcid不匹配，删掉npc
	local tbPlayerTemp = pPlayer.GetTempTable("Player").tbFollowPartner;
	if not tbPlayerTemp or tbPlayerTemp.nParnerId ~= nNpcId then
		pNpc.Delete();
		return;
	end
	if self.tbFollowChat[tbNpcTemp.nType] and #self.tbFollowChat[tbNpcTemp.nType] > 0 then
		local nIndex = MathRandom(#self.tbFollowChat[tbNpcTemp.nType]);
		pNpc.SendChat(self.tbFollowChat[tbNpcTemp.nType][nIndex], 1);
	end
end

function tbFollowPartner:OnFollowPartnerSkill(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local tbNpcTemp = pNpc.GetTempTable("Npc").tbFollowPartner;
	if not tbNpcTemp then
		return;
	end
	if not tbNpcTemp.nType or not tbNpcTemp.nPlayerId then
		return;
	end
	--如果跟随的玩家找不到，删掉npc
	local pPlayer = KPlayer.GetPlayerObjById(tbNpcTemp.nPlayerId);
	if not pPlayer then
		pNpc.Delete();
		return;
	end
	--如果跟随的玩家记录的npcid和当前npcid不匹配，删掉npc
	local tbPlayerTemp = pPlayer.GetTempTable("Player").tbFollowPartner;
	if not tbPlayerTemp or tbPlayerTemp.nParnerId ~= nNpcId then
		pNpc.Delete();
		return;
	end
	local tbSkill = self.tbFollowSkill[tbNpcTemp.nType];
	if tbSkill and tbSkill[1] > 0 and tbSkill[2] > 0 then
		if tbSkill[3] == "self" then
			pNpc.CastSkill(tbSkill[1], tbSkill[2], -1, pNpc.nIndex);
		elseif tbSkill[3] == "owner" then
			pPlayer.CastSkill(tbSkill[1], tbSkill[2], -1, pPlayer.GetNpc().nIndex);
		end
	end
end

--玩家进入地图把自己宠物也拉过来
function tbFollowPartner:FollowPartnerOnEnter()
	local tbTemp = me.GetTempTable("Player").tbFollowPartner;
	if not tbTemp then
		return;
	end
	local pNpc = KNpc.GetById(tbTemp.nParnerId);
	if not pNpc then
		return;
	end
	local tbNpcTemp = pNpc.GetTempTable("Npc").tbFollowPartner;
	if not tbNpcTemp or tbNpcTemp.nPlayerId ~= me.nId then
		return;
	end
	pNpc.NewWorld(me.GetWorldPos());
end

--玩家踩trap点把自己宠物也拉过来
function tbFollowPartner:FollowPartnerOnTrap()
	local tbTemp = me.GetTempTable("Player").tbFollowPartner;
	if not tbTemp then
		return;
	end
	local pNpc = KNpc.GetById(tbTemp.nParnerId);
	if not pNpc then
		return;
	end
	local tbNpcTemp = pNpc.GetTempTable("Npc").tbFollowPartner;
	if not tbNpcTemp or tbNpcTemp.nPlayerId ~= me.nId then
		return;
	end
	--宠物跟玩家跳trap点
	pNpc.NewWorld(me.GetWorldPos());
end

--玩家跟随跳转，主动调
function tbFollowPartner:FollowNewWorld(pPlayer, nMapId, nX, nY)
	if not nMapId or not nX or not nY then
		return;
	end
	local tbTemp = pPlayer.GetTempTable("Player").tbFollowPartner;
	if not tbTemp then
		return;
	end
	local pNpc = KNpc.GetById(tbTemp.nParnerId);
	if not pNpc then
		return;
	end
	local tbNpcTemp = pNpc.GetTempTable("Npc").tbFollowPartner;
	if not tbNpcTemp or tbNpcTemp.nPlayerId ~= pPlayer.nId then
		return;
	end
	--宠物跟玩家跳trap点
	pNpc.NewWorld(nMapId, nX, nY);
end

function tbFollowPartner:CheckIsFollowPartner()
	local tbNpcTemp = him.GetTempTable("Npc").tbFollowPartner;
	if not tbNpcTemp or not tbNpcTemp.nPlayerId then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(tbNpcTemp.nPlayerId);
	if pPlayer then
		return 1;
	end
	return 0;
end

--跟宠上线事件
function tbFollowPartner:FollowPartnerLogin()	
	local nType = me.GetTask(self.TSK_GROUP, self.TSK_TYPE);
	local nNpcTempId = me.GetTask(self.TSK_GROUP, self.TSK_NPC_TEMPID);
	if nType <= 0 then
		return;
	end
	local tbType = self.tbFollowPartner[nType];
	if not tbType then
		return;
	end
	local nRet, nRelTime = self:CheckTimeValid(me);
	if nRet <= 0 then
		self:InitSelf();
		return;
	end
	local pPartner = self:CallFollowPartner(nNpcTempId, nType, nRelTime);
	local nOther = me.GetTask(self.TSK_GROUP, self.TSK_CHANGECOLOR);
	if pPartner and nOther > 0 then
		pPartner.ChangeColorScheme(nOther - 1);
	end
	local nSkillId = me.GetTask(self.TSK_GROUP, self.TSK_SKILLID);
	local nSkillLevel = me.GetTask(self.TSK_GROUP, self.TSK_SKILLLEVEL);
	if pPartner and nSkillLevel > 0 and nSkillId > 0 then
		if me.GetSkillState(nSkillId) < 0 then
			me.AddSkillState(nSkillId, nSkillLevel, 1, nRelTime  * 18,1,0,1);
		end
	end
end

--跟宠下线事件
function tbFollowPartner:FollowPartnerLogOut()
	local tbTemp = me.GetTempTable("Player").tbFollowPartner;
	if not tbTemp then
		return;
	end
	local pNpc = KNpc.GetById(tbTemp.nParnerId);
	if not pNpc then
		return;
	end
	pNpc.Delete();
end

function tbFollowPartner:CheckTimeValid(pPlayer)
	local nRelTime = pPlayer.GetTask(self.TSK_GROUP, self.TSK_CALL_TIME_R);
	local nLastCallTime = pPlayer.GetTask(self.TSK_GROUP, self.TSK_CALL_TIME);
	if nLastCallTime <= 0 then
		return 2;
	end
	nRelTime = nRelTime - (GetTime() - nLastCallTime);
	if nRelTime <= 0 then
		return 0;
	end
	return 1, nRelTime;
end

function tbFollowPartner:CheckAwardCount(pPlayer, tbType)
	local nAwardCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_AWARD_ADD);
	if nAwardCount >= tbType[6] then
		return 0;
	end
	return tbType[6] - nAwardCount;
end

function tbFollowPartner:AddAward(pPlayer, szType)
	if not pPlayer or not szType then
		return;
	end
	local nType = pPlayer.GetTask(self.TSK_GROUP, self.TSK_TYPE);
	local tbType = self.tbFollowPartner[nType];
	if not tbType then
		return;
	end
	if self:CheckTimeValid(pPlayer) ~= 1 then
		return;
	end
	local nMaxAdd = self:CheckAwardCount(pPlayer, tbType);
	if nMaxAdd == 0 then
		return;
	end
	local nAddCount = 0;
	--匹配类型
	if tbType[7] ~= szType and (tbType[13] == "" or not string.find(tbType[13], szType))  then
		return;
	end
	--奖励获取方式
	if tbType[16] == "random" and tbType[10] > 0 and tbType[11] > 0 then
		local nRate = MathRandom(tbType[10]);
		if nRate > tbType[11] then
			return;
		end
	end
	--奖励增加方式
	if tbType[8] == "random" then
		nAddCount = MathRandom(tbType[12], tbType[9]);
	elseif tbType[8] == "addnum" then
		nAddCount = tbType[9];
	end
	if nAddCount <= 0 then
		return;
	end
	nAddCount = math.min(nMaxAdd, nAddCount);
	local nRealCount = nAddCount;
	if tbType[5] == 0 then
		return;
	elseif tbType[5] == 1 then
		pPlayer.CallClientScript({"TestFlyChar", 15, nRealCount});
	elseif tbType[5] == 2 then
		nRealCount = nRealCount * pPlayer.GetBaseAwardExp();
		pPlayer.CallClientScript({"TestFlyChar", 7, nRealCount});
	elseif tbType[5] == 3 then
		pPlayer.CallClientScript({"TestFlyChar", 7, nRealCount});
	elseif tbType[5] == 4 then
		pPlayer.CallClientScript({"TestFlyChar", 17, nRealCount});
	end
	self:AwardChat(pPlayer, nType, nRealCount);
	pPlayer.SetTask(self.TSK_GROUP, self.TSK_AWARD_ADD, pPlayer.GetTask(self.TSK_GROUP, self.TSK_AWARD_ADD) + nAddCount);
end

function tbFollowPartner:AwardChat(pPlayer, nType, nAddCount)
	local tbPlayerTemp =  pPlayer.GetTempTable("Player");
	if not tbPlayerTemp.tbFollowPartner or not tbPlayerTemp.tbFollowPartner.nParnerId then
		return;
	end
	if not self.tbFollowAwardChat[nType] then
		return;
	end
	local pNpc = KNpc.GetById(tbPlayerTemp.tbFollowPartner.nParnerId);
	if pNpc then
		pNpc.SendChat(string.format(self.tbFollowAwardChat[nType], nAddCount), 1);
	end 	
end
