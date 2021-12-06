function [textfiles] = getTextfilesInfo(folder)
    textfiles =dir([folder '*.txt']);
    for itxt=1:length(textfiles)
        [pathstr, name_exp, ext] = fileparts(textfiles(itxt).name);
        textfiles(itxt).fullName=strcat(textfiles(itxt).folder,'\',textfiles(itxt).name);
        textfiles(itxt).imageName=dir(strcat(folder,name_exp,'*.tif'));
        nimg = size(textfiles(itxt).imageName,1);
        for iimg = 1:nimg
            textfiles(itxt).imageName(iimg).fullname=strcat(textfiles(itxt).imageName(iimg).folder,textfiles(itxt).imageName(iimg).name);     
        end
        textfiles(itxt).chNames=getChannel(textfiles(itxt).fullName);
        textfiles(itxt).chNb =size(textfiles(itxt).chNames,1);
        [x,y,overlap] = getMontageDim(textfiles(itxt).fullName);
        textfiles(itxt).x=x;
        textfiles(itxt).y=y;
        textfiles(itxt).overlap=overlap;
        z = getZStack(textfiles(itxt).fullName);
        textfiles(itxt).z=z;
    end
    disp('Info from textfiles recovered');
end