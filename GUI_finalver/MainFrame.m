function varargout = MainFrame(varargin)
% MAINFRAME MATLAB code for MainFrame.fig
%      MAINFRAME, by itself, creates a new MAINFRAME or raises the existing
%      singleton*.
%
%      H = MAINFRAME returns the handle to a new MAINFRAME or the handle to
%      the existing singleton*.
%
%      MAINFRAME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINFRAME.M with the given input arguments.
%
%      MAINFRAME('Property','Value',...) creates a new MAINFRAME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainFrame_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainFrame_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainFrame

% Last Modified by GUIDE v2.5 11-Dec-2023 12:16:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MainFrame_OpeningFcn, ...
    'gui_OutputFcn',  @MainFrame_OutputFcn, ...
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


% --- Executes just before MainFrame is made visible.
function MainFrame_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainFrame (see VARARGIN)

% Choose default command line output for MainFrame
handles.output = hObject;
clc;
handles.videoFilePath = 0;
handles.videoInfo = 0;
handles.videoImgList = 0;
handles.videoStop = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainFrame wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MainFrame_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonPlay.
function pushbuttonPlay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbuttonPause, 'Enable', 'On');
set(handles.pushbuttonPause, 'tag', 'pushbuttonPause', 'String', 'Pause');
set(handles.sliderVideoPlay, 'Max', handles.videoInfo.NumberOfFrames, 'Min', 0, 'Value', 1);
set(handles.editSlider, 'String', sprintf('%d/%d', 0, handles.videoInfo.NumberOfFrames));
for i = 1 : handles.videoInfo.NumberOfFrames
    waitfor(handles.pushbuttonPause,'tag','pushbuttonPause');
    I = imread(fullfile(pwd, ['video_images/',num2str(i),'.jpg']));    
    try
        imshow(I, [], 'Parent', handles.axesVideo);
        set(handles.sliderVideoPlay, 'Value', i);
        set(handles.editSlider, 'String', sprintf('%d/%d', i, handles.videoInfo.NumberOfFrames));
    catch
        return;
    end
    drawnow;
end
set(handles.pushbuttonPause, 'Enable', 'Off');

% --- Executes on button press in pushbuttonOpenVideoFile.
function pushbuttonOpenVideoFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOpenVideoFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
videoFilePath = OpenVideoFile();
if videoFilePath == 0
    return;
end
set(handles.editVideoFilePath, 'String', videoFilePath);
msgbox('Load Video Successful', 'Inbox');
handles.videoFilePath = videoFilePath;
guidata(hObject, handles);


% --- Executes on button press in pushbuttonImageList.
function pushbuttonImageList_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonImageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.videoInfo == 0
    msgbox('Please Get Video Info First', 'Inbox');
    return;
end
Video2Images(handles.videoFilePath);
msgbox('Get Frames Successful', 'Inbox');

% --- Executes on button press in pushbuttonStopCheck.
function pushbuttonStopCheck_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStopCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[s, sx, sy] =  MotionAnalysis();
handles.s = s;
handles.sx = sx;
handles.sy = sy;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbuttonPause.
function pushbuttonPause_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(handles.pushbuttonPause, 'tag');
if strcmp(str, 'pushbuttonPause') == 1
    set(handles.pushbuttonPause, 'tag', 'pushbuttonContinue', 'String', 'Continue');
    pause on;
else
    set(handles.pushbuttonPause, 'tag', 'pushbuttonPause', 'String', 'Pause');
    pause off;
end

% --- Executes on button press in pushbuttonStop.
function pushbuttonStop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axesVideo); cla; axis on; box on;
set(gca, 'XTick', [], 'YTick', [], ...
    'XTickLabel', '', 'YTickLabel', '', 'Color', [0.7020 0.7804 1.0000]);
set(handles.editSlider, 'String', '0/0');
set(handles.sliderVideoPlay, 'Value', 0);
set(handles.pushbuttonPause, 'tag', 'pushbuttonContinue', 'String', 'Continue');
set(handles.pushbuttonPause, 'Enable', 'Off');
set(handles.pushbuttonPause, 'String', 'Pause');


function editFrameNum_Callback(hObject, eventdata, handles)
% hObject    handle to editFrameNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrameNum as text
%        str2double(get(hObject,'String')) returns contents of editFrameNum as a double


% --- Executes during object creation, after setting all properties.
function editFrameNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrameNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFrameWidth_Callback(hObject, eventdata, handles)
% hObject    handle to editFrameWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrameWidth as text
%        str2double(get(hObject,'String')) returns contents of editFrameWidth as a double


% --- Executes during object creation, after setting all properties.
function editFrameWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrameWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFrameHeight_Callback(hObject, eventdata, handles)
% hObject    handle to editFrameHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrameHeight as text
%        str2double(get(hObject,'String')) returns contents of editFrameHeight as a double


