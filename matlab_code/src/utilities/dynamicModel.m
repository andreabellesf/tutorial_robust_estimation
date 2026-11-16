function [F, Q] = dynamicModel(dt, cfg)

%% State indexing
nCons = cfg.filters.nCons;
[idx, nx] = stateIndex(nCons);

%% Dynamic model and process noise
F = eye(nx);


switch cfg.filters.trajectory.type
    case 'constant_velocity'
        
        F = [eye(3), dt*eye(3), zeros(3,nCons);
            zeros(3), eye(3), zeros(3,nCons);
            zeros(nCons, 3), zeros(nCons, 3), eye(nCons)];

        Fq = [0.5*dt^2*eye(3), zeros(3,nCons);                     
            dt*eye(3), zeros(3, nCons);
            zeros(nCons, 3), dt*eye(nCons)];

        Qw = blkdiag( diag(cfg.filters.velSigma(:).^2), cfg.filters.clkSigma^2*eye(nCons));

        Q = Fq * Qw * Fq.';

end



end
