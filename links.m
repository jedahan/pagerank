function t = buildMatrix(pagelist)
    % buildMatrix  Creates the normalized probability matrix

    %%% create cellarray of indexed pages
    pages = textread(pagelist,'%s');

    %%% initialize empty matrix
    b = zeros(length(pages), length(pages));

    %%% for each page,
    for page_num=1:length(pages)    % FIXME: can this be
      page = pages(page_num){1,1};  % for page in pages
      %%% capture all the hrefs 
      fid = fopen(strrep(page,"http://",""));
      % FIXME range error conversion is here
      hrefs = regexp(fscanf(fid,'%s'),'ahref=["'']([^"'']+html)["'']','tokens');
      fclose(fid);
      %%% for each href
      for href_num=1:length(hrefs)
        href = hrefs(href_num){1,1}{1,1};
        %%% replace first character in relative path with full path
        href = regexprep(href,'^[/\w]',page(1:findstr(page,'/')(end)),'once');
        %%% replace any number of ../s with the full path
        if regexpi(href,'^\.\./')
            ups = strfind(href,'../');
            downs = strfind(page,'/');
            href = strcat(page(1:downs(end-length(ups))), href(ups(end)+3:end));
        end

        %%% prepend http if its not found
        regexprep(href, '^[^http\:]','http://$0');

        %%% mark the appropriate entry in b
        b(find(strcmp(pages,page)), find(strcmp(pages,href))) = 1;
      end
    end

  %%% replace any all 0 column with all 1s
  b(:,find(all(~b)))=1;

  %%% normalize by the column sum
  t = bsxfun(@rdivide,b,sum(b));
end

buildMatrix('allpages.txt')

