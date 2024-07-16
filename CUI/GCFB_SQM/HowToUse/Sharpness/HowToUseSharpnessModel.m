%% How to use sharpness model
close all
clear
clc

%% Initial Setup
addpath(genpath('../../Function')) % Pass through the path to the Function folder
[Setting] = LSQMSetting('Parashow','ON','Figshow','ON'); % Setting Model Parameters

%% Make band-pass noise
Fs0 = 44100;
T = 1000;
Fc = 1000;
[~, BandWidth] = Freq2CB(Fc);
StepSize = 1;
Seed = 1;
[St] = MakeNoise(Fs0,T,Fc,BandWidth,StepSize,Seed);

%% Calculation of loudness
SPL = 60;
[Nt,N,Npk,Excitation,GTout] = GCLoudnessModel(St,Fs0,SPL,Setting);

%% Calculation of sharpness
[St,S] = GCSharpnessModel(Npk,N,Fs0,Setting);

OverallSharpness = mean(S(0.2*Fs0+1:end-0.2*Fs0)); % Calculate the mean of a stationary interval
disp(['Sharpness: ' num2str(round(OverallSharpness*1000)/1000)])

%% Remove path
rmpath(genpath('../../Function'))