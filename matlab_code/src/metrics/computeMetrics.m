function metrics = computeMetrics(mcEstimationResults, cfg)

%COMPUTEMETRICS Compute Monte Carlo navigation performance metrics.
%
% INPUTS:
%   mcResults.estimationError : [nFilters x nEpochs x nState x nRuns]
%
%   cfg.filters.names      : filter names, e.g.
%                            {'EKF','UKF','WLS'}
%
% OUTPUT:
%   metrics.rmse           : [nFilters x nState x nEpochs]
%   metrics. ...           : [nFilters x nState x nEpochs]
%
% Dimension convention:
%
%   1 -> filter
%   2 -> state
%   3 -> epoch
%   4 -> Monte Carlo run


%% Input

err = mcEstimationResults.estimationError;
neesFullState = mcEstimationResults.neesFullState;
neesPos = mcEstimationResults.neesPos;
neesVel = mcEstimationResults.neesVel;
residuals = mcEstimationResults.residuals;

[idx, ~] = stateIndex();
[nFilters, nState, nEpochs, nRuns] = size(err);
nPos = numel(idx.pos);
nVel = numel(idx.vel);

%% Store useful information

metrics.nFilters = nFilters;
metrics.nState   = nState;
metrics.nEpochs  = nEpochs;
metrics.nRuns    = nRuns;

if cfg.metrics.computeRMSE

    %% RMSE versus time
    %
    % For every:
    %   - state
    %   - epoch
    %   - filter
    %
    % average over Monte Carlo runs (dimension 4).
    
    metrics.rmse = sqrt(mean(err.^2, 4));
    
    % Result:
    %
    % size(metrics.rmse)
    %
    %   [nState x nEpochs x nFilters]
    
    
    %% Overall RMSE
    %
    % Collapse both:
    %
    %   epoch -> dimension 3
    %   MC    -> dimension 4
    %
    % while keeping state and filter.
    
    metrics.rmseOverall = ...
        sqrt(mean(err.^2, [3 4]));
    
    % Result:
    %
    %   [nState x 1 x nFilters]
    
    %% Position RMSE and percentiles
    
    posErr = err(:,idx.pos,:,:);
    
    % ||position error||^2
    posErrSquared = sum(posErr.^2, 2);
    
    % Average over Monte Carlo dimension
    metrics.position.rmse = ...
        squeeze(sqrt(mean(posErrSquared, 4)));
    
    % Position error magnitude
    posErrNorm = sqrt(posErrSquared);
    
    % Percentiles across Monte Carlo runs
    metrics.position.p05 = ...
        prctile(posErrNorm, 5, 4);
    
    metrics.position.p50 = ...
        prctile(posErrNorm, 50, 4);
    
    metrics.position.p95 = ...
        prctile(posErrNorm, 95, 4);
    
    
    % Dimensions:
    %   [nFilters x nEpochs]
    
    
    %% Velocity RMSE
    
    velErr = err(:,idx.vel,:,:);
    
    velErrSquared = sum(velErr.^2, 2);
    
    metrics.velocity.rmse = ...
        squeeze(sqrt(mean(velErrSquared, 4)));
    
    % Position error magnitude
    velErrNorm = sqrt(velErrSquared);
    
    % Percentiles across Monte Carlo runs
    metrics.velocity.p05 = ...
        prctile(velErrNorm, 5, 4);
    
    metrics.velocity.p50 = ...
        prctile(velErrNorm, 50, 4);
    
    metrics.velocity.p95 = ...
        prctile(velErrNorm, 95, 4);
    
    % Dimensions:
    %   [nFilters x nEpochs]
end

if cfg.metrics.computeNEES

    %% Average NEES (ANEES) and Normalized ANEES (NANEES) across Monte Carlo runs
    %
    % Normalized ANEES = ANEES / number of states
    %
    % Expected value for a consistent filter = 1.
    
    
    metrics.nees.fullState.anees = ...
        mean(neesFullState, 3, 'omitnan');
    
    metrics.nees.position.anees = ...
        mean(neesPos, 3, 'omitnan');
    
    metrics.nees.velocity.anees = ...
        mean(neesVel, 3, 'omitnan');


    
    metrics.nees.fullState.nanees = metrics.nees.fullState.anees / nState;
    metrics.nees.position.nanees = metrics.nees.position.anees / nPos;
    metrics.nees.velocity.nanees = metrics.nees.velocity.anees / nVel;
 
    % Dimensions:
    %   [nFilters x nEpochs]

    %% Expected ANEES and NANEES
    %  ==============================================================

    metrics.nees.fullState.aneesExpected  = nState;
    metrics.nees.position.aneesExpected = nPos;
    metrics.nees.velocity.aneesExpected = nVel;

    metrics.nees.fullState.naneesExpected  = 1;
    metrics.nees.position.naneesExpected = 1;
    metrics.nees.velocity.naneesExpected = 1;
    
    %% 95% confidence bounds for average NEES
    
    alpha = cfg.metrics.alpha;
    
    % Full state
    metrics.nees.fullState.lowerBound = ...
        chi2inv(alpha/2, nRuns*nState) / nRuns;
    
    metrics.nees.fullState.upperBound = ...
        chi2inv(1-alpha/2, nRuns*nState) / nRuns;
    
    
    % Position
    metrics.nees.position.lowerBound = ...
        chi2inv(alpha/2, nRuns*nPos) / nRuns;
    
    metrics.nees.position.upperBound = ...
        chi2inv(1-alpha/2, nRuns*nPos) / nRuns;
    
    
    % Velocity
    metrics.nees.velocity.lowerBound = ...
        chi2inv(alpha/2, nRuns*nVel) / nRuns;
    
    metrics.nees.velocity.upperBound = ...
        chi2inv(1-alpha/2, nRuns*nVel) / nRuns;

end

%% Average residuals over MC simulations

% Euclidean norm across measurements
residualsNorm = sqrt(sum(residuals.^2, 1));
% [nFilters x nEpochs x 1 x nRuns]

% Average norm across Monte Carlo runs
metrics.residuals.meanNorm = squeeze(mean(residualsNorm, 4, 'omitnan'));
% [nFilters x nEpochs]


end

