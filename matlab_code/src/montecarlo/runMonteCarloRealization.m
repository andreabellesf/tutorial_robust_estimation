function [estimation, results]  = runMonteCarloRealization(trial, scenario, cfg)

nFilters = numel(cfg.filters.enabled);
nEpochs = cfg.simulation.nEpochs;
[~, nState] = stateIndex();

results = struct();

results.estimationError = nan(nFilters, nState, nEpochs);
results.neesFullState = nan(nFilters, nEpochs);
results.neesPos = nan(nFilters, nEpochs);
results.neesVel = nan(nFilters, nEpochs);
results.residuals = nan(nFilters, scenario.gnss.nSatellites, nEpochs);

for m = 1:nFilters

    filtername = cfg.filters.enabled{m};

    switch filtername

        case 'EKF'

            estimation.(filtername) = runEKF( ...
                trial, scenario, cfg);

        case 'Huber'

            estimation.(filtername) = runRKF( ...
                trial, scenario, cfg, filtername);

        % case '...'

        otherwise

            error('Unknown filter: %s', filtername);

    end

    %% Store helping variables
    
    results.estimationError(m,:,:) = estimation.(filtername).errorEst;
    results.neesFullState(m,:) = estimation.(filtername).neesFullState;
    results.neesPos(m,:) = estimation.(filtername).neesPos;
    results.neesVel(m,:) = estimation.(filtername).neesVel;
    results.residuals(m,:,:) = estimation.(filtername).residuals;


end

end