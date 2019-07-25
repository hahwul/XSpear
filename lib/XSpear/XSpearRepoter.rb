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
  def initialize(url,starttime, method)
    @url = url
    @starttime = starttime
    @endtime = nil
    @issue = []
    @query = []
    @filtered_objects = {}
    @method = method
    # type : i,v,l,m,h
    # param : paramter
    # type :
    # query :
    # pattern
    # desc
    # category
    # callback
  end

  def add_issue_first(type, issue, param, payload, pattern, description)
    rtype = {"i"=>"INFO".blue,"v"=>"VULN".red,"l"=>"LOW".green,"m"=>"MIDUM".yellow,"h"=>"HIGH".red}
    rissue = {"f"=>"FILERD RULE","r"=>"REFLECTED","x"=>"XSS","s"=>"STATIC ANALYSIS","d"=>"DYNAMIC ANALYSIS"}
    @issue.insert(0,["-", rtype[type], rissue[issue], @method, param, pattern, description])
    @query.push payload
  end

  def add_issue(type, issue, param, payload, pattern, description)
    rtype = {"i"=>"INFO".blue,"v"=>"VULN".red,"l"=>"LOW".green,"m"=>"MIDUM".yellow,"h"=>"HIGH".red}
    rissue = {"f"=>"FILERD RULE","r"=>"REFLECTED","x"=>"XSS","s"=>"STATIC ANALYSIS","d"=>"DYNAMIC ANALYSIS"}
    @issue << [@issue.size, rtype[type], rissue[issue], @method, param, pattern, description]
    @query.push payload
  end

  def set_filtered f
    @filtered_objects = f
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
    rurl = ""
    if @url.length > 66
      rurl = @url[0..66]+"... (snip)"
    else
      rurl = @url
    end
    table = Terminal::Table.new
    table.title = "[ XSpear report ]".red+"\n#{rurl}\n#{@starttime} ~ #{@endtime} Found #{@issue.length} issues."
    table.headings = ['NO','TYPE','ISSUE', 'METHOD', 'PARAM', 'PAYLOAD','DESCRIPTION']
    table.rows = @issue
    #table.style = {:width => 80}
    puts table
    puts "< Available Objects >".yellow
    @filtered_objects.each do |key, value|
      eh = []
      tag = []
      sc = []
      uc = []
      puts "[#{key}]".blue+" param"
      value.each do |n|
        if n.include? "=64"
          # eh
          eh.push n.chomp("=64")
        elsif n.include? "xsp<"
          # tag
          n = n.sub("xsp<","")
          tag.push n.chomp(">")
        elsif n.include? ".xspear"
          # uc
          uc.push n.sub(".xspear","")
        else
          # sc
          sc.push n.sub("XsPeaR","")
        end
      end
      puts " + Available Special Char: ".green+"#{sc.map(&:inspect).join(',').gsub('"',"")}".gsub(',',' ')
      puts " + Available Event Handler: ".green+"#{eh.map(&:inspect).join(',')}"
      puts " + Available HTML Tag: ".green+"#{tag.map(&:inspect).join(',')}"
      puts " + Available Useful Code: ".green+"#{uc.map(&:inspect).join(',')}"
    end
    puts "< Raw Query >".yellow
    @query.each_with_index do |q, i|
      puts "[#{i}] "+@url+"?"+q
    end
  end
end