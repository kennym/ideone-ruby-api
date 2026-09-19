# Changelog

## 3.0.0

- Require Ruby 3.4 or newer. Developed and CI-tested on Ruby 4.0.
- Upgrade Savon to `~> 2.17` and add the `cgi` gem (removed from default gems in Ruby 4.0).
- Call the Ideone SOAP API over HTTPS (`https://ideone.com/api/1/service.wsdl`).
- Replace Jeweler-generated packaging with a hand-maintained gemspec.
- Replace Travis CI with GitHub Actions (Ruby 3.4 and 4.0).
- Use Minitest 6 and WebMock for the test suite.
- Stop treating every Ideone error as `Ideone::AuthError`. Authentication failures still raise `AuthError`; other API errors raise `Ideone::Error`.
- Stop mutating shared request state between calls.
- Read credentials from `IDEONE_USER` / `IDEONE_PASSWORD` in optional live tests instead of hardcoding them.

## 2.1.2

- Last Jeweler-era release (2014-05-10).
