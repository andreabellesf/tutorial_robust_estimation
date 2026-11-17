function [xPost,PPost,info,residuals] = updateRKF(xPred, PPred, y, satPos, nObs, clkMatrix, cfg, filtername)

    [idx, nx] = stateIndex(cfg.simulation.nCons);    

    % Make sure measurement vector is a column
    y = y(:);

    [~,H,R] = observationModel(xPred, satPos, nObs, clkMatrix, cfg);

    [L,~] = chol(R,'lower');

    % Prior information matrix
    Yminus = PPred \ eye(nx);

    % Initialization
    W = eye(nObs);
    w = diag(W);

    xIter = xPred;
    errorState = zeros(nx,1);

    % Robust EKF loop
    for it = 1:cfg.filters.rkf.maxIter

        [h,H,~] = observationModel(xIter, satPos, nObs, clkMatrix, cfg);
        
        residuals = y - h;

        newRminus = L.' \ W / L;

        HtRminus = H.' * newRminus;
        HtRminusH = HtRminus * H;

        yplus = HtRminus * residuals + HtRminusH * errorState;
        Yplus = Yminus + HtRminusH;

        errorState = ( Yplus\yplus);

        xNew = xPred + errorState;

        u = L \ residuals;

        w = robustWeights(u,filtername,cfg.filters.rkf);
        w = w(:);
        W = diag(w);

        % Convergence
        dxConv = norm(xNew-xIter);                     
        
        xIter = xNew;

        if dxConv < cfg.filters.rkf.stateTol 
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