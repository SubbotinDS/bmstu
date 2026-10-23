clear; clc; close all;

% Вариант 12
A = [-34, -54, -17; 
      20,  30.5, 9.4; 
     -5.9, -7.9, -2.3];
B = [0.228; -0.127; 0.038];
C = [21000, 63000, 84000];

% Задание 1. Проверка управляемости
W = ctrb(A, B); % Формирование матрицы управляемости
disp('Матрица управляемости W = [B, AB, A^2B]:'); disp(W);
det_W = det(W);
disp('Определитель матрицы управляемости:'); disp(det_W);
if det_W ~= 0
    disp('Система управляема.');
else
    disp('Система неуправляема.');
end

% Задание 2. Расчет коэффициентов обратной связи K
% Вариант А: Перерегулирование 0% (апериодический процесс)
P1 = [-1, -2, -3];
disp('Желаемые полюса P1 ='); disp(P1);
K1 = acker(A, B, P1);
disp('Вектор K (0% перерегулирования):'); disp(K1);


% Проверка полюсов замкнутой системы
poles1 = eig(A - B*K1);
disp('Фактические полюса eig(A - B*K1) =');
disp(sort(poles1));


% Вариант Б: Перерегулирование 30%
delta = 0.30;
mu    = pi / (-log(delta));
alpha = 1;
beta  = mu * alpha;
P2    = [-alpha + 1i*beta, -alpha - 1i*beta, -7];
K2    = place(A, B, P2);
disp('Желаемые полюса P2 ='); disp(P2);
disp('Коэффициенты обратной связи K2 ='); disp(K2);

% Проверка полюсов замкнутой системы
poles2 = eig(A - B*K2);
disp('Фактические полюса eig(A - B*K2) =');
disp(sort(poles2));



% Задание 3. Масштабирующие коэффициенты k0
% k0 = -1 / ( C * inv(A - B*K) * B )
k0_1 = -1 / (C * ((A - B*K1) \ B));
k0_2 = -1 / (C * ((A - B*K2) \ B));

fprintf('\nМасштабирующие коэффициенты\n');
fprintf('k0 (0%% перерегулирования)  = %.6g\n', k0_1);
fprintf('k0 (30%% перерегулирования) = %.6g\n', k0_2);

% Проверка переходных процессов через step() (до Simulink)

sys1 = ss(A - B*K1, B*k0_1, C, 0);
sys2 = ss(A - B*K2, B*k0_2, C, 0);

T_end = 12;
[y1, t1] = step(sys1, T_end);
[y2, t2] = step(sys2, T_end);

overshoot1 = max(0, (max(y1) - 1) * 100);
overshoot2 = max(0, (max(y2) - 1) * 100);

fprintf('\n=== Результаты step() ===\n');
fprintf('Перерегулирование А: %.2f %%\n', overshoot1);
fprintf('Перерегулирование Б: %.2f %%\n', overshoot2);
fprintf('y_уст А: %.6f\n', y1(end));
fprintf('y_уст Б: %.6f\n', y2(end));

figure('Name','Переходные процессы','Color','w');
plot(t1, y1, 'b-', 'LineWidth', 1.8); hold on;
plot(t2, y2, 'r-', 'LineWidth', 1.8);
yline(1, 'k--', 'LineWidth', 1.0);
grid on;
xlabel('t, с'); ylabel('y(t)');
title('Переходные процессы в замкнутой системе');
legend('0% перерегулирования', '30% перерегулирования','y = 1', 'Location', 'southeast');




