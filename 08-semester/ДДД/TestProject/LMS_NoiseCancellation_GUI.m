function LMS_NoiseCancellation_GUI

clc
close all

minW = 1100;
minH = 650;

data.noisy = [];
data.desired = [];
data.filtered = [];
data.noise = [];
data.Fs = 44100;

data.player = [];
data.cursor = [];

%% FIGURE

f = figure( ...
'Position',[200 200 minW minH], ...
'Name','LMS Noise Cancellation', ...
'NumberTitle','off', ...
'Resize','on', ...
'SizeChangedFcn',@resizeGuard);

%% AXES

ax1 = axes('Parent',f,'Units','pixels','Position',[80 440 750 130]);
title(ax1,'Original Signal')

ax2 = axes('Parent',f,'Units','pixels','Position',[80 250 750 130]);
title(ax2,'Noisy Signal')

ax3 = axes('Parent',f,'Units','pixels','Position',[80 60 750 130]);
title(ax3,'Filtered Output')

%% BUTTONS TOP

uicontrol(f,'Style','pushbutton','String','Load Noisy Signal',...
'Position',[40 590 150 40],'Callback',@loadNoisy);

uicontrol(f,'Style','pushbutton','String','Load Desired Signal',...
'Position',[210 590 150 40],'Callback',@loadDesired);

uicontrol(f,'Style','pushbutton','String','Load Matlab Noise',...
'Position',[380 590 150 40],'Callback',@generateNoise);

uicontrol(f,'Style','pushbutton','String','Record Speech',...
'Position',[550 590 150 40],'Callback',@recordSpeechMix);

uicontrol(f,'Style','pushbutton','String','Run LMS',...
'Position',[720 590 120 40],'Callback',@runLMS);

uicontrol(f,'Style','pushbutton','String','Reset',...
'Position',[860 590 100 40],'Callback',@resetGUI);

%% PLAY BUTTONS

uicontrol(f,'Style','pushbutton','String','Play',...
'Position',[900 460 100 40],'Callback',@playOriginal);

uicontrol(f,'Style','pushbutton','String','Play',...
'Position',[900 270 100 40],'Callback',@playNoisy);

uicontrol(f,'Style','pushbutton','String','Play',...
'Position',[900 80 100 40],'Callback',@playFiltered);

%% RESIZE CONTROL

function resizeGuard(src,~)

pos = src.Position;

newW = max(pos(3),minW);
newH = max(pos(4),minH);

if newW ~= pos(3) || newH ~= pos(4)
    src.Position = [pos(1) pos(2) newW newH];
end

end

%% LOAD NOISY

function loadNoisy(~,~)

[file,path] = uigetfile('*.wav');

if file==0
return
end

[signal,Fs] = audioread(fullfile(path,file));

data.noisy = signal(:,1);
data.Fs = Fs;

axes(ax2)
plot(data.noisy,'b')
title('Noisy Signal')

end

%% LOAD DESIRED

function loadDesired(~,~)

[file,path] = uigetfile('*.wav');

if file==0
return
end

[signal,Fs] = audioread(fullfile(path,file));

data.desired = signal(:,1);
data.Fs = Fs;

axes(ax1)
plot(data.desired,'b')
title('Original Signal')

end

%% GENERATE NOISE

function generateNoise(~,~)

Fs = data.Fs;
duration = 5;

noise = randn(Fs*duration,1);
noise = noise/max(abs(noise));

data.noise = noise;
data.noisy = noise;

axes(ax2)
plot(noise,'b')
title('MATLAB White Noise')

end

%% RECORD SPEECH

function recordSpeechMix(~,~)

Fs = data.Fs;

if isempty(data.noise)
errordlg('Generate Matlab Noise first')
return
end

noise = data.noise;
N = length(noise);

recObj = audiorecorder(Fs,16,1);

disp('Recording... Speak now')

record(recObj)
pause(N/Fs)
stop(recObj)

speech = getaudiodata(recObj);

if length(speech)<N
speech=[speech;zeros(N-length(speech),1)];
elseif length(speech)>N
speech=speech(1:N);
end

data.desired = speech + noise;

axes(ax1)
plot(data.desired,'b')
title('Speech + Noise')

end

%% LMS FILTER

function runLMS(~,~)

if isempty(data.noisy) || isempty(data.desired)
errordlg('Need noisy and desired signals')
return
end

x = data.noisy;
d = data.desired;

N = min(length(x),length(d));

x = x(1:N);
d = d(1:N);

order = 32;
mu = 0.01;

w = zeros(order,1);
y = zeros(N,1);
e = zeros(N,1);

for n = order:N

buffer = x(n:-1:n-order+1);

y(n) = w' * buffer;

e(n) = d(n) - y(n);

w = w + mu * buffer * e(n);

end

data.filtered = e;

axes(ax3)
plot(data.filtered,'b')
title('Filtered Output')

end

%% STOP PLAYER

function stopPlayer

if ~isempty(data.player)

if strcmp(data.player.Running,'on')
stop(data.player)
end

end

end

%% PLAY WITH CURSOR

function playSignal(signal,Fs,ax)

stopPlayer

axes(ax)

if ~isempty(data.cursor)
if isgraphics(data.cursor)
delete(data.cursor)
end
end

data.cursor = xline(ax,1,'r','LineWidth',2);

player = audioplayer(signal,Fs);
data.player = player;

set(player,'TimerPeriod',0.03,'TimerFcn',@moveCursor);

play(player)

    function moveCursor(~,~)

    if isempty(data.cursor)
    return
    end

    sample = get(player,'CurrentSample');

    data.cursor.Value = sample;

    drawnow limitrate

    end

end

%% PLAY FUNCTIONS

function playOriginal(~,~)

if isempty(data.desired)
return
end

playSignal(data.desired,data.Fs,ax1)

end

function playNoisy(~,~)

if isempty(data.noisy)
return
end

playSignal(data.noisy,data.Fs,ax2)

end

function playFiltered(~,~)

if isempty(data.filtered)
return
end

playSignal(data.filtered,data.Fs,ax3)

end

%% RESET

function resetGUI(~,~)

stopPlayer

data.noisy = [];
data.desired = [];
data.filtered = [];
data.noise = [];
data.player = [];
data.cursor = [];

cla(ax1)
title(ax1,'Original Signal')

cla(ax2)
title(ax2,'Noisy Signal')

cla(ax3)
title(ax3,'Filtered Output')

disp('GUI Reset')

end

end