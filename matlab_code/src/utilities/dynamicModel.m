function [F, Q] = dynamicModel(dt, cfg)

%% State indexing
[idx, nx] = stateIndex();

%% Dynamic model and process noise
F = eye(nx);

switch cfg.filters.trajectory.type
    case 'constant_velocity'
        
        F = [eye(3), dt*eye(3);
            zeros(3), eye(3)];

        Fq = [zeros(3);
            dt*eye(3)];

        Qw = diag(cfg.trajectory.velocitySigma(:).^2);

        Q = Fq * Qw * Fq.';

end

% F(idx.pos,idx.vel) = dt * eye(3);

% % Process noise
% Q = zeros(nx);
% 
% Fq = [zeros(3); dt*eye(3)];
% QVelEnu  = diag(cfg.filters.velSigmaEnu(:).^2);
% 
% Qpv = Fq * QVelEnu * Fq.';
% 
% Q(idx.pos,idx.pos) = Qpv(1:3,1:3);
% Q(idx.pos,idx.vel) = Qpv(1:3,4:6);
% Q(idx.vel,idx.pos) = Qpv(4:6,1:3);
% Q(idx.vel,idx.vel) = Qpv(4:6,4:6);

% Q = zeros(nx);
% 
% G = [0.5*dt^2*eye(3);
%      dt*eye(3)];
% 
% Qa = diag(cfg.filters.accSigmaEnu(:).^2);
% 
% Qpv = G * Qa * G.';
% 
% Q(idx.pos,idx.pos) = Qpv(1:3,1:3);
% Q(idx.pos,idx.vel) = Qpv(1:3,4:6);
% Q(idx.vel,idx.pos) = Qpv(4:6,1:3);
% Q(idx.vel,idx.vel) = Qpv(4:6,4:6);

end