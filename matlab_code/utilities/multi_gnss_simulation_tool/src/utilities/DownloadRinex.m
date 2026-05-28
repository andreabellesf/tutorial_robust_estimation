%% Download Rinex
% Automatic download of last brdc rinex from igs-ftp.bkg.bund.de.

disp('Download last available rinex...')
rin=ftp('igs-ftp.bkg.bund.de');
cd(rin,'NTRIP');
cd(rin,'BRDC_v3');
mget(rin,'brdc_last_v3.rnx.Z');
close(rin);
% rinexrnx=untar('brdc_last_v3.rnx.Z');
! start WinRaR e brdc_last_v3.rnx.Z
pause(5)
str_date = date;
str_path = strcat('input\brdc_rinex\rinex_',str_date,'.rnx');
movefile('brdc_last_v3.rnx',str_path)
delete("brdc_last_v3.rnx.Z")