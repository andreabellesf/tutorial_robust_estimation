function [] = plotMetrics(scenario, metrics, outliersLog, cfg)

%% Plotting options
t = scenario.time;

% Colors
try
    C = orderedcolors("gem12");
catch
    C = lines(12);
end

%% Results MC -- Plot A: 3-D position error
% Solid lines show epoch-wise RMSE across MC runs.
% Transparent bands show the 5th--95th percentile interval.

figure; hold on; grid on; box on;

for iFilter = 1:metrics.nFilters

    filtername = cfg.filters.enabled{iFilter};

    plotBand(t, ...
        metrics.position.p05(iFilter,:), ...
        metrics.position.p95(iFilter,:), ...
        C(iFilter,:), 0.10);

    plot(t, metrics.position.rmse(iFilter,:), ...
        'LineWidth',2,'Color', C(iFilter,:), ...
        'DisplayName', filtername);

end

xlim([0 metrics.nEpochs]);

xlabel('Time [s]','Interpreter','latex');

ylabel('3D position RMSE [m]','Interpreter','latex');

title(sprintf(['Monte-Carlo position performance: \n RMSE lines and ', ...
     '5th--95th percentile bands (%d runs)'], metrics.nRuns),'Interpreter','latex');

legend('show','Location','northeast','NumColumns',1, ...
    'Interpreter','latex','FontSize',15);

set(gca, 'FontSize',15, 'TickLabelInterpreter','latex');

if cfg.outliers.enabled
    axs = findobj(gca, 'Type', 'axes');
    addFaultPatches(axs, outliersLog);
end

%% Results MC -- Plot B: position-only ANEES

figure; hold on; grid on; box on;

for iFilter = 1:metrics.nFilters

    filtername = cfg.filters.enabled{iFilter};

    plot(t, metrics.nees.position.nanees(iFilter,:), ...
        'LineWidth',2,'Color', C(iFilter,:), ...
        'DisplayName', filtername);

end

yline(metrics.nees.position.naneesExpected,'k-','Expected NEES = 1', ...
    'LineWidth',2,'HandleVisibility','off',...
    'Interpreter','latex', 'FontSize',13);


xlim([0 metrics.nEpochs]);

xlabel('Time [s]', 'Interpreter','latex');

ylabel('Position Normalized ANEES', 'Interpreter','latex');

title(sprintf('Position consistency over %d Monte-Carlo runs',metrics.nRuns), ...
    'Interpreter','latex');

legend('show','Location','northeast','NumColumns',1, ...
    'Interpreter','latex','FontSize',15);

set(gca, 'FontSize',15, 'TickLabelInterpreter','latex');

if cfg.outliers.enabled
    axs = findobj(gca, 'Type', 'axes');
    addFaultPatches(axs, outliersLog);
end

%% Results MC -- Plot C: full-state ANEES

figure; hold on; grid on; box on;

for iFilter = 1:metrics.nFilters

    filtername = cfg.filters.enabled{iFilter};

    plot(t, metrics.nees.fullState.nanees(iFilter,:), ...
        'LineWidth',2,'Color', C(iFilter,:), ...
        'DisplayName', filtername);

end

yline(metrics.nees.fullState.naneesExpected,'k-','Expected NEES = 1', ...
    'LineWidth',2,'HandleVisibility','off',...
    'Interpreter','latex', 'FontSize',13);


xlim([0 metrics.nEpochs]);

xlabel('Time [s]', 'Interpreter','latex');

ylabel('Full-state Normalized ANEES', 'Interpreter','latex');

title(sprintf('Full-state consistency over %d Monte-Carlo runs',metrics.nRuns), ...
    'Interpreter','latex');

legend('show','Location','northeast','NumColumns',1, ...
    'Interpreter','latex','FontSize',15);

set(gca, 'FontSize',15, 'TickLabelInterpreter','latex');

if cfg.outliers.enabled
    axs = findobj(gca, 'Type', 'axes');
    addFaultPatches(axs, outliersLog);
end

%% Results MC -- Plot D: Estimated residuals

figure; hold on; grid on; box on;

for iFilter = 1:metrics.nFilters

    filtername = cfg.filters.enabled{iFilter};

    plot(t, metrics.residuals.meanNorm(iFilter,:), ...
        'LineWidth',2,'Color', C(iFilter,:), ...
        'DisplayName', filtername);

end

xlim([0 metrics.nEpochs]);

xlabel('Time [s]', 'Interpreter','latex');

ylabel('Norm residuals', 'Interpreter','latex');

title(sprintf('Norm residuals over %d Monte-Carlo runs',metrics.nRuns), ...
    'Interpreter','latex');

legend('show','Location','northeast','NumColumns',1, ...
    'Interpreter','latex','FontSize',15);

set(gca, 'FontSize',15, 'TickLabelInterpreter','latex');

if cfg.outliers.enabled
    axs = findobj(gca, 'Type', 'axes');
    addFaultPatches(axs, outliersLog);
end


end