function filter = runRKF(trial, scenario, cfg, filtername)
% Conventional EKF using GNSS pseudorange observations

n = cfg.simulation.nEpochs;

%% State indexing and variable initialization
[idx, nx] = stateIndex();

x = zeros(nx, 1);
P = zeros(nx);

filter.xEst = zeros(nx,n);
filter.P = cell(1,n);
filter.info = cell(1,n);

filter.xEst = zeros(nx,n);
filter.P = cell(1,n);
filter.idx = idx;
errorEst = zeros(nx,n);
errorEstPos = zeros(3,n);
errorEstVel = zeros(3,n);
neesFullState = zeros(1,n);
neesPos = zeros(1,n);
neesVel = zeros(1,n);

%% Initial state
x(idx.pos) = cfg.filters.initialPosition;
x(idx.vel) = cfg.filters.initialVelocity;

P(idx.pos,idx.pos) = ...
    cfg.filters.initPosSigma^2 * eye(3);

P(idx.vel,idx.vel) = ...
    cfg.filters.initVelSigma^2 * eye(3);

%% Dynamic model
[F, Q] = dynamicModel(cfg.simulation.dt, cfg);

%% Time loop
for k = 1:n

    %% Select valid satellite positions and GNSS measurement for current epoch k

    pseudorangeEpoch  = trial.gnss.pseudorange(:,k);
    [idxValidSat,~,nObsPerEpoch] = makeSvIndexEpoch(trial.gnss.satellitePosition.ENU, ...
                                                        pseudorangeEpoch);
    satPos = trial.gnss.satellitePosition.ENU(:, idxValidSat);
    pseudorange = pseudorangeEpoch(idxValidSat);

    y = pseudorange(:);

    %% Prediction step
    
    [xPred,PPred] = predict(x, P, F, Q);

    %% Update step
    
    [xEst,PEst,info,residuals] = updateRKF(xPred, PPred, y, satPos, nObsPerEpoch, cfg, filtername);

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
    filter.weights(:, k) = info.weights;
    filter.iterations(k) = info.iterations;
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