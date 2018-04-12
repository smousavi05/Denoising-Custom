% [maxtab, mintab]=peakdet(v, delta, x);
%
% this function Detects peaks in a vector
% 
% [INPUTS]
% v: input vector. 
% delta: dt.
% nn: arriaval times
%
% [OUTPUTS]
% maxtab: maximum. 
% mintab: minimum
% -------------------------------------------------------------------------
% Mostafa Mousavi, smousavi@memphis.edu 
% Last modify: Oct 2, 2016
% -------------------------------------------------------------------------

function [maxtab, mintab]=peakdet(v, delta, x)
maxtab = [];
mintab = [];

v = v(:);

if nargin < 3
  x = (1:length(v))';
else 
  x = x(:);
  if length(v)~= length(x)
    error('Input vectors v and x must have same length');
  end
end
  

mn = Inf; mx = -Inf;
mnpos = NaN; mxpos = NaN;

lookformax = 1;

for i=1:length(v)
  this = v(i);
  if this > mx, mx = this; mxpos = x(i); end
  if this < mn, mn = this; mnpos = x(i); end
  
  if lookformax
    if this < mx-delta
      maxtab = [maxtab ; mxpos mx];
      mn = this; mnpos = x(i);
      lookformax = 0;
    end  
  else
    if this > mn+delta
      mintab = [mintab ; mnpos mn];
      mx = this; mxpos = x(i);
      lookformax = 1;
    end
  end
end