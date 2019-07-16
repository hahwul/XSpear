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
  # Your code goes here...
end

class XspearScan
  def initialize(url, data, headers, level, thread, output, verbose)
    @url = url
    @data = data
    @headers = headers
    @level = level
    @thread = thread
    @output = output
    @verbose = verbose
    @report = XspearRepoter.new @url, Time.now
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

  class CallbackXSSSelenium < ScanCallbackFunc
    def run
      options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
      driver = Selenium::WebDriver.for(:firefox, options: options)
      if @method == "GET"
        begin
          driver.get(@url)
          alert = driver.switch_to().alert()
          if alert.text.to_s == "45"
            driver.quit
            [true, "found alert/prompt/confirm (45) in selenium!! #{@query}\n               => "]
          else
            driver.quit
            [true, "found alert/prompt/confirm event in selenium #{@query}\n               =>"]
          end
        rescue Selenium::WebDriver::Error::UnexpectedAlertOpenError => e
          driver.quit
          [true, "found alert/prompt/confirm error base in selenium #{@query}\n               =>"]
        rescue => e
          driver.quit
          [false, "not found alert/prompt/confirm event #{@query}\n               =>"]
        end
      end
    end
  end


  def run
    r = []
    log('s', 'creating a test query.')
    r.push makeQueryPattern('r', 'rEfe6', 'rEfe6', 'i', 'reflected parameter', CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR>', 'XsPeaR>', 'i', "not filtered "+">".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', '<XsPeaR', '<XsPeaR', 'i', "not filtered "+"<".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR"', 'XsPeaR"', 'i', "not filtered "+'"'.blue, CallbackStringMatch)
    r.push makeQueryPattern('f', "XsPeaR'", "XsPeaR'", 'i', "not filtered "+"'".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', "XsPeaR`", "XsPeaR`", 'i', "not filtered "+"`".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR;', 'XsPeaR;', 'i', "not filtered "+";".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR|', 'XsPeaR|', 'i', "not filtered "+"|".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR(', 'XsPeaR(', 'i', "not filtered "+"(".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR)', 'XsPeaR)', 'i', "not filtered "+")".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR{', 'XsPeaR{', 'i', "not filtered "+"{".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR}', 'XsPeaR}', 'i', "not filtered "+"}".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR[', 'XsPeaR[', 'i', "not filtered "+"[".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR]', 'XsPeaR]', 'i', "not filtered "+"]".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR:', 'XsPeaR:', 'i', "not filtered "+":".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR.', 'XsPeaR.', 'i', "not filtered "+".".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR,', 'XsPeaR,', 'i', "not filtered "+",".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR+', 'XsPeaR+', 'i', "not filtered "+"+".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR-', 'XsPeaR-', 'i', "not filtered "+"-".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR=', 'XsPeaR=', 'i', "not filtered "+"=".blue, CallbackStringMatch)
    r.push makeQueryPattern('f', 'XsPeaR$', 'XsPeaR$', 'i', "not filtered "+"$".blue, CallbackStringMatch)
    r.push makeQueryPattern('x', '"><script>alert(45)</script>', '<script>alert(45)</script>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
    r.push makeQueryPattern('x', '<svg/onload=alert(45)>', '<svg/onload=alert(45)>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
    r.push makeQueryPattern('x', '<img/src onerror=alert(45)>', '<img/src onerror=alert(45)>', 'h', "reflected "+"XSS Code".red, CallbackStringMatch)
    r.push makeQueryPattern('x', '<script>alert(45)</script>', '<script>alert(45)</script>', 'h', "injected "+"<script>alert(45)</script>".red, CallbackXSSSelenium)
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
            @report.add_issue(node[:category],node[:type],node[:query],node[:desc])
          else
            log('d', (result[1]).to_s)
          end
          rescue => e
          end
        end
      end.each(&:join)
    end
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
    result = []
    uri = URI.parse(@url)
    begin
      params = URI.decode_www_form(uri.query)
      params.each do |p|
        dparams = params
        dparams.each do |d|
          d[1] = p[1] + payload if p[0] == d[0]
        end
        result.push("inject": 'url',"param":p[0] ,"type": type, "query": URI.encode_www_form(dparams), "pattern": pattern, "desc": desc, "category": category, "callback": callback)
      end
      unless @data.nil?
        params = URI.decode_www_form(@data)
        params.each do |p|
          dparams = params
          dparams.each do |d|
            d[1] = p[1] + payload if p[0] == d[0]
          end
          result.push("inject": 'body', "param":p[0], "type": type, "query": URI.encode_www_form(dparams), "pattern": pattern, "desc": desc, "category": category, "callback": callback)
        end
      end
    rescue StandardError
      result.push("inject": 'url',"param":"error", "type": type, "query": '', "pattern": pattern, "desc": desc, "category": category, "callback": callback)
    end
    result
  end

  def task(query, injected, pattern, callback)
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
end