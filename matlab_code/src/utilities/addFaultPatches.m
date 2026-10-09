function addFaultPatches(ax, faultLog)
    % Create grey patches for faults (if present)
    % Extract intervals from fault log
    intervals = [[faultLog.startTime]' [faultLog.endTime]'];
    % Current y-axis limits
    yl = ylim(ax);
    % Add one patch per fault interval
    for i = 1:size(intervals, 1)
        x1 = intervals(i, 1);
        x2 = intervals(i, 2);
        p = patch(ax, ...
            [x1 x2 x2 x1], ...
            [yl(1) yl(1) yl(2) yl(2)], ...
            [0.7 0.7 0.7], ...
            'FaceAlpha', 0.6, ...
            'EdgeColor', 'none', ...
            'HandleVisibility', 'off');
        uistack(p, 'bottom');
    end
end