------------------------------------------------------
-- 文件名　：partner.lua
-- 创建者　：dengyong
-- 创建时间：2009-12-02 09:26:07
-- 描  述  ：同伴
------------------------------------------------------
if MODULE_GAMESERVER then

-- 给同伴对象初始化数据
-- 第六个参数为整型时，表示五行，需要根据五行随机技能；为表时，表示技能ID数组，直接添加就可以了
function Partner:Init(pPartner, nPartnerTempId, nType, szName, nPotentialTemp, varSkillOrSeries)
	pPartner.SetName(szName);		-- 同伴名字，初始时为NPC的名字
	-- 注意，同伴身上的模板ID不是NPC模板ID，是实实在在的同伴模板ID。不过，事实上NPC模板ID与同伴模板ID是一一对应的
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_TEMPID, nPartnerTempId);	 		 -- 同伴的模板ID	
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_EXP, 0);							 -- 经验初始为0
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_LEVEL, 1);							 -- 等级初始为1	
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_FRIENDSHIP, self.FRIENDSHIP_INIT);	 -- 亲密度初始为60
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_TALENT, self.TAlENT_MIN);	  		 -- 领悟度初始为40
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_PotentialTemp, nPotentialTemp);		 -- 潜能模板
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_CREATETIME, GetTime());				 -- 创建时间
	
	self:CaclulatePotential(pPartner.nPartnerIndex);
	
	if type(varSkillOrSeries) == "number" then
		local nSeries = varSkillOrSeries;
		self:GenerateSkill(pPartner, nType, nSeries);		  						 -- 生成技能
	else
		local tbSkillId = varSkillOrSeries;
		for nIndex, nSkillId in pairs(tbSkillId) do								 -- 直接添加技能
			local tbSkill = {};
			tbSkill.nId = nSkillId;
			tbSkill.nLevel = 1;
			
			pPartner.AddSkill(tbSkill);
		end
	end
end

-- 判定同伴升级的相关条件及处理升级时触发的相关事件（升级技能）
function Partner:PreUpgrade(pPartner)	
	local nExp = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_EXP);			-- 累计经验
	local nCurLevel = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL);	-- 当前等级

	if nCurLevel >= self.MAXLEVEL then
		local szMsg = "Bạn đồng hành đã đạt cấp tối đa!";
		return 0, szMsg;
	end	
	
	if nExp < self.tbLevelSetting[nCurLevel].nExp then
		return 0, "Không đủ kinh nghiệm để thăng cấp!";	
	end
	
	return 1;	
end

-- 提升技能等级
function Partner:UpgradeSkill(pPartner)
	local nRes, varRes, nResultId = self:CalToUpgradeSkill(pPartner);
	local szResult;
	if nRes == 0 then
		if nResultId == 1 then
			szResult = ", tất cả kỹ năng đã đạt tối đa";
		elseif nResultId == 2 then
			szResult = "Thất bại";
		end
	else
		szResult = "Thành công";
	end
	--提升技能的log
	local szLog = string.format("同伴Log:%s的同伴%s以%d领悟度提升技能%s",me.szName, pPartner.szName, pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TALENT) % 1000, szResult);
	Dbg:WriteLog(szLog);
	
	if nRes == 0 then
		me.Msg(varRes);
		self:SendClientMsg(varRes);
		return;
	end
	
	local nSkillIndex = varRes;		--如果可以提升技能，第二个参数是要提升的技能索引	
	local tbSkill = pPartner.GetSkill(nSkillIndex - 1);		-- 在程序中索引是从0开始的，要减1
	
	if not tbSkill then
		return;
	end
	
	-- 不能给已经是满级的技能升级
	if tbSkill.nLevel >= self.SKILLMAXLEVEL then
		return;
	end
	
	tbSkill.nLevel = tbSkill.nLevel + 1;
	local nNewTalentLevel, nPointRemain = self:GetTalentLevelAdded(pPartner, -self.TALENT_DECREASE, 0);
	local _, szMsg = self:AddTalent(pPartner, nNewTalentLevel, nPointRemain);		-- 提升技能成功，扣除10点的领悟度
	if szMsg ~= "" then
		me.Msg(szMsg);
		self:SendClientMsg(szMsg);
	end
	
	pPartner.SetSkill(nSkillIndex - 1, tbSkill); 	-- 在程序中索引是从0开始的，要减1
	
	me.Msg(string.format("%s đã lĩnh ngộ [%s] lên cấp %d!", pPartner.szName, KFightSkill.GetSkillName(tbSkill.nId), tbSkill.nLevel));
	self:SendClientMsg(string.format("Kỹ năng [%s] thăng cấp %d!", KFightSkill.GetSkillName(tbSkill.nId), tbSkill.nLevel));
	
	-- 如果玩家有同伴教育任务-更加强大，则记录任务变量。
	local tbPlayerTasks	= Task:GetPlayerTask(me).tbTasks;
	local tbTask = tbPlayerTasks[tonumber(self.TASK_SKILLUP_MAIN, 16)];	-- 主任务ID
	if tbTask and tbTask.nReferId == tonumber(self.TASK_SKILLUP_SUB, 16) then
		me.SetTask(self.TASKID_MAIN, self.TASKID_SKILLUP, 1);
	end
end

-- 产生随机数判断同伴当前能否提升等级
-- 不能则返回0和失败信息，能则返回1和技能索引
function Partner:CalToUpgradeSkill(pPartner)
	local nTalent = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TALENT);	-- 同伴当前的领悟度
	local nTalentLevel = nTalent % 1000;
	
	local tbSkillIndex = {};
	local nSkillCount = pPartner.nSkillCount;	-- 当前同伴拥有的技能总数
	for i = 1, nSkillCount do
		local tbSkill = pPartner.GetSkill(i - 1);	-- 在程序中的索引是从0开始的，要减1
		if tbSkill.nLevel < self.SKILLMAXLEVEL then
			table.insert(tbSkillIndex, i);
		end
	end
	
	if #tbSkillIndex == 0 then
		local szMsg = string.format("Đồng hành của bạn - %s đã nâng tất cả kỹ năng đến mức tối đa, không thể nâng nữa!", pPartner.szName);
		return 0, szMsg, 1;
	end
	
	if MathRandom(1, 100) > nTalentLevel then
		local szMsg = "Thật tiếc, đồng hành không nâng cấp kỹ năng được, hãy tăng thêm 5 cấp rồi thử lại.";
		return 0, szMsg, 2;
	end
	
	local nGenIndex = MathRandom(1, #tbSkillIndex);
	return 1, tbSkillIndex[nGenIndex], 0;
end

-- 判断某个同伴是否所有技能等级都升满
function Partner:CanUpgradeSkill(pPartner)
	-- 无对象，则返回0表示不能再升技能等级了
	if not pPartner then
		return 0;
	end
	
	for i = 1, pPartner.nSkillCount do
		local tbSkill = pPartner.GetSkill(i - 1);
		if tbSkill.nLevel < self.SKILLMAXLEVEL then
			return 1;
		end
	end
	
	return 0;
end

-- 经验
-- 增加失败，返回失败信息，否则返回增加的经验
function Partner:AddExp(pPartner, nExp)
	local nCurLevel = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL);	-- 当前等级
	
	if nCurLevel >= self.MAXLEVEL then
		local szMsg = string.format("Đồng hành đã đạt cấp tối đa, không thể nhận thêm kinh nghiệm.");
		return 0, szMsg;
	end
	
	local nStoreMax = self:GetMaxStoreExp(pPartner);		-- 计算当前能累积的最大经验值
	local nCurExp = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_EXP);
	if nCurExp >= nStoreMax then
		local szMsg = string.format("Đồng hành của bạn - %s đã đạt kinh nghiệm tối đa, để tránh rớt kinh nghiệm, hãy nâng cấp cho đồng hành!", pPartner.szName);
		return 0, szMsg;
	end

	local nActualExp = nCurExp + nExp;
	if nActualExp >= nStoreMax then
		nActualExp = nStoreMax;
	end
	
	-- 可以升级给提示
	if nActualExp >= nStoreMax and nCurLevel < self.MAXLEVEL - 9 then
			me.CallClientScript({"PopoTip:ShowPopo", 23});
	elseif nCurExp < Partner.tbLevelSetting[nCurLevel].nExp and 
		nActualExp >= Partner.tbLevelSetting[nCurLevel].nExp and
		nCurLevel < self.MAXLEVEL then
			me.CallClientScript({"PopoTip:ShowPopo", 21});
	end
		
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_EXP, nActualExp);
	return 1, nActualExp - nCurExp;		-- 增加经验成功，返回1和实际增加的经验
