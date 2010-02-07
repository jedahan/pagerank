allpages = fscanfl(fopen('allpages.txt'),'%s',Inf));

reghref = 'ahref=["'']([^"'']+)html["'']';
reglink = '["'']([^"'']+)["'']';
regrel = ?

for pagenum=1:length(allpages),
  website = fscanf(fopen(allpages(pagenum),'%s',Inf))
  % our fscanf removes spaces lol
  hrefs = regexpi(website, reghref, 'match');

  for i=1:length(hrefs),
    link = regexp(hrefs(i),  reglink, 'match');
    if length(link)=0,
	link=canonicalize(regexp(hrefs(i), regrel, 'match'))    
    end
  end
end
