-- 文件名　：kingame_yaoshang.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-01 21:07:50
-- 描述：家族关卡药商


local tbNpc = Npc:GetClass("kingame_yaoshang");

function tbNpc:OnDialog()
	local szMsg = "前方危险，我可以给你提供免费药的机会，好好把握哦！";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"<color=gold>[绑定银两]<color>我要买药",self.OnBuyMedicine,self,1};
	tbOpt[#tbOpt + 1] = {"我要买药",self.OnBuyMedicine,self,0};
	tbOpt[#tbOpt + 1] = {"<color=gold>[绑定银两]<color>我要买菜",self.OnBuyCai,self,1};
	tbOpt[#tbOpt + 1] = {"我要买菜",self.OnBuyCai,self,0};
	tbOpt[#tbOpt + 1] = {"领取今日免费药品", SpecialEvent.tbMedicine_2012.GetMedicine, SpecialEvent.tbMedicine_2012};
	tbOpt[#tbOpt + 1] = {"谢谢，我暂时不需要。"};
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:OnBuyMedicine(bBind)
	if bBind and bBind == 1 then
		me.OpenShop(14,7);
	else
		me.OpenShop(14,1);
	end
end

function tbNpc:OnBuyCai(bBind)
	if bBind and bBind == 1 then
		me.OpenShop(21,7);
	else
		me.OpenShop(21,1);
	end
end

function tbNpc:CheckCanGet()
	local nLastTime = me.GetTask(KinGame2.TASK_GROUP_ID,KinGame2.TASK_GET_MEDICINE_TIME);
	local nTime = tonumber(os.date("%Y%m%d", GetTime()));
	if nLastTime == nTime then
		return 0;
	else
		return 1;
	end
end

function tbNpc:OnGetKinMedicine()
	local nRet = self:CheckCanGet();
	if nRet == 0 then
		Dialog:Say("此次关卡您已经领取过一次免费的药啦！");
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		me.Msg("Hành trang không đủ chỗ trống!");
		return 0;
	end
	local szMsg = "我这里免费给你提供3种药，每天只能领取一次哦!";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"领取家族回血丹",self.GetKinMedicine,self,1}
	tbOpt[#tbOpt + 1] = {"领取家族回内丹",self.GetKinMedicine,self,2}
	tbOpt[#tbOpt + 1] = {"领取家族乾坤造化丸",self.GetKinMedicine,self,3}
	tbOpt[#tbOpt + 1] = {"谢谢，我暂时不需要。"};
	Dialog:Say(szMsg,tbOpt);
end


function tbNpc:GetKinMedicine(nType)
	local nLevel = me.nLevel;
	if nLevel >= 60 and nLevel < 90 then
		nLevel = 60;
	elseif nLevel >= 90 and nLevel < 120  then
		nLevel = 90;
	elseif nLevel >= 120 then
		nLevel = 120;
	else
		Dialog:Say("你的等级还未达到领取免费药的等级!");
		return 0;
	end
	if not KinGame2.KIN_MEDICINE[nLevel] or not KinGame2.KIN_MEDICINE[nLevel][nType] then
		return 0;
	end
	local pItem = me.AddItem(unpack(KinGame2.KIN_MEDICINE[nLevel][nType]));
	if pItem then
		me.SetItemTimeout(pItem, KinGame2.KIN_MEDICINE_TIME,0);
		pItem.Sync()
	end
	local nTime = tonumber(os.date("%Y%m%d", GetTime()));
	me.SetTask(KinGame2.TASK_GROUP_ID,KinGame2.TASK_GET_MEDICINE_TIME,nTime);
end