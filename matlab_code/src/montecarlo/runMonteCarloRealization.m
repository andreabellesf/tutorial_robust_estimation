function result = runMonteCarloRealization(trial, cfg)

nFilters = numel(cfg.filters.enabled);


for m = 1:nFilters

    filter = cfg.filters.enabled{m};

    switch filter

        case 'EKF'

            result.EKF = runEKF( ...
                trial, cfg);

        case 'RKF'

            result.RKF = runRKF( ...
                trial, cfg);

        % case '...'

        otherwise

            error('Unknown filter: %s', filter);

    end

    %% Compute errors

    %% Store results

end

end