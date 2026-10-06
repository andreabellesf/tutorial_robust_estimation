function [result, estimationError, neesFullState, neesPos, neesVel, residuals]  = runMonteCarloRealization(trial, scenario, cfg)

nFilters = numel(cfg.filters.enabled);
nEpochs = cfg.simulation.nEpochs;
[~, nState] = stateIndex();

estimationError = nan(nFilters, nState, nEpochs);
neesFullState = nan(nFilters, nEpochs);
neesPos = nan(nFilters, nEpochs);
neesVel = nan(nFilters, nEpochs);
residuals = nan(nFilters, scenario.gnss.nSatellites, nEpochs);

for m = 1:nFilters

    filtername = cfg.filters.enabled{m};

    switch filtername

        case 'EKF'

            result.(filtername) = runEKF( ...
                trial, scenario, cfg);

        case 'Huber'

            result.(filtername) = runRKF( ...
                trial, scenario, cfg, filtername);

        % case '...'

        otherwise

            error('Unknown filter: %s', filtername);

    end

    %% Store helping variables
    
    estimationError(m,:,:) = result.(filtername).errorEst;
    neesFullState(m,:) = result.(filtername).neesFullState;
    neesPos(m,:) = result.(filtername).neesPos;
    neesVel(m,:) = result.(filtername).neesVel;
    residuals(m,:,:) = result.(filtername).residuals;


end

end