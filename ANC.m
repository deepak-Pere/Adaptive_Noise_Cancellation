 % Real-Time Adaptive Noise Cancellation and Listening
clear; clc; close all;

%% Parameters
fs = 8000;             % Sampling frequency
frameLength = 1024;    % Samples per frame
filterOrder = 32;      % Order of LMS filter
mu = 0.015;            % Step size
3
mic = audioDeviceReader('SampleRate', fs, 'SamplesPerFrame', frameLength);
player = audioDeviceWriter('SampleRate', fs);
lms = dsp.LMSFilter('Length', filterOrder, 'StepSize', mu);

disp('Speak into your mic.');
duration = 10;  % seconds
numFrames = fs/frameLength * duration;

x_all = [];
noisy_all = [];
e_all = [];

%% Capture and process
for i = 1:numFrames
    x = mic();                        % clean speech from mic
    noise = 0.05 * randn(size(x));    % Gaussian noise
    noisy = x + noise;                % noisy signal
    ref = noise;                      % reference noise

    [~, e] = lms(ref, noisy);         % e = output (noise removed)

    % store all
    x_all = [x_all; x];
    noisy_all = [noisy_all; noisy];
    e_all = [e_all; e];

    % plot live
    plot([noisy e]);
    legend('Noisy input','Filtered output');
    title('Adaptive Noise Cancellation (Real-Time)');
    xlabel('Samples'); ylabel('Amplitude');
    drawnow limitrate;
end

release(mic);
release(player);
disp('Recording done.');

%% Playback options
disp(' ');
disp('Press 1 = Original Mic Sound (x)');
disp('Press 2 = Noisy Sound (x + noise)');
disp('Press 3 = Filtered Output (e)');
disp('Press 4 = Exit');

choice = 0;
while choice ~= 4
    choice = input('Enter choice: ');
    switch choice
        case 1
            disp('Playing Original Mic Input');
            sound(x_all, fs);
        case 2
            disp('Playing Noisy Signal');
            sound(noisy_all, fs);
        case 3
            disp('Playing Filtered (Cleaned) Output');
            sound(e_all, fs);
        case 4
            disp('Exiting...');
        otherwise
            disp('Invalid choice');
    end
end
