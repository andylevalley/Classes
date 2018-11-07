function Output = Propagate(Problem,Solution)

ManeuverList = Problem.ManeuverList;
NumberManeuvers = length(ManeuverList);
Inspector = Problem.Inspector;
dvar = Solution.dvar;

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


k = 1; 
Inspector.Propagate(TransferTimes(k)); 
for i = 1:length(Order)
      
    [n,m] = find(Order == i);
    TargetRSO = ManeuverList(m).SatelliteProperties;
    ManeuverRSO = ManeuverList(m);
    TargetRSO.Propagate(sum(TransferTimes(1:k+1)));
    SunVector{i}(1:3,1) = TargetRSO.Sun2Rso';
    
    TargetHill(1,1:6) = ManeuverRSO.ManeuverStateHill;
    InspectorHill = Inspector.CurrentStateHill(TargetRSO.CurrentStateECI);
             
    DeltaV = HCW2BurnTargeting(InspectorHill(1:3)',TargetHill(1:3)',...
             InspectorHill(4:6)',TargetHill(4:6)',TransferTimes(k+1),...
             ManeuverList(1).SatelliteProperties.MeanMotion);
         
   [rHillTransfer,vHillTransfer] = CWHPropagator(InspectorHill(1:3)',...
                                   InspectorHill(4:6)'+DeltaV(1:3,1),...
                                   TargetRSO.MeanMotion,0:TransferTimes(k+1));
                               
   [rHillLoiter,vHillLoiter] = CWHPropagator(rHillTransfer(1:3,end),...
                               vHillTransfer(1:3,end)+DeltaV(1:3,2),...
                               TargetRSO.MeanMotion,0:TransferTimes(k+2));
   
   State{i} = horzcat([rHillTransfer; vHillTransfer],...
              [rHillLoiter; vHillLoiter]);
   
   TargetRSO.Propagate(TransferTimes(k+2));
   SunVector{i}(1:3,2) = TargetRSO.Sun2Rso';
                           
   [r,v] = hill2eci(TargetRSO.CurrentStateECI(1:3)',...
           TargetRSO.CurrentStateECI(4:6)',...
           State{i}(1:3,end),State{i}(4:6,end));
       
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

[rHillTransfer,vHillTransfer] = CWHPropagator(rHill(1:3),...
                                vHill(1:3)+DeltaV(1:3,1),...
                                TargetRSO.MeanMotion,0:TransferTimes(k+1));
                            
rHillFinal = rHillTransfer(1:3,end);
vHillFinal = vHillTransfer(1:3,end) + DeltaV(1:3,2);

State{i+1} = horzcat([rHillTransfer; vHillTransfer],...
             [rHillFinal; vHillFinal]);


Output.State = State;

%% Propagate SunVector


% Inspector.Reset;
% for i = 1:NumberManeuvers
%     ManeuverList(i).SatelliteProperties.Reset;
% end
% 
% dt = 60;
% clock = sum(TransferTimes(1:2));
% n = 3;
% for i = 1:length(Order)
%     
%     Sun2RSO = [];
%     InspectorHist = [];
%     [x,m] = find(Order == i);
%     TargetRSO = ManeuverList(m).SatelliteProperties;
%     TargetRSO.Propagate(clock);
%     Sun2RSO = TargetRSO.Sun2Rso';
% 
%     
%     for j = 1:floor(TransferTimes(n)/dt)
%         TargetRSO.Propagate(dt);
%         Sun2RSO = horzcat(Sun2RSO,TargetRSO.Sun2Rso');
%     end
%     SunVector{i} = Sun2RSO;
%     
%     InspectorHist = State{i}(1:3,floor(TransferTimes(n-1)):dt:end);
%     
%     p = 1;
%     for k = 0:length(Sun2RSO)-1
%         theta = acos(dot(InspectorHist(1:3,p),Sun2RSO(1:3,p)')/...
%                 (norm(InspectorHist(1:3,p)')*norm(Sun2RSO(1:3,p)')));
%             
%         SunAngle{i}(1:2,p) = vertcat(k*dt,theta);
%         p = p+1;
%     end
%     
%     clock = clock + TransferTimes(n) + TransferTimes(n+1);
%     n = n+2;
% end

% % Output.SunAngle = SunAngle;
Output.SunVector = SunVector;

    
    
    
end