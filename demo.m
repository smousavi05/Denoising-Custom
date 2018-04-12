%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The following is a demo to run the Denoising/Detection code. This
%  is a sample code to demonstrate the process. Depending on your data, it
%  might need some modifications. 
%
%  Referece:
%   Mousavi S. M., C. A. Langston, and S. P. Horton (2016). Automatic
%   microseismic denoising and onset detection using the synchrosqueezed 
%   continuous wavelet transform, Geophysics, 81 (4), V341-V355, 
%   DOI:10.1785/0120150345.
%  
%  Mostafa Mousavi
%  Center for Earthquake Research and Information (CERI), 
%  University of Memphis, Memphis, TN.
%  smousavi@memphis.edu
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
close all 
tic

data.nm ='tes.ARK2.EHZ.2010298053500.240-360';   % waveform name
% Parameters for CWT and SS-CWT
opt.type = 'hshannon';         % Mother wavelet type; 'gauss' 'cmhat'   'morlet'   'hshannon'    'hhhat'    'bump' 
opt.padtype = 'symmetric';   % padded via symmetrization
opt.rpadded = 1;
opt.nv = 32;                 % Number of voices
opt.disp = 0;
opt.dtype = 1; 

% Read the original 
h = waitbar(0,'Loading...');
[data.t,data.x,data.hdr] = read_sac(data.nm);
data.t = linspace(0,(data.hdr.times.e - data.hdr.times.b),length(data.x));
data.dt = data.t(2)-data.t(1);
close(h)
clear h


%%  wavelet Transforming
h = waitbar(0.1,'Wavelet Transforming...');

[wl.Coef,wl.as,wl.dWx] = cwt_fw(data.x,opt.type,opt.nv,data.dt);

waitbar(0.8,h,'Wavelet Transforming...'); close(h)

%% Segmentation 
[dec nn ]= segment(wl.Coef, wl.dWx,wl.as,data);  

%% Synchronize Denoising 
[denoised ] = synchDenois(dec,opt,data,nn);

%% Post Denoising  
% forward wavelet transform
[wdn,w.as] = cwt_fw(denoised,opt.type,opt.nv,data.dt);

% Customized thresholding 
[ dnCuCoef ] = customThrSoft(wdn,opt,nn);
dnCuCoef(isnan(dnCuCoef)) = 0;
x = cwt_iw(dnCuCoef, opt.type, opt, opt.nv); 

%% Detection
[TT, ff, aa] = synsq_cwt_fw(data.t, x, opt.nv , opt);

% characteristic function DF
[na n] = size(TT); 
ee  = zeros(na,n);
for i = 1:na
v = real(TT(i,:));
a = (v).^2 ;
b = (hilbert(v)).^2;
ee(i,:) = sqrt(a+b);
end
row = sum(abs(ee));

rr = row';
L = 30;
z =zeros(L,1);
rowm =[z; rr; z];
er = [];

 for i = 1: length(rowm)-2*L;
     p = L+i;
     rowUp = rowm(p:p+L);
     rowUp = rowUp.^2;
     
     rowDn = rowm(p-L:p);
     rowDn = rowDn.^2;
     
     e= sum(rowUp)/sum(rowDn);
     
     er = [er;e];

 end
 
[pks,locs] = findpeaks(er);
out = []; T = 0.20*max(er);
for f=1:length(pks);
    if pks(f)> T
       out = [out locs(f)];
    end
end

up.T = zeros(size(out)); 
for i = 1:length(out);
    cut = er(out(i)-30:out(i));
    DV=movingslope(cut,2,1,data.dt);
    [m idx] = min(abs(DV));
    up.T(i) = out(i)-(30-i);
 
end

Xnoisy = data.x/max(data.x);
denoised_norm = x/max(x);


figure(6)
subplot(4,2,1);plot(data.t,Xnoisy);
grid on
grid minor
title('Original Signal','Rotation',0,'FontSize',14);xlabel({'Time (s)'}); 
xlim([min(data.t) max(data.t)]);
ax = gca;
ax.TitleFontSizeMultiplier = 1.1;
ax.LabelFontSizeMultiplier=1.1;
ax.FontWeight='bold';
ax.Position=[0.05 0.75 0.420 0.150];
hold off
clear title xlabel ylabel
  

subplot(4,2,2);
[Tx, fs, as] = synsq_cwt_fw(data.t, Xnoisy, opt.nv , opt); 
tplot(Tx,data.t, fs); 
title({'SS-CWT Spectrum'},'Rotation',0,'FontSize',13); 
xlim([min(data.t) max(data.t)]);
xlabel({'Time (s)'},'FontSize',11)
ylabel('Frequency (Hz)','FontSize',11)
ax = gca;
ax.YAxisLocation = 'right';
ax.TitleFontSizeMultiplier = 1.1;
ax.LabelFontSizeMultiplier=1.1;
ax.FontWeight='bold';
ax.Position=[0.510 0.75 0.420 0.150];
ax.CLim=[-0.00005 0.0005];
hold off
clear title xlabel ylabel


subplot(4,2,3);
plot(data.t,denoised_norm)
grid on 
grid minor
title('Denoised Signal','Rotation',0,'FontSize',14);xlabel({'Time (s)'}); 
xlim([min(data.t) max(data.t)]);
ax = gca;
ax.TitleFontSizeMultiplier = 1.1;
ax.LabelFontSizeMultiplier=1.1;
ax.FontWeight='bold';
ax.Position=[0.05 0.50 0.420 0.150];
hold off
clear title xlabel ylabel


