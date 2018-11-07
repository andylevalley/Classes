function [c, ceq] = Constraint(dvar,Problem)

%% pull out relevent values from Problem structure
ManeuverList = Problem.ManeuverList;
NumberManeuvers = length(ManeuverList);
Inspector = Problem.Inspector;
TotalTime = Problem.TotalTime;

%% Seperate chromosome
Order = dvar(1:NumberManeuvers);
TransferTimes = dvar(NumberManeuvers+1:end-NumberManeuvers);

test = 1:1:NumberManeuvers;
A = sum(Order == test,1);
B = ones(1,NumberManeuvers);


%% Time and visit constraints
c = [sum(TransferTimes)-(TotalTime); % change t_total and num_objects 
    -(isequal(A,B))+1]; % this needs to change depending on number of objects 

%% Sun constraint

Inspector.Reset;
for i = 1:NumberManeuvers
    ManeuverList(i).SatelliteProperties.Reset;
end

beta = dvar(end-NumberManeuvers+1:end);
for i = 1:NumberManeuvers
    ManeuverList(i).ManeuverAttributes(6) = beta(i);
end


% Starting after initial wait and transfer
clock = sum(TransferTimes(1:2));
n = 3;

for i = 1:length(Order)
    
    [p,m] = find(Order == i);
    if length(m) > 1
        m(2:end) = [];
    elseif isempty(m) == 1
        m = 1;
    end
    TargetRSO = ManeuverList(m).SatelliteProperties;
    TargetRSO.Propagate(clock);
    ManeuverHill = ManeuverList(m).ManeuverStateHill;
               
    SunVector = TargetRSO.Sun2Rso;
    
    thetaStart = acos(dot(ManeuverHill(1:2)',SunVector(1:2)')/...
                 (norm(ManeuverHill(1:2)')*norm(SunVector(1:2)')));
    
    if strcmp(ManeuverList(m).ConstraintType,'Sun') == 1
        c(end+1:end+2,1) = [-ManeuverList(m).ConstraintValue + thetaStart];
        
    end
    
    clock = clock + TransferTimes(n) + TransferTimes(n+1);
    n = n + 2;
    
end
 

ceq = [];
end