function truth = generateTrajectory(cfg)

%% Initialize reference solution for ground truth generation

dt = cfg.simulation.dt;
nCons = cfg.simulation.nCons;

% Create variables for the state --> position, velocity, clock offsets (one per GNSS constellation)
state_reference = nan( 6+nCons, cfg.simulation.nEpochs );  
state_reference(:,1) = [    cfg.trajectory.initialPosition(:) + cfg.trajectory.initPosSigma*randn(3,1); ... % random initialization of the initial position
                            cfg.trajectory.initialVelocity(:) + cfg.trajectory.initVelSigma*randn(3,1); ... % random initialization of the initial velocity
                            cfg.trajectory.initClkSigma*randn(nCons,1) ];                                   % random initialization of the clock offset(s)



%% Define motion model matrices

dt = cfg.simulation.dt;

switch cfg.trajectory.type
    case 'constant_velocity'
        F = [eye(3), dt*eye(3), zeros(3,nCons);
            zeros(3), eye(3), zeros(3,nCons);
            zeros(nCons, 3), zeros(nCons, 3), eye(nCons)];

        Fq = [0.5*dt^2*eye(3), zeros(3,nCons);                     
            dt*eye(3), zeros(3, nCons);
            zeros(nCons, 3), dt*eye(nCons)];

        Qw = blkdiag( diag(cfg.trajectory.velocitySigma(:).^2), cfg.trajectory.clkSigma^2*eye(nCons));

        Lw = chol(Qw,'lower');

    % case '...'
    otherwise
        error('unrecognized option for generating the trajectory')
end

%% Time recursion
for t = 2:cfg.simulation.nEpochs
    state_reference(:,t) = F*state_reference(:,t-1) + Fq*Lw*randn(3+nCons,1); % Reference solution

end

%% Store ground truth 
truth.position = state_reference(1:3,:);
truth.velocity = state_reference(4:6,:);
truth.clk = state_reference(7:end,:);
truth.x        = state_reference;

end