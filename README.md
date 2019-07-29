<img src="https://user-images.githubusercontent.com/13212227/62022122-36a00180-b1ba-11e9-9f78-abd0eda9ae8f.png" width=100%>

# XSpear
XSpear is XSS Scanner on ruby gems

<img src="https://img.shields.io/static/v1.svg?label=lang&message=ruby&color=RED"> <img src="https://img.shields.io/gem/v/XSpear.svg"> <img src="https://img.shields.io/gem/dt/XSpear.svg"> <img src="https://img.shields.io/github/license/hahwul/XSpear.svg"> <a href="https://twitter.com/intent/follow?screen_name=hahwul"><img src="https://img.shields.io/static/v1.svg?label=follow&message=hahwul&color=black"></a>

## Key features
- Pattern matching based XSS scanning
- Detect `alert` `confirm` `prompt` event on headless browser (with Selenium)
- Testing request/response for XSS protection bypass and reflected params<br>
  + Reflected Params
  + Filtered test `event handler` `HTML tag` `Special Char`
- Testing Blind XSS (with XSS Hunter , ezXSS, HBXSS, Etc all url base blind test...)
- Dynamic/Static Analysis
  + Find SQL Error pattern
  + Analysis Security headers(`CSP` `HSTS` `X-frame-options`, `XSS-protection` etc.. )
  + Analysis Other headers..(Server version, Content-Type, etc...)
- Scanning from Raw file(Burp suite, ZAP Request)
- XSpear running on ruby code(with Gem library)
- Show `table base cli-report` and `filtered rule`, `testing raw query`(url)
- Testing at selected parameters
- Support output format `cli` `json`
  + cli: summary, filtered rule(params), Raw Query
- Support Verbose level (quit / nomal / raw data)
- Support custom callback code to any test various attack vectors

## Installation

Install it yourself as:

    $ gem install XSpear

Or install it yourself as (local file):

    $ gem install XSpear-{version}.gem
    
Add this line to your application's Gemfile:

```ruby
gem 'XSpear'
```

And then execute:

    $ bundle

### Dependency gems
`colorize` `selenium-webdriver` `terminal-table`<br>
If you configured it to install automatically in the Gem library, but it behaves abnormally, install it with the following command.

```
$ gem install colorize
$ gem install selenium-webdriver
$ gem install terminal-table
```

## Usage on cli

```
Usage: xspear -u [target] -[options] [value]
[ e.g ]
$ ruby a.rb -u 'https://www.hahwul.com/?q=123' --cookie='role=admin'

[ Options ]
    -u, --url=target_URL             [required] Target Url
    -d, --data=POST Body             [optional] POST Method Body data
        --headers=HEADERS            [optional] Add HTTP Headers
        --cookie=COOKIE              [optional] Add Cookie
        --raw=FILENAME               [optional] Load raw file(e.g raw_sample.txt)
    -p, --param=PARAM                [optional] Test paramters
    -b, --BLIND=URL                  [optional] Add vector of Blind XSS
                                      + with XSS Hunter, ezXSS, HBXSS, etc...
                                      + e.g : -b https://hahwul.xss.ht
    -t, --threads=NUMBER             [optional] thread , default: 10
    -o, --output=FILENAME            [optional] Save JSON Result
    -v, --verbose=1~3                [optional] Show log depth
                                      + Default value: 2
                                      + v=1 : quite mode
                                      + v=2 : show scanning log
                                      + v=3 : show detail log(req/res)
    -h, --help                       Prints this help
        --version                    Show XSpear version
        --update                     Update with online

```
### Result types
- (I)NFO: Get information ( e.g sql error , filterd rule, reflected params, etc..)
- (V)UNL: Vulnerable XSS, Checked alert/prompt/confirm with Selenium
- (L)OW: Low level issue
- (M)EDIUM: medium level issue
- (H)IGH: high level issue

### Case by Case
**Scanning XSS**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query" -d "searchFor=yy"
```

**json output**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query" -d "searchFor=yy" -o json -v 1
```

**detail log**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query" -d "searchFor=yy" -v 3
```

**set thread**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query" -t 30
```

**testing at selected parameters**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query&cat=123&ppl=1fhhahwul" -p cat,test
```

**testing blind xss**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query" -b "https://hahwul.xss.ht"
```

etc...

