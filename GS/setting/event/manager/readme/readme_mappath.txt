召唤npc说明				
字段名	描述	格式	类型	说明
Name	描述	string	字符串	Npc名字,为空为默认名
MapId	地图ID	n	整型	MapId,PosX,PosY,NpcId必须同时存在
PosX	地图X坐标32位	n	整型	MapId,PosX,PosY,NpcId必须同时存在
PosY	地图Y坐标32位	n	整型	MapId,PosX,PosY,NpcId必须同时存在
NpcId	怪物ID	n	整型	MapId,PosX,PosY,NpcID必须同时存在
Level	等级	n	整型	G,D,P,L值必须同时填写
Series	五行	n	整型	五行,-1或不填则随机五行,0金,1木,2,水,3,火,4土
RandRate	几率	n	整型	百万分之N,最大几率是所有相加,所有几率不填则召唤所有boss
Annouce	公告	n	整型	0不告,1全服公告
