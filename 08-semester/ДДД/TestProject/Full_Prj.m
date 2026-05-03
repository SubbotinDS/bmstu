function NoiseCancellation_GUI

clc
close all

minW = 1200;
minH = 700;

data.noisy = [];
data.desired = [];
data.filtered = [];
data.Fs = 44100;
data.player = [];
data.cursor = [];

%% FIGURE

f = figure( ...
'Position',[200 200 minW minH], ...
'Name','Adaptive Filtering GUI', ...
'NumberTitle','off', ...
'Resize','on', ...
'SizeChangedFcn',@resizeGuard);

%% AXES

ax1 = axes('Parent',f,'Units','pixels','Position',[80 470 750 130]);
title(ax1,'Desired Signal')

ax2 = axes('Parent',f,'Units','pixels','Position',[80 270 750 130]);
title(ax2,'Input Signal')

ax3 = axes('Parent',f,'Units','pixels','Position',[80 70 750 130]);
title(ax3,'Error / Output')

%% BUTTONS

uicontrol(f,'Style','pushbutton','String','Load Signal',...
'Position',[40 620 150 40],'Callback',@loadSignal);

uicontrol(f,'Style','pushbutton','String','Run',...
'Position',[210 620 120 40],'Callback',@runAlgorithms);

uicontrol(f,'Style','pushbutton','String','Reset',...
'Position',[350 620 100 40],'Callback',@resetGUI);

uicontrol(f,'Style','pushbutton','String','Save Result',...
'Position',[470 620 150 40],'Callback',@saveResults);

%% PARAMETERS

uicontrol(f,'Style','text','String','Signal Type',...
'Position',[950 620 120 20]);

signalTypeMenu = uicontrol(f,'Style','popup',...
'String',{'White Noise','AR Process','From File'},...
'Position',[950 600 150 25]);

uicontrol(f,'Style','text','String','AR Order',...
'Position',[950 570 120 20]);

arOrderEdit = uicontrol(f,'Style','edit','String','4',...
'Position',[950 550 120 25]);

uicontrol(f,'Style','text','String','Samples',...
'Position',[950 520 120 20]);

samplesEdit = uicontrol(f,'Style','edit','String','1000',...
'Position',[950 500 120 25]);

uicontrol(f,'Style','text','String','Filter Length',...
'Position',[950 470 120 20]);

filterLenEdit = uicontrol(f,'Style','edit','String','32',...
'Position',[950 450 120 25]);

uicontrol(f,'Style','text','String','Mu (LMS)',...
'Position',[950 420 120 20]);

muEdit = uicontrol(f,'Style','edit','String','0.01',...
'Position',[950 400 120 25]);

uicontrol(f,'Style','text','String','Lambda (RLS)',...
'Position',[950 370 120 20]);

lambdaEdit = uicontrol(f,'Style','edit','String','0.99',...
'Position',[950 350 120 25]);

%% CHECKBOXES

lmsCheck = uicontrol(f,'Style','checkbox','String','LMS',...
'Position',[950 300 100 25],'Value',1);

rlsCheck = uicontrol(f,'Style','checkbox','String','RLS',...
'Position',[950 270 100 25]);

%% PLAY BUTTONS

uicontrol(f,'Style','pushbutton','String','Play',...
'Position',[850 500 80 40],'Callback',@playDesired);

uicontrol(f,'Style','pushbutton','String','Play',...
'Position',[850 300 80 40],'Callback',@playInput);

uicontrol(f,'Style','pushbutton','String','Play',...
'Position',[850 100 80 40],'Callback',@playOutput);

%% ---------------- FUNCTIONS ----------------

function resizeGuard(src,~)
pos = src.Position;
src.Position(3) = max(pos(3),minW);
src.Position(4) = max(pos(4),minH);
end

%% LOAD SIGNAL

function loadSignal(~,~)

[file,path] = uigetfile('*.wav');
if file==0, return, end

[x,Fs] = audioread(fullfile(path,file));
data.noisy = x(:,1);
data.desired = x(:,1);
data.Fs = Fs;

axes(ax2)
plot(data.noisy)
title('Loaded Signal')

end

%% GENERATE SIGNAL

function generateSignal()

type = signalTypeMenu.Value;
N = str2double(samplesEdit.String);
arOrder = str2double(arOrderEdit.String);

if isnan(N) || N<=0
    errordlg('Invalid number of samples'); return
end

switch type

case 1
x = randn(N,1);

case 2
a = randn(arOrder,1)*0.5;
x = filter(1,[1; -a],randn(N,1));

case 3
[file,path] = uigetfile('*.wav');
if file==0, return, end
[x,Fs] = audioread(fullfile(path,file));
x = x(:,1);
data.Fs = Fs;

end

data.noisy = x;
data.desired = x;

axes(ax2)
plot(x)
title('Input Signal')

axes(ax1)
plot(x)
title('Desired Signal')

end

%% RUN

function runAlgorithms(~,~)

generateSignal()

x = data.noisy;
d = data.desired;

order = str2double(filterLenEdit.String);
mu = str2double(muEdit.String);
lambda = str2double(lambdaEdit.String);

if lmsCheck.Value
    [~,e_lms,~] = runLMS(x,d,order,mu);
    axes(ax3)
    plot(e_lms,'b')
    title('LMS Error')
    hold on
end

if rlsCheck.Value
    [~,e_rls,~] = runRLS(x,d,order,lambda);
    plot(e_rls,'r')
    title('LMS (blue) vs RLS (red)')
end

hold off

data.filtered = e_lms;

end

%% LMS

function [y,e,w] = runLMS(x,d,order,mu)

N = length(x);
w = zeros(order,1);
y = zeros(N,1);
e = zeros(N,1);

for n = order:N
u = x(n:-1:n-order+1);
y(n) = w'*u;
e(n) = d(n)-y(n);
w = w + mu*u*e(n);
end

end

%% RLS

function [y,e,w] = runRLS(x,d,order,lambda)

N = length(x);
w = zeros(order,1);
P = eye(order)*1000;

y = zeros(N,1);
e = zeros(N,1);

for n = order:N
u = x(n:-1:n-order+1);
y(n) = w'*u;
e(n) = d(n)-y(n);
k = (P*u)/(lambda + u'*P*u);
w = w + k*e(n);
P = (P - k*u'*P)/lambda;
end

end

%% SAVE

function saveResults(~,~)

[file,path] = uiputfile('results.mat');
if file==0, return, end

results.filtered = data.filtered;
results.Fs = data.Fs;
results.time = datestr(now);

save(fullfile(path,file),'results')

disp('Saved!')

end

%% PLAYER

function playSignal(signal,Fs,ax)

if isempty(signal), return, end

axes(ax)
cursor = xline(ax,1,'r');

player = audioplayer(signal,Fs);
play(player)

set(player,'TimerFcn',@(~,~) updateCursor(player,cursor))

end

function updateCursor(player,cursor)
cursor.Value = player.CurrentSample;
drawnow limitrate
end

function playDesired(~,~)
playSignal(data.desired,data.Fs,ax1)
end

function playInput(~,~)
playSignal(data.noisy,data.Fs,ax2)
end

function playOutput(~,~)
playSignal(data.filtered,data.Fs,ax3)
end

%% RESET

function resetGUI(~,~)

data.noisy = [];
data.desired = [];
data.filtered = [];

cla(ax1), title(ax1,'Desired Signal')
cla(ax2), title(ax2,'Input Signal')
cla(ax3), title(ax3,'Output')

end

end