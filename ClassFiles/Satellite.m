classdef Satellite < handle
    
    properties (Constant)
        mu = 398600.5;     % standard gravitational parameter (km^3/s^2)  
    end
    
    properties (Access = public)
        Name = 'sat1'               % Satellite type
        CurrentStateECI             % current satellite state (ECI)
        CurrentTimeUTCO             % current time (UTCO)
        InitialStateECI             % initial state (ECI)
        InitialTimeUTCO             % initial time (UTCO)
        MeanMotion                  % meanmotion
    end 
    
    methods % initialize class from user
        function obj = Satellite(Name,InitStateECI,InitTimeUTCO)
            obj.Name = Name;
            obj.CurrentStateECI = InitStateECI;
            obj.CurrentTimeUTCO = InitTimeUTCO;
            obj.InitialStateECI = InitStateECI;
            obj.InitialTimeUTCO = InitTimeUTCO;
            obj.MeanMotion = sqrt(obj.mu/(6378.137 + 35786)^3);
        end
    end
    
    methods
        function obj = Reset(obj)
            obj.CurrentStateECI(1:end) = [];
            obj.CurrentTimeUTCO(1:end) = [];
            obj.CurrentStateECI = obj.InitialStateECI;
            obj.CurrentTimeUTCO = obj.InitialTimeUTCO;

        end
    end
        
    methods % get current state in Hill frame relative to Virtual Chief
        function [rHill,vHill] = CurrentStateHill(obj,VirtualChiefECI)
             [rHill,vHill] = eci2hill(VirtualChiefECI(1:3)',...
                             VirtualChiefECI(4:6)',...
                             obj.CurrentStateECI(1:3)',...
                             obj.CurrentStateECI(4:6)');
             rHill = rHill';
             vHill = vHill';
        end
    end
        
    methods % propagate orbit, update state and current time
        function obj = Propagate(obj,Time)
          [rECI,vECI] = TwoBodyPropagation(obj.CurrentStateECI(1:3)',...
                          obj.CurrentStateECI(4:6)',Time);       
            obj.CurrentStateECI = [rECI(1:3,end)',vECI(1:3,end)'];
            obj.CurrentTimeUTCO(6) = obj.CurrentTimeUTCO(6) + Time(end);
            CurrentTimeJD = utco2jd(obj.CurrentTimeUTCO);
            obj.CurrentTimeUTCO = jd2utco(CurrentTimeJD);
        end
    end
    
    methods % get vector from sun to satellite for current satellite state
        function val = Sun2Rso(obj)
            sun2RSO_vector = sun2rso(obj.CurrentTimeUTCO,...
                             obj.CurrentStateECI(1:3)',...
                             obj.CurrentStateECI(4:6)');
            val = sun2RSO_vector';
        end
    end
            
   
end