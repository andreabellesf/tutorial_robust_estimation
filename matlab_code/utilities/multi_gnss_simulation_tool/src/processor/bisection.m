function [x,e,iter]=bisection(f,a,b,err,itermax)
% bisection Bisection method for equation root finding.
%   [x,e,iter]=bisection(f,a,b,err,itermax)
%
%   INPUT:
%   -f = function
%   -a = min
%   -b = max
%   -err = error threshold
%   -itermax = max nuber of iteration
%
%   OUTPUT:
%   -x = solution
%   -e = error
%   -iter = number of iteration performed
%
%Example
%>>f=@(x)x.^3;
%>>a=-1; b=2;
%>>err=1e-5; itermax=1000;
%>>[x e iter]=kepler(f,a,b,err,itermax);

e=b-a;
iter=0;
if( f(a) * f(b) >= 0 ) 
	x =[];
	disp('f(a) *  f(b) >= 0! No solution!')
else
	while( e > err )
		iter = iter + 1;
		x = 0.5 * ( b + a );
		e = abs(b - x);
		if( f(x) == 0 )
			break;
		elseif( f(x) * f(a) > 0 )
			a = x;
		else
			b = x;
		end
		if( iter == itermax)
			break;
		end	
	end
end