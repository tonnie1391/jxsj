-- 文件名　：kingame_jieyinren.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-04 21:52:50
-- 描述：


local tbNpc = Npc:GetClass("kingame_jieyinren");

function tbNpc:OnDialog()
	local szMsg = "在我这里，可以告诉你一些关于石鼓书院的秘密！有了我的指引，相信你们的探险会顺利一些！";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"书院背景",self.Description,self,1};
	tbOpt[#tbOpt + 1] = {"难度介绍",self.Description,self,2};
	tbOpt[#tbOpt + 1] = {"奖励介绍",self.Description,self,3};
	tbOpt[#tbOpt + 1] = {"Ta hiểu rồi"};
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:Description(nType)
	if nType == 1 then
		local szMsg = string.format("　　南宋庆元元年，朝廷发动了一场抨击“理学”的运动，被斥为“伪学”，朱熹被斥为“伪师”。\n　　尊崇理学的文人及部分长歌门弟子对朝廷的决定不服，这帮文弱书生受到金国内奸鼓动，在奸贼的谋划之下占领了石鼓书院，企图以一己之力挽回理学地位，并推翻朝廷，建立一个理想中的社会。然而时至今日，他们已不是当年那些一心为国为民，崇尚理学的文弱书生，他们的思想和灵魂几近扭曲。到底这千年学府里还有多少不为人知的秘密。还石鼓书院一片碧绿青葱；一抹纯净天空；一片朗朗书声。");
		Dialog:Say(szMsg);
	elseif nType == 2 then
		local szMsg = string.format("    石鼓书院最低8人，最高40人可以进入探险。每个家族可以挑战前3个星级的难度。当3星级难度的石鼓书院你们过了4关或者以上则本星级难度通关，下一次你们便可以挑战更高一级难度的石鼓书院了。选择的难度越高，奖励越丰厚，当然我还是奉劝大家量力而行，如果某一关你们没在规定时间内完成，那本关的奖励可是拿不到的哦！");
		Dialog:Say(szMsg);
	elseif nType == 3 then
		local szMsg = string.format("    侠客们所选择的关卡难度星级越高，所获得的家族古金币也就越多，当然前提是必须通过此关卡才能获得此关卡的古金币。古金币可以在马穿山处兑换石鼓残卷。石鼓残卷可开出<color=green>高级玄晶、家族令牌、家族高级勋章以及金刚矿石。<color>");
		Dialog:Say(szMsg);
	end
end

