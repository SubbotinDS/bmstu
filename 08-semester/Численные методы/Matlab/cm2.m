clc;
clear;

a = [1;1;-1;2;-1]; % (поддиагональ заполняется со второго элемента)
b = [60;80;130;-90;140;70]; % (диагональ заполняется полностью)
c = [1;1;-2;1;-1]; % (наддиагональ заполняется без последнего элемента)
d = [6;7;13;-8;15;9]; % правые части

% Проверка применимости метода условием диагонального преобладания

n = length(b);

is_ok = true;
strict = false;

for i = 1:n
    if i == 1
        left = abs(b(i));
        right = abs(c(i));
    elseif i == n
        left = abs(b(i));
        right = abs(a(i-1));
    else
        left = abs(b(i));
        right = abs(a(i-1)) + abs(c(i));
    end
    
    if left < right
        is_ok = false;
    end
    
    fprintf('i=%d: |b|=%.2f, sum=%.2f\n', i, left, right);
end

if is_ok
    disp('Условие выполнено');
else
    disp('Условие НЕ выполнено');
end

n = length(d);
alpha = zeros(n-1, 1);  % Коэффициенты alpha
beta = zeros(n, 1);     % Коэффициенты beta
gamma = zeros(n, 1);   % Коэффициенты gamma

% Алгоритм прямого хода
gamma(1) = b(1);
alpha(1) = -c(1) / gamma(1);
beta(1) = d(1) / gamma(1);

for i = 2:n-1
    gamma(i) = b(i) + a(i-1) * alpha(i-1);
    alpha(i) = -c(i) / gamma(i);
    beta(i) = (d(i) - a(i-1) * beta(i-1)) / gamma(i);
end

% Обработка последнего элемента
gamma(n) = b(n) + a(n-1) * alpha(n-1);
beta(n) = (d(n) - a(n-1) * beta(n-1)) / gamma(n);

% Алгоритм обратного хода
x = zeros(n, 1);
x(n) = beta(n);
for i = n-1:-1:1
   x(i) = beta(i) - alpha(i) * x(i+1);
end

disp('Решение x');
disp(x);
disp('Коэффициенты альфа');
disp(alpha);
disp('Коэффициенты бета');
disp(beta);
disp('Коэффициенты гамма');
disp(gamma);

% Вычисление невязки
Ax = b .* x + [0; a] .* [x(2:end); 0] + [c; 0] .* [0; x(1:end-1)];
r = d - Ax;
% Нормы невязки
norm_1 = norm(r, 1);
norm_inf = norm(r, inf);
disp('Нормы невязки для исходной системы (1 и inf)');
disp(norm_1);
disp(norm_inf);
% Возмущения правой части
d_perturbed = d;
d_perturbed(1) = d_perturbed(1) + 0.01;
d_perturbed(2) = d_perturbed(2) + 0.01;
d_perturbed(3) = d_perturbed(3) - 0.01;
d_perturbed(4) = d_perturbed(4) - 0.01;
% Вычисление с возмущениями
p_alpha = zeros(n-1, 1);
p_beta = zeros(n, 1); 
p_gamma = zeros(n, 1);  

% Алгоритм прямого хода
p_gamma(1) = b(1);
p_alpha(1) = -c(1) / p_gamma(1);
p_beta(1) = d_perturbed(1) / p_gamma(1);

for i = 2:n-1
    p_gamma(i) = b(i) + a(i-1) * p_alpha(i-1);
    p_alpha(i) = -c(i) / p_gamma(i);
    p_beta(i) = (d_perturbed(i) - a(i-1) * p_beta(i-1)) / p_gamma(i);
end

% Обработка последнего элемента
p_gamma(n) = b(n) + a(n-1) * p_alpha(n-1);
p_beta(n) = (d_perturbed(n) - a(n-1) * p_beta(n-1)) / p_gamma(n);

% Алгоритм обратного хода
p_x = zeros(n, 1);
p_x(n) = p_beta(n);
for i = n-1:-1:1
   p_x(i) = p_beta(i) - p_alpha(i) * p_x(i+1);
end

disp('Решение x с возмущениями');
disp(p_x);
disp('Коэффициенты альфа с возмущениями');
disp(p_alpha);
disp('Коэффициенты бета с возмущениями');
disp(p_beta);
disp('Коэффициенты гамма с возмущениями');
disp(p_gamma);
% Вычисление возмущенной невязки
p_Ax = b .* p_x + [0; a] .* [p_x(2:end); 0] + [c; 0] .* [0; p_x(1:end-1)];
r_p = d_perturbed - p_Ax;

% Нормы невязки с возмущениями
norm_1_p = norm(r_p, 1);
norm_inf_p = norm(r_p, inf);
disp('Нормы невязки для системы с возмущениями(1 и inf)');
disp(norm_1_p);
disp(norm_inf_p);
%Вычисление разницы между возмущенной системой и нет
difference = x - p_x;
disp('Разница между решениями:');
disp(difference);

% Вычисление абсолютной и относительной погрешности
absolute_error = abs(difference);  % Абсолютная погрешность
relative_error = abs(difference ./ x);  % Относительная погрешность

disp('Абсолютная погрешность:');
disp(absolute_error);

disp('Относительная погрешность:');
disp(relative_error);