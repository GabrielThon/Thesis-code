function Gridstitching2(folder)
    pretreatment = true; objective = '20X'; project = true;
    
    % Build a sub-folder Treated-files to save the treated data
    savefolder = strcat(folder,"Treated-files\");
    mkdir(folder,"Treated-files\");

    dirFilter=strcat(folder,"Treated-files\Computed-filters\");
    
    list = dir(folder);
    % Build an array textfiles that contains all the .txt metadata files
    textfiles=strings(size(list,1),1);
    counttxt=0;
    for i=1:size(list,1)
        if (contains(list(i).name,'.txt'))
            counttxt = counttxt+1;
            textfiles(counttxt)=list(i).name;
        end
    end
    textfiles=textfiles(1:counttxt);

    % For each testfile, we treat the data
    for c=1:counttxt
        disp(["Analysing file:" textfiles(c)]);
        tempstring =char(textfiles(c));
        name_exp=tempstring(1:findstr(textfiles(c),".txt")-1);
        % Build an array that contains all the .tif images corresponding to
        % the.txt file
        curfilenames="";
        countimg=0;
        for i=1:size(list,1)
            if (and(contains(list(i).name,name_exp),contains(list(i).name,'.tif')))
                disp(['Found img file:' list(i).name]);
                countimg = countimg+1;
                curfilenames(countimg,1)=list(i).name;
            end
        end
        %Retrieve the main parameters of the experiment by calling functions to read the .txt file
        % channels is an array. Its size is the number of channels used during the experiment. Channels are listed in the order they were used.
        channels=getChannel(strcat(folder,textfiles(c)));
        % colors is an array. Its size is the number of channels used during the experiment. Colors have only been implemented for BF, GFP, YFP, CFP, RFP, far red and Tom_BF, Tom_GFP, Tom_YFP, Tom_CFP, Tom_RFP
        colors=getChannelName(channels);
        % filters is an array. Its size is the number of channels used during the experiment. It makes every channel correspond to its filter counterpart which will be used when treating the image.
        filters=getFilterName(channels);
        % z is a number. Its value corresponds to the number of stacks if a Z Scan was performed. Its standard value is 1 if no Z Scan was performed.
        z=getZStack(strcat(folder,textfiles(c)));
        % x is the x dimension if a XY Scan was performed. Its standard value is 1 if no XY Scan was performed.
        % y is the y dimension if a XY Scan was performed. Its standard value is 1 if no XY Scan was performed.
        % overlap is the overlap if a XY Scan was performed. Its standard value is 0 if no XY Scan was performed.
        [x,y,overlap]=getMontageDim(strcat(folder,textfiles(c)));
        % nPos corresponds to the number of different positions every .tif files contains. In case files the experiment is split in several files of the format "_f0000.tif" which are montages, nPos is the total number of files. Else, nPos is 1.
        nPos=getXYPositions(strcat(folder,textfiles(c)), curfilenames(1));
        cat=category(curfilenames,x,y,nPos);
        nPosPerFile=getPosPerFile(nPos,cat);
        nChannels=size(channels,1);
        treat(folder,savefolder,dirFilter,curfilenames,x,y,z,channels,colors,filters,overlap,pretreatment,project,nPos,objective,cat,nChannels,nPosPerFile)
    end
end

function treat(folder,savefolder,dirFilter,curfilenames,x,y,z,channels,colors,filters,overlap,pretreatment,project,nPos,objective,cat,nChannels,nPosPerFile)
    ij.IJ.run("Close All");
    
    info = imfinfo(char(strcat(folder,'\',curfilenames(1))));
    w=info(1).Width;
    h=info(1).Height;
    if pretreatment
        isTreated = "_treated";
        Ifilter= single(zeros(h,w,nChannels));
        for ic=1:nChannels
            Ifilter(:,:,ic)=imread(strcat(dirFilter,filters(ic),'.tif'),1);
        end
    else
        isTreated = "_untreated";
    end
    
    if needsStitching(x,y)
        %%outputfilenames = 
        outputfilenames = toPosFileNames(curfilenames,x,y,nPos);
        outputfilenames2 = fromPosFileNames(outputfilenames,x,y,nPos,isTreated);
        outputfilenamesproj = appendFileName(outputfilenames2,"_projected"); 
    else
        outputfilenames=appendFileName(curfilenames,isTreated);
		outputfilenamesproj=appendFileName(outputfilenames,"_projected");	
    end
    slices = size(imfinfo(char(strcat(folder,'\',curfilenames(1)))),1);
    [indices,t] = computeSubstack(slices,x,y,z,size(channels,1),nPosPerFile);
    
    for iFile=1:size(curfilenames,1)
        for iPosPerFile=1:nPosPerFile
            %IF order : x,y,z,c,t
            if needsStitching(x,y)
                for ix=1:x
                    for iy=1:y
                        IF=uint16(zeros(h,w,z,nChannels,t));
                        counter=1;
                        for it=1:t
                            for iz=1:z
                                for ic=1:nChannels
                                    IF(:,:,iz,ic,it)=uint16(imread(strcat(folder,'\',curfilenames(iFile)),indices{iPosPerFile,ix,iy}(counter)));
                                    if pretreatment
                                        IF(:,:,iz,ic,it)=uint16(single(IF(:,:,iz,ic,it))./Ifilter(:,:,ic));
                                    end
                                    counter = counter+1;
                                end
                            end
                        end
                        writeHyperstack(strcat(savefolder,outputfilenames(iFile,ix,iy)), IF);
                    end
                end
                filenames=strcat("[",extractBefore(outputfilenames(iFile),"_MMStack"),"_MMStack_",digitsString(iFile,2),"-Pos_{xxx}_{yyy}.tif]");
                ij.IJ.run("Grid/Collection stitching", "type=[Filename defined position] order=[Defined by filename         ] grid_size_x="+x+" grid_size_y="+y+" tile_overlap="+overlap+" first_file_index_x=0 first_file_index_y=0 directory=["+savefolder+"] file_names="+filenames+" output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
                if project
                    ij.IJ.run("Z Project...", "projection=[Max Intensity]");
                    ij.IJ.saveAs("Tiff",strcat(savefolder,'\',outputfilenamesproj(iFile)));
                else
                    ij.IJ.saveAs("Tiff",strcat(savefolder,'\',outputfilenames2(iFile)));
                end
                ij.IJ.run("Close All");
                ij.IJ.run("Collect Garbage");
                for ix=1:x
                    for iy=1:y
                        delete(strcat(savefolder,'\',outputfilenames(iFile,ix,iy)));
                    end
                end
            end
        end
    end
end

function [boolean] = isMontage(x,y,nPos)
    boolean = (x*y*nPos>1);
end

function [boolean] = needsStitching(x,y)
    boolean = (x*y>1);
end

function [outputfilenames] = toPosFileNames(filenames,x,y,nPos)
    if contains(filenames(1),'_f00')
        name_exp=extractBefore(filenames(1),'_f00');
        nMMStacks=size(filenames,1);
    else
        name_exp=extractBefore(filenames(1),'.tif');
        nMMStacks=nPos;
    end
    outputfilenames=strings(nMMStacks,x,y);
    for iMMStacks=1:nMMStacks
        for i=1:x
            for j=1:y
               outputfilenames(iMMStacks,i,j)=strcat(name_exp,"_MMStack_",digitsString(iMMStacks,2),"-Pos_",digitsString(i-1,3),"_",digitsString(j-1,3),".tif");
            end
        end
    end
end

function [outputfilenames] = fromPosFileNames(filenames,x,y,nPos,tag)
    nFile = size(filenames,1);
    outputfilenames = strings(nFile,1);
    for file=1:nFile
        name_exp=extractBefore(filenames(file*x*y),'_MMStack_');
        outputfilenames(file)=strcat(name_exp,"_MMStack_",digitsString(file,2),tag,".tif");
    end
end

% Adds the string appendString between filename and the extension
function [appendedName] = appendFileName(filename, appendString)
   dimensions = size(filename);
   numElements = prod(size(filename));
   tempfilename = reshape(filename, [numElements 1]);
   filenamewithoutExt = strings(numElements,1);
   appendedName = strings(numElements,1);
   for i=1:numElements
       [pathstr, filenamewithoutExt(i), ext] = fileparts(char(tempfilename(i)));
       appendedName(i) = strcat(pathstr, char(filenamewithoutExt(i)), appendString, ext);
   end
end

function [indices,time] = computeSubstack(slices,x,y,z,nChannels,nPosPerFile)
    spacing= x*y*z*nChannels*nPosPerFile;
    time=slices/spacing;
    indices = cell(nPosPerFile,x,y);
    for t=1:time
        for iPosPerFile=1:nPosPerFile
            for i=1:x
                for j=1:y
                    startingindice = z*nChannels*(i-1+x*(j-1)+x*y*(iPosPerFile-1)+x*y*nPosPerFile*(t-1))+1;
                    endingindice = startingindice+z*nChannels-1; 
                    indices{iPosPerFile,i,j} = [indices{iPosPerFile,i,j}, linspace(startingindice,endingindice,z*nChannels)];
                end
            end
        end
    end
end

function [cat] = category(filenames,x,y,nPos)
    if ~isMontage(x,y,nPos)
        if ~contains(filenames(1),'_f000')
            %Category 1a : No montages, XY pos in the same file
            cat=1;
        else
            %Category 2 : No montages, XY pos in different files
            cat=2;
        end
    else
        if ~contains(filenames(1),'_m000')
            if ~contains(filenames(1),'_f000')
                %Category 3 : Montage in the same file, XY pos in the same
                %file
                cat=3;
            else
                %Category 4 : Montage in the same file, XY pos in different
                %file
                cat=4;
            end
        else
            if ~contains(filenames(1),'_f000')
                %Category 5 : Montage in different files, XY pos in the same
                %file
                cat=5;
            else
                %Category 6 : Montage in different files, XY pos in different
                %file
                cat=6;
            end
        end
    end
end

function [nPosPerFile] = getPosPerFile(nPos,cat)
    if mod(cat,2) ==0
        nPosPerFile = 1;
    else
        nPosPerFile = nPos;
    end
end