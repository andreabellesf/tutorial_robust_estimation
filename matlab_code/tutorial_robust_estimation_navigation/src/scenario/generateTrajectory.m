function truth = generateTrajectory(cfg)

%% Initialize reference solution for ground truth generation
state_reference = nan( 6, cfg.simulation.nEpochs ); 
state_reference(:,1) = [ cfg.trajectory.initialPosition(:); cfg.trajectory.initialVelocity(:) ]; 

%% Define motion model matrices
switch cfg.trajectory.type
    case 'constant_velocity'
        F = [ eye(3), cfg.simulation.dt*eye(3); zeros(3), eye(3) ];
        Fq = [ zeros(3); cfg.simulation.dt*eye(3) ]; % This is for a first-order integration. It is possible using the second order with Fq = [ dt^2/2*eye(3); dt*eye(3) ];
        Q = diag( eye(3) * cfg.trajectory.velocitySigma(:).^2 );
    % case '...'
    otherwise
        error('unrecognized option for generating the trajectory')
end

%% Time recursion
for t = 2:cfg.simulation.nEpochs
    state_reference(:,t) = F*state_reference(:,t-1) + Fq*sqrtm(Q)*randn( 3,1 ); % Reference solution
end

%% Store ground truth 
truth.position = state_reference(1:3,:);
truth.velocity = state_reference(4:6,:);

end