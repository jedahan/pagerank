% make a cellarray of all the pages
allpages = fopen('allpages.txt');
pages{1} = fgetl(allpages)
while ~feof(allpages)
    pages{end+1} = fgetl(allpages);
end
fclose(allpages);

b = zeros(length(pages), length(pages));

href_regex = 'ahref=["'']([^"'']+)html["'']';

% for each page
for page_num=1:length(pages)
  page = fscanf(fopen(strrep(pages{page_num},"http://","")) ,'%s',Inf);
  % our fscanf removes spaces lol
  hrefs = regexpi(page, href_regex, 'match');
  % for each href
  for href_num=1:length(hrefs)
    href = hrefs(href_num){1,1};
    link = substr(href, 8, length(href)-8);

    % replace ../ with directory above
    page(1:strfind(page,'/')(length(strfind(link,'../'))));

    if strfind(link,'http://')~=1
      link = regexprep(link,'', 'http://$1');
    end

    pages

    b(find(strcmp(pages,page)), find(strcmp(pages,link))) = 1;
  end
end


