function f = ObjectiveFunction_ImpulsiveTargeting(dvar,Problem)

%% pull out relevent values from Problem structure
ManeuverList = Problem.ManeuverList;
NumberManeuvers = length(ManeuverList);
Inspector = Problem.Inspector;

%% Seperate chromosome
Order = dvar(1:NumberManeuvers);
TransferTimes = dvar(NumberManeuvers+1:end-NumberManeuvers);

%% Targeting

Inspector.Reset;
for i = 1:NumberManeuvers
    ManeuverList(i).SatelliteProperties.Reset;
end


beta = dvar(end-NumberManeuvers+1:end);

% assign beta value to maneuvers
for i = 1:NumberManeuvers
    ManeuverList(i).ManeuverAttributes(6) = beta(i);
end

f = 0;
k = 1;
Inspector.Propagate(TransferTimes(k));
for i = 1:length(Order)
    
    [n,m] = find(Order == i);
    TargetRSO = ManeuverList(m).SatelliteProperties;
    ManeuverRSO = ManeuverList(m);
    TargetRSO.Propagate(sum(TransferTimes(1:k+1)));
    
    TargetHill(1,1:6) = ManeuverRSO.ManeuverStateHill;
    InspectorHill = Inspector.CurrentStateHill(TargetRSO.CurrentStateECI);
             
    DeltaV = HCW2BurnTargeting(InspectorHill(1:3)',TargetHill(1:3)',...
             InspectorHill(4:6)',TargetHill(4:6)',TransferTimes(k+1),...
             ManeuverList(1).SatelliteProperties.MeanMotion);
         
    [rHillTransfer,vHillTransfer] = CWHPropagator(InspectorHill(1:3)',...
                                    InspectorHill(4:6)'+DeltaV(1:3,1),...
                                    TargetRSO.MeanMotion,TransferTimes(k+1));
                               
    [rHillLoiter,vHillLoiter] = CWHPropagator(rHillTransfer(1:3,end),...
                                vHillTransfer(1:3,end)+DeltaV(1:3,2),...
                                TargetRSO.MeanMotion,TransferTimes(k+2));
         
   f = f + abs(norm(DeltaV(1:3,1))) + abs(norm(DeltaV(1:3,2)));
   
   TargetRSO.Propagate(TransferTimes(k+2));
                           
   [r,v] = hill2eci(TargetRSO.CurrentStateECI(1:3)',...
           TargetRSO.CurrentStateECI(4:6)',...
           rHillLoiter(1:3,end),vHillLoiter(1:3,end));
       
   Inspector.CurrentStateECI = [r' v'];
    
    
    k = k+2;
end


InspectorState = Inspector.CurrentStateECI;
Inspector.Reset;
Inspector.Propagate(sum(TransferTimes));

[rHill,vHill] = eci2hill(Inspector.CurrentStateECI(1:3)',...
                Inspector.CurrentStateECI(4:6)',InspectorState(1:3)',...
                InspectorState(4:6)');
            
TargetHill = [0 0 0 0 0 0];

DeltaV = HCW2BurnTargeting(rHill(1:3),TargetHill(1:3)',...
         vHill(1:3),TargetHill(4:6)',TransferTimes(k+1),...
         ManeuverList(1).SatelliteProperties.MeanMotion);


f = f + abs(norm(DeltaV(1:3,1))) + abs(norm(DeltaV(1:3,2)));

end