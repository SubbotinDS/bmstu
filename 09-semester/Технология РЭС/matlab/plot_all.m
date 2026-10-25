clear; clc; close all;
% Имена файлов, сохранённых кнопкой «Сохранить структуру»
sets = { ...
    {'T223.mat',  'Default.mat',  'T423.mat'}, ...
    {'Al95.mat',  'Default.mat'}, ...
    {'D1_1.mat',  'Default.mat',  'D1_3.mat'}, ...
    {'D2_1.mat',  'Default.mat',  'D2_3.mat'}, ...
    {'D3_1.mat',  'Default.mat',  'D3_3.mat'}, ...
    {'D4_1.mat',  'Default.mat',  'D4_3.mat'}, ...
    {'D5_1.mat',  'Default.mat',  'D5_3.mat'}, ...
    {'D6_1.mat',  'Default.mat',  'D6_3.mat'}, ...
    {'D7_1.mat',  'Default.mat',  'D7_3.mat'}, ...
    {'D8_1.mat',  'Default.mat',  'D8_3.mat'}, ...
    {'D9_1.mat',  'Default.mat',  'D9_3.mat'}, ...
    {'Default.mat',  'Default.mat',  'Default.mat'}, ...
    {'Imin.mat',  'Default.mat',  'Imax.mat'}, ...
};
titles = {'ВАХ РТД при разных температурах', ...
          'ВАХ РТД при разных долях алюминия', ...
          'ВАХ РТД при разной толщине квантовой ямы', ...
          'ВАХ РТД при разной толщине первого барьера', ...
          'ВАХ РТД при разной толщине второго барьера', ...
          'ВАХ РТД при одинаковом изменении барьеров', ...
          'ВАХ РТД при противоположном изменении барьеров', ...
          'ВАХ РТД при разной толщине первого спейсера', ...
          'ВАХ РТД при разной толщине второго спейсера', ...
          'ВАХ РТД при одинаковом изменении спейсеров', ...
          'ВАХ РТД при противоположном изменении спейсеров', ...
          'ВАХ РТД при разной толщине мезы', ...
          'ВАХ РТД для минимального и максимального тока', ...
};
barrier_rows = [5, 7];
spacer_rows = [4, 8];
% Какой период строить: 0 — исходный (первый столбец), 1 — следующий и т.д.
period_s = 0;
col = period_s + 1;

