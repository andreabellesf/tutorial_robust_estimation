function Skyplot(Insert_data,step_sim,out,Skyplot_time,Skyplot_costellation,Costellation, downsample_skyplot)
% SKYPLOT Generate a skyplot with the visible satellites.
%   Skyplot(Insert_data,step_sim,out,Skyplot_time,Skyplot_costellation,Costellation, downsample_skyplot)


figure
axis square
axis off
hold on
Gradi={'90°','75°','60°','45°','30°','15°','0°'};
vet=[0 15 30 45 60 75 90];
k=1;
for i=vet
    raggio=i;
    teta=[0:pi/256:2*pi];
    xraggio=raggio*cos(teta);
    yraggio=raggio*sin(teta);
    plot(xraggio,yraggio,'b')
    text(0.1,raggio-3,Gradi(1,k),'FontSize',8)
    k=k+1;
end
radius=96;
line1=[radius*cos(pi/6) radius*sin(pi/6);radius*cos(7*pi/6) radius*sin(7*pi/6)];
line2=[radius*cos(pi/3) radius*sin(pi/3);radius*cos(4*pi/3) radius*sin(4*pi/3)];
line3=[radius*cos(-pi/6) radius*sin(-pi/6);radius*cos(5*pi/6) radius*sin(5*pi/6)];
line4=[radius*cos(4*pi/6) radius*sin(4*pi/6);radius*cos(-pi/3) radius*sin(-pi/3)];
line5=[90 0;-90 0];
line6=[0 90;0 -90];
plot(line1(:,1),line1(:,2),'b')
plot(line2(:,1),line2(:,2),'b')
plot(line3(:,1),line3(:,2),'b')
plot(line4(:,1),line4(:,2),'b')
plot(line5(:,1),line5(:,2),'b')
plot(line6(:,1),line6(:,2),'b')

text(line1(1,1),line1(1,2),'60°','HorizontalAlignment','center')
text(line2(1,1),line2(1,2),'30°','HorizontalAlignment','center')
text(line1(2,1),line1(2,2),'240°','HorizontalAlignment','center')
text(line2(2,1),line2(2,2),'100°','HorizontalAlignment','center')
text(line3(1,1),line3(1,2),'120°','HorizontalAlignment','center')
text(line3(2,1),line3(2,2),'300°','HorizontalAlignment','center')
text(line4(1,1),line4(1,2),'330°','HorizontalAlignment','center')
text(line4(2,1),line4(2,2),'150°','HorizontalAlignment','center')
text(0,95,'N','HorizontalAlignment','center','FontSize',12)
text(95,0,'E','HorizontalAlignment','center','FontSize',12)
text(0,-95,'S','HorizontalAlignment','center','FontSize',12)
text(-95,0,'W','HorizontalAlignment','center','FontSize',12)
title({'SKYPLOT'},'FontSize',14)

%% Skyplot of one istant
if length(Skyplot_time)==1
    UTC=time_fun(Insert_data(1,4)*3600+Insert_data(1,5)*60+Insert_data(1,6)+Skyplot_time*3600,Insert_data);
    str_date=[num2str(UTC(1,1)),'-',num2str(UTC(1,2)),'-',num2str(UTC(1,3)),'  ',num2str(UTC(1,4)),':',num2str(UTC(1,5)),':',num2str(UTC(1,6))];
