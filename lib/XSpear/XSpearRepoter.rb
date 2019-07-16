require 'terminal-table'

IssueStruct = Struct.new(:id, :type, :issue, :payload, :description)
class IssueStruct
  def to_json(*a)
    {:id => self.id, :type => self.type, :issue => self.issue, :payload => self.payload, :description => self.description}.to_json(*a)
  end


  def self.json_create(o)
    new(o['id'], o['type'], o['issue'], o['payload'], o['description'])
  end
end

class XspearRepoter
  def initialize(url,starttime)
    @url = url
    @starttime = starttime
    @endtime = nil
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

  def set_endtime
    @endtime = Time.now
  end

  def to_json
    buffer = []
    @issue.each do |i|
      tmp = IssueStruct.new(i[0],i[1],i[2],i[3],i[4])
      buffer.push(tmp)
    end

    hash = {}
    hash["starttime"]=@starttime
    hash["endtime"]=@endtime
    hash["issue_count"]=@issue.length
    hash["issue_list"]=buffer
    hash.to_json
  end

  def to_html; end

  def to_cli
    table = Terminal::Table.new
    table.title = "[ XSpear report ]\n#{@starttime} ~ #{@endtime} || Found #{@issue.length} issues.\n#{@url}"
    table.headings = ['NO','TYPE','ISSUE','PAYLOAD','DESCRIPTION']
    table.rows = @issue
    #table.style = {:width => 80}
    puts table
  end
end