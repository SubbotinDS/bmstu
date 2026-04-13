
clear; clc; close all;
tau = 0.6;
xi = 0.21;

%% Пункт 5: Построение АФХ аналитическим методом
w = [0:0.1:20];
P = 1 ./ (1 + tau^2 * w.^2);
Q = -tau * w ./ (1 + tau^2 * w.^2);
figure(1);
plot(P, Q, 'b-', 'LineWidth', 1.5);
grid on;
xlabel('Re — вещественная ось');
ylabel('Im — мнимая ось');
title(sprintf('АФХ апериодического звена (аналитический метод), \\tau = %.1f', tau));

%% Пункт 6: Нанесение маркеров для выбранных частот
hold on;
w_points = [0, 0.1, 0.3, 0.5, 0.7, 1, 2, 3, 4, 5, 10, 15, 20];
P_points = 1 ./ (1 + tau^2 * w_points.^2);
Q_points = -tau * w_points ./ (1 + tau^2 * w_points.^2);
plot(P_points, Q_points, 'r*', 'MarkerSize', 8, 'LineWidth', 1.5);
% Подписи частот
for i = 1:length(w_points)
    if ismember(w_points(i), w_points)
        if w_points(i) == 0
            text(P_points(i), Q_points(i), '  \omega=0', 'FontSize', 10);
        else
            text(P_points(i), Q_points(i), ['  \omega=', num2str(w_points(i))], ...
                 'FontSize', 10, 'VerticalAlignment', 'bottom');
        end
    end
end
hold off;

%% Пункт 8: Сравнение АФХ разомкнутой и замкнутой системы
s = tf('s');
W_open = 1 / (tau * s + 1);  % разомкнутая система
% Передаточная функция замкнутой системы (единичная отрицательная обратная связь)
W_closed = feedback(W_open, 1);  % или W_closed = 1/(tau*s + 2)
figure(2);
nyquist(W_open, 'b');% Построение АФХ разомкнутой системы
hold on;
nyquist(W_closed, 'r');% Построение АФХ замкнутой системы
grid on;
title(sprintf('Сравнение АФХ разомкнутой и замкнутой системы, \\tau = %.1f', tau));
legend('Разомкнутая система KW_1(j\omega)', 'Замкнутая система \Phi_1(j\omega)', ...
       'Location', 'best');
hold off;
%% Пункт 9 (звено второго порядка)
a = tau^2;      % 0.36
b = 2 * xi * tau; % 0.252
c = 1;
w = [0:0.01:20];  % более мелкий шаг для гладкости
% Знаменатель
denom = (1 - a * w.^2).^2 + (b * w).^2;
P = (1 - a * w.^2) ./ denom;
Q = -b * w ./ denom;
figure(3);
plot(P, Q, 'b-', 'LineWidth', 1.5);
grid on;
xlabel('Re — вещественная ось');
ylabel('Im — мнимая ось');
title(sprintf('АФХ колебательного звена, τ = %.1f, ξ = %.2f', tau, xi));
xlim([-1, 2]);
ylim([-2.5, 0.5]);
% Нанесение маркеров для выбранных частот
hold on;
w_points = [0, 0.2, 0.4, 0.6, 0.8, 1, 1.2, 1.5, 2, 3, 4, 5, 7, 10, 15, 20];
% Расчёт для выбранных частот
denom_points = (1 - a * w_points.^2).^2 + (b * w_points).^2;
P_points = (1 - a * w_points.^2) ./ denom_points;
Q_points = -b * w_points ./ denom_points;
plot(P_points, Q_points, 'r*', 'MarkerSize', 8, 'LineWidth', 1.5);
% Подписи ключевых частот
key_freqs = [0, 0.2, 0.4, 0.6, 1, 1.2, 2, 3, 4, 5, 20];
for i = 1:length(w_points)
    if ismember(w_points(i), key_freqs)
        if w_points(i) == 0
            text(P_points(i), Q_points(i), '  \omega=0', 'FontSize', 10);
        else
            text(P_points(i), Q_points(i), ['  \omega=', num2str(w_points(i))], ...
                 'FontSize', 10, 'VerticalAlignment', 'bottom');
        end
    end
