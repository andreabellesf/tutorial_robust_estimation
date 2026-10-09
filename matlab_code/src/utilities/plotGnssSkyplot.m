function [az, el] = plotGnssSkyplot(satECEF, rxLLH, satIDs, cfg)
% plotGNSSSkyplot - GPS/Galileo skyplot
%
% INPUTS:
%   satECEF : Nx3 satellite ECEF positions [m]
%   rxLLH   : [latitude, longitude, height] [deg, deg, m]
%   satIDs  : Nx1 satellite IDs ("G01", "E11", etc.)
%   minElev : Minimum elevation angle [deg], default 10
%
% OUTPUTS:
%   az      : Nx1 azimuth [deg]
%   el      : Nx1 elevation [deg]
%
% GPS satellites: blue
% Galileo satellites: orange
%
% No additional toolbox required.

    minElev = cfg.gnss.elevationMask;

    if nargin < 4 || isempty(minElev)
        minElev = 10;
    end

    satIDsStr = [];
    if cfg.gnss.enabledGPS
        satelliteIdGPSString = "G" + satIDs.GPS;
        satIDsStr = [satIDsStr; satelliteIdGPSString];

    end

    if cfg.gnss.enabledGAL

        satelliteIdGALString = "E" + satIDs.GAL;
        satIDsStr = [satIDsStr; satelliteIdGALString];
    end

    %% 1. Receiver LLH to ECEF (WGS84)

    lat = rxLLH(1);
    lon = rxLLH(2);
    h   = rxLLH(3);

    a  = 6378137.0;
    f  = 1/298.257223563;
    e2 = f*(2-f);

    N = a / sqrt(1 - e2*sind(lat)^2);

    rxECEF = [
        (N+h)*cosd(lat)*cosd(lon), ...
        (N+h)*cosd(lat)*sind(lon), ...
        (N*(1-e2)+h)*sind(lat)
    ];

    %% 2. ECEF to ENU rotation matrix

    R = [
        -sind(lon),            cosd(lon),           0;
        -sind(lat)*cosd(lon), -sind(lat)*sind(lon), cosd(lat);
         cosd(lat)*cosd(lon),  cosd(lat)*sind(lon), sind(lat)
    ];

    %% 3. Compute satellite azimuth and elevation

    dXYZ = satECEF - rxECEF;
    enu = (R*dXYZ.').';

    E = enu(:,1);
    N = enu(:,2);
    U = enu(:,3);

    az = mod(atan2d(E,N),360);
    el = atan2d(U,hypot(E,N));

    %% 4. Skyplot coordinates

    r = 90-el;
    theta = deg2rad(90-az);

    xp = r.*cos(theta);
    yp = r.*sin(theta);

    visible = el >= minElev;

    %% 5. Identify constellations

    isGPS = startsWith(upper(satIDsStr),"G");
    isGAL = startsWith(upper(satIDsStr),"E");

    %% 6. Plot skyplot

    h = [];
    figure('Color','w', 'Position', [1000,443,1159,795]);
    hold on;
    axis equal;

    t = linspace(0,2*pi,360);

    % Elevation circles
    for elev = 0:30:90
        radius = 90-elev;

        plot(radius*cos(t),radius*sin(t), ...
            'Color',[0.75 0.75 0.75]);

        if elev > 0 && elev < 90
            text(0,radius,sprintf('%d%c',elev,char(176)), ...
                'Color',[0.4 0.4 0.4], ...
                'Interpreter','none');
        end
    end

    % Azimuth radial lines
    for angle = 0:45:315
        th = deg2rad(90-angle);

        plot([0 90*cos(th)], ...
             [0 90*sin(th)], ...
             ':','Color',[0.75 0.75 0.75]);
    end

    % Elevation mask
    maskR = 90-minElev;

    hMask = plot(maskR*cos(t),maskR*sin(t), ...
        'r--','LineWidth',1.2);
    h = [h hMask];

    %% 7. Plot GPS satellites

    idx = isGPS & visible;

    hGPS = scatter(xp(idx),yp(idx),75, ...
        [0.0 0.45 0.85],'filled', ...
        'DisplayName','GPS');
    h = [h hGPS];

    %% 8. Plot Galileo satellites

    idx = isGAL & visible;

    hGAL = scatter(xp(idx),yp(idx),75, ...
        [0.95 0.45 0.10],'filled', ...
        'DisplayName','Galileo');
    h = [h hGAL];

    %% 9. Plot other constellations

    idx = ~(isGPS | isGAL) & visible;

    if any(idx)
        hOther = scatter(xp(idx),yp(idx),75, ...
            [0.5 0.5 0.5],'filled', ...
            'DisplayName','Other GNSS');
        h = [h hOther];
    end

    %% 10. Plot satellites below elevation mask

    idx = ~visible;

    if any(idx)
        hBelowMask = scatter(xp(idx),yp(idx),50, ...
            [0.75 0.75 0.75],'filled', ...
            'DisplayName','Below mask');
        h = [h hBelowMask];
    end

    %% 11. Satellite labels

    for i = 1:numel(az)

        if isGPS(i)
            labelColor = [0.0 0.45 0.85];
        elseif isGAL(i)
            labelColor = [0.95 0.45 0.10];
        else
            labelColor = [0.4 0.4 0.4];
        end

        text(xp(i)-3,yp(i)+5,satIDsStr(i), ...
            'FontSize',12, ...
            'FontWeight','bold', ...
            'Color',labelColor);
    end

    %% 12. Cardinal directions

    text(0,98,'N','FontSize',15,'HorizontalAlignment','center');
    text(98,0,'E','FontSize',15,'HorizontalAlignment','center');
    text(0,-98,'S','FontSize',15,'HorizontalAlignment','center');
    text(-98,0,'W','FontSize',15,'HorizontalAlignment','center');

    xlim([-105 105]);
    ylim([-105 105]);

    axis off;

    legend(h, ...
       {'Elevation Mask', 'GPS', 'Galileo'}, ...
       'Location', 'southoutside', ...
       'Orientation', 'horizontal');

    title('Skyplot');

    hold off;

end
