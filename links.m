function t = buildMatrix(directory)
    % buildMatrix  Creates the normalized probability matrix

    %%% create cellarray of indexed pages
    pages = textread([directory '/allpages.txt'],'%s');

    %%% initialize empty matrix
    b = zeros(length(pages), length(pages));

    %%% for each page,
    for page_num=1:length(pages)
      page = pages(page_num){1,1};
      %%% capture all the hrefs 
      fid = fopen(strrep(page,"http://",""));
      %%% NOTE utf8 pages complain about range error conversion here
      hrefs=regexp(fscanf(fid,'%s'),'ahref=["'']([^"'']+html)["'']','tokens');
      fclose(fid);
      %%% for each href
      for href_num=1:length(hrefs)
        href = hrefs{1,href_num}{1,1};
        %%% replace first character in relative path with full path
        href = regexprep(href,'^[/\w]',[page(1:findstr(page,'/')(end)) '$0'],'once');
        %%% replace any number of ../s with the full path
        if regexpi(href,'^\.\./')
            ups = strfind(href,'../');
            downs = strfind(page,'/');
            href = strcat(page(1:downs(end-length(ups))), href(ups(end)+3:end));
        end

        %%% prepend http if its not found
        regexprep(href, '^[^http\:]','http://$0');

        %%% mark the appropriate entry in b
        b(find(strcmp(pages,href)), find(strcmp(pages,page))) = 1;
      end
    end

  %%% replace any all 0 column with all 1s
  b(:,find(all(~b)))=1;

  %%% normalize by the column sum
  t = bsxfun(@rdivide,b,sum(b));
end

buildMatrix('test')