end


-- 领悟度, nTalent可以为负，表示减少
-- 第二个参数表示新的等级，第三个参数表示增加后新的剩余价值量
function Partner:AddTalent(pPartner, nNewLevel, nPointRemain)
	local nTalent = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TALENT);	-- 当前领悟度
	local nTalentLevel = nTalent % 1000;	-- nCurTalent = nTalentLevel*1000 + nTalentPoint
	
	local szMsg = "";
	if nTalentLevel >= self.TALENT_MAX and nNewLevel >= nTalentLevel then
		szMsg = string.format("Đồng hành %s đã thông suốt, không cần nâng lĩnh ngộ nữa!", pPartner.szName);
		return 0, szMsg;
	end
			
	if nNewLevel < nTalentLevel then  	-- 领悟度降低了
		if nNewLevel <= self.TAlENT_MIN then
			szMsg = string.format("Đồng hành %s tổn hao tâm trí, lĩnh ngộ giảm %d! Đã giảm đến mức thấp nhất.", pPartner.szName,  nTalentLevel - nNewLevel);
		else
			szMsg = string.format("Đồng hành %s tổn hao tâm trí, lĩnh ngộ giảm %d!", pPartner.szName,  self.TALENT_DECREASE);
		end
		
	elseif nNewLevel > nTalentLevel then		-- 领悟度提高了
		szMsg = string.format("Đồng hành %s lĩnh ngộ tăng đến %d.", pPartner.szName, nNewLevel);
	end		
	
	-- 这里再做一层保护
	if nNewLevel >= self.TALENT_MAX then
		nPointRemain = 0;
	end
	
	-- 将新的领悟度值写入
	local nNewTalent = nNewLevel + nPointRemain * 1000;
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_TALENT, nNewTalent);
	
	return 1, szMsg;
end

-- 亲密度, nFriendship可以为负，表示减少
function Partner:AddFriendship(pPartner, nAddFriendship)
	local nFriendship = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_FRIENDSHIP);	-- 当前亲密度
	
	if nFriendship >= self.FRIENDSHIP_MAX and nAddFriendship > 0 then
		local szMsg = string.format("Độ thân mật của bạn và %s đã đạt tối đa, không phải nâng điểm thân mật nữa.", pPartner.szName);
		return 0, szMsg;
	end
	
	local nNewFriendship = nFriendship + nAddFriendship;
	
	nNewFriendship = math.max(nNewFriendship, 0);	-- 最小为0
	
	nNewFriendship = math.min(nNewFriendship, self.FRIENDSHIP_MAX);	-- 最大为10000
	
	local szMsg = "";
	if nAddFriendship > 0 then
		szMsg = string.format("Độ thân mật của bạn và %s tăng %0.2f.", pPartner.szName, nNewFriendship/100);
	end
	
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_FRIENDSHIP, nNewFriendship);
	
	return 1, szMsg;
end

-- 杀死精英怪/首领怪/武林BOSS 
function Partner:OnKillBoss(pPlayer, pNpc)
	if not pPlayer or not pNpc then
		return;
	end
	
	if not self.tbLevelSetting then
		return;
	end
	
	local tbShareMember = {pPlayer};	-- 可以分享经验的玩家列表
	
	-- 如果杀死怪的时候处于组队状态，则所有队友分享经验和亲密度
	local tbPlayerId = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	if tbPlayerId then
		local nNpcMapId, nNpcX, nNpcY = pNpc.GetWorldPos();
		for _, nPlayerId in pairs(tbPlayerId) do
			local pTeamMember = KPlayer.GetPlayerObjById(nPlayerId);
			if pTeamMember and pTeamMember.nId ~= pPlayer.nId then
				local nPlayerMapId, nPlayerPosX, nPlayerPosY = pTeamMember.GetWorldPos();
				local nDisSquare = math.floor(math.sqrt((nNpcX - nPlayerPosX)^2 + (nNpcY - nPlayerPosY)^2) * 32);
				if (nDisSquare < self.SHAREEXPDISTANCE) then		-- 在可分享经验范围内才可以分享经验
					table.insert(tbShareMember, pTeamMember);		-- 分享经验的玩家个数加1
				end
			end
		end
	end
	
	self:GetAwardByKillBoss(tbShareMember, pNpc.nLevel, pNpc.GetNpcType());	
end

-- 杀死怪物时，队友的同伴获得的经验
-- 这里把所有的情况都转化为队伍来处理，没组队的时候视为只有一个人的队伍
function Partner:GetAwardByKillBoss(tbPlayer, nNpcLevel, nNpcType)
	local szExpType = nNpcType == 1 and "nJYExp" or "nSLExp";	
	
	for _, pPlayer in pairs(tbPlayer) do
		local bAdd = 1;		-- 标识是否可以给该玩家加经验，大于1的时候表示可以，否则表示不可以
		local pPartner = pPlayer.GetPartner(pPlayer.nActivePartner);
		if pPartner then
			-- TODO:还没有做玩家身上有获取多倍经验的BUFF的相关判断
			
			local nLevel = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL);	-- 同伴等级
			-- 如果同伴的等级与怪物的等级差大于15，则不能获得经验和亲密度
			if math.abs(nLevel - nNpcLevel) > 15 then
				bAdd = 0;
			end

			if bAdd ~= 0 and (EventManager.IVER_bOpenPartnerExpLimit == 0 or (EventManager.IVER_bOpenPartnerExpLimit == 1 and pPartner.nSkillCount < 5)) then
				local nEarnRate = 100;	-- 获得经验、亲密度的比例, 100为满值
				
				-- 杀掉的精英首领怪的等级不符合要求，不加经验（队友肯定也不能加了，直接break）
				if not self.tbNpcExp[nNpcLevel] then
					break;
				end
				
				local nExp = self.tbNpcExp[nNpcLevel][szExpType] * nEarnRate / 100;	
				
				local nRes, szMsg = self:AddExp(pPartner, nExp);
				if nRes == 1 then
					local nExpAdded = szMsg;	-- 如果nRes=1,则第二个参数为加上去的经验
					szMsg = string.format("Kinh nghiệm của đồng hành %s tăng %d", pPartner.szName, nExpAdded);
				end
			
				pPlayer.Msg(szMsg);
			end
		end
	end
end


