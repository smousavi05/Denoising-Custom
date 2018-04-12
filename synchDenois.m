%   [USAGE] 
%   [denoised ] = synchDenois(dec,opt,data,nn);
% 
%   [INPUTS] 
%   dec:    a structure including segmented time-frequency picture of data.
%   opt:    a structure including parameters needed for transforms.
%   data:   a structure including waveform info
%   nn:     a structure including arrival time estimates
%
%   [OUTPUTS]
%   denoised:  denoised signal 
% 
%   [References] 
%   Mousavi S. M., C.A. Langston, and S.P. Horton (2016). Automatic microseismic
%   denoising and onset detection using the synchrosqueezed continuous wavelet 
%   transform, Geophysics, 81 (4), V341-V355, DOI:10.1190/GEO2015-0598.1. 
%
%-------------------------------------------------------------------------- 
%   By: S. Mostafa Mousavi 
%   smousavi@memphis.edu
%   Last time modified: November, 25, 2015
%---------------------------------------------------------------------------
%%%   Copyright (c) 2015 S. Mostafa Mousavi
%%%   All rights reserved.
%%%   This software is provided for non-commercial research purposes only. 
%%%   No warranty is implied by this distribution. Permission is hereby granted
%%%   without written agreement and without license or royalty fees, to use, 
%%%   copy, modify, and distribute this code and its documentation, provided 
%%%   that the copyright notice in its entirety appear in all copies of this 
%%%   code, and the original source of this code, 

function [denoised ] = synchDenois(dec,opt,data,nn);

[txlong ,fxlong] =sst(dec.long,opt);
[txrest ,fxrest] =sst(dec.rest,opt);

% soft thresholding long periods
[na, n] = size(dec.long.wl);
gamma = sqrt(2*log(n)) * mad( abs(dec.long.wl(:))) * 1.4826;
dec.long.wl= SoftThresh(dec.long.wl,gamma);

% Synchrosqueezing
[dn.long ,fs.long] =sst(dec.long,opt);

[Tx, ff, as] = synsq_cwt_fw(data.t, data.x, opt.nv, opt); 

[tx.rest ,fs.rest] =sst(dec.rest,opt);
[tx.noise ,fs.noise] =sst(dec.noise,opt);

gammaN = sqrt(2*log(n)) * mad( abs(tx.noise(:))) * 1.4826;
highN = HardThresh(tx.noise,gammaN);
sigma =  mad(highN(:))./0.6745;
Mmax = mean(max(abs(highN)));
Sig = mad(tx.noise(:))./0.6745;


% finding the frequency band of highest noise concentration 
[nu.noise nd.noise]= sep(highN ,fs.noise, dec.noise.t );


fUp = []; fDn = [];
for i = 1:length(nu.noise);
   fUp = [ fUp fs.noise(nu.noise(i)) ];
   fDn = [ fDn fs.noise(nd.noise(i)) ];
end


idUpRest = []; idDnRest = [];
for j = 1:length(fUp);
tmp = abs(fs.rest(:) - fUp(j));
[m idx] = min(tmp) ;
idUpRest = [idUpRest idx];

tmp = abs(fs.rest(:) - fDn(j));
[m idx] = min(tmp) ;
idDnRest = [idDnRest idx];

end 


% taking care of the noise
[na n] = size(tx.rest);
for i = 1:length(idUpRest);

for j=idUpRest(i):idDnRest(i);
for k = 1:n;
    val = abs(tx.rest(j,k));
    
  if abs(val) > Mmax  
    
    res = (abs(val) - Mmax);
    tx.rest(j,k) = tx.rest(j,k)*(res/val);
    
  elseif abs(val) <= Mmax &  abs(val) > gammaN;
      
    tx.rest(j,k) = 0;
  else 
     tx.rest(j,k) = tx.rest(j,k)/gammaN;
  end  

end
end 
end


% asembelyy 
dnFnl = zeros(nn.na, nn.n);
dnFnl(nn.ny+1:nn.na,:)= dn.long;
dnFnl(1:nn.ny,1:nn.n)= tx.rest;

dnFnl(isnan(dnFnl)) = 0;
denoised = synsq_cwt_iw(dnFnl, ff, opt);


figure 

  subplot 411
 tplot(txlong, dec.rest.t, fxlong);
 title({'Low-Frequency Segment'});
 xlabel({'Time (s)'});
 ylabel({'Instantaneous';'Frequency (Hz)'});
 ax = gca;
 ax.YAxisLocation = 'right';
 ax.TitleFontSizeMultiplier = 1.3;
 ax.LabelFontSizeMultiplier=1.3;
 ax.FontWeight='bold';
 ax.CLim=[-5 30];
 hold off
 clear title xlabel ylabel ax

 
  subplot 412
 tplot(txrest, dec.rest.t, fxrest);
 title({'High-Frequency Segment'});
 xlabel({'Time (s)'});
 ylabel({'Instantaneous';'Frequency (Hz)'});
 ax = gca;
 ax.YAxisLocation = 'right';
 ax.TitleFontSizeMultiplier = 1.3;
 ax.LabelFontSizeMultiplier=1.3;
 ax.FontWeight='bold';
 ax.CLim=[-50 300]; 
 hold off
 clear title xlabel ylabel ax
 
   subplot 413
 tplot(dn.long, dec.rest.t, fs.long);
 title({'Low-Frequency Segment (Soft-Thresholded)'});
 xlabel({'Time (s)'});
 ylabel({'Instantaneous';'Frequency (Hz)'});
 ax = gca;
 ax.YAxisLocation = 'right';
 ax.TitleFontSizeMultiplier = 1.3;
 ax.LabelFontSizeMultiplier=1.3;
 ax.FontWeight='bold';
 ax.CLim=[-5 30];
 hold off
 clear title xlabel ylabel ax

 
  subplot 414
 tplot(tx.rest, dec.rest.t, fs.rest);
 title({'High-Frequency Segment (Normalized)'});
 xlabel({'Time (s)'});
 ylabel({'Instantaneous';'Frequency (Hz)'});
 ax = gca;
 ax.YAxisLocation = 'right';
 ax.TitleFontSizeMultiplier = 1.3;
 ax.LabelFontSizeMultiplier=1.3;
 ax.FontWeight='bold';
 ax.CLim=[-50 300];
 hold off
 clear title xlabel ylabel ax
 
