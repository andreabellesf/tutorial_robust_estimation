function urban=urban_simulation(out,Costellation,dir_az,width,height)
% urban_simulation Perform the simulation of visible satellites in urban
% environment.

dir=dir_az;
if Costellation(1,1)==1
    for istant=1:length(out)
        in=1;
    for k=1:(length(out(istant).GPS.el)-1)
        el_sat=(out(istant).GPS.el(1,k));
        theta=(out(istant).GPS.az(1,k));
        theta=theta-dir;
        dist=abs((width/2)/sin(theta));
        alpha_el=atan(height/dist);
        if el_sat>=alpha_el
            theta=theta+dir;
            urban(istant).GPS.PRN{1,in}=out(istant).GPS.PRN{1,k};
            urban(istant).GPS.el(1,in)=el_sat;
            urban(istant).GPS.az(1,in)=theta;
            urban(istant).GPS.time=out(istant).GPS.time;
            urban(istant).GPS.date=out(istant).GPS.date;
            urban(istant).GPS.xyz(:,in)=out(istant).GPS.xyz(:,k);
            in=in+1;
        end
    end
        %% Invalid
        invalid={'invalid'};
        urban(istant).GPS.el(1,in)=NaN;
        urban(istant).GPS.az(1,in)=NaN;
        urban(istant).GPS.PRN{1,in}=invalid;
        urban(istant).GPS.xyz(:,in)=[0;0;0];
        urban(istant).GPS.time=out(istant).GPS.time;
        urban(istant).GPS.date=out(istant).GPS.date;
        SatPos=urban(istant).GPS.xyz;
        [urban(istant).GPS.PDOP,urban(istant).GPS.H]=DOP(SatPos);

    
    end
end
if Costellation(1,2)==1
    for istant=1:length(out)
        in=1;
    for k=1:(length(out(istant).GLO.el)-1)
        el_sat=(out(istant).GLO.el(1,k));
        theta=(out(istant).GLO.az(1,k));
        theta=theta-dir;
        dist=abs((width/2)/sin(theta));
        alpha_el=atan(height/dist);
        if el_sat>=alpha_el
            theta=theta+dir;
            urban(istant).GLO.SV{1,in}=out(istant).GLO.SV{1,k};
            urban(istant).GLO.el(1,in)=el_sat;
            urban(istant).GLO.az(1,in)=theta;
            urban(istant).GLO.time=out(istant).GLO.time;
            urban(istant).GLO.date=out(istant).GLO.date;
            urban(istant).GLO.xyz(:,in)=out(istant).GLO.xyz(:,k);
            in=in+1;
        end
    end
            %% Invalid
        invalid={'invalid'};
        urban(istant).GLO.el(1,in)=NaN;
        urban(istant).GLO.az(1,in)=NaN;
        urban(istant).GLO.SV{1,in}=invalid;
        urban(istant).GLO.xyz(:,in)=[0;0;0];
        urban(istant).GLO.time=out(istant).GLO.time;
        urban(istant).GLO.date=out(istant).GLO.date;
        SatPos=urban(istant).GLO.xyz;
        [urban(istant).GLO.PDOP,urban(istant).GLO.H]=DOP(SatPos);

    end
end
if Costellation(1,3)==1
    for istant=1:length(out)
        in=1;
    for k=1:(length(out(istant).BEI.el)-1)
        el_sat=(out(istant).BEI.el(1,k));
        theta=(out(istant).BEI.az(1,k));
        theta=theta-dir;
        dist=abs((width/2)/sin(theta));
        alpha_el=atan(height/dist);
        if el_sat>=alpha_el
            theta=theta+dir;
            urban(istant).BEI.PRN{1,in}=out(istant).BEI.PRN{1,k};
            urban(istant).BEI.el(1,in)=el_sat;
            urban(istant).BEI.az(1,in)=theta;
            urban(istant).BEI.time=out(istant).BEI.time;
            urban(istant).BEI.date=out(istant).BEI.date;
            urban(istant).BEI.xyz(:,in)=out(istant).BEI.xyz(:,k);
            in=in+1;
        end
    end
            %% Invalid
        invalid={'invalid'};
        urban(istant).BEI.el(1,in)=NaN;
        urban(istant).BEI.az(1,in)=NaN;
        urban(istant).BEI.PRN{1,in}=invalid;
        urban(istant).BEI.xyz(:,in)=[0;0;0];
        urban(istant).BEI.time=out(istant).BEI.time;
        urban(istant).BEI.date=out(istant).BEI.date;
        SatPos=urban(istant).BEI.xyz;
        [urban(istant).BEI.PDOP,urban(istant).BEI.H]=DOP(SatPos);

    end
end
if Costellation(1,4)==1
    for istant=1:length(out)
        in=1;
    for k=1:(length(out(istant).GAL.el)-1)
        el_sat=(out(istant).GAL.el(1,k));
        theta=(out(istant).GAL.az(1,k));
        theta=theta-dir;
        dist=abs((width/2)/sin(theta));
        alpha_el=atan(height/dist);
        if el_sat>=alpha_el
            theta=theta+dir;
            urban(istant).GAL.SV{1,in}=out(istant).GAL.SV{1,k};
            urban(istant).GAL.el(1,in)=el_sat;
            urban(istant).GAL.az(1,in)=theta;
            urban(istant).GAL.time=out(istant).GAL.time;
            urban(istant).GAL.date=out(istant).GAL.date;
            urban(istant).GAL.xyz(:,in)=out(istant).GAL.xyz(:,k);
            in=in+1;
        end
    end
            %% Invalid
        invalid={'invalid'};
        urban(istant).GAL.el(1,in)=NaN;
        urban(istant).GAL.az(1,in)=NaN;
        urban(istant).GAL.PRN{1,in}=invalid;
        urban(istant).GAL.xyz(:,in)=[0;0;0];
        urban(istant).GAL.time=out(istant).GAL.time;
        urban(istant).GAL.date=out(istant).GAL.date;
        SatPos=urban(istant).GAL.xyz;
        [urban(istant).GAL.PDOP,urban(istant).GAL.H]=DOP(SatPos);

    end
end