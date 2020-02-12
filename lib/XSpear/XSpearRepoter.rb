require 'terminal-table'
require 'cgi'

IssueStruct = Struct.new(:id, :type, :issue, :method, :param, :payload, :description)
class IssueStruct
  def to_json(*a)
    # NO TYPE ISSUE METHOD PARAM PAYLOAD DESCRIPTION
    {:id => self.id, :type => self.type, :issue => self.issue, :method => self.method, :param => self.param, :payload => self.payload, :description => self.description}.to_json(*a)
  end

  def self.json_create(o)
    new(o['id'], o['type'], o['issue'], o['method'], o['param'], o['payload'], o['description'])
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
    @rtype = {"i"=>"INFO".blue,"v"=>"VULN".red,"l"=>"LOW".green,"m"=>"MEDIUM".yellow,"h"=>"HIGH".light_red}
    @rissue = {"f"=>"FILERD RULE","r"=>"REFLECTED","x"=>"XSS","s"=>"STATIC ANALYSIS","d"=>"DYNAMIC ANALYSIS"}
  end

  def add_issue_first(type, issue, param, payload, pattern, description)
    rtype = @rtype
    rissue = @rissue
    @issue.insert(0,["-", rtype[type], rissue[issue], @method, param, pattern, description])
    @query.push payload
  end

  def add_issue(type, issue, param, payload, pattern, description)
    rtype = @rtype
    rissue = @rissue
    @issue << [@issue.size, rtype[type], rissue[issue], @method, param, pattern, description]
    @query.push payload
  end

  def filtered_objects
    @filtered_objects
  end

  def issues
    @issue
  end

  def set_filtered f
    @filtered_objects = f
  end
  def set_endtime
    @endtime = Time.now
  end

  def to_html
    rurl = ""
    if @url.length > 66
      rurl = @url[0..66]+"... (snip)"
    else
      rurl = @url
    end
    t_info= "Testing to <a href='#{CGI.escapeHTML @url}'>#{CGI.escapeHTML rurl}</a><br>Found #{@issue.length} issues and running on #{@starttime} ~ #{@endtime} "
    t_issue = ""
    t_available = ""
    t_rawquery = ""
    @issue.each do |i|
      i[1] = i[1].uncolorize
      i[6] = i[6].uncolorize
      # NO TYPE ISSUE METHOD PARAM PAYLOAD DESCRIPTION
      t_issue = t_issue + "<tr class='#{i[1]} ISSUE'><td>#{i[0]}</td><td>#{i[1]}</td><td>#{CGI.escapeHTML i[2]}</td><td>#{i[3]}</td><td>#{CGI.escapeHTML i[4]}</td><td>#{CGI.escapeHTML i[5]}</td><td>#{CGI.escapeHTML i[6]}</td></tr>" #(i[0],i[1],i[2],i[3],i[4],i[5],i[6])
    end
    @filtered_objects.each do |key, value|
      begin
        eh = []
        tag = []
        sc = []
        uc = []
        t_available = t_available + "<code>#{key}</code> param<br>"
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
        as = ""#sc.map(&:inspect).join(',')
        ae = ""#eh.map(&:inspect).join(',')
        at = ""#tag.map(&:inspect).join(',')
        ac = ""#uc.map(&:inspect).join(',')

        sc.each do |z|
          as = as + "<code>#{CGI.escapeHTML z}</code> "
        end
        eh.each do |z|
          ae = ae + "<code>#{CGI.escapeHTML z}</code> "
        end
        tag.each do |z|
          at = at + "<code>#{CGI.escapeHTML z}</code> "
        end
        uc.each do |z|
          ac = ac + "<code>#{CGI.escapeHTML z}</code> "
        end

        t_available = t_available + """
        <table>
            <tr>
                <td width='50%'>
                    <table>
                        <tr>
                            <td>Category</td>
                            <td>Data</td>
                        </tr>
                        <tr><td style='width:150px;'>HTML Tag</td><td>#{at}</td></tr>
                        <tr><td style='width:150px;'>Useful Code</td><td>#{ac}</td></tr>
                        <tr><td style='width:150px;'>Special Char</td><td>#{as}</td></tr>

                    </table>
                </td>
                <td><table>
                    <tr>
                        <td>Category</td>
                        <td>Data</td>
                        <tr><td style='width:150px;'>Event Handler</td><td>#{ae}</td></tr>
                    </tr>

                </table>
                </td>
            </tr>
        </table>
        """
      rescue
      end
    end
    if @filtered_objects.length == 0
    end
    begin
      @query.each_with_index do |q, i|
        html_q = "#{@url.sub(URI.parse(@url).query,"")}"+q
        t_rawquery = t_rawquery + "<li><a href='#{CGI.escapeHTML html_q}'>[#{i}] #{CGI.escapeHTML html_q}</a></li>"
      end
    rescue
    end
    report = """
      <style>
          @import url(https://fonts.googleapis.com/css?family=Lato:100,300,400,700);
          @import url(https://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css);

          html {
              height: 100%;
              font-family: 'Lato', sans-serif;
              -webkit-user-select: none;
              color:rgba(255, 255, 255, 0.4);
          }
          body {
              height: 100%;
              margin: 0;
              background: #252C33;
          }
          * {
              box-sizing: border-box;
              word-break: keep-all;
          }

          ::-webkit-scrollbar {
              min-width: 12px;
              width: 12px;
              max-width: 12px;
              min-height: 12px;
              height: 12px;
              max-height: 12px;
              background-color: #252C33;
          }
          ::-webkit-scrollbar-thumb {
              background: rgba(255,255,255,0.1);
              border: solid 3px #252C33;
              border-radius: 100px;
          }
          ::-webkit-scrollbar-thumb:hover {
              background: rgba(255,255,255,0.2);
          }
          ::-webkit-scrollbar-thumb:active {
              background: rgba(255,255,255,0.2);
          }
          ::-webkit-scrollbar-button {
              display: none;
              height: 0px;
          }

          /* CONTAINER */
          #container {
              display: table;
              width: 100%;
              background: #252C33;
              margin: 0px auto;
              border-radius: 0px;
          }

          /* Side Bar */
          #sideMenu {
              width: 240px;
              height: 100%;
              padding: 30px;
              border-right: 1px solid rgba(0,0,0,.1);
              background: #1b232a;
              display: table-cell;
              vertical-align: top;
              color: #fff;
          }
          #sideMenuFixed{
              position: fixed;
              top: 0px;
              left: 0px;
              width: 240px;
              height: 100%;
              padding: 30px;
              border-right: 1px solid rgba(0,0,0,.1);
              background: #1b232a;
              z-index: 9;
          }
          #sidecontent{
              position: fixed;
              width: 200px;
              z-index: 10;
          }
          #sidecontent h1:first-child{
              color: maroon;
              text-shadow: 5px 5px 0px rgba(0,0,0,.2);
              font-weight: 700;
              font-size: 27px;
              margin-left: -8px;
          }
          .menu {
              list-style: none;
              margin:  24px 0;
              padding: 0;
              width: 100%;
          }
          .menu li {
              display: block;
              height: 30px;
              width: 100%;
              line-height: 30px;
              font-size: 14px;
              font-weight: 300;
              color: rgba(255, 255, 255, .7);
              position: relative;
              cursor: pointer;
          }
          .menu li:hover {
              color: #FFF;
          }
          .menu li:first-child {
              height: 35px;
              line-height: 35px;
              font-size: 16px;
              font-weight: 700;
              color: #DDD;
              background: rgba(0,0,0,.08);
              margin-left: -18px;
              padding: 0px 10px;
              border-radius: 8px;
              cursor: default;
          }
          .addCategory {
              font-size: 13px;
              font-weight: 200;
              color: rgba(255, 255, 255, .2);
          }
          .addCategory:hover {
              color: #fff;
          }

          /* Content */
          #content {
              width: calc(100% - 240px);
              height: 100%;
              padding: 25px;
              display: table-cell;
          }

          a{
            color:rgba(255, 255, 255, .8);
          }

          /* Table */
          table {
              width: 100%;
              border-collapse: collapse;
          }
          th {
              text-align: left;
              color: #fff;
              font-weight: 400;
              font-size: 13px;
              text-transform: uppercase;
              border-bottom: 1px solid rgba(255, 255, 255, 0.1);
              padding: 0 10px;
              padding-bottom: 14px;
          }
          tr:not(:first-child):hover {
              background: rgba(255, 255, 255, 0.03);
          }
          td {
              height: 40px;
              line-height: 40px;
              font-weight: 300;
              color: white;
              padding: 0 10px;
              vertical-align: top;
          }
          /* Headers */
          h1 {
              font-size: 13px;
              font-weight: 200;
              letter-spacing: 1px;
              text-transform: uppercase;
              margin: 0;
          }
          h2 {
              float: left;
              letter-spacing: 1px;
              margin: 0;
              color: white;
          }
          h3 {
              float: left;
              color: #fff;
              font-size: 32px;
              font-weight: 300;
              margin: 0;
              margin-top: 8%;
              margin-left: 20px;
              margin-bottom: 6px;
          }
          .LOW {
            background-color: darkgoldenrod;
          }
          .MEDIUM {
            background-color: sienna;
          }
          .HIGH {
            background-color: firebrick;
          }
          .VULN {
            background-color: maroon;
          }
          .ISSUE{
            border: 1px solid white;
          }
          code {
              background: black;
              border: 1px solid;
              padding: 3px;
              border-radius: 5px;
              color: white;
          }
      </style>
      <div id='container'>
          <div id='sideMenu'>
              <div id='sideMenuFixed'></div>
              <div id='sidecontent'>
                  <h1>XSPEAR</h1> v#{XSpear::VERSION}

                  <ul class='menu'>
                      <li><a href='#summary'>Report</a></li>
                      <li><a href='#issues'>Issues</a></li>
                      <li><a href='#available'>Available Objects</a></li>
                      <li><a href='#raw_query'>Raw Query</a></li>
                  </ul>
                  <ul class='menu'>
                      <li><a href='https://github.com/hahwul/XSpear'>About XSpear</a></li>
                      <li><a href='https://github.com/hahwul/XSpear/issues/new'>Submit Bugs</a></li>
                  </ul>
              </div>
          </div>
          <div id='content'>
              <h2 id=summary>Summary</h2><br><br>
              #{t_info}
              <br><br><h2 id=issues>Issues</h2><br>
              <table>
                  <tr>
                      <td>No</td><td>Type</td><td>Issue</td><td>Method</td><td>Parameter</td><td>Payload</td><td>Description</td>
                  </tr>
                  #{t_issue}
              </table>
              <br><br><h2 id=available>Available Objects</h2><br><br>
              #{t_available}
              <br><br><h2 id=raw_query>Raw Query</h2><br><br>
              #{t_rawquery}
          </div>
      </div>
    """
    return report
  end

  def to_json
    buffer = []
    @issue.each do |i|
      i[1] = i[1].uncolorize
      i[6] = i[6].uncolorize
      # NO TYPE ISSUE METHOD PARAM PAYLOAD DESCRIPTION
      tmp = IssueStruct.new(i[0],i[1],i[2],i[3],i[4],i[5],i[6])
      buffer.push(tmp)
    end

    hash = {}
    hash["starttime"]=@starttime
    hash["endtime"]=@endtime
    hash["issue_count"]=@issue.length
    hash["issue_list"]=buffer
    hash.to_json
  end

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
      begin
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
      rescue
        puts "Not found"
      end
    end
    if @filtered_objects.length == 0
      puts "Not found"
    end
    puts "\n< Raw Query >".yellow
    begin
    @query.each_with_index do |q, i|
      puts "[#{i}] #{@url.sub(URI.parse(@url).query,"")}"+q
    end
    rescue
      puts "Not found"
    end
  end
end