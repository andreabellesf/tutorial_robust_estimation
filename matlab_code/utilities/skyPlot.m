function skyPlot ( varargin )
%**************************************************************************
%
% Date: 29.10.2018
% DLR Neustrelitz
% Author: Daniel Arias Medina
%
% svPrn is a column vector where each entry is the name of a satellite
% svAzimuth is a column vector with the azimuth of the satellites (in
% degrees!)
% svZenith is a column vector with the elevation of each satellite (in
% degrees)
% gpsTimeGps is a column vector with the name for each of the satellites.
% It is not really important which value is inside, it is just a way to
% sort and organize the satellites for each time epoch
% elevationMask is used to draw the limit on the plot
%
%
%**************************************************************************
% Input check
if nargin<2
    error('Wrong number of inputs')
end
% Default parameters
elevation = varargin{1};
azimuth = varargin{2};
plot_prn = 0;
plot_snr = 0;
elevationMask = 5;
constellation = [];
markersize = 25;
snr = [];
prn = [];
makeNewFigure = 1;
myColor = 0.5*[1,1,1];
% Handle input arguments
if nargin > 2
    elevation = varargin{1};
    azimuth = varargin{2};
    for idx = 3:2:length(varargin)
        if ischar( varargin{idx} )
            switch lower(varargin{idx})
                case 'plot_snr'
                    plot_snr = varargin{idx+1};
                case 'snr'
                    snr = varargin{idx+1};
                case 'plot_prn'
                    plot_prn = varargin{idx+1};
                case 'prn'
                    prn = varargin{idx+1};
                case 'constellation'
                    constellation = varargin{idx+1};
                case 'elevationmask'
                    elevationMask = varargin{idx+1};
                case 'markersize'
                    markersize = varargin{idx+1};
                case 'makenewfigure'
                    makeNewFigure = varargin{idx+1};
                case 'color'
                    myColor = varargin{idx+1};
                otherwise
                    error(['Unrecognized variable: ' varargin{idx}])
            end
        end
    end
end

% Check wrong inputs
if plot_snr == true && isempty( snr )
    plot_snr = 0;
    warning('Missing SNR values');
end
if plot_prn == true && isempty( prn )
    plot_prn = 0;
    warning('Missing PRN values');
end

      
minSnr = 30;
maxSnr = 50;
fontsizee = 16;
n = length(azimuth);


% initialize polar - plotting area
if makeNewFigure,  figure; end
axis([-1.4 1.4 -1.1 1.1]);
axis('off');
axis(axis);
hold on;
% plot circular axis and labels
th = linspace(0,2*pi,1000);
circleRadius = [ 90, (90-elevationMask), 60, 30 ] /90;
x = circleRadius.*[cos(th)]';
y = circleRadius.*[sin(th)]';
plot(x,y,  ':', 'Color',[0.5 0.5 0.5], 'linewidth', 1);
circleRadius = [ 90 ] /90;
x = circleRadius.*[cos(th)]';
y = circleRadius.*[sin(th)]';
plot(x,y,  '-', 'Color',[0.5 0.5 0.5], 'linewidth', 2);
circleRadiusMask = [ (90-elevationMask) ] /90;
x = circleRadiusMask.*[cos(th)]';
y = circleRadiusMask.*[sin(th)]';
plot(x,y,  ':', 'Color',[0.5 0.5 0.5], 'linewidth', 1.5);
text(1.10,0,'$90^{\circ}$','horizontalalignment','center','fontsize',fontsizee,'interpreter','latex');
text(-(0.52+0.27),0.52+0.25,'$315^{\circ}$','horizontalalignment','center','fontsize',fontsizee,'interpreter','latex');
text(0.52+0.27,-(0.52+0.27),'$135^{\circ}$','horizontalalignment','center','fontsize',fontsizee,'interpreter','latex');
text(0.52+0.25,0.52+0.25,'$45^{\circ}$','horizontalalignment','center','fontsize',fontsizee,'interpreter','latex');
text(-(0.52+0.27),-(0.52+0.27),'$225^{\circ}$','horizontalalignment','center','fontsize',fontsizee,'interpreter','latex');
text(0,1.10,'$0^{\circ}$','horizontalalignment','center','fontsize',fontsizee,'interpreter','latex');
text(-1.12,0,'$270^{\circ}$','horizontalalignment','center','fontsize',fontsizee,'interpreter','latex');
text(0,-1.10,'$180^{\circ}$','horizontalalignment','center','fontsize',fontsizee,'interpreter','latex'); 
% plot spoke axis and labels
th = 15*pi/180 * (1:12);
x = [ -cos(th); cos(th) ];
y = [ -sin(th); sin(th) ];
plot(x,y, ':', 'Color', [0.5 0.5 0.5], 'linewidth', 0.5);
th = 45*pi/180 * (0:3);
x = [ -cos(th); cos(th) ];
y = [ -sin(th); sin(th) ];
plot(x,y, ':', 'Color', [0.0 0.0 0.0], 'linewidth', 1.0);