-- 创建一个同伴
-- 参数：玩家对象，要被转化成为同伴的NPC
function Partner:CreatePartner(nPlayerId, dwNpcId, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	local pItem = KItem.GetObjById(nItemId)
	if not pPlayer or not pItem then
		return 0;
	end
	
	--pPlayer.RemoveSkillState(self.nPersuadeSkillId);
	--pPlayer.GetTempTable("Partner").nPersuadeRefCount = 0;
	
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc or pNpc.IsDead() == 1 then
		return 0;
	end
	
	if not self.tbPartnerAttrib or not self.tbPersuadeInfo then
		return 0;
	end
		
	-- 生成随机数，根据配置表中的说服概率判定该NPC是否被说服了
	local nPartnerId = self.tbPersuadeInfo[pNpc.nTemplateId];
	local nRate = self.tbPartnerAttrib[nPartnerId].nRate;		-- 该NPC能被说服的概率
	if MathRandom(1, 100) > nRate then
		--if pNpc.GetTempTable("Partner").nPersuadeRefCount <= 1 then		-- 去掉被说服状态
		--	pNpc.RemoveTaskState(self.nBePersuadeSkillId);
		--end		
		--pNpc.GetTempTable("Partner").nPersuadeRefCount = pNpc.GetTempTable("Partner").nPersuadeRefCount - 1;

		pPlayer.Msg("Dù đã cố gắng dùng thiệp nhưng vẫn không thuyết phục được đồng hành.");
		self:SendClientMsg("Dù đã cố gắng dùng thiệp nhưng vẫn không thuyết phục được đồng hành.");
		return 0;	-- 说服失败直接返回，不删除NPC
	end
	
	if self:ConsumePartnerItem(pItem, pPlayer) ~= 1 then
		Dbg:WriteLog("Partner", "Partner:CreatePartner DeleteItem Failed!")
		return 0;
	end

	-- 添加一个同伴
	local nRes = self:AddPartner(pPlayer.nId, pNpc.nTemplateId, pNpc.nSeries);
	if nRes == 0 then
		return 0;
	end
	
	local nNpcTemplateId = pNpc.nTemplateId;
	Dbg:WriteLog("同伴Log:", pPlayer.szName, "使用", pItem.szName, "获得同伴：", pNpc.szName);
		
	--pNpc.RemoveTaskState(self.nBePersuadeSkillId);			-- 去掉被说服状态
	--pNpc.GetTempTable("Partner").nPersuadeRefCount = 0;
	if self.tbPartnerAttrib[nPartnerId].IsDrop == 0 then
		pNpc.DieWithoutPunish();				-- 删除NPC，不掉落不给经验
	else
		pNpc.DieWithoutPunish();				-- TODO:需要加掉落。
	end
	pPlayer.Msg("Chúc mừng! Bạn có thể cùng đồng hành xông pha giang hồ rồi!");
	pPlayer.CallClientScript({"PopoTip:ShowPopo", 22});
	
	StatLog:WriteStatLog("stat_info", "Partner", "catchpartner", nPlayerId, nNpcTemplateId, pPlayer.nTemplateMapId);
	
	-- 如果玩家有同伴教育任务-寻找同伴，则记录任务变量。
	local tbPlayerTasks	= Task:GetPlayerTask(pPlayer).tbTasks;
	local tbTask = tbPlayerTasks[tonumber(self.TASK_FINDPARTNER_MAIN, 16)];	-- 主任务ID
	if tbTask and tbTask.nReferId == tonumber(self.TASK_FINDPARTNER_SUB, 16) then
		pPlayer.SetTask(self.TASKID_MAIN, self.TASKID_FINDPARTNER, 1);
	end
		
	return 1;
end

-- 扣掉一个甜言蜜语丸/精魄 并增加消耗记录
-- 相关的可叠加物品消耗都可以通过这个接口完成扣除操作
-- 目前使用到的道具都有：精魄，说服帖子，推荐信，洗髓经
function Partner:ConsumePartnerItem(pItem, pPlayer)
	local nCount = pItem.nCount - 1;
	if nCount == 0 then
		return pPlayer.DelItem(pItem);	-- 直接删除不用手动添加消耗记录
	else
		local pOwnner = pItem.GetOwner()
		if not pOwnner or pOwnner.nId ~= pPlayer.nId then
			return 0;
		end
		pItem.SetCount(nCount, Item.emITEM_DATARECORD_REMOVE);
		
		Setting:SetGlobalObj(nil, nil, pItem);
		Spreader:OnItemConsumed(1, Spreader.emITEM_CONSUMEMODE_ERRORLOST_STACK);
		Setting:RestoreGlobalObj();
		
		return 1;
	end
	return 0;	
end

-- 根据NPC模板ID，给玩家添加一个对应的同伴
-- nPotentialTemp表示要生成的同伴的模板分配ID，如果没有给该参数，则随机给定
function Partner:AddPartner(nPlayerId, nTemplateId, nSeries, nPotentialTemp)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	if not self.tbPersuadeInfo[nTemplateId] then
		-- print("无效的NPC模板ID");
		return 0;
	end	

	local nPartnerTempId = self.tbPersuadeInfo[nTemplateId];	-- 同伴的模板ID

	if pPlayer.nPartnerLimit == 0 then
		pPlayer.SetPartnerLimit(self.PARTNERLIMIT_MIN);
	end	
	local pPartner = pPlayer.AddPartner(nPartnerTempId);
	if not pPartner then
		-- print("Partner:CreatePartner(),创建同伴对象失败！！");
		return 0;
	end
	
	-- 记录该同伴的潜能模板分配ID，如果没有指定，随机分配一个
	if not nPotentialTemp then
		 nPotentialTemp = self:RandomPotentialTemp(pPlayer);
	end
	
	-- 为创建的同伴初始化数据
	local nType = self.tbPartnerAttrib[nPartnerTempId].nType;
	if not nType then
		-- print("配置表 \setting\partner\partner.txt 数据有误！");
		return 0;
	end
	
	-- 如果没有指定名字，取NPC模板ID所对应的NPC名字
	local szName = KNpc.GetNameByTemplateId(nTemplateId);
	if not nSeries or nSeries == 0 then
		-- 防止怪没有五行的情况，随机给一个五行
		nSeries = MathRandom(1, 5);
	end
	self:Init(pPartner, nPartnerTempId, nType, szName, nPotentialTemp, nSeries);		-- 初始化同伴的基本属性信息
	
	--Player.tbFightPower:RefreshFightPower(pPlayer);
	PlayerHonor:UpdatePartnerValue(pPlayer, 0);
	PlayerHonor:UpdateFightPower(pPlayer);
	return 1;
end

function Partner:GetPartnerType(nTemplateId)
	if not self.tbPersuadeInfo[nTemplateId] then
		return 0;
	end	

	local nPartnerTempId = self.tbPersuadeInfo[nTemplateId];	-- 同伴的模板ID
	
	if (not nPartnerTempId) then
		return 0;
	end

	local nType = self.tbPartnerAttrib[nPartnerTempId].nType;
	return nType;
end

-- 根据指定的模板ID重新分配同伴的潜能点
-- 失败返回0，成功返回新的潜能模板ID
function Partner:ResetPartnerPotential(pPartner, nPotentialTemp)
	if not pPartner then
		return 0;
	end
	
	if nPotentialTemp < 1 or nPotentialTemp > #self.tbPotentialTemp then
		return 0;		-- 给定的潜能模板ID不合法，直接RETURN
	end
	
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_PotentialTemp, nPotentialTemp);
	
	-- 先将各项潜能点洗掉
	local nSumPotential = 0;
	for nAttribIndex = 0, 3 do
		nSumPotential = nSumPotential + pPartner.GetAttrib(nAttribIndex);
		pPartner.SetAttrib(nAttribIndex, 0);
	end
	
	-- 重新分配
	self:AddPotential_Pure(pPartner.nPartnerIndex, nSumPotential);
	
	return nPotentialTemp;
end