end
hold off;

% Сравнение АФХ разомкнутой и замкнутой системы
s = tf('s');
W_open = 1 / (a * s^2 + b * s + 1);  % разомкнутая система
% Передаточная функция замкнутой системы (единичная отрицательная обратная связь)
W_closed = feedback(W_open, 1);
figure(4);
nyquist(W_open, 'b');
hold on;
nyquist(W_closed, 'r');
grid on;
title(sprintf('Сравнение АФХ разомкнутой и замкнутой системы, \\tau = %.1f, ξ = %.2f', tau, xi));
legend('Разомкнутая система KW_2(j\omega)', 'Замкнутая система \Phi_2(j\omega)', ...
       'Location', 'best');

%% Пункт 10: Влияние коэффициента демпфирования на вид АФХ (экспериментально)
% Параметры
tau = 0.6;
xi1 = 0.21;      % исходный
xi2 = 0.42;      % увеличенный в 2 раза
xi4 = 0.84;
xi8 = 1.68;
xi16 = 3.36;
% Коэффициенты
a = tau^2;       % 0.36
b1 = 2 * xi1 * tau;
b2 = 2 * xi2 * tau;
b4 = 2 * xi4 * tau;
b8 = 2 * xi8 * tau;
b16 = 2 * xi16 * tau;
% Создание передаточных функций
s = tf('s');
W1 = 1 / (a * s^2 + b1 * s + 1);  % исходная система (ξ = 0.21)
W2 = 1 / (a * s^2 + b2 * s + 1);
W4 = 1 / (a * s^2 + b4 * s + 1);
W8 = 1 / (a * s^2 + b8 * s + 1);
W16 = 1 / (a * s^2 + b16 * s + 1);
% Построение АФХ с помощью nyquist
figure(5);
nyquist(W1, 'b');
hold on;
nyquist(W2, 'r');
nyquist(W4, 'g');
nyquist(W8, 'm');
nyquist(W16, 'k');
grid on;
title(sprintf('Влияние коэффициента демпфирования на АФХ, \\tau = %.1f', tau));
legend(sprintf('ξ = %.2f', xi1), sprintf('ξ = %.2f', xi2), sprintf('ξ = %.2f', xi4), sprintf('ξ = %.2f', xi8), sprintf('ξ = %.2f', xi16), 'Location', 'best');
hold off;

%% Пункты 11-13: ЛАХ и ЛФХ для KW_3(s) с сравнением аналитического метода и bode
% Параметры
K = 2.1;
T1 = 0.76;
T2 = 0.46;
T3 = 0.16;
xi = 0.52;

% Вычисление коэффициентов
T3_sq = T3^2;                    % T₃²
damping = 2 * xi * T3;           % 2ξT₃

% Диапазон частот
w = logspace(-3, 2, 1000);

% Аналитический расчёт ЛАХ и ЛФХ
% Модуль АФХ: используем T3_sq в знаменателе
numerator = K * sqrt((T2 * w).^2 + 1);
denominator = sqrt((T1 * w).^2 + 1) .* sqrt((1 - T3_sq * w.^2).^2 + (damping * w).^2);
A = numerator ./ denominator;
H = 20 * log10(A);

% Фаза: в аргументе atan2 также используем T3_sq
theta_rad = atan(T2 * w) - atan(T1 * w) - atan2(damping * w, 1 - T3_sq * w.^2);
theta_rad_unwrap = unwrap(theta_rad * 10) / 10;
theta_deg_unwrap = theta_rad_unwrap * 180 / pi;

% Экспериментальное получение ЛАХ и ЛФХ с помощью bode
s = tf('s');
W_tf = K * (T2 * s + 1) / ((T1 * s + 1) * (T3_sq * s^2 + damping * s + 1));
[mag_bode, phase_bode, w_bode] = bode(W_tf, w);
mag_bode = squeeze(mag_bode);
phase_bode = squeeze(phase_bode);
H_bode = 20 * log10(mag_bode);

