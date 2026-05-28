function [Absolute_SatPosGPS, el,az,PRN,indexes]=visible_satGPS(phi,lambda,h,SatGPS_all,el_mask)
% visible_satGPS Find the visible GPS satellites.
%   [Absolute_SatPosGPS, SatPosGPS,el,az,PRN]=visible_satGPS(phi,lambda,h,SatGPS_all,el_mask)

%% Parameters
global constellations

aax=6378137;%[m]
flattening=1/298.257222101;
bax=(1-flattening)*aax;%[m]
% SV={'G01','G02','G03','G04','G05','G06','G07','G08','G09','G10','G11','G12','G13','G14','G15','G16','G17','G18','G19','G20','G21','G22','G23','G24','G25','G26','G27','G28','G29','G30','G31','G32'};
% SV_ID = [1:32];
% svId = [];

indexes = [];
PRN = [];


%% Algorithm
N=aax/sqrt(1-(1-(bax)^2/aax^2)*(sin(phi))^2);
X=(N+h)*cos(phi)*cos(lambda);%[m]
Y=(N+h)*cos(phi)*sin(lambda);%[m]
Z=((1-(1-bax^2/aax^2))*N+h)*sin(phi);%[m]

index=1;
for k=1:length(SatGPS_all(1,:))
    xs=SatGPS_all(1,k)-X;%deltax%[m]
    ys=SatGPS_all(2,k)-Y;%deltay%[m]
    zs=SatGPS_all(3,k)-Z;%deltaz%[m]
    ENU=[-sin(lambda) cos(lambda) 0;-cos(lambda)*sin(phi) -sin(lambda)*sin(phi) cos(phi);cos(lambda)*cos(phi) sin(lambda)*cos(phi) sin(phi)]*[xs;ys;zs];
    Est=ENU(1,1);
    Nord=ENU(2,1);
    Up=ENU(3,1);
    Elevation=asin(Up/sqrt(Est^2+Nord^2+Up^2));
    Azimuth=atan2(Est,Nord);
    Azimuth=rem(Azimuth+2*pi,2*pi);
    if Elevation>el_mask
        el(index,1) = Elevation;
        az(index, 1) = Azimuth;
        PRN( index,1 ) = constellations.GPS.PRN(k);
        indexes( index, 1 ) = constellations.GPS.PRN(k);
        Absolute_SatPosGPS(index,:) = [SatGPS_all(1,k);SatGPS_all(2,k);SatGPS_all(3,k)].';
%         svId(1,index)=constellations.('GPS').indexes(k);
        index=index+1;
    end
end

%% Invalid
% invalid={'invalid'};
% el(index,1)=NaN;
% az(index,1)=NaN;
% % PRN(index,1)=invalid;
% index=index+1;