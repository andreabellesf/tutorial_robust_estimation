function [] = plotScenario(scenario, example, cfg)

setCustomPlottingOptions();

% Reference trajectory plot
figure; hold on; grid on; box on; plot( scenario.truth.position(1,:), scenario.truth.position(2,:) ); xlabel('East (m)'); ylabel('North (m)'); axis tight; title('Ground truth trajectory');
% velocity over time
figure; hold on; grid on; box on; plot(scenario.truth.velocity.'); xlabel('time (s)'); ylabel('velocity (m/s)'); legend('$v_{East}$','$v_{North}$','$v_{Up}$'); axis tight; title('Ground truth velocity');
% true pseudorange error
figure; hold on; grid on; box on; plot(example.gnss.truePseudorangeError.'); xlabel('time (s)'); ylabel('true pseudorange error (m)'); xlim([1 cfg.simulation.nEpochs]); ylim([-3 3]);

end