-- 将同伴转成道具，转成的道具可以交易
function Partner:TurnPartnerToItem(pPlayer, pPartner)
	if not pPartner then
		return 0;
	end
	
	if pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL) > 1 then
		self:SendClientMsg("Chỉ có đồng hành cấp 1 mới có thể chuyển hóa thành đạo cụ!");
		pPlayer.Msg("Chỉ có đồng hành cấp 1 mới có thể chuyển hóa thành đạo cụ!");
		return 0;
	end
		
	-- 先判断玩家是否能成功添加道具，能添加才将同伴转成道具
	if pPlayer.CountFreeBagCell() < 1 then
		self:SendClientMsg("Túi bạn không đủ trống, xin thu xếp lại!");
		pPlayer.Msg("Túi bạn không đủ trống, xin thu xếp lại!");
		return 0;
	end
	
	-- 添加道具，并将同伴的信息保存到道具里
	local nRes, pItem = self:SavePartnerInfoToGenInfo(pPlayer, pPartner);
	if nRes == 0 then
		return 0;
	end
	
	
	return 1, pItem;
end

function Partner:SavePartnerInfoToGenInfo(pPlayer, pPartner)	
	if not pPartner then
		return 0;
	end
	
	-- 在将同伴转成道具之前，保存同伴的相关信息
	local nPartnerTempId = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID);		-- 模板ID
	local nPotentialTemp = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_PotentialTemp);  -- 潜能分配模板
	local nSkillCount = pPartner.nSkillCount;
	local szPartnerName = pPartner.szName;
	
	local tbSkillGenInfo = {};			-- 把同伴的技能信息记录到道具的扩展参数中
	-- 每个技能占16位，即一个扩展信息包含两个技能
	for i = 1, pPartner.nSkillCount do
		local tbSkill = pPartner.GetSkill(i - 1);
		if tbSkill then
			tbSkillGenInfo[math.ceil(i/2)] = tbSkillGenInfo[math.ceil(i/2)] or 0;
			local nBitBegin = (i % 2) == 0 and 16 or 0; 
			-- 每个技能占16位
			tbSkillGenInfo[math.ceil(i/2)] = Lib:SetBits(tbSkillGenInfo[math.ceil(i/2)], tbSkill.nId, nBitBegin, nBitBegin + 15);
		end
	end
		
	if (self:DissolveConfirm(pPlayer.nId, pPartner.nPartnerIndex, 1) ~= 1) then
		Dbg:WriteLog("[TurnPartnerToItem]", string.format("%s将同伴%s(%d,%d,%d)放入同伴推荐信失败！", pPlayer.szName,
			szPartnerName, nPartnerTempId, nSkillCount, nPotentialTemp));
		return;
	end
		
	-- 先添加道具，道具（稚嫩的同伴）添加成功后再删除同伴
	-- n级稚嫩的同伴道具对应n+1个技能个数的同伴
	local pItem = pPlayer.AddItem(self.tbChildPartner.nGenre, self.tbChildPartner.nDetail, 
		self.tbChildPartner.nParticular, nSkillCount - 1);
	if not pItem then
		return 0;
	end
	
	pItem.SetGenInfo(1, nPartnerTempId);
	pItem.SetGenInfo(2, nPotentialTemp);
	for i = 1, #tbSkillGenInfo do
		pItem.SetGenInfo(i + 2, tbSkillGenInfo[i]);
	end	
	-- pItem.SetGenInfo(12, me.nId);		-- 记录生成这个道具的玩家的ID
	pItem.Sync();	-- 同步到客户端
	
	return 1, pItem;
end

-- 使用道具（稚嫩的同伴）添加一个同伴
function Partner:TurnItemToPartner(pPlayer, nPartnerTempId, nPotentialTemp, tbSkillId)
	if not pPlayer or not nPartnerTempId or not nPotentialTemp or not tbSkillId then
		return 0;
	end
	
	if pPlayer.nPartnerCount >= pPlayer.nPartnerLimit then
		pPlayer.Msg("Danh sách đồng hành của bạn đã đầy, không thể nhận thêm đồng hành mới!");
		self:SendClientMsg("Danh sách đồng hành của bạn đã đầy, không thể nhận thêm đồng hành mới!");
		return 0;
	end
	
	local pPartner = pPlayer.AddPartner(nPartnerTempId);
	if not pPartner then
		return 0;
	end
	
	--local nNpcTempId = self.tbPartIdToNpcId[nPartnerTempId]; 
	local nType = self.tbPartnerAttrib[nPartnerTempId].nType;
	local szName = KNpc.GetNameByTemplateId(self.tbPartnerAttrib[nPartnerTempId].nEffectNpcId);
	
	self:Init(pPartner, nPartnerTempId, nType, szName, nPotentialTemp, tbSkillId);
	local szMsg = string.format("Bạn đã nhận đồng hành %s", szName);
	pPlayer.Msg(szMsg);
	self:SendClientMsg(szMsg);
	
	PlayerHonor:UpdatePartnerValue(pPlayer, 0);
	--Player.tbFightPower:RefreshFightPower(pPlayer);
	PlayerHonor:UpdateFightPower(pPlayer);
	
	return 1;
end

