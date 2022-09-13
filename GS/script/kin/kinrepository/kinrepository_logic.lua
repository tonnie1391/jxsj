-- 文件名　：homeland_logic.lua
-- 创建者　：huangxiaoming
-- 创建时间：2012-06-13 9:18:10
-- 描  述  ：


function KinRepository:GetRoomInfo(dwKinId, nRoom)
	if nRoom < 0 or nRoom > self.ROOMTASK_END - self.ROOMTASK_BEGIN then
		return 0;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return 0;
	end
	local nRoomTask = 73;
	local uInfo = cKin.GetTask(self.ROOMTASK_BEGIN + nRoom);
	local nExp = Lib:LoadBits(uInfo, self.BITS_EXP_BEG, self.BITS_EXP_END);
	local nPermit = Lib:LoadBits(uInfo, self.BITS_AUTHORITY_BEG, self.BITS_AUTHORITY_END);
	if nPermit == 0 then -- 如果没有设权限则用默认权限,该参数保留方便扩展
		nPermit = self.AUTHORITY_ROOM[nRoom];
	end
	local nRoomSize = Lib:LoadBits(uInfo, self.BITS_SIZE_BEG, self.BITS_SIZE_END);
	if nRoomSize == 0 then
		nRoomSize = self.ROOMSIZE_ROOM[nRoom]; -- 如果未设大小则用每页默认大小
	end
	return nRoomSize, nPermit, nExp;
end

function KinRepository:CheckRepAuthority(nKinId, nExcutorId, nFigureLevel)
	if nKinId == 0 or nExcutorId == 0 then
		return 0
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	--执行者为-1默认系统执行
	if nExcutorId == -1 then
		return 1, cKin;
	end
	local cMemberExcutor = cKin.GetMember(nExcutorId)
	if not cMemberExcutor then
		return 0, cKin;
	end
	local nAssignAuthority = cMemberExcutor.GetRepAuthority();
	if nAssignAuthority < 0 then -- 小于0代表是被禁止操作
		return 0, cKin, cMemberExcutor;
	end
	-- 如果设置了权限，且权限比需要的权限大那肯定可以操作
	if nAssignAuthority > 0 and nAssignAuthority >= nFigureLevel then
		return 1, cKin, cMemberExcutor;
	end
	local nExcutorFigure = cMemberExcutor.GetFigure();
	
	-- 所有玩家都可以操作
	if nFigureLevel <= self.AUTHORITY_EVERYONE then
		return 1, cKin, cMemberExcutor;
	end
	-- 3级以下权限不关联玩家权限
	if (nFigureLevel == self.AUTHORITY_RETIRE and (nExcutorFigure <= Kin.FIGURE_REGULAR or nExcutorFigure == Kin.FIGURE_RETIRE)) -- 正式的和荣誉成员能操作
		or (nFigureLevel == self.AUTHORITY_FIGURE_REGULAR and nExcutorFigure <= Kin.FIGURE_REGULAR)  then-- 正式以上成员能操作
		return 1, cKin, cMemberExcutor;
	end
	 -- 族长肯定有权限
	if nExcutorFigure == Kin.FIGURE_CAPTAIN then
		if cKin.GetCaptainLockState() == 1 then
			if MODULE_GAMESERVER then
				local pPlayer = KPlayer.GetPlayerObjById(cMemberExcutor.GetPlayerId());
				if pPlayer then
					pPlayer.Msg("你已被罢免，仓库管理权限已被取消！");
				end
			end
			return 0, cKin, cMemberExcutor;
		end
		return 1, cKin, cMemberExcutor;
	end
	return 0, cKin, cMemberExcutor;
end


function KinRepository:GetRoomType(nRoom)
	for nType, tbSet in pairs(self.ROOM_SET) do
		for _, nFindRoom in ipairs(tbSet) do
			if nFindRoom == nRoom then
				return nType;
			end
		end
	end
	return 0;
end

-- 扩展仓库需要的银两
function KinRepository:GetExtendMoney(nType, nLevel)
	local nAvg = JbExchange.GetPrvAvgPrice;
	if nAvg > self.MAX_AVG_PRICE then
		nAvg = self.MAX_AVG_PRICE;
	end
	local nMoney = KinRepository.BUILD_VALUE[nType][nLevel][2] * KinRepository.EXTEND_MONEY_COE * nAvg;
	return math.floor(nMoney);
end