function scenario = generateScenario(cfg)

%% Construct Time vector

scenario.time = ...
    (0:cfg.simulation.nEpochs-1).' * cfg.simulation.dt;

%% Generate ground truth

% Function to generate the state estimation reference (position, velocity and clock offset)
scenario.truth = generateTrajectory(cfg);

%% Load real data or generate sythentic GNSS measurements 

if cfg.simulation.enableRealData
    scenario.gnss = loadRealGnssData(scenario.truth, cfg);
else
    scenario.gnss = generateGnssObservables(scenario.truth, cfg);
end

end