-- 为新加的同伴随机一个潜能分配模板ID
function Partner:RandomPotentialTemp(pPlayer)
	local nRateSum = 0;		-- 统计配置表中的权重总和
	for _, tbData in pairs(self.tbPotentialTemp) do
		nRateSum = nRateSum + tbData.nRate or 0;
	end
	
	-- 如果配置表中的权重列全为0或者没填，则认为各个模板的权重是相等的
	if nRateSum == 0 then
		return MathRandom(1, #self.tbPotentialTemp);
	end
	
	local nRandom = MathRandom(1, nRateSum);
	for nPotentialTempId, tbData in pairs(self.tbPotentialTemp) do
		nRandom = nRandom - tbData.nRate;
		if nRandom <= 0 then
			return nPotentialTempId;
		end
	end
	
	-- 如果循环执行过后，随机数还大于0，则出了问题
	if nRandom > 0 then
		Dbg:WriteLog("同伴Log:", pPlayer.szName, 
			string.format("潜能模板随机数超出范围！！模板权重总和为%d，随机数为%d", nRateSum, nRandom + nRateSum));
				
		-- 权重出了问题，在所有模板中随机返回一个模板
		return MathRandom(1, #self.tbPotentialTemp);
	end
end

-- 为一个空白的同伴对象生成技能列表
-- 返回值：技能总数，技能ID列表
function Partner:GenerateSkill(pPartner, nType, nSeries)
	if not self.tbSkillRule then
		return;
	end
	
	if not self.tbSkillSetting then 
		return;
	end
	
	-- 给定的5行值超出范围
	if not self.tbSeries[nSeries] and self.tbSeries[#self.tbSeries] ~= nSeries then
		return;
	end

	local tbSkillCountRate = self.tbSkillRule[nType];
	if not tbSkillCountRate then
		return;		-- 给定同伴类型没有对应的配置
	end

	--得到技能总数
	local nCountAll = self:RandomSkillCount(tbSkillCountRate, nType);	
	
	-- 再依次生成必出技能
	local tbBichuSkill = self:GenBichuSkill(tbSkillCountRate, nCountAll, nSeries);
	
	local tbRandomSkill = {};
	-- 若还有空技能，则在随机模板中随机剩余技能
	if #tbBichuSkill < nCountAll then
		if not tbSkillCountRate.nRandomSkillTemplateId or tbSkillCountRate.nRandomSkillTemplateId == 0 then
			print(string.format("skillrule.txt，[Type = %d]所在行的没有填随机技能模板ID！！", nType));
		else
			local nRandomCount = nCountAll - #tbBichuSkill;
			tbRandomSkill = self:GenRandomSkill(tbSkillCountRate.nRandomSkillTemplateId, nSeries, nRandomCount);
		end
	end
	
	local tbSkillAll = {};
	Lib:MergeTable(tbSkillAll, tbBichuSkill);
	Lib:MergeTable(tbSkillAll, tbRandomSkill);
		
	for _, nAddSkillId in pairs(tbSkillAll) do
		local tbAddSkill = {};
		tbAddSkill.nId = nAddSkillId;
		tbAddSkill.nLevel = 1;		-- 初始时所有技能都是1级
		pPartner.AddSkill(tbAddSkill);		
	end
	
end

-- 某玩家应用同伴技能
-- 第三个参数为0，表示应用技能；否则表示取消技能应用。默认为0
function Partner:ApplySkill(nPlayerId, nPartnerIndex, nApply)
	local nApply = nApply or 0;
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local pPartner = pPlayer.GetPartner(nPartnerIndex);
	if not pPartner then
		return;
	end
	
	for i = 0, pPartner.nSkillCount - 1 do
		local tbSkill = pPartner.GetSkill(i);
		if nApply == 0 then
			pPlayer.AddSkillState(tbSkill.nId, tbSkill.nLevel, 0, 6 * 60 * Env.GAME_FPS);	-- 技能状态不存档,始终有效
		else
			pPlayer.RemoveSkillState(tbSkill.nId);
		end
	end
end

-- 同伴召出效果定时器回调
function Partner:OnCallPartner(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	-- 玩家已经不在这个服务器了，关闭TIMER
	if not pPlayer then
		return;
	end
	
	-- 宏观开关，该变量被设定之后表明所有玩家的这个TIMER都将不起作用
	if Partner.bClosePartnerTimer then	
		-- 关闭TIMER
		self:UnRegisterPartnerTimer(pPlayer);
		return;
	end
	
	local pPartner = pPlayer.GetPartner(pPlayer.nActivePartner);
	-- 没有激活同伴，关闭TIMER
	if not pPartner then
		-- 关闭TIMER
		self:UnRegisterPartnerTimer(pPlayer);
		return;
	end
		
	-- 非战斗状态不做效果应用
	if pPlayer.nFightState == 0 then
		return;
	end
	
	-- 如果玩家正躺在地上也不做效果应用了
	if pPlayer.IsDead() == 1 then
		return;
	end
	
	-- 做激活同伴的亲密度衰减
	self:DecreaseFriendship(nPlayerId);
	
	-- 如果当前玩家正处于隐身状态，同伴就不用出来啦
	-- 16是NPC状态枚举隐身状态的枚举值
	local tbPlayerState = pPlayer.GetNpc().GetState(16);
	-- 如果这个数组中有某项的值不为0，说明玩家正处于隐身状态，同伴不出来了。
	for _, nSingleState in pairs(tbPlayerState) do
		if nSingleState ~= 0 then 
			return;		-- 直接return掉
		end
	end
	
	-- 设置了不能被招出，不出来了！
	if self:IsForbitOut(pPlayer) == 1 then
		return;
	end
	
	if pPartner.GetValue(self.emKPARTNERATTRIBTYPE_FRIENDSHIP) >= self.FRIENDSHIP_SHUYUAN then
		-- TODO:还需要在这里添加施放技能魔法动画
		--local nTempId = self.tbPartIdToNpcId[pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID)];
		local nEffectNpcId = self.tbPartnerAttrib[pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID)].nEffectNpcId;
		local nLevel = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL);
		local nPlayerMapId, nPlayerPosX, nPlayerPosY = pPlayer.GetWorldPos();

		local pNpc = KNpc.Add2(nEffectNpcId, nLevel, -1, nPlayerMapId, nPlayerPosX, nPlayerPosY, 0, 0, 0, 1);
		if not pNpc then
			Dbg:WriteLog("Partner", "Add Npc Faild!", nEffectNpcId, nLevel, nPlayerMapId, nPlayerPosX, nPlayerPosY)
			return 0;
		end
		pNpc.szName = pPartner.szName;
		pNpc.SetTitle(string.format("Đồng hành của %s", pPlayer.szName));
		pNpc.SetNpcAI(0, 0, 0, 0, 0, 0, 0, 0); 	-- 让同伴出来不动
		pNpc.SetCamp(0);	-- 新手阵营
		pNpc.SetCurCamp(0);
		pNpc.AddTaskState(1475);	-- 加无敌状态,1475为无敌BUFF技能ID
		pNpc.SetLiveTime(5 * Env.GAME_FPS)	-- 加生存时间, 5秒
		local nEffectSkillId = MathRandom(1523, 1524);	-- 在两个技能中随机一个
		pNpc.AddFightSkill(nEffectSkillId, 1, 1);
		pNpc.Sync();
		pNpc.DoSkill(nEffectSkillId, -1, pNpc.nIndex);	-- 施放动作

	end
end

function Partner:SetForbitOut(pPlayer, bForit)
	local tbTemp = pPlayer.GetTempTable("Partner");
	tbTemp.bForit = bForit;
end

function Partner:IsForbitOut(pPlayer)
	return pPlayer.GetTempTable("Partner").bForit;
end


-- 做亲密度衰减
function Partner:DecreaseFriendship(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	-- 如果当前没有激活同伴，不扣
	if pPlayer.nActivePartner == -1 then
		return;
	end
	
	local pPartner = pPlayer.GetPartner(pPlayer.nActivePartner);
	if not pPartner then
		return;
	end
	
	-- 同伴等级30级以下不做亲密度衰减
	if pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL) < self.FRIENDSHIP_DECLEVEL then
		return;
	end
	
	
	local nTodayDecr = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_DECRFSTODAY); --今天已经衰减了多少
	
	local nLastTime = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_DECRFSLASTTIME);
	local nNowTime = GetTime();
	
	local nLastTime_day = Lib:GetLocalDay(nLastTime);
	local nNowTime_day = Lib:GetLocalDay(nNowTime);
	
	local nDiff = nNowTime - nLastTime;
	local nToDel = math.ceil(nDiff / self.FRIENDSHIP_TIMEDIFF);
	
	if nNowTime_day - nLastTime_day > 0 then
		-- 到第二天了,把这整个时间段的亲密度衰减都算到第二天里，会有误差，误差在1/1000以内
		if nToDel > self.FRIENDSHIP_DECMAX then
			nToDel = self.FRIENDSHIP_DECMAX;
		end
		
		self:AddFriendship(pPartner, -nToDel);
		pPartner.SetValue(self.emKPARTNERATTRIBTYPE_DECRFSTODAY, nToDel);			
	else
		if nToDel > self.FRIENDSHIP_DECMAX - nTodayDecr then
			nToDel = self.FRIENDSHIP_DECMAX - nTodayDecr;
		end
		
		self:AddFriendship(pPartner, -nToDel);
		pPartner.SetValue(self.emKPARTNERATTRIBTYPE_DECRFSTODAY, nTodayDecr + nToDel);
	end
	-- 一个衰减周期结束，重新计时，重置扣除时间
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_DECRFSLASTTIME, nNowTime);
	
	-- 如果当前激活的同伴的亲密度小于4000了，则强制召回同伴
	if pPartner.GetValue(self.emKPARTNERATTRIBTYPE_FRIENDSHIP) < self.FRIENDSHIP_SHUYUAN then
		self:DoPartnerCallBack(pPlayer, 0);	-- 不用再减亲密度了
		local szMsg = string.format("Độ thân mật của bạn và đồng hành - %s chưa đạt 40, đồng hành không thể giúp đỡ!", pPartner.szName);
		pPlayer.Msg(szMsg);
		self:SendClientMsg(szMsg);
	end
end

