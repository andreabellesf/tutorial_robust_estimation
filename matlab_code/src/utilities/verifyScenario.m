function [] = verifyScenario(scenario, cfg)

% Verification 
positionEstimates = zeros(3,cfg.simulation.nEpochs);
estimatedResiduals = zeros(scenario.gnss.nSatellites,cfg.simulation.nEpochs);
for t=1:cfg.simulation.nEpochs
    xnow = positionEstimates(1:3, t);
    for iterations=1:10
        hx = vecnorm( scenario.gnss.satellitePositions(1:3,:) - repmat( xnow, 1, scenario.gnss.nSatellites), 2, 1 ).';
        H = - [ scenario.gnss.satellitePositions(1:3,:) - xnow].' ./ vecnorm( scenario.gnss.satellitePositions(1:3,:) - repmat( xnow, 1, scenario.gnss.nSatellites), 2, 1 ).'; 
        xnow = xnow + (H.'*H)\H.'*(scenario.gnss.pseudoranges(:,t) - hx);
    end
    estimatedResiduals(:,t) = scenario.gnss.pseudoranges(:,t) - hx;
    positionEstimates(:,t) = xnow;
end

error = positionEstimates - scenario.truth.position;
rmse = sqrt(sum(error.^2, 1)/3);
figure; hold on; grid on; box on; plot(rmse); xlabel('time (s)'); ylabel('position RMSE (m)');

figure; hold on; grid on; box on; plot(scenario.gnss.trueResiduals.'); xlabel('time (s)'); ylabel('true residuals (m)'); xlim([1 cfg.simulation.nEpochs]); ylim([-3 3]);
figure; hold on; grid on; box on; plot(estimatedResiduals.'); xlabel('time (s)'); ylabel('estimated residuals (m)'); xlim([1 cfg.simulation.nEpochs]); ylim([-3 3]);
figure; hold on; grid on; box on; plot(scenario.gnss.trueResiduals.' - estimatedResiduals.'); xlabel('time (s)'); ylabel('error true - estimated residuals (m)'); xlim([1 cfg.simulation.nEpochs]); ylim([-1 1]);

% Verification 
estimatedResiduals_2 = zeros(scenario.gnss.nSatellites,cfg.simulation.nEpochs);
for t=1:cfg.simulation.nEpochs
    hx = vecnorm( scenario.gnss.satellitePositions(1:3,:) - repmat( scenario.truth.position(:,t), 1, scenario.gnss.nSatellites), 2, 1 ).';
    estimatedResiduals_2(:,t) = scenario.gnss.pseudoranges(:,t) - hx;
end

figure; hold on; grid on; box on; plot(scenario.gnss.trueResiduals.'); xlabel('time (s)'); ylabel('true residuals (m)'); xlim([1 cfg.simulation.nEpochs]); ylim([-3 3]);
figure; hold on; grid on; box on; plot(estimatedResiduals_2.'); xlabel('time (s)'); ylabel('estimated residuals (m)'); xlim([1 cfg.simulation.nEpochs]); ylim([-3 3]);
figure; hold on; grid on; box on; plot(scenario.gnss.trueResiduals.' - estimatedResiduals_2.'); xlabel('time (s)'); ylabel('error true - estimated residuals (m)'); xlim([1 cfg.simulation.nEpochs]); ylim([-1 1]);

end