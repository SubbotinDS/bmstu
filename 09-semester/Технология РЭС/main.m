function main()
warning off;

function cdt=geticon(fp)
    [im,mp,tr]=imread(fp);
    [im,mp]=rgb2ind(im,mp);
    mp(~tr) = NaN;
    cdt=ind2rgb(im,mp);
end

function str=cstr(datas,datap,nm)
    str=struct('Name',nm,...
               'hst',datas,...
               'par',datap);
end

function dstr(str)
    set(hw149,'data',str.hst);
    set(hw140,'data',str.par);
end

function pl_vac()
    for Is=1:length(axs)
        delete(axs(Is));
    end
    axs=[];
    if isempty(rpr)
        tl=0;
        Na=1;
        k=0;
    else
        tl=[0,cumsum(rpr(1,:))];
        Na=length(rpr(1,:))+1;
    end
    Nl=length(strd);
        clr=[[0;0;1],[0;1;0],[1;0;0],[0;1;1],[1;0;1],[1;1;0],[0;0;0]];
    counter=1;
    while length(clr)<Nl
        counter=counter+1;
        clr=[clr,[[0;0;1],[0;1;0],[1;0;0],[0;1;1],[1;0;1],[1;1;0],[1;1;1]]/counter];
    end
    set(hw22,'Max',Na-2);
    for It=1:Na
        ha=axes('Parent',hw2,'Position',[.07+.5*(It-1) .2 .4 .6]);
            xlabel(ha,'Напряжение, В');
            ylabel(ha,'Плотность тока, А/м^2');
            grid on; grid minor;
            title(ha,['Период:' num2str(It-1)]);
        hold on;
        for Is=1:Nl
            Vs=strd{Is}{2};
            Js=strd{Is}{3};
            Vs=Vs(:,It);
            Js=Js(:,It);
            plot(ha,Vs,Js,'Color',clr(:,Is));
        end
        legend(ha,cellfun(@(x) x.Name, strc, 'UniformOutput', false),'Location','best','Interpreter','none');
        axs=[axs,ha];
    end
end

function cb_add(src,event)
    if length(strc{inds}.hst(:,1))==3
        set(hw148,'Enable','on');
    end
    strc{inds}.hst=[strc{inds}.hst;[1 0 0 0]];
    dstr(strc{inds});
end

function cb_del(src,event)
    strc{inds}.hst=strc{inds}.hst(1:end-1,:);
    dstr(strc{inds});
    if length(strc{inds}.hst(:,1))==3
        set(hw148,'Enable','off');
    end
end

function cb_news(src,event)
    if isscalar(strc)
        set(hw146,'Enable','on');
    end
    nums=nums+1;
    hstr=get(hw143,'String');
    hstr(length(hstr)+1)={['Структура ',num2str(nums)]};
    set(hw143,'String',hstr,'Value',length(hstr));
    strc(length(strc)+1)={cstr([50 0 400 0; 2.26 0 0 0; 2.26 1 0 0; 4.52 0 0 0; 2.26 1 0 0; 2.26 0 0 0; 50 0 400 0],[0;0;1;1;100;0;0;1;100;0;1;1000;300],['Структура ',num2str(nums)])};
    inds=length(strc);
    dstr(strc{inds});
end

function cb_cops(src,event)
    if isscalar(strc)
        set(hw146,'Enable','on');
    end
    nm=[strc{inds}.Name,'_копия'];
    hstr=get(hw143,'String');
    hstr=hstr([1:inds,inds:end]);
    hstr{inds+1}=nm;
    set(hw143,'String',hstr,'Value',inds+1);
    strc=strc([1:inds,inds:end]);
    strc{inds+1}.Name=nm;
    inds=inds+1;
    dstr(strc{inds});
end

function cb_dels(src,event)
    strc=strc([1:inds-1,inds+1:end]);
    hstr=get(hw143,'String');
    hstr=hstr([1:inds-1,inds+1:end]);
    inds=inds-1;
    if inds==0 
        inds=1;
    end
    set(hw143,'String',hstr,'Value',inds);
    dstr(strc{inds});
    if isscalar(strc)
        set(hw146,'Enable','off');
    end
end

function cb_nnms(src,event)
    nm=inputdlg('Введите название');
    hstr=get(hw143,'String');
    hstr(inds)=nm;
    set(hw143,'String',hstr);
    strc{inds}.Name=nm{1};
end

function cb_hst(~,event)
    hst=get(hw149,'data');
    strc{inds}.hst=hst;