-- 获取指定同伴每点亲密度的价值
function Partner:GetFriendshipValue(nIndex)
	local pPartner = me.GetPartner(nIndex);
	if pPartner == nil then
		assert(false);
		return;
	end
	local nLevel = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL);
	local nRate = Partner:GetRate(pPartner);
	nRate = math.floor(nRate / 10) * 10;
	-- 暂时实现着，要改
	if not self.tbMaintenance[nRate] then
		nRate = self.SKILLUPRATEMIN;
	end
	local nBasePrice = self.tbMaintenance[nRate].nMaintenance; -- 维护价值
	--local nTempId = self.tbPartIdToNpcId[pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID)];
	local nType = self.tbPartnerAttrib[pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID)].nType;
	-- 每点亲密度价值量的计算公式为 = 该同伴的基准维护费用 / 600 * 权重系数
	-- 下面的代码中之所以要再除以10是因为公式中的亲密度是按1000为总和算的，而代码中是以10000为总和算的。
	local nPointValue = nBasePrice / 600 * self.tbSkillRule[nType].nCalRate / 10;
	
	return nPointValue;
end

-- 注册同伴定时器
function Partner:RegisterPartnerTimer(pPlayer)
	if not pPlayer then
		return 0;
	end
	
	if not Partner.bClosePartnerTimer and not pPlayer.GetTempTable("Partner").nPartnerTimer then
		pPlayer.GetTempTable("Partner").nPartnerTimer = Timer:Register(self.EFFECTTIME * 60 * Env.GAME_FPS, self.OnCallPartner,
			self, pPlayer.nId);	
			
		return 1;
	end
	
	return 0;
end

-- 注销同伴定时器
function Partner:UnRegisterPartnerTimer(pPlayer)
	if not pPlayer then
		return 0;
	end
	
	if pPlayer.GetTempTable("Partner").nPartnerTimer then
		Timer:Close(pPlayer.GetTempTable("Partner").nPartnerTimer);
		pPlayer.GetTempTable("Partner").nPartnerTimer = nil;
	end
	
	return 1;
end

-- 重置同伴亲密度衰减变量
function Partner:ResetDecrTime(pPartner)
	if pPartner then
		local nLastTime = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_DECRFSLASTTIME);
		local nNowTime = GetTime();
		local nLastTime_day = Lib:GetLocalDay(nLastTime);
		local nNowTime_day = Lib:GetLocalDay(nNowTime);
		
		if nNowTime_day ~= nLastTime_day then
			pPartner.SetValue(Partner.emKPARTNERATTRIBTYPE_DECRFSTODAY, 0);	 -- 如果跨天了，需要手动重设一下数据
		end
		pPartner.SetValue(Partner.emKPARTNERATTRIBTYPE_DECRFSLASTTIME, nNowTime);
		
		if pPartner.nPartnerIndex == me.nActivePartner and me.nFightState == 1  then
			-- 如果该玩家有激活的同伴，开启为同伴召出效果而加的定时器
			Partner:RegisterPartnerTimer(me);
		end
	end
end

------------------------------------------------------------------------------------------------------------
-- 以下函数私有，外部最好不要调用


-- 随机技能的个数
-- 返回值：技能的总个数，必出技能的个数，随机技能的个数
-- TODO: 对表中概率总和小于100的情况做了判断，但没有对概率和大于100的情况做判断
function Partner:RandomSkillCount(tbSkillCountRate, nType)	
	local nRandom = MathRandom(1, 100);	-- 产生的随机数，用来随机技能的总个数
	local nCountAll = 0;	-- 返回值，技能的总个数
	local nMinInThisType = 0;			-- 该类别的NPC允许的技能个数的最低值
	
	for i = self.SKILLCOUNTMIN, self.SKILLCOUNTMAX do
		if tbSkillCountRate["nRateOf"..i.."Skills"] > 0  and nMinInThisType == 0 then
			-- 记录该类别NPC允许的技能个数的最小值
			nMinInThisType = i;
		end
				
		nRandom = nRandom - tbSkillCountRate["nRateOf"..i.."Skills"];		
		
		if nRandom <= 0 then
			nCountAll = i;
			break;
		end
	end
	
	if nRandom > 0 then 		
		-- 走到这里，说明skillrule.txt中该行的概率总和小于100，导致该同伴随机得到的技能数为0
		-- 手动将技能总数置为该类别允许的最小值，并写日志
		if nMinInThisType == 0 then
			-- 悲剧了，如果连这个值都为0，那么说明这项值全被填成了0，则默认技能总数为最小值两个吧！！
			nCountAll = self.SKILLCOUNTMIN;
		else
			nCountAll = nMinInThisType;		-- 这种类别同伴的技能总数最低值
		end
		
		-- print(string.format("\setting\partner\skillrule.txt, [Type = %d]所在行的技能个数概率总和不为100！！", nType));
	end
	
	return nCountAll;
end

-- 生成必出技能，参数为技能总数
-- 返回必出技能ID表
function  Partner:GenBichuSkill(tbSkillCountRate, nCountAll, nSeries)
	local nCanBichuCount = nCountAll;	-- 技能的最大个数
	local tbSkill = {};		-- 存放生成的必出技能ID
	for i = 1, self.BICHUSKILLCOUNT do
		local szBichuSkillId = tbSkillCountRate["nBichuSkill"..i.."Id"];
		local tbBichuSkillId = Lib:SplitStr(szBichuSkillId);
		if #tbBichuSkillId ~= 0 then
			for j = 1, #tbBichuSkillId do
				local nSkillId = tonumber(tbBichuSkillId[j]);
				if not nSkillId then
					break;
				end
				
				local nThisSeries = self.tbSkillSeries[nSkillId];
				if nThisSeries and (nSeries == nThisSeries or nThisSeries == -1 or nSeries == -1) then
					table.insert(tbSkill, nSkillId);
					nCanBichuCount = nCanBichuCount - 1;
					break;
				end
			end
		end
		
		if nCanBichuCount <= 0 then
			break;
		end
	end
	
	return tbSkill;
end

-- 生成随机技能，参数1：随机技能模板ID，参数2：5行，参数3：技能个数
function Partner:GenRandomSkill(nRandomSkillTemplateId, nSeries, nCount)
	local tbUsabelSkillList = {};	-- 可用的技能列表
	local nWeight = 0;	-- 权重总值
	for _, tbList in pairs(self.tbSkillSetting[nRandomSkillTemplateId]) do
		if tbList.nSeries == -1 or tbList.nSeries == nSeries then
			nWeight = nWeight + tbList.nRate;
			tbUsabelSkillList = self:TabInsertPriority(tbUsabelSkillList, tbList);
		end

	end
	
	local tbRandomSkill = {};
	for i = 1, nCount do
		local nRandom = MathRandom(1, nWeight);
		for nKey, tbSkillData in pairs(tbUsabelSkillList) do
			nRandom = nRandom - tbSkillData.nRate;
			if nRandom <= 0 then
				table.insert(tbRandomSkill, tbSkillData.nSkillId);
				nWeight = nWeight - tbSkillData.nRate;	-- 扣除刚学到的技能的权重
				table.remove(tbUsabelSkillList, nKey);	-- 把刚学到的技能从随机表里删除
				break;
			end
		end
	end
	
	return tbRandomSkill;
end

-- 模拟优先权队列，按权重插入数据，权重大的在前列，权重小的在后列
function Partner:TabInsertPriority(tb, tbData)
	-- 二分法插入数据
	local nBegin = 1;
	local nEnd   = #tb;
	local nIndex = math.ceil((nBegin + nEnd)/2);
	while tb[nIndex] do
		if tb[nIndex].nRate > tbData.nRate then
			-- 二分索引的数据比要插入数据优先级高，向下再取二分
			if nIndex == nEnd then
				--table.insert(tb, nIndex + 1, tbData);	-- 如果已到最后，直接插到最末
				nIndex = nIndex + 1;
				break;
			end
			nBegin = nIndex;
			nIndex = math.ceil((nBegin + nEnd)/2);
		elseif tb[nIndex].nRate < tbData.nRate then
			-- 二分索引的数据比要插入数据优先级低，向上再取二分
			if nIndex == nBegin then
				--table.insert(tb, nBegin, tbData);	-- 如果已到最前，直接插到最前
				nIndex = nBegin;
				break;
			end
			nEnd = nIndex;
			nIndex = math.floor((nBegin + nEnd)/2);
		else
			-- 二分索引的数据跟要插入的数据权重相同，则视为原数据优先级比要插入数据大1
			nIndex = nIndex + 1;
			-- table.insert(tb, nIndex + 1, tbData);
			break;
		end
		
		-- 定位到两个相邻数的中间
		if nBegin == nEnd - 1 and tb[nBegin].nRate > tbData.nRate and tb[nEnd].nRate < tbData.nRate then
			--table.insert(tb, nEnd, tbData);
			nIndex = nEnd;
			break;
		end
	end
	
	table.insert(tb, nIndex, tbData);

	return tb;
