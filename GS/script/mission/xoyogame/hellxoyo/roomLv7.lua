-- 文件名　：roomLv7.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-03-27 19:21:54
-- 描述：逍遥谷 ,璇静双姝，逍遥谷主



-----------------璇静双姝------------------
Require("\\script\\mission\\xoyogame\\room_base.lua");

XoyoGame.RoomXuanjingShuangZhu = Lib:NewClass(XoyoGame.BaseRoom);

local RoomXuanjingShuangZhu = XoyoGame.RoomXuanjingShuangZhu;


function RoomXuanjingShuangZhu:OnInitRoom()
	self.tbBlood = {};
end

function RoomXuanjingShuangZhu:RecordBlood(szGroup)
	if not self.tbNpcGroup[szGroup] then
		return 0;
	end
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		local nLife = pNpc.nCurLife;
		local nMaxLife = pNpc.nMaxLife;
		if nLife and nLife > 0 then
			self.tbBlood[szGroup] = (nLife / nMaxLife) * 100;
			break;
		end	
	end
end

function RoomXuanjingShuangZhu:SetNpcBlood(szGroup)
	if szGroup == "yejing2" then
		self:SetNpcLife(szGroup,self.tbBlood["yejing"] or 100);
	elseif szGroup == "yexuan2" then
		self:SetNpcLife(szGroup,self.tbBlood["yexuan"] or 100);
	end
end

------------------逍遥谷主------------------
Require("\\script\\mission\\xoyogame\\room_base.lua");

XoyoGame.RoomXoyoGuzhu = Lib:NewClass(XoyoGame.BaseRoom);

local RoomXoyoGuzhu = XoyoGame.RoomXoyoGuzhu;


function RoomXoyoGuzhu:OnInitRoom()
	self.tbBlood = {};
end

function RoomXoyoGuzhu:RecordBlood(szGroup)
	if not self.tbNpcGroup[szGroup] then
		return 0;
	end
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		local nLife = pNpc.nCurLife;
		local nMaxLife = pNpc.nMaxLife;
		if nLife and nLife > 0 then
			self.tbBlood[szGroup] = (nLife / nMaxLife) * 100;
			break;
		end	
	end
end

function RoomXoyoGuzhu:SetNpcBlood(szGroup)
	if szGroup == "boss2" then
		self:SetNpcLife(szGroup,self.tbBlood["boss1"] or 100);
	elseif szGroup == "boss3" then
		self:SetNpcLife(szGroup,self.tbBlood["boss2"] or 100);
	elseif szGroup == "boss4" then
		self:SetNpcLife(szGroup,self.tbBlood["boss3"] or 100);
	end
end