end

function cb_par(src,event)
    par=get(hw140,'data');
    if par(3)==0
        par(3)=1;
        set(hw140,'data',par);
    end
    if par(4)==0
        par(4)=1;
        set(hw140,'data',par);
    end
    strc{inds}.par=par;
end
    
function cb_chs(src,event)
    inds=get(hw143,'Value');
    dstr(strc{inds});
end

function cb_addr(src,event)
    hsd=get(hw111,'data');
    hsd=[hsd;{1, 'год' ,1, 300}];
    set(hw111,'data',hsd);
end

function cb_delr(src,event)
    hsd=get(hw111,'data');
    hsd=hsd(1:end-1,:);
    set(hw111,'data',hsd);
end

function cb_calc(src,event)
    strd={};
    rpr=get(hw111,'data')';
    if isempty(rpr)
        rpr=[];
    else
    	et=rpr(2,:);
        rpr=cell2mat(rpr([1,3,4],:));
        for Iet=1:length(et)
            switch et{Iet}
                case 'с'
                    et{Iet}=1;
                case 'мин'
                    et{Iet}=60;
                case 'час'
                    et{Iet}=360;
                case 'сутки'
                    et{Iet}=8640;
                case 'год'
                    et{Iet}=3153600;
            end
        end
    end
    ipr=get(hw121,'data');
    ts=0;
    for Ihst=1:length(strc)
        hstnm=strc{Ihst}.Name;
        hst=strc{Ihst}.hst';
        hst(3,:)=hst(3,:)*1E22;
        par=strc{Ihst}.par;
        gpr=[par(1:4);ipr(3:-1:2);par(5:6);ipr(1);par(end)]';
        V=linspace(par(7),par(8),par(9));
        E=linspace(par(10),par(11),par(12));
        [zi,Vs,Js,Ts,Vc,Nc,xdi,ndi,tm]=owns(hst,rpr,gpr,V,E,hstnm,ht1);
        strd{Ihst}={zi,Vs,Js,Ts,Vc,Nc,xdi,ndi,tm};
        ts=ts+sum(tm);
    end
    pl_vac();
    set(hw,'SelectedTab',hw2);
    set(ht1,'String',['Расчёт закончен. Суммарное время - ',num2str(ts),' c']);
end

function cb_sldrvac(src,event)
    for Ia=1:length(axs)
        pos=get(axs(Ia),'Position');
        v=get(src,'Value');
        pos(1)=.07+.5*(Ia-1-v);
        set(axs(Ia),'Position',pos);
    end
end

function cb_bvac(src,event)
    kvac=~kvac;
    if kvac
        set(src,'String','По времени');
    else
        set(src,'String','По структурам');
    end
    pl_vac(kvac);
end

function cb_save(src,event)
    vac = cellfun(@(x) x(2:3), strd, 'UniformOutput', false);
    structures = strc;
    save('data.mat','vac','structures');
end

ic_new=geticon(fullfile(matlabroot,'toolbox','matlab','icons','file_new.png'));
ic_open=geticon(fullfile(matlabroot,'toolbox','matlab','icons','file_open.png'));
ic_save=geticon(fullfile(matlabroot,'toolbox','matlab','icons','file_save.png'));
ic_news=geticon(fullfile(matlabroot,'toolbox','matlab','icons','tool_shape_rectangle.png'));
ic_cops=geticon(fullfile(matlabroot,'toolbox','matlab','icons','tool_plot_linked.png'));
ic_dels=geticon(fullfile(matlabroot,'toolbox','matlab','icons','dialog_warning_16.png'));
ic_calc=geticon(fullfile(matlabroot,'toolbox','matlab','icons','help_gs.png'));

nums=1;
inds=1;
strc={cstr([50 0 400 0; 2.26 0 0 0; 2.26 1 0 0; 4.52 0 0 0; 2.26 1 0 0; 2.26 0 0 0; 50 0 400 0],[0;0;1;1;100;0;0;1;100;0;1;1000;300],'Структура 1')};
strd={};
rpr=[];
axs=[];
kvac=true;

hf=figure('NumberTitle','off','Name','OwnS','MenuBar','none','Position',[300 200 900 500],'Resize','off');
%     hm1=uimenu(hf,'Label','Файл');
%         hm11=uimenu(hm1,'Label','Новый');
%         hm12=uimenu(hm1,'Label','Открыть');
%         hm13=uimenu(hm1,'Label','Сохранить');
%         hm14=uimenu(hm1,'Label','Выход','Separator','on');
%     hm2=uimenu(hf,'Label','Справка');
    hb=uitoolbar(hf);