for s = 1:numel(sets)
    files = sets{s};
    clr = lines(numel(files));
    figure('Color','w','Position',[200+40*s 200-40*s 780 540]);
    hold on; grid on; grid minor;
    
    if s < 13
        sub_title = titles{s}(8:end);
        fprintf('======================================================\n');
        fprintf('Коэффициенты чувствительности%s\n', sub_title);
    else
        fprintf('======================================================\n');
        fprintf('Итоговый технологический разброс (min / nom / max)\n');
    end

    % Массивы для сохранения данных по всем файлам текущего набора
    V_ops = zeros(1, numel(files));
    I_ops = zeros(1, numel(files));
    lbls  = cell(1, numel(files));
    st_all  = cell(1, numel(files));
    
    for k = 1:numel(files)
        S = load(files{k});
        if ~isfield(S, 'single_structure') || ~isfield(S, 'single_vac') || isempty(S.single_vac)
            error(['Файл "%s": нет сохранённой ВАХ. ' ...
                   'Открой структуру в Final, нажми «Старт», затем «Сохранить структуру».'], files{k});
        end
        st  = S.single_structure;
        vac = S.single_vac;
        st_all{k} = st;
        Vs = vac{2};
        Js = vac{3};
        if col > size(Vs,2)
            error('Файл "%s": нет периода %d (доступны 0...%d).', ...
                  files{k}, period_s, size(Vs,2)-1);
        end
        V = Vs(:, col);
        J = Js(:, col);
        
        % --- Расчет тока в зависимости от набора (для 12 и 13 наборов — разная меза) ---
        if s == 12 || s == 13
            switch k
                case 1
                    mesa_d = 9.5e-6;   % минимальная меза (Imin)
                case 2
                    mesa_d = 10.0e-6;  % номинал
                case 3
                    mesa_d = 10.5e-6;  % максимальная меза (Imax)
            end
            I = J * pi * mesa_d^2 / 4 * 1000; % мА
        else
            I = J * pi * (10e-6)^2 / 4 * 1000; % мА
        end
        % -----------------------------------------------------------------------
        
        % --- Поиск рабочей точки: ближайший отсчет к напряжению 0.655 В ---
        target_V = 0.175;
        [~, op_idx] = min(abs(V - target_V));
        
        V_ops(k) = V(op_idx);
        I_ops(k) = I(op_idx);
        % ---------------------------------------------------------------
        
        % --- подпись для легенды ---
        switch s
            case 1
                T_s = st.par(13);
                lbl = sprintf('T = %d K', round(T_s));
            case 2
                x1 = st.hst(barrier_rows(1), 2);
                x2 = st.hst(barrier_rows(2), 2);
                if abs(x1 - x2) < 1e-9
                    lbl = sprintf('x_{Al} = %.2g', x1);
                else
                    lbl = sprintf('x_{Al} = %.2g / %.2g', x1, x2);
                end
            case 3
                lbl = sprintf('d = %.4g нм', st.hst(6, 1));
            case 4
                lbl = sprintf('d = %.4g нм', st.hst(5, 1));
            case 5
                lbl = sprintf('d = %.4g нм', st.hst(7, 1));
            case 6
                d1 = st.hst(barrier_rows(1), 1);
                d2 = st.hst(barrier_rows(2), 1);
                if abs(d1 - d2) < 1e-9
                    lbl = sprintf('d_{бар} = %.4g нм', d1);
                else
                    lbl = sprintf('d_{бар} = %.4g / %.4g нм', d1, d2);
                end
            case 7
                d1 = st.hst(barrier_rows(1), 1);
                d2 = st.hst(barrier_rows(2), 1);
                if abs(d1 - d2) < 1e-9
                    lbl = sprintf('d_{бар} = %.4g нм', d1);
                else
                    lbl = sprintf('d_{бар} = %.4g / %.4g нм', d1, d2);
                end
            case 8
                lbl = sprintf('d = %.4g нм', st.hst(4, 1));
            case 9
                lbl = sprintf('d = %.5g нм', st.hst(8, 1));
            case 10
                d1 = st.hst(spacer_rows(1), 1);
                d2 = st.hst(spacer_rows(2), 1);
                if abs(d1 - d2) < 1e-9
                    lbl = sprintf('d_{сп} = %.4g нм', d1);
                else
                    lbl = sprintf('d_{сп} = %.4g / %.4g нм', d1, d2);
                end
            case 11
                d1 = st.hst(spacer_rows(1), 1);
                d2 = st.hst(spacer_rows(2), 1);
                if abs(d1 - d2) < 1e-9
                    lbl = sprintf('d_{сп} = %.4g нм', d1);
                else
                    lbl = sprintf('d_{сп} = %.4g / %.4g нм', d1, d2);
                end
            case 12
                if k == 1
                    lbl = 'd_{меза} = 9.5 мкм';
                elseif k == 2
                    lbl = 'd_{меза} = 10 мкм';
                else
                    lbl = 'd_{меза} = 10.5 мкм';
                end
            case 13
                if k == 1
                    lbl = 'I_{min}';
                elseif k == 2
                    lbl = 'I_{nom}';
                else
                    lbl = 'I_{max}';
                end
        end
        lbls{k} = lbl;
        
        % Отрисовка
        plot(V, I, 'Color', clr(k,:), 'LineWidth', 1, 'DisplayName', lbl);
        plot(V_ops(k), I_ops(k), 'o', 'Color', clr(k,:), 'MarkerFaceColor', clr(k,:), 'MarkerSize', 5, 'HandleVisibility', 'off');
    end
    
    % Вывод названий графиков в консоль
    for k = 1:numel(files)
        clean_lbl = strrep(strrep(strrep(lbls{k}, '_{', '_'), '}', ''), '\mu{}m', 'мкм');
        fprintf('%s\n', clean_lbl);
    end
    fprintf('------------------------------------------------------\n');
    
    % --- РАСЧЕТ КОНЕЧНЫХ РАЗНОСТЕЙ И ТЕХНОЛОГИЧЕСКОГО РАЗБРОСА ТОКА ---
    switch s
        case 1
            I_minus = I_ops(1); I_0 = I_ops(2); I_plus = I_ops(3);
            x_minus = st_all{1}.par(13); x_0 = st_all{2}.par(13); x_plus = st_all{3}.par(13);
        
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / abs(x_0 - x_minus));
            K_plus  = ((I_plus - I_0)  / I_0) * (x_0 / abs(x_0 - x_plus));
        
            delta_max_exp = abs((I_plus - I_0) / I_0 * 100);
            delta_min_exp = abs((I_minus - I_0) / I_0 * 100);
            I_range_exp = abs(I_plus - I_minus);

            fprintf('I_- (223 K) = %.6g мА\n', I_minus);
            fprintf('I_0   (300 K) = %.6g мА\n', I_0);
            fprintf('I_+ (423 K) = %.6g мА\n', I_plus);
            fprintf('I_max - I_min = %.6g мА\n', I_range_exp);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('K+ = %.4g\n', K_plus);
            fprintf('delta_max (эксп) = %.2f %%\n', delta_max_exp);
            fprintf('delta_min (эксп) = %.2f %%\n', delta_min_exp);
            
        case 2
            % Доля алюминия: только отклонение -5% (0.95)
            I_minus = I_ops(1); I_0 = I_ops(2);
            x_0 = st_all{2}.hst(barrier_rows(1), 2);
            dx = 0.05 * x_0;
            
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / dx);
            delta_minus_tech = (I_minus - I_0) / I_0 * 100;
            
            % Для алюминия I_minus - это максимальный ток (при 0.95), I_0 - минимальный (при 1.0)
            I_range_al = I_minus - I_0; 

            fprintf('I_- (x=0.95)  = %.6g мА\n', I_minus);
            fprintf('I_0 (x=1.00)  = %.6g мА\n', I_0);
            fprintf('I_- - I_0     = %.6g мА\n', I_range_al);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('delta_- (тех) = %+.2f %%\n', delta_minus_tech);
            
        case 3
            I_minus = I_ops(1); I_0 = I_ops(2); I_plus = I_ops(3);
            x_0 = st_all{2}.hst(6, 1);
            dx = 0.283;
            
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / dx);
            K_plus  = ((I_plus - I_0) / I_0) * (x_0 / dx);
            delta_minus_tech = (I_minus - I_0) / I_0 * 100;
            delta_plus_tech  = (I_plus - I_0) / I_0 * 100;
            I_range = I_plus - I_minus;

            fprintf('I_- (-1 слой)  = %.6g мА\n', I_minus);
            fprintf('I_0 (номинал)  = %.6g мА\n', I_0);
            fprintf('I_+ (+1 слой)  = %.6g мА\n', I_plus);
            fprintf('I_+ - I_-     = %.6g мА\n', I_range);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('K+ = %.4g\n', K_plus);
            fprintf('delta_- (тех) = %+.2f %%\n', delta_minus_tech);
            fprintf('delta_+ (тех) = %+.2f %%\n', delta_plus_tech);
            
        case 4
            I_minus = I_ops(1); I_0 = I_ops(2); I_plus = I_ops(3);
            x_0 = st_all{2}.hst(5, 1);
            dx = 0.283;
            
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / dx);
            K_plus  = ((I_plus - I_0) / I_0) * (x_0 / dx);
            delta_minus_tech = (I_minus - I_0) / I_0 * 100;
            delta_plus_tech  = (I_plus - I_0) / I_0 * 100;
            I_range = I_plus - I_minus;

            fprintf('I_- (-1 слой)  = %.6g мА\n', I_minus);
            fprintf('I_0 (номинал)  = %.6g мА\n', I_0);
            fprintf('I_+ (+1 слой)  = %.6g мА\n', I_plus);
            fprintf('I_+ - I_-     = %.6g мА\n', I_range);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('K+ = %.4g\n', K_plus);
            fprintf('delta_- (тех) = %+.2f %%\n', delta_minus_tech);
            fprintf('delta_+ (тех) = %+.2f %%\n', delta_plus_tech);
            
        case 5
            I_minus = I_ops(1); I_0 = I_ops(2); I_plus = I_ops(3);
            x_0 = st_all{2}.hst(7, 1);
            dx = 0.283;
            
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / dx);
            K_plus  = ((I_plus - I_0) / I_0) * (x_0 / dx);
            delta_minus_tech = (I_minus - I_0) / I_0 * 100;
            delta_plus_tech  = (I_plus - I_0) / I_0 * 100;
            I_range = I_plus - I_minus;

            fprintf('I_- (-1 слой)  = %.6g мА\n', I_minus);
            fprintf('I_0 (номинал)  = %.6g мА\n', I_0);
            fprintf('I_+ (+1 слой)  = %.6g мА\n', I_plus);
            fprintf('I_+ - I_-     = %.6g мА\n', I_range);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('K+ = %.4g\n', K_plus);
            fprintf('delta_- (тех) = %+.2f %%\n', delta_minus_tech);
            fprintf('delta_+ (тех) = %+.2f %%\n', delta_plus_tech);

        case 6
            I_minus = I_ops(1); I_0 = I_ops(2); I_plus = I_ops(3);
            x_0 = st_all{2}.hst(barrier_rows(1), 1);
            dx = 0.283 * 2;
            
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / dx);
            K_plus  = ((I_plus - I_0) / I_0) * (x_0 / dx);
            delta_minus_tech = (I_minus - I_0) / I_0 * 100;
            delta_plus_tech  = (I_plus - I_0) / I_0 * 100;
            I_range = I_plus - I_minus;

            fprintf('I_- (совм -)  = %.6g мА\n', I_minus);
            fprintf('I_0 (номинал) = %.6g мА\n', I_0);
            fprintf('I_+ (совм +)  = %.6g мА\n', I_plus);
            fprintf('I_+ - I_-     = %.6g мА\n', I_range);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('K+ = %.4g\n', K_plus);
            fprintf('delta_- (тех) = %+.2f %%\n', delta_minus_tech);
            fprintf('delta_+ (тех) = %+.2f %%\n', delta_plus_tech);
            
        case 7
            I_minus = I_ops(1); I_0 = I_ops(2); I_plus = I_ops(3);
            x_0 = st_all{2}.hst(barrier_rows(1), 1);
            dx = 0.283 * 2;
            
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / dx);
            K_plus  = ((I_plus - I_0) / I_0) * (x_0 / dx);
            delta_minus_tech = (I_minus - I_0) / I_0 * 100;
            delta_plus_tech  = (I_plus - I_0) / I_0 * 100;
            I_range = I_plus - I_minus;

            fprintf('I_- (разн -/+) = %.6g мА\n', I_minus);
            fprintf('I_0 (номинал)  = %.6g мА\n', I_0);
            fprintf('I_+ (разн +/-) = %.6g мА\n', I_plus);
            fprintf('I_+ - I_-      = %.6g мА\n', I_range);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('K+ = %.4g\n', K_plus);
            fprintf('delta_- (тех) = %+.2f %%\n', delta_minus_tech);
            fprintf('delta_+ (тех) = %+.2f %%\n', delta_plus_tech);
            
        case 8
            I_minus = I_ops(1); I_0 = I_ops(2); I_plus = I_ops(3);
            x_0 = st_all{2}.hst(4, 1);
            dx = 0.283;
            
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / dx);
            K_plus  = ((I_plus - I_0) / I_0) * (x_0 / dx);
            delta_minus_tech = (I_minus - I_0) / I_0 * 100;
            delta_plus_tech  = (I_plus - I_0) / I_0 * 100;
            I_range = I_plus - I_minus;

            fprintf('I_- (-1 слой)  = %.6g мА\n', I_minus);
            fprintf('I_0 (номинал)  = %.6g мА\n', I_0);
            fprintf('I_+ (+1 слой)  = %.6g мА\n', I_plus);
            fprintf('I_+ - I_-     = %.6g мА\n', I_range);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('K+ = %.4g\n', K_plus);
            fprintf('delta_- (тех) = %+.2f %%\n', delta_minus_tech);
            fprintf('delta_+ (тех) = %+.2f %%\n', delta_plus_tech);
            
        case 9
            I_minus = I_ops(1); I_0 = I_ops(2); I_plus = I_ops(3);
            x_0 = st_all{2}.hst(8, 1);
            dx = 0.283;
            
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / dx);
            K_plus  = ((I_plus - I_0) / I_0) * (x_0 / dx);
            delta_minus_tech = (I_minus - I_0) / I_0 * 100;
            delta_plus_tech  = (I_plus - I_0) / I_0 * 100;
            I_range = I_plus - I_minus;

            fprintf('I_- (-1 слой)  = %.6g мА\n', I_minus);
            fprintf('I_0 (номинал)  = %.6g мА\n', I_0);
            fprintf('I_+ (+1 слой)  = %.6g мА\n', I_plus);
            fprintf('I_+ - I_-     = %.6g мА\n', I_range);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('K+ = %.4g\n', K_plus);
            fprintf('delta_- (тех) = %+.2f %%\n', delta_minus_tech);
            fprintf('delta_+ (тех) = %+.2f %%\n', delta_plus_tech);
            
        case 10
            I_minus = I_ops(1); I_0 = I_ops(2); I_plus = I_ops(3);
            x_0 = st_all{2}.hst(spacer_rows(1), 1);
            dx = 0.283 * 2;
            
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / dx);
            K_plus  = ((I_plus - I_0) / I_0) * (x_0 / dx);
            delta_minus_tech = (I_minus - I_0) / I_0 * 100;
            delta_plus_tech  = (I_plus - I_0) / I_0 * 100;
            I_range = I_plus - I_minus;

            fprintf('I_- (совм -)  = %.6g мА\n', I_minus);
            fprintf('I_0 (номинал) = %.6g мА\n', I_0);
            fprintf('I_+ (совм +)  = %.6g мА\n', I_plus);
            fprintf('I_+ - I_-     = %.6g мА\n', I_range);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('K+ = %.4g\n', K_plus);
            fprintf('delta_- (тех) = %+.2f %%\n', delta_minus_tech);
            fprintf('delta_+ (тех) = %+.2f %%\n', delta_plus_tech);
            
        case 11
            I_minus = I_ops(1); I_0 = I_ops(2); I_plus = I_ops(3);
            x_0 = st_all{2}.hst(spacer_rows(1), 1);
            dx = 0.283 * 2;
            
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / dx);
            K_plus  = ((I_plus - I_0) / I_0) * (x_0 / dx);
            delta_minus_tech = (I_minus - I_0) / I_0 * 100;
            delta_plus_tech  = (I_plus - I_0) / I_0 * 100;
            I_range = I_plus - I_minus;

            fprintf('I_- (разн -/+) = %.6g мА\n', I_minus);
            fprintf('I_0 (номинал)  = %.6g мА\n', I_0);
            fprintf('I_+ (разн +/-) = %.6g мА\n', I_plus);
            fprintf('I_+ - I_-      = %.6g мА\n', I_range);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('K+ = %.4g\n', K_plus);
            fprintf('delta_- (тех) = %+.2f %%\n', delta_minus_tech);
            fprintf('delta_+ (тех) = %+.2f %%\n', delta_plus_tech);
            
        case 12
            I_minus = I_ops(1); I_0 = I_ops(2); I_plus = I_ops(3);
            x_0 = 10.0;
            dx = 0.05 * x_0;
            
            K_minus = ((I_0 - I_minus) / I_0) * (x_0 / dx);
            K_plus  = ((I_plus - I_0) / I_0) * (x_0 / dx);
            delta_minus_tech = (I_minus - I_0) / I_0 * 100;
            delta_plus_tech  = (I_plus - I_0) / I_0 * 100;
            I_range = I_plus - I_minus;

            fprintf('I_- (9.5 мкм)  = %.6g мА\n', I_minus);
            fprintf('I_0 (10 мкм)   = %.6g мА\n', I_0);
            fprintf('I_+ (10.5 мкм) = %.6g мА\n', I_plus);
            fprintf('I_+ - I_-      = %.6g мА\n', I_range);
            fprintf('K- = %.4g\n', K_minus);
            fprintf('K+ = %.4g\n', K_plus);
            fprintf('delta_- (тех) = %+.2f %%\n', delta_minus_tech);
            fprintf('delta_+ (тех) = %+.2f %%\n', delta_plus_tech);
            
        case 13
            I_min_op = I_ops(1); I_0_tech = I_ops(2); I_max_op = I_ops(3);
            I_tech = I_max_op - I_min_op;
            
            delta_max_tech = (I_max_op - I_0_tech) / I_0_tech * 100;
            delta_min_tech = (I_min_op - I_0_tech) / I_0_tech * 100;

            fprintf('I_min (тех) = %.6g мА\n', I_min_op);
            fprintf('I_0 (тех)   = %.6g мА\n', I_0_tech);
            fprintf('I_max (тех) = %.6g мА\n', I_max_op);
            fprintf('I_max - I_min = %.6g мА\n', I_tech);
            fprintf('delta_max (тех) = %+.2f %%\n', delta_max_tech);
            fprintf('delta_min (тех) = %+.2f %%\n', delta_min_tech);
    end
    
    fprintf('======================================================\n\n'); % Пустая строка для читаемости между графиками
    
    xlabel('Напряжение, В');
    ylabel('Сила тока, мА');
    xlim([0 0.35]);
    title(titles{s});
    legend('Location','best','Interpreter','tex');
    set(gca,'FontSize',12);
end