clear; clc; close all;
%% load sample data file from 3/10/21
fileName = 'SampleData3.mat';
load(fileName,'-mat');
thermocoup = SampleData.thermocoupleRespiration;
opsens = SampleData.opsensRespiration;
fs = SampleData.samplingRate;
%% plot figure showing raw signals
rawData = figure('Name','Raw Data','NumberTitle','off');
ax1 = subplot(2,1,1);
plot((1:length(thermocoup))/fs,thermocoup,'b')
title('Respiration from Thermocouple Temperature')
ylabel('Amp. Voltage (a.u.)')
xlabel('Time (s)')
set(gca,'box','off')
axis tight
ax1.TickLength = [0.03,0.03];
ax2 = subplot(2,1,2);
plot((1:length(opsens))/fs,opsens,'k')
title('Respiration from Opsense Pressure')
ylabel('Amp. Voltage (a.u.)')
xlabel('Time (s)')
set(gca,'box','off')
axis tight
ax2.TickLength = [0.03,0.03];
% link axes for scrolling
linkaxes([ax1,ax2],'x')
%% plot figure showing lowpass filtered signals
[z,p,k] = butter(4,10/(fs/2),'low');
[sos,g] = zp2sos(z,p,k);
filtThermocoup = detrend(filtfilt(sos,g,thermocoup - thermocoup(1)) + thermocoup(1),'constant');
filtOpsens = detrend(filtfilt(sos,g,opsens - opsens(1)) + opsens(1),'constant');
% plot
procData = figure('Name','Filtered Data','NumberTitle','off');
ax3 = subplot(2,1,1);
plot((1:length(filtThermocoup))/fs,filtThermocoup,'b')
title('Filtered Thermocouple Temperature (10 Hz LP)')
ylabel('Amp. Voltage (a.u.)')
xlabel('Time (s)')
set(gca,'box','off')
axis tight
ax3.TickLength = [0.03,0.03];
ax4 = subplot(2,1,2);
plot((1:length(filtOpsens))/fs,filtOpsens,'k')
title('Filtered Opsense Pressure (10 Hz LP)')
ylabel('Amp. Voltage (a.u.)')
xlabel('Time (s)')
set(gca,'box','off')
axis tight
ax4.TickLength = [0.03,0.03];
% link axes for scrolling
linkaxes([ax3,ax4],'x')
%% plot figure showing normalized power spectra
params.tapers = [1,1];
params.pad = 0;
params.Fs = fs;
params.fpass = [0,10];
params.trialave = 1;
params.err = [2,0.05];
[thermocoup_S,thermocoup_f,~] = mtspectrumc(filtThermocoup,params);
thermocoup_S = thermocoup_S/max(thermocoup_S);
[opsens_S,opsens_f,~] = mtspectrumc(filtOpsens,params);
opsens_S = opsens_S/max(opsens_S);
powerSpec = figure('Name','Power Spectra','NumberTitle','off');
L2 = semilogx(opsens_f,opsens_S,'k');
hold on
L1 = semilogx(thermocoup_f,thermocoup_S,'b');
title('Respiration powerspectra (0-10 Hz)')
ylabel('Normalized by peak power (a.u.)')
xlabel('Freq (Hz)')
legend([L1,L2],'Thermocouple','OpSens')
set(gca,'box','off')
axis tight

%% Spectrogram
params.tapers = [1,1];
params.pad = 0;
params.Fs = fs;
params.fpass = [0,10];
params.trialave = 1;
params.err = [2,0.05];
movingwin = [1,0.25];
[filtTherm_S,filtThermo_t,filtThermo_f,~] = mtspecgramc(filtThermocoup,movingwin,params);
[filtOpSens_S,filtOpSens_t,filtOpsens_f,~] = mtspecgramc(filtOpsens,movingwin,params);

spectrogram = figure('Name','Spectrogram','NumberTitle','off');
subplot(2,1,1)
imagesc(filtThermo_t,filtThermo_f,filtTherm_S')
colormap
ylabel('Frequency (Hz)')
xlabel('Time (s)')
title('Thermocouple Power Spectrum')
axis xy

subplot(2,1,2)
imagesc(filtOpSens_t,filtOpsens_f,filtOpSens_S')
colormap
ylabel('Frequency (Hz)')
xlabel('Time (s)')
title('OpSens Power Spectrum')
axis xy




%% 
% mean subtract to remove slow drift
filtThermocoup = filtThermocoup - mean(filtThermocoup);
 % [time band width, number of tapers]
tapers_r = [2,3];
movingwin_r = [0.5,0.1];
% Frame rate
params_r.Fs = fs;
params_r.fpass = [1,5];
params_r.tapers = tapers_r;
[Sr,tr,fr] = mtspecgramc(filtThermocoup,movingwin_r,params_r);
% Sr: spectrum; tr: time; fr: frequency
% largest elements along the frequency direction
[~,ridx] = max(Sr,[],2);
HR = fr(ridx);   % heart rate, in Hz

% mean subtract to remove slow drift
filtOpsens = filtOpsens - mean(filtOpsens);
 % [time band width, number of tapers]
tapers_r = [2,3];
movingwin_r = [0.5,0.1];
% Frame rate
params_r.Fs = fs;
params_r.fpass = [1,5];
params_r.tapers = tapers_r;
[Sr2,tr2,fr2] = mtspecgramc(filtOpsens,movingwin_r,params_r);
% Sr: spectrum; tr: time; fr: frequency
% largest elements along the frequency direction
[~,ridx] = max(Sr2,[],2);
HR_opsens = fr(ridx);   % heart rate, in Hz

figure('Name','Respiration','NumberTitle','off')
plot(tr,HR,tr2,HR_opsens)
title('Respiration Rate)')
ylabel('Frequency(Hz)')
xlabel('TIme (s)')
legend('Thermocouple','OpSens Pressure')

