# CHANGELOG

## 1.1.0

* Add `on_behalf_of` on debit.
* Create Balanced Customer for Project owner when making a debit.
* Add debit `description`.
* Add meta informations on debit.
* Add `appears_on_statement_as` on debit.
* Define payout class on engine configuration.
* Move notifications to `neighborly-balanced`.
* Create an interface class for `PaymentEngine` with engine configurations.
* Rename `PaymentEngines` to `PaymentEngine`.
* Add name and postal code to balanced JS.
* Fix `select_month` and `select_year`.

## 1.0.0

* First version.
* Lists registered cards of current user.
* Generates payments through API.
* Handles events notified by Balanced.
* Selects between additional and inclusive fee calculation.
