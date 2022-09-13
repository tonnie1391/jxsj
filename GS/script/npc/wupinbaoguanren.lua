-- 通用物品保管员脚本

local tbNpc = Npc:GetClass("wupinbaoguanren");

if (not MODULE_GAMESERVER) then
	return;
end

tbNpc.tbMapPosMap	= {};	-- [nMapId]	= tbMapPos
							-- tbMapPos:	[nPointId]	= {X,Y}

tbNpc.tbBornPos		= {};	-- { {nMapId, nX, nY}, {nMapId, nX, nY}, ... }

function tbNpc:Init()
	self.tbMapPosMap	= {};
	local tbData	= Lib:LoadTabFile("\\setting\\map\\revivepos.txt");
	for _, tbRow in ipairs(tbData) do
		local nMapId	= tonumber(tbRow.MapId);
		local nPointId	= tonumber(tbRow.PointId);
		local tbPos		= {tonumber(tbRow.PosX), tonumber(tbRow.PosY)};
		if (tbRow.Type == "save") then	-- 保存点
			local tbMapPos	= self.tbMapPosMap[nMapId];
			if (not tbMapPos) then
				tbMapPos	= {};
				self.tbMapPosMap[nMapId]	= tbMapPos;
			end
			tbMapPos[nPointId]	= tbPos;
		elseif (tbRow.Type == "born") then	-- 出生点
			self.tbBornPos[#self.tbBornPos + 1]	= {nMapId, tbPos[1], tbPos[2]};
		end
	end
end

function tbNpc:OnDialog()
	if (me.nFightState ~= 0) then
		me.Msg("Không thể mở trong trạng thái chiến đấu!");
		return;
	end
	
	local tbNpcTempTable	= him.GetTempTable("Npc");
	local nNearestPointId	= tbNpcTempTable.nWuPinBaoGuanRen_NearestPointId;
	if (not nNearestPointId) then
		nNearestPointId	= 0;
		local nMapId, nX, nY	= him.GetWorldPos();
		local nNearestLen	= 10000;	-- 当前找到的最短距离的平方，初始值可以用于限定允许寻找的最大范围
		for nPointId, tbPos in pairs(self.tbMapPosMap[nMapId] or {}) do
			local nLen	= (tbPos[1] - nX)*(tbPos[1] - nX) + (tbPos[2] - nY)*(tbPos[2] - nY)
			if (nLen < nNearestLen) then
				nNearestLen		= nLen;
				nNearestPointId	= nPointId;
			end
		end
		tbNpcTempTable.nWuPinBaoGuanRen_NearestPointId	= nNearestPointId;
	end
	
	if (nNearestPointId == 0) then -- 未找到对应回城点，直接开箱子
		self:OpenBox();
		return;
	end
	
	local nMapId, nPointId	= me.GetDeathRevivePos();
	if (nMapId == him.nMapId and nPointId == nNearestPointId) then	-- 回城点没变化，直接开箱子
		self:OpenBox();
		return;
	end
	local szMsg = "Ngươi muốn ghi nhớ điểm hồi thành tại đây?" 
	if (me.CheckXuanJingTimeOut(7, 0) == 1) then
		szMsg = "<color=green>   Trong rương có Huyền tinh sắp hết hạn. Hãy mau sử dụng.<color>\n\n  " .. szMsg;
	end
	Dialog:Say(szMsg,
		{"Đúng vậy", tbNpc.OnSavePoint, tbNpc, nNearestPointId},
		{"Không, ta mở rương thôi", tbNpc.OpenBox, tbNpc},
		{"Kết thúc đối thoại"}
	);
end

function tbNpc:OnSavePoint(nNearestPointId)
	Log:Ui_LogSetValue("是否改变过存点", 1)
	me.SetRevivePos(him.nMapId, nNearestPointId);
	me.Msg("Đã lưu điểm hồi sinh!");
	self:OpenBox();
end

function tbNpc:OpenBox()
	Log:Ui_LogSetValue("是否使用过储物箱", 1)
	me.OpenRepository(him);
	--成就
	Achievement:FinishAchievement(me,413);
end

tbNpc:Init();
