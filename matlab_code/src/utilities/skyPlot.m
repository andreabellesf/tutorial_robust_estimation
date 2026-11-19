function [ax, h] = skyPlot(elevation, azimuth, varargin)
% SKYPLOT Display GNSS satellites on a sky-view diagram.
%
% DESCRIPTION:
%   Creates a conventional GNSS sky plot: north at the top, east at the
%   right, horizon at the outer circle and zenith at the center.
%   Azimuth and elevation must be supplied in radians.
%
%   Optional C/N0 coloring is enabled automatically when 'snr' is supplied.
%   Optional satellite labels are enabled automatically when 'satelliteId'
%   is supplied. The two options are independent of each other.
%
% SYNTAX:
%   skyPlot(elevation, azimuth)
%   skyPlot(elevation, azimuth, 'snr', cn0)
%   skyPlot(elevation, azimuth, 'satelliteId', {'G01','E03'})
%   skyPlot(elevation, azimuth, 'snr', cn0, 'satelliteId', {'G01','E03'}, 'elevationmask', 10)
%   [ax, h] = skyPlot(elevation, azimuth, Name1, Value1, Name2, Value2)
%
% REQUIRED INPUTS:
%   elevation       Nx1 or 1xN satellite elevation [rad]
%   azimuth         Nx1 or 1xN satellite azimuth [rad]
%
% NAME-VALUE OPTIONS (case insensitive):
%   'snr'           Nx1 or 1xN C/N0 measurements [dB-Hz]. Default [].
%                   Nonfinite values are plotted in the neutral color.
%   'satelliteId'   Nx1 or 1xN cellstr or string array of already-formatted
%                   IDs (e.g. {'G01','G03','E12'}). Default [] (no labels).
%   'elevationmask' Elevation reference circle [deg], default 5.
%   'snrlimits'     C/N0 color scale [min max] [dB-Hz], default [30 50].
%   'markersize'    Marker diameter [points], default 12.
%   'makenewfigure' Create a new figure if true, default true. When false,
%                   overlay new satellites on the current axes (no clearing).
%   'parent'        Existing axes handle, default []. Overrides makenewfigure
%                   and overlays on the specified axes.
%   'color'         Marker RGB color when not C/N0-colored,
%                   default [0.5 0.5 0.5].
%   'interpreter'   Degree labels and C/N0 colorbar text interpreter:
%                   'latex' (default), 'tex', or 'none'.
%                   Satellite IDs always use 'none' to preserve IDs exactly.
%
% OUTPUTS:
%   ax              Axes handle.
%   h               Structure containing handles: horizon, mask,
%                   satellites, coloredSatellites, uncoloredSatellites,
%                   labels, and colorbar.
%
% NOTES:
%   - Azimuth is wrapped into [0,2*pi).
%   - Satellites below the horizon or above the zenith are not plotted.
%   - The elevation mask is visual only; it does not filter measurements.
%   - Repeated satellite IDs are labeled once (at their first valid point).
%   - Reusing existing axes preserves earlier markers, labels and grid.
%   - The sky grid and elevation mask are drawn only once per axes.
%   - All C/N0 layers in an axes share its colormap and color limits.
%   - Existing sky-grid labels are preserved and can change interpreter
%     on subsequent calls (with this version of skyPlot).
%   - No additional toolboxes are required.
%
% EXAMPLE:
%   [az, el] = satelliteAzEl(svPos, userPos);
%   skyPlot(el, az, 'snr', cn0, 'satelliteId', satelliteId);

    %% Validate required inputs
    narginchk(2, inf);
    validateattributes(elevation, {'numeric'}, {'real', 'vector', 'nonempty'}, mfilename, 'elevation', 1);
    validateattributes(azimuth, {'numeric'}, {'real', 'vector', 'nonempty'}, mfilename, 'azimuth', 2);

    n = numel(elevation);
    if numel(azimuth) ~= n
        error('skyPlot:SizeMismatch', 'Elevation and azimuth must have the same number of elements.');
    end
    elevation = elevation(:);
    azimuth   = azimuth(:);

    %% Parse optional name-value inputs
    p = inputParser;
    p.FunctionName = mfilename;
    p.CaseSensitive = false;

    addParameter(p, 'snr', [], @(v) isempty(v) || (isnumeric(v) && isreal(v) && isvector(v)));
    addParameter(p, 'satelliteId', [], @(v) isempty(v) || (iscellstr(v) && isvector(v)) || (isstring(v) && isvector(v)) || (ischar(v) && isrow(v) && n == 1));
    addParameter(p, 'elevationmask', 5, @(v) isnumeric(v) && isreal(v) && isscalar(v) && isfinite(v) && v >= 0 && v <= 90);
    addParameter(p, 'snrlimits', [30 50], @(v) isnumeric(v) && isreal(v) && isequal(size(v), [1 2]) && all(isfinite(v)) && v(1) < v(2));
    addParameter(p, 'markersize', 12, @(v) isnumeric(v) && isreal(v) && isscalar(v) && isfinite(v) && v > 0);
    addParameter(p, 'makenewfigure', true, @isLogicalScalar);
    addParameter(p, 'parent', [], @(v) isempty(v) || (isscalar(v) && isgraphics(v, 'axes')));
    addParameter(p, 'color', [0.5 0.5 0.5], @(v) isnumeric(v) && isreal(v) && isequal(size(v), [1 3]) && all(isfinite(v)) && all(v >= 0) && all(v <= 1));
    addParameter(p, 'interpreter', 'latex', @(v) (ischar(v) || (isstring(v) && isscalar(v))) && any(strcmpi(v, {'latex', 'tex', 'none'})));

    parse(p, varargin{:});
    opt = p.Results;
    labelInterpreter = lower(char(opt.interpreter));

    %% Validate optional per-satellite metadata
    showSNR = ~isempty(opt.snr);
    showID  = ~isempty(opt.satelliteId);

    snr = [];
    if showSNR
        if numel(opt.snr) ~= n
            error('skyPlot:SNRSize', 'snr must contain exactly one value per satellite (%d).', n);
        end
        snr = opt.snr(:);
    end

    satelliteId = strings(0, 1);
    if showID
        if ischar(opt.satelliteId)
            satelliteId = string(opt.satelliteId);
        else
            satelliteId = string(opt.satelliteId(:));
        end
        if numel(satelliteId) ~= n
            error('skyPlot:SatelliteIdSize', 'satelliteId must contain exactly one ID per satellite (%d).', n);
        end
        if any(ismissing(satelliteId)) || any(strlength(strtrim(satelliteId)) == 0)
            error('skyPlot:InvalidSatelliteId', 'All satellite IDs must be nonempty, e.g. ''G01''.');
        end
    end

    %% Valid directions and sky-plot coordinates
    azimuth = mod(azimuth, 2*pi);
    valid = isfinite(elevation) & isfinite(azimuth) & elevation >= 0 & elevation <= pi/2;

    radius = 1 - elevation / (pi/2);
    xSat = radius .* sin(azimuth);
    ySat = radius .* cos(azimuth);

    %% Create or reuse axes (never clear an existing plot)
    if ~isempty(opt.parent)
        ax = opt.parent;
    elseif opt.makenewfigure
        fig = figure('Color', 'w');
        ax = axes('Parent', fig);
    else
        ax = gca;
    end

    % Preserve the caller's hold setting, but add our graphics on top.
    wasHeld = ishold(ax);
    hold(ax, 'on');

    % Tag the background so repeated calls do not draw duplicate grids.
    h = struct();
    h.horizon = findobj(ax, 'Tag', 'skyPlotHorizon');
    h.mask = findobj(ax, 'Tag', 'skyPlotMask');
    drawGrid = isempty(h.horizon);

    if drawGrid
        axis(ax, 'equal');
        axis(ax, [-1.22 1.22 -1.22 1.22]);
        axis(ax, 'off');

        %% Draw sky grid and labels (only once per axes)
        theta = linspace(0, 2*pi, 721);
        gridGray = [0.72 0.72 0.72];

        for elDeg = [30 60]
            r = 1 - elDeg/90;
            plot(ax, r*sin(theta), r*cos(theta), ':', 'Color', gridGray, 'LineWidth', 0.8);
            text(ax, r, -0.045, formatDegreeLabel(elDeg, labelInterpreter), 'HorizontalAlignment', 'center', 'FontSize', 10, 'Interpreter', labelInterpreter, 'Tag', 'skyPlotDegreeLabel', 'UserData', elDeg);
        end

        for azDeg = 0:30:330
            a = azDeg*pi/180;
            plot(ax, [0 sin(a)], [0 cos(a)], ':', 'Color', [0.82 0.82 0.82], 'LineWidth', 0.7);
        end

        h.horizon = plot(ax, sin(theta), cos(theta), '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 1.4, 'Tag', 'skyPlotHorizon');

        rMask = 1 - opt.elevationmask/90;
        h.mask = plot(ax, rMask*sin(theta), rMask*cos(theta), '--', 'Color', [0.8 0.25 0.25], 'LineWidth', 1.1, 'Tag', 'skyPlotMask');

        if opt.elevationmask > 0 && opt.elevationmask < 90
            text(ax, rMask, -0.065, formatDegreeLabel(opt.elevationmask, labelInterpreter), 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', [0.65 0.16 0.16], 'Interpreter', labelInterpreter, 'Tag', 'skyPlotDegreeLabel', 'UserData', opt.elevationmask);
        end

        for azDeg = 0:45:315
            a = azDeg*pi/180;
            text(ax, 1.12*sin(a), 1.12*cos(a), formatDegreeLabel(azDeg, labelInterpreter), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 11, 'Interpreter', labelInterpreter, 'Tag', 'skyPlotDegreeLabel', 'UserData', azDeg);
        end
    else
        % Update existing sky-grid label formatting without clearing the plot.
        degreeText = findobj(ax, 'Type', 'text', 'Tag', 'skyPlotDegreeLabel');
        for k = 1:numel(degreeText)
            degreeText(k).String = formatDegreeLabel(degreeText(k).UserData, labelInterpreter);
            degreeText(k).Interpreter = labelInterpreter;
        end
    end

    %% Plot satellite markers (optionally colored by C/N0)
    h.colorbar = [];
    h.coloredSatellites   = gobjects(0);
    h.uncoloredSatellites = gobjects(0);
    h.labels = gobjects(0);

    if showSNR
        goodSNR = valid & isfinite(snr);
        missingSNR = valid & ~isfinite(snr);

        % Keep measurements with missing C/N0 visible in neutral gray.
        if any(missingSNR)
            h.uncoloredSatellites = plot(ax, xSat(missingSNR), ySat(missingSNR), '.', 'Color', opt.color, 'MarkerSize', opt.markersize);
        end

        if any(goodSNR)
            % Red -> yellow -> green colormap.
            colorStops = [1.00 0.20 0.00; 1.00 1.00 0.00; 0.00 0.80 0.00];
            cmap = interp1([0 0.5 1], colorStops, linspace(0, 1, 256));
            colormap(ax, cmap);
            caxis(ax, opt.snrlimits);
            h.coloredSatellites = scatter(ax, xSat(goodSNR), ySat(goodSNR), opt.markersize^2, snr(goodSNR), 'filled', 'MarkerEdgeColor', 'none');

            h.colorbar = colorbar(ax, 'eastoutside');
            h.colorbar.Label.String = formatCNoLabel(labelInterpreter);
            h.colorbar.Label.Interpreter = labelInterpreter;
            h.colorbar.TickLabelInterpreter = labelInterpreter;
            h.colorbar.Ticks = linspace(opt.snrlimits(1), opt.snrlimits(2), 5);
        end

        h.satellites = [h.coloredSatellites(:); h.uncoloredSatellites(:)];
    else
        h.satellites = plot(ax, xSat(valid), ySat(valid), '.', 'Color', opt.color, 'MarkerSize', opt.markersize);
        h.uncoloredSatellites = h.satellites;
    end

    %% Label satellites only when satelliteId is given
    if showID
        plottedIdx = find(valid);
        [~, firstOccurrence] = unique(satelliteId(plottedIdx), 'stable');
        labelIdx = plottedIdx(firstOccurrence);
        h.labels = gobjects(numel(labelIdx), 1);

        for k = 1:numel(labelIdx)
            j = labelIdx(k);
            h.labels(k) = text(ax, xSat(j), ySat(j)+0.045, char(satelliteId(j)), 'HorizontalAlignment', 'center', 'FontSize', 10, 'Interpreter', 'none', 'Color', [0.15 0.15 0.15]);
        end
    end

    if ~wasHeld
        hold(ax, 'off');
    end
end

function tf = isLogicalScalar(x)
% ISLOGICALSCALAR Accept logical or numeric 0/1 scalar.
    tf = isscalar(x) && (islogical(x) || (isnumeric(x) && isreal(x) && isfinite(x) && any(x == [0 1])));
end

function str = formatDegreeLabel(value, interpreter)
% FORMATDEGREELABEL Create valid degree labels for each text interpreter.
    switch interpreter
        case 'latex'
            str = ['$' num2str(value) '^{\circ}$'];
        case 'tex'
            str = [num2str(value) '^\circ'];
        otherwise
            str = [num2str(value) char(176)];
    end
end

function str = formatCNoLabel(interpreter)
% FORMATCNOLABEL Format the C/N0 label for the selected interpreter.
    switch interpreter
        case 'latex'
            str = '$C/N_0$ [dB-Hz]';
        case 'tex'
            str = 'C/N_0 [dB-Hz]';
        otherwise
            str = 'C/N0 [dB-Hz]';
    end
end