end

------------------------------------------------------------------------------------------------------------

end 	-- if MODULE_GAMESERVER then

-- 客户端服务端共用
-- 第三个参数nType表示类型，nType为0表示第二个参数为领悟度等级（1-100），否则为1表示第二个参数为领悟度价值量
function Partner:GetTalentLevelAdded(pPartner, nValueAdded, nType)
	if not pPartner then
		return 0, 0;
	end
	
	-- 增加前的领悟度等级和剩余领悟度价值量
	local nCurTalent = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TALENT);	
	local nNewTalentLevel = nCurTalent % 1000;	 -- nCurTalent = nTalentLevel*1000 + nTalentPoint
	local nTalentPoint = math.floor(nCurTalent / 1000);
	
	-- 计算领悟度价值量需要的最大等级数
	local nSkillCount = pPartner.nSkillCount;
	local nNeedLevelMax = self.tbFsTalRate[nSkillCount][1];
	
	-- 计算领悟度价值量时的比率
	--local nTempId = self.tbPartIdToNpcId[pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID)];
	local nPartnerType = self.tbPartnerAttrib[pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID)].nType;
	local nTalentRate = self.tbSkillRule[nPartnerType].nCalRate;
	
	nType = nType or 1;	
	if nType == 0 then
		nNewTalentLevel = math.min(nNewTalentLevel + nValueAdded, self.TALENT_MAX);	-- 最大不能超过100
		nNewTalentLevel = math.max(nNewTalentLevel, self.TAlENT_MIN);	-- 最小不能小于40
	else
		nTalentPoint = nTalentPoint + nValueAdded;
	end
	

	while nNewTalentLevel < self.TALENT_MAX do
		local nCalLevel = math.min(nNewTalentLevel, nNeedLevelMax);
		if nTalentPoint >= self.tbTalentLevel[nCalLevel] * nTalentRate then
			nTalentPoint = nTalentPoint - self.tbTalentLevel[nCalLevel] * nTalentRate;
			nNewTalentLevel = nNewTalentLevel + 1;
		else
			break;
		end
	end
	
	local bTooMuch = 0;		-- 是否太多了
	-- 如果玩家的领悟度达到了100，将剩余的价值量部分清0
	if nNewTalentLevel >= self.TALENT_MAX then
		-- 剩余部分超过了最高点的50%，说明放得太多了
		if (nTalentPoint >= self.tbTalentLevel[self.TALENT_MAX - 1] * nTalentRate * 0.5) then
			bTooMuch = 1;
		end	
		
		nTalentPoint = 0;		
	end
	
	return nNewTalentLevel, nTalentPoint, bTooMuch;
end

-- 获得指定同伴能累计的经验上限
function Partner:GetMaxStoreExp(pPartner)
	local nLevel = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL);
	-- 已经满级了，不能再累积经验
	if nLevel >= self.MAXLEVEL then
		return 0;
	end
	
	local nExpSum = 0;
	for i = nLevel, nLevel + self.LEVELEXPSTROE - 1 do
		nExpSum = nExpSum + self.tbLevelSetting[i].nExp;
		if i >= self.MAXLEVEL - 1 then	
			break;
		end
	end
	
	return nExpSum;
end

-- 计算同伴价值量
function Partner:GetPartnerValue(pPartner)
	if not pPartner then
		return 0;
	end

	--local nNpcId = self.tbPartIdToNpcId[pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID)];
	local nType = self.tbPartnerAttrib[pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID)].nType;

	local nBaseValue = self.tbBaseValue[nType]["nValueOf"..pPartner.nSkillCount.."Skills"];
	if not nBaseValue then
		return 0;
	end
	
	local nSkillUpRate = self:GetRate(pPartner);
	nSkillUpRate = math.floor(nSkillUpRate / 10) * 10;  -- 向下取整十
	if not self.tbMaintenance[nSkillUpRate] then
		nSkillUpRate = self.SKILLUPRATEMIN;
	end
	-- 计算价值量时的比率
	--local nPartnerType = self.tbPartnerAttrib[pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID)].nType;
	local nCalRate = self.tbSkillRule[nType].nCalRate;

	-- 技能升级概率对应的价值量
	local nTitleValue = self.tbMaintenance[nSkillUpRate].nTitleValue; 
	-- 计算价值量时也要乘以档次系数
	nTitleValue = nTitleValue * pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL) / self.MAXLEVEL * nCalRate;
	
	-- 再加上同伴吃掉的技能书的价值量
	local nBookValue = self:GetPartnerSkillBookValue(pPartner);

	return nBaseValue + nTitleValue + nBookValue;
end

--by jiazhenwei  2010/01/20
--计算同伴研习的秘籍的价值量
function Partner:GetPartnerSkillBookValue(pPartner)
	local nValue = 0;		

	if pPartner then
		local nCount = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_SKILLBOOK);
		if nCount < 0 then
			nCount = 0;
		end
		for i =1 , 3 do
			local nNum = math.fmod(nCount, 10 ^ i);
			nValue = nValue + math.floor(nNum / (10^(i - 1)))* self.tbBookValue[i];
		end
	end
	
	return nValue;
end

--获取同伴升级技能的概率，为0-100的整数
function Partner:GetRate(pPartner)
	if pPartner == nil then
		assert(false);
		return;
	end
	-- 当前技能点数
	local nSkillPoint = 0;
	for i = 0, pPartner.nSkillCount - 1 do
		local tbSkill = pPartner.GetSkill(i);
		nSkillPoint = nSkillPoint + tbSkill.nLevel - 1;
	end
	
	local nSkillChannce = math.floor(pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL) / 5);

	-- 该同伴的实际技能升级概率
	local nSkillUpRate = 0;
	if nSkillChannce ~= 0 then
		nSkillUpRate =  math.floor(nSkillPoint * 100 / nSkillChannce);
	end
	-- 该同伴计算时采用的最大概率
	if not self.tbFsTalRate[pPartner.nSkillCount] then
		return 0;
	end
	
	local nMaxRate = self.tbFsTalRate[pPartner.nSkillCount][2] or 100;
	return math.min(nMaxRate, nSkillUpRate);
end

function Partner:SendClientMsg(szMsg)
	me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", szMsg});
end

-- 获得我的同伴的星级
function Partner:GetSelfStartCount(pPartner)
	if not pPartner then
		return 0;
	end

	local nPartnerValue = self:GetPartnerValue(pPartner);
	local nCount = 1;
	for i = 2, Partner.MAXSTARLEVEL do
		local nLevelValue = self.tbStarLevel[i].nStarValue;
		if nPartnerValue >= nLevelValue then
			nCount = nCount + 1;
		end
	end
	
	if nCount < 2 then
		nCount = 2;
	end
	
	return nCount;
end

