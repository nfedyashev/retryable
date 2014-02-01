## Retryable 1.3.5 ##

*   New callback option(:exception_cb) to run after an rescued exception is introduced. Thanks @jondruse

## Retryable 1.3.4 ##

*   Namespace issue has been fixed. Thanks @darkhelmet

## Retryable 1.3.3 ##

*   Retryable::Version constant typo has been fixed

## Retryable 1.3.2 ##

*   Retryable.disable method has been added
*   Retryable.enabled method has been added

## Retryable 1.3.1 ##

*   :ensure retryable option add added

*   ArgumentError is raised instead of InvalidRetryableOptions in case of invalid option param for retryable block

## Retryable 1.3.0 ##

*   StandardError is now default exception for rescuing.

## Retryable 1.2.5 ##

*   became friendly to any rubygems version installed

## Retryable 1.2.4 ##

*   added :matching option + better options validation

## Retryable 1.2.3 ##

*   fixed dependencies

## Retryable 1.2.2 ##

*   added :sleep option

## Retryable 1.2.1 ##

*   stability -- Thoroughly unit-tested

## Retryable 1.2.0 ##

*   FIX -- block would run twice when `:tries` was set to `0`. (Thanks for the heads-up to [Tuker](http://github.com/tuker).)