%     str_sim=num2str(Skyplot_time);
    str_stamp=[str_date,' UTC'];
    text(0,0,str_stamp,'Units','normalized')

    istant=(Skyplot_time*3600)/(int32(step_sim*downsample_skyplot))+1;
    switch Skyplot_costellation
        case 1
            for k=1:(length(out(istant).GPS.el)-1)
                ro=90-abs(rad2deg(out(istant).GPS.el(1,k)));
                theta=(out(istant).GPS.az(1,k));
                sat=out(istant).GPS.PRN{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','k','MarkerSize',6)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
               text(1,0.95,'\sl Gps','Color','k','Units','normalized')

        case 2
            for k=1:(length(out(istant).GLO.el)-1)
                ro=90-abs(rad2deg(out(istant).GLO.el(1,k)));
                theta=(out(istant).GLO.az(1,k));
                sat=out(istant).GLO.SV{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','b','MarkerSize',6)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
               text(1,0.9,'\sl Glonass','Color','b','Units','normalized')

        case 3
            for k=1:(length(out(istant).BEI.el)-1)
                ro=90-abs(rad2deg(out(istant).BEI.el(1,k)));
                theta=(out(istant).BEI.az(1,k));
                sat=out(istant).BEI.PRN{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','g','MarkerSize',6)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
                text(1,0.85,'\sl Beidou','Color',[0 0.4 0],'Units','normalized')

        case 4
            for k=1:(length(out(istant).GAL.el)-1)
                ro=90-abs(rad2deg(out(istant).GAL.el(1,k)));
                theta=(out(istant).GAL.az(1,k));
                sat=out(istant).GAL.SV{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','m','MarkerSize',6)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
                text(1,0.8,'\sl Galileo','Color','m','Units','normalized')

        case 5
            if Costellation(1,1)==1
                for k=1:(length(out(istant).GPS.el)-1)
                    ro=90-abs(rad2deg(out(istant).GPS.el(1,k)));
                    theta=(out(istant).GPS.az(1,k));
                    sat=out(istant).GPS.PRN{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','k','MarkerSize',6)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                   text(1,0.95,'\sl Gps','Color','k','Units','normalized')

            end
            if Costellation(1,2)==1
                for k=1:(length(out(istant).GLO.el)-1)
                    ro=90-abs(rad2deg(out(istant).GLO.el(1,k)));
                    theta=(out(istant).GLO.az(1,k));
                    sat=out(istant).GLO.SV{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','b','MarkerSize',6)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                   text(1,0.9,'\sl Glonass','Color','b','Units','normalized')

            end
            if Costellation(1,3)==1
                for k=1:(length(out(istant).BEI.el)-1)
                    ro=90-abs(rad2deg(out(istant).BEI.el(1,k)));
                    theta=(out(istant).BEI.az(1,k));
                    sat=out(istant).BEI.PRN{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','g','MarkerSize',6)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                    text(1,0.85,'\sl Beidou','Color',[0 0.4 0],'Units','normalized')

            end
            if Costellation(1,4)==1
                for k=1:(length(out(istant).GAL.el)-1)
                    ro=90-abs(rad2deg(out(istant).GAL.el(1,k)));
                    theta=(out(istant).GAL.az(1,k));
                    sat=out(istant).GAL.SV{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','m','MarkerSize',6)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                    text(1,0.8,'\sl Galileo','Color','m','Units','normalized')

            end
    end
end
if length(Skyplot_time)==2
    UTC1=time_fun(Insert_data(1,4)*3600+Insert_data(1,5)*60+Insert_data(1,6)+Skyplot_time(1,1)*3600,Insert_data);
    str_date1=[num2str(UTC1(1,1)),'-',num2str(UTC1(1,2)),'-',num2str(UTC1(1,3)),'  ',num2str(UTC1(1,4)),':',num2str(UTC1(1,5)),':',num2str(UTC1(1,6))];
    UTC2=time_fun(Insert_data(1,4)*3600+Insert_data(1,5)*60+Insert_data(1,6)+Skyplot_time(1,2)*3600,Insert_data);
    str_date2=[num2str(UTC2(1,1)),'-',num2str(UTC2(1,2)),'-',num2str(UTC2(1,3)),'  ',num2str(UTC2(1,4)),':',num2str(UTC2(1,5)),':',num2str(UTC2(1,6))];

    %     str_sim=num2str(Skyplot_time);
    str_stamp=[str_date1,' to ',str_date2,' UTC'];
    text(0,0,str_stamp,'Units','normalized')

    istant=(Skyplot_time(1,1)*3600)/(int32(step_sim*downsample_skyplot))+1;
    switch Skyplot_costellation
        case 1
            for k=1:(length(out(istant).GPS.el)-1)
                ro=90-abs(rad2deg(out(istant).GPS.el(1,k)));
                theta=(out(istant).GPS.az(1,k));
                sat=out(istant).GPS.PRN{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','k','MarkerSize',6)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
               text(1,0.95,'\sl Gps','Color','k','Units','normalized')

        case 2
            for k=1:(length(out(istant).GLO.el)-1)
                ro=90-abs(rad2deg(out(istant).GLO.el(1,k)));
                theta=(out(istant).GLO.az(1,k));
                sat=out(istant).GLO.SV{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','b','MarkerSize',6)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
               text(1,0.9,'\sl Glonass','Color','b','Units','normalized')

        case 3
            for k=1:(length(out(istant).BEI.el)-1)
                ro=90-abs(rad2deg(out(istant).BEI.el(1,k)));
                theta=(out(istant).BEI.az(1,k));
                sat=out(istant).BEI.PRN{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','g','MarkerSize',6)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
                text(1,0.85,'\sl Beidou','Color',[0 0.4 0],'Units','normalized')

        case 4
            for k=1:(length(out(istant).GAL.el)-1)
                ro=90-abs(rad2deg(out(istant).GAL.el(1,k)));
                theta=(out(istant).GAL.az(1,k));
                sat=out(istant).GAL.SV{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','m','MarkerSize',6)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
                text(1,0.8,'\sl Galileo','Color','m','Units','normalized')

        case 5
            if Costellation(1,1)==1
                for k=1:(length(out(istant).GPS.el)-1)
                    ro=90-abs(rad2deg(out(istant).GPS.el(1,k)));
                    theta=(out(istant).GPS.az(1,k));
                    sat=out(istant).GPS.PRN{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','k','MarkerSize',6)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                   text(1,0.95,'\sl Gps','Color','k','Units','normalized')

            end
            if Costellation(1,2)==1
                for k=1:(length(out(istant).GLO.el)-1)
                    ro=90-abs(rad2deg(out(istant).GLO.el(1,k)));
                    theta=(out(istant).GLO.az(1,k));
                    sat=out(istant).GLO.SV{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','b','MarkerSize',6)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                   text(1,0.9,'\sl Glonass','Color','b','Units','normalized')

            end
            if Costellation(1,3)==1
                for k=1:(length(out(istant).BEI.el)-1)
                    ro=90-abs(rad2deg(out(istant).BEI.el(1,k)));
                    theta=(out(istant).BEI.az(1,k));
                    sat=out(istant).BEI.PRN{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','g','MarkerSize',6)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                    text(1,0.85,'\sl Beidou','Color',[0 0.4 0],'Units','normalized')

            end
            if Costellation(1,4)==1
                for k=1:(length(out(istant).GAL.el)-1)
                    ro=90-abs(rad2deg(out(istant).GAL.el(1,k)));
                    theta=(out(istant).GAL.az(1,k));
                    sat=out(istant).GAL.SV{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'kv','MarkerFaceColor','m','MarkerSize',6)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                    text(1,0.8,'\sl Galileo','Color','m','Units','normalized')

            end
    end
    
    
    istant1=istant+1;
    istant2=(Skyplot_time(1,2)*3600)/(int32(step_sim*downsample_skyplot))+1;
    for istant=istant1:istant2-1
    switch Skyplot_costellation
        case 1
            for k=1:(length(out(istant).GPS.el)-1)
                ro=90-abs(rad2deg(out(istant).GPS.el(1,k)));
                theta=(out(istant).GPS.az(1,k));
                sat=out(istant).GPS.PRN{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'ko','MarkerFaceColor','k','MarkerSize',3)
            end

        case 2
            for k=1:(length(out(istant).GLO.el)-1)
                ro=90-abs(rad2deg(out(istant).GLO.el(1,k)));
                theta=(out(istant).GLO.az(1,k));
                sat=out(istant).GLO.SV{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'ko','MarkerFaceColor','b','MarkerSize',3)
            end

        case 3
            for k=1:(length(out(istant).BEI.el)-1)
                ro=90-abs(rad2deg(out(istant).BEI.el(1,k)));
                theta=(out(istant).BEI.az(1,k));
                sat=out(istant).BEI.PRN{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'ko','MarkerFaceColor','g','MarkerSize',3)
            end

        case 4
            for k=1:(length(out(istant).GAL.el)-1)
                ro=90-abs(rad2deg(out(istant).GAL.el(1,k)));
                theta=(out(istant).GAL.az(1,k));
                sat=out(istant).GAL.SV{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'ko','MarkerFaceColor','m','MarkerSize',o)
            end

        case 5
            if Costellation(1,1)==1
                for k=1:(length(out(istant).GPS.el)-1)
                    ro=90-abs(rad2deg(out(istant).GPS.el(1,k)));
                    theta=(out(istant).GPS.az(1,k));
                    sat=out(istant).GPS.PRN{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'ko','MarkerFaceColor','k','MarkerSize',3)
                end

            end
            if Costellation(1,2)==1
                for k=1:(length(out(istant).GLO.el)-1)
                    ro=90-abs(rad2deg(out(istant).GLO.el(1,k)));
                    theta=(out(istant).GLO.az(1,k));
                    sat=out(istant).GLO.SV{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'ko','MarkerFaceColor','b','MarkerSize',3)
                end

            end
            if Costellation(1,3)==1
                for k=1:(length(out(istant).BEI.el)-1)
                    ro=90-abs(rad2deg(out(istant).BEI.el(1,k)));
                    theta=(out(istant).BEI.az(1,k));
                    sat=out(istant).BEI.PRN{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'ko','MarkerFaceColor','g','MarkerSize',3)
                end

            end
            if Costellation(1,4)==1
                for k=1:(length(out(istant).GAL.el)-1)
                    ro=90-abs(rad2deg(out(istant).GAL.el(1,k)));
                    theta=(out(istant).GAL.az(1,k));
                    sat=out(istant).GAL.SV{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'ko','MarkerFaceColor','m','MarkerSize',2)
                end

            end
    end
    end
    istant=istant2;
        switch Skyplot_costellation
        case 1
            for k=1:(length(out(istant).GPS.el)-1)
                ro=90-abs(rad2deg(out(istant).GPS.el(1,k)));
                theta=(out(istant).GPS.az(1,k));
                sat=out(istant).GPS.PRN{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'k*','MarkerFaceColor','k','MarkerSize',3)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',6,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
               text(1,0.95,'\sl Gps','Color','k','Units','normalized')

        case 2
            for k=1:(length(out(istant).GLO.el)-1)
                ro=90-abs(rad2deg(out(istant).GLO.el(1,k)));
                theta=(out(istant).GLO.az(1,k));
                sat=out(istant).GLO.SV{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'k*','MarkerFaceColor','b','MarkerSize',3)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',6,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
               text(1,0.9,'\sl Glonass','Color','b','Units','normalized')

        case 3
            for k=1:(length(out(istant).BEI.el)-1)
                ro=90-abs(rad2deg(out(istant).BEI.el(1,k)));
                theta=(out(istant).BEI.az(1,k));
                sat=out(istant).BEI.PRN{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'k*','MarkerFaceColor','g','MarkerSize',3)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',6,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
                text(1,0.85,'\sl Beidou','Color',[0 0.4 0],'Units','normalized')

        case 4
            for k=1:(length(out(istant).GAL.el)-1)
                ro=90-abs(rad2deg(out(istant).GAL.el(1,k)));
                theta=(out(istant).GAL.az(1,k));
                sat=out(istant).GAL.SV{1,k};
                plot(ro*(sin(theta)),ro*cos(theta),'k*','MarkerFaceColor','m','MarkerSize',3)
                text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',6,'VerticalAlignment','bottom','HorizontalAlignment','center')
            end
                text(1,0.8,'\sl Galileo','Color','m','Units','normalized')

        case 5
            if Costellation(1,1)==1
                for k=1:(length(out(istant).GPS.el)-1)
                    ro=90-abs(rad2deg(out(istant).GPS.el(1,k)));
                    theta=(out(istant).GPS.az(1,k));
                    sat=out(istant).GPS.PRN{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'k*','MarkerFaceColor','k','MarkerSize',3)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',6,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                   text(1,0.95,'\sl Gps','Color','k','Units','normalized')

            end
            if Costellation(1,2)==1
                for k=1:(length(out(istant).GLO.el)-1)
                    ro=90-abs(rad2deg(out(istant).GLO.el(1,k)));
                    theta=(out(istant).GLO.az(1,k));
                    sat=out(istant).GLO.SV{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'k*','MarkerFaceColor','b','MarkerSize',3)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',6,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                   text(1,0.9,'\sl Glonass','Color','b','Units','normalized')

            end
            if Costellation(1,3)==1
                for k=1:(length(out(istant).BEI.el)-1)
                    ro=90-abs(rad2deg(out(istant).BEI.el(1,k)));
                    theta=(out(istant).BEI.az(1,k));
                    sat=out(istant).BEI.PRN{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'k*','MarkerFaceColor','g','MarkerSize',3)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',6,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                    text(1,0.85,'\sl Beidou','Color',[0 0.4 0],'Units','normalized')

            end
            if Costellation(1,4)==1
                for k=1:(length(out(istant).GAL.el)-1)
                    ro=90-abs(rad2deg(out(istant).GAL.el(1,k)));
                    theta=(out(istant).GAL.az(1,k));
                    sat=out(istant).GAL.SV{1,k};
                    plot(ro*(sin(theta)),ro*cos(theta),'k*','MarkerFaceColor','m','MarkerSize',3)
                    text(ro*(sin(theta)),ro*cos(theta),sat,'FontSize',6,'VerticalAlignment','bottom','HorizontalAlignment','center')
                end
                    text(1,0.8,'\sl Galileo','Color','m','Units','normalized')

            end
    end

end

