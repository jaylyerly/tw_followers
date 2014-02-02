![Travis Status](https://api.travis-ci.org/jaylyerly/tw_followers.png)


[![Coverage Status](https://coveralls.io/repos/jaylyerly/tw_followers/badge.png)](https://coveralls.io/r/jaylyerly/tw_followers)

Followers
============
This is a simple demo app that connects to the Twitter API and retrieves your followers.  You can drill down on your followers and see their followers as well.

The app uses the configured system Twitter account.  If there are multiple accounts, it uses the last one in the list.

Unit test coverage isn't complete, but there are some detailed unit tests, especially for the Twitter interface.  Unit tests use [OCMock](http://ocmock.org) and [Mocktail](https://github.com/square/objc-mocktail) testing libraries and some utilities from the [Google Toolbox for Mac](https://code.google.com/p/google-toolbox-for-mac/) for [compatibility with gcov](https://code.google.com/p/coverstory/wiki/UsingCoverstory).

This project is also configured for continuous integration with [Travis CI](https://travis-ci.org/jaylyerly/tw_followers) and reports unit test coverage with [Coveralls](https://coveralls.io/r/jaylyerly/tw_followers).