function varargout = TFMmPAD_GUI_v2(varargin)
% TFMmPAD_GUI_v2 M-file for TFMmPAD_GUI_v2.fig
%      TFMmPAD_GUI_v2, by itself, creates a new TFMmPAD_GUI_v2 or raises the existing
%      singleton*.
%
%      H = TFMmPAD_GUI_v2 returns the handle to a new TFMmPAD_GUI_v2 or the handle to
%      the existing singleton*.
%
%      TFMmPAD_GUI_v2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TFMmPAD_GUI_v2.M with the given input arguments.
%
%      TFMmPAD_GUI_v2('Property','Value',...) creates a new TFMmPAD_GUI_v2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TFMmPAD_GUI_v2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TFMmPAD_GUI_v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TFMmPAD_GUI_v2

% Last Modified by GUIDE v2.5 06-May-2014 13:33:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TFMmPAD_GUI_v2_OpeningFcn, ...
                   'gui_OutputFcn',  @TFMmPAD_GUI_v2_OutputFcn, ...
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


% --- Executes just before TFMmPAD_GUI_v2 is made visible.
function TFMmPAD_GUI_v2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TFMmPAD_GUI_v2 (see VARARGIN)

% Choose default command line output for TFMmPAD_GUI_v2
global allpar hglob dat

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

hglob = handles;

entries={...
    'find centers in current slice',...
    'find centers in stack',...
    'track posts through stack',...
    'refine positions by fit',...
    'refine positions by correlation',...
    'remove systematic drift from stack',...
    'generate force map'...
    };
set(handles.processmenu,'String',entries);
processmenu_Callback(hObject,-1,handles);

%% default parameters for allpar
% parameters for finding center positions
allpar.f1=4;    %smoothing parameter: larger is sharper
allpar.f2=6;    %size for disconnecting
allpar.f3=0.5;  %fraction of area
% parameters for stack processing (unused up to now)
allpar.fs1=0.;
allpar.fs2=0.;
% parameters for connecting
allpar.c1=2;    %connect mode: 1= no gaps, 2= allow gap of 1 frame
allpar.c2=1;    %show progress: 1= yes, 0= no
% parameters for refining center positions by fitting
allpar.r1=0;    %method: 0=radial symmetry, 1=centroid
allpar.r2=0;    %images to use: 0=selected range, 1=top-bottom
% parameters for refining center positions by correlation
allpar.rbc1=0;    %method
allpar.rbc2=0;    %images to use: 0=selected range, 1=top-bottom
% parameters for drift correction
allpar.dc1=1;     %method [0= mean, 1=spline]
allpar.dc2=0.3;   %fraction of posts for 2nd round of refinement
allpar.dc3=1.0;   %color range max [std in pixel]
% parameters for calculating force maps
allpar.force1=0.053; %pixel size [um]
allpar.force2=1.83;  %pillar D [um]
allpar.force3=4.0;   %pillar L [um]
allpar.force4=2.0;   %Young's modulus of PDMS [mPa]
allpar.force5=0;     %method: 0=fit deflection profile, 1=top-bottom
% processmenu entry
allpar.process=1;

% UIWAIT makes TFMmPAD_GUI_v2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TFMmPAD_GUI_v2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;





function directory_Callback(hObject, eventdata, handles)
% hObject    handle to directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of directory as text
%        str2double(get(hObject,'String')) returns contents of directory as a double


% --- Executes during object creation, after setting all properties.
function directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
global dat

id1=get(handles.idmPAD,'String'); % get name of mPAD stacks
id2=get(handles.idActin,'String'); % get name of cell staining