%         hb1=uipushtool(hb,'CData',ic_new,'ToolTip','Создать новый проект');
%         hb2=uipushtool(hb,'CData',ic_open,'ToolTip','Открыть проект');
        hb3=uipushtool(hb,'CData',ic_save,'ToolTip','Сохранить проект','ClickedCallback',@cb_save);
        hb7=uipushtool(hb,'CData',ic_calc,'ToolTip','Запуск расчёта','ClickedCallback',@cb_calc);
    hw=uitabgroup(hf,'Position',[0 .05 1 .95]);
        hw1=uitab(hw,'Title','Структуры');
            hw11=uipanel(hw1,'Position',[.00 .21 .355 .79],'Title','Режимы');
                hw111=uitable(hw11,'Units','normalized','Position',[.0 .05 1 .95],'ColumnEditable',true,'ColumnName',{'Время','Единицы','Коэффициенты','Tемпература, K'},'ColumnWidth',{39 53 90 90},'ColumnFormat',{'numeric',{'c','мин','час','сутки','год'},'numeric'});
                hw112=uicontrol(hw11,'Style','pushbutton','Units','Normalized','Position',[.0 .0 .5 .07],'CallBack',@cb_addr,'String','Добавить');
                hw113=uicontrol(hw11,'Style','pushbutton','Units','Normalized','Position',[.5 .0 .5 .07],'CallBack',@cb_delr,'String','Удалить');
            hw12=uipanel(hw1,'Position',[.00 .0 .355 .21],'Title','Параметры');
                hw121=uitable(hw12,'RowName',{'Nt','Интервал интегр.','Точность интегр.'},'Data',[100; 1; 1E-35],'Units','normalized','Position',[0 0 1 1],'ColumnEditable',true);
            hw14=uipanel(hw1,'Position',[.355 .0 .645 1],'Title','Редактирование структур');
                hw141=uicontrol(hw14,'Style','pushbutton','Units','normalized','Position',[.00 .92 .69 .06],'String','Добавить структуру','Callback',@cb_news);
                hw142=uicontrol(hw14,'Style','text','Units','normalized','Position',[.7 .81 .12 .1],'String','Структура');
                hw143=uicontrol(hw14,'Style','popupmenu','Units','normalized','Position',[.81 .82 .17 .1],'String',{'Структура 1'},'Callback',@cb_chs);
                hw144=uicontrol(hw14,'Style','pushbutton','Units','Normalized','Position',[.000 .86 .230 .06],'CallBack',@cb_nnms,'String','Переименовать');
                hw145=uicontrol(hw14,'Style','pushbutton','Units','Normalized','Position',[.230 .86 .230 .06],'CallBack',@cb_cops,'String','Копировать');
                hw146=uicontrol(hw14,'Style','pushbutton','Units','Normalized','Position',[.460 .86 .230 .06],'CallBack',@cb_dels,'String','Удалить','Enable','off');
                hw147=uicontrol(hw14,'Style','pushbutton','Units','Normalized','Position',[.000 .80 .345 .06],'CallBack',@cb_add,'String','Добавить слой');
                hw148=uicontrol(hw14,'Style','pushbutton','Units','Normalized','Position',[.345 .80 .345 .06],'CallBack',@cb_del,'String','Удалить слой','Enable','off');
                hw149=uitable(hw14,'Units','normalized','Position',[.00 0 .69 .8],'ColumnEditable',true,'ColumnName',{'Толщина, нм','Доля Al','Nд, 10^22/куб. м', 'Опт. потенциал, В'},'Data',[50 0 400 0; 2.26 0 0 0; 2.26 1 0 0; 4.52 0 0 0; 2.26 1 0 0; 2.26 0 0 0; 50 0 400 0],'ColumnWidth',{79 50 100 110},'CellEditCallback',@cb_hst);
                hw140=uitable(hw14,'Units','normalized','Position',[.69 0 .31 .8],'ColumnEditable',true,'RowName',{'Rs, Ом','gx, эВ*нм','r1','r2','Nz','Ns','Vmin, В','Vmax, В','Nv','Emin, эВ','Emax, эВ','NE','T, K'},'Data',[0;0;1;1;100;0;0;1;100;0;1;1000;300],'ColumnWidth',{73},'CellEditCallback',@cb_par);
        hw2=uitab(hw,'Title','ВАХ');
            hw22=uicontrol(hw2,'Style','Slider','Units','normalized','Position',[0 0.05 1 .04],'Min',0,'Max',0,'Value',0,'SliderStep',[.1 .1],'Callback',@cb_sldrvac);
        % hw3=uitab(hw,'Title','Прозрачность');
        %     hw31=uicontrol(hw3,'Style','Text','Units','normalized','Position',[.77 .85 .1 .1],'String','Структура');
        %     hw32=uicontrol(hw3,'Style','Popupmenu','Units','normalized','Position',[.87 .855 .1 .1],'String',{'1','2','3'});
        %     hw33=uicontrol(hw3,'Style','Text','Units','normalized','Position',[.77 .80 .1 .1],'String','V = 1 В');
        %     hw34=uicontrol(hw3,'Style','Slider','Units','normalized','Position',[.75 .15 .025 .8]);
        %     hw35=axes('Parent',hw3,'Position',[.10 .15 .6 .8]);
        %         xlabel(hw35,'Энергия, эВ');
        %         ylabel(hw35,'Прозрачность');
        % hw4=uitab(hw,'Title','Потенциал');
        %     hw41=uicontrol(hw4,'Style','Text','Units','normalized','Position',[.77 .85 .1 .1],'String','Структура');
        %     hw42=uicontrol(hw4,'Style','Popupmenu','Units','normalized','Position',[.87 .855 .1 .1],'String',{'1','2','3'});
        %     hw43=uicontrol(hw4,'Style','Text','Units','normalized','Position',[.77 .80 .1 .1],'String','V = 1 В');
        %     hw44=uicontrol(hw4,'Style','Slider','Units','normalized','Position',[.75 .15 .025 .8]);
        %     hw45=axes('Parent',hw4,'Position',[.10 .15 .6 .8]);
        %         xlabel(hw45,'Координата, нм');
        %         ylabel(hw45,'Напряжение, В');        
        % hw5=uitab(hw,'Title','Концентрация');
        %     hw51=uicontrol(hw5,'Style','Text','Units','normalized','Position',[.77 .85 .1 .1],'String','Структура');
        %     hw52=uicontrol(hw5,'Style','Popupmenu','Units','normalized','Position',[.87 .855 .1 .1],'String',{'1','2','3'});
        %     hw53=uicontrol(hw5,'Style','Text','Units','normalized','Position',[.77 .80 .1 .1],'String','V = 1 В');
        %     hw54=uicontrol(hw5,'Style','Slider','Units','normalized','Position',[.75 .15 .025 .8]);
        %     hw55=axes('Parent',hw5,'Position',[.10 .15 .6 .8]);
        %         xlabel(hw55,'Координата, нм');
        %         ylabel(hw55,'Напряжение, В');  
        % hw6=uitab(hw,'Title','Анализ ВАХ');
        %     hw61=uibuttongroup(hw6,'Position',[.75 .5 .2 .4],'Title','Отобразить графики');
        %         hw611=uicontrol(hw61,'Style','Radiobutton','Units','normalized','Position',[.1 7/8 .9 1/8],'String','Пиковый ток (+)');
        %         hw612=uicontrol(hw61,'Style','Radiobutton','Units','normalized','Position',[.1 6/8 .9 1/8],'String','Пиковое напряжение (+)');
        %         hw613=uicontrol(hw61,'Style','Radiobutton','Units','normalized','Position',[.1 5/8 .9 1/8],'String','Долинный ток (+)');
        %         hw614=uicontrol(hw61,'Style','Radiobutton','Units','normalized','Position',[.1 4/8 .9 1/8],'String','Долинное напяжение (+)');
        %         hw615=uicontrol(hw61,'Style','Radiobutton','Units','normalized','Position',[.1 3/8 .9 1/8],'String','Пиковый ток (-)');
        %         hw616=uicontrol(hw61,'Style','Radiobutton','Units','normalized','Position',[.1 2/8 .9 1/8],'String','Пиковое напряжение (-)');
        %         hw617=uicontrol(hw61,'Style','Radiobutton','Units','normalized','Position',[.1 1/8 .9 1/8],'String','Долинный ток (-)');
        %         hw618=uicontrol(hw61,'Style','Radiobutton','Units','normalized','Position',[.1 0/8 .9 1/8],'String','Долинное напяжение (-)');
        %     hw62=axes('Parent',hw6,'Position',[.10 .2 .6 .7]);
        %         xlabel(hw62,'Напряжение, В');
        %         ylabel(hw62,'Плотность тока, А/м^2');
    ht=uipanel(hf,'Position',[0 0 1 .05]);
        ht1=uicontrol(ht,'Style','text','Units','normalized','Position',[0 0 1 .9],'String','Готово к расчёту');
        
