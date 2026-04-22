% Вариант 2: 2x^3 + x^2 - 6x + 2 = 0, меньший корень
clear; clc; close all;

eps = 0.00001;
syms x;

f1_sym = 2^(x - 0.1) - 1;
df1_sym = diff(f1_sym, x);
f1 = matlabFunction(f1_sym);
df1 = matlabFunction(df1_sym);

plot([0:0.01:1], f1([0:0.01:1])); grid on;
x01 = 1; % выполняется f(x0)*f''(x0) > 0

f2_sym = (x - 0.2)^3;
df2_sym = diff(f2_sym, x);
f2 = matlabFunction(f2_sym);
df2 = matlabFunction(df2_sym);

figure
plot([0:0.01:1], f2([0:0.01:1])); grid on;
x02 = 1; % выполняется f(x0)*f''(x0) > 0

newton(x01, f1, df1, eps)
newton_mod(x01, f1, df1, eps)
newton(x02, f2, df2, eps)
newton_mod(x02, f2, df2, eps)

figure
f = @(x) 2*x.^3 + x.^2 - 6*x + 2;
plot([-2.5:0.01:2.5], f([-2.5:0.01:2.5])); grid on;
df = @(x) 6*x.^2 + 2*x - 6;
a = -3; b = -2; % Интервал для меньшего корня

% Массивы для хранения результатов
methods = {'Ньютона', 'Ньютона (упр.)', 'Секущих', 'Половинного деления'};
res_x = zeros(4,1); res_err = zeros(4,1); res_iter = zeros(4,1); res_time = zeros(4,1);

%% 1. Метод половинного деления
tic;
a1 = a; b1 = b; iter = 0;
while (b1 - a1) > 2*eps
    iter = iter + 1;
    c = (a1 + b1) / 2;
    if f(a1) * f(c) < 0
        b1 = c;
    else
        a1 = c;
    end
end
res_x(4) = (a1 + b1) / 2; res_iter(4) = iter; res_time(4) = toc;

%% 2. Метод Ньютона
% Проверка условия сходимости: f(x0)*f''(x0) > 0
% f''(x) = 12x + 2. В точке -3: f(-3)=-25, f''(-3)=-34. (-25)*(-34) > 0.
x0 = -3;
[res_x(1) res_iter(1) res_time(1) x_log] = newton(x0, f, df, eps);

% Геометрическая интерпретация
figure
x_plot = linspace(a-0.2, b, 100);
plot(x_plot, f(x_plot)); grid on; hold on;
line([a-0.2 b], [0 0], 'Color', 'k');
for i = 1:length(x_log)
    y_tan = f(x_log(i)) + df(x_log(i))*(x_plot - x_log(i));
    plot(x_plot, y_tan);
end
title('Геометрическая интерпретация метода Ньютона');
legend('f(x)', 'y=0');
xlabel('x'); ylabel('f(x)');

%% 3. Упрощенный метод Ньютона

[res_x(2) res_iter(2) res_time(2) x_log] = newton_mod(x0, f, df, eps);

% Геометрическая интерпретация
figure
x_plot = linspace(a-0.2, b, 100);
plot(x_plot, f(x_plot)); grid on; hold on;
line([a-0.2 b], [0 0], 'Color', 'k');
y_tan = f(x_log(1)) + df(x_log(1))*(x_plot - x_log(1));
plot(x_plot, y_tan);
for i = 2:length(x_log)
    y_tan = y_tan + f(x_log(i));
    plot(x_plot, y_tan);
end
title('Геометрическая интерпретация метода Ньютона-У');
legend('f(x)', 'y=0');
xlabel('x'); ylabel('f(x)');
figure
%% 4. Метод секущих
tic;
x_prev = a; x_curr = b; iter = 0;
while true
    iter = iter + 1;
    x_next = x_curr - f(x_curr)*(x_curr - x_prev)/(f(x_curr) - f(x_prev));
    if abs(x_next - x_curr) < eps, break; end
    x_prev = x_curr;
    x_curr = x_next;
end
res_x(3) = x_next; res_iter(3) = iter; res_time(3) = toc;

% Заполнение ошибок (разница с самым точным методом или значение f(x))
res_err = abs(f(res_x));

%% Вывод таблицы
T = table(methods', res_x, res_err, res_iter, res_time, ...
    'VariableNames', {'Метод', 'Приближ_решение', 'Абс_погрешность', 'Число_итераций', 'Время_работы'});
disp(T);

%% Функции
function [res_x, res_iter, res_time, x_log] = newton(x0, f, df, eps)
    tic;
    x_curr = x0; iter = 0;
    x_log = [x_curr];
    while true
        iter = iter + 1;
        x_next = x_curr - f(x_curr)/df(x_curr);
        x_log = [x_log x_next];
        if abs(x_next - x_curr) < eps, break; end
        x_curr = x_next;
    end
    res_x = x_next; res_iter = iter; res_time = toc;
end

function [res_x, res_iter, res_time, x_log] = newton_mod(x0, f, df, eps)
    tic;
    x_curr = x0; df0 = df(x0); iter = 0;
    x_log = [x0];
    while true
        iter = iter + 1;
        x_next = x_curr - f(x_curr)/df0;
        x_log = [x_log x_next];
        if abs(x_next - x_curr) < eps, break; end
        x_curr = x_next;
    end
    res_x = x_next; res_iter = iter; res_time = toc;
end