function[indiceG,indiceR,indiceC,indiceE]=find_last_eph(Eph,Insertdata)
% find_last_eph Find the last available orbital parameters in the rinex
% file to perform orbits propagation.
%   [indiceG,indiceR,indiceC,indiceE]=find_last_eph(Eph,Insertdata)

%% Parameters
h=Insertdata(1,4);
m=Insertdata(1,5);
s=Insertdata(1,6);
day_seconds=h*3600+m*60+s;
G=double('G');%GPS code ASCII
R=double('R');%GLONASS code
E=double('E');%GALILEO code
C=double('C');%BEIDOU code
S=double('S');%SBAS code
J=double('J');%QZSS code
I=double('I');%IRNSS code
%%
M=Eph;
[n,~]=size(M);

for k=1:40
     tempsG=0;
     tempsR=0;
     tempsC=0;
     tempsE=0;
            %GPS
            for j=1:n
                if (M(j,1)==G && M(j,2)==k && M(j,3)==Insertdata(1,1) && M(j,4)==Insertdata(1,2) && M(j,5)==Insertdata(1,3))%Se corrispondono Sistema e giorno
                    SecG=M(j,6)*3600+M(j,7)*60+M(j,8);
                    if SecG<=day_seconds && SecG>=tempsG
                        tempsG=SecG;
                        indiceG(k,:)=[k,j];
                    end
                end
                 if (M(j,1)==R && M(j,2)==k && M(j,3)==Insertdata(1,1) && M(j,4)==Insertdata(1,2) && M(j,5)==Insertdata(1,3))%Se corrispondono Sistema e giorno
                    SecR=M(j,6)*3600+M(j,7)*60+M(j,8);
                    if SecR<=day_seconds && SecR>=tempsR
                        tempsR=SecR;
                        indiceR(k,:)=[k,j];
                    end
                end
                if (M(j,1)==E && M(j,2)==k && M(j,3)==Insertdata(1,1) && M(j,4)==Insertdata(1,2) && M(j,5)==Insertdata(1,3))%Se corrispondono Sistema e giorno
                    SecE=M(j,6)*3600+M(j,7)*60+M(j,8);
                    if SecE<=day_seconds && SecE>=tempsE
                        tempsE=SecE;
                        indiceE(k,:)=[k,j];
                    end
                end
                if (M(j,1)==C && M(j,2)==k && M(j,3)==Insertdata(1,1) && M(j,4)==Insertdata(1,2) && M(j,5)==Insertdata(1,3))%Se corrispondono Sistema e giorno
                    SecC=M(j,6)*3600+M(j,7)*60+M(j,8);
                    if SecC<=day_seconds && SecC>=tempsC
                        tempsC=SecC;
                        indiceC(k,:)=[k,j];
                    end
                end

            end
end
