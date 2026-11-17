function [mcEstimationFilters, mcEstimationResults, mcData, outliersLog] = runMonteCarlo(scenario, cfg)

nRuns = cfg.monteCarlo.numRuns;
nFilters = numel(cfg.filters.enabled);
nEpochs = cfg.simulation.nEpochs;
nObs = scenario.gnss.nSatellites;
nCons = cfg.simulation.nCons;
[~, nState] = stateIndex(nCons);
outliersLog = [];

mcEstimationResults = struct();
mcEstimationFilters = cell(1, nRuns);
mcData = cell(1, nRuns);

mcEstimationResults.estimationError = nan(nFilters, nState, nEpochs, nRuns);
mcEstimationResults.neesFullSate = nan(nFilters, nEpochs, nRuns);
mcEstimationResults.neesPos = nan(nFilters, nEpochs, nRuns);
mcEstimationResults.neesVel = nan(nFilters, nEpochs, nRuns);
mcEstimationResults.residuals = nan(nFilters, nObs, nEpochs, nRuns);


mcElapsed = zeros(nRuns,1);
totalTimer = tic;

for iRun = 1:nRuns
    mcTimer = tic;

    % Reproducible seed for this realization
    rng(cfg.monteCarlo.baseSeed + iRun);

    %% Inject outliers / faults into GNSS measurements
    
    % Generate realization-specific measurements
    trial = generateNoise( scenario, cfg); 

    %% Run all enabled filters
    [estimationFilters, ...
        estimationResults] = runMonteCarloRealization( ...
        trial, scenario, cfg);

    %% Monte-Carlo timing parameters
   
    % Elapsed time for this Monte-Carlo realization
    mcElapsed(iRun) = toc(mcTimer);

    if cfg.monteCarlo.showProgress
        fprintf('Monte Carlo run %d / %d | elapsed: %.3f s\n', iRun, nRuns, mcElapsed(iRun));
    end

    %% Rearrange variables
    mcEstimationResults.estimationError(:, :, :, iRun) = estimationResults.estimationError;
    mcEstimationResults.neesFullState(:, :, iRun) = estimationResults.neesFullState;
    mcEstimationResults.neesPos(:, :, iRun) = estimationResults.neesPos;
    mcEstimationResults.neesVel(:, :, iRun) = estimationResults.neesVel;
    mcEstimationResults.residuals(:, :, :, iRun) = estimationResults.residuals;  

    mcEstimationFilters{iRun} = estimationFilters;

    mcData{iRun} = trial;

    
end

% Elapsed time for the complete Monte-Carlo simulation
totalElapsed = toc(totalTimer);

fprintf('\nMonte-Carlo timing summary\n');
fprintf('--------------------------\n');
fprintf('Number of runs:       %d\n',nRuns);
fprintf('Total elapsed time:   %s\n',formatElapsedTime(totalElapsed));
fprintf('Mean time per run:    %.3f s\n',mean(mcElapsed));

end