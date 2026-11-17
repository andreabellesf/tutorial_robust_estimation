function filter = runEKF(trial, scenario, cfg)
% Conventional EKF using GNSS pseudorange observations

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
    idxSvPerCons = trial.gnss.satelliteIdx(idxValidSat, :);
    satPos = trial.gnss.satellitePosition(idxValidSat,:);
    pseudorange = pseudorangeEpoch(idxValidSat);

    y = pseudorange(:);

    %% Prediction step
    
    [xPred,PPred] = predict(x, P, F, Q);

    %% Update step
    
    [xEst,PEst,residuals] = updateEKF(xPred, PPred, y, satPos, nObsPerEpoch, idxSvPerCons, cfg);

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