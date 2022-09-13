local tbXisuidashi = Npc:GetClass("xisuidashi");

function tbXisuidashi:OnDialog()
	local tbOpt = {};
	
	local nChangeGerneIdx = Faction:GetChangeGenreIndex(me);
	if(nChangeGerneIdx >= 1)then
		local szMsg;
		if(Faction:Genre2Faction(me, nChangeGerneIdx) > 0 )then --该种类已修
			szMsg = "Ta muốn thay đổi môn phái Phụ tu";
		else
			szMsg = "Ta muốn lựa chọn Phụ tu môn phái";
		end
		table.insert(tbOpt, {szMsg, self.OnChangeGenreFaction, self, me});
	end
	
	table.insert(tbOpt, {"Tẩy điểm tiềm năng", self.OnResetDian, self, me, 1});
	table.insert(tbOpt, {"Tẩy điểm kỹ năng", self.OnResetDian, self, me, 2});
	table.insert(tbOpt, {"Tẩy điểm tiềm năng và kỹ năng", self.OnResetDian, self, me, 0});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});

	local szMsg = "Ta có thể giúp ngươi phân phối lại điểm tiềm năng và kỹ năng. Phía trên có 1 hang động, ngươi hãy vào đó trải nghiệm. Khi đã hài lòng có thể đến truyền tống môn phái để về với giang hồ.";
	Dialog:Say(szMsg, tbOpt);
end

function tbXisuidashi:OnResetDian(pPlayer, nType)
	local szMsg = "";
	
	-- GM号
	if (me.GetCamp() == 6) then
		if (me.IsHaveSkill(91)) then
			me.DelFightSkill(91);	-- 银丝飞蛛
		end
		if (me.IsHaveSkill(163)) then
			me.DelFightSkill(163);	-- 梯云纵
		end
		if (me.IsHaveSkill(1417)) then
			me.DelFightSkill(1417);	-- 1级移形换影
		end
	end
	
	if (1 == nType) then
		pPlayer.SetTask(2,1,1);
		pPlayer.UnAssignPotential();
		szMsg = "Tẩy điểm tiềm năng thành công.";
	elseif (2 == nType) then
		pPlayer.ResetFightSkillPoint();
		szMsg = "Tẩy điểm kỹ năng thành công.";
	elseif (0 == nType) then
		pPlayer.ResetFightSkillPoint();
		pPlayer.SetTask(2,1,1);
		pPlayer.UnAssignPotential();
		szMsg = "Tẩy điểm tiềm năng và kỹ năng thành công.";
	end
	
	-- GM号
	if (me.GetCamp() == 6) then
		me.AddFightSkill(91, 60);	-- 银丝飞蛛
		me.AddFightSkill(163, 60);	-- 梯云纵
		me.AddFightSkill(1417, 1);	-- 1级移形换影
	end
	
	Setting:SetGlobalObj(pPlayer);
	Dialog:Say(szMsg);
	Setting:RestoreGlobalObj();
end

function tbXisuidashi:OnChangeGenreFaction(pPlayer)
	local tbOpt	= {};
	local nFactionGenre = Faction:GetChangeGenreIndex(pPlayer);
	for nFactionId, tbFaction in ipairs(Player.tbFactions) do
		if (Faction:CheckGenreFaction(pPlayer, nFactionGenre, nFactionId) == 1) then
			table.insert(tbOpt, {tbFaction.szName, self.OnChangeGenreFactionSelected, self, pPlayer, nFactionId});
		end
	end
	table.insert(tbOpt,{"Kết thúc đối thoại"});
	
	local szMsg = "Hãy lựa chọn môn phái phụ tu";
	
	Setting:SetGlobalObj(pPlayer);
	Dialog:Say(szMsg, tbOpt);
	Setting:RestoreGlobalObj();
end