% --- Executes during object creation, after setting all properties.
function editFrameHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrameHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFrameRate_Callback(hObject, eventdata, handles)
% hObject    handle to editFrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrameRate as text
%        str2double(get(hObject,'String')) returns contents of editFrameRate as a double


% --- Executes during object creation, after setting all properties.
function editFrameRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editVideoFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to editVideoFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVideoFilePath as text
%        str2double(get(hObject,'String')) returns contents of editVideoFilePath as a double


% --- Executes during object creation, after setting all properties.
function editVideoFilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVideoFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonGetVideoInfo.
function pushbuttonGetVideoInfo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGetVideoInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.videoFilePath == 0
    msgbox('Please Load Video Info First', 'Inbox');
    return;
end
videoInfo = VideoReader(handles.videoFilePath);
handles.videoInfo = videoInfo;
guidata(hObject, handles);
set(handles.editFrameNum, 'String', sprintf('%d', videoInfo.NumberOfFrames));
set(handles.editFrameWidth, 'String', sprintf('%d px', videoInfo.Width));
set(handles.editFrameHeight, 'String', sprintf('%d px', videoInfo.Height));
set(handles.editFrameRate, 'String', sprintf('%d f/s', videoInfo.FrameRate));
set(handles.editDuration, 'String', sprintf('%.1f s', videoInfo.Duration));
set(handles.editVideoFormat, 'String', sprintf('%s', videoInfo.VideoFormat));
msgbox('Get video info successful', 'Inbox');


function editDuration_Callback(hObject, eventdata, handles)
% hObject    handle to editDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDuration as text
%        str2double(get(hObject,'String')) returns contents of editDuration as a double


% --- Executes during object creation, after setting all properties.
function editDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editVideoFormat_Callback(hObject, eventdata, handles)
% hObject    handle to editVideoFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVideoFormat as text
%        str2double(get(hObject,'String')) returns contents of editVideoFormat as a double


% --- Executes during object creation, after setting all properties.
function editVideoFormat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVideoFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSnap.
function pushbuttonSnap_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSnap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SnapImage();

% --- Executes on slider movement.
function sliderVideoPlay_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVideoPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderVideoPlay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVideoPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editSlider_Callback(hObject, eventdata, handles)
% hObject    handle to editSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSlider as text
%        str2double(get(hObject,'String')) returns contents of editSlider as a double


% --- Executes during object creation, after setting all properties.
function editSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editInfo_Callback(hObject, eventdata, handles)
% hObject    handle to editInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editInfo as text
%        str2double(get(hObject,'String')) returns contents of editInfo as a double


% --- Executes during object creation, after setting all properties.
function editInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonExit.
function pushbuttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Confirm to Log out?', ...
    'Logout', ...
    'Confirm','Cancel','Cancel');
switch choice
    case 'Confirm'
        close;
    case 'Cancel'
        return;
end


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Exist_Callback(hObject, eventdata, handles)
% hObject    handle to Exist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Confirm to Log out?', ...
    'Logout', ...
    'Confirm','Cancel','Cancel');
switch choice
    case 'Confirm'
        close;
    case 'Cancel'
        return;
end

% --------------------------------------------------------------------
function About_Callback(hObject, eventdata, handles)
% hObject    handle to About (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = 'Video Filtering';
msgbox(str, 'Inbox');



function edit_videowidth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_videowidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_videowidth as text
%        str2double(get(hObject,'String')) returns contents of edit_videowidth as a double


% --- Executes during object creation, after setting all properties.
function edit_videowidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_videowidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filter_arr=get(handles.popupmenu1,'string');
filter_index=get(handles.popupmenu1,'value');
filter=filter_arr{filter_index};
if  strcmp(filter,"Choose Filter")
    msgbox('Select Filter First', 'Inbox');
end
if strcmp(filter,"Snow")
    Video2Snowflake(handles.videoFilePath);
    msgbox('Select Snow Filter', 'Inbox');
end
if  strcmp(filter, "Cartoon")
    Video2Cartoon(handles.videoFilePath);
    msgbox('Select Cartoon Filter', 'Inbox');
end
if  strcmp(filter, "Sketch")
    Video2Sketch(handles.videoFilePath);
    msgbox('Select Sketch Filter', 'Inbox');
end 
if  strcmp(filter, "Oldfilm")
    Video2OldMovie(handles.videoFilePath);
    msgbox('Select Oldfim Filter', 'Inbox');
end  


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton16.
function pushbutton16_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% framerate = get(handles.editFrameRate, 'value');
framerate=handles.videoInfo.FrameRate;
framenum=handles.videoInfo.NumFrames;
SaveVideo(framerate, framenum);
