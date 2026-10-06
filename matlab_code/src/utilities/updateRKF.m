function [xPost,PPost,info,residuals] = updateRKF(xPred, PPred, y, satPos, nObsPerEpoch, cfg, filtername)

    [idx, nx] = stateIndex();    
    m  = length(y);

    % Make sure measurement vector is a column
    y = y(:);

    [~,H,R] = observationModel(xPred(idx.pos), satPos, nObsPerEpoch, cfg);

    [L,~] = chol(R,'lower');

    % Prior information matrix
    Yminus = PPred \ eye(nx);

    % Initialization
    W = eye(m);
    w = diag(W);

    xIter = xPred;
    errorState = zeros(nx,1);

    % Robust EKF loop
    for it = 1:cfg.filters.nIterRKF

        [h,~,~] = observationModel(xIter(idx.pos), satPos, nObsPerEpoch, cfg);
        
        residuals = y - h;

        newRminus = L.' \ W / L;

        HtRminus = H.' * newRminus;
        HtRminusH = HtRminus * H;

        yplus = HtRminus * residuals + HtRminusH * errorState;
        Yplus = Yminus + HtRminusH;

        errorState = ( Yplus\yplus);

        xNew = xPred + errorState;

        u = L \ residuals;

        w = robustWeights(u,filtername,cfg.filters.tuning);
        w = w(:);
        W = diag(w);

        % Convergence
        dxConv = norm(xNew-xIter);
                     
        xIter = xNew;

        if dxConv < cfg.filters.stateTol 
            break
        end

    end

    % Final state
    xPost = xIter;
    PPost = Yplus \ eye(nx);

    % Information output
    info.iterations   = it;
    info.weights      = w;

end