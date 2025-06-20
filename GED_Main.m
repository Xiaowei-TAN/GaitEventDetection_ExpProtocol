% Procedures:
% 1. Configure and enable the Bertec TCP function;
% 2. Type the individual comfortable speed values in 'comSped';
% 3. Change the experiment code 'expCode', and run the script.
%
% Check Items:
% 1. Check the variable values of 'expCode' and 'comSped'.
%
% Note:
% 1. Uphill running trail is separated in three sessions as 4.1, 4.2, 4.3
% for the expCode variable, since it's hard to compelte the trail in once
%
% The program has been tested on Matlab R2022b, Bertec Treadmill Control 
% Panel 1.8.8.1.
%
% This script is used to implement Gait Event Detection (GED) experimental
% protocol, which involves multiple trials under various conditions. See
% details in the protocol or the manuscript
%

clear
clc


%% -----------------------------Pre-define-----------------------------
% LC1, LC2, LC3, LC4.1, LC4.2, LC4.3, LC5-LC13
% Please note: LC1-LC3 = T1-T3; LC4.1-LC4.3 = T4-T6; LC5-LC13 = T7-T15.
% T1-T15 have been described in the paper: Robust Real-Time Gait Event 
% Detection Across Diverse Activities Using a Single IMU.
expCode = 'LC13';

%% Default
comSped = [ 1.0, ... % Level Walking [m/s]
            2.0, ... % Level Running
            1.0, ... % Uphill Walking
            1.6, ... % Uphill Running
           -1.0, ... % Downhill Walking [negative]
           -1.6];    % Downhill Running [negative]




%% -----------------------------Call the main function--------------------------------
mainFnc(expCode, comSped);


%% -----------------------------Main function definition--------------------------------
function mainFnc(expCode, comSped)

% -------------------Connect to Bertec Treadmill-------------------
try
    Bertec = tm_connect();
    disp('[MSG]: Bertec treadmill is connected');
catch
    disp('[ERROR]: Failed to connect Bertec');
    return;
end

% -------------------Set CleanUp Function-------------------
cleanupObj = onCleanup(@()cleanUp(Bertec));


% -------------------Set Belt Paras-------------------
BSlope_1 = 0; % 1st stage
BSlope_2 = 0; % 2nd stage
BSlope_3 = 0; % 3rd stage
BSpeed_1 = 0;
BSpeed_2 = 0;
BSpeed_3 = 0;

eachStageDuration = 0; % exclude the transition period
switch expCode
    case 'LC1' % level walking
        BSlope_1 = 0;
        BSlope_2 = 0;
        BSlope_3 = 0;
        BSpeed_1 = 0.8*comSped(1);
        BSpeed_2 = 1.0*comSped(1);
        BSpeed_3 = 1.2*comSped(1);
        eachStageDuration = 120; % [s]
    case 'LC2' % level running
        BSlope_1 = 0;
        BSlope_2 = 0;
        BSlope_3 = 0;
        BSpeed_1 = 0.8*comSped(2);
        BSpeed_2 = 1.0*comSped(2);
        BSpeed_3 = 1.2*comSped(2);
        eachStageDuration = 60; % [s]
    case 'LC3' % uphill walking
        BSlope_1 = 10;
        BSlope_2 = 10;
        BSlope_3 = 10;
        BSpeed_1 = 0.8*comSped(3);
        BSpeed_2 = 1.0*comSped(3);
        BSpeed_3 = 1.2*comSped(3);
        eachStageDuration = 120; % [s]
    case 'LC4.1' % uphill running 80%CS
        BSlope_1 = 10;
        BSlope_2 = 10;
        BSlope_3 = 10;
        BSpeed_1 = 0.8*comSped(4);
        BSpeed_2 = BSpeed_1; % must be same as the speed in the first stage
        BSpeed_3 = BSpeed_1;
        eachStageDuration = 60; % [s] % total time in this trial
    case 'LC4.2' % uphill running 100%CS
        BSlope_1 = 10;
        BSlope_2 = 10;
        BSlope_3 = 10;
        BSpeed_1 = 1.0*comSped(4);
        BSpeed_2 = BSpeed_1;
        BSpeed_3 = BSpeed_1;
        eachStageDuration = 60; % [s]
    case 'LC4.3' % uphill running 120%CS
        BSlope_1 = 10;
        BSlope_2 = 10;
        BSlope_3 = 10;
        BSpeed_1 = 1.2*comSped(4);
        BSpeed_2 = BSpeed_1;
        BSpeed_3 = BSpeed_1;
        eachStageDuration = 60; % [s]
    case 'LC5' % downhill walking
        BSlope_1 = 10;
        BSlope_2 = 10;
        BSlope_3 = 10;
        BSpeed_1 = 0.8*comSped(5);
        BSpeed_2 = 1.0*comSped(5);
        BSpeed_3 = 1.2*comSped(5);
        eachStageDuration = 120; % [s]
    case 'LC6' % downhill running
        BSlope_1 = 10;
        BSlope_2 = 10;
        BSlope_3 = 10;
        BSpeed_1 = 0.8*comSped(6);
        BSpeed_2 = 1.0*comSped(6);
        BSpeed_3 = 1.2*comSped(6);
        eachStageDuration = 60; % [s]
    case 'LC7' % uphill walking, running, and walking
        BSlope_1 = 10;
        BSlope_2 = 10;
        BSlope_3 = 10;
        BSpeed_1 = comSped(3);
        BSpeed_2 = comSped(4);
        BSpeed_3 = comSped(3);
        eachStageDuration = 30; % [s]
    case 'LC8' % downhill walking, running, and walking
        BSlope_1 = 10;
        BSlope_2 = 10;
        BSlope_3 = 10;
        BSpeed_1 = comSped(5);
        BSpeed_2 = comSped(6);
        BSpeed_3 = comSped(5);
        eachStageDuration = 30; % [s]
    case 'LC9' % level walking, running, and walking
        BSlope_1 = 0;
        BSlope_2 = 0;
        BSlope_3 = 0;
        BSpeed_1 = comSped(1);
        BSpeed_2 = comSped(2);
        BSpeed_3 = comSped(1);
        eachStageDuration = 30; % [s]
    case 'LC10' % level walking, uphill walking, level walking
        BSlope_1 = 0;
        BSlope_2 = 10;
        BSlope_3 = 0;
        BSpeed_1 = min(comSped(1), comSped(3));
        BSpeed_2 = min(comSped(1), comSped(3));
        BSpeed_3 = min(comSped(1), comSped(3));
        eachStageDuration = 30; % [s]
    case 'LC11' % level walking, downhill walking, level walking
        BSlope_1 = 0;
        BSlope_2 = 10;
        BSlope_3 = 0;
        BSpeed_1 = max(-comSped(1), comSped(5));
        BSpeed_2 = max(-comSped(1), comSped(5));
        BSpeed_3 = max(-comSped(1), comSped(5));
        eachStageDuration = 30; % [s]
    case 'LC12' % level running, uphill running, level running
        BSlope_1 = 0;
        BSlope_2 = 10;
        BSlope_3 = 0;
        BSpeed_1 = min(comSped(2), comSped(4));
        BSpeed_2 = min(comSped(2), comSped(4));
        BSpeed_3 = min(comSped(2), comSped(4));
        eachStageDuration = 10; % [s]
    case 'LC13' % level running, downhill running, level running
        BSlope_1 = 0;
        BSlope_2 = 10;
        BSlope_3 = 0;
        BSpeed_1 = max(-comSped(2), comSped(6));
        BSpeed_2 = max(-comSped(2), comSped(6));
        BSpeed_3 = max(-comSped(2), comSped(6));
        eachStageDuration = 10; % [s]
    otherwise
        disp('[ERROR]: Wrong value of ''expCode''');
        return;
