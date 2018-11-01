clc
clear all

addpath(genpath('C:/Users/andyl/Desktop/Classes-master')) 
% addpath(genpath('/home/andy/Desktop/Classes-master')) 
% addpath(genpath('I:/setup/Desktop/Classes-master/')) 

%% sat COEs

mu = 398600.5;
sma = 6378.137 + 35786; % semi-major axis of *circular* RSO or virtual RSO (km)
nu0 = deg2rad(0); % initial true anomaly of RSO or virtual RSO (deg)
ecc = 0; % eccentricity - this should be or stay very close to zero - we are using the HCW equations!
incl = deg2rad(0); % inclination (deg) - this combined with RAAN should be appropriate for use (see dissertation)
RAAN = deg2rad(0); % right ascension of the ascending node (deg) - see note above
argp = deg2rad(0); % argument of perigee (deg)
arglat = deg2rad(0); % for ci orbit
truelon = deg2rad(0); % for ce orbit
lonper = deg2rad(0); % for ee orbit
omega = 0;
w = sqrt(mu/sma)^3;
p = sma*(1-ecc^2);

[rInit,vInit] = coe2rvh(p,ecc,incl,omega,argp,nu0,arglat,truelon,lonper,mu);

%% build sat objects

yr0 = 2017;
mo0 = 8;
day0 = 15;
hr0 = 18;
min0 = 7;
sec0 = 57.84;

pos = rInit';
vel = vInit';
VirtualChief = Satellite('virtualchief',[pos vel],[yr0,mo0,day0,hr0,min0,sec0]);

Inspector = Satellite('inspector',[pos vel],[yr0,mo0,day0,hr0,min0,sec0]);

[pos1,vel1] = hill2eci(pos',vel',[20 -10 0]',[0 0 0]');
sat1 = Satellite('rso1',[pos1' vel1'],[yr0,mo0,day0,hr0,min0,sec0]);

[pos2,vel2] = hill2eci(pos',vel',[-20 10 0]',[0 0 0]');
sat2 = Satellite('rso2',[pos2' vel2'],[yr0,mo0,day0,hr0,min0,sec0]);

[pos3,vel3] = hill2eci(pos',vel',[30 30 0]',[0 0 0]');
sat3 = Satellite('rso2',[pos3' vel3'],[yr0,mo0,day0,hr0,min0,sec0]);

%% Attach maneuvers to RSOs

ManeuverInfo = [5, 0, 0, 0, 0, 0];

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
OptimStruct.ObjectiveGunction = 'Impulsive';
OptimStruct.Algorithm = 'GA';

p1 = Problem(ManeuverList,2*24*60*60,VirtualChief,Inspector,OptimStruct);


Solution = Run(p1)