subplot(4,2,4);
tplot(TT, data.t, ff); 
title({'SS-CWT Spectrum'},'Rotation',0,'FontSize',13);
xlabel({'Time (s)'},'FontSize',11)
ylabel('Frequency (Hz)','FontSize',11)
ax = gca;
ax.YAxisLocation = 'right';
ax.TitleFontSizeMultiplier = 1.1;
ax.LabelFontSizeMultiplier=1.1;
ax.FontWeight='bold';
ax.Position=[0.510 0.50 0.420 0.150];
ax.CLim=[-0.35 3.5];
hold off
clear title xlabel ylabel


subplot(4,2,5);
plot(data.t,Xnoisy)
grid on 
grid minor
title('Zoomed Window- Noisy','Rotation',0,'FontSize',14);xlabel({'Time (s)'}); 
xlim([min(data.t) max(data.t)]);
ax = gca;
ax.TitleFontSizeMultiplier = 1.1;
ax.LabelFontSizeMultiplier=1.1;
ax.FontWeight='bold';
ax.Position=[0.05 0.28 0.200 0.150];
hold off
clear title xlabel ylabel


subplot(4,2,6);
plot(data.t,denoised_norm)
grid on 
grid minor 
title('Zoomed Window-Denoised','Rotation',0,'FontSize',14);xlabel({'Time (s)'}); 
xlim([min(data.t) max(data.t)]);
ax = gca;
ax.TitleFontSizeMultiplier = 1.1;
ax.LabelFontSizeMultiplier=1.1;
ax.FontWeight='bold';
ax.Position=[0.27 0.28 0.200 0.150];
hold off
clear title xlabel ylabel


subplot(4,2,7);
tplot(Tx, data.t, fs); 
title({'Zoomed Spectrum'},'Rotation',0,'FontSize',13);
xlabel({'Time (s)'},'FontSize',11)
ax = gca;
ax.YAxisLocation = 'right';
ax.YTick =[] ;
ax.TitleFontSizeMultiplier = 1.1;
ax.LabelFontSizeMultiplier=1.1;
ax.FontWeight='bold';
ax.Position=[0.510 0.28 0.200 0.150];
ax.CLim=[-0.00005 0.0005];
hold off
clear title xlabel ylabel


subplot(4,2,8);
tplot(TT, data.t, ff); 
title({'Zoomed Spectrum'},'Rotation',0,'FontSize',13);
xlabel({'Time (s)'},'FontSize',11)
ylabel('Frequency (Hz)','FontSize',11)
ax = gca;
ax.YAxisLocation = 'right';
ax.TitleFontSizeMultiplier = 1.1;
ax.LabelFontSizeMultiplier=1.1;
ax.FontWeight='bold';
ax.Position=[0.73 0.28 0.200 0.150];
ax.CLim=[-0.35 3.5];
hold off
clear title xlabel ylabel

% 
% % %% Characteristic function R 
% figure (7)
% subplot 311
% plot(data.t,denoised_norm)
% grid on 
% grid minor
% title('Denoised Signal','Rotation',0,'FontSize',14);xlabel({'Time (s)'}); 
% xlim([0 120]);
% ax = gca;
% ax.TitleFontSizeMultiplier = 1.1;
% ax.LabelFontSizeMultiplier=1.1;
% ax.FontWeight='bold';
% ax.Position=[0.13 0.72 0.800 0.200]; 
% hold on
% yrange=get(gca,'ylim');
%  for i = 1:length(out);
%  h(i) = line([up.T(i)/100,up.T(i)/100],yrange);
%  set(h(i),'Color','magenta','LineWidth',1.0);
%  hold on
%  end
%  hold off
%  clear title xlabel ylabel
%   
% 
%  hold on 
%  subplot 312
%  plot(row); xlim([0 n]);
%  grid on 
%  grid minor
%  title('Envelop Characteristic Function','Rotation',0,'FontSize',14);xlabel({'Time (s)'}); 
%  yrange=get(gca,'ylim');
%  for i = 1:length(out);
%  h(i) = line([up.T(i)/100,up.T(i)/100],yrange);
%  set(h(i),'Color','magenta','LineWidth',1.0);
%  hold on
%  end
%  ax = gca;
%  ax.TitleFontSizeMultiplier = 1.1;
%  ax.LabelFontSizeMultiplier=1.1;
%  ax.FontWeight='bold';
%  ax.Position=[0.13 0.41 0.800 0.200];
%  hold off
%  clear title xlabel ylabel
%   
%  hold on 
%  subplot 313
%  plot(er);axis tight;
%  grid on 
%  grid minor 
%  title('Modeified Energy Ratio','Rotation',0,'FontSize',14);xlabel({'Time (s)'}); 
%  ax = gca;
%  ax.TitleFontSizeMultiplier = 1.1;
%  ax.LabelFontSizeMultiplier=1.1;
%  ax.FontWeight='bold';
%  ax.Position=[0.13 0.10 0.800 0.200];
%  hold on
%  plot(up.T/100,0,'o','MarkerE','k','MarkerF','w')
%  hold off
%  clear title xlabel ylabel
%  toc
%  {'time laps' toc}
% 
