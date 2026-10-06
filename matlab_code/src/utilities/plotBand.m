function plotBand(x,lower,upper,color,alphaValue,ax)
% Draw a percentile envelope without adding it to the legend.

    if nargin < 6 || isempty(ax)
        ax = gca;
    end

    x = x(:).';
    lower = lower(:).';
    upper = upper(:).';

    good = isfinite(x) & isfinite(lower) & isfinite(upper);
    x = x(good);
    lower = lower(good);
    upper = upper(good);

    if isempty(x)
        return;
    end

    fill(ax,[x fliplr(x)],[lower fliplr(upper)],color, ...
        'FaceAlpha',alphaValue, ...
        'EdgeColor','none', ...
        'HandleVisibility','off');
end