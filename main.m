clc
clear all

%% build sat objects

yr0 = 2017;
mo0 = 8;
day0 = 15;
hr0 = 18;
min0 = 7;
sec0 = 57.84;

pos = [6524.834,0,0];
vel = [0,7.81599286557539,0];
VirtualChief = Satellite('virtualchief',[pos vel],[yr0,mo0,day0,hr0,min0,sec0]);

[pos1,vel1] = hill2eci(pos',vel',[20 -10 0]',[0 0 0]');
sat1 = Satellite('rso1',[pos1 vel1],[yr0,mo0,day0,hr0,min0,sec0]);

[pos2,vel2] = hill2eci(pos',vel',[-20 10 0]',[0 0 0]');
sat2 = Satellite('rso2',[pos2' vel2'],[yr0,mo0,day0,hr0,min0,sec0]);

[pos3,vel3] = hill2eci(pos',vel',[30 30 0]',[0 0 0]');
sat3 = Satellite('rso2',[pos3' vel3'],[yr0,mo0,day0,hr0,min0,sec0]);

%% Attach maneuvers to RSOs

ManeuverInfo = [10, 0, 0, 0, 0, 0];

maneuver_sat1 = Maneuver('NMC',ManeuverInfo,'Sun',sat1);
maneuver_sat2 = Maneuver('NMC',ManeuverInfo,'Sun',sat2);
maneuver_sat3 = Maneuver('NMC',ManeuverInfo,'Sun',sat3);

ManeuverList = [maneuver_sat1, maneuver_sat2, maneuver_sat3];

%% Create Problem

OptimStruct.Popsize = 200;
OptimStruct.EliteCount = ceil(0.1*OptimStruct.Popsize);
OptimStruct.MaxGenerations = 200;
OptimStruct.UseParallel = false;
OptimStruct.CrossoverFraction = 0.9;

p1 = Problem(ManeuverList,2*24*60*60,'GA',OptimStruct);