### Sample log
**Scanning XSS**
```
xspear -u "http://testphp.vulnweb.com/listproducts.php?cat=z"
    )  (
 ( /(  )\ )
 )\())(()/(          (     )  (
((_)\  /(_))`  )    ))\ ( /(  )(
__((_)(_))  /(/(   /((_))(_))(()\
\ \/ // __|((_)_\ (_)) ((_)_  ((_)
 >  < \__ \| '_ \)/ -_)/ _` || '_|
/_/\_\|___/| .__/ \___|\__,_||_|    />
           |_|                   \ /<
{\\\\\\\\\\\\\BYHAHWUL\\\\\\\\\\\(0):::<======================-
                                 / \<
                                    \>       [ v1.0.7 ]
[*] creating a test query.
[*] test query generation is complete. [149 query]
[*] starting test and analysis. [10 threads]
[I] [00:37:34] reflected 'XsPeaR
[-] [00:37:34] 'cat' Not reflected |XsPeaR
[I] [00:37:34] [param: cat][Found SQL Error Pattern]
[-] [00:37:34] 'STATIC' not reflected
[I] [00:37:34] reflected "XsPeaR
[-] [00:37:34] 'cat' Not reflected ;XsPeaR
[I] [00:37:34] reflected `XsPeaR
...snip...
[H] [00:37:44] reflected "><iframe/src=JavaScriPt:alert(45)>[param: cat][reflected XSS Code]
[-] [00:37:44] 'cat' not reflected <img/src onerror=alert(45)>
[-] [00:37:44] 'cat' not reflected <svg/onload=alert(45)>
[-] [00:37:49] 'cat' not found alert/prompt/confirm event '"><svg/onload=alert(45)>
[-] [00:37:49] 'cat' not found alert/prompt/confirm event '"><svg/onload=alert(45)>
[-] [00:37:50] 'cat' not found alert/prompt/confirm event <xmp><p title="</xmp><svg/onload=alert(45)>">
[-] [00:37:51] 'cat' not found alert/prompt/confirm event '"><svg/onload=alert(45)>
[V] [00:37:51] found alert/prompt/confirm (45) in selenium!! <script>alert(45)</script>
               => [param: cat][triggered <script>alert(45)</script>]
[V] [00:37:51] found alert/prompt/confirm (45) in selenium!! '"><svg/onload=alert(45)>
               => [param: cat][triggered <svg/onload=alert(45)>]
[*] finish scan. the report is being generated..
+----+-------+------------------+--------+-------+-------------------------------------+--------------------------------------------+
|                                                         [ XSpear report ]                                                         |
|                                         http://testphp.vulnweb.com/listproducts.php?cat=z                                         |
|                              2019-07-24 00:37:33 +0900 ~ 2019-07-24 00:37:51 +0900 Found 12 issues.                               |
+----+-------+------------------+--------+-------+-------------------------------------+--------------------------------------------+
| NO | TYPE  | ISSUE            | METHOD | PARAM | PAYLOAD                             | DESCRIPTION                                |
+----+-------+------------------+--------+-------+-------------------------------------+--------------------------------------------+
| 0  | INFO  | DYNAMIC ANALYSIS | GET    | cat   | XsPeaR"                             | Found SQL Error Pattern                    |
| 1  | INFO  | STATIC ANALYSIS  | GET    | -     | original query                      | Found Server: nginx/1.4.1                  |
| 2  | INFO  | STATIC ANALYSIS  | GET    | -     | original query                      | Not set HSTS                               |
| 3  | INFO  | STATIC ANALYSIS  | GET    | -     | original query                      | Content-Type: text/html                    |
| 4  | LOW   | STATIC ANALYSIS  | GET    | -     | original query                      | Not Set X-Frame-Options                    |
| 5  | MIDUM | STATIC ANALYSIS  | GET    | -     | original query                      | Not Set CSP                                |
| 6  | INFO  | REFLECTED        | GET    | cat   | rEfe6                               | reflected parameter                        |
| 7  | INFO  | FILERD RULE      | GET    | cat   | onhwul=64                           | not filtered event handler on{any} pattern |
| 8  | HIGH  | XSS              | GET    | cat   | <script>alert(45)</script>          | reflected XSS Code                         |
| 9  | HIGH  | XSS              | GET    | cat   | "><iframe/src=JavaScriPt:alert(45)> | reflected XSS Code                         |
| 10 | VULN  | XSS              | GET    | cat   | <script>alert(45)</script>          | triggered <script>alert(45)</script>       |
| 11 | VULN  | XSS              | GET    | cat   | '"><svg/onload=alert(45)>           | triggered <svg/onload=alert(45)>           |
+----+-------+------------------+--------+-------+-------------------------------------+--------------------------------------------+
< Available Objects >
[cat] param
 + Available Special Char: ' \ ` ) [ } : . { ] $
 + Available Event Handler: "onActivate","onBeforeActivate","onAfterUpdate","onAbort","onAfterPrint","onBeforeCopy","onBeforeCut","onBeforePaste","onBlur","onBeforePrint","onBeforeDeactivate","onBeforeUpdate","onBeforeEditFocus","onBegin","onBeforeUnload","onBounce","onDataSetChanged","onCellChange","onClick","onDataAvailable","onChange","onContextMenu","onCopy","onControlSelect","onDataSetComplete","onCut","onDragStart","onDragEnter","onDragOver","onDblClick","onDragEnd","onDrop","onDeactivate","onDragLeave","onDrag","onDragDrop","onHashChange","onFocusOut","onFilterChange","onEnd","onFocus","onHelp","onErrorUpdate","onFocusIn","onFinish","onError","onLayoutComplete","onKeyDown","onKeyUp","onMediaError","onLoad","onMediaComplete","onInput","onKeyPress","onloadstart","onLoseCapture","onMouseOut","onMouseDown","onMouseWheel","onMove","onMouseLeave","onMessage","onMouseEnter","onMouseMove","onMouseOver","onMouseUp","onPropertyChange","onMoveStart","onProgress","onPopState","onPaste","onOnline","onMoveEnd","onPause","onOutOfSync","onOffline","onReverse","onResize","onRedo","onRowsEnter","onRepeat","onReset","onResizeEnd","onResizeStart","onReadyStateChange","onResume","onRowInserted","onStart","onScroll","onRowExit","onSelectionChange","onSeek","onStop","onRowDelete","onSelectStart","onSelect","ontouchstart","ontouchend","onTrackChange","onSyncRestored","onTimeError","onUndo","onURLFlip","onStorage","onUnload","onSubmit","ontouchmove"
 + Available HTML Tag: "meta","video","iframe","embed","script","audio","svg","object","img","frameset","applet","style","frame"
 + Available Useful Code: "document.cookie","document.location","window.location"
< Raw Query >
[0] http://testphp.vulnweb.com/listproducts.php?cat=z?cat=zXsPeaR%22
[1] http://testphp.vulnweb.com/listproducts.php?cat=z?-
[2] http://testphp.vulnweb.com/listproducts.php?cat=z?-
[3] http://testphp.vulnweb.com/listproducts.php?cat=z?-
[4] http://testphp.vulnweb.com/listproducts.php?cat=z?-
[5] http://testphp.vulnweb.com/listproducts.php?cat=z?-
[6] http://testphp.vulnweb.com/listproducts.php?cat=z?cat=zrEfe6
[7] http://testphp.vulnweb.com/listproducts.php?cat=z?cat=z%5C%22%3E%3Cxspear+onhwul%3D64%3E
[8] http://testphp.vulnweb.com/listproducts.php?cat=z?cat=z%22%3E%3Cscript%3Ealert%2845%29%3C%2Fscript%3E
[9] http://testphp.vulnweb.com/listproducts.php?cat=z?cat=z%22%3E%3Ciframe%2Fsrc%3DJavaScriPt%3Aalert%2845%29%3E
[10] http://testphp.vulnweb.com/listproducts.php?cat=z?cat=z%22%3E%3Cscript%3Ealert%2845%29%3C%2Fscript%3E
[11] http://testphp.vulnweb.com/listproducts.php?cat=z?cat=z%27%22%3E%3Csvg%2Fonload%3Dalert%2845%29%3E
```            

**to JSON**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query" -d "searchFor=yy" -o json -v 1
{"starttime":"2019-07-17 01:02:13 +0900","endtime":"2019-07-17 01:02:59 +0900","issue_count":24,"issue_list":[{"id":0,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yy%3CXsPeaR","description":"not filtered \u001b[0;34;49m<\u001b[0m"},{"id":1,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%27","description":"not filtered \u001b[0;34;49m'\u001b[0m"},{"id":2,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%3E","description":"not filtered \u001b[0;34;49m>\u001b[0m"},{"id":3,"type":"INFO","issue":"REFLECTED","payload":"searchFor=yyrEfe6","description":"reflected parameter"},{"id":4,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%22","description":"not filtered \u001b[0;34;49m\"\u001b[0m"},{"id":5,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%60","description":"not filtered \u001b[0;34;49m`\u001b[0m"},{"id":6,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%3B","description":"not filtered \u001b[0;34;49m;\u001b[0m"},{"id":7,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%28","description":"not filtered \u001b[0;34;49m(\u001b[0m"},{"id":8,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%7C","description":"not filtered \u001b[0;34;49m|\u001b[0m"},{"id":9,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%29","description":"not filtered \u001b[0;34;49m)\u001b[0m"},{"id":10,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%7B","description":"not filtered \u001b[0;34;49m{\u001b[0m"},{"id":11,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%5B","description":"not filtered \u001b[0;34;49m[\u001b[0m"},{"id":12,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%5D","description":"not filtered \u001b[0;34;49m]\u001b[0m"},{"id":13,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%7D","description":"not filtered \u001b[0;34;49m}\u001b[0m"},{"id":14,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%3A","description":"not filtered \u001b[0;34;49m:\u001b[0m"},{"id":15,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%2B","description":"not filtered \u001b[0;34;49m+\u001b[0m"},{"id":16,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR.","description":"not filtered \u001b[0;34;49m.\u001b[0m"},{"id":17,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR-","description":"not filtered \u001b[0;34;49m-\u001b[0m"},{"id":18,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%2C","description":"not filtered \u001b[0;34;49m,\u001b[0m"},{"id":19,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%3D","description":"not filtered \u001b[0;34;49m=\u001b[0m"},{"id":20,"type":"HIGH","issue":"XSS","payload":"searchFor=yy%3Cimg%2Fsrc+onerror%3Dalert%2845%29%3E","description":"reflected \u001b[0;31;49mXSS Code\u001b[0m"},{"id":21,"type":"HIGH","issue":"XSS","payload":"searchFor=yy%3Csvg%2Fonload%3Dalert%2845%29%3E","description":"reflected \u001b[0;31;49mXSS Code\u001b[0m"},{"id":22,"type":"HIGH","issue":"XSS","payload":"searchFor=yy%22%3E%3Cscript%3Ealert%2845%29%3C%2Fscript%3E","description":"reflected \u001b[0;31;49mXSS Code\u001b[0m"},{"id":23,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%24","description":"not filtered \u001b[0;34;49m$\u001b[0m"}]}
```

## Usage on ruby code (gem library)
```ruby
require 'XSPear'

# Set options
options = {}
options['thread'] = 30
options['cookie'] = "data=123"
options['blind'] = "https://hahwul.xss.ht"
options['output'] = json

# Create XSpear object with url, options
s = XspearScan.new "https://www.hahwul.com?target_url", options

# Scanning
result = s.run
r = JSON.parse result
```

## Add Scanning Module
**1) Add `makeQueryPattern`**
```ruby
makeQueryPattern('type', 'query,', 'pattern', 'category', "description", "callback funcion")
# type: f(ilterd?) r(eflected?) x(ss?)
# category i(nfo) v(uln) l(ow) m(edium) h(igh) 

# e.g 
# makeQueryPattern('f', 'XsPeaR,', 'XsPeaR,', 'i', "not filtered "+",".blue, CallbackStringMatch)
```

**2) if other callback, write callback class override `ScanCallbackFunc`**
e.g
```ruby
  class CallbackStringMatch < ScanCallbackFunc
    def run
      if @response.body.include? @query
        [true, "reflected #{@query}"]
      else
        [false, "not reflected #{@query}"]
      end
    end
  end
```

Parent class(ScanCallbackFunc)
```ruby
class ScanCallbackFunc()
    def initialize(url, method, query, response)
      @url = url
      @method = method
      @query = query
      @response = response
      # self.run
    end
    
    def run
      # override
    end
end
```

Common Callback Class
- CallbackXSSSelenium
- CallbackErrorPatternMatch
- CallbackCheckHeaders
- CallbackStringMatch
- CallbackNotAdded
etc...

## Update
if nomal user
```
$ gem update XSpear
```

if developers (soft)
```
$ git pull -v
```
if develpers (hard)
```
$ git reset --hard HEAD; git pull -v
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hahwul/XSpear. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the XSpear project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/XSpear/blob/master/CODE_OF_CONDUCT.md).

## ScreenShot
<img src="https://user-images.githubusercontent.com/13212227/61727892-1681d400-adaf-11e9-832d-37547006f778.png" width=100%>
<img src="https://user-images.githubusercontent.com/13212227/61311071-8b459300-a830-11e9-8e60-c08e984fdacb.png" width=100%>

## Logos
<img src="https://user-images.githubusercontent.com/13212227/62022122-36a00180-b1ba-11e9-9f78-abd0eda9ae8f.png" width=100%>
<hr>
<img src="https://user-images.githubusercontent.com/13212227/61967487-63b0b080-b010-11e9-9c3d-15b404c957fe.png" width=100%>
