clc;
clear;

a = [1;1;-1;2;-1];              % (поддиагональ заполняется со второго элемента)
b = [60;80;130;-90;140;70];     % (диагональ заполняется полностью)
c = [1;1;-2;1;-1];              % (наддиагональ заполняется без последнего элемента)
d = [6;7;13;-8;15;9];           % правые части

% проверка на примере из лекции
% a = [2; 2];
% b = [2; -4; -3];
% c = [-1;1];
% d = [-1;-8;-14];

disp('3х диагональня матрица и правые части:');
A = diag(b) + diag(a, -1) + diag(c, 1);
disp([A d]);

%% Без возмущений
disp('---------------------------Прогонка для исходных данных:---------------------------');
x = progonka(a, b, c, d);

% Нормы невязки
r = d - A * x;
fprintf('Нормы невязки (1 и inf): %.2e  %.2e\n', norm(r,1), norm(r,inf));


%% Возмущения правой части
fprintf('\n\n---------------------------Прогонка для данных с возмущением----------------------\n');
d_pert = d;
d_pert(1) = d(1) + 0.01;
d_pert(2) = d(2) - 0.01;
d_pert(3) = d(3) + 0.01;

x_p = progonka(a, b, c, d_pert);

% Нормы невязок с возмущениями
r_p = d_pert - A * x_p;
fprintf('Нормы невязки для системы с возмущениями(1 и inf): %.2e  %.2e\n', norm(r_p,1), norm(r_p,inf));


%% Сравнение решений
delta = x_pert - x;
abs_err = abs(delta);
rel_err = abs(delta ./ x);  % предполагаем, что x не содержит нулей

disp('--------------------------- Сравнение решений ---------------------------');
fprintf('Разность (возмущённое – исходное):\n');    disp(delta);
fprintf('Абсолютная погрешность:\n');               disp(abs_err);
fprintf('Относительная погрешность:\n');            disp(rel_err);


%% функция проверки
function is_ok = progonka_valid(a, b, c)
    % Проверка строгого диагонального преобладания для трёхдиагональной матрицы
    n = length(b);
    sums = [abs(c(1)); abs(a(1:n-2)) + abs(c(2:n-1)); abs(a(n-1))];
    is_ok = all(abs(b) > sums);

    if is_ok
        disp('Условие выполнено');
    else
        disp('Условие НЕ выполнено');
    end
end
%% функция прогонки
function x = progonka(a, b, c, d)
    n = length(d);

    if ~progonka_valid(a, b, c)
        return;
    end

    alpha = zeros(n-1,1);
    beta = zeros(n,1);

    % прямой ход
    alpha(1) = -c(1) / b(1);
    beta(1) = d(1) / b(1);
    for i = 2:n-1
        gamma = b(i) + a(i-1) * alpha(i-1);
        alpha(i) = -c(i) / gamma;
        beta(i) = (d(i) - a(i-1) * beta(i-1)) / gamma;
    end
    gamma = b(n) + a(n-1) * alpha(n-1);
    beta(n) = (d(n) - a(n-1) * beta(n-1)) / gamma;

    % обратный ход
    x = zeros(n,1);
    x(n) = beta(n);
    for i = n-1:-1:1
        x(i) = beta(i) + alpha(i) * x(i+1);
    end
    disp('Решение x');              disp(x);
    disp('Коэффициенты альфа');     disp(alpha);
    disp('Коэффициенты бета');      disp(beta);
end




