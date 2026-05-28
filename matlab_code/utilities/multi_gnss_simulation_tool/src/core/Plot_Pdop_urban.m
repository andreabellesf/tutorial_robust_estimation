function Plot_Pdop_urban(out,Costellation,MultiPDOP,step_sim,Insert_data)
% Plot_Pdop_urban Plot the Pdop for the simulated scenarion in urban
% environment

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
    disp('Mean of urban GPS pdop')
    mean(Pdop_GPS, 'omitnan')
end
if Costellation(1,2)==1
    disp('Mean of urban Glonass pdop')
    mean(Pdop_GLO, 'omitnan')
end
if Costellation(1,3)==1
    disp('Mean of urban Beidou pdop')
    mean(Pdop_BEI, 'omitnan')
end
if Costellation(1,4)==1
    disp('Mean of urban Galileo pdop')
    mean(Pdop_GAL, 'omitnan')
end

%% Figure PDOP and Total Visible SATELLITES
% ax=[0:length(out)-1];
s1=Insert_data(1,4)*3600;
s2=(Insert_data(1,5))*60;
s3=Insert_data(1,6);
ax=[seconds(s1+s2+s3):seconds(step_sim):seconds(s1+s2+s3+((length(out)-1)*step_sim))];
% ax=[(s1+s2+s3):(step_sim*60):(s1+s2+s3+((length(out)-1)*step_sim*60))];
% for kk=1:length(ax)
%     if ax(kk)>=86400
%         ax(kk)=ax(kk)-86400;
%     end
% end
% ax=seconds(ax)%[seconds(s1+s2+s3):seconds(step_sim*60):seconds(s1+s2+s3+((length(out)-1)*step_sim*60))];

figure
subplot(2,1,1)
if Costellation(1,1)==1
   plot(ax,Pdop_GPS,'k','DurationTickFormat','dd:hh:mm:ss')
   text(1,0.95,'\sl Gps','Color','k','Units','normalized')
end
hold on
if Costellation(1,2)
   plot(ax,Pdop_GLO,'b','DurationTickFormat','dd:hh:mm:ss')
   text(1,0.9,'\sl Glonass','Color','b','Units','normalized')
end
if Costellation(1,3)==1
    plot(ax,Pdop_BEI,'g','DurationTickFormat','dd:hh:mm:ss')
    text(1,0.85,'\sl Beidou','Color','g','Units','normalized')
end
if Costellation(1,4)==1
    plot(ax,Pdop_GAL,'m','DurationTickFormat','dd:hh:mm:ss')
    text(1,0.8,'\sl Galileo','Color','m','Units','normalized')
end
if sum(Costellation)>1
   plot(ax,MultiPDOP,'r','DurationTickFormat','dd:hh:mm:ss')
   text(1,1,'\sl MULTI','Color','r','Units','normalized')
end
grid on
grid minor
title('PDOP in Urban Enviroment')
xlabel('Day Time [dd:hh:mm:ss]')
ylabel('Pdop [m]')
ylim([0 50])

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
plot(ax,Sat_num,'r','LineWidth',1,'DurationTickFormat','dd:hh:mm:ss')
if Costellation(1,1)==1
    plot(ax,Sat_num_GPS,'k')
    disp('Mean pf sat Gps urban:')
    mean(Sat_num_GPS)
end
if Costellation(1,2)==1
    plot(ax,Sat_num_GLO,'b')
    disp('Mean pf sat Glonass urban:')
    mean(Sat_num_GLO)
end
if Costellation(1,3)==1
    plot(ax,Sat_num_BEI,'g')
    disp('Mean pf sat BeiDou urban:')
    mean(Sat_num_BEI)
    
end
if Costellation(1,4)==1
    plot(ax,Sat_num_GAL,'m')
    disp('Mean pf sat Galileo urban:')
    mean(Sat_num_GAL)
    
end
title('Number of total visible satellites')
grid on
grid minor
xlabel('Day Time')
hold off
