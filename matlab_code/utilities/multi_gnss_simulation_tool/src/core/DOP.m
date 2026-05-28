function [PDOP,H]=DOP(SatPos)
% DOP Evaluate the position dilution of precision (PDOP).
%   [Pdop, H] = DOP(SatPos)
%   
%   INPUT:
%   SatPos = satellite position with respect to point of interest [dx, dy, dz]
%
%   OUTPUT:
%   Pdop = position dilution of precision
%   H = geometry matrix

if length(SatPos(1,:))>3
for i=1:(length(SatPos(1,:))-1)
    x=SatPos(1,i);
    y=SatPos(2,i);
    z=SatPos(3,i);
    r=sqrt(x^2+y^2+z^2);
    ax=x/r;
    ay=y/r;
    az=z/r;
    H(i,:)=[ax ay az];
end
G=inv(H'*H);
PDOP=sqrt(G(1,1)+G(2,2)+G(3,3));
% if PDOP>50
%     PDOP=50;
% end
end
if length(SatPos(1,:))>1 && length(SatPos(1,:))<=3
    PDOP=NaN;
for i=1:(length(SatPos(1,:))-1)
    x=SatPos(1,i);
    y=SatPos(2,i);
    z=SatPos(3,i);
    r=sqrt(x^2+y^2+z^2);
    ax=x/r;
    ay=y/r;
    az=z/r;
    H(i,:)=[ax ay az];
end
end
if length(SatPos(1,:))==1
    PDOP=NaN;
    H=[0 0 0];
end