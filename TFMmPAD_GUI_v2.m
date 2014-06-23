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

% Last Modified by GUIDE v2.5 20-Jun-2014 14:06:26

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

%%
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
    'define cell outlines',...
    'remove systematic drift from stack',...
    'calculate forces and directions',...
    'output cell statistics'...
    };
set(handles.processmenu,'String',entries);
processmenu_Callback(hObject,-1,handles);

entries={...
    'mPAD',...
    'image'...
    };
set(handles.experimentmenu,'String',entries);
experimentmenu_Callback(hObject,-1,handles);

entries={...
    '#2',...
    '#3 (hard)',...
    '#5',...
    '#7 (medium)',...
    '#9',...
    '#11 (soft)',...
    '#12'...
    };
set(handles.mpadmenu,'String',entries);
mpadmenu_Callback(hObject,-1,handles);

% default parameters for allpar
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
allpar.dc1=1;     %method [0= of all posts, 1= exclude cell]
allpar.dc2=0.7;   %fraction of posts for 2nd round of refinement
allpar.dc3=1.0;   %color range max [std in pixel]
% parameters for calculating force maps
allpar.force1=0;     %method: 0=spline fit, 1=exact fit, 2=top-bottom
allpar.force2=0.1;   %spline smoothness. default=0.1, smaller = smoother
allpar.force3=5.;    %scaling factor for force arrow length
allpar.force4=20;    %scale bar [nN]
% parameters for determining cell masks
allpar.cell1=0;      %method for determining cell regions: 0=freehand, 1=from force map
% mPAD parameters
allpar.mpadD=1.83;  %pillar D [um]
allpar.mpadL=5.0;   %pillar L [um]
allpar.mpadP=4.0;   %array pitch [um]
allpar.mpadE=2.0;   %Young's modulus of PDMS [mPa]
allpar.mpadNu=0.45;  %Poisson ratio
% outline parameters
allpar.outline1 = 1;    %method [0= freehand, 1=automatic]
allpar.outline2 = 0.1;  %threshold
allpar.outline3 = 1000;  %minimum object size [pixel]
allpar.outline4 = 7;    %radius for closing [pixel]
% cell statistics
allpar.stat1 = 0;       %par 1 [unused]
allpar.stat2 = 0;       %par 2 [unused]
% image specifications
allpar.pixelsize=0.090; %pixel size [um]
% processmenu entry
allpar.process=1;
% experimentmenu entry
allpar.experiment=1;
% mpadmenu entry
allpar.mpad=4;

%%
% --- Outputs from this function are returned to the command line.
function varargout = TFMmPAD_GUI_v2_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


