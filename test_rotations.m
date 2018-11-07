clc
clear all

yr0 = 2017;
mo0 = 8;
day0 = 15;
hr0 = 18;
min0 = 7;
sec0 = 57.84;

mu = 398600.5;
sma = 6378.137 + 35786; % semi-major axis of *circular* RSO or virtual RSO (km)
nu0 = deg2rad(0); % initial true anomaly of RSO or virtual RSO (deg)
ecc = 0; % eccentricity - this should be or stay very close to zero - we are using the HCW equations!
incl = deg2rad(0); % inclination (deg) - this combined with RAAN should be appropriate for use (see dissertation)
RAAN = deg2rad(360); % right ascension of the ascending node (deg) - see note above
argp = deg2rad(0); % argument of perigee (deg)
arglat = deg2rad(0); % for ci orbit
truelon = deg2rad(0); % for ce orbit
lonper = deg2rad(0); % for ee orbit
omega = 0;
w = sqrt(mu/sma)^3;
p = sma*(1-ecc^2);

[rInit,vInit] = coe2rvh(p,ecc,incl,omega,argp,nu0,arglat,truelon,lonper,mu);

sat1 = Satellite('rso1',[rInit' vInit'],[yr0,mo0,day0,hr0,min0,sec0]);

sat1.Propagate(23*60*60 + 53*60 + 4)
    
    
    