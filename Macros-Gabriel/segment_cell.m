function segment_cell(img)
% segment a cell user friendly
%% Parameters for positions and colors of figures and some handles
% The position of the game figure will be [figX1,figX2,figY1,figY2]
figX1 = 0;
figX2 = 800;
figY1 = 0;
figY2 = 500;

%% sets initial variables
openI = 1;
thresh = 0;
%% Create and hide the GUI figure as it is being constructed.
segfigure = figure('Visible','on','Tag','segfigure','Position',[figX1,figY1,figX2,figY2]);
set ( gcf, 'Color', [0 0 0] );
%% Create buttons and others
hquitbutton = uicontrol('Style','pushbutton',...
    'String','Quit','Callback',@hquitbutton_Callback,...
    'Position',[750,450,50,50]); % Quit seg
%20.6628 -446.1809  144.5822   52.1283

hopen = uicontrol('Style','slider',...
    'Min',1,'Max',30, 'value',openI,...
    'Position',[50,450,100,20],...
    'SliderStep',[1/30 0.2],'Callback',@hopen_Callback);

hthresh = uicontrol('Style','slider',...
    'Min',-0.2,'Max',0.2, 'value',thresh,...
    'Position',[50,420,100,20],...
    'SliderStep',[0.4/200 0.1],'Callback',@hthresh_Callback);

hsegment = uicontrol('Style','pushbutton','String', 'Segment',...
    'Position',[160,450,50,20],...
    'Callback',@hsegment_Callback);
%% Create axes and display image
canvas = 300;
sI = size(img);
panelI_X1 = 40;
%panelI_X2 = panelI_X1+sI(2);
panelI_X2 = canvas;
panelI_Y1 = 40;
%panelI_Y2 = panelI_Y1+sI(1);
panelI_Y2 = canvas;
ha = axes('Units','Pixels','Position',[panelI_X1,panelI_Y1,panelI_X2,panelI_Y2]);
imshow(img,[]);

hbw = axes('Units','Pixels','Position',[panelI_X1+canvas+30,panelI_Y1,panelI_X2,panelI_Y2]);
%bw = im2bw(uint8(img),graythresh(uint8(img)));
bw = zeros(sI(1),sI(2));
imshow(bw,[]);

% Change units to normalized so components resize automatically.
set([segfigure,ha,hbw,hquitbutton,hopen,hthresh,hsegment],...
    'Units','normalized');
%% Final settings
% Assign the GUI a name to appear in the window title.
set(segfigure,'Name','Segment Cell v. 1.0');
% Move the GUI to the center of the screen.
movegui(segfigure,'northwest');
% Make the GUI visible.
set(segfigure,'Visible','on');

%% Callbacks
    function hquitbutton_Callback(~,~)
       assignin('base', 'bw_output',bw);
       close(segfigure);
    end

    function hopen_Callback(~,~)
        openI = get(hopen,'Value');
        openI = round(openI);
        set(hopen,'Value',openI);
        bw = openi(img);
        showbw(bw);
    end

    function hthresh_Callback(~,~)
        thresh = get(hthresh,'Value');
        bw = openi(img);
        bw = segment(bw);
        showbw(bw);
        showI(img,bw);
    end

    function hsegment_Callback(~,~)
        bw = segment(bw);
        showbw(bw);
        showI(img,bw);
    end

%% Functions
    function showI(image,bwi)
        axes(ha);
        imshow(image,[]);
        bwp = bwperim(bwi);
        hold on
        [r,c] = find(bwp==1,1);
        if ~isempty(r)
            contour = bwtraceboundary(bwi,[r c],'W',8,Inf,'counterclockwise');
            plot(contour(:,2),contour(:,1),'g','LineWidth',0.5);
        end
        hold off
        axes(hbw);
        imshow(bwi,[]);
    end

    function showbw(bwimage)
        axes(hbw);
        imshow(bwimage,[]);
    end

    function bwo = segment(bwi)
        bwi = double(bwi);
        bwi = bwi./max(max(bwi));
        th = graythresh(bwi)+thresh;
        bwo = im2bw(bwi,th);       
        %bwo = imclearborder(bwo);
        bwo = bwareaopen(bwo,5000);
        se = strel('disk',10);
        bwo = imclose(bwo,se);
        bwo = imfill(bwo,'holes');  
    end


    function bwo = openi(Im)
        f1 = fspecial('Gaussian', openI, openI/3);
        f2 = fspecial('Gaussian', openI, openI/2);
        df = f1-2.*f2;
        bwo = conv2(double(Im), df, 'same');
        bwo = imcomplement(bwo);
    end
end

