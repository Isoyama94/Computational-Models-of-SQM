% This function is Loudness Model with Gammatone filterbank
%
%   [Nt,N,Npk,Excitation,GTout] = GCLoudnessModel(St,Fs0,SPL,Setting)
%
% Input:  St        : Input signal
%         Fs0       : Sampling frequency
%         SPL       : Sound pressure level [dB]
%         Setting   : Setting.Op = 'Ap'
% Output: Nt        : Time [sec]
%         N         : Loundess [sone]
%         Npk       : Specific loudness [sone/ERB]
%         Excitation: Excitaiton pattern
%         GCout     : Output of gammachirp filterbank
%
% Author:  Takuto Isoyama
% Created: 2 Oct. 2019
% Modified 10 Apr. 2024: The low-pass filter and the squaring process were swapped in the part that calculates the excitation.
%
% Reference [1] T. Isoyama, and S. Kidani, M. Unoki, ``Computational models 
%               of auditory sensation important for sound quality on basis of 
%               either gammatone or gammachirp auditory filterbank,''
%               Applied Acoustics, Vol. 218, 2024. 
%               DOI: https://doi.org/10.1016/j.apacoust.2024.109914
% Copyright: (c) 2019-2024 Unoki-Lab. JAIST
%
function [Nt,N,Npk,Excitation,GCout] = GCLoudnessModel(St,Fs0,SPL,Setting)
%% Initial setup
[m,n] = size(St);
St = reshape(St,[1,m*n]);
T = length(St)/Fs0*1000; % ms
Nt = 0:1/Fs0:(T/1000)-1/Fs0;

[QL,E0,TQ_power,G_power,alph,A_data] = LoudnessParameters(Setting);

%% Sound pressure level
out = GCAdaptLevel(St,SPL,Setting);

%% Outer and middle ear correction
[yt] = OuterMiddleEarFilter(out,Fs0,Setting);

%% Auditory filtering
[GCout, Frs, ~, ~, ~, ~] = GCFB(Fs0,yt',Setting.ERBNnumber,4,1.019,[],[-4 0.0],'FF','real');

%% Calcuration of excitation
[Excitation,~] = CalculationOfExcitation(GCout,Fs0,E0,Setting);

%% Calculation of specific loudness
[Npk] = CalculationOfInstantaneousSpecificLoudness(Excitation,Fs0,QL,TQ_power,G_power,A_data,alph,Setting);

%% Calculation of loundess
N = sum(Npk,1)*0.1;
end