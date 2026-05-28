function Plot_Pdop(out,Costellation,MultiPDOP,step_sim,Insert_data)
% Plot_Pdop Plotting the Pdop fro the simulated scenarion in Open Sky.

for ii=1:length(out)
    if Costellation(1,1)==1
        Pdop_GPS(1,ii)=out(ii).GPS.PDOP;

    end
    if Costellation(1,2)==1
        Pdop_GLO(1,ii)=out(ii).GLO.PDOP;


    end
    if Costellation(1,3)==1
        Pdop_BEI(1,ii)=out(ii).BEI.PDOP;


    end
    if Costellation(1,4)==1
        Pdop_GAL(1,ii)=out(ii).GAL.PDOP;


    end
end
if Costellation(1,1)==1
    disp('Mean of GPS pdop')
    mean(Pdop_GPS, 'omitnan')
end
if Costellation(1,2)==1
    disp('Mean of Glonass pdop')
    mean(Pdop_GLO, 'omitnan')
end
if Costellation(1,3)==1
    disp('Mean of Beidou pdop')
    mean(Pdop_BEI, 'omitnan')
end
if Costellation(1,4)==1
    disp('Mean of Galileo pdop')
    mean(Pdop_GAL, 'omitnan')
end

%% Figure PDOP and Total Visible SATELLITES
s1=Insert_data(1,4)*3600;
s2=(Insert_data(1,5))*60;
s3=Insert_data(1,6);
asse=0:step_sim:(length(out)-1)*step_sim;
start_time=datenum(Insert_data);
ax=start_time+asse./86400;

figure
subplot(2,1,1)
hold on
if Costellation(1,1)==1
   plot(ax,Pdop_GPS,'k')
   datetick('x','HH:MM')
end
hold on
if Costellation(1,2)==1
   plot(ax,Pdop_GLO,'b')
end
hold on
if Costellation(1,3)==1
    plot(ax,Pdop_BEI,'g')
    datetick('x','HH:MM')
end
hold on
if Costellation(1,4)==1
    plot(ax,Pdop_GAL,'m')
    datetick('x','HH:MM')
end
if sum(Costellation)>1
   plot(ax,MultiPDOP,'r')
   datetick('x','HH:MM')
end
grid minor
title('PDOP')
xlabel('Day Time  [hh:mm]')
ylabel('Pdop')
ylim([0 5])
% datetick('x','HH:MM');
%% legend case
if Costellation(1,1)==1
    gps='G';
else
    gps='0';
end
if Costellation(1,2)==1
    glo='R';
else
    glo='0';
end
if Costellation(1,3)==1
    bei='C';
else
    bei='0';
end
if Costellation(1,4)==1
    gal='E';
else
    gal='0';
end
C_string=strcat(gps,glo, bei, gal);
switch C_string
    case 'G000'
        legend('Gps')
    case '0R00'
        legend('Glonass')
    case '00C0'
        legend('BeiDou')
    case '000E'
        legend('Galileo')
    case 'GR00'
        legend('Gps','Glonass','Multi')

    case 'G0C0'
        legend('Gps','BeiDou','Multi')

    case 'G00E'
        legend('Gps','Galileo','Multi')

    case '0RC0'
        legend('Glonass','BeiDou','Multi')

    case '0R0E'
        legend('Glonass','Galileo','Multi')

    case '00CE'
        legend('BeiDou','Galileo','Multi')

    case 'GRC0'
        legend('Gps','Glonass','BeiDou','Multi')

    case 'GR0E'
        legend('Gps','Glonass','Galileo','Multi')

    case 'G0CE'
        legend('Gps','BeiDou','Galileo','Multi')

    case '0RCE'
        legend('Glonass','BeiDou','Galileo','Multi')

    case 'GRCE'
        legend('Gps','Glonass','BeiDou','Galileo','Multi')
end

%%
for ii=1:length(out)
    Sat_num(ii)=0;
    if Costellation(1,1)==1
        Sat_num_GPS(ii)=length(out(ii).GPS.el)-1;
         Sat_num(ii)=Sat_num(ii)+length(out(ii).GPS.el)-1; 
    end
    if Costellation(1,2)==1
        Sat_num_GLO(ii)=length(out(ii).GLO.el)-1;
         Sat_num(ii)=Sat_num(ii)+length(out(ii).GLO.el)-1;
    end
    if Costellation(1,3)==1
        Sat_num_BEI(ii)=length(out(ii).BEI.el)-1;
         Sat_num(ii)=Sat_num(ii)+length(out(ii).BEI.el)-1;
    end
    if Costellation(1,4)==1
        Sat_num_GAL(ii)=length(out(ii).GAL.el)-1;
         Sat_num(ii)=Sat_num(ii)+length(out(ii).GAL.el)-1;
    end

end
subplot(2,1,2)
hold on
% plot(ax,Sat_num,'r','LineWidth',1)
if Costellation(1,1)==1
    plot(ax,Sat_num_GPS,'k')
    disp('Mean of sat GPS:')
    mean(Sat_num_GPS)
end
if Costellation(1,2)==1
    plot(ax,Sat_num_GLO,'b')
    disp('Mean of sat GLO:')
    mean(Sat_num_GLO)

end
if Costellation(1,3)==1
    plot(ax,Sat_num_BEI,'g')
    disp('Mean of sat BEI:')
    mean(Sat_num_BEI)

end
if Costellation(1,4)==1
    plot(ax,Sat_num_GAL,'m')
    disp('Mean of sat GAL:')
    mean(Sat_num_GAL)

end
title('Number of total visible satellites')
grid on
grid minor
xlabel('Day Time  [hh:mm]')
datetick('x','HH:MM');
hold off
