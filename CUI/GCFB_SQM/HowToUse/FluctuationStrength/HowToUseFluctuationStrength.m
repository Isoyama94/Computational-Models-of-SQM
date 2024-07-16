%% How to use fluctuation-strength model
close all
clear
clc

%% Initial Setup
addpath(genpath('../../Function')) % Pass through the path to the Function folder
[Setting] = LSQMSetting('Parashow','ON','Figshow','ON'); % Setting Model Parameters

%% Make AM sound
Fs0 = 44100;
T = 6000;
ModulationIndex = 0.98;
Fc = 1000;
Fmod = 4;
[St] = MakeAMSound(Fs0,T,Fc,Fmod,ModulationIndex,'OFF');

%% Calculation of loudness
SPL = 60;
[Nt,N,Npk,Excitation,GTout] = GCLoudnessModel(St,Fs0,SPL,Setting);

%% Calculation of fluctuation-strength
[Rt,R,Rpk,dLr,ik] = GCFluctuationStrengthModel(Npk,Fs0,Setting);

OverallFluctuationStrength = mean(R(200+1:end-200)); % Calculate the mean of a stationary interval
disp(['Fluctuation strength: ' num2str(round(OverallFluctuationStrength*1000)/1000) ' [Vacil]'])

%% Remove path
rmpath(genpath('../../Function'))