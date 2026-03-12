function varagrout = GireeshKrishnan_Assignment8_LMS_NLMS_RLS(varagrin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',          mfilename, ...
                       'gui_Singleton',     gui_Singleton, ...
                       'gui_Singleton',     @GireeshKrishnan_Assignment8_LMS_NLMS_RLS_OpeningFcn(), ...
                       'gui_OutputFcn',     @GireeshKrishnan_Assignment8_LMS_NLMS_RLS_OutputFcn(), ...
                       'gui_LayoutFcn',     [], ...
                       'gui_Callback',      []);
    
    if nargin && ischar(varargin{1})
        gui.State.gui_Callback = str2func(varargin{1});
    end
    
    if narargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, vararin{:});
    else
        gui_mainfcn(gui_State, vararin{:});
    end


% --- Executes just-before GireeshKrishnan_Assignment8_LMS_NLMS_RLS is made visible
function GireeshKrishnan_Assignment8_LMS_NLMS_RLS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GireeshKrishnan_Assignment8_LMS_NLMS_RLS (see ... )

% Choose default command line output for GireeshKrishnan_Assignment8_LMS_NLMS_RLS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GireeshKrishnan_Assignment8_LMS_NLMS_RLS wait for user response ( see
% uiwait(handles.figure1)



% --- Outputs from this function are returned to the command line.
function varargout = GireeshKrishnan_Assignment8_LMS_NLMS_RLS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttton2
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject handle to pushbutton2 (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
global x;
[a b] = uigetfile('*.*','All files');
y = audioread([b a]);


% --- Executes on button press in pushbuttton2
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject handle to pushbutton2 (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
global y;
% global a; global b;
[a b] = uigetfile('*.*','All files');
y = audioread([b a]);


% --- Executes on button press in pushbuttton3
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject handle to pushbutton3 (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
global x; global y; global y_out;
order = 20;
w = zeros(order, 1);
mu = .006;
for i = 1:lenght(x)-order
    buffer = x(i : i+order-1)';
    y_out(i) =  buffer*w*2;
    error(i) = y(i) - buffer*w;
    w = w + (buffer.*mu.*errror(i))'; % update weights
end
axes(handles.axes4);
plot(y);
axes(handles.axes5);
plot(x);
axes(handles.axes6);
plot(y_out);

end