clc
clear all

yr0 = 2017;
mo0 = 8;
day0 = 15;
hr0 = 18;
min0 = 7;
sec0 = 57.84;

pos = [6378.137 + 35786,0,0];
vel = [0,7.81599286557539,0];
sat1 = Satellite('rso1',[pos vel],[yr0,mo0,day0,hr0,min0,sec0]);

% [pos2,vel2] = hill2eci(pos',vel',[0 0 0]',[0 0 0]');
% sat2 = Satellite('rso1',[pos2' vel2'],[yr0,mo0,day0,hr0,min0,sec0]);


ManeuverInfo = [5, 0, 0, 0, 0, 0];
maneuver_sat1 = Maneuver('NMC',ManeuverInfo,sat1);


[state] = maneuver_sat1.ManeuverStateECI;

[rHillinit(1:3),vHillinit(1:3)] = eci2hill(pos',vel',state(1,1:3)',state(1,4:6)');

% sat2 = Satellite('rso2',state,[yr0,mo0,day0,hr0,min0,sec0]);

sat1.Propagate(60*60);
[state] = maneuver_sat1.ManeuverStateECI;
[rHillinit(1:3),vHillinit(1:3)] = eci2hill(sat1.CurrentStateECI(1:3)',sat1.CurrentStateECI(4:6)',state(1,1:3)',state(1,4:6)');

% for i = 1:12
%     [rHill(1:3,i),vHill(1:3,i)] = eci2hill(pos',vel',stateNMC(i,1:3)',stateNMC(i,4:6)');
%     
% end

[rHill,vHill] = CWHPropagator(rHillinit',vHillinit',sat1.MeanMotion,0:60:24*60*60);

scatter(rHill(2,:),rHill(1,:))
    
    
    