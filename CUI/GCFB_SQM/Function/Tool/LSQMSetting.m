% Loudness and SQM Setting
%           [Setting] = LSQMSetting(varargin)
%
% Setting of All model
%      Figshow: 'ON' or 'OFF'           (Default: 'OFF')
%   ERBNnumber:                         (Default: 2.6:0.1:38.9) 
%     Parallel: 'ON' or 'OFF'           (Default: 'OFF') % To be implemented in the future
%
% Setting of Loudness
%       OpData: 'Ap', 'INTERNOISE'      (Default:'Ap')
%        Field: 'Free' or 'Diffuse'     (Default: 'Free')
%      SPLmode: 'Signal' or 'ALLRMS'    (Default: 'ALLRMS')
%  TimeVarying: 'ON' or 'OFF'           (Default: 'OFF') To be implemented in the future
%
% Setting of Sharpness
%      SWaight: 'DIN' or 'Zwicker'      (Default: 'Zwicker') To be implemented in the future
%
% Parameter
%      Parashow: 'ON' or 'OFF'          (Default: 'OFF')
%
% Author: Takuto ISOYAMA
% Created: 30 Jun. 2023
% Copyright: (c) 2019-2024 Unoki-Lab. JAIST
%
function [Setting] = LSQMSetting(varargin)
% ALL
[Para] = GetParameter(varargin,'Figshow','OFF');
Setting.Figshow = Para; % 'ON' or 'OFF'
[Para] = GetParameter(varargin,'ERBNnumber',2.6:0.1:38.9);
Setting.ERBNnumber = Para; % Cam
[Para] = GetParameter(varargin,'Parallel','OFF');
Setting.Parallel = Para; % Cam

% Loudness
[Para] = GetParameter(varargin,'Op','Ap');
Setting.Op = Para; % No Leaky int TVL model
[Para] = GetParameter(varargin,'Field','Free');
Setting.Field = Para; % "Free" or "Diffuse"
[Para] = GetParameter(varargin,'SPLmode','ALLRMS');
Setting.SPLmode = Para; % "Signal" or "ALLRMS"
[Para] = GetParameter(varargin,'TimeVarying','OFF'); % To be implemented in the future
Setting.TimeVarying = Para; % "ON" or "OFF"

% Sharpness % To be implemented in the future
% [Para] = GetParameter(varargin,'SWaight','Zwicker');
% Setting.SWaight = Para; % "DIN": DIN 45692 or "Zwicker"

[Para] = GetParameter(varargin,'Parashow','OFF');
if strcmp('ON',Para) == 1
    disp('ALL')
    disp(['Figshow: ' Setting.Figshow])
    disp(['ERBNnumber: ' num2str(Setting.ERBNnumber(1)) ' to ' num2str(Setting.ERBNnumber(end))])
   disp(['Parallel: ' Setting.Parallel])

    disp('Loudness')
    disp(['Op: ' Setting.Op])
    disp(['Field: ' Setting.Field])
    disp(['SPLmode: ' Setting.SPLmode])
%     disp(['TimeVarying: ' Setting.TimeVarying])

%     disp('Sharpness')
%     disp(['SWaight: ' Setting.SWaight])
end
end