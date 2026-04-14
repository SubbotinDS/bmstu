%% Лабораторная работа №1
clear; clc; close all;
s = tf('s');
% Правильная передаточная функция: произведение в знаменателе
W = (0.1*s + 1) / ((4*s + 1) * (0.25*s + 1));

% 1. Аналитическое определение переходной и импульсной функций
syms t s_sym
W_sym = (0.1*s_sym + 1) / ((4*s_sym + 1) * (0.25*s_sym + 1));
H_sym = W_sym / s_sym;
K_sym = W_sym;
h_t = ilaplace(H_sym, s_sym, t);
k_t = ilaplace(K_sym, s_sym, t);

h_t = simplify(h_t);
k_t = simplify(k_t);

disp('Переходная функция h(t):');
h_t
disp('Импульсная функция k(t):');
k_t

% 2. Построение графиков в MATLAB
t_vec = 0:0.1:25;

h_vals = double(subs(h_t, t, t_vec));
k_vals = double(subs(k_t, t, t_vec));

figure(1);
plot(t_vec, h_vals, 'b-', 'LineWidth', 1.5); hold on;
plot(t_vec, k_vals, 'r--', 'LineWidth', 1.5);
grid on;
xlabel('t, c');
ylabel('h(t), k(t)');
title('Переходная и импульсная функции');
legend('h(t)', 'k(t)');
hold off;

% 3. Проверка с помощью step и impulse
figure(2);
step(W); hold on;
impulse(W);
grid on;
title('Step и Impulse');
legend('step (h(t))', 'impulse (k(t))');
hold off;

% 4. Определение показателей качества переходного процесса
step_info = stepinfo(W);

% Извлечение нужных параметров
t_rise = step_info.RiseTime;          % время нарастания (от 10% до 90%)
t_settle = step_info.SettlingTime;    % время переходного процесса (2% трубка по умолчанию)
overshoot = step_info.Overshoot;      % перерегулирование, %
peak = step_info.Peak;                % максимальное значение
final_value = dcgain(W);              % установившееся значение

fprintf('\n Показатели качества переходного процесса\n');
fprintf('Время нарастания (10-90%%):        t_rise = %.4f c\n', t_rise);
fprintf('Время переходного процесса (2%%):  t_settle = %.4f c\n', t_settle);
fprintf('Перерегулирование:                 σ = %.2f %%\n', overshoot);
fprintf('Максимальное значение:             h_max = %.4f\n', peak);
fprintf('Установившееся значение:           h_уст = %.4f\n', final_value);

% Для монотонной системы колебательность нулевая
fprintf('Показатель колебательности:        ζ = 0 (колебания отсутствуют)\n');



%% 4. Оценка показателей качества (по step-характеристике)
[y, t_out] = step(W);
h_final = y(end);
h_max = max(y);

[~, idx_max] = max(y);
t_rise = t_out(idx_max);

delta = 0.05 * h_final;
idx_settle = find(abs(y - h_final) > delta, 1, 'last');
if isempty(idx_settle)
    t_settle = t_out(end);
else
    t_settle = t_out(idx_settle);
end

overshoot = (h_max - h_final) / h_final * 100;
zero_cross = find(diff(sign(y - h_final)) ~= 0);
oscillations = sum(zero_cross < idx_settle) / 2;

fprintf('\n--- Показатели качества (по переходной функции) ---\n');
fprintf('Установившееся значение h_уст = %.3f\n', h_final);
fprintf('Время нарастания t_р = %.3f с\n', t_rise);
fprintf('Время переходного процесса t_пп = %.3f с\n', t_settle);
fprintf('Перерегулирование σ = %.2f %%\n', overshoot);
fprintf('Колебательность ζ = %.0f\n', oscillations);

%% Лабораторная работа №2 (Вариант 2)

% Параметры из табл. 3.2 (вариант 2)
K = 1.1;
T1 = 0.66;
T2 = 0.36;
xi = 0.32;

% Передаточная функция разомкнутой системы
s = tf('s');
KW2 = K * (T2*s + 1) / ((T1*s + 1) * (T2^2 * s^2 + 2*xi*T2*s + 1));

%% 1. Аналитическое построение АФХ разомкнутой системы
omega = 0.01:0.01:20; % диапазон частот

