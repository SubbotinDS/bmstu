% Вариант 2: 2x^3 + x^2 - 6x + 2 = 0, меньший корень
clear; clc; close all;

eps = 0.00001;          %точность
MAX_ITER = 5000;        % максимальное количество итераций (введенное ограничение)

% Уравнения 1 и 2 и их производные:
syms x;
f1_sym = 2^(x - 0.1) - 1;       df1_sym = diff(f1_sym, x);
f1 = matlabFunction(f1_sym);    df1 = matlabFunction(df1_sym);
f2_sym = (x - 0.2)^3;           df2_sym = diff(f2_sym, x);
f2 = matlabFunction(f2_sym);    df2 = matlabFunction(df2_sym);

% Точные решения ур-й 1 и 2:
exact1 = 0.1;
exact2 = 0.2;

%% Решения 1ого ур-я
fprintf('Уравнение №1   точное значение: %d\n', exact1);

[x1, iter1, time1, x_log1] = newton(1, f1, df1, eps);
print_results('1) Метод Ньютона', x1, exact1, iter1, time1);
plot_newton(f1, df1, x_log1, x1, 0, 1, 'Метод Ньютона: 2^{x-0.1} - 1 = 0');

[x1, iter1, time1, x_log1] = newton_simple(1, f1, df1, eps);
print_results('2) Упрощенный Ньютон', x1, exact1, iter1, time1);
plot_newton_simple(f1, df1, x_log1, x1, 0, 1,'Упрощенный Ньютон: 2^{x-0.1} - 1 = 0');

[x1, iter1, time1, x_log1] = secant(0, 1, f1, eps);
print_results('3) Метод секущих', x1, exact1, iter1, time1);
plot_secant(f1, x_log1, x1, 0, 1,'Метод секущих: 2^{x-0.1} - 1 = 0');

[x1, iter1, time1, x_log1, a_log1, b_log1] = bisection(0, 1, f1, eps);
print_results('4) Половинное деление', x1, exact1, iter1, time1);
plot_bisection(f1, x_log1, a_log1, b_log1, x1, 0, 1, 'Половинное деление: 2^{x-0.1} - 1 = 0');
fprintf('-------------------------------------------------------------------------------------------\n');

%% Решения 2ого ур-я
fprintf('Уравнение №2   точное значение: %d\n', exact2);

[x2, iter2, time2, x_log2] = newton(1, f2, df2, eps);
print_results('1) Метод Ньютона', x2, exact2, iter2, time2);
plot_newton(f2, df2, x_log2, x2, 0, 1,'Метод Ньютона: (x-0.2)^3 = 0');

[x2, iter2, time2, x_log2] = newton_simple(1, f2, df2, eps);
print_results('2) Упрощенный Ньютон', x2, exact2, iter2, time2);
plot_newton_simple(f2, df2, x_log2, x2, 0, 1,'Упрощенный Ньютон: (x-0.2)^3 = 0');

[x2, iter2, time2, x_log2] = secant(0, 1, f2, eps);
print_results('3) Метод секущих', x2, exact2, iter2, time2);
plot_secant(f2, x_log2, x2, 0, 1,'Метод секущих: (x-0.2)^3 = 0');

[x2, iter2, time2, x_log2, a_log2, b_log2] = bisection(0, 1, f2, eps);
print_results('4) Половинное деление', x2, exact2, iter2, time2);
plot_bisection(f2, x_log2, a_log2, b_log2, x2, 0, 1, 'Половинное деление: (x-0.2)^3 = 0');
fprintf('-------------------------------------------------------------------------------------------\n');

%% Этот блок для конкретного варианта надо бы подупростить, трудночитаем
% Уравнение из варианта
fprintf('Уравнение из варианта\n');
f3_sym = 2*x^3 + x^2 - 6*x + 2;     df3_sym = diff(f3_sym, x);  ddf3_sym = diff(df3_sym, x);
f3 = matlabFunction(f3_sym);    df3 = matlabFunction(df3_sym);  ddf3 = matlabFunction(ddf3_sym);

% Нахождение истиного значения меньего корня
r = roots([2 1 -6 2]);
r = sort(real(r));
exact3 = r(1);

% локализация корней
L = 10;        % достаточно для полинома
step = 0.1;

X = -L:step:L;
intervals = [];

for i = 1:length(X)-1
    if f3(X(i)) * f3(X(i+1)) < 0
        intervals = [intervals; X(i), X(i+1)];
    end
end

if isempty(intervals)
    error('Корни не найдены');
end

intervals = sortrows(intervals);

disp('Найденные интервалы корней:');
disp(intervals);

% График для визуального анализа корректности найденных интервалов
xx = linspace(-L, L, 1000);

figure;
plot(xx, f3(xx), 'b', 'LineWidth', 2); hold on;
yline(0, 'k--');