%%
function directory_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function directory_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
global dat allpar

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
    
    % import images
    dat.stack=import_tiff_stack([pn '\' dat.allfiles(1).name],[pn '\' dat.allfiles(l1+1).name]);
    
    % set back the method for outline determination
    allpar.outline1 = 1;
    
    % update display
    plotfig(handles)
    
end

%%
% --- Executes on slider movement when new file is selected.
function chosepic_Callback(hObject, ~, handles)

global dat allpar
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

% set back the method for outline determination
allpar.outline1 = 1;

dat.currentchanged=1;
plotfig(handles)

% --- Executes during object creation, after setting all properties.
function chosepic_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%%
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

%%
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
function idActin_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','w1SPI 491');

%%
% --- Executes during object creation, after setting all properties.
function idmPAD_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','w2SPI 561');

function idmPAD_Callback(hObject, eventdata, handles)


% --- Executes on button press in zbottomp.
function zbottomp_Callback(hObject, eventdata, handles)
bz=num2str(get(handles.slice,'Value'));
set(handles.zbottomv,'String',bz);

% --- Executes on button press in ztopp.
function ztopp_Callback(hObject, eventdata, handles)
tz=num2str(get(handles.slice,'Value'));
set(handles.ztopv,'String',tz);

%%
function min2v_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function min2v_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function max2v_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function max2v_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function zbottomv_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function zbottomv_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function ztopv_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ztopv_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
% --- Executes during object creation, after setting all properties.
function image1_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function image2_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)

%%
% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filename_Callback(hObject, eventdata, handles)

%%
% --- Executes during object creation, after setting all properties.
function filename2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filename2_Callback(hObject, eventdata, handles)

%%
% --- Executes on button press in processgo.
function processgo_Callback(hObject, eventdata, handles)
global dat allpar hglob
% % get bottom slice of experimentmenu images
% bs = round(str2num(get(handles.zbottomv,'String')));

switch allpar.process
    
    case 1 %find initial center positions
        %%
        % get current slice of experimentmenu images
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
       
    case 2 %find center positions throughout stack
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
        
        % get initial positions
        objinit = dat.objinit;
        
        % connect
        objinit = nnlink_rp(objinit, Inf, memory, dispopt);
                
        % throw out tracks that don't span all slices
        objinit = discard_incomplete(objinit);
        
        % save into global dat variable
        dat.objinit = objinit;
        
        % plot found tracks
        if dispopt
            show_results_tracks(objinit,7);
        end
        
        
    case 4 %refine positions by fitting
        %%
        % process parameters
        method = allpar.r1;
        imgs2use = allpar.r2;
               
        % load initial positions
        objinit = dat.objinit;
        
        % determine slices for refinement
        slice_range = unique(objinit(5,:));
        if imgs2use == 1
            slice_range = [slice_range(1) slice_range(end)];
        end
                
        % loop through slices and refine positions
        objref = refine_stack(objinit,slice_range,method);
        
        % save into global variable
        dat.objref = objref;
        
        % plot refined tracks
        show_results_tracks(objref,7);
        
        
%     case 5 %refine positions by correlation
%         
%         %%to be implemented; 
%         % based on correlation between ROIs around posts (pairwise for all)
%         % the fit spline
%         % does not require symmetric intensity distribution
%         % averages out erroroneous stainings


      case 5 % determine outline of cells
        %%
        
        % import current image of second channel
        imnum = round(size(dat.stack,3)/2+dat.currentslice);
        im = double(dat.stack(:,:,imnum));
        % grayscale parameters       
        thr = allpar.outline2;
        im = (im-min(im(:)))/(thr*(max(im(:))-min(im(:))));
        im(im>1) = 1;
        figure(1)
        imshow(im, []);
        colormap gray
        
        % determine outline
        meth = allpar.outline1;
        switch meth
            case 0 % freehand drawing of cell outlines
                L = outlines_freehand();
            case 1 % from actin image
                L = outlines_actin(im);
            case 2 % manual adaption of outlines
                L = outlines_adjustmanually(im);
        end
        % save into global variable
        dat.labelmask = L;
                
    case 6 %drift correction
        %%
        % map hexagonal lattice, correct drift...
        objID_still = drift_correction_and_more();
        
        % display results
        show_results_driftcorrection(objID_still,9)
     
        
    case 7 % force calculation
        %%
        
        % load refined and drift-corrected objects
        objrefdc = dat.objrefdc;
        
        % calculate forces
        defl_ang_force = calc_forces(objrefdc);
        
        % save deflection, angle, and force into hexagonal maps
        hexa_lattice = dat.hexaIDs;
        [hexad hexaa hexaf] = map_results_hexa(defl_ang_force,hexa_lattice);
        dat.hexadefl = hexad;
        dat.hexaang = hexaa;
        dat.hexaforce = hexaf;
        
        % show results of force calculation
        show_results_forcecalculation(defl_ang_force,objrefdc,10);
        
    case 8 % generate and save statistics for each cell
        %%
        % get labelmatrix of cell outlines
        L = dat.labelmask;
        % get pixel size
        pixsiz = allpar.pixelsize;
        
        % calculate cell statistics from image
        [cellstats, cellarea, cellellipt, cellcentroid, cellcirc] = ...
            cellstatistics(L,pixsiz);
        
        % force statistics
        [xyposts, ~, angposts, forceposts, labelposts, cellavgforce,...
            cellmaxforce, celltotalforce, cellnetforce, cellnetang, f0median, kspring] =...
            poststatistics(L);
        
        % assemble all data into table for later export
        [colnames, dataall] = table4export(L,cellcentroid,cellarea,...
            cellcirc,cellellipt,cellavgforce,cellmaxforce,celltotalforce,...
            cellnetforce,f0median,kspring);

        % load images and rescale for displaying
        [im_mpad, im_actin, B] = images4display(L);
               
        % figures and output (saving to disk)
        display_and_save_results(im_mpad, im_actin, B, L, cellcentroid,...
            angposts, forceposts, xyposts, cellstats, labelposts, ...
            cellnetang, cellnetforce, colnames, dataall);
        
end

%%
% --- Executes on selection change in processmenu.
function processmenu_Callback(hObject, eventdata, handles)

global allpar
allpar.process=get(handles.processmenu,'Value');

% --- Executes during object creation, after setting all properties.
function processmenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
% --- Executes during object creation, after setting all properties.
function experimentmenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in experimentmenu.
function experimentmenu_Callback(hObject, eventdata, handles)

global allpar
allpar.experiment=get(handles.experimentmenu,'Value');

%%
% --- Executes during object creation, after setting all properties.
function mpadmenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in mpadmenu.
function mpadmenu_Callback(hObject, eventdata, handles)

global allpar
allpar.mpad=get(handles.mpadmenu,'Value');
switch allpar.mpad %choose mPAD. All values refer to Chris Chen's mPADs
    case 1 % #2
        allpar.mpadD=1.83;
        allpar.mpadL=2.3;
    case 2 % #3 (hard)
        allpar.mpadD=1.83;
        allpar.mpadL=5;
    case 3 % #5
        allpar.mpadD=1.83;
        allpar.mpadL=6.1;
    case 4 % #7 (medium)
        allpar.mpadD=1.83;
        allpar.mpadL=7.1;
    case 5 % #9
        allpar.mpadD=1.83;
        allpar.mpadL=8.3;
    case 6 % #11 (soft)
        allpar.mpadD=1.83;
        allpar.mpadL=10.3;
    case 7 % #12
        allpar.mpadD=1.83;
        allpar.mpadL=12.9;
end

%%
% --- Executes on button press in parexperiment.
function parexperiment_Callback(hObject, eventdata, handles)
% hObject    handle to parexperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global allpar
%display(allpar.process)

switch allpar.experiment
    case 1 % mPAD parameters
        textvar={'post D [um]',...
            'post L [um]',...
            'array pitch (center-to-center distance) [µm]',...
            'Youngs modulus of PDMS [MPa]',...
            'Poisson number [0...0.5]'};
        defans={num2str(allpar.mpadD),...
            num2str(allpar.mpadL),...
            num2str(allpar.mpadP),...
            num2str(allpar.mpadE),...
            num2str(allpar.mpadNu)};
        answer=inputdlg(textvar,'mPAD parameters',1,defans);
        allpar.mpadD=str2double(answer(1));
        allpar.mpadL=str2double(answer(2));
        allpar.mpadP=str2double(answer(3));
        allpar.mpadE=str2double(answer(4));
        allpar.mpadNu=str2double(answer(5));
        
    case 2 % image specifications
        textvar={'pixel size [um]'};
        defans={num2str(allpar.pixelsize)};
        answer=inputdlg(textvar,'image specifications',1,defans);
        allpar.pixelsize=str2double(answer(1));
        
end

%%
% --- Executes on button press in parprocess.
function parprocess_Callback(hObject, eventdata, handles)

global allpar

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
%     case 5 %refine positions by correlation between ROIs
%         textvar={'upscaling factor [10...100]',...
%             'images to use [0=selected, 1=top-bottom]'};
%         defans={num2str(allpar.rbc1),num2str(allpar.rbc2)};
%         answer=inputdlg(textvar,'Parameters for refining post positions by correlation',1,defans);
%         allpar.rbc1=str2double(answer(1));
%         allpar.rbc2=str2double(answer(2));

    case 5 %define cell regions
        textvar={['method [0= freehand, 1= automatic, '...
            '2= modify existing mask]'],...
            'threshold',...
            'minimum object size [pixel]',...
            'radius for closing [pixel]'};
        defans={num2str(allpar.outline1),num2str(allpar.outline2),...
            num2str(allpar.outline3),num2str(allpar.outline4)};
        answer=inputdlg(textvar,'Parameters for determining cell outlines',1,defans);
        allpar.outline1=str2double(answer(1));
        allpar.outline2=str2double(answer(2));
        allpar.outline3=str2double(answer(3));
        allpar.outline4=str2double(answer(4));
        
    case 6 %remove drift from stack
        textvar={'method [0= no mask, 1= cell outlines]',...
            'fraction of posts for refinement [0...1]',...
            'color range max [0.5...2]'};
        defans={num2str(allpar.dc1),num2str(allpar.dc2),num2str(allpar.dc3)};
        answer=inputdlg(textvar,'Parameters for drift correction',1,defans);
        allpar.dc1=str2double(answer(1));
        allpar.dc2=str2double(answer(2));
        allpar.dc3=str2double(answer(3));
    case 7 %calculate forces
        textvar={
            'method [0= spline, 1= exact fit, 2= top-bottom',...
            'smoothness of spline [0...1]',...
            'scaling factor for length of force arrows',...
            'scale bar [nN]',...
            };
        defans={num2str(allpar.force1),...
            num2str(allpar.force2),...
            num2str(allpar.force3),...
            num2str(allpar.force4)...
            };
        answer=inputdlg(textvar,'Parameters for calculation of forces',1,defans);
        allpar.force1=str2double(answer(1));
        allpar.force2=str2double(answer(2));
        allpar.force3=str2double(answer(3));
        allpar.force4=str2double(answer(4));
    case 8 %statistics for cells
        textvar={
            'save? [0= no, 1= yes]',...
            'par2',...
            'scaling factor for length of force arrows',...
            'scale bar [nN]',...
            };
        defans={num2str(allpar.stat1),...
            num2str(allpar.stat2),...
            num2str(allpar.force3),...
            num2str(allpar.force4)...
            };
        answer=inputdlg(textvar,'Parameters for cell statistics',1,defans);
        allpar.stat1=str2double(answer(1));
        allpar.stat2=str2double(answer(2));
        allpar.force3=str2double(answer(3));
        allpar.force4=str2double(answer(4));
       
end
