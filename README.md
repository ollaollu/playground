# README
Running Code:
- run `bundle install`
- run `rails db:create`
- run `rails db:migrate`
- run `rails s`
- run endpoints in postman

Running Spec:
- run `bundle exec rspec spec`

Persistence Structure:
- User
    - email: to uniquely store users in the system
    - name: to identify users before initiating transfers
    - pin: a hashed pin for verifying transactions

- Account
    - balance: to store the balance of the said account
    - currency: to identify which currency account this is

- Account Transactions
    - amount: the amount of the said transaction
    - status: the status of the said transaction whether successful or failed
    - transaction_type: to identify what type of transaction that was stored
    - direction: whether the said transaction was a credit or a debit


Requirements:
[ x ] Create an account
```
Endpoint: http://localhost:3000/users [POST]
Payload: {
    "email": "tony@example.com",
    "name": "tony",
    "pin": 4321,
    "pin_confirmation": 4321
}
Response: {
    "id": 3,
    "email": "tony@gmail.com",
    "name": "tony"
}
```

[ x ] Fund their account with (fake) currency
```
Endpoint: http://localhost:3000/users/:user_id/accounts/:account_id/fund [POST]
Payload: {
    "amount": 123
}
Response; {
    "account": {
        "user_id": 2,
        "balance": "246.0",
        "id": 2,
        "currency": "dollar",
        "created_at": "2023-05-01T17:15:04.781Z",
        "updated_at": "2023-05-02T09:42:49.791Z"
    },
    "message": "Success!"
}
```

[ x ] Securely send money from their account to the account of another user
```
Endpoint: http://localhost:3000/users/:user_id/accounts/:account_id/transfer [POST]
Payload: {
    "recipient_id": "3",
    "pin": 1234,
    "amount": 230.9
}
Response: {
    "account": {
        "balance": "220.0",
        "id": 2,
        "currency": "dollar",
        "user_id": 2,
        "created_at": "2023-05-01T17:15:04.781Z",
        "updated_at": "2023-05-02T10:18:10.332Z"
    },
    "message": "Transfer to tony successful!"
}
```

[ x ] Check their account balance and transactions
```
Account Balance:
Endpoint: http://localhost:3000/users/:user_id/accounts [GET]
Response:
```
{
    "accounts": [
        {
            "id": 2,
            "balance": "235.0",
            "currency": "dollar",
            "user_id": 2,
            "created_at": "2023-05-01T17:15:04.781Z",
            "updated_at": "2023-05-02T09:51:01.630Z"
        }
    ]
}
```

Account Balance:
Endpoint: http://localhost:3000/users/:user_id/accounts/:user_id/account_transactions [GET]
Response:
{
    "account_transactions": [
        {
            "id": 12,
            "amount": "1.0",
            "account_id": 3,
            "status": "success",
            "transaction_type": "transfer",
            "direction": "credit",
            "created_at": "2023-05-02T09:45:59.836Z",
            "updated_at": "2023-05-02T09:45:59.836Z"
        }
    ]
}
```

Next Hi-Priority features:
- Improve security around user account: I opted for a clean email/pin combination as this was very simple/convenient for time window and still to a little extent secure enough.
- Double entry system of accounting: This is so credit/debit can be accounted for seeing as the way money is moved here is not ideal. We could easily lead
- Ensure that transactions are better tracked + idempotency: AccountTransactions only contain the transactions being moved across but ideally, we want to have a model that tracks what transaction was moved i.e we have a Transfer model that tracks sender/recipient and then on the AccountTransaction model, we have a `detail_type` and `detail_id` that will store "Transfer" and "1" respectively. That way, we can always tie account transactions to what triggered them. This direction also allows us to store details of transactions before actually acting on them which means we can do more things like queuing the transfers for later time.
- Notifications: we want to ensure there are notifications for things like funding, transfer being sent/received successfully, account logins as well.
- Extend tests to cover more edge cases as requirements listed are the only test cases covered
- Extend tests to also further cover all guard clauses that were added to the implementation


Extending the application more using the below:
• Send an email notification to the account holder when:
• The account balance is below a user-configurable amount
• The account receives a transfer
• Other triggers may be requested in the future
• Allow account holders to schedule recurring transfers

For these features, I will need to:
- Add a `NotificationJob` worker that will allow us queue notifications in background
- Add a `Notifications` model that will store:
    - `trigger_type`: this will allow us know what model created this notification 
    - `trigger_id`: this will allow us store the id of the model that created this notification
    - `trigger`: this will allow us store the trigger that resulted in this notification
    - `body`: this will allow us to pass the content of the notification along
    - `channel`: this will allow us to specify what type of notification we want to send maybe an email, push or sms notification
    - `status`: this will allow us track when notifications get delivered by the third-party so we can attempt to resend on failures
    - `recipient_id`: this allows us to idempotently fetch a recipient every time the job runs
- Add a `minimum_balance_threshold` to the `accounts` table
- Add an endpoint for a user to configure their `minimum_balance_threshold`
- Then I will add a `AccountTransactionListener` model concern to the `AccountTransaction` table that will create a `Notification` record when some rules are triggered and queue it to be sent using the `NotificationJob`. Some rules to account for:
    - A `balance_below_threshold` rule: this will be triggered after a successful database commit and it will check if the updated balance on the `account` is below the configured threshold. It will only fire when the `direction` is a `debit`.
    - A `transfer incoming` rule: this will be triggered after a `transaction_type` of `transfer` occurs and the `direction` is a `credit`
- Other triggers: Since the approach used above is a rule based callback implementation, we will be able to add other triggers to the `AccountTransactionListener` and when in the callback lifecycle we want to queue a notification for them.

For the `Allow account holders to schedule recurring transfers`:
- I will need to add to the `Transfer` model (mentioned in Hi-Pri) a field `due_at` that will store the date the transfer should happen. If no date is passed, then it will default to the current time. I will also add a `recurring` boolean so as to know this transfer is to be repeated on the same date every month.
- I will need to modify the `/transfer` endpoint to accept a parameter `due_at` that when passed, will simply allow us to store the transfer details but not act on them till that day arrives. The endpont will also allow `recurring` so user can specify if they want this to repeat
- I will need to add a cron that runs every day at a particular time and processes every queued transfer for that day.
- Since we have notifications for when an account transaction happens, the only notification we will need to account for here is when a transaction has failed and if it will be retried or user input will be required to modify the recipient details.
- Gotchas to account for here will be if a user schedules a recurring transfer on the 30th of a month and we end up in February. What we will need to do here is default to the last day of the current month if the month in question does not have the specified day. 

