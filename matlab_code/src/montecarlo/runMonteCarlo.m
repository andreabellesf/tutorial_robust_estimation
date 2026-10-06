function [mcData, mcResults] = runMonteCarlo(scenario, cfg)

nRuns = cfg.monteCarlo.numRuns;
nFilters = numel(cfg.filters.enabled);
nEpochs = cfg.simulation.nEpochs;
nObs = scenario.gnss.nSatellites;
[~, nState] = stateIndex();

mcResults = struct();
mcData = cell(1, nRuns);

mcResults.estimationError = nan(nFilters, nState, nEpochs, nRuns);
mcResults.neesFullSate = nan(nFilters, nEpochs, nRuns);
mcResults.neesPos = nan(nFilters, nEpochs, nRuns);
mcResults.neesVel = nan(nFilters, nEpochs, nRuns);
mcResults.residuals = nan(nFilters, nObs, nEpochs, nRuns);

mcElapsed = zeros(nRuns,1);
totalTimer = tic;

for iRun = 1:nRuns
    mcTimer = tic;

    % Reproducible seed for this realization
    rng(cfg.monteCarlo.baseSeed + iRun);

    %% Generate realization-specific measurements
    trial = generateMonteCarloRealization( ...
        scenario, cfg);

    %% Add faults/outliers
    % if cfg.outliersOn
    %     % Add faults to "noisy" measurements and sv position and clock
    %     [ ] = gnss_obs_faults_injector( );
    % end

    %% Run all enabled filters
    [mcData{iRun}, ...
        estimationError, ...
        neesFullState, ...
        neesPos, ...
        neesVel, ...
        residuals] = runMonteCarloRealization( ...
        trial, scenario, cfg);

    %% Monte-Carlo timing parameters
   
    % Elapsed time for this Monte-Carlo realization
    mcElapsed(iRun) = toc(mcTimer);

    if cfg.monteCarlo.showProgress
        fprintf('Monte Carlo run %d / %d | elapsed: %.3f s\n', iRun, nRuns, mcElapsed(iRun));
    end

    %% Rearrange variables
    mcResults.estimationError(:, :, :, iRun) = estimationError;
    mcResults.neesFullState(:, :, iRun) = neesFullState;
    mcResults.neesPos(:, :, iRun) = neesPos;
    mcResults.neesVel(:, :, iRun) = neesVel;
    mcResults.residuals(:, :, :, iRun) = residuals;   

    
end

% Elapsed time for the complete Monte-Carlo simulation
totalElapsed = toc(totalTimer);

fprintf('\nMonte-Carlo timing summary\n');
fprintf('--------------------------\n');
fprintf('Number of runs:       %d\n',nRuns);
fprintf('Total elapsed time:   %s\n',formatElapsedTime(totalElapsed));
fprintf('Mean time per run:    %.3f s\n',mean(mcElapsed));


end