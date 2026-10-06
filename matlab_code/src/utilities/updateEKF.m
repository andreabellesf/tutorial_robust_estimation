function [x,P,residuals] = updateEKF(xPred, PPred, y, satPos, nObsPerEpoch, cfg)

    nx = length(xPred);

    % Make sure measurement vector is a column
    y = y(:);

    predPos = xPred(1:3);

    [hx,H,R] = observationModel(predPos, satPos, nObsPerEpoch, cfg);

    residuals = y - hx;

    S = H * PPred * H' + R;
    K = PPred * H' / S;

    x = xPred + K * residuals;

    I = eye(nx);
    P = (I - K * H) * PPred;

end