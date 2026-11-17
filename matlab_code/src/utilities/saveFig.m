function saveFig(f,cfg,name)
    if cfg.save.printPlotProgress
        fprintf('[FIGURE] Exporting %s (keep open: %d)\n',name,cfg.save.keepFiguresOpen);
    end
    path=fullfile(cfg.paths.scenario,name);
    try
        saveas(f,[path '.fig']);
        saveas(f,[path '.svg']);
        if cfg.save.exportPDF,exportgraphics(f,[path '.pdf'],'ContentType','vector');end
    catch ME
        warning('Figure export issue (%s): %s',name,ME.message);
        saveas(f,[path '.fig']);
        saveas(f,[path '.svg']);
    end
    if ~cfg.save.keepFiguresOpen
        close(f);
    end
end