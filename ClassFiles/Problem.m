classdef Problem < handle
    
    properties
        ManeuverList
        TotalTime
        Algorithm
        OptimizationStructure
    end
    
    methods
        function obj = Problem(ManeuverList,TotalTime,Algorithm,OptimizationStructure)
            obj.ManeuverList = ManeuverList;
            obj.TotalTime = TotalTime;
            obj.Algorithm = Algorithm;
            obj.OptimizationStructure = OptimizationStructure;
            
            NumberManeuvers = length(obj.ManeuverList);
            NumberVariables = NumberManeuvers*4+2;
            
            ub = zeros(1,NumberManeuvers+1);
            lb = zeros(1,NumberManeuvers+1);
            ub(1) = obj.TotalTime;
            lb(1) = 1;
            for i = 1:NumberManeuvers
                ub(i+1) = obj.ManeuverList(i).TimeBounds(2);
                lb(i+1) = obj.ManeuverList(i).TimeBounds(1);
            end

            obj.OptimizationStructure.NumberVariables = NumberVariables;
            obj.OptimizationStructure.UpperBound = ub;
            obj.OptimizationStructure.LowerBound = lb;
        end
    end
    
    
end
    
        