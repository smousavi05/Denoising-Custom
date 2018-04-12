% [dec nn ]= segment(wlCoef, wldWx,wlas,data);
%
% this function find significant features in time-frequency picture of the 
% data and segment it basen on these features as was explained in page V345. 
% 
% [INPUTS]
% wlCoef: coefficients of the continuous wavelet transform of noisy data.
% wldWx: derivative of the CWT coefficients. 
% wlas: scales associated with the CWT coefficients. 
% data: a structuer containing waveform's info.
%
% [OUTPUTS]
% dec: a structure containing segmented CWT coefficients of main features.
% nn: a structure containing ifo about strong energy arrivals
% -------------------------------------------------------------------------
% By Mostafa Mousavi, smousavi@memphis.edu 
% Last modify: Oct 2, 2016
% -------------------------------------------------------------------------

function [dec nn ]= segment(wlCoef, wldWx,wlas,data);

%% separating long periods 
[na n] = size(wlCoef); col = 0;
for i = 1:n
    col = col + abs(wlCoef(:,i));
end

% The Otsu method for finding the optimum point of separation 
xotsu = otsu(na,col); % Appendix (B-1) 

% Finding peaks of smoothed histogram as a second criteria for Bimodality.
xsmooth = smooth(col,0.5,'loess');
[maxtab] = peakdet(xsmooth, 100);
[m1 idx1] = max(maxtab(:,2));

% Cheking the Bimodality using the Akaike's information criterion difference
AICd = akaikeC(col); % Appendix (B-2) & (B-3)
difpeack = abs(maxtab(idx1,1) - xotsu);

if (AICd > 0 & difpeack >= 0.02*na)
  
   disp('Bimodal'); 

   [na n] = size(wlCoef);
   ny = xotsu ;
   
   dec.long.wl = wlCoef(ny+1:na,1:n);
   dec.long.dWx = wldWx(ny+1:na,1:n);
   dec.long.as = wlas(ny+1:na);
   dec.long.t = data.t;
   
   dec.rest.wl = wlCoef(1:ny,1:n);
   dec.rest.dWx = wldWx(1:ny,1:n);
   dec.rest.as = wlas(1:ny);
   dec.rest.t = data.t;
  
else
    
   disp('Unimodal')
   [na n] = size(wlCoef);
   ny = xotsu + 0.4*na; 
   
   dec.long.wl = wlCoef(ny+1:na,1:n);
   dec.long.dWx = wldWx(ny+1:na,1:n);
   dec.long.as = wlas(ny+1:na);
   dec.long.t = data.t;
   
   dec.rest.wl = wlCoef(1:ny,1:n);
   dec.rest.dWx = wldWx(1:ny,1:n);
   dec.rest.as = wlas(1:ny);
   dec.rest.t = data.t;
  
end


%% Separating the noise periods 
% characteristic function R as was explained in page V346 eg(15) and (16)
[na n] = size(dec.rest.wl); 
ee  = zeros(na,n);
for i = 1:na
v= real( dec.rest.wl(i,:));
a = (v).^2 ;
b = (hilbert(v)).^2; 
ee(i,:) = sqrt(a+b);
end
row = sum(abs(ee));

% finding the local slope and arraivals
[g Dvec up nd] =  vertSec(row,data);
   
% segmenting the noise sample
dec.noise.wl = dec.rest.wl(:,1:up.all(1));
dec.noise.dWx = dec.rest.dWx(:,1:up.all(1));
dec.noise.as = wlas(1:ny);
dec.noise.t = data.t(1:up.all(1)); 

figure
hold on
 
%% original waveform
 subplot 421
 plot(data.x)
 xlim([0 length(data.t)]);
 title({'Waveform'});
 xlabel({'Time (s)'});

 ax = gca;
%  ax.XTick = [];
 ax.TitleFontSizeMultiplier = 1.1;
 ax.LabelFontSizeMultiplier=1.1;
 ax.FontWeight='bold';
 ax.Position=[0.23 0.77 0.700 0.200];
 grid on
 grid minor
 hold off
 clear title xlabel ylabel ax
   
  
%% stacked function C
 subplot 424
 a = 1:length(col);
 a = a';
 bar(a,col);
 xlim([0 length(col)])
 title({'Stacked';'Function C'});
 ylabel({'Magnitude'});
 
 hold on
 plot(xsmooth, 'Color','Green','LineWidth',2)
 hold off

 hold on
 yrange=get(gca,'ylim'); 
 h = line([ny,ny],yrange);
 set(h,'Color','magenta','LineWidth',3);
 hold off 

 ax = gca;
 ax.XTick = [];
 ax.TitleFontSizeMultiplier = 1.1;
 ax.LabelFontSizeMultiplier=1.1;
 ax.FontWeight='bold';
 ax.Position=[0.11 0.50 0.100 0.200];
 ax.View=[270 90];
 
 hold off
 clear title xlabel ylabel ax
  
 
 %% wavelet Scalogram 
 subplot 425
 tplot(wlCoef,data.t, wlas);
 title({'Wavelet Scalogram'});
 xlabel({'Time (s)'});
 ylabel({'Scale'});
 ax = gca;
 ax.YAxisLocation = 'right';
 ax.TitleFontSizeMultiplier = 1.1;
 ax.LabelFontSizeMultiplier=1.1;
 ax.FontWeight='bold';
 ax.Position=[0.23 0.50 0.700 0.200];
 hold off
 clear title xlabel ylabel ax
 
 
%% Step transition function (Accumulative energy density)
 subplot 427
 [na n] = size(wlCoef);
 hold on 
% plot(g); xlim([0 n]);
 plot(row); xlim([0 n]);
 ylabel({'Characteristic';'Function'});

 yrange=get(gca,'ylim');
 for i = 1:length(up.trig);
 h(i) = line([up.trig(i),up.trig(i)],yrange);
 set(h(i),'Color','k','LineWidth',1.5);
 hold on
 end

 ax = gca;
 ax.XTick = [];
 ax.TitleFontSizeMultiplier = 1.1;
 ax.LabelFontSizeMultiplier=1.1;
 ax.FontWeight='bold';
 ax.Position=[0.23 0.160 0.700 0.090];
 hold off
 clear title xlabel ylabel h ax
 
 
%% scalogram of high frequency segment  
 subplot 426
 tplot(dec.rest.wl, dec.rest.t,  dec.rest.as);
 title({'High-Frequency Segment'});
 ylabel({'Scale'});
 
 ax = gca;
 ax.XTick = [];
 ax.YAxisLocation = 'right';
 ax.TitleFontSizeMultiplier = 1.1;
 ax.LabelFontSizeMultiplier=1.1;
 ax.FontWeight='bold';
 ax.Position=[0.23 0.26 0.700 0.150];
 hold off
 clear title xlabel ylabel ax
 

 [na n] = size(wlCoef);
 nn.ny = ny;
 nn.na = na;
 nn.n = n;
 nn.nu = up.trig;
 nn.nd = nd.trig;


%  figure
%  tplot(dec.long.wl, dec.long.t,  dec.long.as);
%  title({'Low-Frequency Segment'});
%  ylabel({'Scale'});
%  ax = gca;
%  ax.XTick = [];
%  ax.YAxisLocation = 'right';
%  ax.TitleFontSizeMultiplier = 1.1;
%  ax.LabelFontSizeMultiplier=1.1;
%  ax.FontWeight='bold';
%  ax.Position=[0.23 0.26 0.700 0.150];
%  hold off
%  clear title xlabel ylabel ax
%  

