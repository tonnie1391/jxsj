-- 文件名　：goldls_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-03-07 15:49:18
-- 功能    ：金牌联赛

--家族建立卡
local tbItemCreatKin = Item:GetClass("Gold_CreatKin");

function tbItemCreatKin:OnUse()
	if me.nLevel < 10 then
		me.Msg("只有达到10级的玩家才能使用该道具。");
		return 0;
	end
	if me.nFaction <= 0 then
		me.Msg("请您先加入门派。");
		return 0;
	end
	local nKinId, nExcutorId = me.GetKinMember();
	if nKinId <= 0 then
		Dialog:Say("您还没有家族，可以通过该卡片不需要银两及人员要求建立家族，您需要建立家族吗？", {{"建立家族", self.CreatKin, self, it.dwId, me.nId}, {"Để ta suy nghĩ thêm"}});
		return 0;
	else
		if me.nKinFigure ~= 1 then
			me.Msg("对不起，您不是族长不能使用该道具。");
			return 0;
		end
		local cKin = KKin.GetKin(nKinId);
		if not cKin then
			return 0;
		end
		if cKin.GetGoldLogo() > 0 then
			me.Msg("你们家族已经是金牌家族了。");
			return 0;
		end
		Dialog:Say("您已经有家族了，可以使用该道具将家族提升为<color=yellow>金牌家族<color>，是否确认？", {{"金牌标志", self.KinLogo, self, it.dwId, me.nId}, {"Để ta suy nghĩ thêm"}});
	end
end

function tbItemCreatKin:KinLogo(dwId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		pPlayer.Msg("您的道具有问题。");
		return 0;
	end
	if pPlayer.dwKinId < 1 then
		pPlayer.Msg("对不起，没有家族。");
		return 0;
	end
	if pPlayer.nKinFigure ~= 1 then
		pPlayer.Msg("对不起，您不是族长不能使用该道具。");
		return 0;
	end
	local cKin = KKin.GetKin(pPlayer.dwKinId);
	if not cKin then
		return 0;
	end
	if cKin.GetGoldLogo() > 0 then
		pPlayer.Msg("你们家族已经是金牌家族了。");
		return 0;
	end
	GCExcute({"Kin:SetGoldFlag", pPlayer.dwKinId});
	StatLog:WriteStatLog("stat_info", "jinpailiansai", "create", nPlayerId, cKin.GetName(), 2);
	pItem.Delete(pPlayer);
end

function tbItemCreatKin:CreatKin(dwId, nPlayerId, nFlag, szKinName)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		pPlayer.Msg("您的道具有问题。");
		return 0;
	end
	local nKinId, nExcutorId = pPlayer.GetKinMember();
	if nKinId > 0 then
		pPlayer.Msg("您已经有家族了。");
		return 0;
	end
	if not nFlag then
		Dialog:AskString("请输入家族名字", 16, self.CreatKin, self, dwId, nPlayerId, 1);
		return 0;
	else
		local nRet = Kin:CreateKin_GS1({nPlayerId}, {pPlayer.nPrestige}, szKinName, 1, nPlayerId, 1);
		if nRet ~= 1 then
			local szMsg = "家族创建失败！"
			if nRet == -1 then
				szMsg = szMsg.."输入的家族名字长度不符合要求（3～6个汉字）！"
			elseif nRet == -2 then
				szMsg = szMsg.."名称只能包含中文简繁体字及· 【 】符号！"
			elseif nRet == -3 then
				szMsg = szMsg.."对不起，您输入的家族名称包含敏感字词，请重新设定"
			elseif nRet == -4 then
				szMsg = szMsg.."家族名已被占用！"
			end
			pPlayer.Msg(szMsg);
			return 0
		end
	end
end

----------------------------------------------------------------------
--江湖邀请令
local tbInviteCard = Item:GetClass("Gold_Invite");
tbInviteCard.nPageCount = 9;	--每页显示个数


function tbInviteCard:OnUse(nParam, nPage, tbPlayer)
	local szMsg = "通过江湖邀请令可以获得江湖新秀的信息，并进行私聊，请选择需要查看的玩家？";
	tbPlayer = tbPlayer or {};
	if not nPage then
		local tbPlayerList = KPlayer.GetAllPlayer();
		for _, pPlayer in ipairs(tbPlayerList) do
			if pPlayer.nId ~= me.nId and pPlayer.nKinFigure <= 0 and IpStatistics:CheckStudioRole(pPlayer) == 0 then
				table.insert(tbPlayer, pPlayer);
			end
		end
	end
	local tbOpt = {{"Để ta suy nghĩ thêm"}};
	nPage = nPage or 1;
	local nCount = 0;	
	for i, pPlayer in ipairs(tbPlayer) do
		if nCount >= self.nPageCount then
			break;
		end
		if i <= self.nPageCount * nPage and i > self.nPageCount * (nPage - 1) then
			table.insert(tbOpt, 1, {pPlayer.szName, self.ViewPlayer, self, me.nId, pPlayer});
			nCount = nCount + 1;
		end
	end
	if nPage == 1 and #tbPlayer  > self.nPageCount then
		table.insert(tbOpt, #tbOpt - 1, {"Trang sau", self.OnUse, self, nParam, nPage + 1, tbPlayer});
	elseif nPage > 1 and #tbPlayer - nPage * self.nPageCount < self.nPageCount then
		table.insert(tbOpt, #tbOpt - 1, {"Trang trước", self.OnUse, self, nParam, nPage - 1, tbPlayer});
	elseif nPage > 1 and #tbPlayer - nPage * self.nPageCount > self.nPageCount then
		table.insert(tbOpt, #tbOpt - 1, {"Trang trước", self.OnUse, self, nParam, nPage - 1, tbPlayer});
		table.insert(tbOpt, #tbOpt - 1, {"Trang sau", self.OnUse, self, nParam, nPage + 1, tbPlayer});
	end
	if #tbOpt <= 1 then
		szMsg = "通过江湖邀请令可以获得江湖新秀的信息，并进行私聊，好像没有新秀玩家可以查看。";
	end
	Dialog:Say(szMsg, tbOpt);
	return;
end

function tbInviteCard:ViewPlayer(nPlayerId, pNewPlayer)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local tbSex = {"男", "女"};
	local tbFactionName = {"少林", "天王", "唐门", "五毒", "娥眉", "翠烟", "丐帮", "天忍", "武当", "昆仑", "明教", "大理段氏"};
	if not pNewPlayer then
		pPlayer.Msg("玩家已经离线。");
		return;
	end
	local szMsg = string.format("江湖邀请令查看玩家信息：\n\n玩家姓名：%s\n玩家性别：%s\n玩家职业：%s\n所在地图：%s\n", pNewPlayer.szName, tbSex[pNewPlayer.nSex + 1], tbFactionName[pNewPlayer.nFaction] or "无门派", GetMapNameFormId(pNewPlayer.nMapId));
	Setting:SetGlobalObj(pPlayer);
	Dialog:Say(szMsg, {{"开始密聊", self.Chat, self, pPlayer, pNewPlayer}, {"Để ta suy nghĩ thêm"}});
	Setting:RestoreGlobalObj();
end

function tbInviteCard:Chat(pPlayer, pNewPlayer)
	if not pPlayer then
		return;
	end
	if not pNewPlayer then
		pPlayer.Msg("玩家已经离线。");
		return;
	end
	pPlayer.CallClientScript({"ChatToPlayer", pNewPlayer.szName});
end
