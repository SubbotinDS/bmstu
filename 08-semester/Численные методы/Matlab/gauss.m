%% Метод Гаусса решения СЛАУ. Оценка числа обусловленности матрицы.
% вариант 2
%% Дано: Хорошо обусловленная матрица
clc, clear, close all

A1 = [
        -52.4000         0.0000        -0.5700         4.7300
          0.1200        32.4000         9.0500         0.4900
          0.0000         5.8800      -175.0000         2.4300
         -5.0100        -2.4300         1.8700       -76.2000
    ];
b1 = [-1309.1700; 224.1300; 97.4000; -7800.6200];
x1_exact = [34; 5; 1; 100]; % Точные решения

%% Решение. Хорошо обусловленная матрица

x1 = gauss(A1,b1);

cond_A1_1 = cond(A1,1);
cond_A1_Inf = cond(A1, Inf);

x1_abs_err1 = norm(x1 - x1_exact,1);
x1_abs_errInf = norm(x1 - x1_exact,inf);

x1_rel_err1 = x1_abs_err1 / norm(x1_exact,1);
x1_rel_errInf = x1_abs_errInf / norm(x1_exact,inf);

r1 = b1 - A1*x1;
r1_norm1 = norm(r1,1);
r1_normInf = norm(r1,inf);

%% Вывод результатов для хорошо обусловленной матрицы
fprintf('Хорошо обусловленная матрица\n');
fprintf('Решение x:\n'); disp(x1);
fprintf('Число обусловленности (1-норма): %.4f\n', cond_A1_1);
fprintf('Число обусловленности (Inf-норма): %.4f\n', cond_A1_Inf);
fprintf('Абсолютная ошибка (1-норма): %.4e\n', x1_abs_err1);
fprintf('Абсолютная ошибка (Inf-норма): %.4e\n', x1_abs_errInf);
fprintf('Относительная ошибка (1-норма): %.4e\n', x1_rel_err1);
fprintf('Относительная ошибка (Inf-норма): %.4e\n', x1_rel_errInf);
fprintf('Невязка (1-норма): %.4e\n', r1_norm1);
fprintf('Невязка (Inf-норма): %.4e\n\n', r1_normInf);

%% Дано. Плохо обусловленная матрица

A2 = [
        -558.5500      2569.1600        12.6000        55.8600
        -139.6500       642.3400         3.1500        13.9650
         -19.9500        91.7700         0.4000         1.9950
         838.3900     -3855.9940       -18.9000       -83.7890
    ];
b2 = [127.3100; 31.8150; 2.0450; -190.3990];
x2_exact = [1; 0; 50; 1]; % Точные решения

%% Решение. Плохо обусловленная матрица
x2 = gauss(A2,b2);

cond_A2_1 = cond(A2,1);
cond_A2_Inf = cond(A2, Inf);

x2_abs_err1 = norm(x2 - x2_exact,1);
x2_abs_errInf = norm(x2 - x2_exact,inf);

x2_rel_err1 = x2_abs_err1 / norm(x2_exact,1);
x2_rel_errInf = x2_abs_errInf / norm(x2_exact,inf);

r2 = b2 - A2*x2;
r2_norm1 = norm(r2,1);
r2_normInf = norm(r2,inf);

%% Вывод результатов для плохо обусловленной матрицы
fprintf('Плохо обусловленная матрица\n');
fprintf('Решение x:\n'); disp(x2);
fprintf('Число обусловленности (1-норма): %.4e\n', cond_A2_1);
fprintf('Число обусловленности (Inf-норма): %.4e\n', cond_A2_Inf);
fprintf('Абсолютная ошибка (1-норма): %.4e\n', x2_abs_err1);
fprintf('Абсолютная ошибка (Inf-норма): %.4e\n', x2_abs_errInf);
fprintf('Относительная ошибка (1-норма): %.4e\n', x2_rel_err1);
fprintf('Относительная ошибка (Inf-норма): %.4e\n', x2_rel_errInf);
fprintf('Невязка (1-норма): %.4e\n', r2_norm1);
fprintf('Невязка (Inf-норма): %.4e\n', r2_normInf);

%% functions
function x = gauss(A, b)

n = length(b);
Ab = [A b];
% прямой ход
for k = 1:n-1
    % поиск главного элемента, перестановка
    [~, m] = max(abs(Ab(k:n,k)));
    m = m + k - 1;

    if m ~= k
        temp = Ab(k,:);
        Ab(k,:) = Ab(m,:);
        Ab(m,:) = temp;
    end
    % нормирование
    Ab(k,k:end) = Ab(k,k:end) / Ab(k,k);
    % вычитание
    for i = k+1:n
        Ab(i,k:end) = Ab(i,k:end) - Ab(k,k:end) * Ab(i,k);
    end

end

Ab(n,n:end) = Ab(n,n:end) / Ab(n,n);
% обратный ход
x = zeros(n,1);

for i = n:-1:1
    x(i) = Ab(i,end) - Ab(i,i+1:n) * x(i+1:n);
end

end
