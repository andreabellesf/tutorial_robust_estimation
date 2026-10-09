function [] = plotMonteCarlo(scenario, data, outliersLog, cfg)

% Difference between faulty and nominal observations
deltaPR = data{cfg.plot.selectedMc}.gnss.pseudorange - ...
          data{cfg.plot.selectedMc}.gnss.noisyPseudorange;

% Maximum absolute difference per epoch
deltaEpoch = squeeze(max(abs(deltaPR), [], 1));

% For multiple frequencies, reduce across frequencies
if ~isvector(deltaEpoch)
    deltaEpoch = max(deltaEpoch, [], 2);
end

% Plot actual injected measurement differences
figure;

stairs(scenario.time, deltaEpoch, 'LineWidth', 1.5);
hold on;

xline(outliersLog(1).startTime, '--r', 'Fault start');
xline(outliersLog(1).endTime, '--r', 'Fault end');

xlabel('Time [s]');
ylabel('Maximum pseudorange difference [m]');
grid on;

end