end


% -------------------Check the current treadmill incline-------------------
% flush old data in input buffer (Bertec continuously postbacks data)
flushinput(Bertec);
[~, slo] = tm_get(Bertec); % [deg]

if slo < 0 || abs(slo-BSlope_1) > 0.1
    disp('[ERROR]: Current incline value is incorrect');
    return;
end


% -------------------Alter the belt is going to run backwards-------------------
if BSpeed_1 < 0
    waitfor(msgbox('The belt is set to run backwards. please confirm your direction.', 'Warning'));
end


% -------------------Wait for Subject Preparation-------------------
for i = 1:3
    sound( sin(2*pi*25*(1:200)/100) ); % short beep sound
    pause(1); % 1s
end
sound( sin(2*pi*25*(1:5000)/100) ); % long beep sound
pause(0.5); % 0.5s


% -------------------run the treadmill-------------------
index = 1;
startTime  = tic();
BSpeedBack = 0;
BSlopeBack = 0;
printCount = 0;

while true
    pause(100/1000); % 100ms
    
    % -------------------Set parameters-------------------
    if toc(startTime) > eachStageDuration
        index = index + 1;
    end
    
    switch index
        case 1 % stage1
            BSpeed = BSpeed_1;
            BSlope = BSlope_1;
        case 2 % stage2
            BSpeed = BSpeed_2;
            BSlope = BSlope_2;
        case 3 % stage3
            BSpeed = BSpeed_3;
            BSlope = BSlope_3;
        case 4
            break; % exit the outer while loop
    end
    
    % -------------------Condition transition-------------------
    if BSpeedBack ~= BSpeed || BSlopeBack ~= BSlope
        tm_set(Bertec, BSpeed, 0.50, BSlope); % 0.5m/s2
        
        % flush old data in input buffer
        flushinput(Bertec);
        while true % wait the transition completed
            pause(1/1000); % 1ms
            [spe, slo] = tm_get(Bertec); % ~100ms
            
            % print at the same frequency with 'tm_get'
            disp(['waiting the transition completed: ' ...
                num2str(spe(1), '%.2f') '/ ' num2str(BSpeed, '%.2f') ' (m/s), '...
                num2str(slo, '%.2f') '/ ' num2str(BSlope, '%.2f') ' (deg)'])

            if abs(spe(1) - BSpeed) < 0.1 && abs(slo - BSlope) < 0.1
                % althought exit the loop, treadmill will continue to reach
                % the destination
                startTime = tic();
                break; % exit the inner while loop
            end
        end
        BSpeedBack = BSpeed;
        BSlopeBack = BSlope;
    end

    % -------------------Print Info-------------------
    printCount = printCount + 1;
    if printCount == 9 % print once each 10s
        disp(['stage no.: ' num2str(index) ', stage time: ' ...
            num2str( floor(toc(startTime)) ) 's/ ' num2str(eachStageDuration) 's']);
        printCount = 0;
        
        % sound alert during the last 5s at each stage 
        if eachStageDuration - toc(startTime) < 5 % [s]
            sound( sin(2*pi*25*(1:200)/100) ); % short beep
        end
    end
end

end



%% -----------------------------Cleanup Function--------------------------------
function cleanUp(Bertec)

%-------------------zero and close Bertec-------------------
try
    % zero speed, keep the slope angle, and disconnect
    flushinput(Bertec);
    [~, slo] = tm_get(Bertec);
    tm_set(Bertec, 0, 0.25, abs(slo));

    pause(100/1000); % 100ms
    tm_disconnect(Bertec);
    disp("[MSG]: Bertec Treadmill Disonnected");
catch
    disp("[ERROR]: Error happened in cleanup function")
end

disp("[MSG]: cleanUp function completed");

end