function scenario = generateScenario(cfg)

%% Construct Time vector
scenario.time = ...
    (0:cfg.simulation.dt:cfg.simulation.nEpochs-1).';

%% Generate ground truth
scenario.truth = generateTrajectory(cfg);

%% Generate GNSS measurements
scenario.gnss = generateGnssObservables(scenario.truth, cfg);

end
