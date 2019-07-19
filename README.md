# XSpear
XSpear is XSS Scanner on ruby gems

<img src="https://img.shields.io/static/v1.svg?label=lang&message=ruby&color=RED"> <img src="https://img.shields.io/github/languages/top/hahwul/XSpear.svg"> <img src="https://img.shields.io/static/v1.svg?label=version&message=1.0&color=purple"> <img src="https://img.shields.io/github/license/hahwul/XSpear.svg"> <a href="https://twitter.com/intent/follow?screen_name=hahwul"><img src="https://img.shields.io/static/v1.svg?label=follow&message=hahwul&color=black"></a>

## Key features
- Pattern matching based XSS scanning
- Detect `alert` `confirm` `prompt` event on headless browser (with Selenium)
- Testing request/response for XSS protection bypass and reflected params
- XSpear running on ruby code(with Gem library)
- Dynamic/Static Analysis(Find SQL Error, etc..)
- Show table base report and testing raw query(url)
- Testing at selected parameters
- Support output format `cli` `json`
- Support Verbose level (quit / nomal / raw data)
- Support custom callback code to any test various attack vectors

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'XSpear'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install XSpear

Or install it yourself as (local file):

    $ gem install XSpear-0.1.0.gem

### Dependency gems
`colorize` `selenium-webdriver`<br>
If you configured it to install automatically in the Gem library, but it behaves abnormally, install it with the following command.

```
$ gem install colorize
$ gem install selenium-webdriver
```

## Usage on cli

```
Usage: xspear -u [target] -[options] [value]
[ e.g ]
$ xspear -u 'https://www.hahwul.com/?q=123' --cookie='role=admin'

[ Options ]
    -u, --url=target_URL             [required] Target Url
    -d, --data=POST Body             [optional] POST Method Body data
        --headers=HEADERS            [optional] Add HTTP Headers
        --cookie=COOKIE              [optional] Add Cookie
    -l, --level=1~3                  [optional] Custom scan level
                                      + Default value: 3
                                      + Level3
                                      + Level2
                                      + Level1: 
    -t, --threads=NUMBER             [optional] thread , default: 10
    -o, --output=FILENAME            [optional] Save JSON Result
    -v, --verbose=1~3                [optional] Show log depth
                                      + Default value: 2
                                      + v=1 : quite mode
                                      + v=2 : show scanning log
                                      + v=3 : show detail log(req/res)
    -h, --help                       Prints this help
        --update                     Update with online

```

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

**testing at selected parameters**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query&cat=123&ppl=1fhhahwul" -p cat,test
```

etc...

### Sample log
**Scanning XSS**
```
$ xspear -u "http://testphp.vulnweb.com/listproducts.php?cat=1"
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
                                    \>
[*] creating a test query.
[*] test query generation is complete. [30 query]
[*] starting test and analysis. [10 threads]
[-] [01:24:38] not reflected XsPeaR`
[-] [01:24:38] not reflected XsPeaR>
[I] [01:24:38] reflected rEfe6[param: cat][reflected parameter]
[-] [01:24:38] not reflected XsPeaR|
[-] [01:24:38] not reflected XsPeaR'
[I] [01:24:38] [param: cat][Found SQL Error Pattern]
[-] [01:24:38] not reflected XsPeaR(
[-] [01:24:38] not reflected <XsPeaR
[-] [01:24:38] not reflected XsPeaR"
[-] [01:24:38] not reflected XsPeaR;
[-] [01:24:39] not reflected XsPeaR:
[-] [01:24:39] not reflected XsPeaR[
[-] [01:24:39] not reflected XsPeaR]
[-] [01:24:39] not reflected XsPeaR}
[-] [01:24:39] not reflected XsPeaR)
[-] [01:24:39] not reflected XsPeaR{
[-] [01:24:39] not reflected XsPeaR.
[-] [01:24:39] not reflected XsPeaR-
[-] [01:24:39] not reflected XsPeaR+
[-] [01:24:39] not reflected XsPeaR,
[I] [01:24:40] reflected XsPeaR$[param: cat][not filtered $]
[-] [01:24:40] not reflected <svg/onload=alert(45)>
[H] [01:24:40] reflected <script>alert(45)</script>[param: cat][reflected XSS Code]
[-] [01:24:40] not reflected XsPeaR=
[-] [01:24:40] not reflected <img/src onerror=alert(45)>
[*] finish scan. the report is being generated..
+----+------+------------------+-------+----------------------------+-------------------------+
|                                      [ XSpear report ]                                      |
|                      http://testphp.vulnweb.com/listproducts.php?cat=1                      |
|            2019-07-20 01:24:38 +0900 ~ 2019-07-20 01:25:41 +0900 Found 4 issues.            |
+----+------+------------------+-------+----------------------------+-------------------------+
| NO | TYPE | ISSUE            | PARAM | PAYLOAD                    | DESCRIPTION             |
+----+------+------------------+-------+----------------------------+-------------------------+
| 0  | INFO | REFLECTED        | cat   | rEfe6                      | reflected parameter     |
| 1  | INFO | DYNAMIC ANALYSIS | cat   | XsPeaR"                    | Found SQL Error Pattern |
| 2  | INFO | FILERD RULE      | cat   | XsPeaR$                    | not filtered $          |
| 3  | HIGH | XSS              | cat   | <script>alert(45)</script> | reflected XSS Code      |
+----+------+------------------+-------+----------------------------+-------------------------+
< Raw Query >
[0] http://testphp.vulnweb.com/listproducts.php?cat=1?cat=1rEfe6
[1] http://testphp.vulnweb.com/listproducts.php?cat=1?cat=1XsPeaR%22
[2] http://testphp.vulnweb.com/listproducts.php?cat=1?cat=1XsPeaR%24
[3] http://testphp.vulnweb.com/listproducts.php?cat=1?cat=1%22%3E%3Cscript%3Ealert%2845%29%3C%2Fscript%3E
```            