-- 可否被转成真元
-- 参数可为同伴对象，或数值表示同伴模板ID，或table第一个值表示同伴模板ID
function Partner:CanConvertToZhenYuan(varPartner)
	if not varPartner then
		return 0;
	end
	
	local bRet = 0;
	local nPartTempId = 0;
	if type(varPartner) == "userdata" then
		nPartTempId = varPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID);
	elseif type(varPartner) == "number" then
		nPartTempId = varPartner;
	elseif type(varPartner) == "table" then
		nPartTempId = varPartner[1];
	end
		
	-- \\item\\001\zhenyuansetting\\partnerconver.txt中存在的同伴才能转真元
	if Item.tbZhenYuanSetting.tbPartnerToZhenYuan[nPartTempId] then
		bRet = 1;
	end
	
	return bRet;
end

-- 通过同伴对象获取真元的GDPL和模板ID以及道具名
-- 参数为userdata表示同伴对象，参数为table第一个值表示同伴ID，第二个值表示同伴技能个数
function Partner:GetZhenYunInfoFromPartner(varPartner)
	if not varPartner then
		return;
	end
	
	local tbGDPL = {};
	local nZhenyuanTemp = 0;
	local nPartnerValue = 0;
	local nPartTempId = 0;
	local nSkillCount = 0;
	if type(varPartner) == "userdata" then
		local pPartner = varPartner;
		nPartTempId = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID);
		nSkillCount = pPartner.nSkillCount;
	elseif type(varPartner) == "table" then
		nPartTempId = varPartner[1];
		nSkillCount = varPartner[2]
	end
	
	if nPartTempId == 0 or nSkillCount < self.SKILLCOUNTMIN or nSkillCount > self.SKILLCOUNTMAX then
		return;
	end
	
	-- 通过配置文件获取真元的GDPL信息
	local tbSetting = Item.tbZhenYuanSetting.tbPartnerToZhenYuan[nPartTempId];
	if not tbSetting then
		return;
	end
	
	tbGDPL = {tbSetting.G, tbSetting.D, tbSetting.P, tbSetting.L};
	nZhenyuanTemp = tbSetting.nZhenYuanTemp;
	
	-- 只能取基础价值量，不能用GetPartnerValue()这个接口来取价值量，因为这个接口中给了技能升级概率基础价值量
	local nType = self.tbPartnerAttrib[nPartTempId].nType;		
	nPartnerValue = self.tbBaseValue[nType]["nValueOf"..nSkillCount.."Skills"];
	
	-- 获取凝聚比例
	local nConverRate = tbSetting.nValueRate;
	nPartnerValue = math.floor(nPartnerValue/100 * nConverRate);		-- 先除后乘防止溢出	
	
	return tbGDPL, nZhenyuanTemp, nPartnerValue, tbSetting.szName;
end

-- 获取同伴增加战斗力
function Partner:GetFightPowerAdded(pPartner, bActive)
	if (1 ~= Player.tbFightPower:IsFightPowerValid()) then
		return;
	end
	
	bActive = bActive or 0;
	
	local nValue = self:GetPartnerValue(pPartner);
	
	local nRate = 100;
	if bActive == 0 and pPartner.nPartnerIndex ~= me.nActivePartner then
		nRate = Partner.FIGHTPOWER_RATE_UNREADY;
	end
	
	return math.floor(nValue / 20000000 * nRate)/100;
end

-- 设置系统开放的基本同伴个数，同时要修改对应宏定义(即PARTNERLIMIT_MIN的值)
function Partner:SetPartnerBaseCount(nCount)
	--  如果相等就不改了
	if self.PARTNERLIMIT_MIN == nCount then
		return;
	end
	
	self.PARTNERLIMIT_MIN = nCount;
	if MODULE_GAMESERVER then
		for _, pPlayer in pairs(KPlayer.GetAllPlayer()) do
			pPlayer.SetPartnerLimit(self.PARTNERLIMIT_MIN);
			pPlayer.CallClientScript({"Partner:SetPartnerBaseCount", nCount});
		end
	end
end

-- 试图说服一个NPC成为自己的同伴，做说服相关的条件判断
-- 返回值：可以被说服返回1，不能被说服返回0和原因
function Partner:TryToPersuade(pPlayer, pNpc, nItemLevel)
	if not self.tbPartnerAttrib or not self.tbPersuadeInfo then
		-- print("没有加载配置表文件\setting\Partner\partner.txt");
		return 0, "Không thể sử dụng!";
	end
	
	-- 必须要有门派
	if pPlayer.nFaction == 0 then
		return 0, "Chưa gia nhập môn phái!";
	end
	
	-- 玩家等级是否满足需求
	if pPlayer.nLevel < self.PERSUADELEVELLIMIT then		-- 100级以后才可以说服同伴
		return 0, "Cấp độ quá thấp!";
	end

	-- 指定的NPC是否被开放为可说服NPC
	local nPartnerId = self.tbPersuadeInfo[pNpc.nTemplateId];
	if not nPartnerId then
		--self:SendClientMsg("这家伙面露凶相，还是不要自讨没趣。换个头像旁有红心的试试看。");
		return 0, "Tên này ghê quá, hãy tìm đồng hành có biểu tượng trái tim để thuyết phục.";
	end
	
	-- 每个类型的怪的说服等级不同
	local nType = self.tbPartnerAttrib[nPartnerId].nType;
	if pPlayer.nLevel < self.tbSkillRule[nType].nLevelRequire then
		return 0, string.format("Phải đến cấp %d mới có thể thuyết phục NPC này!", self.tbSkillRule[nType].nLevelRequire);
	end

	-- 道具的等级与说服NPC需求的道具等级是否匹配
	if nItemLevel ~= self.tbPartnerAttrib[nPartnerId].nTypeLevel then
		return 0, "Cấp độ loại đạo cụ này không phù hợp.";
	end
	
	-- NPC的血量比例是否满足需求
	local nLifeRate = math.ceil(pNpc.nCurLife/pNpc.nMaxLife * 100);
	if nLifeRate > self.tbPartnerAttrib[nPartnerId].nLifeRatio then
		return 0, string.format("Lượng máu phải dưới %d%% mới có thể thuyết phục.", 
			self.tbPartnerAttrib[nPartnerId].nLifeRatio);
	end
	
	-- 玩家和NPC的距离是否满足需求
	local nPlayerMapId, nPlayerPosX, nPlayerPosY = pPlayer.GetWorldPos();
	local nNpcMapId, nNpcPosX, nNpcPosY	= pNpc.GetWorldPos();
	if nPlayerMapId ~= nNpcMapId then
		Dbg:WriteLog("Partner", 
			string.format("玩家%s试图去说服跟自己不在同一地图的NPC成为自己的同伴！！！", pPlayer.szName));
		return 0, "Sử dụng đạo cụ thất bại!";
	end
	local nDistance = math.ceil(math.sqrt((nPlayerPosX - nNpcPosX) ^ 2 + (nPlayerPosY - nNpcPosY) ^ 2) * 32);
	if nDistance > self.MAXPERSUADEDISTANCE then
		return 0, "Hãy đến gần hơn để thuyết phục";
	end
		
	-- 玩家拥有的同伴个数是否已达上限
	if pPlayer.nPartnerLimit == 0 then
		pPlayer.SetPartnerLimit(self.PARTNERLIMIT_MIN);
	end	
	if pPlayer.nPartnerCount >= pPlayer.nPartnerLimit then
		local szMsg = string.format("Đã có quá nhiều đồng hành, đừng tham lam.");
		-- 目前先不给玩家能买同伴槽的信息提示
		--[[if me.nPartnerLimit < self.PARTNERLIMIT_MAX then
			szMsg = szMsg.."，若还想继续寻得同伴，可去新手村纳兰真那里看看。"
		else
			szMsg = szMsg.."。";
		end]]--
		return 0, szMsg;
	end
	
	return 1;
end