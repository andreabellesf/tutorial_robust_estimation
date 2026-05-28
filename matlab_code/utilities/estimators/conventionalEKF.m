function [x, P, innov, S] = conventionalEKF(x, P, z, satPos, Q, R, dt)
% conventionalEKF 
% Simple GNSS EKF using pseudorange observations
%
% State:
%   x = [px; py; pz; vx; vy; vz;]
%
% Inputs:
%   x      : current state [6x1]
%   P      : current covariance [6x6]
%   z      : pseudorange observations [nx1]
%   satPos : satellite positions [3xn]
%   Q      : process noise covariance [6x6]
%   R      : measurement noise covariance [nxn] or scalar
%   dt     : time step scalar
%
% Outputs:
%   x      : updated state
%   P      : updated covariance
%   innov  : measurement residual
%   S      : innovation covariance

    n = size(z, 1);

    if isscalar(R)
        R = R * eye(n);
    end

    % -------------------------
    % Prediction step
    % -------------------------
    
    % Construct process model jacobian matrix
    F = [ eye(3), dt*eye(3); zeros(3), eye(3) ];        % constant vel model
    
    % Predict state
    xPred = F * x;

    % Predict covariance matrix
    PPred = F * P * F' + Q;

    % -------------------------
    % Measurement prediction
    % -------------------------
    rxPos = xPred(1:3);
    rxVel = xPred(4:6);

    zPred = zeros(n, 1);
    H = zeros(n, 6);

    for i = 1:n
        d = rxPos - satPos(:, i);
        rho = norm(d);

        zPred(i) = rho;

        % Construct measurement jacobian matrix 
        H(i, 1:3) = d' / rho;
        H(i, 4:6) = zeros(1, 3);
    end

    % -------------------------
    % EKF update
    % -------------------------

    % Compute residuals
    innov = z - zPred;

    % Compute Kalman Gain
    S = H * PPred * H' + R;
    K = PPred * H' / S;

    % Update state
    x = xPred + K * innov;

    % Update covariance matrix
    I = eye(size(P));
    P = (I - K * H) * PPred; 
end