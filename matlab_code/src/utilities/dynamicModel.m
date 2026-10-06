function [F, Q] = dynamicModel(dt, cfg)

%% State indexing
[idx, nx] = stateIndex();

%% Dynamic model and process noise
F = eye(nx);

switch cfg.filters.trajectory.type
    case 'constant_velocity'
        F = blkdiag( [eye(3), dt*eye(3); zeros(3), eye(3)], eye(nx-6));
end

F(idx.pos,idx.vel) = dt * eye(3);

% Process noise
Q = zeros(nx);

Fq = [zeros(3); dt*eye(3)];
QVelEnu  = diag(cfg.filters.velSigmaEnu(:).^2);

Qpv = Fq * QVelEnu * Fq.';

Q(idx.pos,idx.pos) = Qpv(1:3,1:3);
Q(idx.pos,idx.vel) = Qpv(1:3,4:6);

end