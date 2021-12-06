function FACS_like_5(img_x,img_y,I_x,I_y,pos)
    % img is the img to analyse with the two channels
    %
    % I_x and I_y are the intensities in two channels to display in
    % FACS-like structure
    % 
    % pos is a two-column vector with the i-th row containing coordinates
    % the i-th point
    c=colormap(jet(200));
    close all;
    colorsX=zeros(length(I_x),3);
    colorsY=zeros(length(I_y),3);
    markersize = 50;
    
    isDoublePositiveCell=ones(size(I_x,1));
    posx=pos(:,1);
    posy=pos(:,2);
    xLabelName=inputname(3);
    yLabelName=inputname(4);
    xmin = double(quantile(I_x,0.01));
    xmax = double(quantile(I_x,0.95));
    cutOff_x = xmin;
    
    ymin = double(quantile(I_y,0.01));
    ymax = double(quantile(I_y,0.95));
    cutOff_y = ymin;
    
    f1 = figure('Name','Control panel','units','normalized');
    %%('Parent',f1,'Position',[0.13 0.39  0.77 0.54]);
    f2 = figure('Name',inputname(1),'units','normalized');
    f3 = figure('Name',inputname(2),'units','normalized');
    f4 = figure('Name',[inputname(1) 'heatmap'],'units','normalized');
    f5 = figure('Name',[inputname(2) 'heatmap'],'units','normalized');
    setFigurePositions();
