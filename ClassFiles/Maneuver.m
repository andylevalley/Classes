classdef Maneuver < handle
    
    properties 
        Type
        ManeuverAttributes % [ae, xd, yd, zmax, upsilon, beta]
        SatelliteName
        SatelliteProperties
        TimeBounds = [12*60*60, 24*60*60];
        ConstraintType
        ConstraintValue
        
    end
    
    properties (Dependent)
        ManeuverStateECI
        ManeuverStateHill
    end

    methods % initialize class from user
        function obj = Maneuver(Type,ManeuverAttributes,ConstraintType,...
                       ConstraintValue,SatelliteObject)
            obj.Type = Type;
            obj.ManeuverAttributes = ManeuverAttributes;
            obj.ConstraintType = ConstraintType;
            obj.ConstraintValue = ConstraintValue;
            obj.SatelliteName = SatelliteObject.Name;
            obj.SatelliteProperties = SatelliteObject;
        end
    end
    
    methods % get injection state
        function val = get.ManeuverStateECI(obj)
            targetHill = Target(obj.Type,obj.ManeuverAttributes,...
                                obj.SatelliteProperties.MeanMotion);
            [rECI,vECI] = hill2eci(obj.SatelliteProperties.CurrentStateECI(1:3)',...
                                   obj.SatelliteProperties.CurrentStateECI(4:6)',...
                                   targetHill(1:3)',...
                                   targetHill(4:6)');
            val = [rECI',vECI'];
        end
    end
    
    methods % get injection state
        function val = get.ManeuverStateHill(obj)
            val = Target(obj.Type,obj.ManeuverAttributes,...
                                obj.SatelliteProperties.MeanMotion);
        end
    end
            
          
end