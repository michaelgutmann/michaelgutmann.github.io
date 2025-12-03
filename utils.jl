using Bibliography
using DataStructures

## Example functions
function hfun_bar(vname)
  val = Meta.parse(vname[1])
  return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end

function lx_baz(com, _)
  # keep this first line
  brace_content = Franklin.content(com.braces[1]) # input string
  # do whatever you want here
  return uppercase(brace_content)
end

function hfun_print_bib(inputs)

  bibname = inputs[1]
  mode = inputs[2]

  # Import a BibTeX file to the internal bib structure
  bib = import_bibtex(joinpath("_assets", bibname))
  sorted_bib = sort_bibliography!(bib, :y)
  if mode=="papers"
    pub_html = bib_to_html(sorted_bib)
  elseif mode=="talks"
    println("in talks")
    pub_html = talks_to_html(sorted_bib)
  end
  return pub_html
end

function return_filepath(bibentry::Bibliography.BibInternal.Entry, basepath)
  if haskey(bibentry.fields, "file")
    filename = bibentry.fields["file"]

    # the filename is included between two : tags
    firstindex = findfirst(':', filename);
    nextindex =  findnext(':', filename, firstindex+1);
    filename = filename[firstindex+1:nextindex-1];
    filepath = joinpath(basepath, filename);
  else
    filepath = nothing;
  end
  return filepath
end  

function talks_to_html(bibs)
  str = ""
  for bib in Iterators.reverse(bibs)
      bib = bib.second
      p = Bibliography.Publication(bib)
      str *= """<div id="$(p.id)">"""
      str *= """<span class="title">$(p.title)</span><br>"""
      str *=bib.fields["venue"]*"<br>"
      str *=bib.fields["location"]*", "*bib.fields["year"]
      filepath = return_filepath(bib, "https://raw.githubusercontent.com/michaelgutmann/presentations/main")
      if isnothing(filepath)
        # do nothing
      else
        str *= "<br>"*"""<a href="$(filepath)" download>[presentation]</a>"""
      end
      str *= "</div>"
      str *= "<br>"
  end
  # clean up latex text encoding
  str = replace(str, latex_conversion...)
  return str
end


function bib_to_html(bibs)
  str = ""
  for bib in Iterators.reverse(bibs)
      bib = bib.second
      p = Bibliography.Publication(bib)
      str *= """<div id="$(p.id)">"""
      str *= """<span class="title">$(p.title)</span><br>"""
      str *= """<span class="author">"""
      str *= abbreviate_first_names(bib.authors)
      str *= "</span> <br>"
      if bib.type === "inproceedings"
        str *= "<i>"*bib.booktitle*"</i>"
      elseif bib.type === "article"
        str *= "<i>"*bib.fields["journal"]*"</i>"
      end
      str *=", "*p.year * "<br>"
      if haskey(bib.fields, "url")
        str *="""<a href="$(bib.fields["url"])">[url]</a>"""
      end
      if haskey(bib.fields, "arxiv")
        str *= "  "
        str *="""<a href="$(bib.fields["arxiv"])">[arxiv]</a>"""
      end
      str *= "</div>"
      str *= "<br>"
  end
  # clean up latex text encoding
  str = replace(str, latex_conversion...)
  return str
end

function abbreviate_first_names(names)
  str = ""
  for name in names
    if isempty(name.middle)
      str *= lstrip(name.first)[begin] * ". " * name.last
    else
      str *= lstrip(name.first)[begin]*". " * lstrip(name.middle)[begin]*". " * name.last
    end
    str *= ", "
  end
  return str[1:end-2]  # remove ", " for the last name
end

latex_conversion = Dict(
  "{"        => "",
  "}"        => "",
  """\\"a""" => "&#228;",
  """\\"o""" => "&#246;",
  """\\"O""" => "&#214;",
  """\\'e""" => "&#233;",
  """\\`e""" => "&#232;",
  """\\'c""" => "&#263;",
  """\\&""" => "&"
)

# old stuff
#= 
function hfun_print_bib_old()
  # doesn't produce a good result
  println("Made it!")
  bib = Bibliography(read(joinpath("_assets", "Refereed.bib"), String))
  formatted_entries = format_entries(PlainAlphaStyle,bib);
  #mdoutput          = write_to_string( MarkdownBackend(),formatted_entries)
  #mdoutput_parsed   = Markdown.parse(mdoutput)
  #return mdoutput_parsed
  htmlbackend       = HTMLBackend() 
  return write_to_string( htmlbackend ,formatted_entries)
end

# works but is not pretty
function hfun_pub()
  read(`pandoc -f markdown _assets/pub.md --citeproc  --bibliography=_assets/mypapers.bib --mathjax `,String)
end =#