function [JD,tetaG0,tetaG]=juliandata(anno,mese,giorno,ora)
% juliandata Compute the Julan date
% Calcola il Julian Date e il tetaG0(specificare l'ora con la funzione
% time2ora in UT1
if mese<=2
    y=anno-1;
    m=mese+12;
else
    y=anno;
    m=mese;
end
JD=floor(365.25*y)+floor(30.6001*(m+1))+giorno+ora/24+1720981.5;
JDut1=floor(365.25*y)+floor(30.6001*(m+1))+giorno+1720981.5;
Tu=(JDut1-2451540.0)/36526;
tetaG0=((6*3600+41*60+50.54841+864018.812866*Tu+0.093104*Tu^2-(6.2e-6)*Tu^3)/3600)*(2*pi)/24;
tetaG=(1.0027379093*ora)*2*pi/24+tetaG0;
end
