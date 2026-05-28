function [Absolute_SatPosGLO,el,az,PRN, indexes]=visible_satGLO(phi,lambda,h,SatGLO_all,el_mask)
% visible_satGLO Find the visible Glonass satellites.
%   [Absolute_SatPosGLO,SatPosGLO,el,az,PRN]=visible_satGLO(phi,lambda,h,SatGLO_all,el_mask)

%% Parameters
global constellations

aax=6378137;%[m]
flattening=1/298.257222101;
bax=(1-flattening)*aax;%[m]
% SV = 'R'+string(1:30);
% GLO_PRN = [1:30];
% svId = [];

PRN = [];
indexes = [];

%% Algorithm
N=aax/sqrt(1-(1-(bax)^2/aax^2)*(sin(phi))^2);
X=(N+h)*cos(phi)*cos(lambda);%[m]
Y=(N+h)*cos(phi)*sin(lambda);%[m]
Z=((1-(1-bax^2/aax^2))*N+h)*sin(phi);%[m]

index=1;
for k=1:length(SatGLO_all(1,:))
    xs=SatGLO_all(1,k)-X;%deltax%[m]
    ys=SatGLO_all(2,k)-Y;%deltay%[m]
    zs=SatGLO_all(3,k)-Z;%deltaz%[m]
    ENU=[-sin(lambda) cos(lambda) 0;-cos(lambda)*sin(phi) -sin(lambda)*sin(phi) cos(phi);cos(lambda)*cos(phi) sin(lambda)*cos(phi) sin(phi)]*[xs;ys;zs];
    Est=ENU(1,1);
    Nord=ENU(2,1);
    Up=ENU(3,1);
    Elevation=asin(Up/sqrt(Est^2+Nord^2+Up^2));
    Azimuth=atan2(Est,Nord);
    Azimuth=rem(Azimuth+2*pi,2*pi);
    if Elevation>el_mask
        el(index,1) = Elevation;
        az(index,1) = Azimuth;
        PRN( index, 1 ) = constellations.GLONASS.PRN(k);
        indexes( index, 1 ) = constellations.GLONASS.indexes(k);
        Absolute_SatPosGLO(index,:) = [SatGLO_all(1,k);SatGLO_all(2,k);SatGLO_all(3,k)].';
%         PRN(1,index)=SV(1,k);
%         svId(1,index)=k;
%         svId(1,index)=constellations.('GLONASS').indexes(k);
        
        index=index+1;
    end
end
%% Invalid
% invalid={'invalid'};
% el(index,1)=NaN;
% az(index,1)=NaN;
% % PRN(index,1)=invalid;
% index=index+1;