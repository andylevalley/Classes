function TargetInfo = Target(Type,ManeuverAttributes,MeanMotion)
% Converts relative orbital elements (as defined by Lovell) to
% Hill-Clohessy-Wiltshire (HCW)

% ManeuverAttributes = [ae, xd, yd, zmax, upsilon, beta]
n = MeanMotion;

switch Type
    case 'NMC'
        
        ae = ManeuverAttributes(1);
        xd = ManeuverAttributes(2);
        yd = ManeuverAttributes(3);
        zmax = ManeuverAttributes(4);
        upsilon = ManeuverAttributes(5);
        beta = ManeuverAttributes(6);

        x = (-ae/2)*cos(beta) + xd;
        y = ae*sin(beta) + yd;
        z = zmax*sin(upsilon);
        x_dot = (ae/2)*n*sin(beta);
        y_dot = ae*n*cos(beta) - 3*n*xd/2;
        z_dot = zmax*n*cos(upsilon);
        TargetInfo = [x y z x_dot y_dot z_dot];
        
end
end