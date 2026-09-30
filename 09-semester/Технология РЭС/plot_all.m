clear; clc; close all;

files = {'VAC_Структура_1_T250K.mat', ...
         'VAC_Структура_1_T300K.mat', ...
         'VAC_Структура_1_T350K.mat'};

clr = lines(numel(files));

figure('Color','w','Position',[200 200 780 540]);
hold on; grid on; grid minor;

Vright = 0;
for k = 1:numel(files)
    S = load(files{k});
    V = S.Vs_s(:,1);
    J = S.Js_s(:,1);

    plot(V, J, 'Color', clr(k,:), 'LineWidth', 1.5, ...
         'DisplayName', sprintf('T = %d K', round(S.T_s)));

    % --- главный пик
    [~, ipk] = max(J);

    % --- зубчик: локальный максимум до главного пика
    Vbef = V(1:ipk);
    Jbef = J(1:ipk);
    islm = find(diff(sign(diff(Jbef)))<0) + 1;   % индексы локальных максимумов
    if ~isempty(islm)
        [~, itooth_rel] = max(Jbef(islm));
        itooth = islm(itooth_rel);
        Vtooth = V(itooth);
    else
        Vtooth = 0;
    end

    Vright = max(Vright, Vtooth);
end

% правая граница — чуть правее самого правого зубчика
xlim([0 Vright + 0.03]);

xlabel('Напряжение, В');
ylabel('Плотность тока, А/м^2');
title('ВАХ РТД при разных температурах');
legend('Location','best');
set(gca,'FontSize',12);