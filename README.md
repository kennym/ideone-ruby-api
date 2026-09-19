# ideone-ruby-api

[![CI](https://github.com/kennym/ideone-ruby-api/actions/workflows/ci.yml/badge.svg)](https://github.com/kennym/ideone-ruby-api/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/ideone-ruby-api.svg)](https://badge.fury.io/rb/ideone-ruby-api)

Ruby bindings for the [Ideone](https://ideone.com) SOAP API — an online compiler and pastebin.

Requires **Ruby 3.4+**. Developed on **Ruby 4.0**.

## Ideone API status

The SOAP service this gem wraps is still live. The original operations
(`testFunction`, `getLanguages`, `createSubmission`, `getSubmissionStatus`,
`getSubmissionDetails`) still work:

| | |
|---|---|
| WSDL | `https://ideone.com/api/1/service.wsdl` |
| Endpoint | `https://ideone.com/api/1/service` |

[Sphere Engine](https://sphere-engine.com) no longer develops this SOAP API.
They recommend the [Compilers REST API v4](https://docs.sphere-engine.com/compilers/api/overview-version-4)
for new products. This gem stays on Ideone SOAP so existing callers keep working.

The old PDF (`http://ideone.com/files/ideone-api.pdf`) is gone.

## Installation

```ruby
# Gemfile
gem "ideone-ruby-api"
```

```bash
gem install ideone-ruby-api
```

## Usage

```ruby
require "ideone"

client = Ideone.new("username", "password")

# Log SOAP traffic
client = Ideone.new("username", "password", true)

link = client.create_submission("puts 'hello, world'", 17) # 17 = Ruby
# => "TOKEN"

client.submission_status(link)
# => { status: 0, result: 15 }

client.submission_details(link)
# => { "error" => "OK", "langName" => "Ruby", "output" => "hello, world\n", ... }

client.languages
# => { "1" => "C++ (gcc 8.3)", "17" => "Ruby (ruby 2.5.5)", "116" => "Python 3 (python 3.12)", ... }

client.test
# => { "error" => "OK", "moreHelp" => "ideone.com", "pi" => "3.14",
#      "answerToLifeAndEverything" => "42", "oOok" => true }
```

### Language ids

Call `languages` for the current list. As of 2026-09 these still match the old docs:

| Id | Language |
|---:|---|
| 1 | C++ (gcc 8.3) |
| 17 | Ruby (ruby 2.5.5) |
| 116 | Python 3 (python 3.12) |

### Submission status and result

`submission_status` returns integers:

**status** (execution stage)

| Value | Meaning |
|---:|---|
| < 0 | waiting in queue |
| 0 | finished |
| 1 | compiling |
| 3 | running |

**result** (when status is 0)

| Value | Meaning |
|---:|---|
| 11 | compilation error |
| 12 | runtime error |
| 13 | time limit exceeded |
| 15 | success |
| 17 | memory limit exceeded |
| 19 | illegal system call |
| 20 | internal error |

Poll until `status == 0` before reading output from `submission_details`.

### Errors

- `Ideone::AuthError` — Ideone returned `AUTH_ERROR`
- `Ideone::Error` — any other API or transport failure

## Development

```bash
bundle install
bundle exec rake
```

Default tests are mocked (WebMock) and do not call Ideone.

```bash
IDEONE_USER=you IDEONE_PASSWORD=secret bundle exec rake
```

CI runs on Ruby 3.4 and 4.0.

## Similar projects

- https://github.com/maveonair/ccpacona
- https://github.com/jonathanperret/ideone.rb
- https://github.com/Pistos/ideone-gem

## License

Copyright (c) 2011-2026 Kenny Meyer. See [LICENSE.txt](LICENSE.txt).
