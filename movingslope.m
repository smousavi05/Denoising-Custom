% Dvec = movingslope(vec,supportlength,modelorder,dt);
%
% This function estimates local slope for a sequence of points, using a sliding window
%
% [INPUTD]
%  vec: row of column vector.
%  supportlength: defines the number of points used for the moving window (at least 2).
%  modelorder: Defines the order of the windowed model used to estimate the slope (at least 1). 
%  dt: spacing for sequences 
%  
%  [OUTPUT]
%  Dvec: vector of derivative estimates.
%--------------------------------------------------------------------------


function Dvec = movingslope(vec,supportlength,modelorder,dt)
n = length(vec);
% supply defaults
if (nargin<4) || isempty(dt)
  dt = 1;
end
if (nargin<3) || isempty(modelorder)
  modelorder = 1;
end
if (nargin<2) || isempty(supportlength)
  supportlength = 3;
end

% check the parameters for problems
if (length(supportlength)~=1) || (supportlength<=1) || (supportlength>n) || (supportlength~=floor(supportlength))
  error('supportlength must be a scalar integer, >= 2, and no more than length(vec)')
end
if (length(modelorder)~=1) || (modelorder<1) || (modelorder>min(10,supportlength-1)) || (modelorder~=floor(modelorder))
  error('modelorder must be a scalar integer, >= 1, and no more than min(10,supportlength-1)')
end
if (length(dt)~=1) || (dt<0)
  error('dt must be a positive scalar numeric variable')
end

if mod(supportlength,2) == 1
  parity = 1; % odd parity
else
  parity = 0;
end
s = (supportlength-parity)/2;
t = ((-s+1-parity):s)';
coef = getcoef(t,supportlength,modelorder);

f = filter(-coef,1,vec);
Dvec = zeros(size(vec));
Dvec(s+(1:(n-supportlength+1))) = f(supportlength:end);

% patch each end
vec = vec(:);
for i = 1:s
  % patch the first few points
  t = (1:supportlength)' - i;
  coef = getcoef(t,supportlength,modelorder);
  
  Dvec(i) = coef*vec(1:supportlength);
  
  % patch the end points
  if i<(s + parity)
    t = (1:supportlength)' - supportlength + i - 1;
    coef = getcoef(t,supportlength,modelorder);
    Dvec(n - i + 1) = coef*vec(n + (0:(supportlength-1)) + 1 - supportlength);
  end
end

% scale by the supplied spacing
Dvec = Dvec/dt;
% all done

end 

% subfunction, used to compute the filter coefficients
function coef = getcoef(t,supportlength,modelorder)
A = repmat(t,1,modelorder+1).^repmat(0:modelorder,supportlength,1);
pinvA = pinv(A);
coef = pinvA(2,:);
end 

