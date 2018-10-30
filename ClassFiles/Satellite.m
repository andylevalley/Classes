classdef Satellite < handle
    
    properties (Constant)
        mu = 3.98600436233e+14;     % standard gravitational parameter (m^3/s^2)
    end
    
    properties (Access = public)
        Type = 'Passive'
        CurrentStateECI             % current satellite state (ECI)
        CurrentTimeUTCO             % current time (UTCO)
        InitialStateECI
        InitialTimeUTCO
    end
    
    methods % initialize class from user
        function obj = Satellite(Type,InitStateECI,InitTimeUTCO)
            obj.Type = Type;
            obj.CurrentStateECI = InitStateECI;
            obj.CurrentTimeUTCO = InitTimeUTCO;
            obj.InitialStateECI = InitStateECI;
            obj.InitialTimeUTCO = InitTimeUTCO;
        end
    end
        
    methods % get current state in Hill frame relative to Virtual Chief
        function [rHill,vHill] = CurrentStateHill(obj,VirtualChiefECI)
             [rHill,vHill] = eci2hill(VirtualChiefECI(1:3)',VirtualChiefECI(4:6)',...
                           obj.CurrentStateECI(1:3)',obj.CurrentStateECI(4:6)');
             rHill = rHill';
             vHill = vHill';
        end
    end
        
    methods % propagate orbit, update state and current time
        function obj = Propagate(obj,Time)
            [rECI,vECI] = TwoBodyPropagation(obj.CurrentStateECI(1:3)',...
                          obj.CurrentStateECI(4:6)',Time);
            obj.CurrentStateECI = [rECI(1:3,end)',vECI(1:3,end)'];
            CurrentTimeJD = utco2jd(obj.CurrentTimeUTCO);
            CurrentTimeJD = CurrentTimeJD + Time(end);
            obj.CurrentTimeUTCO = jd2utco(CurrentTimeJD);
        end
    end
    
    methods % get vector from sun to satellite for current satellite state
        function val = Sun2RSO(obj)
            sun2RSO_vector = sun2rso(obj.CurrentTimeUTCO,obj.CurrentStateECI(1:3)',...
                                     obj.CurrentStateECI(4:6)');
            val = sun2RSO_vector';
        end
    end
            
   
end