% Частотная передаточная функция KW2(jw)
s_jw = 1j * omega;
num = K * (T2*s_jw + 1);
den = (T1*s_jw + 1) .* (T2^2 * (s_jw).^2 + 2*xi*T2*s_jw + 1);
KW2_jw = num ./ den;

P = real(KW2_jw);
Q = imag(KW2_jw);

% Построение АФХ
figure;
plot(P, Q, 'b-', 'LineWidth', 1.5);
grid on;
xlabel('P(ω)');
ylabel('Q(ω)');
title('АФХ разомкнутой системы KW₂(jω) (аналитически)');
axis equal;

% Отметим несколько частот
freq_markers = [0.1, 0.5, 1, 2, 5, 10];
hold on;
for w = freq_markers
    s_w = 1j * w;
    num_w = K * (T2*s_w + 1);
    den_w = (T1*s_w + 1) * (T2^2 * s_w^2 + 2*xi*T2*s_w + 1);
    val = num_w / den_w;
    plot(real(val), imag(val), 'ro', 'MarkerSize', 8);
    text(real(val), imag(val), sprintf('  ω=%.1f', w), 'FontSize', 10);
end
hold off;

%% 2. Экспериментальное построение АФХ (команда nyquist)
figure;
nyquist(KW2);
title('АФХ разомкнутой системы (команда nyquist)');
grid on;

%% 3. АФХ замкнутой системы
Phi = feedback(KW2, 1);

figure;
nyquist(Phi);
title('АФХ замкнутой системы');
grid on;

%% 4. ЛАХ и ЛФХ разомкнутой системы (аналитически)
w_log = logspace(-2, 2, 500);

% Вычисляем модуль и фазу
s_w = 1j * w_log;
num_log = K * (T2*s_w + 1);
den_log = (T1*s_w + 1) .* (T2^2 * s_w.^2 + 2*xi*T2*s_w + 1);
KW2_jw_log = num_log ./ den_log;

A = abs(KW2_jw_log);
H = 20 * log10(A);
theta = unwrap(angle(KW2_jw_log)) * 180/pi;

% Построение
figure;
subplot(2,1,1);
semilogx(w_log, H, 'b-', 'LineWidth', 1.5);
grid on;
xlabel('\omega, рад/с');
ylabel('H(\omega), дБ');
title('ЛАХ разомкнутой системы (аналитически)');

subplot(2,1,2);
semilogx(w_log, theta, 'r-', 'LineWidth', 1.5);
grid on;
xlabel('\omega, рад/с');
ylabel('\theta(\omega), град');
title('ЛФХ разомкнутой системы (аналитически)');

%% 5. Экспериментальные ЛАХ и ЛФХ (команда bode)
figure;
bode(KW2);
title('ЛАХ и ЛФХ разомкнутой системы (команда bode)');
grid on;

%% 6. ЛАХ и ЛФХ замкнутой системы
figure;
bode(Phi);
title('ЛАХ и ЛФХ замкнутой системы');
grid on;

%% 7. Исследование влияния ξ на ЛАХ и ЛФХ
xi_vals = [0.2, 0.5, 0.8];
figure;
for i = 1:length(xi_vals)
    xi_temp = xi_vals(i);
    KW_temp = K * (T2*s + 1) / ((T1*s + 1) * (T2^2 * s^2 + 2*xi_temp*T2*s + 1));
    bode(KW_temp);
    hold on;
end
grid on;
title('Влияние ξ на ЛАХ и ЛФХ');
legend('\xi = 0.2', '\xi = 0.5', '\xi = 0.8');

%% 8. Обработка результатов ЛАХ (асимптоты и срез)
% Сопрягающие частоты
w1 = 1/T1;   % 1/0.66 ≈ 1.515
w2 = 1/T2;   % 1/0.36 ≈ 2.778
w3 = 1/T2;   % для колебательного звена (та же, но наклон -40 дБ/дек)

fprintf('\n--- Обработка ЛАХ ---\n');
fprintf('Сопрягающая частота ω₁ (апериодическое звено T1) = %.3f рад/с\n', w1);
fprintf('Сопрягающая частота ω₂ (форсирующее звено T2) = %.3f рад/с\n', w2);
fprintf('Сопрягающая частота ω₃ (колебательное звено T2^2) = %.3f рад/с\n', w3);

% Частота среза (приближённо)
[~, idx_cut] = min(abs(H));
w_cut = w_log(idx_cut);
fprintf('Частота среза ω_ср ≈ %.3f рад/с\n', w_cut);