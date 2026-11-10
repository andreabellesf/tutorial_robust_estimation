function scenario = generateScenario(cfg)

%% Construct Time vector
scenario.time = ...
    (0:cfg.simulation.nEpochs-1).' * cfg.simulation.dt;

%% Generate ground truth
% Function to generate the state estimation reference (position, velocity and clock offset)
scenario.truth = generateTrajectory(cfg);

%% Generate GNSS measurements
scenario.gnss = generateGnssObservables(scenario.truth, cfg);

end
