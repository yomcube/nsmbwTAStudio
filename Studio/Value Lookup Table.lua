--This file documents the valid buttons to use with TAS Studio, as well as a bunch of address lookup values for use with Write commands.

validButtons = 'CDGHJKLMNOPRUX'
inputTable = {
['L'] = 'LEFT',
['R'] = 'RIGHT',
['U'] = 'UP',
['D'] = 'DOWN',
['G'] = 'B',
['N'] = '',
['J'] = 'A',
['P'] = '+',
['M'] = '-',
['H'] = 'HOME',
['O'] = '1',
['K'] = '2',
['C'] = 'C',
['X'] = ''
}

lookupTable = {
["InputE"] = 0x8039F460,
["InputJ"] = 0x8039F120,
["Player"] = 0x8154B804,
[".Collision"] = 0x10D4,
["Collision"] = 0x8154C8D8,
[".PosX"] = 0xAC,
["PosX"] = 0x8154B8B0,
[".PosY"] = 0xB0,
["PosY"] = 0x8154B8B4,
[".StarTimer"] = 0x1070,
["StarTimer"] = 0x8154C874,
[".TwirlTimer"] = 0x27C8,
["TwirlTimer"] = 0x8154DFCC,
[".SlideTimer"] = 0x1A18,
["SlideTimer"] = 0x8154D21C,
[".SpinTimer"] = 0x17C4,
["SpinTimer"] = 0x8154CFC8,
[".ActionTimer"] = 0xEC0,
["ActionTimer"] = 0x8154C6C4,
[".Jump"] = 0x1564,
["Jump"] = 0x8154CD68,
[".StoredJump"] = 0x1564,
["StoredJump"] = 0x8154CD68,
[".ChainJumpTimer"] = 0x1568,
["ChainJumpTimer"] = 0x8154CD6C,
[".PowerupState"] = 0x14E0,
[".Powerup"] = 0x14E0,
["Powerup"] = 0x8154CCE4,
[".PS"] = 0x14E0,
["PS"] = 0x8154CCE4,
[".PipeTimerL"] = 0x420,
["PipeTimerL"] = 0x8154BC24,
[".PipeTimerR"] = 0x421,
["PipeTimerR"] = 0x8154BC25,
["RNGE"] = 0x80429F44,
["RNGJ"] = 0x80429C64,
["Inv"] = 0x815DBB74,
["Inventory"] = 0x815DBB74,
[".Mushrooms"] = 0x0,
[".FireFlowers"] = 0x4,
[".Propellers"] = 0x8,
[".IceFlowers"] = 0xC,
[".Penguins"] = 0x10,
[".Minis"] = 0x14,
[".Stars"] = 0x18,
[".ps7s"] = 0x1C,
["IGT"] = 0x80D25BF8,
["FrameTypeA"] = 0x815E44EE,
["FrameTypeB"] = 0x923d4066,
["SwitchTimer"] = 0x815E4338,
["LifeCountE"] = 0x80354E90,
["LifeCountJ"] = 0x80354C10,
["CoinCountE"] = 0x80354EA0,
["CoinCountJ"] = 0x80354C20,
["ScoreE"] = 0x80429CC0,
["ScoreJ"] = 0x804299E0,
["ProjectileCountA"] = 0x8037582B,
["ProjectileCountB"] = 0x8037583B,
["LevelIDE"] = 0x80373D7C,
["LevelIDJ"] = 0x80373AFC,
["LevelDeaths"] = 0x80C80624,
[".1"] = 0x0,
[".2"] = 0x2A,
[".3"] = 0x54,
[".4"] = 0x7E,
[".5"] = 0xA8,
[".6"] = 0xD2,
[".7"] = 0xFC,
[".8"] = 0x126,
[".9"] = 0x150,
["Ghost"] = 20,
["Tower"] = 21,
["Castle"] = 23,
["Cannon"] = 35,
["Airship"] = 37,
["1"] = 0,
["2"] = 1,
["3"] = 2,
["4"] = 3,
["5"] = 4,
["6"] = 5,
["7"] = 6,
["8"] = 7,
["9"] = 8
}

validLookupOptions = [[
Input
Player
.Collision
.PosX
.PosY
.StarTimer
.TwirlTimer
.SlideTimer
.SpinTimer
.ActionTimer
.Jump
.StoredJump
.ChainJumpTimer
.PowerupState
.Powerup
.PS
.PipeTimerL
.PipeTimerR
Collision
PosX
PosY
StarTimer
TwirlTimer
SlideTimer
SpinTimer
ActionTimer
Jump
StoredJump
ChainJumpTimer
Powerup
PS
PipeTimerL
PipeTimerR
RNG
Inv
Inventory
.Mushrooms
.FireFlowers
.Propellers
.IceFlowers
.Penguins
.Minis
.Stars
.ps7s
IGT
FrameTypeA
FrameTypeB
SwitchTimer
LifeCount
CoinCount
Score
ProjectileCountA
ProjectileCountB
LevelID
LevelDeaths
.1
.2
.3
.4
.5
.6
.7
.8
.9
.0
Ghost
Tower
Castle
Cannon
Airship
1
2
3
4
5
6
7
8
9
]]

regionSpecificList = 'LevelID, Score, CoinCount, LifeCount, RNG'