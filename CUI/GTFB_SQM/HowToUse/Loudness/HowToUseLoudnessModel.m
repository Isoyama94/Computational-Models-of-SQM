%% How to use loudness model
close all
clear
clc

%% Initial Setup
addpath(genpath('../../Function')) % Pass through the path to the Function folder
[Setting] = LSQMSetting('Parashow','ON','Figshow','ON','Parallel','ON'); % Setting Model Parameters

%% Make signal
Fs0 = 44100; % Hz
SPL = 40; % dB
Fc = 1000; % Hz
T = 1000; % ms
t = 0:1/Fs0:T/1000-1/Fs0;
St = sin(2*pi*Fc*t);

%% Calculation of loudness
[Nt,N,Npk,Excitation,GTout] = GTLoudnessModel(St,Fs0,SPL,Setting); % 

OverallLoudness = mean(N(0.2*Fs0+1:end-0.2*Fs0)); % Calculate the mean of a stationary interval

disp(['Loudness: ' num2str(round(OverallLoudness*1000)/1000)])