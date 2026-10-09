function metrics = computeMetrics(scenario, mcResults, cfg)

error_pos = mcResults{1}.EKF.x(1:3, :) - scenario.truth.position;
error_vel = mcResults{1}.EKF.x(4:6, :) - scenario.truth.velocity;

metrics.EKF.rmse_pos = sqrt(mean(error_pos.^2, 1));
metrics.EKF.rmse_vel = sqrt(mean(error_vel.^2, 1));

figure; plot(metrics.EKF.rmse_pos);
figure; plot(metrics.EKF.rmse_vel);

end