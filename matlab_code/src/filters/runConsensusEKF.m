function filter = runConsensusEKF(trial, scenario, cfg)
% Outlier detection for GNSS pseudorange measurements based on RANSAC

n = cfg.simulation.nEpochs;
nCons = cfg.simulation.nCons;

%% Check dimensions
if ~isequal(size(trial.gnss.pseudorange, 2), n)
    error('pseudorange must be an nObs x nEpochs matrix.');
end

if ~isequal(size(trial.gnss.satellitePosition, 2), 3)
    error('satellitePosition must be an nObs x 3 matrix.');
end

%% State indexing and variable initialization
[idx, nx] = stateIndex(nCons);

x = zeros(nx, 1);
P = zeros(nx);

filter.xEst = zeros(nx,n);
filter.P = cell(1,n);
filter.idx = idx;
errorEst = zeros(nx,n);
errorEstPos = zeros(3,n);
errorEstVel = zeros(3,n);
neesFullState = zeros(1,n);
neesPos = zeros(1,n);
neesVel = zeros(1,n);

sppState.x = zeros(nx, 1);
sppState.P = zeros(nx);

%% Initialization state
% Iniial mean of the state
x(idx.pos) = cfg.filters.initialPosition;
x(idx.vel) = cfg.filters.initialVelocity;
x(idx.clk) = zeros(nCons,1);

% Initial covariance matrix
P(idx.pos,idx.pos) = cfg.filters.initPosSigma^2 * eye(3);
P(idx.vel,idx.vel) = cfg.filters.initVelSigma^2 * eye(3);
P(idx.clk,idx.clk) = cfg.filters.initClkSigma^2 * eye(nCons);


%% Dynamic model
[F, Q] = dynamicModel(cfg.simulation.dt, cfg);

%% Time loop
for k = 1:n

    %% Select valid satellite positions and GNSS measurement for current epoch k

    pseudorangeEpoch  = trial.gnss.pseudorange(:,k);
    [idxValidSat,~,nObsPerEpoch] = makeSvIndexEpoch(trial.gnss.satellitePosition, ...
                                                        pseudorangeEpoch);
    clockMatrix = trial.gnss.satelliteIdx(idxValidSat, :);
    satPos = trial.gnss.satellitePosition(idxValidSat,:);
    pseudorange = pseudorangeEpoch(idxValidSat);

    y = pseudorange(:);
    residuals = nan(nObsPerEpoch,1);

    %% Prediction step
    
    [xPred,PPred] = predict(x, P, F, Q);

    %% Update step

    % Get SPP for cross-checking
    [posSPP, clkSPP, ~, ~, ~, ~] = MultiGNSS_Snapshot( ...
    y, satPos, clockMatrix);
    sppState.x(idx.pos) = posSPP;
    sppState.x(idx.clk) = clkSPP;

    [bestInliers, info] = snapshotRANSAC( ...
    y, satPos, clockMatrix, xPred, PPred, sppState, cfg); 

    [xEst,PEst,residuals_best] = updateEKF(xPred, PPred, y(bestInliers), satPos(bestInliers,:), length(bestInliers), clockMatrix(bestInliers, :), cfg);
    residuals(bestInliers) = residuals_best;
    
    %% Compute errors and NEES

    [errorEst(:, k), ...
        errorEstPos(:, k), ...
        errorEstVel(:, k)  ...
        ] = computeEstimationErrors( xEst, ...
                                     scenario.truth.x(:, k),     ...
                                     idx);

    [neesFullState(:, k), ...
    neesPos(:, k), ...
    neesVel(:, k)  ...
    ] = computeNees( errorEst(:, k), ...
                     PEst,     ...
                     idx);

    %% Store estimated state

    filter.xEst(:, k) = xEst;
    filter.P{k} = PEst;
    filter.residuals(:, k) = residuals;
    filter.nObsPerEpoch(k) = nObsPerEpoch;

    %% Set for next iteration
    x = xEst;
    P = PEst;

end

%% Store errors and NEES

filter.errorEst = errorEst;
filter.errorEstPos = errorEstPos;
filter.errorEstVel = errorEstVel;
filter.neesFullState = neesFullState;
filter.neesPos = neesPos;
filter.neesVel = neesVel;

end