% Построение единого графика с наложением
figure(6);

% Верхний график: ЛАХ
subplot(2,1,1);
semilogx(w, H, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Аналитический расчёт');
hold on;
semilogx(w_bode, H_bode, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Эксперимент (bode)');
grid on;
xlabel('\omega, рад/с');
ylabel('H(\omega), дБ');
title(sprintf('ЛАХ системы KW_3(s), (K=%.1f, T_1=%.2f, T_2=%.2f, T_3=%.2f, \\xi=%.2f)', K, T1, T2, T3, xi));
xlim([0.001, 100]);

% Асимптота на низких частотах
yline(20*log10(K), 'g--', 'DisplayName', sprintf('20lgK = %.1f дБ', 20*log10(K)));
% Частоты сопряжения: для T1 и для колебательного звена (1/T3)
xline(1/T1, 'g--', 'DisplayName', sprintf('ω₁ = 1/T₁ = %.2f', 1/T1));
xline(1/T3, 'm--', 'DisplayName', sprintf('ω₂ = 1/T₃ = %.2f', 1/T3));
legend('Location', 'best');
hold off;

% Нижний график: ЛФХ
subplot(2,1,2);
semilogx(w, theta_deg_unwrap, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Аналитический расчёт (unwrap)');
hold on;
semilogx(w_bode, phase_bode, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Эксперимент (bode)');
grid on;
xlabel('\omega, рад/с');
ylabel('\theta(\omega), град');
title('ЛФХ системы KW_3(s)');
xlim([0.001, 100]);
ylim([-270, 90]);

% Характерные линии
yline(0, 'k--', 'DisplayName', '0°');
yline(-90, 'k--', 'DisplayName', '-90°');
yline(-180, 'k--', 'DisplayName', '-180°');
yline(-270, 'k--', 'DisplayName', '-270°');
xline(1/T1, 'g--', 'DisplayName', sprintf('ω₁ = 1/T₁ = %.2f', 1/T1));
xline(1/T3, 'm--', 'DisplayName', sprintf('ω₂ = 1/T₃ = %.2f', 1/T3));
legend('Location', 'best');
hold off;

%% Пункт 14: Сравнение ЛАХ и ЛФХ разомкнутой и замкнутой системы
% Передаточные функции (с использованием T3 в колебательном звене)
s = tf('s');
W_open = K * (T2 * s + 1) / ((T1 * s + 1) * (T3_sq * s^2 + damping * s + 1));  % разомкнутая
W_closed = feedback(W_open, 1);  % замкнутая

% Получение ЛАХ и ЛФХ для разомкнутой системы
[mag_open, phase_open, w_out] = bode(W_open, w);
mag_open = squeeze(mag_open);
phase_open = squeeze(phase_open);
H_open = 20 * log10(mag_open);

% Получение ЛАХ и ЛФХ для замкнутой системы
[mag_closed, phase_closed, w_out] = bode(W_closed, w);
mag_closed = squeeze(mag_closed);
phase_closed = squeeze(phase_closed);
H_closed = 20 * log10(mag_closed);

% Построение графиков
figure(7);

% Верхний график: сравнение ЛАХ
subplot(2,1,1);
semilogx(w_out, H_open, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Разомкнутая система');
hold on;
semilogx(w_out, H_closed, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Замкнутая система');
grid on;
xlabel('\omega, рад/с');
ylabel('H(\omega), дБ');
title('Сравнение ЛАХ разомкнутой и замкнутой системы');
legend('Location', 'best');
xlim([0.001, 100]);

% Добавление асимптоты для разомкнутой системы
yline(20*log10(K), 'b--', 'DisplayName', sprintf('20lgK (разомкн.) = %.1f дБ', 20*log10(K)));
hold off;

% Нижний график: сравнение ЛФХ
subplot(2,1,2);
semilogx(w_out, phase_open, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Разомкнутая система');
hold on;
semilogx(w_out, phase_closed, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Замкнутая система');
grid on;
xlabel('\omega, рад/с');
ylabel('\theta(\omega), град');
title('Сравнение ЛФХ разомкнутой и замкнутой системы');
legend('Location', 'best');
xlim([0.001, 100]);
ylim([-270, 90]);

% Добавление характерных линий
yline(0, 'k--', 'DisplayName', '0°');
yline(-90, 'k--', 'DisplayName', '-90°');
yline(-180, 'k--', 'DisplayName', '-180°');
yline(-270, 'k--', 'DisplayName', '-270°');
hold off;

%% Пункт 15: ЛАХ и ЛФХ для KW_4(s) с сравнением аналитического метода и bode
% Параметры для варианта 12
K = 2.1;
T1 = 0.76;
xi = 0.52;

% Вычисление коэффициентов
T1_sq = T1^2;           % 0.5776
damping = 2 * xi * T1;  % 0.7904

% Диапазон частот
w = logspace(-3, 2, 1000);

% Аналитический расчёт ЛАХ и ЛФХ
% Модуль АФХ: A(ω) = K / [ω * √((1 - T1²ω²)² + (2ξT1ω)²)]
A = K ./ (w .* sqrt((1 - T1_sq * w.^2).^2 + (damping * w).^2));
H = 20 * log10(A);

% Фаза: θ(ω) = -90° - arctg(2ξT1ω/(1 - T1²ω²))
theta_rad = -pi/2 - atan2(damping * w, 1 - T1_sq * w.^2);
theta_rad_unwrap = unwrap(theta_rad * 10) / 10;
theta_deg_unwrap = theta_rad_unwrap * 180 / pi;

% Экспериментальное получение ЛАХ и ЛФХ с помощью bode
s = tf('s');
W_tf = K / (s * (T1_sq * s^2 + damping * s + 1));
[mag_bode, phase_bode, w_bode] = bode(W_tf, w);
mag_bode = squeeze(mag_bode);
phase_bode = squeeze(phase_bode);
H_bode = 20 * log10(mag_bode);

% Построение единого графика с наложением
figure(8);

% Верхний график: ЛАХ
subplot(2,1,1);
semilogx(w, H, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Аналитический расчёт');
hold on;
semilogx(w_bode, H_bode, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Эксперимент (bode)');
grid on;
xlabel('\omega, рад/с');
ylabel('H(\omega), дБ');
title(sprintf('ЛАХ системы KW_4(s), (K=%.1f, T_1=%.2f, \\xi=%.2f)', K, T1, xi));
xlim([0.001, 100]);

% Асимптота на низких частотах
yline(20*log10(K), 'g--', 'DisplayName', sprintf('20lgK = %.1f дБ', 20*log10(K)));
% Частота сопряжения
xline(1/T1, 'g--', 'DisplayName', sprintf('ω₀ = 1/T₁ = %.2f', 1/T1));
legend('Location', 'best');
hold off;

% Нижний график: ЛФХ
subplot(2,1,2);
semilogx(w, theta_deg_unwrap, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Аналитический расчёт (unwrap)');
hold on;
semilogx(w_bode, phase_bode, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Эксперимент (bode)');
grid on;
xlabel('\omega, рад/с');
ylabel('\theta(\omega), град');
title('ЛФХ системы KW_4(s)');
xlim([0.001, 100]);
ylim([-360, 0]);

% Характерные линии
yline(-90, 'k--', 'DisplayName', '-90°');
yline(-180, 'k--', 'DisplayName', '-180°');
yline(-270, 'k--', 'DisplayName', '-270°');
xline(1/T1, 'g--', 'DisplayName', sprintf('ω₀ = 1/T₁ = %.2f', 1/T1));
legend('Location', 'best');
hold off;

% Сравнение ЛАХ и ЛФХ разомкнутой и замкнутой системы
% Создание передаточных функций
s = tf('s');
W_open = K / (s * (T1_sq * s^2 + damping * s + 1));  % разомкнутая
W_closed = feedback(W_open, 1);  % замкнутая (единичная отрицательная обратная связь)

% Получение ЛАХ и ЛФХ для разомкнутой системы
[mag_open, phase_open, w_out] = bode(W_open, w);
mag_open = squeeze(mag_open);
phase_open = squeeze(phase_open);
H_open = 20 * log10(mag_open);

% Получение ЛАХ и ЛФХ для замкнутой системы
[mag_closed, phase_closed, w_out] = bode(W_closed, w);
mag_closed = squeeze(mag_closed);
phase_closed = squeeze(phase_closed);
H_closed = 20 * log10(mag_closed);

% Построение графиков
figure(9);

% Верхний график: сравнение ЛАХ
subplot(2,1,1);
semilogx(w_out, H_open, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Разомкнутая система');
hold on;
semilogx(w_out, H_closed, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Замкнутая система');
grid on;
xlabel('\omega, рад/с');
ylabel('H(\omega), дБ');
title('Сравнение ЛАХ разомкнутой и замкнутой системы (KW_4(s))');
legend('Location', 'best');
xlim([0.001, 100]);

% Добавление асимптоты для разомкнутой системы
yline(20*log10(K), 'b--', 'DisplayName', sprintf('20lgK (разомкн.) = %.1f дБ', 20*log10(K)));
hold off;

% Нижний график: сравнение ЛФХ
subplot(2,1,2);
semilogx(w_out, phase_open, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Разомкнутая система');
hold on;
semilogx(w_out, phase_closed, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Замкнутая система');
grid on;
xlabel('\omega, рад/с');
ylabel('\theta(\omega), град');
title('Сравнение ЛФХ разомкнутой и замкнутой системы (KW_4(s))');
legend('Location', 'best');
xlim([0.001, 100]);
ylim([-400, 0]);

% Добавление характерных линий
yline(-90, 'k--', 'DisplayName', '-90°');
yline(-180, 'k--', 'DisplayName', '-180°');
yline(-270, 'k--', 'DisplayName', '-270°');
hold off;

%% Пункт 16: Влияние ξ на ЛАХ и ЛФХ колебательного звена

% Параметры
tau = 0.6;
xi_vec = [0.2, 0.5, 0.8];   % три значения ξ
colors = {'b', 'r', 'g'};
styles = {'-', '-', '-'};

% Частотный диапазон
w = logspace(-2, 2, 1000);

figure(10); clf;

% Перебор ξ
for i = 1:length(xi_vec)
    xi = xi_vec(i);
    % Коэффициенты передаточной функции: 1/(τ²s² + 2ξτ s + 1)
    a = tau^2;
    b = 2*xi*tau;
    s = tf('s');
    W = 1 / (a*s^2 + b*s + 1);
    
    % Получение ЛАХ и ЛФХ через bode
    [mag, phase, w_out] = bode(W, w);
    mag = squeeze(mag);
    phase = squeeze(phase);
    H = 20*log10(mag);
    
    % Построение ЛАХ
    subplot(2,1,1);
    semilogx(w_out, H, colors{i}, 'LineWidth', 1.5, 'LineStyle', styles{i}, ...
             'DisplayName', sprintf('\\xi = %.1f', xi));
    hold on;
    
    % Построение ЛФХ
    subplot(2,1,2);
    semilogx(w_out, phase, colors{i}, 'LineWidth', 1.5, 'LineStyle', styles{i}, ...
             'DisplayName', sprintf('\\xi = %.1f', xi));
    hold on;
end

% Оформление ЛАХ
subplot(2,1,1);
grid on;
xlabel('\omega, рад/с');
ylabel('H(\omega), дБ');
title('Влияние коэффициента демпфирования \xi на ЛАХ колебательного звена (\tau=0.6)');
xlim([0.01, 100]);
ylim([-40, 10]);
legend('Location', 'best');

% Оформление ЛФХ
subplot(2,1,2);
grid on;
xlabel('\omega, рад/с');
ylabel('\theta(\omega), град');
title('Влияние коэффициента демпфирования \xi на ЛФХ колебательного звена');
xlim([0.01, 100]);
ylim([-180, 0]);
legend('Location', 'best');