function tbXisuidashi:OnChangeGenreFactionSelected(pPlayer, nFactionId)
	
	local nGenreId		 = Faction:GetChangeGenreIndex(pPlayer);
	local nPrevFaction   = Faction:Genre2Faction(pPlayer, nGenreId);
	local nResult, szMsg = Faction:ChangeGenreFaction(pPlayer, nGenreId, nFactionId);
	if(nResult == 1)then
		if (nPrevFaction == 0) then -- 第一次多修
			szMsg = "Ngươi đã chọn %s, sử dụng Tu luyện châu để tiến hành đổi môn phái, đồng thời <color=yellow>Ngũ hành ấn và Phi phong<color> cũng sẽ được tự động chuyển đổi, <color=yellow>và giữ lại cấp độ, thuộc tính ban đầu<color>.<enter>Sau khi chuyển sang môn phái phụ tu, ngươi có thể tự phân phối điểm. Tại <color=yellow>Thương Nhân<color> ngươi có thể mua vũ khí để trải nghiệm.<enter>Nếu ngươi chưa hài lòng, hãy đến gặp ta phân phối lại.  Khi đã ưng ý, đến <color=yellow>Truyền tốn môn phái<color> để rời đi.<enter>Sau khi rời đi, chính thức xác nhận môn phái phụ tu và <color=yellow>sẽ không thể thay đổi<color>, hãy suy nghĩ kỹ.";
		else
			szMsg = "Môn phái phụ tu thay đổi thành %s, sử dụng Tu luyện châu để tiến hành đổi môn phái, đồng thời <color=yellow>Ngũ hành ấn và Phi phong<color> cũng sẽ được tự động chuyển đổi,  <color=yellow>và giữ lại cấp độ, thuộc tính ban đầu<color>.<enter>Sau khi chuyển sang môn phái phụ tu, ngươi có thể tự phân phối điểm. Tại <color=yellow>Thương Nhân<color> ngươi có thể mua vũ khí để trải nghiệm.<enter>Nếu ngươi chưa hài lòng, hãy đến gặp ta phân phối lại.  Khi đã ưng ý, đến <color=yellow>Truyền tốn môn phái<color> để rời đi.<enter>Sau khi rời đi, chính thức xác nhận môn phái phụ tu và <color=yellow>sẽ không thể thay đổi<color>, hãy suy nghĩ kỹ."
		end
		szMsg = string.format(szMsg, Player.tbFactions[nFactionId].szName);
	end
	
	Setting:SetGlobalObj(pPlayer);
	Dialog:Say(szMsg);
	Setting:RestoreGlobalObj();
end

local tbXisuimenpai = Npc:GetClass("xisuimenpaichuansongren");

function tbXisuimenpai:OnDialog()
	local nChangeGerne = Faction:GetChangeGenreIndex(me); 
	local szMsg;
	if(nChangeGerne > 0)then -- 我来这儿多修
		szMsg = "Khi nào ngươi hài long với lựa chọn của mình, ta sẽ đưa ngươi về môn phái";
	else
		szMsg = "Khi nào ngươi hài lòng với lần tẩy tủy này, ta sẽ đưa ngươi về môn phái";
	end
	
	local tbOpt = {
			{"Rời khỏi đầy", self.OnCheckLeave, self, me},
			{"Kết thúc đối thoại"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbXisuimenpai:OnCheckLeave(pPlayer)
	local nChangeGerne = Faction:GetChangeGenreIndex(pPlayer); 
	local szMsg, tbOpt;
	if(nChangeGerne > 0)then -- 我来这儿多修
		if(Faction:Genre2Faction(pPlayer, nChangeGerne) <= 0)then
			szMsg = "Ngươi chưa chọn môn phái phụ tu, không thể rời khỏi";
		elseif(pPlayer.IsAccountLock() == 1)then
			szMsg = "Tài khoản đang khóa, không thể rời khỏi Tẩy Tủy Đảo";
		else
			szMsg = "<enter>Sau khi rời khỏi, môn phái lựa đã lựa chọn <color=yellow>không thể thay đổi<color>, ngươi có chắc muốn rời đi không?";
			tbOpt = {
					{"Có, ta chắc chắn", self.OnLeave, self, pPlayer},
					{"Để ta suy nghĩ lại một chút"},
				};
		end	
	else
		szMsg = "Ngươi chắc rằng muốn rời khỏi đây?";
		tbOpt = {
				{"Có, ta chắc chắn", self.OnLeave, self, pPlayer},
				{"Kết thúc đối thoại"},
			};
	end
	Setting:SetGlobalObj(pPlayer);
	Dialog:Say(szMsg, tbOpt);
	Setting:RestoreGlobalObj();
end

function tbXisuimenpai:OnLeave(pPlayer)
	local nChangeFactionIndex = Faction:GetChangeGenreIndex(pPlayer);
	local nChangedFaction;
	if (nChangeFactionIndex > 0) then -- 我来这儿多修
		nChangedFaction = Faction:Genre2Faction(pPlayer, nChangeFactionIndex);
		Faction:WriteLog(Dbg.LOG_INFO, "tbXisuimenpai:OnLeave", pPlayer.szName, nChangeFactionIndex, nChangedFaction);
		Faction:SetChangeGenreIndex(pPlayer, 0);
	end
	
	assert(pPlayer.nFaction);
	Npc.tbMenPaiNpc:Transfer(pPlayer.nFaction);
	
	if (nChangeFactionIndex > 0) then
		pPlayer.Msg("Đã lựa chọn " .. Player.tbFactions[nChangedFaction].szName);
		--成就
		if nChangeFactionIndex == 2 then
			Achievement:FinishAchievement(pPlayer, 64);
		elseif nChangeFactionIndex == 3 then
			Achievement:FinishAchievement(pPlayer, 65);
		end 	
		--end
		
	end
end
