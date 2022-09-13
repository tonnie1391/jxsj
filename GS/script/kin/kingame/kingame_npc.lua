-------------------------------------------------------------------
--File		: kingame_npc.lua
--Author	: zhengyuhua
--Date		: 2008-5-13 10:24
--Describe	: 家族关卡定义脚本
-------------------------------------------------------------------

local DYN_MAP_ID_START = 65535;	--动态地图起始


-- 进入副本对话逻辑
function KinGame:OnEnterDialog(bConfirm)
	-- 城市的地图ID，每个城市有开副本的上限限制
	local nKinId, nMemberId = me.GetKinMember();	
	local cKin = KKin.GetKin(nKinId);
	local nRet = Kin:CheckSelfRight(nKinId, nMemberId, 2)
	local nRet2 = Kin:HaveFigure(nKinId, nMemberId, 3)
	local bIsOldPAction = EventManager.ExEvent.tbPlayerCallBack:IsOpen(me, 2);	-- 是否是老玩家在召回期间参见活动
	local nNpcServerCityId = KinGame2:GetSeverCity();	--npc所在server的城市map
	local tbOpt = 
	{
		--{"我想修改家族关卡的活动时间及地点", self.ChangeGameSetting, self, 0},
		{"Câu Hồn Ngọc", self.OnBuyCallBossItem, self, 1},
		{"Mua trang bị Danh vọng Gia tộc", self.OpenReputeShop, self},
		{"Nhận phần thưởng vượt ải", self.OnFinalAward, self},
		{"<color=yellow>Nhận phần thưởng vượt ải (mới)<color>", self.OnFinalAward_New, self},
		{"Nhận Túi tiền", self.GameExplain, self, 2},
		{"Mô tả hoạt động", self.GameExplain, self, 1};
		{"Kết thúc đối thoại"}
	}
	if HomeLand:GetMapIdByKinId(nKinId) <= 0 and me.nMapId >= DYN_MAP_ID_START then
		local szMsg = "    Xếp hạng gia tộc rời khỏi top 200, Lãnh địa gia tộc đã bị lấy lại!"
		local tbBackOpt = {};
		tbBackOpt[#tbBackOpt + 1] = {"Trở lại thành thị",Npc:GetClass("chefu").SelectMap,Npc:GetClass("chefu"),"city"};
		tbBackOpt[#tbBackOpt + 1] = {"Ta ở lại đây một chút"};
		Dialog:Say(szMsg,tbBackOpt);
		return 0;
	end
	if (0 == bIsOldPAction) then	-- 老玩家在召回期间参加活动可以不论任何身份都能参加
		if not cKin or nRet2 ~= 1 then
			Dialog:Say("Ngươi chưa phải là thành viên gia tộc chính thức, trở thành <color=red>Thành viên chính thức<color> hãy đến tìm ta.", unpack(tbOpt));
			return 0;
		end
	elseif (not cKin) then
		Dialog:Say("Ngươi chưa phải là thành viên gia tộc, vào gia tộc hãy đến tìm ta.", unpack(tbOpt));
		return 0;
	end
	-- 原有进入流程太乱，新流程搬出来，进行改变
	-- 如果有家园并且开放150级了，才能进行新流程
	if HomeLand:GetMapIdByKinId(nKinId) > 0 then
		self:OnEnterDialog_New(bConfirm);
		return 0;
	end
	if HomeLand:GetMapIdByKinId(nKinId) == me.nMapId and TimeFrame:GetState("OpenLevel150") ~= 1 then
		Dialog:Say("    石鼓书院，需要您所在的服务器开放150级等级上限后才能开启哦！若想开启神秘宝库副本，去各大城市里找我，我会带你们过去的！",unpack(tbOpt));
		return 0;
	end
	local tbData = Kin:GetKinData(nKinId);
	if tbData.nApplyKinGameMap and tbData.nApplyKinGameMap ~= nNpcServerCityId then
		local szCity = GetMapNameFormId(tbData.nApplyKinGameMap);
		local szMsg = string.format("Tộc trưởng của ngươi nói vào trong %s rất khó, đi đến cung điện ngầm bí ẩn, sau đó đến %s tìm ta!", szCity, szCity)
		Dialog:Say(szMsg, unpack(tbOpt));		
		return 0;
	end
	if tbData.nApplyKinGameMap == nNpcServerCityId then
		local tbGame = KinGame:GetGameObjByKinId(nKinId);
		if not tbGame then
			Dialog:Say("Đang chờ...");
			return;
		end
		if tbGame:IsStart() == 1 and tbGame:FindLogOutPlayer(me.nId) ~= 1 then
			Dialog:Say("Lối vào ải gia tộc đã đóng, ngươi không thể vào được nữa!", tbOpt);
			return 0;
		end
		local tbIsBagIn = {"Có, cho ta qua.",self.JoinGame, self } 
		local tbFind = me.FindItemInBags(unpack(self.QIANDAI_ITEM));
		if #tbFind < 1 then
			tbFind = me.FindItemInRepository(unpack(self.QIANDAI_ITEM));
			if #tbFind < 1 then
				tbIsBagIn = {"Có, cho ta qua.", self.GiveQianDai, self, 1};
			end
		end
		Dialog:Say("Sẵn sàng chưa? Bây giờ ta sẽ đưa ngươi đi.",
			{
				tbIsBagIn,
				unpack(tbOpt)
			})
		return 0;
	end
	local nTime = cKin.GetKinGameTime();
	local nDegree = cKin.GetKinGameDegree();
	if os.date("%W%w", nTime) == os.date("%W%w", GetTime()) then
		Dialog:Say("Ah? Không quay trở lại? Ngươi muốn đi không?",tbOpt);
		me.Msg("Hoạt động chỉ diễn ra 1 lần, hãy quay trở lại vào ngày mai.");
		return 0;
	end
	if os.date("%W", nTime) == os.date("%W", GetTime()) and nDegree >= KinGame.MAX_WEEK_DEGREE then
		Dialog:Say(string.format("   Tuần này đã vượt ải! Đi thường xuyên sẽ xảy ra tai nạn!\n   Một tuần được vào <color=red>%d<color> lần.", KinGame.MAX_WEEK_DEGREE), 
			tbOpt);
		me.Msg(string.format("Sự kiện này chỉ có thể được mở một tuần %d lần. Hãy trở lại vào tuần tới.", KinGame.MAX_WEEK_DEGREE));
		return 0;
	end
	if nRet == 1 and bConfirm ~= 1 then
		if self:GetCityGameNum(nNpcServerCityId) >= self.MAX_GAME then
			Dialog:Say("Hư ~! Ở đây tựa hồ có người ở nghe trộm! Chúng ta hoán một thành thị tái trò chuyện ba!", tbOpt);
			me.Msg("Cai thành thị đích hoạt động nơi sân dĩ mãn!");
			return 0;
		end
		Dialog:Say("   Gần đây ta phát hiện ra một cung điện bí ẩn dưới lòng đất! Đã có một cuộc chiến, chưa bao giờ thấy một cơ thể lớn như vậy, ta sợ và mọi người thậm chí không thể đi ra ngoài mà sống sót. Dường như có sức mạnh của gia tộc của ngươi, ngươi đi đến nó? Ta có thể đáp ứng.\n   Tuy nhiên, cần lưu ý là <color=green>có 6 cơ quan bên trong cần phải mở, sau đó mọi người có thể vào cung điện dưới lòng đất.<color>",
			{
				{"Mở Ải Gia tộc", self.OnEnterDialog, self, 1},
				unpack(tbOpt)
			});
		return 0;
	elseif nRet == 1 then
		local tbData_New = Kin:GetKinData(nKinId);
		if tbData_New and tbData_New.nApplyKinGameMap then
			Dialog:Say("Đã nâng cấp thành công!");
			return 0;
		end
		if me.CountFreeBagCell() < 1 then
			me.Msg("Hành trang đầy!");
			return 0;
		end
		local pItem = me.AddItemEx(unpack(self.OPEN_KEY_ITEM));
		if pItem then
			me.SetItemTimeout(pItem, self.KEY_ITME_TIME);
			pItem.Sync()
		end
		GCExcute{" KinGame:ApplyKinGame_GC", nKinId, nMemberId, nNpcServerCityId, me.nId};
		Dialog:Say("   Ta đưa chìa khóa cổng cho ngươi, lối vào cung điện ngầm sẽ được đóng lại sau 10 phút, bên ngoài của người của ngươi không thể đi vào. Ngươi có 10 phút để tập hợp thành viên, nhưng nếu tất cả đã có mặt ở đây, có thể sử dụng khóa để mở luôn.\n Sẵn sàng và sau đó tìm ta!");
		return 0;
	else
		Dialog:Say("   Gần đây ta phát hiện ra một cung điện bí ẩn dưới lòng đất! Đã có một cuộc chiến, chưa bao giờ thấy một cơ thể lớn như vậy, ta sợ và mọi người thậm chí không thể đi ra ngoài mà sống sót. Dường như có sức mạnh của gia tộc của ngươi, ngươi đi đến nó? Ta có thể đáp ứng.\n   <color=red>Tộc trưởng ngươi có nhìn ta<color>.", 
			tbOpt);
		return 0;
	end
end 

-- 详细说明
function KinGame:GameExplain(nType)
	if nType == 1 then
		Dialog:Say(string.format("   Hoạt động gia tộc, là thành viên chính thức mới được tham gia, do Tộc trưởng hoặc Tộc phó mở, có 10 phút vào phó bản, sau đó tự động bắt đầu và không vào được nữa.\n   Cần ít nhất 6 người tham gia, không đủ sẽ bị hủy bỏ. Độ khó và phần thưởng điều chỉnh theo số người, càng nhiều người phần thưởng càng cao.\n   <color=green>Chú ý: Mỗi tuần chỉ mở %d lần, 1 ngày 1 lần, thời gian hoạt động nhiều nhất là 2 giờ, bất luận thế nào sau 2 giờ tất cả người chơi sẽ được đưa về thành.<color>", KinGame.MAX_WEEK_DEGREE))
	elseif nType == 2 then
		Dialog:Say("Túi tiền đó à, trên đí có ký hiệu của ta, chứng minh sự tín nhiệm của ta với ngươi, không thấy ta sẽ cho lại. Hãy nhớ, khi tìm ta đổi bảo rương phải mang túi tiền trên người để bày tỏ thành ý!",
			{
				{"Mất túi tiền rồi, có thể cho lại?", self.GiveQianDai, self},
				{"Kết thúc đối thoại"}
			})
	end
end

-- 给予钱袋
function KinGame:GiveQianDai(bJoinGame)
	local tbFind1 = me.FindItemInBags(unpack(self.QIANDAI_ITEM));
	local tbFind2 = me.FindItemInRepository(unpack(self.QIANDAI_ITEM));
	if #tbFind1 > 0 or #tbFind2 > 0 then
		Dialog:Say("Không có mất gì đâu!");
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Túi tiền mà ngươi có, trong phó bản có nhiều tiền xu cổ, thu thập số lượng xu cổ nhất định sẽ nhận thưởng.\n   <color=red>Oh, hành trang của ngươi thật đầy đủ, không phù hợp ta sẽ cung cấp cho túi tiền trước tiên.<color>");
		return 0;
	end
	me.AddItem(unpack(self.QIANDAI_ITEM));
	local tbOpt = {{"Tốt!"}};
	if bJoinGame == 1 then
		tbOpt = {"Tốt!", self.JoinGame, self};
	end
	Dialog:Say("Túi tiền mà ngươi có, trong phó bản có nhiều tiền xu cổ, thu thập số lượng xu cổ nhất định sẽ nhận thưởng.", tbOpt);
end

function KinGame:OnFinalAward()
		local tbFind1 = me.FindItemInBags(unpack(self.QIANDAI_ITEM));
		if #tbFind1 < 1 then
			Dialog:Say("Trên người của ngươi không có túi tiền! Cầm túi tiền và mang đến gặp ta.");
			return 0;
		end
		local szMsg = "Ta đã sai lầm, ngươi thực sự rất mạnh mẽ! Ngươi thu thập được rất nhiều tiền xu cổ, phải không? Ta sẽ đổi kho báu của ta để lấy nó!";
		local tbOpt = 
		{
			{"Dùng 100 tiền xu cổ để đổi",self.GiveFinalAward, self},
			{"Kết thúc đối thoại"},
		}
		Dialog:Say(szMsg, tbOpt);
end

function KinGame:GiveFinalAward()
	local pPlayer = me;
	local nCount = pPlayer.GetTask(KinGame.TASK_GROUP_ID, KinGame.TASK_BAG_ID);
	if nCount < 100 then
		Dialog:Say("Ta muốn 100 Đồng tiền cổ, có đủ rồi hãy đưa ta. Ta đang rất bận.");
		return 0;
	end
	
	local nFreeCount, tbExecute = SpecialEvent.ExtendAward:DoCheck("KinGame", pPlayer, nCount, 1);
	if me.CountFreeBagCell() < 1 + nFreeCount then
		me.Msg("Hành trang không đủ chỗ trống.");
		return 0;
	end

	pPlayer.SetTask(KinGame.TASK_GROUP_ID, KinGame.TASK_BAG_ID, nCount - 100);
	local nAddExp = self.LevelBaseExp[pPlayer.nLevel] * 30 * 2;
	pPlayer.AddExp(nAddExp);
	pPlayer.AddItem(unpack(self.ZHENCHANGBAOXIANG_ITEM))
	
	SpecialEvent.ExtendAward:DoExecute(tbExecute);
	-- 江湖威望改为击杀boss时获取，by zhangjinpin@kingsoft
	--pPlayer.AddKinReputeEntry(5, "kingame");
	Dialog:Say("Công dụng của Đồng tiền cổ, đây là phần thưởng của ngươi, hãy nhận nó.");
end

function KinGame:ShowInfo(nRoomId, nMapId)
	local tbGame = self:GetGameObjByMapId(nMapId);
	Lib:ShowTB1(tbGame.tbRoom[nRoomId].tbNextLock);
end

function KinGame:UnLock(nRoomId, nMapId)
	local tbGame = self:GetGameObjByMapId(nMapId);
	tbGame.tbRoom[nRoomId]:UnLock();
end


function KinGame:OpenReputeShop()
	local nFaction = me.nFaction;
	if nFaction <= 0 or me.GetCamp() == 0 then
		Dialog:Say("Nhân vật chữ trắng không thể mua trang bị Danh Vọng Gia Tộc.");
		return 0;
	end
	me.OpenShop(self.REPUTE_SHOP_ID[nFaction], 1, 100, me.nSeries) --使用声望购买
end

function KinGame:OnBuyCallBossItem(nStep, nItemLevel, szItemLevel)
	local nKinId, nMemberId = me.GetKinMember()
	local nRet, cKin = Kin:CheckSelfRight(nKinId, nMemberId, 2);
	local szInfo = "  Cầu Hồn Ngọc là bảo vật, dùng nó trong ải gia tộc, kêu gọi võ lâm cao thủ, đánh bại hắn mới được bảo vật.\n  <color=green>Cầu Hồn Ngọc (sơ) gọi được cao thủ võ lâm cấp 55\n  Cầu Hồn Ngọc (trung) gọi được cao thủ võ lâm cấp 75<color>\n  Mua Cầu Hồn Ngọc, phải tốn bạc cổ gia tộc. 24:00 mỗi tuần, tặng bạc cổ, căn cứ vào tổng điểm uy danh gia tộc. 1000 điểm nhận được 100, 2000 điểm nhận được 150, 4000 điểm nhận được 200.\n"
	local tbOpt = {{"Kết thúc đối thoại"}};
	if cKin and nStep == 1 then
		szInfo = szInfo..string.format("Số bạc cổ gia tộc hiện có:\n <color=red>%d/%d<color>", cKin.GetKinGuYinBi(), Kin.MAX_GU_YIN_BI);
		if nRet == 1 then
			tbOpt = {
				{string.format("Mua Cầu Hồn Ngọc sơ(%d Bạc cổ gia tộc)", self.GOU_HUN_YU_COST[1]), self.OnBuyCallBossItem, self, 2, 1, "Sơ"},
				{string.format("Mua Cầu Hồn Ngọc trung(%d Bạc cổ gia tộc)", self.GOU_HUN_YU_COST[2]), self.OnBuyCallBossItem, self, 2, 2, "Trung"},
				{"Kết thúc đối thoại"}
			}
		else
			szInfo = szInfo.."\n  Chỉ Tộc trưởng hoặc Tộc phó mới được phép mua. Hãy họi họ đến chỗ ta.";
		end
	elseif nRet == 1 and nStep >= 2 then
		if cKin.GetKinGuYinBi() < self.GOU_HUN_YU_COST[nItemLevel] then
			szInfo = "Bạc cổ gia tộc không đủ, lần sau hãy đến.";
			nRet = 0;
		end
		if me.CountFreeBagCell() <= 0 then
			szInfo = "Hành trang không đủ ô trống!";
			nRet = 0;
		end
		if nStep == 2 and nRet == 1 then
			szInfo = string.format("Ngươi muốn mua 1 Cầu Hồn Ngọc %s, cần %d Bạc cổ gia tộc, ngươi có chắc chắn?", szItemLevel, self.GOU_HUN_YU_COST[nItemLevel])
			tbOpt = {
				{"Xác định mua", self.OnBuyCallBossItem, self, 3, nItemLevel, szItemLevel},
				{"Để ta suy nghĩ lại"},
			}
		elseif nStep == 3 and nRet == 1 then
			me.AddWaitGetItemNum(1);		-- 角色锁定
			return GCExcute{"KinGame:BuyCallBossItem_GC", nKinId, nMemberId, nItemLevel};
		end
	end
	Dialog:Say(szInfo,tbOpt);
end

function KinGame:ChangeGameSetting(bConfirm)
	
	local szInfo = "Ta không có nghe thác ba? Nếu là như thế này, như vậy thỉnh nâm chuẩn bị cho tốt 100000 lưỡng ngân lượng, để ta lai vi nâm an bài tương quan chuyện hạng.";
	local tbOpt = {
					{"Ta chuẩn bị cho tốt liễu 100000 lưỡng ngân lượng. Còn lại chuyện tựu phiền phức nâm liễu.", self.ChangeGameSetting, self, 1},
					{"Để ta suy nghĩ lại"}
				  }
				  
	if bConfirm == 0 then 
		Dialog:Say(szInfo,tbOpt);
		return 0;
	end
	
	-- 弹出修改对话框
	local nKinId, nMemberId = me.GetKinMember();	
	local cKin = KKin.GetKin(nKinId);
	local nOrderTime1 = 0;
	local nOrderTime2 = 0;
	local nOrderTime3 = 0;
	local nOrderMapId = 0;
	cKin.SetKinGameOrderTime1(nOrderTime1);
	cKin.SetKinGameOrderTime2(nOrderTime2);
	cKin.SetKinGameOrderTime3(nOrderTime3);
	cKin.SetKinGameOrderMapId(nOrderMapId);
	
	KinGame:ApplyKinGame(nKinId, cKin.GetKinGameOrderMapId());
end



function KinGame:GameExplain_New(nType)
	if nType == 1 then
		local szMsg = "你想了解哪个活动？";
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"石鼓书院",self.GameExplain_New,self,3};
		tbOpt[#tbOpt + 1] = {"神秘宝库",self.GameExplain,self,1};
		Dialog:Say(szMsg,tbOpt);
	elseif nType == 2 then
		Dialog:Say("你是说那个古金币袋子啊，这种钱袋是家族高级关卡专用(石鼓书院)钱袋，给你这个是我信任你的证明，如果你搞不见了我可以再给你一个。不过要记得，想找我换石鼓残卷的话就把钱袋带在身上以示诚意！",
			{
				{"我上次把钱袋搞丢了，你能再给我一个吗？", self.GiveQianXiang, self},
				{"Kết thúc đối thoại"}
			})
	elseif nType == 3 then
		Dialog:Say(string.format("   本关卡为家族高级关卡，必须为正式家族成员才能参加，并且需要家族的族长或副族长开启，开启后你有10分钟时间进入副本，10分种后活动自动开始，这时将不能再进入。本关卡最少参加人数为8人，最多为40人。\n   石鼓书院进入后，在大门处开启时，可进行关卡难度的选择，难度越高，获得奖励将会越高。\n   <color=green>注意：本关卡只能从家族领地的马穿山进入，每个星期能开启%d次，但一天只能开启1次，活动最大时间为2小时，就是说无论是否完成，2小时后所有玩家将会被传送回城市。<color>", KinGame.MAX_WEEK_DEGREE))	
	end
end



function KinGame:OnEnterDialog_New(bConfirm)
	-- 城市的地图ID，每个城市有开副本的上限限制
	local nKinId, nMemberId = me.GetKinMember();	
	local cKin = KKin.GetKin(nKinId);
	local nRet = Kin:CheckSelfRight(nKinId, nMemberId, 2)
	local nRet2 = Kin:HaveFigure(nKinId, nMemberId, 3)
	local bIsOldPAction = EventManager.ExEvent.tbPlayerCallBack:IsOpen(me, 2);	-- 是否是老玩家在召回期间参见活动
	local nNpcServerCityId = KinGame2:GetSeverCity();
	local tbOpt = 
	{
		--{"我想修改家族关卡的活动时间及地点", self.ChangeGameSetting, self, 0},
		{"Câu Hồn Ngọc", self.OnBuyCallBossItem, self, 1},
		{"Mua trang bị Danh vọng Gia tộc", self.OpenReputeShop, self},
		{"Nhận phần thưởng vượt ải", self.OnFinalAward, self},
		{"<color=yellow>Nhận phần thưởng vượt ải (mới)<color>", self.OnFinalAward_New, self},
		{"Nhận Túi tiền", self.GameExplain, self, 2},
		{"<color=yellow>Nhận túi tiền (mới)<color>", self.GameExplain_New, self, 2},
		{"Thuyết minh hoạt động", self.GameExplain_New, self, 1};
		{"Kết thúc đối thoại"}
	}
	if (0 == bIsOldPAction) then	-- 老玩家在召回期间参加活动可以不论任何身份都能参加
		if not cKin or nRet2 ~= 1 then
			Dialog:Say("Ngươi chưa phải là thành viên gia tộc chính thức, trở thành <color=red>Thành viên chính thức<color> hãy đến tìm ta.", unpack(tbOpt));
			return 0;
		end
	elseif (not cKin) then
		Dialog:Say("Ngươi chưa phải là thành viên gia tộc, vào gia tộc hãy đến tìm ta.", unpack(tbOpt));
		return 0;
	end
	
	local tbData = Kin:GetKinData(nKinId);
	--新家族关卡的判断
	if tbData.nIsNewGame and tbData.nIsNewGame == 1 then
		self:EnterNewGame(tbOpt);	
		return 0;
	end
	if tbData.nApplyKinGameMap and tbData.nApplyKinGameMap ~= nNpcServerCityId then
		local szCity = GetMapNameFormId(tbData.nApplyKinGameMap);
		local szMsg = string.format("Tộc trưởng của ngươi nói vào trong %s rất khó, đi đến cung điện ngầm bí ẩn, sau đó đến %s tìm ta!", szCity, szCity)
		Dialog:Say(szMsg, unpack(tbOpt));		
		return 0;
	end
	if tbData.nApplyKinGameMap and HomeLand:GetMapIdByKinId(nKinId) == me.nMapId then
		local szCity = GetMapNameFormId(tbData.nApplyKinGameMap);
		local szMsg = string.format("Lối vào Thư Viện Thạch Cổ đã mở, hãy đến <color=yellow>“%s”<color> để tham gia!",szCity);
		Dialog:Say(szMsg, unpack(tbOpt));		
		return 0;
	end
	if tbData.nApplyKinGameMap == nNpcServerCityId then
		local tbGame = KinGame:GetGameObjByKinId(nKinId);
		if not tbGame then
			Dialog:Say("Đang chờ...");
			return;
		end
		if tbGame:IsStart() == 1 and tbGame:FindLogOutPlayer(me.nId) ~= 1 then
			Dialog:Say("Lối vào ải gia tộc đã đóng, ngươi không thể vào được nữa!", tbOpt);
			return 0;
		end
		local tbIsBagIn = {"<color=yellow>Đưa ta đến Thư Viện Thạch Cổ<color>",self.JoinGame, self } 
		local tbFind = me.FindItemInBags(unpack(self.QIANDAI_ITEM));
		if #tbFind < 1 then
			tbFind = me.FindItemInRepository(unpack(self.QIANDAI_ITEM));
			if #tbFind < 1 then
				tbIsBagIn = {"Mau đưa ta chìa khóa", self.GiveQianDai, self, 1};
			end
		end
		Dialog:Say("Chuẩn bị xong chưa? Bây giờ ta sẽ đưa ngươi đến thư viện thần bí đó",
			{
				tbIsBagIn,
				unpack(tbOpt)
			})
		return 0;
	end
	local nTime = cKin.GetKinGameTime();
	local nDegree = cKin.GetKinGameDegree();
	if os.date("%W%w", nTime) == os.date("%W%w", GetTime()) then
		Dialog:Say("Sao? Ngươi vừa đến đây rồi còn gì?",tbOpt);
		me.Msg("Hoạt động này mỗi ngày chỉ có thể tham gia 1 lần");
		return 0;
	end
	if os.date("%W", nTime) == os.date("%W", GetTime()) and nDegree >= KinGame.MAX_WEEK_DEGREE then
		Dialog:Say(string.format("   这个星期搞到了不少好东西吧！不过行有行规，探险这种危险的事情，去太频繁的话会出事的！\n   一个星期去了<color=red>%d次<color>就不敢再去了。", KinGame.MAX_WEEK_DEGREE), 
			tbOpt);
		me.Msg(string.format("该活动一周内只能开启%d次,请下周再来吧。", KinGame.MAX_WEEK_DEGREE));
		return 0;
	end
	if nRet == 1 and bConfirm ~= 1 then
		local nGameNum = self:GetCityGameNum(nNpcServerCityId) + KinGame2:GetCityGameNum(nNpcServerCityId);
		if nGameNum >= self.MAX_GAME then	
			Dialog:Say("嘘~！这里似乎有人在偷听！我们换个城市再聊吧！", tbOpt);
			me.Msg("这里的活动场地已满！");
			return 0;
		end
		Dialog:Say("   Gần đây ta phát hiện được 1 thư viện thần bí, nghe nói các nho sinh ở đây đều theo lý học, võ công bất phàm, chẳng lẽ trong thư viện có bí mật gì ư?\n   Nhưng điều quan trọng là <color=green>cần có đủ 8 người và phải đi vào từ Lãnh địa Gia tộc, nếu không đủ người thì không thể vào Thư viện thần bí này.<color>",
			{
				{"Được! Đưa ta đi mau", self.OnEnterDialog_New, self, 1},
				unpack(tbOpt)
			});
		return 0;
	elseif nRet == 1 then
		local szMsg = "   Đây là chìa khóa cổng thành, phó bản này chỉ cần có người bước vào thì sẽ đóng sau 10 phút, người bên ngoài sẽ không thể vào. Nghĩa là trong 10 phút phải tập hợp đủ người, nếu đã đủ có thể dùng chìa khóa ta đưa để mở cơ quan.\n    Chuẩn bị xong hãy đến tìm ta!"
		local tbOptSelect = {};
		if me.nMapId ~= HomeLand:GetMapIdByKinId(nKinId) then
			tbOptSelect[#tbOptSelect + 1] = {"Ải gia tộc",self.SelectGame,self,0,nNpcServerCityId};
		end
		tbOptSelect[#tbOptSelect + 1] = {"Thư Viện Thạch Cổ",self.SelectGame,self,1,nNpcServerCityId};
		tbOptSelect[#tbOptSelect + 1] = {"Để ta suy nghĩ"};
		Dialog:Say(szMsg,tbOptSelect);
		return 0;
	else
		Dialog:Say("   Gần đây ta phát hiện được 1 thư viện thần bí, nghe nói các nho sinh ở đây đều theo lý học, võ công bất phàm, chẳng lẽ trong thư viện có bí mật gì ư?\n   Tuy nhiên, cần lưu ý rằng phải đến <color=green>Lãnh địa Gia tộc<color> để đi vào.<color>\n   <color=red>Hãy gọi Tộc trưởng đến gặp ta<color>", 
			tbOpt);
		return 0;
	end
end

--选择副本
function KinGame:SelectGame(bIsNew,nMapId)
	local nKinId,nMemberId = me.GetKinMember();
	local tbData = Kin:GetKinData(nKinId);
	if tbData and tbData.nApplyKinGameMap then
		Dialog:Say("你们家族关卡已经申请成功了！");
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		me.Msg("Hành trang không đủ chỗ trống!");
		return 0;
	end
	if not bIsNew or bIsNew == 0 then
		GCExcute{"KinGame:ApplyKinGame_GC", nKinId, nMemberId, nMapId, me.nId};
		local pItem = me.AddItemEx(unpack(self.OPEN_KEY_ITEM));
		if pItem then
			me.SetItemTimeout(pItem, self.KEY_ITME_TIME);
			pItem.Sync();
		end
		return 0;
	elseif bIsNew == 1  then
		if me.nMapId == HomeLand:GetMapIdByKinId(nKinId) then
			GCExcute{"KinGame2:ApplyKinGame_GC", nKinId, nMemberId, nMapId, me.nId};
			local pItem = me.AddItemEx(unpack(self.OPEN_KEY_ITEM));
			if pItem then
				me.SetItemTimeout(pItem, self.KEY_ITME_TIME);
				pItem.Sync();
			end
			return 0;
		else
			local szMsg = "Để đến được Thư Viện Thạch Cổ cần thông qua <color=green>Lãnh địa Gia Tộc<color>. Ngươi có muốn ta đưa đến đó không?";
			local tbOpt = {};
			tbOpt[#tbOpt + 1] = {"Hãy đưa ta đi",HomeLand.OnEnterDialog,HomeLand};
			tbOpt[#tbOpt + 1] = {"Để ta nghĩ lại!"}
			Dialog:Say(szMsg,tbOpt);
			return 0;
		end
	else
		return 0;
	end
end

--进入新家族关卡的选项
function KinGame:EnterNewGame(tbOpt)
	if not tbOpt then
		tbOpt = {};
	end
	local nKinId, nMemberId = me.GetKinMember();	
	local cKin = KKin.GetKin(nKinId);
	local nNpcServerCityId = KinGame2:GetSeverCity();
	local tbData = Kin:GetKinData(nKinId);
	--if tbData.nApplyKinGameMap and HomeLand:GetMapIdByKinId(nKinId) ~= me.nMapId then --tbData.nApplyKinGameMap ~= nNpcServerCityId and 
	if tbData.nApplyKinGameMap and HomeLand:GetMapIdByKinId(nKinId) ~= me.nMapId then
		local szMsg = string.format("   Để đến được Thư Viện Thạch Cổ cần thông qua <color=green>Lãnh địa Gia Tộc<color>. Ta sẽ đợi ngươi ở đó!");
		Dialog:Say(szMsg, unpack(tbOpt));		
		return 0;
	end
	if tbData.nApplyKinGameMap == nNpcServerCityId and HomeLand:GetMapIdByKinId(nKinId) == me.nMapId then
	--if tbData.nApplyKinGameMap == nNpcServerCityId then
		local tbGame = KinGame2:GetGameObjByKinId(nKinId);
		if not tbGame then
			Dialog:Say("Đang đợi...");
			return;
		end
		if me.nLevel < KinGame2.MIN_LEVEL then	--小于80级不能进入
			Dialog:Say("Đẳng cấp nhỏ hơn 80, không thể vào!", tbOpt);
			return 0;
		end
		if tbGame:IsStart() == 1 and tbGame:FindLogOutPlayer(me.nId) ~= 1 then
			Dialog:Say("Cơ quan đã mở, không cách nào tiến vào được!", tbOpt);
			return 0;
		end
		if tbGame:GetPlayerCount() >= KinGame2.MAX_PLAYER then
			Dialog:Say(string.format("Số lượng thành viên đã đạt %s, không thể vào thêm!", KinGame2.MAX_PLAYER), tbOpt);
			return 0;
		end
		local tbIsBagIn = {"<color=yellow>Đưa ta đến Thư Viện Thạch Cổ<color>",KinGame2.JoinGame, KinGame2} 
		local tbFind = me.FindItemInBags(unpack(KinGame2.QIANXIANG_ITEM));
		if #tbFind < 1 then
			tbFind = me.FindItemInRepository(unpack(KinGame2.QIANXIANG_ITEM));
			if #tbFind < 1 then
				tbIsBagIn = {"<color=yellow>Đưa ta đến Thư Viện Thạch Cổ<color>", self.GiveQianXiang, self, 1};
			end
		end
		Dialog:Say("Đã chuẩn bị xong chưa? Bây giờ ta sẽ đưa ngươi đến thư viện thần bí đó.",
			{
				tbIsBagIn,
				unpack(tbOpt)
			})
		return 0;
	end
end


--给予钱箱
function KinGame:GiveQianXiang(bJoinGame)
	local tbFind1 = me.FindItemInBags(unpack(KinGame2.QIANXIANG_ITEM));
	local tbFind2 = me.FindItemInRepository(unpack(KinGame2.QIANXIANG_ITEM));
	if #tbFind1 > 0 or #tbFind2 > 0 then
		Dialog:Say("Ngươi không có túi tiền");
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô trống!");
		return 0;
	end
	me.AddItem(unpack(KinGame2.QIANXIANG_ITEM));
	local tbOpt = {{"Được!"}};
	if bJoinGame == 1 then
		tbOpt = {"Được!", KinGame2.JoinGame, KinGame2};
	end
	Dialog:Say("Túi tiền rất có giá trị, ngươi có thể thu thập tiền cổ vào bên trong. Đừng để mất nó!", tbOpt);
end

--新的金币兑换
function KinGame:OnFinalAward_New()
		local tbFind1 = me.FindItemInBags(unpack(KinGame2.QIANXIANG_ITEM));
		if #tbFind1 < 1 then
			Dialog:Say("Ngươi không có túi tiền");
			return 0;
		end
		local szMsg = "Đây là Mảnh Thạch Cổ, những quyển sách tưởng như cũ kỹ này lại chứa vô số bí mật lớn.";
		local tbOpt = 
		{
			{"Dùng 100 tiền cổ đổi Mảnh Thạch Cổ",self.GiveFinalAward_New, self},
			{"Kết thúc đối thoại"},
		}
		Dialog:Say(szMsg, tbOpt);
end

--新的金币兑换
function KinGame:GiveFinalAward_New()
	local pPlayer = me;
	local nCount = pPlayer.GetTask(KinGame2.TASK_GROUP_ID, KinGame2.TASK_GOLD_COIN);
	if nCount < 100 then
		Dialog:Say("Ta cần 100 đồng tiền cổ. Khi nào thu thập đủ hãy đến tìm ta.");
		return 0;
	end
	
	local nFreeCount, tbExecute = SpecialEvent.ExtendAward:DoCheck("KinGame", pPlayer, nCount, 2);
	if me.CountFreeBagCell() < 1 + nFreeCount then
		me.Msg("Hành trang không đủ chỗ trống!");
		return 0;
	end
	
	pPlayer.SetTask(KinGame2.TASK_GROUP_ID, KinGame2.TASK_GOLD_COIN, nCount - 100);
	local nAddExp = self.LevelBaseExp[pPlayer.nLevel] * 30 * 2;
	pPlayer.AddExp(nAddExp);
	pPlayer.AddItem(unpack(KinGame2.KIN_XUNZHANG));
	
	SpecialEvent.ExtendAward:DoExecute(tbExecute);
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"Quay lại",self.OnFinalAward_New,self};
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};
	Dialog:Say("Ngươi vừa nhận được phẩn thưởng giá trị!",tbOpt);
end
