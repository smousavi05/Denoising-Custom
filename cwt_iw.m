% function x = cwt_iw(Wx, type, opt)
%
% The inverse wavelet transform of signal Wx
%
% Implements Eq. (4.67) of [1].
%
% 1. Mallat, S., Wavelet Tour of Signal Processing 3rd ed.
%
% Inputs:
%  Wx: wavelet transform of a signal, see help cwt_fw
%  type: wavelet used to take the wavelet transform,
%        see help cwt_fw and help wfiltfn
%  opt: options structure used for forward wavelet transform.
%
% Output:
%  x: the signal, as reconstructed from Wx
%
%---------------------------------------------------------------------------------
%    Authors: Eugene Brevdo 
%---------------------------------------------------------------------------------
function x = cwt_iw(Wx, type, opt,nv)
    if nargin<3, opt = struct(); end

    [na, n] = size(Wx);

%     [N,n1,n2] = p2up(n);
    N = 2^(1+round(log2(n+eps)));
    n1 = floor((N-n)/2); n2 = n1;
    if (mod(2*n1+n,2)==1), n2 = n1 + 1; end
    Wxp = zeros(na, N);

    % TODO - do we want to pad the wavelet representation here?  Or not
    % cut off Wx in cwt_fw and then use that to reconstruct?
    Wxp(:, n1+1:n1+n) = Wx;
    Wx = Wxp; clear Wxp;

    % Following the same value in cwt_fw
    noct = log2(N)-1;
%     nv = na/noct;
    as = 2^(1/nv) .^ (1:1:na);
    
    assert(mod(noct,1) == 0);
    assert(nv>0 && mod(nv,1)==0); % integer

    % Find the admissibility coefficient Cpsi
    switch type
      case 'sombrero',
        if ~isfield(opt,'s'), s = 1; else s = opt.s; end
        Cpsi = (4/3)*s*sqrt(pi);
      case 'shannon',
        Cpsi = log(2);
      otherwise
        psihfn = wfiltfn(type, opt);
        Cpsi = quadgk(@(x) (conj(psihfn(x)).*psihfn(x))./x, 0, Inf);
    end
    
    % Normalize
    Cpsi = Cpsi / (4*pi);
    
    x = zeros(1, N);
    for ai=1:na
        a = as(ai);
        Wxa = Wx(ai, :);

        psih = wfilth(type, N, a, opt);

        % Convolution theorem here
        Wxah = fft(Wxa);
        xah = Wxah .* psih;
        xa = ifftshift(ifft(xah));
        
        x = x + xa/a;
    end

     % Take real part and normalize by log_e(a)/Cpsi
     x = log(2^(1/nv))/Cpsi * real(x);

     % Keep the unpadded part
     x = x(n1+1: n1+n);

end % cwt_iw
