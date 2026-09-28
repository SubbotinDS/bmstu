% ============================================================
% Лаба: Расчет характеристик радиолокационных сигналов
% Задача 2.1, Вариант 2
% Тип сигнала: ФКМ РИ (код Баркера 7)
% ============================================================
clear; clc; close all;

% ---------- 1. Параметры сигнала ----------
tau_d = 4e-3;              % Длительность дискрета, с
Um = 2.5;                  % Амплитуда, В
fn = 1.5e3;                % Несущая частота, Гц
N_d = 7;                   % Длина кода Баркера
q = [1 1 1 -1 -1 1 -1];    % Код Баркера
tau_n = N_d * tau_d;       % Общая длительность, с (28 мс)

% ---------- 2. Ширина спектра (ф-ла 2.5) ----------
Delta_f = 1 / tau_d;
fprintf('=== Параметры сигнала ===\n');
fprintf('Тип сигнала: ФКМ РИ (код Баркера 7)\n');
fprintf('tau_d = %.2f мс, tau_n = %.2f мс\n', tau_d*1000, tau_n*1000);
fprintf('fn = %.1f Гц, Delta_f = %.2f Гц\n', fn, Delta_f);
fprintf('Код Баркера: [%s]\n\n', num2str(q));

% ---------- 3. Временное представление (ф-ла 2.8) ----------
% Используем SIN, чтобы на границах дискрет синусоида была в нуле
% и фазовый скачок выглядел естественно (как на рис. 2.3 методички).
fs = 500e3;
t = 0:1/fs:tau_n;

U = zeros(size(t));
for k = 0:N_d-1
    start_t = k * tau_d;
    end_t = start_t + tau_d;
    idx = t >= start_t & t < end_t;
    U(idx) = q(k+1) * Um * sin(2*pi*fn*t(idx));
end

figure('Name', 'Временное представление ФКМ РИ', ...
       'Position', [100 100 1400 500]);
plot(t*1000, U, 'b', 'LineWidth', 1.2);
xlabel('Время t, мс');
ylabel('U(t), В');
title('ФКМ РИ (код Баркера 7) — временное представление');
grid on;
xlim([0, tau_n*1000]);
ylim([-Um*1.3, Um*1.3]);

% Вертикальные линии — границы дискрет
for k = 1:N_d-1
    xline(k*tau_d*1000, 'k--', 'LineWidth', 0.8);
end
% Подписи кода над каждым дискретом
for k = 0:N_d-1
    text((k+0.5)*tau_d*1000, Um*1.15, num2str(q(k+1)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 13, 'FontWeight', 'bold', 'Color', 'r');
end

% ---------- 4. Тело неопределенности (ф-ла 2.9) ----------
tau_vec = linspace(-tau_n, tau_n, 200);
F_vec   = linspace(-4*Delta_f, 4*Delta_f, 200);
[Tau, F] = meshgrid(tau_vec, F_vec);

Rho = zeros(size(Tau));
for k = 0:N_d-1
    for m = 0:N_d-1
        tau_shifted = Tau - (k - m)*tau_d;
        rho_d = zeros(size(tau_shifted));
        valid_idx = abs(tau_shifted) <= tau_d;
        rho_d(valid_idx) = (1 - abs(tau_shifted(valid_idx))/tau_d) .* ...
                           sinc(F(valid_idx) .* (tau_d - abs(tau_shifted(valid_idx))));
        Rho = Rho + (1/N_d) * q(k+1) * q(m+1) * rho_d .* ...
                    exp(1j * 2 * pi * F * k * tau_d);
    end
end
Rho = abs(Rho);

figure('Name', 'Тело неопределенности');
mesh(Tau*1000, F, Rho);
xlabel('Рассогласование по времени \tau, мс');
ylabel('Рассогласование по частоте F, Гц');
zlabel('|\rho(\tau, F)|');
title('Тело неопределенности ФКМ РИ (код Баркера 7)');
colormap jet; colorbar;

% ---------- 5. Сечения ----------
% АКФ (F = 0)
[~, idx_F0] = min(abs(F_vec));
rho_tau = Rho(idx_F0, :);
figure('Name', 'Сечение АКФ');
plot(tau_vec*1000, rho_tau, 'b', 'LineWidth', 2);
xlabel('Задержка \tau, мс'); ylabel('|\rho(\tau, 0)|');
title('Сечение во временной области (АКФ)');
grid on;
yline(0.5, 'r--', 'LineWidth', 1.5);
xline( tau_d/2*1000, 'g--', 'LineWidth', 1.5);
xline(-tau_d/2*1000, 'g--', 'LineWidth', 1.5);

% Доплеровское (tau = 0)
[~, idx_tau0] = min(abs(tau_vec));
rho_F = Rho(:, idx_tau0);
figure('Name', 'Сечение по частоте');
plot(F_vec, rho_F, 'b', 'LineWidth', 2);
xlabel('Частота Доплера F, Гц'); ylabel('|\rho(0, F)|');
title('Сечение в частотной области');
grid on;
yline(0.64, 'r--', 'LineWidth', 1.5);
xline( 1/(2*tau_n), 'g--', 'LineWidth', 1.5);
xline(-1/(2*tau_n), 'g--', 'LineWidth', 1.5);

% ---------- 6. Вывод ----------
fprintf('=== Анализ сечений ===\n');
fprintf('1. АКФ: ширина на уровне 0.5 = tau_d = %.2f мс\n', tau_d*1000);
fprintf('   Уровень боковых лепестков кода Баркера: 1/N_d = %.4f\n', 1/N_d);
fprintf('2. Спектр: Delta_f = %.2f Гц\n', Delta_f);
fprintf('   Ширина главного лепестка по частоте: 1/(2*tau_n) = %.2f Гц\n', 1/(2*tau_n));