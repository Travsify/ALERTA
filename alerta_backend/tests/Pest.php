<?php

/*
|--------------------------------------------------------------------------
| Test Case
|--------------------------------------------------------------------------
| The closure you provide to your test functions is always bound to a specific
| PHPUnit test case class. By default, that class is "PHPUnit\Framework\TestCase".
| Pest uses this class to provide the `test()` and `it()` global functions.
*/

uses(Tests\TestCase::class)->in('Feature');
