% FIXME 'warning: range error for conversion to character value'

% make a cellarray of all the pages
allpages = fopen('allpages.txt');
pages{1} = fgetl(allpages);
while ~feof(allpages)
  pages{end+1} = fgetl(allpages);
end
fclose(allpages);

% initialize matrix
b = zeros(length(pages), length(pages));

% for each page,
for page_num=1:length(pages)
  page = pages(page_num){1,1};

  % capture all the hrefs.
  webpage = fscanf(fopen(strrep(page,"http://","")) ,'%s',Inf);
  hrefs = regexp(webpage, 'ahref=["'']([^"'']+html)["'']', 'tokens');

  % for each href
  for href_num=1:length(hrefs)
    href = hrefs(href_num){1,1}{1,1};

    % replace first character in relative path with full path
    href = regexprep(href,'^[/\w]',page(1:findstr(page,'/')(end)),'once');

    % replace any number of ../s with the full path
    if regexpi(href,'^\.\./')
        ups = strfind(href,'../');
        downs = strfind(page,'/');
        href = strcat(page(1:downs(end-length(ups))), href(ups(end)+3:end));
    end

    % prepend http if its not found,
    if isempty(strfind(href, 'http://'))
      href = strcat('http://',href);
    end

    % mark the appropriate entry in b
    b(find(strcmp(pages,page)), find(strcmp(pages,href))) = 1;
  end
end

b
