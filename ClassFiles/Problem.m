classdef Problem < handle
    
    properties
        ManeuverList
        TotalTime
        OptimizationStructure
        Inspector
    end
    
    methods
        function obj = Problem(ManeuverList,TotalTime,Inspector,OptimizationStructure)
            obj.ManeuverList = ManeuverList;
            obj.TotalTime = TotalTime;
            obj.Inspector = Inspector;
            obj.OptimizationStructure = OptimizationStructure;
            
            NumberManeuvers = length(obj.ManeuverList);
            NumberVariables = NumberManeuvers*4+2;
            
            ubInt = ones(1,NumberManeuvers)*NumberManeuvers;
            lbInt = ones(1,NumberManeuvers);
            
            ubInit = obj.TotalTime;
            lbInit = 1;
            
            TransferTimeMin = 60*30;
            TransferTimeMax = obj.TotalTime;
            
            n = 1;
            for i = 1:NumberManeuvers
                ub(n) = TransferTimeMax;
                lb(n) = TransferTimeMin;
                ub(n+1) = obj.ManeuverList(i).TimeBounds(2);
                lb(n+1) = obj.ManeuverList(i).TimeBounds(1);
                n = n + 2;
            end
            lb(n) = TransferTimeMin;
            ub(n) = TransferTimeMax;
            
            lbBeta = zeros(1,NumberManeuvers);
            ubBeta = ones(1,NumberManeuvers)*2*pi;
            
            ub = [ubInt, ubInit, ub, ubBeta];
            lb = [lbInt, lbInit, lb, lbBeta];
            
            obj.OptimizationStructure.NumberVariables = NumberVariables;
            obj.OptimizationStructure.UpperBound = ub;
            obj.OptimizationStructure.LowerBound = lb;
        end
    end
    
    
end
    
        