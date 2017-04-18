function varargout = input_GUI(varargin)
% INPUT_GUI MATLAB code for input_GUI.fig
%      INPUT_GUI, by itself, creates a new INPUT_GUI or raises the existing
%      singleton*.
%
%      H = INPUT_GUI returns the handle to a new INPUT_GUI or the handle to
%      the existing singleton*.
%
%      INPUT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INPUT_GUI.M with the given input arguments.
%
%      INPUT_GUI('Property','Value',...) creates a new INPUT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before input_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to input_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help input_GUI

% Last Modified by GUIDE v2.5 25-Mar-2017 16:52:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @input_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @input_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before input_GUI is made visible.
function input_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to input_GUI (see VARARGIN)

% Choose default command line output for input_GUI
handles.output = hObject;

% Pause button
global state;
state = struct('interrupted',false,'ini_frame',1,'view',2);

% Create GENERAL tab group
handles.tgroup = uitabgroup('Parent',handles.panel_tag ,'TabLocation','top');
handles.tab1 = uitab('Parent',handles.tgroup,'Title','Input Simulation');
handles.tab2 = uitab('Parent',handles.tgroup,'Title','Radiation Model');
handles.tab3 = uitab('Parent',handles.tgroup,'Title','Sensor Configuration');
handles.tab4 = uitab('Parent',handles.tgroup,'Title','Algorithm Configuration');

% Place panels into each tab
set(handles.panel1,'Parent',handles.tab1);
set(handles.panel2,'Parent',handles.tab2);
set(handles.panel3,'Parent',handles.tab3);

% Reposition of each panel to same location as panel 1
set(handles.panel2,'position',get(handles.panel1,'position'));
set(handles.panel3,'position',get(handles.panel1,'position'));

% Create RADIATION MODEL tab group
handles.tgroup_rad = uitabgroup('Parent',handles.panel2,'TabLocation','left');
handles.tab1_rad = uitab('Parent', handles.tgroup_rad,'Title','RF Model');
handles.tab2_rad = uitab('Parent', handles.tgroup_rad,'Title','T Model');
handles.tab3_rad = uitab('Parent', handles.tgroup_rad,'Title','LIDAR Model');

% Place panels into each tab
set(handles.panel_rf,'Parent', handles.tab1_rad);
set(handles.panel_t,'Parent', handles.tab2_rad);
set(handles.panel_lidar, 'Parent', handles.tab3_rad);

% Reposition of panels to same position as panel_rf
set(handles.panel_t, 'position',get(handles.panel_rf,'position'));
set(handles.panel_lidar, 'position', get(handles.panel_rf,'position'));

% Sensor button group
handles.rf_control = uicontrol('Parent',handles.uibuttongroup_sensors,'Style','radio','String','RF','Position',[10 110 50 20]);
handles.lidar_control = uicontrol('Parent',handles.uibuttongroup_sensors,'Style','radio','String','LIDAR','Position',[10 80 50 20]);
handles.t_control = uicontrol('Parent',handles.uibuttongroup_sensors,'Style','radio','String','T','Position',[10 50 50 20]);

% Sensors overview UITABLE
set(handles.uitable_sensors,'ColumnName',{'','Type','X','Y','Active'},'ColumnWidth',{20,58,50,50,57},'Data',[],'ColumnEditable',true(1,5));

% Input simulation - fixing axes parameters
axes(handles.axes1)
grid on
title('Paths of the targets in the monitored area')
xlabel('X')
ylabel('Y')
axis([handles.xmin handles.xmax handles.ymin handles.ymax])

% Radiation model - fixing axes parameters
axes(handles.axes3)
grid on
title('Radiation')
xlabel('X')
ylabel('Y')
axis([handles.xmin handles.xmax handles.ymin handles.ymax])

% Sensor map - fixing axes parameters
axes(handles.axes6)
grid on
title('Sensors Location')
xlabel('X')
ylabel('Y')
axis([handles.xmin handles.xmax handles.ymin handles.ymax])

% Initialization "save file"
handles.saved_sensors = false;

% Update handles structure
guidata(hObject, handles);

uiwait;

% UIWAIT makes input_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = input_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = [ntargets nsteps step_distance mean_distance ]
varargout{1} = 0;

%% Start INPUT and close GUI
% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;

