clear; clc; close all;
% задание1
N0 = 1000;          % Общее число микросхем
dt = 100;           % Ширина интервала, ч

% Число отказов по интервалам t (из таблицы задачи)
n = [50, 40, 32, 25, 20, 17, 16, 16, 15, 14, 15, 14, 14, 13, 14, 13, 13, 13, 14, 12, 12, 13, 12, 13, 14, 16, 20, 25, 30, 40];

% Сетки времени
t_edges = 0:dt:3000;             % Границы интервалов [0, 100, ..., 3000]
t_mid = t_edges(1:end-1) + dt/2; % Середины интервалов [50, 150, ..., 2950]

f_hat = n / (N0 * dt); % Эмпирическая PDF (Плотность вероятности отказа)
P_hat = (N0 - cumsum(n)) / N0; % Эмпирическая ВБР (Вероятность безотказной работы)

P_plot = [1, P_hat]; % Для корректного построения графика добавим точку P(0) = 1 //надо ли???

% Эмпирическая ИО (Интенсивность отказов
N_end = N0 - cumsum(n);
N_start = [N0, N_end(1:end-1)];
N_avg = (N_start + N_end) / 2;

lambda_hat = n ./ (N_avg * dt);


% построение графиков
figure('Name', 'Эмпирические функции надежности', 'Position', [100 100 800 900]);

% График 1: Гистограмма PDF
subplot(3, 1, 1);
bar(t_mid, f_hat, 1, 'FaceColor', [0.2 0.6 0.8], 'EdgeColor', 'black');
title('Гистограмма плотности вероятности (PDF)');
xlabel('t, [ч]');
ylabel('f(t), [1/ч]');
xlim([0 3000]);
grid on;

% График 2: Эмпирическая ВБР
subplot(3, 1, 2);
stairs(t_edges, P_plot, 'LineWidth', 2, 'Color', 'r');
hold on;
title('Вероятность безотказной работы (ВБР)');
xlabel('t, ч');
ylabel('P(t)');
xlim([0 3000]);
grid on;

% График 3: Эмпирическая ИО
subplot(3, 1, 3);
bar(t_mid, lambda_hat, 1, 'FaceColor', [0.8 0.4 0.2], 'EdgeColor', 'black');
title('Интенсивность отказов (ИО)');
xlabel('Время t, ч');
ylabel('\lambda^*(t), 1/ч');
xlim([0 3000]);
grid on;





% задание2
% Физически обоснованные функциональные зависимости показателей надежности для генеральной совокупности

% Аппроксимируем эмпирическую интенсивность отказов двухсоставной моделью Вейбулла:
beta1_fun = @(z) 0.05 + 0.95 ./ (1 + exp(-z(1)));
eta1_fun = @(z) exp(z(2));
beta2_fun = @(z) 1.01 + exp(z(3));
eta2_fun = @(z) exp(z(4));

% Функция интенсивности отказов модели
lambda_fun = @(z,t) ...
    beta1_fun(z) ./ eta1_fun(z) .* ...
    (t ./ eta1_fun(z)).^(beta1_fun(z)-1) + ...
    beta2_fun(z) ./ eta2_fun(z) .* ...
    (t ./ eta2_fun(z)).^(beta2_fun(z)-1);

% МНК
% Умножение на 10^4 только для удобства численной оптимизации
% (не меняет найденные параметры модели)

objective = @(z) ...
    sum(((lambda_fun(z,t_mid) - lambda_hat) * 1e4).^2);

% Начальные приближения параметров
% beta1 ~ 0.7
% eta1  ~ 6000 ч
% beta2 ~ 5
% eta2  ~ 3500 ч

z0 = [0, log(6000), log(4), log(3500)];

options = optimset( ...
    'Display', 'off', ...
    'MaxFunEvals', 10000, ...
    'MaxIter', 10000, ...
    'TolX', 1e-10, ...
    'TolFun', 1e-12);

% Определение параметров методом наименьших квадратов
z_hat = fminsearch(objective, z0, options);

% ---------------------------------------------------------
% Полученные параметры модели
% ---------------------------------------------------------

beta1 = beta1_fun(z_hat);
eta1  = eta1_fun(z_hat);

beta2 = beta2_fun(z_hat);
eta2  = eta2_fun(z_hat);

fprintf('\n\n');
fprintf('Параметры аппроксимации модели Вейбулла\n');
fprintf('beta1 = %.6f\n', beta1);
fprintf('eta1  = %.3f ч\n', eta1);
fprintf('beta2 = %.6f\n', beta2);
fprintf('eta2  = %.3f ч\n', eta2);

T_avg = (sum(n.* t_mid))/(sum(n));
fprintf('Средняя наработка на отказ для случая а) = %.3f \n\n', T_avg);

% ---------------------------------------------------------
% Функции надежности генеральной совокупности
% ---------------------------------------------------------

% Сетка времени для ВБР
t_P = linspace(0, 3000, 1000);

% Для lambda(t) нельзя брать t = 0,
% поскольку при beta1 < 1 первая составляющая
% стремится к бесконечности.
t_model = linspace(1, 3000, 1000);

% ---------------------------------------------------------
% ВБР P(t)
% ---------------------------------------------------------

P_model = exp( ...
    -(t_P ./ eta1).^beta1 ...
    -(t_P ./ eta2).^beta2);

% Интенсивность отказов lambda(t)
lambda_model_curve = ...
    beta1 ./ eta1 .* ...
    (t_model ./ eta1).^(beta1 - 1) + ...
    beta2 ./ eta2 .* ...
    (t_model ./ eta2).^(beta2 - 1);

% PDF f(t)
P_for_pdf = exp( ...
    -(t_model ./ eta1).^beta1 ...
    -(t_model ./ eta2).^beta2);

f_model = lambda_model_curve .* P_for_pdf;



% графики
figure('Name','Аппроксимация','Position', [150 100 900 600]);
subplot(3, 1, 1);
bar(t_mid, f_hat, 1,'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'black');
hold on;
plot(t_model, f_model, 'r', 'LineWidth', 2.5);
title('PDF: эмпирические оценки и аппроксимация');
xlabel('Наработка t, ч');
ylabel('f(t), 1/ч');
xlim([0 3000]);
grid on;

subplot(3, 1, 2);
bar(t_edges(2:end), P_hat, 1,'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'black');
hold on;
plot(t_P, P_model,'r','LineWidth', 2.5);
title('ВБР: эмпирические оценки и аппроксимация');
xlabel('Наработка t, ч');
ylabel('P(t)');
xlim([0 3000]);
grid on;

subplot(3,1,3);
bar(t_mid, lambda_hat, 1, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'black');
hold on;
plot(t_model, lambda_model_curve,'r','LineWidth', 2.5);
title('Интенсивность отказов: эмпирические оценки и аппроксимация');
xlabel('Наработка t, ч');
ylabel('\lambda(t), 1/ч');
xlim([0 3000]);
grid on;





