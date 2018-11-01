function Solution = Run(Problem)

lb = Problem.OptimizationStructure.LowerBound;
ub = Problem.OptimizationStructure.UpperBound;
IntCon = 1:1:length(Problem.ManeuverList);

Popsize = Problem.OptimizationStructure.Popsize;
EliteCount = Problem.OptimizationStructure.EliteCount;
MaxGenerations = Problem.OptimizationStructure.MaxGenerations;
UseParallel = Problem.OptimizationStructure.UseParallel;
CrossoverFraction = Problem.OptimizationStructure.CrossoverFraction;
numvars = Problem.OptimizationStructure.NumberVariables;

opts = optimoptions('ga','CrossoverFraction',CrossoverFraction,...
                    'PopulationSize',Popsize,'EliteCount',EliteCount,...
                    'MaxGenerations',MaxGenerations,'PlotFcn',@gaplotbestf,...
                    'UseParallel',UseParallel);
                
% Fitness and Penalty Function definition
switch Problem.OptimizationStructure.ObjectiveFunction
    case 'Impulsive'
        ObjectiveFunction = @(dvar) ObjectiveFunction_ImpulsiveTargeting(dvar,Problem);
        ConstraintFunction = @(dvar) constraint(dvar,Problem);
    case 'BVP'
end

[dvar,fval,exitflag,output] = ga(ObjectiveFunction,numvars,[],[],[],[],...
    lb,ub,ConstraintFunction,IntCon,opts);

Solution.dvar = dvar;
Solution.fval = fval;
Solution.exitflag = exitflag;
Solution.output = output;

end