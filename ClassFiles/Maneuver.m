classdef Maneuver < handle
    
    properties 
        Type
        ManeuverAttributes % [ae, xd, yd, zmax, upsilon, beta]
        SatelliteName
        SatelliteProperties
    end
    
    properties (Dependent)
        ManeuverStateECI
    end

    methods % initialize class from user
        function obj = Maneuver(Type,ManeuverAttributes,SatelliteObject)
            obj.Type = Type;
            obj.ManeuverAttributes = ManeuverAttributes;
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