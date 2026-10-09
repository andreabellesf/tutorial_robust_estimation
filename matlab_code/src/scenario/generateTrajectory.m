function truth = generateTrajectory(cfg)

%% Initialize reference solution for ground truth generation
state_reference = nan( 6, cfg.simulation.nEpochs ); 
state_reference(:,1) = [ cfg.trajectory.initialPosition.ENU(:); cfg.trajectory.initialVelocity.ENU(:) ]; 

%% Define motion model matrices
switch cfg.trajectory.type
    case 'constant_velocity'
        F = [eye(3), cfg.simulation.dt*eye(3);
            zeros(3), eye(3)];

        Fq = [zeros(3);
            cfg.simulation.dt*eye(3)];

        Qw = diag(cfg.trajectory.velocitySigma(:).^2);

        Lw = chol(Qw,'lower');

    % case '...'
    otherwise
        error('unrecognized option for generating the trajectory')
end

%% Time recursion
for t = 2:cfg.simulation.nEpochs
    state_reference(:,t) = F*state_reference(:,t-1) + Fq*Lw*randn(3,1); % Reference solution
end

%% Store ground truth 
truth.position = state_reference(1:3,:);
truth.velocity = state_reference(4:6,:);
truth.x        = state_reference;

end