function [zi,Vs,Js,Ts,Vc,Nc,xdi,ndi,tm]=owns(hst,rpr,gpr,V,E,hstnm,hnd)
    %Константы (в СИ)
    hp=1.054E-34;       %Постоянная Дирака
    qe=1.602E-19;       %Элементарный заряд
    m0=9.109E-31;       %Масса покоя электрона
    eps0=8.85E-12;      %Электрическая постоянная
    kb=1.38E-23;        %Постоянная Больцмана
    Ea=3.5*qe;          %Энергия активации
    D0=0.17;            %Коэффициент диффузии Al при бесконечно большой температуре
    Cr=1/2/pi^2*(2*(0.063*m0)/hp^2)^(3/2);                %Предынтегральный множитель в формуле для концентрации в резервуарах
    %Извлечение параметров
    dl=hst(1,:);
    xl=hst(2,:);
    nl=hst(3,:); 
    wl=hst(4,:);
    if isempty(rpr)
        tp=[];
        kp=[];
        Tp=300;
    else
        tp=rpr(1,:);
        kp=rpr(2,:);
        Tp=rpr(3,:);
    end
    Rs=gpr(1);                   
    gx=gpr(2);                  
    r1=gpr(3);                   
    r2=gpr(4);                   
    itl=gpr(5);
    dei=gpr(6);
    Nz=gpr(7);                 
    Ns=gpr(8);                   
    Nt=gpr(9);
    %Построение массивов
    zl=[0,cumsum(dl)];
    tl=[0,cumsum(tp)];
    Dl=D0*exp(-Ea/kb./Tp).*kp;
    %Перевод в СИ
    zl=zl*1E-9;
    gx=gx*1E-10*qe;
    wl=wl*qe;
    Rs=Rs*1E-12;
    E=E*qe;
    dei=dei*qe;
    %Дно зоны проводимости, эффективная масса и диэлектрическая проницаемость(в AlGaAs)
    eg=@(x)0.79*x*qe;
    ex=@(x)(0.475-0.335*x+0.143*x.^2)*qe;
    mg=@(x)(0.063+0.083*x)*m0;
    mx=@(x)(1.30-0.33*x)*m0;
    ep=@(x)(12.9-2.84*x)*eps0;
    %Прогонка (три диагонали)
    function x=sl3(d,t,b)
        n=length(d);
        x=zeros(1,n);
        for I=1:n-1
            d(I+1)=d(I+1)-t(I)*t(I)/d(I);
            b(I+1)=b(I+1)-b(I)*t(I)/d(I);
        end
        x(n)=b(n)/d(n);
        for I=n-1:-1:1
            x(I)=(b(I)-t(I)*x(I+1))/d(I);
        end
    end
    %Прогонка (пять диагоналей)
    function x=sl5(d,a,t,b)
        n=length(d);
        x=zeros(1,n);
        for I=1:n-2
            d(I+1)=d(I+1)-a(I)*a(I)/d(I);
            a(I+1)=a(I+1)-t(I)*a(I)/d(I);
            b(I+1)=b(I+1)-b(I)*a(I)/d(I);
            d(I+2)=d(I+2)-t(I)*t(I)/d(I);
            b(I+2)=b(I+2)-b(I)*t(I)/d(I);
        end
        d(n)=d(n)-a(n-1)*a(n-1)/d(n-1);
        b(n)=b(n)-b(n-1)*a(n-1)/d(n-1);
        x(n)=b(n)/d(n);
        x(n-1)=(b(n-1)-a(n-1)*x(n))/d(n-1);
        for I=n-2:-1:1
            x(I)=(b(I)-a(I)*x(I+1)-t(I)*x(I+2))/d(I);
        end
    end
    %Функция построения сеток
    function xi=fxi(xl,zl,zi)
        xi=zeros(1,length(zi)-1);
        for I=1:length(zi)-1  
           for K=1:length(xl) 
                ttk1=(zi(I+1)-zl(K))/(zi(I+1)-zi(I));
                ttk2=(zi(I+1)-zl(K+1))/(zi(I+1)-zi(I));
                if ttk1>1 
                    ttk1=1;
                end
                if ttk1<0 
                    ttk1=0;
                end
                if ttk2>1 
                    ttk2=1;
                end
                if ttk2<0 
                    ttk2=0; 
                end
                ttk=ttk1-ttk2;
                xi(I)=xi(I)+xl(K)*ttk;
            end
        end
    end
    %Функция расчёта диффузионных изменений профиля на интервале времени
    function xi=dfsi(D,ti,xi,dz)
        nz=length(xi);
        L=diag(ones(1,nz-1),1)-2*eye(nz)+diag(ones(1,nz-1),-1);
        L=L*D/dz^2;
        L(1,1)=-D/dz^2;
        L(end,end)=-D/dz^2;
        for I=1:length(ti)-1
            xi=xi+L*xi*(ti(I+1)-ti(I));
        end
    end
    %Функция расчёта диффузионных изменений на нескольких интервалах
    function xi=dfs(Dt,tl,x0,dz,Nt)
        xi=zeros(length(tl),length(x0));
        xi(1,:)=x0;
        for I=1:length(tl)-1
            xi(I+1,:)=dfsi(Dt(I),linspace(tl(I),tl(I+1),Nt),xi(I,:)',dz);
        end
    end
    %Функция расчёта уровня Ферми
    function Ef=FindEF(Nd,T)   
        foo=@(E,Ef)sqrt(E)./(1+exp((E-Ef)/kb/T));
        nE=@(Ef)Cr*integral(@(E)foo(E,Ef),0,dei,'AbsTol',itl,'ArrayValued',true);
        nm=@(E)nE(E)-Nd;
        Ef=fzero(nm,0,optimset('MaxFunEvals',Inf,'TolX',itl));
    end
    %Функция расчёта ВАХ
    function [Vs,J,Te,Vc,Nc]=JV(V,E,xi,ni,wi,dz,i1,i2,Ns,T,R,indt)
        kT=kb*T;                                              %Тепловая энергия
        Vr=kT/qe;                                             %Тепловой потенциал
        Ca=sqrt(2)*((0.063*m0)^(3/2))*kT/(((2*pi)^2)*hp^3);   %Предынтегральный множитель в формуле для концентрации в канале
        Cj=0.0315*m0*qe*kT/pi^2/hp^3;                         %Предынтегральный множитель в формуле Цу-Есаки
        Ef=FindEF(ni(1),T);
        n=i2-i1+1;
        egi=[eg(xi(1)),(eg(xi(2:end))+eg(xi(1:end-1)))/2,eg(xi(end))];
        exi=[ex(xi(1)),(ex(xi(2:end))+ex(xi(1:end-1)))/2,ex(xi(end))];
        mgi=mg(xi);
        mxi=mx(xi);
        ei=ep(xi);
        tg=hp^2/2./mgi(i1:i2-1)./dz^2;
        tx=hp^2/2./mxi(i1:i2-1)./dz^2;
        tg1=hp^2/2/mgi(i1-1)./dz^2;
        tx1=hp^2/2/mxi(i1-1)./dz^2;
        tg2=hp^2/2/mgi(i2)./dz^2;
        tx2=hp^2/2/mxi(i2)./dz^2;
        tdg=[tg1,tg(1:end-1)+tg(2:end),tg2];
        tdx=[tx1,tx(1:end-1)+tx(2:end),tx2];
        ai=[0,abs(xi(2:end)-xi(1:end-1)),0]/dz*gx;
        ai=[ai(i1:i2);zeros(1,n)]; ai=reshape(ai,1,2*n);  ai=ai(1:end-1);
        wi=[wi(1),(wi(1:end-1)+wi(2:end))/2,wi(end)]*1i;
        wi=wi(i1:i2);
        ti=[tg;tx]; ti=reshape(ti,1,2*n-2);
        ci=ei/dz^2/qe;
        cd=[1,-ci(1:end-1)-ci(2:end),1];
        ni=[ni(1),(ni(1:end-1)+ni(2:end))/2,ni(end)];
        function res=nz(Vj)
            Ug1=egi(i1)-qe*Vj(i1);
            Ug2=egi(i2)-qe*Vj(i2);
            Un1=egi(1:i1-1)-qe*Vj(1:i1-1);
            Un2=egi(i2+1:end)-qe*Vj(i2+1:end);
            d0=-tdg-egi(i1:i2)+qe*Vj(i1:i2);
            sg=zeros(1,n);
            function Pg=fNz(E)
                Pg=zeros(length(E),n);
                for Ie=1:length(E)
                    f1=real(log(1+exp((Ef-E(Ie)+Un1(1))/kT))./sqrt(E(Ie)-Ug1));
                    f2=real(log(1+exp((Ef-E(Ie)+Un2(end))/kT))./sqrt(E(Ie)-Ug2));
                    k1=sqrt(2*mgi(i1-1)*(E(Ie)-Ug1))/hp;
                    k2=sqrt(2*mgi(i2)*(E(Ie)-Ug2))/hp;
                    sg(1)=-2i*k1*tg1*dz*sqrt(f1);
                    sg(end)=-2i*k2*tg2*dz*sqrt(f2);
                    di=d0+E(Ie);
                    di(1)=di(1)+1i*k1*tg1*dz;
                    di(end)=di(end)+1i*k2*tg2*dz;
                    Pg(Ie,:)=abs(sl3(di,tg,sg)).^2;
                end
            end
            naz=Ca*integral(@(E)fNz(E),min([Ug1,Ug2]),min([Ug1,Ug2])+dei,'AbsTol',itl,'ArrayValued',true);
            nrz1=zeros(1,i1-1);
            nrz2=zeros(1,Nz-i2);
            for K=1:length(Un1)
                foo=@(Ez)sqrt(Ez-Un1(K))./(1+exp((Ez-Un1(1)-Ef)/kT));
                nrz1(K)=Cr*integral(foo,Un1(K),Un1(K)+dei,'AbsTol',itl);
            end
            for K=1:length(Un2)
                foo=@(Ez)sqrt(Ez-Un2(K))./(1+exp((Ez-Un2(end)-Ef)/kT));
                nrz2(K)=Cr*integral(foo,Un2(K),Un2(K)+dei,'AbsTol',itl);
            end
            res=[nrz1,naz,nrz2];
        end
        function T=TE(E,vi,r)
            ug1=egi(i1)-qe*vi(1);
            ux1=exi(i1)-qe*vi(1);
            ug2=egi(i2)-qe*vi(end);
            ux2=exi(i2)-qe*vi(end);
            dg0=-tdg-egi(i1:i2)+qe*vi;
            dx0=-tdx-exi(i1:i2)+qe*vi;
            si=zeros(1,2*n);
            T=zeros(1,length(E));
            for Ie=1:length(E)
                kg1=sqrt(2*mgi(i1-1)*(E(Ie)-ug1))/hp;
                kg2=sqrt(2*mgi(i2)*(E(Ie)-ug2))/hp; 
                kx1=sqrt(2*mxi(i1-1)*(E(Ie)-ux1))/hp;
                kx2=sqrt(2*mxi(i2)*(E(Ie)-ux2))/hp; 
                dgi=dg0+E(Ie);
                dxi=dx0+E(Ie);
                dgi(1)=dgi(1)+1i*kg1*tg1*dz;
                dxi(1)=dxi(1)+1i*kx1*tx1*dz;
                dgi(end)=dgi(end)+1i*kg2*tg2*dz;
                dxi(end)=dxi(end)+1i*kx2*tx2*dz;
                di=[dgi+wi;dxi]; di=reshape(di,1,2*n);
                if r
                    si(2*n-1)=2i*kg2*tg2*dz;
                else
                    si(1)=2i*kg1*tg1*dz;
                end
                pg=sl5(di,ai,ti,si);
                pw=sl3(dgi,tg,-wi.*pg(1:2:end));
                lg=abs(kg1)/mgi(i1-1);
                lx=abs(kx1)/mxi(i1-1);
                rg=abs(kg2)/mgi(i2);
                rx=abs(kx2)/mxi(i2);
                if r
                    Tg=abs(pg(1)).^2*lg/rg*(E(Ie)>ug2);
                    Rg=abs(pg(2*n-1)-1).^2*(E(Ie)>ug2);
                    Tx=abs(pg(2)).^2*lx/rg*(E(Ie)>ux2);
                    Rx=abs(pg(2*n)).^2.*rx./rg*(E(Ie)>ux2);
                    Tw=abs(pw(1)).^2*lg/rg*(E(Ie)>ug2);
                    Rw=abs(pw(n)).^2*(E(Ie)>ug2);
                else
                    Tg=abs(pg(2*n-1)).^2*rg/lg*(E(Ie)>ug1);
                    Rg=abs(pg(1)-1).^2*(E(Ie)>ug1);
                    Tx=abs(pg(2*n)).^2*rx/lg*(E(Ie)>ux1);
                    Rx=abs(pg(2)).^2.*lx./lg*(E(Ie)>ux1);
                    Tw=abs(pw(n)).^2*rg/lg*(E(Ie)>ug1);
                    Rw=abs(pw(1)).^2*(E(Ie)>ug1);
                end
                Tb=Tw./(Tw+Rw);
                Tb(isnan(Tb))=0;
                T(Ie)=Tg+Tx+(1-Tg-Rg-Tx-Rx)*Tb;
            end
        end
        J=zeros(1,length(V));
        Vc=zeros(Nz,length(V));
        Nc=zeros(Nz,length(V));
        Te=zeros(length(E),length(V));
        for Iv=1:length(V)
            vi=[zeros(1,i1-1),linspace(0,V(Iv),n),V(Iv)*ones(1,Nz-i2)];
            for Is=1:Ns
                set(hnd,'String',[hstnm,' - Время: ',num2str(indt),'/',num2str(length(tl)),' Напряжение: ',num2str(Iv),'/',num2str(length(V)),' Самосогласование: ',num2str(Is),'/',num2str(Ns)]); drawnow;
                gi=nz(vi);
                cb=gi(2:end-1).*(1-vi(2:end-1)/Vr)-ni(2:end-1);
                cb(end)=cb(end)-V(Iv)*ci(end);
                vi=[0,sl3(cd(2:end-1)-gi(2:end-1)/Vr,ci(2:end-1),cb),V(Iv)];
            end
            gi=nz(vi);
            TDE=@(E)TE(E,vi(i1:i2),V(Iv)<0).*log((1+exp((egi(i1)-qe*vi(i1)+Ef-E)/kT))./(1+exp((egi(i2)-qe*vi(i2)+Ef-E)/kT)));
            set(hnd,'String',[hstnm,' - T: ',num2str(indt),'/',num2str(length(tl)),' V: ',num2str(Iv),'/',num2str(length(V)),' Вычисление выходных параметров']); drawnow;
            E0=(egi(i1)-qe*vi(i1))*(V(Iv)>=0)+(egi(i2)-qe*vi(i2))*(V(Iv)<0);
            J(Iv)=Cj*integral(TDE,E0,E0+dei,'AbsTol',itl);
            Vc(:,Iv)=vi;
            Nc(:,Iv)=gi;
            Te(:,Iv)=TE(E,vi(i1:i2),V(Iv)<0);
        end
        Vs=V+J*R*100E-12;
    end
    %Построение сеток
    dz=zl(end)/(Nz-1);              %Шаг пространственной сетки
    zi=linspace(0,zl(end),Nz);      %Пространственная сетка (границы интервалов)
    xi=fxi(xl,zl,zi);               %Массив средних долей Al в ячейках сетки
    ni=fxi(nl,zl,zi);               %Массив средних концентраций примесей в ячейках сетки
    wi=fxi(wl,zl,zi);               %Массив средних значений оптического потенциала
    i1=find(zi<zl(1+r1),1,'last');     %Индекс границы канала и левого резервуара (i1-ая ячейка принадлежит каналу)
    i2=find(zi>zl(end-r2),1);           %Индекс границы канала и правого резервуара (i2-ая ячейка принадлежит резервуару)
    Tp=[Tp(1),Tp];
    %Вычисление диффузии
    xdi=dfs(Dl,tl,xi,dz,Nt);
    ndi=dfs(Dl,tl,ni,dz,Nt);
    wdi=dfs(Dl,tl,wi,dz,Nt);
    R = Rs + 25*exp(-qe/2/kb./Tp).*sqrt(tl);
    %Вычисление ВАХ
    Vs=zeros(length(V),length(tl));
    Js=zeros(length(V),length(tl));
    Ts=zeros(length(E),length(V),length(tl));
    Vc=zeros(Nz,length(V),length(tl));
    Nc=zeros(Nz,length(V),length(tl));
    tm=zeros(1,length(tl));
    for Ij=1:length(tl)
        tic; [Vsi,Ji,Tei,Vci,Nci]=JV(V,E,xdi(Ij,:),ndi(Ij,:),wdi(Ij,:),dz,i1,i2,Ns,gpr(end),R(Ij),num2str(Ij)); tmi=toc;
        Vs(:,Ij)=Vsi;
        Js(:,Ij)=Ji;
        Ts(:,:,Ij)=Tei;
        Vc(:,:,Ij)=Vci;
        Nc(:,:,Ij)=Nci;
        tm(Ij)=tmi;
    end
end
  

end