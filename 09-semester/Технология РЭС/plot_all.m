clear; clc; close all;

% Имена файлов, сохранённых кнопкой «Сохранить структуру»
sets = { ...
    {'Структура 1.mat', 'Структура 2.mat', 'Структура 3.mat'}, ...
    {'Структура 4.mat', 'Структура 5.mat', 'Структура 6.mat'}, ...
    {'Структура 7.mat', 'Структура 8.mat', 'Структура 9.mat', 'Структура 10.mat'} ...
};

titles = {'ВАХ РТД при разных температурах', ...
          'ВАХ РТД при разных долях алюминия', ...
          'ВАХ РТД при разной толщине барьера'};

% Строки hst, соответствующие двум барьерам (для наборов 2 и 3)
barrier_rows = [5, 7];

% Какой период строить: 0 — исходный (первый столбец), 1 — следующий и т.д.
period_s = 0;
col = period_s + 1;

for s = 1:numel(sets)
    files = sets{s};
    clr = lines(numel(files));

    figure('Color','w','Position',[200+40*s 200-40*s 780 540]);
    hold on; grid on; grid minor;

    for k = 1:numel(files)
        S = load(files{k});

        if ~isfield(S, 'single_structure') || ~isfield(S, 'single_vac') || isempty(S.single_vac)
            error(['Файл "%s": нет сохранённой ВАХ. ' ...
                   'Открой структуру в Final, нажми «Старт», затем «Сохранить структуру».'], files{k});
        end

        st  = S.single_structure;
        vac = S.single_vac;
        Vs = vac{2};
        Js = vac{3};

        if col > size(Vs,2)
            error('Файл "%s": нет периода %d (доступны 0...%d).', ...
                  files{k}, period_s, size(Vs,2)-1);
        end

        V = Vs(:, col);
        J = Js(:, col);

        % --- подпись для легенды ---
        switch s
            case 1
                T_s = st.par(13);
                lbl = sprintf('T = %d K', round(T_s));

            case 2
                % Два барьера — показываем обе доли Al
                x1 = st.hst(barrier_rows(1), 2);
                x2 = st.hst(barrier_rows(2), 2);
                if abs(x1 - x2) < 1e-9
                    lbl = sprintf('x_{Al} = %.2g', x1);
                else
                    lbl = sprintf('x_{Al} = %.2g / %.2g', x1, x2);
                end

            case 3
                % Два барьера — показываем обе толщины
                d1 = st.hst(barrier_rows(1), 1);
                d2 = st.hst(barrier_rows(2), 1);
                if abs(d1 - d2) < 1e-9
                    lbl = sprintf('d_{бар} = %.2g нм', d1);
                else
                    lbl = sprintf('d_{бар} = %.2g / %.2g нм', d1, d2);
                end
        end

        plot(V, J, 'Color', clr(k,:), 'LineWidth', 1.5, 'DisplayName', lbl);
    end

    xlabel('Напряжение, В');
    ylabel('Плотность тока, А/м^2');
    title(titles{s});
    legend('Location','best','Interpreter','tex');
    set(gca,'FontSize',12);
end