function resultsMC = runMonteCarlo(scenario, cfg)

nMC = cfg.monteCarlo.numRuns;
resultsMC = cell(1, nMC);

mcElapsed = zeros(nMC,1);
totalTimer = tic;

for mc = 1:nMC
    mcTimer = tic;

    % Reproducible seed for this realization
    rng(cfg.monteCarlo.baseSeed + mc);

    %% Generate realization-specific measurements
    trial = generateMonteCarloRealization( ...
        scenario, cfg);

    %% Add faults/outliers
    % if cfg.outliersOn
    %     % Add faults to "noisy" measurements and sv position and clock
    %     [ ] = gnss_obs_faults_injector( );
    % end

    %% Run all enabled filters
    resultsMC{mc} = runMonteCarloRealization( ...
        trial, cfg);

    %% Monte-Carlo timing parameters
   
    % Elapsed time for this Monte-Carlo realization
    mcElapsed(mc) = toc(mcTimer);

    if cfg.monteCarlo.showProgress
        fprintf('Monte Carlo run %d / %d | elapsed: %.3f s\n', mc, nMC, mcElapsed(mc));
    end

    
end

totalElapsed = toc(totalTimer);

fprintf('\nMonte-Carlo timing summary\n');
fprintf('--------------------------\n');
fprintf('Number of runs:       %d\n',nMC);
fprintf('Total elapsed time:   %s\n',formatElapsedTime(totalElapsed));
fprintf('Mean time per run:    %.3f s\n',mean(mcElapsed));

end