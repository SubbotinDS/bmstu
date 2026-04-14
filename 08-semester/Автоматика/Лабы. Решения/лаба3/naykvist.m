clc, clear, close all

% Передаточная функция разомкнутой системы
w = tf([1], [0.05, 0.1, 1, 1, 1]);

T = feedback(w, 1);   % замкнутая система (единичная ОС)

if isstable(T)
    fprintf('Замкнутая система УСТОЙЧИВА\n');
else
    fprintf('Замкнутая система НЕУСТОЙЧИВА\n');
end

figure;
step(w);
title('Переходная функция разомкнутой системы');
grid on;

% Построение годографа по расчетам
MAT = [ 0.1     1       0       0
        0.05    1       0       0
        0       0.1     1       0
        0       0.05    1       0 ];
det([0.1     1       
     0.05    1])
det([0.1     1      0       
     0.05    1      0 
     0       0.1    1])
det(MAT)


syms w
A = 0.05 * w^4 - w^2 + 1;
B = w - 0.1 * w^3;
P = A / (A^2 + B^2)
Q = -B / (A^2 + B^2)

subs(P, w, 0)
subs(Q, w, 0)
format short
w1 = round(double(solve(P == 0, w)), 2)
Im = round(double(subs(Q, w1)), 4)

w2 = round(double(solve(Q == 0, w)), 2)
Re = round(double(subs(P, w2)), 4)

P = [1 0        -0.2500 0      0];
Q = [0 -1.0861  0       0.2576 0];

t = 1:length(P);                 
tt = linspace(1, length(P), 100); 

P_smooth = interp1(t, P, tt, 'spline');
Q_smooth = interp1(t, Q, tt, 'spline');

figure
plot(P_smooth, Q_smooth, '-', P, Q, 'o', -1, 0, '*')
grid on