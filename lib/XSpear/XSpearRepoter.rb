require 'terminal-table'

class XspearRepoter
  def initialize(url)
    @url = url
    @issue = []
    # type : i,v,l,m,h
    # param : paramter
    # type :
    # query :
    # pattern
    # desc
    # category
    # callback
  end

  def add_issue(type, issue, payload, description)
    rtype = {"i"=>"INFO","v"=>"VULN","l"=>"LOW","m"=>"MIDUM","h"=>"HIGH"}
    rissue = {"f"=>"FILERD RULE","r"=>"REFLECTED","x"=>"XSS"}
    @issue << [@issue.size, rtype[type], rissue[issue], payload, description]
  end

  def to_json; end

  def to_html; end

  def to_cli
    table = Terminal::Table.new
    table.title = "XSpear report\n#{@url}"
    table.headings = ['NO','TYPE','ISSUE','PAYLOAD','DESCRIPTION']
    table.rows = @issue
    #table.style = {:width => 80}
    puts table
  end
end