title('График функции f(x) = 2x^3 + x^2 - 6x + 2');
xlabel('x'); ylabel('f(x)');
grid on;

% Отметим найденные интервалы
for i = 1:size(intervals,1)
    xi = intervals(i,:);
    plot(xi, f3(xi), 'ro', 'LineWidth', 2);
end

legend('f(x)', 'y=0', 'Интервалы смены знака');


% 2.берем меньший
a = intervals(1,1);
b = intervals(1,2);

fprintf('Интервал для меньшего корня: [%.4f, %.4f]\n', a, b);

% 3. выбор нач. точки (через выпуклость)
if f3(a) * ddf3(a) > 0
    x0 = a;
else
    x0 = b;
end

fprintf('Начальная точка для Ньютона: %.4f\n', x0);

% для секущих
x0_sec = a; x1_sec = b;

% Ньютон
[x3, iter3, time3, xlog3] = newton(x0, f3, df3, eps);
print_results('1) Метод Ньютона', x3, exact3, iter3, time3);
plot_newton(f3, df3, xlog3, x3, a, b, 'Ньютон');

% Упрощенный Ньютон
[x3, iter3, time3, xlog3] = newton_simple(x0, f3, df3, eps);
print_results('2) Упрощенный Ньютон', x3, exact3, iter3, time3);
plot_newton_simple(f3, df3, xlog3, x3, a, b, 'Упрощенный Ньютон');

% Секущие
[x3, iter3, time3, xlog3] = secant(x0_sec, x1_sec, f3, eps);
print_results('3) Метод секущих', x3, exact3, iter3, time3);
plot_secant(f3, xlog3, x3, a, b, 'Секущие');

% Половинное деление
[x3, iter3, time3, xlog3, a_log3, b_log3] = bisection(a, b, f3, eps);
print_results('4) Половинное деление', x3, exact3, iter3, time3);
plot_bisection(f3, xlog3, a_log3, b_log3, x3, a, b, 'Половинное деление');

%% Функции
%% Метод Ньютона
function [res_x, res_iter, res_time, x_log] = newton(x0, f, df, eps)
    tic;
    x_curr = x0; iter = 0;
    x_log = [x_curr];
    while iter < 5000
        iter = iter + 1;
        if abs(df(x_curr)) < 1e-12
            error('Производная близка к нулю');
        end
        x_next = x_curr - f(x_curr)/df(x_curr);
        x_log(end+1) = x_next;
        if abs(x_next - x_curr) < eps, break; end
        x_curr = x_next;
    end
    res_x = x_next; res_iter = iter; res_time = toc;
end

%% Упрощенный метод Ньютона
function [res_x, res_iter, res_time, x_log] = newton_simple(x0, f, df, eps)
    tic;
    x_curr = x0; df0 = df(x0); iter = 0;
    x_log = [x_curr];
    if abs(df0) < 1e-12
        error('Производная в начальной точке близка к нулю');
    end
    while iter < 5000
        iter = iter + 1;
        x_next = x_curr - f(x_curr)/df0;
        x_log(end+1) = x_next;
        if abs(x_next - x_curr) < eps, break; end
        x_curr = x_next;
    end
    res_x = x_next; res_iter = iter; res_time = toc;
end
%% Метод секущих
function [res_x, res_iter, res_time, x_log] = secant(x0, x1, f, eps)
    tic;
    iter = 0; x_prev = x0; x_curr = x1;
    x_log = [x_prev x_curr];

    while iter < 5000
        iter = iter + 1;
        % if abs(f(x_curr) - f(x_prev)) < 1e-12
        %     error('Деление на ноль в методе секущих');
        % end
        x_next = x_curr - (x_curr - x_prev)/(f(x_curr) - f(x_prev)) * f(x_curr);
        x_log(end+1) = x_next;
        if abs(x_next - x_curr) < eps, break; end

        x_prev = x_curr;
        x_curr = x_next;
    end

    res_x = x_next;
    res_iter = iter;
    res_time = toc;
end

%% Метод половинного деления
function [res_x, res_iter, res_time, x_log, a_log, b_log] = bisection(a, b, f, eps)
    tic; iter = 0;
    
    if f(a)*f(b) > 0
        error('Нет смены знака');
    end
    
    x_log = [];
    a_log = [];
    b_log = [];
    
    while iter < 5000
        iter = iter + 1;
        
        x_mid = (a + b)/2;
        
        x_log(end+1) = x_mid;
        a_log(end+1) = a;
        b_log(end+1) = b;
        
        if abs(b - a) < 2*eps
            break;
        end
        
        if f(a)*f(x_mid) <= 0
            b = x_mid;
        else
            a = x_mid;
        end
    end
    
    res_x = (a + b)/2;
    res_iter = iter;
    res_time = toc;
