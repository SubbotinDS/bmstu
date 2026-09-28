% Лаба: Расчет характеристик радиолокационных сигналов
% Задача 1.1, Вариант 2
% Тип сигнала: Пачка прямоугольных радиоимпульсов (ППРИ)
clear; clc; close all;

% 1. Параметры сигнала
tau_n = 4e-3;      % Длительность одного импульса, с
Um = 2.5;          % Амплитуда, В
fn = 3e3;          % Несущая частота, Гц
M = 3;             % Количество импульсов в пачке
Q = 2;             % Скважность

Tn = Q * tau_n;    % Период повторения, с (8e-3)
tau_p = M * Tn;    % Общая длительность пачки, с (24e-3)

% 2. Расчет ширины спектра
% Ширина спектра для ППРИ определяется длительностью одного импульса
Delta_f = 1 / tau_n;
fprintf('Ширина спектра сигнала (ППРИ): Delta_f = %.2f Гц\n', Delta_f);
fprintf('Период повторения Tn = %.2f мс\n', Tn*1000);
fprintf('Общая длительность пачки tau_p = %.2f мс\n', tau_p*1000);

% 3. Временное представление сигнала
fs = 200e3;        % Частота дискретизации
t = 0:1/fs:tau_p + Tn; % Временной вектор

U = zeros(size(t));
for m = 0:M-1
    start_t = m * Tn;                   % Время начала m-го импульса
    end_t = start_t + tau_n;            % Время конца m-го импульса
    idx = t >= start_t & t < end_t;
    U(idx) = Um * cos(2*pi*fn*(t(idx) - start_t));
end

figure;
plot(t*1000, U, 'b', 'LineWidth', 1.5);
xlabel('Время t, мс');
ylabel('Напряжение U(t), В');
title('Временное представление ППРИ');
grid on;
xlim([0, (tau_p + Tn)*1000]);
ylim([-Um-(Um/5), Um+(Um/5)]);

% 4. Построение тела неопределенности (Функция неопределенности)
% Используем аналитическую формулу для пачки когерентных импульсов
tau_vec = linspace(-tau_p, tau_p, 2000);
F_vec = linspace(-2*Delta_f, 2*Delta_f, 2000);
[Tau, F] = meshgrid(tau_vec, F_vec);

Rho = zeros(size(Tau));

for p = -(M-1):(M-1)
    tau_shifted = Tau - p*Tn;
    rho1 = zeros(size(tau_shifted));
    valid_idx = abs(tau_shifted) <= tau_n;
    rho1(valid_idx) = (1 - abs(tau_shifted(valid_idx))/tau_n) .* sinc(F(valid_idx) .* (tau_n - abs(tau_shifted(valid_idx))));
    dirichlet_factor = sin(pi * F * Tn * (M - abs(p))) ./ (M * sin(pi * F * Tn + eps));
    Rho = Rho + dirichlet_factor .* rho1 .* exp(1j * 2 * pi * F * p * Tn);
end
Rho = abs(Rho);

figure;
mesh(Tau*1000, F, Rho);
xlabel('Рассогласование по времени \tau, мс');
ylabel('Рассогласование по частоте F, Гц');
zlabel('|\rho(\tau, F)|');
title('Тело неопределенности ППРИ');
colormap jet;
colorbar;

% 5. Сечения тела неопределенности
% Сечение во временной плоскости (АКФ сигнала, F = 0)
[~, idx_F0] = min(abs(F_vec));
rho_tau = Rho(idx_F0, :);

figure('Name', 'Сечение АКФ');
plot(tau_vec*1000, rho_tau, 'b', 'LineWidth', 2);
xlabel('Задержка \tau, мс');
ylabel('|\rho(\tau, 0)|');
title('Сечение функции неопределенности во временной области (АКФ)');
grid on;

% Горизонтальная линия на уровне 0.5
yline(0.5, 'r--', 'LineWidth', 1.5); 

% Вертикальные линии на уровне 0.5 (границы по половинной мощности)
xline(tau_n/2*1000, 'g--', 'LineWidth', 1.5);
xline(-tau_n/2*1000, 'g--', 'LineWidth', 1.5);

% Сечение в частотной области (tau = 0)
[~, idx_tau0] = min(abs(tau_vec));
rho_F = Rho(:, idx_tau0);

figure('Name', 'Сечение в частотной области');
plot(F_vec, rho_F, 'b', 'LineWidth', 2);
xlabel('Частота Доплера F, Гц');
ylabel('|\rho(0, F)|');
title('Сечение функции неопределенности в частотной области');
grid on;
xline(0, 'r--');
% Ширина главного лепестка доплеровского сечения определяется длительностью всей пачки tau_p
xline(1/(2*tau_p), 'g--', 'LineWidth', 1.5);
xline(-1/(2*tau_p), 'g--', 'LineWidth', 1.5);

% 6. Вывод результатов
fprintf('\n--- Анализ сечений ---\n');
fprintf('1. По сечению АКФ (временная область):\n');
fprintf('   Ширина главного лепестка АКФ определяется длительностью импульса.\n');
fprintf('   Основание лепестка: от -%.2f мс до +%.2f мс.\n', tau_n*1000, tau_n*1000);
fprintf('   Пики повторяются через период Tn = %.2f мс.\n', Tn*1000);

fprintf('2. По сечению в частотной области:\n');
fprintf('   Ширина главного лепестка спектра: Delta_f = %.2f Гц.\n', Delta_f);
fprintf('   Данное значение совпадает с расчетным (1/tau_n).\n');
fprintf('   Между пиками расстояние 1/Tn = %.2f Гц.\n', 1/Tn);