function Multi_PDOP=multipdop(Costellation,out,kk)
% multipdop Evaluate PDOP for multiple systems.
%   Multi_PDOP=multipdop(Costellation,out,kk)

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
    case 'GR00'
        HGPS=out(kk).GPS.H;
        HGLO=out(kk).GLO.H;
        H=[HGPS;HGLO];
        n=rank(H);
        if n<3
            Multi_PDOP=NaN;
        else
        G=inv(H'*H);
        Multi_PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
        end
    case 'G0C0'
        HGPS=out(kk).GPS.H;
        HBEI=out(kk).BEI.H;
        H=[HGPS;HBEI];
        n=rank(H);
        if n<3
            Multi_PDOP=NaN;
        else
        G=inv(H'*H);
        Multi_PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
        end

    case 'G00E'
        HGPS=out(kk).GPS.H;
        HGAL=out(kk).GAL.H;
        H=[HGPS;HGAL];
        n=rank(H);
        if n<3
            Multi_PDOP=NaN;
        else
        G=inv(H'*H);
        Multi_PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
        end
    case '0RC0'
        HGLO=out(kk).GLO.H;
        HBEI=out(kk).BEI.H;
        H=[HGLO;HBEI];
        n=rank(H);
        if n<3
            Multi_PDOP=NaN;
        else
        G=inv(H'*H);
        Multi_PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
        end

    case '0R0E'
        HGLO=out(kk).GLO.H;
        HGAL=out(kk).GAL.H;
        H=[HGLO;HGAL];
        n=rank(H);
        if n<3
            Multi_PDOP=NaN;
        else
        G=inv(H'*H);
        Multi_PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
        end

    case '00CE'
        HBEI=out(kk).BEI.H;
        HGAL=out(kk).GAL.H;
        H=[HBEI;HGAL];
        n=rank(H);
        if n<3
            Multi_PDOP=NaN;
        else
        G=inv(H'*H);
        Multi_PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
        end

    case 'GRC0'
        HGPS=out(kk).GPS.H;
        HGLO=out(kk).GLO.H;
        HBEI=out(kk).BEI.H;
        H=[HGPS;HGLO;HBEI];
        n=rank(H);
        if n<3
            Multi_PDOP=NaN;
        else
        G=inv(H'*H);
        Multi_PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
        end

    case 'GR0E'
        HGPS=out(kk).GPS.H;
        HGLO=out(kk).GLO.H;
        HGAL=out(kk).GAL.H;
        H=[HGPS;HGLO;HGAL];
        n=rank(H);
        if n<3
            Multi_PDOP=NaN;
        else
        G=inv(H'*H);
        Multi_PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
        end

    case 'G0CE'
        HGPS=out(kk).GPS.H;
        HBEI=out(kk).BEI.H;
        HGAL=out(kk).GAL.H;
        H=[HGPS;HBEI;HGAL];
        n=rank(H);
        if n<3
            Multi_PDOP=NaN;
        else
        G=inv(H'*H);
        Multi_PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
        end

    case '0RCE'
        HGLO=out(kk).GLO.H;
        HBEI=out(kk).BEI.H;
        HGAL=out(kk).GAL.H;
        H=[HGLO;HBEI;HGAL];
        n=rank(H);
        if n<3
            Multi_PDOP=NaN;
        else
        G=inv(H'*H);
        Multi_PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
        end

    case 'GRCE'
        HGPS=out(kk).GPS.H;
        HGLO=out(kk).GLO.H;
        HBEI=out(kk).BEI.H;
        HGAL=out(kk).GAL.H;
        H=[HGPS;HGLO;HBEI;HGAL];
        n=rank(H);
        if n<3
            Multi_PDOP=NaN;
        else
        G=inv(H'*H);
        Multi_PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
        end

    otherwise
        disp('Multi PDOP DISABLED')
        Multi_PDOP=0;
end
