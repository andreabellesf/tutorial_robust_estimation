function filter = runRKF(trial, cfg)
% Conventional EKF using GNSS pseudorange observations

n = cfg.simulation.nEpochs;

%% State indexing
[idx, nx] = stateIndex();

x = zeros(nx, 1);
P = zeros(nx);

filter.x = zeros(nx,n);
filter.P = cell(1,n);

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
    [idxValidSat,~,nObsPerEpoch] = makeSvIndexEpoch(trial,pseudorangeEpoch);
    satPos = trial.gnss.satellitePosition(1:3, idxValidSat);
    pseudorange = pseudorangeEpoch(idxValidSat);

    y = pseudorange(:);

    %% Prediction step
    
    xPred = F * x;
    PPred = F * P * F' + Q;

    predPos = xPred(1:3);
    predVel = xPred(4:6);

    
    %% EKF update
    
    [hx,H,R] = observationModel(predPos, satPos, nObsPerEpoch, cfg);

    residuals = y - hx;

    S = H * PPred * H' + R;
    K = PPred * H' / S;

    x = xPred + K * residuals;

    I = eye(size(P));
    P = (I - K * H) * PPred; 

    %% Store estimated state

    filter.x(:, k) = x;
    filter.P{k} = P;

end