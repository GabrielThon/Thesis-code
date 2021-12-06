% Adds the string appendString between filename and the extension
function [appendedName] = appendFile(filename, appendString)
   dimensions = size(filename);
   numElements = prod(size(filename));
   tempfilename = reshape(filename, [numElements 1]);
   filenamewithoutExt = strings(numElements,1);
   appendedName = strings(numElements,1);
   for i=1:numElements
       [pathstr, filenamewithoutExt(i), ext] = fileparts(char(tempfilename(i)));
       appendedName(i) = strcat(pathstr, char(filenamewithoutExt(i)), appendString, ext);
   end
   appendedName=cellstr(appendedName);
end