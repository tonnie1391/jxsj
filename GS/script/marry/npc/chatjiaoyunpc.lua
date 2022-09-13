-- 文件名　：chatjiaoyunpc.lua
-- 创建者　：furuilei
-- 创建时间：2010-01-13 10:48:49
-- 功能描述：结婚相关npc（自动发送教育信息的教育npc）

Marry.tbJiaoyuNpc = Marry.tbJiaoyuNpc or {};
local tbNpc = Marry.tbJiaoyuNpc;

--===============================================================

tbNpc.MSG_STAY_TIME = 5;	-- 消息停留时间

-- npc的刷出坐标{[npcid] = {{坐标1}, {坐标2}, ...}
tbNpc.tbNpcPos = {
	[6529] = {{498, 1625, 3246}, {499, 1553, 3108},{500, 1728, 3119}, {575, 1547, 3197},},
	[6530] = {{498, 1730, 3076}, {499, 1603, 3062},{500, 1723, 3187}, {575, 1614, 3224},},
	[6531] = {{498, 1824, 3183}, {499, 1657, 3035},{500, 1675, 3203}, {575, 1534, 3322},},
	[6532] = {{498, 1749, 3315}, {499, 1675, 3182},{500, 1651, 3052}, {575, 1625, 3302},},
	};

-- npc的说话内容{[npcid] = {[1] = "大家好，", [2] = "我来了",}, ...}
tbNpc.tbChatMsg = {
	[6529] = {
			[1] = "每个人都有一段悲伤，",
			[2] = "想隐藏，却在生长。",
			[3] = "在对的时间遇见错的人，是遗憾；",
			[4] = "在错的时间遇见对的人，是无奈。",
			[5] = "一分钟可以遇见一个人；",
			[6] = "一个小时可以喜欢上一个人；",
			[7] = "一秒可以记住上一个人，",
			[8] = "而忘记她，可能需要我一生的时间。",
			},
	[6530] = {
			[1] = "我从来不知道自己如此的软弱，",
			[2] = "这一刻才懂，",
			[3] = "那个你幻想中的幸福场景，",
			[4] = "像一个我永远都到达不了的梦境。",
			[5] = "我忘记了哪年哪月的哪一天，",
			[6] = "我在哪面墙上刻下了一张脸，",
			[7] = "一张微笑着、忧伤着、凝望着我的脸。",
			[8] = "我们微笑着说我们停留在时光的原处，",
			[9] = "其实早已被洪流无声地卷走了。",
			},	
	[6531] = {
			[1] = "木头对火说：“抱我。”",
			[2] = "火拥抱了木头，",
			[3] = "木头微笑着化为灰烬。",
			[4] = "火哭了，",
			[5] = "泪水熄灭了自己",
			[6] = "当木头遇上烈火，注定会被烧伤。",
			[7] = "人的寂寞，",
			[8] = "有时候很难用语言表达，",
			[9] = "而我的世界是寂静无声的，",
			[10] = "我会惧怕孤独吗？",
			[11] = "我只是偶尔会感觉寂寞。",
			},
	[6532] = {
			[1] = "我的快乐都是微小的事情，",
			[2] = "任何一件事情，",
			[3] = "只要心甘情愿，",
			[4] = "总是能够变得简单。",
			[5] = "我想有些事情是可以遗忘的，",
			[6] = "有些事情是可以纪念的，",
			[7] = "有些事情能够心甘情愿，",
			[8] = "有些事情一直无能为力。",
			[9] = "我想你，",
			[10] = "这是我的劫难，",
			[11] = "依然，始终，永远。",
			},
	};

--===============================================================

function tbNpc:StartChat()
	for nNpcTemplateId, tbPosInfo in pairs(self.tbNpcPos) do
		for _, tbPos in pairs(tbPosInfo) do
			local pNpc = KNpc.Add2(nNpcTemplateId, 1, -1, unpack(tbPos));
			if (pNpc and self.tbChatMsg[nNpcTemplateId]) then
				local tbMsg = self.tbChatMsg[nNpcTemplateId];
				local tbNpcData = pNpc.GetTempTable("Marry") or {};
				tbNpcData.nJiaoyuMsgIndex = 1;
				if (#tbMsg >= 1) then
					Timer:Register(self.MSG_STAY_TIME * Env.GAME_FPS, self.SendMsg, self, pNpc.dwId, tbMsg);
				end
			end
		end
	end
end

function tbNpc:SendMsg(dwId, tbChatMsg)
	local pNpc = KNpc.GetById(dwId);
	if (not pNpc) then
		return 0;
	end
	local tbNpcData = pNpc.GetTempTable("Marry") or {};
	local nMsgIndex = tbNpcData.nJiaoyuMsgIndex or 1;
	if (nMsgIndex >= #tbChatMsg) then
		nMsgIndex = 1;
	end
	
	pNpc.SendChat(tbChatMsg[nMsgIndex]);
	
	tbNpcData.nJiaoyuMsgIndex = nMsgIndex + 1;
end

ServerEvent:RegisterServerStartFunc(Marry.tbJiaoyuNpc.StartChat, Marry.tbJiaoyuNpc);