end


%% Геометрические интерпритации
%% Геометрическая интерпритация: Ньютон
function plot_newton(f, df, x_log, x_root, a, b, title_str)
    figure;
    xx = linspace(a, b, 200);
    h1 = plot(xx, f(xx), 'b', 'LineWidth', 2); hold on;
    yline(0, 'k--');
    h2 = plot(x_log, f(x_log), 'ro', 'LineWidth', 1.5);

    % Касательные
    for i = 1:length(x_log)-1
        xk = x_log(i);
        x_next = x_log(i+1);
        t = [xk x_next];
        y_tan = f(xk) + df(xk)*(t - xk);
        h3 = plot(t, y_tan, 'm--');
    end

    h4 = plot(x_root, 0, 'go', 'MarkerSize', 8, 'LineWidth', 2);

    title(title_str);
    xlabel('x');
    ylabel('f(x)');
    grid on;
    
    legend([h1 h2 h3 h4],'f(x)', 'Итерации', 'Касательные', 'Корень');
end

%% Геометрическая интерпретация: упрощенный Ньютон
function plot_newton_simple(f, df, x_log, x_root, a, b, title_str)
    figure;
    xx = linspace(a, b, 200);
    h1 = plot(xx, f(xx), 'b', 'LineWidth', 2); hold on;
    yline(0, 'k--');
    h2 = plot(x_log, f(x_log), 'ro', 'LineWidth', 1.5);

    df0 = df(x_log(1));   % фикс. наклон

    % Параллельные прямые
    for i = 1:length(x_log)-1
        xk = x_log(i);
        x_next = x_log(i+1);
        t = [xk x_next];
        y_line = f(xk) + df0*(t - xk);
        h3 = plot(t, y_line, 'm--');
    end

    h4 = plot(x_root, 0, 'go', 'MarkerSize', 8, 'LineWidth', 2);

    title(title_str);
    xlabel('x');
    ylabel('f(x)');
    grid on;

    legend([h1 h2 h3 h4], 'f(x)', 'Итерации','Параллельные прямые', 'Корень');
end

%% Геометрическая интерпретация: секущие
function plot_secant(f, x_log, x_root, a, b, title_str)
    figure;
    xx = linspace(a, b, 200);
    h1 = plot(xx, f(xx), 'b', 'LineWidth', 2); hold on;
    yline(0, 'k--');
    h2 = plot(x_log, f(x_log), 'ro', 'LineWidth', 1.5);

    % Секущие
    for i = 2:length(x_log)-1
        x_prev = x_log(i-1);
        x_curr = x_log(i);
        t = [x_prev x_curr];
        y_sec = [f(x_prev) f(x_curr)];
        h3 = plot(t, y_sec, 'm--');
    end

    % Корень
    h4 = plot(x_root, 0, 'go', 'MarkerSize', 8, 'LineWidth', 2);

    title(title_str);
    xlabel('x');
    ylabel('f(x)');
    grid on;

    legend([h1 h2 h3 h4],'f(x)', 'Итерации', 'Секущие', 'Корень');
end

%% Геометрическая интерпретация: метод половинного деления
function plot_bisection(f, x_log, a_log, b_log, x_root, a, b, title_str)
    figure;
    xx = linspace(a, b, 200);
    h1 = plot(xx, f(xx), 'b', 'LineWidth', 2); hold on;
    yline(0, 'k--');
    h2 = plot(x_log, f(x_log), 'ro', 'LineWidth', 1.5);
    
    % дуги
    scale0 = max(abs(f(linspace(a, b, 200)))) * 0.3;
    for i = 1:length(a_log)
        a_i = a_log(i);
        b_i = b_log(i);
        center = (a_i + b_i)/2;
        radius = (b_i - a_i)/2;
        t = linspace(0, pi, 50);
        x_arc = center + radius*cos(t);
        y_arc = scale0 * sin(t) / sqrt(i); % было radius*sin(t);
        h3 = plot(x_arc, y_arc, 'm--');
    end

    h4 = plot(x_root, 0, 'go', 'MarkerSize', 8, 'LineWidth', 2);
    
    title(title_str);
    xlabel('x');
    ylabel('f(x)');
    grid on;
    
    legend([h1 h2 h3 h4], 'f(x)', 'Итерации', 'Сужение интервала', 'Корень');
end
%% Функция для вывода результатов:
function print_results(method_name, x, exact, iter, time)
    error = abs(x - exact);
    
    fprintf('%s\n', method_name);
    fprintf('Приближенное значение: %.20f\n', x);
    fprintf('Абсолютная погрешность: %.6e\n', error);
    fprintf('Число итераций: %d\n', iter);
    fprintf('Время работы: %.6f сек\n\n', time);
end









