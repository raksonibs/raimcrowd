# CHANGELOG

## 1.1.0

* Create Payout to pay raised amount of a project to a project owner Bank Account.
* Observe `debit.canceled` event and cancel confirmed contributions.
* Observe `bank_account_verification.verified` event and process pending contributions.
* Observe `bank_account_verification.deposited` event and send an email to Bank Account owner.
* Store `debit.canceled` events on database.
* Store `bank_account_verification.deposited` events on database.
* Create worker to process pending contributions made by `neighborly-balanced-bankaccount` gem.
* Create observers for events.
* Automatically include `User` model changes to main app.
* Import notifications from `neighborly-balanced-creditcard`.
* Rename `PaymentEngines` to `PaymentEngine`.

## 1.0.0

* First version.
* Initializes Balanced API access.
* Provides methods to create/fetch/update customers from Balanced.
* Handles "debit.created" and "debit.succeeded" events from API.