p=get(handles.directory,'String'); % start directory for browsing
pn=uigetdir(p); % open dialog
if pn
    set(handles.directory,'String',pn); % set new directory
    allfiles=dir([pn '\*' id1 '*.tif']); % get file names of mPAD images
    allfiles2=dir([pn '\*' id2 '*.tif']); % get file names of cell stainings
    
    l1=length(allfiles);
    l2=length(allfiles2);
    
    dat.allfiles(1:l1)=allfiles; % combine into the 'allfiles' variable of dat
    dat.allfiles(l1+1:l1+l2)=allfiles2; 
    dat.mode(1:l1)=ones(l1,1); % tag images with 1 (mPAD)
    dat.mode(l1+1:l1+l2)=2*ones(l2,1); % ... or 2 (cell)
    dat.current=1;
    dat.currentslice=1; % added for tiff stacks
    dat.currentchanged=1;
    
    % update the slider for browsing the multipage-TIFFs accordingly
    set(handles.chosepic,'Min',1);
    set(handles.chosepic,'Max',l1);
    set(handles.chosepic,'Value',1);
    set(handles.chosepic,'SliderStep',[1 1]/(l1-1));
    % update display
    set(handles.filename,'String',dat.allfiles(dat.current).name);
    set(handles.filename2,'String',dat.allfiles(dat.current+l1).name);
        
    % determine the size of the stack
    fn1=dat.allfiles(dat.current).name;
    info1=imfinfo([pn '\' fn1]);
    num_images=numel(info1);
    
    % update the slider for browsing the z stack accordingly
    set(handles.slice,'Min',1);
    set(handles.slice,'Max',num_images);
    set(handles.slice,'Value',1);
    set(handles.slice,'SliderStep',[1 1]/(num_images-1));
    % reset info for bottom and top slize
    set(handles.zbottomv,'String','1');
    set(handles.ztopv,'String',num2str(num_images));
    
    dat.stack=import_tiff_stack([pn '\' dat.allfiles(1).name],[pn '\' dat.allfiles(l1+1).name]);
    
    % update display
    plotfig(handles)
    
end


% --- Executes on slider movement when new file is selected.
function chosepic_Callback(hObject, ~, handles)

global dat
dat.current=round(get(hObject,'Value')); % get file number from slider
l1=round(get(hObject,'Max')); % get number of files from slider

% update the filename strings
set(handles.filename,'String',dat.allfiles(dat.current).name);
set(handles.filename2,'String',dat.allfiles(dat.current+l1).name);
p=get(handles.directory,'String');

% determine the size of the stack
fn1=dat.allfiles(dat.current).name;
info1 = imfinfo([p '\' fn1]);
num_images = numel(info1);
    
% update the slider for browsing the z stack accordingly
set(handles.slice,'Min',1);
set(handles.slice,'Max',num_images);
set(handles.slice,'Value',1);
set(handles.slice,'SliderStep',[1 1]/(num_images-1));
% reset info for bottom and top slize
set(handles.zbottomv,'String','1');
set(handles.ztopv,'String',num2str(num_images));

% import image stacks for both channels
dat.stack=import_tiff_stack([p '\' dat.allfiles(dat.current).name],[p '\' dat.allfiles(dat.current+l1).name]);

dat.currentchanged=1;
plotfig(handles)

% --- Executes during object creation, after setting all properties.
function chosepic_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on slider movement when new slice is selected.
function slice_Callback(hObject, eventdata, handles)
global dat
dat.currentslice=round(get(hObject,'Value'));
dat.currentchanged=1;
plotfig(handles)

% --- Executes during object creation, after setting all properties.
function slice_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





% Executes when the slider in mins is moved
function mins_Callback(hObject, eventdata, handles)
minv=get(handles.mins,'Value');
set(handles.minv,'String',num2str(minv));
plotfig(handles)

% Executes when the slider in min2s is moved
function min2s_Callback(hObject, eventdata, handles)
min2v=get(handles.min2s,'Value');
set(handles.min2v,'String',num2str(min2v));
plotfig(handles)

% --- Executes during object creation, after setting all properties.
function mins_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',0);
set(hObject,'Max',1);
set(hObject,'Value',0);

% --- Executes during object creation, after setting all properties.
function min2s_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',0);
set(hObject,'Max',1);
set(hObject,'Value',0);

% --- Executes on slider movement.
function maxs_Callback(hObject, eventdata, handles)
maxv=get(handles.maxs,'Value');
set(handles.maxv,'String',num2str(maxv));
plotfig(handles)

% --- Executes on slider movement.
function max2s_Callback(hObject, eventdata, handles)
max2v=get(handles.max2s,'Value');
set(handles.max2v,'String',num2str(max2v));
plotfig(handles)

% --- Executes during object creation, after setting all properties.
function max2s_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',0);
set(hObject,'Max',1);
set(hObject,'Value',1);

% --- Executes during object creation, after setting all properties.
function maxs_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',0);
set(hObject,'Max',1);
set(hObject,'Value',1);

function minv_Callback(hObject, eventdata, handles)
minv=str2double(get(handles.minv,'String'));
set(handles.mins,'Value', minv);
plotfig(handles);

function minv_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxv_Callback(hObject, eventdata, handles)
maxv=str2double(get(handles.maxv,'String'));
set(handles.maxs,'Value', maxv);
plotfig(handles);

function maxv_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.
function outmeds_Callback(hObject, eventdata, handles)
outmedv=get(handles.outmeds,'Value');
set(handles.outmedv,'String',num2str(outmedv));

% --- Executes during object creation, after setting all properties.
function outmeds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outmeds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',1);
set(hObject,'Max',31);
set(hObject,'Value',9);
set(hObject,'SliderStep',[1 1]/15);

% --- Executes during object creation, after setting all properties.
function outmedv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outmedv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function outmedv_Callback(hObject, eventdata, handles)
% hObject    handle to outmedv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outmedv as text
%        str2double(get(hObject,'String')) returns contents of outmedv as a double
outmedv=str2double(get(handles.outmedv,'String'));
set(handles.outmeds,'Value', outmedv);



% --- Executes on button press in minp.
function minp_Callback(hObject, eventdata, handles)
set(handles.minv,'String','0');
set(handles.mins,'Value', 0);
plotfig(handles);
% --- Executes on button press in maxp.
function maxp_Callback(hObject, eventdata, handles)
set(handles.maxv,'String','1');
set(handles.maxs,'Value', 1);
plotfig(handles);
% --- Executes on button press in min"p.
function min2p_Callback(hObject, eventdata, handles)
set(handles.min2v,'String','0');
set(handles.min2s,'Value', 0);
plotfig(handles);
% --- Executes on button press in max"p.
function max2p_Callback(hObject, eventdata, handles)
set(handles.max2v,'String','1');
set(handles.max2s,'Value', 1);
plotfig(handles);
% --- Executes on button press in auto.
function auto_Callback(hObject, eventdata, handles)
global dat
lh = stretchlim(dat.raw(1));
set(handles.minv,'String', num2str(lh(1)));
set(handles.maxv,'String', num2str(lh(2)));
set(handles.mins,'Value', (lh(1)));
set(handles.maxs,'Value', (lh(2)));
plotfig(handles)
% --- Executes on button press in auto2.
function auto2_Callback(hObject, eventdata, handles)
global dat
lh = stretchlim(dat.raw(2));
set(handles.min2v,'String', num2str(lh(1)));
set(handles.max2v,'String', num2str(lh(2)));
set(handles.min2s,'Value', (lh(1)));
set(handles.max2s,'Value', (lh(2)));
plotfig(handles)



% --- Executes during object creation, after setting all properties.
function throutl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to throutl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','0.0');

% --- Executes during object creation, after setting all properties.
function holesize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to holesize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','1000');

function minobjsiz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minobjsiz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','5000');

% --- Executes during object creation, after setting all properties.
function wghtorig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wghtorig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','5');


% --- Executes during object creation, after setting all properties.
function threshsmall_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshsmall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','10');


% --- Executes during object creation, after setting all properties.
function threshlarge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshlarge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','25');


% --- Executes during object creation, after setting all properties.
function factorotsu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to factorotsu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','1.5');


% --- Executes during object creation, after setting all properties.
function factorotsu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to factorotsu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','1.0');



% --- Executes during object creation, after setting all properties.
function focalsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to focalsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','5');

% --- Executes during object creation, after setting all properties.
function focalotsu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to focalotsu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','1.0');


% --- Executes during object creation, after setting all properties.
function mosnucleus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mosnucleus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','400');


% --- Executes during object creation, after setting all properties.
function sesize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sesize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','7');


% --- Executes during object creation, after setting all properties.
function thrfac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thrfac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','0.2');



% --- Executes during object creation, after setting all properties.
function idActin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to idActin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','w1SPI 491');

% --- Executes during object creation, after setting all properties.
function idActinFib_CreateFcn(hObject, eventdata, handles)
% hObject    handle to idActinFib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','FITC');

% --- Executes during object creation, after setting all properties.
function idmPAD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to idmPAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','w2SPI 561');


% --- Executes on button press in outlines.
function outlines_Callback(hObject, eventdata, handles)
% hObject    handle to outlines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global dat

p=get(handles.directory,'String');
fn=dat.allfiles(dat.current).name;

im=double(dat.raw);
im=im/max(im(:));

[bwout overout] = outlines_func(im, handles);

figure(3)
imagesc(overout)
colormap gray

[p,f,ext]=fileparts([p '\' fn]);
[f p]=uiputfile([p '\' f '_Outline.png']);
if f
   imwrite(bwout,[p '\' f])
end

function [bwout overout] = outlines_func(im, handles)
% hObject    handle to outlines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

imdiff=im*0;
for sig1=[5 7 11 15 19 25 33 41 49] % subtract images with different degrees of blurring
    hg = fspecial('gaussian', 5*sig1+1, sig1);
    imdiff=imdiff+(im-imfilter(im,hg,'replicate'));
end;
wo = str2double(get(handles.wghtorig,'String'));
imdiff=imdiff+wo*(im-mean(im(:))); % remove dim background in dark regions
imdiff=imdiff/(max(imdiff(:)));

fon = str2double(get(handles.throutl,'String'));
level = fon*graythresh(imdiff); %choose threshold not exactly at 0. but a little higher to get rid of connected background pixels
bw0 = im2bw(imdiff, level); %create binary


% attempt to work with rank filters to close gaps in outline
% se = fspecial('disk',9);
% se(se>0) = 1;
% perc = floor(0.9*sum(se(:)));
% imrank = ordfilt2(imdiff,perc,se,'ones');
% se = fspecial('disk',10);
% se(se>0) = 1;
% perc = max(floor(0.1*sum(se(:))),1);
% imrank = ordfilt2(imrank,perc,se,'ones');
% bwrank = im2bw(imrank, 0); %create binary
% bw1 = imfill(bwrank,'holes'); % fill holes
% % some holes where empty spaces between cells; try to get them back again
% mhs = round(str2double(get(handles.holesize,'String')));
% bwholes = bw1-bwrank;
% bwholes = bwareaopen(bwholes,mhs);
% bwrank = bw1-bwholes;

se = strel('disk',5);
bw1 = imopen(bw0,se); % remove thin connected objects
mos = round(str2double(get(handles.minobjsiz,'String')));
bw1 = bwareaopen(bw1,mos); % remove small remaining objects, only centers of cells should remain
bw0 = imreconstruct(bw1,bw0,4); % reconstruct objects based on remaining centers

bw1 = imfill(bw0,'holes'); % fill holes
% some holes where empty spaces between cells; try to get them back again
mhs = round(str2double(get(handles.holesize,'String')));
bwholes = bw1-bw0;
bwholes = bwareaopen(bwholes,mhs);
bw1 = bw1-bwholes;

% marker = imerode(bw1,se);
% bwout = imreconstruct(marker,bwrank);

% figure(2)
% imagesc([bw1 bwrank bwout])
% colormap gray

% 
bw1 = bwmorph(bw1,'clean'); % remove single pixels
dim = round(get(handles.outmeds,'Value'))
bw1 = medfilt2(bw1,[dim dim]); % median filter to smoothen outline without displacing it
mos = round(str2double(get(handles.minobjsiz,'String')));
bw1 = bwareaopen(bw1,mos);
% 
bw2 = bwperim(bw1,4);
overim = max(bw2,im);

bwout = bw1;
overout = overim;


% --- Executes on button press in fibers.
function fibers_Callback(hObject, eventdata, handles)
% hObject    handle to fibers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global dat

p=get(handles.directory,'String');
fn=dat.allfiles(dat.current).name;

im=double(dat.raw);
im=im/max(im(:));

[bw, angle] = fibers_func(im, handles);

figure(3)
imagesc(angle.*bw)
colormap hsv

figure(4)
imagesc(bw)
colormap gray

angleim = exp(2*i*angle).*bw; % 'squared' orientational image: complex representation

% % orientational averaging
% h = fspecial('disk', 15);
% angleimav = imfilter(angleim,h,'replicate');
% % angleimav = imresize(angleimav,1/16);
% maskav = imfilter(bw,h,'replicate');
% % maskav = imresize(maskav,1/16);
% maskav(maskav == 0) = 1.;
% angleav = atan2(imag(angleimav),real(angleimav))/2.;
% orderav = abs(angleimav)./maskav;
% figure(4)
% imagesc(orderav,[0. 1.])
% colormap gray
% figure(3)
% imagesc(angleav)
% colormap hsv

% calculate 2D orientational autocorrelation... pixels that are zero don't
% contribute
[m n] = size(angleim);
border = round(min([m n])*0.3);
% padd on all sides with zeros to prevent artefacts from cyclic FFT
angleimpad = padarray(angleim,border); 
fftang = fft2(angleimpad);
% this essentially gives cos(2*theta) with theta the difference of orientations between 2 pixels
oriautocorr = real(ifft2(fftang.*conj(fftang)));
% center zero distance at image center [mm/2 nn/2] and normalize for radial averaging
[mm nn] = size(oriautocorr);
oriautocorr = circshift(oriautocorr,[mm/2-1 nn/2-1]);
oriautocorr = oriautocorr/max(oriautocorr(:));
% figure(3)
% imagesc(oriautocorr)
% colormap hsv

% take radial average
radav = zeros(1,mm*nn+1);
radnumb = radav;
for k=1:mm
    for l=1:nn
        dd = round(sqrt((k-mm/2)^2+(l-nn/2)^2));
        radav(dd+1) = radav(dd+1)+oriautocorr(k,l);
        radnumb(dd+1) = radnumb(dd+1)+1;
    end
end
radav = radav./radnumb;
figure(5)
semilogx(radav(2:border))

% save as text file
data2write = [(1:border)-1; radav(1:border)];
p=get(handles.directory,'String');
fn=dat.allfiles(dat.current).name;
[p,f,ext]=fileparts([p '\' fn]);
[f p]=uiputfile([p '\' f '_OrderDecay.txt']);
if f
    fid = fopen([p '\' f], 'w');
    fprintf(fid, '%u\t%6.6f\n',data2write);
    fclose(fid);
end

p=get(handles.directory,'String');
fn=dat.allfiles(dat.current).name;
[p,f,ext]=fileparts([p '\' fn]);
[f p]=uiputfile([p '\' f '_Filaments.png']);
if f
   imwrite(bw,[p '\' f])
end

p=get(handles.directory,'String');
fn=dat.allfiles(dat.current).name;
[p,f,ext]=fileparts([p '\' fn]);
[f p]=uiputfile([p '\' f '_Angles.png']);
if f
   anglew=uint16(((angle/pi)+0.5)*65535);
   imwrite(anglew,[p '\' f],'bitdepth',16)
end

function idActin_Callback(hObject, eventdata, handles)
% hObject    handle to idActin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of idActin as text
%        str2double(get(hObject,'String')) returns contents of idActin as a double


function idmPAD_Callback(hObject, eventdata, handles)
% hObject    handle to idmPAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of idmPAD as text
%        str2double(get(hObject,'String')) returns contents of idmPAD as a double


function wghtorig_Callback(hObject, eventdata, handles)
% hObject    handle to wghtorig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wghtorig as text
%        str2double(get(hObject,'String')) returns contents of wghtorig as a double


function throutl_Callback(hObject, eventdata, handles)
% hObject    handle to throutl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of throutl as text
%        str2double(get(hObject,'String')) returns contents of throutl as a double


% --- Executes on button press in zbottomp.
function zbottomp_Callback(hObject, eventdata, handles)
bz=num2str(get(handles.slice,'Value'));
set(handles.zbottomv,'String',bz);


% --- Executes on button press in ztopp.
function ztopp_Callback(hObject, eventdata, handles)
tz=num2str(get(handles.slice,'Value'));
set(handles.ztopv,'String',tz);


function min2v_Callback(hObject, eventdata, handles)
% hObject    handle to min2v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min2v as text
%        str2double(get(hObject,'String')) returns contents of min2v as a double


% --- Executes during object creation, after setting all properties.
function min2v_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min2v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max2v_Callback(hObject, eventdata, handles)
% hObject    handle to max2v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max2v as text
%        str2double(get(hObject,'String')) returns contents of max2v as a double


% --- Executes during object creation, after setting all properties.
function max2v_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max2v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zbottomv_Callback(hObject, eventdata, handles)
% hObject    handle to zbottomv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zbottomv as text
%        str2double(get(hObject,'String')) returns contents of zbottomv as a double


% --- Executes during object creation, after setting all properties.
function zbottomv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zbottomv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ztopv_Callback(hObject, eventdata, handles)
% hObject    handle to ztopv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ztopv as text
%        str2double(get(hObject,'String')) returns contents of ztopv as a double


% --- Executes during object creation, after setting all properties.
function ztopv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ztopv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function image1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate image1


% --- Executes during object creation, after setting all properties.
function image2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate image2


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filename_Callback(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename as text
%        str2double(get(hObject,'String')) returns contents of filename as a double



function filename2_Callback(hObject, eventdata, handles)
% hObject    handle to filename2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename2 as text
%        str2double(get(hObject,'String')) returns contents of filename2 as a double


% --- Executes during object creation, after setting all properties.
function filename2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in processgo.
function processgo_Callback(hObject, eventdata, handles)
global dat allpar hglob
% % get bottom slice of mPAD images
% bs = round(str2num(get(handles.zbottomv,'String')));

switch allpar.process
    
    case 1 %find initial center positions
        %%
        % get current slice of mPAD images
        bs = round(get(hglob.slice,'Value'));
        im = dat.stack(:,:,bs);
        img = double(im);

        % determine approximate pitch in image
        pitch=find_pitch(img);
        display(pitch);
        dat.pitch = pitch;
        
        % determine approximate center positions [pixel]
        [x y] = find_centers_ingmar(img,pitch);
        
        % plot found centers
        figure(7);
        radpost=round(pitch/4.);
        imshow(im, []); title('initial post positions')
        for j=1:length(x)
            rectangle('Position', [x(j)-radpost y(j)-radpost 2*radpost 2*radpost], ...
                'Curvature', [1 1], ...
                'Linewidth', 2.0, 'EdgeColor', [1.0 1.0 0.3]);
        end
       
    case 2 %find initial center positions
        %%
        pitch = dat.pitch;
        
        % follow progress
        progtitle = sprintf('finding centers in stack...  '); 
        progbar = waitbar(0, progtitle);  % will display progress
               
        % determine stack range
        bs = round(str2double(get(hglob.zbottomv,'String')));
        ts = round(str2double(get(hglob.ztopv,'String')));
        
        % finding centers for each image in stack
        % start with first (bottom) slice
        img = double(dat.stack(:,:,bs));
        [x y] = find_centers_ingmar(img,pitch);
        nrows = 8;
        obj = zeros(nrows,length(x));
        obj(1,:) = x;           % x coordinates
        obj(2,:) = y;           % y coordinates
        obj(4,:) = 1:length(x); % ID of points in frame
        obj(5,:) = bs;          % slice number
        waitbar(1/(ts-bs), progbar, progtitle);
        % loop through other images in stack
        for i=bs+1:ts
            img = double(dat.stack(:,:,i));
            [x y] = find_centers_ingmar(img,pitch);
            obji = zeros(nrows,length(x));
            obji(1,:) = x;
            obji(2,:) = y;
            obji(4,:) = 1:length(x);
            obji(5,:) = i;
            obj = [obj obji];
            waitbar((i-bs+1)/(ts-bs), progbar, progtitle);
        end
        close(progbar)
        
        % save into global dat variable
        dat.objinit = obj;
        
        % plot found centers for last slice
        figure(7);
        radpost=round(pitch/4.);
        imshow(img, []); title('initial post positions')
        for j=1:length(x)
            rectangle('Position', [x(j)-radpost ...
                y(j)-radpost 2*radpost 2*radpost], ...
                'Curvature', [1 1], ...
                'Linewidth', 2.0, 'EdgeColor', [1.0 1.0 0.3]);
        end
        
    case 3 %track posts through stack
        %%
        % process parameters
        memory = allpar.c1;
        dispopt = logical(allpar.c2);
        pitch = dat.pitch;

        % get initial positions
        objinit = dat.objinit;
        
        % connect
        objinit = nnlink_rp(objinit, Inf, memory, dispopt);
                
        % throw out tracks that don't span all slices
        tracks_range = unique(objinit(6,:));
        nsl = length(unique(objinit(5,:)));
        for k = tracks_range
            lentrack = sum(objinit(6,:) == k);
            if lentrack < nsl
               cullind = find(objinit(6,:) == k);
               objinit(6, cullind) = 0; % particles with trackid 0 are culled at end
            end
        end
        % now get rid of incomplete posts
        incomplete = find(objinit(6,:) == 0);
        objinit(:, incomplete) = [];
        
        % save into global dat variable
        dat.objinit = objinit;
        
        % plot found tracks
        if dispopt
            figure(7);
            radpost=round(pitch/4.);
            sl = max(objinit(5,:));
            imshow(dat.stack(:,:,sl), []); title('tracked posts')
            for j = unique(objinit(6,:))
                objs_j = objinit(:,objinit(6,:)==j);  % track j
                x = objs_j(1,:);  % x positions of this track
                y = objs_j(2,:);  % y positions of this track
                line(x,y,'Color','r','LineWidth',2);
            end
        end
        
    case 4 %refine positions by fitting
        %%
        % process parameters
        method = allpar.r1;
        imgs2use = allpar.r2;
        pitch = dat.pitch;
        
        % load initial positions
        objinit = dat.objinit;
        
        % determine slices for refinement
        slice_range = unique(objinit(5,:));
        if imgs2use == 1
            slice_range = [slice_range(1) slice_range(end)];
        end
                
        % loop through slices and refine positions
        roisize = round(pitch/2.);
        curr = slice_range(1);   % bottom slice
        img = dat.stack(:,:,curr);
        objs_j = objinit(:,objinit(5,:)==curr);  
        objref = refine_by_fit(img,objs_j,roisize,method);
        for j = 2:length(slice_range)
            curr = slice_range(j);
            img = dat.stack(:,:,curr);
            objs_j = objinit(:,objinit(5,:)==curr); % selected slice
            objs_j = refine_by_fit(img,objs_j,roisize,method);
            objref = [objref objs_j];
        end
        
        % save into global variable
        dat.objref = objref;
        
        % plot refined tracks
        figure(7);
        radpost=floor(pitch/4.);
        sl = slice_range(end);
        imshow(dat.stack(:,:,sl), []); title('refined post tracks')
        for j = unique(objref(6,:))
            objs_j = objref(:,objref(6,:)==j);  % track j
            x = objs_j(1,:);  % x positions of this track
            y = objs_j(2,:);  % y positions of this track
            line(x,y,'Color','r','LineWidth',2);
        end
        
        
    case 5 %refine positions by correlation
        
        %%
        
    case 6 %drift correction
        %%
        % process parameters
        method = allpar.dc1;
        frac4refine = allpar.dc2;
        colormax = allpar.dc3;
        pitch = dat.pitch;
        
        %% load refined positions
        objref = dat.objref;
        
        %% first correct globally (all posts, by mean position)
        trackIDs = unique(objref(6,:));
        objrefdc = drift_correct(objref,trackIDs);

        %% second round: use fraction of posts that showed little movement
        obj_range = unique(objrefdc(6,:));
        obj_std = obj_range.*0.;
        for j = 1:length(obj_range)
            objs_j = objrefdc(:,objrefdc(6,:)==obj_range(j));  % track j
            x = objs_j(1,:);  % x positions of this track
            y = objs_j(2,:);  % y positions of this track
            stdx = std(x);
            stdy = std(y);
            stdxy = sqrt( stdx*stdx + stdy*stdy );
            obj_std(j) = stdxy;
        end
        %fraction of posts with std below cutoff
        std_cutoff = quantile(obj_std,frac4refine);
        objID_still = obj_range(obj_std < std_cutoff);
        %one more round of refinement
        switch method
            case 0 % just by mean per slice
                objrefdc = drift_correct(objrefdc,objID_still);
            case 1 % spline interpolation over stack
                objrefdc = drift_correct_spline(objrefdc,objID_still);
        end
        
        %% save into global variable
        dat.objrefdc = objrefdc;

        %% plot refined tracks and color-coded variance
        figure(7);
        radpost=floor(pitch/4.);
        sl = max(objrefdc(5,:));
        obj_range = unique(objrefdc(6,:));
        obj_std = zeros([1 length(obj_range)]);
        imshow(dat.stack(:,:,sl), []); title('drift corrected post tracks')
        for j = obj_range;
            objs_j = objrefdc(:,objrefdc(6,:)==j);  % track j
            x = objs_j(1,:);  % x positions of this track
            y = objs_j(2,:);  % y positions of this track
            line(x,y,'Color','r','LineWidth',2);
            stdx = std(x);
            stdy = std(y);
            stdxy = sqrt( stdx*stdx + stdy*stdy );
            obj_std(j) = stdxy;
            huevalue = 0.75*(1 - min([stdxy/colormax, 1]));
            rectangle('Position', [x(end)-radpost ...
                y(end)-radpost 2*radpost 2*radpost], ...
                'Curvature', [1 1], ...
                'Linewidth', 2.0, 'EdgeColor', hsv2rgb([huevalue 1 1]));
        end
        
        figure(8)
        xbin = 0.05:0.1:5;
        hist(obj_std,xbin)
        
     
end


% --- Executes on selection change in processmenu.
function processmenu_Callback(hObject, eventdata, handles)
% hObject    handle to processmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global allpar
allpar.process=get(handles.processmenu,'Value');
display(allpar.process);


% --- Executes during object creation, after setting all properties.
function processmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in parprocess.
function parprocess_Callback(hObject, eventdata, handles)
% hObject    handle to parprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global allpar
%display(allpar.process)

switch allpar.process
    case 1 %find centers
        textvar={'smoothing: larger=sharper [2...8]',...
            'size correction for deconnecting posts [1...6]',...
            'fraction of post area for filtering [0.2...0.8]'};
        defans={num2str(allpar.f1),num2str(allpar.f2),num2str(allpar.f3)};
        answer=inputdlg(textvar,'Parameters for initializing post positions',1,defans);
        allpar.f1=str2double(answer(1));
        allpar.f2=str2double(answer(2));
        allpar.f3=str2double(answer(3));
    case 2 %find position in images of stack
        textvar={'par 1 [unused]','par 2 [unused]'};
        defans={num2str(allpar.fs1),num2str(allpar.fs2)};
        answer=inputdlg(textvar,'Parameters for stack processing',1,defans);
        allpar.fs1=str2double(answer(1));
        allpar.fs2=str2double(answer(2));
    case 3 %connect positions
        textvar={'bridging gaps [1=no, 2=yes]','display progress [0=no, 1=yes]'};
        defans={num2str(allpar.c1),num2str(allpar.c2)};
        answer=inputdlg(textvar,'Parameters for connecting',1,defans);
        allpar.c1=str2double(answer(1));
        allpar.c2=str2double(answer(2));        
    case 4 %refine positions by fitting
        textvar={'method [0=radial symmetry, 1=centroid]',...
            'images to use [0=selected, 1=top-bottom]'};
        defans={num2str(allpar.r1),num2str(allpar.r2)};
        answer=inputdlg(textvar,'Parameters for refining post positions by fitting',1,defans);
        allpar.r1=str2double(answer(1));
        allpar.r2=str2double(answer(2));
    case 5 %refine positions by correlation between ROIs
        textvar={'upscaling factor [10...100]',...
            'images to use [0=selected, 1=top-bottom]'};
        defans={num2str(allpar.rbc1),num2str(allpar.rbc2)};
        answer=inputdlg(textvar,'Parameters for refining post positions by correlation',1,defans);
        allpar.rbc1=str2double(answer(1));
        allpar.rbc2=str2double(answer(2));
    case 6 %remove drift from stack
        textvar={'method [0= mean, 1= spline]',...
            'fraction of posts for refinement [0...1]',...
            'color range max [0.5...2]'};
        defans={num2str(allpar.dc1),num2str(allpar.dc2),num2str(allpar.dc3)};
        answer=inputdlg(textvar,'Parameters for drift correction',1,defans);
        allpar.dc1=str2double(answer(1));
        allpar.dc2=str2double(answer(2));
        allpar.dc3=str2double(answer(3));
    case 7 %calculate forces
        textvar={'pixel size [um]','pillar D [um]',...
            'pillar L [um]','Youngs modulus of PDMS [MPa]'};
        defans={num2str(allpar.force1),num2str(allpar.force2),...
            num2str(allpar.force3),num2str(allpar.force4)};
        answer=inputdlg(textvar,'Parameters for calculation of forces',1,defans);
        allpar.force1=str2double(answer(1));
        allpar.force2=str2double(answer(2));
        allpar.force3=str2double(answer(3));
        allpar.force4=str2double(answer(4));
end