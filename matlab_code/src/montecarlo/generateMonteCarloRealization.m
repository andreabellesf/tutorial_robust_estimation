function trial = generateMonteCarloRealization(scenario, cfg)

    %% Start from reference scenario
    trial = scenario;

    %% Pseudorange noise
    % Inject noise into pseudorange measurements according to the configuration

    nObsPerEpoch = scenario.gnss.nSatellites;

    pseudorangeSigmaSq = cfg.gnss.pseudorangeSigma^2;

    R = diag( pseudorangeSigmaSq*ones(1,nObsPerEpoch) );
    
    noise = mgd( cfg.simulation.nEpochs, nObsPerEpoch, zeros(1,nObsPerEpoch), R ).';

    trial.gnss.pseudorange = ...
        scenario.gnss.idealPseudorange + noise;

    %% Store true measurement errors
    trial.gnss.truePseudorangeError = noise;
   
end