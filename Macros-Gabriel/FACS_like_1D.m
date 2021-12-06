function FACS_like_1D(img_x,I_x,pos)
    c=colormap(jet(200));
    close all;
    colorsX=zeros(length(I_x),3);
    markersize = 50;
    isDoublePositiveCell=ones(size(I_x,1));
    posx=pos(:,1);
    posy=pos(:,2);
    xLabelName=inputname(2);
    xmin = double(quantile(I_x,0.05));
    xmax = double(quantile(I_x,0.95));
    cutOff_x = xmin;
    f1 = figure('Name','Control panel','units','normalized');
    f2 = figure('Name',inputname(1),'units','normalized');
    f3 = figure('Name',[inputname(1) 'heatmap'],'units','normalized');
    setFigurePositions();
    initialplot();
    figure(f1);
    
    hquitbutton = uicontrol('Parent',f1,'Style','pushbutton',...
    'String','Quit','Callback',@hquitbutton_Callback,...
    'Units','normalized',...
    'Position',[0.7,0.1,0.2,0.2]);

    Slider_x = uicontrol('Parent',f1,'Style','slider',...
     'Min',xmin-100,'Max',xmax+100, 'value',cutOff_x,...
     'Units','normalized',...
     'Position',[0.2,0.2,0.2,0.1],...
     'SliderStep',[1/100 5/100],...
     'Callback',@Slider_x_Callback);
  
    cutOffxBox = uicontrol('Parent',f1,'Style','edit',...
     'Units','normalized',... 
     'Position',[0.2,0.1,0.2,0.1],...
     'String',num2str(cutOff_x),...
     'Callback',@cutOffxBox_Callback);
     
    textx = uicontrol('Parent',f1,'Style','text',...
    'String',['x-axis : ' xLabelName],...
    'Units','normalized',... 
    'Position',[0.2,0,0.2,0.1]);
    
    function initialplot()
        figure(f1);
        isXPositiveCell=(I_x>cutOff_x);
        isXNegativeCell=(I_x<cutOff_x);
        % Make heatmap according to the cutOffs values
        for x=1:size(I_x)
            colorsX(x,:)=c(max(0,min(floor((I_x(x)-cutOff_x)/(xmax-xmin)*100)+100,200)),:);
        end
        
        hsc=histogram(I_x,'FaceColor',[0,0,205/255]) ; hold on;
        xlim([xmin-100 xmax+100]);
        %xlabel(xLabelName);
        ax = gca;
        line([cutOff_x cutOff_x],get(ax,'YLim'),'Color',[1 0 0]); 
        figure(f2);
        minImg_x = double(quantile(reshape(img_x,[size(img_x,1)*size(img_x,2),1]),0.05)); hold on;
        maxImg_x = double(quantile(reshape(img_x,[size(img_x,1)*size(img_x,2),1]),0.98));
        imshow(img_x,[minImg_x maxImg_x]); hold on
        f21=plot(posx(isXPositiveCell),posy(isXPositiveCell),'g+','MarkerSize',5);
        f22=plot(posx(~isXPositiveCell),posy(~isXPositiveCell),'r+','MarkerSize',5); 
        zoom on;
                 
        figure(f3);
        imshow(img_x,[minImg_x maxImg_x]); hold on
        scatter(posx,posy,markersize,colorsX,'.')
        zoom on;        
        setFigurePositions();
    end

    function FACSplot()
        clearFigure(f1);
        clearFigure(f2);
        clearFigure(f3);
        
        figure(f1);
        
        isXPositiveCell=(I_x>cutOff_x);
        isXNegativeCell=(I_x<cutOff_x);
        % Make heatmap according to the cutOffs values
        for x=1:size(I_x)
            colorsX(x,:)=c(max(1,min(floor((I_x(x)-cutOff_x)/(xmax-xmin)*100)+100,200)),:);
        end
    
        hsc=histogram(I_x,'FaceColor',[0,0,205/255]) ; hold on;
        xlim([xmin-100 xmax+100]);
        %xlabel(xLabelName);
        ax = gca;
        line([cutOff_x cutOff_x],get(ax,'YLim'),'Color',[1 0 0]); 
        figure(f2);
        minImg_x = double(quantile(reshape(img_x,[size(img_x,1)*size(img_x,2),1]),0.05)); hold on;
        maxImg_x = double(quantile(reshape(img_x,[size(img_x,1)*size(img_x,2),1]),0.98));
        imshow(img_x,[minImg_x maxImg_x]); hold on
        f21=plot(posx(isXPositiveCell),posy(isXPositiveCell),'g+','MarkerSize',5);
        f22=plot(posx(~isXPositiveCell),posy(~isXPositiveCell),'r+','MarkerSize',5); 
        zoom on;
                 
        figure(f3);
        imshow(img_x,[minImg_x maxImg_x]); hold on
        scatter(posx,posy,markersize,colorsX,'.')
        zoom on;        
        setFigurePositions();
    end
   
    function hquitbutton_Callback(~,~)
       assignin('base', 'cutOff_x_output',cutOff_x);
       close(f1);
       close(f2);
       close(f3);
    end

    function Slider_x_Callback(~,~)
        cutOff_x = get(Slider_x,'value');
        set(Slider_x,'value',cutOff_x);
        set(cutOffxBox,'String',num2str(cutOff_x));
        FACSplot();
    end
    
    function cutOffxBox_Callback(~,~)
        cutOff_x = str2num(get(cutOffxBox,'String'));
        set(Slider_x,'value',cutOff_x);
        set(cutOffxBox,'String',num2str(cutOff_x));
        FACSplot();
    end

    function setFigurePositions()
        figure(f1);
        f1.OuterPosition = [0 0 0.5 1];
        axesf1 = gca;
        axesf1.Position = [0.11,0.38,0.81,0.57];
        f2.OuterPosition = [0.5 0 0.5 0.5];
        f3.OuterPosition = [0.5 0.5 0.5 0.5];
    end
  
    function clearFigure(f)
        currentax=findall(f, 'type', 'axes');
        delete(currentax.Children);
    end
end