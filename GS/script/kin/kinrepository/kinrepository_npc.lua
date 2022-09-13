local tbClass = Npc:GetClass("KinRepManager");

function tbClass:OnDialog()
	local szMsg = "<color=green>十年生死两茫茫，<enter>     不思量，自难忘。<enter>          相顾无言，惟有泪千行。<color><enter>十年了，这凝心池的冰结又化，化又结，你可还记得当年对语荷的承诺？";
	local nKinId, nMemberId = me.GetKinMember();
	if nKinId <= 0 then
		Dialog:Say("等你加入了家族再来找我吧。");
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		Dialog:Say("等你加入了家族再来找我吧。");
		return 0;
	end
	if cKin.GetIsOpenRepository() == 0 then
		local nRet, cKin = Kin:CheckSelfRight(nKinId, nMemberId, 1);
		if nRet ~= 1 then
			Dialog:Say("请让家族族长前来开启家族仓库。");
			return 0;
		end
		local tbOpt = 
		{
			{"开启家族仓库功能", self.SetRepositoryFlag, self},
			{"Ta chỉ xem qua"},	
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end

	local tbOpt = 
	{
		{"打开家族仓库", self.OpenRepository, self},
		{"Ta chỉ xem qua"},	
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbClass:OpenRepository()
	me.OpenKinRepository(KinRepository.LIMIT_ROOM_SET[1]);
	KinRepository:SyncRepositoryInfo(me);
end

function tbClass:SetRepositoryFlag()
	local nKinId, nMemberId = me.GetKinMember();
	if nKinId <= 0 then
		Dialog:Say("等你加入了家族再来找我吧。");
		return 0;
	end
	local nRet, cKin = Kin:CheckSelfRight(nKinId, nMemberId, 1)
	if nRet ~= 1 then
		Dialog:Say("请让家族族长前来开启家族仓库");
		return 0;
	end
	if not HomeLand.tbLastWeekKinId2Index[nKinId] then
		Dialog:Say(string.format("等你的家族江湖总威望达到服务器前%s名再来找我吧。", HomeLand.MAX_LADDER_RNAK));
		return 0;
	end
	if HomeLand.tbLastWeekKinId2Index[nKinId] > HomeLand.MAX_LADDER_RNAK then
		Dialog:Say(string.format("等你的家族江湖总威望达到服务器前%s名再来找我吧。", HomeLand.MAX_LADDER_RNAK));
		return 0;
	end
	GCExcute{"KinRepository:SetRepositoryFlag_GC", nKinId, nMemberId, me.nId};
end