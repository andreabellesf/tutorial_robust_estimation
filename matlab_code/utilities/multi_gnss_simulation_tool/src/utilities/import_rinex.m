function M=import_rinex(in_path)
% import_rinex Import brdc rinex file.
%    M=import_rinex(in_path).
% 
%   INPUT:
%   in_path = name of the rinex file located in the input folder.
%
%   OUTPUT:
%   M = matrix containing rinex information


disp('Importing rinex...')
% h=Insertdata(1,4);
% m=Insertdata(1,5);
% s=Insertdata(1,6);
% day_seconds=h*3600+m*60+s;
startRow = 1;
fileID = fopen(in_path,'r');
counter=1;
while (~feof(fileID))     
tline = fgetl(fileID);   
counter=counter+1;
end
fclose(fileID);
fileID = fopen(in_path,'r');
riga=zeros(counter,80);
index=1;
while index==1 
   startRow = startRow+1;
   line = fgetl(fileID);
   endofheader = strfind(line,'END OF HEADER');
   index=isempty(endofheader);
end
endRow = inf;
counter=1;
while (~feof(fileID))     
tline = fgetl(fileID);
%disp(double(tline))
riga(counter,:)=double(tline);   
counter=counter+1;
end
 
CHAR=char(riga);
G=double('G');%GPS code ASCII
R=double('R');%GLONASS code
E=double('E');%GALILEO code
C=double('C');%BEIDOU code
S=double('S');%SBAS code
J=double('J');%QZSS code
I=double('I');%IRNSS code
eph=zeros(ceil(counter/4),612);
ind=1;
for ii=1:length(riga(:,1))
    if riga(ii,1)==G
        eph(ind,:)=[riga(ii,:) riga(ii+1,5:end) riga(ii+2,5:end) riga(ii+3,5:end) riga(ii+4,5:end) riga(ii+5,5:end) riga(ii+6,5:end) riga(ii+7,5:end)];
        ind=ind+1;
    end
        if riga(ii,1)==E
        eph(ind,:)=[riga(ii,:) riga(ii+1,5:end) riga(ii+2,5:end) riga(ii+3,5:end) riga(ii+4,5:end) riga(ii+5,5:end) riga(ii+6,5:end) riga(ii+7,5:end)];
        ind=ind+1;
        end
        if riga(ii,1)==C
        eph(ind,:)=[riga(ii,:) riga(ii+1,5:end) riga(ii+2,5:end) riga(ii+3,5:end) riga(ii+4,5:end) riga(ii+5,5:end) riga(ii+6,5:end) riga(ii+7,5:end)];
        ind=ind+1;
    end
    if riga(ii,1)==R
        eph(ind,:)=[riga(ii,:) riga(ii+1,5:end) riga(ii+2,5:end) riga(ii+3,5:end) zeros(1,304)];
        ind=ind+1;
    end


end

for kk=1:length(eph(:,1))
    EP=eph(kk,1:23);
    for ii=24:19:(length(eph(kk,:))-19)
        EP=[EP,32,eph(kk,ii:ii+18)];
    end
    EP2(kk,:)=EP;
end
EPH=char(EP2);
g=1;
r=1;
e=1;
c=1;

for ii=1:length(EPH(:,1))
    EPHstr=strcat(EPH(ii,:));
    if isempty(EPHstr)
        break
    end
    
    EPHnum=str2num(EPHstr(2:end));
    if strcmp('G',EPHstr(1,1))
       EPHE(g,:)=[G zeros(1,39)];
        for kk=1:length(EPHnum)
        EPHE(g,kk+1)=(EPHnum(kk));
        end
        g=g+1;
    end
    if strcmp('R',EPHstr(1,1))
       EPHE(g,:)=[R zeros(1,39)];
        for kk=1:length(EPHnum)
        EPHE(g,kk+1)=(EPHnum(kk));
        end
        g=g+1;
    end
    if strcmp('C',EPHstr(1,1))
       EPHE(g,:)=[C zeros(1,39)];
        for kk=1:length(EPHnum)
        EPHE(g,kk+1)=(EPHnum(kk));
        end
        g=g+1;
    end
    if strcmp('E',EPHstr(1,1))
       EPHE(g,:)=[E zeros(1,39)];
        for kk=1:length(EPHnum)
        EPHE(g,kk+1)=(EPHnum(kk));
        end
        g=g+1;
    end
    clear EPHstr
    clear EPHnum
end
M=EPHE;
disp('End import rinex')