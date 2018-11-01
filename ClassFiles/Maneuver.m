classdef Maneuver < handle
    
    properties 
        Type
        ManeuverAttributes % [ae, xd, yd, zmax, upsilon, beta]
        SatelliteName
        SatelliteProperties
        TimeBounds = [12*60*60, 24*60*60];
        Constraint
    end
    
    properties (Dependent)
        ManeuverStateECI
    end

    methods % initialize class from user
        function obj = Maneuver(Type,ManeuverAttributes,Constraint,SatelliteObject)
            obj.Type = Type;
            obj.ManeuverAttributes = ManeuverAttributes;
            obj.Constraint = Constraint;
            obj.SatelliteName = SatelliteObject.Name;
            obj.SatelliteProperties = SatelliteObject;
        end
    end
    
    methods % get injection state
        function val = get.ManeuverStateECI(obj)
            ManeuverStateHill = Target(obj.Type,obj.ManeuverAttributes,...
                                obj.SatelliteProperties.MeanMotion);
            [rECI,vECI] = hill2eci(obj.SatelliteProperties.CurrentStateECI(1:3)',...
                                   obj.SatelliteProperties.CurrentStateECI(4:6)',...
                                   ManeuverStateHill(1:3)',...
                                   ManeuverStateHill(4:6)');
            val = [rECI',vECI'];
        end
    end
            
          
end