-- 文件名　：kingame_wuyoushusheng.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-29 22:39:26
-- 描述：无忧书生


local tbNpc = Npc:GetClass("kingame_wuyoushusheng");

-- 血量触发
function tbNpc:OnLifePercentReduceHere(nLifePercent)
	local pNpc = him;
	local szMsg = "";
	if nLifePercent == 98 then
		szMsg = "我不怪我的学生，他们只是一时糊涂，请帮助我！";
		pNpc.SendChat(szMsg);
	elseif nLifePercent == 90 then
		szMsg = "我不怪我的学生，他们只是一时糊涂，请帮助我！";
		pNpc.SendChat(szMsg);
	elseif nLifePercent == 80  then
		szMsg = "我受到了攻击，没关系，我一定能活着走出这里！";
		pNpc.SendChat(szMsg);
	elseif nLifePercent == 70  then
		szMsg = "我受到了攻击，没关系，我一定能活着走出这里！";
		pNpc.SendChat(szMsg);
	elseif nLifePercent == 60  then
		szMsg = "我流血了，不用在意，我还能坚持一会儿！";
		pNpc.SendChat(szMsg);
	elseif nLifePercent == 50  then
		szMsg = "我流血了，不用在意，我还能坚持一会儿！";
		pNpc.SendChat(szMsg);
	elseif nLifePercent == 40  then
		szMsg = "心中很疼，细作们在利用可怜的书生啊！";
		pNpc.SendChat(szMsg);
	elseif nLifePercent == 30  then
		szMsg = "心中很疼，细作们在利用可怜的书生啊！";
		pNpc.SendChat(szMsg);
	elseif nLifePercent == 20  then
		szMsg = "请再多给我一些……时间…… ";
		pNpc.SendChat(szMsg);
	elseif nLifePercent == 10  then
		szMsg = "人间五十年 如梦又似幻，这是宿命吧！";
		pNpc.SendChat(szMsg);
	end
end