%     f1.Position = [0.05 0.05 0.4 0.9];
%     f2.Position = [0.55 0.05 0.4 0.4];
%     f3.Position = [0.55 0.55 0.4 0.4];
    initialplot();
    figure(f1);
    
    hquitbutton = uicontrol('Parent',f1,'Style','pushbutton',...
    'String','Quit','Callback',@hquitbutton_Callback,...
    'Position',[500,20,50,50]);

    Slider_x = uicontrol('Parent',f1,'Style','slider',...
     'Min',xmin-100,'Max',xmax+100, 'value',cutOff_x,...
     'Position',[100,40,100,20],...
     'SliderStep',[1/100 5/100],...
     'Units','normalized',...
     'Callback',@Slider_x_Callback);
 
    Slider_y = uicontrol('Parent',f1,'Style','slider',...
     'Min',ymin-100,'Max',ymax+100, 'value',cutOff_y,...
     'Position',[300,40,100,20],...
     'SliderStep',[1/100 5/100],...
     'Units','normalized',...
     'Callback',@Slider_y_Callback);
 
    cutOffxBox = uicontrol('Parent',f1,'Style','edit',...
     'Position',[100,20,100,20],...
     'String',num2str(cutOff_x),...
     'Callback',@cutOffxBox_Callback);
 
    cutOffyBox = uicontrol('Parent',f1,'Style','edit',...
     'Position',[300,20,100,20],...
     'String',num2str(cutOff_y),...
     'Callback',@cutOffyBox_Callback);
 
    textx = uicontrol('Parent',f1,'Style','text',...
    'String',['x-axis : ' xLabelName],...
    'Position',[100,60,100,20]);

    texty = uicontrol('Parent',f1,'Style','text',...
    'String',['y-axis : ' yLabelName],...
    'Position',[300,60,100,20]);
    
    function initialplot()
        figure(f1);
        
        isXPositiveCell=(I_x>cutOff_x);
        isYPositiveCell=(I_y>cutOff_y);
        isDoublePositiveCell=isXPositiveCell & isYPositiveCell;
        isDoubleNegativeCell=~isXPositiveCell & ~isYPositiveCell;
        % Make heatmap according to the cutOffs values
        for x=1:size(I_x)
            colorsX(x,:)=c(max(0,min(floor((I_x(x)-cutOff_x)/(xmax-xmin)*100)+100,200)),:);
        end
        
        for y=1:size(I_y)
            colorsY(y,:)=c(max(0,min(floor((I_y(y)-cutOff_y)/(ymax-ymin)*100)+100,200)),:);
        end
        %
        
        hsc=scatter(I_x(isXPositiveCell),I_y(isXPositiveCell),'y+') ; hold on;
        hsc=scatter(I_x(isYPositiveCell),I_y(isYPositiveCell),'y+') ; 
        hsc=scatter(I_x(isDoublePositiveCell),I_y(isDoublePositiveCell),'g+') ;
        hsc=scatter(I_x(isDoubleNegativeCell),I_y(isDoubleNegativeCell),'r+') ; 
        xlim([xmin xmax+100]);
        %xlabel(xLabelName);
        ylim([ymin ymax+100]);
        %ylabel(yLabelName);
        ax = gca;
        line([cutOff_x cutOff_x],get(ax,'YLim'),'Color',[1 0 0]);
        line(get(ax,'XLim'),[cutOff_y cutOff_y],'Color',[1 0 0]); hold off;
        
        figure(f2);
        minImg_x = double(quantile(reshape(img_x,[size(img_x,1)*size(img_x,2),1]),0.05)); hold on;
        maxImg_x = double(quantile(reshape(img_x,[size(img_x,1)*size(img_x,2),1]),0.98));
        imshow(img_x,[minImg_x maxImg_x]); hold on
        f21=plot(posx(isXPositiveCell),posy(isXPositiveCell),'g+','MarkerSize',5);
        f22=plot(posx(~isXPositiveCell),posy(~isXPositiveCell),'r+','MarkerSize',5); 
        zoom on;
        
        %%h_zoom = zoom;
        %%h_zoom.ActionPostCallback = {@resize_markers}
        
        figure(f3);
        minImg_y = double(quantile(reshape(img_x,[size(img_x,1)*size(img_x,2),1]),0.05)); hold on;
        maxImg_y = double(quantile(reshape(img_y,[size(img_y,1)*size(img_y,2),1]),0.98));
        imshow(img_y,[minImg_y maxImg_y]); hold on
        plot(posx(isYPositiveCell),posy(isYPositiveCell),'g+','MarkerSize',5);
        plot(posx(~isYPositiveCell),posy(~isYPositiveCell),'r+','MarkerSize',5); 
        zoom on;
        
        figure(f4);
        imshow(img_x,[minImg_x maxImg_x]); hold on
        scatter(posx,posy,markersize,colorsX,'.')
        zoom on;
        
        figure(f5);
        imshow(img_y,[minImg_y maxImg_y]); hold on
        scatter(posx,posy,markersize,colorsY,'.')
        zoom on;
        
        setFigurePositions();
    end

    function FACSplot()
        clearFigure(f1);
        clearFigure(f2);
        clearFigure(f3);
        clearFigure(f4);
        clearFigure(f5);
        
        figure(f1);
        
        isXPositiveCell=(I_x>cutOff_x);
        isYPositiveCell=(I_y>cutOff_y);
        isDoublePositiveCell=isXPositiveCell & isYPositiveCell;
        isDoubleNegativeCell=~isXPositiveCell & ~isYPositiveCell;
        % Make heatmap according to the cutOffs values
        for x=1:size(I_x)
            colorsX(x,:)=c(max(1,min(floor((I_x(x)-cutOff_x)/(xmax-xmin)*100)+100,200)),:);
        end
        
        for y=1:size(I_y)
            colorsY(y,:)=c(max(1,min(floor((I_y(y)-cutOff_y)/(ymax-ymin)*100)+100,200)),:);
        end
        %
        
        hsc=scatter(I_x(isXPositiveCell),I_y(isXPositiveCell),'y+') ; hold on;
        hsc=scatter(I_x(isYPositiveCell),I_y(isYPositiveCell),'y+') ; 
        hsc=scatter(I_x(isDoublePositiveCell),I_y(isDoublePositiveCell),'g+') ;
        hsc=scatter(I_x(isDoubleNegativeCell),I_y(isDoubleNegativeCell),'r+') ; 
        xlim([xmin xmax+100]);
        %xlabel(xLabelName);
        ylim([ymin ymax+100]);
        %ylabel(yLabelName);
        ax = gca;
        line([cutOff_x cutOff_x],get(ax,'YLim'),'Color',[1 0 0]);
        line(get(ax,'XLim'),[cutOff_y cutOff_y],'Color',[1 0 0]); hold off;
        
        figure(f2);
        minImg_x = double(quantile(reshape(img_x,[size(img_x,1)*size(img_x,2),1]),0.05)); hold on;
        maxImg_x = double(quantile(reshape(img_x,[size(img_x,1)*size(img_x,2),1]),0.98));
        imshow(img_x,[minImg_x maxImg_x]); hold on
        f21=plot(posx(isXPositiveCell),posy(isXPositiveCell),'g+','MarkerSize',5);
        f22=plot(posx(~isXPositiveCell),posy(~isXPositiveCell),'r+','MarkerSize',5); 
        zoom on;
        
        %%h_zoom = zoom;
        %%h_zoom.ActionPostCallback = {@resize_markers}
        
        figure(f3);
        minImg_y = double(quantile(reshape(img_x,[size(img_x,1)*size(img_x,2),1]),0.05)); hold on;
        maxImg_y = double(quantile(reshape(img_y,[size(img_y,1)*size(img_y,2),1]),0.98));
        imshow(img_y,[minImg_y maxImg_y]); hold on
        plot(posx(isYPositiveCell),posy(isYPositiveCell),'g+','MarkerSize',5);
        plot(posx(~isYPositiveCell),posy(~isYPositiveCell),'r+','MarkerSize',5); 
        zoom on;
        
        figure(f4);
        imshow(img_x,[minImg_x maxImg_x]); hold on
        scatter(posx,posy,markersize,colorsX,'.')
        zoom on;
        
        figure(f5);
        imshow(img_y,[minImg_y maxImg_y]); hold on
        scatter(posx,posy,markersize,colorsY,'.')
        zoom on;
        
        setFigurePositions();
    end
   
    function hquitbutton_Callback(~,~)
       assignin('base', 'cutOff_x_output',cutOff_x);
       assignin('base', 'cutOff_y_output',cutOff_y);
       close(f1);
       close(f2);
       close(f3);
       close(f4);
       close(f5);
    end

    function Slider_x_Callback(~,~)
        cutOff_x = get(Slider_x,'value');
        set(Slider_x,'value',cutOff_x);
        set(cutOffxBox,'String',num2str(cutOff_x));
        FACSplot();
    end

    function Slider_y_Callback(~,~)
        cutOff_y = get(Slider_y,'value');
        set(Slider_y,'value',cutOff_y);
        set(cutOffyBox,'String',num2str(cutOff_y));
        FACSplot();
    end
    
    function cutOffxBox_Callback(~,~)
        cutOff_x = str2num(get(cutOffxBox,'String'));
        set(Slider_x,'value',cutOff_x);
        set(cutOffxBox,'String',num2str(cutOff_x));
        FACSplot();
    end

    function cutOffyBox_Callback(~,~)
        cutOff_y = str2num(get(cutOffyBox,'String'));
        set(Slider_y,'value',cutOff_y);
        set(cutOffyBox,'String',num2str(cutOff_y));
        FACSplot();
    end

    function setFigurePositions()
        figure(f1);
        f1.OuterPosition = [0 0.6 0.4 0.4];
        axesf1 = gca;
        axesf1.Position = [0.11,0.38,0.81,0.57];
        f2.InnerPosition = [0 0 0.25 0.5];
        f3.InnerPosition = [0.5 0 0.25 0.5];
        f4.InnerPosition = [0.25 0 0.25 0.5];
        f5.InnerPosition = [0.75 0 0.25 0.5];
    end

    %%function resize_markers(~,~)
    %   f21.MarkerSize = f21.MarkerSize*2;
    %   f22.MarkerSize = f22.MarkerSize*2;
    %end
    
    function clearFigure(f)
        currentax=findall(f, 'type', 'axes');
        delete(currentax.Children);
        %delete(child);
    end
end