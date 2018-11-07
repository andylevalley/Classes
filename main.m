clc
clear all

addpath(genpath('C:/Users/andyl/Dropbox/Thesis/Classes-master')) 
% addpath(genpath('/home/andy/Dropbox/Thesis/Classes-master')) 
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

Inspector = Satellite('inspector',[pos vel],[yr0,mo0,day0,hr0,min0,sec0]);

[pos1,vel1] = hill2eci(pos',vel',[0 30*1000 0]',[0 0 0]');
sat1 = Satellite('rso1',[pos1' vel1'],[yr0,mo0,day0,hr0,min0,sec0]);

[pos2,vel2] = hill2eci(pos',vel',[0 -30*1000 0]',[0 0 0]');
sat2 = Satellite('rso2',[pos2' vel2'],[yr0,mo0,day0,hr0,min0,sec0]);
% 
[pos3,vel3] = hill2eci(pos',vel',[10*1000 -10*1000 0]',[0 0 0]');
sat3 = Satellite('rso3',[pos3' vel3'],[yr0,mo0,day0,hr0,min0,sec0]);

%% Attach maneuvers to RSOs

ManeuverInfo = [5*1000, 0, 0, 0, 0, 0];

maneuver_sat1 = Maneuver('NMC',ManeuverInfo,'Sun',deg2rad(20),sat1);
maneuver_sat1.TimeBounds = [23*60*60 24*60*60];
maneuver_sat2 = Maneuver('NMC',ManeuverInfo,'Sun',deg2rad(20),sat2);
maneuver_sat2.TimeBounds = [23*60*60 24*60*60];
maneuver_sat3 = Maneuver('NMC',ManeuverInfo,'Sun',deg2rad(20),sat3);
maneuver_sat3.TimeBounds = [23*60*60 24*60*60];

ManeuverList = [maneuver_sat1, maneuver_sat2, maneuver_sat3];

%% Create Problem

OptimStruct.Popsize = 200;
OptimStruct.EliteCount = ceil(0.1*OptimStruct.Popsize);
OptimStruct.MaxGenerations = 300;
OptimStruct.UseParallel = false;
OptimStruct.CrossoverFraction = 0.9;
OptimStruct.ObjectiveFunction = 'Impulsive';
OptimStruct.Algorithm = 'GA';

p1 = Problem(ManeuverList,4*24*60*60,Inspector,OptimStruct);

Solution = Run(p1);

Output = Propagate(p1,Solution);
State = Output.State;
SunVector = Output.SunVector;
close(gcf);

%% Plot Results
dvar = Solution.dvar;
Order = dvar(1:length(ManeuverList));
TransferTimes = dvar(length(ManeuverList)+1:end-length(ManeuverList));

c = @colors;

scl = ManeuverInfo(1)/1000;

n = 2;
for i = 1:length(ManeuverList)
    figure(i)
    plot(State{i}(2,1:floor(TransferTimes(n)))/1000,State{i}(1,1:floor(TransferTimes(n)))/1000,'-.r','LineWidth',1.5);
    axis([-10 10 -10 10])
    hold on
    plot(State{i}(2,floor(TransferTimes(n))+1:end)/1000,State{i}(1,floor(TransferTimes(n))+1:end)/1000,'.-b','LineWidth',1.5);
    axis([-10 10 -10 10])
    hold on
    qt0 = quiver(SunVector{i}(2,1)*scl,SunVector{i}(1,1)*scl,-SunVector{i}(2,1)*scl,-SunVector{i}(1,1)*scl);
    set(qt0,'color',[1 .5 0],'LineWidth',1.5,'MaxHeadSize',1);
    qtf = quiver(SunVector{i}(2,2)*scl,SunVector{i}(1,2)*scl,-SunVector{i}(2,2)*scl,-SunVector{i}(1,2)*scl);
    set(qtf,'color',[1 .5 0],'LineWidth',1.5,'MaxHeadSize',1);
    set(qtf,'LineStyle','--');
    hold on
    scatter(0,0,100,[ 0.5843 0.8157 0.9882],'x','LineWidth',2)
    title(sprintf('RSO %.0f Visit',i))
    hold off
    legend({'Transfer Trajectory','Natural Motion','$\vec{r}_{sun}$ at $t_0$','$\vec{r}_{sun}$ at $t_f$'})
    xlabel('In-Track (km)');
    ylabel('Radial (km)');
    n = n + 2;
end



