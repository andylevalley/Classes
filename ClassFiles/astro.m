classdef astro
    %ASTRO Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant)
        small = 1.0e-10;
        infinite  = 999999.9;
        undefined = 999999.1;
        % -------------------------  mathematical  --------------------
        rad    = 180.0 / pi;
        twopi  = 2.0 * pi;
        halfpi = pi * 0.5;
        % -------------------------  conversions  ---------------------
        ft2m    =    0.3048;
        mile2m  = 1609.344;
        nm2m    = 1852;
        mile2ft = 5280;
        mileph2kmph = 0.44704;
        nmph2kmph   = 0.5144444;
        
        % -----------------------  physical constants  ----------------
        % WGS-84/EGM-96 constants used here
        re         = 6378.137;         % km
        flat       = 1.0/298.257223563;
        omegaearth = 7.292115e-5;     % rad/s
        mu         = 398600.4418;      % km3/s2
        mum        = 3.986004418e14;   % m3/s2

        % derived constants from the base values
        eccearth = sqrt(2.0*astro.flat - astro.flat^2);
        eccearthsqrd = astro.eccearth^2;

        renm = astro.re / astro.nm2m;
        reft = astro.re * 1000.0 / astro.ft2m;

        tusec = sqrt(astro.re^3/astro.mu);
        tumin = astro.tusec / 60.0;
        tuday = astro.tusec / 86400.0;

        omegaearthradptu  = astro.omegaearth * astro.tusec;
        omegaearthradpmin = astro.omegaearth * 60.0;

        velkmps = sqrt(astro.mu / astro.re);
        velftps = astro.velkmps * 1000.0/astro.ft2m;
        velradpmin = astro.velkmps * 60.0/astro.re;
        %for afspc
        %velkmps1 = velradpmin*6378.135/60.0   7.90537051051763
        %mu1 = velkmps*velkmps*6378.135        3.986003602567418e+005        
        degpsec = (180.0 / pi) / astro.tusec;
        radpday = 2.0 * pi * 1.002737909350795;

        speedoflight = 2.99792458e8; % m/s
        au = 149597870.0;      % km
        earth2moon = 384400.0; % km
        moonradius =   1738.0; % km
        sunradius  = 696000.0; % km

        masssun   = 1.9891e30;
        massearth = 5.9742e24;
        massmoon  = 7.3483e22;
    end
    
    properties
        
    end
    
    methods
        function obj = astro()
        end
    end
    methods (Static)
        [r,v] = kepler(ro,vo,dtseco);        
    end
end