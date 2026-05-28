function [Absolute_SatPosGAL,el,az,PRN, indexes]=visible_satGAL(phi,lambda,h,SatGAL_all,el_mask)
% visible_satGAL Find the visible Galileo satellites.
%   [Absolute_SatPosGAL,SatPosGAL,el,az,PRN]=visible_satGAL(phi,lambda,h,SatGAL_all,el_mask)

%% Parameters
global constellations

aax=6378137;%[m]
flattening=1/298.257222101;
bax=(1-flattening)*aax;%[m]
% SV={'E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12','E13','E14','E15','E16','E17','E18','E19','E20','E21','E22','E23','E24','E25','E26','E27','E28','E29','E30','E31','E32','E33','E34','E35','E36'};
% GAL_PRN = [1:36];
% svId = [];

PRN = [];
indexes = [];

%% Algorithm
N=aax/sqrt(1-(1-(bax)^2/aax^2)*(sin(phi))^2);
X=(N+h)*cos(phi)*cos(lambda);%[m]
Y=(N+h)*cos(phi)*sin(lambda);%[m]
Z=((1-(1-bax^2/aax^2))*N+h)*sin(phi);%[m]

index=1;
for k=1:length(SatGAL_all(1,:))
    xs=SatGAL_all(1,k)-X;%deltax%[m]
    ys=SatGAL_all(2,k)-Y;%deltay%[m]
    zs=SatGAL_all(3,k)-Z;%deltaz%[m]
    ENU=[-sin(lambda) cos(lambda) 0;-cos(lambda)*sin(phi) -sin(lambda)*sin(phi) cos(phi);cos(lambda)*cos(phi) sin(lambda)*cos(phi) sin(phi)]*[xs;ys;zs];
    Est=ENU(1,1);
    Nord=ENU(2,1);
    Up=ENU(3,1);
    Elevation=asin(Up/sqrt(Est^2+Nord^2+Up^2));
    Azimuth=atan2(Est,Nord);
    Azimuth=rem(Azimuth+2*pi,2*pi);
    if Elevation>el_mask
        el(index,1)=Elevation;
        az(index,1)=Azimuth;
%         PRN(1,index)=SV(1,k);
%         svId(1,index)=k;
%         svId(1,index)=constellations.('Galileo').indexes(k);

        PRN(index,1) = constellations.Galileo.PRN(k);
        indexes(index,1) = constellations.Galileo.indexes(k);
        Absolute_SatPosGAL(index,:) = [SatGAL_all(1,k);SatGAL_all(2,k);SatGAL_all(3,k)].';
        index=index+1;
    end
end
%% Invalid
% invalid={'invalid'};
% el(index,1)=NaN;
% az(index,1)=NaN;
% % PRN(1,index)=invalid;
% % SatPosGAL(index,:)=[0;0;0].';
% index=index+1;