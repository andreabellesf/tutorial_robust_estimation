function [x,P,residuals] = updateEKF(xPred, PPred, y, satPos, nObs, idxSvPerCons, cfg)

    nx = length(xPred);

    % Make sure measurement vector is a column
    y = y(:);

    [hx,H,R] = observationModel(xPred, satPos, nObs, idxSvPerCons, cfg);

    residuals = y - hx;

    S = H * PPred * H' + R;
    K = PPred * H' / S;

    x = xPred + K * residuals;

    I = eye(nx);
    P = (I - K * H) * PPred;

end