% Getting satellite positions in polar coordinates
x = (pi/2-abs(elevation))/(pi/2).*cos(azimuth-pi/2);
y = -1*(pi/2-abs(elevation))/(pi/2).*sin(azimuth-pi/2); 
if plot_snr == false
    ax=gca; ax.ColorOrderIndex=1;
    plot(x,y,'.','MarkerSize',markersize,'color',myColor);
%     plot(x,y,'b.','color',0.5*[1,1,1]);
%     ax=gca; ax.ColorOrderIndex=3;
%     plot(x,y,'.');
elseif plot_snr == true
    scaleSNR = linspace(minSnr,maxSnr,10);
    green=[0,204,0]/255;
    yellow=[255,255,0]/255;
    red=[255,51,0]/255;
    cmap = makeColorMap(red,yellow,green, 10);
    for i = 1:n
        [~, indSnr] = min( abs( scaleSNR-snr(i)  ) );
        colorrii = cmap( indSnr(1),: );
        plot(x(i),y(i),'o','MarkerFaceColor',colorrii,'MarkerSize',markersize,'MarkerEdgeColor','none');
    end
end
% axis equal;


text(30/90,-.1,'$60^{\circ}$','horizontalalignment','center','fontsize',fontsizee,'interpreter','latex');
text(60/90,-.1,'$30^{\circ}$','horizontalalignment','center','fontsize',fontsizee,'interpreter','latex');
elevationMaskText = num2str(elevationMask);
elevationMaskFullText = strcat( elevationMaskText,'$^{\circ}$' );
text(1-elevationMask/90,-.1,elevationMaskFullText,'horizontalalignment','center','fontsize',fontsizee,'interpreter','latex');
% Plotting the SNR colormap
if plot_snr
    colormap(cmap)
    ccc = colorbar;
    ccc.Label.String = 'SNR [dBHz]';
    set(ccc,'Location','east', 'AxisLocation','out','FontSize',fontsizee,'TickLabelInterpreter','latex','TickLabels',{'$\leq 30$','35','40','45','50','$\geq$ 55'})
end



% % To name the satellites:
if plot_prn == true
    if isempty(constellation)
        constellation = repmat( 'G', n, 1 );
    end
    id_cons= unique( constellation );
    ncons = length(id_cons);
    for iCons = 1:ncons
        aux = find( constellation == id_cons(iCons) );
        prnTmp = prn( aux );
        uniqueSv = unique(prnTmp);
        nSv = length(uniqueSv);
        for iSv = 1:nSv
            indSv = find( prn==uniqueSv(iSv) );
            
            el = elevation(indSv(1));
            az = azimuth(indSv(1));
            x_prn = (pi/2-abs(el))/(pi/2).*cos(az-pi/2);
            y_prn = -1*(pi/2-abs(el))/(pi/2).*sin(az-pi/2);
            
            nameSv = strcat( id_cons(iCons), num2str( uniqueSv(iSv), '%02g' ) );
%             text(x_prn,y_prn+.07,nameSv, 'horizontalalignment', 'center', 'fontsize',fontsizee-2,'interpreter','latex','Color',[0,0.45,0.74]);
%             text(x_prn,y_prn+.07,nameSv, 'horizontalalignment', 'center', 'fontsize',fontsizee-2,'interpreter','latex','Color',[0.9290, 0.6940, 0.1250]);
            text(x_prn,y_prn+.07,nameSv, 'horizontalalignment', 'center', 'fontsize',fontsizee,'interpreter','latex','Color',0.2*[1,1,1]);
        end
    end
end



end