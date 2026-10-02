%% Лабораторная работа: определение IP3 по двухтональному тесту
clear; clc; close all;

% --- Данные из таблицы 3 ---
Pin  = [3; 5; 8; 10];
Pout = [-23; -21; -18; -16];
IM3  = [-73; -71; -62; -55];

IM3(1) = -77;   % исправление опечатки
IM3(4) = -56;

% --- 1. Линия усиленного сигнала: наклон 1:1 ---
G = mean(Pout - Pin);
fprintf('Средний коэффициент передачи G = %.2f dB\n', G);

Pin_line = linspace(min(Pin)-5, 40, 500)';
Pout_ideal = Pin_line + G;

% --- 2. Линия IM3: наклон 3:1 ---
b3 = mean(IM3 - 3*Pin);
IM3_line = 3*Pin_line + b3;
fprintf('IM3 = 3*Pin + (%.2f) dBm\n', b3);

% --- 3. Точка IP3 ---
Pin_IP3 = (G - b3)/2;
OIP3    = Pin_IP3 + G;
fprintf('IIP3 = %.2f dBm\n', Pin_IP3);
fprintf('OIP3 = %.2f dBm\n', OIP3);

% --- График ---
figure('Color','w');
ax = axes;
hold(ax, 'on');

plot(Pin, Pout, 'o', 'MarkerSize', 8, ...
     'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', ...
     'LineStyle', 'none', 'DisplayName', 'P_{out} эксперимент');

plot(Pin, IM3, 'o', 'MarkerSize', 8, ...
     'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', ...
     'LineStyle', 'none', 'DisplayName', 'IM3 эксперимент');

plot(Pin_line, Pout_ideal, '--b', 'LineWidth', 2, ...
     'DisplayName', 'P_{out} идеал., наклон 1:1');

plot(Pin_line, IM3_line, '--r', 'LineWidth', 2, ...
     'DisplayName', 'IM3, наклон 3:1');

plot(Pin_IP3, OIP3, 'o', 'MarkerSize', 12, ...
     'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y', ...
     'LineStyle', 'none', 'DisplayName', 'IP3');

% --- Диапазоны осей (задаём заранее, чтобы всё влезло) ---
xlim([min(Pin)-3, Pin_IP3+4]);
ylim([min(IM3)-6, OIP3+10]);

% --- Подпись IP3 в свободном левом верхнем углу ---
xL = xlim;  yL = ylim;
txtX = xL(1) + 0.03*(xL(2)-xL(1));   % чуть правее левой границы
txtY = yL(2) - 0.05*(yL(2)-yL(1));   % чуть ниже верхней границы

text(txtX, txtY, ...
     sprintf('IP3:\nIIP3 = %.1f dBm\nOIP3 = %.1f dBm', Pin_IP3, OIP3), ...
     'FontSize', 10, ...
     'HorizontalAlignment', 'left', ...
     'VerticalAlignment', 'top', ...
     'BackgroundColor', 'w', ...
     'EdgeColor', [0.5 0.5 0.5], ...
     'Margin', 5);

grid on;
xlabel('P_{in} (мощность тона на входе), dBm');
ylabel('P_{out} (мощность составляющей на выходе), dBm');
title('Определение точки IP3 по двухтональному тесту');
legend('Location','southeast');