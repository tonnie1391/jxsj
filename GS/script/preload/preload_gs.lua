--固定预先加载的脚本，会是所有脚本加载的第一个

print("Preload gs script files...");

-- GS、GC通用
Require("\\script\\misc\\globaltaskdef.lua");

-- Client、GS通用
Require("\\script\\misc\\serverevent.lua");
Require("\\script\\player\\kluaplayer.lua");
Require("\\script\\npc\\npc.lua");
Require("\\script\\player\\player.lua");
Require("\\script\\item\\item.lua");
Require("\\script\\obj\\obj.lua");
Require("\\script\\task\\task.lua");
Require("\\script\\fightskill\\fightskill.lua");
Require("\\script\\map\\map.lua");
Require("\\script\\lib\\gift.lua");
Require("\\script\\event\\manager\\define.lua");
Require("\\script\\task\\help\\help.lua");
Require("\\script\\mission\\logout_rv.lua");
-- GS专用
Require("\\script\\mission\\mission.lua");
Require("\\script\\transfer\\transfer.lua");