%% Input simulation
function text_targets_Callback(hObject, eventdata, handles)
% hObject    handle to text_targets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - Number of targets 
handles.ntargets = str2double(get(handles.text_targets,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end

% Hints: get(hObject,'String') returns contents of text_targets as text
%        str2double(get(hObject,'String')) returns contents of text_targets as a double


% --- Executes during object creation, after setting all properties.
function text_targets_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_targets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Input - Number of targets 
handles.ntargets = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text_steps_Callback(hObject, eventdata, handles)
% hObject    handle to text_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - Maximum number of steps of a user
handles.nsteps = str2double(get(handles.text_steps,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end

% Hints: get(hObject,'String') returns contents of text_steps as text
%        str2double(get(hObject,'String')) returns contents of text_steps as a double


% --- Executes during object creation, after setting all properties.
function text_steps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Input - Maximum number of steps of a user
handles.nsteps = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_xmin_Callback(hObject, eventdata, handles)
% hObject    handle to text_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - xmin
handles.xmin = str2double(get(handles.text_xmin,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end

% Hints: get(hObject,'String') returns contents of text_xmin as text
%        str2double(get(hObject,'String')) returns contents of text_xmin as a double


% --- Executes during object creation, after setting all properties.
function text_xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Input - xmin
handles.xmin = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text_xmax_Callback(hObject, eventdata, handles)
% hObject    handle to text_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - xmax
handles.xmax = str2double(get(handles.text_xmax,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_xmax as text
%        str2double(get(hObject,'String')) returns contents of text_xmax as a double


% --- Executes during object creation, after setting all properties.
function text_xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Input - xmax
handles.xmax = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to text_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - ymin
handles.ymin = str2double(get(handles.text_ymin,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_ymin as text
%        str2double(get(hObject,'String')) returns contents of text_ymin as a double


% --- Executes during object creation, after setting all properties.
function text_ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Input - ymin
handles.ymin = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to text_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - ymax
handles.ymax = str2double(get(handles.text_ymax,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end

% Hints: get(hObject,'String') returns contents of text_ymax as text
%        str2double(get(hObject,'String')) returns contents of text_ymax as a double

% --- Executes during object creation, after setting all properties.
function text_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Input - ymax
handles.ymax = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_createpaths.
function button_createpaths_Callback(hObject, eventdata, handles)
% hObject    handle to button_createpaths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %% Input
    % Paths that the targets follow inside the considered map
    handles.dimensions = [handles.xmin handles.xmax ; handles.ymin handles.ymax];
    handles.users_path = create_path(handles.ntargets, handles.dimensions, handles.nsteps, handles.step_distance, handles.mean_distance);
    axes(handles.axes1);
    cla
 
    for i = 1:handles.ntargets
        plot(handles.users_path(1,:,i),handles.users_path(2,:,i))
        hold on
    end
    grid on
    title('Paths of the targets in the monitored area')
    xlabel('X')
    ylabel('Y')
    axis([handles.dimensions(1,1) handles.dimensions(1,2) handles.dimensions(2,1) handles.dimensions(2,2)])
    axes(handles.axes6)
    axis([handles.dimensions(1,1) handles.dimensions(1,2) handles.dimensions(2,1) handles.dimensions(2,2)])
    % Update handles structure
    guidata(hObject, handles);


%% Radiation Model
function text_stepdistance_Callback(hObject, eventdata, handles)
% hObject    handle to text_stepdistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Input - step distance in meters [m]
handles.step_distance = str2double(get(handles.text_stepdistance,'String'));

% Update handles structure
guidata(hObject,handles)

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_stepdistance as text
%        str2double(get(hObject,'String')) returns contents of text_stepdistance as a double


% --- Executes during object creation, after setting all properties.
function text_stepdistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_stepdistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%Input - step distance in meters [m]
handles.step_distance = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text_meandistance_Callback(hObject, eventdata, handles)
% hObject    handle to text_meandistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - Average straight distance of a target for modeling the paths
handles.mean_distance = str2double(get(handles.text_meandistance,'String'));

% Update handles structure
guidata(hObject,handles)

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_meandistance as text
%        str2double(get(hObject,'String')) returns contents of text_meandistance as a double


% --- Executes during object creation, after setting all properties.
function text_meandistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_meandistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Input - Average straight distance of a target for modeling the paths
handles.mean_distance = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_amplitude_Callback(hObject, eventdata, handles)
% hObject    handle to text_amplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% RF Radiation Model - Gaussian Amplitude
handles.rf_amplitude = str2double(get(handles.text_amplitude,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createradiation_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_amplitude as text
%        str2double(get(hObject,'String')) returns contents of text_amplitude as a double


% --- Executes during object creation, after setting all properties.
function text_amplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_amplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% RF Radiation Model - Gaussian Amplitude
handles.rf_amplitude = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_calibration_Callback(hObject, eventdata, handles)
% hObject    handle to text_calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% RF Radiation Model - Number of observations during training period (empty
% scenario)
handles.calibration = str2double(get(handles.text_calibration,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createradiation_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_calibration as text
%        str2double(get(hObject,'String')) returns contents of text_calibration as a double


% --- Executes during object creation, after setting all properties.
function text_calibration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% RF Radiation Model - Number of observations during training period (empty
% scenario)
handles.calibration = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_precision_Callback(hObject, eventdata, handles)
% hObject    handle to text_precision (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% RF Radiation Model - Precision of the map in voxels (pixels) per meter 
handles.precision = str2double(get(handles.text_precision,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createradiation_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_precision as text
%        str2double(get(hObject,'String')) returns contents of text_precision as a double


% --- Executes during object creation, after setting all properties.
function text_precision_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_precision (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% RF Radiation Model - Precision of the map in voxels (pixels) per meter 
handles.precision = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_targetwidthx_Callback(hObject, eventdata, handles)
% hObject    handle to text_targetwidthx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% RF Radiation Model - Target width in X axis in meters [m] 
handles.targetwidth_x = str2double(get(handles.text_targetwidthx,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createradiation_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_targetwidthx as text
%        str2double(get(hObject,'String')) returns contents of text_targetwidthx as a double


% --- Executes during object creation, after setting all properties.
function text_targetwidthx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_targetwidthx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% RF Radiation Model - Target width in X axis in meters [m] 
handles.targetwidth_x = str2double(get(hObject,'String'));

% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_targetwidthy_Callback(hObject, eventdata, handles)
% hObject    handle to text_targetwidthy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% RF Radiation Model - Target width in Y axis in meters [m] 
handles.targetwidth_y = str2double(get(handles.text_targetwidthy,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createradiation_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_targetwidthy as text
%        str2double(get(hObject,'String')) returns contents of text_targetwidthy as a double


% --- Executes during object creation, after setting all properties.
function text_targetwidthy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_targetwidthy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% RF Radiation Model - Target width in Y axis in meters [m] 
handles.targetwidth_y = str2double(get(hObject,'String'));

% Update handles structure
guidata(hObject, handles);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_rotation_Callback(hObject, eventdata, handles)
% hObject    handle to text_rotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% RF Radiation Model - Rotation angle of a target in radians 
handles.rotation = str2double(get(handles.text_rotation,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createradiation_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_rotation as text
%        str2double(get(hObject,'String')) returns contents of text_rotation as a double


% --- Executes during object creation, after setting all properties.
function text_rotation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_rotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% RF Radiation Model - Rotation angle of a target in radians 
handles.rotation = str2double(get(hObject,'String'));

% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function text_noiselevel_Callback(hObject, eventdata, handles)
% hObject    handle to text_noiselevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% RF Radiation Model - Noise deviation in the Gaussian function that model
% the radiation for each target (i.e. noiselevel*randn)
handles.noiselevel = str2double(get(handles.text_noiselevel,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createradiation_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_noiselevel as text
%        str2double(get(hObject,'String')) returns contents of text_noiselevel as a double


% --- Executes during object creation, after setting all properties.
function text_noiselevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_noiselevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% RF Radiation Model - Noise deviation in the Gaussian function that model
% the radiation for each target (i.e. noiselevel*randn)
handles.noiselevel = str2double(get(hObject,'String'));

% Update handles structure
guidata(hObject, handles);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_createradiation.
function button_createradiation_Callback(hObject, eventdata, handles)
% hObject    handle to button_createradiation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Parameter Settings
handles.target_width = [handles.targetwidth_x handles.targetwidth_y];
set(handles.text_ok,'Visible','off')
set(handles.button_play2d,'Enable','on')
set(handles.button_play3d,'Enable','on')
tic
% RF radiation
handles.radiation = create_radiation(handles.dimensions, handles.users_path, handles.precision, handles.calibration, handles.rf_amplitude, handles.target_width, handles.rotation, handles.noiselevel );
toc
set(handles.text_ok,'Visible','on')
% Update handles structure
guidata(hObject, handles);
pause(1);
set(handles.text_ok,'Visible','off')


% --- Executes on button press in button_play2d.
function button_play2d_Callback(hObject, eventdata, handles)
% hObject    handle to button_play2d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state;
state.view = 2;
% Radiation movie 2D
set(handles.button_pause,'Enable','on','String','Pause')
set(handles.button_stop,'Enable','on')
axes(handles.axes3);
cla
colorbar('peer', handles.axes3);
plottracking(1, handles.radiation, handles.users_path, handles.dimensions, handles.calibration, 2);
if state.interrupted == 0
    set(handles.button_pause,'Enable','off')
    set(handles.button_stop,'Enable','off')
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in button_play3d.
function button_play3d_Callback(hObject, eventdata, handles)
% hObject    handle to button_play3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state;
state.view = 3;
% Radiation movie 3D
set(handles.button_pause,'Enable','on','String','Pause')
set(handles.button_stop,'Enable','on')

axes(handles.axes3);
cla
plottracking(1, handles.radiation, handles.users_path, handles.dimensions, handles.calibration, 3);
if state.interrupted == 0
    set(handles.button_pause,'Enable','off');
    set(handles.button_stop,'Enable','off');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in button_pause.
function button_pause_Callback(hObject, eventdata, handles)
% hObject    handle to button_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state;
    if state.interrupted
        set(handles.button_pause,'String','Pause');
        plottracking(state.ini_frame, handles.radiation, handles.users_path, handles.dimensions, handles.calibration, state.view);
        if state.interrupted == 0
            set(handles.button_pause,'Enable','off')
        end
    else
        set(handles.button_pause,'String','Continue');
        state.interrupted = true;
    end
% Update handles structure
guidata(hObject, handles);
    
% --- Executes on button press in button_stop.
function button_stop_Callback(hObject, eventdata, handles)
% hObject    handle to button_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state;
state.interrupted = true;
set(handles.button_stop,'Enable','off');
set(handles.button_pause,'Enable','off','String','Pause');
axes(handles.axes3)
cla
% Update handles structure
guidata(hObject, handles);


%% Sensor Configuration

% --- Executes on button press in pushbutton_addsensor.
function pushbutton_addsensor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_addsensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.newsensor_x = str2double(get(handles.text_newsensor_x,'String'));
handles.newsensor_y = str2double(get(handles.text_newsensor_y,'String'));
sensor_types = cellstr(get(handles.popupmenu_sensors,'String'));
handles.selected_sensor = sensor_types{get(handles.popupmenu_sensors,'Value')};
if strcmp(handles.selected_sensor, 'RF')
    sensor_color = 'm';
elseif strcmp(handles.selected_sensor, 'LIDAR')
    sensor_color = 'c';
else
    sensor_color = 'g';
end
axes(handles.axes6)
hold on
plot(handles.newsensor_x, handles.newsensor_y,'x','Color',sensor_color)


% Includes the sensor characteristics in the Table 'Sensors overview'
if sum(size(get(handles.uitable_sensors,'Data'))) == 0
set(handles.uitable_sensors,'Data',[{false},{handles.selected_sensor}, {handles.newsensor_x}, {handles.newsensor_y}, {true}]);
else
set(handles.uitable_sensors,'Data',[get(handles.uitable_sensors,'Data') ; {false},{handles.selected_sensor}, {handles.newsensor_x}, {handles.newsensor_y}, {true}]);
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_loadsensors.
function pushbutton_loadsensors_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadsensors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_clearall.
function button_clearall_Callback(hObject, eventdata, handles)
% hObject    handle to button_clearall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes6)
cla
set(handles.uitable_sensors,'Data',[]);
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in popupmenu_sensors.
function popupmenu_sensors_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sensors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sensor_types = cellstr(get(handles.popupmenu_sensors,'String'));
handles.selected_sensor = sensor_types{get(handles.popupmenu_sensors,'Value')};
% Update handles structure
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sensors contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sensors


% --- Executes during object creation, after setting all properties.
function popupmenu_sensors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sensors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
sensor_types = cellstr(get(hObject,'String'));
handles.selected_sensor = sensor_types{get(hObject,'Value')};
% Update handles structure
guidata(hObject, handles);
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


function text_newsensor_x_Callback(hObject, eventdata, handles)
% hObject    handle to text_newsensor_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.newsensor_x = str2double(get(handles.text_newsensor_x,'String'));
% Update handles structure
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of text_newsensor_x as text
%        str2double(get(hObject,'String')) returns contents of text_newsensor_x as a double
% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    pushbutton_addsensor_Callback(hObject, eventdata, handles);
end

% --- Executes during object creation, after setting all properties.
function text_newsensor_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_newsensor_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% handles    structure with handles and user data (see GUIDATA)
handles.newsensor_x = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_newsensor_y_Callback(hObject, eventdata, handles)
% hObject    handle to text_newsensor_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.newsensor_y = str2double(get(handles.text_newsensor_y,'String'));
% Update handles structure
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of text_newsensor_y as text
%        str2double(get(hObject,'String')) returns contents of text_newsensor_y as a double
% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    pushbutton_addsensor_Callback(hObject, eventdata, handles);
end

% --- Executes during object creation, after setting all properties.
function text_newsensor_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_newsensor_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% handles    structure with handles and user data (see GUIDATA)
handles.newsensor_y = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_addinmap.
function pushbutton_addinmap_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_addinmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes6)
[handles.newsensor_x, handles.newsensor_y] = ginput(1);


if get(handles.rf_control,'Value')
    sensor_color = 'm';
    handles.selected_sensor = get(handles.rf_control,'String');
elseif get(handles.lidar_control,'Value')
    sensor_color = 'c';
    handles.selected_sensor = get(handles.lidar_control,'String');
else
    sensor_color = 'g';
    handles.selected_sensor = get(handles.t_control,'String');
end
hold on
plot(handles.newsensor_x, handles.newsensor_y,'x','Color',sensor_color)


% Includes the sensor characteristics in the Table 'Sensors overview'
if sum(size(get(handles.uitable_sensors,'Data'))) == 0
set(handles.uitable_sensors,'Data',[{false},{handles.selected_sensor}, {handles.newsensor_x}, {handles.newsensor_y}, {true}]);
else
set(handles.uitable_sensors,'Data',[get(handles.uitable_sensors,'Data') ; {false},{handles.selected_sensor}, {handles.newsensor_x}, {handles.newsensor_y}, {true}]);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in button_deletesensors.
function button_deletesensors_Callback(hObject, eventdata, handles)
% hObject    handle to button_deletesensors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sensordata = get(handles.uitable_sensors,'Data');
size_sensordata = size(sensordata);
nsensors = size_sensordata(1);
non_deleted_rows = [];
for sensor = 1:nsensors
    if sensordata{sensor,1} == 0
       non_deleted_rows = [non_deleted_rows sensor];
    end
end
sensordata = sensordata(non_deleted_rows,:);
set(handles.uitable_sensors,'Data',sensordata);

% Update handles structure
guidata(hObject, handles);


function save_filename(hObject, eventdata, handles)
% hObject    handle to button_savesensors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in button_savesensors.
[handles.filename,handles.pathname] = uiputfile({'*.csv','CSV file (*.csv)'},'Saving sensors');
handles.file  = fullfile(handles.pathname,handles.filename);
% Update handles structure
guidata(hObject, handles);

function button_savesensors_Callback(hObject, eventdata, handles)
% hObject    handle to button_savesensors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~(handles.saved_sensors)
    handles.saved_sensors = true;
    pushbutton_saveas_Callback(hObject, eventdata, handles);
else 
  
    file = get(handles.pushbutton_saveas,'UserData');
    fid = fopen(file,'w');
    titles = {'Type','X','Y'};
    fprintf(fid, '%s,',titles{1:1:end-1});
    fprintf(fid, '%s\n', titles{1,end});
    sensordata = get(handles.uitable_sensors,'Data');
    data_size = size(sensordata);
    nsensors = data_size(1);
    for sensor = 1:nsensors
        fprintf(fid,'%s, %.2f, %.2f\n',sensordata{sensor,2:4});
    end
    fclose(fid);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_saveas.
function pushbutton_saveas_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname] = uiputfile({'*.csv','CSV file (*.csv)'},'Saving sensors');
file  = fullfile(pathname,filename);

if ~(isequal(filename,0) || isequal(pathname,0))
    fid = fopen(file,'w');
    titles = {'Type','X','Y'};
    fprintf(fid, '%s,',titles{1:1:end-1});
    fprintf(fid, '%s\n', titles{1,end});
    sensordata = get(handles.uitable_sensors,'Data');
    data_size = size(sensordata);
    nsensors = data_size(1);
    for sensor = 1:nsensors
        fprintf(fid,'%s, %.2f, %.2f\n',sensordata{sensor,2:4});
    end
    fclose(fid);
end
set(handles.text_savename,'String',filename);
set(handles.pushbutton_saveas,'UserData',file);

% Update handles structure
guidata(hObject, handles);


    
