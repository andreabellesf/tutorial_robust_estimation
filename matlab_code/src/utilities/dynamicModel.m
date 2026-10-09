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

end
