function f = ObjectiveFunction_ImpulsiveTargeting(dvar,Problem)

%% pull out relevent values from Problem structure
ManeuverList = Problem.ManeuverList;
NumberManeuvers = length(ManeuverList);
VirtualChiefECI = Problem.VirtualChiefECI;
InitialStateECI = VirtualChiefECI;

%% Seperate chromosome
Order = dvar(1:NumberManeuvers);
TransferTimes = dvar(NumberManeuvers+1:end-NumberManeuvers);

%% Targeting
InitState = Problem.InitialStateECI;
beta = dvar(end-NumberManeuvers+1:end);

% assign beta value to maneuvers
for i = 1:NumberManeuvers
    ManeuverList(i).ManeuverAttributes(6) = beta(i);
end

f = 0;
k = 1;
for i = 1:length(Order)
    for n = 1:NumberManeuvers
        ManeuverList(i).SatelliteProperties.Propagate(sum(TransferTimes(1:k)));
    end
    
    index = find(Order == i);
    targetECI = ManeuverList(index).ManeuverStateECI;
    targetHill = eci2hill(VirtualChiefECI(1:3)',VirtualChiefECI(4:6)',...
                 targetECI(1:3)',targetECI(4:6)');
    DeltaV = HCW_DeltaV(CurrentState(1:3)',targetHill(tgt,1:3)',...
             CurrentState(4:6)',targetHill(tgt,4:6)',TransferTimes(k+1),...
             ManeuverList(1).SatelliteProperties.MeanMotion);
         
    CurrentState = ;
    
    f = f + norm(DeltaV);
    
    
    k = k+2;
%% Calculate Fitness

% initialize variables
CurrentState = InitState;
n = 1;
f = 0;

for i = 1:length(Order)
    
    tgt = dvar(i);
    
    [x_drift,v_drift] = CWHPropagator(CurrentState(1:3)',CurrentState(4:6)',Omega,TransferTimes(n));
    CurrentState = [x_drift',v_drift'];
    
    DeltaV = HCW_DeltaV(CurrentState(1:3)',TargetInfo(tgt,1:3)',...
             CurrentState(4:6)',TargetInfo(tgt,4:6)',TransferTimes(n+1),...
             ManeuverList(1).SatelliteProperties.MeanMotion);
    
    CurrentState = TargetInfo(tgt,:);
    
    f = f + norm(DeltaV);
    
    n = n + 2;
    
end

[x_drift,v_drift] = CWHPropagator(CurrentState(1:3)',CurrentState(4:6)',Omega,TransferTimes(n));
CurrentState = [x_drift',v_drift'];

ReturnState = InitState;

DeltaV = HCW_DeltaV(CurrentState(1:3)',ReturnState(1:3)',...
    CurrentState(4:6)',ReturnState(4:6)',TransferTimes(n+1),Omega);

CurrentState = ReturnState;

f = f + norm(DeltaV);

end