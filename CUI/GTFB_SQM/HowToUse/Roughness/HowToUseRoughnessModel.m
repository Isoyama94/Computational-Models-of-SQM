%% How to use roughness model
close all
clear
clc

%% Initial Setup
addpath(genpath('../../Function')) % Pass through the path to the Function folder
[Setting] = LSQMSetting('Parashow','ON','Figshow','ON'); % Setting Model Parameters

%% Make AM sound
Fs0 = 44100;
T = 1000;
ModulationIndex = 0.98;
Fc = 1000;
Fmod = 20;
[St] = MakeAMSound(Fs0,T,Fc,Fmod,ModulationIndex,'OFF');

%% Calculation of loudness
SPL = 60;
[Nt,N,Npk,Excitation,GTout] = GTLoudnessModel(St,Fs0,SPL,Setting);

%% Calculation of roughness
[Rt,R,Rpk,dLr,ik] = GTRoughnessModel(Npk,Fs0,Setting);

OverallRoughness = mean(R(0.2*1000+1:end-0.2*1000)); % Calculate the mean of a stationary interval
disp(['Roughness: ' num2str(round(OverallRoughness*1000)/1000)])