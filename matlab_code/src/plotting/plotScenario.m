function [] = plotScenario(scenario, example, cfg)

setCustomPlottingOptions();

% Reference trajectory plot
figure; hold on; grid on; box on; axis tight; 
plot( scenario.truth.position(1,:), scenario.truth.position(2,:),'LineWidth', 2 ); 
xlabel('East (m)'); ylabel('North (m)'); 
title('Ground truth trajectory');

% Velocity over time
figure; hold on; grid on; box on; axis tight;
plot(scenario.truth.velocity.', 'LineWidth', 2); 
xlabel('time (s)'); ylabel('velocity (m/s)'); 
legend('$v_{East}$','$v_{North}$','$v_{Up}$'); 
title('Ground truth velocity');

% GNSS Skyplot
[az, el] = plotGnssSkyplot(scenario.gnss.satellitePosition.ECEF.', ...
    cfg.trajectory.initialPosition.LLH, ...
    scenario.gnss.satelliteId, ...
    cfg); 

% true pseudorange error
figure; hold on; grid on; box on; 
plot(example.gnss.truePseudorangeError.', 'LineWidth', 1.5); 
xlabel('time (s)'); ylabel('true pseudorange error (m)'); 
xlim([1 cfg.simulation.nEpochs]); ylim([-3 3]);

end