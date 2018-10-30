clc
clear all

addpath(genpath('/home/andy/Dropbox/Thesis/Classes')) 

yr0 = 2017;
mo0 = 8;
day0 = 15;
hr0 = 18;
min0 = 7;
sec0 = 57.84;

pos = [6524.834,0,0];
vel = [0,7.81599286557539,0];

sat1 = Satellite('Inspector',[pos vel],[yr0,mo0,day0,hr0,min0,sec0]);

[rHill,vHill] = sat1.CurrentStateHill([pos vel]);


sat1.Propagate(12*60*60)
sat1.Sun2RSO