**to JSON**
```
$ xspear -u "http://testphp.vulnweb.com/search.php?test=query" -d "searchFor=yy" -o json -v 1
{"starttime":"2019-07-17 01:02:13 +0900","endtime":"2019-07-17 01:02:59 +0900","issue_count":24,"issue_list":[{"id":0,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yy%3CXsPeaR","description":"not filtered \u001b[0;34;49m<\u001b[0m"},{"id":1,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%27","description":"not filtered \u001b[0;34;49m'\u001b[0m"},{"id":2,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%3E","description":"not filtered \u001b[0;34;49m>\u001b[0m"},{"id":3,"type":"INFO","issue":"REFLECTED","payload":"searchFor=yyrEfe6","description":"reflected parameter"},{"id":4,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%22","description":"not filtered \u001b[0;34;49m\"\u001b[0m"},{"id":5,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%60","description":"not filtered \u001b[0;34;49m`\u001b[0m"},{"id":6,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%3B","description":"not filtered \u001b[0;34;49m;\u001b[0m"},{"id":7,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%28","description":"not filtered \u001b[0;34;49m(\u001b[0m"},{"id":8,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%7C","description":"not filtered \u001b[0;34;49m|\u001b[0m"},{"id":9,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%29","description":"not filtered \u001b[0;34;49m)\u001b[0m"},{"id":10,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%7B","description":"not filtered \u001b[0;34;49m{\u001b[0m"},{"id":11,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%5B","description":"not filtered \u001b[0;34;49m[\u001b[0m"},{"id":12,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%5D","description":"not filtered \u001b[0;34;49m]\u001b[0m"},{"id":13,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%7D","description":"not filtered \u001b[0;34;49m}\u001b[0m"},{"id":14,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%3A","description":"not filtered \u001b[0;34;49m:\u001b[0m"},{"id":15,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%2B","description":"not filtered \u001b[0;34;49m+\u001b[0m"},{"id":16,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR.","description":"not filtered \u001b[0;34;49m.\u001b[0m"},{"id":17,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR-","description":"not filtered \u001b[0;34;49m-\u001b[0m"},{"id":18,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%2C","description":"not filtered \u001b[0;34;49m,\u001b[0m"},{"id":19,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%3D","description":"not filtered \u001b[0;34;49m=\u001b[0m"},{"id":20,"type":"HIGH","issue":"XSS","payload":"searchFor=yy%3Cimg%2Fsrc+onerror%3Dalert%2845%29%3E","description":"reflected \u001b[0;31;49mXSS Code\u001b[0m"},{"id":21,"type":"HIGH","issue":"XSS","payload":"searchFor=yy%3Csvg%2Fonload%3Dalert%2845%29%3E","description":"reflected \u001b[0;31;49mXSS Code\u001b[0m"},{"id":22,"type":"HIGH","issue":"XSS","payload":"searchFor=yy%22%3E%3Cscript%3Ealert%2845%29%3C%2Fscript%3E","description":"reflected \u001b[0;31;49mXSS Code\u001b[0m"},{"id":23,"type":"INFO","issue":"FILERD RULE","payload":"searchFor=yyXsPeaR%24","description":"not filtered \u001b[0;34;49m$\u001b[0m"}]}
```

## Usage on ruby code (gem library)
```ruby
require 'XSPear'

s = XspearScan.new "https://www.hahwul.com?target_url", "post_body=thisisbodydata", "CustomHeader: wow", 3, 10, "result.json", "3"
# s = XspearScan.new options.url, options.data, options.headers, options.level, options.thread.to_i, options.output, options.verbose
s.run
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/XSpear. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the XSpear project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/XSpear/blob/master/CODE_OF_CONDUCT.md).

## ScreenShot
<img src="https://user-images.githubusercontent.com/13212227/61550885-a7467000-aa8e-11e9-9677-2a0c5800e1cc.png" width=100%>
<img src="https://user-images.githubusercontent.com/13212227/61311071-8b459300-a830-11e9-8e60-c08e984fdacb.png" width=100%>
